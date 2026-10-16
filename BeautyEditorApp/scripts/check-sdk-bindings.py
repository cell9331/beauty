#!/usr/bin/env python3
"""Check host-owned field/cap mirrors against the configured local SDK sources."""
import re
from pathlib import Path
host = Path(__file__).resolve().parents[1]
project = (host / 'project.yml').read_text()
package = re.search(r'(?m)^  BeautySDK:\n    path: (.+)$', project)
assert package, 'Configured local BeautySDK path missing'
sdk_root = (host / package.group(1).strip().strip('\"\'')).resolve()
assert sdk_root == (host.parent / 'BeautySDK').resolve(), 'Host must use the same-repository SDK'
validation_package = re.search(r'\.package\(path: "([^"]+)"\)', (host / 'Package.swift').read_text())
assert validation_package and (host / validation_package.group(1)).resolve() == sdk_root, 'Validation SDK path drift'
project_reference = re.search(r'isa = XCLocalSwiftPackageReference;\s+relativePath = "([^"]+)";',
                              (host / 'BeautyEditor.xcodeproj/project.pbxproj').read_text())
assert project_reference and (host / project_reference.group(1)).resolve() == sdk_root, 'Xcode SDK path drift'
sdk = sdk_root / 'Sources'
catalog = (host / 'Sources' / 'ToolCatalog.swift').read_text()
state = (host / 'Sources' / 'EditorState.swift').read_text()
limits = dict(re.findall(r'static let (\w+): Float = ([\d.]+)', (sdk / 'BeautyEffects/Planning/BeautySafetyCaps.swift').read_text()))
mirrored = dict(re.findall(r'"(\w+)": ([\d.]+)', catalog))
fields = set(re.findall(r'field: "(\w+)"', catalog))
assert fields == set(mirrored), 'Host limit mirror must cover exactly its canonical fields'
for field in fields:
    assert float(mirrored[field]) == float(limits.get(field, '1.0')), f'Cap drift: {field}'
    assert f'case "{field}": \\BeautyParameters.{field}' in state, f'Binding missing: {field}'
eye_fields = {'eyeSize', 'eyeYPosition', 'eyeHeight', 'eyeLength', 'eyeDistance',
              'pupilSize', 'lowerEyelidDrop', 'eyeTailLift', 'eyeTilt', 'innerCornerOpen', 'outerCornerOpen'}
for field in eye_fields:
    assert re.search(r'field: "' + field + r'", range: \.signed', catalog), f'Eye range drift: {field}'
assert 'eyeSlider.applying(position:' in state and 'eyeSlider.position(in:' in state
brow_helpers = {'eyebrowThickness': 'thickness', 'eyebrowLength': 'length',
                'eyebrowSpacing': 'spacing', 'eyebrowHeadSpacing': 'headSpacing',
                'eyebrowTilt': 'tilt', 'eyebrowPeakDefinition': 'peak'}
assert 'var eyebrowSlider: BeautyEyebrowSlider?' in state
for field, helper in brow_helpers.items():
    assert re.search(r'field: "' + field + r'", range: \.signed', catalog), f'Brow range drift: {field}'
    assert f'case "{field}": .{helper}' in state, f'Brow helper drift: {field}'
assert 'eyebrowSlider.applying(position:' in state and 'eyebrowSlider.position(in:' in state
resolver = (sdk / 'BeautyEffects/Warp/GeometryConflictResolver.swift').read_text()
assert re.search(r'totalThreshold: Float = 1\.0', resolver), 'Legacy geometry budget drift'
assert 'usesDenseMap: Bool = false' in resolver, 'SDK dense combination route missing'
assert 'setValuePreservingGeometryBudget' not in state, 'Obsolete host quota must not return'
assert re.search(r'id: "face.jawline".*field: "jawlineShadow", range: \.unit', catalog)
assert 'field != "jawlineShadow"' in state, 'Photometric jawline must not enter geometry totals'
assert len(fields) == 57
print('57 canonical bindings/caps match the same-repository SDK; centered brow helpers and SDK-owned admission verified')
