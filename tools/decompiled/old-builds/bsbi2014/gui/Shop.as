package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarView;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.*;
   import den.DenItem;
   import den.DenRoomItem;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import gskinner.motion.GTween;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   
   public class Shop
   {
      
      private static const EXTENDED_ITEM_COUNT_BIT_INDEX:int = 1;
      
      private static const NUM_EXTRA_SLOTS_DEN:int = 200;
      
      private static const NUM_EXTRA_SLOTS_ACC:int = 100;
      
      private static const NUM_ACC_SLOTS:int = 100;
      
      private static const NUM_DEN_SLOTS:int = 200;
      
      private static const NUM_AUDIO_SLOTS:int = 16;
      
      private static const WARNING_ITEM_COUNT:int = 95;
      
      private static const WARNING_DEN_ITEM_COUNT:int = 195;
      
      private static const WARNING_DEN_AUDIO_COUNT:int = 13;
      
      private static const WARNING_DEN_ROOM_COUNT_OFFSET:int = 3;
      
      public static const DEN_EDIT_TUTORIAL_SHOP_BUY:int = 7;
      
      public static const DEN_EDIT_TUTORIAL_COMPLETE:int = 8;
      
      private const DEN_EDIT_TUTORIAL_SHOP_PREVIEW:int = 6;
      
      private const ITEMS_PER_SCREEN:int = 6;
      
      private const GLOW_FILTER_COLOR:uint = 5586479;
      
      private const GLOW_FILTER_ALPHA:Number = 1;
      
      private var _shopPopup:SBPopup;
      
      private var _closeCallback:Function;
      
      private var _denRoomShopCallback:Function;
      
      private var _onPurchaseSuccessCallback:Function;
      
      private var _shopId:int;
      
      private var _glDefType:int;
      
      private var _playerAvatar:Avatar;
      
      private var _shop:MovieClip;
      
      private var _makePopup:Boolean;
      
      private var _popupLayer:DisplayLayer;
      
      private var _unfilteredItemArray:Array;
      
      private var _unfilteredColorsArray:Array;
      
      private var _shopItemArray:Array;
      
      private var _itemColorsArray:Array;
      
      private var _denItemColorsArray:Array;
      
      private var _numItems:int;
      
      private var _itemToBuy:Object;
      
      private var _myCurrencyCount:int;
      
      private var _bItemsPurchased:Boolean;
      
      private var _isMember:Boolean;
      
      private var _itemIdx:int;
      
      private var _itemColorIdx:int;
      
      private var _itemOffset:int;
      
      private var _denItemIdx:int;
      
      private var _useStartupShopIndex:int;
      
      private var _spirals:Array;
      
      private var _pageURI:String;
      
      private var _lastPage:int;
      
      private var _isDenAudioList:Boolean;
      
      private var _isShopOnlyDen:Boolean;
      
      private var _itemNotAvailPopup:SBOkPopup;
      
      private var _infoTweenFinished:Boolean;
      
      private var _isInfoOpen:Boolean;
      
      private var _petFinder:PetFinder;
      
      private var _appendString:String;
      
      private var _isDiamondStore:Boolean;
      
      private var _isInFFM:Boolean;
      
      private var _recyclePopup:RecycleItems;
      
      private var _timeSeconds:uint;
      
      private var _showTutorial:Boolean;
      
      public function Shop()
      {
         super();
      }
      
      public static function get maxItems() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << EXTENDED_ITEM_COUNT_BIT_INDEX) != 0)
         {
            return NUM_ACC_SLOTS + NUM_EXTRA_SLOTS_ACC;
         }
         return NUM_ACC_SLOTS;
      }
      
      public static function get maxDenItems() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << EXTENDED_ITEM_COUNT_BIT_INDEX) != 0)
         {
            return NUM_DEN_SLOTS + NUM_EXTRA_SLOTS_DEN;
         }
         return NUM_DEN_SLOTS;
      }
      
      public static function get maxAudioItems() : int
      {
         return NUM_AUDIO_SLOTS;
      }
      
      public static function get warningItemCount() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << EXTENDED_ITEM_COUNT_BIT_INDEX) != 0)
         {
            return WARNING_ITEM_COUNT + NUM_EXTRA_SLOTS_ACC;
         }
         return WARNING_ITEM_COUNT;
      }
      
      public static function get warningDenItemCount() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << EXTENDED_ITEM_COUNT_BIT_INDEX) != 0)
         {
            return WARNING_DEN_ITEM_COUNT + NUM_EXTRA_SLOTS_DEN;
         }
         return WARNING_DEN_ITEM_COUNT;
      }
      
      public static function get warningAudioItemCount() : int
      {
         return WARNING_DEN_AUDIO_COUNT;
      }
      
      public static function get warningDenRoomCount() : int
      {
         return SwitchManager.NUM_DEN_ROOM_SLOTS - WARNING_DEN_ROOM_COUNT_OFFSET;
      }
      
      public function init(init_shopId:int, init_glDefType:int, playerAvatar:Avatar, guiLayer:DisplayLayer, initMakePopup:Boolean = true, init_closeCallback:Function = null, initPopupX:int = 450, initPopupY:int = 275, initDenitemIdx:int = 0, initDenRoomShopCallback:Function = null, initIsShopOnlyDen:Boolean = false, initItemIndex:int = -1) : SBPopup
      {
         var timeOffset:uint = 0;
         SBTracker.push();
         this._shopId = init_shopId;
         this._glDefType = init_glDefType;
         this._playerAvatar = playerAvatar;
         this._popupLayer = guiLayer;
         this._appendString = "";
         this._shop = GETDEFINITIONBYNAME("ShopContent");
         this._isMember = gMainFrame.userInfo.isMember;
         this._denRoomShopCallback = initDenRoomShopCallback;
         this._isShopOnlyDen = initIsShopOnlyDen;
         this._isInFFM = GuiManager.isInFFM;
         this._useStartupShopIndex = initItemIndex;
         this._showTutorial = this._shopId == GenericListXtCommManager.DEN_ITEM_FIRST_TIME_SHOP_ID;
         if(this._showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_SHOP_PREVIEW))
         {
            GuiManager.openTutorialTextPopup(LocalizationManager.translateIdOnly(18659),10,115);
         }
         this._denItemIdx = initDenitemIdx;
         this._spirals = new Array();
         for(var i:int = 0; i < this.ITEMS_PER_SCREEN; i++)
         {
            this._shop["iw" + i].lock.visible = false;
            this._shop["iw" + i].lockOpen.visible = false;
            this._shop["iw" + i].blueBG.visible = false;
            if(Boolean(this._spirals[i]))
            {
               this._spirals[i].destroy();
            }
         }
         this._makePopup = initMakePopup;
         var shopSkin:MovieClip = GETDEFINITIONBYNAME("ShopSkin");
         if(this._makePopup)
         {
            this._shopPopup = new SBPopup(this._popupLayer,shopSkin,this._shop,true,true,false,false,true);
         }
         else
         {
            this._shopPopup = new SBPopup(this._popupLayer,shopSkin,this._shop,false,true,false,false,true);
         }
         this._closeCallback = init_closeCallback;
         this._shopPopup.x = initPopupX;
         this._shopPopup.y = initPopupY;
         this._shopPopup.bxClosesPopup = false;
         this._shopPopup.visible = false;
         this._timeSeconds = new Date().valueOf() / 1000;
         if(!isNaN(gMainFrame.clientInfo.currentTimestamp))
         {
            timeOffset = gMainFrame.clientInfo.currentTimestamp - this._timeSeconds;
         }
         else
         {
            timeOffset = 0;
         }
         this._timeSeconds += timeOffset;
         this.toggleInitialVisibility();
         this._shop.titleTxt.text = "";
         this._shop.titleTxtDiamond.text = "";
         this._shop.buyPopup.visible = false;
         this._shop.oopsPopup.visible = false;
         this._shop.gemAnim.visible = false;
         this._bItemsPurchased = false;
         DarkenManager.showLoadingSpiral(true);
         ItemXtCommManager.requestShopList(this.gotItemListCallback,this._shopId);
         DenPreviewManager.setCurrentShop(this);
         return this._shopPopup;
      }
      
      public function get showTutorial() : Boolean
      {
         return this._showTutorial;
      }
      
      public function set denItemIdx(value:int) : void
      {
         this._denItemIdx = value;
      }
      
      public function showShop(show:Boolean) : void
      {
         if(this._shopPopup.visible != show)
         {
            this._shopPopup.visible = show;
            if(show)
            {
               this.setupBigBuyPopup();
            }
         }
      }
      
      public function attemptToBuyCurrrentItem() : void
      {
         this.buyBtnDownHandler(null);
      }
      
      private function toggleInitialVisibility() : void
      {
         for(var i:int = 0; i < this.ITEMS_PER_SCREEN; i++)
         {
            this._shop["iw" + i].tag.visible = !this._shop["iw" + i].tag.visible;
            this._shop["iw" + i].banner.visible = false;
            this._shop["iw" + i].newTag.visible = false;
            this._shop["iw" + i].saleTag.visible = false;
            this._shop["iw" + i].clearanceTag.visible = false;
            this._shop["iw" + i].daysLeftTag.visible = false;
            this._shop["iw" + i].itemNameTxt.visible = !this._shop["iw" + i].itemNameTxt.visible;
            this._shop["iw" + i].itemNameTxtMultiline.visible = !this._shop["iw" + i].itemNameTxtMultiline.visible;
            this._shop["iw" + i].ocean.visible = false;
         }
         this._shop.buyBigPopup.visible = false;
         this._shop.colorCycleBigBtn.visible = false;
         this._shop.colorCycleBigFlash.visible = false;
         this._shop.buyPopup.paw.visible = false;
         this._shop.buyPopup.newTag.visible = false;
         this._shop.buyPopup.saleTag.visible = false;
         this._shop.buyPopup.clearanceTag.visible = false;
         this._shop.buyPopup.daysLeftTag.visible = false;
         this._shop.buyPopup.ocean.visible = false;
         this._shop.buyBigPopup.newTag.visible = false;
         this._shop.buyBigPopup.saleTag.visible = false;
         this._shop.buyBigPopup.clearanceTag.visible = false;
         this._shop.buyBigPopup.daysLeftTag.visible = false;
         this._shop.buyBigPopup.ocean.visible = false;
      }
      
      private function setupDiamondItems(isDiamondStore:Boolean) : void
      {
         if(isDiamondStore)
         {
            this._appendString = "Diamond";
            this._isDiamondStore = true;
            this._shop.buyBigPopup.buyGreenBGDiamond.visible = true;
            this._shop.buyBigPopup.buyGreenBG.visible = false;
            this._shop.buyBigPopup.buyBlueBGDiamond.visible = true;
            this._shop.buyBigPopup.buyBlueBG.visible = false;
            this._shop.buyBigPopup.bgDiamond.visible = true;
            this._shop.buyBigPopup.bg.visible = false;
            this._shop.buyPopup.buyGreenBGDiamond.visible = true;
            this._shop.buyPopup.buyGreenBG.visible = false;
            this._shop.buyPopup.buyBlueBGDiamond.visible = true;
            this._shop.buyPopup.buyBlueBG.visible = false;
            this._shop.buyPopup.bgDiamond.visible = true;
            this._shop.buyPopup.bg.visible = false;
            this._shop.buyPopup.questAbilitiesDiamond.visible = false;
            this._shop.buyPopup.questAbilities.visible = false;
            this._shop.titleTxtDiamond.visible = true;
            this._shop.gemBanner.visible = false;
            this._shop.myGemCountTxt.visible = false;
            this._shop.myGemCountTxt = this._shop.myGemCountTxtDiamond;
            this._shop.titleTxt = this._shop.titleTxtDiamond;
            this._shop.sparkleCont.visible = true;
            this._shop.infoBtn.visible = true;
         }
         else
         {
            this._shop.buyBigPopup.buyGreenBGDiamond.visible = false;
            this._shop.buyBigPopup.buyBlueBGDiamond.visible = false;
            this._shop.buyBigPopup.bgDiamond.visible = false;
            this._shop.buyPopup.buyGreenBGDiamond.visible = false;
            this._shop.buyPopup.buyBlueBGDiamond.visible = false;
            this._shop.buyPopup.bgDiamond.visible = false;
            this._shop.buyPopup.questAbilitiesDiamond.visible = false;
            this._shop.titleBannerDiamond.visible = false;
            this._shop.titleTxtDiamond.visible = false;
            this._shop.oopsCostPopupDiamond.visible = false;
            this._shop.myGemCountTxtDiamond.visible = false;
            this._shop.gemBannerDiamond.visible = false;
            this._shop.myGemCountTxt.visible = true;
            this._shop.sparkleCont.visible = false;
            this._shop.buyBigPopup.sparkleCont.visible = false;
            this._shop.buyPopup.sparkleCont.visible = false;
            this._shop.infoBtn.visible = false;
         }
         this._shop["oopsCostPopup"].visible = false;
         this._shop["oopsCostPopup" + this._appendString].visible = false;
         this._shop.buyPopup["questAbilities" + this._appendString].visible = false;
      }
      
      public function destroy() : void
      {
         var i:int = 0;
         var j:int = 0;
         SBTracker.pop();
         DenPreviewManager.setCurrentShop(null);
         this.removeListeners();
         if(Boolean(this._shop.buyPopup.visible))
         {
            DarkenManager.unDarken(this._shop.buyPopup);
         }
         if(Boolean(this._shop.buyBigPopup.visible))
         {
            DarkenManager.unDarken(this._shop.buyBigPopup);
         }
         if(this._makePopup && Boolean(this._shopPopup))
         {
            this._shopPopup.destroy();
            this._shopPopup = null;
         }
         if(Boolean(this._shopItemArray) && this._shopItemArray.length > 0)
         {
            for(i = 0; i < this._shopItemArray.length; i++)
            {
               this._shopItemArray[i].destroy();
            }
            this._shopItemArray.splice(0,this._shopItemArray.length);
         }
         this._shopItemArray = null;
         if(Boolean(this._spirals) && this._spirals.length > 0)
         {
            for(j = 0; j < this._spirals.length; j++)
            {
               this._spirals[j].destroy();
            }
            this._spirals.splice(0,this._spirals.length);
         }
         GuiManager.closeTutorialTextPopup();
         this._spirals = null;
         this._closeCallback = null;
      }
      
      public function setOnPurchaseSuccessCallback(callback:Function) : void
      {
         this._onPurchaseSuccessCallback = callback;
      }
      
      public function get isAudioShop() : Boolean
      {
         return this._isDenAudioList;
      }
      
      public function applyAndClose() : void
      {
         if(this._closeCallback != null)
         {
            this._closeCallback(this._bItemsPurchased);
         }
         else
         {
            this.destroy();
         }
      }
      
      public function gotItemListCallback(itemArray:Array, shopName:String, itemColorsArray:Array = null) : void
      {
         if(shopName != "")
         {
            LocalizationManager.translateId(this._shop.titleTxt,int(shopName));
            LocalizationManager.translateId(this._shop.titleTxtDiamond,int(shopName));
         }
         this._pageURI = "/game/play/popup/store/";
         switch(this._glDefType)
         {
            case DefPacksDefHelper.DEF_ITEM:
               this._pageURI += "accessory/#";
               break;
            case DefPacksDefHelper.DEF_DEN_ITEM:
               if(this._isDenAudioList)
               {
                  this._pageURI += "denAudio/#";
               }
               else
               {
                  this._pageURI += "denItem/#";
               }
               break;
            case DefPacksDefHelper.DEF_DEN_ROOM:
               this._pageURI += "denRoom/#";
               break;
            case DefPacksDefHelper.DEF_CURRENCY_EXCHANGE:
               this._pageURI += "currency/#";
            case DefPacksDefHelper.DEF_DIAMOND:
               this._pageURI += "diamond/#";
         }
         this._pageURI += shopName + "/page";
         this._unfilteredItemArray = itemArray;
         this._unfilteredColorsArray = itemColorsArray;
         this.filterItemLists();
         this.initialShopSetup();
      }
      
      public function filterItemLists() : void
      {
         if(GenericListXtCommManager.isAvailListExpired())
         {
            GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVAIL_LIST_ID,this.filterItemLists);
            return;
         }
         this._shopItemArray = this._unfilteredItemArray.concat();
         if(Boolean(this._unfilteredColorsArray))
         {
            this._itemColorsArray = this._unfilteredColorsArray.concat();
         }
         else
         {
            this._itemColorsArray = null;
         }
         if(this._shop.titleTxt.text != "")
         {
            GenericListXtCommManager.filterList(this._glDefType,this._shopItemArray,this._itemColorsArray);
         }
      }
      
      public function getCurrentItemDefId() : int
      {
         var diamondDef:Object = null;
         var currItem:Object = this._shopItemArray[this._itemIdx];
         var currItemDef:int = int(currItem.itemDefId);
         if(this._isDiamondStore)
         {
            diamondDef = DiamondXtCommManager.getDiamondDef(currItem.diamondDefId);
            if(Boolean(diamondDef))
            {
               currItemDef = int(diamondDef.refDefId);
            }
         }
         return currItemDef;
      }
      
      public function get isDiamondStore() : Boolean
      {
         return this._isDiamondStore;
      }
      
      private function initialShopSetup() : void
      {
         DarkenManager.showLoadingSpiral(false);
         this._shopPopup.visible = true;
         this._numItems = this._shopItemArray.length;
         if(this._shopItemArray[0] is DenItem && this._shopItemArray[0].sortId == DenItem.SORT_AUDIO)
         {
            this._isDenAudioList = true;
         }
         if(this._shopItemArray[0].currencyType == Item.TICKET_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.ticketCount;
            this._shop.currency.gotoAndStop("tickets");
         }
         else if(this._shopItemArray[0].currencyType == Item.GEM_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.gemCount;
            this._shop.currency.gotoAndStop("gems");
         }
         else if(this._shopItemArray[0].currencyType == Item.ORB_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.orbCount;
            this._shop.currency.gotoAndStop("orbs");
         }
         else if(this._shopItemArray[0].currencyType == Item.DIAMOND_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.diamondCount;
            this._shop.currency.gotoAndStop("diamonds");
            this._shopPopup.skin.s.gotoAndStop("diamond");
            this._shopPopup.bringContentToFront();
            this.setupDiamondItems(true);
         }
         if(!this._isDiamondStore)
         {
            this.setupDiamondItems(false);
         }
         this._shop.myGemCountTxt.text = Utility.convertNumberToString(this._myCurrencyCount);
         if(this._numItems <= 6)
         {
            this._shop.nextBtn.activateGrayState(true);
            this._shop.prevBtn.activateGrayState(true);
         }
         this.addListeners();
         this.setupShopWindows();
         if(this._useStartupShopIndex != -1)
         {
            this.onItemWindowDown(null);
         }
      }
      
      private function setupShopWindows() : void
      {
         var currItem:Object = null;
         var currWindow:MovieClip = null;
         var tempItem:Object = null;
         var matrix:Matrix = null;
         var page:int = int(this._itemOffset / this.ITEMS_PER_SCREEN) + 1;
         if(this._lastPage != page)
         {
            SBTracker.trackPageview(this._pageURI + page);
            this._lastPage = page;
         }
         for(var i:int = 0; i < this.ITEMS_PER_SCREEN; i++)
         {
            currItem = this._shopItemArray[i + this._itemOffset];
            currWindow = this._shop["iw" + i];
            while(currWindow.itemLayer.numChildren > 1)
            {
               currWindow.itemLayer.removeChildAt(1);
            }
            currWindow.removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemWindowDown);
            currWindow.removeEventListener(MouseEvent.ROLL_OVER,this.onItemWindowRollOver);
            currWindow.removeEventListener(MouseEvent.ROLL_OUT,this.onItemWindowRollOut);
            if(Boolean(currItem))
            {
               tempItem = currItem;
               if(!(currItem is DenItem) && !(currItem.icon is AvatarView) && !(currItem.icon is GuiPet))
               {
                  tempItem.icon.filters = [new GlowFilter(this.GLOW_FILTER_COLOR,this.GLOW_FILTER_ALPHA,2,2,4)];
               }
               if(currItem.hasOwnProperty("icon"))
               {
                  if(currItem.icon is AvatarView)
                  {
                     matrix = currItem.icon.transform.matrix;
                     if(matrix.a != -1)
                     {
                        matrix.scale(-1,1);
                        currItem.icon.transform.matrix = matrix;
                     }
                  }
                  currWindow.itemLayer.addChild(tempItem.icon);
               }
               else
               {
                  currWindow.itemLayer.addChild(tempItem);
               }
               this._spirals[i] = new LoadingSpiral(currWindow.itemLayer);
               if(Boolean(this._shopItemArray[i].hasOwnProperty("isIconLoaded")) && !this._shopItemArray[i].isIconLoaded)
               {
                  this._shopItemArray[i].imageLoadedCallback = this._spirals[i].destroy;
               }
               else
               {
                  this._spirals[i].destroy();
               }
               currWindow.tag.txt.text = Utility.convertNumberToString(tempItem.value);
               if(this._myCurrencyCount >= tempItem.value)
               {
                  if(tempItem.currencyType == Item.GEM_CURRENCY)
                  {
                     if(currWindow.tag.currentFrameLabel != "green")
                     {
                        currWindow.tag.gotoAndPlay("green");
                     }
                  }
                  else if(tempItem.currencyType == Item.TICKET_CURRENCY)
                  {
                     if(currWindow.tag.currentFrameLabel != "ticketGreen")
                     {
                        currWindow.tag.gotoAndPlay("ticketGreen");
                     }
                  }
                  else if(tempItem.currencyType == Item.ORB_CURRENCY)
                  {
                     if(currWindow.tag.currentFrameLabel != "orbGreen")
                     {
                        currWindow.tag.gotoAndPlay("orbGreen");
                     }
                  }
                  else if(tempItem.currencyType == Item.DIAMOND_CURRENCY)
                  {
                     if(currWindow.tag.currentFrameLabel != "diamondGreen")
                     {
                        currWindow.tag.gotoAndPlay("diamondGreen");
                     }
                  }
                  currWindow.tag.txt.textColor = "0x386630";
               }
               else
               {
                  if(tempItem.currencyType == Item.GEM_CURRENCY)
                  {
                     if(currWindow.tag.currentFrameLabel != "red")
                     {
                        currWindow.tag.gotoAndPlay("red");
                     }
                  }
                  else if(tempItem.currencyType == Item.TICKET_CURRENCY)
                  {
                     if(currWindow.tag.currentFrameLabel != "ticketRed")
                     {
                        currWindow.tag.gotoAndPlay("ticketRed");
                     }
                  }
                  else if(tempItem.currencyType == Item.ORB_CURRENCY)
                  {
                     if(currWindow.tag.currentFrameLabel != "orbRed")
                     {
                        currWindow.tag.gotoAndPlay("orbRed");
                     }
                  }
                  else if(tempItem.currencyType == Item.DIAMOND_CURRENCY)
                  {
                     if(currWindow.tag.currentFrameLabel != "diamondRed")
                     {
                        currWindow.tag.gotoAndPlay("diamondRed");
                     }
                  }
                  currWindow.tag.txt.textColor = "0x800000";
               }
               currWindow.tag.visible = true;
               LocalizationManager.updateToFit(currWindow.itemNameTxt,tempItem.name);
               if(Boolean(currItem.isMemberOnly))
               {
                  currWindow.banner.visible = true;
                  LocalizationManager.translateId(currWindow.banner.txt,LocalizationManager.MEMBERS);
                  if(this._isMember)
                  {
                     currWindow.lockOpen.visible = true;
                  }
                  else
                  {
                     currWindow.lock.visible = true;
                  }
               }
               else
               {
                  currWindow.banner.visible = false;
                  currWindow.lock.visible = false;
                  currWindow.lockOpen.visible = false;
               }
               if(Boolean(currItem.isOcean))
               {
                  currWindow.blueBG.visible = true;
                  currWindow.greenBG.visible = false;
               }
               else
               {
                  currWindow.greenBG.visible = true;
               }
               currWindow.avtSpecific.visible = false;
               currWindow.newTag.visible = currItem.isNew;
               currWindow.clearanceTag.visible = currItem.isOnClearance;
               this.setupNumDaysLeft(currWindow.daysLeftTag,currItem);
               currWindow.rareTag.visible = currItem.isRare;
               currWindow.saleTag.visible = currItem.isOnSale;
               currWindow.ocean.visible = currItem.isOcean;
               currWindow.addEventListener(MouseEvent.MOUSE_DOWN,this.onItemWindowDown,false,0,true);
               currWindow.addEventListener(MouseEvent.ROLL_OVER,this.onItemWindowRollOver,false,0,true);
               currWindow.addEventListener(MouseEvent.ROLL_OUT,this.onItemWindowRollOut,false,0,true);
            }
            else
            {
               currWindow.tag.visible = false;
               currWindow.tag.txt.text = "";
               currWindow.itemNameTxt.text = "";
               currWindow.itemNameTxtMultiline.text = "";
               currWindow.banner.visible = false;
               currWindow.lock.visible = false;
               currWindow.lockOpen.visible = false;
               currWindow.blueBG.visible = false;
               currWindow.newTag.visible = false;
               currWindow.clearanceTag.visible = false;
               currWindow.saleTag.visible = false;
               currWindow.ocean.visible = false;
               currWindow.greenBG.visible = false;
               currWindow.rareTag.visible = false;
               currWindow.avtSpecific.visible = false;
               currWindow.daysLeftTag.visible = false;
            }
            currWindow.itemNameTxt.visible = false;
            currWindow.itemNameTxtMultiline.visible = false;
         }
      }
      
      private function setupNumDaysLeft(daysLeftTag:MovieClip, currItem:Object) : void
      {
         var daysLeft:int = 0;
         if(!currItem.isRare && !currItem.isNew && !currItem.isOnSale)
         {
            daysLeft = Math.ceil((currItem.endTime - this._timeSeconds) / 60 / 60 / 24);
            if(daysLeft > 0 && daysLeft <= 10)
            {
               if(daysLeft == 1)
               {
                  LocalizationManager.translateId(daysLeftTag.txt,18061);
               }
               else
               {
                  LocalizationManager.translateIdAndInsert(daysLeftTag.txt,6260,daysLeft);
               }
               daysLeftTag.visible = true;
               MovieClip(daysLeftTag.parent).clearanceTag.visible = false;
            }
            else
            {
               daysLeftTag.visible = false;
            }
         }
         else
         {
            daysLeftTag.visible = false;
         }
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(Boolean(this._shop.buyPopup.visible))
         {
            if(this._itemToBuy is DenItem && this._itemToBuy.sortId == DenItem.SORT_AUDIO)
            {
               RoomManagerWorld.instance.playPreviousMusic();
            }
            DarkenManager.unDarken(this._shop.buyPopup);
         }
         if(Boolean(this._shop.buyBigPopup.visible))
         {
            DarkenManager.unDarken(this._shop.buyBigPopup);
         }
         this.applyAndClose();
         QuestManager.onShopClose();
         GuiManager.closeTutorialTextPopup();
      }
      
      private function buyBtnDownHandler(evt:MouseEvent = null) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         var canBuyThisItem:Boolean = Boolean(this._shopItemArray[this._itemIdx].isMemberOnly) ? this._isMember : true;
         if(this._isDiamondStore && canBuyThisItem)
         {
            GuiManager.showDiamondConfirmation(this._shopItemArray[this._itemIdx].value,this.attemptToPurchaseItem);
         }
         else
         {
            this.attemptToPurchaseItem();
         }
      }
      
      private function attemptToPurchaseItem() : void
      {
         var recycleId:int = 0;
         var displayFullMessage:Boolean = false;
         var currItem:Object = this._shopItemArray[this._itemIdx];
         if(!this._isMember)
         {
            if(Boolean(currItem.isMemberOnly))
            {
               if(currItem is Item)
               {
                  UpsellManager.displayPopup(UpsellManager.ACCESSORIES,"buyAccessory/" + currItem.name);
                  return;
               }
               if(currItem is DenItem)
               {
                  if(this._isDenAudioList)
                  {
                     UpsellManager.displayPopup(UpsellManager.DEN_AUDIO,"buyDenAudio/" + currItem.name);
                  }
                  else
                  {
                     UpsellManager.displayPopup(UpsellManager.DEN_ITEMS,"buyDenItem/" + currItem.name);
                  }
                  return;
               }
               if(currItem is DenRoomItem)
               {
                  UpsellManager.displayPopup(UpsellManager.DENS,"buyDenRoom/" + currItem.name);
                  return;
               }
               trace("ERROR: _shopId=" + this._shopId + " is not expected.");
            }
         }
         if(currItem.value > this._myCurrencyCount)
         {
            if(this._isDiamondStore)
            {
               UpsellManager.displayPopup(UpsellManager.EXTRA_DIAMONDS_AS_MEMBER,"extraDiamonds");
            }
            else
            {
               DarkenManager.darken(this._shop["oopsCostPopup" + this._appendString]);
               if(currItem.currencyType == Item.GEM_CURRENCY)
               {
                  this._shop["oopsCostPopup" + this._appendString].currency.gotoAndStop("gems");
               }
               else if(currItem.currencyType == Item.TICKET_CURRENCY)
               {
                  this._shop["oopsCostPopup" + this._appendString].currency.gotoAndStop("tickets");
               }
               else if(currItem.currencyType == Item.ORB_CURRENCY)
               {
                  this._shop["oopsCostPopup" + this._appendString].currency.gotoAndStop("orbs");
               }
               else if(currItem.currencyType == Item.DIAMOND_CURRENCY)
               {
                  this._shop["oopsCostPopup" + this._appendString].currency.gotoAndStop("diamonds");
               }
               this._shop["oopsCostPopup" + this._appendString].gemsTxt.text = this._myCurrencyCount;
               this._shop["oopsCostPopup" + this._appendString].costTxt.text = Utility.convertNumberToString(currItem.value);
               this._shop["oopsCostPopup" + this._appendString].needTxt.text = Utility.convertNumberToString(currItem.value - this._myCurrencyCount);
               this._shop["oopsCostPopup" + this._appendString].visible = true;
            }
         }
         else if(currItem is Item)
         {
            if(this._playerAvatar.inventoryClothing.numItems < maxItems)
            {
               if(currItem.defId > 0)
               {
                  this.sendBuyRequest(currItem);
               }
            }
            else
            {
               if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND)
               {
                  recycleId = RecycleItems.RECYCLE_ACCESSORIES_LAND_ONLY;
               }
               else
               {
                  recycleId = RecycleItems.RECYCLE_ACCESSORIES_OCEAN_ONLY;
               }
               new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdOnly(14746),true,this.confirmRecycleHandler,recycleId);
            }
         }
         else if(currItem is DenItem)
         {
            if(currItem.sortId == DenItem.SORT_AUDIO)
            {
               if(Utility.numDenItemsInList(this._playerAvatar.inventoryDenFull.itemArray,-1,true) < maxAudioItems)
               {
                  this.sendBuyRequest(currItem);
               }
               else
               {
                  recycleId = RecycleItems.RECYCLE_DEN_AUDIO;
                  displayFullMessage = true;
               }
            }
            else if(Utility.numDenItemsInList(this._playerAvatar.inventoryDenPartial.itemArray,-1) < maxDenItems)
            {
               this.sendBuyRequest(currItem);
            }
            else
            {
               if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND)
               {
                  recycleId = RecycleItems.RECYCLE_DEN_ITEMS_LAND_ONLY;
               }
               else
               {
                  recycleId = RecycleItems.RECYCLE_DEN_ITEMS_OCEAN_ONLY;
               }
               displayFullMessage = true;
            }
            if(displayFullMessage)
            {
               new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdOnly(14746),true,this.confirmRecycleHandler,recycleId);
            }
         }
         else if(currItem is DenRoomItem)
         {
            if(this._denItemIdx == 0)
            {
               this._denItemIdx = DenSwitch.nextFreeSlotIdx;
            }
            if(!DenSwitch.denList[this._denItemIdx] && this._denItemIdx < SwitchManager.NUM_DEN_ROOM_SLOTS && this._denItemIdx > 0)
            {
               this.sendBuyRequest(currItem);
            }
            else
            {
               recycleId = DenSwitch.RECYCLE_DEN_ROOM;
               new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdOnly(14746),true,this.confirmRecycleHandler,recycleId);
            }
         }
         else if(this._glDefType == DefPacksDefHelper.DEF_CURRENCY_EXCHANGE)
         {
            this.sendBuyRequest(currItem);
         }
      }
      
      private function sendBuyRequest(currItem:Object) : void
      {
         if(this._showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,DEN_EDIT_TUTORIAL_SHOP_BUY))
         {
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,DEN_EDIT_TUTORIAL_SHOP_BUY);
            this._shop.buyBtnGreen.setButtonState(0);
         }
         if(this._showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,DEN_EDIT_TUTORIAL_COMPLETE))
         {
            GuiManager.openTutorialTextPopup(LocalizationManager.translateIdOnly(18661),10,115);
         }
         if(currItem is Item)
         {
            ItemXtCommManager.requestItemBuy(this.confirmPurchase,this._shopId,this._isDiamondStore ? int(currItem.diamondDefId) : int(currItem.defId),this._itemColorIdx,this._isDiamondStore ? 1 : 0);
            ItemXtCommManager.setItemBuyIlCallback(this.putOnPurchasedItem);
         }
         else if(currItem is DenItem)
         {
            DenXtCommManager.requestBuy(true,this._shopId,this._isDiamondStore ? int(currItem.diamondDefId) : int(currItem.itemDefId),this.confirmPurchase,0,null,this._itemToBuy.version,this._isDiamondStore ? 1 : 0);
         }
         else if(currItem is DenRoomItem)
         {
            DenXtCommManager.requestBuy(false,this._shopId,currItem.itemDefId,this.confirmPurchase,this._denItemIdx,this._denRoomShopCallback != null ? this._denRoomShopCallback : this.onDenPurchase,0,this._isDiamondStore ? 1 : 0);
         }
         else if(this._glDefType == DefPacksDefHelper.DEF_CURRENCY_EXCHANGE)
         {
            ItemXtCommManager.requestCurrencyExchange(this._shopId,currItem.itemDefId,this.confirmPurchase);
         }
         DarkenManager.showLoadingSpiral(true);
      }
      
      private function pageCatalogHandler(evt:MouseEvent) : void
      {
         var offset:int = 0;
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            if(evt.currentTarget.name == this._shop.nextBtn.name && this._numItems > this.ITEMS_PER_SCREEN)
            {
               if(this._itemOffset + this.ITEMS_PER_SCREEN < this._numItems)
               {
                  this._itemOffset += this.ITEMS_PER_SCREEN;
               }
               else
               {
                  this._itemOffset = 0;
               }
            }
            else if(evt.currentTarget.name == this._shop.prevBtn.name && this._numItems > this.ITEMS_PER_SCREEN)
            {
               if(this._itemOffset == 0)
               {
                  offset = this._numItems % this.ITEMS_PER_SCREEN;
                  if(offset != 0)
                  {
                     this._itemOffset = this._numItems - offset;
                  }
                  else
                  {
                     this._itemOffset = this._numItems - this.ITEMS_PER_SCREEN;
                  }
               }
               else
               {
                  this._itemOffset -= this.ITEMS_PER_SCREEN;
               }
            }
            this.setupShopWindows();
         }
      }
      
      private function okBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function confirmFullInventoryHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBOkPopup.destroyInParentChain(evt.target.parent);
         this.onClose(null);
      }
      
      private function confirmRecycleHandler(o:Object) : void
      {
         var recycleType:int = 0;
         if(Boolean(o.status))
         {
            recycleType = int(o.passback);
            if(recycleType == DenSwitch.RECYCLE_DEN_ROOM)
            {
               GuiManager.openDenRoomSwitcher(true,this.onDenRoomRecycleClose,false,-1,this._shopId);
            }
            else
            {
               this._recyclePopup = new RecycleItems();
               this._recyclePopup.init(recycleType,this._popupLayer,true,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5,true);
            }
         }
         else
         {
            this.onClose(null);
         }
      }
      
      private function onRecycleClose(itemRecycled:Boolean = false) : void
      {
         if(Boolean(this._recyclePopup))
         {
            this._recyclePopup.destroy();
            this._recyclePopup = null;
         }
      }
      
      private function onDenRoomRecycleClose(itemRecycled:Boolean = false) : void
      {
         GuiManager.onDenSwitchClose(itemRecycled);
         DenPreviewManager.exitPreview();
      }
      
      private function onItemNoLongerAvailable(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._itemNotAvailPopup))
         {
            this._itemNotAvailPopup.destroy();
            this._itemNotAvailPopup = null;
         }
         if(this._shopId == GenericListXtCommManager.DEN_ROOM_SHOP_ID)
         {
            this.onBuyBigPopupCloseBtnDown(null);
         }
         else
         {
            this.onBuyPopupCloseBtnDown(null);
         }
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVAIL_LIST_ID,this.filterItemLists);
      }
      
      private function onDenPurchase() : void
      {
         DenPreviewManager.handleDenPurchase();
      }
      
      private function confirmPurchase(status:int, newGemCount:int = 0) : void
      {
         var numAudioItems:int = 0;
         var numDenItems:int = 0;
         var numDenRoomItems:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(status == 1)
         {
            this._bItemsPurchased = true;
            if(this._shopId == GenericListXtCommManager.DEN_ROOM_SHOP_ID)
            {
               this.onBuyBigPopupCloseBtnDown(null);
               if(!this._isShopOnlyDen)
               {
                  this._shop.gemAnim.visible = true;
                  this._shop.gemAnim.gotoAndPlay(1);
                  AJAudio.playShopCachingSound();
                  return;
               }
            }
            else
            {
               this.onBuyPopupCloseBtnDown(null);
               this.onBuyBigPopupCloseBtnDown(null);
            }
            this._shop.gemAnim.visible = true;
            this._shop.gemAnim.gotoAndPlay(1);
            AJAudio.playShopCachingSound();
            this._myCurrencyCount = newGemCount;
            this._shop.myGemCountTxt.text = Utility.convertNumberToString(this._myCurrencyCount);
            if(this._itemToBuy is Item && this._playerAvatar.inventoryClothing.numItems >= warningItemCount)
            {
               new SBOkPopup(this._popupLayer,this.getWarningText(this._playerAvatar.inventoryClothing.numItems,maxItems));
            }
            else if(this._itemToBuy is DenItem)
            {
               if(this._itemToBuy.sortId == DenItem.SORT_AUDIO)
               {
                  numAudioItems = Utility.numDenItemsInList(this._playerAvatar.inventoryDenFull.itemArray,-1,true);
                  if(numAudioItems >= warningAudioItemCount)
                  {
                     new SBOkPopup(this._popupLayer,this.getWarningText(numAudioItems,maxAudioItems));
                  }
               }
               else
               {
                  numDenItems = Utility.numDenItemsInList(this._playerAvatar.inventoryDenPartial.itemArray,-1);
                  if(numDenItems >= warningDenItemCount)
                  {
                     new SBOkPopup(this._popupLayer,this.getWarningText(numDenItems,maxDenItems));
                  }
               }
            }
            else if(this._itemToBuy is DenRoomItem)
            {
               numDenRoomItems = DenSwitch.numDens;
               if(numDenRoomItems >= warningDenRoomCount)
               {
                  new SBOkPopup(this._popupLayer,this.getWarningText(numDenRoomItems,SwitchManager.NUM_DEN_ROOM_SLOTS));
               }
            }
            this.setupShopWindows();
         }
         else
         {
            if(status == -1)
            {
               this._itemNotAvailPopup = new SBOkPopup(this._popupLayer,LocalizationManager.translateIdOnly(14797),true,this.onItemNoLongerAvailable);
            }
            else
            {
               new SBOkPopup(this._popupLayer,LocalizationManager.translateIdOnly(14798));
            }
            ItemXtCommManager.setItemBuyIlCallback(null);
         }
      }
      
      private function getWarningText(numItemsOwned:int, maxItems:int) : String
      {
         var numRemaining:int = maxItems - (numItemsOwned + 1);
         var warningTxt:String = "";
         if(numRemaining > 1)
         {
            warningTxt = LocalizationManager.translateIdAndInsertOnly(11378,numRemaining);
         }
         else if(numRemaining == 1)
         {
            warningTxt = LocalizationManager.translateIdAndInsertOnly(11379,numRemaining);
         }
         else
         {
            warningTxt = LocalizationManager.translateIdOnly(11381);
         }
         return warningTxt;
      }
      
      private function putOnPurchasedItem() : void
      {
         var takeOffItem:Item = null;
         var layerId:int = int(this._shopItemArray[this._itemIdx].layerId);
         var itemList:Array = this._playerAvatar.inventoryClothing.itemArray;
         var itemInvIdxToGoOn:int = int(itemList[0].invIdx);
         var itemInvIdxToComeOff:int = -1;
         for each(takeOffItem in itemList)
         {
            if(takeOffItem.getInUse(this._playerAvatar.perUserAvId) && takeOffItem.layerId == layerId && takeOffItem.invIdx != itemInvIdxToGoOn)
            {
               itemInvIdxToComeOff = takeOffItem.invIdx;
               break;
            }
         }
         if(this._shopItemArray[this._itemIdx].enviroType == AvatarManager.roomEnviroType)
         {
            ItemXtCommManager.requestItemUse(null,[itemInvIdxToGoOn],itemInvIdxToComeOff != -1 ? [itemInvIdxToComeOff] : []);
            ItemXtCommManager.setItemBuyIlCallback(null);
         }
         if(this._onPurchaseSuccessCallback != null)
         {
            this._onPurchaseSuccessCallback();
         }
      }
      
      private function onItemWindowDown(evt:MouseEvent) : void
      {
         var idx:int = 0;
         if(Boolean(evt))
         {
            evt.stopPropagation();
            if(evt.currentTarget.name == this._shop.iw0.name)
            {
               idx = 0;
            }
            else if(evt.currentTarget.name == this._shop.iw1.name)
            {
               idx = 1;
            }
            else if(evt.currentTarget.name == this._shop.iw2.name)
            {
               idx = 2;
            }
            else if(evt.currentTarget.name == this._shop.iw3.name)
            {
               idx = 3;
            }
            else if(evt.currentTarget.name == this._shop.iw4.name)
            {
               idx = 4;
            }
            else if(evt.currentTarget.name == this._shop.iw5.name)
            {
               idx = 5;
            }
            this._itemIdx = idx + this._itemOffset;
         }
         else
         {
            this._itemIdx = this._useStartupShopIndex;
         }
         var currItem:Object = this._shopItemArray[this._itemIdx];
         if(!currItem)
         {
            return;
         }
         if(Boolean(currItem is Item) && Boolean(this._itemColorsArray) && this._itemColorsArray[this._itemIdx].length > 1)
         {
            currItem.color = this._itemColorsArray[this._itemIdx][this._itemColorIdx];
            this._shop.colorCycleBtn.visible = !this._isInFFM;
            this._shop.colorCycleFlash.visible = !this._isInFFM;
         }
         else if(currItem is DenItem)
         {
            if(Boolean(currItem.getVersions()) && currItem.getVersions().length > 0)
            {
               this._denItemColorsArray = currItem.getVersions();
               currItem.setVersion(this._denItemColorsArray[this._itemColorIdx]);
               this._shop.colorCycleBtn.visible = !this._isInFFM;
               this._shop.colorCycleFlash.visible = !this._isInFFM;
            }
            else
            {
               this._denItemColorsArray = null;
               this._shop.colorCycleFlash.visible = false;
               this._shop.colorCycleBtn.visible = false;
            }
         }
         else
         {
            this._shop.colorCycleFlash.visible = false;
            this._shop.colorCycleBtn.visible = false;
         }
         if(this._shopId == GenericListXtCommManager.DEN_ROOM_SHOP_ID || currItem is DenRoomItem)
         {
            this._shop.buyPopup.visible = false;
            this.setupBigBuyPopup();
         }
         else
         {
            this._shop.buyBigPopup.visible = false;
            this.setupBuyPopup();
         }
      }
      
      private function onItemWindowRollOver(evt:MouseEvent) : void
      {
         var idx:int = 0;
         evt.stopPropagation();
         if(evt.currentTarget.name == this._shop.iw0.name)
         {
            idx = 0;
         }
         else if(evt.currentTarget.name == this._shop.iw1.name)
         {
            idx = 1;
         }
         else if(evt.currentTarget.name == this._shop.iw2.name)
         {
            idx = 2;
         }
         else if(evt.currentTarget.name == this._shop.iw3.name)
         {
            idx = 3;
         }
         else if(evt.currentTarget.name == this._shop.iw4.name)
         {
            idx = 4;
         }
         else if(evt.currentTarget.name == this._shop.iw5.name)
         {
            idx = 5;
         }
         if(this._shop["iw" + idx].currentFrameLabel != "mouse")
         {
            this._shop["iw" + idx].gotoAndPlay("mouse");
         }
         if(this._shop["iw" + idx].itemNameTxt.text == this._shop["iw" + idx].itemNameTxtMultiline.text)
         {
            this._shop["iw" + idx].mouse0.gotoAndStop("multi");
            this._shop["iw" + idx].itemNameTxtMultiline.visible = true;
         }
         else
         {
            this._shop["iw" + idx].mouse0.gotoAndStop("single");
            this._shop["iw" + idx].itemNameTxt.visible = true;
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowRollOut(evt:MouseEvent) : void
      {
         var idx:int = 0;
         evt.stopPropagation();
         if(evt.currentTarget.name == this._shop.iw0.name)
         {
            idx = 0;
         }
         else if(evt.currentTarget.name == this._shop.iw1.name)
         {
            idx = 1;
         }
         else if(evt.currentTarget.name == this._shop.iw2.name)
         {
            idx = 2;
         }
         else if(evt.currentTarget.name == this._shop.iw3.name)
         {
            idx = 3;
         }
         else if(evt.currentTarget.name == this._shop.iw4.name)
         {
            idx = 4;
         }
         else if(evt.currentTarget.name == this._shop.iw5.name)
         {
            idx = 5;
         }
         if(this._shop["iw" + idx].currentFrameLabel != "out")
         {
            this._shop["iw" + idx].gotoAndPlay("out");
         }
         if(this._shop["iw" + idx].itemNameTxt.text == this._shop["iw" + idx].itemNameTxtMultiline.text)
         {
            this._shop["iw" + idx].itemNameTxtMultiline.visible = false;
         }
         else
         {
            this._shop["iw" + idx].itemNameTxt.visible = false;
         }
      }
      
      private function setupBuyPopup() : void
      {
         this._itemToBuy = this._shopItemArray[this._itemIdx];
         if(this._itemToBuy.icon is GuiPet)
         {
            this._petFinder = new PetFinder();
            this._petFinder.init(this._itemToBuy.icon.idx,this.OnPetFinderClose,false,null,this._itemToBuy.currencyType,DiamondXtCommManager.getDiamondItem(this._itemToBuy.itemDefId),this._shopId);
            return;
         }
         if(this._itemToBuy.icon is AvatarView)
         {
            AvatarSwitch.addAvatar(AvatarSwitch.avatars.length,false,this.onAvatarAdded,false,this._itemToBuy.isOcean,this._itemToBuy.icon.avTypeId,true,this._itemToBuy.currencyType,this._itemToBuy.value,this._shopId,this._itemToBuy.itemDefId);
            return;
         }
         this._itemToBuy = this._shopItemArray[this._itemIdx].clone();
         this._itemColorIdx = 0;
         if(Boolean(this._itemToBuy.isMemberOnly))
         {
            this._shop.buyPopup.banner.visible = true;
            LocalizationManager.translateId(this._shop.buyPopup.banner.txt,LocalizationManager.MEMBERS);
            if(this._isMember)
            {
               this._shop.buyPopup.lockOpen.visible = true;
               this._shop.buyPopup.lock.visible = false;
            }
            else
            {
               this._shop.buyPopup.lock.visible = true;
               this._shop.buyPopup.lockOpen.visible = false;
            }
         }
         else
         {
            this._shop.buyPopup.banner.visible = false;
            this._shop.buyPopup.lockOpen.visible = false;
            this._shop.buyPopup.lock.visible = false;
         }
         if(Boolean(this._itemToBuy.isOcean))
         {
            this._shop.buyPopup.buyGreenBG.visible = false;
         }
         else
         {
            this._shop.buyPopup.buyGreenBG.visible = true;
         }
         this._shop.buyPopup.avtSpecificIcon.visible = false;
         this._shop.buyPopup.newTag.visible = this._itemToBuy.isNew;
         this._shop.buyPopup.clearanceTag.visible = this._itemToBuy.isOnClearance;
         this.setupNumDaysLeft(this._shop.buyPopup.daysLeftTag,this._itemToBuy);
         this._shop.buyPopup.saleTag.visible = this._itemToBuy.isOnSale;
         this._shop.buyPopup.rareTag.visible = this._itemToBuy.isRare;
         if(this._shop.buyPopup.itemLayer.numChildren > 1)
         {
            this._shop.buyPopup.itemLayer.removeChildAt(1);
         }
         if(!(this._itemToBuy is DenItem))
         {
            this._itemToBuy.largeIcon.filters = [new GlowFilter(this.GLOW_FILTER_COLOR,this.GLOW_FILTER_ALPHA,2,2,8)];
         }
         this._shop.buyPopup.itemLayer.addChild(this._itemToBuy.largeIcon);
         this._shop.buyPopup.tag.txt.text = Utility.convertNumberToString(this._itemToBuy.value);
         if(this._myCurrencyCount >= this._itemToBuy.value)
         {
            if(this._itemToBuy.currencyType == Item.GEM_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "green")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("green");
               }
            }
            else if(this._itemToBuy.currencyType == Item.TICKET_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "ticketGreen")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("ticketGreen");
               }
            }
            else if(this._itemToBuy.currencyType == Item.ORB_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "orbGreen")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("orbGreen");
               }
            }
            else if(this._itemToBuy.currencyType == Item.DIAMOND_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "diamondGreen")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("diamondGreen");
               }
            }
            this._shop.buyPopup.tag.txt.textColor = "0x386630";
            this._shop.buyBtnGreen.visible = true;
         }
         else
         {
            if(this._itemToBuy.currencyType == Item.GEM_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "red")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("red");
               }
            }
            else if(this._itemToBuy.currencyType == Item.TICKET_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "ticketRed")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("ticketRed");
               }
            }
            else if(this._itemToBuy.currencyType == Item.ORB_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "orbRed")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("orbRed");
               }
            }
            else if(this._itemToBuy.currencyType == Item.DIAMOND_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "diamondRed")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("diamondRed");
               }
            }
            this._shop.buyPopup.tag.txt.textColor = "0x800000";
            this._shop.buyBtnGreen.visible = false;
         }
         LocalizationManager.updateToFit(this._shop.buyPopupItemNameTxt,this._itemToBuy.name);
         if(this._shop.buyPopupItemNameTxt.text == this._shop.buyPopupItemNameTxtMultiline.text)
         {
            this._shop.buyPopup["bg" + this._appendString].gotoAndStop("multi");
         }
         else
         {
            this._shop.buyPopup["bg" + this._appendString].gotoAndStop("single");
         }
         DarkenManager.darken(this._shop.buyPopup);
         this._shop.buyPopup.visible = true;
         AJAudio.playSubMenuBtnClick();
         if(Boolean(this._itemToBuy.isOcean) && Boolean(this._itemToBuy is DenItem) && !DenSwitch.haveOceanDen())
         {
            new SBOkPopup(this._popupLayer,LocalizationManager.translateIdOnly(14799));
         }
         if(this._itemToBuy is DenItem && this._itemToBuy.sortId == DenItem.SORT_AUDIO)
         {
            RoomManagerWorld.instance.playMusic(this._itemToBuy.strmName + ".mp3",this._itemToBuy.version2 / 100);
         }
         if(this._showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_SHOP_PREVIEW))
         {
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_SHOP_PREVIEW);
         }
         if(this._showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,DEN_EDIT_TUTORIAL_SHOP_BUY))
         {
            GuiManager.openTutorialTextPopup(LocalizationManager.translateIdOnly(18660),10,115);
            this._shop.buyBtnGreen.setButtonState(2);
         }
         else
         {
            this._shop.buyBtnGreen.setButtonState(1);
         }
      }
      
      private function setupBigBuyPopup() : void
      {
         var tempItem:Object = this._shopItemArray[this._itemIdx].clone();
         this._itemColorIdx = 0;
         if(Boolean(tempItem.isMemberOnly))
         {
            this._shop.buyBigPopup.banner.visible = true;
            LocalizationManager.translateId(this._shop.buyBigPopup.banner.txt,LocalizationManager.MEMBERS);
            if(this._isMember)
            {
               this._shop.buyBigPopup.lockOpen.visible = true;
               this._shop.buyBigPopup.lock.visible = false;
            }
            else
            {
               this._shop.buyBigPopup.lock.visible = true;
               this._shop.buyBigPopup.lockOpen.visible = false;
            }
         }
         else
         {
            this._shop.buyBigPopup.lockOpen.visible = false;
            this._shop.buyBigPopup.lock.visible = false;
            this._shop.buyBigPopup.banner.visible = false;
         }
         if(Boolean(tempItem.isOcean))
         {
            this._shop.buyBigPopup.buyGreenBG.visible = false;
         }
         else
         {
            this._shop.buyBigPopup.buyGreenBG.visible = true;
         }
         this._shop.buyBigPopup.avtSpecificIcon.visible = false;
         this._shop.buyBigPopup.newTag.visible = tempItem.isNew;
         this._shop.buyBigPopup.clearanceTag.visible = tempItem.isOnClearance;
         this.setupNumDaysLeft(this._shop.buyBigPopup.daysLeftTag,tempItem);
         this._shop.buyBigPopup.saleTag.visible = tempItem.isOnSale;
         this._shop.buyBigPopup.rareTag.visible = tempItem.isRare;
         if(this._shop.buyBigPopup.itemLayer.numChildren > 1)
         {
            this._shop.buyBigPopup.itemLayer.removeChildAt(1);
         }
         if(!(tempItem is DenItem))
         {
            tempItem.largeIcon.filters = [new GlowFilter(this.GLOW_FILTER_COLOR,this.GLOW_FILTER_ALPHA,2,2,8)];
         }
         this._shop.buyBigPopup.itemLayer.addChild(tempItem.largeIcon);
         this._shop.buyBigPopup.tag.txt.text = Utility.convertNumberToString(tempItem.value);
         if(this._myCurrencyCount >= tempItem.value)
         {
            if(tempItem.currencyType == Item.GEM_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "green")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("green");
               }
            }
            else if(tempItem.currencyType == Item.TICKET_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "ticketGreen")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("ticketGreen");
               }
            }
            else if(tempItem.currencyType == Item.ORB_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "orbGreen")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("orbGreen");
               }
            }
            else if(tempItem.currencyType == Item.DIAMOND_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "diamondGreen")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("diamondGreen");
               }
            }
            this._shop.buyBigPopup.tag.txt.textColor = "0x386630";
            this._shop.buyBigBtnGreen.visible = true;
         }
         else
         {
            if(tempItem.currencyType == Item.GEM_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "red")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("red");
               }
            }
            else if(tempItem.currencyType == Item.TICKET_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "ticketRed")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("ticketRed");
               }
            }
            else if(tempItem.currencyType == Item.ORB_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "orbRed")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("orbRed");
               }
            }
            else if(tempItem.currencyType == Item.DIAMOND_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "diamondRed")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("diamondRed");
               }
            }
            this._shop.buyBigPopup.tag.txt.textColor = "0x800000";
            this._shop.buyBigBtnGreen.visible = false;
         }
         LocalizationManager.updateToFit(this._shop.buyBigPopupItemNameTxt,tempItem.name);
         if(this._shop.buyBigPopupItemNameTxt.text == this._shop.buyBigPopupItemNameTxtMultiline.text)
         {
            this._shop.buyBigPopup["bg" + this._appendString].gotoAndStop("multi");
         }
         else
         {
            this._shop.buyBigPopup["bg" + this._appendString].gotoAndStop("single");
         }
         DarkenManager.darken(this._shop.buyBigPopup);
         this._shop.buyBigPopup.visible = true;
         AJAudio.playSubMenuBtnClick();
      }
      
      private function OnPetFinderClose() : void
      {
         if(this._shopItemArray[0].currencyType == Item.TICKET_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.ticketCount;
         }
         else if(this._shopItemArray[0].currencyType == Item.GEM_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.gemCount;
         }
         else if(this._shopItemArray[0].currencyType == Item.ORB_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.orbCount;
         }
         else if(this._shopItemArray[0].currencyType == Item.DIAMOND_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.diamondCount;
         }
         this._shop.myGemCountTxt.text = Utility.convertNumberToString(this._myCurrencyCount);
         this.setupShopWindows();
      }
      
      private function onAvatarAdded(status:int) : void
      {
         if(status == 1)
         {
            this.OnPetFinderClose();
            return;
         }
         if(status == -1)
         {
            LocalizationManager.translateIdAndInsert(this._shop.oopsPopup.body_txt,11382,this._itemToBuy.name.toLowerCase());
         }
         else
         {
            LocalizationManager.translateId(this._shop.oopsPopup.body_txt,11225);
         }
         this._shop.oopsPopup.visible = true;
      }
      
      private function onColorBtnDown(evt:MouseEvent) : void
      {
         var tempItem:Object = null;
         evt.stopPropagation();
         if(this._isMember)
         {
            if(this._itemToBuy is Item && Boolean(this._itemColorsArray))
            {
               if(Boolean(this._itemColorsArray[this._itemIdx][this._itemColorIdx + 1]))
               {
                  ++this._itemColorIdx;
               }
               else
               {
                  if(this._itemColorIdx == 0)
                  {
                     this._shop.colorCycleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorBtnDown);
                     this._shop.colorCycleBtn.visible = false;
                     return;
                  }
                  this._itemColorIdx = 0;
               }
               this._shop.buyPopup.itemLayer.removeChildAt(1);
               tempItem = this._shopItemArray[this._itemIdx].clone();
               tempItem.color = this._itemColorsArray[this._itemIdx][this._itemColorIdx];
               if(!(tempItem is DenItem))
               {
                  tempItem.largeIcon.filters = [new GlowFilter(this.GLOW_FILTER_COLOR,this.GLOW_FILTER_ALPHA,2,2,8)];
               }
               this._shop.buyPopup.itemLayer.addChild(tempItem.largeIcon);
            }
            else
            {
               if(this._denItemColorsArray[this._itemColorIdx + 1] != null)
               {
                  ++this._itemColorIdx;
               }
               else if(this._itemColorIdx != 0)
               {
                  this._itemColorIdx = 0;
               }
               this._shop.buyPopup.itemLayer.removeChildAt(1);
               this._itemToBuy.setVersion(this._denItemColorsArray[this._itemColorIdx]);
               if(!(this._itemToBuy is DenItem))
               {
                  this._itemToBuy.largeIcon.filters = [new GlowFilter(this.GLOW_FILTER_COLOR,this.GLOW_FILTER_ALPHA,2,2,8)];
               }
               this._shop.buyPopup.itemLayer.addChild(this._itemToBuy.largeIcon);
            }
         }
         else if(this._itemToBuy is Item && Boolean(this._itemColorsArray))
         {
            UpsellManager.displayPopup(UpsellManager.ACC_COLOR_CHANGES,"accessoryColorChange");
         }
         else
         {
            UpsellManager.displayPopup(UpsellManager.DEN_ITEM_COLORS,"denItemColorChange");
         }
      }
      
      private function onBuyPopupCloseBtnDown(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         DarkenManager.unDarken(this._shop.buyPopup);
         this._shop.buyPopup.visible = false;
         if(this._shop.buyPopup.itemLayer.numChildren > 1)
         {
            this._shop.buyPopup.itemLayer.removeChildAt(1);
         }
         if(this._itemToBuy is DenItem && this._itemToBuy.sortId == DenItem.SORT_AUDIO)
         {
            RoomManagerWorld.instance.playPreviousMusic();
         }
         GuiManager.closeTutorialTextPopup();
         this._itemColorIdx = 0;
      }
      
      private function onDiamondShopInfoBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.openDiamondShopInfo();
      }
      
      private function onInfoBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._isInfoOpen)
         {
            new GTween(evt.currentTarget.parent,0.5,{"x":evt.currentTarget.parent.x - 185},{
               "ease":TweenManager.quadratic,
               "onComplete":this.sideMenuComplete
            });
            this._isInfoOpen = false;
            AJAudio.playBuddyCardClose();
         }
         else
         {
            new GTween(evt.currentTarget.parent,0.5,{"x":evt.currentTarget.parent.x + 185},{
               "ease":TweenManager.quadratic,
               "onComplete":this.sideMenuComplete
            });
            this._isInfoOpen = true;
            AJAudio.playBuddyCardOpen();
         }
         this._infoTweenFinished = false;
      }
      
      private function sideMenuComplete(tween:GTween) : void
      {
         this._infoTweenFinished = true;
      }
      
      private function onBuyBigPopupCloseBtnDown(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         DarkenManager.unDarken(this._shop.buyBigPopup);
         this._shop.buyBigPopup.visible = false;
         this._denItemIdx = 0;
         if(this._shop.buyBigPopup.itemLayer.numChildren > 1)
         {
            this._shop.buyBigPopup.itemLayer.removeChildAt(1);
         }
      }
      
      private function onBuyBigPopupPreviewBtnDown(evt:MouseEvent) : void
      {
         var diamondDef:Object = null;
         evt.stopPropagation();
         var currItem:Object = this._shopItemArray[this._itemIdx];
         var currItemDef:int = int(currItem.itemDefId);
         if(this._isDiamondStore)
         {
            diamondDef = DiamondXtCommManager.getDiamondDef(currItem.diamondDefId);
            if(Boolean(diamondDef))
            {
               currItemDef = int(diamondDef.refDefId);
            }
         }
         var roomDef:Object = gMainFrame.userInfo.denRoomDefs[currItemDef];
         if(Boolean(roomDef))
         {
            if(Utility.isSameEnviroType(AvatarManager.playerAvatar.enviroTypeFlag,currItem.enviroType))
            {
               DarkenManager.unDarken(this._shop.buyBigPopup);
               RoomManagerWorld.instance.loadDenPreviewRoom(roomDef.xRoomName,currItem.enviroType);
            }
            else
            {
               new SBOkPopup(this._popupLayer,LocalizationManager.translateIdOnly(18903));
            }
         }
      }
      
      private function onOopsPopupCloseBtnDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(this._shop.oopsPopup);
         this._shop.oopsPopup.visible = false;
      }
      
      private function onCostPopupClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(this._shop["oopsCostPopup" + this._appendString]);
         this._shop["oopsCostPopup" + this._appendString].visible = false;
      }
      
      private function addListeners() : void
      {
         if(Boolean(this._shopPopup))
         {
            this._shopPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         this._shop.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.pageCatalogHandler,false,0,true);
         this._shop.prevBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.pageCatalogHandler,false,0,true);
         this._shop.buyBtnGreen.addEventListener(MouseEvent.MOUSE_DOWN,this.buyBtnDownHandler,false,0,true);
         this._shop.buyBtnRed.addEventListener(MouseEvent.MOUSE_DOWN,this.buyBtnDownHandler,false,0,true);
         this._shop.buyPopup.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyPopupCloseBtnDown,false,0,true);
         this._shop.colorCycleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorBtnDown,false,0,true);
         this._shop.buyBigBtnGreen.addEventListener(MouseEvent.MOUSE_DOWN,this.buyBtnDownHandler,false,0,true);
         this._shop.buyBigBtnRed.addEventListener(MouseEvent.MOUSE_DOWN,this.buyBtnDownHandler,false,0,true);
         this._shop.buyBigPopup.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBigPopupCloseBtnDown,false,0,true);
         this._shop.buyBigPopupPreviewBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBigPopupPreviewBtnDown,false,0,true);
         this._shop.oopsPopup.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onOopsPopupCloseBtnDown,false,0,true);
         this._shop["oopsCostPopup" + this._appendString].bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCostPopupClose,false,0,true);
         this._shop.infoBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDiamondShopInfoBtn,false,0,true);
      }
      
      private function removeListeners() : void
      {
         if(Boolean(this._shopPopup))
         {
            this._shopPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         }
         this._shop.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.pageCatalogHandler);
         this._shop.prevBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.pageCatalogHandler);
         for(var i:int = 0; i < this.ITEMS_PER_SCREEN; i++)
         {
            this._shop["iw" + i].removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemWindowDown);
            this._shop["iw" + i].removeEventListener(MouseEvent.ROLL_OVER,this.onItemWindowRollOver);
            this._shop["iw" + i].removeEventListener(MouseEvent.ROLL_OUT,this.onItemWindowRollOut);
         }
         this._shop.buyBtnGreen.removeEventListener(MouseEvent.MOUSE_DOWN,this.buyBtnDownHandler);
         this._shop.buyBtnRed.removeEventListener(MouseEvent.MOUSE_DOWN,this.buyBtnDownHandler);
         this._shop.buyPopup.closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBuyPopupCloseBtnDown);
         this._shop.colorCycleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorBtnDown);
         this._shop.buyBigBtnGreen.removeEventListener(MouseEvent.MOUSE_DOWN,this.buyBtnDownHandler);
         this._shop.buyBigBtnRed.removeEventListener(MouseEvent.MOUSE_DOWN,this.buyBtnDownHandler);
         this._shop.buyBigPopup.closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBigPopupCloseBtnDown);
         this._shop.buyBigPopupPreviewBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBigPopupPreviewBtnDown);
         this._shop.oopsPopup.closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onOopsPopupCloseBtnDown);
         this._shop["oopsCostPopup" + this._appendString].bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCostPopupClose);
         this._shop.infoBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDiamondShopInfoBtn);
      }
   }
}

