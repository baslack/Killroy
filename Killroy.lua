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
			nSayRange = knDefaultSayRange,
			nEmoteRange = knDefaultEmoteRange,
			nFalloff = knDefaultFalloff,
			bUseOcclusion = true,
			kstrEmoteColor = ksDefaultEmoteColor,
			kstrSayColor = ksDefaultSayColor,
			kstrOOCColor 	= ksDefaultOOCColor,
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
	Apollo.RegisterEventHandler('OnSetEmoteColor', OnSetEmoteColor, self)
	Apollo.RegisterEventHandler('OnSetSayColor', OnSetSayColor, self)
	Apollo.RegisterEventHandler('OnSetOOCColor', OnSetOOCColor, self)
	
	-- replace ChatLogFunctions
	self:Change_HelperGenerateChatMessage()
	self:Change_OnChatInputReturn()
	self:Change_OnRoleplayBtn()
	self:Change_OnChatMessage()
	--self:Change_ActionBarFrame_OnMountBtn()
	--self:RestoreMountSetting()
	self:Change_AddChannelTypeToList()
	self:Append_OnChannelColorBtn()
	self:Change_OnViewCheck()
	self:Change_VerifyChannelVisibility()
end
-----------------------------------------------------------------------------------------------
-- Killroy Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function Killroy:OnConfigure()
	self.wndMain:FindChild('bCrossFaction'):SetCheck(not(self.tPrefs['bCrossFaction']))
	self.wndMain:FindChild('bRPOnly'):SetCheck(not(self.tPrefs['bRPOnly']))
	self.wndMain:FindChild('bFormatChat'):SetCheck(not(self.tPrefs['bFormatChat']))
	self.wndMain:FindChild('bRangeFilter'):SetCheck(not(self.tPrefs['bRangeFilter']))
	self.wndMain:FindChild('bUseOcclusion'):SetCheck(not(self.tPrefs['bUseOcclusion']))
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
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account) then return nil end
	return {tPrefs = self.tPrefs,}
end

function Killroy:OnRestore(eLevel, tData)
	--Killroy's Prefs
	if (tData.tPrefs ~= nil) then
		for i,v in pairs(tData.tPrefs) do
			self.tPrefs[i] = v
		end
	end
end

--Killroy Specific Functions

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

--------------------------------------------------------
-- Killroy Change Methods, these replace ChatLog methods
--------------------------------------------------------
function Killroy:Change_OnViewCheck()
	ChatLog = Apollo.GetAddon("ChatLog")
	if not ChatLog then return nil end
	
	function ChatLog:OnViewCheck(wndHandler, wndControl)
		Killroy = Apollo.GetAddon("Killroy")
		if not Killroy then return nil end
			
		local bDebug = true
		
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
		if self.tAllViewedChannels[ Killroy:ChannelCludge(channelChecking:GetName(), channelChecking:GetType()) ] ~= nil then -- see if this channelChecking is viewed
			local strMessage = tInput.strMessage
			if Killroy:ChannelCludge(channelChecking:GetName(),channelChecking:GetType()) == ChatSystemLib.ChatChannel_AccountWhisper then
				if self.tAccountWhisperContex then
					local strCharacterAndRealm = self.tAccountWhisperContex.strCharacterName .. "@" .. self.tAccountWhisperContex.strRealmName
					strMessage = string.gsub(strMessage, self.tAccountWhisperContex.strDisplayName, strCharacterAndRealm, 1)
				end
			end
			channelChecking:Send(strMessage)
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

function Killroy:ChannelCludge(sName,nType)
	local knFudge = 40
	local nCludge = 0
	
	--Print(sName)
	--Print(sName.."|"..tostring(nType))
	
	for idx, this_chan in ipairs(ChatSystemLib.GetChannels()) do
		--Print(this_chan:GetName())
	end
	
	if nType == ChatSystemLib.ChatChannel_Custom then
		local chan = ChatSystemLib.GetChannels()
		for idx, this_chan in ipairs(chan) do
			--Print("this_chan:"..this_chan:GetName())
			if this_chan:GetName() == sName then nCludge = idx + knFudge end
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
		--Cludge for custom channels
		--tQueuedMessage.eChannelType = channelCurrent:GetType()
		tQueuedMessage.eChannelType = Killroy:ChannelCludge(channelCurrent:GetName(),channelCurrent:GetType())
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
	end

end

function Killroy:Change_HelperGenerateChatMessage()
	local aAddon = Apollo.GetAddon("ChatLog")
	if aAddon == nil then
		return false
	end
	
	function aAddon:HelperGenerateChatMessage(tQueuedMessage)
		if tQueuedMessage.xml then
			return
		end

		local eChannelType = tQueuedMessage.eChannelType
		local tMessage = tQueuedMessage.tMessage
		
		--[[
		-- Killroy Range Filter Hooks
		local Killroy = Apollo.GetAddon("Killroy")
		if not(Killroy) then return end
		
		-- Only engage the filter with say, emote and animated emotes, and if the message is not the players own
		
		local bPlayerTest
		if tMessage.unitSource then
			bPlayerTest = not (GameLib.GetPlayerUnit():GetName() == tMessage.unitSource:GetName())
		else
			bPlayerTest = true
		end
		
		local bChannelTest1 = eChannelType == ChatSystemLib.ChatChannel_Say
		local bChannelTest2 = eChannelType == ChatSystemLib.ChatChannel_Emote
		local bChannelTest3 = eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote
		local bChannelTest = bChannelTest1 or bChannelTest2 or bChannelTest3
		
		if bPlayerTest and bChannelTest then
			if Killroy.tPrefs["bRangeFilter"] then
				for idx, tSegment in ipairs( tMessage.arMessageSegments ) do
					local strText = tSegment.strText
					strText = Killroy:RangeFilter(strText, tMessage.unitSource:GetName(), eChannelType)
					tSegment.strText = strText
					if strText == nil then return end
				end
			end	
		end
		]]--
		
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
	local aAddon = Apollo.GetAddon("ChatLog")
	if aAddon == nil then
		return false
	end
	function aAddon:OnChatInputReturn(wndHandler, wndControl, strText)
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
					if ((self.eRoleplayOption == 2) or (self.eRoleplayOption == 1)) and Killroy.tPrefs['bRPOnly'] then
						tInput.strMessage = Apollo.GetString("ChatLog_RPMarker") .. tInput.strMessage
					end
					bViewedChannel = self:VerifyChannelVisibility(channelCurrent, tInput, wndForm)
				end
			end

			local crText = self.arChatColor[tChatData.channelCurrent:GetType()] or ApolloColor.new("white")
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
	local aAddon = Apollo.GetAddon("ChatLog")
	if aAddon == nil then
		return false
	end
	function aAddon:OnRoleplayBtn(wndHandler, wndControl)
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
	self.tPrefs['kstrEmoteColor'] = self.tColorBuffer['kstrEmoteColor']
	self.tPrefs['kstrSayColor'] = self.tColorBuffer['kstrSayColor']
	self.tPrefs['kstrOOCColor'] = self.tColorBuffer['kstrOOCColor']
	self.tPrefs['nSayRange'] = self.tRFBuffer['nSayRange']
	self.tPrefs['nEmoteRange'] = self.tRFBuffer['nEmoteRange']
	self.tPrefs['nFalloff'] = self.tRFBuffer['nFalloff']
end

-- when the Cancel button is clicked
function Killroy:OnCancel()
	self.wndMain:Close() -- hide the window
	self.wndMain:FindChild('bCrossFaction'):SetCheck(not(self.tPrefs['bCrossFaction']))
	self.wndMain:FindChild('bRPOnly'):SetCheck(not(self.tPrefs['bRPOnly']))
	self.wndMain:FindChild('bFormatChat'):SetCheck(not(self.tPrefs['bFormat']))
	self.wndMain:FindChild('bRangeFilter'):SetCheck(not(self.tPrefs['bRangeFilter']))
	self.wndMain:FindChild('bUseOcclusion'):SetCheck(not(self.tPrefs['bUseOcclusion']))
	self.tColorBuffer['kstrEmoteColor'] = self.tPrefs['kstrEmoteColor'] 
	self.tColorBuffer['kstrSayColor'] = self.tPrefs['kstrSayColor']
	self.tColorBuffer['kstrOOCColor'] = self.tPrefs['kstrOOCColor']
	self.tRFBuffer['nSayRange'] = self.tPrefs['nSayRange']
	self.tRFBuffer['nEmoteRange'] = self.tPrefs['nEmoteRange']
	self.tRFBuffer['nFalloff'] = self.tPrefs['nFalloff']
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
