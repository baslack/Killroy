-----------------------------------------------------------------------------------------------
-- Client Lua Script for Killroy
-- Copyright (c) NCsoft. All rights reserved
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

-- local Killroy = {}
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

local ktDefaultChannels = -- Dont' need this one, doesn't appear in the code you are changing. Togglebutton
{
	[ChatSystemLib.ChatChannel_Command] 		= true,
	[ChatSystemLib.ChatChannel_Debug] 			= true,
	[ChatSystemLib.ChatChannel_Say] 			= true,
	[ChatSystemLib.ChatChannel_Yell] 			= true,
	[ChatSystemLib.ChatChannel_Whisper] 		= true,
	[ChatSystemLib.ChatChannel_Party] 			= true,
	[ChatSystemLib.ChatChannel_Emote] 			= true,
	[ChatSystemLib.ChatChannel_AnimatedEmote] 	= true,
	[ChatSystemLib.ChatChannel_Zone]			= true,
	[ChatSystemLib.ChatChannel_ZonePvP] 		= true,
	[ChatSystemLib.ChatChannel_Trade] 			= true,
	[ChatSystemLib.ChatChannel_Guild] 			= true,
	[ChatSystemLib.ChatChannel_GuildOfficer] 	= true,
	[ChatSystemLib.ChatChannel_WarParty] 		= true,
	[ChatSystemLib.ChatChannel_WarPartyOfficer] = true,
	[ChatSystemLib.ChatChannel_Society] 		= true,
	[ChatSystemLib.ChatChannel_Custom] 			= true,
	[ChatSystemLib.ChatChannel_NPCSay] 			= true,
	[ChatSystemLib.ChatChannel_NPCYell] 		= true,
	[ChatSystemLib.ChatChannel_NPCWhisper] 		= true,
	[ChatSystemLib.ChatChannel_Datachron] 		= true,
	[ChatSystemLib.ChatChannel_Realm] 			= true,
	[ChatSystemLib.ChatChannel_Loot] 			= true,
	[ChatSystemLib.ChatChannel_System] 			= true,
	[ChatSystemLib.ChatChannel_PlayerPath] 		= true,
	[ChatSystemLib.ChatChannel_Instance] 		= true,
	[ChatSystemLib.ChatChannel_Advice] 			= true,
	[ChatSystemLib.ChatChannel_AccountWhisper]	= true,
}

local ktChatResultOutputStrings = -- Dont' need this one, doesn't appear in the code you are changing. Togglebutton
{
	[ChatSystemLib.ChatChannelResult_DoesntExist] 			= Apollo.GetString("CRB_Channel_does_not_exist"),
	[ChatSystemLib.ChatChannelResult_BadPassword] 			= Apollo.GetString("CRB_Channel_password_incorrect"),
	[ChatSystemLib.ChatChannelResult_NoPermissions] 		= Apollo.GetString("CRB_Channel_no_permissions"),
	[ChatSystemLib.ChatChannelResult_NoSpeaking] 			= Apollo.GetString("CRB_Channel_no_speaking"),
	[ChatSystemLib.ChatChannelResult_Muted] 				= Apollo.GetString("CRB_Channel_muted"),
	[ChatSystemLib.ChatChannelResult_Throttled] 			= Apollo.GetString("CRB_Channel_throttled"),
	[ChatSystemLib.ChatChannelResult_NotInGroup] 			= Apollo.GetString("CRB_Not_in_group"),
	[ChatSystemLib.ChatChannelResult_NotInGuild] 			= Apollo.GetString("CRB_Channel_not_in_guild"),
	[ChatSystemLib.ChatChannelResult_NotInSociety] 			= Apollo.GetString("CRB_Channel_not_in_society"),
	[ChatSystemLib.ChatChannelResult_NotGuildOfficer] 		= Apollo.GetString("CRB_Channel_not_guild_officer"),
	[ChatSystemLib.ChatChannelResult_AlreadyMember] 		= Apollo.GetString("ChatLog_AlreadyInChannel"),
	[ChatSystemLib.ChatChannelResult_BadName] 				= Apollo.GetString("ChatLog_InvalidChannel"),
	[ChatSystemLib.ChatChannelResult_NotMember] 			= Apollo.GetString("ChatLog_TargetNotInChannel"),
	[ChatSystemLib.ChatChannelResult_NotInWarParty] 		= Apollo.GetString("ChatLog_NotInWarparty"),
	[ChatSystemLib.ChatChannelResult_NotWarPartyOfficer] 	= Apollo.GetString("ChatLog_NotWarpartyOfficer"),
	[ChatSystemLib.ChatChannelResult_InvalidMessageText] 	= Apollo.GetString("ChatLog_InvalidMessage"),
	[ChatSystemLib.ChatChannelResult_InvalidPasswordText] 	= Apollo.GetString("ChatLog_UseDifferentPassword"),
	[ChatSystemLib.ChatChannelResult_TruncatedText]			= Apollo.GetString("ChatLog_MessageTruncated"),
	[ChatSystemLib.ChatChannelResult_InvalidCharacterName]	= Apollo.GetString("ChatLog_InvalidCharacterName"),
	[ChatSystemLib.ChatChannelResult_GMMuted]				= Apollo.GetString("ChatLog_MutedByGm"),
}

local ktChatActionOutputStrings = -- Dont' need this one, doesn't appear in the code you are changing. Togglebutton
{
	[ChatSystemLib.ChatChannelAction_PassOwner] 		= Apollo.GetString("ChatLog_PassedOwnership"),
	[ChatSystemLib.ChatChannelAction_AddModerator] 		= Apollo.GetString("ChatLog_MadeModerator"),
	[ChatSystemLib.ChatChannelAction_RemoveModerator] 	= Apollo.GetString("ChatLog_MadeMember"),
	[ChatSystemLib.ChatChannelAction_Muted] 			= Apollo.GetString("ChatLog_PlayerMuted"),
	[ChatSystemLib.ChatChannelAction_Unmuted] 			= Apollo.GetString("ChatLog_PlayerUnmuted"),
	[ChatSystemLib.ChatChannelAction_Kicked] 			= Apollo.GetString("ChatLog_PlayerKicked"),
	[ChatSystemLib.ChatChannelAction_AddPassword] 		= Apollo.GetString("ChatLog_PasswordAdded"),
	[ChatSystemLib.ChatChannelAction_RemovePassword] 	= Apollo.GetString("ChatLog_PasswordRemoved")
}

local ktChatJoinOutputStrings = -- Dont' need this one, doesn't appear in the code you are changing. Togglebutton
{
	[ChatSystemLib.ChatChannelResult_BadPassword] 			= Apollo.GetString("CRB_Channel_password_incorrect"),
	[ChatSystemLib.ChatChannelResult_AlreadyMember] 		= Apollo.GetString("ChatLog_AlreadyMember"),
	[ChatSystemLib.ChatChannelResult_BadName]				= Apollo.GetString("ChatLog_BadName"),
	[ChatSystemLib.ChatChannelResult_InvalidPasswordText] 	= Apollo.GetString("ChatLog_InvalidPasswordText"),
	[ChatSystemLib.ChatChannelResult_NoPermissions] 		= Apollo.GetString("CRB_Channel_no_permissions"),
	[ChatSystemLib.ChatChannelResult_TooManyCustomChannels]	= Apollo.GetString("ChatLog_TooManyCustom")
}

local ktDatacubeTypeStrings = -- Dont' need this one, doesn't appear in the code you are changing. Togglebutton
{
	[DatacubeLib.DatacubeType_Datacube]						= Apollo.GetString("ChatLog_Datacube"),
	[DatacubeLib.DatacubeType_Chronicle]					= Apollo.GetString("ChatLog_Chronicle"),
	[DatacubeLib.DatacubeType_Journal]						= Apollo.GetString("ChatLog_Journal")
}

local ktDefaultHolds = {}
ktDefaultHolds[ChatSystemLib.ChatChannel_Whisper] = true

local kcrSayEmoteChar = '*'
local kcrEmoteQuoteChar  = '"'
local kstrEmote = 'emote'
local kstrSay = 'say'
local kstrEmoteColor = 'ffff9900'
local kstrSayColor = 'ffffffff'

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Killroy:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function Killroy:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
	"ChatLog"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Killroy OnLoad
-----------------------------------------------------------------------------------------------
function Killroy:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Killroy.xml")
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "KillroyForm", nil, self)
	self.wndMain:Show(false, true)
	
	--self.xmlDoc:RegisterCallback("OnDocLoaded", self) -- No need for the callback, forms are not big enough to cause lag. Togglebutton
	self:Change_ChatLogOnChatMessage()
	--self:Change_OnRoleplayBtn()
	--self:Change_OnChatInputReturn()
end

-----------------------------------------------------------------------------------------------
-- Killroy Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function Killroy:ParseForContext(strText, eChannelType)
	--[[
	This function will take incoming text and do the following:
	if SAY chat it will look for '*' and segment the string into sub-strings
	if EMOTE chat it will look for '"' and segment the string into substrings
	create an indexed table that will contain a sub-table formated thus:
	{{{string},{format}}...}
	]]--
	
	--[[
		tMessage = {
			{1, "string"}, -- 1 = say type
			{2, "string"}, -- 2 = emote (Keep the information small and easy to process. use the same colors for say and emote in each other)
		}
	]]
	
	local parsedText = {}
	local pT_idx = 1
	
		
	if eChannelType == ChatSystemLib.ChatChannel_Say then
		-- match for emotes
		pattern = '[' .. kcrSayEmoteChar .. '][^' .. kcrSayEmoteChar .. ']*[' .. kcrSayEmoteChar ..']*'
		
		index = 1 --start of string
		length = strText:len()
		
		-- if the string has emotes, parse them
		while strText:find(pattern, index) ~= nil do
			first, last = strText:find(pattern, index)
			-- from index, line starts with an emote
			if first == index then
				parsedText[pT_idx] = {strText:sub(first, last), kstrEmote}
				pT_idx = pT_idx + 1
				index = last + 1
			-- from index, line starts with copy
			else
				parsedText[pT_idx] = {strText:sub(index, (first-1)), kstrSay}
				pT_idx = pT_idx + 1
				parsedText[pT_idx] = {strText:sub(first, last), kstrEmote}
				index = last + 1
				pT_idx = pT_idx + 1
			end			
		end
		
		-- no emotes in string
		if strText:find(pattern, index) == nil then
			parsedText[pT_idx] = {strText:sub(index, length), kstrSay}
		end
		
		--[[
			string.gsub(strText,"%b\"\"", function(strSubString) return "</T>"..kstrSayFormat..strSubString.."</T>"..kstrEmote end)
			
			-- this should replace the quoted substring with the quoted substring surrounded by the correct XML markup. You don't have to use XmlDoc:AppendText, you can take the formatted text and simply use XmlDoc:AddLine() We just ahve to add the openign and closing tags to strText before setting it.
		]]
		
	elseif eChannelType == ChatSystemLib.ChatChannel_Emote then
		-- match for quotes
		pattern = '[' .. kcrEmoteQuoteChar .. '][^' .. kcrEmoteQuoteChar .. ']*[' .. kcrEmoteQuoteChar ..']*'
		
		index = 1 --start of string
		length = strText:len()
		
		-- if the string has quotes, parse them
		while strText:find(pattern, index) ~= nil do
			first, last = strText:find(pattern, index)
			-- from index, line starts with an quote
			if first == index then
				parsedText[pT_idx] = {strText:sub(first, last), kstrSay}
				pT_idx = pT_idx + 1
				index = last + 1
			-- from index, line starts with emote
			else
				parsedText[pT_idx] = {strText:sub(index, (first-1)), kstrEmote}
				pT_idx = pT_idx + 1
				parsedText[pT_idx] = {strText:sub(first, last), kstrSay}
				index = last + 1
				pT_idx = pT_idx + 1
			end			
		end
		
		-- no quotes in string
		if strText:find(pattern, index) == nil then
			parsedText[pT_idx] = {strText:sub(index, length), kstrEmote}
		end
	end
	return parsedText
end

function Killroy:DumpToChat(parsedText, strChatFont, xml)
	for i,t in ipairs(parsedText) do
		if t[2] == kstrEmote then
			xml:AppendText(t[1], kstrEmoteColor, strChatFont)
		else
			xml:AppendText(t[1], kstrSayColor, strChatFont)
		end
	end
	return true
end

function Killroy:Change_ChatLogOnChatMessage()
    local aAddon = Apollo.GetAddon("ChatLog")
    if aAddon == nil then
        return false
    end
    
	function aAddon:OnChatMessage(channelCurrent, tMessage)
		-- tMessage has bAutoResponse, bGM, bSelf, strSender, strRealmName, nPresenceState, arMessageSegments, unitSource, bShowChatBubble, bCrossFaction, nReportId
	
		-- arMessageSegments is an array of tables.  Each table representsa part of the message + the formatting for that segment.
		-- This allows us to signal font (alien text for example) changes mid stream.
		-- local example = arMessageSegments[1]
		-- example.strText is the text
		-- example.bAlien == true if alien font set
		-- example.bRolePlay == true if this is rolePlay Text.  RolePlay text should only show up for people in roleplay mode, and non roleplay text should only show up for people outside it.
	
		-- to use: 	{#}toggles alien on {*}toggles rp on. Alien is still on {!}resets all format codes.
	
		
		local eChannelType = channelCurrent:GetType()
	
		-- Different handling for combat log
		if eChannelType == ChatSystemLib.ChatChannel_Combat then
			-- no formats in combat, roll it all up into one.
			local strMessage = ""
			for idx, tSegment in ipairs(tMessage.arMessageSegments) do
				strMessage = strMessage .. tSegment.strText
			end
			self:QueueAChatLine(strMessage, eChannelType)
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
		elseif eChannelType == ChatSystemLib.ChatChannel_AccountWhisper then
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
							if not tMessage.bSelf then
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
	
		end
	
		-- We build strings backwards, right to left
		if eChannelType == ChatSystemLib.ChatChannel_AnimatedEmote then -- emote animated channel gets special formatting
			xml:AddLine(strTime, crChannel, self.strFontOption, "Left")
	
		elseif eChannelType == ChatSystemLib.ChatChannel_Emote then -- emote channel gets special formatting
			xml:AddLine(strTime, crChannel, self.strFontOption, "Left")
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
				strChannel = String_GetWeaselString(Apollo.GetString("ChatLog_GuildCommand"), channelCurrent:GetName(), channelCurrent:GetCommand())
			else
				strChannel = String_GetWeaselString(Apollo.GetString("CRB_Brackets_Space"), channelCurrent:GetName())
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
	
		local xmlBubble = XmlDoc.new() -- This is the speech bubble form
		xmlBubble:AddLine("", crChannel, self.strFontOption, "Center")
	
		local bHasVisibleText = false
		for idx, tSegment in ipairs( tMessage.arMessageSegments ) do
			local strText = tSegment.strText
			--[[
			Second half of this line commented out to remove cross faction filtering. bs:041214
			]]--
			local bAlien = tSegment.bAlien -- or tMessage.bCrossFaction
			local bShow = false
	
			if self.eRoleplayOption == 3 then
				bShow = not tSegment.bRolePlay
			elseif self.eRoleplayOption == 2 then
				-- Force say and emote to IC
				if eChannelType == ChatSystemLib.ChatChannel_Say or eChannelType == ChatSystemLib.ChatChannel_Emote then
					tSegment.bRolePlay = true
				end
				-- Catch Whispers
				if eChannelType == ChatSystemLib.ChatChannel_Whisper or eChannelType==ChatSystemLib.ChatChannel_AccountWhisper then
					bShow = true
				else
					bShow = tSegment.bRolePlay
				end
				--[[
				This original line is commented out to replace with Killroy functionality, bs:041214
				bShow = tSegment.bRolePlay
				]]--
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
					crChatText = ApolloColor.new("cyan")
					crBubbleText = ApolloColor.new("cyan")
	
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
					-- This is to location to substitute in our replacement for what it sends to chat. bs: 042314
					--xml:AppendText(strText, crChatText, strChatFont) original send to xml line
					if (eChannelType == ChatSystemLib.ChatChannel_Say) or (eChannelType == ChatSystemLib.ChatChannel_Emote) then
						parsedText = Killroy:ParseForContext(strText, eChannelType)
						Killroy:DumpToChat(parsedText, strChatFont, xml)
					else
						xml:AppendText(strText, crChatText, strChatFont)
					end
				else
					local strLinkIndex = tostring( self:HelperSaveLink(tLink) )
					-- append text can only save strings as attributes.
					xml:AppendText(strText, crChatText, strChatFont, {strIndex=strLinkIndex} , "Link")
				end
	
				if (eChannelType == ChatSystemLib.ChatChannel_Say) or (eChannelType == ChatSystemLib.ChatChannel_Emote) then
					parsedText = Killroy:ParseForContext(strText, eChannelType)
					Killroy:DumpToChat(parsedText, strBubbleFont, xmlBubble)
				else
					xmlBubble:AppendText(strText, crBubbleText, strBubbleFont) -- Format for bubble; regular
				end
				bHasVisibleText = bHasVisibleText or self:HelperCheckForEmptyString(strText)
			end
		end
	
		if bHasVisibleText then
			if tMessage.unitSource and tMessage.bShowChatBubble then
				tMessage.unitSource:AddTextBubble(xmlBubble)
			end
	
			self:QueueAChatLine(xml, eChannelType)
		end
	end
	return true
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
			--[[
			--disabled auto insertion of RP marker. bs: 041814
			if self.eRoleplayOption == 2 then
				wndChat:FindChild("Input"):SetText(Apollo.GetString("ChatLog_RPMarker"))
			else
				wndChat:FindChild("Input"):SetText("")
			end
			]]--
			wndChat:FindChild("Input"):SetText("")
		end
	end
	return true
end

function Killroy:Change_OnChatInputReturn()
	local aAddon = Apollo.GetAddon('ChatLog')
	if aAddon == nil then
		return false
	end
	
	function aAddon:OnChatInputReturn(wndHandler, wndControl, strText)

		if wndControl:GetName() == "Input" then
			local wndForm = wndControl:GetParent()
			strText = self:HelperReplaceLinks(strText, wndControl:GetAllLinks())

			local wndInput = wndForm:FindChild("Input")

			wndControl:SetText("")
			--[[
			if self.eRoleplayOption == 2 then
				wndControl:SetText(Apollo.GetString("ChatLog_RPMarker"))
			end
			]]--

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



-----------------------------------------------------------------------------------------------
-- KillroyForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function Killroy:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function Killroy:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- Killroy Instance
-----------------------------------------------------------------------------------------------
local KillroyInst = Killroy:new()
KillroyInst:Init()
