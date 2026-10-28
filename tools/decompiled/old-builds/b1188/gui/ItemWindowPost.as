package gui
{
   import avatar.Avatar;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import buddy.Buddy;
   import com.sbi.corelib.input.SBTextField;
   import com.sbi.graphics.LayerAnim;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import playerWall.PlayerWallManager;
   
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
         this._onReportDown = param9.reportMsgBtnMouseDown;
         this._onDeleteDown = param9.deleteMsgBtnMouseDown;
         this._isMyPost = param9.isMyPost;
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
      
      override public function destroy() : void
      {
         this.removeEventListeners();
         if(this._iconMediaHelper)
         {
            this._iconMediaHelper.destroy();
            this._iconMediaHelper = null;
         }
         this._onReportDown = null;
         this._onDeleteDown = null;
         if(this._smileyText)
         {
            this._smileyText.destroy();
            this._smileyText = null;
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
         if(Boolean(_currItem) && !_isCurrItemLoaded)
         {
            if(!_spiral)
            {
               _spiral = new LoadingSpiral(_window.iconLayer);
            }
            else
            {
               _spiral.setNewParent(_window.iconLayer);
            }
            this._smileyText = new SBTextField(null,_window.messageTxt,_window.textItemHolder,true);
            this._smileyText.text = _currItem.message;
            this._smileyText.mouseChildren = false;
            this._smileyText.mouseEnabled = false;
            this._smileyText.selectable = false;
            _window.deleteMessageBtn.parent.setChildIndex(_window.deleteMessageBtn,_window.deleteMessageBtn.parent.numChildren - 1);
            _window.reportMessageBtn.parent.setChildIndex(_window.reportMessageBtn,_window.reportMessageBtn.parent.numChildren - 1);
            if(!this._isMyPost)
            {
               _window.reportMessageBtn.x += _window.reportMessageBtn.width;
            }
            _isCurrItemLoaded = true;
            this.setupCurrAvtImage();
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Object = null;
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
            this.loadPostPattern();
            _window.reportMessageBtn.visible = false;
            _window.deleteMessageBtn.visible = false;
            _window.gotoAndStop(_currItem.colorId);
            _window.messageTxt.text = "";
            _window.messageTxt.selectable = false;
            _window.nameTxt.text = _currItem.senderModeratedUserName;
            _window.timeTxt.autoSize = TextFieldAutoSize.RIGHT;
            _loc1_ = new Date().valueOf();
            _loc2_ = Utility.calculateTime((new Date().valueOf() - _currItem.postTime) / 1000);
            LocalizationManager.translateIdAndInsert(_window.timeTxt,11360,Utility.calculatePrintTime(_loc2_.mins,_loc2_.hours,false,_loc2_.days));
            if(Boolean(_currItem.isBuddy) && _currItem.senderUserName != gMainFrame.userInfo.myUserName)
            {
               _window.buddyIcon.visible = true;
               _window.nameTxt.x += _window.buddyIcon.width;
            }
            else
            {
               _window.buddyIcon.visible = false;
            }
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(this._isMyPost)
         {
            _window.deleteMessageBtn.addEventListener(MouseEvent.MOUSE_DOWN,this._onDeleteDown,false,0,true);
         }
         else
         {
            addEventListener(MouseEvent.MOUSE_DOWN,this.onPostDown,false,0,true);
         }
         _window.reportMessageBtn.addEventListener(MouseEvent.MOUSE_DOWN,this._onReportDown,false,0,true);
         addEventListener(MouseEvent.ROLL_OVER,this.onPostRollOverOut,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onPostRollOverOut,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         if(this._isMyPost)
         {
            _window.deleteMessageBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this._onDeleteDown);
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onPostDown);
         }
         _window.reportMessageBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this._onReportDown);
         removeEventListener(MouseEvent.ROLL_OVER,this.onPostRollOverOut);
         removeEventListener(MouseEvent.ROLL_OUT,this.onPostRollOverOut);
      }
      
      private function onPostDown(param1:MouseEvent) : void
      {
         var _loc2_:Buddy = null;
         param1.stopPropagation();
         if(_window)
         {
            _loc2_ = BuddyManager.getBuddyByUserName(_currItem.senderUserName);
            if(_loc2_)
            {
               BuddyCard.showBuddyCard({
                  "userName":_loc2_.userName,
                  "onlineStatus":_loc2_.onlineStatus
               });
               return;
            }
            AvatarXtCommManager.requestAvatarGet(_currItem.senderUserName,this.onUserLookUpReceived,true);
            return;
         }
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
               if(this._isMyPost)
               {
                  _window.deleteMessageBtn.visible = true;
               }
            }
            else
            {
               _window.messageHighlight.gotoAndStop("off");
               _window.reportMessageBtn.visible = false;
               if(this._isMyPost)
               {
                  _window.deleteMessageBtn.visible = false;
               }
            }
         }
      }
      
      private function loadPostPattern() : void
      {
         this._patternWindow = new ItemWindowPattern(null,PlayerWallManager.PATTERN_MEDIA_ID,"",0,null,null,null,null,{
            "type":ItemWindowPattern.TYPE_MESSAGE,
            "colorIndex":_currItem.colorId,
            "patternIndex":_currItem.patternId
         });
         _window.messageBodyHolder.addChild(this._patternWindow);
      }
      
      private function setupCurrAvtImage() : void
      {
         var _loc1_:Avatar = new Avatar();
         _loc1_.init(-1,"",_currItem.avtDefId,_currItem.avtColors,_currItem.avtCustomId,null,_currItem.senderUserName);
         var _loc2_:Array = [];
         var _loc3_:Item = new Item();
         _loc2_[0] = _loc3_;
         _loc3_.init(1,1,0,-1,-1);
         _loc3_ = new Item();
         _loc2_[1] = _loc3_;
         _loc3_.init(_currItem.avtEyeDefId > 0 ? int(_currItem.avtEyeDefId) : 2,2,0,-1,-1);
         var _loc4_:Object = gMainFrame.userInfo.getAvatarDefByAvatar(_loc1_);
         if(_currItem.avtCustomId != -1 && Boolean(_loc4_))
         {
            _currItem.avtPatternDefId = _loc4_.patternRefId;
         }
         if(_currItem.avtPatternDefId > 0)
         {
            _loc3_ = new Item();
            _loc2_[2] = _loc3_;
            _loc3_.init(_currItem.avtPatternDefId,3,0,-1,-1);
         }
         _loc1_.itemResponseIntegrate(_loc2_);
         var _loc5_:AvatarView = new AvatarView();
         _loc5_.init(_loc1_,null);
         _loc5_.playAnim(LayerAnim.AN_HUD_AVT,false,LayerAnim.PLAY_ONE_SHOT,null);
         _loc5_.x = 275;
         _loc5_.y = 260;
         _window.charCont.charLayer.addChild(_loc5_);
      }
   }
}

