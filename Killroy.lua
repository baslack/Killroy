-----------------------------------------------------------------------------------------------
-- Client Lua Script for Killroy
-- Open Source Licensing granted by Benjamin A. Slack, feel free to use, change or extend.
-----------------------------------------------------------------------------------------------
 
require "Apollo"
require "Window"
require "Unit"
require "Spell"
require "GameLib"
require "ChatSystemLib"
require "ChatChannelLib"
require "CombatFloater"
require "GroupLib"
require "FriendshipLib"
require "DatacubeLib"

-----------------------------------------------------------------------------------------------
-- Killroy Module Definition
-----------------------------------------------------------------------------------------------
local Killroy = {}
local GeminiColor
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local kcrInvalidColor = ApolloColor.new("InvalidChat")
local kcrValidColor = ApolloColor.new("white")

local kstrColorChatRegular 	= "ff7fffb9"
local kstrColorChatShout	= "ffd9eef7"
local kstrColorChatRoleplay = "ff58e3b0"
local kstrBubbleFont 		= "CRB_Dialog"
local kstrDialogFont 		= "CRB_Dialog"
local kstrDialogFontRP 		= "CRB_Dialog_I"

local kstrGMIcon 		= "Icon_Windows_UI_GMIcon"
local knChannelListHeight = 500

local knSaveVersion = 2

local karEvalColors =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "ItemQuality_Inferior",
	[Item.CodeEnumItemQuality.Average] 			= "ItemQuality_Average",
	[Item.CodeEnumItemQuality.Good] 			= "ItemQuality_Good",
	[Item.CodeEnumItemQuality.Excellent] 		= "ItemQuality_Excellent",
	[Item.CodeEnumItemQuality.Superb] 			= "ItemQuality_Superb",
	[Item.CodeEnumItemQuality.Legendary] 		= "ItemQuality_Legendary",
	[Item.CodeEnumItemQuality.Artifact]		 	= "ItemQuality_Artifact",
}

local karChannelTypeToColor = -- TODO Merge into one table like this
{
	[ChatSystemLib.ChatChannel_Command] 		= { Channel = "ChannelCommand", 		},
	[ChatSystemLib.ChatChannel_System] 			= { Channel = "ChannelSystem", 			},
	[ChatSystemLib.ChatChannel_Debug] 			= { Channel = "ChannelDebug", 			},
	[ChatSystemLib.ChatChannel_Say] 			= { Channel = "ChannelSay", 			},
	[ChatSystemLib.ChatChannel_Yell] 			= { Channel = "ChannelShout", 			},
	[ChatSystemLib.ChatChannel_Whisper] 		= { Channel = "ChannelWhisper", 		},
	[ChatSystemLib.ChatChannel_Party] 			= { Channel = "ChannelParty", 			},
	[ChatSystemLib.ChatChannel_Emote] 			= { Channel = "ChannelEmote", 			},
	[ChatSystemLib.ChatChannel_AnimatedEmote] 	= { Channel = "ChannelEmote", 			},
	[ChatSystemLib.ChatChannel_Zone] 			= { Channel = "ChannelZone", 			},
	[ChatSystemLib.ChatChannel_ZonePvP] 		= { Channel = "ChannelPvP", 			},
	[ChatSystemLib.ChatChannel_Trade] 			= { Channel = "ChannelTrade",			},
	[ChatSystemLib.ChatChannel_Guild] 			= { Channel = "ChannelGuild", 			},
	[ChatSystemLib.ChatChannel_GuildOfficer] 	= { Channel = "ChannelGuildOfficer",	},
	[ChatSystemLib.ChatChannel_Society] 		= { Channel = "ChannelCircle2",			},
	[ChatSystemLib.ChatChannel_Custom] 			= { Channel = "ChannelCustom", 			},
	[ChatSystemLib.ChatChannel_NPCSay] 			= { Channel = "ChannelNPC", 			},
	[ChatSystemLib.ChatChannel_NPCYell] 		= { Channel = "ChannelNPC",		 		},
	[ChatSystemLib.ChatChannel_NPCWhisper]		= { Channel = "ChannelNPC", 			},
	[ChatSystemLib.ChatChannel_Datachron] 		= { Channel = "ChannelNPC", 			},
	[ChatSystemLib.ChatChannel_Combat] 			= { Channel = "ChannelGeneral", 		},
	[ChatSystemLib.ChatChannel_Realm] 			= { Channel = "ChannelSupport", 		},
	[ChatSystemLib.ChatChannel_Loot] 			= { Channel = "ChannelLoot", 			},
	[ChatSystemLib.ChatChannel_PlayerPath] 		= { Channel = "ChannelGeneral", 		},
	[ChatSystemLib.ChatChannel_Instance] 		= { Channel = "ChannelParty", 			},
	[ChatSystemLib.ChatChannel_WarParty] 		= { Channel = "ChannelWarParty",		},
	[ChatSystemLib.ChatChannel_WarPartyOfficer] = { Channel = "ChannelWarPartyOfficer", },
	[ChatSystemLib.ChatChannel_Advice] 			= { Channel = "ChannelAdvice", 			},
	[ChatSystemLib.ChatChannel_AccountWhisper] 	= { Channel = "ChannelAccountWisper", 	},
}

local ktDefaultHolds = {}
ktDefaultHolds[ChatSystemLib.ChatChannel_Whisper] = true

local tagEmo = 1
local tagSay = 2
local tagOOC = 3

local knDefaultSayRange = 30
local knDefaultEmoteRange = 60
local knDefaultFalloff = 5
local ksDefaultEmoteColor = 'ffff9900'
local ksDefaultSayColor = 'ffffffff'
local ksDefaultOOCColor = 'ff7fffb9'

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Killroy:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	if not(self.tPrefs) then
		self.tPrefs = 
		{
			bCrossFaction = true,
			bRPOnly = true,
			bFormatChat = true,
			bRangeFilter = true,
			bCustomChatColors = true,
			nSayRange = knDefaultSayRange,
			nEmoteRange = knDefaultEmoteRange,
			nFalloff = knDefaultFalloff,
			bUseOcclusion = true,
			kstrEmoteColor = ksDefaultEmoteColor,
			kstrSayColor = ksDefaultSayColor,
			kstrOOCColor 	= ksDefaultOOCColor,
			sVersion = "1-3-7"
		}
		self.tColorBuffer = 
		{
			kstrEmoteColor = ksDefaultEmoteColor,
			kstrSayColor = ksDefaultSayColor,
			kstrOOCColor 	= ksDefaultOOCColor,
		}
		self.tRFBuffer = {
			nSayRange = knDefaultSayRange,
			nEmoteRange = knDefaultEmoteRange,
			nFalloff = knDefaultFalloff,
		}
		self.arChatColor = {}
	else
		self.tColorBuffer = 
		{
			kstrEmoteColor = self.tPrefs['kstrEmoteColor'],
			kstrSayColor = self.tPrefs['kstrSayColor'],
			kstrOOCColor 	= self.tPrefs['kstrOOCColor'],
		}
		self.tRFBuffer =
		{
			nSayRange = self.tPrefs['nSayRange'],
			nEmoteRange = self.tPrefs['nEmoteRange'],
			nFalloff = self.tPrefs['nFalloff'],
		}
	end
	
	self.bReloadUIRequired = false
	self.bSkipAnimatedEmote = false

    return o
end

function Killroy:Init()
	local bHasConfigureFunction = true
	local strConfigureButtonText = "Killroy"
	local tDependencies = {
	"ChatLog",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Killroy OnLoad
-----------------------------------------------------------------------------------------------
function Killroy:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Killroy.xml")
	self.xmlDoc:RegisterCallback("OnDocumentLoaded", self)
	Apollo.LoadSprites("KIL.xml", "KIL")
end

function Killroy:OnDocumentLoaded()
	GeminiColor = Apollo.GetPackage("GeminiColor").tPackage
	
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "KillroyForm", nil, self)
	self.wndMain:Show(false, true)

	--register commands and actions
	Apollo.RegisterSlashCommand("killroy", "OnKillroyOn", self)
	Apollo.RegisterSlashCommand("klabout", "KillroyAbout", self)
	Apollo.RegisterEventHandler('OnSetEmoteColor', OnSetEmoteColor, self)
	Apollo.RegisterEventHandler('OnSetSayColor', OnSetSayColor, self)
	Apollo.RegisterEventHandler('OnSetOOCColor', OnSetOOCColor, self)
	
	-- replace ChatLogFunctions
	self:Change_HelperGenerateChatMessage()
	self:Change_OnChatInputReturn()
	self:Change_OnRoleplayBtn()
	self:Change_OnChatMessage()
	self:Change_VerifyChannelVisibility()

	--self:Change_ActionBarFrame_OnMountBtn()
	--self:RestoreMountSetting()
	if self.tPrefs["bCustomChatColors"] then
		self:Change_AddChannelTypeToList()
		self:Append_OnChannelColorBtn()
		self:Change_OnViewCheck()
		self:Change_NewChatWindow()
		self:Change_OnInputChanged()
		self:Change_OnInputMenuEntry()
		self:Change_BuildInputTypeMenu()
		self:Change_HelperRemoveChannelFromInputWindow()
		self:Change_HelperFindAViewedChannel()
		self:Change_OnSettings()
		self.arChatColorTimer = ApolloTimer.Create(2, true, "arChatColor_Check", self)
	end
end
-----------------------------------------------------------------------------------------------
-- Killroy Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function Killroy:arChatColor_Check()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	if ChatLog.arChatColor[ChatSystemLib.ChatChannel_AccountWhisper] then
		self:Restore_arChatColor()
		self.arChatColorTimer:Stop()
	end
end

function Killroy:OnConfigure()
	self.wndMain:FindChild('bCrossFaction'):SetCheck(not(self.tPrefs['bCrossFaction']))
	self.wndMain:FindChild('bRPOnly'):SetCheck(not(self.tPrefs['bRPOnly']))
	self.wndMain:FindChild('bFormatChat'):SetCheck(not(self.tPrefs['bFormatChat']))
	self.wndMain:FindChild('bRangeFilter'):SetCheck(not(self.tPrefs['bRangeFilter']))
	self.wndMain:FindChild('bUseOcclusion'):SetCheck(not(self.tPrefs['bUseOcclusion']))
	self.wndMain:FindChild('bCustomChatColors'):SetCheck(not(self.tPrefs['bCustomChatColors']))
	self.wndMain:FindChild('setEmoteColor'):SetNormalTextColor(self.tPrefs['kstrEmoteColor'])
	self.wndMain:FindChild('setSayColor'):SetNormalTextColor(self.tPrefs['kstrSayColor'])
	self.wndMain:FindChild('setOOCColor'):SetNormalTextColor(self.tPrefs['kstrOOCColor'])
	self.wndMain:FindChild('nSayRange'):SetValue(self.tPrefs['nSayRange'])
	self.tRFBuffer['nSayRange'] = self.tPrefs['nSayRange']
	self.wndMain:FindChild('nEmoteRange'):SetValue(self.tPrefs['nEmoteRange'])
	self.tRFBuffer['nEmoteRange'] = self.tPrefs['nEmoteRange']
	self.wndMain:FindChild('nFalloff'):SetValue(self.tPrefs['nFalloff'])
	self.tRFBuffer['nFalloff'] = self.tPrefs['nFalloff']
	self.wndMain:Show(true)
end

function Killroy:OnKillroyOn()
	self:OnConfigure()
end

function Killroy:GetPreferences()
	return self.tPrefs
end

function Killroy:OnSave(eLevel)
	if (eLevel == GameLib.CodeEnumAddonSaveLevel.Account) then
		return {tPrefs = self.tPrefs,}
	elseif (eLevel == GameLib.CodeEnumAddonSaveLevel.Character) then
		return {arChatColor = self.arChatColor}
	else
		return nil
	end
end

function Killroy:OnRestore(eLevel, tData)
	--Killroy's Prefs
	if (tData.tPrefs ~= nil) then
		for i,v in pairs(tData.tPrefs) do
			self.tPrefs[i] = v
		end
	end
	if (tData.arChatColor ~= nil) then
		for i,v in pairs(tData.arChatColor) do
			self.arChatColor[i] = v
		end
	end
end

----------------------------
--Killroy Specific Functions
----------------------------

function Killroy:GetChannelByName(sName)
	bNotFound = false
	for i, this_chan in ipairs(ChatSystemLib.GetChannels()) do
		if this_chan:GetName() == sName then return this_chan end
	end
	if bNotFound then return nil end
end
	
function Killroy:KillroyAbout()
	local SystemChannel = self:GetChannelByName("System")
	SystemChannel:Post(string.format("Killroy Version: %s", self.tPrefs["sVersion"]))
end

function Killroy:ParseForAnimatedEmote(strText)
	local strTextClean
	local strEmbeddedEmote
	
	--capture the emote
	local strEmbeddedEmote = string.match(strText, "[{](.*)[}]")
	local bValidEmote = false
	
	--check for valid emote
	for idx, this_emote in ipairs(ChatSystemLib.GetEmotes()) do
		if this_emote == strEmbeddedEmote then bValidEmote = true end
	end
	
	--cleanup
	if bValidEmote then
		strTextClean = string.gsub (strText, "%s*%b{}", "")
	else
		strTextClean = strText
	end
	
	--dump a table to return
	local tDump = {}
	tDump["strTextClean"] = strTextClean
	if bValidEmote then
		tDump["strEmbeddedEmote"] = "/"..strEmbeddedEmote
		self.bSkipAnimatedEmote = true
	else
		tDump["strEmbeddedEmote"] = nil
	end
	
	return tDump
end

function Killroy:ParseForTarget(strText)
	if GameLib.GetTargetUnit() ~=  nil then
		return string.gsub (strText, "%%t", GameLib.GetTargetUnit():GetName())
	else
		return strText
	end
end

function Killroy:ParseForContext(strText, eChannelType)
	-- search for asterik emotes
	-- search for quotes
	-- search for OOC '((<verbage>))'
	-- color remainder with channel color
	
	function tagByChan()
		if eChannelType == ChatSystemLib.ChatChannel_Say then
			return tagSay
		elseif eChannelType == ChatSystemLib.ChatChannel_Emote then
			return tagEmo
		else
			return nil
		end
	end
	
	local parsedText = {}
		
	emotes = {}
	quotes = {}
	oocs = {}
	
	index = 1
	for emote in strText:gmatch('%b**') do
		first, last = strText:find(emote, index, true)
		emotes[first] = last
		index = last + 1
	end
	
	index = 1
	for quote in strText:gmatch('%b""') do
		first, last = strText:find(quote, index, true)
		quotes[first] = last
		index = last + 1
	end
	
	index = 1
	for ooc in strText:gmatch('%(%(.*%)%)') do
		first, last = strText:find(ooc, index, true)
		oocs[first] = last
		index = last + 1
	end
	
	buffer = ''
	index = 1
	
	while index <= strText:len() do
		if oocs[index] then
			if buffer then
				table.insert(parsedText, {buffer, tagByChan()})
				buffer = ''
			end
			table.insert(parsedText, {strText:sub(index, oocs[index]), tagOOC})
			index = oocs[index] + 1
		elseif emotes[index] then
			if buffer then
				table.insert(parsedText, {buffer, tagByChan()})
				buffer = ''
			end
			table.insert(parsedText, {strText:sub(index, emotes[index]), tagEmo})
			index = emotes[index] + 1
		elseif quotes[index] then
			if buffer then
				table.insert(parsedText, {buffer, tagByChan()})
				buffer = ''
			end
			table.insert(parsedText, {strText:sub(index, quotes[index]), tagSay})
			index = quotes[index] + 1
		else
			buffer = buffer .. strText:sub(index, index)
			index = index + 1
		end
	end
	
	if buffer ~= '' then
		table.insert(parsedText, {buffer, tagByChan()})
	end

	return parsedText
	
end

function Killroy:DumpToChat(parsedText, strChatFont, xml)
	for i,t in ipairs(parsedText) do
		if t[2] == tagEmo then
			xml:AppendText(t[1], self.tPrefs['kstrEmoteColor'], strChatFont)
		elseif t[2] == tagSay then
			xml:AppendText(t[1], self.tPrefs['kstrSayColor'], strChatFont)
		elseif t[2] == tagOOC then
			xml:AppendText(t[1], self.tPrefs['kstrOOCColor'], strChatFont)
		end
	end
	return true
end

-- TB's contribution to the range filter code, edits by bs:061914

function Killroy:Distance(unitTarget)
    local unitPlayer = GameLib.GetPlayerUnit()
    if type(unitTarget) == "string" then
        unitTarget = GameLib.GetPlayerUnitByName(unitTarget)
    end

    if not unitTarget or not unitPlayer then
        return 0
    end

    tPosTarget = unitTarget:GetPosition()
    tPosPlayer = unitPlayer:GetPosition()

    if tPosTarget == nil or tPosPlayer == nil then
        return 0
    end

    local nDeltaX = tPosTarget.x - tPosPlayer.x
    local nDeltaY = tPosTarget.y - tPosPlayer.y
    local nDeltaZ = tPosTarget.z - tPosPlayer.z

    local nDistance = math.floor(math.sqrt((nDeltaX ^ 2) + (nDeltaY ^ 2) + (nDeltaZ ^ 2)))

	return nDistance
end

function Killroy:Garble(sMessage, nMin, nRange, nMax)
	local nGarbleQuotient = (nRange-nMin)/(nMax-nMin)
	local nCount = 0
	local tWordStack = {}
	for word in string.gmatch(sMessage, "[^%s]+") do
		nCount = nCount + 1
		tWordStack[nCount] = word
	end
	local nGarbleTries = math.floor(nCount * nGarbleQuotient)
	local sGarble = "..."
	for nTry = 1, nGarbleTries, 1 do
		local idx = math.random(nCount)
		tWordStack[idx] = sGarble
	end
	local sReturn = ""
	for nIdx = 1, nCount, 1 do
		sReturn = sReturn .. tWordStack[nIdx]
		if nIdx ~= nCount then
			sReturn = sReturn .. " "
		end 
	end
	return sReturn
end

function Killroy:Myoptic()
	local tResponses = {
						"does something, but you can't make it out from here.",
						"waves? You think they waved.",
						"might have just flipped you off, but you couldn't really see from here.",
						"is too far away to see exactly what they're up to.",
						"appears to be talking animatedly, but you make out a word of it.",
						"apparently has something on their mind. Maybe you should go see what?",
						"looks like they want something. Maybe you should investigate?",
						"says something, but you can't overhear it.",
						"has an incredibly huge butt... wait, did you hear that right?",
						"is just to far away to make out.",
						}
						
	return tResponses[math.random(10)]
end
						

function Killroy:RangeFilter(sMessage, sSender, eChannelType)
	--[[
	I. Context, does the messsage contain the player's name?
		A. if so, half the range
	II. Occlusion, doesn't stop sound, stops sight
		A. if channel is "say", then double range if occluded
		B. if channel is emote or animated emote, cull message
	III. check range
		A. if greater than range + falloff, cut off message
		B. if between range and fallor, garble message
		C. if less than or equal to range show message
	]]--
	
	if not sMessage then
		return nil
	end
	
	local nRange = self:Distance(sSender)
	
	local bEnableDebug = false
	if bEnableDebug then
		if sSender == GameLib.GetPlayerUnit():GetName() then nRange = self.tPrefs['nSayRange'] + 6 end
	end
	
	local sPlayer = GameLib.GetPlayerUnit():GetName()
	local bContext = false
	for word in string.gmatch(sMessage, "%g+") do
		if word == sPlayer then
			bContext = true
		end
	end
	if bContext then nRange = nRange / 2 end
	
	if self.tPrefs["bUseOcclusion"] then
		if GameLib.GetPlayerUnitByName(sSender) then
			if GameLib.GetPlayerUnitByName(sSender):IsOccluded() then
				if eChannelType == ChatSystemLib.ChatChannel_Say then
					nRange = nRange * 2
				elseif eChannelType == ChatSystemLib.ChatChannel_Emote then
					return nil
				elseif eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote then
					return nil
				end
			end
		end
	end
	
	local nMaxRange = 0
	local nMinRange = 0
	
	if eChannelType == ChatSystemLib.ChatChannel_Say then
		nMaxRange = self.tPrefs["nSayRange"] + self.tPrefs["nFalloff"]
		nMinRange = self.tPrefs["nSayRange"]
	end
	if (eChannelType == ChatSystemLib.ChatChannel_Emote) or (eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote) then
		nMaxRange = self.tPrefs["nEmoteRange"] + self.tPrefs["nFalloff"]
		nMinRange = self.tPrefs["nEmoteRange"]
	end
	
	if (nRange > nMaxRange) then return nil
	elseif (nMaxRange >= nRange) and (nRange > nMinRange) then
		if eChannelType == ChatSystemLib.ChatChannel_Say then
			return self:Garble(sMessage, nMinRange, nRange, nMaxRange)
		elseif eChannelType == ChatSystemLib.ChatChannel_Emote or eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote then
			return self.Myoptic()
		end
	elseif nMinRange >= nRange then
		return sMessage
	end
end

function Killroy:RestoreMountSetting()
	if self.tPrefs["nSelectedMount"] then
		ActionBarFrame = Apollo.GetAddon("ActionBarFrame")
		if not(ActionBarFrame) then return nil end
		
		if self.tPrefs["nSelectedMount"] then
			ActionBarFrame.nSelectedMount = self.tPrefs["nSelectedMount"]
			ActionBarFrame:RedrawSelectedMounts()
		end 
	end
end

function Killroy:Restore_arChatColor()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then 
		return nil 
	end
	
	if next(self.arChatColor) ~= nil then
		for idx, this_channel in ipairs(ChatSystemLib.GetChannels()) do
			local nCludge = self:ChannelCludge(this_channel:GetName(),this_channel:GetType())
			if self.arChatColor[nCludge] then
				ChatLog.arChatColor[nCludge] = ApolloColor.new(self.arChatColor[nCludge])
			end
		end	
	end
	
end

function Killroy:ChannelCludge(sName,nType)
	local knFudgeCustom = 40
	local knFudgeCircle = 50
	local nCludge = 0
	
	--Print(sName)
	--Print(sName.."|"..tostring(nType))
	
	for idx, this_chan in ipairs(ChatSystemLib.GetChannels()) do
		--Print(this_chan:GetName())
	end
	
	if nType == ChatSystemLib.ChatChannel_Custom then
		local chan = ChatSystemLib.GetChannels()
		for idx, this_chan in ipairs(chan) do
			if this_chan:GetName() == sName then nCludge = idx + knFudgeCustom end
		end
		return nCludge
	elseif nType == ChatSystemLib.ChatChannel_Society then
		local chan = ChatSystemLib.GetChannels()
		for idx, this_chan in ipairs(chan) do
			if this_chan:GetName() == sName then nCludge = idx + knFudgeCircle end
		end
		return nCludge
	else
		return nType
	end
end

function Killroy:Quantize(nFloat)
	if nFloat < 0 then 
		return 0
	elseif nFloat > 1 then 
		return 255
	else 
		return math.ceil(255*nFloat)
	end
end

function Killroy:toHex(tColor)
	local a = self:Quantize(tColor["a"])
	local r = self:Quantize(tColor["r"])
	local g = self:Quantize(tColor["g"])
	local b = self:Quantize(tColor["b"])
	return string.format("%02x%02x%02x%02x",a,r,g,b)
end

--------------------------------------------------------
-- Killroy Change Methods, these replace ChatLog methods
--------------------------------------------------------

--[[

check color calls in:

NewChatWindow -done
OnChatInputReturn -done
OnInputChanged -done
BuildInputTypeMenu -done
OnInputMenuEntry -done
HelperGenerateChatMessage -done
HelperRemoveChannelFromInputWindow -done

]]--

function Killroy:Change_OnSettings()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end

	function ChatLog:OnSettings(wndHandler, wndControl)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		
		local wndForm = wndControl:GetParent()
		local tData = wndForm:GetData()
	
		if wndForm:FindChild("BGArt_ChatBackerIcon"):IsShown() then
			self:OnSettingsCombat(wndForm:FindChild("Options"), wndForm:FindChild("Options"))
			return
		end
	
		if not wndControl:IsChecked() then
			tData.wndOptions:Show(false)
			wndForm:FindChild("Input"):Show(true)
		else
			if wndForm:FindChild("EmoteMenu"):IsVisible() then
				wndForm:FindChild("EmoteMenu"):Show(false)
				wndForm:FindChild("EmoteBtn"):SetCheck(false)
			end
	
			if wndForm:FindChild("InputWindow"):IsVisible() then
				wndForm:FindChild("InputWindow"):Show(false)
				wndForm:FindChild("InputTypeBtn"):SetCheck(false)
			end
	
			self:DrawSettings(wndForm)
		end
		
		for idx, this_channel in ipairs(ChatSystemLib.GetChannels()) do
			nCludge = Killroy:ChannelCludge(this_channel:GetName(), this_channel:GetType())
			Killroy.arChatColor[nCludge] = Killroy:toHex(self.arChatColor[nCludge]:ToTable())
		end
			
	end

end

function Killroy:Change_HelperFindAViewedChannel()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:HelperFindAViewedChannel()
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
			
		local channelNew = nil
		local nNewChannelIdx = nil
		local tBaseChannels = ChatSystemLib.GetChannels()
		local tChannelsWithInput = {}
	
		for idx, channelCurrent in pairs(tBaseChannels) do
			local nCludge = Killroy:ChannelCludge(channelCurrent:GetName(),channelCurrent:GetType())
			if channelCurrent:GetCommand() ~= nil and channelCurrent:GetCommand() ~= "" then
				-- tChannelsWithInput[channelCurrent:GetType()] = true
				tChannelsWithInput[nCludge] = true
			end
		end
	
		for idx, channelCurrent in pairs(self.tAllViewedChannels) do
			if self.tAllViewedChannels[idx] ~= nil and tChannelsWithInput[idx] ~= nil then
				nNewChannelIdx = idx
				break
			end
		end
	
		if nNewChannelIdx == nil then
			nNewChannelIdx = ChatSystemLib.ChatChannel_Say
		end
	
		for idx, channelCurrent in ipairs(tBaseChannels) do
			local nCludge = Killroy:ChannelCludge(channelCurrent:GetName(),channelCurrent:GetType())
			--if channelCurrent:GetType() == nNewChannelIdx then
			if nCludge == nNewChannelIdx then
				channelNew = channelCurrent
				break
			end
		end
	
		return channelNew
	end
	
end

function Killroy:Change_HelperRemoveChannelFromInputWindow()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:HelperRemoveChannelFromInputWindow(channelRemoved) -- used when we've totally removed a channel
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		
		for idx, wnd in pairs(self.tChatWindows) do
			local tChatData = wnd:GetData()
			local nCludge = Killroy:ChannelCludge(tChatData.channelCurrent:GetName(),tChatData.channelCurrent:GetType())
			--if tChatData.channelCurrent:GetType() == channelRemoved then
			if nCludge == channelRemoved then
			
				local channelNew = self:HelperFindAViewedChannel()
				local wndInputType = wnd:FindChild("InputType")
	
				if channelNew ~= nil then
					tChatData.channelCurrent = channelNew
					wndInputType:SetText(tChatData.channelCurrent:GetCommand())
					--tChatData.crText = self.arChatColor[tChatData.channelCurrent:GetType()]
					tChatData.crText = self.arChatColor[nCludge]

					wndInputType:SetTextColor(tChatData.crText)
	
					--TODO: Helper this since we do it other places
					local wndInput = wnd:FindChild("Input")
					local strText = wndInput:GetText()
					local strCommand = tChatData.channelCurrent:GetAbbreviation()
	
					if strCommand == "" or strCommand == nil then
						strCommand = tChatData.channelCurrent:GetCommand()
					end
	
					if strText == "" then
						strText =String_GetWeaselString(Apollo.GetString("ChatLog_SlashPrefix"),  strCommand)
					else
						local tInput = ChatSystemLib.SplitInput(strText) -- get the existing message, ignore the old command
						strText = String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), strCommand, tInput.strMessage)
					end
	
					wndInput:SetText(strText)
					--local crText = self.arChatColor[tChatData.channelCurrent:GetType()] or ApolloColor.new("white")
					local crText = self.arChatColor[nCludge] or ApolloColor.new("white")
					wndInput:SetTextColor(crText)
					wndInput:SetFocus()
					wndInput:SetSel(strText:len(), -1)
	
				else
					wndInputType:SetText("X")
					wndInputType:SetTextColor(kcrInvalidColor)
				end
			end
		end
	end

end

function Killroy:Change_OnInputMenuEntry()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:OnInputMenuEntry(wndHandler, wndControl)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
	
		local channelCurrent = wndControl:GetData()
		local wndChat = wndControl:GetParent():GetParent():GetParent()
		local tChatData = wndChat:GetData()
		local wndInput = wndChat:FindChild("Input")
		local strText = wndInput:GetText()
		local strCommand = channelCurrent:GetAbbreviation()
	
		if strCommand == "" or strCommand == nil then
			strCommand = channelCurrent:GetCommand()
		end
	
		if strText == "" then
			strText = String_GetWeaselString(Apollo.GetString("ChatLog_SlashPrefix"), strCommand)
		else
			local tInput = ChatSystemLib.SplitInput(strText) -- get the existing message, ignore the old command
			strText = String_GetWeaselString(Apollo.GetString("ChatLog_SlashPrefix"), strCommand, tInput.strMessage)
		end
	
		wndInput:SetText(strText)
		--local crText = self.arChatColor[channelCurrent:GetType()] or ApolloColor.new("white")
		local crText = self.arChatColor[Killroy:ChannelCludge(channelCurrent:GetName(),channelCurrent:GetType())] or ApolloColor.new("white")
		local wndInputType = wndChat:FindChild("InputType")
		wndInput:SetTextColor(crText)
		wndInputType:SetText(channelCurrent:GetCommand())
		wndInputType:SetTextColor(crText)
		wndInputType:Show(string.len(strText) == 0)
	
		wndInput:SetFocus()
		wndInput:SetSel(strText:len(), -1)
	
		tChatData.channelCurrent = channelCurrent
	
		wndControl:GetParent():GetParent():Show(false)
		wndChat:FindChild("InputTypeBtn"):SetCheck(false)
	end

end

function Killroy:Change_BuildInputTypeMenu()

	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:BuildInputTypeMenu(wndChat) -- setting this up externally so we can remove it from toggle at some point
		--local wndChannel = wndControl:GetParent()
		--local wndOptions = wndChat:GetParent():GetParent():GetParent()
		--local channelType = wndChannel:GetData()
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		
		local tData = wndChat:GetData()
	
		if tData == nil then
			return
		end
	
		local wndInputMenu = wndChat:FindChild("InputWindow")
		local wndContent = wndInputMenu:FindChild("InputMenuContent")
		wndContent:DestroyChildren()
	
		local tChannels = ChatSystemLib.GetChannels()
		local nEntryHeight = 26 --height of the entry wnd
		local nCount = 0 --number of joined channels
	
		for idx, channelCurrent in pairs(tChannels) do -- gives us our viewed channels
			--if tData.tViewedChannels[ channelCurrent:GetType() ] ~= nil then
			--bs070414, Cludge abbr.
			local nCludge = Killroy:ChannelCludge(channelCurrent:GetName(),channelCurrent:GetType())
			--if self.tAllViewedChannels[ channelCurrent:GetType() ] ~= nil then, disabled bs070414
			if self.tAllViewedChannels[nCludge] ~= nil then
				if channelCurrent:GetCommand() ~= nil and channelCurrent:GetCommand() ~= "" then -- make sure it's a channelCurrent that can be spoken into
					local strCommand = channelCurrent:GetAbbreviation()
	
					if strCommand == "" or strCommand == nil then
						strCommand = channelCurrent:GetCommand()
					end
	
					local wndEntry = Apollo.LoadForm(self.xmlDoc, "InputMenuEntry", wndContent, self)
	
					local strType = ""
					if channelCurrent:GetType() == ChatSystemLib.ChatChannel_Custom then
						strType = Apollo.GetString("ChatLog_CustomLabel")
					end
	
					wndEntry:FindChild("NameText"):SetText(channelCurrent:GetName())
					wndEntry:FindChild("CommandText"):SetText(String_GetWeaselString(Apollo.GetString("ChatLog_SlashPrefix"), strCommand))
					wndEntry:SetData(channelCurrent) -- set the channelCurrent
	
					--local crText = self.arChatColor[channelCurrent:GetType()] or ApolloColor.new("white")
					local crText = self.arChatColor[nCludge] or ApolloColor.new("white")
					wndEntry:FindChild("CommandText"):SetTextColor(crText)
					wndEntry:FindChild("NameText"):SetTextColor(crText)
	
					nCount = nCount + 1
				end
			end
		end
	
		if nCount == 0 then
			local wndEntry = Apollo.LoadForm(self.xmlDoc, "InputMenuEntry", wndContent, self)
			wndEntry:Enable(false)
			wndEntry:FindChild("NameText"):SetText(Apollo.GetString("CRB_No_Channels_Visible"))
			nCount = 1
		end
	
		nEntryHeight = nEntryHeight * nCount
		wndInputMenu:SetAnchorOffsets(self.nInputMenuLeft, math.max(-knChannelListHeight , self.nInputMenuTop - nEntryHeight), self.nInputMenuRight, self.nInputMenuBottom)
	
		wndContent:ArrangeChildrenVert()
	end


end

function Killroy:Change_OnInputChanged()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:OnInputChanged(wndHandler, wndControl, strText)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		
		local wndForm = wndControl:GetParent()
	
		if wndControl:GetName() ~= "Input" then
			return
		end
	
		for idx, wndChat in pairs(self.tChatWindows) do
			wndChat:FindChild("Input"):SetData(false)
		end
		wndControl:SetData(true)
	
		local wndForm = wndControl:GetParent()
		local wndInputType = wndForm:FindChild("InputType")
		local wndInput = wndForm:FindChild("Input")
		wndInputType:Show(string.len(strText) == 0) -- Hide background say once a message has been typed
	
		if strText == Apollo.GetString("ChatLog_Reply") and self.tLastWhisperer and self.tLastWhisperer.strCharacterName ~= "" then
			local strName = self.tLastWhisperer.strCharacterName
			local channel = self.channelWhisper
			if self.tLastWhisperer.eChannelType == ChatSystemLib.ChatChannel_AccountWhisper then
				channel = self.channelAccountWhisper
	
				self.tAccountWhisperContex =
				{
					["strDisplayName"]		= self.tLastWhisperer.strDisplayName,
					["strCharacterName"]	= self.tLastWhisperer.strCharacterName,
					["strRealmName"]		= self.tLastWhisperer.strRealmName,
				}
				strName = self.tLastWhisperer.strDisplayName
			end
	
			local strWhisper = String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), channel:GetAbbreviation(), strName)
	
			wndInputType:SetText(channel:GetCommand())
			wndInputType:SetTextColor(self.arChatColor[self.tLastWhisperer.eChannelType])
			wndInput:SetTextColor(self.arChatColor[self.tLastWhisperer.eChannelType])
			wndInput:SetText(strWhisper)
			wndInput:SetFocus()
			wndInput:SetSel(strWhisper:len(), -1)
			return
		end
	
		local tChatData = wndForm:GetData()
		local tInput = ChatSystemLib.SplitInput(strText)
		local channelInput = tInput.channelCommand or tChatData.channelCurrent
		-- bs070414, nCludge abbr.
		local nCludge = Killroy:ChannelCludge(channelInput:GetName(),channelInput:GetType())
		--local crText = self.arChatColor[channelInput:GetType()] or ApolloColor.new("white")
		local crText = self.arChatColor[nCludge] or ApolloColor.new("white")
		wndInputType:SetTextColor(crText)
		wndInput:SetTextColor(crText)
	
		if channelInput:GetType() == ChatSystemLib.ChatChannel_Command then -- command or emote
			if tInput.bValidCommand then
				wndInputType:SetText(String_GetWeaselString(Apollo.GetString("CRB_CurlyBrackets"), "", tInput.strCommand))
				wndInput:SetTextColor(kcrValidColor)
				wndInputType:SetTextColor(kcrValidColor)
			else
				wndInputType:SetText("X")
				wndInputType:SetTextColor(kcrInvalidColor)
			end
		else -- chatting in a channel; check for visibility
			--if tChatData.tViewedChannels[ channel:GetType() ] ~= nil then -- channel is viewed, Carbine
			--if self.tAllViewedChannels[ channelInput:GetType() ] ~= nil then -- channel is viewed, bs070414
			if self.tAllViewedChannels[nCludge] ~= nil then -- channel is viewed
				wndInputType:SetText(channelInput:GetCommand())
			else -- channel is hidden
				wndInputType:SetText(String_GetWeaselString(Apollo.GetString("ChatLog_Invalid"), channelInput:GetCommand()))
				wndInputType:SetTextColor(kcrInvalidColor)
			end
		end
	end

end	

function Killroy:Change_NewChatWindow()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end

	function ChatLog:NewChatWindow(strTitle, tViewedChannels, tHeldChannels, bCombatLog, channelCurrent)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end	
	
		local wndChatWindow = Apollo.LoadForm(self.xmlDoc, "ChatWindow", "FixedHudStratum", self)
		Event_FireGenericEvent("WindowManagementAdd", {wnd = wndChatWindow, strName = strTitle})
	
		wndChatWindow:SetSizingMinimum(240, 240)
		wndChatWindow:SetStyle("AutoFadeNC", self.bEnableBGFade)
		wndChatWindow:SetStyle("AutoFadeBG", self.bEnableBGFade)
		wndChatWindow:FindChild("BGArt"):SetBGColor(CColor.new(1.0, 1.0, 1.0, self.nBGOpacity))
		wndChatWindow:FindChild("BGArt_SidePanel"):SetBGColor(CColor.new(1.0, 1.0, 1.0, self.nBGOpacity))
		wndChatWindow:SetText(strTitle)
		wndChatWindow:Show(true)
		wndChatWindow:FindChild("MouseCatcher"):SetData({ wndChatWindow:FindChild("InputType"), wndChatWindow:FindChild("InputTypeBtnText") })
	
		--Store the initial input window size
		self.nInputMenuLeft, self.nInputMenuTop, self.nInputMenuRight, self.nInputMenuBottom = wndChatWindow:FindChild("InputWindow"):GetAnchorOffsets()
	
		local tChatData = {}
		tChatData.wndForm = wndChatWindow
		tChatData.tViewedChannels = {}
		tChatData.tHeldChannels = {}
	
		tChatData.tMessageQueue = Queue:new()
		tChatData.tChildren = Queue:new()
	
		local wndChatChild = wndChatWindow:FindChild("Chat")
		for idx = 1, self.nMaxChatLines do
			local wndChatLine = Apollo.LoadForm(self.xmlDoc, "ChatLine", wndChatChild, self)
			wndChatLine:SetData(idx)
			wndChatLine:Show(false)
			tChatData.tChildren:Push(wndChatLine)
		end
		tChatData.nNextIndex = self.nMaxChatLines + 1
	
		local tChannels = bCombatLog and self.tCombatChannels or tViewedChannels
		tChatData.wndForm:FindChild("BGArt_ChatBackerIcon"):Show(bCombatLog)
	
		for key, value in pairs(tChannels) do
			tChatData.tViewedChannels[key] = value
		end
	
		for key, value in pairs(tHeldChannels) do
			tChatData.tHeldChannels[key] = value
		end
	
		tChatData.bCombatLog = bCombatLog
		wndChatWindow:SetData(tChatData)
	
		if not bCombatLog then
			for key, value in pairs(tViewedChannels) do
				if value then
					self:HelperAddChannelToAll(key)
				end
			end
		end
	
		tChatData.channelCurrent = channelCurrent or self:HelperFindAViewedChannel()
	
		local wndInputType = wndChatWindow:FindChild("InputType")
		if tChatData.channelCurrent then
			--tChatData.crText = self.arChatColor[tChatData.channelCurrent:GetType()]
			tChatData.crText = self.arChatColor[Killroy:ChannelCludge(tChatData.channelCurrent:GetName(), tChatData.channelCurrent:GetType())]
			wndInputType:SetText(tChatData.channelCurrent:GetCommand())
			wndInputType:SetTextColor(tChatData.crText)
		else
			wndInputType:SetText("X")
			wndInputType:SetTextColor(kcrInvalidColor)
		end
	
		tChatData.wndOptions = tChatData.wndForm:FindChild("OptionsSubForm")
		tChatData.wndOptions:Show(false)
	
		if #self.tChatWindows >= 1 then
			wndChatWindow:FindChild("CloseBtn"):Show(true)
		else
			wndChatWindow:FindChild("CloseBtn"):Show(false)
		end
	
		table.insert(self.tChatWindows, wndChatWindow)
	
		local nWindowCount = #self.tChatWindows
		if not self.tChatWindows[1]:FindChild("CloseBtn"):IsShown() and nWindowCount > 1 then
			self.tChatWindows[1]:FindChild("CloseBtn"):Show(true)
		end
	
		return wndChatWindow
	end
	
end

function Killroy:Change_OnViewCheck()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:OnViewCheck(wndHandler, wndControl)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
			
		local bDebug = false
		
		local wndChannel = wndControl:GetParent()
		if bDebug then Print("wndChannel: "..tostring(wndChannel:GetName())) end
		
		local wndOptions = wndChannel:GetParent():GetParent():GetParent()
		if bDebug then Print("wndOptions: "..tostring(wndOptions:GetName())) end
		
		local channelType = wndChannel:GetData()
		if bDebug then Print("channelType: "..tostring(channelType)) end
		
		local tData = wndOptions:GetData()
		if bDebug then Print("tData: "..table.concat(tData)) end

		if tData == nil then
			return
		end

		if tData.tViewedChannels[channelType] then
			tData.tViewedChannels[channelType] = nil
			self:HelperRemoveChannelFromAll(channelType)
		else
			tData.tViewedChannels[channelType] = true
			self:HelperAddChannelToAll(channelType)
		end
	end
end

function Killroy:Change_VerifyChannelVisibility()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:VerifyChannelVisibility(channelChecking, tInput, wndChat)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		
		local tChatData = wndChat:GetData()
	
		--if tChatData.tViewedChannels[ channelChecking:GetType() ] ~= nil then
		--use cludge if custom colors enabled
		local nTestChannelType
		if Killroy.tPrefs["bCustomChatColors"] then
			nTestChannelType = self.tAllViewedChannels[ Killroy:ChannelCludge(channelChecking:GetName(), channelChecking:GetType()) ]
		else
			nTestChannelType = tChatData.tViewedChannels[ channelChecking:GetType() ]
		end
		
		if nTestChannelType ~= nil then -- see if this channelChecking is viewed
			local strMessage = tInput.strMessage
			
			--as previous, use cludge if
			local nCheckingType
			if Killroy.tPrefs["bCustomChatColors"] then
				nCheckingType = Killroy:ChannelCludge(channelChecking:GetName(),channelChecking:GetType())
			else
				nCheckingType = channelChecking:GetType()
			end
			
			if nCheckingType == ChatSystemLib.ChatChannel_AccountWhisper then
				if self.tAccountWhisperContex then
					local strCharacterAndRealm = self.tAccountWhisperContex.strCharacterName .. "@" .. self.tAccountWhisperContex.strRealmName
					strMessage = string.gsub(strMessage, self.tAccountWhisperContex.strDisplayName, strCharacterAndRealm, 1)
				end
			end
			
			-- filter for targets and embedded emotes before sending to channel
			local strTargetFiltered = Killroy:ParseForTarget(strMessage)
			local tEmoteFiltered = Killroy:ParseForAnimatedEmote(strTargetFiltered)
			strMessage = tEmoteFiltered["strTextClean"]
			local strEmbeddedEmote = tEmoteFiltered["strEmbeddedEmote"]
			
			channelChecking:Send(strMessage)
			
			if strEmbeddedEmote then
				local ComChan = Killroy:GetChannelByName("Command")
				ComChan:Send(strEmbeddedEmote)
			end
			
			return true
		else
			local wndInput = wndChat:FindChild("Input")
	
			strMessage = String_GetWeaselString(Apollo.GetString("CRB_Message_not_sent_you_are_not_viewing"), channelChecking:GetName())
			ChatSystemLib.PostOnChannel( ChatSystemLib.ChatChannel_Command, strMessage, "" )
			wndInput:SetText(String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), tInput.strCommand, tInput.strMessage))
			wndInput:SetFocus()
			local strSubmitted = wndInput:GetText()
			wndInput:SetSel(strSubmitted:len(), -1)
			return false
		end
	end
end

function Killroy:Change_AddChannelTypeToList()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:AddChannelTypeToList(tData, wndList, channel)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		--insert a cludge her for channel type 18, so that it gets spread out into multple ids in the chat log
		
		local nCludge = Killroy:ChannelCludge(channel:GetName(), channel:GetType())
		local wndChannelItem = Apollo.LoadForm(Killroy.xmlDoc, "ChatType", wndList, self)
		wndChannelItem:FindChild("TypeName"):SetText(channel:GetName())
		--wndChannelItem:SetData(channel:GetType())
		wndChannelItem:SetData(nCludge)
		--wndChannelItem:FindChild("ViewCheck"):SetCheck(tData.tViewedChannels[channel:GetType()] or false)
		wndChannelItem:FindChild("ViewCheck"):SetCheck(tData.tViewedChannels[nCludge] or false)
		--wndChannelItem:FindChild("HoldCheck"):SetCheck(tData.tHeldChannels[channel:GetType()] or false)
		wndChannelItem:FindChild("HoldCheck"):SetCheck(tData.tHeldChannels[nCludge] or false)
		
		local CCB = wndChannelItem:FindChild("ChannelColorBtn")
		if self.arChatColor[nCludge] then
			CCB:SetBGColor(self.arChatColor[nCludge])
		else
			CCB:SetBGColor(self.arChatColor[ChatSystemLib.ChatChannel_Custom])
			self.arChatColor[nCludge] = self.arChatColor[ChatSystemLib.ChatChannel_Custom]
		end
	end
end

function Killroy:Change_ActionBarFrame_OnMountBtn()

	ActionBarFrame = Apollo.GetAddon("ActionBarFrame")
	if not(ActionBarFrame) then return nil end
	
	function ActionBarFrame:OnMountBtn(wndHandler, wndControl)
		Killroy = Apollo.GetAddon("Killroy")
		if not(Killroy) then return nil end
		
		self.nSelectedMount = wndControl:GetData():GetId()
		Killroy.tPrefs["nSelectedMount"] = self.nSelectedMount
	
		self.wndMountFlyout:FindChild("MountPopoutFrame"):Show(false)
		self:RedrawSelectedMounts()
	end
end

function Killroy:Change_OnChatMessage()

	local ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end

	function ChatLog:OnChatMessage(channelCurrent, tMessage)
		-- tMessage has bAutoResponse, bGM, bSelf, strSender, strRealmName, nPresenceState, arMessageSegments, unitSource, bShowChatBubble, bCrossFaction, nReportId
	
		-- arMessageSegments is an array of tables.  Each table representsa part of the message + the formatting for that segment.
		-- This allows us to signal font (alien text for example) changes mid stream.
		-- local example = arMessageSegments[1]
		-- example.strText is the text
		-- example.bAlien == true if alien font set
		-- example.bRolePlay == true if this is rolePlay Text.  RolePlay text should only show up for people in roleplay mode, and non roleplay text should only show up for people outside it.
	
		-- to use: 	{#}toggles alien on {*}toggles rp on. Alien is still on {!}resets all format codes.
	
	
		-- There will be a lot of chat messages, particularly for combat log.  If you make your own chat log module, you will want to batch
		-- up several at a time and only process lines you expect to see.
	
		local Killroy = Apollo.GetAddon("Killroy")
		if not(Killroy) then return end
		
		local tQueuedMessage = {}
		tQueuedMessage.tMessage = tMessage
		
		--[[
		--%t target substitution
		for idx, this_segment in ipairs(tQueuedMessage.tMessage.arMessageSegments) do
			local strText = this_segment.strText
			strText = Killroy:ParseForTarget(strText)
			this_segment.strText = strText
		end
		
		--Animated Emote Parsing
		local strEmbeddedEmote = nil
		local bFirst = true
		for idx, this_segment in ipairs(tQueuedMessage.tMessage.arMessageSegments) do
			local strText = this_segment.strText
			local this_dump = Killroy:ParseForAnimatedEmote(strText)
			if this_dump["strEmbeddedEmote"] and bFirst then
				bFirst = not bFirst
				strEmbeddedEmote = this_dump["strEmbeddedEmote"]
			end
			strText = this_dump["strTextClean"]
			this_segment.strText = strText
		end
		]]--
		
		--Cludge for custom channels
		--tQueuedMessage.eChannelType = channelCurrent:GetType()
		if Killroy.tPrefs["bCustomChatColors"] then
			tQueuedMessage.eChannelType = Killroy:ChannelCludge(channelCurrent:GetName(),channelCurrent:GetType())
		else
			tQueuedMessage.eChannelType = channelCurrent:GetType()
		end
		tQueuedMessage.strChannelName = channelCurrent:GetName()
		tQueuedMessage.strChannelCommand = channelCurrent:GetCommand()
		
		
		-- Killroy Range Filter Hooks
		
		local bEnableDebug = false
		
		-- Only engage the filter with say, emote and animated emotes, and if the message is not the players own
		
		local eChannelType = tQueuedMessage.eChannelType
		local bPlayerTest = true
		
		
		if tMessage.unitSource then
			bPlayerTest = not (GameLib.GetPlayerUnit():GetName() == tMessage.unitSource:GetName())
		else
			bPlayerTest = true
		end
		
		
		local bChannelTest1 = eChannelType == ChatSystemLib.ChatChannel_Say
		local bChannelTest2 = eChannelType == ChatSystemLib.ChatChannel_Emote
		local bChannelTest3 = eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote
		local bChannelTest = bChannelTest1 or bChannelTest2 or bChannelTest3
		
		local bKillMessage = false
		
		--skip animated emote test
		if eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote and Killroy.bSkipAnimatedEmote then
			Killroy.bSkipAnimatedEmote = false
			bKillMessage = true
		end
		
		if eChannelType ~= ChatSystemLib.ChatChannel_Debug and bEnableDebug then Print("bPlayerTest: "..tostring(bPlayerTest).." bChannelTest:"..tostring(bChannelTest)) end
		if eChannelType ~= ChatSystemLib.ChatChannel_Debug and bEnableDebug then Print("bKillMessage: "..tostring(bKillMessage)) end

		
		if bPlayerTest and bChannelTest then
			if Killroy.tPrefs["bRangeFilter"] then
				for idx, tSegment in ipairs( tMessage.arMessageSegments ) do
					local strText = tSegment.strText
					if eChannelType ~= ChatSystemLib.ChatChannel_Debug and bEnableDebug then Print("original strText:"..tostring(strText)) end
					strText = Killroy:RangeFilter(strText, tMessage.unitSource:GetName(), eChannelType)
					if eChannelType ~= ChatSystemLib.ChatChannel_Debug and bEnableDebug then Print("post strText:"..tostring(strText)) end
					if not(strText) then
						bKillMessage = true
						if eChannelType ~= ChatSystemLib.ChatChannel_Debug and bEnableDebug then Print("bKillMessage: "..tostring(bKillMessage)) end
					else
						if eChannelType ~= ChatSystemLib.ChatChannel_Debug and bEnableDebug then Print("bKillMessage: "..tostring(bKillMessage)) end
						tSegment.strText = strText
						if eChannelType ~= ChatSystemLib.ChatChannel_Debug and bEnableDebug then Print("tSegment.strText: "..tostring(tSegment.strText)) end
					end
				end
			end	
		end	
						
		--bKillMessage = false
		
		if not bKillMessage then
			-- handle unit bubble if needed.
			if tQueuedMessage.tMessage.unitSource and tQueuedMessage.tMessage.bShowChatBubble then
				self:HelperGenerateChatMessage(tQueuedMessage)
				if tQueuedMessage.xmlBubble then
					tMessage.unitSource:AddTextBubble(tQueuedMessage.xmlBubble)
				end
			end
		
			-- queue message on windows.
			for key, wndChat in pairs(self.tChatWindows) do
				if wndChat:GetData().tViewedChannels[tQueuedMessage.eChannelType] then -- check flags for filtering
					self.bQueuedMessages = true
					wndChat:GetData().tMessageQueue:Push(tQueuedMessage)
				end
			end
		end
		
		--[[
		if strEmbeddedEmote and (tQueuedMessage.tMessage.strSender == GameLib.GetPlayerUnit():GetName()) then
			ComChan = Killroy:GetChannelByName("Command")
			ComChan:Send(strEmbeddedEmote)
		end
		]]--
	end

end

function Killroy:Change_HelperGenerateChatMessage()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:HelperGenerateChatMessage(tQueuedMessage)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		
		if tQueuedMessage.xml then
			return
		end

		local eChannelType = tQueuedMessage.eChannelType
		local tMessage = tQueuedMessage.tMessage
		
		-- Different handling for combat log
		if eChannelType == ChatSystemLib.ChatChannel_Combat then
			-- no formats in combat, roll it all up into one.
			local strMessage = ""
			for idx, tSegment in ipairs(tMessage.arMessageSegments) do
				strMessage = strMessage .. tSegment.strText
			end
			tQueuedMessage.strMessage = strMessage
			return
		end

		local xml = XmlDoc.new()
		local tm = GameLib.GetLocalTime()
		--local crText = self.arChatColor[eChannelType] or ApolloColor.new("white")
		local crText = self.arChatColor[eChannelType] or ApolloColor.new("white")
		--local crChannel = ApolloColor.new(karChannelTypeToColor[eChannelType].Channel or "white")
		local crChannel = self.arChatColor[eChannelType] or ApolloColor.new("white")
		local crPlayerName = ApolloColor.new("ChatPlayerName")

		local strTime = "" if self.bShowTimestamp then strTime = string.format("%d:%02d ", tm.nHour, tm.nMinute) end
		local strWhisperName = tMessage.strSender
		if tMessage.strRealmName:len() > 0 then
			-- Name/Realm formatting needs to be very specific for cross realm chat to work
			strWhisperName = strWhisperName .. "@" .. tMessage.strRealmName
		end

		--strWhisperName must only be sender@realm, or friends equivelent name.

		local strPresenceState = ""
		if tMessage.bAutoResponse then
			strPresenceState = '('..Apollo.GetString("AutoResponse_Prefix")..')'
		end

		if tMessage.nPresenceState == FriendshipLib.AccountPresenceState_Away then
			strPresenceState = '<'..Apollo.GetString("Command_Friendship_AwayFromKeyboard")..'>'
		elseif tMessage.nPresenceState == FriendshipLib.AccountPresenceState_Busy then
			strPresenceState = '<'..Apollo.GetString("Command_Friendship_DoNotDisturb")..'>'
		end

		if eChannelType == ChatSystemLib.ChatChannel_Whisper then
			if not tMessage.bSelf then
				self.tLastWhisperer = { strCharacterName = strWhisperName, eChannelType = ChatSystemLib.ChatChannel_Whisper }--record the last incoming whisperer for quick response
			end
			Sound.Play(Sound.PlayUISocialWhisper)
		elseif eChannelType == ChatSystemLib.ChatChannel_AccountWhisper then

			local tPreviousWhisperer = self.tLastWhisperer

			self.tLastWhisperer =
			{
				strCharacterName = tMessage.strSender,
				strRealmName = nil,
				strDisplayName = nil,
				eChannelType = ChatSystemLib.ChatChannel_AccountWhisper
			}

			local tAccountFriends = FriendshipLib.GetAccountList()
			for idx, tAccountFriend in pairs(tAccountFriends) do
				if tAccountFriend.arCharacters ~= nil then
					for idx, tCharacter in pairs(tAccountFriend.arCharacters) do
						if tCharacter.strCharacterName == tMessage.strSender and (tMessage.strRealmName:len() == 0 or tCharacter.strRealm == tMessage.strRealmName) then
							if not tMessage.bSelf or (tPreviousWhisperer and tPreviousWhisperer.strCharacterName == tMessage.strSender) then
								self.tLastWhisperer.strDisplayName = tAccountFriend.strCharacterName
								self.tLastWhisperer.strRealmName = tCharacter.strRealm
							end
							strWhisperName = tAccountFriend.strCharacterName
							if tMessage.strRealmName:len() > 0 then
								-- Name/Realm formatting needs to be very specific for cross realm chat to work
								strWhisperName = strWhisperName .. "@" .. tMessage.strRealmName
							end
						end
					end
				end
			end
			Sound.Play(Sound.PlayUISocialWhisper)
		end

		-- We build strings backwards, right to left
		if eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote then -- emote animated channel gets special formatting
			-- bs:051414, incorporating preferences variables
			if Killroy.tPrefs['bFormatChat'] then
				xml:AddLine(strTime, Killroy.tPrefs['kstrEmoteColor'], self.strFontOption, "Left")
			else
				xml:AddLine(strTime, crChannel, self.strFontOption, "Left")
			end

		elseif eChannelType == ChatSystemLib.ChatChannel_Emote then -- emote channel gets special formatting
			-- bs: 051414, incorporating preferences variables
			if Killroy.tPrefs['bFormatChat'] then
				xml:AddLine(strTime, Killroy.tPrefs['kstrEmoteColor'], self.strFontOption, "Left")
			else
				xml:AddLine(strTime, crChannel, self.strFontOption, "Left")
			end
			if strWhisperName:len() > 0 then
				if tMessage.bGM then
					xml:AppendImage(kstrGMIcon, 16, 16)
				end
				xml:AppendText(strWhisperName, crPlayerName, self.strFontOption, {CharacterName=strWhisperName, nReportId=tMessage.nReportId}, "Source")
			end
			xml:AppendText(" ")
		else
			local strChannel
			if eChannelType == ChatSystemLib.ChatChannel_Society then
				strChannel = String_GetWeaselString(Apollo.GetString("ChatLog_GuildCommand"), tQueuedMessage.strChannelName, tQueuedMessage.strChannelCommand)
			else
				strChannel = String_GetWeaselString(Apollo.GetString("CRB_Brackets_Space"), tQueuedMessage.strChannelName)
			end

			if self.bShowChannel ~= true then
				strChannel = ""
			end

			xml:AddLine(strTime .. strChannel, crChannel, self.strFontOption, "Left")
			if strWhisperName:len() > 0 then

				local strWhisperNamePrefix = ""
				if eChannelType == ChatSystemLib.ChatChannel_Whisper or eChannelType == ChatSystemLib.ChatChannel_AccountWhisper then
					if tMessage.bSelf then
						strWhisperNamePrefix = Apollo.GetString("ChatLog_To")
					else
						strWhisperNamePrefix = Apollo.GetString("ChatLog_From")
					end
				end

				xml:AppendText( strWhisperNamePrefix, crText, self.strFontOption)

				if tMessage.bGM then
					xml:AppendImage(kstrGMIcon, 16, 16)
				end

				xml:AppendText( strWhisperName, crPlayerName, self.strFontOption, {CharacterName=strWhisperName, nReportId=tMessage.nReportId}, "Source")
			end
			xml:AppendText( strPresenceState .. ": ", crChannel, self.strFontOption, "Left")
		end

		local xmlBubble = nil
		if tMessage.bShowChatBubble then
			xmlBubble = XmlDoc.new() -- This is the speech bubble form
			xmlBubble:AddLine("", crChannel, self.strFontOption, "Center")
		end

		local bHasVisibleText = false
		for idx, tSegment in ipairs( tMessage.arMessageSegments ) do
			local strText = tSegment.strText
			-- bs:051414, incorporating preferences variables
			local bAlien = tSegment.bAlien or (tMessage.bCrossFaction and not(Killroy.tPrefs['bCrossFaction']))
			local bShow = false

			if self.eRoleplayOption == 3 then
				bShow = not tSegment.bRolePlay
			elseif self.eRoleplayOption == 2 then
				bShow = tSegment.bRolePlay
			else
				bShow = true;
			end

			if bShow then
				local crChatText = crText;
				local crBubbleText = kstrColorChatRegular
				local strChatFont = self.strFontOption
				local strBubbleFont = kstrBubbleFont
				local tLink = {}


				if tSegment.uItem ~= nil then -- item link
					-- replace me with correct colors
					strText = String_GetWeaselString(Apollo.GetString("CRB_Brackets"), tSegment.uItem:GetName())
					crChatText = karEvalColors[tSegment.uItem:GetItemQuality()]
					crBubbleText = ApolloColor.new("white")

					tLink.strText = strText
					tLink.uItem = tSegment.uItem

				elseif tSegment.uQuest ~= nil then -- quest link
					-- replace me with correct colors
					strText = String_GetWeaselString(Apollo.GetString("CRB_Brackets"), tSegment.uQuest:GetTitle())
					crChatText = ApolloColor.new("green")
					crBubbleText = ApolloColor.new("green")

					tLink.strText = strText
					tLink.uQuest = tSegment.uQuest

				elseif tSegment.uArchiveArticle ~= nil then -- archive article
					-- replace me with correct colors
					strText = String_GetWeaselString(Apollo.GetString("CRB_Brackets"), tSegment.uArchiveArticle:GetTitle())
					crChatText = ApolloColor.new("ffb7a767")
					crBubbleText = ApolloColor.new("ffb7a767")

					tLink.strText = strText
					tLink.uArchiveArticle = tSegment.uArchiveArticle

				else
					if tSegment.bRolePlay then
						crBubbleText = kstrColorChatRoleplay
						strChatFont = self.strRPFontOption
						strBubbleFont = kstrDialogFontRP
					end

					if bAlien or tSegment.bProfanity then -- Weak filter. Note only profanity is scrambled.
						strChatFont = self.strAlienFontOption
						strBubbleFont = self.strAlienFontOption
					end
				end

				if next(tLink) == nil then
					-- bs:051414, incorportating preferences
					if Killroy.tPrefs['bFormatChat'] and ((eChannelType == ChatSystemLib.ChatChannel_Say) or (eChannelType == ChatSystemLib.ChatChannel_Emote)) then
						parsedText = Killroy:ParseForContext(strText, eChannelType)
						Killroy:DumpToChat(parsedText, strChatFont, xml)
					elseif Killroy.tPrefs['bFormatChat'] and (eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote) then
						xml:AppendText(strText, Killroy.tPrefs['kstrEmoteColor'], strChatFont)
					else
						xml:AppendText(strText, crChatText, strChatFont)
					end

				else
					local strLinkIndex = tostring( self:HelperSaveLink(tLink) )
					-- append text can only save strings as attributes.
					xml:AppendText(strText, crChatText, strChatFont, {strIndex=strLinkIndex} , "Link")
				end

				if xmlBubble then
					if Killroy.tPrefs['bFormatChat'] and ((eChannelType == ChatSystemLib.ChatChannel_Say) or (eChannelType == ChatSystemLib.ChatChannel_Emote)) then
						parsedText = Killroy:ParseForContext(strText, eChannelType)
						Killroy:DumpToChat(parsedText, strBubbleFont, xmlBubble)
					else
						xmlBubble:AppendText(strText, crBubbleText, strChatFont)
					end
					-- bs: 052114, format the chat bubble
					---xmlBubble:AppendText(strText, crBubbleText, strBubbleFont) -- Format for bubble; regular
				end

				bHasVisibleText = bHasVisibleText or self:HelperCheckForEmptyString(strText)
			end
		end

		tQueuedMessage.bHasVisibleText = bHasVisibleText
		tQueuedMessage.xml = xml
		tQueuedMessage.xmlBubble = xmlBubble
	end
	
	return true

end

function Killroy:Change_OnChatInputReturn()
	local ChatLog  = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:OnChatInputReturn(wndHandler, wndControl, strText)
		local Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		
		if wndControl:GetName() == "Input" then
			local wndForm = wndControl:GetParent()
			strText = self:HelperReplaceLinks(strText, wndControl:GetAllLinks())

			local wndInput = wndForm:FindChild("Input")

			wndControl:SetText("")
			-- bs:051414, incorporating preferences
			if not(Killroy.tPrefs['bRPOnly']) then
				if self.eRoleplayOption == 2 then
					wndControl:SetText(Apollo.GetString("ChatLog_RPMarker"))
				end
			end


			local tChatData = wndForm:GetData()
			local bViewedChannel = true
			local tInput = ChatSystemLib.SplitInput(strText)
			if strText ~= "" and strText ~= Apollo.GetString("ChatLog_RPMarker") and strText ~= Apollo.GetString("ChatLog_Marker") then

				local channelCurrent = tInput.channelCommand or tChatData.channelCurrent

				if channelCurrent:GetType() == ChatSystemLib.ChatChannel_Command then
					if tInput.bValidCommand then -- good command
						ChatSystemLib.Command( strText )
					else	-- bad command
						local strFailString = String_GetWeaselString(Apollo.GetString("ChatLog_UnknownCommand"), Apollo.GetString("CombatFloaterType_Error"), {strLiteral = tInput.strCommand})
						ChatSystemLib.PostOnChannel( ChatSystemLib.ChatChannel_Command, strFailString, "" )
						wndInput:SetText(String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), {strLiteral = tInput.strCommand}, {strLiteral = tInput.strMessage}))
						wndInput:SetFocus()
						local strSubmitted = wndForm:FindChild("Input"):GetText()
						wndInput:SetSel(strSubmitted:len(), -1)
						return
					end
				else
					tChatData.channelCurrent = channelCurrent
					if self.eRoleplayOption == 2 and Killroy.tPrefs['bRPOnly'] then
						tInput.strMessage = Apollo.GetString("ChatLog_RPMarker") .. tInput.strMessage
					end
					bViewedChannel = self:VerifyChannelVisibility(channelCurrent, tInput, wndForm)
				end
			end

			--local crText = self.arChatColor[tChatData.channelCurrent:GetType()] or ApolloColor.new("white")
			local crtext
			if Killroy.tPrefs["bCustomChatColors"] then
				crText = self.arChatColor[Killroy:ChannelCludge(tChatData.channelCurrent:GetName(),tChatData.channelCurrent:GetType())] or ApolloColor.new("white")
			else
				crText = self.arChatColor[tChatData.channelCurrent:GetType()] or ApolloColor.new("white")
			end
			local wndInputType = wndForm:FindChild("InputType")
			wndForm:GetData().crText = crText
			wndForm:FindChild("InputType"):SetTextColor(crText)
			wndInput:SetTextColor(crText)
			wndInputType:SetText(tChatData.channelCurrent:GetCommand())

			if bViewedChannel ~= true then
				wndInputType:SetText("X " .. tInput.strCommand)
				wndInputType:SetTextColor(kcrInvalidColor)
			end
		end
	end
end

function Killroy:Change_OnRoleplayBtn()
	local ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:OnRoleplayBtn(wndHandler, wndControl)
		local Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
		
		if wndHandler ~= wndControl then
			return false
		end

		local wndParent = wndControl:GetParent()
		self.eRoleplayOption = wndParent:GetRadioSel("RoleplayViewToggle")
		for idx, wndChat in pairs(self.tChatWindows) do
			if not(Killroy.tPrefs['bRPOnly']) then
				if self.eRoleplayOption == 2 then
					wndChat:FindChild("Input"):SetText(Apollo.GetString("ChatLog_RPMarker"))
				else
					wndChat:FindChild("Input"):SetText("")
				end
			end
			wndChat:FindChild("Input"):SetText("")
		end
	end
end
-----------------------------------------------------------------------------------------------
-- KillroyForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function Killroy:OnOK()
	self.wndMain:Close() -- hide the window
	self.tPrefs['bCrossFaction'] = not(self.wndMain:FindChild('bCrossFaction'):IsChecked())
	self.tPrefs['bRPOnly'] = not(self.wndMain:FindChild('bRPOnly'):IsChecked())
	self.tPrefs['bFormatChat'] = not(self.wndMain:FindChild('bFormatChat'):IsChecked())
	self.tPrefs['bRangeFilter'] = not(self.wndMain:FindChild('bRangeFilter'):IsChecked())
	self.tPrefs['bUseOcclusion'] = not(self.wndMain:FindChild('bUseOcclusion'):IsChecked())
	self.tPrefs['bCustomChatColors'] = not(self.wndMain:FindChild('bCustomChatColors'):IsChecked())
	self.tPrefs['kstrEmoteColor'] = self.tColorBuffer['kstrEmoteColor']
	self.tPrefs['kstrSayColor'] = self.tColorBuffer['kstrSayColor']
	self.tPrefs['kstrOOCColor'] = self.tColorBuffer['kstrOOCColor']
	self.tPrefs['nSayRange'] = self.tRFBuffer['nSayRange']
	self.tPrefs['nEmoteRange'] = self.tRFBuffer['nEmoteRange']
	self.tPrefs['nFalloff'] = self.tRFBuffer['nFalloff']
	if self.bReloadUIRequired then
		self.bReloadUIRequired = false
		local ComChan = self:GetChannelByName("Command")
		ComChan:Send("/reloadui")
	end
end

-- when the Cancel button is clicked
function Killroy:OnCancel()
	self.wndMain:Close() -- hide the window
	self.wndMain:FindChild('bCrossFaction'):SetCheck(not(self.tPrefs['bCrossFaction']))
	self.wndMain:FindChild('bRPOnly'):SetCheck(not(self.tPrefs['bRPOnly']))
	self.wndMain:FindChild('bFormatChat'):SetCheck(not(self.tPrefs['bFormat']))
	self.wndMain:FindChild('bRangeFilter'):SetCheck(not(self.tPrefs['bRangeFilter']))
	self.wndMain:FindChild('bUseOcclusion'):SetCheck(not(self.tPrefs['bUseOcclusion']))
	self.wndMain:FindChild('bCustomChatColors'):SetCheck(not(self.tPrefs['bCustomChatColors']))
	self.tColorBuffer['kstrEmoteColor'] = self.tPrefs['kstrEmoteColor'] 
	self.tColorBuffer['kstrSayColor'] = self.tPrefs['kstrSayColor']
	self.tColorBuffer['kstrOOCColor'] = self.tPrefs['kstrOOCColor']
	self.tRFBuffer['nSayRange'] = self.tPrefs['nSayRange']
	self.tRFBuffer['nEmoteRange'] = self.tPrefs['nEmoteRange']
	self.tRFBuffer['nFalloff'] = self.tPrefs['nFalloff']
	self.bReloadUIRequired = false
end

function Killroy:OnSetOOCColor( wndHandler, wndControl, eMouseButton )
	tAddon = Apollo.GetAddon('Killroy')
	GeminiColor:ShowColorPicker( tAddon, 'OnSetOOCColorOk', true, self.tColorBuffer['kstrOOCColor'])
end

function Killroy:OnSetOOCColorOk(hexcolor)
	self.tColorBuffer['kstrOOCColor'] = hexcolor
	self.wndMain:FindChild('setOOCColor'):SetNormalTextColor(hexcolor)
end

function Killroy:OnSetEmoteColor( wndHandler, wndControl, eMouseButton )
	tAddon = Apollo.GetAddon('Killroy')
	GeminiColor:ShowColorPicker( tAddon, 'OnSetEmoteColorOk', true, self.tColorBuffer['kstrEmoteColor'])
end

function Killroy:OnSetEmoteColorOk(hexcolor)
	self.tColorBuffer['kstrEmoteColor'] = hexcolor
	self.wndMain:FindChild('setEmoteColor'):SetNormalTextColor(hexcolor)
end

function Killroy:OnSetSayColor( wndHandler, wndControl, eMouseButton )
	tAddon = Apollo.GetAddon('Killroy')
	GeminiColor:ShowColorPicker( tAddon, 'OnSetSayColorOk', true, self.tColorBuffer['kstrSayColor'])
end

function Killroy:OnSetSayColorOk(hexcolor)
	self.tColorBuffer['kstrSayColor'] = hexcolor
	self.wndMain:FindChild('setSayColor'):SetNormalTextColor(hexcolor)
end

function Killroy:OnRangeSlider( wndHandler, wndControl, fNewValue, fOldValue )
	sName = wndControl:GetName()
	self.tRFBuffer[sName] = fNewValue
end

function Killroy:OnCustomChatColorsChanged( wndHandler, wndControl, eMouseButton )
	self.bReloadUIRequired = true
end

---------------------------------------------------------------------------------------------------
-- ChatType Functions
---------------------------------------------------------------------------------------------------

function Killroy:Append_OnChannelColorBtn()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	Apollo.RegisterEventHandler('OnChannelColorBtn', OnChannelColorBtn, ChatLog)

	function ChatLog:OnChannelColorBtn( wndHandler, wndControl, eMouseButton )
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end

		local GeminiColor = Apollo.GetPackage("GeminiColor").tPackage
		
		wndChatType = wndControl:GetParent()
		nChannel = wndChatType:GetData()
		
		GeminiColor:ShowColorPicker( ChatLog, 'OnChannelColorBtnOK', true, Killroy:toHex(self.arChatColor[nChannel]), nChannel, wndControl)
	end
	
	function ChatLog:OnChannelColorBtnOK(hexcolor, nChannel, wndControl)
		self.arChatColor[nChannel] = ApolloColor.new(hexcolor)
		wndControl:SetBGColor(self.arChatColor[nChannel])
	end
end

-----------------------------------------------------------------------------------------------
-- Killroy Instance
-----------------------------------------------------------------------------------------------
local KillroyInst = Killroy:new()
KillroyInst:Init()
