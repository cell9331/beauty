"use strict";

const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");

const HTML_PATH = path.join(__dirname, "54-review.html");
const CONTROLLER_PATH = path.join(__dirname, "54-review-controller.js");
const AUTHORIZATION_PATH = path.join(__dirname, "54-rights-authorization-registry.js");
const IMAGE_SAFETY_PATH = path.join(__dirname, "54-image-safety.js");
const missing = [HTML_PATH, CONTROLLER_PATH, AUTHORIZATION_PATH, IMAGE_SAFETY_PATH]
  .filter((candidate) => !fs.existsSync(candidate))
  .map((candidate) => path.basename(candidate));
if (missing.length > 0) {
  throw new Error("RED_MISSING_ARTIFACT:54-review.html,54-review-controller.js");
}

const html = fs.readFileSync(HTML_PATH, "utf8");
const controller = fs.readFileSync(CONTROLLER_PATH, "utf8");
const authorization = fs.readFileSync(AUTHORIZATION_PATH, "utf8");
const imageSafetySource = fs.readFileSync(IMAGE_SAFETY_PATH, "utf8");
const imageSafety = require(IMAGE_SAFETY_PATH);
const source = `${html}\n${authorization}\n${imageSafetySource}\n${controller}`;

const UI_CONSIDERATIONS = [
  "UI-CONSIDERATION-01",
  "UI-CONSIDERATION-02",
  "UI-CONSIDERATION-03",
  "UI-CONSIDERATION-04",
  "UI-CONSIDERATION-05",
  "UI-CONSIDERATION-06",
  "UI-CONSIDERATION-07",
  "UI-CONSIDERATION-08",
];
const UI_ACCEPTANCE = Array.from({ length: 19 }, (_, index) =>
  `UI-AC-${String(index + 1).padStart(2, "0")}`);

const SELECTORS = [
  "manifest-input",
  "asset-directory-input",
  "validation-summary",
  "feature-gates",
  "gate-teeth-whitening",
  "gate-sclera-redness",
  "gate-upper-eyelid-fullness",
  "review-workspace",
  "review-progress",
  "comparison-original",
  "comparison-mask",
  "comparison-after",
  "view-fit",
  "view-actual",
  "judgment-form",
  "previous-item",
  "save-and-next",
  "export-review",
  "session-status",
  "replace-session-dialog",
];

const EXACT_COPY = [
  "本地证据盲审",
  "文件只在当前浏览器标签页中读取，不会上传或保留。",
  "1. 选择评审清单",
  "2. 选择本地资产目录",
  "等待本地评审材料",
  "选择清单和资产目录后开始。页面不会显示文件名或路径。",
  "正在检查本地清单…",
  "正在核对本地资产…",
  "无法开始评审。请修正下列清单或资产问题后重新选择。",
  "材料校验完成，可以开始盲审。",
  "证据门已关闭",
  "证据门已开启",
  "保存并继续",
  "保存评审",
  "导出脱敏评审 JSON",
  "脱敏评审 JSON 已下载。页面不会保留副本。",
  "导出失败。请完成所有必填判断并重试。",
  "重新载入会清除本标签页内尚未导出的评审。继续？",
  "继续载入",
  "保留当前评审",
];

const FIELD_NAMES = [
  "target_present",
  "mask_coverage",
  "protected_leakage",
  "naturalness",
  "structure_changed",
  "decision",
  "reason_code",
];

const REVIEW_REASONS = [
  "none",
  "target_mismatch",
  "insufficient_mask_coverage",
  "protected_leakage",
  "unnatural_result",
  "texture_loss",
  "structure_change",
  "unsupported_input",
];

function count(text, pattern) {
  return [...text.matchAll(pattern)].length;
}

function assertContainsAll(text, values, label) {
  for (const value of values) assert.ok(text.includes(value), `${label}: ${value}`);
}

function assertNoForbiddenRuntime(text) {
  const forbidden = [
    /\bfetch\s*\(/,
    /\bXMLHttpRequest\b/,
    /\bWebSocket\b/,
    /\bEventSource\b/,
    /\bsendBeacon\b/,
    /\bRTCPeerConnection\b/,
    /\b(?:localStorage|sessionStorage|indexedDB|caches|cookie|serviceWorker|clipboard|SharedWorker|Worker)\b/,
    /\.innerHTML\b/,
    /\.outerHTML\b/,
    /insertAdjacentHTML/,
    /document\.write/,
    /https?:\/\//i,
    /<link\b[^>]*href=/i,
    /<form\b[^>]*(?:action|method)=/i,
  ];
  for (const pattern of forbidden) assert.doesNotMatch(text, pattern);
}

function functionSource(name) {
  const start = controller.indexOf(`function ${name}(`);
  assert.notEqual(start, -1, `missing function ${name}`);
  const following = controller.slice(start + 1);
  const next = following.search(/\n  (?:async )?function /);
  return controller.slice(start, next === -1 ? controller.length : start + 1 + next);
}

test("closed inventory is exactly 27 = 8 considerations + 19 acceptance criteria", () => {
  assert.equal(UI_CONSIDERATIONS.length, 8);
  assert.equal(UI_ACCEPTANCE.length, 19);
  assert.equal(new Set([...UI_CONSIDERATIONS, ...UI_ACCEPTANCE]).size, 27);
});

test("stable selectors are unique and complete", () => {
  for (const id of SELECTORS) {
    assert.equal(count(html, new RegExp(`\\bid=["']${id}["']`, "g")), 1, `#${id}`);
  }
});

test("document uses semantic regions controls labels and live feedback", () => {
  assert.match(html, /<header\b/i);
  assert.match(html, /<main\b/i);
  assert.match(html, /<section\b/i);
  assert.match(html, /<form\b[^>]*id=["']judgment-form["']/i);
  assert.match(html, /<fieldset\b/i);
  assert.match(html, /<legend\b/i);
  assert.match(html, /<table\b/i);
  assert.match(html, /role=["']status["']/i);
  assert.match(html, /role=["']alert["']/i);
  assert.match(html, /aria-live=["']polite["']/i);
  for (const field of FIELD_NAMES) {
    assert.match(html, new RegExp(`<label\\b[^>]*for=["']${field}["']`, "i"));
    assert.match(html, new RegExp(`<select\\b[^>]*(?:id|name)=["']${field}["']`, "i"));
  }
});

test("document policy and external same-directory scripts are exact", () => {
  assert.match(html, /http-equiv=["']Content-Security-Policy["']/i);
  for (const directive of [
    "default-src 'none'",
    "script-src 'self'",
    "style-src 'self' 'unsafe-inline'",
    "img-src blob:",
    "connect-src 'none'",
    "font-src 'none'",
    "object-src 'none'",
    "worker-src 'none'",
    "base-uri 'none'",
    "form-action 'none'",
  ]) assert.ok(html.includes(directive), directive);
  assert.doesNotMatch(html, /<script\b(?![^>]*\bsrc=)[^>]*>/i);
  assert.doesNotMatch(html, /\son[a-z]+\s*=/i);
  const coreIndex = html.indexOf('src="54-evidence-core.js"');
  const authorizationIndex = html.indexOf('src="54-rights-authorization-registry.js"');
  const imageSafetyIndex = html.indexOf('src="54-image-safety.js"');
  const controllerIndex = html.indexOf('src="54-review-controller.js"');
  assert.ok(coreIndex >= 0
    && authorizationIndex > coreIndex
    && imageSafetyIndex > authorizationIndex
    && controllerIndex > imageSafetyIndex);
  assertContainsAll(authorization, [
    "createTrustedAuthorizationRegistry",
    "rights_record_id",
    "fixture_id",
    "feature",
    "polarity",
    "permitted_use",
    "evidence_classification",
  ], "trusted authorization registry");
});

test("approved fixed copy and judgment labels are present", () => {
  assertContainsAll(source, EXACT_COPY, "copy");
  assertContainsAll(html, [
    "原图中是否存在目标状态？",
    "遮罩覆盖目标的程度",
    "是否改动了保护区域？",
    "处理结果自然度",
    "是否出现结构变化？",
    "本项目结论",
    "固定原因",
    "1 = 未覆盖，3 = 部分覆盖，5 = 完整且边界准确",
    "1 = 明显不自然，3 = 可见瑕疵，5 = 自然且保留细节",
  ], "judgment copy");
  assertContainsAll(source, REVIEW_REASONS, "review reason");
});

test("all seven judgments start unselected and disable autocomplete", () => {
  for (const field of FIELD_NAMES) {
    const select = html.match(new RegExp(`<select\\b[^>]*(?:id|name)=["']${field}["'][\\s\\S]*?<\\/select>`, "i"));
    assert.ok(select, field);
    assert.match(select[0], /<option\b[^>]*value=["']["'][^>]*(?:selected)?[^>]*>\s*请选择\s*<\/option>/i);
    assert.equal(count(select[0], /\sselected(?:\s|=|>)/gi), 1, `${field} has only placeholder selected`);
  }
  assert.match(html, /<form\b[^>]*autocomplete=["']off["']/i);
});

test("UI-CONSIDERATION-01 empty state remains fail closed", () => {
  assertContainsAll(source, ["waiting", "not_validated", "hidden", "disabled"], "empty-state anchors");
  assert.match(html, /id=["']review-workspace["'][^>]*hidden/i);
  assert.match(html, /id=["']export-review["'][^>]*disabled/i);
  assert.doesNotMatch(html, /id=["']replace-session-dialog["'][^>]*open/i);
});

test("UI-CONSIDERATION-02 loading state disables local initiation and stays bounded", () => {
  assertContainsAll(controller, ["manifest_loading", "assets_loading", "setInputsDisabled"], "loading-state anchors");
  assert.doesNotMatch(source, /spinner|retryAfter|setInterval/i);
});

test("UI-CONSIDERATION-03 error state is fixed redacted and focus-directed", () => {
  assertContainsAll(controller, ["fixedCopyForReason", "focusFirstInvalid", "focusValidationHeading"], "error anchors");
  assert.doesNotMatch(controller, /(?:error|exception)\.message|String\s*\(\s*(?:error|exception)/i);
  assert.doesNotMatch(controller, /textContent\s*=\s*(?:value|raw|path|name|fixture)/i);
});

test("UI-CONSIDERATION-04 populated state has three gates and one active blinded triple", () => {
  assert.deepEqual([
    count(html, /id=["']gate-teeth-whitening["']/g),
    count(html, /id=["']gate-sclera-redness["']/g),
    count(html, /id=["']gate-upper-eyelid-fullness["']/g),
  ], [1, 1, 1]);
  assertContainsAll(html, ["原图", "遮罩", "处理后"], "pane labels");
  assert.match(controller, /项目\s*\$?\{?/);
  assert.match(controller, /已完成\s*\$?\{?/);
});

test("UI-CONSIDERATION-05 partial state never infers a judgment or blocks a complete sibling", () => {
  assertContainsAll(controller, ["partial", "incomplete_asset_triple", "selectedIndex = 0"], "partial anchors");
  assert.match(controller, /evaluateFeature/);
});

test("UI-CONSIDERATION-06 overflow is confined and actions remain reachable", () => {
  assert.match(html, /@media\s*\(max-width:\s*768px\)/i);
  assert.match(html, /@media\s*\(max-width:\s*480px\)/i);
  assert.match(html, /min-height:\s*44px/i);
  assert.match(html, /overflow-x:\s*hidden/i);
  assert.match(html, /\.actual[^}]*overflow:\s*auto/is);
  assert.doesNotMatch(html, /white-space:\s*nowrap/i);
});

test("UI-CONSIDERATION-07 zero one many keeps deterministic counts and exactly three gates", () => {
  assertContainsAll(controller, ["FEATURE_ORDER", "reviewableRows", "completedCount"], "inventory anchors");
  assert.match(controller, /sort\s*\(/);
  assert.equal(count(html, /id=["']gate-[^"']+["']/g), 3);
});

test("UI-CONSIDERATION-08 long text wraps while input-derived content stays absent", () => {
  assert.match(html, /overflow-wrap:\s*anywhere/i);
  assert.match(html, /word-break:\s*break-word/i);
  assert.doesNotMatch(controller, /(?:fixture_id|rights_record_id|webkitRelativePath|\.name)\s*\)?\s*;/i);
});

test("UI-AC-01 initial boundary is closed hidden and disabled", () => {
  assertContainsAll(controller, ["initialState", "not_validated", "resetJudgmentForm"], "initial state");
  assert.match(html, /id=["']review-workspace["'][^>]*hidden/i);
  assert.match(html, /id=["']export-review["'][^>]*disabled/i);
});

test("UI-AC-02 local-only operation forbids network storage external sources and unsafe DOM", () => {
  assertNoForbiddenRuntime(source);
  assert.ok(html.includes("connect-src 'none'"));
  assert.match(controller, /FileReader|\.text\s*\(\s*\)/);
});

test("UI-AC-03 redacted invalid input maps fixed reasons and disables routes", () => {
  assertContainsAll(controller, ["invalid_json", "invalid_path", "unsupported_enum", "duplicate_fixture_id", "missing_asset"], "redacted reasons");
  assertContainsAll(controller, ["disableReview", "disableExport"], "closed invalid routes");
});

test("UI-AC-04 blinded display exposes only item number feature and generic panes", () => {
  assertContainsAll(html, ['alt="原图"', 'alt="遮罩"', 'alt="处理后"'], "generic alt");
  assert.doesNotMatch(html, /data-(?:fixture|polarity|rights|path|file)/i);
  assertContainsAll(controller, ["blindedItemLabel", "friendlyFeatureLabel"], "blinded labels");
});

test("UI-AC-05 original detail validates decode dimensions and synchronized fit actual views", () => {
  assertContainsAll(source, ["naturalWidth", "naturalHeight", "max_decoded_dimension", "max_decoded_pixels", "synchronizeScroll"], "detail validation");
  assertContainsAll(html, ["适合窗口", "100%"], "view modes");
  assert.match(html, /image-rendering:\s*auto/i);
});

function pngHeader(width, height) {
  const bytes = new Uint8Array(24);
  bytes.set([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A], 0);
  bytes.set([0x49, 0x48, 0x44, 0x52], 12);
  new DataView(bytes.buffer).setUint32(16, width, false);
  new DataView(bytes.buffer).setUint32(20, height, false);
  return bytes;
}

function jpegHeader(width, height) {
  return Uint8Array.from([
    0xFF, 0xD8,
    0xFF, 0xC0, 0x00, 0x11, 0x08,
    (height >>> 8) & 0xFF, height & 0xFF,
    (width >>> 8) & 0xFF, width & 0xFF,
    0x03, 0x01, 0x11, 0x00, 0x02, 0x11, 0x00, 0x03, 0x11, 0x00,
  ]);
}

function fakeFile(bytes, type) {
  return {
    size: bytes.byteLength,
    type,
    slice(start, end) {
      const sliced = bytes.slice(start, end);
      return { arrayBuffer: async () => sliced.buffer };
    },
  };
}

test("oversized PNG and JPEG headers reject before Image or object URL creation", async () => {
  const limits = { maxDimension: 4096, maxPixels: 16_000_000 };
  for (const [label, file] of [
    ["PNG dimension", fakeFile(pngHeader(4097, 1), "image/png")],
    ["JPEG dimension", fakeFile(jpegHeader(1, 4097), "image/jpeg")],
    ["PNG pixels", fakeFile(pngHeader(4096, 4096), "image/png")],
  ]) {
    let imageCount = 0;
    let objectURLCount = 0;
    const result = await imageSafety.inspectAndDecode(file, limits, {
      ImageCtor: function InstrumentedImage() { imageCount += 1; },
      createObjectURL() { objectURLCount += 1; return "blob:test"; },
      revokeObjectURL() {},
    });
    assert.equal(result.valid, false, label);
    assert.equal(result.header, false, label);
    assert.equal(imageCount, 0, `${label}: no decoder allocation`);
    assert.equal(objectURLCount, 0, `${label}: no object URL`);
  }
});

test("bounded PNG and JPEG headers proceed to one instrumented decode", async () => {
  const limits = { maxDimension: 4096, maxPixels: 16_000_000 };
  for (const [file, width, height] of [
    [fakeFile(pngHeader(800, 600), "image/png"), 800, 600],
    [fakeFile(jpegHeader(640, 480), "image/jpeg"), 640, 480],
  ]) {
    let objectURLCount = 0;
    let revokeCount = 0;
    class InstrumentedImage {
      constructor() {
        this.naturalWidth = width;
        this.naturalHeight = height;
        this.listeners = new Map();
      }
      addEventListener(name, callback) { this.listeners.set(name, callback); }
      set src(_) { this.listeners.get("load")(); }
    }
    const result = await imageSafety.inspectAndDecode(file, limits, {
      ImageCtor: InstrumentedImage,
      createObjectURL() { objectURLCount += 1; return "blob:test"; },
      revokeObjectURL() { revokeCount += 1; },
    });
    assert.deepEqual(result, { valid: true, naturalWidth: width, naturalHeight: height });
    assert.equal(objectURLCount, 1);
    assert.equal(revokeCount, 1);
  }
});

test("UI-AC-06 required judgments save exact fields focus first invalid and advance once", () => {
  assertContainsAll(controller, FIELD_NAMES, "judgment fields");
  assertContainsAll(controller, ["collectJudgment", "issueReviewCandidate", "focusFirstInvalid", "advanceOnce"], "save flow");
});

test("UI-AC-07 no implicit approval delegates reason consistency to core", () => {
  assert.match(controller, /ReviewCore\.createReview/);
  assert.doesNotMatch(controller, /decision\s*:\s*["']accept["']/);
  assert.doesNotMatch(controller, /reason_code\s*:\s*["']none["']/);
});

test("UI-AC-08 progress navigation restores revisions and confirms replacement", () => {
  assertContainsAll(controller, ["savedReviews", "restoreJudgment", "previous-item", "save-and-next", "replace-session-dialog"], "navigation");
  assertContainsAll(controller, ["showModal", "returnValue", "restoreInitiatorFocus"], "replacement");
});

test("manifest replacement invalidates prior session before every fail-closed check", () => {
  const acceptance = functionSource("acceptManifestFile");
  const assetAcceptance = functionSource("acceptAssetFiles");
  const invalidation = functionSource("invalidateManifestCandidateState");
  const clearState = functionSource("clearReviewSessionState");
  assert.ok(
    acceptance.indexOf("invalidateManifestCandidateState()") < acceptance.indexOf("file.size"),
    "oversized manifest cannot retain the prior session",
  );
  assert.ok(
    acceptance.indexOf("invalidateManifestCandidateState()") < acceptance.indexOf("JSON.parse"),
    "invalid JSON cannot retain the prior session",
  );
  assert.ok(
    acceptance.indexOf("invalidateManifestCandidateState()") < acceptance.indexOf("ReviewCore.validateManifest"),
    "schema-invalid manifest cannot retain the prior session",
  );
  assertContainsAll(invalidation, [
    "replacesExistingManifest = manifest !== null",
    "clearReviewSessionState()",
    "manifest = null",
    "assetFiles = new Map()",
    'assetInput.value = ""',
  ], "manifest invalidation");
  assertContainsAll(clearState, [
    "revokeActiveObjectURLs()",
    "activeSnapshot = null",
    "reviewableRows = []",
    "savedReviews.clear()",
    "resetJudgmentForm()",
    "resetFeatureSnapshots()",
  ], "session invalidation");
  assert.ok(
    assetAcceptance.indexOf("if (!manifest)") < assetAcceptance.indexOf("ReviewCore.createReviewSnapshot"),
    "a later asset selection cannot evaluate against a rejected prior manifest",
  );
});

test("replacement confirmation preserves dialog choice focus and type-specific valid reload", () => {
  const confirmation = functionSource("confirmReplacement");
  const processing = functionSource("processReplacement");
  const assetAcceptance = functionSource("acceptAssetFiles");
  assertContainsAll(confirmation, [
    'returnValue = "replace"',
    "pendingReplacement = null",
    "focusTarget = replacementInitiator",
    "replacementInitiator = null",
    "processReplacement(replacement, focusTarget)",
  ], "confirmed replacement");
  assert.doesNotMatch(confirmation, /teardownSession\s*\(/);
  assertContainsAll(processing, ["acceptManifestFile", "acceptAssetFiles"], "replacement dispatch");
  assert.ok(
    processing.indexOf("await acceptManifestFile") < processing.indexOf("focusTarget.focus()")
      && processing.indexOf("await acceptAssetFiles") < processing.indexOf("focusTarget.focus()"),
    "confirmed replacement restores focus only after the async load reaches a terminal state",
  );
  assert.ok(
    assetAcceptance.indexOf("invalidateAssetCandidateState()") < assetAcceptance.indexOf("buildExactFileIndex"),
    "asset replacement clears old media and reviews before indexing new files",
  );
  assertContainsAll(functionSource("keepCurrentSession"), [
    'returnValue = "keep"',
    "pendingReplacement = null",
    "restoreInitiatorFocus()",
  ], "keep-current dialog behavior");
});

test("UI-AC-09 mechanics exclusion uses decoded selected product rows only", () => {
  assert.match(controller, /snapshot\.review_rows\s*\|\|\s*snapshot\.selected_rows/);
  assert.match(controller, /ReviewCore\.createClosedSnapshot\(feature\)/);
  assert.match(controller, /decodedProductRows/);
  assert.match(controller, /snapshot\.selected_rows\.filter/);
  assert.match(controller, /decodedDimensions\.has\(row\.fixture_id\)/);
  assert.doesNotMatch(controller, /mechanics[^\n]*(?:\+\+|\+=)|naturalness[^\n]*mechanics/i);
});

test("UI-AC-09 reviews are core-issued and clones cannot enter saved product state", () => {
  const issue = functionSource("issueReviewCandidate");
  const save = functionSource("saveCurrentReview");
  assertContainsAll(issue, ["ReviewCore.createReview(activeSnapshot, review)", "return null"], "review issuance");
  assert.match(save, /savedReviews\.set\(review\.fixture_id, review\)/);
  assert.doesNotMatch(save, /Object\.freeze\(\{\s*\.\.\.review\s*\}\)/);
});

test("UI-AC-10 independent gates evaluate fixed feature snapshots separately", () => {
  assertContainsAll(controller, ["teeth_whitening", "sclera_redness", "upper_eyelid_fullness"], "features");
  assert.match(controller, /ReviewCore\.evaluateFeature/);
  assert.doesNotMatch(controller, /overall(?:Gate|Status|Decision)/);
});

test("UI-AC-11 frozen acceptance is delegated to immutable ReviewCore snapshot", () => {
  assert.match(controller, /ReviewCore\.createReviewSnapshot/);
  assert.match(controller, /RightsAuthorizationRegistry/);
  assert.doesNotMatch(controller, /mask_coverage\s*[<>]=?\s*4|naturalness\s*[<>]=?\s*4/);
  assert.doesNotMatch(controller, /rowPasses\s*=|function\s+rowPasses/);
});

test("UI-AC-12 upper eyelid renders both current fixed closure reasons", () => {
  assertContainsAll(source, ["missing_genuine_positive", "non_warp_design_unqualified"], "eyelid reasons");
  assert.doesNotMatch(controller, /eyeHeight|upperEyelidLift|brow|darkCircle|eyeBag/);
});

test("UI-AC-13 closed result remains a completed exportable outcome", () => {
  assertContainsAll(controller, ["reviewsComplete", "decisionsResolved", "enableExport"], "closed export");
  assert.doesNotMatch(controller, /status\s*!==?\s*["']open["'][^\n]*disableExport/);
});

test("UI-AC-14 deterministic export uses core bytes and one fixed filename", () => {
  assert.match(controller, /ReviewCore\.serializeDurableExport/);
  assert.equal(count(controller, /beauty-evidence-review-v1\.json/g), 1);
  assert.doesNotMatch(controller, /Date\s*\(|Date\.now|toISOString|Math\.random|localeCompare/);
});

test("UI-AC-15 export privacy never previews or copies rich input", () => {
  assert.doesNotMatch(html, /<textarea\b/i);
  assert.doesNotMatch(controller, /JSON\.stringify\s*\(\s*(?:manifest|state|snapshot)/i);
  assert.doesNotMatch(controller, /navigator\.clipboard|execCommand\s*\(\s*["']copy/i);
});

test("UI-AC-16 ephemeral media owns at most three active URLs and revokes every lifecycle", () => {
  assert.match(controller, /activeObjectURLs/);
  assert.match(controller, /URL\.createObjectURL/);
  assert.match(controller, /URL\.revokeObjectURL/);
  assertContainsAll(controller, ["revokeActiveObjectURLs", "pagehide", "export"], "URL lifecycle");
  assert.doesNotMatch(source, /localStorage|sessionStorage|indexedDB/);
});

test("UI-AC-17 accessibility preserves labels focus ring dialog trap and restoration", () => {
  assert.match(html, /:focus-visible\s*\{[^}]*outline:\s*3px/is);
  assert.match(html, /outline-offset:\s*2px/i);
  assertContainsAll(controller, ["trapDialogFocus", "Escape", "restoreInitiatorFocus"], "dialog focus");
  assert.match(html, /aria-live=["']polite["']/i);
});

test("UI-AC-18 responsive behavior covers 1200 768 480 320 zoom and reduced motion", () => {
  assertContainsAll(html, ["1200px", "768px", "480px", "320px", "prefers-reduced-motion"], "responsive anchors");
  assert.match(html, /min-height:\s*44px/i);
  assert.match(html, /max-width:\s*1200px/i);
});

test("UI-AC-19 production scope contains no SDK Demo candidate or realtime import", () => {
  assert.doesNotMatch(source, /BeautySDK|BeautyDemo|BeautyParameters|BeautyEngine|pixelBuffer|realtime/i);
  assert.doesNotMatch(source, /teethWhitening|scleraRednessReduction|upperEyelidFullnessReduction/);
});
