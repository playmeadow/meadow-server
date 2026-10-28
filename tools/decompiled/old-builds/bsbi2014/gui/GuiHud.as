package gui
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class GuiHud extends MovieClip
   {
      
      public var charWindow:MovieClip;
      
      public var charNameTxt:TextField;
      
      public var safeChatTreeWindow:MovieClip;
      
      public var swapBtn:MovieClip;
      
      public var actionsWindow:MovieClip;
      
      public var emotesWindow:MovieClip;
      
      public var chatBar:MovieClip;
      
      public var sendChatBtn:MovieClip;
      
      public var ansChatBtn:MovieClip;
      
      public var chatTxt:TextField;
      
      public var chatHist:MovieClip;
      
      public var chatHistUpDownBtn:MovieClip;
      
      public var chatHistTxt:TextField;
      
      public var chatRepeatBtn:MovieClip;
      
      public var chatRepeatWindow:MovieClip;
      
      public var editCharBtn:MovieClip;
      
      public var actionsBtn:MovieClip;
      
      public var safeChatBtn:MovieClip;
      
      public var emotesBtn:MovieClip;
      
      public var denBtn:MovieClip;
      
      public var worldMapBtn:MovieClip;
      
      public var soundBtn:MovieClip;
      
      public var furnBtn:MovieClip;
      
      public var eCardBtn:MovieClip;
      
      public var buddyListBtn:MovieClip;
      
      public var newsBtn:MovieClip;
      
      public var awardsBtn:MovieClip;
      
      public var gemsBtn:MovieClip;
      
      public var reportBtn:MovieClip;
      
      public var mySettingsBtn:MovieClip;
      
      public var zoneName:MovieClip;
      
      public var zoneNameTxt:TextField;
      
      public var eCardCount:MovieClip;
      
      public var eCardCountTxt:TextField;
      
      public var partyBtn:MovieClip;
      
      public var playerWallBtn:MovieClip;
      
      public var combatCardDeckBtn:MovieClip;
      
      public var questExitBtn:MovieClip;
      
      public var questPlayersBtn:MovieClip;
      
      public var questObjectiveTxt:TextField;
      
      public var mainBlock:MovieClip;
      
      public var gemsBtnBlock:MovieClip;
      
      public var charWindowBlock:MovieClip;
      
      private var append:String;
      
      public function GuiHud()
      {
         super();
         this.init();
      }
      
      public function init(inGame:Boolean = false) : void
      {
         this.append = currentFrameLabel == "quest" ? "Quest" : "";
         this.charWindow = this["char"];
         this.charNameTxt = this["text01_charName"];
         this.safeChatTreeWindow = this["safeChatTree" + this.append];
         this.actionsWindow = this["actionWindow" + this.append];
         this.emotesWindow = this["emoteWindow" + this.append];
         this.chatBar = this["hud01_chat" + this.append];
         this.sendChatBtn = this.chatBar != null ? this.chatBar.but01_send : null;
         this.ansChatBtn = this.chatBar != null ? this.chatBar.but01_ans : null;
         this.chatTxt = this.chatBar != null ? this.chatBar.text01_chat : null;
         this.chatHist = this["chat" + this.append];
         this.chatHistUpDownBtn = this.chatHist != null ? this.chatHist.chatHistoryBG.chatHistBox.hud01_chatHistory.chatUpDown : null;
         this.chatHistTxt = this.chatHist != null ? this.chatHist.chatHistoryBG["chatHistoryTxtCont" + this.append].text01_chatHistory : null;
         this.chatRepeatBtn = this["chatRepeat" + this.append];
         this.chatRepeatWindow = this["chatRepeatWindow" + this.append];
         this.swapBtn = this["swap"];
         this.actionsBtn = this["anim" + this.append];
         this.safeChatBtn = this["speedChat" + this.append];
         this.emotesBtn = this["emote" + this.append];
         this.denBtn = this["home"];
         this.worldMapBtn = this["world"];
         this.soundBtn = this["sound_btn" + this.append];
         this.furnBtn = this["furnBtn"];
         this.eCardBtn = this["mail"];
         this.buddyListBtn = this["buddyList"];
         this.newsBtn = this["news"];
         this.awardsBtn = this["trophy"];
         this.gemsBtn = this["money"];
         this.reportBtn = this["report"];
         this.mySettingsBtn = this["mySettings"];
         this.zoneName = this["zoneName"];
         this.zoneNameTxt = this.zoneName != null ? this.zoneName.mouse.name_txt : null;
         this.eCardCount = this.eCardBtn != null ? this.eCardBtn.newEcardCount : null;
         this.eCardCountTxt = this.eCardCount != null ? this.eCardCount.eCardCountTxt : null;
         this.mainBlock = this["mainBlock"];
         this.gemsBtnBlock = this["gemsBtnBlock"];
         this.charWindowBlock = this["charWindowBlock"];
         this.partyBtn = this["party"];
         this.playerWallBtn = this["playerWall"];
         this.combatCardDeckBtn = this["cardDeck_btn"];
         this.questExitBtn = this["questingExit_btn" + this.append];
         this.questPlayersBtn = this["questPlayersBtn"];
         if(this["objBar"] != null)
         {
            this.questObjectiveTxt = this["objBar"].objTxt;
         }
         if(!inGame)
         {
            if(!(Boolean(this.eCardBtn) && Boolean(this.buddyListBtn) && Boolean(this.newsBtn) && Boolean(this.awardsBtn) && Boolean(this.gemsBtn) && Boolean(this.zoneName) && Boolean(this.mySettingsBtn) && Boolean(this.reportBtn) && Boolean(this.playerWallBtn)))
            {
               throw new Error("GuiHud TOP BAR section is missing parts or they are named incorrectly!");
            }
            if(!(this.swapBtn && this.actionsBtn && this.safeChatBtn && this.emotesBtn && this.denBtn && this.worldMapBtn && this.soundBtn && this.charNameTxt && Boolean(this.eCardCount) && this.eCardCountTxt))
            {
               throw new Error("GuiHud MAIN BUTTONS section is missing parts or they are named incorrectly!");
            }
            if(!(Boolean(this.actionsWindow) && Boolean(this.safeChatTreeWindow) && Boolean(this.emotesWindow) && Boolean(this.charWindow)))
            {
               throw new Error("GuiHud WINDOWS section is missing parts or they are named incorrectly!");
            }
            if(!(Boolean(this.zoneName) && Boolean(this.zoneName.mouse.mid) && Boolean(this.zoneName.mouse.left) && Boolean(this.zoneName.mouse.right)))
            {
               throw new Error("GuiHud ZONE NAME section is missing parts or they are named incorrectly!");
            }
            if(!(Boolean(this.chatBar) && Boolean(this.sendChatBtn) && Boolean(this.ansChatBtn) && this.chatTxt))
            {
               throw new Error("GuiHud CHAT BAR section is missing parts or they are named incorrectly!");
            }
            if(!(this.chatHist && this.chatHistUpDownBtn && this.chatHistTxt && Boolean(this.chatRepeatBtn) && this.chatRepeatWindow))
            {
               throw new Error("GuiHud CHAT HISTORY section is missing parts or they are named incorrectly!");
            }
            if(!(Boolean(this.mainBlock) && Boolean(this.gemsBtnBlock) && Boolean(this.charWindowBlock)))
            {
               throw new Error("GuiHud BLOCK section is missing parts or they are named incorrectly!");
            }
         }
      }
   }
}

