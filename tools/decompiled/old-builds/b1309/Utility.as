package
{
   import avatar.NameBar;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.Utils;
   import currency.UserCurrency;
   import den.DenItem;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Matrix;
   import flash.globalization.Collator;
   import flash.globalization.NumberFormatter;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gui.GuiManager;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class Utility
   {
      
      private static const AUDIO_TYPE:int = 4;
      
      private static const NOT_ENOUGH_GEMS_POPUP_ID:int = 1245;
      
      private static const DIAMOND_REFUND_POPUP_ID:int = 4437;
      
      private static var _notEnoughGemsPopup:MovieClip;
      
      private static var _diamondRefundPopup:MovieClip;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _showLoadingSpiral:Function;
      
      private static var _darken:Function;
      
      private static var _undarken:Function;
      
      private static var _levelShapeHelper:MediaHelper;
      
      private static var _shapesMediaHelperArray:Array;
      
      private static var _timeOffset:Number;
      
      public function Utility()
      {
         super();
      }
      
      public static function init(param1:Function, param2:Function, param3:Function) : void
      {
         _showLoadingSpiral = param1;
         _darken = param2;
         _undarken = param3;
         if(!isNaN(gMainFrame.clientInfo.currentTimestamp))
         {
            _timeOffset = gMainFrame.clientInfo.currentTimestamp - new Date().valueOf() / 1000;
         }
         else
         {
            _timeOffset = 0;
         }
      }
      
      public static function getTimeOffset() : Number
      {
         return _timeOffset;
      }
      
      public static function getCurrEpochTime() : Number
      {
         return new Date().valueOf() / 1000 + _timeOffset;
      }
      
      public static function isLand(param1:int) : Boolean
      {
         return (param1 & 1) == 1;
      }
      
      public static function isOcean(param1:int) : Boolean
      {
         return (param1 >> 1 & 1) == 1;
      }
      
      public static function isAir(param1:int) : Boolean
      {
         return (param1 >> 2 & 1) == 1;
      }
      
      public static function isSameEnviroType(param1:int, param2:int) : Boolean
      {
         if(param2 == 0)
         {
            return isLand(param1);
         }
         if(param2 == 2)
         {
            return isAir(param1);
         }
         return isOcean(param1);
      }
      
      public static function isRoomOfThisType(param1:int) : Boolean
      {
         return gMainFrame.clientInfo.roomType == param1;
      }
      
      public static function sortItems(param1:Object, param2:int, param3:int, param4:int = -1, param5:int = -1, param6:Boolean = false) : Object
      {
         if(param1 is Array)
         {
            return doArraySort(param1 as Array,param2,param3,param4,param5,param6);
         }
         if(param1 is DenItemCollection)
         {
            return doCollectionDenItemSort(param1 as DenItemCollection,param2,param3,param4,param5,param6);
         }
         if(param1 is AccItemCollection)
         {
            return doCollectionItemSort(param1 as AccItemCollection,param2,param3,param4,param5,param6);
         }
         throw new Error("Trying to sort with an unknown type");
      }
      
      private static function doArraySort(param1:Array, param2:int, param3:int, param4:int = -1, param5:int = -1, param6:Boolean = false) : Array
      {
         var _loc12_:Array = null;
         var _loc7_:Object = null;
         var _loc10_:int = 0;
         var _loc13_:Array = param1.concat();
         _loc12_ = [];
         var _loc8_:int = param2;
         var _loc9_:int = 0;
         var _loc11_:int = -1;
         var _loc14_:int = int(_loc13_.length);
         while(_loc8_ < _loc14_)
         {
            _loc7_ = _loc13_[_loc8_];
            if(_loc7_ is Item)
            {
               _loc10_ = int(_loc7_.layerId);
            }
            else
            {
               _loc10_ = int(_loc7_.typeCatId);
            }
            if(_loc7_.isOcean)
            {
               if(_loc11_ == -1)
               {
                  _loc11_ = convertOceanSortId(param3);
               }
               if(_loc10_ == _loc11_)
               {
                  if(param6)
                  {
                     _loc12_[_loc9_] = _loc13_[_loc8_].clone();
                  }
                  else
                  {
                     _loc12_[_loc9_] = _loc13_[_loc8_];
                  }
                  _loc9_++;
               }
            }
            else if(_loc10_ == param3 || _loc10_ == param4 || _loc10_ == param5)
            {
               if(param6)
               {
                  _loc12_[_loc9_] = _loc13_[_loc8_].clone();
               }
               else
               {
                  _loc12_[_loc9_] = _loc13_[_loc8_];
               }
               _loc9_++;
            }
            _loc8_++;
         }
         return _loc12_;
      }
      
      private static function doCollectionItemSort(param1:AccItemCollection, param2:int, param3:int, param4:int = -1, param5:int = -1, param6:Boolean = false) : AccItemCollection
      {
         var _loc13_:Item = null;
         var _loc9_:int = 0;
         var _loc12_:AccItemCollection = new AccItemCollection(param1.concatCollection(null));
         var _loc10_:AccItemCollection = new AccItemCollection();
         var _loc7_:int = param2;
         var _loc8_:int = 0;
         var _loc11_:int = -1;
         var _loc14_:int = int(_loc12_.length);
         while(_loc7_ < _loc14_)
         {
            _loc13_ = _loc12_.getAccItem(_loc7_);
            _loc9_ = _loc13_.layerId;
            if(_loc13_.isOcean)
            {
               if(_loc11_ == -1)
               {
                  _loc11_ = convertOceanSortId(param3);
               }
               if(_loc9_ == _loc11_)
               {
                  if(param6)
                  {
                     _loc10_.setAccItem(_loc8_,_loc12_.getAccItem(_loc7_).clone() as Item);
                  }
                  else
                  {
                     _loc10_.setAccItem(_loc8_,_loc12_.getAccItem(_loc7_));
                  }
                  _loc8_++;
               }
            }
            else if(_loc9_ == param3 || _loc9_ == param4 || _loc9_ == param5)
            {
               if(param6)
               {
                  _loc10_.setAccItem(_loc8_,_loc12_.getAccItem(_loc7_).clone() as Item);
               }
               else
               {
                  _loc10_.setAccItem(_loc8_,_loc12_.getAccItem(_loc7_));
               }
               _loc8_++;
            }
            _loc7_++;
         }
         return _loc10_;
      }
      
      private static function doCollectionDenItemSort(param1:DenItemCollection, param2:int, param3:int, param4:int = -1, param5:int = -1, param6:Boolean = false) : DenItemCollection
      {
         var _loc12_:DenItem = null;
         var _loc9_:int = 0;
         var _loc13_:DenItemCollection = new DenItemCollection(param1.concatCollection(null));
         var _loc10_:DenItemCollection = new DenItemCollection();
         var _loc7_:int = param2;
         var _loc8_:int = 0;
         var _loc11_:int = -1;
         var _loc14_:int = int(_loc13_.length);
         while(_loc7_ < _loc14_)
         {
            _loc12_ = _loc13_.getDenItem(_loc7_);
            _loc9_ = _loc12_.typeCatId;
            if(_loc12_.isOcean)
            {
               if(_loc11_ == -1)
               {
                  _loc11_ = convertOceanSortId(param3);
               }
               if(_loc9_ == _loc11_)
               {
                  if(param6)
                  {
                     _loc10_.setDenItem(_loc8_,_loc13_.getDenItem(_loc7_).clone() as DenItem);
                  }
                  else
                  {
                     _loc10_.setDenItem(_loc8_,_loc13_.getDenItem(_loc7_));
                  }
                  _loc8_++;
               }
            }
            else if(_loc9_ == param3 || _loc9_ == param4 || _loc9_ == param5)
            {
               if(param6)
               {
                  _loc10_.setDenItem(_loc8_,_loc13_.getDenItem(_loc7_).clone() as DenItem);
               }
               else
               {
                  _loc10_.setDenItem(_loc8_,_loc13_.getDenItem(_loc7_));
               }
               _loc8_++;
            }
            _loc7_++;
         }
         return _loc10_;
      }
      
      public static function sortItemsAll(param1:AccItemCollection, param2:int, param3:int, param4:int = -1, param5:int = -1) : AccItemCollection
      {
         return new AccItemCollection((sortItems(param1,param2,param3,param4,param5) as AccItemCollection).getCoreArray());
      }
      
      public static function sortByItem(param1:Object, param2:int) : Object
      {
         if(param1 is AccItemCollection)
         {
            (param1 as AccItemCollection).getCoreArray().concat().sortOn(param1,["accId","color"],0x10 | 2);
            return param1;
         }
         if(param1 is DenItemCollection)
         {
            (param1 as DenItemCollection).getCoreArray().concat().sortOn(param1,["sortId","defId","version"],16);
            return param1;
         }
         throw new Error("Unexpectd type for sortByItem");
      }
      
      private static function convertOceanSortId(param1:int) : int
      {
         switch(param1 - 5)
         {
            case 0:
               return 8;
            case 1:
               return 6;
            case 2:
               return 5;
            case 3:
            case 4:
            case 5:
               return 7;
            default:
               return param1;
         }
      }
      
      public static function numDenItemsInList(param1:DenItemCollection, param2:int, param3:Boolean = false) : int
      {
         return int(denItemsInList(param1,param2,true,param3));
      }
      
      public static function denItemListByEnviroType(param1:DenItemCollection, param2:int, param3:Boolean = false) : DenItemCollection
      {
         return denItemsInList(param1,param2,false,param3) as DenItemCollection;
      }
      
      private static function denItemsInList(param1:DenItemCollection, param2:int, param3:Boolean = false, param4:Boolean = false) : Object
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:DenItemCollection = new DenItemCollection();
         if(param1)
         {
            _loc5_ = int(param1.length);
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(param4)
               {
                  if(param1.getDenItem(_loc6_).sortId == 4)
                  {
                     _loc7_.pushDenItem(param1.getDenItem(_loc6_));
                  }
               }
               else if(param1.getDenItem(_loc6_).sortId != 4)
               {
                  if(param2 == -1 || param1.getDenItem(_loc6_).enviroType == param2)
                  {
                     _loc7_.pushDenItem(param1.getDenItem(_loc6_));
                  }
               }
               _loc6_++;
            }
         }
         if(param3)
         {
            return _loc7_.length;
         }
         return _loc7_;
      }
      
      public static function numClothingItemsInList(param1:AccItemCollection, param2:int) : int
      {
         return int(clothingItemsInList(param1,param2,true));
      }
      
      public static function clothingItemListByEnviroType(param1:AccItemCollection, param2:int) : AccItemCollection
      {
         return clothingItemsInList(param1,param2,false) as AccItemCollection;
      }
      
      private static function clothingItemsInList(param1:AccItemCollection, param2:int, param3:Boolean = false) : Object
      {
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:AccItemCollection = new AccItemCollection();
         if(param1)
         {
            _loc6_ = int(param1.length);
            _loc4_ = 0;
            while(_loc4_ < _loc6_)
            {
               if(param1.getAccItem(_loc4_).enviroType == param2)
               {
                  _loc5_.pushAccItem(param1.getAccItem(_loc4_));
               }
               _loc4_++;
            }
         }
         if(param3)
         {
            return _loc5_.length;
         }
         return _loc5_;
      }
      
      public static function setupNotEnoughGemsPopup(param1:DisplayObjectContainer, param2:int, param3:int = 0, param4:Function = null) : void
      {
         if(_notEnoughGemsPopup)
         {
            _showLoadingSpiral(false);
            _notEnoughGemsPopup.x = 900 * 0.5;
            _notEnoughGemsPopup.y = 550 * 0.5;
            _notEnoughGemsPopup.earnGemsBtn.visible = false;
            if(param3 == 0)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("gems");
               _notEnoughGemsPopup.gemsTxt.text = UserCurrency.getCurrency(0);
               _notEnoughGemsPopup.earnGemsBtn.visible = true;
               _notEnoughGemsPopup.earnGemsBtn.addEventListener("mouseDown",onEarnGemsBtn,false,0,true);
            }
            else if(param3 == 1)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("tickets");
               _notEnoughGemsPopup.gemsTxt.text = UserCurrency.getCurrency(1);
            }
            else if(param3 == 2)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("earth");
               _notEnoughGemsPopup.gemsTxt.text = UserCurrency.getCurrency(2);
            }
            else if(param3 == 3)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("diamonds");
               _notEnoughGemsPopup.gemsTxt.text = UserCurrency.getCurrency(3);
            }
            _notEnoughGemsPopup.costTxt.text = param2;
            _notEnoughGemsPopup.needTxt.text = param2 - int(_notEnoughGemsPopup.gemsTxt.text);
            _notEnoughGemsPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
            _notEnoughGemsPopup.bx.addEventListener("mouseDown",onClose,false,0,true);
            _notEnoughGemsPopup.closeCallback = param4;
            param1.addChild(_notEnoughGemsPopup);
            _darken(_notEnoughGemsPopup);
         }
         else
         {
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(1245,onMediaItemLoaded,{
               "guiLayer":param1,
               "itemCost":param2,
               "currencyType":param3,
               "callback":param4
            });
         }
      }
      
      private static function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1.mediaHelper.id == 1245)
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/avatarSwitch/buyAnimal_notEnoughGems",-1,1);
            _notEnoughGemsPopup = MovieClip(param1.getChildAt(0));
            setupNotEnoughGemsPopup(param1.passback.guiLayer,param1.passback.itemCost,param1.passback.currencyType,param1.passback.callback);
         }
         else if(param1.mediaHelper.id == 4437)
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/privateParty/privatePartyDiamondRefund",-1,1);
            _diamondRefundPopup = MovieClip(param1.getChildAt(0));
            setupDiamondRefundPopup(param1.passback.guiLayer,param1.passback.refundAmount,param1.passback.callback);
         }
      }
      
      private static function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent == _notEnoughGemsPopup)
         {
            SBTracker.pop();
            _undarken(_notEnoughGemsPopup);
            _notEnoughGemsPopup.parent.removeChild(_notEnoughGemsPopup);
            if(_notEnoughGemsPopup.closeCallback != null)
            {
               _notEnoughGemsPopup.closeCallback();
               _notEnoughGemsPopup.closeCallback = null;
            }
         }
         else if(param1.currentTarget.parent == _diamondRefundPopup)
         {
            SBTracker.pop();
            _undarken(_diamondRefundPopup);
            _diamondRefundPopup.parent.removeChild(_diamondRefundPopup);
            if(_diamondRefundPopup.closeCallback != null)
            {
               _diamondRefundPopup.closeCallback();
               _diamondRefundPopup.closeCallback = null;
            }
            _diamondRefundPopup.removeEventListener("mouseDown",onPopupDown);
            _diamondRefundPopup.closeButton.removeEventListener("mouseDown",onClose);
            _diamondRefundPopup.okBtn.removeEventListener("mouseDown",onClose);
            _diamondRefundPopup = null;
         }
      }
      
      private static function onEarnGemsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openJoinGamesPopup();
         onClose(param1);
      }
      
      public static function setupDiamondRefundPopup(param1:DisplayLayer, param2:int, param3:Function) : void
      {
         if(_diamondRefundPopup)
         {
            _showLoadingSpiral(false);
            _diamondRefundPopup.x = 900 * 0.5;
            _diamondRefundPopup.y = 550 * 0.5;
            _diamondRefundPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
            _diamondRefundPopup.closeButton.addEventListener("mouseDown",onClose,false,0,true);
            _diamondRefundPopup.okBtn.addEventListener("mouseDown",onClose,false,0,true);
            _diamondRefundPopup.closeCallback = param3;
            _diamondRefundPopup.diamondTxt.text = "+" + param2;
            param1.addChild(_diamondRefundPopup);
            _darken(_diamondRefundPopup);
         }
         else
         {
            _showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(4437,onMediaItemLoaded,{
               "guiLayer":param1,
               "refundAmount":param2,
               "callback":param3
            });
         }
      }
      
      public static function canBuddy() : Boolean
      {
         return (gMainFrame.clientInfo.interactions & 1) == 1;
      }
      
      public static function canTrade() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 1 & 1) == 1;
      }
      
      public static function canGift() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 2 & 1) == 1;
      }
      
      public static function canChat() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 3 & 1) == 1;
      }
      
      public static function canJAG() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 4 & 1) == 1;
      }
      
      public static function canMultiplayer() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 5 & 1) == 1;
      }
      
      public static function canPVP() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 6 & 1) == 1;
      }
      
      public static function canQuest() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 7 & 1) == 1;
      }
      
      public static function canTradeNonDegraded() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 8 & 1) == 1;
      }
      
      public static function canGiftNonDegraded() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 9 & 1) == 1;
      }
      
      public static function toggleInteractionBit(param1:int) : void
      {
         gMainFrame.clientInfo.interactions ^= 1 << param1;
      }
      
      public static function calculatePrintTime(param1:int, param2:int, param3:Boolean = false, param4:int = 0) : String
      {
         var _loc5_:String = "";
         if(param2 > 0 || param4 > 0)
         {
            if(param1 == 0)
            {
               param3 = true;
            }
            if(param4 > 0)
            {
               if(param4 == 1)
               {
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(11118,param4).toLowerCase() + " ";
               }
               else
               {
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(11119,param4).toLowerCase() + " ";
               }
            }
            if(param3)
            {
               if(param2 == 1)
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11120,param2).toLowerCase();
               }
               else
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11121,param2).toLowerCase();
               }
               if(param1 == 1)
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11122,param1);
               }
               else if(param1 != 0)
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11123,param1);
               }
            }
            else
            {
               if(param2 == 1)
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11124,param2);
               }
               else
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11125,param2);
               }
               if(param1 == 1)
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11126,param1);
               }
               else if(param1 != 0)
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11127,param1);
               }
            }
         }
         else if(param1 == 1)
         {
            _loc5_ = LocalizationManager.translateIdAndInsertOnly(11128,param1);
         }
         else
         {
            _loc5_ = LocalizationManager.translateIdAndInsertOnly(11129,param1);
         }
         return _loc5_;
      }
      
      public static function calculatePrintTimeToNearest(param1:int, param2:int, param3:Boolean = false, param4:int = 0) : String
      {
         var _loc5_:String = "";
         if(param2 > 0 || param4 > 0)
         {
            if(param1 == 0)
            {
               param3 = true;
            }
            if(param4 > 0)
            {
               if(param4 == 1)
               {
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(11118,param4).toLowerCase();
               }
               else if(param4 > 30)
               {
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(23239,30);
               }
               else
               {
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(11119,param4).toLowerCase();
               }
               return _loc5_;
            }
            if(param3)
            {
               if(param2 == 1)
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11120,param2).toLowerCase();
               }
               else
               {
                  _loc5_ += LocalizationManager.translateIdAndInsertOnly(11121,param2).toLowerCase();
               }
               return _loc5_;
            }
            if(param2 == 1)
            {
               _loc5_ += LocalizationManager.translateIdAndInsertOnly(11124,param2);
            }
            else
            {
               _loc5_ += LocalizationManager.translateIdAndInsertOnly(11125,param2);
            }
            return _loc5_;
         }
         if(param1 == 0)
         {
            _loc5_ = LocalizationManager.translateIdOnly(23240);
         }
         else if(param1 == 1)
         {
            _loc5_ = LocalizationManager.translateIdAndInsertOnly(11128,param1);
         }
         else
         {
            _loc5_ = LocalizationManager.translateIdAndInsertOnly(11129,param1);
         }
         return _loc5_;
      }
      
      public static function calculatePrintTimeForCustomParties(param1:int) : String
      {
         if(param1 == 60)
         {
            return LocalizationManager.translateIdAndInsertOnly(24237,Math.ceil(param1 / 60));
         }
         return LocalizationManager.translateIdAndInsertOnly(24241,Math.ceil(param1 / 60));
      }
      
      public static function calculateTime(param1:int) : Object
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = 0;
         var _loc2_:Number = Math.round(param1 / 60);
         if(_loc2_ < 60)
         {
            _loc5_ = _loc2_;
            _loc3_ = 0;
         }
         else
         {
            _loc4_ = _loc2_ / 60;
            if(_loc4_ >= 24)
            {
               _loc6_ = _loc4_ / 24;
               _loc3_ = (_loc6_ - Math.floor(_loc6_)) * 24;
               _loc5_ = (_loc3_ - Math.floor(_loc3_)) * 60;
               _loc3_ = Math.floor(_loc3_);
               _loc6_ = int(_loc6_);
            }
            else
            {
               _loc3_ = Math.floor(_loc4_);
               _loc5_ = Math.ceil((_loc4_ - Math.floor(_loc4_)) * 60);
            }
         }
         return {
            "days":_loc6_,
            "hours":_loc3_,
            "mins":_loc5_
         };
      }
      
      public static function convertNumberToString(param1:int) : String
      {
         var _loc2_:NumberFormatter = new NumberFormatter(LocalizationManager.localeForNumberFormatting);
         _loc2_.trailingZeros = false;
         return _loc2_.formatInt(param1);
      }
      
      public static function isMember(param1:int) : Boolean
      {
         return param1 >= 2;
      }
      
      public static function getColorId(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = param1 & 0xFF;
         if(_loc2_ == 0)
         {
            _loc3_ = 4;
         }
         else if(_loc2_ > 3 && _loc2_ < 10)
         {
            _loc3_ = _loc2_ + 1;
         }
         else
         {
            _loc3_ = Math.min(4,_loc2_);
         }
         return _loc3_;
      }
      
      public static function createXpShape(param1:int, param2:Boolean, param3:MovieClip, param4:MovieClip = null, param5:int = 65536) : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         if((param5 >> 16 & 0x0F) == 0)
         {
            if(_shapesMediaHelperArray == null)
            {
               _shapesMediaHelperArray = [];
            }
            _loc6_ = int(Math.floor(param1 / 5) > NameBar.LEVEL_SHAPES.length - 1 ? NameBar.LEVEL_SHAPES[NameBar.LEVEL_SHAPES.length - 1] : NameBar.LEVEL_SHAPES[Math.floor(param1 / 5)]);
            _loc7_ = String(_shapesMediaHelperArray.length);
            _levelShapeHelper = new MediaHelper();
            _levelShapeHelper.init(_loc6_,onLevelShapeLoaded,{
               "shapeUp":true,
               "level":param1,
               "isMember":param2,
               "iconHolderUp":param3,
               "iconHolderMouse":param4,
               "arrayId":_loc7_
            });
            _shapesMediaHelperArray[_loc7_] = _levelShapeHelper;
            if(param4 != null)
            {
               _loc7_ = String(_shapesMediaHelperArray.length);
               _levelShapeHelper = new MediaHelper();
               _levelShapeHelper.init(_loc6_,onLevelShapeLoaded,{
                  "shapeUp":false,
                  "level":param1,
                  "isMember":param2,
                  "iconHolderUp":param3,
                  "iconHolderMouse":param4,
                  "arrayId":_loc7_
               });
               _shapesMediaHelperArray[_loc7_] = _levelShapeHelper;
            }
         }
      }
      
      private static function onLevelShapeLoaded(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            _loc2_ = MovieClip(param1.getChildAt(0));
            if(param1.passback.isMember)
            {
               _loc2_.gotoAndStop("member");
            }
            _loc2_.dark.text.text = param1.passback.level;
            if(param1.passback.shapeUp == true)
            {
               _shapesMediaHelperArray[param1.passback.arrayId].destroy();
               delete _shapesMediaHelperArray[param1.passback.arrayId];
               while(param1.passback.iconHolderUp.numChildren > 0)
               {
                  param1.passback.iconHolderUp.removeChildAt(0);
               }
               param1.passback.iconHolderUp.addChild(_loc2_);
               param1.passback.iconHolderUp.parent.parent.gotoAndStop(1);
            }
            else
            {
               _shapesMediaHelperArray[param1.passback.arrayId].destroy();
               delete _shapesMediaHelperArray[param1.passback.arrayId];
               while(param1.passback.iconHolderMouse.numChildren > 0)
               {
                  param1.passback.iconHolderMouse.removeChildAt(0);
               }
               param1.passback.iconHolderMouse.addChild(_loc2_);
               param1.passback.iconHolderMouse.parent.parent.gotoAndStop(1);
            }
         }
      }
      
      public static function findIndexToInsert(param1:Array, param2:String, param3:String = "") : int
      {
         var _loc5_:Boolean = false;
         var _loc4_:Collator = null;
         var _loc7_:String = null;
         var _loc6_:int = 0;
         if(param1.length == 0)
         {
            return 0;
         }
         _loc5_ = param3 != "";
         _loc4_ = new Collator(LocalizationManager.localeForSorting);
         _loc7_ = _loc5_ ? param1[0][param3] : param1[0];
         _loc6_ = 0;
         while(_loc4_.compare(param2,_loc7_) > 0)
         {
            if(++_loc6_ > param1.length - 1)
            {
               return param1.length;
            }
            _loc7_ = _loc5_ ? param1[_loc6_][param3] : param1[_loc6_];
         }
         return _loc6_;
      }
      
      public static function isSettingOn(param1:int) : Boolean
      {
         var _loc2_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(363));
         if(_loc2_ == -1)
         {
            return true;
         }
         if((_loc2_ >> param1 & 1) == 1)
         {
            return false;
         }
         return true;
      }
      
      public static function numProperties(param1:Object) : int
      {
         var _loc3_:int = 0;
         for each(var _loc2_:Object in param1)
         {
            _loc3_++;
         }
         return _loc3_;
      }
      
      public static function leftShiftNumbers(param1:int) : Number
      {
         var _loc3_:Boolean = false;
         if(param1 == 31)
         {
            param1--;
            _loc3_ = true;
         }
         var _loc2_:Number = 1 << param1;
         if(_loc3_)
         {
            _loc2_ *= 2;
         }
         if(param1 > 31)
         {
            _loc2_ = Number("0x" + _loc2_.toString(16) + "00000000");
         }
         return _loc2_;
      }
      
      public static function rightShiftNumber(param1:Number) : Number
      {
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1 > 4294967295)
         {
            _loc4_ = param1.toString(2);
            _loc2_ = _loc4_.substr(0,_loc4_.length - 32);
            _loc3_ = _loc4_.substr(_loc4_.length - 32);
            _loc3_ = _loc2_.charAt(_loc2_.length - 1) + _loc3_.substr(0,_loc3_.length - 1);
            _loc2_ = _loc2_.substr(0,_loc2_.length - 1);
            if(_loc2_ == "")
            {
               _loc2_ = "0";
            }
            return Number("0x" + _loc2_ + "00000000") + parseInt(_loc3_,2);
         }
         return param1 >>> 1;
      }
      
      public static function bitwiseAnd(param1:Number, param2:Number) : Number
      {
         var _loc6_:String = null;
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc3_:* = 0;
         var _loc8_:* = 0;
         var _loc7_:* = 0;
         var _loc9_:Number = NaN;
         if(param1 < 1073741824 && param2 < 1073741824)
         {
            return param1 & param2;
         }
         _loc6_ = param1.toString(2);
         _loc4_ = uint(_loc6_.length > 32 ? parseInt(_loc6_.substr(0,_loc6_.length - 32),2) : 0);
         _loc5_ = uint(parseInt(_loc6_.substr(_loc6_.length > 32 ? _loc6_.length - 32 : 0),2));
         _loc6_ = param2.toString(2);
         _loc3_ = uint(_loc6_.length > 32 ? parseInt(_loc6_.substr(0,_loc6_.length - 32),2) : 0);
         _loc8_ = uint(parseInt(_loc6_.substr(_loc6_.length > 32 ? _loc6_.length - 32 : 0),2));
         _loc7_ = uint(_loc5_ & _loc8_);
         _loc9_ = Number("0x" + (_loc4_ & _loc3_).toString(16) + "00000000");
         return _loc7_ + _loc9_;
      }
      
      public static function bitwiseOr(param1:Number, param2:Number) : Number
      {
         var _loc6_:String = null;
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc3_:* = 0;
         var _loc8_:* = 0;
         var _loc7_:* = 0;
         var _loc9_:Number = NaN;
         if(param1 < 1073741824 && param2 < 1073741824)
         {
            return param1 | param2;
         }
         _loc6_ = param1.toString(2);
         _loc4_ = uint(_loc6_.length > 32 ? parseInt(_loc6_.substr(0,_loc6_.length - 32),2) : 0);
         _loc5_ = uint(parseInt(_loc6_.substr(_loc6_.length > 32 ? _loc6_.length - 32 : 0),2));
         _loc6_ = param2.toString(2);
         _loc3_ = uint(_loc6_.length > 32 ? parseInt(_loc6_.substr(0,_loc6_.length - 32),2) : 0);
         _loc8_ = uint(parseInt(_loc6_.substr(_loc6_.length > 32 ? _loc6_.length - 32 : 0),2));
         _loc7_ = uint(_loc5_ | _loc8_);
         _loc9_ = Number("0x" + (_loc4_ | _loc3_).toString(16) + "00000000");
         return _loc7_ + _loc9_;
      }
      
      public static function bitwiseNot(param1:Number) : Number
      {
         var _loc5_:String = param1.toString(2);
         var _loc2_:uint = _loc5_.length > 32 ? parseInt(_loc5_.substr(0,_loc5_.length - 32),2) : 0;
         var _loc4_:uint = parseInt(_loc5_.substr(_loc5_.length > 32 ? _loc5_.length - 32 : 0),2);
         _loc2_ = uint(~_loc2_);
         _loc4_ = uint(~_loc4_);
         var _loc6_:String = _loc2_.toString(2).substr(11);
         var _loc3_:String = _loc4_.toString(2);
         return parseInt(_loc6_ + _loc3_,2);
      }
      
      public static function currTimeOffsetToMatchUTC() : Number
      {
         var _loc1_:Date = new Date();
         var _loc2_:Number = gMainFrame.clientInfo.currentTimestamp - _loc1_.time / 1000;
         return _loc1_.time / 1000 + _loc2_;
      }
      
      public static function reloadSWFOrGetIp(param1:Boolean = true, param2:Boolean = true, param3:String = null) : String
      {
         var _loc7_:Object = null;
         var _loc5_:String = null;
         var _loc6_:URLRequest = null;
         var _loc4_:String = null;
         if(ExternalInterface.available)
         {
            _loc7_ = {};
            _loc7_.ip = param3;
            _loc7_.sessionId = gMainFrame.clientInfo.sessionId;
            _loc4_ = ExternalInterface.call("reloadSwfOrGetIP",param1,_loc7_);
         }
         else
         {
            _loc5_ = gMainFrame.clientInfo.websiteURL + (param2 ? "game/play" : "create_account");
            _loc6_ = new URLRequest(_loc5_);
            _loc6_.method = "GET";
            navigateToURL(_loc6_,"_self");
         }
         return _loc4_;
      }
      
      public static function getUsernameRestrictions() : String
      {
         return Utility.generateRangeForUnicodeVariables(48,57) + Utility.generateRangeForUnicodeVariables(65,90) + Utility.generateRangeForUnicodeVariables(97,122) + Utility.generateRangeForUnicodeVariables(192,255);
      }
      
      private static function generateRangeForUnicodeVariables(param1:Object, param2:Object) : String
      {
         return String.fromCharCode(param1) + "-" + String.fromCharCode(param2);
      }
      
      public static function shuffleArray(param1:Array, param2:Array) : Array
      {
         var _loc8_:String = null;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = int(param1.length);
         var _loc5_:Array = param1.slice();
         while(_loc7_ < _loc4_)
         {
            _loc8_ = _loc5_[_loc7_];
            _loc3_ = Math.floor(Math.random() * _loc4_);
            if(_loc7_ != _loc3_)
            {
               _loc5_[_loc7_] = _loc5_[_loc3_];
               _loc5_[_loc3_] = _loc8_;
               _loc6_ = int(param2[_loc7_]);
               param2[_loc7_] = param2[_loc3_];
               param2[_loc3_] = _loc6_;
            }
            _loc7_++;
         }
         return _loc5_;
      }
      
      public static function findItemWithEvent(param1:MovieClip) : Object
      {
         var _loc4_:DisplayObject = null;
         var _loc3_:int = 0;
         var _loc2_:Object = null;
         if(param1.hasEventListener("click"))
         {
            return {
               "mc":param1,
               "type":"click"
            };
         }
         if(param1.hasEventListener("mouseDown"))
         {
            return {
               "mc":param1,
               "type":"mouseDown"
            };
         }
         _loc3_ = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_);
            if(_loc4_ is MovieClip)
            {
               if(_loc4_.hasEventListener("click"))
               {
                  return {
                     "mc":MovieClip(_loc4_),
                     "type":"click"
                  };
               }
               if(_loc4_.hasEventListener("mouseDown"))
               {
                  return {
                     "mc":MovieClip(_loc4_),
                     "type":"mouseDown"
                  };
               }
               if(_loc4_ is MovieClip && (_loc4_ as MovieClip).numChildren > 0)
               {
                  if(_loc4_)
                  {
                     _loc2_ = findItemWithEvent(_loc4_ as MovieClip);
                     if(_loc2_ != null)
                     {
                        return _loc2_;
                     }
                  }
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function loadNameBarrelListAndReturnSetupArrays(param1:Array, param2:Function, param3:Boolean, ... rest) : void
      {
         var _loc5_:int = 0;
         if(param1 == null)
         {
            param1 = [];
         }
         _loc5_ = 0;
         while(_loc5_ < rest.length)
         {
            GenericListXtCommManager.requestGenericList(rest[_loc5_],onNameBarrelLoaded,{
               "names":param1,
               "index":_loc5_,
               "callback":param2,
               "lowerCaseLastWord":param3
            });
            _loc5_++;
         }
      }
      
      private static function onNameBarrelLoaded(param1:int, param2:Array, param3:Object) : void
      {
         var _loc4_:Array = null;
         var _loc10_:String = null;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc11_:Object = [];
         var _loc7_:int = -1;
         var _loc5_:Array = param3.names;
         var _loc9_:Boolean = Boolean(param3.lowerCaseLastWord);
         switch(param3.index)
         {
            case 0:
               _loc7_ = 0;
               _loc11_ = {
                  "names":[],
                  "locIds":[]
               };
               break;
            case 1:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc11_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc7_ = 2;
               }
               else
               {
                  _loc11_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc7_ = 1;
               }
               break;
            case 2:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc11_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc7_ = 1;
               }
               else
               {
                  _loc11_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc7_ = 2;
               }
         }
         if(_loc7_ != -1)
         {
            _loc8_ = 0;
            while(_loc8_ < param2.length)
            {
               if(_loc7_ == 1)
               {
                  _loc4_ = LocalizationManager.translateIdOnly(param2[_loc8_]).split("$");
                  _loc10_ = _loc4_[0];
                  _loc6_ = int(Utility.findIndexToInsert(_loc11_.names,_loc10_));
                  _loc11_.names.splice(_loc6_,0,_loc10_);
                  if(_loc4_[1])
                  {
                     _loc11_.types.splice(_loc6_,0,_loc4_[1]);
                  }
                  else
                  {
                     _loc11_.types.splice(_loc6_,0,"m");
                  }
               }
               else if(_loc7_ == 2)
               {
                  _loc4_ = LocalizationManager.translateIdOnly(param2[_loc8_]).split("$");
                  _loc10_ = _loc9_ ? _loc4_[0].toLowerCase() : _loc4_[0];
                  _loc6_ = int(Utility.findIndexToInsert(_loc11_.names,_loc10_));
                  _loc11_.names.splice(_loc6_,0,_loc10_);
                  if(_loc4_[1])
                  {
                     _loc11_.femNames.splice(_loc6_,0,_loc9_ ? _loc4_[1].toLowerCase() : _loc4_[1]);
                  }
                  else
                  {
                     _loc11_.femNames.splice(_loc6_,0,_loc10_);
                  }
               }
               else
               {
                  _loc10_ = LocalizationManager.translateIdOnly(param2[_loc8_]);
                  _loc6_ = int(Utility.findIndexToInsert(_loc11_.names,_loc10_));
                  _loc11_.names.splice(_loc6_,0,_loc10_);
               }
               _loc11_.locIds.splice(_loc6_,0,param2[_loc8_]);
               _loc8_++;
            }
            _loc5_[_loc7_] = _loc11_;
         }
         if(_loc5_[0] != null && _loc5_[1] != null && _loc5_[2] != null)
         {
            if(param3.callback != null)
            {
               param3.callback(_loc5_);
            }
         }
      }
      
      public static function checkEmailDomain(param1:String) : Object
      {
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc5_:Boolean = false;
         var _loc2_:Array = SbiConstants.COMMON_DOMAINS;
         var _loc9_:int = 0;
         var _loc4_:int = int(_loc2_.length);
         var _loc3_:String = param1.substr(param1.indexOf("@") + 1).toLowerCase();
         while(_loc9_ < _loc4_)
         {
            if(_loc3_ == _loc2_[_loc9_])
            {
               _loc5_ = true;
               break;
            }
            _loc9_++;
         }
         var _loc6_:Array = [];
         if(!_loc5_)
         {
            _loc7_ = _loc3_.split("");
            _loc9_ = 0;
            while(_loc9_ < _loc4_)
            {
               _loc8_ = Utils.damerauLevenshteinDistance(_loc7_,_loc2_[_loc9_].split(""),64);
               if(_loc8_ == 1)
               {
                  _loc6_.push(_loc2_[_loc9_]);
               }
               _loc9_++;
            }
         }
         return {
            "exactMatch":_loc5_,
            "suggestions":_loc6_
         };
      }
      
      public static function discardDefaultAudioItem(param1:DenItemCollection) : DenItemCollection
      {
         var _loc2_:int = 0;
         var _loc3_:DenItemCollection = new DenItemCollection();
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            if(param1.getDenItem(_loc2_).sortId != 4 || param1.getDenItem(_loc2_).defId != 617)
            {
               _loc3_.pushDenItem(param1.getDenItem(_loc2_));
            }
            _loc2_++;
         }
         return _loc3_;
      }
      
      public static function resizeImage(param1:BitmapData, param2:uint, param3:uint, param4:Boolean = true) : BitmapData
      {
         var _loc6_:Number = NaN;
         _loc6_ = 0.5;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc7_:Number = param2 / param1.width;
         var _loc9_:Number = param3 / param1.height;
         if(param4)
         {
            if(_loc7_ > _loc9_)
            {
               _loc7_ = _loc9_;
            }
            else
            {
               _loc9_ = _loc7_;
            }
         }
         var _loc11_:BitmapData = param1;
         if(_loc7_ >= 1 && _loc9_ >= 1)
         {
            _loc11_ = new BitmapData(Math.ceil(param1.width * _loc7_),Math.ceil(param1.height * _loc9_),true,0);
            _loc11_.draw(param1,new Matrix(_loc7_,0,0,_loc9_),null,null,null,true);
            return _loc11_;
         }
         var _loc8_:Number = _loc7_;
         var _loc10_:Number = _loc9_;
         while(_loc8_ < 1)
         {
            _loc8_ /= 0.5;
         }
         while(_loc10_ < 1)
         {
            _loc10_ /= 0.5;
         }
         if(_loc7_ < 0.5)
         {
            _loc8_ *= 0.5;
         }
         if(_loc9_ < 0.5)
         {
            _loc10_ *= 0.5;
         }
         var _loc5_:BitmapData = new BitmapData(_loc11_.width * _loc8_,_loc11_.height * _loc10_,true,0);
         _loc5_.draw(_loc11_,new Matrix(_loc8_,0,0,_loc10_),null,null,null,true);
         _loc11_ = _loc5_;
         _loc8_ *= 0.5;
         _loc10_ *= 0.5;
         while(_loc8_ >= _loc7_ || _loc10_ >= _loc9_)
         {
            _loc12_ = _loc8_ >= _loc7_ ? 0.5 : 1;
            _loc13_ = _loc10_ >= _loc9_ ? 0.5 : 1;
            _loc5_ = new BitmapData(_loc11_.width * _loc12_,_loc11_.height * _loc13_,true,0);
            _loc5_.draw(_loc11_,new Matrix(_loc12_,0,0,_loc13_),null,null,null,true);
            _loc11_.dispose();
            _loc8_ *= 0.5;
            _loc10_ *= 0.5;
            _loc11_ = _loc5_;
         }
         return _loc11_;
      }
   }
}

