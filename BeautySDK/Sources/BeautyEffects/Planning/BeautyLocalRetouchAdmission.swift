/// Feature-neutral admission for request-local still-image work.
///
/// Phase 53 intentionally owns an empty production inventory. The opaque count
/// exists only so the package testing seam can prove that one or many future
/// demands share one canonical request without naming a candidate feature.
package struct BeautyLocalRetouchAdmission: Equatable, Sendable {
    package static let none = BeautyLocalRetouchAdmission(opaqueDemandCount: 0)

    private let opaqueDemandCount: Int

    package init(opaqueDemandCount: Int) {
        self.opaqueDemandCount = max(0, opaqueDemandCount)
    }

    package var isEmpty: Bool {
        opaqueDemandCount == 0
    }
}
