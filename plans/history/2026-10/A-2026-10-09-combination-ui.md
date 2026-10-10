# A-2026-10-09-combination-ui

Status: `completed`。所有者要求取消组合上限提示、改进组合处理，并明确选择未开发入口
保留但置灰、不弹提示。

## Scope

- 478点统一网格已具备实际像素位移/梯度界；旧跨区域参数总和1.0及宿主余额截停重复
  限制，与实际变形无直接对应。本轮对进入dense map的参数保留独立强度，仍由map最终
  位移/梯度/姿态预算保护；源像素refinement/admission及刚性平移单列保留旧组合预算，legacy路线不改。
- 宿主滑块只按独立字段cap映射，保留之前参数/撤销与别名。取消regular UI预算提示；
  SDK安全降幅仍为aggregate debug/metrics，不能承诺任意组合完全不减弱或无限强度。
- 未实现的两个分类和去脂入口置灰且禁用交互；直接model调用同样无弹窗/无状态改变。
  不实现新的3D/去脂或未有规格的分类，不恢复已关闭算法任务。
- 核对字段接线、整体scope、视觉标识与可调用内容；只更新当前任务直接相关的契约。

## Executed verification

- SDK最终定向 **25 tests / 0 failures / 0 skips**：4个新dense组合测试、7个既有网格
  测试、14个既有冲突测试。独立字段/方向不被L1缩减、九源字段及legacy保留原预算、
  nonfresh不启用新组合准入；实际解析高组合输出变化、重复、alpha/尺寸、边缘保护、
  所有三角正面积和位移/梯度界通过。参数/default/cap与retained shader未改。
- 外部宿主 **12个不同相关用例最终全部通过**（10 unit + 2 UI）：51字段接线/cap、
  alias、满档组合、旧字段/撤销/确认事务、未开发调用无状态变化、原生连续鼻子与组合
  实际像素、478复检、重复、UI完整滑块值及无quota banner、禁用语义与实际点击。
  `.verification/combination-ui-20261009.xcresult`初轮12项为11通过/1失败/0跳过，失败是
  测试在没有提示时读取不存在元素的label；改成直接断言提示不存在后，
  `combination-ui-20261009-disabled-r2.xcresult`单项 **1/0/0**。
  最终明确fresh条件后，`combination-ui-20261009-fresh-final.xcresult`真实组合像素单项
  **1/0/0**；它是此前12项中的重验，不将重复计入新用例总数。三个xcresult独立解析。
- 已实际查看同一设备编辑/确认/恢复及禁用分类/眼部入口5张生成输入截图；单安全区
  所有者、184pt面板、44pt滑块/按钮、背景贴底和内容避让断言通过。未改变方向/字体。
- 既有macOS像素helper只做增量编译通过，确认setter移除后没有失效调用；legacy组合
  警告仍为合法SDK诊断，不冒称macOS已启用dense网格。51字段绑定/cap静态核对、
  post-archive SDK-only boundary和差异/当前文档导航通过。没有跑全量或重新签发1098门禁。

## Corrections and limits

- 新测试首轮误用无参数strength类型的memberwise初始化；随后把小脸请求0.6当作
  准入值，实际cap为0.45。修正构造/输入，没有改cap或放宽生产标准。
  stale脸型strength原契约保留字段但跳过域，测试改为验证域跳过、无点/无map；
  鼻/唇仍为零。新增fresh条件没有授权复用过期检测，生产adapter始终产生新支撑。
- 模拟器准备首轮自动审批超时；将只读清单与tmp准备分开后成功，没有安全拒绝或
  设备抢占。复用同一iPhone15Pro/iOS17.5及稳定缓存；占用记录结束释放。
- 常规界面自动处理组合，debug仍保留aggregate警告。实际网格超界可以共同减弱，
  不能宣称任意组合位移不衰减、无限强度、真机速度或所有人像外观合格。
  SDK/UI未开发状态分别记录；“整体”仍只读，Pro/限免装饰及后续能力状态来源已写入
  当前技术债。旧Vision与人物分割失败、去脂suspended和EYE/SEG终局保留。
- App源仍在已授权的外部宿主；仓库内不恢复UI、归档或新增GPU/模型资源。临时输入与
  截图提取副本检查后清理，只保留现有有效缓存/xcresult和本聚合文字，不写原始数据。
