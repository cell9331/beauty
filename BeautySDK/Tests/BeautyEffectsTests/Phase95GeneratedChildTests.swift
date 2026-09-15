import Darwin
import Foundation
import XCTest

final class Phase95GeneratedChildTests: XCTestCase {
    private let directory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    func testExactSuccessRejectsTypeCoercionDuplicatesAndTrailingData() {
        XCTAssertTrue(Phase95GeneratedChild.isSuccess(Data("{\"structural_pairs\": 1, \"passed\": true}\n".utf8), pairs: true))
        XCTAssertTrue(Phase95GeneratedChild.isSuccess(Data("{\"contained\": 2}\n".utf8), pairs: false))
        for bad in ["{\"structural_pairs\":true,\"passed\":1}",
                    "{\"structural_pairs\":1.0,\"passed\":1.0}",
                    "{\"structural_pairs\":1,\"passed\":true,\"passed\":false}",
                    "{\"structural_pairs\": 1, \"passed\": true}\n{}",
                    "{\"contained\": 2, \"contained\": 0}\n"] {
            XCTAssertFalse(Phase95GeneratedChild.isSuccess(Data(bad.utf8), pairs: true))
            XCTAssertFalse(Phase95GeneratedChild.isSuccess(Data(bad.utf8), pairs: false))
        }
    }

    func testNormalChildDrainsInputAndReturnsExactRecord() throws {
        let result = try Phase95GeneratedChild.run("sys.stdin.buffer.read(); print('{\"contained\": 2}')",
            payload: Data(repeating: 32, count: 200_000), directory: directory, timeout: 5)
        XCTAssertTrue(Phase95GeneratedChild.isSuccess(result, pairs: false))
    }

    private func isExecuting(_ pid: Int32) -> Bool {
        var info = kinfo_proc(), size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        let status = mib.withUnsafeMutableBufferPointer { sysctl($0.baseAddress, 4, &info, &size, nil, 0) }
        // Unknown state must not certify cleanup; zombies cannot execute and
        // are reaped by Foundation/launchd rather than a polling assertion.
        return status != 0 || (size > 0 && info.kp_proc.p_stat != SZOMB)
    }

    func testStoppedAndTermIgnoringChildrenHaveBoundedCleanup() {
        let common = """
        import signal,time
        def ack(role,pid=None):
            pid=os.getpid() if pid is None else pid
            sys.stdout.write('scenario:%s:%d:%d\\n'%(role,pid,os.getpgid(pid)));sys.stdout.flush()
        """
        let ignore = """
        signal.signal(signal.SIGTERM,signal.SIG_IGN)
        ack('leader')
        time.sleep(60)
        """
        let stopped = """
        sys.stdin.buffer.read()
        pid=os.fork()
        if pid==0:
            os.kill(os.getpid(),signal.SIGSTOP)
            time.sleep(60)
            os._exit(0)
        _,state=os.waitpid(pid,os.WUNTRACED)
        if not os.WIFSTOPPED(state): os._exit(2)
        ack('descendant',pid);ack('leader')
        time.sleep(60)
        """
        func forked(closeOutput: Bool) -> String {
            """
            sys.stdin.buffer.read()
            r,w=os.pipe()
            pid=os.fork()
            if pid==0:
                os.close(r);signal.signal(signal.SIGTERM,signal.SIG_IGN)
                ack('descendant')
                \(closeOutput ? "os.close(1)" : "pass")
                os.write(w,b'1');os.close(w)
                time.sleep(60);os._exit(0)
            os.close(w)
            if os.read(r,1)!=b'1': os._exit(2)
            os.close(r);ack('leader');os._exit(0)
            """
        }
        for (body, identities, expectsTimeout) in [(ignore, 1, true), (stopped, 2, true),
                                                  (forked(closeOutput: false), 2, true),
                                                  (forked(closeOutput: true), 2, false)] {
            let observation = Phase95GeneratedChild.Observation()
            defer {
                if let pid = observation.leaderPID {
                    _ = kill(-pid, SIGKILL)
                    if isExecuting(pid) { _ = kill(pid, SIGKILL) }
                }
            }
            let start = ProcessInfo.processInfo.systemUptime
            do {
                _ = try Phase95GeneratedChild.run(common + "\n" + body,
                    payload: Data(repeating: 32, count: 200_000), directory: directory, timeout: 2,
                    observation: observation)
                XCTAssertFalse(expectsTimeout)
            } catch Phase95GeneratedChild.Failure.timeout {
                XCTAssertTrue(expectsTimeout)
            } catch { XCTFail("Wrong child outcome category") }
            XCTAssertLessThan(ProcessInfo.processInfo.systemUptime - start, 5)
            let records = String(decoding: observation.output, as: UTF8.self).split(separator: "\n").compactMap { line -> (String, Int32, Int32)? in
                let parts = line.split(separator: ":")
                guard parts.count == 4, parts[0] == "scenario", ["leader", "descendant"].contains(parts[1]),
                      let pid = Int32(parts[2]), let group = Int32(parts[3]), pid > 1, group > 1,
                      group != getpgrp(), group == observation.leaderPID else { return nil }
                return (String(parts[1]), pid, group)
            }
            // Test-owned final cleanup protects the runner even when a mutation
            // deliberately removes KILL or signals only the group leader.
            XCTAssertEqual(records.count, identities, "Scenario setup must be acknowledged")
            XCTAssertEqual(Set(records.map { $0.0 }), identities == 1 ? ["leader"] : ["leader", "descendant"])
            XCTAssertEqual(Set(records.map { $0.2 }).count, 1)
            XCTAssertTrue(records.filter { $0.0 == "leader" }.allSatisfy { $0.1 == $0.2 })
            let deadline = ProcessInfo.processInfo.systemUptime + 1
            while records.contains(where: { isExecuting($0.1) }) && ProcessInfo.processInfo.systemUptime < deadline { usleep(10_000) }
            XCTAssertFalse(records.contains(where: { isExecuting($0.1) }), "Acknowledged processes must stop executing")
        }
    }

    func testOutputOverflowAndFailureCannotBecomeSuccess() {
        for script in ["sys.stdin.buffer.read(); print('x'*10000)",
                       "sys.stdin.buffer.read(); print('{\"contained\": 2}'); sys.exit(2)"] {
            XCTAssertThrowsError(try Phase95GeneratedChild.run(script,
                payload: Data("{}".utf8), directory: directory, timeout: 5))
        }
    }
}
