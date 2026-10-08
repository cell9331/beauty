# beauty 仓库 Git 操作与账号

提交、推送、拉取或排查本仓库 GitHub 身份/权限前读取。本文只记录
`beauty` 的远端和账号选择；其他仓库按各自约定处理，不迁移到全局 `AGENTS.md`。

## 已验证的本机身份（2026-10-08）

用户有两个 GitHub 账号。本次 SSH 实际认证与推送确认如下：

| 入口 | GitHub 身份 | 本仓库用途 |
| --- | --- | --- |
| `/Users/yakangwang/.ssh/id_ed25519`，显式 `IdentitiesOnly=yes` | `cell9331` | `origin` 所属账号；用此身份执行本仓库 SSH 操作。 |
| `/Users/yakangwang/.ssh/id_rsa`，以及本次默认 SSH 选择 | `WYaKang` | 本次推送被拒绝：`Permission to cell9331/beauty.git denied to WYaKang`。 |
| 当前 `gh` 登录（本次核对） | `WYaKang` | 仓库元数据查询显示 `READ`，不能据此判断 `cell9331` SSH 身份的写权限。 |

`origin` 为 `ssh://git@ssh.github.com:443/cell9331/beauty.git`。
该仓库在本次核对时公开；这是仓库可见性记录，不增加 SDK、模型、权重、
私有夹具或派生数据的分发授权。账号与远端变更后应更新本文件。

## 直接使用的推送方式

用户要求推送到本仓库现有 `origin` 时，先按正常提交流程确认当前分支、
提交范围与远端，再直接使用已验证的 SSH 身份，无需重新枚举账号或密钥。

```sh
git branch --show-current
git remote get-url --push origin
git -c 'core.sshCommand=ssh -o BatchMode=yes -o IdentitiesOnly=yes -i /Users/yakangwang/.ssh/id_ed25519' push --set-upstream origin HEAD
```

最后一条适用于已确认的普通当前分支；用户指定目标分支时使用其指定的 ref，
不照抄历史分支名、不自动推送其他分支或标签、不使用 force。
`fetch` 等 SSH 操作也可复用同一命令级 `core.sshCommand`。
不修改全局 Git/SSH 配置、不切换 `gh` 默认账号、不轮换或删除密钥。
工作流锁、尝试日志和其他本地运行状态不因“提交代码”自动进入提交。

## 需要重新核对的情况

- 远端所有者/协议、执行主机、密钥文件或用户指定身份已变化，才重新核对相关项；
  HTTPS 远端不能套用上述 SSH 配置。
- 再次出现 `denied to WYaKang` 时，检查本次命令是否确实带了上述 SSH 配置；
  若已认证为 `cell9331` 仍被拒绝，再检查目标仓库权限。
- DNS/连接失败、sandbox 内的 `gh` 登录检查失败不证明凭据无效；按实际网络或
  审批错误处理，不据此重新登录或删除凭据。自动审批拒绝时报告其原因，不绕过。

本次用户在获知具体公开目标及未推送历史后明确授权推送；使用
`id_ed25519` 成功创建远端分支 `codex/face-parsing-coreml-evaluation`，
提交 `c2f5bc4f`，Git 返回退出码 0 并设置追踪。本记录不是以后任意目标的推送授权。
