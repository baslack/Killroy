Killroy
=======

Current Release: 1-5-19-8

[Manual available here!](http://www.wildstar-roleplay.com/forum/m/11410152/viewthread/16453255-documentation-killroy-manual/page/1)

Killroy is a ChatLog modification for roleplayers in Wildstar. It has several features that make roleplay easier. The current feature list includes the following:

* Cross-faction Chat
* Asterisk Emote, Emote Quotes, and OOC Bracket chat color formatting in any channel.
* Auto Insertion of the Carbine RP Chat Marker {*} in RP Only mode
* A customizable Range Filter that reduces the distance say chat and emotes are received, with a soft falloff and occlusion detection.
* Customizable Chat Colors
* Fixes a ChatLog  bug that prevents muting of individual custom chat channels and circles (CustomChatColors required for this fix.)
* 500+ character sends, with "chunking" into multiple sends.
* Inline Target (%t) insertion in your chat.
* Inline Emotes, {<youremote>}, that allow you to play animated emotes as you chat in say or emote.
* Command Line access. /kl for usage prompt.
* Per Channel RP Filter Settings
* Custom Fonts in Chat and Chat Bubbles
* Override and Restoration of all ChatLog Settings
* Kills Chat Line Fade Timer
* Mention Highlighting in RP channels
* Shows Circle Commands and Chat Channel Commands in Channel Names

**Killroy requires the Carbine ChatLog Addon.** It will not play well with any addon that replaces ChatLog or overrides ChatLog's methods. Killroy works by modifying ChatLog. If another addon modifies the same code, there will be conflicts which may not be immediately apparent.

---

**ChatLog and "RP Only" mode**

Carbine's ChatLog addon has a built in feature for filtering RP Chat from regular OOC chat. It's kind of hidden away and difficult to use by default. Killroy makes it easier by auto inserting the RP marker in your chat stream, but you can still confuse folks if you don't know what you're doing.

There are three settings for ChatLog's RP Filter: Both, RP Only and No RP. Every chat you send in Wildstar gets tagged by the system with a collection of variables. One of those variables tells the UI whether or not your chat is RP. The filter then either excludes no RP chat, excludes RP chat, or allows both. To tag your chat as RP chat you need to use the characters below (unless of course you're using Killroy with ChatLog in RP Only mode.)

Keep in mind that most folks aren't going to notice or bother with the RP filter, so the majority will only see your chat in the default (NoRP) mode. Taking that into account, the RP Filter is best used when you want some privacy and have agreed with your RP friends to use it.

ChatLog formatting characters:

```
"{#}": Forces input into the "alien" font.  
"{*}": Forces input into "roleplay" mode.  
"{!}": Removes special formatting from what comes after it.
```

Example:

```
/s {*} Mary had a {!} little lamb, its {#} fleece was white {!} as snow.
```

Would send "Mary had a" to the chat as RP text, "little lamb, its" as regular chat, "fleece was white" as alien text and "as snow" as regular text.



Killroy is offered as is, with no warranty expressed our implied. Errors can be reported via [GITHUB](http://github.com/baslack/Killroy/) or [Curse](http://www.curse.com/ws-addons/wildstar/220130-scchatlog). Killroy is offered completely open source. Chat addon developers are encouraged to fork the project and or include it with their own modifications to enhance their addon. I however do not have the time nor inclination to keep pace with all the addon developers out there, so please do not request me to do so.

Questions and change requests to me, Scriptorium, [iam@nimajneb.com](mailto:iam@nimajneb.com)
