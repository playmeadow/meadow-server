package gui
{
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.loader.LoaderCache;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomXtCommManager;
   
   public class AvatarSwitcher
   {
      
      private const SLOTS_PER_NONMEMBER:int = 2;
      
      private const MIN_NUM_AVATARS:int = 1;
      
      private const COST_OF_NEW_ANIMAL:int = 1000;
      
      private const AVSWITCH_MEDIA_ID:int = 1168;
      
      private const AVSWITCH_CHOOSING_MEDIA_ID:int = 1169;
      
      private var _numTotalSlots:int;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _views:Array;
      
      private var _activeIdx:int;
      
      private var _idx:int;
      
      private var _purchaseIdx:int;
      
      private var _myGemCount:int;
      
      private var _recycling:Boolean;
      
      private var _hasDeletedAnAvatar:Boolean;
      
      private var _isChoosing:Boolean;
      
      private var _isChoosingOceanAnimal:Boolean;
      
      private var _joinRoomAfterSwitch:Boolean;
      
      private var _avatarsChosen:Array;
      
      private var _currSound:Sound;
      
      private var _currSoundChannel:SoundChannel;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _mediaHelpers:Array;
      
      private var _contentItems:Array;
      
      private var _switchContent:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _choosingContent:MovieClip;
      
      private var _hasAddedListeners:Boolean;
      
      private var _scrollbar:SBScrollbar;
      
      private var _itemWindows:WindowGenerator;
      
      public function AvatarSwitcher()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Function = null, param3:Boolean = false, param4:Boolean = false, param5:Boolean = true) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._guiLayer = param1;
         this._closeCallback = param2;
         this._isChoosing = param3;
         this._isChoosingOceanAnimal = param4;
         this._joinRoomAfterSwitch = param5;
         AvatarSwitch.isChoosing = this._isChoosing;
         this._myGemCount = gMainFrame.clientInfo.gemCount;
         this._numTotalSlots = SwitchManager.NUM_AVATAR_SLOTS;
         this._mediaHelpers = [];
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.AVSWITCH_MEDIA_ID,this.onMediaItemLoaded,true);
         this._mediaHelpers.push(this._loadingMediaHelper);
         if(this._isChoosing)
         {
            this._loadingMediaHelper = new MediaHelper();
            this._loadingMediaHelper.init(this.AVSWITCH_CHOOSING_MEDIA_ID,this.onMediaItemLoaded,true);
            this._mediaHelpers.push(this._loadingMediaHelper);
            this._avatarsChosen = [];
            AvatarSwitch.availSlotFlags = 4095;
            this._currSound = new Sound();
            this._currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + 72 + ".mp3"));
         }
      }
      
      public function destroy() : void
      {
         if(this._hasDeletedAnAvatar)
         {
            AvatarSwitch.updateSlotPositions();
         }
         this.removeListeners();
         KeepAlive.stopKATimer(this._switchContent);
         var _loc1_:int = 0;
         while(_loc1_ < this._views.length)
         {
            if(this._views[_loc1_])
            {
               this._views[_loc1_].destroy();
               this._views[_loc1_] = null;
            }
            _loc1_++;
         }
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = null;
         }
         if(this._switchContent)
         {
            if(this._switchContent.root.parent == this._guiLayer)
            {
               this._guiLayer.removeChild(this._switchContent.root);
            }
            DarkenManager.unDarken(MovieClip(this._switchContent.root));
            this._switchContent.root.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._switchContent = null;
            if(this._closeBtn)
            {
               this._closeBtn = null;
            }
            if(this._contentItems)
            {
               this._contentItems = null;
            }
         }
         if(this._itemWindows)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         this._closeCallback = null;
      }
      
      public function close() : void
      {
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      public function get isChoosing() : Boolean
      {
         return this._isChoosing;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(param1.mediaHelper.id == this.AVSWITCH_MEDIA_ID)
            {
               this._closeBtn = MovieClip(param1.getChildAt(0)).bx;
               this._switchContent = MovieClip(param1.getChildAt(0)).c;
               KeepAlive.startKATimer(this._switchContent);
               this._guiLayer.addChild(param1);
               param1.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
               param1.x = MainFrame.VIEW_WIDTH * 0.5;
               param1.y = MainFrame.VIEW_HEIGHT * 0.5;
               DarkenManager.showLoadingSpiral(false);
               DarkenManager.darken(param1);
               if(this._isChoosing)
               {
                  if(this._choosingContent)
                  {
                     this.addListeners();
                  }
               }
               else
               {
                  this.addListeners();
               }
               this.initializePopupStates();
               this.buildWindows();
            }
            else if(param1.mediaHelper.id == this.AVSWITCH_CHOOSING_MEDIA_ID)
            {
               this._choosingContent = new MovieClip();
               this._choosingContent.oneAmlPopup = param1.OneAmlPopup;
               this._choosingContent.amlsPopup = param1.AmlsPopup;
               this._guiLayer.addChild(this._choosingContent.amlsPopup);
               this._guiLayer.addChild(this._choosingContent.oneAmlPopup);
               this._choosingContent.oneAmlPopup.x = MainFrame.VIEW_WIDTH * 0.5;
               this._choosingContent.oneAmlPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
               this._choosingContent.amlsPopup.x = MainFrame.VIEW_WIDTH * 0.5;
               this._choosingContent.amlsPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
               this._choosingContent.oneAmlPopup.visible = false;
               this._choosingContent.amlsPopup.visible = false;
               if(!this._hasAddedListeners && Boolean(this._switchContent))
               {
                  this.addListeners();
               }
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function initializePopupStates() : void
      {
         var _loc1_:int = 0;
         if(this._views)
         {
            _loc1_ = 0;
            while(_loc1_ < this._views.length)
            {
               if(this._views[_loc1_])
               {
                  this._views[_loc1_].destroy();
                  this._views[_loc1_] = null;
               }
               _loc1_++;
            }
         }
         this._activeIdx = AvatarSwitch.activeAvatarIdx;
         LocalizationManager.translateId(this._switchContent.buyPopup.item_name_txt,11218);
         this._switchContent.buyPopup.tag.txt.text = "";
         this._switchContent.oopsPopup.body_txt.text = "";
         this._switchContent.buyPopup.newTag.visible = false;
         this._switchContent.buyPopup.saleTag.visible = false;
         this._switchContent.buyPopup.clearanceTag.visible = false;
         this._switchContent.buyPopup.paw.gray.visible = false;
         this._switchContent.buyPopup.banner.visible = false;
         this._switchContent.buyPopup.lock.visible = false;
         this._switchContent.buyPopup.lockOpen.visible = false;
         this._switchContent.buyPopup.colorChange_btn.visible = false;
         this._switchContent.buyPopup.paw.visible = true;
         this._switchContent.buyPopup.visible = false;
         this._switchContent.buyPopup.ocean.visible = false;
         if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND)
         {
            this._switchContent.buyPopup.buyGreenBG.visible = true;
         }
         else
         {
            this._switchContent.buyPopup.buyGreenBG.visible = false;
         }
         this._switchContent.oopsPopup.visible = false;
         this._switchContent.oopsCostPopup.visible = false;
         this._switchContent.denShopTag.visible = false;
         this._switchContent.saveAmlTag.visible = false;
      }
      
      private function buildWindows() : void
      {
         var _loc8_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:MovieClip = null;
         var _loc12_:int = 0;
         if(this._scrollbar)
         {
            this._scrollbar.destroy();
            this._scrollbar = null;
         }
         if(this._itemWindows)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         this._views = [];
         var _loc1_:int = 0;
         while(_loc1_ < this._numTotalSlots)
         {
            if(AvatarSwitch.avatars[_loc1_] != null)
            {
               this._views[_loc1_] = this.setupAvatarViews(_loc1_);
            }
            _loc1_++;
         }
         if(this._views.length > 0 && this._isChoosing)
         {
            this._avatarsChosen = [];
         }
         AvatarSwitch.numOpenNonMemberSlots = 0;
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(gMainFrame.userInfo.myUserName);
         var _loc3_:int = this._numTotalSlots;
         var _loc4_:int = Math.min(_loc3_,4);
         var _loc5_:int = Math.ceil(_loc4_ / 2);
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(_loc4_,_loc5_,_loc3_,2,2,0,ItemWindowAnimal,this._views,"",{
            "mouseDown":this.onItemWindowDown,
            "mouseOver":this.onItemWindowOver,
            "mouseOut":this.onItemWindowOut
         },{
            "isAnimal":true,
            "isChoosing":this._isChoosing,
            "isChoosingOcean":this._isChoosingOceanAnimal,
            "nameBarData":_loc2_.nameBarData
         },null,false,false);
         this._switchContent.itemBlock.addChild(this._itemWindows);
         this._contentItems = new Array(this._numTotalSlots);
         this._activeIdx = AvatarSwitch.activeAvatarIdx;
         var _loc6_:int = AvatarSwitch.numNonMemberAvatars;
         var _loc7_:int = AvatarSwitch.numNonMemberOceanAvatars;
         var _loc9_:int = -1;
         _loc1_ = 0;
         while(_loc1_ < this._numTotalSlots)
         {
            if(AvatarSwitch.avatars[_loc1_] != null)
            {
               if(!this._isChoosing && AvatarSwitch.numNonMemberAvatars < 2 && _loc9_ == -1)
               {
                  _loc9_ = _loc1_;
               }
            }
            else
            {
               _loc8_ = true;
            }
            _loc11_ = MovieClip(this._itemWindows.bg.getChildAt(_loc1_));
            this._contentItems[_loc1_] = _loc11_;
            _loc1_++;
         }
         if(this._isChoosingOceanAnimal)
         {
            _loc12_ = AvatarSwitch.numTotalAvatars;
            if(_loc12_ == this._numTotalSlots)
            {
               LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11219);
               this._switchContent.oopsPopup.visible = true;
               this.onRecycleDown(null);
            }
            else
            {
               if(_loc9_ != -1)
               {
                  LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11220);
               }
               else if(Boolean(gMainFrame.userInfo.isMember) && _loc12_ > 1)
               {
                  LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11221);
               }
               else if(!gMainFrame.userInfo.isMember)
               {
                  if(_loc12_ == 1)
                  {
                     LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11222);
                  }
                  else
                  {
                     LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11219);
                  }
               }
               else
               {
                  LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11222);
               }
               this._switchContent.oopsPopup.visible = true;
            }
         }
         if(this._isChoosing)
         {
            if(AvatarSwitch.numMemberAvatars == this._numTotalSlots || _loc6_ == 0 && !_loc8_ || !_loc8_ && _loc6_ - _loc7_ < 1)
            {
               LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11223);
               this._switchContent.oopsPopup.visible = true;
               this.onRecycleDown(null);
            }
            else if(_loc8_ && (_loc6_ - _loc7_ < 1 || _loc6_ == 0))
            {
               LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11224);
               this._switchContent.oopsPopup.visible = true;
            }
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(AvatarSwitch.numAvailAvatars <= this.MIN_NUM_AVATARS)
            {
               _loc10_ = true;
            }
         }
         else if(this._isChoosing && (_loc6_ > 0 || _loc8_))
         {
            _loc10_ = true;
         }
         else if(_loc6_ < 2 && AvatarSwitch.numMemberAvatars == 0)
         {
            _loc10_ = true;
         }
         if(_loc10_)
         {
            this._switchContent.recycleBtn.gray.visible = true;
            this._switchContent.recycleBtn.mouse.visible = false;
            this._switchContent.recycleBtn.down.visible = false;
         }
         else
         {
            this._switchContent.recycleBtn.gray.visible = false;
            this._switchContent.recycleBtn.mouse.visible = true;
            this._switchContent.recycleBtn.down.visible = true;
         }
         if(!this._isChoosing)
         {
            this._contentItems[this._activeIdx].aml.sel.visible = true;
         }
         else
         {
            this._closeBtn.visible = false;
         }
         this._scrollbar = new SBScrollbar();
         this._scrollbar.init(this._itemWindows,840,440,0,"scrollbar2",224.6);
      }
      
      private function setupAvatarViews(param1:int) : AvatarView
      {
         var _loc2_:AvatarView = new AvatarView();
         var _loc3_:Avatar = AvatarSwitch.avatars[param1];
         _loc3_.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(_loc3_.userName).getPartialItemList(_loc3_.avTypeId,true));
         _loc2_.init(_loc3_);
         _loc2_.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
         var _loc4_:Point = AvatarUtility.getAnimalItemWindowOffset(_loc2_.avTypeId);
         _loc2_.x = _loc4_.x;
         _loc2_.y = _loc4_.y;
         return _loc2_;
      }
      
      public function resetSlots() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._numTotalSlots)
         {
            while(this._contentItems[_loc1_].gray.amlMask.amlBox.numChildren > 0)
            {
               this._contentItems[_loc1_].gray.amlMask.amlBox.removeChildAt(0);
            }
            while(this._contentItems[_loc1_].aml.amlMask.amlBox.numChildren > 0)
            {
               this._contentItems[_loc1_].aml.amlMask.amlBox.removeChildAt(0);
            }
            _loc1_++;
         }
      }
      
      public function addAvatarCallback(param1:int) : void
      {
         if(param1 == 1)
         {
            if(!this._isChoosing)
            {
               this._myGemCount -= this.COST_OF_NEW_ANIMAL;
               this.close();
               if(this._isChoosingOceanAnimal && this._joinRoomAfterSwitch)
               {
                  RoomXtCommManager.sendRoomJoinRequest(RoomXtCommManager._joinRoomName);
               }
            }
            else
            {
               this.buildWindows();
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._switchContent.oopsPopup);
            LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11225);
            this._switchContent.oopsPopup.visible = true;
         }
      }
      
      public function isChoosingAddCallback(param1:Boolean) : void
      {
         if(param1)
         {
            this.resetSlots();
            this.initializePopupStates();
            this.buildWindows();
         }
      }
      
      public function switchAvatarCallback(param1:Boolean, param2:Boolean = false) : void
      {
         if(param2)
         {
            if(Boolean(this._switchContent) && param1)
            {
               this._switchContent.root.visible = false;
               return;
            }
         }
         if(param1)
         {
            this.close();
         }
         else
         {
            DarkenManager.darken(this._switchContent.oopsPopup);
            LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11226);
            this._switchContent.oopsPopup.visible = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function recycleAvatarCallback(param1:Boolean, param2:int, param3:int, param4:int, param5:Boolean) : void
      {
         var _loc6_:MovieClip = null;
         var _loc7_:int = 0;
         if(param1)
         {
            this._hasDeletedAnAvatar = true;
            _loc6_ = this._contentItems[param2];
            if(this._views[param2])
            {
               this._views[param2].destroy();
               this._views[param2] = null;
            }
            this._recycling = false;
            if(param2 >= 0)
            {
               while(_loc6_.aml.amlMask.amlBox.numChildren > 0)
               {
                  _loc6_.aml.amlMask.amlBox.removeChildAt(0);
               }
               while(_loc6_.gray.amlMask.amlBox.numChildren > 0)
               {
                  _loc6_.gray.amlMask.amlBox.removeChildAt(0);
               }
            }
            _loc7_ = 0;
            while(_loc7_ < this._numTotalSlots)
            {
               this._contentItems[_loc7_].recycle.visible = false;
               _loc7_++;
            }
            _loc6_.resetWindow(param2);
            if(!gMainFrame.userInfo.isMember && !param5)
            {
               if(!this._isChoosing)
               {
                  if(AvatarSwitch.numOpenNonMemberSlots >= this.SLOTS_PER_NONMEMBER)
                  {
                     _loc6_.makeNew.newAmlBtn.gray.visible = true;
                  }
               }
               else
               {
                  _loc6_.makeNew.newAmlBtn.gray.visible = true;
               }
            }
            if(AvatarSwitch.numTotalAvatars <= this.MIN_NUM_AVATARS)
            {
               this._switchContent.recycleBtn.gray.visible = true;
               this._switchContent.recycleBtn.mouse.visible = false;
               this._switchContent.recycleBtn.down.visible = false;
            }
            if(this._isChoosing)
            {
               this.buildWindows();
            }
            GuiManager.startGemsFlash();
            this._myGemCount = param4;
            gMainFrame.clientInfo.gemCount = param4;
         }
         else
         {
            DarkenManager.darken(this._switchContent.oopsPopup);
            LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11227);
            this._switchContent.oopsPopup.visible = true;
            this._recycling = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function numSlotsAvailable() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = AvatarSwitch.availSlotFlags;
         var _loc3_:int = 0;
         while(_loc3_ < this._numTotalSlots)
         {
            if((_loc1_ & 1 << _loc3_) > 0)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         if(param1.status)
         {
            if(Boolean(this._contentItems[this._idx].gray.visible) && Boolean(gMainFrame.userInfo.isMember))
            {
               AvatarSwitch.availSlotFlags |= 1 << AvatarXtCommManager.avSlotInfo[AvatarSwitch.avatars[this._idx].dbAvId].avInvId;
            }
            AvatarSwitch.removeAvatar(this._idx,this.recycleAvatarCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Avatar = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         param1.stopPropagation();
         this._idx = param1.currentTarget.index;
         var _loc2_:MovieClip = this._contentItems[this._idx];
         if(_loc2_.makeNew.visible)
         {
            if(!_loc2_.makeNew.newAmlBtn.gray.visible)
            {
               if(this._myGemCount >= this.COST_OF_NEW_ANIMAL)
               {
                  SBTracker.push();
                  SBTracker.trackPageview("/game/play/popup/avatarSwitch/chooseAvatar");
               }
               AvatarSwitch.addAvatar(this._idx,false,this.addAvatarCallback,this._isChoosing,this._isChoosingOceanAnimal);
            }
            else if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(UpsellManager.ANIMAL_SLOTS,"chooseAvatar");
            }
         }
         else if(this._recycling)
         {
            if(_loc2_.recycle.visible)
            {
               if(this._idx != this._activeIdx || this._isChoosing)
               {
                  if(AvatarSwitch.getNumUsableLandAvatars(this._isChoosing,gMainFrame.userInfo.isMember) == 1 && AvatarSwitch.isSlotAvailable(this._idx) && Utility.isLand(AvatarSwitch.avatars[this._idx].enviroTypeFlag))
                  {
                     DarkenManager.darken(this._switchContent.oopsPopup);
                     LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11228);
                     this._switchContent.oopsPopup.visible = true;
                  }
                  else
                  {
                     _loc3_ = _loc2_.level > 0 ? LocalizationManager.translateIdAndInsertOnly(11229,_loc2_.level) : "";
                     new SBYesNoPopup(this._guiLayer,_loc3_ + LocalizationManager.translateIdAndInsertOnly(11230,Utility.convertNumberToString(AvatarUtility.findAvDefByType(AvatarSwitch.avatars[this._idx].avTypeId).cost * 0.5)),true,this.confirmRecycleHandler);
                  }
               }
               else
               {
                  DarkenManager.darken(this._switchContent.oopsPopup);
                  LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11231);
                  this._switchContent.oopsPopup.visible = true;
               }
            }
         }
         else if(_loc2_.aml.visible == true || _loc2_.den.visible == true)
         {
            if(this._isChoosing)
            {
               if(!AvatarSwitch.isMemberOnlyAvatar(this._idx))
               {
                  _loc2_.checkbox.check.visible = !_loc2_.checkbox.check.visible;
                  if(_loc2_.checkbox.check.visible)
                  {
                     if(this._avatarsChosen.length < 2)
                     {
                        if(this._avatarsChosen.length > 0)
                        {
                           _loc4_ = AvatarSwitch.avatars[this._idx];
                           if(!Utility.isLand(_loc4_.enviroTypeFlag) && Utility.isOcean(_loc4_.enviroTypeFlag))
                           {
                              _loc4_ = AvatarSwitch.avatars[this._avatarsChosen[0]];
                              if(!Utility.isLand(_loc4_.enviroTypeFlag) && Utility.isOcean(_loc4_.enviroTypeFlag))
                              {
                                 LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11232);
                                 this._switchContent.oopsPopup.visible = true;
                                 _loc2_.checkbox.check.visible = !_loc2_.checkbox.check.visible;
                                 return;
                              }
                           }
                        }
                        this._avatarsChosen.push(this._idx);
                        if(AvatarSwitch.numNonMemberAvatars == 1 || this._avatarsChosen.length > 1)
                        {
                           this._switchContent.saveAmlTag.visible = true;
                        }
                        else
                        {
                           this._switchContent.saveAmlTag.visible = false;
                        }
                     }
                     else
                     {
                        _loc4_ = AvatarSwitch.avatars[this._idx];
                        if(!Utility.isLand(_loc4_.enviroTypeFlag) && Utility.isOcean(_loc4_.enviroTypeFlag))
                        {
                           _loc4_ = AvatarSwitch.avatars[this._avatarsChosen[1]];
                           if(!Utility.isLand(_loc4_.enviroTypeFlag) && Utility.isOcean(_loc4_.enviroTypeFlag))
                           {
                              LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11232);
                              this._switchContent.oopsPopup.visible = true;
                              _loc2_.checkbox.check.visible = !_loc2_.checkbox.check.visible;
                              return;
                           }
                        }
                        _loc5_ = int(this._avatarsChosen[0]);
                        this._avatarsChosen.shift();
                        this._avatarsChosen.push(this._idx);
                        this._contentItems[_loc5_].checkbox.check.visible = false;
                        this._contentItems[_loc5_].aml.bg.visible = false;
                        this._contentItems[_loc5_].aml.sel.visible = false;
                     }
                     _loc2_.aml.bg.visible = true;
                     _loc2_.aml.sel.visible = true;
                  }
                  else
                  {
                     this._avatarsChosen.splice(this._avatarsChosen.indexOf(this._idx),1);
                     this._switchContent.saveAmlTag.visible = false;
                     _loc2_.aml.bg.visible = false;
                     _loc2_.aml.sel.visible = false;
                  }
               }
            }
            else if(PartyManager.canSwitchToAvatar(AvatarSwitch.avatars[this._idx],true))
            {
               if(this._idx != this._activeIdx)
               {
                  AvatarSwitch.switchAvatars(this._idx,this.switchAvatarCallback);
               }
               else if(this._idx == this._activeIdx)
               {
                  this.close();
               }
            }
         }
         else if(_loc2_.lock.visible == true)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(UpsellManager.ANIMAL_SLOTS,"buyThirdAvatar");
            }
            else
            {
               DebugUtility.debugTrace("WARNING: Slot is locked but user is a member. Why?!");
            }
         }
         else if(_loc2_.gray.visible == true)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               _loc6_ = gMainFrame.userInfo.getAvatarDefByAvType(AvatarSwitch.avatars[this._idx].avTypeId);
               if(_loc6_)
               {
                  UpsellManager.displayPopup(UpsellManager.ANIMAL_SLOTS,"useLockedAvatar/" + LocalizationManager.translateIdOnly(_loc6_.titleStrRef));
               }
               else
               {
                  UpsellManager.displayPopup(UpsellManager.ANIMAL_SLOTS,"useLockedAvatar");
               }
            }
         }
      }
      
      private function onItemWindowOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._idx = param1.currentTarget.index;
         if(this._contentItems[this._idx].aml.currentFrameLabel != "mouse")
         {
            this._contentItems[this._idx].aml.gotoAndPlay("mouse");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._idx = param1.currentTarget.index;
         if(this._contentItems[this._idx].aml.currentFrameLabel != "out")
         {
            this._contentItems[this._idx].aml.gotoAndPlay("out");
         }
      }
      
      private function onOopsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(this._switchContent.oopsPopup);
         this._switchContent.oopsPopup.visible = false;
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.close();
      }
      
      private function onRecycleDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._recycling)
         {
            _loc2_ = 0;
            while(_loc2_ < this._numTotalSlots)
            {
               this._contentItems[_loc2_].recycle.visible = false;
               _loc2_++;
            }
            this._recycling = false;
         }
         else if(!this._switchContent.recycleBtn.gray.visible)
         {
            this._recycling = true;
            _loc3_ = 0;
            while(_loc3_ < this._numTotalSlots)
            {
               if(this._views[_loc3_])
               {
                  this._contentItems[_loc3_].recycle.visible = true;
               }
               _loc3_++;
            }
         }
         else
         {
            this._switchContent.recycleBtn.mouse.visible = false;
         }
      }
      
      private function onRecycleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14626),842,480);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onSaveAnimalsDown(param1:MouseEvent) : void
      {
         var _loc2_:AvatarView = null;
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/avatarConfirm");
         if(this._avatarsChosen.length > 1)
         {
            while(this._choosingContent.amlsPopup._slot0.amlMask.amlBox.numChildren > 0)
            {
               this._choosingContent.amlsPopup._slot0.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = this.setupAvatarViews(this._avatarsChosen[0]);
            this._choosingContent.amlsPopup._slot0.amlMask.amlBox.addChild(_loc2_);
            this._choosingContent.amlsPopup._slot0.nameTxt.text = _loc2_.avName;
            while(this._choosingContent.amlsPopup._slot1.amlMask.amlBox.numChildren > 0)
            {
               this._choosingContent.amlsPopup._slot1.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = this.setupAvatarViews(this._avatarsChosen[1]);
            this._choosingContent.amlsPopup._slot1.amlMask.amlBox.addChild(_loc2_);
            this._choosingContent.amlsPopup._slot1.nameTxt.text = _loc2_.avName;
            DarkenManager.darken(this._choosingContent.amlsPopup);
            if(this._currSoundChannel)
            {
               this._currSoundChannel.stop();
               this._currSoundChannel = this._currSound.play();
            }
            else
            {
               this._currSoundChannel = this._currSound.play();
            }
            this._choosingContent.amlsPopup.visible = true;
            this._choosingContent.amlsPopup.parent.setChildIndex(this._choosingContent.amlsPopup,this._choosingContent.amlsPopup.parent.numChildren - 1);
         }
         else
         {
            while(this._choosingContent.oneAmlPopup._slot0.amlMask.amlBox.numChildren > 0)
            {
               this._choosingContent.oneAmlPopup._slot0.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = this.setupAvatarViews(this._avatarsChosen[0]);
            this._choosingContent.oneAmlPopup._slot0.amlMask.amlBox.addChild(_loc2_);
            this._choosingContent.oneAmlPopup._slot0.nameTxt.text = _loc2_.avName;
            DarkenManager.darken(this._choosingContent.oneAmlPopup);
            this._choosingContent.oneAmlPopup.soundBtn.visible = false;
            this._choosingContent.oneAmlPopup.visible = true;
            this._choosingContent.oneAmlPopup.parent.setChildIndex(this._choosingContent.oneAmlPopup,this._choosingContent.oneAmlPopup.parent.numChildren - 1);
         }
      }
      
      private function onChooseOkNoDown(param1:MouseEvent) : void
      {
         SBTracker.pop();
         param1.stopPropagation();
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
         }
         DarkenManager.unDarken(param1.currentTarget.parent);
         param1.currentTarget.parent.visible = false;
         if(param1.currentTarget == this._choosingContent.amlsPopup.okBtn || param1.currentTarget == this._choosingContent.oneAmlPopup.okBtn)
         {
            if(this._avatarsChosen.length == 1)
            {
               this.checkForAdditionalSpots();
            }
            DarkenManager.showLoadingSpiral(true);
            if(AvatarSwitch.activeAvatarIdx != AvatarXtCommManager.avSlotInfo[AvatarSwitch.avatars[this._avatarsChosen[0]].dbAvId].slotId)
            {
               AvatarSwitch.setAvatarSwitchCallback(this.onSwitchComplete);
            }
            AvatarSwitch.chooseTwo(this._avatarsChosen,this.onChooseCallback);
         }
      }
      
      private function onChooseCallback(param1:Boolean) : void
      {
         var _loc2_:Array = null;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _loc2_ = AvatarSwitch.avatars;
            if(this._avatarsChosen.length > 1 && Boolean(_loc2_[this._avatarsChosen[1]]))
            {
               AvatarSwitch.availSlotFlags = 1 << AvatarXtCommManager.avSlotInfo[_loc2_[this._avatarsChosen[0]].dbAvId].avInvId | 1 << AvatarXtCommManager.avSlotInfo[_loc2_[this._avatarsChosen[1]].dbAvId].avInvId;
            }
            else
            {
               AvatarSwitch.availSlotFlags = 1 << AvatarXtCommManager.avSlotInfo[_loc2_[this._avatarsChosen[0]].dbAvId].avInvId;
            }
            this.close();
         }
         else
         {
            DarkenManager.darken(this._switchContent.oopsPopup);
            LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11233);
            this._switchContent.oopsPopup.visible = true;
         }
      }
      
      private function onSwitchComplete(param1:Boolean, param2:Boolean = false) : void
      {
         if(!param1)
         {
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._switchContent.oopsPopup);
            LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11233);
            this._switchContent.oopsPopup.visible = true;
         }
      }
      
      private function onChooseSoundBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = this._currSound.play();
         }
         else
         {
            this._currSoundChannel = this._currSound.play();
         }
      }
      
      private function checkForAdditionalSpots() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._numTotalSlots)
         {
            if(this._avatarsChosen[0] != _loc1_)
            {
               if(AvatarSwitch.avatars[_loc1_] == null)
               {
                  this._avatarsChosen.push(_loc1_);
                  break;
               }
               if(!AvatarSwitch.isMemberOnlyAvatar(_loc1_))
               {
                  this._avatarsChosen.push(_loc1_);
                  break;
               }
            }
            _loc1_++;
         }
      }
      
      private function addListeners() : void
      {
         if(this._closeBtn)
         {
            this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         if(this._switchContent)
         {
            this._hasAddedListeners = true;
            this._switchContent.recycleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRecycleDown,false,0,true);
            this._switchContent.recycleBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onRecycleOver,false,0,true);
            this._switchContent.recycleBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onRecycleOut,false,0,true);
            this._switchContent.oopsPopup.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onOopsClose,false,0,true);
            if(this._isChoosing && Boolean(this._choosingContent))
            {
               this._switchContent.saveAmlTag.saveAmlBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSaveAnimalsDown,false,0,true);
               this._choosingContent.amlsPopup.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onChooseOkNoDown,false,0,true);
               this._choosingContent.amlsPopup.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onChooseOkNoDown,false,0,true);
               this._choosingContent.oneAmlPopup.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onChooseOkNoDown,false,0,true);
               this._choosingContent.oneAmlPopup.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onChooseOkNoDown,false,0,true);
               this._choosingContent.amlsPopup.soundBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onChooseSoundBtn,false,0,true);
            }
         }
      }
      
      private function removeListeners() : void
      {
         if(this._closeBtn)
         {
            this._closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         }
         if(this._switchContent)
         {
            this._switchContent.recycleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRecycleDown);
            this._switchContent.recycleBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onRecycleOver);
            this._switchContent.recycleBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onRecycleOut);
            this._switchContent.oopsPopup.closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onOopsClose);
            if(this._isChoosing)
            {
               this._switchContent.saveAmlTag.saveAmlBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSaveAnimalsDown);
               this._choosingContent.amlsPopup.okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onChooseOkNoDown);
               this._choosingContent.amlsPopup.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onChooseOkNoDown);
               this._choosingContent.oneAmlPopup.okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onChooseOkNoDown);
               this._choosingContent.oneAmlPopup.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onChooseOkNoDown);
               this._choosingContent.amlsPopup.soundBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onChooseSoundBtn);
            }
         }
      }
   }
}

