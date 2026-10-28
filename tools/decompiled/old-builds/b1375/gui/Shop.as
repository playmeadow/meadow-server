package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarItem;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarView;
   import collection.AccItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import currency.CombinedCurrencyItem;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenRoomItem;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.system.ApplicationDomain;
   import gskinner.motion.GTween;
   import gui.itemWindows.ItemWindowSatchel;
   import inventory.Iitem;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetItem;
   import pet.PetManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TutorialPopups;
   
   public class Shop
   {
      
      public static const SHOP_MEDIA_ID:int = 3934;
      
      private static const EXTENDED_ITEM_COUNT_BIT_INDEX:int = 1;
      
      private static const NUM_EXTRA_SLOTS_DEN:int = 800;
      
      private static const NUM_EXTRA_SLOTS_ACC:int = 900;
      
      private static const NUM_ACC_SLOTS:int = 100;
      
      private static const NUM_DEN_SLOTS:int = 200;
      
      private static const NUM_AUDIO_SLOTS:int = 48;
      
      private static const WARNING_ITEM_COUNT:int = 95;
      
      private static const WARNING_DEN_ITEM_COUNT:int = 195;
      
      private static const WARNING_DEN_AUDIO_COUNT:int = 45;
      
      private static const WARNING_DEN_ROOM_COUNT_OFFSET:int = 3;
      
      public static const DEN_EDIT_TUTORIAL_SHOP_BUY:int = 7;
      
      public static const DEN_EDIT_TUTORIAL_COMPLETE:int = 8;
      
      private const DEN_EDIT_TUTORIAL_SHOP_PREVIEW:int = 6;
      
      protected const ITEMS_PER_SCREEN:int = 6;
      
      protected const GLOW_FILTER_COLOR:uint = 5586479;
      
      protected const GLOW_FILTER_ALPHA:Number = 1;
      
      protected var _closeCallback:Function;
      
      protected var _denRoomShopCallback:Function;
      
      protected var _onPurchaseSuccessCallback:Function;
      
      protected var _shopId:int;
      
      protected var _glDefType:int;
      
      protected var _playerAvatar:Avatar;
      
      protected var _shop:MovieClip;
      
      protected var _popupLayer:DisplayLayer;
      
      protected var _unfilteredItemArray:IitemCollection;
      
      protected var _unfilteredColorsArray:Array;
      
      protected var _currShopItemArray:IitemCollection;
      
      protected var _shopItemArray:IitemCollection;
      
      protected var _shopItemArrayReversed:IitemCollection;
      
      protected var _shopItemArrayGemHigh:IitemCollection;
      
      protected var _shopItemArrayGemLow:IitemCollection;
      
      protected var _shopItemArrayNameHigh:IitemCollection;
      
      protected var _shopItemArrayNameLow:IitemCollection;
      
      protected var _itemColorsArray:Array;
      
      protected var _denItemColorsArray:Array;
      
      protected var _numItems:int;
      
      protected var _shopNameId:int;
      
      protected var _itemToBuy:Iitem;
      
      protected var _bItemsPurchased:Boolean;
      
      protected var _isMember:Boolean;
      
      protected var _itemIdx:int = -1;
      
      protected var _itemColorIdx:int;
      
      protected var _itemOffset:int;
      
      protected var _denItemIdx:int;
      
      protected var _useStartupShopIndex:int;
      
      protected var _spirals:Array;
      
      protected var _pageURI:String;
      
      protected var _lastPage:int;
      
      protected var _isDenAudioList:Boolean;
      
      protected var _isShopOnlyDen:Boolean;
      
      protected var _itemNotAvailPopup:SBOkPopup;
      
      protected var _infoTweenFinished:Boolean;
      
      protected var _isInfoOpen:Boolean;
      
      protected var _appendString:String;
      
      protected var _isInFFM:Boolean;
      
      protected var _recyclePopup:RecycleItems;
      
      protected var _showTutorial:Boolean;
      
      protected var _mediaHelper:MediaHelper;
      
      protected var _currLoaderAppDomain:ApplicationDomain;
      
      protected var _satchelWindow:WindowAndScrollbarGenerator;
      
      protected var _denPreviewManager:DenPreviewManager;
      
      protected var _isCombinedCurrencyStore:Boolean;
      
      protected var _shopWithPreview:ShopWithPreview;
      
      public function Shop()
      {
         super();
      }
      
      public static function get maxItems() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << 1) != 0)
         {
            return 100 + 900;
         }
         return 100;
      }
      
      public static function get maxDenItems() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << 1) != 0)
         {
            return 200 + 800;
         }
         return 200;
      }
      
      public static function get maxAudioItems() : int
      {
         return 48;
      }
      
      public static function get warningItemCount() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << 1) != 0)
         {
            return 95 + 900;
         }
         return 95;
      }
      
      public static function get warningDenItemCount() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << 1) != 0)
         {
            return 195 + 800;
         }
         return 195;
      }
      
      public static function get warningAudioItemCount() : int
      {
         return 45;
      }
      
      public static function get warningDenRoomCount() : int
      {
         return 32 - 3;
      }
      
      public function init(param1:int, param2:int, param3:Avatar, param4:DisplayLayer, param5:Function = null, param6:int = 0, param7:Function = null, param8:Boolean = false, param9:int = -1) : void
      {
         DarkenManager.showLoadingSpiral(true);
         SBTracker.push();
         _shopId = param1;
         _glDefType = param2;
         _playerAvatar = param3;
         _popupLayer = param4;
         _appendString = "";
         _isMember = gMainFrame.userInfo.isMember;
         _denRoomShopCallback = param7;
         _isShopOnlyDen = param8;
         _isInFFM = GuiManager.isInFFM;
         _useStartupShopIndex = param9;
         _denItemIdx = param6;
         _closeCallback = param5;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(3934,onShopLoaded);
      }
      
      public function get showTutorial() : Boolean
      {
         return _showTutorial;
      }
      
      public function set denItemIdx(param1:int) : void
      {
         _denItemIdx = param1;
      }
      
      public function showShop(param1:Boolean) : void
      {
         if(_shop.visible != param1)
         {
            _shop.visible = param1;
            if(param1)
            {
               DarkenManager.darken(_shop);
            }
            else
            {
               DarkenManager.unDarken(_shop);
            }
            if(param1)
            {
               setupBigBuyPopup();
            }
         }
         if(param1)
         {
            _denPreviewManager.destroy();
            _denPreviewManager = null;
         }
      }
      
      public function attemptToBuyCurrrentItem() : void
      {
         buyBtnDownHandler(null);
      }
      
      protected function onShopLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _currLoaderAppDomain = param1.loaderInfo.applicationDomain;
            _shop = param1.getChildAt(0) as MovieClip;
            _showTutorial = _shopId == 234;
            if(_showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,6))
            {
               TutorialPopups.openTutorialTextPopup(18659,10,115);
            }
            _spirals = [];
            _loc2_ = 0;
            while(_loc2_ < 6)
            {
               _shop["iw" + _loc2_].lock.visible = false;
               _shop["iw" + _loc2_].lockOpen.visible = false;
               _shop["iw" + _loc2_].blueBG.visible = false;
               if(_spirals[_loc2_])
               {
                  _spirals[_loc2_].destroy();
               }
               _loc2_++;
            }
            _shop.x = 900 * 0.5;
            _shop.y = 550 * 0.5;
            toggleInitialVisibility();
            _bItemsPurchased = false;
            ItemXtCommManager.requestShopList(gotItemListCallback,_shopId);
         }
      }
      
      protected function toggleInitialVisibility() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < 6)
         {
            _loc1_ = _shop["iw" + _loc2_];
            _loc1_.tag.visible = !_loc1_.tag.visible;
            _loc1_.tagTall.visible = false;
            _loc1_.banner.visible = false;
            _loc1_.newTag.visible = false;
            _loc1_.saleTag.visible = false;
            _loc1_.clearanceTag.visible = false;
            _loc1_.daysLeftTag.visible = false;
            _loc1_.itemNameTxt.visible = !_loc1_.itemNameTxt.visible;
            _loc1_.itemNameTxtMultiline.visible = !_loc1_.itemNameTxtMultiline.visible;
            _loc1_.ocean.visible = false;
            if(_loc1_.yellowBG)
            {
               _loc1_.yellowBG.visible = false;
            }
            _loc2_++;
         }
         _shop.buyPopup.paw.visible = false;
         _shop.buyPopup.newTag.visible = false;
         _shop.buyPopup.saleTag.visible = false;
         _shop.buyPopup.clearanceTag.visible = false;
         _shop.buyPopup.daysLeftTag.visible = false;
         _shop.buyPopup.ocean.visible = false;
         _shop.buyPopup.tag.visible = false;
         _shop.buyPopup.tagTall.visible = false;
         if(_shop.buyBigPopup)
         {
            _shop.buyBigPopup.visible = false;
            _shop.buyBigPopup.newTag.visible = false;
            _shop.buyBigPopup.saleTag.visible = false;
            _shop.buyBigPopup.clearanceTag.visible = false;
            _shop.buyBigPopup.daysLeftTag.visible = false;
            _shop.buyBigPopup.ocean.visible = false;
            _shop.buyBigPopup.tag.visible = false;
            _shop.buyBigPopup.tagTall.visible = false;
            _shop.colorCycleBigBtn.visible = false;
            _shop.colorCycleBigFlash.visible = false;
         }
         _shop.sortBtn.visible = false;
         if(_shop.sortBtnDiamond)
         {
            _shop.sortBtnDiamond.visible = false;
         }
         _shop.sortingPopup.visible = false;
         if(_shop.sortingPopupDiamond)
         {
            _shop.sortingPopupDiamond.visible = false;
         }
         _shop.titleTxt.text = "";
         if(_shop.titleTxtDiamond)
         {
            _shop.titleTxtDiamond.text = "";
         }
         _shop.buyPopup.visible = false;
         if(_shop.oopsPopup)
         {
            _shop.oopsPopup.visible = false;
         }
         _shop.gemAnim.visible = false;
      }
      
      private function setupDiamondItems(param1:Boolean) : void
      {
         if(param1)
         {
            _appendString = "Diamond";
            if(_shop.buyBigPopup)
            {
               _shop.buyBigPopup.buyGreenBGDiamond.visible = true;
               _shop.buyBigPopup.buyGreenBG.visible = false;
               _shop.buyBigPopup.buyBlueBGDiamond.visible = true;
               _shop.buyBigPopup.buyBlueBG.visible = false;
               _shop.buyBigPopup.bgDiamond.visible = true;
               _shop.buyBigPopup.bg.visible = false;
            }
            _shop.buyPopup.buyGreenBGDiamond.visible = true;
            _shop.buyPopup.buyGreenBG.visible = false;
            _shop.buyPopup.buyBlueBGDiamond.visible = true;
            _shop.buyPopup.buyBlueBG.visible = false;
            _shop.buyPopup.bgDiamond.visible = true;
            _shop.buyPopup.bg.visible = false;
            if(_shop.buyPopup.questAbilities)
            {
               _shop.buyPopup.questAbilitiesDiamond.visible = false;
               _shop.buyPopup.questAbilities.visible = false;
            }
            _shop.titleTxtDiamond.visible = true;
            if(_shop.currentFrameLabel == "twoCurrency")
            {
               _shop.gemBanner.visible = true;
               _shop.myGemCountTxt.visible = true;
            }
            else
            {
               _shop.gemBanner.visible = false;
               _shop.myGemCountTxt.visible = false;
            }
            _shop.titleTxt = _shop.titleTxtDiamond;
            _shop.sparkleCont.visible = true;
            _shop.infoBtn.visible = true;
         }
         else
         {
            if(_shop.buyBigPopup)
            {
               _shop.buyBigPopup.buyGreenBGDiamond.visible = false;
               _shop.buyBigPopup.buyBlueBGDiamond.visible = false;
               _shop.buyBigPopup.bgDiamond.visible = false;
               _shop.buyBigPopup.sparkleCont.visible = false;
            }
            _shop.buyPopup.buyGreenBGDiamond.visible = false;
            _shop.buyPopup.buyBlueBGDiamond.visible = false;
            _shop.buyPopup.bgDiamond.visible = false;
            if(_shop.buyPopup.questAbilitiesDiamond)
            {
               _shop.buyPopup.questAbilitiesDiamond.visible = false;
            }
            if(_shop.titleBannerDiamond)
            {
               _shop.titleBannerDiamond.visible = false;
            }
            if(_shop.titleTxtDiamond)
            {
               _shop.titleTxtDiamond.visible = false;
            }
            if(_shop.oopsCostPopupDiamond)
            {
               _shop.oopsCostPopupDiamond.visible = false;
            }
            if(_shop.myGemCountTxtDiamond && _glDefType != 1060)
            {
               _shop.myGemCountTxtDiamond.visible = false;
               _shop.gemBannerDiamond.visible = false;
               _shop.myGemCountTxt.visible = true;
               if(_shop.infoBtn)
               {
                  _shop.infoBtn.visible = false;
               }
            }
            if(_shop.sparkleCont)
            {
               _shop.sparkleCont.visible = false;
            }
            _shop.buyPopup.sparkleCont.visible = false;
            if(_shop.sortBtnDiamond)
            {
               _shop["sortBtnDiamond"].visible = false;
               _shop["sortingPopupDiamond"].visible = false;
            }
            if(_shop.infoBtn)
            {
               _shop.infoBtn.visible = false;
            }
         }
         if(!_isCombinedCurrencyStore)
         {
            if(_shopWithPreview)
            {
               _shop["sortBtn"].visible = true;
               _shop["sortingPopup"].visible = false;
            }
            else
            {
               _shop["sortBtn" + _appendString].visible = true;
               _shop["sortingPopup" + _appendString].visible = false;
            }
         }
         if(_shop.oopsCostPopup)
         {
            _shop.oopsCostPopup.visible = false;
            _shop["oopsCostPopup" + _appendString].visible = false;
         }
         if(_shop.buyPopup["questAbilities" + _appendString])
         {
            _shop.buyPopup["questAbilities" + _appendString].visible = false;
         }
      }
      
      private function setupCombinedCurrencyItems(param1:Boolean) : void
      {
         if(param1)
         {
            _shop.gotoAndStop("combinedCurrency");
            _shop.buyPopup.tag.visible = false;
            _shop.buyBigPopup.tag.visible = false;
            _shop.buyPopup.tagTall.visible = true;
            _shop.buyBigPopup.tagTall.visible = true;
            if(_shopNameId != 0)
            {
               LocalizationManager.translateId(_shop.titleTxt,_shopNameId);
            }
            else
            {
               _shop.titleTxt.text = "";
            }
            _satchelWindow = new WindowAndScrollbarGenerator();
            _satchelWindow.init(_shop.satchelCont.itemWindow.width,_shop.satchelCont.itemWindow.height,0,0,1,7,0,0,3,0,1.5,ItemWindowSatchel,[4143,4138,4144,4142,4141,4140,4139],"",0,null,null,null,true,false,true,true);
            _shop.satchelCont.itemWindow.addChild(_satchelWindow);
         }
         else
         {
            if(_glDefType == 1060)
            {
               _shop.gotoAndStop("twoCurrency");
               _shop.gemAnim.visible = false;
               _shop.diamondAnim.visible = false;
            }
            else if(_shop.currentLabels.length > 0)
            {
               _shop.gotoAndStop("singleCurrency");
            }
            if(_shopNameId != 0)
            {
               LocalizationManager.translateId(_shop.titleTxt,_shopNameId);
               if(_shop.titleTxtDiamond)
               {
                  LocalizationManager.translateId(_shop.titleTxtDiamond,_shopNameId);
               }
            }
            else
            {
               _shop.titleTxt.text = "";
               if(_shop.titleTxtDiamond)
               {
                  _shop.titleTxtDiamond.text = "";
               }
            }
            _shop.buyPopup.tagTall.visible = false;
            if(_shop.buyBigPopup)
            {
               _shop.buyBigPopup.tagTall.visible = false;
            }
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         SBTracker.pop();
         if(_denPreviewManager)
         {
            _denPreviewManager.destroy();
            _denPreviewManager = null;
         }
         removeListeners();
         if(_shopItemArray && _shopItemArray.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _shopItemArray.length)
            {
               _shopItemArray.getIitem(_loc2_).destroy();
               if(_shopItemArrayReversed)
               {
                  _shopItemArrayReversed.getIitem(_loc2_).destroy();
                  _shopItemArrayGemHigh.getIitem(_loc2_).destroy();
                  _shopItemArrayGemLow.getIitem(_loc2_).destroy();
                  _shopItemArrayNameHigh.getIitem(_loc2_).destroy();
                  _shopItemArrayNameLow.getIitem(_loc2_).destroy();
               }
               _loc2_++;
            }
            _shopItemArray = null;
            _shopItemArrayReversed = null;
            _shopItemArrayGemHigh = null;
            _shopItemArrayGemLow = null;
            _shopItemArrayNameHigh = null;
            _shopItemArrayNameLow = null;
         }
         _shopItemArray = null;
         if(_spirals && _spirals.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _spirals.length)
            {
               _spirals[_loc1_].destroy();
               _loc1_++;
            }
            _spirals = null;
         }
         TutorialPopups.closeTutorialTextPopup();
         _spirals = null;
         _closeCallback = null;
         if(_shop.buyPopup.visible)
         {
            DarkenManager.unDarken(_shop.buyPopup);
         }
         if(_shop.buyBigPopup && _shop.buyBigPopup.visible)
         {
            DarkenManager.unDarken(_shop.buyBigPopup);
         }
         DarkenManager.unDarken(_shop);
         _popupLayer.removeChild(_shop);
         _shop = null;
      }
      
      public function setOnPurchaseSuccessCallback(param1:Function) : void
      {
         _onPurchaseSuccessCallback = param1;
      }
      
      public function get isAudioShop() : Boolean
      {
         return _isDenAudioList;
      }
      
      public function applyAndClose() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback(_bItemsPurchased);
         }
         else
         {
            destroy();
         }
      }
      
      public function gotItemListCallback(param1:IitemCollection, param2:String, param3:Array = null) : void
      {
         if(param2 != "")
         {
            _shopNameId = int(param2);
            LocalizationManager.translateId(_shop.titleTxt,_shopNameId);
            if(_shop.titleTxtDiamond)
            {
               LocalizationManager.translateId(_shop.titleTxtDiamond,_shopNameId);
            }
         }
         _pageURI = "/game/play/popup/store/";
         switch(_glDefType)
         {
            case 1000:
               _pageURI += "accessory/#";
               break;
            case 1030:
               if(_isDenAudioList)
               {
                  _pageURI += "denAudio/#";
               }
               else
               {
                  _pageURI += "denItem/#";
               }
               break;
            case 1040:
               _pageURI += "denRoom/#";
               break;
            case 1051:
               _pageURI += "currency/#";
            case 1054:
               _pageURI += "diamond/#";
         }
         _pageURI += param2 + "/page";
         _unfilteredItemArray = param1;
         _unfilteredColorsArray = param3;
         filterItemLists();
      }
      
      public function filterItemLists() : void
      {
         if(GenericListXtCommManager.isAvailListExpired())
         {
            GenericListXtCommManager.requestGenericList(1,filterItemLists);
            return;
         }
         _shopItemArray = new IitemCollection(_unfilteredItemArray.concatCollection(null));
         if(_unfilteredColorsArray)
         {
            _itemColorsArray = _unfilteredColorsArray.concat();
         }
         else
         {
            _itemColorsArray = null;
         }
         if(_shop.titleTxt.text != "")
         {
            GenericListXtCommManager.filterIitemList(_glDefType,_shopItemArray,true,_itemColorsArray);
         }
         _currShopItemArray = _shopItemArray;
         initialShopSetup();
      }
      
      public function getCurrentItemDefId() : int
      {
         var _loc3_:Object = null;
         var _loc2_:Object = _currShopItemArray.getIitem(_itemIdx);
         var _loc1_:int = int(_loc2_.defId);
         if(_loc2_.currencyType == 3)
         {
            _loc3_ = DiamondXtCommManager.getDiamondDef(_loc2_.diamondItem.defId);
            if(_loc3_)
            {
               _loc1_ = int(_loc3_.refDefId);
            }
         }
         return _loc1_;
      }
      
      public function get isCurrentItemDiamond() : Boolean
      {
         return _currShopItemArray.getIitem(_itemIdx).currencyType == 3;
      }
      
      private function initialShopSetup() : void
      {
         DarkenManager.showLoadingSpiral(false);
         _shop.visible = true;
         if(_shopItemArray)
         {
            _numItems = _shopItemArray.length;
         }
         else
         {
            _numItems = 0;
         }
         if(_numItems > 0)
         {
            if(_shopItemArray.getIitem(0) is DenItem && (_shopItemArray.getIitem(0) as DenItem).sortId == 4)
            {
               _isDenAudioList = true;
            }
            if(_shopItemArray.getIitem(0).currencyType == 1)
            {
               _shop.currency.gotoAndStop("tickets");
            }
            else if(_shopItemArray.getIitem(0).currencyType == 0 || _glDefType == 1060)
            {
               _shop.currency.gotoAndStop("gems");
            }
            else if(_shopItemArray.getIitem(0).currencyType == 2)
            {
               _shop.currency.gotoAndStop("earth");
            }
            else if(_shopItemArray.getIitem(0).currencyType == 3)
            {
               _shop.currency.gotoAndStop("diamonds");
               _shop.frame.gotoAndStop("diamond");
            }
         }
         _isCombinedCurrencyStore = _shopItemArray.getIitem(0).currencyType == 100;
         setupCombinedCurrencyItems(_isCombinedCurrencyStore);
         setupDiamondItems(_shopItemArray.getIitem(0).currencyType == 3 && _glDefType != 1060);
         if(!_isCombinedCurrencyStore)
         {
            if(_shopWithPreview)
            {
               _shop["sortBtn"].gotoAndStop("timeBtnDn");
            }
            else
            {
               _shop["sortBtn" + _appendString].gotoAndStop("timeBtnDn");
            }
            _shopItemArrayReversed = new IitemCollection(_shopItemArray.getCoreArray().concat().reverse());
            if(_shop.currentFrameLabel == "twoCurrency")
            {
               _shopItemArrayGemLow = new IitemCollection(_shopItemArray.getCoreArray().concat().sort(function(param1:Iitem, param2:Iitem):int
               {
                  if(param1.isDiamond && param2.isDiamond || !param1.isDiamond && !param2.isDiamond)
                  {
                     if(param1.value < param2.value)
                     {
                        return -1;
                     }
                     if(param1.value > param2.value)
                     {
                        return 1;
                     }
                     return 0;
                  }
                  if(param1.isDiamond)
                  {
                     return 1;
                  }
                  if(param2.isDiamond)
                  {
                     return -1;
                  }
                  return 0;
               }));
            }
            else
            {
               _shopItemArrayGemLow = new IitemCollection(_shopItemArray.getCoreArray().concat().sortOn("value",16));
            }
            _shopItemArrayGemHigh = new IitemCollection(_shopItemArrayGemLow.getCoreArray().concat().reverse());
            _shopItemArrayNameLow = new IitemCollection(_shopItemArray.getCoreArray().concat().sortOn("name",2));
            _shopItemArrayNameHigh = new IitemCollection(_shopItemArrayNameLow.getCoreArray().concat().reverse());
         }
         if(_shop.currentFrameLabel == "singleCurrency" || _shop.currentLabels.length == 0)
         {
            _shop["myGemCountTxt" + _appendString].text = Utility.convertNumberToString(UserCurrency.getCurrency(_shopItemArray.getIitem(0).currencyType));
         }
         else if(_shop.currentFrameLabel == "twoCurrency")
         {
            _shop.currencyDiamond.gotoAndStop("diamonds");
            _shop.myGemCountTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(0));
            _shop.myGemCountTxtDiamond.text = Utility.convertNumberToString(UserCurrency.getCurrency(3));
            _shop.myGemCountTxtDiamond.visible = true;
         }
         if(_numItems <= 6)
         {
            _shop.nextBtn.activateGrayState(true);
            _shop.prevBtn.activateGrayState(true);
         }
         _popupLayer.addChild(_shop);
         DarkenManager.darken(_shop);
         addListeners();
         setupShopWindows();
         if(_useStartupShopIndex != -1)
         {
            onItemWindowDown(null);
         }
      }
      
      private function setupShopWindows() : void
      {
         var _loc6_:int = 0;
         var _loc1_:Iitem = null;
         var _loc5_:MovieClip = null;
         var _loc4_:Iitem = null;
         var _loc3_:Matrix = null;
         var _loc2_:int = int(_itemOffset / 6) + 1;
         if(_lastPage != _loc2_)
         {
            SBTracker.trackPageview(_pageURI + _loc2_);
            _lastPage = _loc2_;
         }
         _loc6_ = 0;
         while(_loc6_ < 6)
         {
            _loc1_ = _currShopItemArray.length > _loc6_ + _itemOffset ? _currShopItemArray.getIitem(_loc6_ + _itemOffset) : null;
            _loc5_ = _shop["iw" + _loc6_];
            while(_loc5_.itemLayer.numChildren > 1)
            {
               _loc5_.itemLayer.removeChildAt(1);
            }
            _loc5_.removeEventListener("mouseDown",onItemWindowDown);
            _loc5_.removeEventListener("rollOver",onItemWindowRollOver);
            _loc5_.removeEventListener("rollOut",onItemWindowRollOut);
            if(_loc1_)
            {
               _loc4_ = _loc1_;
               if(_shopWithPreview && _loc4_ is Item)
               {
                  (_loc4_ as Item).specialScale = 0.4;
               }
               if(_loc4_.icon)
               {
                  if(!(_loc4_ is DenItem) && !(_loc4_ is AvatarItem) && !(_loc4_ is PetItem))
                  {
                     _loc4_.icon.filters = [new GlowFilter(5586479,1,2,2,4)];
                  }
                  if(_loc4_ is AvatarItem)
                  {
                     _loc3_ = _loc4_.icon.transform.matrix;
                     if(_loc3_.a != -1)
                     {
                        _loc3_.scale(-1,1);
                        _loc4_.icon.transform.matrix = _loc3_;
                     }
                  }
                  _loc5_.itemLayer.addChild(_loc4_.icon);
               }
               else
               {
                  _loc5_.itemLayer.addChild(_loc4_);
               }
               _spirals[_loc6_] = new LoadingSpiral(_loc5_.itemLayer);
               if(!_loc4_.isIconLoaded)
               {
                  _loc4_.imageLoadedCallback = _spirals[_loc6_].destroy;
               }
               else
               {
                  _spirals[_loc6_].destroy();
               }
               setupPriceTags(_loc5_,_loc4_);
               LocalizationManager.updateToFit(_loc5_.itemNameTxt,_loc4_.name);
               if(_loc4_.isMemberOnly)
               {
                  _loc5_.banner.visible = true;
                  LocalizationManager.translateId(_loc5_.banner.txtCont.txt,11376);
                  if(_isMember)
                  {
                     _loc5_.lockOpen.visible = true;
                  }
                  else
                  {
                     _loc5_.lock.visible = true;
                  }
               }
               else
               {
                  _loc5_.banner.visible = false;
                  _loc5_.lock.visible = false;
                  _loc5_.lockOpen.visible = false;
               }
               if(_loc4_.isOcean)
               {
                  _loc5_.blueBG.visible = true;
                  _loc5_.greenBG.visible = false;
               }
               else
               {
                  _loc5_.greenBG.visible = true;
               }
               _loc5_.avtSpecific.visible = false;
               _loc5_.newTag.visible = _loc4_.isNew;
               _loc5_.clearanceTag.visible = _loc4_.isOnClearance;
               _loc5_.rareTag.visible = _loc4_.isRare;
               _loc5_.saleTag.visible = _loc4_.isOnSale;
               _loc5_.ocean.visible = _loc4_.isOcean;
               setupNumDaysLeft(_loc5_,_loc4_);
               if(_shopWithPreview)
               {
                  _shopWithPreview.checkIfThisItemEquipped(_loc6_,_itemOffset);
               }
               _loc5_.addEventListener("mouseDown",onItemWindowDown,false,0,true);
               _loc5_.addEventListener("rollOver",onItemWindowRollOver,false,0,true);
               _loc5_.addEventListener("rollOut",onItemWindowRollOut,false,0,true);
            }
            else
            {
               _loc5_.tag.visible = false;
               _loc5_.tagTall.visible = false;
               _loc5_.tag.txt.text = "";
               _loc5_.itemNameTxt.text = "";
               _loc5_.itemNameTxtMultiline.text = "";
               _loc5_.banner.visible = false;
               _loc5_.lock.visible = false;
               _loc5_.lockOpen.visible = false;
               _loc5_.blueBG.visible = _shop.frame.currentFrameLabel == "diamond";
               _loc5_.newTag.visible = false;
               _loc5_.clearanceTag.visible = false;
               _loc5_.saleTag.visible = false;
               _loc5_.ocean.visible = false;
               _loc5_.greenBG.visible = false;
               _loc5_.rareTag.visible = false;
               _loc5_.avtSpecific.visible = false;
               _loc5_.daysLeftTag.visible = false;
               if(_loc5_.yellowBG)
               {
                  _loc5_.yellowBG.visible = false;
               }
            }
            _loc5_.itemNameTxt.visible = false;
            _loc5_.itemNameTxtMultiline.visible = false;
            _loc6_++;
         }
      }
      
      private function setupCombinedTag(param1:MovieClip, param2:Object, param3:MovieClip) : void
      {
         var _loc7_:* = undefined;
         var _loc8_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc6_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc9_:int = 0;
         while(param1.tagTall.tag_mid.numChildren > 1)
         {
            param1.tagTall.tag_mid.removeChildAt(param1.tagTall.tag_mid.numChildren - 1);
         }
         var _loc5_:CombinedCurrencyItem = param2.combinedCurrencyItem;
         if(_loc5_)
         {
            _loc7_ = _loc5_.countData;
            _loc9_ = 0;
            while(_loc9_ < _loc7_.length)
            {
               if(_loc7_[_loc9_] != null)
               {
                  _loc4_ = new (_currLoaderAppDomain.getDefinition("mid_tallTag") as Class)();
                  _loc4_.iconCont.gotoAndStop(_loc7_[_loc9_].name);
                  _loc4_.gemCountTxt.text = Utility.convertNumberToString(_loc7_[_loc9_].count);
                  if(UserCurrency.hasEnoughCurrency(param2.currencyType,param2.value,_loc9_))
                  {
                     param1.tagTall.gotoAndStop("green");
                     param1.tagTall.tag_mid.tagWindow.height = _loc4_.height * (_loc8_ + 1);
                     _loc4_.gotoAndStop("green");
                     _loc10_ = true;
                  }
                  else
                  {
                     if(!_loc10_)
                     {
                        param1.tagTall.gotoAndStop("red");
                     }
                     param1.tagTall.tag_mid.tagWindow.height = _loc4_.height * (_loc8_ + 1);
                     _loc4_.gotoAndStop("red");
                     _loc6_ = true;
                  }
                  _loc4_.y = _loc4_.height * _loc8_;
                  param1.tagTall.tag_mid.addChild(_loc4_);
                  _loc8_++;
               }
               _loc9_++;
            }
            param1.tagTall.tag_btm.y = param1.tagTall.tag_mid.y + param1.tagTall.tag_mid.height;
            if(param3 != null)
            {
               param3.visible = !_loc6_;
            }
         }
      }
      
      private function setupNumDaysLeft(param1:MovieClip, param2:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:MovieClip = param1.daysLeftTag;
         if(!param2.isRare)
         {
            _loc3_ = Math.ceil((param2.endTime - Utility.getCurrEpochTime()) / 60 / 60 / 24);
            if(_loc3_ > 0 && _loc3_ <= 10)
            {
               if(_loc3_ == 1)
               {
                  LocalizationManager.translateId(_loc4_.txt,18061);
               }
               else
               {
                  LocalizationManager.translateIdAndInsert(_loc4_.txt,6260,_loc3_);
               }
               _loc4_.visible = true;
               param1.clearanceTag.visible = false;
               param1.rareTag.visible = false;
               param1.saleTag.visible = false;
               param1.newTag.visible = false;
            }
            else
            {
               _loc4_.visible = false;
            }
         }
         else
         {
            _loc4_.visible = false;
         }
      }
      
      private function setupPriceTags(param1:MovieClip, param2:Object, param3:MovieClip = null) : void
      {
         var _loc4_:String = "";
         if(param2.currencyType == 1)
         {
            _loc4_ = "ticket";
         }
         else if(param2.currencyType == 2)
         {
            _loc4_ = "earth";
         }
         else if(param2.currencyType == 3)
         {
            _loc4_ = "diamond";
         }
         if(param2.currencyType == 100)
         {
            setupCombinedTag(param1,param2,param3);
            param1.tagTall.visible = true;
         }
         else
         {
            if(UserCurrency.hasEnoughCurrency(param2.currencyType,param2.value))
            {
               if(param1.tag.currentFrameLabel != _loc4_ + "green")
               {
                  param1.tag.gotoAndPlay(_loc4_ + "green");
               }
               param1.tag.txt.textColor = "0x386630";
               if(param3 != null)
               {
                  param3.visible = true;
               }
            }
            else
            {
               if(param1.tag.currentFrameLabel != _loc4_ + "red")
               {
                  param1.tag.gotoAndPlay(_loc4_ + "red");
               }
               param1.tag.txt.textColor = "0x800000";
               if(param3 != null)
               {
                  param3.visible = false;
               }
            }
            param1.tag.txt.text = Utility.convertNumberToString(param2.value);
            param1.tag.visible = true;
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_shop.buyPopup.visible)
         {
            if(_itemToBuy is DenItem && (_itemToBuy as DenItem).sortId == 4)
            {
               RoomManagerWorld.instance.playPreviousMusic();
            }
            DarkenManager.unDarken(_shop.buyPopup);
         }
         if(_shop.buyBigPopup && _shop.buyBigPopup.visible)
         {
            DarkenManager.unDarken(_shop.buyBigPopup);
         }
         applyAndClose();
         QuestManager.onShopClose();
         TutorialPopups.closeTutorialTextPopup();
      }
      
      protected function buyBtnDownHandler(param1:MouseEvent = null) : void
      {
         var _loc2_:Boolean = false;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_itemToBuy)
         {
            _loc2_ = _itemToBuy.isMemberOnly ? _isMember : true;
            if(_itemToBuy.currencyType == 3 && _loc2_)
            {
               GuiManager.showDiamondConfirmation(_itemToBuy.value,attemptToPurchaseItem);
            }
            else
            {
               attemptToPurchaseItem();
            }
         }
      }
      
      private function attemptToPurchaseItem() : void
      {
         var _loc1_:CombinedCurrencyItem = null;
         var _loc2_:* = undefined;
         var _loc8_:String = null;
         var _loc5_:int = 0;
         var _loc4_:Object = null;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc3_:Iitem = _currShopItemArray.getIitem(_itemIdx).clone();
         if(!_isMember)
         {
            if(_loc3_.isMemberOnly)
            {
               if(_loc3_ is Item)
               {
                  UpsellManager.displayPopup("accessories","buyAccessory/" + _loc3_.name);
                  return;
               }
               if(_loc3_ is DenItem)
               {
                  if(_isDenAudioList)
                  {
                     UpsellManager.displayPopup("denAudio","buyDenAudio/" + _loc3_.name);
                  }
                  else
                  {
                     UpsellManager.displayPopup("denItems","buyDenItem/" + _loc3_.name);
                  }
                  return;
               }
               if(_loc3_ is DenRoomItem)
               {
                  UpsellManager.displayPopup("dens","buyDenRoom/" + _loc3_.name);
                  return;
               }
               trace("ERROR: _shopId=" + _shopId + " is not expected.");
            }
         }
         if(!UserCurrency.hasEnoughCurrency(_loc3_.currencyType,_loc3_.value))
         {
            if(_loc3_.currencyType == 3)
            {
               UpsellManager.displayPopup("","extraDiamonds");
            }
            else
            {
               DarkenManager.darken(_shop["oopsCostPopup" + _appendString]);
               if(_loc3_.currencyType == 100)
               {
                  _loc1_ = _loc3_.value;
                  _shop["oopsCostPopup" + _appendString].gotoAndStop(_loc1_.numCurrenciesInUse);
                  _loc2_ = _loc1_.countData;
                  _loc8_ = "";
                  _loc9_ = 0;
                  while(_loc9_ < _loc2_.length)
                  {
                     _loc4_ = _loc2_[_loc9_];
                     if(_loc4_ != null)
                     {
                        _loc5_ = UserCurrency.getCurrency(_loc4_.type);
                        _shop["oopsCostPopup" + _appendString]["currencyType" + _loc8_].gotoAndStop(_loc4_.name);
                        _shop["oopsCostPopup" + _appendString]["currencyCost" + _loc8_].gotoAndStop(_loc4_.name);
                        _shop["oopsCostPopup" + _appendString]["currencyNeed" + _loc8_].gotoAndStop(_loc4_.name);
                        _shop["oopsCostPopup" + _appendString]["gemsTxt" + _loc8_].text = Utility.convertNumberToString(_loc5_);
                        _shop["oopsCostPopup" + _appendString]["costTxt" + _loc8_].text = Utility.convertNumberToString(_loc4_.count);
                        _shop["oopsCostPopup" + _appendString]["needTxt" + _loc8_].text = Utility.convertNumberToString(Math.max(0,_loc4_.count - _loc5_));
                        _shop["oopsCostPopup" + _appendString]["needCircle" + _loc8_].visible = _loc4_.count - _loc5_ > 0;
                        if(_loc8_ == "")
                        {
                           _loc8_ = "Two";
                        }
                        else if(_loc8_ == "Two")
                        {
                           _loc8_ = "Three";
                        }
                     }
                     _loc9_++;
                  }
                  _shop["oopsCostPopup" + _appendString].visible = true;
                  _shop["oopsCostPopup" + _appendString].earnGemsBtn.visible = false;
               }
               else
               {
                  _shop["oopsCostPopup" + _appendString].currencyCost.gotoAndStop(SbiConstants.CURRENCY_NAMES[_loc3_.currencyType]);
                  _shop["oopsCostPopup" + _appendString].currencyNeed.gotoAndStop(SbiConstants.CURRENCY_NAMES[_loc3_.currencyType]);
                  _shop["oopsCostPopup" + _appendString].currencyType.gotoAndStop(SbiConstants.CURRENCY_NAMES[_loc3_.currencyType]);
                  _shop["oopsCostPopup" + _appendString].gemsTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(_loc3_.currencyType));
                  _shop["oopsCostPopup" + _appendString].costTxt.text = Utility.convertNumberToString(_loc3_.value);
                  _shop["oopsCostPopup" + _appendString].needTxt.text = Utility.convertNumberToString(_loc3_.value - int(_shop["oopsCostPopup" + _appendString].gemsTxt.text));
                  _shop["oopsCostPopup" + _appendString].visible = true;
                  if(_loc3_.currencyType == 0)
                  {
                     if(_appendString == "")
                     {
                        _shop.oopsCostPopup.earnGemsBtn.addEventListener("mouseDown",onEarnGemsBtn,false,0,true);
                     }
                  }
                  else
                  {
                     _shop.oopsCostPopup.earnGemsBtn.visible = false;
                  }
               }
            }
         }
         else if(_loc3_ is Item)
         {
            if(_playerAvatar.inventoryClothing.numItems < maxItems)
            {
               if(_loc3_.defId > 0)
               {
                  sendBuyRequest(_loc3_);
               }
            }
            else
            {
               if(AvatarManager.roomEnviroType == 0)
               {
                  _loc6_ = 6;
               }
               else
               {
                  _loc6_ = 5;
               }
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14746),true,confirmRecycleHandler,_loc6_);
            }
         }
         else if(_loc3_ is DenItem)
         {
            if((_loc3_ as DenItem).sortId == 4)
            {
               if(Utility.numDenItemsInList(_playerAvatar.inventoryDenFull.denItemCollection,-1,true) < maxAudioItems)
               {
                  sendBuyRequest(_loc3_);
               }
               else
               {
                  _loc6_ = 2;
                  _loc7_ = true;
               }
            }
            else if(Utility.numDenItemsInList(_playerAvatar.inventoryDenPartial.denItemCollection,-1) < maxDenItems)
            {
               sendBuyRequest(_loc3_);
            }
            else
            {
               if(AvatarManager.roomEnviroType == 0)
               {
                  _loc6_ = 4;
               }
               else
               {
                  _loc6_ = 3;
               }
               _loc7_ = true;
            }
            if(_loc7_)
            {
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14746),true,confirmRecycleHandler,_loc6_);
            }
         }
         else if(_loc3_ is DenRoomItem)
         {
            if(_denItemIdx < 1)
            {
               _denItemIdx = DenSwitch.nextFreeSlotIdx;
            }
            if(!DenSwitch.denList.getDenRoomItem(_denItemIdx) && _denItemIdx < 32 && _denItemIdx > 0)
            {
               sendBuyRequest(_loc3_);
            }
            else
            {
               _loc6_ = 99;
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14746),true,confirmRecycleHandler,_loc6_);
            }
         }
         else if(_glDefType == 1051)
         {
            sendBuyRequest(_loc3_);
         }
      }
      
      private function sendBuyRequest(param1:Object) : void
      {
         DarkenManager.showLoadingSpiral(true);
         if(_showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,7))
         {
            AchievementXtCommManager.requestSetUserVar(379,7);
            _shop.buyBtnGreen.setButtonState(0);
         }
         var _loc2_:Boolean = param1.currencyType == 3;
         if(param1 is Item)
         {
            ItemXtCommManager.requestItemBuy(confirmPurchase,_shopId,_loc2_ ? param1.diamondItem.defId : param1.defId,_itemColorIdx,_loc2_ ? 1 : 0);
            ItemXtCommManager.setItemBuyIlCallback(putOnPurchasedItem);
         }
         else if(param1 is DenItem)
         {
            DenXtCommManager.requestBuy(true,_shopId,_loc2_ ? param1.diamondItem.defId : param1.defId,confirmPurchase,onDenItemPurchaseInventoryResponse,0,null,(_itemToBuy as DenItem).version,_loc2_ ? 1 : 0);
         }
         else if(param1 is DenRoomItem)
         {
            DenXtCommManager.requestBuy(false,_shopId,_loc2_ ? param1.diamondItem.defId : param1.defId,confirmPurchase,null,_denItemIdx,_denRoomShopCallback != null ? _denRoomShopCallback : onDenPurchase,0,_loc2_ ? 1 : 0);
         }
         else if(_glDefType == 1051)
         {
            ItemXtCommManager.requestCurrencyExchange(_shopId,param1.defId,confirmPurchase);
         }
      }
      
      private function pageCatalogHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == _shop.nextBtn.name && _numItems > 6)
            {
               if(_itemOffset + 6 < _numItems)
               {
                  _itemOffset += 6;
               }
               else
               {
                  _itemOffset = 0;
               }
            }
            else if(param1.currentTarget.name == _shop.prevBtn.name && _numItems > 6)
            {
               if(_itemOffset == 0)
               {
                  _loc2_ = _numItems % 6;
                  if(_loc2_ != 0)
                  {
                     _itemOffset = _numItems - _loc2_;
                  }
                  else
                  {
                     _itemOffset = _numItems - 6;
                  }
               }
               else
               {
                  _itemOffset -= 6;
               }
            }
            setupShopWindows();
         }
      }
      
      private function okBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function confirmFullInventoryHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         onClose(null);
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         var _loc2_:int = int(param1.passback);
         if(param1.status)
         {
            if(_loc2_ == 99)
            {
               if(_denPreviewManager)
               {
                  _denPreviewManager.showBuyAndBackBtns(false);
               }
               GuiManager.showDenSwitcher(true);
               if(GuiManager.currDenSwitcher)
               {
                  GuiManager.currDenSwitcher.rebuildWindows(true,onDenRoomRecycleClose);
               }
               else
               {
                  GuiManager.openDenRoomSwitcher(true,onDenRoomRecycleClose);
               }
            }
            else
            {
               _recyclePopup = new RecycleItems();
               _recyclePopup.init(_loc2_,_popupLayer,true,onRecycleClose,900 * 0.5,550 * 0.5,true);
            }
         }
         else if(_loc2_ != 99)
         {
            onClose(null);
         }
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(_recyclePopup)
         {
            _recyclePopup.destroy();
            _recyclePopup = null;
         }
      }
      
      private function onDenRoomRecycleClose(param1:Boolean = false) : void
      {
         GuiManager.showDenSwitcher(false,_shop ? _popupLayer.getChildIndex(_shop) - 1 : -1);
         if(_denPreviewManager)
         {
            _denPreviewManager.showBuyAndBackBtns(true);
            if(param1)
            {
               _denPreviewManager.exitPreview();
            }
         }
      }
      
      private function onItemNoLongerAvailable(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_itemNotAvailPopup)
         {
            _itemNotAvailPopup.destroy();
            _itemNotAvailPopup = null;
         }
         if(_shopId == 13)
         {
            onBuyBigPopupCloseBtnDown(null);
         }
         else
         {
            onBuyPopupCloseBtnDown(null);
         }
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestGenericList(1,filterItemLists);
      }
      
      public function onDenPurchase() : void
      {
         if(_denPreviewManager)
         {
            _denPreviewManager.handleDenPurchase();
         }
      }
      
      private function confirmPurchase(param1:int, param2:Object, param3:int) : void
      {
         var _loc4_:int = 0;
         if(param1 == 1)
         {
            _bItemsPurchased = true;
            playCurrencyAnimation();
            if(_shopId == 13)
            {
               onBuyBigPopupCloseBtnDown(null);
               if(!_isShopOnlyDen)
               {
                  return;
               }
            }
            else
            {
               onBuyPopupCloseBtnDown(null);
               onBuyBigPopupCloseBtnDown(null);
            }
            UserCurrency.setCurrency(param2,_itemToBuy.currencyType);
            if(_itemToBuy.currencyType == 100)
            {
               _satchelWindow.callUpdateInWindow();
            }
            else if(_shop.myGemCountTxt && (_itemToBuy.currencyType == 0 || _itemToBuy.currencyType == 1))
            {
               _shop.myGemCountTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(_itemToBuy.currencyType));
            }
            else if(_shop.myGemCountTxtDiamond && _itemToBuy.currencyType == 3)
            {
               _shop.myGemCountTxtDiamond.text = Utility.convertNumberToString(UserCurrency.getCurrency(_itemToBuy.currencyType));
            }
            if(_itemToBuy is Item && _playerAvatar.inventoryClothing.numItems >= warningItemCount)
            {
               new SBOkPopup(_popupLayer,getWarningText(_playerAvatar.inventoryClothing.numItems,maxItems));
            }
            else
            {
               if(_itemToBuy is DenItem)
               {
                  return;
               }
               if(_itemToBuy is DenRoomItem)
               {
                  _loc4_ = DenSwitch.numDens;
                  if(_loc4_ + 1 >= warningDenRoomCount)
                  {
                     new SBOkPopup(_popupLayer,getWarningText(_loc4_,32));
                  }
               }
            }
            if(!(_itemToBuy is Item))
            {
               DarkenManager.showLoadingSpiral(false);
            }
            setupShopWindows();
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            if(param1 == -2)
            {
               _itemNotAvailPopup = new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14797),true,onItemNoLongerAvailable);
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14798));
            }
            ItemXtCommManager.setItemBuyIlCallback(null);
         }
      }
      
      private function onDenItemPurchaseInventoryResponse() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(_shop)
         {
            if((_itemToBuy as DenItem).sortId == 4)
            {
               _loc1_ = Utility.numDenItemsInList(_playerAvatar.inventoryDenFull.denItemCollection,-1,true);
               if(_loc1_ >= warningAudioItemCount)
               {
                  new SBOkPopup(_popupLayer,getWarningText(_loc1_,maxAudioItems));
               }
            }
            else
            {
               _loc2_ = Utility.numDenItemsInList(_playerAvatar.inventoryDenPartial.denItemCollection,-1);
               if(_loc2_ >= warningDenItemCount)
               {
                  new SBOkPopup(_popupLayer,getWarningText(_loc2_,maxDenItems));
               }
               if((_itemToBuy as DenItem).sortId == 2 || (_itemToBuy as DenItem).sortId == 3)
               {
                  if(gMainFrame.userInfo.userVarCache.getUserVarValueById(420) <= 0)
                  {
                     AchievementXtCommManager.requestSetUserVar(420,1);
                     GuiManager.resetPetWindowListAndUpdateBtns();
                  }
               }
               GuiManager.updateSwitchRecycleBtnVisibility();
            }
            if(_shopId == 13)
            {
               if(!_isShopOnlyDen)
               {
                  return;
               }
            }
            setupShopWindows();
         }
      }
      
      private function getWarningText(param1:int, param2:int) : String
      {
         var _loc3_:int = param2 - (param1 + 1);
         var _loc4_:String = "";
         if(_loc3_ > 1)
         {
            _loc4_ = LocalizationManager.translateIdAndInsertOnly(11378,_loc3_);
         }
         else if(_loc3_ == 1)
         {
            _loc4_ = LocalizationManager.translateIdAndInsertOnly(11379,_loc3_);
         }
         else
         {
            _loc4_ = LocalizationManager.translateIdOnly(11381);
         }
         return _loc4_;
      }
      
      private function putOnPurchasedItem() : void
      {
         var _loc3_:IntItemCollection = null;
         var _loc1_:IntItemCollection = null;
         var _loc6_:int = _currShopItemArray.getIitem(_itemIdx).layerId;
         var _loc2_:AccItemCollection = _playerAvatar.inventoryClothing.itemCollection;
         var _loc7_:int = _loc2_.getAccItem(0).invIdx;
         var _loc4_:int = -1;
         for each(var _loc5_:Item in _loc2_.getCoreArray())
         {
            if(_loc5_.getInUse(_playerAvatar.perUserAvId) && _loc5_.layerId == _loc6_ && _loc5_.invIdx != _loc7_)
            {
               _loc4_ = _loc5_.invIdx;
               break;
            }
         }
         if(_currShopItemArray.getIitem(_itemIdx).enviroType == AvatarManager.roomEnviroType)
         {
            _loc3_ = new IntItemCollection();
            _loc3_.pushIntItem(_loc7_);
            _loc1_ = new IntItemCollection();
            if(_loc4_ != -1)
            {
               _loc1_.pushIntItem(_loc4_);
            }
            ItemXtCommManager.requestItemUse(onItemUseResponse,_loc3_,_loc1_);
            ItemXtCommManager.setItemBuyIlCallback(null);
         }
         if(_onPurchaseSuccessCallback != null)
         {
            _onPurchaseSuccessCallback();
         }
      }
      
      private function onItemUseResponse(param1:IntItemCollection, param2:IntItemCollection, param3:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_shopWithPreview)
         {
            _shopWithPreview.purchaseComplete();
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
            if(param1.currentTarget.name == _shop.iw0.name)
            {
               _loc3_ = 0;
            }
            else if(param1.currentTarget.name == _shop.iw1.name)
            {
               _loc3_ = 1;
            }
            else if(param1.currentTarget.name == _shop.iw2.name)
            {
               _loc3_ = 2;
            }
            else if(param1.currentTarget.name == _shop.iw3.name)
            {
               _loc3_ = 3;
            }
            else if(param1.currentTarget.name == _shop.iw4.name)
            {
               _loc3_ = 4;
            }
            else if(param1.currentTarget.name == _shop.iw5.name)
            {
               _loc3_ = 5;
            }
            _itemIdx = _loc3_ + _itemOffset;
         }
         else
         {
            _itemIdx = _useStartupShopIndex;
         }
         var _loc2_:Iitem = _currShopItemArray.getIitem(_itemIdx);
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_ is Item && _itemColorsArray && _itemColorsArray[_loc2_.defId].length > 1)
         {
            (_loc2_ as Item).color = _itemColorsArray[_loc2_.defId][_itemColorIdx];
            _shop.colorCycleBtn.visible = !_isInFFM;
            _shop.colorCycleFlash.visible = !_isInFFM;
         }
         else if(_loc2_ is DenItem)
         {
            if((_loc2_ as DenItem).getVersions() && (_loc2_ as DenItem).getVersions().length > 0)
            {
               _denItemColorsArray = (_loc2_ as DenItem).getVersions();
               (_loc2_ as DenItem).setVersion(_denItemColorsArray[_itemColorIdx]);
               _shop.colorCycleBtn.visible = !_isInFFM;
               _shop.colorCycleFlash.visible = !_isInFFM;
            }
            else
            {
               _denItemColorsArray = null;
               _shop.colorCycleFlash.visible = false;
               _shop.colorCycleBtn.visible = false;
            }
         }
         else
         {
            _shop.colorCycleFlash.visible = false;
            _shop.colorCycleBtn.visible = false;
         }
         if(_shopId == 13 || _loc2_ is DenRoomItem)
         {
            _shop.buyPopup.visible = false;
            setupBigBuyPopup();
         }
         else
         {
            if(_shop.buyBigPopup)
            {
               _shop.buyBigPopup.visible = false;
            }
            if(_shopWithPreview)
            {
               _shopWithPreview.handleItemEquip(_loc2_,_loc3_);
            }
            else
            {
               setupBuyPopup();
            }
         }
      }
      
      private function onItemWindowRollOver(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _shop.iw0.name)
         {
            _loc2_ = 0;
         }
         else if(param1.currentTarget.name == _shop.iw1.name)
         {
            _loc2_ = 1;
         }
         else if(param1.currentTarget.name == _shop.iw2.name)
         {
            _loc2_ = 2;
         }
         else if(param1.currentTarget.name == _shop.iw3.name)
         {
            _loc2_ = 3;
         }
         else if(param1.currentTarget.name == _shop.iw4.name)
         {
            _loc2_ = 4;
         }
         else if(param1.currentTarget.name == _shop.iw5.name)
         {
            _loc2_ = 5;
         }
         if(_shop["iw" + _loc2_].currentFrameLabel != "mouse")
         {
            _shop["iw" + _loc2_].gotoAndPlay("mouse");
         }
         if(_shop["iw" + _loc2_].itemNameTxt.text == _shop["iw" + _loc2_].itemNameTxtMultiline.text)
         {
            _shop["iw" + _loc2_].mouse0.gotoAndStop("multi");
            _shop["iw" + _loc2_].itemNameTxtMultiline.visible = true;
         }
         else
         {
            _shop["iw" + _loc2_].mouse0.gotoAndStop("single");
            _shop["iw" + _loc2_].itemNameTxt.visible = true;
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowRollOut(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _shop.iw0.name)
         {
            _loc2_ = 0;
         }
         else if(param1.currentTarget.name == _shop.iw1.name)
         {
            _loc2_ = 1;
         }
         else if(param1.currentTarget.name == _shop.iw2.name)
         {
            _loc2_ = 2;
         }
         else if(param1.currentTarget.name == _shop.iw3.name)
         {
            _loc2_ = 3;
         }
         else if(param1.currentTarget.name == _shop.iw4.name)
         {
            _loc2_ = 4;
         }
         else if(param1.currentTarget.name == _shop.iw5.name)
         {
            _loc2_ = 5;
         }
         if(_shop["iw" + _loc2_].currentFrameLabel != "out")
         {
            _shop["iw" + _loc2_].gotoAndPlay("out");
         }
         if(_shop["iw" + _loc2_].itemNameTxt.text == _shop["iw" + _loc2_].itemNameTxtMultiline.text)
         {
            _shop["iw" + _loc2_].itemNameTxtMultiline.visible = false;
         }
         else
         {
            _shop["iw" + _loc2_].itemNameTxt.visible = false;
         }
      }
      
      protected function setupBuyPopup() : void
      {
         _itemToBuy = _currShopItemArray.getIitem(_itemIdx).clone();
         if(_itemToBuy is PetItem)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId((_itemToBuy.icon as GuiPet).idx),OnPetFinderClose,false,null,_itemToBuy,(_itemToBuy as PetItem).currencyType,_shopId);
            return;
         }
         if(_itemToBuy is AvatarItem)
         {
            AvatarSwitch.addAvatar(AvatarSwitch.avatars.length,false,onAvatarAdded,false,_itemToBuy.isOcean,false,(_itemToBuy.icon as AvatarView).avTypeId,true,_shopId,_itemToBuy.defId,_itemToBuy);
            return;
         }
         if(_shopWithPreview == null)
         {
            _itemColorIdx = 0;
         }
         if(_itemToBuy.isMemberOnly)
         {
            _shop.buyPopup.banner.visible = true;
            LocalizationManager.translateId(_shop.buyPopup.banner.txtCont.txt,11376);
            if(_isMember)
            {
               _shop.buyPopup.lockOpen.visible = true;
               _shop.buyPopup.lock.visible = false;
            }
            else
            {
               _shop.buyPopup.lock.visible = true;
               _shop.buyPopup.lockOpen.visible = false;
            }
         }
         else
         {
            _shop.buyPopup.banner.visible = false;
            _shop.buyPopup.lockOpen.visible = false;
            _shop.buyPopup.lock.visible = false;
         }
         if(_itemToBuy.isOcean)
         {
            _shop.buyPopup.buyGreenBG.visible = false;
         }
         else
         {
            _shop.buyPopup.buyGreenBG.visible = true;
         }
         _shop.buyPopup.avtSpecificIcon.visible = false;
         _shop.buyPopup.newTag.visible = _itemToBuy.isNew;
         _shop.buyPopup.clearanceTag.visible = _itemToBuy.isOnClearance;
         setupNumDaysLeft(_shop.buyPopup,_itemToBuy);
         _shop.buyPopup.saleTag.visible = _itemToBuy.isOnSale;
         _shop.buyPopup.rareTag.visible = _itemToBuy.isRare;
         _shop.buyPopup.rareTag.gotoAndStop(_shop.colorCycleBtn.visible ? "color" : "noColor");
         if(_shop.buyPopup.itemLayer.numChildren > 1)
         {
            _shop.buyPopup.itemLayer.removeChildAt(1);
         }
         onColorBtnDown(null);
         if(!(_itemToBuy is DenItem))
         {
            _itemToBuy.largeIcon.filters = [new GlowFilter(5586479,1,2,2,8)];
         }
         _shop.buyPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         setupPriceTags(_shop.buyPopup,_itemToBuy,_shop.buyBtnGreen);
         LocalizationManager.updateToFit(_shop.buyPopupItemNameTxt,_itemToBuy.name);
         if(_shop.buyPopupItemNameTxt.text == _shop.buyPopupItemNameTxtMultiline.text)
         {
            _shop.buyPopup["bg" + _appendString].gotoAndStop("multi");
         }
         else
         {
            _shop.buyPopup["bg" + _appendString].gotoAndStop("single");
         }
         if(_shopWithPreview == null)
         {
            DarkenManager.darken(_shop.buyPopup);
         }
         _shop.buyPopup.visible = true;
         AJAudio.playSubMenuBtnClick();
         if(_itemToBuy is DenItem && (_itemToBuy as DenItem).sortId == 4)
         {
            RoomManagerWorld.instance.playMusic((_itemToBuy as DenItem).strmName + ".mp3",(_itemToBuy as DenItem).version2 / 100);
         }
         else if(_itemToBuy.isOcean && _itemToBuy is DenItem && !DenSwitch.haveOceanDen())
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14799));
         }
         if(_showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,6))
         {
            AchievementXtCommManager.requestSetUserVar(379,6);
         }
         if(_showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,7))
         {
            TutorialPopups.openTutorialTextPopup(18660,10,115);
            _shop.buyBtnGreen.gotoAndStop("new");
            _shop.buyBtnGreen.setButtonState(2);
         }
         else
         {
            _shop.buyBtnGreen.setButtonState(1);
         }
      }
      
      private function setupBigBuyPopup() : void
      {
         _itemToBuy = _currShopItemArray.getIitem(_itemIdx).clone();
         _itemColorIdx = 0;
         if(_itemToBuy.isMemberOnly)
         {
            _shop.buyBigPopup.banner.visible = true;
            LocalizationManager.translateId(_shop.buyBigPopup.banner.txtCont.txt,11376);
            if(_isMember)
            {
               _shop.buyBigPopup.lockOpen.visible = true;
               _shop.buyBigPopup.lock.visible = false;
            }
            else
            {
               _shop.buyBigPopup.lock.visible = true;
               _shop.buyBigPopup.lockOpen.visible = false;
            }
         }
         else
         {
            _shop.buyBigPopup.lockOpen.visible = false;
            _shop.buyBigPopup.lock.visible = false;
            _shop.buyBigPopup.banner.visible = false;
         }
         if(_itemToBuy.isOcean)
         {
            _shop.buyBigPopup.buyGreenBG.visible = false;
         }
         else
         {
            _shop.buyBigPopup.buyGreenBG.visible = true;
         }
         _shop.buyBigPopup.avtSpecificIcon.visible = false;
         _shop.buyBigPopup.newTag.visible = _itemToBuy.isNew;
         _shop.buyBigPopup.clearanceTag.visible = _itemToBuy.isOnClearance;
         setupNumDaysLeft(_shop.buyBigPopup,_itemToBuy);
         _shop.buyBigPopup.saleTag.visible = _itemToBuy.isOnSale;
         _shop.buyBigPopup.rareTag.visible = _itemToBuy.isRare;
         if(_shop.buyBigPopup.itemLayer.numChildren > 1)
         {
            _shop.buyBigPopup.itemLayer.removeChildAt(1);
         }
         if(!(_itemToBuy is DenItem))
         {
            _itemToBuy.largeIcon.filters = [new GlowFilter(5586479,1,2,2,8)];
         }
         _shop.buyBigPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         _shop.buyBigPopup.tag.txt.text = Utility.convertNumberToString(_itemToBuy.value);
         setupPriceTags(_shop.buyBigPopup,_itemToBuy,_shop.buyBigBtnGreen);
         LocalizationManager.updateToFit(_shop.buyBigPopupItemNameTxt,_itemToBuy.name);
         if(_shop.buyBigPopupItemNameTxt.text == _shop.buyBigPopupItemNameTxtMultiline.text)
         {
            _shop.buyBigPopup["bg" + _appendString].gotoAndStop("multi");
         }
         else
         {
            _shop.buyBigPopup["bg" + _appendString].gotoAndStop("single");
         }
         DarkenManager.darken(_shop.buyBigPopup);
         _shop.buyBigPopup.visible = true;
         AJAudio.playSubMenuBtnClick();
      }
      
      private function OnPetFinderClose(param1:Boolean) : void
      {
         if(param1)
         {
            playCurrencyAnimation();
         }
         if(_shop)
         {
            _shop["myGemCountTxt" + _appendString].text = Utility.convertNumberToString(UserCurrency.getCurrency(_itemToBuy.currencyType));
            setupShopWindows();
         }
      }
      
      private function onAvatarAdded(param1:int) : void
      {
         if(param1 == 1)
         {
            OnPetFinderClose(true);
            return;
         }
         if(param1 == -1)
         {
            LocalizationManager.translateIdAndInsert(_shop.oopsPopup.body_txt,11382,_itemToBuy.name.toLowerCase());
         }
         else
         {
            LocalizationManager.translateId(_shop.oopsPopup.body_txt,11225);
         }
         _shop.oopsPopup.visible = true;
      }
      
      private function onColorBtnDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_itemToBuy is Item && _itemColorsArray)
         {
            if(param1)
            {
               if(_itemColorsArray[_itemToBuy.defId][_itemColorIdx + 1] != null)
               {
                  _itemColorIdx = _itemColorIdx + 1;
               }
               else
               {
                  if(_itemColorIdx == 0)
                  {
                     _shop.colorCycleBtn.removeEventListener("mouseDown",onColorBtnDown);
                     _shop.colorCycleBtn.visible = false;
                     return;
                  }
                  _itemColorIdx = 0;
               }
            }
            if(_shop.buyPopup.itemLayer.numChildren > 1)
            {
               _shop.buyPopup.itemLayer.removeChildAt(1);
            }
            (_itemToBuy as Item).color = _itemColorsArray[_itemToBuy.defId][_itemColorIdx];
            _itemToBuy.largeIcon.filters = [new GlowFilter(5586479,1,2,2,8)];
            _shop.buyPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         }
         else if(_itemToBuy is DenItem && _denItemColorsArray)
         {
            if(param1)
            {
               if(_denItemColorsArray[_itemColorIdx + 1] != null)
               {
                  _itemColorIdx = _itemColorIdx + 1;
               }
               else if(_itemColorIdx != 0)
               {
                  _itemColorIdx = 0;
               }
            }
            if(_shop.buyPopup.itemLayer.numChildren > 1)
            {
               _shop.buyPopup.itemLayer.removeChildAt(1);
            }
            (_itemToBuy as DenItem).setVersion(_denItemColorsArray[_itemColorIdx]);
            _shop.buyPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         }
         if(_shopWithPreview)
         {
            _shopWithPreview.adjustColor();
         }
      }
      
      protected function onBuyPopupCloseBtnDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.unDarken(_shop.buyPopup);
         _shop.buyPopup.visible = false;
         if(_shop.buyPopup.itemLayer.numChildren > 1)
         {
            _shop.buyPopup.itemLayer.removeChildAt(1);
         }
         if(_itemToBuy is DenItem && (_itemToBuy as DenItem).sortId == 4)
         {
            RoomManagerWorld.instance.playPreviousMusic();
         }
         TutorialPopups.closeTutorialTextPopup();
         if(_shopWithPreview)
         {
            _shopWithPreview.adjustColor();
         }
         else
         {
            _itemColorIdx = 0;
         }
      }
      
      private function onDiamondShopInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openDiamondShopInfo();
      }
      
      private function onInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_isInfoOpen)
         {
            new GTween(param1.currentTarget.parent,0.5,{"x":param1.currentTarget.parent.x - 185},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            _isInfoOpen = false;
            AJAudio.playBuddyCardClose();
         }
         else
         {
            new GTween(param1.currentTarget.parent,0.5,{"x":param1.currentTarget.parent.x + 185},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            _isInfoOpen = true;
            AJAudio.playBuddyCardOpen();
         }
         _infoTweenFinished = false;
      }
      
      private function sideMenuComplete(param1:GTween) : void
      {
         _infoTweenFinished = true;
      }
      
      private function onBuyBigPopupCloseBtnDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_shop.buyBigPopup)
         {
            DarkenManager.unDarken(_shop.buyBigPopup);
            _shop.buyBigPopup.visible = false;
            if(_shop.buyBigPopup.itemLayer.numChildren > 1)
            {
               _shop.buyBigPopup.itemLayer.removeChildAt(1);
            }
         }
         _itemColorIdx = 0;
         _denItemIdx = 0;
      }
      
      private function onBuyBigPopupPreviewBtnDown(param1:MouseEvent) : void
      {
         var _loc5_:Object = null;
         param1.stopPropagation();
         var _loc3_:Iitem = _currShopItemArray.getIitem(_itemIdx);
         var _loc2_:int = _loc3_.defId;
         if(_loc3_.currencyType == 3)
         {
            _loc5_ = DiamondXtCommManager.getDiamondDef(_loc3_.diamondItem.defId);
            if(_loc5_)
            {
               _loc2_ = int(_loc5_.refDefId);
            }
         }
         var _loc6_:Object = gMainFrame.userInfo.denRoomDefs[_loc2_];
         var _loc4_:Object = _loc6_ != null ? RoomXtCommManager.getRoomDef(_loc6_.roomDefId) : null;
         if(_loc4_)
         {
            if(Utility.isSameEnviroType(AvatarManager.playerAvatar.enviroTypeFlag,_loc3_.enviroType))
            {
               DarkenManager.unDarken(_shop.buyBigPopup);
               _denPreviewManager = new DenPreviewManager();
               _denPreviewManager.setCurrentShop(this);
               RoomManagerWorld.instance.loadPreviewRoom(_loc4_.pathName,_loc3_.enviroType,_denPreviewManager);
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(Utility.isOcean(AvatarManager.playerAvatar.enviroTypeFlag) ? 18905 : 18903));
            }
         }
      }
      
      private function onOopsPopupCloseBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_shop.oopsPopup);
         _shop.oopsPopup.visible = false;
      }
      
      private function onCostPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_shop["oopsCostPopup" + _appendString]);
         _shop["oopsCostPopup" + _appendString].visible = false;
         if(_appendString == "")
         {
            _shop.oopsCostPopup.earnGemsBtn.removeEventListener("mouseDown",onEarnGemsBtn);
         }
      }
      
      private function onEarnGemsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onCostPopupClose(param1);
         onClose(param1);
         GuiManager.openJoinGamesPopup();
      }
      
      private function playCurrencyAnimation() : void
      {
         var _loc1_:Boolean = _itemToBuy.currencyType == 3;
         if(_shop)
         {
            if(_glDefType == 1060 && _loc1_)
            {
               if(_shop.diamondAnim)
               {
                  _shop.diamondAnim.gotoAndStop("diamonds");
                  _shop.diamondAnim.visible = true;
                  _shop.diamondAnim.diamonds.gotoAndPlay(1);
               }
            }
            else if(_shop.gemAnim)
            {
               _shop.gemAnim.gotoAndStop(_loc1_ ? "diamonds" : "gems");
               _shop.gemAnim.visible = true;
               _shop.gemAnim[_loc1_ ? "diamonds" : "gems"].gotoAndPlay(1);
            }
         }
         AJAudio.playShopCachingSound();
      }
      
      private function onSortBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:String = _shopWithPreview ? "" : _appendString;
         _shop["sortingPopup" + _loc2_].visible = !_shop["sortingPopup" + _loc2_].visible;
         if(_shop["sortingPopup" + _loc2_].visible)
         {
            onSortBtnOut(param1);
         }
      }
      
      private function onSortBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_shop["sortingPopup" + (_shopWithPreview ? "" : _appendString)].visible)
         {
            return;
         }
         GuiManager.toolTip.init(param1.currentTarget as MovieClip,LocalizationManager.translateIdOnly(24502),0,30,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onSortBtnOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onSortingBtns(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc3_:Iitem = null;
         param1.stopPropagation();
         if(_shopWithPreview)
         {
            _loc3_ = _currShopItemArray.getIitem(_itemIdx);
            if(_loc3_)
            {
               _shopWithPreview.handleItemEquip(_loc3_,0,true);
            }
         }
         onBuyPopupCloseBtnDown(null);
         if(param1.currentTarget.name == "timeBtn")
         {
            if(_currShopItemArray == _shopItemArray)
            {
               _currShopItemArray = _shopItemArrayReversed;
               _loc4_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Dn");
            }
            else
            {
               _currShopItemArray = _shopItemArray;
               _loc4_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Up");
            }
         }
         else if(param1.currentTarget.name == "gemBtn")
         {
            if(_currShopItemArray == _shopItemArrayGemLow)
            {
               _currShopItemArray = _shopItemArrayGemHigh;
               _loc4_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"gemIcon",param1.currentTarget.name + "Up");
            }
            else
            {
               _currShopItemArray = _shopItemArrayGemLow;
               _loc4_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"gemIcon",param1.currentTarget.name + "Dn");
            }
         }
         else if(param1.currentTarget.name == "abcBtn")
         {
            if(_currShopItemArray == _shopItemArrayNameHigh)
            {
               _currShopItemArray = _shopItemArrayNameLow;
               _loc4_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"abc",param1.currentTarget.name + "Dn");
            }
            else
            {
               _currShopItemArray = _shopItemArrayNameHigh;
               _loc4_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"abc",param1.currentTarget.name + "Up");
            }
         }
         var _loc2_:String = _shopWithPreview ? "" : _appendString;
         _shop["sortBtn" + _loc2_].gotoAndStop(param1.currentTarget.name + _loc4_);
         _shop["sortingPopup" + _loc2_].visible = false;
         _itemOffset = 0;
         setupShopWindows();
      }
      
      protected function addListeners() : void
      {
         _shop.frame.bx.addEventListener("mouseDown",onClose,false,0,true);
         _shop.nextBtn.addEventListener("mouseDown",pageCatalogHandler,false,0,true);
         _shop.prevBtn.addEventListener("mouseDown",pageCatalogHandler,false,0,true);
         _shop.buyBtnGreen.addEventListener("mouseDown",buyBtnDownHandler,false,0,true);
         _shop.buyBtnRed.addEventListener("mouseDown",buyBtnDownHandler,false,0,true);
         _shop.buyPopup.closeBtn.addEventListener("mouseDown",onBuyPopupCloseBtnDown,false,0,true);
         _shop.colorCycleBtn.addEventListener("mouseDown",onColorBtnDown,false,0,true);
         if(_shop.buyBigPopup)
         {
            _shop.buyBigBtnGreen.addEventListener("mouseDown",buyBtnDownHandler,false,0,true);
            _shop.buyBigBtnRed.addEventListener("mouseDown",buyBtnDownHandler,false,0,true);
            _shop.buyBigPopup.closeBtn.addEventListener("mouseDown",onBuyBigPopupCloseBtnDown,false,0,true);
            _shop.buyBigPopupPreviewBtn.addEventListener("mouseDown",onBuyBigPopupPreviewBtnDown,false,0,true);
         }
         _shop.oopsPopup.closeBtn.addEventListener("mouseDown",onOopsPopupCloseBtnDown,false,0,true);
         _shop["oopsCostPopup" + _appendString].bx.addEventListener("mouseDown",onCostPopupClose,false,0,true);
         var _loc1_:String = _shopWithPreview == null ? _appendString : "";
         if(!_isCombinedCurrencyStore)
         {
            _shop["sortBtn" + _loc1_].addEventListener("mouseDown",onSortBtn,false,0,true);
            _shop["sortBtn" + _loc1_].addEventListener("mouseOver",onSortBtnOver,false,0,true);
            _shop["sortBtn" + _loc1_].addEventListener("mouseOut",onSortBtnOut,false,0,true);
            _shop["sortingPopup" + _loc1_].timeBtn.addEventListener("mouseDown",onSortingBtns,false,0,true);
            _shop["sortingPopup" + _loc1_].gemBtn.addEventListener("mouseDown",onSortingBtns,false,0,true);
            _shop["sortingPopup" + _loc1_].abcBtn.addEventListener("mouseDown",onSortingBtns,false,0,true);
         }
         if(_shop.infoBtn)
         {
            _shop.infoBtn.addEventListener("mouseDown",onDiamondShopInfoBtn,false,0,true);
         }
      }
      
      protected function removeListeners() : void
      {
         var _loc2_:int = 0;
         _shop.frame.bx.removeEventListener("mouseDown",onClose);
         _shop.nextBtn.removeEventListener("mouseDown",pageCatalogHandler);
         _shop.prevBtn.removeEventListener("mouseDown",pageCatalogHandler);
         _loc2_ = 0;
         while(_loc2_ < 6)
         {
            _shop["iw" + _loc2_].removeEventListener("mouseDown",onItemWindowDown);
            _shop["iw" + _loc2_].removeEventListener("rollOver",onItemWindowRollOver);
            _shop["iw" + _loc2_].removeEventListener("rollOut",onItemWindowRollOut);
            _loc2_++;
         }
         _shop.buyBtnGreen.removeEventListener("mouseDown",buyBtnDownHandler);
         _shop.buyBtnRed.removeEventListener("mouseDown",buyBtnDownHandler);
         if(_shop.buyBtnGreenPreview)
         {
            _shop.buyBtnGreenPreview.removeEventListener("mouseDown",buyBtnDownHandler);
            _shop.buyBtnRedPreview.removeEventListener("mouseDown",buyBtnDownHandler);
         }
         _shop.buyPopup.closeBtn.removeEventListener("mouseDown",onBuyPopupCloseBtnDown);
         _shop.colorCycleBtn.removeEventListener("mouseDown",onColorBtnDown);
         if(_shop.buyBigPopup)
         {
            _shop.buyBigBtnGreen.removeEventListener("mouseDown",buyBtnDownHandler);
            _shop.buyBigBtnRed.removeEventListener("mouseDown",buyBtnDownHandler);
            _shop.buyBigPopup.closeBtn.removeEventListener("mouseDown",onBuyBigPopupCloseBtnDown);
            _shop.buyBigPopupPreviewBtn.removeEventListener("mouseDown",onBuyBigPopupPreviewBtnDown);
         }
         _shop.oopsPopup.closeBtn.removeEventListener("mouseDown",onOopsPopupCloseBtnDown);
         var _loc1_:String = _shopWithPreview == null ? _appendString : "";
         _shop["oopsCostPopup" + _loc1_].bx.removeEventListener("mouseDown",onCostPopupClose);
         if(!_isCombinedCurrencyStore)
         {
            _shop["sortBtn" + _loc1_].removeEventListener("mouseDown",onSortBtn);
            _shop["sortBtn" + _loc1_].removeEventListener("mouseOver",onSortBtnOver);
            _shop["sortBtn" + _loc1_].removeEventListener("mouseOut",onSortBtnOut);
            _shop["sortingPopup" + _loc1_].timeBtn.removeEventListener("mouseDown",onSortingBtns);
            _shop["sortingPopup" + _loc1_].gemBtn.removeEventListener("mouseDown",onSortingBtns);
            _shop["sortingPopup" + _loc1_].abcBtn.removeEventListener("mouseDown",onSortingBtns);
         }
         if(_shop.infoBtn)
         {
            _shop.infoBtn.removeEventListener("mouseDown",onDiamondShopInfoBtn);
         }
      }
   }
}

