package
{
   import achievement.AchievementXtCommManager;
   import avatar.NameBar;
   import com.sbi.analytics.SBTracker;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.globalization.Collator;
   import flash.globalization.NumberFormatter;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class Utility
   {
      
      private static var _notEnoughGemsPopup:MovieClip;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _showLoadingSpiral:Function;
      
      private static var _darken:Function;
      
      private static var _undarken:Function;
      
      private static var _levelShapeHelper:MediaHelper;
      
      private static var _shapesMediaHelperArray:Array;
      
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
      
      public static const INTERACTION_TYPE_BUDDY:int = 0;
      
      public static const INTERACTION_TYPE_TRADE:int = 1;
      
      public static const INTERACTION_TYPE_GIFT:int = 2;
      
      public static const INTERACTION_TYPE_CHAT:int = 3;
      
      public static const INTERACTION_TYPE_JAG:int = 4;
      
      public static const INTERACTION_TYPE_MULTIPLAYER:int = 5;
      
      public static const INTERACTION_TYPE_PVP:int = 6;
      
      public static const INTERACTION_TYPE_QUEST:int = 7;
      
      public static const ENVIRO_LAND:int = 0;
      
      public static const ENVIRO_OCEAN:int = 1;
      
      public static const ENVIRO_AIR:int = 2;
      
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
      
      public static function init(showLoadingSpiral:Function, darken:Function, undarken:Function) : void
      {
         _showLoadingSpiral = showLoadingSpiral;
         _darken = darken;
         _undarken = undarken;
      }
      
      public static function isLand(flag:int) : Boolean
      {
         return (flag & 1) == 1;
      }
      
      public static function isOcean(flag:int) : Boolean
      {
         return (flag >> ENVIRO_OCEAN & 1) == 1;
      }
      
      public static function isAir(flag:int) : Boolean
      {
         return (flag >> ENVIRO_AIR & 1) == 1;
      }
      
      public static function isSameEnviroType(enviroTypeFlag:int, currEnviroType:int) : Boolean
      {
         if(currEnviroType == ENVIRO_LAND)
         {
            return isLand(enviroTypeFlag);
         }
         if(currEnviroType == ENVIRO_AIR)
         {
            return isAir(enviroTypeFlag);
         }
         return isOcean(enviroTypeFlag);
      }
      
      public static function isRoomOfThisType(type:int) : Boolean
      {
         return gMainFrame.clientInfo.roomType == type;
      }
      
      public static function sortItems(items:Array, startIdx:int, sortId:int, sortId2:int = -1, sortId3:int = -1) : Array
      {
         var newItemArray:Array = null;
         var itemObj:Object = null;
         var type:int = 0;
         var oldItems:Array = items.concat();
         newItemArray = [];
         var i:int = startIdx;
         var j:int = 0;
         var oceanSortId:int = -1;
         var oldItemLength:int = int(oldItems.length);
         while(i < oldItemLength)
         {
            itemObj = oldItems[i];
            if(itemObj is Item)
            {
               type = int(itemObj.layerId);
            }
            else
            {
               type = int(itemObj.sortId);
            }
            if(Boolean(itemObj.isOcean))
            {
               if(oceanSortId == -1)
               {
                  oceanSortId = convertOceanSortId(sortId);
               }
               if(type == oceanSortId)
               {
                  newItemArray[j] = oldItems[i];
                  j++;
               }
            }
            else if(type == sortId || type == sortId2 || type == sortId3)
            {
               newItemArray[j] = oldItems[i];
               j++;
            }
            i++;
         }
         return newItemArray;
      }
      
      public static function sortItemsAll(items:Array, startIdx:int, sortId:int, sortId2:int = -1, sortId3:int = -1) : Array
      {
         var newItemArray:Array = null;
         var itemAdded:Boolean = false;
         var itemObj:Object = null;
         var type:int = 0;
         var oldItems:Array = items.concat();
         newItemArray = [];
         var i:int = startIdx;
         var j:int = 0;
         var oceanSortId:int = -1;
         while(i < oldItems.length)
         {
            itemAdded = false;
            itemObj = oldItems[i];
            if(itemObj is Item)
            {
               type = int(itemObj.layerId);
            }
            else
            {
               type = int(itemObj.sortId);
            }
            if(Boolean(itemObj.isOcean))
            {
               if(oceanSortId == -1)
               {
                  oceanSortId = convertOceanSortId(sortId);
               }
               if(type == oceanSortId)
               {
                  newItemArray[j] = oldItems[i];
                  itemAdded = true;
                  j++;
               }
            }
            else if(type == sortId || type == sortId2 || type == sortId3)
            {
               newItemArray[j] = oldItems[i];
               itemAdded = true;
               j++;
            }
            if(itemAdded)
            {
               oldItems.splice(i,1);
            }
            else
            {
               i++;
            }
         }
         return newItemArray.concat(oldItems);
      }
      
      public static function sortByItem(items:Array, startIdx:int) : Array
      {
         var newItems:Array = items.concat();
         if(newItems[0] is Item)
         {
            newItems.sortOn(["accId","color"],Array.NUMERIC | Array.DESCENDING);
         }
         else
         {
            newItems.sortOn(["sortId","itemDefId","version"],Array.NUMERIC);
         }
         return newItems;
      }
      
      private static function convertOceanSortId(sortId:int) : int
      {
         switch(sortId)
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
               return sortId;
         }
      }
      
      public static function numDenItemsInList(itemArray:Array, enviroType:int, findAudioItemsOnly:Boolean = false) : int
      {
         return int(denItemsInList(itemArray,enviroType,true,findAudioItemsOnly));
      }
      
      public static function denItemListByEnviroType(itemArray:Array, enviroType:int, findAudioItemsOnly:Boolean = false) : Array
      {
         return denItemsInList(itemArray,enviroType,false,findAudioItemsOnly) as Array;
      }
      
      private static function denItemsInList(itemArray:Array, enviroType:int, returnItemCount:Boolean = false, findAudioItemsOnly:Boolean = false) : Object
      {
         var itemArrayLength:int = 0;
         var i:int = 0;
         var returnArray:Array = [];
         if(Boolean(itemArray))
         {
            itemArrayLength = int(itemArray.length);
            for(i = 0; i < itemArrayLength; i++)
            {
               if(findAudioItemsOnly)
               {
                  if(itemArray[i].sortId == AUDIO_TYPE)
                  {
                     returnArray.push(itemArray[i]);
                  }
               }
               else if(itemArray[i].sortId != AUDIO_TYPE)
               {
                  if(enviroType == -1 || itemArray[i].enviroType == enviroType)
                  {
                     returnArray.push(itemArray[i]);
                  }
               }
            }
         }
         if(returnItemCount)
         {
            return returnArray.length;
         }
         return returnArray;
      }
      
      public static function numClothingItemsInList(itemArray:Array, enviroType:int) : int
      {
         return int(clothingItemsInList(itemArray,enviroType,true));
      }
      
      public static function clothingItemListByEnviroType(itemArray:Array, enviroType:int) : Array
      {
         return clothingItemsInList(itemArray,enviroType,false) as Array;
      }
      
      private static function clothingItemsInList(itemArray:Array, enviroType:int, returnItemCount:Boolean = false) : Object
      {
         var listLength:int = 0;
         var i:int = 0;
         var returnArray:Array = [];
         if(Boolean(itemArray))
         {
            listLength = int(itemArray.length);
            for(i = 0; i < listLength; i++)
            {
               if(itemArray[i].enviroType == enviroType)
               {
                  returnArray.push(itemArray[i]);
               }
            }
         }
         if(returnItemCount)
         {
            return returnArray.length;
         }
         return returnArray;
      }
      
      public static function setupNotEnoughGemsPopup(guiLayer:DisplayObjectContainer, itemCost:int, currencyType:int = 0, callback:Function = null) : void
      {
         if(Boolean(_notEnoughGemsPopup))
         {
            _showLoadingSpiral(false);
            _notEnoughGemsPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _notEnoughGemsPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            if(currencyType == Item.GEM_CURRENCY)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("gems");
               _notEnoughGemsPopup.gemsTxt.text = gMainFrame.clientInfo.gemCount;
            }
            else if(currencyType == Item.TICKET_CURRENCY)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("tickets");
               _notEnoughGemsPopup.gemsTxt.text = gMainFrame.clientInfo.ticketCount;
            }
            else if(currencyType == Item.ORB_CURRENCY)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("orbs");
               _notEnoughGemsPopup.gemsTxt.text = gMainFrame.clientInfo.orbCount;
            }
            else if(currencyType == Item.DIAMOND_CURRENCY)
            {
               _notEnoughGemsPopup.currency.gotoAndStop("diamonds");
               _notEnoughGemsPopup.gemsTxt.text = gMainFrame.clientInfo.diamondCount;
            }
            _notEnoughGemsPopup.costTxt.text = itemCost;
            _notEnoughGemsPopup.needTxt.text = itemCost - int(_notEnoughGemsPopup.gemsTxt.text);
            _notEnoughGemsPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopupDown,false,0,true);
            _notEnoughGemsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
            _notEnoughGemsPopup.closeCallback = callback;
            guiLayer.addChild(_notEnoughGemsPopup);
            _darken(_notEnoughGemsPopup);
         }
         else
         {
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(NOT_ENOUGH_GEMS_POPUP_ID,onMediaItemLoaded,{
               "guiLayer":guiLayer,
               "itemCost":itemCost,
               "currencyType":currencyType,
               "callback":callback
            });
         }
      }
      
      private static function onMediaItemLoaded(img:MovieClip) : void
      {
         if(img.mediaHelper.id == NOT_ENOUGH_GEMS_POPUP_ID)
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/avatarSwitch/buyAnimal_notEnoughGems",-1,SBTracker.TYPE_EVENT);
            _notEnoughGemsPopup = MovieClip(img.getChildAt(0));
            setupNotEnoughGemsPopup(img.passback.guiLayer,img.passback.itemCost,img.passback.currencyType,img.passback.callback);
         }
      }
      
      private static function onPopupDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.parent == _notEnoughGemsPopup)
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
         return (gMainFrame.clientInfo.interactions >> INTERACTION_TYPE_TRADE & 1) == 1;
      }
      
      public static function canGift() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> INTERACTION_TYPE_GIFT & 1) == 1;
      }
      
      public static function canChat() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> INTERACTION_TYPE_CHAT & 1) == 1;
      }
      
      public static function canJAG() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> INTERACTION_TYPE_JAG & 1) == 1;
      }
      
      public static function canMultiplayer() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> INTERACTION_TYPE_MULTIPLAYER & 1) == 1;
      }
      
      public static function canPVP() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> INTERACTION_TYPE_PVP & 1) == 1;
      }
      
      public static function canQuest() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> INTERACTION_TYPE_QUEST & 1) == 1;
      }
      
      public static function canTradeNonDegraded() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 8 & 1) == 1;
      }
      
      public static function canGiftNonDegraded() : Boolean
      {
         return (gMainFrame.clientInfo.interactions >> 9 & 1) == 1;
      }
      
      public static function toggleInteractionBit(bitIndex:int) : void
      {
         gMainFrame.clientInfo.interactions ^= 1 << bitIndex;
      }
      
      public static function calculatePrintTime(mins:int, hours:int, showFullWords:Boolean = false, days:int = 0) : String
      {
         var time:String = "";
         if(hours > 0 || days > 0)
         {
            if(mins == 0)
            {
               showFullWords = true;
            }
            if(days > 0)
            {
               if(days == 1)
               {
                  time = LocalizationManager.translateIdAndInsertOnly(11118,days).toLowerCase() + " ";
               }
               else
               {
                  time = LocalizationManager.translateIdAndInsertOnly(11119,days).toLowerCase() + " ";
               }
            }
            if(showFullWords)
            {
               if(hours == 1)
               {
                  time += LocalizationManager.translateIdAndInsertOnly(11120,hours).toLowerCase();
               }
               else
               {
                  time += LocalizationManager.translateIdAndInsertOnly(11121,hours).toLowerCase();
               }
               if(mins == 1)
               {
                  time += LocalizationManager.translateIdAndInsertOnly(11122,mins);
               }
               else if(mins != 0)
               {
                  time += LocalizationManager.translateIdAndInsertOnly(11123,mins);
               }
            }
            else
            {
               if(hours == 1)
               {
                  time += LocalizationManager.translateIdAndInsertOnly(11124,hours);
               }
               else
               {
                  time += LocalizationManager.translateIdAndInsertOnly(11125,hours);
               }
               if(mins == 1)
               {
                  time += LocalizationManager.translateIdAndInsertOnly(11126,mins);
               }
               else if(mins != 0)
               {
                  time += LocalizationManager.translateIdAndInsertOnly(11127,mins);
               }
            }
         }
         else if(mins == 1)
         {
            time = LocalizationManager.translateIdAndInsertOnly(11128,mins);
         }
         else
         {
            time = LocalizationManager.translateIdAndInsertOnly(11129,mins);
         }
         return time;
      }
      
      public static function calculateTime(sec:int) : Object
      {
         var hours:Number = NaN;
         var tempHours:Number = NaN;
         var mins:Number = NaN;
         var days:Number = 0;
         var tempTime:Number = Math.ceil(sec / 60);
         if(tempTime < 60)
         {
            mins = tempTime;
            hours = 0;
         }
         else
         {
            tempHours = tempTime / 60;
            if(tempHours >= 24)
            {
               days = tempHours / 24;
               hours = (days - Math.floor(days)) * 24;
               mins = (hours - Math.floor(hours)) * 60;
               hours = Math.floor(hours);
               days = int(days);
            }
            else
            {
               hours = Math.floor(tempHours);
               mins = Math.ceil((tempHours - Math.floor(tempHours)) * 60);
            }
         }
         return {
            "days":days,
            "hours":hours,
            "mins":mins
         };
      }
      
      public static function convertNumberToString(num:int) : String
      {
         var nf:NumberFormatter = new NumberFormatter(LocalizationManager.localeForNumberFormatting);
         nf.trailingZeros = false;
         return nf.formatInt(num);
      }
      
      public static function isMember(accountType:int) : Boolean
      {
         return accountType >= PREMIUM_MEMBER;
      }
      
      public static function getColorId(nameBarData:int) : int
      {
         var frameId:int = 0;
         var color:int = nameBarData & 0xFF;
         if(color == 0)
         {
            frameId = 4;
         }
         else if(color > 3 && color <= NameBar.MAX_COLORS)
         {
            frameId = color + 1;
         }
         else
         {
            frameId = Math.min(4,color);
         }
         return frameId;
      }
      
      public static function createXpShape(level:int, isMember:Boolean, iconHolderUp:MovieClip, iconHolderMouse:MovieClip = null, nameBarData:int = 65536) : void
      {
         var shapeId:int = 0;
         var arrayId:String = null;
         if((nameBarData >> 16 & 0xFF) == 0)
         {
            if(_shapesMediaHelperArray == null)
            {
               _shapesMediaHelperArray = [];
            }
            shapeId = Math.floor(level / 5) > NameBar.LEVEL_SHAPES.length - 1 ? int(NameBar.LEVEL_SHAPES[NameBar.LEVEL_SHAPES.length - 1]) : int(NameBar.LEVEL_SHAPES[Math.floor(level / 5)]);
            arrayId = String(_shapesMediaHelperArray.length);
            _levelShapeHelper = new MediaHelper();
            _levelShapeHelper.init(shapeId,onLevelShapeLoaded,{
               "shapeUp":true,
               "level":level,
               "isMember":isMember,
               "iconHolderUp":iconHolderUp,
               "iconHolderMouse":iconHolderMouse,
               "arrayId":arrayId
            });
            _shapesMediaHelperArray[arrayId] = _levelShapeHelper;
            if(iconHolderMouse != null)
            {
               arrayId = String(_shapesMediaHelperArray.length);
               _levelShapeHelper = new MediaHelper();
               _levelShapeHelper.init(shapeId,onLevelShapeLoaded,{
                  "shapeUp":false,
                  "level":level,
                  "isMember":isMember,
                  "iconHolderUp":iconHolderUp,
                  "iconHolderMouse":iconHolderMouse,
                  "arrayId":arrayId
               });
               _shapesMediaHelperArray[arrayId] = _levelShapeHelper;
            }
         }
      }
      
      private static function onLevelShapeLoaded(img:MovieClip) : void
      {
         var shape:MovieClip = null;
         if(Boolean(img))
         {
            shape = MovieClip(img.getChildAt(0));
            if(Boolean(img.passback.isMember))
            {
               shape.gotoAndStop("member");
            }
            shape.text.text = img.passback.level;
            if(img.passback.shapeUp == true)
            {
               _shapesMediaHelperArray[img.passback.arrayId].destroy();
               delete _shapesMediaHelperArray[img.passback.arrayId];
               while(img.passback.iconHolderUp.numChildren > 0)
               {
                  img.passback.iconHolderUp.removeChildAt(0);
               }
               img.passback.iconHolderUp.addChild(shape);
               img.passback.iconHolderUp.parent.parent.gotoAndStop(1);
            }
            else
            {
               _shapesMediaHelperArray[img.passback.arrayId].destroy();
               delete _shapesMediaHelperArray[img.passback.arrayId];
               while(img.passback.iconHolderMouse.numChildren > 0)
               {
                  img.passback.iconHolderMouse.removeChildAt(0);
               }
               img.passback.iconHolderMouse.addChild(shape);
               img.passback.iconHolderMouse.parent.parent.gotoAndStop(1);
            }
         }
      }
      
      public static function findIndexToInsert(array:Array, currName:String) : int
      {
         var col:Collator = null;
         var comparisonName:String = null;
         var i:int = 0;
         if(array.length == 0)
         {
            return 0;
         }
         col = new Collator(LocalizationManager.localeForSorting);
         comparisonName = array[0];
         i = 0;
         while(col.compare(currName,comparisonName) > 0)
         {
            if(++i > array.length - 1)
            {
               return array.length;
            }
            comparisonName = array[i];
         }
         return i;
      }
      
      public static function isSettingOn(settingBit:int) : Boolean
      {
         var settingUV:int = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_SETTINGS));
         if(settingUV == -1)
         {
            return true;
         }
         if((settingUV >> settingBit & 1) == 1)
         {
            return false;
         }
         return true;
      }
      
      public static function numProperties(obj:Object) : int
      {
         var prop:Object = null;
         var count:int = 0;
         for each(prop in obj)
         {
            count++;
         }
         return count;
      }
   }
}

