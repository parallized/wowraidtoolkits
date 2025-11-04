local addonName = "WowRaidToolkits"
local addon = CreateFrame("Frame")

WowRaidToolkitsDB = WowRaidToolkitsDB or {}

local classColors = {
    ["WARRIOR"] = "|cffC79C6E",
    ["PALADIN"] = "|cffF58CBA",
    ["HUNTER"] = "|cffABD473",
    ["ROGUE"] = "|cffFFF569",
    ["PRIEST"] = "|cffFFFFFF",
    ["DEATHKNIGHT"] = "|cffC41F3B",
    ["SHAMAN"] = "|cff0070DE",
    ["MAGE"] = "|cff69CCF0",
    ["WARLOCK"] = "|cff9482C9",
    ["MONK"] = "|cff00FF96",
    ["DRUID"] = "|cffFF7D0A",
    ["DEMONHUNTER"] = "|cffA330C9",
    ["EVOKER"] = "|cff33937F",
}

local roleNames = {
    ["TANK"] = "坦克",
    ["HEALER"] = "治疗",
    ["DAMAGER"] = "输出",
}

local classNameMap = {
    ["WARRIOR"] = "战士",
    ["PALADIN"] = "圣骑士",
    ["HUNTER"] = "猎人",
    ["ROGUE"] = "潜行者",
    ["PRIEST"] = "牧师",
    ["DEATHKNIGHT"] = "死亡骑士",
    ["SHAMAN"] = "萨满",
    ["MAGE"] = "法师",
    ["WARLOCK"] = "术士",
    ["MONK"] = "武僧",
    ["DRUID"] = "德鲁伊",
    ["DEMONHUNTER"] = "恶魔猎手",
    ["EVOKER"] = "唤魔师",
}

local roleToJson = {
    ["TANK"] = "tank",
    ["HEALER"] = "healer", 
    ["DAMAGER"] = "dps",
}

local classToJson = {
    ["WARRIOR"] = "warrior",
    ["PALADIN"] = "paladin",
    ["HUNTER"] = "hunter",
    ["ROGUE"] = "rogue",
    ["PRIEST"] = "priest",
    ["DEATHKNIGHT"] = "deathknight",
    ["SHAMAN"] = "shaman",
    ["MAGE"] = "mage",
    ["WARLOCK"] = "warlock",
    ["MONK"] = "monk",
    ["DRUID"] = "druid",
    ["DEMONHUNTER"] = "demonhunter",
    ["EVOKER"] = "evoker",
}

local function RemoveServerName(fullName)
    if not fullName then
        return fullName
    end
    local name, server = strsplit("-", fullName, 2)
    return name or fullName
end

local function GetDifficulty()
    local difficultyID = GetRaidDifficultyID()
    local difficultyName = GetDifficultyInfo(difficultyID)
    
    if difficultyID == 16 then
        return "mythic"
    elseif difficultyID == 15 then
        return "heroic"
    elseif difficultyID == 14 then
        return "normal"
    elseif difficultyID == 1 then
        return "lfr"
    else
        return "normal"
    end
end

local function GetRaidInfoDisplay()
    local raidInfo = {}
    local numGroupMembers = GetNumGroupMembers()
    
    if numGroupMembers == 0 then
        return "你不在团队中"
    end
    
    local isRaid = IsInRaid()
    local groupType = isRaid and "团队" or "小队"
    
    table.insert(raidInfo, "=== " .. groupType .. "信息 ===")
    table.insert(raidInfo, "")
    
    for i = 1, numGroupMembers do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        
        if name then
            name = RemoveServerName(name)
            local className = classNameMap[fileName] or fileName or "未知职业"
            local roleName = roleNames[role] or "未知"
            local color = classColors[fileName] or "|cffffffff"
            local status = online and "" or "|cff808080[离线]|r"
            
            local info = string.format("%s%s|r %s (%s) - %s%s", 
                color, name, className, level, roleName, status)
            table.insert(raidInfo, info)
        end
    end
    
    return table.concat(raidInfo, "\n")
end

local function GetRaidInfo()
    local numGroupMembers = GetNumGroupMembers()
    
    if numGroupMembers == 0 then
        return "你不在团队中"
    end
    
    local difficulty = GetDifficulty()
    local raidPlayers = {}
    
    for i = 1, numGroupMembers do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        
        if name and online then
            name = RemoveServerName(name)
            local role = UnitGroupRolesAssigned(name)
            local jsonRole = roleToJson[role] or "unknown"
            local jsonClass = classToJson[fileName] or "unknown"
            
            table.insert(raidPlayers, {
                name = name,
                role = jsonRole,
                class = jsonClass
            })
        end
    end
    
    local jsonStr = '{"difficulty":"' .. difficulty .. '","raidPlayers":['
    
    for i, player in ipairs(raidPlayers) do
        if i > 1 then
            jsonStr = jsonStr .. ","
        end
        jsonStr = jsonStr .. string.format('{"name":"%s","role":"%s","class":"%s"}', 
            player.name, player.role, player.class)
    end
    
    jsonStr = jsonStr .. "]}"
    
    return jsonStr
end

local function CreateMainFrame()
    local frame = CreateFrame("Frame", "WowRaidToolkitsFrame", UIParent)
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.8)
    
    -- frame.border = CreateFrame("Frame", nil, frame, "DialogBorderTemplate")
    -- frame.border:SetAllPoints()
    
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -15)
    frame.title:SetText("团队信息")
    
    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.hint:SetPoint("TOP", 0, -35)
    frame.hint:SetText("|cff808080提示: 可以直接在文本框中编辑和复制内容|r")
    
    frame.editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.editBox:SetSize(460, 280)
    frame.editBox:SetPoint("TOP", 0, -60)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject("GameFontHighlight")
    frame.editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetSize(460, 280)
    frame.scrollFrame:SetPoint("TOP", 0, -60)
    frame.scrollFrame:SetScrollChild(frame.editBox)
    
    frame.selectAllButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.selectAllButton:SetSize(100, 30)
    frame.selectAllButton:SetPoint("BOTTOMLEFT", 20, 20)
    frame.selectAllButton:SetText("全选")
    frame.selectAllButton:SetScript("OnClick", function()
        frame.editBox:SetFocus()
        frame.editBox:HighlightText()
        frame.editBox:SetCursorPosition(0)
    end)
    
    frame.toggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.toggleButton:SetSize(100, 30)
    frame.toggleButton:SetPoint("BOTTOM", 0, 20)
    frame.toggleButton:SetText("切换格式")
    frame.toggleButton:SetScript("OnClick", function()
        if frame.showJson then
            frame.showJson = false
            frame.editBox:SetText(GetRaidInfoDisplay())
            frame.toggleButton:SetText("显示JSON")
        else
            frame.showJson = true
            frame.editBox:SetText(GetRaidInfo())
            frame.toggleButton:SetText("显示列表")
        end
    end)
    
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.closeButton:SetSize(100, 30)
    frame.closeButton:SetPoint("BOTTOMRIGHT", -20, 20)
    frame.closeButton:SetText("关闭")
    frame.closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    return frame
end

function ShowRaidInfo()
    if not addon.mainFrame then
        addon.mainFrame = CreateMainFrame()
    end
    
    local raidInfoJson = GetRaidInfo()
    local raidInfoDisplay = GetRaidInfoDisplay()
    
    addon.mainFrame.showJson = true
    addon.mainFrame.editBox:SetText(raidInfoJson)
    addon.mainFrame.toggleButton:SetText("显示列表")
    
    addon.mainFrame:Show()
end

SLASH_WOWRAIDTOOLKITS1 = "/wrt"
SLASH_WOWRAIDTOOLKITS2 = "/wowraidtoolkits"

SlashCmdList["WOWRAIDTOOLKITS"] = function(msg)
    if msg == "" or msg == "show" then
        ShowRaidInfo()
    elseif msg == "hide" then
        if addon.mainFrame then
            addon.mainFrame:Hide()
        end
    end
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and (...) == addonName then
        print("|cff00ff00[WowRaidToolkits]|r 插件已加载! 输入 |cff00ff00/wrt|r 来显示团队信息")
    end
end)
