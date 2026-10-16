import Foundation
import Photos

@MainActor
protocol PhotoLibrarySaving {
    func save(_ data: Data) async throws
}

@MainActor
struct PhotoLibraryWriter: PhotoLibrarySaving {
    func save(_ data: Data) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { throw EditorError.saveDenied }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            }
        } catch { throw EditorError.saveFailed }
    }
}
