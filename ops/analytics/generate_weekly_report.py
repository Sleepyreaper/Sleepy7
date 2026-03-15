from __future__ import annotations

import csv
import datetime as dt
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "ops" / "analytics" / "input"
OUTPUT = ROOT / "ops" / "analytics" / "output"
README = ROOT / "README.md"

OUTPUT.mkdir(parents=True, exist_ok=True)

TODAY = dt.date.today()
WEEK_START = TODAY - dt.timedelta(days=7)


def parse_date(value: str) -> dt.date:
    for fmt in ("%Y-%m-%d", "%m/%d/%Y", "%Y/%m/%d"):
        try:
            return dt.datetime.strptime(value.strip(), fmt).date()
        except ValueError:
            continue
    raise ValueError(f"Unsupported date format: {value}")


def load_csv(path: Path):
    if not path.exists():
        return []
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def money(value: str) -> float:
    cleaned = (value or "").replace("$", "").replace(",", "").strip()
    return float(cleaned) if cleaned else 0.0


def sum_since(rows, date_key: str, amount_key: str) -> float:
    total = 0.0
    for row in rows:
        try:
            row_date = parse_date(row[date_key])
        except Exception:
            continue
        if row_date >= WEEK_START:
            total += money(row.get(amount_key, "0"))
    return round(total, 2)


def update_readme_badges(summary: dict):
    badge_block = f"""<!-- monetization-badges:start -->
![Weekly IAP Revenue](https://img.shields.io/badge/Weekly%20IAP-${summary['iap_revenue']:.2f}-brightgreen)
![Weekly Ad Revenue](https://img.shields.io/badge/Weekly%20Ads-${summary['ad_revenue']:.2f}-blue)
![Weekly Ad Spend](https://img.shields.io/badge/Weekly%20Spend-${summary['ad_spend']:.2f}-orange)
![Weekly Net](https://img.shields.io/badge/Weekly%20Net-${summary['net_revenue']:.2f}-purple)
<!-- monetization-badges:end -->"""

    if README.exists():
        content = README.read_text(encoding="utf-8")
    else:
        content = "# Sleepy7\n\n"

    start = "<!-- monetization-badges:start -->"
    end = "<!-- monetization-badges:end -->"

    if start in content and end in content:
        prefix = content.split(start)[0]
        suffix = content.split(end)[1]
        content = prefix + badge_block + suffix
    else:
        content += "\n## Weekly Monetization\n\n" + badge_block + "\n"

    README.write_text(content, encoding="utf-8")


def main():
    iap_rows = load_csv(INPUT / "app_store_iap.csv")
    admob_rows = load_csv(INPUT / "admob_report.csv")
    spend_rows = load_csv(INPUT / "ad_spend.csv")

    iap_revenue = sum_since(iap_rows, "Date", "Developer Proceeds")
    ad_revenue = sum_since(admob_rows, "Date", "Estimated earnings")
    ad_spend = sum_since(spend_rows, "Date", "Spend")
    net_revenue = round(iap_revenue + ad_revenue - ad_spend, 2)

    summary = {
        "generated_at": dt.datetime.utcnow().isoformat() + "Z",
        "week_start": WEEK_START.isoformat(),
        "week_end": TODAY.isoformat(),
        "iap_revenue": iap_revenue,
        "ad_revenue": ad_revenue,
        "ad_spend": ad_spend,
        "net_revenue": net_revenue,
    }

    (OUTPUT / "weekly_summary.json").write_text(
        json.dumps(summary, indent=2),
        encoding="utf-8",
    )

    md = f"""# Weekly Monetization Summary

- Week start: {summary['week_start']}
- Week end: {summary['week_end']}
- IAP revenue: ${summary['iap_revenue']:.2f}
- Ad revenue: ${summary['ad_revenue']:.2f}
- Ad spend: ${summary['ad_spend']:.2f}
- Net revenue: ${summary['net_revenue']:.2f}
"""
    (OUTPUT / "weekly_summary.md").write_text(md, encoding="utf-8")

    update_readme_badges(summary)


if __name__ == "__main__":
    main()