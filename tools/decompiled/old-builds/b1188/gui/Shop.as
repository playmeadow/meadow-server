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
   import pet.PetManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import trade.TutorialPopups;
   
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
      
      public function init(param1:int, param2:int, param3:Avatar, param4:DisplayLayer, param5:Boolean = true, param6:Function = null, param7:int = 450, param8:int = 275, param9:int = 0, param10:Function = null, param11:Boolean = false, param12:int = -1) : SBPopup
      {
         var _loc15_:uint = 0;
         SBTracker.push();
         this._shopId = param1;
         this._glDefType = param2;
         this._playerAvatar = param3;
         this._popupLayer = param4;
         this._appendString = "";
         this._shop = GETDEFINITIONBYNAME("ShopContent");
         this._isMember = gMainFrame.userInfo.isMember;
         this._denRoomShopCallback = param10;
         this._isShopOnlyDen = param11;
         this._isInFFM = GuiManager.isInFFM;
         this._useStartupShopIndex = param12;
         this._showTutorial = this._shopId == GenericListXtCommManager.DEN_ITEM_FIRST_TIME_SHOP_ID;
         if(this._showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_SHOP_PREVIEW))
         {
            TutorialPopups.openTutorialTextPopup(18659,10,115);
         }
         this._denItemIdx = param9;
         this._spirals = new Array();
         var _loc13_:int = 0;
         while(_loc13_ < this.ITEMS_PER_SCREEN)
         {
            this._shop["iw" + _loc13_].lock.visible = false;
            this._shop["iw" + _loc13_].lockOpen.visible = false;
            this._shop["iw" + _loc13_].blueBG.visible = false;
            if(this._spirals[_loc13_])
            {
               this._spirals[_loc13_].destroy();
            }
            _loc13_++;
         }
         this._makePopup = param5;
         var _loc14_:MovieClip = GETDEFINITIONBYNAME("ShopSkin");
         if(this._makePopup)
         {
            this._shopPopup = new SBPopup(this._popupLayer,_loc14_,this._shop,true,true,false,false,true);
         }
         else
         {
            this._shopPopup = new SBPopup(this._popupLayer,_loc14_,this._shop,false,true,false,false,true);
         }
         this._closeCallback = param6;
         this._shopPopup.x = param7;
         this._shopPopup.y = param8;
         this._shopPopup.bxClosesPopup = false;
         this._shopPopup.visible = false;
         this._timeSeconds = new Date().valueOf() / 1000;
         if(!isNaN(gMainFrame.clientInfo.currentTimestamp))
         {
            _loc15_ = gMainFrame.clientInfo.currentTimestamp - this._timeSeconds;
         }
         else
         {
            _loc15_ = 0;
         }
         this._timeSeconds += _loc15_;
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
      
      public function set denItemIdx(param1:int) : void
      {
         this._denItemIdx = param1;
      }
      
      public function showShop(param1:Boolean) : void
      {
         if(this._shopPopup.visible != param1)
         {
            this._shopPopup.visible = param1;
            if(param1)
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
         var _loc1_:int = 0;
         while(_loc1_ < this.ITEMS_PER_SCREEN)
         {
            this._shop["iw" + _loc1_].tag.visible = !this._shop["iw" + _loc1_].tag.visible;
            this._shop["iw" + _loc1_].banner.visible = false;
            this._shop["iw" + _loc1_].newTag.visible = false;
            this._shop["iw" + _loc1_].saleTag.visible = false;
            this._shop["iw" + _loc1_].clearanceTag.visible = false;
            this._shop["iw" + _loc1_].daysLeftTag.visible = false;
            this._shop["iw" + _loc1_].itemNameTxt.visible = !this._shop["iw" + _loc1_].itemNameTxt.visible;
            this._shop["iw" + _loc1_].itemNameTxtMultiline.visible = !this._shop["iw" + _loc1_].itemNameTxtMultiline.visible;
            this._shop["iw" + _loc1_].ocean.visible = false;
            _loc1_++;
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
      
      private function setupDiamondItems(param1:Boolean) : void
      {
         if(param1)
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
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         SBTracker.pop();
         DenPreviewManager.setCurrentShop(null);
         this.removeListeners();
         if(this._shop.buyPopup.visible)
         {
            DarkenManager.unDarken(this._shop.buyPopup);
         }
         if(this._shop.buyBigPopup.visible)
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
            _loc1_ = 0;
            while(_loc1_ < this._shopItemArray.length)
            {
               this._shopItemArray[_loc1_].destroy();
               _loc1_++;
            }
            this._shopItemArray.splice(0,this._shopItemArray.length);
         }
         this._shopItemArray = null;
         if(Boolean(this._spirals) && this._spirals.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < this._spirals.length)
            {
               this._spirals[_loc2_].destroy();
               _loc2_++;
            }
            this._spirals.splice(0,this._spirals.length);
         }
         TutorialPopups.closeTutorialTextPopup();
         this._spirals = null;
         this._closeCallback = null;
      }
      
      public function setOnPurchaseSuccessCallback(param1:Function) : void
      {
         this._onPurchaseSuccessCallback = param1;
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
      
      public function gotItemListCallback(param1:Array, param2:String, param3:Array = null) : void
      {
         if(param2 != "")
         {
            LocalizationManager.translateId(this._shop.titleTxt,int(param2));
            LocalizationManager.translateId(this._shop.titleTxtDiamond,int(param2));
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
         this._pageURI += param2 + "/page";
         this._unfilteredItemArray = param1;
         this._unfilteredColorsArray = param3;
         this.filterItemLists();
      }
      
      public function filterItemLists() : void
      {
         if(GenericListXtCommManager.isAvailListExpired())
         {
            GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVAIL_LIST_ID,this.filterItemLists);
            return;
         }
         this._shopItemArray = this._unfilteredItemArray.concat();
         if(this._unfilteredColorsArray)
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
         this.initialShopSetup();
      }
      
      public function getCurrentItemDefId() : int
      {
         var _loc3_:Object = null;
         var _loc1_:Object = this._shopItemArray[this._itemIdx];
         var _loc2_:int = int(_loc1_.itemDefId);
         if(this._isDiamondStore)
         {
            _loc3_ = DiamondXtCommManager.getDiamondDef(_loc1_.diamondDefId);
            if(_loc3_)
            {
               _loc2_ = int(_loc3_.refDefId);
            }
         }
         return _loc2_;
      }
      
      public function get isDiamondStore() : Boolean
      {
         return this._isDiamondStore;
      }
      
      private function initialShopSetup() : void
      {
         DarkenManager.showLoadingSpiral(false);
         this._shopPopup.visible = true;
         if(this._shopItemArray)
         {
            this._numItems = this._shopItemArray.length;
         }
         else
         {
            this._numItems = 0;
         }
         if(this._numItems > 0)
         {
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
            else if(this._shopItemArray[0].currencyType == Item.CRYSTAL_CURRENCY)
            {
               this._myCurrencyCount = QuestManager.getPlayerCrystalCount();
               this._shop.currency.gotoAndStop("earth");
            }
            else if(this._shopItemArray[0].currencyType == Item.DIAMOND_CURRENCY)
            {
               this._myCurrencyCount = gMainFrame.clientInfo.diamondCount;
               this._shop.currency.gotoAndStop("diamonds");
               this._shopPopup.skin.s.gotoAndStop("diamond");
               this._shopPopup.bringContentToFront();
               this.setupDiamondItems(true);
            }
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
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         var _loc5_:Object = null;
         var _loc6_:Matrix = null;
         var _loc1_:int = int(this._itemOffset / this.ITEMS_PER_SCREEN) + 1;
         if(this._lastPage != _loc1_)
         {
            SBTracker.trackPageview(this._pageURI + _loc1_);
            this._lastPage = _loc1_;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.ITEMS_PER_SCREEN)
         {
            _loc3_ = this._shopItemArray[_loc2_ + this._itemOffset];
            _loc4_ = this._shop["iw" + _loc2_];
            while(_loc4_.itemLayer.numChildren > 1)
            {
               _loc4_.itemLayer.removeChildAt(1);
            }
            _loc4_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemWindowDown);
            _loc4_.removeEventListener(MouseEvent.ROLL_OVER,this.onItemWindowRollOver);
            _loc4_.removeEventListener(MouseEvent.ROLL_OUT,this.onItemWindowRollOut);
            if(_loc3_)
            {
               _loc5_ = _loc3_;
               if(!(_loc3_ is DenItem) && !(_loc3_.icon is AvatarView) && !(_loc3_.icon is GuiPet))
               {
                  _loc5_.icon.filters = [new GlowFilter(this.GLOW_FILTER_COLOR,this.GLOW_FILTER_ALPHA,2,2,4)];
               }
               if(_loc3_.hasOwnProperty("icon"))
               {
                  if(_loc3_.icon is AvatarView)
                  {
                     _loc6_ = _loc3_.icon.transform.matrix;
                     if(_loc6_.a != -1)
                     {
                        _loc6_.scale(-1,1);
                        _loc3_.icon.transform.matrix = _loc6_;
                     }
                  }
                  _loc4_.itemLayer.addChild(_loc5_.icon);
               }
               else
               {
                  _loc4_.itemLayer.addChild(_loc5_);
               }
               this._spirals[_loc2_] = new LoadingSpiral(_loc4_.itemLayer);
               if(Boolean(this._shopItemArray[_loc2_].hasOwnProperty("isIconLoaded")) && !this._shopItemArray[_loc2_].isIconLoaded)
               {
                  this._shopItemArray[_loc2_].imageLoadedCallback = this._spirals[_loc2_].destroy;
               }
               else
               {
                  this._spirals[_loc2_].destroy();
               }
               _loc4_.tag.txt.text = Utility.convertNumberToString(_loc5_.value);
               if(this._myCurrencyCount >= _loc5_.value)
               {
                  if(_loc5_.currencyType == Item.GEM_CURRENCY)
                  {
                     if(_loc4_.tag.currentFrameLabel != "green")
                     {
                        _loc4_.tag.gotoAndPlay("green");
                     }
                  }
                  else if(_loc5_.currencyType == Item.TICKET_CURRENCY)
                  {
                     if(_loc4_.tag.currentFrameLabel != "ticketGreen")
                     {
                        _loc4_.tag.gotoAndPlay("ticketGreen");
                     }
                  }
                  else if(_loc5_.currencyType == Item.CRYSTAL_CURRENCY)
                  {
                     if(_loc4_.tag.currentFrameLabel != "earthGreen")
                     {
                        _loc4_.tag.gotoAndPlay("earthGreen");
                     }
                  }
                  else if(_loc5_.currencyType == Item.DIAMOND_CURRENCY)
                  {
                     if(_loc4_.tag.currentFrameLabel != "diamondGreen")
                     {
                        _loc4_.tag.gotoAndPlay("diamondGreen");
                     }
                  }
                  _loc4_.tag.txt.textColor = "0x386630";
               }
               else
               {
                  if(_loc5_.currencyType == Item.GEM_CURRENCY)
                  {
                     if(_loc4_.tag.currentFrameLabel != "red")
                     {
                        _loc4_.tag.gotoAndPlay("red");
                     }
                  }
                  else if(_loc5_.currencyType == Item.TICKET_CURRENCY)
                  {
                     if(_loc4_.tag.currentFrameLabel != "ticketRed")
                     {
                        _loc4_.tag.gotoAndPlay("ticketRed");
                     }
                  }
                  else if(_loc5_.currencyType == Item.CRYSTAL_CURRENCY)
                  {
                     if(_loc4_.tag.currentFrameLabel != "earthRed")
                     {
                        _loc4_.tag.gotoAndPlay("earthRed");
                     }
                  }
                  else if(_loc5_.currencyType == Item.DIAMOND_CURRENCY)
                  {
                     if(_loc4_.tag.currentFrameLabel != "diamondRed")
                     {
                        _loc4_.tag.gotoAndPlay("diamondRed");
                     }
                  }
                  _loc4_.tag.txt.textColor = "0x800000";
               }
               _loc4_.tag.visible = true;
               LocalizationManager.updateToFit(_loc4_.itemNameTxt,_loc5_.name);
               if(_loc3_.isMemberOnly)
               {
                  _loc4_.banner.visible = true;
                  LocalizationManager.translateId(_loc4_.banner.txt,LocalizationManager.MEMBERS);
                  if(this._isMember)
                  {
                     _loc4_.lockOpen.visible = true;
                  }
                  else
                  {
                     _loc4_.lock.visible = true;
                  }
               }
               else
               {
                  _loc4_.banner.visible = false;
                  _loc4_.lock.visible = false;
                  _loc4_.lockOpen.visible = false;
               }
               if(_loc3_.isOcean)
               {
                  _loc4_.blueBG.visible = true;
                  _loc4_.greenBG.visible = false;
               }
               else
               {
                  _loc4_.greenBG.visible = true;
               }
               _loc4_.avtSpecific.visible = false;
               _loc4_.newTag.visible = _loc3_.isNew;
               _loc4_.clearanceTag.visible = _loc3_.isOnClearance;
               this.setupNumDaysLeft(_loc4_.daysLeftTag,_loc3_);
               _loc4_.rareTag.visible = _loc3_.isRare;
               _loc4_.saleTag.visible = _loc3_.isOnSale;
               _loc4_.ocean.visible = _loc3_.isOcean;
               _loc4_.addEventListener(MouseEvent.MOUSE_DOWN,this.onItemWindowDown,false,0,true);
               _loc4_.addEventListener(MouseEvent.ROLL_OVER,this.onItemWindowRollOver,false,0,true);
               _loc4_.addEventListener(MouseEvent.ROLL_OUT,this.onItemWindowRollOut,false,0,true);
            }
            else
            {
               _loc4_.tag.visible = false;
               _loc4_.tag.txt.text = "";
               _loc4_.itemNameTxt.text = "";
               _loc4_.itemNameTxtMultiline.text = "";
               _loc4_.banner.visible = false;
               _loc4_.lock.visible = false;
               _loc4_.lockOpen.visible = false;
               _loc4_.blueBG.visible = false;
               _loc4_.newTag.visible = false;
               _loc4_.clearanceTag.visible = false;
               _loc4_.saleTag.visible = false;
               _loc4_.ocean.visible = false;
               _loc4_.greenBG.visible = false;
               _loc4_.rareTag.visible = false;
               _loc4_.avtSpecific.visible = false;
               _loc4_.daysLeftTag.visible = false;
            }
            _loc4_.itemNameTxt.visible = false;
            _loc4_.itemNameTxtMultiline.visible = false;
            _loc2_++;
         }
      }
      
      private function setupNumDaysLeft(param1:MovieClip, param2:Object) : void
      {
         var _loc3_:int = 0;
         if(!param2.isRare && !param2.isNew && !param2.isOnSale)
         {
            _loc3_ = Math.ceil((param2.endTime - this._timeSeconds) / 60 / 60 / 24);
            if(_loc3_ > 0 && _loc3_ <= 10)
            {
               if(_loc3_ == 1)
               {
                  LocalizationManager.translateId(param1.txt,18061);
               }
               else
               {
                  LocalizationManager.translateIdAndInsert(param1.txt,6260,_loc3_);
               }
               param1.visible = true;
               MovieClip(param1.parent).clearanceTag.visible = false;
            }
            else
            {
               param1.visible = false;
            }
         }
         else
         {
            param1.visible = false;
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._shop.buyPopup.visible)
         {
            if(this._itemToBuy is DenItem && this._itemToBuy.sortId == DenItem.SORT_AUDIO)
            {
               RoomManagerWorld.instance.playPreviousMusic();
            }
            DarkenManager.unDarken(this._shop.buyPopup);
         }
         if(this._shop.buyBigPopup.visible)
         {
            DarkenManager.unDarken(this._shop.buyBigPopup);
         }
         this.applyAndClose();
         QuestManager.onShopClose();
         TutorialPopups.closeTutorialTextPopup();
      }
      
      private function buyBtnDownHandler(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc2_:Boolean = this._shopItemArray[this._itemIdx].isMemberOnly ? this._isMember : true;
         if(this._isDiamondStore && _loc2_)
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
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         var _loc1_:Object = this._shopItemArray[this._itemIdx];
         if(!this._isMember)
         {
            if(_loc1_.isMemberOnly)
            {
               if(_loc1_ is Item)
               {
                  UpsellManager.displayPopup(UpsellManager.ACCESSORIES,"buyAccessory/" + _loc1_.name);
                  return;
               }
               if(_loc1_ is DenItem)
               {
                  if(this._isDenAudioList)
                  {
                     UpsellManager.displayPopup(UpsellManager.DEN_AUDIO,"buyDenAudio/" + _loc1_.name);
                  }
                  else
                  {
                     UpsellManager.displayPopup(UpsellManager.DEN_ITEMS,"buyDenItem/" + _loc1_.name);
                  }
                  return;
               }
               if(_loc1_ is DenRoomItem)
               {
                  UpsellManager.displayPopup(UpsellManager.DENS,"buyDenRoom/" + _loc1_.name);
                  return;
               }
            }
         }
         if(_loc1_.value > this._myCurrencyCount)
         {
            if(this._isDiamondStore)
            {
               UpsellManager.displayPopup(UpsellManager.EXTRA_DIAMONDS_AS_MEMBER,"extraDiamonds");
            }
            else
            {
               DarkenManager.darken(this._shop["oopsCostPopup" + this._appendString]);
               if(_loc1_.currencyType == Item.GEM_CURRENCY)
               {
                  this._shop["oopsCostPopup" + this._appendString].currency.gotoAndStop("gems");
               }
               else if(_loc1_.currencyType == Item.TICKET_CURRENCY)
               {
                  this._shop["oopsCostPopup" + this._appendString].currency.gotoAndStop("tickets");
               }
               else if(_loc1_.currencyType == Item.CRYSTAL_CURRENCY)
               {
                  this._shop["oopsCostPopup" + this._appendString].currency.gotoAndStop("earth");
               }
               else if(_loc1_.currencyType == Item.DIAMOND_CURRENCY)
               {
                  this._shop["oopsCostPopup" + this._appendString].currency.gotoAndStop("diamonds");
               }
               this._shop["oopsCostPopup" + this._appendString].gemsTxt.text = this._myCurrencyCount;
               this._shop["oopsCostPopup" + this._appendString].costTxt.text = Utility.convertNumberToString(_loc1_.value);
               this._shop["oopsCostPopup" + this._appendString].needTxt.text = Utility.convertNumberToString(_loc1_.value - this._myCurrencyCount);
               this._shop["oopsCostPopup" + this._appendString].visible = true;
            }
         }
         else if(_loc1_ is Item)
         {
            if(this._playerAvatar.inventoryClothing.numItems < maxItems)
            {
               if(_loc1_.defId > 0)
               {
                  this.sendBuyRequest(_loc1_);
               }
            }
            else
            {
               if(AvatarManager.roomEnviroType == SbiConstants.ENVIRO_LAND)
               {
                  _loc2_ = RecycleItems.RECYCLE_ACCESSORIES_LAND_ONLY;
               }
               else
               {
                  _loc2_ = RecycleItems.RECYCLE_ACCESSORIES_OCEAN_ONLY;
               }
               new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdOnly(14746),true,this.confirmRecycleHandler,_loc2_);
            }
         }
         else if(_loc1_ is DenItem)
         {
            if(_loc1_.sortId == DenItem.SORT_AUDIO)
            {
               if(Utility.numDenItemsInList(this._playerAvatar.inventoryDenFull.itemArray,-1,true) < maxAudioItems)
               {
                  this.sendBuyRequest(_loc1_);
               }
               else
               {
                  _loc2_ = RecycleItems.RECYCLE_DEN_AUDIO;
                  _loc3_ = true;
               }
            }
            else if(Utility.numDenItemsInList(this._playerAvatar.inventoryDenPartial.itemArray,-1) < maxDenItems)
            {
               this.sendBuyRequest(_loc1_);
            }
            else
            {
               if(AvatarManager.roomEnviroType == SbiConstants.ENVIRO_LAND)
               {
                  _loc2_ = RecycleItems.RECYCLE_DEN_ITEMS_LAND_ONLY;
               }
               else
               {
                  _loc2_ = RecycleItems.RECYCLE_DEN_ITEMS_OCEAN_ONLY;
               }
               _loc3_ = true;
            }
            if(_loc3_)
            {
               new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdOnly(14746),true,this.confirmRecycleHandler,_loc2_);
            }
         }
         else if(_loc1_ is DenRoomItem)
         {
            if(this._denItemIdx < 1)
            {
               this._denItemIdx = DenSwitch.nextFreeSlotIdx;
            }
            if(!DenSwitch.denList[this._denItemIdx] && this._denItemIdx < SwitchManager.NUM_DEN_ROOM_SLOTS && this._denItemIdx > 0)
            {
               this.sendBuyRequest(_loc1_);
            }
            else
            {
               _loc2_ = DenSwitch.RECYCLE_DEN_ROOM;
               new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdOnly(14746),true,this.confirmRecycleHandler,_loc2_);
            }
         }
         else if(this._glDefType == DefPacksDefHelper.DEF_CURRENCY_EXCHANGE)
         {
            this.sendBuyRequest(_loc1_);
         }
      }
      
      private function sendBuyRequest(param1:Object) : void
      {
         if(this._showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,DEN_EDIT_TUTORIAL_SHOP_BUY))
         {
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,DEN_EDIT_TUTORIAL_SHOP_BUY);
            this._shop.buyBtnGreen.setButtonState(0);
         }
         if(param1 is Item)
         {
            ItemXtCommManager.requestItemBuy(this.confirmPurchase,this._shopId,this._isDiamondStore ? int(param1.diamondDefId) : int(param1.defId),this._itemColorIdx,this._isDiamondStore ? 1 : 0);
            ItemXtCommManager.setItemBuyIlCallback(this.putOnPurchasedItem);
         }
         else if(param1 is DenItem)
         {
            DenXtCommManager.requestBuy(true,this._shopId,this._isDiamondStore ? int(param1.diamondDefId) : int(param1.itemDefId),this.confirmPurchase,0,null,this._itemToBuy.version,this._isDiamondStore ? 1 : 0);
         }
         else if(param1 is DenRoomItem)
         {
            DenXtCommManager.requestBuy(false,this._shopId,param1.itemDefId,this.confirmPurchase,this._denItemIdx,this._denRoomShopCallback != null ? this._denRoomShopCallback : this.onDenPurchase,0,this._isDiamondStore ? 1 : 0);
         }
         else if(this._glDefType == DefPacksDefHelper.DEF_CURRENCY_EXCHANGE)
         {
            ItemXtCommManager.requestCurrencyExchange(this._shopId,param1.itemDefId,this.confirmPurchase);
         }
         DarkenManager.showLoadingSpiral(true);
      }
      
      private function pageCatalogHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == this._shop.nextBtn.name && this._numItems > this.ITEMS_PER_SCREEN)
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
            else if(param1.currentTarget.name == this._shop.prevBtn.name && this._numItems > this.ITEMS_PER_SCREEN)
            {
               if(this._itemOffset == 0)
               {
                  _loc2_ = this._numItems % this.ITEMS_PER_SCREEN;
                  if(_loc2_ != 0)
                  {
                     this._itemOffset = this._numItems - _loc2_;
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
      
      private function okBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function confirmFullInventoryHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         this.onClose(null);
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1.status)
         {
            _loc2_ = int(param1.passback);
            if(_loc2_ == DenSwitch.RECYCLE_DEN_ROOM)
            {
               GuiManager.openDenRoomSwitcher(true,this.onDenRoomRecycleClose,false,-1,this._shopId);
            }
            else
            {
               this._recyclePopup = new RecycleItems();
               this._recyclePopup.init(_loc2_,this._popupLayer,true,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5,true);
            }
         }
         else
         {
            this.onClose(null);
         }
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(this._recyclePopup)
         {
            this._recyclePopup.destroy();
            this._recyclePopup = null;
         }
      }
      
      private function onDenRoomRecycleClose(param1:Boolean = false) : void
      {
         GuiManager.onDenSwitchClose(param1);
         DenPreviewManager.exitPreview();
      }
      
      private function onItemNoLongerAvailable(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._itemNotAvailPopup)
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
      
      private function confirmPurchase(param1:int, param2:int = 0) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(param1 == 1)
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
            this._myCurrencyCount = param2;
            this._shop.myGemCountTxt.text = Utility.convertNumberToString(this._myCurrencyCount);
            if(this._itemToBuy is Item && this._playerAvatar.inventoryClothing.numItems >= warningItemCount)
            {
               new SBOkPopup(this._popupLayer,this.getWarningText(this._playerAvatar.inventoryClothing.numItems,maxItems));
            }
            else if(this._itemToBuy is DenItem)
            {
               if(this._itemToBuy.sortId == DenItem.SORT_AUDIO)
               {
                  _loc3_ = Utility.numDenItemsInList(this._playerAvatar.inventoryDenFull.itemArray,-1,true);
                  if(_loc3_ >= warningAudioItemCount)
                  {
                     new SBOkPopup(this._popupLayer,this.getWarningText(_loc3_,maxAudioItems));
                  }
               }
               else
               {
                  _loc4_ = Utility.numDenItemsInList(this._playerAvatar.inventoryDenPartial.itemArray,-1);
                  if(_loc4_ >= warningDenItemCount)
                  {
                     new SBOkPopup(this._popupLayer,this.getWarningText(_loc4_,maxDenItems));
                  }
               }
            }
            else if(this._itemToBuy is DenRoomItem)
            {
               _loc5_ = DenSwitch.numDens;
               if(_loc5_ >= warningDenRoomCount)
               {
                  new SBOkPopup(this._popupLayer,this.getWarningText(_loc5_,SwitchManager.NUM_DEN_ROOM_SLOTS));
               }
            }
            this.setupShopWindows();
         }
         else
         {
            if(param1 == -1)
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
         var _loc5_:Item = null;
         var _loc1_:int = int(this._shopItemArray[this._itemIdx].layerId);
         var _loc2_:Array = this._playerAvatar.inventoryClothing.itemArray;
         var _loc3_:int = int(_loc2_[0].invIdx);
         var _loc4_:int = -1;
         for each(_loc5_ in _loc2_)
         {
            if(_loc5_.getInUse(this._playerAvatar.perUserAvId) && _loc5_.layerId == _loc1_ && _loc5_.invIdx != _loc3_)
            {
               _loc4_ = _loc5_.invIdx;
               break;
            }
         }
         if(this._shopItemArray[this._itemIdx].enviroType == AvatarManager.roomEnviroType)
         {
            ItemXtCommManager.requestItemUse(null,[_loc3_],_loc4_ != -1 ? [_loc4_] : []);
            ItemXtCommManager.setItemBuyIlCallback(null);
         }
         if(this._onPurchaseSuccessCallback != null)
         {
            this._onPurchaseSuccessCallback();
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
            if(param1.currentTarget.name == this._shop.iw0.name)
            {
               _loc3_ = 0;
            }
            else if(param1.currentTarget.name == this._shop.iw1.name)
            {
               _loc3_ = 1;
            }
            else if(param1.currentTarget.name == this._shop.iw2.name)
            {
               _loc3_ = 2;
            }
            else if(param1.currentTarget.name == this._shop.iw3.name)
            {
               _loc3_ = 3;
            }
            else if(param1.currentTarget.name == this._shop.iw4.name)
            {
               _loc3_ = 4;
            }
            else if(param1.currentTarget.name == this._shop.iw5.name)
            {
               _loc3_ = 5;
            }
            this._itemIdx = _loc3_ + this._itemOffset;
         }
         else
         {
            this._itemIdx = this._useStartupShopIndex;
         }
         var _loc2_:Object = this._shopItemArray[this._itemIdx];
         if(!_loc2_)
         {
            return;
         }
         if(Boolean(_loc2_ is Item) && Boolean(this._itemColorsArray) && this._itemColorsArray[this._itemIdx].length > 1)
         {
            _loc2_.color = this._itemColorsArray[this._itemIdx][this._itemColorIdx];
            this._shop.colorCycleBtn.visible = !this._isInFFM;
            this._shop.colorCycleFlash.visible = !this._isInFFM;
         }
         else if(_loc2_ is DenItem)
         {
            if(Boolean(_loc2_.getVersions()) && _loc2_.getVersions().length > 0)
            {
               this._denItemColorsArray = _loc2_.getVersions();
               _loc2_.setVersion(this._denItemColorsArray[this._itemColorIdx]);
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
         if(this._shopId == GenericListXtCommManager.DEN_ROOM_SHOP_ID || _loc2_ is DenRoomItem)
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
      
      private function onItemWindowRollOver(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == this._shop.iw0.name)
         {
            _loc2_ = 0;
         }
         else if(param1.currentTarget.name == this._shop.iw1.name)
         {
            _loc2_ = 1;
         }
         else if(param1.currentTarget.name == this._shop.iw2.name)
         {
            _loc2_ = 2;
         }
         else if(param1.currentTarget.name == this._shop.iw3.name)
         {
            _loc2_ = 3;
         }
         else if(param1.currentTarget.name == this._shop.iw4.name)
         {
            _loc2_ = 4;
         }
         else if(param1.currentTarget.name == this._shop.iw5.name)
         {
            _loc2_ = 5;
         }
         if(this._shop["iw" + _loc2_].currentFrameLabel != "mouse")
         {
            this._shop["iw" + _loc2_].gotoAndPlay("mouse");
         }
         if(this._shop["iw" + _loc2_].itemNameTxt.text == this._shop["iw" + _loc2_].itemNameTxtMultiline.text)
         {
            this._shop["iw" + _loc2_].mouse0.gotoAndStop("multi");
            this._shop["iw" + _loc2_].itemNameTxtMultiline.visible = true;
         }
         else
         {
            this._shop["iw" + _loc2_].mouse0.gotoAndStop("single");
            this._shop["iw" + _loc2_].itemNameTxt.visible = true;
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowRollOut(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == this._shop.iw0.name)
         {
            _loc2_ = 0;
         }
         else if(param1.currentTarget.name == this._shop.iw1.name)
         {
            _loc2_ = 1;
         }
         else if(param1.currentTarget.name == this._shop.iw2.name)
         {
            _loc2_ = 2;
         }
         else if(param1.currentTarget.name == this._shop.iw3.name)
         {
            _loc2_ = 3;
         }
         else if(param1.currentTarget.name == this._shop.iw4.name)
         {
            _loc2_ = 4;
         }
         else if(param1.currentTarget.name == this._shop.iw5.name)
         {
            _loc2_ = 5;
         }
         if(this._shop["iw" + _loc2_].currentFrameLabel != "out")
         {
            this._shop["iw" + _loc2_].gotoAndPlay("out");
         }
         if(this._shop["iw" + _loc2_].itemNameTxt.text == this._shop["iw" + _loc2_].itemNameTxtMultiline.text)
         {
            this._shop["iw" + _loc2_].itemNameTxtMultiline.visible = false;
         }
         else
         {
            this._shop["iw" + _loc2_].itemNameTxt.visible = false;
         }
      }
      
      private function setupBuyPopup() : void
      {
         this._itemToBuy = this._shopItemArray[this._itemIdx];
         if(this._itemToBuy.icon is GuiPet)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId(this._itemToBuy.icon.idx),this.OnPetFinderClose,false,null,DiamondXtCommManager.getDiamondItem(this._itemToBuy.itemDefId),this._itemToBuy.currencytype,this._shopId);
            return;
         }
         if(this._itemToBuy.icon is AvatarView)
         {
            AvatarSwitch.addAvatar(AvatarSwitch.avatars.length,false,this.onAvatarAdded,false,this._itemToBuy.isOcean,false,this._itemToBuy.icon.avTypeId,true,this._shopId,this._itemToBuy.itemDefId);
            return;
         }
         this._itemToBuy = this._shopItemArray[this._itemIdx].clone();
         this._itemColorIdx = 0;
         if(this._itemToBuy.isMemberOnly)
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
         if(this._itemToBuy.isOcean)
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
            else if(this._itemToBuy.currencyType == Item.CRYSTAL_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "earthGreen")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("earthGreen");
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
            else if(this._itemToBuy.currencyType == Item.CRYSTAL_CURRENCY)
            {
               if(this._shop.buyPopup.tag.currentFrameLabel != "earthRed")
               {
                  this._shop.buyPopup.tag.gotoAndPlay("earthRed");
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
            TutorialPopups.openTutorialTextPopup(18660,10,115);
            this._shop.buyBtnGreen.gotoAndStop("new");
            this._shop.buyBtnGreen.setButtonState(2);
         }
         else
         {
            this._shop.buyBtnGreen.setButtonState(1);
         }
      }
      
      private function setupBigBuyPopup() : void
      {
         var _loc1_:Object = this._shopItemArray[this._itemIdx].clone();
         this._itemColorIdx = 0;
         if(_loc1_.isMemberOnly)
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
         if(_loc1_.isOcean)
         {
            this._shop.buyBigPopup.buyGreenBG.visible = false;
         }
         else
         {
            this._shop.buyBigPopup.buyGreenBG.visible = true;
         }
         this._shop.buyBigPopup.avtSpecificIcon.visible = false;
         this._shop.buyBigPopup.newTag.visible = _loc1_.isNew;
         this._shop.buyBigPopup.clearanceTag.visible = _loc1_.isOnClearance;
         this.setupNumDaysLeft(this._shop.buyBigPopup.daysLeftTag,_loc1_);
         this._shop.buyBigPopup.saleTag.visible = _loc1_.isOnSale;
         this._shop.buyBigPopup.rareTag.visible = _loc1_.isRare;
         if(this._shop.buyBigPopup.itemLayer.numChildren > 1)
         {
            this._shop.buyBigPopup.itemLayer.removeChildAt(1);
         }
         if(!(_loc1_ is DenItem))
         {
            _loc1_.largeIcon.filters = [new GlowFilter(this.GLOW_FILTER_COLOR,this.GLOW_FILTER_ALPHA,2,2,8)];
         }
         this._shop.buyBigPopup.itemLayer.addChild(_loc1_.largeIcon);
         this._shop.buyBigPopup.tag.txt.text = Utility.convertNumberToString(_loc1_.value);
         if(this._myCurrencyCount >= _loc1_.value)
         {
            if(_loc1_.currencyType == Item.GEM_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "green")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("green");
               }
            }
            else if(_loc1_.currencyType == Item.TICKET_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "ticketGreen")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("ticketGreen");
               }
            }
            else if(_loc1_.currencyType == Item.CRYSTAL_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "earthGreen")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("earthGreen");
               }
            }
            else if(_loc1_.currencyType == Item.DIAMOND_CURRENCY)
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
            if(_loc1_.currencyType == Item.GEM_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "red")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("red");
               }
            }
            else if(_loc1_.currencyType == Item.TICKET_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "ticketRed")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("ticketRed");
               }
            }
            else if(_loc1_.currencyType == Item.CRYSTAL_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "earthRed")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("earthRed");
               }
            }
            else if(_loc1_.currencyType == Item.DIAMOND_CURRENCY)
            {
               if(this._shop.buyBigPopup.tag.currentFrameLabel != "diamondRed")
               {
                  this._shop.buyBigPopup.tag.gotoAndPlay("diamondRed");
               }
            }
            this._shop.buyBigPopup.tag.txt.textColor = "0x800000";
            this._shop.buyBigBtnGreen.visible = false;
         }
         LocalizationManager.updateToFit(this._shop.buyBigPopupItemNameTxt,_loc1_.name);
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
         else if(this._shopItemArray[0].currencyType == Item.CRYSTAL_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.crystalCount;
         }
         else if(this._shopItemArray[0].currencyType == Item.DIAMOND_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.diamondCount;
         }
         this._shop.myGemCountTxt.text = Utility.convertNumberToString(this._myCurrencyCount);
         this.setupShopWindows();
      }
      
      private function onAvatarAdded(param1:int) : void
      {
         if(param1 == 1)
         {
            this.OnPetFinderClose();
            return;
         }
         if(param1 == -1)
         {
            LocalizationManager.translateIdAndInsert(this._shop.oopsPopup.body_txt,11382,this._itemToBuy.name.toLowerCase());
         }
         else
         {
            LocalizationManager.translateId(this._shop.oopsPopup.body_txt,11225);
         }
         this._shop.oopsPopup.visible = true;
      }
      
      private function onColorBtnDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(this._isMember)
         {
            if(this._itemToBuy is Item && Boolean(this._itemColorsArray))
            {
               if(this._itemColorsArray[this._itemIdx][this._itemColorIdx + 1] != null)
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
               _loc2_ = this._shopItemArray[this._itemIdx].clone();
               _loc2_.color = this._itemColorsArray[this._itemIdx][this._itemColorIdx];
               if(!(_loc2_ is DenItem))
               {
                  _loc2_.largeIcon.filters = [new GlowFilter(this.GLOW_FILTER_COLOR,this.GLOW_FILTER_ALPHA,2,2,8)];
               }
               this._shop.buyPopup.itemLayer.addChild(_loc2_.largeIcon);
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
      
      private function onBuyPopupCloseBtnDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
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
         TutorialPopups.closeTutorialTextPopup();
         this._itemColorIdx = 0;
      }
      
      private function onDiamondShopInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openDiamondShopInfo();
      }
      
      private function onInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._isInfoOpen)
         {
            new GTween(param1.currentTarget.parent,0.5,{"x":param1.currentTarget.parent.x - 185},{
               "ease":TweenManager.quadratic,
               "onComplete":this.sideMenuComplete
            });
            this._isInfoOpen = false;
            AJAudio.playBuddyCardClose();
         }
         else
         {
            new GTween(param1.currentTarget.parent,0.5,{"x":param1.currentTarget.parent.x + 185},{
               "ease":TweenManager.quadratic,
               "onComplete":this.sideMenuComplete
            });
            this._isInfoOpen = true;
            AJAudio.playBuddyCardOpen();
         }
         this._infoTweenFinished = false;
      }
      
      private function sideMenuComplete(param1:GTween) : void
      {
         this._infoTweenFinished = true;
      }
      
      private function onBuyBigPopupCloseBtnDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.unDarken(this._shop.buyBigPopup);
         this._shop.buyBigPopup.visible = false;
         this._denItemIdx = 0;
         if(this._shop.buyBigPopup.itemLayer.numChildren > 1)
         {
            this._shop.buyBigPopup.itemLayer.removeChildAt(1);
         }
      }
      
      private function onBuyBigPopupPreviewBtnDown(param1:MouseEvent) : void
      {
         var _loc5_:Object = null;
         param1.stopPropagation();
         var _loc2_:Object = this._shopItemArray[this._itemIdx];
         var _loc3_:int = int(_loc2_.itemDefId);
         if(this._isDiamondStore)
         {
            _loc5_ = DiamondXtCommManager.getDiamondDef(_loc2_.diamondDefId);
            if(_loc5_)
            {
               _loc3_ = int(_loc5_.refDefId);
            }
         }
         var _loc4_:Object = gMainFrame.userInfo.denRoomDefs[_loc3_];
         if(_loc4_)
         {
            if(Utility.isSameEnviroType(AvatarManager.playerAvatar.enviroTypeFlag,_loc2_.enviroType))
            {
               DarkenManager.unDarken(this._shop.buyBigPopup);
               RoomManagerWorld.instance.loadDenPreviewRoom(_loc4_.xRoomName,_loc2_.enviroType);
            }
            else
            {
               new SBOkPopup(this._popupLayer,LocalizationManager.translateIdOnly(18903));
            }
         }
      }
      
      private function onOopsPopupCloseBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(this._shop.oopsPopup);
         this._shop.oopsPopup.visible = false;
      }
      
      private function onCostPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(this._shop["oopsCostPopup" + this._appendString]);
         this._shop["oopsCostPopup" + this._appendString].visible = false;
      }
      
      private function addListeners() : void
      {
         if(this._shopPopup)
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
         if(this._shopPopup)
         {
            this._shopPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         }
         this._shop.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.pageCatalogHandler);
         this._shop.prevBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.pageCatalogHandler);
         var _loc1_:int = 0;
         while(_loc1_ < this.ITEMS_PER_SCREEN)
         {
            this._shop["iw" + _loc1_].removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemWindowDown);
            this._shop["iw" + _loc1_].removeEventListener(MouseEvent.ROLL_OVER,this.onItemWindowRollOver);
            this._shop["iw" + _loc1_].removeEventListener(MouseEvent.ROLL_OUT,this.onItemWindowRollOut);
            _loc1_++;
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

