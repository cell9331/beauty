// Appended IN MEMORY to exact hash-pinned comparator and root-metric definition
// prefixes by phase95-root-registration.py. No source code or pixels are emitted.
// This is source-only registration, never a candidate/reference scoring entry.
private enum RootSourceAdapter {
    static let sourceHash = "707e9106e394421a00732b0efa2fbd2e1dc4dfee79d9244fcc763e2dbb106818"
    static let contractsHash = "68d192c37821c4c059ac3763722bea491e5dd27850c2ab0a69ec5aa6246cd168"
    static let manifestHash = "5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e"

    static func plane(_ image: CanonicalImage) throws -> RootEdgePlane {
        guard (32...8192).contains(image.width), (16...8192).contains(image.height),
              image.width * image.height <= 16_777_216,
              image.rgba.count == image.width * image.height * 4 else { throw RootEdgeFailure.invalidInput }
        var luma: [Double] = []; luma.reserveCapacity(image.width * image.height)
        for y in 0..<image.height { for x in 0..<image.width {
            guard image.rgba[(y * image.width + x) * 4 + 3] == 255 else { throw RootEdgeFailure.invalidInput }
            luma.append(Double(lumaQ8(image, x: x, y: y)) / 256)
        } }
        return try .init(width: image.width, height: image.height, values: luma)
    }

    static func eyeExclusions(_ eyes: [CGRect], width: Int, height: Int) throws -> [RootEdgeRegion] {
        guard (32...8192).contains(width), (16...8192).contains(height), eyes.count == 2 else { throw RootEdgeFailure.invalidInput }
        return try eyes.map { eye in
            guard [eye.minX, eye.maxX, eye.minY, eye.maxY].allSatisfy(\.isFinite),
                  eye.minX >= 0, eye.minY >= 0, eye.maxX <= 1, eye.maxY <= 1,
                  eye.width > 0, eye.height > 0 else { throw RootEdgeFailure.invalidInput }
            // Explicit conservative outward pixel coverage for measurement
            // exclusions. This does not modify acceptance/protection ROIs.
            return .init(minX: Int(floor(eye.minX * Double(width))), maxX: Int(ceil(eye.maxX * Double(width))),
                         minY: Int(floor(eye.minY * Double(height))), maxY: Int(ceil(eye.maxY * Double(height))))
        }
    }

    static func sourceOnly() throws -> [String: Any] {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let input = root.appendingPathComponent("example-images/input")
        let manifestURL = root.appendingPathComponent("scripts/face-feature-batch-manifest.json")
        try requireAdmittedRegularFile(manifestURL, beneath: root)
        let manifestData = try Data(contentsOf: manifestURL)
        guard sha256Hex(manifestData) == manifestHash,
              let base = try validateManifestData(manifestData).semanticContracts else { throw RootEdgeFailure.identityMismatch }
        let fixtures = try admittedFixtureURLs(in: input)
        guard fixtures.count == 1 else { throw RootEdgeFailure.invalidInput }
        let source = fixtures[0]
        let sourceData = try Data(contentsOf: source)
        guard sha256Hex(sourceData) == sourceHash else { throw RootEdgeFailure.identityMismatch }
        let color = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        let image = try canonicalImage(at: source, context: context)
        let luminance = try plane(image)
        // Exact legacy recipe is reused, not duplicated. Every ROI/protection,
        // sign and threshold must reproduce the ORIGINAL full contract digest.
        let registered = try portraitContracts(source: source, context: context, base: base)
        guard try semanticContractsDigest(registered) == contractsHash,
              let rootContract = registered.first(where: { $0.caseID == "noseRootNarrowing_0p25" }),
              rootContract.targetRegions.count == 1 else { throw RootEdgeFailure.identityMismatch }
        let region = try rasterize(rootContract.targetRegions[0], width: Int64(image.width), height: Int64(image.height))
        guard region.maxY <= image.height - watermarkExcludedRows(width: image.width) else { throw RootEdgeFailure.invalidInput }

        guard let ci = CIImage(contentsOf: source, options: [.applyOrientationProperty: true]),
              ci.extent == ci.extent.integral,
              let cg = context.createCGImage(ci, from: ci.extent),
              cg.width == image.width, cg.height == image.height else { throw RootEdgeFailure.invalidInput }
        let request = VNDetectFaceLandmarksRequest()
        try VNImageRequestHandler(cgImage: cg, orientation: .up).perform([request])
        guard request.results?.count == 1, let face = request.results?.first,
              let landmarks = face.landmarks else { throw RootEdgeFailure.unavailable }
        let bounds = face.boundingBox
        let eyes = try [landmarks.leftEye, landmarks.rightEye].map { region -> CGRect in
            guard let region, (3...32).contains(region.pointCount) else { throw RootEdgeFailure.unavailable }
            let points = region.normalizedPoints.map { p in
                CGPoint(x: bounds.minX + CGFloat(p.x) * bounds.width,
                        y: 1 - bounds.minY - CGFloat(p.y) * bounds.height)
            }
            guard points.allSatisfy({ $0.x.isFinite && $0.y.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y) })
            else { throw RootEdgeFailure.invalidInput }
            let xs = points.map(\.x), ys = points.map(\.y)
            return CGRect(x: xs.min()!, y: ys.min()!, width: xs.max()! - xs.min()!, height: ys.max()! - ys.min()!)
        }
        let exclusions = try eyeExclusions(eyes, width: image.width, height: image.height)
        let binding = try RootStructuralMetricPrototype.register(luminance,
            roi: .init(minX: Int(region.minX), maxX: Int(region.maxX), minY: Int(region.minY), maxY: Int(region.maxY)),
            exclusions: exclusions)
        // Verify the admitted input again after registration, before exporting
        // only commitment/counts. No width/edge/template is part of the result.
        try requireAdmittedRegularFile(source, beneath: input)
        guard sha256Hex(try Data(contentsOf: source)) == sourceHash else { throw RootEdgeFailure.identityMismatch }
        return ["schema": "phase95-root-source-registration-v2", "status": "registered",
                "source_sha256": sourceHash, "contracts_sha256": contractsHash,
                "canonical_source_sha256": binding.sourceDigest, "source_registration_sha256": binding.commitment,
                "registered_rows": binding.pairs.count, "eye_exclusions": exclusions.count,
                "vision_revision": request.revision, "metric_id": RootStructuralMetricPrototype.identifier,
                "canonicalization": "legacy_ci_orientation_srgb_cg_opaque_luma_q8_v1",
                "portrait_scoring_enabled": false]
    }

    static func selfTest() throws -> Int {
        var checks = 0
        func require(_ flag: Bool) throws { guard flag else { throw RootEdgeFailure.invalidInput }; checks += 1 }
        let w = 64, h = 16
        var bytes = [UInt8](repeating: 255, count: w * h * 4)
        for i in 0..<(w * h) { bytes[i * 4] = 10; bytes[i * 4 + 1] = 20; bytes[i * 4 + 2] = 30 }
        let result = try plane(.init(width: w, height: h, rgba: bytes))
        try require(result.values.allSatisfy { $0 == Double(77 * 10 + 150 * 20 + 29 * 30) / 256 })
        bytes[3] = 254
        do { _ = try plane(.init(width: w, height: h, rgba: bytes)); throw RootEdgeFailure.unavailable }
        catch RootEdgeFailure.invalidInput { checks += 1 }
        for bad in [CanonicalImage(width: Int.max, height: 16, rgba: []),
                    .init(width: 64, height: 16, rgba: [])] {
            do { _ = try plane(bad); throw RootEdgeFailure.unavailable }
            catch RootEdgeFailure.invalidInput { checks += 1 }
        }
        let eyes = [CGRect(x: 0.1, y: 0.2, width: 0.15, height: 0.15), CGRect(x: 0.6, y: 0.2, width: 0.1, height: 0.15)]
        let exclusion = try eyeExclusions(eyes, width: w, height: h)
        try require(exclusion.count == 2 && exclusion[0].minX == 6 && exclusion[0].maxX == 16 &&
                    exclusion[0].minY == 3 && exclusion[0].maxY == 6)
        for invalid in [[], [eyes[0]], [CGRect(x: -0.1, y: 0, width: 0.2, height: 0.2), eyes[1]]] {
            do { _ = try eyeExclusions(invalid, width: w, height: h); throw RootEdgeFailure.unavailable }
            catch RootEdgeFailure.invalidInput { checks += 1 }
        }
        return checks
    }
}
