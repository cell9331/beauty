@_exported import BeautyCore
import BeautyRender

public enum BeautySDKModule {
    public static let name = "BeautySDK"
}

@_spi(Testing) public typealias SDKTestingCopyRenderPass = CopyRenderPass
@_spi(Testing) public typealias SDKTestingRenderGraph = RenderGraph
@_spi(Testing) public typealias SDKTestingRenderPass = RenderPass
