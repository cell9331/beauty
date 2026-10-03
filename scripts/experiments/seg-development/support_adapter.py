"""Request-local existing observation plumbing in a disposable CPU package."""
def install(package, require):
    path=package/'Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift'
    text=path.read_text()
    changes=[
      ('face: face, textureFaceBounds: selectedFaceObservation?.imageBounds,\n                     textureExclusionMask: textureExclusionMask)',
       'face: face, textureFaceBounds: selectedFaceObservation?.imageBounds,\n                     textureExclusionMask: textureExclusionMask, pilotFace: selectedFaceObservation)'),
      ('textureFaceBounds: selectedFaceObservation?.imageBounds,\n            textureExclusionMask: textureExclusionMask\n',
       'textureFaceBounds: selectedFaceObservation?.imageBounds,\n            textureExclusionMask: textureExclusionMask, pilotFace: selectedFaceObservation\n'),
      ('textureExclusionMask: BeautyTextureExclusionMask? = nil\n    ) -> CIImage {\n        var output = applyColorEffects(',
       'textureExclusionMask: BeautyTextureExclusionMask? = nil,\n        pilotFace: BeautyFaceObservation? = nil\n    ) -> CIImage {\n        var output = applyColorEffects('),
      ('face: face, textureFaceBounds: textureFaceBounds,\n            textureExclusionMask: textureExclusionMask\n',
       'face: face, textureFaceBounds: textureFaceBounds,\n            textureExclusionMask: textureExclusionMask, pilotFace: pilotFace\n'),
      ('textureExclusionMask: BeautyTextureExclusionMask?\n    ) -> CIImage {',
       'textureExclusionMask: BeautyTextureExclusionMask?,\n        pilotFace: BeautyFaceObservation? = nil\n    ) -> CIImage {'),
      ('faceBounds: textureFaceBounds, exclusionMask: textureExclusionMask\n',
       'faceBounds: textureFaceBounds, exclusionMask: textureExclusionMask, pilotFace: pilotFace\n')]
    for old,new in changes:
        require(text.count(old)==1,'support_adapter_anchor_changed')
        text=text.replace(old,new)
    path.write_text(text)
