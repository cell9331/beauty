import BeautyCore
import Foundation

/// Package-only primitive data used by the bounded Metal transaction.
///
/// The pass graph intentionally carries no image, framework, support, mask, or
/// landmark objects. Those remain owned by the adapter that creates this value.
package enum BeautyMetalPass: Equatable, Sendable {
    case color(BeautyMetalColorParameters)
    case geometry(BeautyMetalGeometryParameters)
    case composedRetouch(BeautyMetalComposedRetouchParameters)

    package var kernelName: String {
        switch self {
        case .color:
            "beauty_color_pass"
        case .geometry:
            "beauty_geometry_pass"
        case .composedRetouch:
            "beauty_local_retouch_pass"
        }
    }
}

package struct BeautyMetalColorUniform: Equatable, Sendable {
    package var saturationDelta: Float
    package var contrastScale: Float
    package var lightLift: Float
    package var redBias: Float
    package var greenBias: Float
    package var blueBias: Float
    package var highlightLift: Float
    package var shadowLift: Float
    package var smoothing: Float
    package var lipCenterX: Float
    package var lipCenterY: Float
    package var lipRadiusX: Float
    package var lipRadiusY: Float
    package var lipStrength: Float
    package var lipEnabled: UInt32
    package var reserved: UInt32 = 0
}

package struct BeautyMetalColorParameters: Equatable, Sendable {
    package let uniform: BeautyMetalColorUniform

    package init(
        saturationDelta: Float,
        contrastScale: Float,
        lightLift: Float,
        redBias: Float,
        greenBias: Float,
        blueBias: Float,
        highlightLift: Float,
        shadowLift: Float,
        smoothing: Float,
        lipCenterX: Float = 0,
        lipCenterY: Float = 0,
        lipRadiusX: Float = 0,
        lipRadiusY: Float = 0,
        lipStrength: Float = 0,
        lipEnabled: Bool = false
    ) throws {
        let values = [
            saturationDelta, contrastScale, lightLift, redBias, greenBias,
            blueBias, highlightLift, shadowLift, smoothing, lipCenterX,
            lipCenterY, lipRadiusX, lipRadiusY, lipStrength,
        ]
        guard values.allSatisfy({ $0.isFinite }),
              abs(saturationDelta) <= 1,
              contrastScale >= 0,
              contrastScale <= 2,
              abs(lightLift) <= 1,
              abs(redBias) <= 1,
              abs(greenBias) <= 1,
              abs(blueBias) <= 1,
              abs(highlightLift) <= 1,
              abs(shadowLift) <= 1,
              smoothing >= 0,
              smoothing <= 1,
              lipCenterX >= 0,
              lipCenterX <= 1,
              lipCenterY >= 0,
              lipCenterY <= 1,
              lipRadiusX >= 0,
              lipRadiusX <= 1,
              lipRadiusY >= 0,
              lipRadiusY <= 1,
              lipStrength >= 0,
              lipStrength <= 1,
              (!lipEnabled || (lipRadiusX > 0 && lipRadiusY > 0))
        else {
            throw BeautyError.invalidInput
        }

        uniform = BeautyMetalColorUniform(
            saturationDelta: saturationDelta,
            contrastScale: contrastScale,
            lightLift: lightLift,
            redBias: redBias,
            greenBias: greenBias,
            blueBias: blueBias,
            highlightLift: highlightLift,
            shadowLift: shadowLift,
            smoothing: smoothing,
            lipCenterX: lipCenterX,
            lipCenterY: lipCenterY,
            lipRadiusX: lipRadiusX,
            lipRadiusY: lipRadiusY,
            lipStrength: lipStrength,
            lipEnabled: lipEnabled ? 1 : 0
        )
    }
}

package struct BeautyMetalWarpPoint: Equatable, Sendable {
    package let sourceX: Float
    package let sourceY: Float
    package let targetX: Float
    package let targetY: Float
    package let radius: Float
    package let strength: Float
    package let falloff: Float

    package init(
        sourceX: Float,
        sourceY: Float,
        targetX: Float,
        targetY: Float,
        radius: Float,
        strength: Float,
        falloff: Float
    ) throws {
        let values = [sourceX, sourceY, targetX, targetY, radius, strength, falloff]
        guard values.allSatisfy({ $0.isFinite }),
              (0...1).contains(sourceX),
              (0...1).contains(sourceY),
              (0...1).contains(targetX),
              (0...1).contains(targetY),
              (0...1).contains(radius),
              abs(strength) <= 1,
              falloff >= 0,
              falloff <= 3
        else {
            throw BeautyError.invalidInput
        }
        self.sourceX = sourceX
        self.sourceY = sourceY
        self.targetX = targetX
        self.targetY = targetY
        self.radius = radius
        self.strength = strength
        self.falloff = falloff
    }
}

package struct BeautyMetalGeometryParameters: Equatable, Sendable {
    package static let maximumPointCount = 256
    package let points: [BeautyMetalWarpPoint]

    package init(points: [BeautyMetalWarpPoint]) throws {
        guard points.count <= Self.maximumPointCount else {
            throw BeautyError.invalidInput
        }
        self.points = points
    }
}

/// A deliberately small placeholder for the composed local-retouch operation.
/// Later composition owners supply the already-composed request-local result;
/// the Metal runtime only performs a bounded copy pass.
package struct BeautyMetalComposedRetouchParameters: Equatable, Sendable {
    package let preservesOriginalBytes: Bool

    package init(preservesOriginalBytes: Bool = true) throws {
        guard preservesOriginalBytes else { throw BeautyError.invalidInput }
        self.preservesOriginalBytes = preservesOriginalBytes
    }
}

package typealias BeautyMetalLocalRetouchParameters = BeautyMetalComposedRetouchParameters
