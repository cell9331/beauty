# 当前 SDK 实现与接入

本目录说明已有 SDK 的有界实现与所有者本地宿主接入。根级
[ARCHITECTURE](../../ARCHITECTURE.md)、[DESIGN](../../DESIGN.md) 和
[PRODUCT_SENSE](../../PRODUCT_SENSE.md) 拥有对应契约。

| 文档 | 内容 |
| --- | --- |
| [效果分类与参数映射](../SDK_EFFECT_TAXONOMY.md) | 当前 effect/control status；保留固定权威路径 |
| [478 点静图改造](DENSE_FACE_REFACTOR.md) | 请求内支撑、固定画布网格、纹理与资源复用 |
| [脸型滑杆与连续轮廓](FACE_SHAPE_SLIDERS.md) | 双向接线、八项连续场、保护与参考差距 |
| [眼部滑杆与连续几何](EYE_SHAPE_SLIDERS.md) | 十一项独立双向映射、眼高/虹膜分离与支撑边界 |
| [固定图片连续编辑](PREPARED_PHOTO_EDITING.md) | 显式单源准备、按用途检测复用、换图/reset失效与Demo预览接入 |
| [主机显式保护](HOST_TEXTURE_PROTECTION.md) | 宿主提供物体与完整唇部保护蒙版的接入 |

图片效果验收与批量工具见 [validation/](../validation/README.md)。

- [Mouth slider mappings and continuous geometry](MOUTH_SLIDERS.md): signed directions, inner-lip protection and reference evidence limits.
