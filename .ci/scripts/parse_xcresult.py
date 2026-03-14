#!/usr/bin/env python3
import argparse
import json
import subprocess
from pathlib import Path

def run_json(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return {}
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return {}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--xcresult", required=True)
    parser.add_argument("--output-json", required=True)
    parser.add_argument("--output-md", required=True)
    args = parser.parse_args()

    xcresult = Path(args.xcresult)
    metrics = {
        "testsCount": 0,
        "testsPassed": 0,
        "testsFailed": 0,
        "passRate": 0.0,
    }

    if xcresult.exists():
        root = run_json(["xcrun", "xcresulttool", "get", "--legacy", "--path", str(xcresult), "--format", "json"])
        actions = root.get("actions", {}).get("_values", [])
        for action in actions:
            action_result = action.get("actionResult", {})
            tests_ref = action_result.get("testsRef", {})
            tests_id = tests_ref.get("id", {}).get("_value")
            if not tests_id:
                continue

            tests = run_json([
                "xcrun", "xcresulttool", "get", "--legacy",
                "--path", str(xcresult),
                "--id", tests_id,
                "--format", "json"
            ])

            summary = tests.get("summaries", {}).get("_values", [])
            for item in summary:
                testable_summaries = item.get("testableSummaries", {}).get("_values", [])
                for testable in testable_summaries:
                    tests_count = testable.get("testsCount", {}).get("_value", 0)
                    failed_count = testable.get("failureCount", {}).get("_value", 0)
                    metrics["testsCount"] += int(tests_count)
                    metrics["testsFailed"] += int(failed_count)

        metrics["testsPassed"] = max(metrics["testsCount"] - metrics["testsFailed"], 0)
        if metrics["testsCount"] > 0:
            metrics["passRate"] = round((metrics["testsPassed"] / metrics["testsCount"]) * 100, 2)

    Path(args.output_json).write_text(json.dumps(metrics, indent=2))
    md = [
        "## Test Metrics",
        "",
        f"- Total tests: {metrics['testsCount']}",
        f"- Passed: {metrics['testsPassed']}",
        f"- Failed: {metrics['testsFailed']}",
        f"- Pass rate: {metrics['passRate']}%",
        "",
    ]
    Path(args.output_md).write_text("\n".join(md))

if __name__ == "__main__":
    main()