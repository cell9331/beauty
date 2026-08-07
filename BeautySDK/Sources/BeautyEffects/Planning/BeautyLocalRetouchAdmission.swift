/// Feature-neutral admission for request-local still-image work.
///
/// The opaque count allows independent local-retouch intents to share one
/// canonical request without naming features or exposing provider details.
package struct BeautyLocalRetouchAdmission: Equatable, Sendable {
    package static let none = BeautyLocalRetouchAdmission(opaqueDemandCount: 0)

    private let opaqueDemandCount: Int

    package init(opaqueDemandCount: Int) {
        self.opaqueDemandCount = max(0, opaqueDemandCount)
    }

    package var isEmpty: Bool {
        opaqueDemandCount == 0
    }

    package var demandCount: Int {
        opaqueDemandCount
    }
}
