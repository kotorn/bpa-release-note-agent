"""Command-line interface for ReleaseChangeV1 validation."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from .validator import find_duplicates, load_hash_registry, load_schema, validate_payload

EXIT_VALID = 0
EXIT_INVALID = 2
EXIT_DUPLICATE = 3
EXIT_USAGE = 4


def repository_root() -> Path:
    return Path(__file__).resolve().parents[2]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="bpa-release-validate",
        description="Validate one or more ReleaseChangeV1 JSON payloads.",
    )
    parser.add_argument("payloads", nargs="+", type=Path)
    parser.add_argument(
        "--schema",
        type=Path,
        default=repository_root() / "schema" / "ReleaseChangeV1.schema.json",
    )
    parser.add_argument("--registry", type=Path)
    parser.add_argument("--quiet", action="store_true")
    return parser


def read_payload(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError("payload root must be a JSON object")
    return value


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    try:
        args = parser.parse_args(argv)
        schema = load_schema(args.schema)
        registry = load_hash_registry(args.registry)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return EXIT_USAGE

    valid_hashes: list[str] = []
    invalid_found = False

    for payload_path in args.payloads:
        try:
            payload = read_payload(payload_path)
        except (OSError, ValueError, json.JSONDecodeError) as error:
            print(f"ERROR {payload_path.name}: {error}", file=sys.stderr)
            return EXIT_USAGE

        errors = validate_payload(payload, schema)
        if errors:
            invalid_found = True
            for error in errors:
                print(f"INVALID {payload_path.name}: {error}", file=sys.stderr)
            continue

        valid_hashes.append(payload["changeHash"])
        if not args.quiet:
            print(f"VALID {payload_path.name}")

    if invalid_found:
        return EXIT_INVALID

    duplicates = find_duplicates(valid_hashes, registry)
    if duplicates:
        for duplicate in sorted(duplicates):
            print(f"DUPLICATE changeHash={duplicate}", file=sys.stderr)
        return EXIT_DUPLICATE

    return EXIT_VALID


if __name__ == "__main__":
    raise SystemExit(main())

