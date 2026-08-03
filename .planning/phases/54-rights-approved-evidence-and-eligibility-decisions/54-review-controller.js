(function runLocalEvidenceReviewer() {
  "use strict";

  const ReviewCore = globalThis.ReviewCore;
  const RightsAuthorizationRegistry = globalThis.RightsAuthorizationRegistry;
  const ImageSafety = globalThis.ImageSafety;
  const FEATURE_ORDER = [
    "teeth_whitening",
    "sclera_redness",
    "upper_eyelid_fullness",
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
  const FIXED_COPY = Object.freeze({
    manifest_loading: "正在检查本地清单…",
    assets_loading: "正在核对本地资产…",
    invalid: "无法开始评审。请修正下列清单或资产问题后重新选择。",
    ready: "材料校验完成，可以开始盲审。",
    export_success: "脱敏评审 JSON 已下载。页面不会保留副本。",
    export_failure: "导出失败。请完成所有必填判断并重试。",
  });
  const REASON_COPY = Object.freeze({
    invalid_json: "清单不是有效的 JSON。",
    invalid_path: "清单包含不受支持的资产位置。",
    unsupported_enum: "清单包含不支持的字段值。",
    duplicate_fixture_id: "清单包含重复的项目标识。",
    missing_asset: "项目缺少完整的原图、遮罩或处理后资产。",
    invalid_asset_type: "本地资产必须是匹配扩展名的 JPEG 或 PNG 图像。",
    asset_size_invalid: "本地资产超出允许的大小。",
    decode_failed: "本地资产无法作为图像读取。",
    dimension_invalid: "本地资产的图像尺寸不受支持。",
    dimension_mismatch: "同一项目的三张图像尺寸必须一致。",
    manifest_size_invalid: "评审清单超出允许的大小。",
    invalid_manifest: "评审清单结构不符合要求。",
    incomplete_asset_triple: "项目缺少完整的原图、遮罩或处理后资产。",
    missing_genuine_positive: "当前功能缺少合格的真实正例。",
    missing_genuine_negative: "当前功能缺少合格的真实反例。",
    unapproved_fixture: "当前功能包含未获批准的评审材料。",
    review_incomplete: "当前功能仍有项目尚未完成评审。",
    review_rejected: "当前功能包含未通过冻结规则的项目。",
    non_warp_design_unqualified: "去脂的非形变方案尚未通过资格审查。",
    review_invalid: "请完成七项结构化判断，并修正不一致的结论。",
    capability_unavailable: "当前环境不支持所需的本地文件读取能力。",
    local_read_failed: "本地资产读取失败。请重新选择评审材料。",
  });
  const FEATURE_LABELS = Object.freeze({
    teeth_whitening: "白牙",
    sclera_redness: "祛红血丝",
    upper_eyelid_fullness: "去脂",
  });
  const MIME_BY_EXTENSION = Object.freeze({
    jpg: "image/jpeg",
    jpeg: "image/jpeg",
    png: "image/png",
  });
  const EXPORT_FILENAME = "beauty-evidence-review-v1.json";

  const element = (id) => document.getElementById(id);
  const manifestInput = element("manifest-input");
  const assetInput = element("asset-directory-input");
  const workspace = element("review-workspace");
  const exportButton = element("export-review");
  const replaceDialog = element("replace-session-dialog");
  const comparisonGrid = element("comparison-grid");
  const comparisonScrollers = Array.from(document.querySelectorAll(".comparison-scroller"));
  const imageElements = [element("image-original"), element("image-mask"), element("image-after")];

  const initialState = Object.freeze({
    phase: "waiting",
    gate_status: "not_validated",
    workspace: "hidden",
    export: "disabled",
  });

  let manifest = null;
  let activeSnapshot = null;
  let assetFiles = new Map();
  let reviewableRows = [];
  let selectedIndex = 0;
  let completedCount = 0;
  let activeObjectURLs = [];
  let decodedDimensions = new Map();
  let hasBlockingAssetErrors = false;
  let pendingReplacement = null;
  let replacementInitiator = null;
  const savedReviews = new Map();
  const featureSnapshots = new Map();

  function closedSnapshot(feature) {
    return ReviewCore.createClosedSnapshot(feature);
  }

  function resetFeatureSnapshots() {
    featureSnapshots.clear();
    for (const feature of FEATURE_ORDER) featureSnapshots.set(feature, closedSnapshot(feature));
  }

  function fixedCopyForReason(reason) {
    return REASON_COPY[reason] || REASON_COPY.invalid_manifest;
  }

  function friendlyFeatureLabel(feature) {
    return FEATURE_LABELS[feature] || "功能";
  }

  function blindedItemLabel(position, total) {
    return `项目 ${position} / ${total}`;
  }

  function replaceProblems(reasons) {
    const items = reasons.map((reason) => {
      const item = document.createElement("li");
      item.textContent = fixedCopyForReason(reason);
      return item;
    });
    element("validation-problems").replaceChildren(...items);
  }

  function setValidation(heading, guidance, reasons, status) {
    element("validation-heading").textContent = heading;
    element("validation-guidance").textContent = guidance;
    replaceProblems(reasons);
    element("session-status").textContent = status;
  }

  function focusValidationHeading() {
    element("validation-summary").focus();
  }

  function setInputsDisabled(disabled) {
    manifestInput.disabled = disabled;
    assetInput.disabled = disabled;
  }

  function disableReview() {
    workspace.hidden = true;
  }

  function disableExport() {
    exportButton.disabled = true;
  }

  function enableExport() {
    exportButton.disabled = false;
  }

  function resetJudgmentForm() {
    element("judgment-form").reset();
    for (const field of FIELD_NAMES) element(field).selectedIndex = 0;
    element("form-alert").textContent = "";
  }

  function revokeActiveObjectURLs() {
    for (const url of activeObjectURLs) {
      try { URL.revokeObjectURL(url); } catch (_) { /* attempt every owned URL */ }
    }
    activeObjectURLs = [];
    for (const image of imageElements) {
      try { image.removeAttribute("src"); } catch (_) { /* keep clearing siblings */ }
    }
  }

  function closeInitialState() {
    revokeActiveObjectURLs();
    disableReview();
    disableExport();
    resetJudgmentForm();
    resetFeatureSnapshots();
    renderInitialGates();
    setValidation(
      "等待本地评审材料",
      "选择清单和资产目录后开始。页面不会显示文件名或路径。",
      [],
      "",
    );
  }

  function clearReviewSessionState() {
    revokeActiveObjectURLs();
    activeSnapshot = null;
    reviewableRows = [];
    selectedIndex = 0;
    completedCount = 0;
    decodedDimensions = new Map();
    hasBlockingAssetErrors = false;
    savedReviews.clear();
    resetJudgmentForm();
    resetFeatureSnapshots();
    renderInitialGates();
  }

  function invalidateManifestCandidateState() {
    const replacesExistingManifest = manifest !== null;
    clearReviewSessionState();
    manifest = null;
    if (replacesExistingManifest) {
      assetFiles = new Map();
      assetInput.value = "";
    }
  }

  function invalidateAssetCandidateState() {
    clearReviewSessionState();
    assetFiles = new Map();
  }

  function renderInitialGates() {
    for (const feature of FEATURE_ORDER) {
      renderGate(feature, {
        status: "closed",
        reasons: ["not_validated"],
        positive: 0,
        negative: 0,
        reviewed: 0,
      });
    }
  }

  function renderGate(feature, presentation) {
    const row = element(`gate-${feature.replaceAll("_", "-")}`);
    const badge = row.querySelector(".gate-badge");
    const counts = row.querySelector(".gate-counts");
    const reasons = row.querySelector(".gate-reasons");
    const isOpen = presentation.status === "open";
    badge.textContent = isOpen ? "证据门已开启" : "证据门已关闭";
    badge.classList.toggle("open", isOpen);
    badge.classList.toggle("closed", !isOpen);
    counts.textContent = `正例 ${presentation.positive} · 反例 ${presentation.negative} · 已评审 ${presentation.reviewed}`;
    reasons.textContent = presentation.reasons[0] === "not_validated"
      ? "尚未校验"
      : presentation.reasons.map(fixedCopyForReason).join(" ");
  }

  function presentationForSnapshot(snapshot) {
    let decision;
    const decodedProductRows = snapshot === activeSnapshot
      ? snapshot.selected_rows.filter((row) => decodedDimensions.has(row.fixture_id))
      : snapshot.selected_rows;
    const selectedReviewCount = snapshot.selected_rows.reduce(
      (count, row) => count + (savedReviews.has(row.fixture_id) ? 1 : 0),
      0,
    );
    if (snapshot.ready && selectedReviewCount === snapshot.selected_rows.length) {
      const reviews = snapshot.selected_rows.map((row) => savedReviews.get(row.fixture_id));
      decision = ReviewCore.evaluateFeature(snapshot, reviews, designQualificationFor(snapshot.feature));
    } else if (snapshot.ready) {
      decision = {
        status: "closed",
        reasons: ["review_incomplete"],
        reviewed_count: selectedReviewCount,
      };
    } else {
      decision = ReviewCore.evaluateFeature(snapshot, [], designQualificationFor(snapshot.feature));
    }
    return {
      status: decision.status,
      reasons: decision.reasons,
      positive: decodedProductRows.filter((row) => row.polarity === "positive").length,
      negative: decodedProductRows.filter((row) => row.polarity === "negative").length,
      reviewed: decision.reviewed_count,
    };
  }

  function designQualificationFor(feature) {
    if (feature !== "upper_eyelid_fullness") return undefined;
    return {
      feature: "upper_eyelid_fullness",
      reviewed: false,
      decision: "unqualified",
      method_class: "invalidated_interior_warp",
    };
  }

  function renderActiveGate() {
    if (activeSnapshot) renderGate(activeSnapshot.feature, presentationForSnapshot(activeSnapshot));
  }

  function renderResolvedGates() {
    for (const feature of FEATURE_ORDER) {
      const snapshot = featureSnapshots.get(feature);
      renderGate(feature, presentationForSnapshot(snapshot));
    }
  }

  function readFileText(file) {
    if (typeof file.text === "function") return file.text();
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.addEventListener("load", () => resolve(typeof reader.result === "string" ? reader.result : ""));
      reader.addEventListener("error", () => reject(new Error("read_failed")));
      reader.readAsText(file, "utf-8");
    });
  }

  function classifyCoreReason(reason) {
    if (reason === "asset_key_invalid") return "invalid_path";
    if (reason === "fixture_id_duplicate") return "duplicate_fixture_id";
    if (reason.endsWith("_invalid") || reason === "polarity_not_predeclared") return "unsupported_enum";
    return reason;
  }

  function selectedRootRelativeKey(file) {
    const relative = String(file["webkitRelativePath"] || "");
    const segments = relative.split("/");
    if (segments.length < 2) return null;
    const key = segments.slice(1).join("/");
    const normalized = ReviewCore.normalizeRelativeAssetKey(key);
    return normalized.valid ? normalized.key : null;
  }

  function fileMatchesKey(file, key) {
    const suffix = key.split(".").at(-1).toLowerCase();
    return Object.hasOwn(MIME_BY_EXTENSION, suffix) && file.type === MIME_BY_EXTENSION[suffix];
  }

  function buildExactFileIndex(files) {
    const next = new Map();
    const reasons = [];
    for (const file of files) {
      const key = selectedRootRelativeKey(file);
      if (key === null) {
        reasons.push("invalid_path");
        continue;
      }
      if (next.has(key)) {
        reasons.push("missing_asset");
        continue;
      }
      if (!fileMatchesKey(file, key)) {
        reasons.push("invalid_asset_type");
        continue;
      }
      if (!Number.isSafeInteger(file.size) || file.size < 1 || file.size > ReviewCore.constants.max_asset_bytes) {
        reasons.push("asset_size_invalid");
        continue;
      }
      next.set(key, file);
    }
    return { files: next, reasons: [...new Set(reasons)] };
  }

  function decodeImage(file) {
    return ImageSafety.inspectAndDecode(file, {
      maxDimension: ReviewCore.constants.max_decoded_dimension,
      maxPixels: ReviewCore.constants.max_decoded_pixels,
    });
  }

  async function inspectAssetFiles() {
    const inspections = new Map();
    const inventory = [];
    const reasons = [];
    for (const [key, file] of assetFiles) {
      const inspected = await decodeImage(file);
      inspections.set(key, inspected);
      if (inspected.read === false) reasons.push("local_read_failed");
      else if (inspected.decode === false) reasons.push("decode_failed");
      else if (inspected.header === false || inspected.valid !== true) reasons.push("dimension_invalid");
      else inventory.push({ key, sha256: inspected.sha256 });
    }
    return { inspections, inventory, reasons: [...new Set(reasons)] };
  }

  function validateReviewableRows(snapshot, inspections) {
    const rows = [];
    const reasons = [];
    const dimensions = new Map();
    for (const row of snapshot.review_rows || snapshot.selected_rows) {
      const keys = [row.assets.original, row.assets.mask, row.assets.after];
      const files = keys.map((key) => assetFiles.get(key));
      if (files.some((file) => file === undefined)) {
        reasons.push("missing_asset");
        continue;
      }
      const decoded = keys.map((key) => inspections.get(key));
      if (decoded.some((item) => item.decode === false)) {
        reasons.push("decode_failed");
        continue;
      }
      if (decoded.some((item) => item.header === false)) {
        reasons.push("dimension_invalid");
        continue;
      }
      if (decoded.some((item) => item.valid !== true)) {
        reasons.push("dimension_invalid");
        continue;
      }
      const [first, second, third] = decoded;
      if (first.naturalWidth !== second.naturalWidth
        || first.naturalWidth !== third.naturalWidth
        || first.naturalHeight !== second.naturalHeight
        || first.naturalHeight !== third.naturalHeight) {
        reasons.push("dimension_mismatch");
        continue;
      }
      rows.push(row);
      dimensions.set(row.fixture_id, { width: first.naturalWidth, height: first.naturalHeight });
    }
    rows.sort((left, right) => left.fixture_id < right.fixture_id ? -1 : left.fixture_id > right.fixture_id ? 1 : 0);
    return { rows, dimensions, reasons: [...new Set(reasons)] };
  }

  function renderProgress() {
    const total = reviewableRows.length;
    element("review-progress").textContent = `${blindedItemLabel(selectedIndex + 1, total)} · 已完成 ${completedCount} / ${total}`;
  }

  function createActiveObjectURLs(row) {
    revokeActiveObjectURLs();
    const files = [row.assets.original, row.assets.mask, row.assets.after].map((key) => assetFiles.get(key));
    const installed = ImageSafety.installDisplayObjectURLs(files, imageElements);
    if (!installed.valid) {
      enterLocalReadFailure();
      return false;
    }
    activeObjectURLs = [...installed.urls];
    return true;
  }

  function enterLocalReadFailure() {
    invalidateAssetCandidateState();
    disableReview();
    disableExport();
    setValidation(FIXED_COPY.invalid, FIXED_COPY.invalid, ["local_read_failed"], "");
    focusValidationHeading();
  }

  function restoreJudgment() {
    resetJudgmentForm();
    const row = reviewableRows[selectedIndex];
    const review = row ? savedReviews.get(row.fixture_id) : undefined;
    if (!review) return;
    element("target_present").value = String(review.target_present);
    element("mask_coverage").value = String(review.mask_coverage);
    element("protected_leakage").value = String(review.protected_leakage);
    element("naturalness").value = String(review.naturalness);
    element("structure_changed").value = String(review.structure_changed);
    element("decision").value = review.decision;
    element("reason_code").value = review.reason_code;
  }

  function renderCurrentRow() {
    const row = reviewableRows[selectedIndex];
    if (!row) {
      revokeActiveObjectURLs();
      disableReview();
      return;
    }
    workspace.hidden = false;
    element("review-item-heading").textContent = `盲审项目 ${selectedIndex + 1}`;
    element("review-feature").textContent = friendlyFeatureLabel(row.feature);
    renderProgress();
    if (!createActiveObjectURLs(row)) return false;
    restoreJudgment();
    element("previous-item").disabled = selectedIndex === 0;
    element("save-and-next").textContent = selectedIndex === reviewableRows.length - 1 ? "保存评审" : "保存并继续";
    return true;
  }

  async function acceptAssetFiles(files) {
    invalidateAssetCandidateState();
    setInputsDisabled(true);
    disableReview();
    disableExport();
    setValidation("正在核对本地资产…", "正在核对本地资产…", [], FIXED_COPY.assets_loading);
    try {
    const indexed = buildExactFileIndex(files);
    assetFiles = indexed.files;
    if (!manifest) {
      setInputsDisabled(false);
      setValidation("等待本地评审材料", "请先选择评审清单。", indexed.reasons, "");
      return;
    }
    const inspected = await inspectAssetFiles();
    const snapshot = ReviewCore.createReviewSnapshot(
      manifest,
      inspected.inventory,
      RightsAuthorizationRegistry,
    );
    if (!snapshot.valid) {
      setInputsDisabled(false);
      setValidation(FIXED_COPY.invalid, FIXED_COPY.invalid, snapshot.reasons.map(classifyCoreReason), "");
      focusValidationHeading();
      return;
    }
    activeSnapshot = snapshot;
    featureSnapshots.set(snapshot.feature, snapshot);
    const decoded = validateReviewableRows(snapshot, inspected.inspections);
    reviewableRows = decoded.rows;
    decodedDimensions = decoded.dimensions;
    selectedIndex = 0;
    const reasons = [...new Set([...indexed.reasons, ...inspected.reasons, ...decoded.reasons])];
    hasBlockingAssetErrors = reasons.length > 0;
    renderResolvedGates();
    setInputsDisabled(false);
    if (reviewableRows.length === 0) {
      disableReview();
      setValidation(
        reasons.length > 0 ? FIXED_COPY.invalid : "等待本地评审材料",
        reasons.length > 0 ? FIXED_COPY.invalid : "选择清单和资产目录后开始。页面不会显示文件名或路径。",
        reasons,
        "partial",
      );
      if (reasons.length > 0) focusValidationHeading();
      return;
    }
    setValidation(
      reasons.length > 0 ? FIXED_COPY.invalid : FIXED_COPY.ready,
      reasons.length > 0 ? FIXED_COPY.invalid : FIXED_COPY.ready,
      reasons,
      reasons.length > 0 ? "partial" : FIXED_COPY.ready,
    );
    if (renderCurrentRow()) element("review-item-heading").focus();
    } catch (_) {
      invalidateAssetCandidateState();
      setValidation(FIXED_COPY.invalid, FIXED_COPY.invalid, ["local_read_failed"], "");
      focusValidationHeading();
    } finally {
      setInputsDisabled(false);
    }
  }

  async function acceptManifestFile(file) {
    invalidateManifestCandidateState();
    setInputsDisabled(true);
    disableReview();
    disableExport();
    setValidation("正在检查本地清单…", "正在检查本地清单…", [], FIXED_COPY.manifest_loading);
    if (!Number.isSafeInteger(file.size) || file.size < 1 || file.size > ReviewCore.constants.max_manifest_bytes) {
      setInputsDisabled(false);
      setValidation(FIXED_COPY.invalid, FIXED_COPY.invalid, ["manifest_size_invalid"], "");
      focusValidationHeading();
      return;
    }
    let parsed;
    try {
      parsed = JSON.parse(await readFileText(file));
    } catch (_) {
      setInputsDisabled(false);
      setValidation(FIXED_COPY.invalid, FIXED_COPY.invalid, ["invalid_json"], "");
      focusValidationHeading();
      return;
    }
    const validation = ReviewCore.validateManifest(parsed);
    if (!validation.valid) {
      setInputsDisabled(false);
      const reasons = validation.reasons.map(classifyCoreReason);
      setValidation(FIXED_COPY.invalid, FIXED_COPY.invalid, reasons, "");
      focusValidationHeading();
      return;
    }
    manifest = parsed;
    activeSnapshot = null;
    reviewableRows = [];
    selectedIndex = 0;
    completedCount = 0;
    savedReviews.clear();
    hasBlockingAssetErrors = false;
    resetFeatureSnapshots();
    resetJudgmentForm();
    setInputsDisabled(false);
    if (assetFiles.size > 0) {
      await acceptAssetFiles([...assetFiles.values()]);
      return;
    }
    const waitingSnapshot = ReviewCore.createReviewSnapshot(manifest, [], RightsAuthorizationRegistry);
    activeSnapshot = waitingSnapshot;
    featureSnapshots.set(waitingSnapshot.feature, waitingSnapshot);
    renderResolvedGates();
    setValidation("等待本地评审材料", "请选择本地资产目录。", [], "waiting");
  }

  function collectJudgment() {
    const row = reviewableRows[selectedIndex];
    if (!row || FIELD_NAMES.some((field) => element(field).value === "")) return null;
    return {
      fixture_id: row.fixture_id,
      target_present: element("target_present").value === "true",
      mask_coverage: Number(element("mask_coverage").value),
      protected_leakage: element("protected_leakage").value === "true",
      naturalness: Number(element("naturalness").value),
      structure_changed: element("structure_changed").value === "true",
      decision: element("decision").value,
      reason_code: element("reason_code").value,
    };
  }

  function issueReviewCandidate(review) {
    if (review === null) return null;
    try {
      return ReviewCore.createReview(activeSnapshot, review);
    } catch (_) {
      return null;
    }
  }

  function focusFirstInvalid() {
    const first = FIELD_NAMES.find((field) => element(field).value === "");
    element(first || FIELD_NAMES[0]).focus();
  }

  function advanceOnce() {
    if (selectedIndex < reviewableRows.length - 1) selectedIndex += 1;
  }

  function reviewsComplete() {
    return reviewableRows.length > 0
      && completedCount === reviewableRows.length
      && !hasBlockingAssetErrors;
  }

  function reviewsForSnapshot(snapshot) {
    if (snapshot !== activeSnapshot || snapshot.ready !== true) return [];
    return snapshot.selected_rows.map((row) => savedReviews.get(row.fixture_id));
  }

  function decisionsResolved() {
    try {
      for (const feature of FEATURE_ORDER) {
        const snapshot = featureSnapshots.get(feature);
        ReviewCore.evaluateFeature(snapshot, reviewsForSnapshot(snapshot), designQualificationFor(feature));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  function updateExportAvailability() {
    if (reviewsComplete() && decisionsResolved()) enableExport();
    else disableExport();
  }

  function saveCurrentReview(event) {
    event.preventDefault();
    const review = issueReviewCandidate(collectJudgment());
    if (review === null) {
      element("form-alert").textContent = fixedCopyForReason("review_invalid");
      focusFirstInvalid();
      return;
    }
    savedReviews.set(review.fixture_id, review);
    completedCount = savedReviews.size;
    element("form-alert").textContent = "";
    renderActiveGate();
    updateExportAvailability();
    if (selectedIndex < reviewableRows.length - 1) {
      advanceOnce();
      if (renderCurrentRow()) element("review-item-heading").focus();
    } else {
      renderProgress();
      restoreJudgment();
      element("session-status").textContent = "所有可评审项目均已完成。";
    }
  }

  function moveToPreviousItem() {
    if (selectedIndex === 0) return;
    selectedIndex -= 1;
    if (renderCurrentRow()) element("review-item-heading").focus();
  }

  function featureInputsForExport() {
    return FEATURE_ORDER.map((feature) => {
      const snapshot = featureSnapshots.get(feature);
      return {
        snapshot,
        reviews: reviewsForSnapshot(snapshot),
        design_qualification: designQualificationFor(feature),
      };
    });
  }

  function exportReview() {
    if (!reviewsComplete() || !decisionsResolved()) {
      element("export-feedback").textContent = FIXED_COPY.export_failure;
      return;
    }
    let blobURL = null;
    try {
      const bytes = ReviewCore.serializeDurableExport(featureInputsForExport());
      const blob = new Blob([bytes], { type: "application/json" });
      blobURL = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = blobURL;
      anchor.download = EXPORT_FILENAME;
      anchor.click();
      URL.revokeObjectURL(blobURL);
      blobURL = null;
      revokeActiveObjectURLs();
      renderCurrentRow();
      element("export-feedback").textContent = FIXED_COPY.export_success;
    } catch (_) {
      if (blobURL !== null) URL.revokeObjectURL(blobURL);
      element("export-feedback").textContent = FIXED_COPY.export_failure;
    }
  }

  function restoreInitiatorFocus() {
    if (replacementInitiator) replacementInitiator.focus();
    replacementInitiator = null;
  }

  function keepCurrentSession() {
    if (replacementInitiator) replacementInitiator.value = "";
    replaceDialog.returnValue = "keep";
    replaceDialog.close();
    pendingReplacement = null;
    restoreInitiatorFocus();
  }

  async function processReplacement(replacement, focusTarget = null) {
    try {
      if (replacement.kind === "manifest") await acceptManifestFile(replacement.files[0]);
      else await acceptAssetFiles(replacement.files);
    } finally {
      if (focusTarget) focusTarget.focus();
    }
  }

  function confirmReplacement() {
    const replacement = pendingReplacement;
    const focusTarget = replacementInitiator;
    replaceDialog.returnValue = "replace";
    replaceDialog.close();
    pendingReplacement = null;
    replacementInitiator = null;
    if (replacement) void processReplacement(replacement, focusTarget);
    else if (focusTarget) focusTarget.focus();
  }

  function requestReplacement(kind, files, initiator) {
    if (savedReviews.size === 0) {
      void processReplacement({ kind, files });
      return;
    }
    pendingReplacement = { kind, files };
    replacementInitiator = initiator;
    replaceDialog.showModal();
    element("keep-current").focus();
  }

  function trapDialogFocus(event) {
    if (event.key === "Escape") {
      event.preventDefault();
      keepCurrentSession();
      return;
    }
    if (event.key !== "Tab") return;
    const controls = Array.from(replaceDialog.querySelectorAll("button"));
    const first = controls[0];
    const last = controls.at(-1);
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  }

  function synchronizeScroll(source) {
    if (!comparisonGrid.classList.contains("actual")) return;
    for (const scroller of comparisonScrollers) {
      if (scroller === source) continue;
      scroller.scrollLeft = source.scrollLeft;
      scroller.scrollTop = source.scrollTop;
    }
  }

  function setViewMode(actual) {
    comparisonGrid.classList.toggle("actual", actual);
    comparisonGrid.classList.toggle("fit", !actual);
    element("view-fit").setAttribute("aria-pressed", String(!actual));
    element("view-actual").setAttribute("aria-pressed", String(actual));
  }

  function showMobilePane(paneID, tabID) {
    for (const pane of document.querySelectorAll(".comparison-pane")) pane.classList.remove("mobile-visible");
    for (const tab of document.querySelectorAll('[role="tab"]')) tab.setAttribute("aria-selected", "false");
    element(paneID).classList.add("mobile-visible");
    element(tabID).setAttribute("aria-selected", "true");
  }

  manifestInput.addEventListener("change", () => {
    const file = manifestInput.files && manifestInput.files[0];
    if (file) requestReplacement("manifest", [file], manifestInput);
  });
  assetInput.addEventListener("change", () => {
    const files = assetInput.files ? Array.from(assetInput.files) : [];
    if (files.length > 0) requestReplacement("assets", files, assetInput);
  });
  element("judgment-form").addEventListener("submit", saveCurrentReview);
  element("previous-item").addEventListener("click", moveToPreviousItem);
  exportButton.addEventListener("click", exportReview);
  element("keep-current").addEventListener("click", keepCurrentSession);
  element("confirm-replace").addEventListener("click", confirmReplacement);
  replaceDialog.addEventListener("keydown", trapDialogFocus);
  replaceDialog.addEventListener("cancel", (event) => {
    event.preventDefault();
    keepCurrentSession();
  });
  element("view-fit").addEventListener("click", () => setViewMode(false));
  element("view-actual").addEventListener("click", () => setViewMode(true));
  element("tab-original").addEventListener("click", () => showMobilePane("comparison-original", "tab-original"));
  element("tab-mask").addEventListener("click", () => showMobilePane("comparison-mask", "tab-mask"));
  element("tab-after").addEventListener("click", () => showMobilePane("comparison-after", "tab-after"));
  for (const scroller of comparisonScrollers) scroller.addEventListener("scroll", () => synchronizeScroll(scroller));
  globalThis.addEventListener("pagehide", revokeActiveObjectURLs);

  void initialState;
  void decodedDimensions;
  void element("replace-session-dialog");
  closeInitialState();
  element("page-heading").focus();
})();
