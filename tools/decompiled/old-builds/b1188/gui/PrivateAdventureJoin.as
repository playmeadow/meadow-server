package gui
{
   import avatar.AvatarManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import quest.QuestXtCommManager;
   
   public class PrivateAdventureJoin
   {
      
      private const MEDIA_ID:int = 2300;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _savedParams:Array;
      
      private var _inParamsWaiting:Object;
      
      private var _waitingAvatarWindows:WindowGenerator;
      
      private var _windowScrollbar:SBScrollbar;
      
      private var _scriptDefId:int;
      
      public function PrivateAdventureJoin()
      {
         super();
      }
      
      public function init(param1:int, param2:Function) : void
      {
         if(GuiManager.chatHist)
         {
            GuiManager.chatHist.removeEmotesFromChatRepeat();
         }
         this._savedParams = [];
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = param2;
         this._scriptDefId = param1;
         DarkenManager.showLoadingSpiral(true);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this.MEDIA_ID,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         GuiManager.grayOutHudItemsForPrivateLobby(false);
         GuiManager.mainHud.emotesBtn.activateGrayState(false);
         this.removeEventListeners();
         this._mediaHelper.destroy();
         this._mediaHelper = null;
         this._guiLayer.removeChild(this._popup);
      }
      
      public function handleWaitResponse(param1:Object) : void
      {
         var _loc2_:Array = null;
         if(this._popup)
         {
            if(this._waitingAvatarWindows)
            {
               this._waitingAvatarWindows.destroy();
               this._waitingAvatarWindows = null;
            }
            _loc2_ = param1.slice(2);
            this._waitingAvatarWindows = new WindowGenerator();
            this._waitingAvatarWindows.init(1,4,_loc2_.length,0,0,0,ItemWindowCustPlayers,param1.slice(2),"",{
               "mouseDown":this.onWindowDown,
               "mouseOver":this.onWindowOver,
               "mouseOut":this.onWindowOut,
               "memberOnlyMouseDown":null
            },{
               "onBxBtn":this.onKickPlayerBtn,
               "scriptDefId":this._scriptDefId
            },this.onWindowLoaded,false,false);
         }
         else
         {
            this._inParamsWaiting = param1;
         }
      }
      
      public function updateDisplayIndex(param1:Boolean = true) : void
      {
         var _loc2_:int = GuiManager.guiLayer.getChildIndex(GuiManager.mainHud);
         var _loc3_:int = this._popup.parent.getChildIndex(this._popup);
         if(param1)
         {
            if(_loc2_ < _loc3_)
            {
               this._popup.parent.setChildIndex(this._popup,_loc2_);
            }
         }
         else if(_loc2_ > _loc3_)
         {
            this._popup.parent.setChildIndex(this._popup,_loc2_);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            GuiManager.mainHud.emotesBtn.activateGrayState(true);
            DarkenManager.showLoadingSpiral(false);
            this._popup = MovieClip(param1.getChildAt(0));
            this.addEventListeners();
            this._popup.x = this._popup.width * 0.5;
            this._popup.y = MainFrame.VIEW_HEIGHT * 0.5 - 20;
            this._guiLayer.addChild(this._popup);
            GuiManager.closeAnyHudPopups();
            if(this._inParamsWaiting != null)
            {
               this.handleWaitResponse(this._inParamsWaiting);
               this._inParamsWaiting = null;
            }
            else
            {
               this._waitingAvatarWindows = new WindowGenerator();
               this._waitingAvatarWindows.init(1,4,1,0,0,0,ItemWindowCustPlayers,[AvatarManager.playerSfsUserId],"",{
                  "mouseDown":this.onWindowDown,
                  "mouseOver":this.onWindowOver,
                  "mouseOut":this.onWindowOut,
                  "memberOnlyMouseDown":null
               },{"onBxBtn":this.onKickPlayerBtn},this.onWindowLoaded,false,false);
            }
         }
      }
      
      private function onWindowLoaded() : void
      {
         if(this._popup.playerWindow.numChildren > 0)
         {
            this._popup.playerWindow.removeChildAt(0);
         }
         this._popup.playerWindow.addChild(this._waitingAvatarWindows);
         if(this._windowScrollbar)
         {
            this._windowScrollbar.destroy();
            this._windowScrollbar = null;
         }
         this._windowScrollbar = new SBScrollbar();
         this._windowScrollbar.init(this._waitingAvatarWindows,this._waitingAvatarWindows.width,this._waitingAvatarWindows.boxHeight * 4 + 0 * 4 + 0 * 2,10,"scrollbar2",this._waitingAvatarWindows.boxHeight + 0);
      }
      
      private function close() : void
      {
         if(this._closeCallback != null)
         {
            this._closeCallback(false);
            this._closeCallback = null;
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onWindowDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(param1.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            _loc2_ = {
               "userName":param1.currentTarget.userName,
               "onlineStatus":true
            };
            BuddyCard.showBuddyCard(_loc2_);
         }
      }
      
      private function onWindowOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            param1.currentTarget.char.gotoAndStop("over");
            param1.currentTarget.showXBtn(true);
         }
      }
      
      private function onWindowOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.char.gotoAndStop("up");
         if(param1.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            param1.currentTarget.showXBtn(false);
         }
      }
      
      private function onKickPlayerBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestPrivateKick(param1.currentTarget.parent.parent.userName);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPopupOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.updateDisplayIndex(false);
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestJoinCancel();
         this.close();
      }
      
      private function onPlayBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestStartRequest();
         this.close();
      }
      
      private function addEventListeners() : void
      {
         this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._popup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
         this._popup.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
         this._popup.addEventListener(MouseEvent.MOUSE_OVER,this.onPopupOver,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._popup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._popup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn);
         this._popup.playBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn);
         this._popup.removeEventListener(MouseEvent.MOUSE_OVER,this.onPopupOver);
      }
   }
}

