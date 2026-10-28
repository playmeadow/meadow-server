package gui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
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
      
      public function EmoticonManager(param1:Function, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:Sprite, param6:MovieClip, param7:MovieClip, param8:Boolean = true)
      {
         super();
         this._useMemberOnlyEmotes = param8;
         this.setEmoteCallback = param1;
         this.emoteBtn = param2;
         this.emoteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.emoteBtnDownHandler,false,0,true);
         this.emoteWindow = param3;
         this.addAllEmotes();
         this.emoteWindow.visible = false;
         this.actionBtn = param4;
         this.actionWindow = param5;
         this.safeChatBtn = param6;
         this.safeChatTree = param7;
         this.emoteBtnsBg = GETDEFINITIONBYNAME("emo_mouse");
         this.emoteWindow.addChild(this.emoteBtnsBg);
         this.emoteBtnsBg.visible = false;
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:Sprite, param5:MovieClip, param6:MovieClip) : void
      {
         if(this.emoteBtn)
         {
            this.emoteBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.emoteBtnDownHandler);
         }
         this.emoteBtn = param1;
         this.emoteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.emoteBtnDownHandler,false,0,true);
         this.emoteWindow = param2;
         this.emoteWindow.addChild(this._emotes);
         this.emoteWindow.addChild(this.emoteBtnsBg);
         this.emoteWindow.visible = false;
         this.actionBtn = param3;
         this.actionWindow = param4;
         this.safeChatBtn = param5;
         this.safeChatTree = param6;
         this.emoteBtnsBg.visible = false;
         this.resetEmotePrivs();
      }
      
      public function resetEmotePrivs() : void
      {
         if(gMainFrame.userInfo.isMember)
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
            if(gMainFrame.userInfo.isMember)
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
      
      public function closeEmotes(param1:Boolean = false) : void
      {
         if(this.emoteWindow.visible)
         {
            this.emoteWindow.visible = false;
            this.brightenEmotes();
            if(!param1)
            {
               this.emoteBtn.downToUpState();
            }
         }
      }
      
      private function emoteBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(this.emoteWindow.visible)
            {
               this.closeEmotes(true);
            }
            else
            {
               if(Boolean(this.safeChatTree) && this.safeChatTree.visible)
               {
                  this.safeChatBtn.dispatchEvent(param1);
               }
               if(Boolean(this.actionWindow) && this.actionWindow.visible)
               {
                  this.actionBtn.dispatchEvent(param1);
               }
               this.openEmotes();
            }
         }
      }
      
      private function smileyClickHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this.emoteBtn.isGray)
         {
            EmoticonUtility.handleSmileyClick(param1.target,this.setEmoteCallback);
            this.emoteBtn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
            AJAudio.playSubMenuBtnClick();
         }
      }
      
      private function smileyRollOverHandler(param1:MouseEvent) : void
      {
         if(param1.target is MovieClip)
         {
            MovieClip(param1.target).gotoAndPlay(1);
         }
         AJAudio.playSubMenuBtnRollover();
         this.emoteWindow.setChildIndex(this.emoteBtnsBg,1);
         this.emoteBtnsBg.x = param1.currentTarget.x;
         this.emoteBtnsBg.y = param1.currentTarget.y;
         this.emoteBtnsBg.visible = true;
      }
      
      private function smileyRollOutHandler(param1:MouseEvent) : void
      {
         this.emoteBtnsBg.visible = false;
      }
   }
}

