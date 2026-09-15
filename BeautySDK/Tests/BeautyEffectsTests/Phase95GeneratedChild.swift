import Darwin
import Foundation

/// Test-only, bounded transport for generated data. Never a private-image API.
enum Phase95GeneratedChild {
    enum Failure: Error { case invalidInput, transport, timeout, outputLimit, childFailed, protocolFailure }
    final class Observation {
        fileprivate(set) var output = Data()
        fileprivate(set) var leaderPID: Int32?
    }
    static let ready = Data("phase95-ready\n".utf8)

    static func isSuccess(_ data: Data, pairs: Bool) -> Bool {
        let expected = pairs ? "{\"structural_pairs\": 1, \"passed\": true}\n" : "{\"contained\": 2}\n"
        return data == Data(expected.utf8)
    }

    static func run(_ script: String, payload: Data, directory: URL, timeout: Double = 300,
                    observation: Observation? = nil) throws -> Data {
        observation?.output = Data(); observation?.leaderPID = nil
        guard timeout.isFinite, timeout > 0, timeout <= 300, !payload.isEmpty,
              payload.count <= 262_144, script.utf8.count <= 32_768 else { throw Failure.invalidInput }
        let child = Process(), input = Pipe(), output = Pipe()
        let writeFD = input.fileHandleForWriting.fileDescriptor
        let readFD = output.fileHandleForReading.fileDescriptor
        var inputClosed = false, groupOwned = false
        func closeInput() {
            if !inputClosed { try? input.fileHandleForWriting.close(); inputClosed = true }
        }
        defer { closeInput(); try? output.fileHandleForReading.close() }
        guard fcntl(writeFD, F_SETFL, O_NONBLOCK) == 0,
              fcntl(readFD, F_SETFL, O_NONBLOCK) == 0,
              fcntl(writeFD, F_SETNOSIGPIPE, 1) == 0 else { throw Failure.transport }
        child.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        child.currentDirectoryURL = directory
        // The fixed preamble establishes a process group before acknowledging
        // ownership. The acknowledgement is stripped, never a success verdict.
        let preamble = "import os,sys\nif os.getpgrp()!=os.getpid(): os.setsid()\nsys.stdout.write('phase95-ready\\n'); sys.stdout.flush()\n"
        child.arguments = ["-B", "-c", preamble + script]
        child.standardInput = input; child.standardOutput = output; child.standardError = FileHandle.nullDevice
        let start = ProcessInfo.processInfo.systemUptime
        try child.run()
        observation?.leaderPID = child.processIdentifier
        var sent = 0, bytes = Data(), eof = false
        func signalOwned(_ signal: Int32) {
            let pid = child.processIdentifier
            if groupOwned || getpgid(pid) == pid { groupOwned = true; _ = kill(-pid, signal) }
            else if child.isRunning { _ = kill(pid, signal) }
        }
        defer {
            closeInput()
            // A deadline can fire before the first normal read, after a fast
            // leader already forked/exited. Recover its fixed acknowledgement
            // without blocking before deciding which process group to clean.
            if !groupOwned {
                var prefix = Data(bytes.prefix(ready.count))
                while prefix.count < ready.count {
                    var buffer = [UInt8](repeating: 0, count: ready.count - prefix.count)
                    let count = Darwin.read(readFD, &buffer, buffer.count)
                    if count <= 0 { break }
                    prefix.append(contentsOf: buffer.prefix(count))
                }
                groupOwned = prefix == ready
            }
            signalOwned(SIGTERM)
            let grace = ProcessInfo.processInfo.systemUptime + 0.2
            while child.isRunning && ProcessInfo.processInfo.systemUptime < grace { usleep(10_000) }
            // Also remove descendants after a normally exited group leader.
            signalOwned(SIGKILL)
            let reap = ProcessInfo.processInfo.systemUptime + 2
            while child.isRunning && ProcessInfo.processInfo.systemUptime < reap { usleep(10_000) }
            // Foundation owns reaping. Never call unbounded waitUntilExit().
        }
        while true {
            guard ProcessInfo.processInfo.systemUptime - start <= timeout else { throw Failure.timeout }
            if !inputClosed {
                let count = payload.withUnsafeBytes { raw in
                    Darwin.write(writeFD, raw.baseAddress!.advanced(by: sent), payload.count - sent)
                }
                if count > 0 { sent += count }
                else if count < 0 && errno != EAGAIN && errno != EINTR { throw Failure.transport }
                if sent == payload.count { closeInput() }
            }
            while !eof {
                var buffer = [UInt8](repeating: 0, count: 4096)
                let count = Darwin.read(readFD, &buffer, buffer.count)
                if count == 0 { eof = true; break }
                if count < 0 {
                    if errno == EAGAIN { break }
                    if errno == EINTR { continue }
                    throw Failure.transport
                }
                bytes.append(contentsOf: buffer.prefix(count))
                guard bytes.count <= 4096 + ready.count else { throw Failure.outputLimit }
                if bytes.count >= ready.count {
                    guard bytes.starts(with: ready) else { throw Failure.protocolFailure }
                    groupOwned = true
                    observation?.output = Data(bytes.dropFirst(ready.count))
                }
            }
            if !child.isRunning && eof {
                guard sent == payload.count, child.terminationStatus == 0 else { throw Failure.childFailed }
                guard groupOwned, bytes.starts(with: ready) else { throw Failure.protocolFailure }
                return bytes.dropFirst(ready.count)
            }
            usleep(10_000)
        }
    }
}
