-- WowRaidToolkits - 团队工具包 (测试版本)
-- 版本: 1.0.0
-- 作者: WowRaidToolkits

local addonName = "WowRaidToolkits"

-- 简单的测试命令
SLASH_WOWRAIDTOOLKITS1 = "/wrt"
SLASH_WOWRAIDTOOLKITS2 = "/wowraidtoolkits"

SlashCmdList["WOWRAIDTOOLKITS"] = function(msg)
    print("|cff00ff00[WowRaidToolkits]|r 命令被调用: " .. (msg or "空"))
    print("|cff00ff00[WowRaidToolkits]|r 测试成功! 插件正在工作")
end

print("|cff00ff00[WowRaidToolkits]|r 插件已加载! 输入 |cff00ff00/wrt|r 来测试")
