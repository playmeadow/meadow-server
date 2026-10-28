package customParty
{
   import Party.PartyManager;
   import Party.PartyXtCommManager;
   import avatar.AvatarManager;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiCarousel;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import gui.PartyPreviewManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class CustomPartyCreatePopup
   {
      
      private static const PARTY_NAMES_1:int = 386;
      
      private static const PARTY_NAMES_2:int = 387;
      
      private static const PARTY_NAMES_3:int = 388;
      
      private static const CUSTOM_PARTY_DEF_LIST_ID:int = 370;
      
      private const CUSTOM_PARTY_COST:int = 1;
      
      private const CUSTOM_PARTY_MEDIA_ID:int = 4413;
      
      private var _mediaHelper:MediaHelper;
      
      private var _roomIconMediaHelper:MediaHelper;
      
      private var _partyTagMediaHelper:MediaHelper;
      
      private var _callback:Function;
      
      private var _customCreatePopup:MovieClip;
      
      private var _currRoomIcon:MovieClip;
      
      private var _currPartyTag:MovieClip;
      
      private var _name1Carousel:GuiCarousel;
      
      private var _name2Carousel:GuiCarousel;
      
      private var _name3Carousel:GuiCarousel;
      
      private var _roomIconLoadingSpiral:LoadingSpiral;
      
      private var _partyTagLoadingSpiral:LoadingSpiral;
      
      private var _previewManager:PartyPreviewManager;
      
      private var _wheelBarrelNames:Array;
      
      private var _partyNameIndexes:Array;
      
      private var _partyNameChosenIds:Array;
      
      private var _partyDefIds:Array;
      
      private var _currPartyDef:Object;
      
      private var _currIconIndex:int;
      
      private var _diamondCount:int;
      
      private var _isRandomSpin:Boolean;
      
      public function CustomPartyCreatePopup(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _callback = param1;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4413,onCustomPartyPopupLoaded);
         _previewManager = new PartyPreviewManager();
         _previewManager.setCreatePopup(this);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         if(_previewManager)
         {
            if(param1)
            {
               _previewManager.handlePartyPurchase(true);
            }
            _previewManager.destroy();
            _previewManager = null;
         }
         if(_customCreatePopup)
         {
            removeEventListeners();
            _callback = null;
            _mediaHelper.destroy();
            _mediaHelper = null;
            if(_roomIconMediaHelper)
            {
               _roomIconMediaHelper.destroy();
               _roomIconMediaHelper = null;
            }
            if(_partyTagMediaHelper)
            {
               _partyTagMediaHelper.destroy();
               _partyTagMediaHelper = null;
            }
            _roomIconLoadingSpiral.destroy();
            _roomIconLoadingSpiral = null;
            _partyTagLoadingSpiral.destroy();
            _partyTagLoadingSpiral = null;
            DarkenManager.unDarken(_customCreatePopup);
            GuiManager.guiLayer.removeChild(_customCreatePopup);
            _customCreatePopup = null;
         }
      }
      
      public function showPopup(param1:Boolean) : void
      {
         if(_customCreatePopup)
         {
            _customCreatePopup.visible = param1;
            if(param1)
            {
               DarkenManager.darken(_customCreatePopup);
            }
            else
            {
               DarkenManager.unDarken(_customCreatePopup);
            }
         }
      }
      
      public function tryToHostPartyFromPreview() : void
      {
         onHostPartyBtn(null);
      }
      
      private function onCustomPartyPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _customCreatePopup = param1.getChildAt(0) as MovieClip;
         _roomIconLoadingSpiral = new LoadingSpiral(_customCreatePopup.room_itemWindow,_customCreatePopup.room_itemWindow.width * 0.5,_customCreatePopup.room_itemWindow.height * 0.5);
         _partyTagLoadingSpiral = new LoadingSpiral(_customCreatePopup.tag_itemWindow,_customCreatePopup.tag_itemWindow.width * 0.5,_customCreatePopup.tag_itemWindow.height * 0.5);
         loadAndSetupNamingWheels();
         loadAndSetupTags();
         setupPricingAndTags();
         addEventListeners();
         _customCreatePopup.x = 900 * 0.5;
         _customCreatePopup.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_customCreatePopup);
         DarkenManager.darken(_customCreatePopup);
      }
      
      private function loadAndSetupNamingWheels() : void
      {
         _partyNameIndexes = [-1,-1,1];
         _partyNameChosenIds = [0,0,0];
         Utility.loadNameBarrelListAndReturnSetupArrays(_wheelBarrelNames,setupNameLists,false,386,387,388);
      }
      
      private function randomizeNames() : void
      {
         _name1Carousel.soundsEnabled = false;
         _name2Carousel.soundsEnabled = false;
         _name3Carousel.soundsEnabled = false;
         _name1Carousel.pickRandomItem(true);
         _name2Carousel.pickRandomItem(true);
         _name3Carousel.pickRandomItem(true);
         _name1Carousel.soundsEnabled = true;
         _name2Carousel.soundsEnabled = true;
         _name3Carousel.soundsEnabled = true;
      }
      
      private function loadAndSetupTags() : void
      {
         GenericListXtCommManager.requestGenericList(370,onCustomPartyDefIdsLoaded);
      }
      
      private function addEventListeners() : void
      {
         _customCreatePopup.addEventListener("mouseDown",onPopup,false,0,true);
         _customCreatePopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _customCreatePopup.nameLever.addEventListener("mouseDown",onRandomLever,false,0,true);
         _customCreatePopup.hostPartyBtn_red.addEventListener("mouseDown",onHostPartyBtn,false,0,true);
         _customCreatePopup.hostPartyBtn_green.addEventListener("mouseDown",onHostPartyBtn,false,0,true);
         _customCreatePopup.leftBtn.addEventListener("mouseDown",onLeftRightBtn,false,0,true);
         _customCreatePopup.rightBtn.addEventListener("mouseDown",onLeftRightBtn,false,0,true);
         _customCreatePopup.previewBtn.addEventListener("mouseDown",onPreviewBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _customCreatePopup.removeEventListener("mouseDown",onPopup);
         _customCreatePopup.bx.removeEventListener("mouseDown",onCloseBtn);
         _customCreatePopup.nameLever.removeEventListener("mouseDown",onRandomLever);
         _customCreatePopup.hostPartyBtn_red.removeEventListener("mouseDown",onHostPartyBtn);
         _customCreatePopup.hostPartyBtn_green.removeEventListener("mouseDown",onHostPartyBtn);
         _customCreatePopup.leftBtn.removeEventListener("mouseDown",onLeftRightBtn);
         _customCreatePopup.rightBtn.removeEventListener("mouseDown",onLeftRightBtn);
         _customCreatePopup.previewBtn.removeEventListener("mouseDown",onPreviewBtn);
      }
      
      private function loadRoomAndPartyIcon() : void
      {
         _currPartyDef = PartyManager.getPartyDef(_partyDefIds[_currIconIndex]);
         if(_currPartyDef)
         {
            _partyTagLoadingSpiral.visible = true;
            _partyTagMediaHelper = new MediaHelper();
            _partyTagMediaHelper.init(_currPartyDef.mediaRefId,onPartyTagLoaded);
            _roomIconLoadingSpiral.visible = true;
            _roomIconMediaHelper = new MediaHelper();
            _roomIconMediaHelper.init(_currPartyDef.iconMediaRefId,onRoomIconLoaded);
         }
      }
      
      private function setupPartyTagText() : void
      {
         if(_currPartyTag)
         {
            LocalizationManager.updateToFit(_currPartyTag.txt.titleTxtCont.titleTxt,_name1Carousel.selectedContentItem + " " + _name2Carousel.selectedContentItem + " " + _name3Carousel.selectedContentItem);
         }
      }
      
      private function setupPricingAndTags() : void
      {
         _diamondCount = UserCurrency.getCurrency(3);
         _customCreatePopup.tag.gotoAndStop(_diamondCount < 1 ? "red" : "green");
         _customCreatePopup.hostPartyBtn_green.visible = _diamondCount >= 1;
         _customCreatePopup.hostPartyBtn_red.visible = !_customCreatePopup.hostPartyBtn_green.visible;
         _customCreatePopup.gem_count_txt.text = Utility.convertNumberToString(_diamondCount);
         _customCreatePopup.tag.costTxt.text = 1;
      }
      
      private function setupNameLists(param1:Array) : void
      {
         _wheelBarrelNames = param1;
         _name1Carousel = new GuiCarousel(_customCreatePopup.nameScroller1);
         _name2Carousel = new GuiCarousel(_customCreatePopup.nameScroller2);
         _name3Carousel = new GuiCarousel(_customCreatePopup.nameScroller3);
         var _loc2_:int = 0;
         var _loc3_:int = 1;
         var _loc4_:int = 2;
         if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
         {
            _loc2_ = 2;
            _loc3_ = 0;
            _loc4_ = 1;
         }
         else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
         {
            _loc2_ = 2;
            _loc3_ = 1;
            _loc4_ = 0;
         }
         _name1Carousel.init(param1[_loc2_].names,names1Changed,false,false,null,false,_partyNameIndexes[0]);
         _name2Carousel.init(param1[_loc3_].names,names2Changed,false,false,null,false,_partyNameIndexes[1]);
         _name3Carousel.init(param1[_loc4_].names,names3Changed,false,false,null,false,_partyNameIndexes[2]);
         randomizeNames();
      }
      
      private function names1Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            setupPartyTagText();
            _partyNameChosenIds[0] = _wheelBarrelNames[0].locIds[_name1Carousel.contentItemIndex];
            _partyNameIndexes[0] = _name1Carousel.contentItemIndex;
         }
      }
      
      private function names2Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            setupPartyTagText();
            _partyNameChosenIds[1] = _wheelBarrelNames[1].locIds[_name2Carousel.contentItemIndex];
            _partyNameIndexes[1] = _name2Carousel.contentItemIndex;
         }
         if(!_name2Carousel.soundsEnabled && _isRandomSpin)
         {
            _name2Carousel.soundsEnabled = true;
            _name3Carousel.soundsEnabled = true;
            _isRandomSpin = false;
         }
         if(_wheelBarrelNames[2] && _name3Carousel.hasLoaded)
         {
            if(_name3Carousel.soundsEnabled)
            {
               _name3Carousel.soundsEnabled = false;
               _name3Carousel.spinToIndex(_name3Carousel.contentItemIndex,true);
               _name3Carousel.soundsEnabled = true;
            }
            else
            {
               _name3Carousel.spinToIndex(_name3Carousel.contentItemIndex,true);
            }
         }
      }
      
      private function names3Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            setupPartyTagText();
            _partyNameChosenIds[2] = _wheelBarrelNames[2].locIds[_name3Carousel.contentItemIndex];
            _partyNameIndexes[2] = _name3Carousel.contentItemIndex;
         }
         if(!_name3Carousel.soundsEnabled && _isRandomSpin)
         {
            _name3Carousel.soundsEnabled = true;
            _name2Carousel.soundsEnabled = true;
            _isRandomSpin = false;
         }
      }
      
      private function onCustomPartyDefIdsLoaded(param1:int, param2:Array, param3:Function) : void
      {
         _partyDefIds = param2;
         loadRoomAndPartyIcon();
      }
      
      private function onRoomIconLoaded(param1:MovieClip) : void
      {
         if(_currRoomIcon != null)
         {
            _customCreatePopup.room_itemWindow.removeChild(_currRoomIcon);
         }
         _currRoomIcon = param1.getChildAt(0) as MovieClip;
         _customCreatePopup.room_itemWindow.addChild(_currRoomIcon);
         _roomIconLoadingSpiral.visible = false;
      }
      
      private function onPartyTagLoaded(param1:MovieClip) : void
      {
         if(_currPartyTag != null)
         {
            _customCreatePopup.tag_itemWindow.removeChild(_currPartyTag);
         }
         _currPartyTag = param1.getChildAt(0) as MovieClip;
         _currPartyTag.mouseChildren = false;
         _currPartyTag.mouseChildren = false;
         _currPartyTag.goBtn.visible = false;
         if(_currPartyDef.txt)
         {
            _currPartyTag.txt.timeTxt.visible = false;
         }
         if(_currPartyDef.timerBg)
         {
            _currPartyTag.timerBg.visible = false;
         }
         _partyTagLoadingSpiral.visible = false;
         _customCreatePopup.tag_itemWindow.addChild(_currPartyTag);
         setupPartyTagText();
      }
      
      private function onConfirmHost() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _previewManager.handlePartyPurchase();
         PartyXtCommManager.sendCustomPartyHostRequest(_currPartyDef.id,_currPartyTag.txt.titleTxtCont.titleTxt.text);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_callback != null)
         {
            _callback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onRandomLever(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_customCreatePopup.nameLever.currentFrameLabel == "_up")
         {
            _isRandomSpin = true;
            _name2Carousel.soundsEnabled = false;
            _name3Carousel.soundsEnabled = false;
            AJAudio.playRandomLever();
            _customCreatePopup.nameLever.gotoAndPlay("_play");
            _name1Carousel.pickRandomItem();
            _name2Carousel.pickRandomItem();
            _name3Carousel.pickRandomItem();
         }
      }
      
      private function onHostPartyBtn(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!gMainFrame.userInfo.isMember)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(24236));
         }
         else if(_diamondCount >= 1)
         {
            if(_currPartyDef)
            {
               _loc2_ = "";
               _loc2_ = LocalizationManager.translateIdOnly(24266);
               GuiManager.showDiamondConfirmation(1,onConfirmHost,_loc2_,LocalizationManager.translateIdOnly(24223));
            }
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(24247));
         }
      }
      
      private function onLeftRightBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _customCreatePopup.leftBtn)
         {
            _currIconIndex = _currIconIndex - 1;
            if(_currIconIndex < 0)
            {
               _currIconIndex = _partyDefIds.length - 1;
            }
         }
         else
         {
            _currIconIndex = _currIconIndex + 1;
            if(_currIconIndex >= _partyDefIds.length)
            {
               _currIconIndex = 0;
            }
         }
         loadRoomAndPartyIcon();
      }
      
      private function onPreviewBtn(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(_currPartyDef)
         {
            _loc2_ = RoomXtCommManager.getRoomDef(_currPartyDef.roomDefId);
            if(_loc2_)
            {
               if(Utility.isSameEnviroType(AvatarManager.playerAvatar.enviroTypeFlag,_loc2_.enviroType))
               {
                  DarkenManager.unDarken(_customCreatePopup);
                  RoomManagerWorld.instance.loadPreviewRoom(_loc2_.pathName,_loc2_.enviroType,_previewManager);
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(Utility.isOcean(AvatarManager.playerAvatar.enviroTypeFlag) ? 24263 : 24262));
               }
            }
         }
      }
   }
}

