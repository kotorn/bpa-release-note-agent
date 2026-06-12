from __future__ import annotations

import copy
import json
import tempfile
import unittest
from pathlib import Path

from bpa_release_validate.cli import (
    EXIT_DUPLICATE,
    EXIT_INVALID,
    EXIT_USAGE,
    EXIT_VALID,
    main,
)
from bpa_release_validate.validator import (
    canonical_change_hash,
    load_schema,
    validate_payload,
)

ROOT = Path(__file__).resolve().parents[2]
SCHEMA_PATH = ROOT / "schema" / "ReleaseChangeV1.schema.json"
SAMPLE_PATH = ROOT / "samples" / "release-change-workflow.json"


def sample_payload() -> dict:
    with SAMPLE_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


class ValidatorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.schema = load_schema(SCHEMA_PATH)

    def write_payload(self, directory: Path, name: str, payload: dict) -> Path:
        path = directory / name
        path.write_text(json.dumps(payload), encoding="utf-8")
        return path

    def test_valid_payload(self) -> None:
        payload = sample_payload()
        self.assertEqual([], validate_payload(payload, self.schema))

    def test_invalid_payload(self) -> None:
        payload = sample_payload()
        payload["environment"] = "unknown"
        errors = validate_payload(payload, self.schema)
        self.assertTrue(any("environment" in error for error in errors))

    def test_missing_evidence(self) -> None:
        payload = sample_payload()
        del payload["afterEvidence"]
        errors = validate_payload(payload, self.schema)
        self.assertTrue(any("afterEvidence" in error for error in errors))

    def test_hash_mismatch(self) -> None:
        payload = sample_payload()
        payload["businessReason"] = "This changes the canonical hash input."
        errors = validate_payload(payload, self.schema)
        self.assertIn("changeHash: does not match canonical payload hash", errors)

    def test_malformed_json_returns_usage_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "malformed.json"
            path.write_text("{", encoding="utf-8")
            result = main(["--schema", str(SCHEMA_PATH), str(path)])
        self.assertEqual(EXIT_USAGE, result)

    def test_cli_invalid_returns_invalid_exit(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            payload = sample_payload()
            payload["changeType"] = "unsupported"
            path = self.write_payload(Path(temp), "invalid.json", payload)
            result = main(["--schema", str(SCHEMA_PATH), str(path)])
        self.assertEqual(EXIT_INVALID, result)

    def test_duplicate_hash_in_batch(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            first = self.write_payload(Path(temp), "first.json", sample_payload())
            second = self.write_payload(Path(temp), "second.json", sample_payload())
            result = main(
                ["--schema", str(SCHEMA_PATH), str(first), str(second)]
            )
        self.assertEqual(EXIT_DUPLICATE, result)

    def test_duplicate_hash_in_registry(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            payload = sample_payload()
            payload_path = self.write_payload(Path(temp), "payload.json", payload)
            registry_path = Path(temp) / "registry.json"
            registry_path.write_text(
                json.dumps([payload["changeHash"]]), encoding="utf-8"
            )
            result = main(
                [
                    "--schema",
                    str(SCHEMA_PATH),
                    "--registry",
                    str(registry_path),
                    str(payload_path),
                ]
            )
        self.assertEqual(EXIT_DUPLICATE, result)

    def test_release_id_and_timestamp_do_not_change_hash(self) -> None:
        original = sample_payload()
        changed = copy.deepcopy(original)
        changed["releaseId"] = "RN-SYNTH-9999"
        changed["timestamp"] = "2026-06-13T08:00:00Z"
        self.assertEqual(
            canonical_change_hash(original), canonical_change_hash(changed)
        )

    def test_cli_valid_returns_zero(self) -> None:
        result = main(["--schema", str(SCHEMA_PATH), str(SAMPLE_PATH)])
        self.assertEqual(EXIT_VALID, result)


if __name__ == "__main__":
    unittest.main()

