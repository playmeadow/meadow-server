package gui
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBPopupManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class BuddyRequest
   {
      
      public static const ACCEPT_REJECT:int = 1;
      
      public static const CONFIRMATION:int = 2;
      
      private var _mediaHelper:MediaHelper;
      
      private var _requestPopup:MovieClip;
      
      private var _playerUserName:String;
      
      private var _mainAvatarView:AvatarView;
      
      private var _loadingSpiralAvatar:LoadingSpiral;
      
      private var _mainAvatar:Avatar;
      
      private var _requestCallback:Function;
      
      private var _popupType:int;
      
      public function BuddyRequest(playerUserName:String, requestCallback:Function, popupType:int)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         this._playerUserName = playerUserName;
         this._requestCallback = requestCallback;
         this._popupType = popupType;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(2778,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         SBPopupManager.destroySpecificNonSBPopup(this);
         if(Boolean(this._mediaHelper))
         {
            this._mediaHelper.destroy();
            this._mediaHelper = null;
         }
         if(Boolean(this._mainAvatarView))
         {
            this._mainAvatarView.destroy();
            this._mainAvatarView = null;
         }
         this._mainAvatar = null;
         this.removeEventListeners();
         DarkenManager.unDarken(this._requestPopup);
         GuiManager.guiLayer.removeChild(this._requestPopup);
         this._requestPopup = null;
      }
      
      private function onMediaLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(img))
         {
            this._requestPopup = MovieClip(img.getChildAt(0));
            this._requestPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._requestPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            GuiManager.guiLayer.addChild(this._requestPopup);
            DarkenManager.darken(this._requestPopup);
            this.setupRequestPopup();
            this.addEventListeners();
         }
      }
      
      private function setupRequestPopup() : void
      {
         this._requestPopup.gotoAndStop(this._popupType);
         this._loadingSpiralAvatar = new LoadingSpiral(this._requestPopup.charBox);
         var avInfo:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(this._playerUserName);
         if(!avInfo)
         {
            AvatarXtCommManager.requestAvatarGet(this._playerUserName,this.onAvatarGetReceived);
         }
         else
         {
            this.onAvatarGetReceived(this._playerUserName,true,0,avInfo);
         }
      }
      
      private function onAvatarGetReceived(userName:String, status:Boolean, onlineStatus:int, avInfo:AvatarInfo = null) : void
      {
         var ui:UserInfo = null;
         var numBuddies:int = 0;
         if(status && userName == this._playerUserName)
         {
            if(!avInfo)
            {
               avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
               if(!avInfo)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            ui = gMainFrame.userInfo.getUserInfoByUserName(this._playerUserName);
            if(avInfo.isMember)
            {
               this._requestPopup.nonmember.visible = false;
               this._requestPopup.userName_txt.visible = false;
               this._requestPopup.member.setNubType("buddy",false);
               this._requestPopup.member.setColorAndBadge(ui.nameBarData);
               this._requestPopup.member.isBlocked = false;
               this._requestPopup.member.setAvName(ui.getModeratedUserName(),false);
               this._requestPopup.member.mouseEnabled = false;
               this._requestPopup.member.mouseChildren = false;
            }
            else
            {
               this._requestPopup.member.visible = false;
               this._requestPopup.userName_txt.visible = true;
               this._requestPopup.userName_txt.text = ui.getModeratedUserName();
            }
            if(this._popupType == CONFIRMATION)
            {
               numBuddies = BuddyManager.buddyCount;
               if(numBuddies >= BuddyManager.WARNING_BUDDY_COUNT)
               {
                  LocalizationManager.translateIdAndInsert(this._requestPopup.txt,18509,BuddyManager.MAX_BUDDY_COUNT - numBuddies);
               }
               else
               {
                  LocalizationManager.translateId(this._requestPopup.txt,9491);
               }
            }
            this._mainAvatar = AvatarManager.getAvatarByUserName(this._playerUserName);
            if(this._mainAvatar == null)
            {
               this._mainAvatar = AvatarUtility.generateNew(avInfo.perUserAvId,null,this._playerUserName,-1,0,this.onAvatarItemData);
            }
            this.drawMainAvatar(this._mainAvatar);
         }
      }
      
      public function onAvatarItemData() : void
      {
         if(this._mainAvatar != null)
         {
            this.drawMainAvatar(this._mainAvatar);
         }
      }
      
      private function drawMainAvatar(avt:Avatar) : void
      {
         if(Utility.isOcean(avt.enviroTypeFlag))
         {
            if(Utility.isLand(avt.enviroTypeFlag))
            {
               this._requestPopup.charBox.gotoAndStop(3);
            }
            else
            {
               this._requestPopup.charBox.gotoAndStop(2);
            }
         }
         else
         {
            this._requestPopup.charBox.gotoAndStop(1);
         }
         this._mainAvatarView = new AvatarView();
         this._mainAvatarView.init(avt);
         if(avt.avTypeId >= 0)
         {
            this._mainAvatarView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,this.positionAndAddMainAvatarView);
         }
      }
      
      private function positionAndAddMainAvatarView(layerAnim:LayerAnim, animId:int) : void
      {
         var offset:Point = BuddyCard.getAvOffsetByDefId(this._mainAvatarView.avTypeId);
         this._mainAvatarView.x = offset.x;
         this._mainAvatarView.y = offset.y;
         if(Boolean(this._requestPopup))
         {
            this._requestPopup.charBox.addChild(this._mainAvatarView);
         }
         this._loadingSpiralAvatar.visible = false;
      }
      
      private function addEventListeners() : void
      {
         if(this._requestPopup.currentFrame == 1)
         {
            this._requestPopup.cancelBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCancelBtn,false,0,true);
         }
         this._requestPopup.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onOkBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         if(this._requestPopup.currentFrame == 1)
         {
            this._requestPopup.cancelBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCancelBtn);
         }
         this._requestPopup.okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onOkBtn);
      }
      
      private function onOkBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._requestPopup.currentFrame == 1)
         {
            this._requestCallback({
               "status":true,
               "passback":this._playerUserName
            });
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onCancelBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._requestCallback({
            "status":false,
            "passback":this._playerUserName
         });
      }
   }
}

