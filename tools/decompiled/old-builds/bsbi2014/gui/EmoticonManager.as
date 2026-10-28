package gui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   
   public class EmoticonManager
   {
      
      private const EMOTEWINDOW_DIM_ALPHA:Number = 0.5;
      
      private const EMOTEWINDOW_BRIGHT_ALPHA:Number = 1;
      
      private var emoteBtn:MovieClip;
      
      private var emoteWindow:MovieClip;
      
      private var emoteBtnsBg:Sprite;
      
      private var actionBtn:MovieClip;
      
      private var actionWindow:Sprite;
      
      private var safeChatBtn:MovieClip;
      
      private var safeChatTree:MovieClip;
      
      private var setEmoteCallback:Function;
      
      private var _useMemberOnlyEmotes:Boolean;
      
      private var _emotes:MovieClip;
      
      public function EmoticonManager(emoteCallbackRef:Function, emoticonBtn:MovieClip, emoticonWindow:MovieClip, actBtn:MovieClip, actWindow:Sprite, safeChatButton:MovieClip, safeChatTreeGui:MovieClip, useMemberOnlyEmotes:Boolean = true)
      {
         super();
         this._useMemberOnlyEmotes = useMemberOnlyEmotes;
         this.setEmoteCallback = emoteCallbackRef;
         this.emoteBtn = emoticonBtn;
         this.emoteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.emoteBtnDownHandler,false,0,true);
         this.emoteWindow = emoticonWindow;
         this.addAllEmotes();
         this.emoteWindow.visible = false;
         this.actionBtn = actBtn;
         this.actionWindow = actWindow;
         this.safeChatBtn = safeChatButton;
         this.safeChatTree = safeChatTreeGui;
         this.emoteBtnsBg = GETDEFINITIONBYNAME("emo_mouse");
         this.emoteWindow.addChild(this.emoteBtnsBg);
         this.emoteBtnsBg.visible = false;
         LocalizationManager.translateId(emoticonWindow.titleTxt,6308);
      }
      
      public function reload(initEmoteBtn:MovieClip, emoticonWindow:MovieClip, actBtn:MovieClip, actWindow:Sprite, safeChatButton:MovieClip, safeChatTreeGui:MovieClip) : void
      {
         if(Boolean(this.emoteBtn))
         {
            this.emoteBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.emoteBtnDownHandler);
         }
         this.emoteBtn = initEmoteBtn;
         this.emoteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.emoteBtnDownHandler,false,0,true);
         this.emoteWindow = emoticonWindow;
         this.emoteWindow.addChild(this._emotes);
         this.emoteWindow.addChild(this.emoteBtnsBg);
         this.emoteWindow.visible = false;
         this.actionBtn = actBtn;
         this.actionWindow = actWindow;
         this.safeChatBtn = safeChatButton;
         this.safeChatTree = safeChatTreeGui;
         this.emoteBtnsBg.visible = false;
         this.resetEmotePrivs();
         LocalizationManager.translateId(emoticonWindow.titleTxt,6308);
         this.emoteBtn.downToUpState();
      }
      
      public function resetEmotePrivs() : void
      {
         if(Boolean(gMainFrame.userInfo.isMember))
         {
            this.emoteWindow.locked.visible = false;
         }
         else
         {
            this.emoteWindow.locked.visible = true;
         }
      }
      
      private function addAllEmotes() : void
      {
         this._emotes = EmoticonUtility.setupEmotes(this.emoteWindow,this._useMemberOnlyEmotes,this.smileyClickHandler,this.smileyRollOverHandler,this.smileyRollOutHandler);
         this.emoteWindow.addChild(this._emotes);
         if(this.emoteWindow.hasOwnProperty("locked"))
         {
            this.emoteWindow.setChildIndex(this.emoteWindow.locked,this.emoteWindow.numChildren - 1);
            this.emoteWindow.locked.mouseChidren = false;
            this.emoteWindow.locked.mouseEnabled = false;
            if(Boolean(gMainFrame.userInfo.isMember))
            {
               this.emoteWindow.locked.visible = false;
            }
            else
            {
               this.emoteWindow.locked.visible = true;
            }
         }
      }
      
      public function destroy() : void
      {
         this.setEmoteCallback = null;
         this.emoteBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.emoteBtnDownHandler);
         this.emoteBtn = null;
         this.emoteWindow.visible = false;
         this.emoteWindow = null;
         this.actionBtn = null;
         this.actionWindow = null;
         this.safeChatBtn = null;
         this.safeChatTree = null;
      }
      
      public function openEmotes() : void
      {
         if(!this.emoteWindow.visible)
         {
            this.emoteWindow.visible = true;
            this.emoteWindow.gotoAndPlay(1);
            this.brightenEmotes();
         }
      }
      
      public function dimEmotes() : void
      {
         if(this.emoteWindow.visible && this.emoteWindow.alpha != this.EMOTEWINDOW_DIM_ALPHA)
         {
            this.emoteWindow.alpha = this.EMOTEWINDOW_DIM_ALPHA;
         }
      }
      
      public function brightenEmotes() : void
      {
         if(this.emoteWindow.alpha != this.EMOTEWINDOW_BRIGHT_ALPHA)
         {
            this.emoteWindow.alpha = this.EMOTEWINDOW_BRIGHT_ALPHA;
         }
      }
      
      public function closeEmotes(fromBtnEvent:Boolean = false) : void
      {
         if(this.emoteWindow.visible)
         {
            this.emoteWindow.visible = false;
            this.brightenEmotes();
            if(!fromBtnEvent)
            {
               this.emoteBtn.downToUpState();
            }
         }
      }
      
      private function emoteBtnDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
         {
            if(this.emoteWindow.visible)
            {
               this.closeEmotes(true);
            }
            else
            {
               if(Boolean(this.safeChatTree) && this.safeChatTree.visible)
               {
                  this.safeChatBtn.dispatchEvent(m);
               }
               if(Boolean(this.actionWindow) && this.actionWindow.visible)
               {
                  this.actionBtn.dispatchEvent(m);
               }
               this.openEmotes();
            }
         }
      }
      
      private function smileyClickHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!this.emoteBtn.isGray)
         {
            EmoticonUtility.handleSmileyClick(m.target,this.setEmoteCallback);
            this.emoteBtn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
            AJAudio.playSubMenuBtnClick();
         }
      }
      
      private function smileyRollOverHandler(m:MouseEvent) : void
      {
         if(m.target is MovieClip)
         {
            MovieClip(m.target).gotoAndPlay(1);
         }
         AJAudio.playSubMenuBtnRollover();
         this.emoteWindow.setChildIndex(this.emoteBtnsBg,1);
         this.emoteBtnsBg.x = m.currentTarget.x;
         this.emoteBtnsBg.y = m.currentTarget.y;
         this.emoteBtnsBg.visible = true;
      }
      
      private function smileyRollOutHandler(m:MouseEvent) : void
      {
         this.emoteBtnsBg.visible = false;
      }
   }
}

