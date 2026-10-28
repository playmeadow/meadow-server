package
{
   import com.sbi.analytics.SBTracker;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import item.Item;
   import loader.MediaHelper;
   
   public class Utility
   {
      
      private static var _notEnoughGemsPopup:MovieClip;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _showLoadingSpiral:Function;
      
      private static var _darken:Function;
      
      private static var _undarken:Function;
      
      private static const AUDIO_TYPE:int = 4;
      
      private static const NOT_ENOUGH_GEMS_POPUP_ID:int = 1245;
      
      public static const ACCOUNT_TYPE_ARCHIVED:int = -2;
      
      public static const ACCOUNT_TYPE_NEW:int = -1;
      
      public static const ACCOUNT_TYPE_NONE:int = 0;
      
      public static const NON_MEMBER:int = 1;
      
      public static const PREMIUM_MEMBER:int = 2;
      
      public static const BETA_MEMBER:int = 3;
      
      public static const INTERNAL:int = 4;
      
      public static const COMMUNITY:int = 5;
      
      public static const ENVIRO_LAND:int = 0;
      
      public static const ENVIRO_OCEAN:int = 1;
      
      public static const ROOMTYPE_WORLD:int = 0;
      
      public static const ROOMTYPE_GAME:int = 1;
      
      public static const ROOMTYPE_DEN:int = 2;
      
      public static const ROOMTYPE_LOBBY:int = 3;
      
      public static const ROOMTYPE_FFM:int = 4;
      
      public static const ROOMTYPE_PARTY:int = 5;
      
      public static const ROOMTYPE_WORLDGAME:int = 6;
      
      public static const ROOMTYPE_QUEST:int = 7;
      
      public static const ROOMTYPE_QUEST_STAGING:int = 8;
      
      public function Utility()
      {
         super();
      }
      
      public static function init(param1:Function, param2:Function, param3:Function) : void
      {
         _showLoadingSpiral = param1;
         _darken = param2;
         _undarken = param3;
      }
      
      public static function isLand(param1:int) : Boolean
      {
         return (param1 & 1) == 1;
      }
      
      public static function isOcean(param1:int) : Boolean
      {
         return (param1 >> ENVIRO_OCEAN & 1) == 1;
      }
      
      public static function isSameEnviroType(param1:int, param2:int) : Boolean
      {
         if(param2 == ENVIRO_LAND)
         {
            return isLand(param1);
         }
         return isOcean(param1);
      }
      
      public static function isRoomOfThisType(param1:int) : Boolean
      {
         return gMainFrame.clientInfo.roomType == param1;
      }
      
      public static function sortItems(param1:Array, param2:int, param3:int, param4:int = -1, param5:int = -1) : Array
      {
         var _loc7_:Array = null;
         var _loc12_:Object = null;
         var _loc13_:int = 0;
         var _loc6_:Array = param1.concat();
         _loc7_ = [];
         var _loc8_:int = param2;
         var _loc9_:int = 0;
         var _loc10_:int = -1;
         var _loc11_:int = int(_loc6_.length);
         while(_loc8_ < _loc11_)
         {
            _loc12_ = _loc6_[_loc8_];
            if(_loc12_ is Item)
            {
               _loc13_ = int(_loc12_.layerId);
            }
            else
            {
               _loc13_ = int(_loc12_.sortId);
            }
            if(_loc12_.isOcean)
            {
               if(_loc10_ == -1)
               {
                  _loc10_ = convertOceanSortId(param3);
               }
               if(_loc13_ == _loc10_)
               {
                  _loc7_[_loc9_] = _loc6_[_loc8_];
                  _loc9_++;
               }
            }
            else if(_loc13_ == param3 || _loc13_ == param4 || _loc13_ == param5)
            {
               _loc7_[_loc9_] = _loc6_[_loc8_];
               _loc9_++;
            }
            _loc8_++;
         }
         return _loc7_;
      }
      
      public static function sortItemsAll(param1:Array, param2:int, param3:int, param4:int = -1, param5:int = -1) : Array
      {
         var _loc7_:Array = null;
         var _loc11_:Boolean = false;
         var _loc12_:Object = null;
         var _loc13_:int = 0;
         var _loc6_:Array = param1.concat();
         _loc7_ = [];
         var _loc8_:int = param2;
         var _loc9_:int = 0;
         var _loc10_:int = -1;
         while(_loc8_ < _loc6_.length)
         {
            _loc11_ = false;
            _loc12_ = _loc6_[_loc8_];
            if(_loc12_ is Item)
            {
               _loc13_ = int(_loc12_.layerId);
            }
            else
            {
               _loc13_ = int(_loc12_.sortId);
            }
            if(_loc12_.isOcean)
            {
               if(_loc10_ == -1)
               {
                  _loc10_ = convertOceanSortId(param3);
               }
               if(_loc13_ == _loc10_)
               {
                  _loc7_[_loc9_] = _loc6_[_loc8_];
                  _loc11_ = true;
                  _loc9_++;
               }
            }
            else if(_loc13_ == param3 || _loc13_ == param4 || _loc13_ == param5)
            {
               _loc7_[_loc9_] = _loc6_[_loc8_];
               _loc11_ = true;
               _loc9_++;
            }
            if(_loc11_)
            {
               _loc6_.splice(_loc8_,1);
            }
            else
            {
               _loc8_++;
            }
         }
         return _loc7_.concat(_loc6_);
      }
      
      public static function sortByItem(param1:Array, param2:int) : Array
      {
         param1 = param1.concat();
         if(param1[0] is Item)
         {
            param1.sortOn(["accId","color"],Array.NUMERIC | Array.DESCENDING);
         }
         else
         {
            param1.sortOn(["sortId","itemDefId","version"],Array.NUMERIC);
         }
         return param1;
      }
      
      private static function convertOceanSortId(param1:int) : int
      {
         switch(param1)
         {
            case Item.HEAD_LAYER_1:
            case Item.HEAD_LAYER_2:
            case Item.HEAD_LAYER_3:
               return Item.OCEAN_HEAD_LAYER;
            case Item.BACK_LAYER:
               return Item.OCEAN_BACK_LAYER;
            case Item.LEG_LAYER:
               return Item.OCEAN_LEG_LAYER;
            case Item.NECK_LAYER:
               return Item.OCEAN_NECK_LAYER;
            default:
               return param1;
         }
      }
      
      public static function numDenItemsInList(param1:Array, param2:int, param3:Boolean = false) : int
      {
         return int(denItemsInList(param1,param2,true,param3));
      }
      
      public static function denItemListByEnviroType(param1:Array, param2:int, param3:Boolean = false) : Array
      {
         return denItemsInList(param1,param2,false,param3) as Array;
      }
      
      private static function denItemsInList(param1:Array, param2:int, param3:Boolean = false, param4:Boolean = false) : Object
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:Array = [];
         if(param1)
         {
            _loc6_ = int(param1.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               if(param4)
               {
                  if(param1[_loc7_].sortId == AUDIO_TYPE)
                  {
                     _loc5_.push(param1[_loc7_]);
                  }
               }
               else if(param1[_loc7_].sortId != AUDIO_TYPE)
               {
                  if(param2 == -1 || param1[_loc7_].enviroType == param2)
                  {
                     _loc5_.push(param1[_loc7_]);
                  }
               }
               _loc7_++;
            }
         }
         if(param3)
         {
            return _loc5_.length;
         }
         return _loc5_;
      }
      
      public static function numClothingItemsInList(param1:Array, param2:int) : int
      {
         return int(clothingItemsInList(param1,param2,true));
      }
      
      public static function clothingItemListByEnviroType(param1:Array, param2:int) : Array
      {
         return clothingItemsInList(param1,param2,false) as Array;
      }
      
      private static function clothingItemsInList(param1:Array, param2:int, param3:Boolean = false) : Object
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:Array = [];
         if(param1)
         {
            _loc5_ = int(param1.length);
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(param1[_loc6_].enviroType == param2)
               {
                  _loc4_.push(param1[_loc6_]);
               }
               _loc6_++;
            }
         }
         if(param3)
         {
            return _loc4_.length;
         }
         return _loc4_;
      }
      
      public static function setupNotEnoughGemsPopup(param1:DisplayObjectContainer, param2:int, param3:int = 0, param4:Function = null) : void
      {
         if(_notEnoughGemsPopup)
         {
            _showLoadingSpiral(false);
            _notEnoughGemsPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _notEnoughGemsPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            if(param3 == Item.GEM_CURRENCY)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("gems");
               _notEnoughGemsPopup.gemsTxt.text = gMainFrame.clientInfo.gemCount;
            }
            else if(param3 == Item.TICKET_CURRENCY)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("tickets");
               _notEnoughGemsPopup.gemsTxt.text = gMainFrame.clientInfo.ticketCount;
            }
            else if(param3 == Item.ORB_CURRENCY)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("orbs");
               _notEnoughGemsPopup.gemsTxt.text = gMainFrame.clientInfo.orbCount;
            }
            else if(param3 == Item.DIAMOND_CURRENCY)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("diamonds");
               _notEnoughGemsPopup.gemsTxt.text = gMainFrame.clientInfo.diamondCount;
            }
            _notEnoughGemsPopup.costTxt.text = param2;
            _notEnoughGemsPopup.needTxt.text = param2 - int(_notEnoughGemsPopup.gemsTxt.text);
            _notEnoughGemsPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopupDown,false,0,true);
            _notEnoughGemsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
            _notEnoughGemsPopup.closeCallback = param4;
            param1.addChild(_notEnoughGemsPopup);
            _darken(_notEnoughGemsPopup);
         }
         else
         {
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(NOT_ENOUGH_GEMS_POPUP_ID,onMediaItemLoaded,{
               "guiLayer":param1,
               "itemCost":param2,
               "currencyType":param3,
               "callback":param4
            });
         }
      }
      
      private static function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1.mediaHelper.id == NOT_ENOUGH_GEMS_POPUP_ID)
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/avatarSwitch/buyAnimal_notEnoughGems");
            _notEnoughGemsPopup = MovieClip(param1.getChildAt(0));
            setupNotEnoughGemsPopup(param1.passback.guiLayer,param1.passback.itemCost,param1.passback.currencyType,param1.passback.callback);
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
      
      public static function calculatePrintTime(param1:int, param2:int, param3:Boolean = false, param4:int = 0) : String
      {
         var _loc5_:String = null;
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
                  _loc5_ = param4 + " day ";
               }
               else
               {
                  _loc5_ = param4 + " days ";
               }
            }
            if(param3)
            {
               if(param2 == 1)
               {
                  _loc5_ = _loc5_ + param2 + " hour";
               }
               else
               {
                  _loc5_ = _loc5_ + param2 + " hours";
               }
               if(param1 == 1)
               {
                  _loc5_ = _loc5_ + " and " + param1 + " minute";
               }
               else if(param1 != 0)
               {
                  _loc5_ = _loc5_ + " and " + param1 + " minutes";
               }
            }
            else
            {
               if(param2 == 1)
               {
                  _loc5_ = _loc5_ + param2 + " hr ";
               }
               else
               {
                  _loc5_ = _loc5_ + param2 + " hrs ";
               }
               if(param1 == 1)
               {
                  _loc5_ = _loc5_ + param1 + " min";
               }
               else if(param1 != 0)
               {
                  _loc5_ = _loc5_ + param1 + " mins";
               }
            }
         }
         else if(param1 == 1)
         {
            _loc5_ = param1 + " minute";
         }
         else
         {
            _loc5_ = param1 + " minutes";
         }
         return _loc5_;
      }
      
      public static function calculateTime(param1:int) : Object
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Number = 0;
         var _loc6_:Number = Math.ceil(param1 / 60);
         if(_loc6_ < 60)
         {
            _loc5_ = _loc6_;
            _loc3_ = 0;
         }
         else
         {
            _loc4_ = _loc6_ / 60;
            if(_loc4_ >= 24)
            {
               _loc2_ = _loc4_ / 24;
               _loc3_ = (_loc2_ - Math.floor(_loc2_)) * 24;
               _loc5_ = (_loc3_ - Math.floor(_loc3_)) * 60;
               _loc3_ = Math.floor(_loc3_);
               _loc2_ = int(_loc2_);
            }
            else
            {
               _loc3_ = Math.floor(_loc4_);
               _loc5_ = Math.ceil((_loc4_ - Math.floor(_loc4_)) * 60);
            }
         }
         return {
            "days":_loc2_,
            "hours":_loc3_,
            "mins":_loc5_
         };
      }
      
      public static function convertNumberToString(param1:int) : String
      {
         if(param1 > 999)
         {
            return param1.toString().replace(/\d{1,3}(?=(\d{3})+(?!\d))/g,"$&,");
         }
         return param1.toString();
      }
      
      public static function isMember(param1:int) : Boolean
      {
         return param1 >= PREMIUM_MEMBER;
      }
   }
}

