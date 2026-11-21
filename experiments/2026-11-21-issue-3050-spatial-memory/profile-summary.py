"""Summarizes DuckDB JSON profiles: peak buffer memory, peak temporary
directory size, and every operator whose details name a top-N aggregate
(arg_min_nulls_last) or that is a window, with its time summed over threads.
Engine 1.5 and 2.0 name the fields differently.

Usage: python3 -I profile-summary.py <profile.json> ...
Handbook: none; supports duckdb/duckdb-r#3050.
"""

import json
import sys


def walk(node, found):
    name = node.get("operator_name", node.get("type"))
    info = node.get("extra_info", {})
    if "nulls_last" in json.dumps(info) or "WINDOW" in str(name):
        found.append((name, node.get("operator_timing", node.get("timing")), info.get("Aggregates", "")))
    for child in node.get("children", []):
        walk(child, found)


for path in sys.argv[1:]:
    with open(path) as f:
        profile = json.load(f)
    system = profile.get("system", profile)
    buffer = system.get("peak_buffer_memory", system.get("system_peak_buffer_memory"))
    temp = system.get("peak_temp_dir_size", system.get("system_peak_temp_dir_size"))
    print(f"{path}: peak buffer memory {buffer / 2**20:.0f} MiB, peak temp dir {temp / 2**20:.0f} MiB")
    found = []
    for root in profile.get("operator", profile.get("children", [])):
        walk(root, found)
    for name, timing, aggregates in found:
        print(f"  {name}: {timing:.2f} s {aggregates}")
