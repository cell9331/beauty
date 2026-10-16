#!/usr/bin/env python3
"""Check the retained Figma vector payloads and their production call sites."""
from pathlib import Path
import hashlib
import json
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "design-assets.json").read_text())
swift = "\n".join(p.read_text() for p in (root / "Sources").glob("*.swift"))
tools = set(re.findall(r'ToolDefinition\(id: "([^"]+)"', swift))
catalog = (root / "Sources" / "ToolCatalog.swift").read_text()
symbol_section = catalog.split('static let systemSymbols: [String: String] = [', 1)[1].split(']', 1)[0]
symbol_tools = set(re.findall(r'"(eye\.[^"]+)": "[^"]+"', symbol_section))
assert symbol_tools == {"eye.size", "eye.positionY", "eye.length", "eye.spacing", "eye.irisSize"}
assert symbol_tools <= tools
assert 'Image(systemName: symbol)' in swift and 'ToolCatalog.systemSymbols[id]' in swift
expected = {name.replace(".", "_") for name in tools - symbol_tools} | {
    "slider_thumb", "protection_off", "protection_on", "action_close", "action_confirm", "smart_indicator"
}
actual = {row["name"] for row in manifest["assets"]}
assert actual == expected and len(actual) == manifest["asset_count"] == 60
for row in manifest["assets"]:
    name = row["name"]
    folder = root / "Sources" / "Assets.xcassets" / f"{name}.imageset"
    contents = json.loads((folder / "Contents.json").read_text())
    assert contents["images"][0]["filename"] == f"{name}.svg"
    data = (folder / f"{name}.svg").read_bytes()
    assert len(data) == row["bytes"] > 0
    assert hashlib.sha256(data).hexdigest() == row["sha256"]
    svg = ET.fromstring(data)
    assert svg.attrib["width"] == row["width"] and svg.attrib["height"] == row["height"]
    assert float(row["width"]) > 0 and float(row["height"]) > 0
    assert any(node.tag.split("}")[-1] in {"path", "rect", "circle", "ellipse", "polygon", "polyline"} for node in svg.iter())
assert not re.search(r'https?://', swift), "Runtime must not depend on a temporary Figma URL"
print(json.dumps({"status": "passed", "assets": len(actual), "tool_icons": len(tools), "native_symbol_tools": len(symbol_tools), "runtime_remote_urls": 0}))
