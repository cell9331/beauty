import BeautyCore
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyEyeSliderContractTests: XCTestCase {
    private let rows: [(BeautyEyeShapeSlider, String, WritableKeyPath<BeautyParameters, Float>, WritableKeyPath<BeautyEffectiveStrengths, Float>, Float, Float)] = [
        (.eyeSize,"eyeSize",\.eyeSize,\.eyeSize,0.45,1),
        (.verticalPosition,"eyeYPosition",\.eyeYPosition,\.eyeYPosition,0.25,1),
        (.height,"eyeHeight",\.eyeHeight,\.eyeHeight,0.35,1),
        (.length,"eyeLength",\.eyeLength,\.eyeLength,0.35,1),
        (.spacing,"eyeDistance",\.eyeDistance,\.eyeDistance,0.30,1),
        (.irisSize,"pupilSize",\.pupilSize,\.pupilSize,0.25,1),
        (.lowerEyelid,"lowerEyelidDrop",\.lowerEyelidDrop,\.lowerEyelidDrop,0.30,1),
        (.outerTail,"eyeTailLift",\.eyeTailLift,\.eyeTailLift,0.30,1),
        (.tilt,"eyeTilt",\.eyeTilt,\.eyeTilt,0.25,-1),
        (.innerCorner,"innerCornerOpen",\.innerCornerOpen,\.innerCornerOpen,0.25,1),
        (.outerCorner,"outerCornerOpen",\.outerCornerOpen,\.outerCornerOpen,0.25,1)
    ]

    func testReferencePolarityFullTravelNeutralAndInverseKeepSiblingValues() {
        XCTAssertEqual(Set(rows.map(\.0)),Set(BeautyEyeShapeSlider.allCases))
        for (slider,_,field,effective,cap,polarity) in rows {
            let baseline = BeautyParameters(skinSmoothing:0.13,noseSlim:-0.19,mouthWidth:0.12)
            for position: Float in [0,0.125,0.25,0.375,0.5,0.625,0.75,0.875,1] {
                var expected=baseline
                expected[keyPath:field]=(2*position-1)*cap*polarity
                let actual=slider.applying(position:position,to:baseline)
                XCTAssertEqual(actual,expected,"\(slider)")
                XCTAssertEqual(slider.position(in:actual),position,accuracy:0.000001)
                let plan=BeautyEffectResolver.resolve(parameters:actual)
                XCTAssertEqual(plan.effectiveStrengths[keyPath:effective],expected[keyPath:field],accuracy:0.000001)
            }
            for invalid: Float in [.nan,.infinity,-.infinity] {
                XCTAssertEqual(slider.applying(position:invalid,to:baseline),baseline)
            }
            XCTAssertEqual(slider.applying(position:-2,to:baseline),slider.applying(position:0,to:baseline))
            XCTAssertEqual(slider.applying(position:2,to:baseline),slider.applying(position:1,to:baseline))
        }
    }

    func testSignedDecodeMutationFiniteNormalizationAndCapRoundTrip() throws {
        for (slider,name,field,effective,cap,_) in rows {
            for sign: Float in [-1,1] {
                let data=try JSONSerialization.data(withJSONObject:[name:Double(sign*2)])
                let decoded=try JSONDecoder().decode(BeautyParameters.self,from:data)
                XCTAssertEqual(decoded[keyPath:field],sign)
                XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self,from:JSONEncoder().encode(decoded)),decoded)
                var mutated=BeautyParameters();mutated[keyPath:field]=sign*2
                XCTAssertEqual(mutated.normalized(),decoded)
                let plan=BeautyEffectResolver.resolve(parameters:decoded)
                XCTAssertEqual(plan.effectiveStrengths[keyPath:effective],sign*cap,accuracy:0.000001)
                XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"],1)
                XCTAssertTrue(BeautyEffectResolver.requiresFaceGeometry(parameters:decoded))
                XCTAssertTrue([Float(0),1].contains(slider.position(in:decoded)))
            }
            for value:Float in [.nan,.infinity,-.infinity] {
                var mutated=BeautyParameters();mutated[keyPath:field]=value
                XCTAssertEqual(mutated.normalized(),BeautyParameters())
                XCTAssertEqual(slider.position(in:mutated),0.5)
            }
        }
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self,from:Data("{}".utf8)),BeautyParameters())
    }

    func testNegativeGeometryCountsTowardLegacyBudgetWithoutCancellation() {
        var input=BeautyEffectiveStrengths()
        for (_,_,_,field,cap,_) in rows { input[keyPath:field] = -cap }
        let sum=rows.reduce(Float(0)) { $0+$1.4 }
        let resolved=GeometryConflictResolver().resolve(strengths:input)
        XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"],11)
        for (_,_,_,field,cap,_) in rows {
            XCTAssertEqual(resolved.strengths[keyPath:field],-cap/sum,accuracy:0.000001)
        }
        let dense=GeometryConflictResolver().resolve(strengths:input,usesDenseMap:true)
        XCTAssertEqual(dense.strengths,input)
    }
}
