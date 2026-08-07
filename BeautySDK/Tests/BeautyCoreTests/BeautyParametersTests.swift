import XCTest
import BeautySDK

// Requirement evidence: SDK-03, SDK-05.
final class BeautyParametersTests: XCTestCase {
    func testBROW01SignedFieldsNormalizeEveryFiniteAndNonFiniteBoundaryIndependently() {
        let cases: [(name: String, value: Float, expected: Float)] = [
            ("negative overflow", -2, -1),
            ("negative edge", -1, -1),
            ("zero", 0, 0),
            ("positive edge", 1, 1),
            ("positive overflow", 2, 1),
            ("NaN", .nan, 0),
            ("positive infinity", .infinity, 0),
            ("negative infinity", -.infinity, 0),
        ]
        let fields: [(name: String, keyPath: KeyPath<BeautyParameters, Float>, make: (Float) -> BeautyParameters)] = [
            ("eyebrowYPosition", \.eyebrowYPosition, { BeautyParameters(eyebrowYPosition: $0) }),
            ("eyebrowThickness", \.eyebrowThickness, { BeautyParameters(eyebrowThickness: $0) }),
            ("eyebrowLength", \.eyebrowLength, { BeautyParameters(eyebrowLength: $0) }),
            ("eyebrowSpacing", \.eyebrowSpacing, { BeautyParameters(eyebrowSpacing: $0) }),
            ("eyebrowHeadSpacing", \.eyebrowHeadSpacing, { BeautyParameters(eyebrowHeadSpacing: $0) }),
            ("eyebrowTilt", \.eyebrowTilt, { BeautyParameters(eyebrowTilt: $0) }),
        ]

        for field in fields {
            for testCase in cases {
                XCTAssertEqual(
                    field.make(testCase.value)[keyPath: field.keyPath],
                    testCase.expected,
                    accuracy: 0.0001,
                    "\(field.name) \(testCase.name)"
                )
            }
        }
    }

    func testBROW01PeakDefinitionNormalizesUnitAndNonFiniteBoundaries() {
        let cases: [(name: String, value: Float, expected: Float)] = [
            ("negative overflow", -2, 0),
            ("negative edge", -1, 0),
            ("zero", 0, 0),
            ("positive edge", 1, 1),
            ("positive overflow", 2, 1),
            ("NaN", .nan, 0),
            ("positive infinity", .infinity, 0),
            ("negative infinity", -.infinity, 0),
        ]

        for testCase in cases {
            XCTAssertEqual(
                BeautyParameters(eyebrowPeakDefinition: testCase.value).eyebrowPeakDefinition,
                testCase.expected,
                accuracy: 0.0001,
                "eyebrowPeakDefinition \(testCase.name)"
            )
        }
    }

    func testBROW01SevenFieldsRemainIndependentAcrossInitializationEqualityAndNormalization() {
        let distinct = BeautyParameters(
            eyebrowYPosition: -0.71,
            eyebrowThickness: -0.52,
            eyebrowLength: -0.33,
            eyebrowSpacing: 0.14,
            eyebrowHeadSpacing: 0.35,
            eyebrowTilt: 0.56,
            eyebrowPeakDefinition: 0.77
        )
        let reordered = BeautyParameters(
            eyebrowYPosition: -0.52,
            eyebrowThickness: -0.33,
            eyebrowLength: 0.14,
            eyebrowSpacing: 0.35,
            eyebrowHeadSpacing: 0.56,
            eyebrowTilt: 0.77,
            eyebrowPeakDefinition: 0.71
        )

        XCTAssertNotEqual(distinct, reordered)
        XCTAssertEqual(
            [
                distinct.eyebrowYPosition,
                distinct.eyebrowThickness,
                distinct.eyebrowLength,
                distinct.eyebrowSpacing,
                distinct.eyebrowHeadSpacing,
                distinct.eyebrowTilt,
                distinct.eyebrowPeakDefinition,
            ],
            [-0.71, -0.52, -0.33, 0.14, 0.35, 0.56, 0.77]
        )

        var mutable = distinct
        mutable.eyebrowYPosition = -2
        mutable.eyebrowThickness = 2
        mutable.eyebrowLength = .nan
        mutable.eyebrowSpacing = .infinity
        mutable.eyebrowHeadSpacing = -.infinity
        mutable.eyebrowTilt = -2
        mutable.eyebrowPeakDefinition = -1

        let normalized = mutable.normalized()
        XCTAssertEqual(normalized.eyebrowYPosition, -1)
        XCTAssertEqual(normalized.eyebrowThickness, 1)
        XCTAssertEqual(normalized.eyebrowLength, 0)
        XCTAssertEqual(normalized.eyebrowSpacing, 0)
        XCTAssertEqual(normalized.eyebrowHeadSpacing, 0)
        XCTAssertEqual(normalized.eyebrowTilt, -1)
        XCTAssertEqual(normalized.eyebrowPeakDefinition, 0)
        XCTAssertEqual(mutable.eyebrowYPosition, -2, "normalization returns a copy")
        XCTAssertTrue(mutable.eyebrowLength.isNaN, "normalization does not mutate the source")
    }

    func testBROW02SourceDefaultsResetInventoryAndSnapshotDiffAreExact() {
        let sourceStyle = BeautyParameters(faceSlim: 0.12, eyeSize: 0.23, filterId: "clean_01")
        let reset = BeautyParameters()
        let labels = Mirror(reflecting: sourceStyle).children.compactMap(\.label)
        let eyebrowLabels = [
            "eyebrowYPosition", "eyebrowThickness", "eyebrowLength", "eyebrowSpacing",
            "eyebrowHeadSpacing", "eyebrowTilt", "eyebrowPeakDefinition",
        ]

        XCTAssertEqual(labels.count, 61)
        XCTAssertEqual(labels.filter { $0 != "filterId" }.count, 60)
        for label in eyebrowLabels {
            XCTAssertEqual(labels.filter { $0 == label }.count, 1, "independent storage for \(label)")
        }
        XCTAssertEqual(
            [
                sourceStyle.eyebrowYPosition,
                sourceStyle.eyebrowThickness,
                sourceStyle.eyebrowLength,
                sourceStyle.eyebrowSpacing,
                sourceStyle.eyebrowHeadSpacing,
                sourceStyle.eyebrowTilt,
                sourceStyle.eyebrowPeakDefinition,
            ],
            Array(repeating: Float(0), count: 7)
        )
        XCTAssertNotEqual(sourceStyle, reset)
        XCTAssertEqual(reset, BeautyParameters())
        let fieldSnapshots = [
            BeautyParameters(eyebrowYPosition: 0.1),
            BeautyParameters(eyebrowThickness: 0.2),
            BeautyParameters(eyebrowLength: 0.3),
            BeautyParameters(eyebrowSpacing: 0.4),
            BeautyParameters(eyebrowHeadSpacing: 0.5),
            BeautyParameters(eyebrowTilt: 0.6),
            BeautyParameters(eyebrowPeakDefinition: 0.7),
        ]
        XCTAssertEqual(fieldSnapshots.count, 7)
        for (index, snapshot) in fieldSnapshots.enumerated() {
            XCTAssertNotEqual(reset, snapshot)
            for other in fieldSnapshots.dropFirst(index + 1) {
                XCTAssertNotEqual(snapshot, other)
            }
        }
    }

    func testBROW02Complete61KeyRoundTripAndLegacy53PayloadRemainIndependentAndNeutral() throws {
        let parameters = BeautyParameters(
            skinSmoothing: 0.08,
            chinLength: -0.19,
            eyeTilt: -0.27,
            eyebrowYPosition: -0.71,
            eyebrowThickness: -0.52,
            eyebrowLength: -0.33,
            eyebrowSpacing: 0.14,
            eyebrowHeadSpacing: 0.35,
            eyebrowTilt: 0.56,
            eyebrowPeakDefinition: 0.77,
            mouthTilt: 0.28,
            filterId: "clean_01",
            filterIntensity: 0.39
        )
        let eyebrowKeys = [
            "eyebrowYPosition", "eyebrowThickness", "eyebrowLength", "eyebrowSpacing",
            "eyebrowHeadSpacing", "eyebrowTilt", "eyebrowPeakDefinition",
        ]

        let data = try JSONEncoder().encode(parameters)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)

        XCTAssertEqual(object.count, 61)
        XCTAssertEqual(Set(object.keys), Set(Mirror(reflecting: parameters).children.compactMap(\.label)))
        XCTAssertEqual(decoded, parameters)
        XCTAssertEqual(
            [
                decoded.eyebrowYPosition,
                decoded.eyebrowThickness,
                decoded.eyebrowLength,
                decoded.eyebrowSpacing,
                decoded.eyebrowHeadSpacing,
                decoded.eyebrowTilt,
                decoded.eyebrowPeakDefinition,
            ],
            [-0.71, -0.52, -0.33, 0.14, 0.35, 0.56, 0.77]
        )

        var legacy = object
        for key in eyebrowKeys {
            legacy.removeValue(forKey: key)
        }
        legacy.removeValue(forKey: "scleraRednessReduction")
        XCTAssertEqual(legacy.count, 53)
        XCTAssertTrue(eyebrowKeys.allSatisfy { legacy[$0] == nil })

        let legacyDecoded = try JSONDecoder().decode(
            BeautyParameters.self,
            from: JSONSerialization.data(withJSONObject: legacy)
        )
        XCTAssertEqual(
            [
                legacyDecoded.eyebrowYPosition,
                legacyDecoded.eyebrowThickness,
                legacyDecoded.eyebrowLength,
                legacyDecoded.eyebrowSpacing,
                legacyDecoded.eyebrowHeadSpacing,
                legacyDecoded.eyebrowTilt,
                legacyDecoded.eyebrowPeakDefinition,
            ],
            Array(repeating: Float(0), count: 7)
        )
        XCTAssertEqual(legacyDecoded.skinSmoothing, parameters.skinSmoothing)
        XCTAssertEqual(legacyDecoded.chinLength, parameters.chinLength)
        XCTAssertEqual(legacyDecoded.eyeTilt, parameters.eyeTilt)
        XCTAssertEqual(legacyDecoded.mouthTilt, parameters.mouthTilt)
        XCTAssertEqual(legacyDecoded.filterId, parameters.filterId)
        XCTAssertEqual(legacyDecoded.filterIntensity, parameters.filterIntensity)
    }

    func testFACE07FACE08FACE09FACE12PositiveOnlyInputsNormalizeIndependently() {
        let cases: [(name: String, value: Float, expected: Float)] = [
            ("negative", -1, 0),
            ("in range", 0.37, 0.37),
            ("overflow", 2, 1),
            ("NaN", .nan, 0),
            ("positive infinity", .infinity, 0),
            ("negative infinity", -.infinity, 0),
        ]
        let fields: [(name: String, keyPath: KeyPath<BeautyParameters, Float>, make: (Float) -> BeautyParameters)] = [
            ("faceContourSmooth", \.faceContourSmooth, { BeautyParameters(faceContourSmooth: $0) }),
            ("templeFullness", \.templeFullness, { BeautyParameters(templeFullness: $0) }),
            ("cheekboneSlim", \.cheekboneSlim, { BeautyParameters(cheekboneSlim: $0) }),
            ("chinTaper", \.chinTaper, { BeautyParameters(chinTaper: $0) }),
        ]

        for field in fields {
            for testCase in cases {
                XCTAssertEqual(
                    field.make(testCase.value)[keyPath: field.keyPath],
                    testCase.expected,
                    accuracy: 0.0001,
                    "\(field.name) \(testCase.name)"
                )
            }
        }
    }

    func testFACE07FACE08FACE09FACE12NormalizedCopyReappliesRulesWithoutMutatingSource() {
        var parameters = BeautyParameters(
            chinLength: -0.42,
            faceContourSmooth: 0.11,
            templeFullness: 0.22,
            cheekboneSlim: 0.33,
            chinTaper: 0.44
        )
        parameters.faceContourSmooth = 2
        parameters.templeFullness = -1
        parameters.cheekboneSlim = .nan
        parameters.chinTaper = .infinity

        let normalized = parameters.normalized()

        XCTAssertEqual(normalized.faceContourSmooth, 1)
        XCTAssertEqual(normalized.templeFullness, 0)
        XCTAssertEqual(normalized.cheekboneSlim, 0)
        XCTAssertEqual(normalized.chinTaper, 0)
        XCTAssertEqual(normalized.chinLength, -0.42, accuracy: 0.0001)
        XCTAssertEqual(parameters.faceContourSmooth, 2, "normalization returns a copy")
        XCTAssertEqual(parameters.templeFullness, -1, "normalization does not mutate the source")
        XCTAssertTrue(parameters.cheekboneSlim.isNaN, "normalization does not mutate the source")
        XCTAssertTrue(parameters.chinTaper.isInfinite, "normalization does not mutate the source")
    }

    func testFACE07FACE08FACE09FACE12InventoryAndSourceDefaultsAreExact() {
        let sourceStyle = BeautyParameters(
            faceSlim: 0.12,
            chinLength: -0.13,
            filterId: "clean_01"
        )
        let labels = Mirror(reflecting: sourceStyle).children.compactMap(\.label)
        let expected = [
            "faceContourSmooth",
            "templeFullness",
            "cheekboneSlim",
            "chinTaper",
        ]

        XCTAssertEqual(labels.count, 61)
        for field in expected {
            XCTAssertEqual(labels.filter { $0 == field }.count, 1, "independent storage for \(field)")
        }
        XCTAssertEqual(sourceStyle.faceContourSmooth, 0)
        XCTAssertEqual(sourceStyle.templeFullness, 0)
        XCTAssertEqual(sourceStyle.cheekboneSlim, 0)
        XCTAssertEqual(sourceStyle.chinTaper, 0)
        XCTAssertEqual(sourceStyle.faceSlim, 0.12, accuracy: 0.0001)
        XCTAssertEqual(sourceStyle.chinLength, -0.13, accuracy: 0.0001)
    }

    func testFACE07FACE08FACE09FACE12All52KeysRoundTripAndLegacy48DecodesNeutrally() throws {
        let parameters = BeautyParameters(
            chinLength: -0.64,
            faceContourSmooth: 0.13,
            templeFullness: 0.27,
            cheekboneSlim: 0.41,
            chinTaper: 0.55,
            filterId: "clean_01"
        )
        let data = try JSONEncoder().encode(parameters)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)

        XCTAssertEqual(object.count, 61)
        XCTAssertEqual(decoded, parameters)
        XCTAssertEqual(
            Set([
                decoded.faceContourSmooth,
                decoded.templeFullness,
                decoded.cheekboneSlim,
                decoded.chinTaper,
            ]).count,
            4,
            "unequal values prove independent encoded storage"
        )
        XCTAssertEqual(decoded.chinLength, -0.64, accuracy: 0.0001)

        var legacy = object
        for key in [
            "faceContourSmooth", "templeFullness", "cheekboneSlim", "chinTaper",
            "eyebrowYPosition", "eyebrowThickness", "eyebrowLength", "eyebrowSpacing",
            "eyebrowHeadSpacing", "eyebrowTilt", "eyebrowPeakDefinition",
            "teethWhitening", "scleraRednessReduction",
        ] {
            legacy.removeValue(forKey: key)
        }
        XCTAssertEqual(legacy.count, 48)

        let legacyDecoded = try JSONDecoder().decode(
            BeautyParameters.self,
            from: JSONSerialization.data(withJSONObject: legacy)
        )
        XCTAssertEqual(legacyDecoded.faceContourSmooth, 0)
        XCTAssertEqual(legacyDecoded.templeFullness, 0)
        XCTAssertEqual(legacyDecoded.cheekboneSlim, 0)
        XCTAssertEqual(legacyDecoded.chinTaper, 0)
        XCTAssertEqual(legacyDecoded.chinLength, -0.64, accuracy: 0.0001)
    }

    func testEYE01NewPositiveOnlyInputsNormalizeIndependently() {
        let cases: [(name: String, value: Float, expected: Float)] = [
            ("negative", -1, 0),
            ("overflow", 2, 1),
            ("in range", 0.37, 0.37),
            ("NaN", .nan, 0),
            ("positive infinity", .infinity, 0),
            ("negative infinity", -.infinity, 0),
        ]
        let fields: [(name: String, keyPath: KeyPath<BeautyParameters, Float>, make: (Float) -> BeautyParameters)] = [
            ("eyeHeight", \.eyeHeight, { BeautyParameters(eyeHeight: $0) }),
            ("eyeLength", \.eyeLength, { BeautyParameters(eyeLength: $0) }),
            ("upperEyelidLift", \.upperEyelidLift, { BeautyParameters(upperEyelidLift: $0) }),
            ("pupilSize", \.pupilSize, { BeautyParameters(pupilSize: $0) }),
            ("gazeCorrection", \.gazeCorrection, { BeautyParameters(gazeCorrection: $0) }),
            ("lowerEyelidDrop", \.lowerEyelidDrop, { BeautyParameters(lowerEyelidDrop: $0) }),
            ("innerCornerOpen", \.innerCornerOpen, { BeautyParameters(innerCornerOpen: $0) }),
            ("outerCornerOpen", \.outerCornerOpen, { BeautyParameters(outerCornerOpen: $0) }),
            ("eyeSymmetry", \.eyeSymmetry, { BeautyParameters(eyeSymmetry: $0) }),
        ]

        for field in fields {
            for testCase in cases {
                XCTAssertEqual(
                    field.make(testCase.value)[keyPath: field.keyPath],
                    testCase.expected,
                    accuracy: 0.0001,
                    "\(field.name) \(testCase.name)"
                )
            }
        }
    }

    func testEYE02EyeTiltNormalizesSignedValuesAndBothDirections() {
        let cases: [(name: String, value: Float, expected: Float)] = [
            ("negative overflow", -2, -1),
            ("positive overflow", 2, 1),
            ("negative in range", -0.37, -0.37),
            ("positive in range", 0.21, 0.21),
            ("NaN", .nan, 0),
            ("positive infinity", .infinity, 0),
            ("negative infinity", -.infinity, 0),
        ]

        for testCase in cases {
            XCTAssertEqual(
                BeautyParameters(eyeTilt: testCase.value).eyeTilt,
                testCase.expected,
                accuracy: 0.0001,
                "eyeTilt \(testCase.name)"
            )
        }
    }

    func testEYE01EYE02NormalizedCopyReappliesNewEyeRules() {
        var parameters = BeautyParameters(
            eyeHeight: 0.11,
            eyeLength: 0.22,
            upperEyelidLift: 0.33,
            pupilSize: 0.44,
            gazeCorrection: 0.55,
            lowerEyelidDrop: 0.66,
            eyeTilt: -0.17,
            innerCornerOpen: 0.77,
            outerCornerOpen: 0.88,
            eyeSymmetry: 0.99
        )
        parameters.eyeHeight = 2
        parameters.eyeLength = -1
        parameters.upperEyelidLift = .nan
        parameters.pupilSize = .infinity
        parameters.gazeCorrection = -.infinity
        parameters.lowerEyelidDrop = 2
        parameters.eyeTilt = -2
        parameters.innerCornerOpen = -1
        parameters.outerCornerOpen = 2
        parameters.eyeSymmetry = .nan

        let normalized = parameters.normalized()

        XCTAssertEqual(normalized.eyeHeight, 1)
        XCTAssertEqual(normalized.eyeLength, 0)
        XCTAssertEqual(normalized.upperEyelidLift, 0)
        XCTAssertEqual(normalized.pupilSize, 0)
        XCTAssertEqual(normalized.gazeCorrection, 0)
        XCTAssertEqual(normalized.lowerEyelidDrop, 1)
        XCTAssertEqual(normalized.eyeTilt, -1)
        XCTAssertEqual(normalized.innerCornerOpen, 0)
        XCTAssertEqual(normalized.outerCornerOpen, 1)
        XCTAssertEqual(normalized.eyeSymmetry, 0)
        XCTAssertEqual(parameters.eyeHeight, 2, "normalization returns a copy")
        XCTAssertTrue(parameters.upperEyelidLift.isNaN, "normalization does not mutate the source")
    }

    func testEYE03InventoryContainsExactlyTenIndependentEyeFields() {
        let parameters = BeautyParameters()
        let labels = Set(Mirror(reflecting: parameters).children.compactMap(\.label))
        let expected: Set<String> = [
            "eyeHeight",
            "eyeLength",
            "upperEyelidLift",
            "pupilSize",
            "gazeCorrection",
            "lowerEyelidDrop",
            "eyeTilt",
            "innerCornerOpen",
            "outerCornerOpen",
            "eyeSymmetry",
        ]

        XCTAssertEqual(labels.count, 61)
        XCTAssertTrue(expected.isSubset(of: labels))
        XCTAssertEqual(expected.count, 10)
        for field in expected {
            XCTAssertEqual(labels.filter { $0 == field }.count, 1, "independent storage for \(field)")
        }
        XCTAssertEqual(
            [
                parameters.eyeHeight,
                parameters.eyeLength,
                parameters.upperEyelidLift,
                parameters.pupilSize,
                parameters.gazeCorrection,
                parameters.lowerEyelidDrop,
                parameters.eyeTilt,
                parameters.innerCornerOpen,
                parameters.outerCornerOpen,
                parameters.eyeSymmetry,
            ],
            Array(repeating: Float(0), count: 10)
        )
    }

    func testEYE03Legacy38FieldJSONDecodesTenNewFieldsAsZero() throws {
        let source = BeautyParameters(
            skinSmoothing: 0.1,
            eyeSize: 0.12,
            eyeDistance: -0.13,
            eyeYPosition: 0.14,
            eyeTailLift: 0.15,
            noseBridge: 0.16,
            mouthTilt: -0.17,
            filterId: "clean_01",
            filterIntensity: 0.18
        )
        let complete = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(source)) as? [String: Any]
        )
        var legacy = complete
        for key in [
            "eyeHeight", "eyeLength", "upperEyelidLift", "pupilSize", "gazeCorrection",
            "lowerEyelidDrop", "eyeTilt", "innerCornerOpen", "outerCornerOpen", "eyeSymmetry",
            "faceContourSmooth", "templeFullness", "cheekboneSlim", "chinTaper",
            "eyebrowYPosition", "eyebrowThickness", "eyebrowLength", "eyebrowSpacing",
            "eyebrowHeadSpacing", "eyebrowTilt", "eyebrowPeakDefinition",
            "teethWhitening", "scleraRednessReduction",
        ] {
            legacy.removeValue(forKey: key)
        }
        XCTAssertEqual(legacy.count, 38)

        let decoded = try JSONDecoder().decode(
            BeautyParameters.self,
            from: JSONSerialization.data(withJSONObject: legacy)
        )

        XCTAssertEqual(decoded.eyeSize, source.eyeSize)
        XCTAssertEqual(decoded.eyeDistance, source.eyeDistance)
        XCTAssertEqual(decoded.eyeYPosition, source.eyeYPosition)
        XCTAssertEqual(decoded.eyeTailLift, source.eyeTailLift)
        XCTAssertEqual(decoded.eyeHeight, 0)
        XCTAssertEqual(decoded.eyeLength, 0)
        XCTAssertEqual(decoded.upperEyelidLift, 0)
        XCTAssertEqual(decoded.pupilSize, 0)
        XCTAssertEqual(decoded.gazeCorrection, 0)
        XCTAssertEqual(decoded.lowerEyelidDrop, 0)
        XCTAssertEqual(decoded.eyeTilt, 0)
        XCTAssertEqual(decoded.innerCornerOpen, 0)
        XCTAssertEqual(decoded.outerCornerOpen, 0)
        XCTAssertEqual(decoded.eyeSymmetry, 0)
    }

    func testEYE03All48FieldsRoundTripUnequalEyeValuesWithoutAliasing() throws {
        let parameters = BeautyParameters(
            eyeSize: 0.11,
            eyeDistance: -0.12,
            eyeYPosition: 0.13,
            eyeTailLift: 0.14,
            eyeHeight: 0.21,
            eyeLength: 0.32,
            upperEyelidLift: 0.43,
            pupilSize: 0.54,
            gazeCorrection: 0.65,
            lowerEyelidDrop: 0.76,
            eyeTilt: -0.87,
            innerCornerOpen: 0.28,
            outerCornerOpen: 0.39,
            eyeSymmetry: 0.91,
            filterId: "clean_01"
        )

        let data = try JSONEncoder().encode(parameters)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)

        XCTAssertEqual(object.count, 61)
        XCTAssertEqual(decoded, parameters)
        XCTAssertEqual(decoded.eyeHeight, 0.21, accuracy: 0.0001)
        XCTAssertEqual(decoded.eyeLength, 0.32, accuracy: 0.0001)
        XCTAssertEqual(decoded.upperEyelidLift, 0.43, accuracy: 0.0001)
        XCTAssertEqual(decoded.pupilSize, 0.54, accuracy: 0.0001)
        XCTAssertEqual(decoded.gazeCorrection, 0.65, accuracy: 0.0001)
        XCTAssertEqual(decoded.lowerEyelidDrop, 0.76, accuracy: 0.0001)
        XCTAssertEqual(decoded.eyeTilt, -0.87, accuracy: 0.0001)
        XCTAssertEqual(decoded.innerCornerOpen, 0.28, accuracy: 0.0001)
        XCTAssertEqual(decoded.outerCornerOpen, 0.39, accuracy: 0.0001)
        XCTAssertEqual(decoded.eyeSymmetry, 0.91, accuracy: 0.0001)
        XCTAssertNotEqual(decoded.eyeHeight, decoded.eyeLength)
        XCTAssertNotEqual(decoded.innerCornerOpen, decoded.outerCornerOpen)
    }

    func testEYE04ExistingSourceStyleInitializerKeepsNewEyeValuesNeutral() {
        let sourceStyle = BeautyParameters(
            skinSmoothing: 0.2,
            eyeSize: 0.12,
            eyeDistance: -0.13,
            eyeYPosition: 0.14,
            eyeTailLift: 0.15,
            filterId: "clean_01"
        )

        XCTAssertEqual(sourceStyle.eyeHeight, 0)
        XCTAssertEqual(sourceStyle.eyeLength, 0)
        XCTAssertEqual(sourceStyle.upperEyelidLift, 0)
        XCTAssertEqual(sourceStyle.pupilSize, 0)
        XCTAssertEqual(sourceStyle.gazeCorrection, 0)
        XCTAssertEqual(sourceStyle.lowerEyelidDrop, 0)
        XCTAssertEqual(sourceStyle.eyeTilt, 0)
        XCTAssertEqual(sourceStyle.innerCornerOpen, 0)
        XCTAssertEqual(sourceStyle.outerCornerOpen, 0)
        XCTAssertEqual(sourceStyle.eyeSymmetry, 0)
        XCTAssertEqual(sourceStyle.eyeSize, 0.12, accuracy: 0.0001)
        XCTAssertEqual(sourceStyle.eyeDistance, -0.13, accuracy: 0.0001)
        XCTAssertEqual(sourceStyle.eyeYPosition, 0.14, accuracy: 0.0001)
        XCTAssertEqual(sourceStyle.eyeTailLift, 0.15, accuracy: 0.0001)
    }

    func testPhase38MOUTH01DefaultsAreZeroEffectAndExpose38StoredFields() {
        let parameters = BeautyParameters()

        XCTAssertEqual(Mirror(reflecting: parameters).children.count, 61)
        XCTAssertEqual(parameters.skinSmoothing, 0)
        XCTAssertEqual(parameters.skinWhitening, 0)
        XCTAssertEqual(parameters.skinRosy, 0)
        XCTAssertEqual(parameters.skinSharpen, 0)
        XCTAssertEqual(parameters.brightness, 0)
        XCTAssertEqual(parameters.contrast, 0)
        XCTAssertEqual(parameters.saturation, 0)
        XCTAssertEqual(parameters.temperature, 0)
        XCTAssertEqual(parameters.tint, 0)
        XCTAssertEqual(parameters.exposure, 0)
        XCTAssertEqual(parameters.highlight, 0)
        XCTAssertEqual(parameters.shadow, 0)
        XCTAssertEqual(parameters.faceSlim, 0)
        XCTAssertEqual(parameters.faceSmall, 0)
        XCTAssertEqual(parameters.faceVShape, 0)
        XCTAssertEqual(parameters.jawSlim, 0)
        XCTAssertEqual(parameters.chinLength, 0)
        XCTAssertEqual(parameters.eyeSize, 0)
        XCTAssertEqual(parameters.eyeDistance, 0)
        XCTAssertEqual(parameters.eyeYPosition, 0)
        XCTAssertEqual(parameters.eyeTailLift, 0)
        XCTAssertEqual(parameters.noseSlim, 0)
        XCTAssertEqual(parameters.noseWingSlim, 0)
        XCTAssertEqual(parameters.noseTipSize, 0)
        XCTAssertEqual(parameters.noseBridge, 0)
        XCTAssertEqual(parameters.noseRootNarrowing, 0)
        XCTAssertEqual(parameters.noseTipLift, 0)
        XCTAssertEqual(parameters.mouthSize, 0)
        XCTAssertEqual(parameters.mouthWidth, 0)
        XCTAssertEqual(parameters.smile, 0)
        XCTAssertEqual(parameters.mouthYPosition, 0)
        XCTAssertEqual(parameters.mouthTilt, 0)
        XCTAssertEqual(parameters.mouthXPosition, 0)
        XCTAssertEqual(parameters.lipPeakDefinition, 0)
        XCTAssertEqual(parameters.lipPlump, 0)
        XCTAssertEqual(parameters.lipColor, 0)
        XCTAssertNil(parameters.filterId)
        XCTAssertEqual(parameters.filterIntensity, 0)
    }

    func testSDK05NormalizationClampsRangesAndZerosNonFiniteValues() {
        let parameters = BeautyParameters(
            skinSmoothing: 2,
            brightness: -2,
            contrast: 2,
            saturation: -2,
            temperature: 2,
            tint: -2,
            exposure: 2,
            highlight: -2,
            shadow: 2,
            chinLength: -2,
            eyeSize: .nan,
            noseTipSize: .infinity,
            mouthSize: -.infinity,
            filterIntensity: 4
        )

        XCTAssertEqual(parameters.skinSmoothing, 1)
        XCTAssertEqual(parameters.brightness, -1)
        XCTAssertEqual(parameters.contrast, 1)
        XCTAssertEqual(parameters.saturation, -1)
        XCTAssertEqual(parameters.temperature, 1)
        XCTAssertEqual(parameters.tint, -1)
        XCTAssertEqual(parameters.exposure, 1)
        XCTAssertEqual(parameters.highlight, -1)
        XCTAssertEqual(parameters.shadow, 1)
        XCTAssertEqual(parameters.chinLength, -1)
        XCTAssertEqual(parameters.eyeSize, 0)
        XCTAssertEqual(parameters.noseTipSize, 0)
        XCTAssertEqual(parameters.mouthSize, 0)
        XCTAssertEqual(parameters.filterIntensity, 1)
    }

    func testEYE04EyeInputsNormalizePositiveOnlySignedOverflowAndNonFiniteValues() {
        let overflow = BeautyParameters(
            eyeSize: -1,
            eyeDistance: 2,
            eyeYPosition: -2,
            eyeTailLift: 2
        )
        XCTAssertEqual(overflow.eyeSize, 0, "eyeSize negative input")
        XCTAssertEqual(overflow.eyeDistance, 1, "eyeDistance positive overflow")
        XCTAssertEqual(overflow.eyeYPosition, -1, "eyeYPosition negative overflow")
        XCTAssertEqual(overflow.eyeTailLift, 1, "eyeTailLift positive overflow")

        let oppositeOverflow = BeautyParameters(
            eyeSize: 2,
            eyeDistance: -2,
            eyeYPosition: 2,
            eyeTailLift: -1
        )
        XCTAssertEqual(oppositeOverflow.eyeSize, 1, "eyeSize positive overflow")
        XCTAssertEqual(oppositeOverflow.eyeDistance, -1, "eyeDistance negative overflow")
        XCTAssertEqual(oppositeOverflow.eyeYPosition, 1, "eyeYPosition positive overflow")
        XCTAssertEqual(oppositeOverflow.eyeTailLift, 0, "eyeTailLift negative input")

        let nonFiniteValues: [(name: String, value: Float)] = [
            ("NaN", .nan),
            ("positive infinity", .infinity),
            ("negative infinity", -.infinity),
        ]
        for entry in nonFiniteValues {
            XCTAssertEqual(
                BeautyParameters(eyeSize: entry.value).eyeSize,
                0,
                "eyeSize \(entry.name)"
            )
            XCTAssertEqual(
                BeautyParameters(eyeDistance: entry.value).eyeDistance,
                0,
                "eyeDistance \(entry.name)"
            )
            XCTAssertEqual(
                BeautyParameters(eyeYPosition: entry.value).eyeYPosition,
                0,
                "eyeYPosition \(entry.name)"
            )
            XCTAssertEqual(
                BeautyParameters(eyeTailLift: entry.value).eyeTailLift,
                0,
                "eyeTailLift \(entry.name)"
            )
        }
    }

    func testNOSE04NoseInputsNormalizePositiveOnlySignedOverflowAndNonFiniteValues() {
        let values = BeautyParameters(
            noseSlim: -1,
            noseWingSlim: 2,
            noseTipSize: -2,
            noseBridge: .infinity
        )
        XCTAssertEqual(values.noseSlim, 0)
        XCTAssertEqual(values.noseWingSlim, 1)
        XCTAssertEqual(values.noseTipSize, -1)
        XCTAssertEqual(values.noseBridge, 0)

        let positive = BeautyParameters(noseTipSize: 2)
        XCTAssertEqual(positive.noseTipSize, 1)
    }

    func testNOSE01NewNoseInputsNormalizePositiveOnlyValuesIndependently() {
        let cases: [(name: String, value: Float, expected: Float)] = [
            ("negative", -1, 0),
            ("overflow", 2, 1),
            ("in range root", 0.21, 0.21),
            ("in range tip", 0.37, 0.37),
            ("NaN", .nan, 0),
            ("positive infinity", .infinity, 0),
            ("negative infinity", -.infinity, 0),
        ]

        for testCase in cases {
            XCTAssertEqual(
                BeautyParameters(noseRootNarrowing: testCase.value).noseRootNarrowing,
                testCase.expected,
                accuracy: 0.0001,
                "noseRootNarrowing \(testCase.name)"
            )
            XCTAssertEqual(
                BeautyParameters(noseTipLift: testCase.value).noseTipLift,
                testCase.expected,
                accuracy: 0.0001,
                "noseTipLift \(testCase.name)"
            )
        }

        let distinct = BeautyParameters(noseRootNarrowing: 0.21, noseTipLift: 0.37)
        XCTAssertEqual(distinct.noseRootNarrowing, 0.21, accuracy: 0.0001)
        XCTAssertEqual(distinct.noseTipLift, 0.37, accuracy: 0.0001)
        XCTAssertNotEqual(distinct, BeautyParameters(noseRootNarrowing: 0.37, noseTipLift: 0.21))
    }

    func testNOSE01NormalizedCopyReappliesRulesAfterMutableAssignment() {
        var parameters = BeautyParameters(noseRootNarrowing: 0.21, noseTipLift: 0.37)
        parameters.noseRootNarrowing = 2
        parameters.noseTipLift = .nan

        let normalized = parameters.normalized()

        XCTAssertEqual(normalized.noseRootNarrowing, 1)
        XCTAssertEqual(normalized.noseTipLift, 0)
        XCTAssertEqual(parameters.noseRootNarrowing, 2, "normalization returns a copy")
        XCTAssertTrue(parameters.noseTipLift.isNaN, "normalization does not mutate the source")
    }

    func testMOUTH05MouthInputsNormalizeSignedPositiveOnlyOverflowAndNonFiniteValues() {
        let overflow = BeautyParameters(mouthSize: -2, mouthWidth: 2, smile: -1, lipColor: 2)
        XCTAssertEqual(overflow.mouthSize, -1)
        XCTAssertEqual(overflow.mouthWidth, 1)
        XCTAssertEqual(overflow.smile, 0)
        XCTAssertEqual(overflow.lipColor, 1)

        for value: Float in [.nan, .infinity, -.infinity] {
            let parameters = BeautyParameters(
                mouthSize: value,
                mouthWidth: value,
                smile: value,
                lipColor: value
            )
            XCTAssertEqual(parameters.mouthSize, 0)
            XCTAssertEqual(parameters.mouthWidth, 0)
            XCTAssertEqual(parameters.smile, 0)
            XCTAssertEqual(parameters.lipColor, 0)
        }
    }

    func testPhase38MOUTH01SignedMouthInputsNormalizeIndependently() {
        let cases: [(name: String, value: Float, expected: Float)] = [
            ("negative overflow", -2, -1),
            ("positive overflow", 2, 1),
            ("negative in range", -0.37, -0.37),
            ("positive in range", 0.21, 0.21),
            ("NaN", .nan, 0),
            ("positive infinity", .infinity, 0),
            ("negative infinity", -.infinity, 0),
        ]

        for testCase in cases {
            XCTAssertEqual(
                BeautyParameters(mouthYPosition: testCase.value).mouthYPosition,
                testCase.expected,
                accuracy: 0.0001,
                "mouthYPosition \(testCase.name)"
            )
            XCTAssertEqual(
                BeautyParameters(mouthTilt: testCase.value).mouthTilt,
                testCase.expected,
                accuracy: 0.0001,
                "mouthTilt \(testCase.name)"
            )
            XCTAssertEqual(
                BeautyParameters(mouthXPosition: testCase.value).mouthXPosition,
                testCase.expected,
                accuracy: 0.0001,
                "mouthXPosition \(testCase.name)"
            )
        }
    }

    func testPhase38MOUTH02PositiveLipInputsNormalizeIndependently() {
        let cases: [(name: String, value: Float, expected: Float)] = [
            ("negative", -1, 0),
            ("overflow", 2, 1),
            ("peak in range", 0.21, 0.21),
            ("plump in range", 0.37, 0.37),
            ("NaN", .nan, 0),
            ("positive infinity", .infinity, 0),
            ("negative infinity", -.infinity, 0),
        ]

        for testCase in cases {
            XCTAssertEqual(
                BeautyParameters(lipPeakDefinition: testCase.value).lipPeakDefinition,
                testCase.expected,
                accuracy: 0.0001,
                "lipPeakDefinition \(testCase.name)"
            )
            XCTAssertEqual(
                BeautyParameters(lipPlump: testCase.value).lipPlump,
                testCase.expected,
                accuracy: 0.0001,
                "lipPlump \(testCase.name)"
            )
        }
    }

    func testPhase38MOUTH01NormalizedCopyReappliesRulesAfterMutableAssignment() {
        var parameters = BeautyParameters(
            mouthYPosition: 0.11,
            mouthTilt: 0.22,
            mouthXPosition: 0.33,
            lipPeakDefinition: 0.44,
            lipPlump: 0.55
        )
        parameters.mouthYPosition = 2
        parameters.mouthTilt = -2
        parameters.mouthXPosition = .nan
        parameters.lipPeakDefinition = -1
        parameters.lipPlump = .infinity

        let normalized = parameters.normalized()

        XCTAssertEqual(normalized.mouthYPosition, 1)
        XCTAssertEqual(normalized.mouthTilt, -1)
        XCTAssertEqual(normalized.mouthXPosition, 0)
        XCTAssertEqual(normalized.lipPeakDefinition, 0)
        XCTAssertEqual(normalized.lipPlump, 0)
        XCTAssertEqual(parameters.mouthYPosition, 2, "normalization returns a copy")
        XCTAssertEqual(parameters.mouthTilt, -2, "normalization returns a copy")
        XCTAssertTrue(parameters.mouthXPosition.isNaN, "normalization does not mutate the source")
        XCTAssertEqual(parameters.lipPeakDefinition, -1, "normalization returns a copy")
        XCTAssertTrue(parameters.lipPlump.isInfinite, "normalization does not mutate the source")
    }

    func testPhase38MOUTH02NewMouthFieldsHaveIndependentStorageAndEquality() {
        let distinct = BeautyParameters(
            mouthYPosition: -0.11,
            mouthTilt: 0.22,
            mouthXPosition: -0.33,
            lipPeakDefinition: 0.44,
            lipPlump: 0.55
        )

        XCTAssertEqual(distinct.mouthYPosition, -0.11, accuracy: 0.0001)
        XCTAssertEqual(distinct.mouthTilt, 0.22, accuracy: 0.0001)
        XCTAssertEqual(distinct.mouthXPosition, -0.33, accuracy: 0.0001)
        XCTAssertEqual(distinct.lipPeakDefinition, 0.44, accuracy: 0.0001)
        XCTAssertEqual(distinct.lipPlump, 0.55, accuracy: 0.0001)
        XCTAssertNotEqual(
            distinct,
            BeautyParameters(
                mouthYPosition: -0.33,
                mouthTilt: -0.11,
                mouthXPosition: 0.22,
                lipPeakDefinition: 0.55,
                lipPlump: 0.44
            )
        )
    }

    func testSDK03CodableRoundTripAndMissingFieldsUseDefaults() throws {
        let parameters = BeautyParameters(
            skinSmoothing: 0.2,
            contrast: -0.4,
            filterId: "clean_01",
            filterIntensity: 0.3
        )

        let data = try JSONEncoder().encode(parameters)
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)
        XCTAssertEqual(decoded, parameters)

        let partial = Data(#"{"skinSmoothing":0.4}"#.utf8)
        let partialDecoded = try JSONDecoder().decode(BeautyParameters.self, from: partial)
        XCTAssertEqual(partialDecoded.skinSmoothing, 0.4)
        XCTAssertEqual(partialDecoded.eyeSize, 0)
        XCTAssertEqual(partialDecoded.noseRootNarrowing, 0)
        XCTAssertEqual(partialDecoded.noseTipLift, 0)
        XCTAssertNil(partialDecoded.filterId)
    }

    func testNOSE02Legacy31FieldJSONDecodesNewFieldsAsZero() throws {
        let legacyJSON = Data(#"""
        {
          "skinSmoothing": 0.1,
          "skinWhitening": 0.1,
          "skinRosy": 0.1,
          "skinSharpen": 0.1,
          "brightness": 0.1,
          "contrast": 0.1,
          "saturation": 0.1,
          "temperature": 0.1,
          "tint": 0.1,
          "exposure": 0.1,
          "highlight": 0.1,
          "shadow": 0.1,
          "faceSlim": 0.1,
          "faceSmall": 0.1,
          "faceVShape": 0.1,
          "jawSlim": 0.1,
          "chinLength": 0.1,
          "eyeSize": 0.1,
          "eyeDistance": 0.1,
          "eyeYPosition": 0.1,
          "eyeTailLift": 0.1,
          "noseSlim": 0.1,
          "noseWingSlim": 0.1,
          "noseTipSize": 0.1,
          "noseBridge": 0.1,
          "mouthSize": 0.1,
          "mouthWidth": 0.1,
          "smile": 0.1,
          "lipColor": 0.1,
          "filterId": null,
          "filterIntensity": 0.1
        }
        """#.utf8)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: legacyJSON) as? [String: Any])
        XCTAssertEqual(object.count, 31)

        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: legacyJSON)

        XCTAssertEqual(decoded.noseRootNarrowing, 0)
        XCTAssertEqual(decoded.noseTipLift, 0)
    }

    func testPhase38MOUTH03ExistingNoseValuesRoundTripWithin38FieldInventory() throws {
        let parameters = BeautyParameters(
            noseRootNarrowing: 0.21,
            noseTipLift: 0.37,
            filterId: "clean_01"
        )

        let data = try JSONEncoder().encode(parameters)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)

        XCTAssertEqual(object.count, 61)
        XCTAssertEqual(decoded, parameters)
        XCTAssertEqual(decoded.noseRootNarrowing, 0.21, accuracy: 0.0001)
        XCTAssertEqual(decoded.noseTipLift, 0.37, accuracy: 0.0001)
    }

    func testPhase38MOUTH03Legacy33FieldJSONDecodesNewMouthFieldsAsZero() throws {
        let legacyJSON = Data(#"""
        {
          "skinSmoothing": 0.1,
          "skinWhitening": 0.1,
          "skinRosy": 0.1,
          "skinSharpen": 0.1,
          "brightness": 0.1,
          "contrast": 0.1,
          "saturation": 0.1,
          "temperature": 0.1,
          "tint": 0.1,
          "exposure": 0.1,
          "highlight": 0.1,
          "shadow": 0.1,
          "faceSlim": 0.1,
          "faceSmall": 0.1,
          "faceVShape": 0.1,
          "jawSlim": 0.1,
          "chinLength": 0.1,
          "eyeSize": 0.1,
          "eyeDistance": 0.1,
          "eyeYPosition": 0.1,
          "eyeTailLift": 0.1,
          "noseSlim": 0.1,
          "noseWingSlim": 0.1,
          "noseTipSize": 0.1,
          "noseBridge": 0.1,
          "noseRootNarrowing": 0.1,
          "noseTipLift": 0.1,
          "mouthSize": 0.1,
          "mouthWidth": 0.1,
          "smile": 0.1,
          "lipColor": 0.1,
          "filterId": null,
          "filterIntensity": 0.1
        }
        """#.utf8)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: legacyJSON) as? [String: Any])
        XCTAssertEqual(object.count, 33)

        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: legacyJSON)

        XCTAssertEqual(decoded.mouthYPosition, 0)
        XCTAssertEqual(decoded.mouthTilt, 0)
        XCTAssertEqual(decoded.mouthXPosition, 0)
        XCTAssertEqual(decoded.lipPeakDefinition, 0)
        XCTAssertEqual(decoded.lipPlump, 0)
    }

    func testPhase38MOUTH03New38FieldValuesRoundTripWithoutAliasing() throws {
        let parameters = BeautyParameters(
            mouthYPosition: -0.11,
            mouthTilt: 0.22,
            mouthXPosition: -0.33,
            lipPeakDefinition: 0.44,
            lipPlump: 0.55,
            filterId: "clean_01"
        )

        let data = try JSONEncoder().encode(parameters)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)

        XCTAssertEqual(object.count, 61)
        XCTAssertEqual(decoded, parameters)
        XCTAssertEqual(decoded.mouthYPosition, -0.11, accuracy: 0.0001)
        XCTAssertEqual(decoded.mouthTilt, 0.22, accuracy: 0.0001)
        XCTAssertEqual(decoded.mouthXPosition, -0.33, accuracy: 0.0001)
        XCTAssertEqual(decoded.lipPeakDefinition, 0.44, accuracy: 0.0001)
        XCTAssertEqual(decoded.lipPlump, 0.55, accuracy: 0.0001)
    }

    func testPhase38MOUTH03ExistingLabeledInitializerCallsRemainNeutral() {
        let existingSourceStyle = BeautyParameters(
            skinSmoothing: 0.2,
            noseBridge: 0.1,
            lipColor: 0.3,
            filterId: "clean_01"
        )

        XCTAssertEqual(existingSourceStyle.mouthYPosition, 0)
        XCTAssertEqual(existingSourceStyle.mouthTilt, 0)
        XCTAssertEqual(existingSourceStyle.mouthXPosition, 0)
        XCTAssertEqual(existingSourceStyle.lipPeakDefinition, 0)
        XCTAssertEqual(existingSourceStyle.lipPlump, 0)
        XCTAssertEqual(existingSourceStyle.lipColor, 0.3, accuracy: 0.0001)
        XCTAssertEqual(existingSourceStyle.filterId, "clean_01")
    }

    func testNOSE02ExistingLabeledInitializerCallsRemainNeutral() {
        let existingSourceStyle = BeautyParameters(skinSmoothing: 0.2, noseBridge: 0.1, filterId: "clean_01")

        XCTAssertEqual(existingSourceStyle.noseRootNarrowing, 0)
        XCTAssertEqual(existingSourceStyle.noseTipLift, 0)
    }

    func testEFFECT02ColorAndFilterFieldsRoundTripThroughCodable() throws {
        let parameters = BeautyParameters(
            brightness: -0.25,
            contrast: 0.15,
            saturation: 0.2,
            temperature: -0.1,
            tint: 0.05,
            exposure: 0.4,
            highlight: -0.3,
            shadow: 0.35,
            filterId: "soft_clean",
            filterIntensity: 0.35
        )

        let data = try JSONEncoder().encode(parameters)
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)

        XCTAssertEqual(decoded.brightness, -0.25)
        XCTAssertEqual(decoded.contrast, 0.15)
        XCTAssertEqual(decoded.saturation, 0.2)
        XCTAssertEqual(decoded.temperature, -0.1)
        XCTAssertEqual(decoded.tint, 0.05)
        XCTAssertEqual(decoded.exposure, 0.4)
        XCTAssertEqual(decoded.highlight, -0.3)
        XCTAssertEqual(decoded.shadow, 0.35)
        XCTAssertEqual(decoded.filterId, "soft_clean")
        XCTAssertEqual(decoded.filterIntensity, 0.35)
    }

    func testEFFECT03FilterDefaultsRepresentNoFilterState() {
        let parameters = BeautyParameters()

        XCTAssertNil(parameters.filterId)
        XCTAssertEqual(parameters.filterIntensity, 0)
    }

    func testBeautyParametersIsSendable() {
        assertSendable(BeautyParameters())
    }

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}

extension BeautyParametersTests {
    func testPhase53LegacyInventoryAdjacencyAt58NumericPlusFilterID() {
        let defaults = BeautyParameters()
        let children = Array(Mirror(reflecting: defaults).children)
        let labels = children.compactMap(\.label)
        XCTAssertEqual(labels.count, 61)
        XCTAssertEqual(labels.filter { $0 != "filterId" }.count, 60)
        XCTAssertEqual(labels.filter { $0 == "filterId" }.count, 1)
        XCTAssertTrue(
            children.allSatisfy { child in
                if child.label == "filterId" {
                    return child.value as? String == nil
                }
                return child.value as? Float == 0
            },
            "All 60 numeric defaults and filterId must retain their exact neutral values"
        )
    }

    func testPhase53MissingKeysAndZeroDefaultsRemainNeutral() throws {
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: Data("{}".utf8))
        XCTAssertEqual(decoded, BeautyParameters())
        XCTAssertEqual(Mirror(reflecting: decoded).children.count, 61)
    }

    func testPhase53StoredAndCodingKeyOrderRemainsCurrent61() throws {
        let stored = Mirror(reflecting: BeautyParameters()).children.compactMap(\.label)
        let source = try String(contentsOf: parametersSourceURL(), encoding: .utf8)
        let codingBlock = try XCTUnwrap(source.split(separator: "enum CodingKeys", maxSplits: 1).last)
            .split(separator: "public init(", maxSplits: 1)[0]
        let coding = codingBlock.split(separator: "\n").compactMap { line -> String? in
            let text = line.trimmingCharacters(in: .whitespaces)
            return text.hasPrefix("case ") ? String(text.dropFirst(5)) : nil
        }
        XCTAssertEqual(stored.count, 61)
        XCTAssertEqual(coding, stored)

        let encoded = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: JSONEncoder().encode(BeautyParameters(filterId: "phase53-inventory"))
            ) as? [String: Any]
        )
        XCTAssertEqual(encoded.count, 61)
        XCTAssertEqual(Set(encoded.keys), Set(stored))
    }

    func testPhase53LegacySourceConstructionRemainsNeutral() {
        let legacySourceCall = BeautyParameters(
            skinSmoothing: 0.2,
            eyeSize: 0.3,
            noseBridge: 0.1,
            lipColor: 0.4,
            filterId: "soft_clean"
        )

        XCTAssertEqual(legacySourceCall.skinSmoothing, 0.2)
        XCTAssertEqual(legacySourceCall.eyeSize, 0.3)
        XCTAssertEqual(legacySourceCall.noseBridge, 0.1)
        XCTAssertEqual(legacySourceCall.lipColor, 0.4)
        XCTAssertEqual(legacySourceCall.filterId, "soft_clean")
        XCTAssertEqual(Mirror(reflecting: legacySourceCall).children.count, 61)
    }

    func testPhase53AdmissionBoundsAreExactAtZeroAndOne() {
        func admitted(_ value: Float) -> Float { value.isFinite ? min(max(value, 0), 1) : 0 }
        XCTAssertEqual(admitted(-Float.ulpOfOne), 0)
        XCTAssertEqual(admitted(0), 0)
        XCTAssertEqual(admitted(Float.ulpOfOne), Float.ulpOfOne)
        XCTAssertEqual(admitted(1), 1)
        XCTAssertEqual(admitted(1 + Float.ulpOfOne), 1)
        XCTAssertEqual(admitted(.nan), 0)
    }

    func testPhase53RemainingSiblingCandidateInventoryRemainsAbsent() throws {
        let source = try String(contentsOf: parametersSourceURL(), encoding: .utf8)
        for forbidden in ["upperEyelidFullnessReduction"] {
            XCTAssertFalse(source.contains(forbidden), forbidden)
        }
        XCTAssertEqual(Mirror(reflecting: BeautyParameters()).children.count, 61)
    }

    func testPhase59OpenTeethFieldKeepsPublicAndCodableSurfaceExact() throws {
        let defaults = BeautyParameters()
        let stored = Mirror(reflecting: defaults).children.compactMap(\.label)
        let source = try String(contentsOf: parametersSourceURL(), encoding: .utf8)
        let codingBlock = try XCTUnwrap(source.split(separator: "enum CodingKeys", maxSplits: 1).last)
            .split(separator: "public init(", maxSplits: 1)[0]
        let coding = codingBlock.split(separator: "\n").compactMap { line -> String? in
            let text = line.trimmingCharacters(in: .whitespaces)
            return text.hasPrefix("case ") ? String(text.dropFirst(5)) : nil
        }
        let encoded = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(defaults)) as? [String: Any]
        )
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: Data("{}".utf8))
        XCTAssertEqual(stored.count, 61)
        XCTAssertEqual(coding, stored)
        XCTAssertEqual(encoded.count, 60)
        XCTAssertEqual(Set(encoded.keys), Set(stored).subtracting(["filterId"]))
        XCTAssertEqual(decoded, defaults)
        XCTAssertEqual(Mirror(reflecting: decoded).children.count, 61)
        XCTAssertEqual(decoded.teethWhitening, 0)
        XCTAssertEqual(Array(stored.suffix(2)), ["teethWhitening", "scleraRednessReduction"])
        XCTAssertEqual(Array(coding.suffix(2)), ["teethWhitening", "scleraRednessReduction"])
        XCTAssertEqual(encoded["teethWhitening"] as? Double, 0)
        XCTAssertTrue(source.contains("teethWhitening"))

        let legacySourceCall = BeautyParameters(
            skinWhitening: 0.2,
            brightness: 0.1,
            mouthWidth: 0.3,
            lipColor: 0.4,
            filterId: "soft_clean"
        )
        XCTAssertEqual(legacySourceCall.skinWhitening, 0.2)
        XCTAssertEqual(legacySourceCall.brightness, 0.1)
        XCTAssertEqual(legacySourceCall.mouthWidth, 0.3)
        XCTAssertEqual(legacySourceCall.lipColor, 0.4)
        XCTAssertEqual(legacySourceCall.filterId, "soft_clean")
        XCTAssertEqual(Mirror(reflecting: legacySourceCall).children.count, 61)
    }

    func testPhase57ClosedEyeRetouchGatesKeepPublicAndCodableSurfaceExact() throws {
        let defaults = BeautyParameters()
        let stored = Mirror(reflecting: defaults).children.compactMap(\.label)
        let source = try String(contentsOf: parametersSourceURL(), encoding: .utf8)
        let codingBlock = try XCTUnwrap(source.split(separator: "enum CodingKeys", maxSplits: 1).last)
            .split(separator: "public init(", maxSplits: 1)[0]
        let coding = codingBlock.split(separator: "\n").compactMap { line -> String? in
            let text = line.trimmingCharacters(in: .whitespaces)
            return text.hasPrefix("case ") ? String(text.dropFirst(5)) : nil
        }
        let encoded = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(defaults)) as? [String: Any]
        )
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: Data("{}".utf8))
        let candidateNames = [
            "scleraRedness", "scleraWhitening", "scleraWhite",
            "scleraBrightness", "whitenSclera", "eyeRedness", "eyeRednessReduction",
            "redEye", "redEyeReduction", "conjunctivaRedness", "conjunctivaRednessReduction",
            "conjunctivalRedness", "conjunctivalRednessReduction", "conjunctivaWhitening", "conjunctivalWhitening",
            "ocularRedness", "ocularRednessReduction", "ocularWhitening", "bloodshotReduction",
            "bloodshotEyeCorrection", "sclera_redness", "sclera_redness_reduction", "sclera_whitening",
            "sclera_white", "sclera_brightness", "whiten_sclera", "eye_redness",
            "eye_redness_reduction", "red_eye", "red_eye_reduction", "conjunctiva_redness",
            "conjunctiva_redness_reduction", "conjunctival_redness", "conjunctival_redness_reduction", "conjunctiva_whitening",
            "conjunctival_whitening", "ocular_redness", "ocular_redness_reduction", "ocular_whitening",
            "bloodshot_reduction", "bloodshot_eye_correction", "eyes.redness", "祛红血丝",
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

        XCTAssertEqual(stored.count, 61)
        XCTAssertEqual(coding, stored)
        XCTAssertEqual(encoded.count, 60)
        XCTAssertEqual(Set(encoded.keys), Set(stored).subtracting(["filterId"]))
        XCTAssertEqual(decoded, defaults)
        for forbidden in candidateNames {
            XCTAssertFalse(stored.contains(forbidden), forbidden)
            XCTAssertFalse(coding.contains(forbidden), forbidden)
            XCTAssertNil(encoded[forbidden], forbidden)
            let escaped = NSRegularExpression.escapedPattern(for: forbidden)
            XCTAssertNil(
                source.range(
                    of: "(?<![A-Za-z0-9_])\(escaped)(?![A-Za-z0-9_])",
                    options: .regularExpression
                ),
                forbidden
            )
        }

        let shippedDomains = BeautyParameters(
            skinSmoothing: 0.1,
            brightness: 0.1,
            eyeSize: 0.2,
            eyeHeight: 0.3,
            upperEyelidLift: 0.4,
            eyebrowYPosition: 0.7
        )
        XCTAssertEqual(shippedDomains.skinSmoothing, 0.1)
        XCTAssertEqual(shippedDomains.eyeSize, 0.2)
        XCTAssertEqual(shippedDomains.eyeHeight, 0.3)
        XCTAssertEqual(shippedDomains.upperEyelidLift, 0.4)
        XCTAssertEqual(shippedDomains.eyebrowYPosition, 0.7)
        XCTAssertEqual(shippedDomains.brightness, 0.1)
        XCTAssertEqual(Mirror(reflecting: shippedDomains).children.count, 61)
    }

    func testPhase53FutureAdmissionChecklistRequiresTrailingAppendOrder() {
        let checklist = [
            "independent", "positive-only Float", "finite-normalized 0...1",
            "default zero", "missing key zero", "trailing appended",
            "exact stored and Codable inventory",
        ]
        XCTAssertEqual(checklist.count, 7)
        XCTAssertEqual(checklist.last, "exact stored and Codable inventory")
    }

    func testPhase59TeethWhiteningNormalizesPositiveOnlyAndKeepsUnequalValuesIndependent() throws {
        let cases: [(value: Float, expected: Float)] = [
            (-1, 0),
            (-Float.ulpOfOne, 0),
            (0, 0),
            (Float.ulpOfOne, Float.ulpOfOne),
            (0.37, 0.37),
            (1, 1),
            (Float(1).nextUp, 1),
            (.nan, 0),
            (.infinity, 0),
            (-.infinity, 0),
        ]

        for testCase in cases {
            let parameters = BeautyParameters(teethWhitening: testCase.value)
            XCTAssertEqual(parameters.teethWhitening, testCase.expected, accuracy: 0.000_001)
            XCTAssertEqual(
                parameters.normalized().teethWhitening,
                testCase.expected,
                accuracy: 0.000_001
            )
        }

        let first = BeautyParameters(teethWhitening: 0.21)
        let second = BeautyParameters(teethWhitening: 0.79)
        XCTAssertNotEqual(first, second)
        XCTAssertEqual(first.normalized().teethWhitening, 0.21, accuracy: 0.000_001)
        XCTAssertEqual(second.normalized().teethWhitening, 0.79, accuracy: 0.000_001)
    }

    func testPhase59TeethWhiteningDefaultMissingKeyLegacyConstructionAndEncoding() throws {
        let defaults = BeautyParameters()
        XCTAssertEqual(defaults.teethWhitening, 0)

        let missing = try JSONDecoder().decode(BeautyParameters.self, from: Data("{}".utf8))
        XCTAssertEqual(missing.teethWhitening, 0)

        let legacy = BeautyParameters(
            skinSmoothing: 0.2,
            eyeSize: 0.3,
            noseBridge: 0.1,
            lipColor: 0.4,
            filterId: "soft_clean"
        )
        XCTAssertEqual(legacy.teethWhitening, 0)
        XCTAssertEqual(legacy.skinSmoothing, 0.2)
        XCTAssertEqual(legacy.eyeSize, 0.3)
        XCTAssertEqual(legacy.noseBridge, 0.1)
        XCTAssertEqual(legacy.lipColor, 0.4)
        XCTAssertEqual(legacy.filterId, "soft_clean")

        let defaultObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(defaults)) as? [String: Any]
        )
        XCTAssertEqual(defaultObject.count, 60)
        XCTAssertEqual(defaultObject["teethWhitening"] as? Double, 0)
        XCTAssertNil(defaultObject["filterId"])

        let nonNilFilter = BeautyParameters(
            filterId: "soft_clean",
            filterIntensity: 0.31,
            teethWhitening: 0.67
        )
        let encoded = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(nonNilFilter)) as? [String: Any]
        )
        XCTAssertEqual(encoded.count, 61)
        XCTAssertEqual(try XCTUnwrap(encoded["teethWhitening"] as? Double), 0.67, accuracy: 0.000_001)
        XCTAssertEqual(
            try JSONDecoder().decode(BeautyParameters.self, from: JSONEncoder().encode(nonNilFilter)),
            nonNilFilter
        )

        var legacyPayload = encoded
        legacyPayload.removeValue(forKey: "teethWhitening")
        let legacyDecoded = try JSONDecoder().decode(
            BeautyParameters.self,
            from: JSONSerialization.data(withJSONObject: legacyPayload)
        )
        XCTAssertEqual(legacyDecoded.teethWhitening, 0)
        XCTAssertEqual(legacyDecoded.filterId, "soft_clean")
        XCTAssertEqual(legacyDecoded.filterIntensity, 0.31, accuracy: 0.000_001)
    }

    func testPhase62ScleraRednessReductionNormalizesAndRoundTripsIndependently() throws {
        let cases: [(value: Float, expected: Float)] = [
            (-1, 0),
            (-Float.ulpOfOne, 0),
            (0, 0),
            (Float.ulpOfOne, Float.ulpOfOne),
            (0.43, 0.43),
            (1, 1),
            (Float(1).nextUp, 1),
            (.nan, 0),
            (.infinity, 0),
            (-.infinity, 0),
        ]

        for testCase in cases {
            let parameters = BeautyParameters(scleraRednessReduction: testCase.value)
            XCTAssertEqual(parameters.scleraRednessReduction, testCase.expected, accuracy: 0.000_001)
            XCTAssertEqual(
                parameters.normalized().scleraRednessReduction,
                testCase.expected,
                accuracy: 0.000_001
            )
        }

        let distinct = BeautyParameters(teethWhitening: 0.21, scleraRednessReduction: 0.79)
        let roundTrip = try JSONDecoder().decode(
            BeautyParameters.self,
            from: JSONEncoder().encode(distinct)
        )
        XCTAssertEqual(roundTrip, distinct)
        XCTAssertEqual(roundTrip.teethWhitening, 0.21, accuracy: 0.000_001)
        XCTAssertEqual(roundTrip.scleraRednessReduction, 0.79, accuracy: 0.000_001)

        var legacyPayload = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(distinct)) as? [String: Any]
        )
        legacyPayload.removeValue(forKey: "scleraRednessReduction")
        let legacy = try JSONDecoder().decode(
            BeautyParameters.self,
            from: JSONSerialization.data(withJSONObject: legacyPayload)
        )
        XCTAssertEqual(legacy.teethWhitening, 0.21, accuracy: 0.000_001)
        XCTAssertEqual(legacy.scleraRednessReduction, 0)
    }

    func testPhase58ZeroAdmissionKeepsTrailingTeethFieldNeutralAndEncodedShape() throws {
        let source = try String(contentsOf: parametersSourceURL(), encoding: .utf8)
        let defaults = BeautyParameters()
        let stored = Mirror(reflecting: defaults).children.compactMap(\.label)
        let codingBlock = try XCTUnwrap(source.split(separator: "enum CodingKeys", maxSplits: 1).last)
        let coding = stored.filter { codingBlock.contains($0) }
        let encoded = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(defaults)) as? [String: Any]
        )
        let candidates = ["upperEyelidFullnessReduction"]

        XCTAssertEqual(stored.count, 61)
        XCTAssertEqual(coding, stored)
        XCTAssertEqual(encoded.count, 60)
        XCTAssertEqual(Set(encoded.keys), Set(stored).subtracting(["filterId"]))
        XCTAssertEqual(defaults.teethWhitening, 0)
        XCTAssertEqual(encoded["teethWhitening"] as? Double, 0)
        XCTAssertEqual(defaults.scleraRednessReduction, 0)
        XCTAssertEqual(encoded["scleraRednessReduction"] as? Double, 0)
        XCTAssertEqual(Array(stored.suffix(3)), [
            "filterIntensity", "teethWhitening", "scleraRednessReduction",
        ])
        for candidate in candidates {
            XCTAssertFalse(stored.contains(candidate), candidate)
            XCTAssertFalse(coding.contains(candidate), candidate)
            XCTAssertNil(encoded[candidate], candidate)
        }
    }

    private func parametersSourceURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/BeautyCore/Models/BeautyParameters.swift")
    }
}
