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
      
      public function init(guiLayer:DisplayLayer, closeCallback:Function = null, isChoosing:Boolean = false, isChoosingOceanAnimal:Boolean = false, joinRoomAfterSwitch:Boolean = true) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._guiLayer = guiLayer;
         this._closeCallback = closeCallback;
         this._isChoosing = isChoosing;
         this._isChoosingOceanAnimal = isChoosingOceanAnimal;
         this._joinRoomAfterSwitch = joinRoomAfterSwitch;
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
         for(var i:int = 0; i < this._views.length; i++)
         {
            if(Boolean(this._views[i]))
            {
               this._views[i].destroy();
               this._views[i] = null;
            }
         }
         if(Boolean(this._currSoundChannel))
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = null;
         }
         if(Boolean(this._switchContent))
         {
            if(this._switchContent.root.parent == this._guiLayer)
            {
               this._guiLayer.removeChild(this._switchContent.root);
            }
            DarkenManager.unDarken(MovieClip(this._switchContent.root));
            this._switchContent.root.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._switchContent = null;
            if(Boolean(this._closeBtn))
            {
               this._closeBtn = null;
            }
            if(Boolean(this._contentItems))
            {
               this._contentItems = null;
            }
         }
         if(Boolean(this._itemWindows))
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
      
      private function onMediaItemLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            if(img.mediaHelper.id == this.AVSWITCH_MEDIA_ID)
            {
               this._closeBtn = MovieClip(img.getChildAt(0)).bx;
               this._switchContent = MovieClip(img.getChildAt(0)).c;
               KeepAlive.startKATimer(this._switchContent);
               this._guiLayer.addChild(img);
               img.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
               img.x = MainFrame.VIEW_WIDTH * 0.5;
               img.y = MainFrame.VIEW_HEIGHT * 0.5;
               DarkenManager.showLoadingSpiral(false);
               DarkenManager.darken(img);
               if(this._isChoosing)
               {
                  if(Boolean(this._choosingContent))
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
            else if(img.mediaHelper.id == this.AVSWITCH_CHOOSING_MEDIA_ID)
            {
               this._choosingContent = new MovieClip();
               this._choosingContent.oneAmlPopup = img.OneAmlPopup;
               this._choosingContent.amlsPopup = img.AmlsPopup;
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
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function initializePopupStates() : void
      {
         var i:int = 0;
         if(Boolean(this._views))
         {
            for(i = 0; i < this._views.length; i++)
            {
               if(Boolean(this._views[i]))
               {
                  this._views[i].destroy();
                  this._views[i] = null;
               }
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
         var hasAtLeastOneOpenSlot:Boolean = false;
         var shouldGrayOut:Boolean = false;
         var mc:MovieClip = null;
         var numTotalAvatars:int = 0;
         if(Boolean(this._scrollbar))
         {
            this._scrollbar.destroy();
            this._scrollbar = null;
         }
         if(Boolean(this._itemWindows))
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         this._views = [];
         for(var i:int = 0; i < this._numTotalSlots; i++)
         {
            if(AvatarSwitch.avatars[i] != null)
            {
               this._views[i] = this.setupAvatarViews(i);
            }
         }
         if(this._views.length > 0 && this._isChoosing)
         {
            this._avatarsChosen = [];
         }
         AvatarSwitch.numOpenNonMemberSlots = 0;
         var ui:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(gMainFrame.userInfo.myUserName);
         var numItemsInCurrentArray:int = this._numTotalSlots;
         var xCount:int = Math.min(numItemsInCurrentArray,4);
         var yCount:int = Math.ceil(xCount / 2);
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(xCount,yCount,numItemsInCurrentArray,2,2,0,ItemWindowAnimal,this._views,"",{
            "mouseDown":this.onItemWindowDown,
            "mouseOver":this.onItemWindowOver,
            "mouseOut":this.onItemWindowOut
         },{
            "isAnimal":true,
            "isChoosing":this._isChoosing,
            "isChoosingOcean":this._isChoosingOceanAnimal,
            "nameBarData":ui.nameBarData
         },null,false,false);
         this._switchContent.itemBlock.addChild(this._itemWindows);
         this._contentItems = new Array(this._numTotalSlots);
         this._activeIdx = AvatarSwitch.activeAvatarIdx;
         var numNonMemberAvatars:int = AvatarSwitch.numNonMemberAvatars;
         var numNonMemberOceanAvatars:int = AvatarSwitch.numNonMemberOceanAvatars;
         var firstOpenIdx:int = -1;
         for(i = 0; i < this._numTotalSlots; i++)
         {
            if(AvatarSwitch.avatars[i] != null)
            {
               if(!this._isChoosing && AvatarSwitch.numNonMemberAvatars < 2 && firstOpenIdx == -1)
               {
                  firstOpenIdx = i;
               }
            }
            else
            {
               hasAtLeastOneOpenSlot = true;
            }
            mc = MovieClip(this._itemWindows.bg.getChildAt(i));
            this._contentItems[i] = mc;
         }
         if(this._isChoosingOceanAnimal)
         {
            numTotalAvatars = AvatarSwitch.numTotalAvatars;
            if(numTotalAvatars == this._numTotalSlots)
            {
               LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11219);
               this._switchContent.oopsPopup.visible = true;
               this.onRecycleDown(null);
            }
            else
            {
               if(firstOpenIdx != -1)
               {
                  LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11220);
               }
               else if(Boolean(gMainFrame.userInfo.isMember) && numTotalAvatars > 1)
               {
                  LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11221);
               }
               else if(!gMainFrame.userInfo.isMember)
               {
                  if(numTotalAvatars == 1)
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
            if(AvatarSwitch.numMemberAvatars == this._numTotalSlots || numNonMemberAvatars == 0 && !hasAtLeastOneOpenSlot || !hasAtLeastOneOpenSlot && numNonMemberAvatars - numNonMemberOceanAvatars < 1)
            {
               LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11223);
               this._switchContent.oopsPopup.visible = true;
               this.onRecycleDown(null);
            }
            else if(hasAtLeastOneOpenSlot && (numNonMemberAvatars - numNonMemberOceanAvatars < 1 || numNonMemberAvatars == 0))
            {
               LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11224);
               this._switchContent.oopsPopup.visible = true;
            }
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(AvatarSwitch.numAvailAvatars <= this.MIN_NUM_AVATARS)
            {
               shouldGrayOut = true;
            }
         }
         else if(this._isChoosing && (numNonMemberAvatars > 0 || hasAtLeastOneOpenSlot))
         {
            shouldGrayOut = true;
         }
         else if(numNonMemberAvatars < 2 && AvatarSwitch.numMemberAvatars == 0)
         {
            shouldGrayOut = true;
         }
         if(shouldGrayOut)
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
         this._scrollbar.init(this._itemWindows,840,440,0,"scrollbar2",222.5);
      }
      
      private function setupAvatarViews(index:int) : AvatarView
      {
         var avtView:AvatarView = new AvatarView();
         var avt:Avatar = AvatarSwitch.avatars[index];
         avt.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(avt.userName).getPartialItemList(avt.avTypeId,true));
         avtView.init(avt);
         avtView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
         var p:Point = AvatarUtility.getAnimalItemWindowOffset(avtView.avTypeId);
         avtView.x = p.x;
         avtView.y = p.y;
         return avtView;
      }
      
      public function resetSlots() : void
      {
         for(var i:int = 0; i < this._numTotalSlots; i++)
         {
            while(this._contentItems[i].gray.amlMask.amlBox.numChildren > 0)
            {
               this._contentItems[i].gray.amlMask.amlBox.removeChildAt(0);
            }
            while(this._contentItems[i].aml.amlMask.amlBox.numChildren > 0)
            {
               this._contentItems[i].aml.amlMask.amlBox.removeChildAt(0);
            }
         }
      }
      
      public function addAvatarCallback(status:int) : void
      {
         if(status == 1)
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
      
      public function isChoosingAddCallback(success:Boolean) : void
      {
         if(success)
         {
            this.resetSlots();
            this.initializePopupStates();
            this.buildWindows();
         }
      }
      
      public function switchAvatarCallback(success:Boolean, shouldHide:Boolean = false) : void
      {
         if(shouldHide)
         {
            if(Boolean(this._switchContent) && success)
            {
               this._switchContent.root.visible = false;
               return;
            }
         }
         if(success)
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
      
      private function recycleAvatarCallback(success:Boolean, removedIndex:int, removedInvId:int, newGemBalance:int, isCurrSlotAvailable:Boolean) : void
      {
         var slotMC:MovieClip = null;
         var i:int = 0;
         if(success)
         {
            this._hasDeletedAnAvatar = true;
            slotMC = this._contentItems[removedIndex];
            if(Boolean(this._views[removedIndex]))
            {
               this._views[removedIndex].destroy();
               this._views[removedIndex] = null;
            }
            this._recycling = false;
            if(removedIndex >= 0)
            {
               while(slotMC.aml.amlMask.amlBox.numChildren > 0)
               {
                  slotMC.aml.amlMask.amlBox.removeChildAt(0);
               }
               while(slotMC.gray.amlMask.amlBox.numChildren > 0)
               {
                  slotMC.gray.amlMask.amlBox.removeChildAt(0);
               }
            }
            for(i = 0; i < this._numTotalSlots; i++)
            {
               this._contentItems[i].recycle.visible = false;
            }
            slotMC.resetWindow(removedIndex);
            if(!gMainFrame.userInfo.isMember && !isCurrSlotAvailable)
            {
               if(!this._isChoosing)
               {
                  if(AvatarSwitch.numOpenNonMemberSlots >= this.SLOTS_PER_NONMEMBER)
                  {
                     slotMC.makeNew.newAmlBtn.gray.visible = true;
                  }
               }
               else
               {
                  slotMC.makeNew.newAmlBtn.gray.visible = true;
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
            this._myGemCount = newGemBalance;
            gMainFrame.clientInfo.gemCount = newGemBalance;
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
         var numSlots:int = 0;
         var availSlots:int = AvatarSwitch.availSlotFlags;
         for(var i:int = 0; i < this._numTotalSlots; i++)
         {
            if((availSlots & 1 << i) > 0)
            {
               numSlots++;
            }
         }
         return numSlots;
      }
      
      private function confirmRecycleHandler(o:Object) : void
      {
         if(Boolean(o.status))
         {
            if(Boolean(this._contentItems[this._idx].gray.visible) && Boolean(gMainFrame.userInfo.isMember))
            {
               AvatarSwitch.availSlotFlags |= 1 << AvatarXtCommManager.avSlotInfo[AvatarSwitch.avatars[this._idx].perUserAvId].avInvId;
            }
            AvatarSwitch.removeAvatar(this._idx,this.recycleAvatarCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function onItemWindowDown(evt:MouseEvent) : void
      {
         var text:String = null;
         var avt:Avatar = null;
         var removeIdx:int = 0;
         var avatarDef:Object = null;
         evt.stopPropagation();
         this._idx = evt.currentTarget.index;
         var currItem:MovieClip = this._contentItems[this._idx];
         if(Boolean(currItem.makeNew.visible))
         {
            if(!currItem.makeNew.newAmlBtn.gray.visible)
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
            if(Boolean(currItem.recycle.visible))
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
                     text = currItem.level > 0 ? LocalizationManager.translateIdAndInsertOnly(11229,currItem.level) : "";
                     new SBYesNoPopup(this._guiLayer,text + LocalizationManager.translateIdAndInsertOnly(11230,Utility.convertNumberToString(AvatarUtility.findAvDefByType(AvatarSwitch.avatars[this._idx].avTypeId).recycleValue)),true,this.confirmRecycleHandler);
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
         else if(currItem.aml.visible == true || currItem.den.visible == true)
         {
            if(this._isChoosing)
            {
               if(!AvatarSwitch.isMemberOnlyAvatar(this._idx))
               {
                  currItem.checkbox.check.visible = !currItem.checkbox.check.visible;
                  if(Boolean(currItem.checkbox.check.visible))
                  {
                     if(this._avatarsChosen.length < 2)
                     {
                        if(this._avatarsChosen.length > 0)
                        {
                           avt = AvatarSwitch.avatars[this._idx];
                           if(!Utility.isLand(avt.enviroTypeFlag) && Utility.isOcean(avt.enviroTypeFlag))
                           {
                              avt = AvatarSwitch.avatars[this._avatarsChosen[0]];
                              if(!Utility.isLand(avt.enviroTypeFlag) && Utility.isOcean(avt.enviroTypeFlag))
                              {
                                 LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11232);
                                 this._switchContent.oopsPopup.visible = true;
                                 currItem.checkbox.check.visible = !currItem.checkbox.check.visible;
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
                        avt = AvatarSwitch.avatars[this._idx];
                        if(!Utility.isLand(avt.enviroTypeFlag) && Utility.isOcean(avt.enviroTypeFlag))
                        {
                           avt = AvatarSwitch.avatars[this._avatarsChosen[1]];
                           if(!Utility.isLand(avt.enviroTypeFlag) && Utility.isOcean(avt.enviroTypeFlag))
                           {
                              LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11232);
                              this._switchContent.oopsPopup.visible = true;
                              currItem.checkbox.check.visible = !currItem.checkbox.check.visible;
                              return;
                           }
                        }
                        removeIdx = int(this._avatarsChosen[0]);
                        this._avatarsChosen.shift();
                        this._avatarsChosen.push(this._idx);
                        this._contentItems[removeIdx].checkbox.check.visible = false;
                        this._contentItems[removeIdx].aml.bg.visible = false;
                        this._contentItems[removeIdx].aml.sel.visible = false;
                     }
                     currItem.aml.bg.visible = true;
                     currItem.aml.sel.visible = true;
                  }
                  else
                  {
                     this._avatarsChosen.splice(this._avatarsChosen.indexOf(this._idx),1);
                     this._switchContent.saveAmlTag.visible = false;
                     currItem.aml.bg.visible = false;
                     currItem.aml.sel.visible = false;
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
         else if(currItem.lock.visible == true)
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
         else if(currItem.gray.visible == true)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               avatarDef = gMainFrame.userInfo.getAvatarDefByAvType(AvatarSwitch.avatars[this._idx].avTypeId);
               if(Boolean(avatarDef))
               {
                  UpsellManager.displayPopup(UpsellManager.ANIMAL_SLOTS,"useLockedAvatar/" + LocalizationManager.translateIdOnly(avatarDef.titleStrRef));
               }
               else
               {
                  UpsellManager.displayPopup(UpsellManager.ANIMAL_SLOTS,"useLockedAvatar");
               }
            }
         }
      }
      
      private function onItemWindowOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._idx = evt.currentTarget.index;
         if(this._contentItems[this._idx].aml.currentFrameLabel != "mouse")
         {
            this._contentItems[this._idx].aml.gotoAndPlay("mouse");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._idx = evt.currentTarget.index;
         if(this._contentItems[this._idx].aml.currentFrameLabel != "out")
         {
            this._contentItems[this._idx].aml.gotoAndPlay("out");
         }
      }
      
      private function onOopsClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(this._switchContent.oopsPopup);
         this._switchContent.oopsPopup.visible = false;
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.close();
      }
      
      private function onRecycleDown(evt:MouseEvent) : void
      {
         var i:int = 0;
         var j:int = 0;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(this._recycling)
         {
            for(i = 0; i < this._numTotalSlots; i++)
            {
               this._contentItems[i].recycle.visible = false;
            }
            this._recycling = false;
         }
         else if(!this._switchContent.recycleBtn.gray.visible)
         {
            this._recycling = true;
            for(j = 0; j < this._numTotalSlots; j++)
            {
               if(Boolean(this._views[j]))
               {
                  this._contentItems[j].recycle.visible = true;
               }
            }
         }
         else
         {
            this._switchContent.recycleBtn.mouse.visible = false;
         }
      }
      
      private function onRecycleOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14626),842,480);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onRecycleOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onSaveAnimalsDown(evt:MouseEvent) : void
      {
         var avtView:AvatarView = null;
         evt.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/avatarConfirm");
         if(this._avatarsChosen.length > 1)
         {
            while(this._choosingContent.amlsPopup._slot0.amlMask.amlBox.numChildren > 0)
            {
               this._choosingContent.amlsPopup._slot0.amlMask.amlBox.removeChildAt(0);
            }
            avtView = this.setupAvatarViews(this._avatarsChosen[0]);
            this._choosingContent.amlsPopup._slot0.amlMask.amlBox.addChild(avtView);
            this._choosingContent.amlsPopup._slot0.nameTxt.text = avtView.avName;
            while(this._choosingContent.amlsPopup._slot1.amlMask.amlBox.numChildren > 0)
            {
               this._choosingContent.amlsPopup._slot1.amlMask.amlBox.removeChildAt(0);
            }
            avtView = this.setupAvatarViews(this._avatarsChosen[1]);
            this._choosingContent.amlsPopup._slot1.amlMask.amlBox.addChild(avtView);
            this._choosingContent.amlsPopup._slot1.nameTxt.text = avtView.avName;
            DarkenManager.darken(this._choosingContent.amlsPopup);
            if(Boolean(this._currSoundChannel))
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
            avtView = this.setupAvatarViews(this._avatarsChosen[0]);
            this._choosingContent.oneAmlPopup._slot0.amlMask.amlBox.addChild(avtView);
            this._choosingContent.oneAmlPopup._slot0.nameTxt.text = avtView.avName;
            DarkenManager.darken(this._choosingContent.oneAmlPopup);
            this._choosingContent.oneAmlPopup.soundBtn.visible = false;
            this._choosingContent.oneAmlPopup.visible = true;
            this._choosingContent.oneAmlPopup.parent.setChildIndex(this._choosingContent.oneAmlPopup,this._choosingContent.oneAmlPopup.parent.numChildren - 1);
         }
      }
      
      private function onChooseOkNoDown(evt:MouseEvent) : void
      {
         SBTracker.pop();
         evt.stopPropagation();
         if(Boolean(this._currSoundChannel))
         {
            this._currSoundChannel.stop();
         }
         DarkenManager.unDarken(evt.currentTarget.parent);
         evt.currentTarget.parent.visible = false;
         if(evt.currentTarget == this._choosingContent.amlsPopup.okBtn || evt.currentTarget == this._choosingContent.oneAmlPopup.okBtn)
         {
            if(this._avatarsChosen.length == 1)
            {
               this.checkForAdditionalSpots();
            }
            DarkenManager.showLoadingSpiral(true);
            if(AvatarSwitch.activeAvatarIdx != AvatarXtCommManager.avSlotInfo[AvatarSwitch.avatars[this._avatarsChosen[0]].perUserAvId].slotId)
            {
               AvatarSwitch.setAvatarSwitchCallback(this.onSwitchComplete);
            }
            AvatarSwitch.chooseTwo(this._avatarsChosen,this.onChooseCallback);
         }
      }
      
      private function onChooseCallback(success:Boolean) : void
      {
         var avatars:Array = null;
         DarkenManager.showLoadingSpiral(false);
         if(success)
         {
            avatars = AvatarSwitch.avatars;
            if(this._avatarsChosen.length > 1 && Boolean(avatars[this._avatarsChosen[1]]))
            {
               AvatarSwitch.availSlotFlags = 1 << AvatarXtCommManager.avSlotInfo[avatars[this._avatarsChosen[0]].perUserAvId].avInvId | 1 << AvatarXtCommManager.avSlotInfo[avatars[this._avatarsChosen[1]].perUserAvId].avInvId;
            }
            else
            {
               AvatarSwitch.availSlotFlags = 1 << AvatarXtCommManager.avSlotInfo[avatars[this._avatarsChosen[0]].perUserAvId].avInvId;
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
      
      private function onSwitchComplete(success:Boolean, shouldHide:Boolean = false) : void
      {
         if(!success)
         {
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._switchContent.oopsPopup);
            LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11233);
            this._switchContent.oopsPopup.visible = true;
         }
      }
      
      private function onChooseSoundBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._currSoundChannel))
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
         for(var i:int = 0; i < this._numTotalSlots; i++)
         {
            if(this._avatarsChosen[0] != i)
            {
               if(AvatarSwitch.avatars[i] == null)
               {
                  this._avatarsChosen.push(i);
                  break;
               }
               if(!AvatarSwitch.isMemberOnlyAvatar(i))
               {
                  this._avatarsChosen.push(i);
                  break;
               }
            }
         }
      }
      
      private function addListeners() : void
      {
         if(Boolean(this._closeBtn))
         {
            this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         if(Boolean(this._switchContent))
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
         if(Boolean(this._closeBtn))
         {
            this._closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         }
         if(Boolean(this._switchContent))
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

