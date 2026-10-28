package gui
{
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import buddy.Buddy;
   import com.sbi.corelib.input.SBTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import playerWall.PostMessage;
   
   public class ItemWindowPost extends ItemWindowBase
   {
      
      private var _iconMediaHelper:MediaHelper;
      
      private var _onReportDown:Function;
      
      private var _onDeleteDown:Function;
      
      private var _smileyText:SBTextField;
      
      private var _isMyPost:Boolean;
      
      private var _patternWindow:ItemWindowPattern;
      
      public function ItemWindowPost(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _onReportDown = param9.reportMsgBtnMouseDown;
         _onDeleteDown = param9.deleteMsgBtnMouseDown;
         _isMyPost = param9.isMyPost;
         tabEnabled = false;
         super(1501,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get msgId() : String
      {
         return _currItem.msgId;
      }
      
      public function get senderUserName() : String
      {
         return _currItem.senderUserName;
      }
      
      public function get senderModeratedUserName() : String
      {
         return _currItem.senderModeratedUserName;
      }
      
      public function get sizeCont() : MovieClip
      {
         return MovieClip(_window.parent).sizeCont;
      }
      
      public function darken(param1:Boolean) : void
      {
         if(_window)
         {
            _window.darkCont.visible = param1;
         }
      }
      
      public function update() : void
      {
         var _loc2_:Number = new Date().valueOf();
         _loc2_ += Utility.getTimeOffset();
         var _loc1_:Object = Utility.calculateTime((_loc2_ - _currItem.postTime) / 1000);
         if(_loc1_.mins < 0)
         {
            _loc1_.mins = 0;
         }
         if(_loc1_.mins == 0 && _loc1_.hours < 1 && _loc1_.days < 1)
         {
            _window.timeTxt.text = Utility.calculatePrintTimeToNearest(_loc1_.mins,_loc1_.hours,true,_loc1_.days);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_window.timeTxt,11360,Utility.calculatePrintTimeToNearest(_loc1_.mins,_loc1_.hours,true,_loc1_.days));
         }
      }
      
      public function updateWithInput(param1:PostMessage) : void
      {
         if(_smileyText && param1)
         {
            _smileyText.text = param1.message;
         }
      }
      
      override public function destroy() : void
      {
         removeEventListeners();
         if(_iconMediaHelper)
         {
            _iconMediaHelper.destroy();
            _iconMediaHelper = null;
         }
         _onReportDown = null;
         _onDeleteDown = null;
         if(_smileyText)
         {
            _smileyText.destroy();
            _smileyText = null;
         }
         _window = null;
         _windowLoadedCallback = null;
         _currItem = null;
         _mouseDown = null;
         _mouseOver = null;
         _mouseOut = null;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !_isCurrItemLoaded)
         {
            if(!_spiral)
            {
               _spiral = new LoadingSpiral(_window.iconLayer);
            }
            else
            {
               _spiral.setNewParent(_window.iconLayer);
            }
            _smileyText = new SBTextField(null,_window.messageTxt,_window.textItemHolder,true);
            _smileyText.text = _currItem.message;
            _smileyText.mouseChildren = false;
            _smileyText.mouseEnabled = false;
            _smileyText.selectable = false;
            if(!_isMyPost)
            {
               _window.reportMessageBtn.x += _window.reportMessageBtn.width;
            }
            _isCurrItemLoaded = true;
            setupCurrAvtImage();
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_currItem)
         {
            if(_currItem.senderUserName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _window.gotoAndStop("player");
               _window = _window.player;
            }
            else
            {
               _window.gotoAndStop("buddies");
               _window = _window.buddies;
            }
            darken(false);
            loadPostPattern();
            _window.reportMessageBtn.visible = false;
            _window.deleteMessageBtn.visible = false;
            _window.gotoAndStop(_currItem.colorId);
            _window.messageTxt.text = "";
            _window.messageTxt.selectable = false;
            _window.nameTxt.text = _currItem.senderModeratedUserName;
            _window.timeTxt.autoSize = "right";
            if(_currItem.isBuddy && _currItem.senderUserName.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _window.buddyIcon.visible = true;
               _window.nameTxt.x += _window.buddyIcon.width;
            }
            else
            {
               _window.buddyIcon.visible = false;
            }
            update();
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_isMyPost)
         {
            _window.deleteMessageBtn.addEventListener("mouseDown",_onDeleteDown,false,0,true);
         }
         _window.reportMessageBtn.addEventListener("mouseDown",_onReportDown,false,0,true);
         _window.darkCont.addEventListener("mouseDown",onDarkCont,false,0,true);
         addEventListener("rollOver",onPostRollOverOut,false,0,true);
         addEventListener("rollOut",onPostRollOverOut,false,0,true);
         addEventListener("mouseDown",onPostDown,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         if(_isMyPost)
         {
            _window.deleteMessageBtn.removeEventListener("mouseDown",_onDeleteDown);
         }
         _window.reportMessageBtn.removeEventListener("mouseDown",_onReportDown);
         _window.darkCont.removeEventListener("mouseDown",onDarkCont);
         removeEventListener("rollOver",onPostRollOverOut);
         removeEventListener("rollOut",onPostRollOverOut);
         removeEventListener("mouseDown",onPostDown);
      }
      
      private function onDarkCont(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPostDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_window && _currItem.senderUserName.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
         {
            BuddyList.requestBuddyListIfNeeded(onBuddyListRequested);
         }
      }
      
      private function onBuddyListRequested() : void
      {
         var _loc1_:Buddy = BuddyManager.getBuddyByUserName(_currItem.senderUserName);
         if(_loc1_)
         {
            BuddyCard.showBuddyCard({
               "userName":_loc1_.userName,
               "onlineStatus":_loc1_.onlineStatus
            });
            return;
         }
         AvatarXtCommManager.requestAvatarGet(_currItem.senderUserName,onUserLookUpReceived,true);
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         if(param2)
         {
            BuddyCard.showBuddyCard({
               "userName":param1,
               "onlineStatus":param3
            });
         }
      }
      
      private function onPostRollOverOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_window)
         {
            if(_window.messageHighlight.currentFrameLabel != "on")
            {
               _window.messageHighlight.gotoAndStop("on");
               _window.reportMessageBtn.visible = _currItem.senderUserName != gMainFrame.userInfo.myUserName;
               if(_isMyPost)
               {
                  _window.deleteMessageBtn.visible = true;
               }
            }
            else
            {
               _window.messageHighlight.gotoAndStop("off");
               _window.reportMessageBtn.visible = false;
               if(_isMyPost)
               {
                  _window.deleteMessageBtn.visible = false;
               }
            }
         }
      }
      
      private function loadPostPattern() : void
      {
         _patternWindow = new ItemWindowPattern(null,3983,"",0,null,null,null,null,{
            "type":"message",
            "colorIndex":_currItem.colorId,
            "patternIndex":_currItem.patternId
         });
         _window.messageBodyHolder.addChild(_patternWindow);
      }
      
      private function setupCurrAvtImage() : void
      {
         var _loc3_:Avatar = new Avatar();
         _loc3_.init(-1,"",_currItem.avtDefId,_currItem.avtColors,_currItem.avtCustomId,null,_currItem.senderUserName);
         var _loc1_:Array = [];
         var _loc5_:Item = new Item();
         _loc1_[0] = _loc5_;
         _loc5_.init(1,1,0,-1,-1);
         _loc5_ = new Item();
         _loc1_[1] = _loc5_;
         _loc5_.init(_currItem.avtEyeDefId > 0 ? _currItem.avtEyeDefId : 2,2,0,-1,-1);
         var _loc2_:Object = gMainFrame.userInfo.getAvatarDefByAvatar(_loc3_);
         if(_currItem.avtCustomId != -1 && _loc2_)
         {
            _currItem.avtPatternDefId = _loc2_.patternRefId;
         }
         if(_currItem.avtPatternDefId > 0)
         {
            _loc5_ = new Item();
            _loc1_[2] = _loc5_;
            _loc5_.init(_currItem.avtPatternDefId,3,0,-1,-1);
         }
         _loc3_.itemResponseIntegrate(_loc1_);
         var _loc4_:AvatarView = new AvatarView();
         _loc4_.init(_loc3_,null);
         _loc4_.playAnim(15,false,1,null);
         var _loc6_:Point = AvatarUtility.getAvatarHudPosition(_loc4_.avTypeId);
         _loc4_.x = _loc6_.x + _window.charCont.width * 0.5;
         _loc4_.y = _loc6_.y + _window.charCont.height * 0.5;
         _window.charCont.charLayer.addChild(_loc4_);
      }
   }
}

