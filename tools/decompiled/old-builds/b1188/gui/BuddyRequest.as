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
      
      public function BuddyRequest(param1:String, param2:Function, param3:int)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         this._playerUserName = param1;
         this._requestCallback = param2;
         this._popupType = param3;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(2778,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         SBPopupManager.destroySpecificNonSBPopup(this);
         if(this._mediaHelper)
         {
            this._mediaHelper.destroy();
            this._mediaHelper = null;
         }
         if(this._mainAvatarView)
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
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            this._requestPopup = MovieClip(param1.getChildAt(0));
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
         var _loc1_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(this._playerUserName);
         if(!_loc1_)
         {
            AvatarXtCommManager.requestAvatarGet(this._playerUserName,this.onAvatarGetReceived);
         }
         else
         {
            this.onAvatarGetReceived(this._playerUserName,true,0,_loc1_);
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:AvatarInfo = null) : void
      {
         var _loc5_:UserInfo = null;
         var _loc6_:int = 0;
         if(param2 && param1.toLowerCase() == this._playerUserName.toLowerCase())
         {
            if(!param4)
            {
               param4 = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
               if(!param4)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(this._playerUserName);
            if(param4.isMember)
            {
               this._requestPopup.nonmember.visible = false;
               this._requestPopup.userName_txt.visible = false;
               this._requestPopup.member.setNubType("buddy",false);
               this._requestPopup.member.setColorAndBadge(_loc5_.nameBarData);
               this._requestPopup.member.isBlocked = false;
               this._requestPopup.member.setAvName(_loc5_.getModeratedUserName(),false);
               this._requestPopup.member.mouseEnabled = false;
               this._requestPopup.member.mouseChildren = false;
            }
            else
            {
               this._requestPopup.member.visible = false;
               this._requestPopup.userName_txt.visible = true;
               this._requestPopup.userName_txt.text = _loc5_.getModeratedUserName();
            }
            if(this._popupType == CONFIRMATION)
            {
               _loc6_ = BuddyManager.buddyCount;
               if(_loc6_ >= BuddyManager.WARNING_BUDDY_COUNT)
               {
                  LocalizationManager.translateIdAndInsert(this._requestPopup.txt,18509,BuddyManager.MAX_BUDDY_COUNT - _loc6_);
               }
               else
               {
                  LocalizationManager.translateId(this._requestPopup.txt,9491);
               }
            }
            this._mainAvatar = AvatarManager.getAvatarByUserName(this._playerUserName);
            if(this._mainAvatar == null)
            {
               this._mainAvatar = AvatarUtility.generateNew(param4.perUserAvId,null,this._playerUserName,-1,0,this.onAvatarItemData);
            }
            this.drawMainAvatar(this._mainAvatar);
         }
         else
         {
            this.destroy();
         }
      }
      
      public function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && this._mainAvatar != null)
         {
            this.drawMainAvatar(this._mainAvatar);
         }
         else
         {
            this.destroy();
         }
      }
      
      private function drawMainAvatar(param1:Avatar) : void
      {
         if(Utility.isOcean(param1.enviroTypeFlag))
         {
            if(Utility.isLand(param1.enviroTypeFlag))
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
         this._mainAvatarView.init(param1);
         if(param1.avTypeId >= 0)
         {
            this._mainAvatarView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,this.positionAndAddMainAvatarView);
         }
      }
      
      private function positionAndAddMainAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = BuddyCard.getAvOffsetByDefId(this._mainAvatarView.avTypeId);
         this._mainAvatarView.x = _loc3_.x;
         this._mainAvatarView.y = _loc3_.y;
         if(this._requestPopup)
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
      
      private function onOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function onCancelBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._requestCallback({
            "status":false,
            "passback":this._playerUserName
         });
      }
   }
}

