import CoreImage
import XCTest
import BeautyCore
@testable import BeautyRender
@testable import BeautyEffects

final class BeautyBackendDeterminismParityTests: XCTestCase {
    func testRepeatedGeneratedRequestsAreByteIdenticalAndResourceClean() throws {
        let fixtures = BeautyBackendParityFixtureFactory.fixtures().prefix(3)
        let plans = BeautyBackendParityFixtureFactory.planMatrix().prefix(3)
        for fixture in fixtures {
            for (_, plan) in plans {
                let cpu = BeautyCPUBackend()
                let request = try BeautyBackendParityFixtureFactory.makeRequest(
                    policy: .cpu, fixture: fixture, plan: plan, stillImage: true
                )
                let first = try cpu.execute(request)
                let second = try cpu.execute(request)
                XCTAssertEqual(
                    try BeautyBackendParityFixtureFactory.rgbaBytes(from: first.output),
                    try BeautyBackendParityFixtureFactory.rgbaBytes(from: second.output)
                )
                XCTAssertEqual(first.diagnostics, second.diagnostics)
            }
        }

        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        for fixture in fixtures {
            for (_, plan) in plans {
                let request = try BeautyBackendParityFixtureFactory.makeRequest(
                    policy: .metal, fixture: fixture, plan: plan, stillImage: true
                )
                let first = try metal.execute(request)
                let second = try metal.execute(request)
                XCTAssertEqual(
                    try BeautyBackendParityFixtureFactory.rgbaBytes(from: first.output),
                    try BeautyBackendParityFixtureFactory.rgbaBytes(from: second.output)
                )
                XCTAssertEqual(first.diagnostics, second.diagnostics)
            }
        }
        if let runtime = try? BeautyMetalRuntime() {
            let fixture = BeautyBackendParityFixtureFactory.fixtures()[0]
            _ = try runtime.render(width: fixture.width, height: fixture.height, rgba8Bytes: fixture.rgba8)
            XCTAssertEqual(runtime.resourceCountersForTesting.active, 0)
            XCTAssertEqual(runtime.resourceCountersForTesting.created, runtime.resourceCountersForTesting.released)
        }
    }

    func testBoundedConcurrentCPUAndMetalRequestsRemainRequestLocal() async throws {
        let metalAvailable = BeautyBackendParityFixtureFactory.makeMetalBackend() != nil
        let requestCount = 4
        let baseline = try (0..<requestCount).map { index -> [UInt8] in
            let fixture = BeautyBackendParityFixtureFactory.fixtures()[index % BeautyBackendParityFixtureFactory.fixtures().count]
            let plan = BeautyBackendParityFixtureFactory.planMatrix()[index % BeautyBackendParityFixtureFactory.planMatrix().count].1
            let request = try BeautyBackendParityFixtureFactory.makeRequest(
                policy: .cpu, fixture: fixture, plan: plan, stillImage: true
            )
            return try BeautyBackendParityFixtureFactory.rgbaBytes(from: BeautyCPUBackend().execute(request).output)
        }

        let results = try await withThrowingTaskGroup(of: (Int, [UInt8]).self, returning: [(Int, [UInt8])].self) { group in
            for id in 0..<requestCount {
                group.addTask {
                    let fixture = BeautyBackendParityFixtureFactory.fixtures()[id % BeautyBackendParityFixtureFactory.fixtures().count]
                    let matrix = BeautyBackendParityFixtureFactory.planMatrix()
                    let plan = matrix[id % matrix.count].1
                    let policy: BeautyBackendExecutionPolicy = metalAvailable && id.isMultiple(of: 2) ? .metal : .cpu
                    let request = try BeautyBackendParityFixtureFactory.makeRequest(
                        policy: policy, fixture: fixture, plan: plan, stillImage: true
                    )
                    let output: BeautyBackendOutput
                    if policy == .metal {
                        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else {
                            throw BeautyError.metalUnavailable
                        }
                        output = try metal.execute(request).output
                    } else {
                        output = try BeautyCPUBackend().execute(request).output
                    }
                    return (id, try BeautyBackendParityFixtureFactory.rgbaBytes(from: output))
                }
            }
            var collected: [(Int, [UInt8])] = []
            for try await result in group { collected.append(result) }
            return collected
        }
        XCTAssertEqual(results.count, requestCount)
        for (id, bytes) in results {
            XCTAssertEqual(bytes, baseline[id])
        }
    }

}
