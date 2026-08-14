import CoreImage
import ImageIO
import XCTest
import BeautySDK

// Requirement evidence: RENDER-01, RENDER-02.
final class BeautyRendererOutputRegressionTests: XCTestCase {
    private static let rendererSourceRelativePath = "BeautySDK/Sources/BeautyExampleRenderer/main.swift"
    private static let rendererSourceDirectoryRelativePath = "BeautySDK/Sources/BeautyExampleRenderer"

    private static let expectedRendererCaseIDs = [
        "skinSmoothing_0p50",
        "skinWhitening_0p50",
        "skinRosy_0p40",
        "skinSharpen_0p40",
        "brightness_plus0p25",
        "contrast_plus0p25",
        "filter_softClean_0p50",
        "filter_warmLight_0p50",
        "skinCombo_0p50",
        "geometryBaseline_noop",
        "faceShapeCombo_0p35",
        "faceSlim_0p35",
        "faceSmall_0p35",
        "chinLength_plus0p30",
        "chinLength_minus0p30",
        "faceVShape_0p35",
        "jawSlim_0p35",
        "faceContourSmooth_0p25",
        "templeFullness_0p25",
        "cheekboneSlim_0p25",
        "chinTaper_0p25",
        "eyeSize_0p35",
        "eyeDistance_plus0p25",
        "eyeDistance_minus0p25",
        "eyeYPosition_plus0p20",
        "eyeYPosition_minus0p20",
        "eyeTailLift_0p25",
        "eyeHeight_0p25",
        "eyeLength_0p25",
        "upperEyelidLift_0p25",
        "pupilSize_0p25",
        "gazeCorrection_0p25",
        "lowerEyelidDrop_0p25",
        "eyeTilt_plus0p25",
        "eyeTilt_minus0p25",
        "innerCornerOpen_0p25",
        "outerCornerOpen_0p25",
        "eyeSymmetry_0p25",
        "eyebrowYPosition_plus0p25",
        "eyebrowYPosition_minus0p25",
        "eyebrowThickness_plus0p25",
        "eyebrowThickness_minus0p25",
        "eyebrowLength_plus0p25",
        "eyebrowLength_minus0p25",
        "eyebrowSpacing_plus0p25",
        "eyebrowSpacing_minus0p25",
        "eyebrowHeadSpacing_plus0p25",
        "eyebrowHeadSpacing_minus0p25",
        "eyebrowTilt_plus0p25",
        "eyebrowTilt_minus0p25",
        "eyebrowPeakDefinition_0p25",
        "noseSlim_0p35",
        "noseWingSlim_0p35",
        "noseTipSize_plus0p30",
        "noseTipSize_minus0p30",
        "noseBridge_0p30",
        "noseRootNarrowing_0p25",
        "noseTipLift_0p25",
        "mouthSize_plus0p35",
        "mouthSize_minus0p35",
        "mouthWidth_plus0p35",
        "mouthWidth_minus0p35",
        "smile_0p50",
        "lipColor_0p50",
        "mouthYPosition_plus0p25",
        "mouthYPosition_minus0p25",
        "mouthTilt_plus0p25",
        "mouthTilt_minus0p25",
        "mouthXPosition_plus0p25",
        "mouthXPosition_minus0p25",
        "lipPeakDefinition_0p25",
        "lipPlump_0p25",
        "teethWhitening_1p00",
        "scleraRednessReduction_1p00"
    ]

    private static let fixtureNames = [
        "portraits/p1.jpg",
        "negatives/no-face-gradient.png"
    ]

    func testRendererCaseInventoryMatchesCurrentPublicFacadeMatrix() throws {
        let source = try rendererSource()

        XCTAssertEqual(
            rendererCaseIDs(in: source),
            Self.expectedRendererCaseIDs,
            "BeautyExampleRenderer/main.swift renderer case IDs changed"
        )
        XCTAssertTrue(source.contains("import BeautySDK"), "BeautyExampleRenderer/main.swift should import BeautySDK")

        for forbiddenTarget in ["BeautyCore", "BeautyDetection", "BeautyEffects", "BeautyRender", "BeautyResources"] {
            XCTAssertFalse(
                source.contains("import \(forbiddenTarget)"),
                "BeautyExampleRenderer/main.swift should not import \(forbiddenTarget)"
            )
        }
        XCTAssertEqual(source.components(separatedBy: "engine.processResult(").count - 1, 1)
    }

    func testRendererSavedPNGPathUsesNamedSRGBWithoutDeviceRGBFallback() throws {
        let source = try rendererSource()

        XCTAssertTrue(source.contains("CGColorSpace(name: CGColorSpace.sRGB)"))
        XCTAssertTrue(source.contains(".workingColorSpace: outputColorSpace"))
        XCTAssertTrue(source.contains(".outputColorSpace: outputColorSpace"))
        XCTAssertTrue(source.contains("NSBitmapImageRep(cgImage: cgImage)"))
        XCTAssertFalse(source.contains("CGColorSpaceCreateDeviceRGB()"))
        XCTAssertFalse(source.contains("colorSpaceName: .deviceRGB"))
    }

    func testRendererFailureSeamIsExecutableInternalAndUndocumented() throws {
        let source = try rendererSource()
        XCTAssertTrue(source.contains("enum RendererFailureInjection"))
        XCTAssertTrue(source.contains("BEAUTY_EXAMPLE_RENDERER_FAILURE"))
        XCTAssertFalse(source.contains("--failure"))
        XCTAssertFalse(source.contains("failureInjection"))

        let publicDirectory = try repositoryRootURL().appendingPathComponent("BeautySDK/Sources/BeautySDK")
        let publicFiles = try FileManager.default.contentsOfDirectory(
            at: publicDirectory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ).filter { $0.pathExtension == "swift" }
        for file in publicFiles {
            let publicSource = try String(contentsOf: file, encoding: .utf8)
            XCTAssertFalse(publicSource.contains("RendererFailureInjection"), file.lastPathComponent)
            XCTAssertFalse(publicSource.contains("BEAUTY_EXAMPLE_RENDERER_FAILURE"), file.lastPathComponent)
        }
    }

    func testRecursiveSameStemInputsAreRejectedBeforeAnyOutputDirectoryWrite() throws {
        let source = try rendererSource()
        let discovery = try XCTUnwrap(source.range(of: "let imageURLs = fixtureImageURLs"))
        let preflight = try XCTUnwrap(source.range(of: "try requireUniqueOutputStems(imageURLs)"))
        let outputDirectoryValidation = try XCTUnwrap(source.range(of: "let outputURL = try requireOutputDirectory"))
        let engine = try XCTUnwrap(source.range(of: "guard let engine = try? BeautyEngine"))

        XCTAssertLessThan(outputDirectoryValidation.lowerBound, discovery.lowerBound)
        XCTAssertLessThan(discovery.lowerBound, preflight.lowerBound)
        XCTAssertLessThan(preflight.lowerBound, engine.lowerBound)
        XCTAssertFalse(source.contains("createDirectory(at: outputURL"))
        XCTAssertTrue(source.contains("case duplicateOutputStem"))
        XCTAssertTrue(source.contains("var stems = Set<String>()"))
        XCTAssertTrue(source.contains("guard stems.insert(outputStemCollisionKey(stem)).inserted else"))
        XCTAssertTrue(source.contains(".folding(options: [.caseInsensitive]"))
        XCTAssertTrue(source.contains(".decomposedStringWithCanonicalMapping"))

        let collisionGroups = [
            [
                URL(fileURLWithPath: "group-a/portrait.png"),
                URL(fileURLWithPath: "group-b/Portrait.jpg"),
            ],
            [
                URL(fileURLWithPath: "group-a/caf\u{00E9}.png"),
                URL(fileURLWithPath: "group-b/cafe\u{0301}.jpg"),
            ],
        ]
        for inputs in collisionGroups {
            let keys = inputs.map {
                $0.deletingPathExtension().lastPathComponent
                    .folding(options: [.caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
                    .decomposedStringWithCanonicalMapping
            }
            XCTAssertEqual(keys.count, 2)
            XCTAssertEqual(Set(keys).count, 1, "the regression fixture must collide under filesystem naming")
        }
    }

    func testPhase51EyebrowCasesUseExactlyOneMatchingPublicParameter() throws {
        let signed = [
            "eyebrowYPosition", "eyebrowThickness", "eyebrowLength",
            "eyebrowSpacing", "eyebrowHeadSpacing", "eyebrowTilt",
        ]
        let allFields = signed + ["eyebrowPeakDefinition"]

        for field in signed {
            for direction in ["plus", "minus"] {
                let caseID = "\(field)_\(direction)0p25"
                let snippet = try rendererCaseSnippet(for: caseID, in: try rendererSource())
                let expected = "\(field): \(direction == "plus" ? "0.25" : "-0.25")"
                XCTAssertTrue(snippet.contains(expected), "Missing \(expected) in \(caseID)")
                XCTAssertEqual(allFields.filter { snippet.contains("\($0):") }, [field])
            }
        }

        let peak = try rendererCaseSnippet(for: "eyebrowPeakDefinition_0p25", in: try rendererSource())
        XCTAssertTrue(peak.contains("eyebrowPeakDefinition: 0.25"))
        XCTAssertEqual(allFields.filter { peak.contains("\($0):") }, ["eyebrowPeakDefinition"])
        XCTAssertEqual(Set(Self.expectedRendererCaseIDs).count, 74)
        XCTAssertEqual(Self.fixtureNames, ["portraits/p1.jpg", "negatives/no-face-gradient.png"])
        for parked in 1...5 {
            XCTAssertFalse(Self.fixtureNames.contains("portraits/e\(parked).png"))
        }
        XCTAssertFalse(Self.fixtureNames.contains("portraits/e6.jpg"))
    }

    func testActivePortraitFixtureIsAuthorizedLocalInputWithSanitizedMetadata() throws {
        let root = try repositoryRootURL()
        let active = root.appendingPathComponent("example-images/input/portraits/p1.jpg")
        let authorization = root.appendingPathComponent("example-images/FIXTURE_AUTHORIZATION.md")
        let parkedDirectory = root.appendingPathComponent("example-images/parked-portraits", isDirectory: true)

        XCTAssertTrue(FileManager.default.fileExists(atPath: active.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: authorization.path))
        let attributes = try FileManager.default.attributesOfItem(atPath: active.path)
        let byteCount = (attributes[.size] as? NSNumber)?.intValue ?? 0
        XCTAssertGreaterThan(byteCount, 0)
        XCTAssertLessThanOrEqual(byteCount, 16 * 1_024 * 1_024)

        guard let source = CGImageSourceCreateWithURL(active as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else {
            XCTFail("p1.jpg must be a readable image fixture")
            return
        }

        XCTAssertEqual((properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue, 2628)
        XCTAssertEqual((properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue, 1778)
        XCTAssertNil(properties[kCGImagePropertyGPSDictionary])
        XCTAssertNil(properties[kCGImagePropertyTIFFDictionary])
        XCTAssertNil(properties[kCGImagePropertyOrientation])
        let metadata = String(describing: properties).lowercased()
        for forbidden in [
            "latitude", "longitude", "datetime", "hostcomputer", "iphone",
            "artist", "author", "copyright", "makernote",
        ] {
            XCTAssertFalse(metadata.contains(forbidden), "p1.jpg leaked metadata token: \(forbidden)")
        }

        for parked in 1...5 {
            let fileName = "e\(parked).png"
            XCTAssertFalse(FileManager.default.fileExists(
                atPath: root.appendingPathComponent("example-images/input/portraits/\(fileName)").path
            ))
            XCTAssertTrue(FileManager.default.fileExists(
                atPath: parkedDirectory.appendingPathComponent(fileName).path
            ))
        }
        XCTAssertFalse(FileManager.default.fileExists(
            atPath: root.appendingPathComponent("example-images/input/portraits/e6.jpg").path
        ))
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: parkedDirectory.appendingPathComponent("e6.jpg").path
        ))
    }

    func testFaceShapeComboCaseUsesOnlyPhase27FaceShapeParameters() throws {
        let source = try rendererSource()
        guard let idRange = source.range(of: "id: \"faceShapeCombo_0p35\"") else {
            XCTFail("Missing faceShapeCombo_0p35 renderer case")
            return
        }
        let snippet = String(source[idRange.lowerBound...]).prefix(600)

        for required in [
            "faceSlim: 0.35",
            "faceSmall: 0.30",
            "faceVShape: 0.35",
            "jawSlim: 0.30",
            "chinLength: 0.20"
        ] {
            XCTAssertTrue(snippet.contains(required), "Missing \(required)")
        }

        for forbidden in [
            "eyeSize",
            "eyeDistance",
            "eyeYPosition",
            "eyeTailLift",
            "noseSlim",
            "noseWingSlim",
            "noseTipSize",
            "noseBridge",
            "mouthSize",
            "mouthWidth",
            "smile",
            "lipColor",
            "brow",
            "proportion",
            "3d"
        ] {
            XCTAssertFalse(snippet.contains(forbidden), "Unexpected geometry scope token: \(forbidden)")
        }
    }

    func testPhase28FaceShapeCasesUseOnlyExistingPublicParameters() throws {
        let source = try rendererSource()
        let expectedCases = [
            ("faceSlim_0p35", "faceSlim: 0.35"),
            ("faceSmall_0p35", "faceSmall: 0.35"),
            ("chinLength_plus0p30", "chinLength: 0.30"),
            ("chinLength_minus0p30", "chinLength: -0.30"),
            ("faceVShape_0p35", "faceVShape: 0.35"),
            ("jawSlim_0p35", "jawSlim: 0.35")
        ]
        let faceShapeFields = [
            "faceSlim:",
            "faceSmall:",
            "faceVShape:",
            "jawSlim:",
            "chinLength:"
        ]

        for (caseID, requiredParameter) in expectedCases {
            let snippet = try rendererCaseSnippet(for: caseID, in: source)

            XCTAssertTrue(snippet.contains(requiredParameter), "Missing \(requiredParameter) in \(caseID)")
            XCTAssertEqual(
                faceShapeFields.filter { snippet.contains($0) },
                [requiredParameter.split(separator: " ").first.map(String.init) ?? ""],
                "\(caseID) should use exactly one public face-shape parameter"
            )
            XCTAssertFalse(snippet.contains("BeautyDemo"), "\(caseID) should not introduce Demo coupling")
        }

        XCTAssertFalse(source.contains("jaw" + "Line"), "Renderer should not add a separate jawline parameter")
        XCTAssertFalse(source.contains("face" + "Line"), "Renderer should not add a separate face-line parameter")
        XCTAssertFalse(source.contains("\u{4E0B}\u{988C}\u{7EBF}"), "Renderer should not add localized alias behavior")
        for term in ["P" + "ro", "V" + "IP", "entitle" + "ment", "pre" + "mium", "pay" + "ment"] {
            XCTAssertFalse(containsStandaloneToken(term, in: source), "Renderer should not add commercial gating")
        }
        XCTAssertFalse(source.contains("net" + "work"), "Renderer should stay local-only")
        XCTAssertFalse(source.contains("cl" + "oud"), "Renderer should stay local-only")
    }

    func testJawlineAliasSharesJawSlimRendererEvidence() throws {
        let source = try rendererSource()
        let caseIDs = rendererCaseIDs(in: source)
        let jawSlimCases = caseIDs.filter { $0 == "jawSlim_0p35" }
        let separateJawlineCases = caseIDs.filter { caseID in
            caseID.contains("jaw" + "Line") || caseID.contains("jawline")
        }
        let snippet = try rendererCaseSnippet(for: "jawSlim_0p35", in: source)

        XCTAssertEqual(jawSlimCases, ["jawSlim_0p35"])
        XCTAssertTrue(snippet.contains("jawSlim: 0.35"))
        XCTAssertTrue(separateJawlineCases.isEmpty, "Jawline alias evidence should share jawSlim_0p35")
    }

    func testPhase47OUT01FaceCasesUseExactlyOneNewPublicFaceParameter() throws {
        let source = try rendererSource()
        let expectedCases = [
            ("faceContourSmooth_0p25", "faceContourSmooth: 0.25"),
            ("templeFullness_0p25", "templeFullness: 0.25"),
            ("cheekboneSlim_0p25", "cheekboneSlim: 0.25"),
            ("chinTaper_0p25", "chinTaper: 0.25"),
        ]
        let allFaceFields = [
            "faceSlim:", "faceSmall:", "faceVShape:", "jawSlim:", "chinLength:",
            "faceContourSmooth:", "templeFullness:", "cheekboneSlim:", "chinTaper:",
        ]

        for (caseID, requiredParameter) in expectedCases {
            let snippet = try rendererCaseSnippet(for: caseID, in: source)
            XCTAssertTrue(snippet.contains(requiredParameter), "Missing \(requiredParameter) in \(caseID)")
            XCTAssertEqual(
                allFaceFields.filter { snippet.contains($0) },
                [requiredParameter.split(separator: " ").first.map(String.init) ?? ""],
                "\(caseID) should use exactly one public face parameter"
            )
            XCTAssertFalse(snippet.contains("BeautyDemo"), "\(caseID) should not introduce Demo coupling")
            for forbidden in ["observedFaceSupport", "FaceShapeWarpProvider", "ChinWarpProvider"] {
                XCTAssertFalse(snippet.contains(forbidden), "\(caseID) should not borrow internal geometry")
            }
        }

        let caseIDs = rendererCaseIDs(in: source)
        XCTAssertEqual(caseIDs.count, 74)
        XCTAssertEqual(Set(caseIDs).count, 74)
        for deferred in [
            "doubleChin", "doubleChinPro", "hairline", "foreheadHairline",
            "faceCombo", "chinWidth", "faceLift",
        ] {
            XCTAssertFalse(
                caseIDs.contains { $0 == deferred || $0.hasPrefix("\(deferred)_") },
                "Renderer should not add deferred or alias face case: \(deferred)"
            )
            XCTAssertFalse(
                containsInitializerLabel(deferred, in: source),
                "Renderer should not add deferred or alias initializer: \(deferred)"
            )
        }
    }

    func testPhase29EyeCasesUseOnlyExistingPublicEyeParameters() throws {
        let source = try rendererSource()
        let expectedCases = [
            ("eyeSize_0p35", "eyeSize: 0.35"),
            ("eyeDistance_plus0p25", "eyeDistance: 0.25"),
            ("eyeDistance_minus0p25", "eyeDistance: -0.25"),
            ("eyeYPosition_plus0p20", "eyeYPosition: 0.20"),
            ("eyeYPosition_minus0p20", "eyeYPosition: -0.20"),
            ("eyeTailLift_0p25", "eyeTailLift: 0.25")
        ]
        let eyeFields = [
            "eyeSize:",
            "eyeDistance:",
            "eyeYPosition:",
            "eyeTailLift:"
        ]

        for (caseID, requiredParameter) in expectedCases {
            let snippet = try rendererCaseSnippet(for: caseID, in: source)

            XCTAssertTrue(snippet.contains(requiredParameter), "Missing \(requiredParameter) in \(caseID)")
            XCTAssertEqual(
                eyeFields.filter { snippet.contains($0) },
                [requiredParameter.split(separator: " ").first.map(String.init) ?? ""],
                "\(caseID) should use exactly one public eye parameter"
            )
            XCTAssertFalse(snippet.contains("BeautyDemo"), "\(caseID) should not introduce Demo coupling")
        }

        for forbidden in ["eyeCombo", "eyeTailLift_minus", "redness"] {
            XCTAssertFalse(source.contains(forbidden), "Renderer should not add out-of-scope eye case: \(forbidden)")
        }
        for term in ["P" + "ro", "V" + "IP", "entitle" + "ment", "pre" + "mium", "pay" + "ment"] {
            XCTAssertFalse(containsStandaloneToken(term, in: source), "Renderer should not add commercial gating")
        }
        XCTAssertFalse(source.contains("net" + "work"), "Renderer should stay local-only")
        XCTAssertFalse(source.contains("cl" + "oud"), "Renderer should stay local-only")
    }

    func testPhase43EYE16EyeCasesUseExactlyOneNewPublicEyeParameter() throws {
        let source = try rendererSource()
        let expectedCases = [
            ("eyeHeight_0p25", "eyeHeight: 0.25"),
            ("eyeLength_0p25", "eyeLength: 0.25"),
            ("upperEyelidLift_0p25", "upperEyelidLift: 0.25"),
            ("pupilSize_0p25", "pupilSize: 0.25"),
            ("gazeCorrection_0p25", "gazeCorrection: 0.25"),
            ("lowerEyelidDrop_0p25", "lowerEyelidDrop: 0.25"),
            ("eyeTilt_plus0p25", "eyeTilt: 0.25"),
            ("eyeTilt_minus0p25", "eyeTilt: -0.25"),
            ("innerCornerOpen_0p25", "innerCornerOpen: 0.25"),
            ("outerCornerOpen_0p25", "outerCornerOpen: 0.25"),
            ("eyeSymmetry_0p25", "eyeSymmetry: 0.25")
        ]
        let newEyeFields = [
            "eyeHeight:", "eyeLength:", "upperEyelidLift:", "pupilSize:",
            "gazeCorrection:", "lowerEyelidDrop:", "eyeTilt:", "innerCornerOpen:",
            "outerCornerOpen:", "eyeSymmetry:"
        ]

        for (caseID, requiredParameter) in expectedCases {
            let snippet = try rendererCaseSnippet(for: caseID, in: source)
            XCTAssertTrue(snippet.contains(requiredParameter), "Missing \(requiredParameter) in \(caseID)")
            XCTAssertEqual(
                newEyeFields.filter { snippet.contains($0) },
                [requiredParameter.split(separator: " ").first.map(String.init) ?? ""],
                "\(caseID) should use exactly one new public eye parameter"
            )
            XCTAssertFalse(snippet.contains("BeautyDemo"), "\(caseID) should not introduce Demo coupling")
        }

        let caseIDs = rendererCaseIDs(in: source)
        XCTAssertEqual(caseIDs.count, 74)
        XCTAssertEqual(Set(caseIDs).count, 74)
        for alias in ["eyeCombo", "manualGaze", "perEyeAsymmetry"] {
            XCTAssertFalse(caseIDs.contains { $0 == alias || $0.hasPrefix("\(alias)_") })
            XCTAssertFalse(containsInitializerLabel(alias, in: source))
        }
    }

    func testPhase36NOSE07NoseCasesUseExactlyOnePublicNoseParameter() throws {
        let source = try rendererSource()
        let expectedCases = [
            ("noseSlim_0p35", "noseSlim: 0.35"),
            ("noseWingSlim_0p35", "noseWingSlim: 0.35"),
            ("noseTipSize_plus0p30", "noseTipSize: 0.30"),
            ("noseTipSize_minus0p30", "noseTipSize: -0.30"),
            ("noseBridge_0p30", "noseBridge: 0.30"),
            ("noseRootNarrowing_0p25", "noseRootNarrowing: 0.25"),
            ("noseTipLift_0p25", "noseTipLift: 0.25")
        ]
        let noseFields = [
            "noseSlim:",
            "noseWingSlim:",
            "noseTipSize:",
            "noseBridge:",
            "noseRootNarrowing:",
            "noseTipLift:"
        ]

        for (caseID, requiredParameter) in expectedCases {
            let snippet = try rendererCaseSnippet(for: caseID, in: source)
            XCTAssertTrue(snippet.contains(requiredParameter), "Missing \(requiredParameter) in \(caseID)")
            XCTAssertEqual(
                noseFields.filter { snippet.contains($0) },
                [requiredParameter.split(separator: " ").first.map(String.init) ?? ""],
                "\(caseID) should use exactly one public nose parameter"
            )
            XCTAssertFalse(snippet.contains("BeautyDemo"), "\(caseID) should not introduce Demo coupling")
        }

        let caseIDs = rendererCaseIDs(in: source)
        for alias in ["noseCombo", "noseRoot", "noseLift", "shanGen", "tiSheng"] {
            XCTAssertFalse(
                caseIDs.contains { $0 == alias || $0.hasPrefix("\(alias)_") },
                "Renderer should not add alias case: \(alias)"
            )
            XCTAssertFalse(
                containsInitializerLabel(alias, in: source),
                "Renderer should not add alias initializer label: \(alias)"
            )
            XCTAssertFalse(
                source.contains("displayName: \"\(alias) "),
                "Renderer should not add alias display label: \(alias)"
            )
        }
    }

    func testPhase39MOUTH09MouthCasesUseExactlyOnePublicMouthParameter() throws {
        let source = try rendererSource()
        let expectedCases = [
            ("mouthSize_plus0p35", "mouthSize: 0.35"),
            ("mouthSize_minus0p35", "mouthSize: -0.35"),
            ("mouthWidth_plus0p35", "mouthWidth: 0.35"),
            ("mouthWidth_minus0p35", "mouthWidth: -0.35"),
            ("smile_0p50", "smile: 0.50"),
            ("lipColor_0p50", "lipColor: 0.50"),
            ("mouthYPosition_plus0p25", "mouthYPosition: 0.25"),
            ("mouthYPosition_minus0p25", "mouthYPosition: -0.25"),
            ("mouthTilt_plus0p25", "mouthTilt: 0.25"),
            ("mouthTilt_minus0p25", "mouthTilt: -0.25"),
            ("mouthXPosition_plus0p25", "mouthXPosition: 0.25"),
            ("mouthXPosition_minus0p25", "mouthXPosition: -0.25"),
            ("lipPeakDefinition_0p25", "lipPeakDefinition: 0.25"),
            ("lipPlump_0p25", "lipPlump: 0.25")
        ]
        let mouthFields = [
            "mouthSize:",
            "mouthWidth:",
            "smile:",
            "mouthYPosition:",
            "mouthTilt:",
            "mouthXPosition:",
            "lipPeakDefinition:",
            "lipPlump:",
            "lipColor:"
        ]

        for (caseID, requiredParameter) in expectedCases {
            let snippet = try rendererCaseSnippet(for: caseID, in: source)
            XCTAssertTrue(snippet.contains(requiredParameter), "Missing \(requiredParameter) in \(caseID)")
            XCTAssertEqual(
                mouthFields.filter { snippet.contains($0) },
                [requiredParameter.split(separator: " ").first.map(String.init) ?? ""],
                "\(caseID) should use exactly one public mouth/lip parameter"
            )
            XCTAssertFalse(snippet.contains("BeautyDemo"), "\(caseID) should not introduce Demo coupling")
        }

        let caseIDs = rendererCaseIDs(in: source)
        for alias in ["mouthCombo", "mLip", "teethWhite", "toothWhitening", "teethBrightness"] {
            XCTAssertFalse(
                caseIDs.contains { $0 == alias || $0.hasPrefix("\(alias)_") },
                "Renderer should not add alias or out-of-scope mouth case: \(alias)"
            )
            XCTAssertFalse(
                containsInitializerLabel(alias, in: source),
                "Renderer should not add alias initializer label: \(alias)"
            )
        }
    }

    func testNoFaceFixtureProducesNoFaceSummaryForFaceShapeCombo() throws {
        let engine = try BeautyEngine(configuration: .default)
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        let fixtureName = "negatives/no-face-gradient.png"
        let fixtureURL = inputDirectory.appendingPathComponent(fixtureName)
        let input = try fixtureImage(at: fixtureURL, named: fixtureName)

        let result = try engine.processResult(
            image: input,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: BeautyParameters(
                faceSlim: 0.35,
                faceSmall: 0.30,
                faceVShape: 0.35,
                jawSlim: 0.30,
                chinLength: 0.20
            )
        )

        XCTAssertEqual(result.output.extent, input.extent)
        XCTAssertEqual(result.detectionSummary?.availability, .noFace)
        XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
        XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        assertRedacted(result)
    }

    func testPhase36NOSE09IsolatedNoseCasesPreserveNoFaceFacadeContract() throws {
        let engine = try BeautyEngine(configuration: .default)
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        let fixtureName = "negatives/no-face-gradient.png"
        let fixtureURL = inputDirectory.appendingPathComponent(fixtureName)
        let input = try fixtureImage(at: fixtureURL, named: fixtureName)
        let isolatedParameters = [
            BeautyParameters(noseRootNarrowing: 0.25),
            BeautyParameters(noseTipLift: 0.25)
        ]

        for parameters in isolatedParameters {
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: parameters
            )

            XCTAssertEqual(result.output.extent, input.extent)
            XCTAssertEqual(result.detectionSummary?.availability, .noFace)
            XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
            XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
            assertRedacted(result)
            assertNoPhase36NoseFieldDisclosure(result)
        }
    }

    func testPhase39MOUTH11IsolatedMouthCasesPreserveNoFaceFacadeContract() throws {
        let engine = try BeautyEngine(configuration: .default)
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        let fixtureName = "negatives/no-face-gradient.png"
        let fixtureURL = inputDirectory.appendingPathComponent(fixtureName)
        let input = try fixtureImage(at: fixtureURL, named: fixtureName)
        let isolatedParameters = [
            BeautyParameters(mouthYPosition: 0.25),
            BeautyParameters(mouthYPosition: -0.25),
            BeautyParameters(mouthTilt: 0.25),
            BeautyParameters(mouthTilt: -0.25),
            BeautyParameters(mouthXPosition: 0.25),
            BeautyParameters(mouthXPosition: -0.25),
            BeautyParameters(lipPeakDefinition: 0.25),
            BeautyParameters(lipPlump: 0.25)
        ]

        for parameters in isolatedParameters {
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: parameters
            )

            XCTAssertEqual(result.output.extent, input.extent)
            XCTAssertEqual(result.detectionSummary?.availability, .noFace)
            XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
            XCTAssertEqual(result.detectionSummary?.faceCount, 0)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 0)
            XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
            XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
            assertRedacted(result)
            assertNoPhase39MouthFieldDisclosure(result)
        }
    }

    func testPhase43EYE18IsolatedEyeCasesPreserveNoFaceFacadeContract() throws {
        let engine = try BeautyEngine(configuration: .default)
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        let fixtureName = "negatives/no-face-gradient.png"
        let fixtureURL = inputDirectory.appendingPathComponent(fixtureName)
        let input = try fixtureImage(at: fixtureURL, named: fixtureName)
        let isolatedParameters = [
            BeautyParameters(eyeHeight: 0.25),
            BeautyParameters(eyeLength: 0.25),
            BeautyParameters(upperEyelidLift: 0.25),
            BeautyParameters(pupilSize: 0.25),
            BeautyParameters(gazeCorrection: 0.25),
            BeautyParameters(lowerEyelidDrop: 0.25),
            BeautyParameters(eyeTilt: 0.25),
            BeautyParameters(eyeTilt: -0.25),
            BeautyParameters(innerCornerOpen: 0.25),
            BeautyParameters(outerCornerOpen: 0.25),
            BeautyParameters(eyeSymmetry: 0.25)
        ]

        for parameters in isolatedParameters {
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: parameters
            )

            XCTAssertEqual(result.output.extent, input.extent)
            XCTAssertEqual(result.detectionSummary?.availability, .noFace)
            XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
            XCTAssertEqual(result.detectionSummary?.faceCount, 0)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 0)
            XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
            XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
            assertRedacted(result)
            assertNoPhase43EyeFieldDisclosure(result)
        }
    }

    func testPhase47OUT03IsolatedFaceCasesPreserveNoFaceFacadeContract() throws {
        let engine = try BeautyEngine(configuration: .default)
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        let fixtureName = "negatives/no-face-gradient.png"
        let fixtureURL = inputDirectory.appendingPathComponent(fixtureName)
        let input = try fixtureImage(at: fixtureURL, named: fixtureName)
        let isolatedParameters = [
            BeautyParameters(faceContourSmooth: 0.25),
            BeautyParameters(templeFullness: 0.25),
            BeautyParameters(cheekboneSlim: 0.25),
            BeautyParameters(chinTaper: 0.25),
        ]

        for parameters in isolatedParameters {
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: parameters
            )

            XCTAssertEqual(result.output.extent, input.extent)
            XCTAssertEqual(result.detectionSummary?.availability, .noFace)
            XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
            XCTAssertEqual(result.detectionSummary?.faceCount, 0)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 0)
            XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
            XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
            assertRedacted(result)
            assertNoPhase47FaceFieldDisclosure(result)
        }
    }

    func testDefaultParametersPreserveCurrentFixturePixelsBeforeWatermark() throws {
        let engine = try BeautyEngine(configuration: .default)

        for fixtureURL in try exampleFixtureURLs() {
            let fixtureName = relativeFixtureName(for: fixtureURL)
            let input = try fixtureImage(at: fixtureURL, named: fixtureName)
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: BeautyParameters()
            )

            XCTAssertEqual(result.output.extent, input.extent, "\(fixtureName) changed extent before watermark")
            XCTAssertEqual(result.warnings, [], "\(fixtureName) changed no-admission warnings")
            XCTAssertEqual(
                result.metrics,
                [
                    "beauty.effects.activeCount": 0,
                    "beauty.effects.cappedCount": 0,
                ],
                "\(fixtureName) changed no-admission metrics"
            )
            XCTAssertEqual(
                result.detectionSummary,
                .notRun,
                "\(fixtureName) changed no-admission detection summary"
            )
            XCTAssertEqual(
                try renderedRGBABytes(from: result.output, named: fixtureName),
                try renderedRGBABytes(from: input, named: fixtureName),
                "\(fixtureName) changed rendered RGBA bytes before watermark"
            )
        }
    }

    private func rendererSource() throws -> String {
        let directory = try repositoryRootURL().appendingPathComponent(Self.rendererSourceDirectoryRelativePath)
        let files = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        .filter { $0.pathExtension == "swift" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
        guard !files.isEmpty else {
            throw RegressionTestError.unreadable(Self.rendererSourceDirectoryRelativePath)
        }
        return try files.map { file in
            guard let contents = try? String(contentsOf: file, encoding: .utf8) else {
                throw RegressionTestError.unreadable(file.path)
            }
            return "// FILE: \(file.lastPathComponent)\n\(contents)"
        }.joined(separator: "\n")
    }

    private func rendererCaseIDs(in source: String) -> [String] {
        source.split(separator: "\n").compactMap { line in
            let marker = "id: \""
            guard let markerRange = line.range(of: marker) else {
                return nil
            }
            let remainder = line[markerRange.upperBound...]
            guard let endIndex = remainder.firstIndex(of: "\"") else {
                return nil
            }
            return String(remainder[..<endIndex])
        }
    }

    private func rendererCaseSnippet(for caseID: String, in source: String) throws -> String {
        guard let idRange = source.range(of: "id: \"\(caseID)\"") else {
            throw RegressionTestError.missing(caseID)
        }

        let remainder = source[idRange.lowerBound...]
        if let nextCaseRange = remainder.range(of: "\n    RenderCase(") {
            return String(remainder[..<nextCaseRange.lowerBound])
        }
        if let endRange = remainder.range(of: "\n]") {
            return String(remainder[..<endRange.lowerBound])
        }
        return String(remainder)
    }

    private func containsStandaloneToken(_ token: String, in source: String) -> Bool {
        source.range(of: "\\b\(NSRegularExpression.escapedPattern(for: token))\\b", options: .regularExpression) != nil
    }

    private func containsInitializerLabel(_ label: String, in source: String) -> Bool {
        source.range(
            of: "\\b\(NSRegularExpression.escapedPattern(for: label))\\s*:",
            options: .regularExpression
        ) != nil
    }

    private func exampleFixtureURLs() throws -> [URL] {
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        return try Self.fixtureNames.map { fixtureName in
            let url = inputDirectory.appendingPathComponent(fixtureName)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw RegressionTestError.missing("example-images/input/\(fixtureName)")
            }
            return url
        }
    }

    private func fixtureImage(at url: URL, named fixtureName: String) throws -> CIImage {
        guard let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else {
            throw RegressionTestError.unreadable("example-images/input/\(fixtureName)")
        }
        return image
    }

    private func renderedRGBABytes(from image: CIImage, named fixtureName: String) throws -> [UInt8] {
        let extent = image.extent
        let width = Int(extent.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(extent.height.rounded(.toNearestOrAwayFromZero))
        guard width > 0, height > 0, CGFloat(width) == extent.width, CGFloat(height) == extent.height else {
            throw RegressionTestError.invalidExtent(fixtureName)
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace
        ])
        let rowBytes = width * 4
        var bytes = [UInt8](repeating: 0, count: rowBytes * height)
        try bytes.withUnsafeMutableBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                throw RegressionTestError.unreadable(fixtureName)
            }
            context.render(
                image,
                toBitmap: baseAddress,
                rowBytes: rowBytes,
                bounds: extent,
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return bytes
    }

    private func assertRedacted(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ")

        for forbidden in [
            "VNFaceObservation",
            "boundingBox",
            "controlPoint",
            "/private/var",
            "NSError",
            "AVError",
            "rawPresetJson",
            "raw JSON",
            "image bytes",
            "landmarks=",
            "landmarkCoordinates",
            "rawLandmark",
            "SIMD"
        ] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
        }
    }

    private func assertNoPhase36NoseFieldDisclosure(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()

        for forbidden in ["noseroot", "nosetip", "narrowing", "lift", "coordinate", "landmark"] {
            XCTAssertFalse(
                metadata.contains(forbidden),
                "Unexpected field-specific or raw geometry term: \(forbidden)",
                file: file,
                line: line
            )
        }
    }

    private func assertNoPhase39MouthFieldDisclosure(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()

        for forbidden in [
            "mouthyposition", "mouthtilt", "mouthxposition", "lippeakdefinition", "lipplump",
            "upperlips", "lowerlips", "innerlips", "support", "coordinate", "landmark",
            "controlpoint", "control point", "provider"
        ] {
            XCTAssertFalse(
                metadata.contains(forbidden),
                "Unexpected field-specific or raw geometry term: \(forbidden)",
                file: file,
                line: line
            )
        }
    }

    private func assertNoPhase43EyeFieldDisclosure(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()

        for forbidden in [
            "eyeheight", "eyelength", "uppereyelidlift", "pupilsize", "gazecorrection",
            "lowereyeliddrop", "eyetilt", "innercorneropen", "outercorneropen", "eyesymmetry",
            "pupil", "contour", "coordinate", "landmark", "controlpoint", "control point", "provider"
        ] {
            XCTAssertFalse(
                metadata.contains(forbidden),
                "Unexpected field-specific or raw geometry term: \(forbidden)",
                file: file,
                line: line
            )
        }
    }

    private func assertNoPhase47FaceFieldDisclosure(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()

        for forbidden in [
            "facecontoursmooth", "templefullness", "cheekboneslim", "chintaper",
            "contour", "median", "apex", "source", "target", "coordinate",
            "landmark", "controlpoint", "control point", "provider", "path",
        ] {
            XCTAssertFalse(
                metadata.contains(forbidden),
                "Unexpected field-specific or raw geometry term: \(forbidden)",
                file: file,
                line: line
            )
        }
    }

    private func relativeFixtureName(for url: URL) -> String {
        url.lastPathComponent
    }

    private func repositoryRootURL() throws -> URL {
        var current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while current.path != "/" {
            let renderer = current.appendingPathComponent(Self.rendererSourceRelativePath)
            if FileManager.default.fileExists(atPath: renderer.path) {
                return current
            }
            current.deleteLastPathComponent()
        }
        throw RegressionTestError.missing(Self.rendererSourceRelativePath)
    }
}

private enum RegressionTestError: Error, CustomStringConvertible {
    case missing(String)
    case unreadable(String)
    case invalidExtent(String)

    var description: String {
        switch self {
        case .missing(let name):
            return "Missing required regression input: \(name)"
        case .unreadable(let name):
            return "Could not read required regression input: \(name)"
        case .invalidExtent(let name):
            return "Invalid rendered image extent for \(name)"
        }
    }
}

extension BeautyRendererOutputRegressionTests {
    func testPhase64ScleraOutputUsesExactlyOnePublicScalarAndPresentationFreeMode() throws {
        let source = try rendererSource()
        let caseID = "scleraRednessReduction_1p00"
        let snippet = try rendererCaseSnippet(for: caseID, in: source)

        XCTAssertEqual(rendererCaseIDs(in: source), Self.expectedRendererCaseIDs)
        XCTAssertEqual(Self.expectedRendererCaseIDs.count, 74)
        XCTAssertEqual(Set(Self.expectedRendererCaseIDs).count, 74)
        XCTAssertEqual(Self.expectedRendererCaseIDs.filter { $0 == caseID }.count, 1)
        XCTAssertTrue(snippet.contains("BeautyParameters(scleraRednessReduction: 1)"))
        XCTAssertEqual(["scleraRednessReduction:"].filter { snippet.contains($0) }, ["scleraRednessReduction:"])
        for forbidden in ["scleraRedness", "scleraWhitening", "eyeRednessReduction"] {
            XCTAssertFalse(containsInitializerLabel(forbidden, in: source), forbidden)
            XCTAssertFalse(source.contains("\"\(forbidden)\""), forbidden)
        }
        XCTAssertFalse(containsInitializerLabel("upperEyelidFullnessReduction", in: source))
        XCTAssertTrue(source.contains("--no-watermark"))
        XCTAssertEqual(source.components(separatedBy: "engine.processResult(").count - 1, 1)
    }

    func testPhase61TeethOutputUsesExactlyOnePublicScalarAndPresentationFreeMode() throws {
        let source = try rendererSource()
        let caseID = "teethWhitening_1p00"
        let snippet = try rendererCaseSnippet(for: caseID, in: source)

        XCTAssertEqual(rendererCaseIDs(in: source), Self.expectedRendererCaseIDs)
        XCTAssertEqual(Self.expectedRendererCaseIDs.count, 74)
        XCTAssertEqual(Set(Self.expectedRendererCaseIDs).count, 74)
        XCTAssertEqual(Self.expectedRendererCaseIDs.filter { $0 == caseID }.count, 1)
        XCTAssertTrue(snippet.contains("BeautyParameters(teethWhitening: 1)"))
        XCTAssertEqual(["teethWhitening:"].filter { snippet.contains($0) }, ["teethWhitening:"])
        for forbidden in ["teethWhite", "toothWhitening", "teethBrightness"] {
            XCTAssertFalse(
                Self.expectedRendererCaseIDs.contains { $0 == forbidden || $0.hasPrefix("\(forbidden)_") },
                forbidden
            )
            XCTAssertFalse(containsInitializerLabel(forbidden, in: source), forbidden)
            XCTAssertFalse(source.contains("\"\(forbidden)\""), forbidden)
        }

        XCTAssertTrue(source.contains("--no-watermark"))
        XCTAssertEqual(source.components(separatedBy: "engine.processResult(").count - 1, 1)
    }

    func testDeferredUpperEyelidGateKeepsRendererAndSavedOutputSurfaceAbsent() throws {
        let source = try rendererSource()
        let candidateNames = [
            "upperEyelidFullness", "upperLidFullness", "eyelidFullness", "lidFullness",
            "upperEyelidFullnessReduction", "upperLidFullnessReduction", "eyelidFullnessReduction", "lidFullnessReduction",
            "upperEyelidFullnessRemoval", "upperLidFullnessRemoval", "eyelidFullnessRemoval", "lidFullnessRemoval",
            "upperEyelidFat", "upperLidFat", "eyelidFat", "lidFat",
            "upperEyelidFatReduction", "upperLidFatReduction", "eyelidFatReduction", "lidFatReduction",
            "upperEyelidFatRemoval", "upperLidFatRemoval", "eyelidFatRemoval", "lidFatRemoval",
            "removeUpperEyelidFat", "removeEyelidFat", "removeUpperLidFat", "removeLidFat",
            "upperEyelidDefatting", "upperLidDefatting", "eyelidDefatting", "lidDefatting",
            "defatUpperEyelid", "defatEyelid", "defatUpperLid", "defatLid",
            "upper_eyelid_fullness", "upper_lid_fullness", "eyelid_fullness", "lid_fullness",
            "upper_eyelid_fullness_reduction", "upper_lid_fullness_reduction", "eyelid_fullness_reduction", "lid_fullness_reduction",
            "upper_eyelid_fullness_removal", "upper_lid_fullness_removal", "eyelid_fullness_removal", "lid_fullness_removal",
            "upper_eyelid_fat", "upper_lid_fat", "eyelid_fat", "lid_fat",
            "upper_eyelid_fat_reduction", "upper_lid_fat_reduction", "eyelid_fat_reduction", "lid_fat_reduction",
            "upper_eyelid_fat_removal", "upper_lid_fat_removal", "eyelid_fat_removal", "lid_fat_removal",
            "remove_upper_eyelid_fat", "remove_eyelid_fat", "remove_upper_lid_fat", "remove_lid_fat",
            "upper_eyelid_defatting", "upper_lid_defatting", "eyelid_defatting", "lid_defatting",
            "defat_upper_eyelid", "defat_eyelid", "defat_upper_lid", "defat_lid",
            "eyes.fat", "去脂",
        ]

        XCTAssertEqual(rendererCaseIDs(in: source), Self.expectedRendererCaseIDs)
        XCTAssertEqual(Self.expectedRendererCaseIDs.count, 74)
        XCTAssertEqual(Set(Self.expectedRendererCaseIDs).count, 74)
        for forbidden in candidateNames {
            XCTAssertFalse(
                Self.expectedRendererCaseIDs.contains { $0 == forbidden || $0.hasPrefix("\(forbidden)_") },
                forbidden
            )
            XCTAssertFalse(containsInitializerLabel(forbidden, in: source), forbidden)
            XCTAssertFalse(source.contains("\"\(forbidden)\""), forbidden)
        }

        for shipped in [
            "skinSmoothing_0p50", "eyeHeight_0p25", "upperEyelidLift_0p25",
            "eyebrowYPosition_plus0p25",
        ] {
            XCTAssertTrue(Self.expectedRendererCaseIDs.contains(shipped), shipped)
        }
        XCTAssertEqual(source.components(separatedBy: "engine.processResult(").count - 1, 1)
    }

    func testIndependentLocalRetouchOutputRoutesKeepUpperEyelidCandidateAbsent() throws {
        let source = try rendererSource()
        let candidates = ["upperEyelidFullnessReduction"]

        XCTAssertEqual(rendererCaseIDs(in: source), Self.expectedRendererCaseIDs)
        XCTAssertEqual(Self.expectedRendererCaseIDs.count, 74)
        XCTAssertEqual(Set(Self.expectedRendererCaseIDs).count, 74)
        XCTAssertTrue(Self.expectedRendererCaseIDs.contains("teethWhitening_1p00"))
        XCTAssertTrue(Self.expectedRendererCaseIDs.contains("scleraRednessReduction_1p00"))
        for candidate in candidates {
            XCTAssertFalse(containsInitializerLabel(candidate, in: source), candidate)
            XCTAssertFalse(source.contains("\"\(candidate)\""), candidate)
            XCTAssertFalse(
                Self.expectedRendererCaseIDs.contains {
                    $0 == candidate || $0.hasPrefix("\(candidate)_")
                },
                candidate
            )
        }
        XCTAssertEqual(source.components(separatedBy: "engine.processResult(").count - 1, 1)
    }
}
