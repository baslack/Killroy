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
			kstrEmoteColor = 'ffff9900',
			kstrSayColor = 'ffffffff',
			kstrOOCColor 	= 'ff7fffb9',
		}
		self.tColorBuffer = 
		{
			kstrEmoteColor = 'ffff9900',
			kstrSayColor = 'ffffffff',
			kstrOOCColor 	= 'ff7fffb9',
		}
	else
		self.tColorBuffer = 
		{
			kstrEmoteColor = self.tPrefs['kstrEmoteColor'],
			kstrSayColor = self.tPrefs['kstrSayColor'],
			kstrOOCColor 	= self.tPrefs['kstrOOCColor'],
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
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "KillroyForm", nil, self)
	self.wndMain:Show(false, true)

	--register commands and actions
	Apollo.RegisterSlashCommand("killroy", "OnKillroyOn", self)
	Apollo.RegisterEventHandler('OnSetEmoteColor', OnSetEmoteColor, self)
	Apollo.RegisterEventHandler('OnSetSayColor', OnSetEmoteColor, self)
	Apollo.RegisterEventHandler('OnSetOOCColor', OnSetEmoteColor, self)

	-- replace ChatLogFunctions
	self:Change_HelperGenerateChatMessage()
	self:Change_OnChatInputReturn()
	self:Change_OnRoleplayBtn()
	
	GeminiColor = _G["GeminiPackages"]:GetPackage("GeminiColor-1.0")	
end
-----------------------------------------------------------------------------------------------
-- Killroy Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function Killroy:OnConfigure()
	self.wndMain:FindChild('bCrossFaction'):SetCheck(not(self.tPrefs['bCrossFaction']))
	self.wndMain:FindChild('bRPOnly'):SetCheck(not(self.tPrefs['bRPOnly']))
	self.wndMain:FindChild('bFormatChat'):SetCheck(not(self.tPrefs['bFormatChat']))
	self.wndMain:FindChild('setEmoteColor'):SetNormalTextColor(self.tPrefs['kstrEmoteColor'])
	self.wndMain:FindChild('setSayColor'):SetNormalTextColor(self.tPrefs['kstrSayColor'])
	self.wndMain:FindChild('setOOCColor'):SetNormalTextColor(self.tPrefs['kstrOOCColor'])
	self.wndMain:Show(true)
end

function Killroy:OnKillroyOn()
	self.wndMain:FindChild('bCrossFaction'):SetCheck(not(self.tPrefs['bCrossFaction']))
	self.wndMain:FindChild('bRPOnly'):SetCheck(not(self.tPrefs['bRPOnly']))
	self.wndMain:FindChild('bFormatChat'):SetCheck(not(self.tPrefs['bFormatChat']))
	self.wndMain:FindChild('setEmoteColor'):SetNormalTextColor(self.tPrefs['kstrEmoteColor'])
	self.wndMain:FindChild('setSayColor'):SetNormalTextColor(self.tPrefs['kstrSayColor'])
	self.wndMain:FindChild('setOOCColor'):SetNormalTextColor(self.tPrefs['kstrOOCColor'])
	self.wndMain:Show(true)
end

function Killroy:DebugTest()
	Print("Printing to debug.")
	Print("bCrossFaction " .. tostring(self.wndMain:FindChild("bCrossFaction"):IsChecked()))
	Print("bRPOnly " .. tostring(self.wndMain:FindChild("bRPOnly"):IsChecked()))
	Print("bFormatChat " .. tostring(self.wndMain:FindChild("bFormatChat"):IsChecked()))
	return true
end

function Killroy:GetPreferences()
	return tPrefs
end

function Killroy:OnSave(eLevel)
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account) then return nil end
	return {tPrefs = self.tPrefs,}
end

function Killroy:OnRestore(eLevel, tData)
	if (tData.tPrefs ~= nil) then
		for i,v in pairs(tData.tPrefs) do
			self.tPrefs[i] = v
		end
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
		local crChannel = ApolloColor.new(karChannelTypeToColor[eChannelType].Channel or "white")
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
						local strFailString = String_GetWeaselString(Apollo.GetString("ChatLog_UnknownCommand"), Apollo.GetString("CombatFloaterType_Error"), tInput.strCommand)
						ChatSystemLib.PostOnChannel( ChatSystemLib.ChatChannel_Command, strFailString, "" )
						wndInput:SetText(String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), tInput.strCommand, tInput.strMessage))
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

			local crText = self.arChatColor[tChatData.channelCurrent:GetType()] or ApolloColor.new("white")
			local wndInputType = wndForm:FindChild("InputTypeBtn:InputType")
			wndForm:GetData().crText = crText
			wndForm:FindChild("InputTypeBtn:InputType"):SetTextColor(crText)
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
	self.tPrefs['kstrEmoteColor'] = self.tColorBuffer['kstrEmoteColor']
	self.tPrefs['kstrSayColor'] = self.tColorBuffer['kstrSayColor']
	self.tPrefs['kstrOOCColor'] = self.tColorBuffer['kstrOOCColor']
end

-- when the Cancel button is clicked
function Killroy:OnCancel()
	self.wndMain:Close() -- hide the window
	self.wndMain:FindChild('bCrossFaction'):SetCheck(not(self.tPrefs['bCrossFaction']))
	self.wndMain:FindChild('bRPOnly'):SetCheck(not(self.tPrefs['bRPOnly']))
	self.wndMain:FindChild('bFormatChat'):SetCheck(not(self.tPrefs['bFormat']))
	self.tColorBuffer['kstrEmoteColor'] = self.tPrefs['kstrEmoteColor'] 
	self.tColorBuffer['kstrSayColor'] = self.tPrefs['kstrSayColor']
	self.tColorBuffer['kstrOOCColor'] = self.tPrefs['kstrOOCColor']
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

-----------------------------------------------------------------------------------------------
-- Killroy Instance
-----------------------------------------------------------------------------------------------
local KillroyInst = Killroy:new()
KillroyInst:Init()
