import CoreGraphics
import CryptoKit
import XCTest
@testable import BeautyCore
@testable import BeautySDK

extension RetouchTerminalTests {
    func hash(_ image: Raster) -> String {
        SHA256.hash(data: Data(image.bytes)).map{String(format:"%02x",$0)}.joined()
    }
    func testE1V2() throws { try evaluate("E1-v2",candidateE1V2) }
    func testE2V1() throws { try evaluate("E2-v1",candidateE2V1) }
    func testE2V2() throws { try evaluate("E2-v2",candidateE2V2) }
    func evaluate(_ mode: String, _ candidate: (Raster,Double)->Raster) throws {
        let pair=try eyePair()
        let negatives=[pair.target,try fixture("upper-eyelid-negative-control.png")]
        XCTAssertEqual(candidate(pair.source,0).bytes,pair.source.bytes,"neutral_identity")
        var passes=true,previous=pair.source
        for strength in [0.5,1.0] {
            let output=candidate(pair.source,strength)
            XCTAssertEqual(output.width,pair.source.width);XCTAssertEqual(output.height,pair.source.height)
            XCTAssertTrue(candidate(pair.source,strength).bytes==output.bytes,"repeat_identity")
            let score=eyeScore(output,pair,strength)
            let reversal=stride(from:0,to:output.bytes.count,by:4).filter{ k in
                (0..<3).contains{output.bytes[k+$0]>previous.bytes[k+$0]}
            }.count
            let accepted=score.direction && score.hard==0 && reversal==0
            passes=passes && accepted
            emit(["kind":"candidate","mode":mode,"strength":strength,"improvement":score.improvement,
                "hp":score.hp,"hard":score.hard,"reversal":reversal,"numeric":accepted,
                "source_sha256":hash(pair.source),"reference_sha256":hash(pair.target),"output_sha256":hash(output)])
            try export(output,"\(mode)-\(Int(strength*100))");previous=output
        }
        var changedNegatives=0
        for (index,negative) in negatives.enumerated() {
            let output=candidate(negative,1)
            let changed=(0..<negative.count).filter { p in
                (0..<4).contains { negative.bytes[p*4+$0] != output.bytes[p*4+$0] }
            }.count
            XCTAssertTrue(candidate(negative,1).bytes==output.bytes,"negative_repeat")
            if changed>0 { changedNegatives+=1 }
            emit(["kind":"negative","mode":mode,"case_id":"N0\(index+1)","changed_pixels":changed,
                "source_sha256":hash(negative),"output_sha256":hash(output)])
            try export(output,"\(mode)-N0\(index+1)")
        }
        passes=passes && changedNegatives==0
        emit(["kind":"outcome","mode":mode,"negative_changes":changedNegatives,"numeric":passes,"visual":"not_qualified"])
    }
}
