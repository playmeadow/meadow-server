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
      
      public function init(initScriptDefId:int, initCloseCallback:Function) : void
      {
         if(Boolean(GuiManager.chatHist))
         {
            GuiManager.chatHist.removeEmotesFromChatRepeat();
         }
         this._savedParams = [];
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = initCloseCallback;
         this._scriptDefId = initScriptDefId;
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
      
      public function handleWaitResponse(params:Object) : void
      {
         var userList:Array = null;
         if(Boolean(this._popup))
         {
            if(Boolean(this._waitingAvatarWindows))
            {
               this._waitingAvatarWindows.destroy();
               this._waitingAvatarWindows = null;
            }
            userList = params.slice(2);
            this._waitingAvatarWindows = new WindowGenerator();
            this._waitingAvatarWindows.init(1,4,userList.length,0,0,0,ItemWindowCustPlayers,params.slice(2),"",{
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
            this._inParamsWaiting = params;
         }
      }
      
      public function updateDisplayIndex(mainHudHigher:Boolean = true) : void
      {
         var mainHudIndex:int = GuiManager.guiLayer.getChildIndex(GuiManager.mainHud);
         var myIndex:int = this._popup.parent.getChildIndex(this._popup);
         if(mainHudHigher)
         {
            if(mainHudIndex < myIndex)
            {
               this._popup.parent.setChildIndex(this._popup,mainHudIndex);
            }
         }
         else if(mainHudIndex > myIndex)
         {
            this._popup.parent.setChildIndex(this._popup,mainHudIndex);
         }
      }
      
      private function onMediaLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            GuiManager.mainHud.emotesBtn.activateGrayState(true);
            DarkenManager.showLoadingSpiral(false);
            this._popup = MovieClip(img.getChildAt(0));
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
         if(Boolean(this._windowScrollbar))
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
      
      private function onWindowDown(evt:MouseEvent) : void
      {
         var player:Object = null;
         evt.stopPropagation();
         if(evt.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            player = {
               "userName":evt.currentTarget.userName,
               "onlineStatus":true
            };
            BuddyCard.showBuddyCard(player);
         }
      }
      
      private function onWindowOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            evt.currentTarget.char.gotoAndStop("over");
            evt.currentTarget.showXBtn(true);
         }
      }
      
      private function onWindowOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.char.gotoAndStop("up");
         if(evt.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            evt.currentTarget.showXBtn(false);
         }
      }
      
      private function onKickPlayerBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         QuestXtCommManager.sendQuestPrivateKick(evt.currentTarget.parent.parent.userName);
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onPopupOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.updateDisplayIndex(false);
      }
      
      private function onCloseBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         QuestXtCommManager.sendQuestJoinCancel();
         this.close();
      }
      
      private function onPlayBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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

