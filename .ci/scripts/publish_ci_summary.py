#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

def load_metrics(path_str):
    path = Path(path_str)
    if not path.exists():
        return {
            "testsCount": 0,
            "testsPassed": 0,
            "testsFailed": 0,
            "passRate": 0.0,
        }
    return json.loads(path.read_text())

def as_int(value):
    try:
        return int(str(value).strip())
    except Exception:
        return 0

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lint-duration", required=True)
    parser.add_argument("--build-duration", required=True)
    parser.add_argument("--test-duration", required=True)
    parser.add_argument("--archive-duration", required=True)
    parser.add_argument("--export-duration", required=True)
    parser.add_argument("--upload-duration", required=True)
    parser.add_argument("--test-metrics-json", required=True)
    parser.add_argument("--output-md", required=True)
    args = parser.parse_args()

    test_metrics = load_metrics(args.test_metrics_json)

    total = (
        as_int(args.lint_duration)
        + as_int(args.build_duration)
        + as_int(args.test_duration)
        + as_int(args.archive_duration)
        + as_int(args.export_duration)
        + as_int(args.upload_duration)
    )

    lines = [
        "# iOS CI Summary",
        "",
        "## Durations",
        "",
        f"- Lint: {as_int(args.lint_duration)}s",
        f"- Build for testing: {as_int(args.build_duration)}s",
        f"- Test: {as_int(args.test_duration)}s",
        f"- Archive: {as_int(args.archive_duration)}s",
        f"- Export: {as_int(args.export_duration)}s",
        f"- Upload: {as_int(args.upload_duration)}s",
        f"- Total measured time: {total}s",
        "",
        "## Quality Signals",
        "",
        f"- Total tests: {test_metrics['testsCount']}",
        f"- Passed: {test_metrics['testsPassed']}",
        f"- Failed: {test_metrics['testsFailed']}",
        f"- Pass rate: {test_metrics['passRate']}%",
        "",
        "## Notes",
        "",
        "- Build/test metrics are emitted into the GitHub job summary.",
        "- Upload runs only on main, tags, or manual dispatch unless you change conditions.",
        "- Concurrency is capped with workflow cancellation and matrix max-parallel=2.",
    ]

    Path(args.output_md).write_text("\n".join(lines))

if __name__ == "__main__":
    main()