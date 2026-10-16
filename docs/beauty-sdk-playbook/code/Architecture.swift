// Architecture.swift
// 设计骨架（未编译验证）：对应《478点完整方案》第 1–2 节的类型划分。
// 目的是固定"边界与协议"，不是可直接运行的实现。
import CoreMedia
import CoreVideo
import Metal
import simd

// MARK: - 能力与特征描述（数据驱动，便于扩展与降级）

public enum Capability: Hashable {
    case landmarks478, blendshapes, facePose
    case skinSegmentation, hairSegmentation, personSegmentation, neckSegmentation
}

public struct ParameterSpec {
    public var range: ClosedRange<Float> = 0...1
    public var defaultValue: Float = 0
    public var curveID: String            // 指向 curves.json 中的 PCHIP 曲线
    public var isBilateral: Bool = false // 是否区分左右
}

public struct FeatureDescriptor {
    public enum Stage { case photometric, geometry, post }
    public var id: String                 // 例："geometry.eye.size"
    public var stage: Stage
    public var requires: Set<Capability>
    public var parameter: ParameterSpec
    public var costHint: Int              // 供质量分级排序，数值越大越贵
}

// MARK: - 关键点 / 分割来源（可插拔，各自独立 target）

public struct FaceObservation {
    public var faceID: Int?                       // 来源可无稳定 ID，则由 FaceTracker 关联
    public var points: [SIMD3<Float>]             // 像素坐标 x,y；z 为相对深度
    public var blendshapes: [String: Float]
    public var poseMatrix: simd_float4x4?
    public var presence: Float
    public var timestamp: CMTime
}

public protocol LandmarkProvider: AnyObject {
    var modelID: String { get }                   // 与 face_model_spec.json 对应
    var capabilities: Set<Capability> { get }
    /// 同步推理；由 Engine 在内部串行队列调用
    func detect(pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation,
                timestamp: CMTime) throws -> [FaceObservation]
}

public enum SegmentationKind { case skin, hair, person, neck }

public protocol SegmentationProvider: AnyObject {
    var kinds: Set<SegmentationKind> { get }
    /// 返回 R8 单通道 mask（可低分辨率，后续用 Guided Filter 细化）
    func segment(pixelBuffer: CVPixelBuffer, kind: SegmentationKind,
                 timestamp: CMTime) throws -> MTLTexture
}

// MARK: - 帧上下文（几何层与像素层共享，值类型，不含 GPU 对象）

public struct FaceContext {
    public var id: Int
    public var points: [SIMD2<Float>]            // 滤波后，像素坐标
    public var frame: SIMD2<Float>               // 占位：实际用 FaceFrame478
    public var yaw: Float, pitch: Float, roll: Float
    public var blinkL: Float, blinkR: Float      // 0 睁眼 ... 1 闭眼
    public var mouthOpen: Float
    public var gate: Float                       // 丢脸渐隐/渐入 0...1
}

// MARK: - 几何功能：只产出位移贡献，不碰 GPU

/// 单个功能对"顶点位移"的贡献（局部坐标单位 = 外眼角距比例）
public struct DisplacementContribution {
    public var vertexOffsets: [SIMD2<Float>]     // 与拓扑顶点一一对应
}

public protocol GeometryFeature: AnyObject {
    var descriptor: FeatureDescriptor { get }
    /// 读取预烘焙权重图（来自 BeautyAssets），结合参数与 FaceContext 返回位移
    func contribute(context: FaceContext,
                    parameters: BeautyParameters,
                    weights: WeightLibrary) -> DisplacementContribution?
}

public struct WeightLibrary {
    public func weights(for featureID: String, side: Side?) -> [Float]? { nil }
    public enum Side { case left, right }
}

// MARK: - 像素功能：声明所需 mask 与 Pass，由 RenderGraph 调度

public struct MaskRequirement: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let skin = MaskRequirement(rawValue: 1 << 0)
    public static let lips = MaskRequirement(rawValue: 1 << 1)
    public static let teeth = MaskRequirement(rawValue: 1 << 2)
    public static let sclera = MaskRequirement(rawValue: 1 << 3)
    public static let brow = MaskRequirement(rawValue: 1 << 4)
    public static let hair = MaskRequirement(rawValue: 1 << 5)
}

public protocol RenderPassNode: AnyObject {
    var id: String { get }
    var reads: [String] { get }                  // 依赖的资源名
    var writes: [String] { get }
    func encode(into commandBuffer: MTLCommandBuffer, graph: RenderGraphContext)
}

public protocol PhotometricFeature: AnyObject {
    var descriptor: FeatureDescriptor { get }
    var maskRequirements: MaskRequirement { get }
    func passes(parameters: BeautyParameters, contexts: [FaceContext]) -> [RenderPassNode]
}

public final class RenderGraphContext {
    // 纹理池（MTLHeap、可别名）、mask 缓存、质量档位等；此处省略
}

// MARK: - 参数（对外 Codable 值类型，内部以不可变快照传递）

public struct BeautyParameters: Codable, Equatable {
    public var values: [String: Float] = [:]     // featureID -> 0...1（UI 值，内部经曲线映射）
    public var preset: String? = nil
    public init() {}
}

// MARK: - 质量分级

public enum QualityTier: Int, Comparable {
    case emergency, low, balanced, high, ultra
    public static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }
}

public struct BeautyConfiguration {
    public var landmarkProvider: LandmarkProvider
    public var segmentationProviders: [SegmentationProvider] = []
    public var assetsURL: URL                    // BeautyAssets 包
    public var maxFaces: Int = 3
    public var preferredQuality: QualityTier = .high
    public var enableTelemetry: Bool = false     // 默认关闭，且永不含人脸数据
}

public struct BeautyDiagnostics {
    public var passTimingsMs: [String: Double] = [:]
    public var disabledFeatures: [String: String] = [:]   // id -> 原因码（如 "missing:hairSegmentation"）
    public var tier: QualityTier = .high
    public var tracking: [Int: String] = [:]              // faceID -> 状态机状态
}

// MARK: - 对外入口

public struct BeautyResult {
    public var output: CVPixelBuffer
    public var diagnostics: BeautyDiagnostics
}

public enum BeautyError: Error {
    case assetsSchemaMismatch(expected: Int, found: Int)
    case metalUnavailable
    case providerFailed(underlying: Error)
}

public final class BeautyEngine {
    public init(configuration: BeautyConfiguration) throws {
        // 1. 校验 assets schemaVersion
        // 2. 创建 Metal 设备/队列，预编译 pipeline（MTLBinaryArchive）
        // 3. 读取 face_model_spec.json，建立语义层；加载拓扑与权重图
        // 4. 按 Capability 注册可用特征；不可用的写入 diagnostics.disabledFeatures
        fatalError("skeleton")
    }

    /// 任意线程可调用；内部原子替换不可变快照
    public func setParameters(_ parameters: BeautyParameters) { }

    /// 宿主保证对同一 engine 串行调用
    public func process(pixelBuffer: CVPixelBuffer,
                        timestamp: CMTime,
                        orientation: CGImagePropertyOrientation) throws -> BeautyResult {
        // FaceTracker → FaceContext[] → 几何合成(限幅/正则/注入性) → RenderGraph 编码 → 输出
        fatalError("skeleton")
    }

    public func reset() { }                      // 切换摄像头、前后台切换时调用
}
