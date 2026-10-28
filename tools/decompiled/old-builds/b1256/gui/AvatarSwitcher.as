package gui
{
   import Party.PartyManager;
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
   import com.sbi.loader.LoaderCache;
   import com.sbi.popup.SBYesNoPopup;
   import currency.UserCurrency;
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
      
      private var _switchDensAfterAdd:Boolean;
      
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
      
      public function init(param1:DisplayLayer, param2:Function = null, param3:Boolean = false, param4:Boolean = false, param5:Boolean = true, param6:Boolean = false) : void
      {
         var _loc7_:int = 0;
         DarkenManager.showLoadingSpiral(true);
         _guiLayer = param1;
         _closeCallback = param2;
         _isChoosing = param3;
         _isChoosingOceanAnimal = param4;
         _joinRoomAfterSwitch = param5;
         _switchDensAfterAdd = param6;
         AvatarSwitch.isChoosing = _isChoosing;
         _myGemCount = UserCurrency.getCurrency(0);
         _numTotalSlots = 36;
         _mediaHelpers = [];
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(1168,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
         if(_isChoosing)
         {
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(1169,onMediaItemLoaded,true);
            _mediaHelpers.push(_loadingMediaHelper);
            _avatarsChosen = [];
            AvatarSwitch.availSlotFlags = 4294967295;
            switch(LocalizationManager.currentLanguage)
            {
               case LocalizationManager.LANG_ENG:
                  _loc7_ = 72;
                  break;
               case LocalizationManager.LANG_SPA:
                  _loc7_ = 680;
                  break;
               case LocalizationManager.LANG_POR:
                  _loc7_ = 635;
                  break;
               case LocalizationManager.LANG_FRE:
                  _loc7_ = 630;
                  break;
               case LocalizationManager.LANG_DE:
                  _loc7_ = 625;
                  break;
               default:
                  _loc7_ = 72;
            }
            _currSound = new Sound();
            _currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + _loc7_ + ".mp3"));
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(_hasDeletedAnAvatar)
         {
            AvatarSwitch.updateSlotPositions();
         }
         removeListeners();
         KeepAlive.stopKATimer(_switchContent);
         _loc1_ = 0;
         while(_loc1_ < _views.length)
         {
            if(_views[_loc1_])
            {
               _views[_loc1_].destroy();
               _views[_loc1_] = null;
            }
            _loc1_++;
         }
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
            _currSoundChannel = null;
         }
         if(_switchContent)
         {
            if(_switchContent.root.parent == _guiLayer)
            {
               _guiLayer.removeChild(_switchContent.root);
            }
            DarkenManager.unDarken(MovieClip(_switchContent.root));
            _switchContent.root.removeEventListener("mouseDown",onPopup);
            _switchContent = null;
            if(_closeBtn)
            {
               _closeBtn = null;
            }
            if(_contentItems)
            {
               _contentItems = null;
            }
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _closeCallback = null;
      }
      
      public function close() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      public function get isChoosing() : Boolean
      {
         return _isChoosing;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(param1.mediaHelper.id == 1168)
            {
               _closeBtn = MovieClip(param1.getChildAt(0)).bx;
               _switchContent = MovieClip(param1.getChildAt(0)).c;
               KeepAlive.startKATimer(_switchContent);
               _guiLayer.addChild(param1);
               param1.addEventListener("mouseDown",onPopup,false,0,true);
               param1.x = 900 * 0.5;
               param1.y = 550 * 0.5;
               DarkenManager.showLoadingSpiral(false);
               DarkenManager.darken(param1);
               if(_isChoosing)
               {
                  if(_choosingContent)
                  {
                     addListeners();
                  }
               }
               else
               {
                  addListeners();
               }
               initializePopupStates();
               buildWindows();
            }
            else if(param1.mediaHelper.id == 1169)
            {
               _choosingContent = new MovieClip();
               _choosingContent.oneAmlPopup = param1.OneAmlPopup;
               _choosingContent.amlsPopup = param1.AmlsPopup;
               _guiLayer.addChild(_choosingContent.amlsPopup);
               _guiLayer.addChild(_choosingContent.oneAmlPopup);
               _choosingContent.oneAmlPopup.x = 900 * 0.5;
               _choosingContent.oneAmlPopup.y = 550 * 0.5;
               _choosingContent.amlsPopup.x = 900 * 0.5;
               _choosingContent.amlsPopup.y = 550 * 0.5;
               _choosingContent.oneAmlPopup.visible = false;
               _choosingContent.amlsPopup.visible = false;
               if(!_hasAddedListeners && _switchContent)
               {
                  addListeners();
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
         if(_views)
         {
            _loc1_ = 0;
            while(_loc1_ < _views.length)
            {
               if(_views[_loc1_])
               {
                  _views[_loc1_].destroy();
                  _views[_loc1_] = null;
               }
               _loc1_++;
            }
         }
         _activeIdx = AvatarSwitch.activeAvatarIdx;
         LocalizationManager.translateId(_switchContent.buyPopup.item_name_txt,11218);
         _switchContent.buyPopup.tag.txt.text = "";
         _switchContent.oopsPopup.body_txt.text = "";
         _switchContent.buyPopup.newTag.visible = false;
         _switchContent.buyPopup.saleTag.visible = false;
         _switchContent.buyPopup.clearanceTag.visible = false;
         _switchContent.buyPopup.paw.gray.visible = false;
         _switchContent.buyPopup.banner.visible = false;
         _switchContent.buyPopup.lock.visible = false;
         _switchContent.buyPopup.lockOpen.visible = false;
         _switchContent.buyPopup.colorChange_btn.visible = false;
         _switchContent.buyPopup.paw.visible = true;
         _switchContent.buyPopup.visible = false;
         _switchContent.buyPopup.ocean.visible = false;
         if(AvatarManager.roomEnviroType == 0)
         {
            _switchContent.buyPopup.buyGreenBG.visible = true;
         }
         else
         {
            _switchContent.buyPopup.buyGreenBG.visible = false;
         }
         _switchContent.oopsPopup.visible = false;
         _switchContent.oopsCostPopup.visible = false;
         _switchContent.denShopTag.visible = false;
         _switchContent.saveAmlTag.visible = false;
      }
      
      private function buildWindows() : void
      {
         var _loc12_:int = 0;
         var _loc9_:Boolean = false;
         var _loc5_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc10_:Boolean = false;
         if(_scrollbar)
         {
            _scrollbar.destroy();
            _scrollbar = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _views = [];
         _loc12_ = 0;
         while(_loc12_ < _numTotalSlots)
         {
            if(AvatarSwitch.avatars[_loc12_] != null)
            {
               _views[_loc12_] = setupAvatarViews(_loc12_);
            }
            _loc12_++;
         }
         if(_views.length > 0 && _isChoosing)
         {
            _avatarsChosen = [];
         }
         AvatarSwitch.numOpenNonMemberSlots = 0;
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(gMainFrame.userInfo.myUserName);
         var _loc1_:int = _numTotalSlots;
         var _loc6_:int = Math.min(_loc1_,4);
         var _loc11_:int = Math.ceil(_loc6_ / 2);
         _itemWindows = new WindowGenerator();
         _itemWindows.init(_loc6_,_loc11_,_loc1_,0.5,2,0,ItemWindowAnimal,_views,"",{
            "mouseDown":onItemWindowDown,
            "mouseOver":onItemWindowOver,
            "mouseOut":onItemWindowOut
         },{
            "isAnimal":true,
            "isChoosing":_isChoosing,
            "isChoosingOcean":_isChoosingOceanAnimal,
            "nameBarData":_loc2_.nameBarData
         },null,false,false);
         _switchContent.itemBlock.addChild(_itemWindows);
         _contentItems = new Array(_numTotalSlots);
         _activeIdx = AvatarSwitch.activeAvatarIdx;
         var _loc8_:int = AvatarSwitch.numNonMemberAvatars;
         var _loc4_:int = AvatarSwitch.numNonMemberOceanAvatars;
         var _loc7_:int = -1;
         _loc12_ = 0;
         while(_loc12_ < _numTotalSlots)
         {
            if(AvatarSwitch.avatars[_loc12_] != null)
            {
               if(!_isChoosing && AvatarSwitch.numNonMemberAvatars < 2 && _loc7_ == -1)
               {
                  _loc7_ = _loc12_;
               }
            }
            else
            {
               _loc9_ = true;
            }
            _loc5_ = MovieClip(_itemWindows.bg.getChildAt(_loc12_));
            _contentItems[_loc12_] = _loc5_;
            _loc12_++;
         }
         if(_isChoosingOceanAnimal)
         {
            _loc3_ = AvatarSwitch.numTotalAvatars;
            if(_loc3_ == _numTotalSlots)
            {
               LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11219);
               _switchContent.oopsPopup.visible = true;
               onRecycleDown(null);
            }
            else
            {
               if(_loc7_ != -1)
               {
                  LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11220);
               }
               else if(gMainFrame.userInfo.isMember && _loc3_ > 1)
               {
                  LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11221);
               }
               else if(!gMainFrame.userInfo.isMember)
               {
                  if(_loc3_ == 1)
                  {
                     LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11222);
                  }
                  else
                  {
                     LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11219);
                  }
               }
               else
               {
                  LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11222);
               }
               _switchContent.oopsPopup.visible = true;
            }
         }
         if(_isChoosing)
         {
            if(AvatarSwitch.numMemberAvatars == _numTotalSlots || _loc8_ == 0 && !_loc9_ || !_loc9_ && _loc8_ - _loc4_ < 1)
            {
               LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11223);
               _switchContent.oopsPopup.visible = true;
               onRecycleDown(null);
            }
            else if(_loc9_ && (_loc8_ - _loc4_ < 1 || _loc8_ == 0))
            {
               LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11224);
               _switchContent.oopsPopup.visible = true;
            }
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(AvatarSwitch.numAvailAvatars <= 1)
            {
               _loc10_ = true;
            }
         }
         else if(_isChoosing && (_loc8_ > 0 || _loc9_))
         {
            _loc10_ = true;
         }
         else if(_loc8_ < 2 && AvatarSwitch.numMemberAvatars == 0)
         {
            _loc10_ = true;
         }
         if(_loc10_)
         {
            _switchContent.recycleBtn.gray.visible = true;
            _switchContent.recycleBtn.mouse.visible = false;
            _switchContent.recycleBtn.down.visible = false;
         }
         else
         {
            _switchContent.recycleBtn.gray.visible = false;
            _switchContent.recycleBtn.mouse.visible = true;
            _switchContent.recycleBtn.down.visible = true;
         }
         if(!_isChoosing)
         {
            _contentItems[_activeIdx].aml.sel.visible = true;
         }
         else
         {
            _closeBtn.visible = false;
         }
         _scrollbar = new SBScrollbar();
         _scrollbar.init(_itemWindows,840,440,-9,"scrollbar2",222.5);
      }
      
      private function setupAvatarViews(param1:int) : AvatarView
      {
         var _loc4_:AvatarView = new AvatarView();
         var _loc2_:Avatar = AvatarSwitch.avatars[param1];
         _loc2_.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(_loc2_.userName).getPartialItemList(_loc2_.avTypeId,true));
         _loc4_.init(_loc2_);
         _loc4_.playAnim(13,false,1,null);
         var _loc3_:Point = AvatarUtility.getAnimalItemWindowOffset(_loc4_.avTypeId);
         _loc4_.x = _loc3_.x;
         _loc4_.y = _loc3_.y;
         return _loc4_;
      }
      
      public function resetSlots() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _numTotalSlots)
         {
            while(_contentItems[_loc1_].gray.amlMask.amlBox.numChildren > 0)
            {
               _contentItems[_loc1_].gray.amlMask.amlBox.removeChildAt(0);
            }
            while(_contentItems[_loc1_].aml.amlMask.amlBox.numChildren > 0)
            {
               _contentItems[_loc1_].aml.amlMask.amlBox.removeChildAt(0);
            }
            _loc1_++;
         }
      }
      
      public function addAvatarCallback(param1:int) : void
      {
         if(param1 == 1)
         {
            if(!_isChoosing)
            {
               _myGemCount -= 1000;
               close();
               if(_isChoosingOceanAnimal)
               {
                  if(_joinRoomAfterSwitch)
                  {
                     RoomXtCommManager.sendRoomJoinRequest(RoomXtCommManager._joinRoomName);
                  }
                  else if(_switchDensAfterAdd)
                  {
                     DenSwitch.reTrySwitchDensAfterAddingAvatar();
                  }
               }
            }
            else
            {
               buildWindows();
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11225);
            _switchContent.oopsPopup.visible = true;
         }
      }
      
      public function isChoosingAddCallback(param1:Boolean) : void
      {
         if(param1)
         {
            resetSlots();
            initializePopupStates();
            buildWindows();
         }
      }
      
      public function switchAvatarCallback(param1:Boolean, param2:Boolean = false) : void
      {
         if(param2)
         {
            if(_switchContent && param1)
            {
               _switchContent.root.visible = false;
               return;
            }
         }
         if(param1)
         {
            close();
         }
         else
         {
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11226);
            _switchContent.oopsPopup.visible = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function recycleAvatarCallback(param1:Boolean, param2:int, param3:int, param4:int, param5:Boolean) : void
      {
         var _loc6_:MovieClip = null;
         var _loc7_:int = 0;
         if(param1)
         {
            _hasDeletedAnAvatar = true;
            _loc6_ = _contentItems[param2];
            if(_views[param2])
            {
               _views[param2].destroy();
               _views[param2] = null;
            }
            _recycling = false;
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
            while(_loc7_ < _numTotalSlots)
            {
               _contentItems[_loc7_].recycle.visible = false;
               _loc7_++;
            }
            _loc6_.resetWindow(param2);
            if(!gMainFrame.userInfo.isMember && !param5)
            {
               if(!_isChoosing)
               {
                  if(AvatarSwitch.numOpenNonMemberSlots >= 2)
                  {
                     _loc6_.makeNew.newAmlBtn.gray.visible = true;
                  }
               }
               else
               {
                  _loc6_.makeNew.newAmlBtn.gray.visible = true;
               }
            }
            if(AvatarSwitch.numTotalAvatars <= 1)
            {
               _switchContent.recycleBtn.gray.visible = true;
               _switchContent.recycleBtn.mouse.visible = false;
               _switchContent.recycleBtn.down.visible = false;
            }
            if(_isChoosing)
            {
               buildWindows();
            }
            _myGemCount = param4;
            UserCurrency.setCurrency(param4,0);
         }
         else
         {
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11227);
            _switchContent.oopsPopup.visible = true;
            _recycling = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         if(param1.status)
         {
            AvatarSwitch.removeAvatar(_idx,recycleAvatarCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Avatar = null;
         var _loc6_:int = 0;
         var _loc5_:Object = null;
         param1.stopPropagation();
         _idx = param1.currentTarget.index;
         var _loc4_:MovieClip = _contentItems[_idx];
         if(_loc4_.makeNew.visible)
         {
            if(!_loc4_.makeNew.newAmlBtn.gray.visible)
            {
               if(_myGemCount >= 1000)
               {
                  SBTracker.push();
                  SBTracker.trackPageview("/game/play/popup/avatarSwitch/chooseAvatar");
               }
               AvatarSwitch.addAvatar(_idx,false,addAvatarCallback,_isChoosing,_isChoosingOceanAnimal,_switchDensAfterAdd);
            }
            else if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(4,"chooseAvatar");
            }
         }
         else if(_recycling)
         {
            if(_loc4_.recycle.visible)
            {
               if(_idx != _activeIdx || _isChoosing)
               {
                  if(AvatarSwitch.getNumUsableLandAvatars(_isChoosing,gMainFrame.userInfo.isMember) == 1 && AvatarSwitch.isSlotAvailable(_idx) && Utility.isLand(AvatarSwitch.avatars[_idx].enviroTypeFlag))
                  {
                     DarkenManager.darken(_switchContent.oopsPopup);
                     LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11228);
                     _switchContent.oopsPopup.visible = true;
                  }
                  else
                  {
                     _loc3_ = _loc4_.level > 0 ? LocalizationManager.translateIdAndInsertOnly(11229,_loc4_.level) : "";
                     new SBYesNoPopup(_guiLayer,_loc3_ + LocalizationManager.translateIdAndInsertOnly(11230,Utility.convertNumberToString(AvatarUtility.findAvDefByType(AvatarSwitch.avatars[_idx].avTypeId,AvatarSwitch.avatars[_idx].customAvId).recycleValue)),true,confirmRecycleHandler);
                  }
               }
               else
               {
                  DarkenManager.darken(_switchContent.oopsPopup);
                  LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11231);
                  _switchContent.oopsPopup.visible = true;
               }
            }
         }
         else if(_loc4_.aml.visible == true || _loc4_.den.visible == true)
         {
            if(_isChoosing)
            {
               if(!AvatarSwitch.isMemberOnlyAvatar(_idx))
               {
                  _loc4_.checkbox.check.visible = !_loc4_.checkbox.check.visible;
                  if(_loc4_.checkbox.check.visible)
                  {
                     if(_avatarsChosen.length < 2)
                     {
                        if(_avatarsChosen.length > 0)
                        {
                           _loc2_ = AvatarSwitch.avatars[_idx];
                           if(!Utility.isLand(_loc2_.enviroTypeFlag) && Utility.isOcean(_loc2_.enviroTypeFlag))
                           {
                              _loc2_ = AvatarSwitch.avatars[_avatarsChosen[0]];
                              if(!Utility.isLand(_loc2_.enviroTypeFlag) && Utility.isOcean(_loc2_.enviroTypeFlag))
                              {
                                 LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11232);
                                 _switchContent.oopsPopup.visible = true;
                                 _loc4_.checkbox.check.visible = !_loc4_.checkbox.check.visible;
                                 return;
                              }
                           }
                        }
                        _avatarsChosen.push(_idx);
                        if(AvatarSwitch.numNonMemberAvatars == 1 || _avatarsChosen.length > 1)
                        {
                           _switchContent.saveAmlTag.visible = true;
                        }
                        else
                        {
                           _switchContent.saveAmlTag.visible = false;
                        }
                     }
                     else
                     {
                        _loc2_ = AvatarSwitch.avatars[_idx];
                        if(!Utility.isLand(_loc2_.enviroTypeFlag) && Utility.isOcean(_loc2_.enviroTypeFlag))
                        {
                           _loc2_ = AvatarSwitch.avatars[_avatarsChosen[1]];
                           if(!Utility.isLand(_loc2_.enviroTypeFlag) && Utility.isOcean(_loc2_.enviroTypeFlag))
                           {
                              LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11232);
                              _switchContent.oopsPopup.visible = true;
                              _loc4_.checkbox.check.visible = !_loc4_.checkbox.check.visible;
                              return;
                           }
                        }
                        _loc6_ = int(_avatarsChosen[0]);
                        _avatarsChosen.shift();
                        _avatarsChosen.push(_idx);
                        _contentItems[_loc6_].checkbox.check.visible = false;
                        _contentItems[_loc6_].aml.bg.visible = false;
                        _contentItems[_loc6_].aml.sel.visible = false;
                     }
                     _loc4_.aml.bg.visible = true;
                     _loc4_.aml.sel.visible = true;
                  }
                  else
                  {
                     _avatarsChosen.splice(_avatarsChosen.indexOf(_idx),1);
                     _switchContent.saveAmlTag.visible = false;
                     _loc4_.aml.bg.visible = false;
                     _loc4_.aml.sel.visible = false;
                  }
               }
            }
            else if(PartyManager.canSwitchToAvatar(AvatarSwitch.avatars[_idx],true))
            {
               if(_idx != _activeIdx)
               {
                  AvatarSwitch.switchAvatars(_idx,switchAvatarCallback);
               }
               else if(_idx == _activeIdx)
               {
                  close();
               }
            }
         }
         else if(_loc4_.lock.visible == true)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(4,"buyThirdAvatar");
            }
            else
            {
               DebugUtility.debugTrace("WARNING: Slot is locked but user is a member. Why?!");
            }
         }
         else if(_loc4_.gray.visible == true)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               _loc5_ = gMainFrame.userInfo.getAvatarDefByAvatar(AvatarSwitch.avatars[_idx]);
               if(_loc5_)
               {
                  UpsellManager.displayPopup(4,"useLockedAvatar/" + LocalizationManager.translateIdOnly(_loc5_.titleStrRef));
               }
               else
               {
                  UpsellManager.displayPopup(4,"useLockedAvatar");
               }
            }
         }
      }
      
      private function onItemWindowOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _idx = param1.currentTarget.index;
         if(_contentItems[_idx].aml.currentFrameLabel != "mouse")
         {
            _contentItems[_idx].aml.gotoAndPlay("mouse");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _idx = param1.currentTarget.index;
         if(_contentItems[_idx].aml.currentFrameLabel != "out")
         {
            _contentItems[_idx].aml.gotoAndPlay("out");
         }
      }
      
      private function onOopsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_switchContent.oopsPopup);
         _switchContent.oopsPopup.visible = false;
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         close();
      }
      
      private function onRecycleDown(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_recycling)
         {
            _loc3_ = 0;
            while(_loc3_ < _numTotalSlots)
            {
               _contentItems[_loc3_].recycle.visible = false;
               _loc3_++;
            }
            _recycling = false;
         }
         else if(!_switchContent.recycleBtn.gray.visible)
         {
            _recycling = true;
            _loc2_ = 0;
            while(_loc2_ < _numTotalSlots)
            {
               if(_views[_loc2_])
               {
                  _contentItems[_loc2_].recycle.visible = true;
               }
               _loc2_++;
            }
         }
         else
         {
            _switchContent.recycleBtn.mouse.visible = false;
         }
      }
      
      private function onRecycleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14626),842,480);
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
         if(_avatarsChosen.length > 1)
         {
            while(_choosingContent.amlsPopup._slot0.amlMask.amlBox.numChildren > 0)
            {
               _choosingContent.amlsPopup._slot0.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = setupAvatarViews(_avatarsChosen[0]);
            _choosingContent.amlsPopup._slot0.amlMask.amlBox.addChild(_loc2_);
            _choosingContent.amlsPopup._slot0.nameTxt.text = _loc2_.avName;
            while(_choosingContent.amlsPopup._slot1.amlMask.amlBox.numChildren > 0)
            {
               _choosingContent.amlsPopup._slot1.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = setupAvatarViews(_avatarsChosen[1]);
            _choosingContent.amlsPopup._slot1.amlMask.amlBox.addChild(_loc2_);
            _choosingContent.amlsPopup._slot1.nameTxt.text = _loc2_.avName;
            DarkenManager.darken(_choosingContent.amlsPopup);
            if(_currSoundChannel)
            {
               _currSoundChannel.stop();
               _currSoundChannel = _currSound.play();
            }
            else
            {
               _currSoundChannel = _currSound.play();
            }
            _choosingContent.amlsPopup.visible = true;
            _choosingContent.amlsPopup.parent.setChildIndex(_choosingContent.amlsPopup,_choosingContent.amlsPopup.parent.numChildren - 1);
         }
         else
         {
            while(_choosingContent.oneAmlPopup._slot0.amlMask.amlBox.numChildren > 0)
            {
               _choosingContent.oneAmlPopup._slot0.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = setupAvatarViews(_avatarsChosen[0]);
            _choosingContent.oneAmlPopup._slot0.amlMask.amlBox.addChild(_loc2_);
            _choosingContent.oneAmlPopup._slot0.nameTxt.text = _loc2_.avName;
            DarkenManager.darken(_choosingContent.oneAmlPopup);
            _choosingContent.oneAmlPopup.soundBtn.visible = false;
            _choosingContent.oneAmlPopup.visible = true;
            _choosingContent.oneAmlPopup.parent.setChildIndex(_choosingContent.oneAmlPopup,_choosingContent.oneAmlPopup.parent.numChildren - 1);
         }
      }
      
      private function onChooseOkNoDown(param1:MouseEvent) : void
      {
         SBTracker.pop();
         param1.stopPropagation();
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
         }
         DarkenManager.unDarken(param1.currentTarget.parent);
         param1.currentTarget.parent.visible = false;
         if(param1.currentTarget == _choosingContent.amlsPopup.okBtn || param1.currentTarget == _choosingContent.oneAmlPopup.okBtn)
         {
            if(_avatarsChosen.length == 1)
            {
               checkForAdditionalSpots();
            }
            DarkenManager.showLoadingSpiral(true);
            if(AvatarSwitch.activeAvatarIdx != AvatarXtCommManager.avSlotInfo[AvatarSwitch.avatars[_avatarsChosen[0]].perUserAvId].slotId)
            {
               AvatarSwitch.setAvatarSwitchCallback(onSwitchComplete);
            }
            AvatarSwitch.chooseTwo(_avatarsChosen,onChooseCallback);
         }
      }
      
      private function onChooseCallback(param1:Boolean) : void
      {
         var _loc2_:Array = null;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _loc2_ = AvatarSwitch.avatars;
            AvatarSwitch.availSlotFlags = 0;
            if(_avatarsChosen.length > 1 && _loc2_[_avatarsChosen[1]])
            {
               AvatarSwitch.adjustAvailSlotFlags(AvatarXtCommManager.avSlotInfo[_loc2_[_avatarsChosen[0]].perUserAvId].avInvId,true);
               AvatarSwitch.adjustAvailSlotFlags(AvatarXtCommManager.avSlotInfo[_loc2_[_avatarsChosen[1]].perUserAvId].avInvId,true);
            }
            else
            {
               AvatarSwitch.adjustAvailSlotFlags(AvatarXtCommManager.avSlotInfo[_loc2_[_avatarsChosen[0]].perUserAvId].avInvId,true);
            }
            close();
         }
         else
         {
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11233);
            _switchContent.oopsPopup.visible = true;
         }
      }
      
      private function onSwitchComplete(param1:Boolean, param2:Boolean = false) : void
      {
         if(!param1)
         {
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11233);
            _switchContent.oopsPopup.visible = true;
         }
      }
      
      private function onChooseSoundBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
            _currSoundChannel = _currSound.play();
         }
         else
         {
            _currSoundChannel = _currSound.play();
         }
      }
      
      private function checkForAdditionalSpots() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _numTotalSlots)
         {
            if(_avatarsChosen[0] != _loc1_)
            {
               if(AvatarSwitch.avatars[_loc1_] == null)
               {
                  _avatarsChosen.push(_loc1_);
                  break;
               }
               if(!AvatarSwitch.isMemberOnlyAvatar(_loc1_))
               {
                  _avatarsChosen.push(_loc1_);
                  break;
               }
            }
            _loc1_++;
         }
      }
      
      private function addListeners() : void
      {
         if(_closeBtn)
         {
            _closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         }
         if(_switchContent)
         {
            _hasAddedListeners = true;
            _switchContent.recycleBtn.addEventListener("mouseDown",onRecycleDown,false,0,true);
            _switchContent.recycleBtn.addEventListener("mouseOver",onRecycleOver,false,0,true);
            _switchContent.recycleBtn.addEventListener("mouseOut",onRecycleOut,false,0,true);
            _switchContent.oopsPopup.closeBtn.addEventListener("mouseDown",onOopsClose,false,0,true);
            if(_isChoosing && _choosingContent)
            {
               _switchContent.saveAmlTag.saveAmlBtn.addEventListener("mouseDown",onSaveAnimalsDown,false,0,true);
               _choosingContent.amlsPopup.okBtn.addEventListener("mouseDown",onChooseOkNoDown,false,0,true);
               _choosingContent.amlsPopup.noBtn.addEventListener("mouseDown",onChooseOkNoDown,false,0,true);
               _choosingContent.oneAmlPopup.okBtn.addEventListener("mouseDown",onChooseOkNoDown,false,0,true);
               _choosingContent.oneAmlPopup.noBtn.addEventListener("mouseDown",onChooseOkNoDown,false,0,true);
               _choosingContent.amlsPopup.soundBtn.addEventListener("mouseDown",onChooseSoundBtn,false,0,true);
            }
         }
      }
      
      private function removeListeners() : void
      {
         if(_closeBtn)
         {
            _closeBtn.removeEventListener("mouseDown",onClose);
         }
         if(_switchContent)
         {
            _switchContent.recycleBtn.removeEventListener("mouseDown",onRecycleDown);
            _switchContent.recycleBtn.removeEventListener("mouseOver",onRecycleOver);
            _switchContent.recycleBtn.removeEventListener("mouseOut",onRecycleOut);
            _switchContent.oopsPopup.closeBtn.removeEventListener("mouseDown",onOopsClose);
            if(_isChoosing)
            {
               _switchContent.saveAmlTag.saveAmlBtn.removeEventListener("mouseDown",onSaveAnimalsDown);
               _choosingContent.amlsPopup.okBtn.removeEventListener("mouseDown",onChooseOkNoDown);
               _choosingContent.amlsPopup.noBtn.removeEventListener("mouseDown",onChooseOkNoDown);
               _choosingContent.oneAmlPopup.okBtn.removeEventListener("mouseDown",onChooseOkNoDown);
               _choosingContent.oneAmlPopup.noBtn.removeEventListener("mouseDown",onChooseOkNoDown);
               _choosingContent.amlsPopup.soundBtn.removeEventListener("mouseDown",onChooseSoundBtn);
            }
         }
      }
   }
}

