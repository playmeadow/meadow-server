package gui
{
   import com.sbi.analytics.SBTracker;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class PlayerEngagement
   {
      
      private var _engagementMediaHelper:MediaHelper;
      
      private var _closeCallBack:Function;
      
      private var _engagementPopup:MovieClip;
      
      private var _currShardId:int;
      
      public function PlayerEngagement()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         this._currShardId = RoomManagerWorld.instance.shardId;
         this._engagementMediaHelper = new MediaHelper();
         this._engagementMediaHelper.init(1567,this.onEngagementLoaded);
         this._closeCallBack = param1;
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         this.removeEventListeners();
         DarkenManager.unDarken(this._engagementPopup);
         GuiManager.guiLayer.removeChild(this._engagementPopup);
         this._engagementPopup = null;
         if(this._closeCallBack != null)
         {
            this._closeCallBack(param1);
            this._closeCallBack = null;
         }
      }
      
      private function onEngagementLoaded(param1:MovieClip) : void
      {
         this._engagementMediaHelper.destroy();
         this._engagementPopup = MovieClip(param1.getChildAt(0));
         this._engagementPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._engagementPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         GuiManager.guiLayer.addChild(this._engagementPopup);
         this._engagementPopup.gotoAndStop("new");
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(this._engagementPopup);
         this.addEventListeners();
      }
      
      private function onDenBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#den",-1,SBTracker.TYPE_EVENT);
         DenXtCommManager.requestDenJoinFull("den" + gMainFrame.userInfo.myUserName);
         this.destroy();
      }
      
      private function onVideoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#video",-1,SBTracker.TYPE_EVENT);
         RoomXtCommManager.sendNonDenRoomJoinRequest("sarepia.movie_theater#" + this._currShardId);
         this.destroy();
      }
      
      private function onShoppingBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#shopping",-1,SBTracker.TYPE_EVENT);
         RoomXtCommManager.sendNonDenRoomJoinRequest("jamaa_township.clothes_shop#" + this._currShardId);
         this.destroy();
      }
      
      private function onGamesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#games",-1,SBTracker.TYPE_EVENT);
         RoomXtCommManager.sendNonDenRoomJoinRequest("jamaa_township.room_arcade#" + this._currShardId);
         this.destroy();
      }
      
      private function onAdventureBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#adventure",-1,SBTracker.TYPE_EVENT);
         RoomXtCommManager.sendNonDenRoomJoinRequest("adventures.queststaging_0_360#" + RoomManagerWorld.instance.shardId);
         this.destroy();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#close",-1,SBTracker.TYPE_EVENT);
         this.destroy();
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         this._engagementPopup.denBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDenBtn,false,0,true);
         if(this._engagementPopup.videoBtn)
         {
            this._engagementPopup.videoBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onVideoBtn,false,0,true);
         }
         if(this._engagementPopup.shoppingBtn)
         {
            this._engagementPopup.shoppingBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onShoppingBtn,false,0,true);
         }
         this._engagementPopup.gamesBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onGamesBtn,false,0,true);
         this._engagementPopup.advBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAdventureBtn,false,0,true);
         this._engagementPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
         this._engagementPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._engagementPopup.denBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDenBtn);
         if(this._engagementPopup.videoBtn)
         {
            this._engagementPopup.videoBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onVideoBtn);
         }
         if(this._engagementPopup.shoppingBtn)
         {
            this._engagementPopup.shoppingBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onShoppingBtn);
         }
         this._engagementPopup.gamesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onGamesBtn);
         this._engagementPopup.advBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAdventureBtn);
         this._engagementPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn);
         this._engagementPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
      }
   }
}

