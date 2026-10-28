package gui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBPopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   import room.RoomXtCommManager;
   
   public class ServerSelector
   {
      
      private static var _popupLayer:DisplayObjectContainer;
      
      private static var _closeCallback:Function;
      
      private static var _serverAllContent:MovieClip;
      
      private static var _serverAll:MovieClip;
      
      private static var _scrollButtons:SBScrollbar;
      
      private static var _itemWindows:WindowGenerator;
      
      private static var _serverAllPopup:SBPopup;
      
      private static var _availShards:Array;
      
      private static var _serverNames:Array;
      
      private static var _numBuddies:Array;
      
      private static var _languageIds:Array;
      
      private static var _popuplation:Array;
      
      private static var _nameIdx:int;
      
      private static var _lastClickedShardTarget:Object;
      
      private static const NUM_Y_WIN:int = 10;
      
      public function ServerSelector()
      {
         super();
      }
      
      public static function init(guiLayer:DisplayObjectContainer, initData:Object, initCloseCallback:Function = null, initPopupX:int = 450, initPopupY:int = 275) : void
      {
         _popupLayer = guiLayer;
         _lastClickedShardTarget = null;
         _closeCallback = initCloseCallback;
         _availShards = [];
         _numBuddies = [];
         _languageIds = [];
         _popuplation = [];
         _nameIdx = 0;
         _serverAllContent = GETDEFINITIONBYNAME("ServerAllPopupContent");
         _serverAllPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ServerAllPopupSkin"),_serverAllContent,true,true,false,false,true);
         _serverAllPopup.bxClosesPopup = false;
         _serverAllPopup.x = initPopupX;
         _serverAllPopup.y = initPopupY;
         DarkenManager.showLoadingSpiral(true);
         MovieClip(_serverAllPopup.content).helpNameBtn.visible = false;
         fillNamesArray();
         SBTracker.trackPageview("/game/play/shardDetail");
         addListeners();
      }
      
      public static function isOpen() : Boolean
      {
         if(Boolean(_serverAllPopup))
         {
            return _serverAllPopup.visible;
         }
         return false;
      }
      
      public static function destroy() : void
      {
         removeListeners();
         if(Boolean(_itemWindows))
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(Boolean(_serverAllPopup))
         {
            _serverAllPopup.x = undefined;
            _serverAllPopup.y = undefined;
            _serverAllPopup.destroy();
            _serverAllPopup = null;
         }
         _closeCallback = null;
      }
      
      public static function setupAllShards(data:Object, lastShardId:int) : void
      {
         var isEmpty:Boolean = false;
         var totalPopulation:int = 0;
         var newIndex:int = 0;
         var newLang:int = 0;
         var slr:int = 0;
         var i:int = 0;
         var firstSkippedShardId:int = -1;
         var numEmptySoFar:int = 0;
         var myLang:int = LocalizationManager.accountLanguage;
         _availShards = [];
         _languageIds = [];
         _popuplation = [];
         _numBuddies = [];
         while(data[slr] != null)
         {
            isEmpty = data[slr + 2] == 0;
            if(isEmpty)
            {
               numEmptySoFar++;
            }
            if(isEmpty && numEmptySoFar > 5)
            {
               if(firstSkippedShardId == -1)
               {
                  firstSkippedShardId = int(data[slr]);
               }
               slr += 4;
            }
            else
            {
               _availShards[i] = data[slr++];
               _languageIds[i] = data[slr++];
               totalPopulation += int(data[slr]);
               _popuplation[i] = data[slr++];
               _numBuddies[i] = data[slr++];
               i++;
            }
         }
         if(totalPopulation >= _availShards.length * 4 && i < _serverNames.length)
         {
            if(firstSkippedShardId == -1)
            {
               newIndex = lastShardId + 1;
               newLang = myLang;
            }
            else
            {
               newIndex = firstSkippedShardId;
               newLang = int(_languageIds[firstSkippedShardId]);
            }
            _availShards.splice(0,0,String(newIndex));
            _languageIds.splice(0,0,String(newLang));
            _popuplation.splice(0,0,String(0));
            _numBuddies.splice(0,0,String(0));
         }
         createServerButtons();
      }
      
      public static function getShardName(shardId:int) : String
      {
         var shardIdx:int = shardId - 1;
         if(Boolean(_serverNames) && 0 <= shardIdx)
         {
            return LocalizationManager.translateIdOnly(_serverNames[shardIdx % _serverNames.length]);
         }
         return "Nullandria" + shardId;
      }
      
      public static function fillNamesArray(isFromWorld:Boolean = false) : void
      {
         if(_serverNames == null || _serverNames.length == 0)
         {
            GenericListXtCommManager.requestGenericList(16,onShardNamesCallback,null,isFromWorld);
         }
         else
         {
            RoomXtCommManager.sendMoreShardRequest();
         }
      }
      
      public static function updatePopulationForRoomFullError() : void
      {
         if(Boolean(_lastClickedShardTarget))
         {
            _lastClickedShardTarget.population = "4";
         }
      }
      
      private static function setupMoreServers(mc:MovieClip) : void
      {
         var langId:int = 0;
         var availShardsIdx:int = (_availShards[_nameIdx] - 1) % _serverNames.length;
         if(availShardsIdx < _serverNames.length)
         {
            LocalizationManager.translateId(mc.textField,_serverNames[availShardsIdx]);
            if(_numBuddies[mc.index] > 0)
            {
               mc.buddy = true;
            }
            else
            {
               mc.buddy = false;
            }
            langId = int(_languageIds[mc.index]);
            if(langId == LocalizationManager.LANG_ENG)
            {
               langId = LocalizationManager.LANG_BLANK;
            }
            mc.flag = langId + 1;
            if(_popuplation[mc.index] > 0)
            {
               mc.population = _popuplation[mc.index];
            }
            else
            {
               mc.population = "0";
            }
            ++_nameIdx;
            return;
         }
         _nameIdx = 0;
         setupMoreServers(mc);
      }
      
      private static function createServerButtons() : void
      {
         var mc:MovieClip = null;
         if(Boolean(_scrollButtons))
         {
            _scrollButtons.destroy();
            _scrollButtons = null;
         }
         if(Boolean(_itemWindows) && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         var numItemsInCurrentArray:int = int(_availShards.length);
         var xCount:int = Math.min(numItemsInCurrentArray,2);
         var yCount:int = Math.min(numItemsInCurrentArray,NUM_Y_WIN);
         _itemWindows = new WindowGenerator();
         _itemWindows.init(xCount,yCount,numItemsInCurrentArray,20,8,10,ItemWindowServer,null,"",{"mouseDown":winMouseDown},null,null,false,false);
         _serverAllContent.itemBlock.addChild(_itemWindows);
         _itemWindows.x = 0;
         _itemWindows.y = 0;
         _nameIdx = 0;
         for(var i:int = 0; i < numItemsInCurrentArray; i++)
         {
            mc = MovieClip(_itemWindows.bg.getChildAt(i));
            setupMoreServers(mc);
         }
         _scrollButtons = new SBScrollbar();
         _scrollButtons.init(_itemWindows,_serverAllContent.itemBlock.width - 31,_itemWindows.boxHeight * NUM_Y_WIN + 8 * NUM_Y_WIN,0,"scrollbar2",_itemWindows.boxHeight + 8);
         DarkenManager.showLoadingSpiral(false);
      }
      
      private static function winMouseDown(m:MouseEvent) : void
      {
         m.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         _lastClickedShardTarget = m.currentTarget;
         if(Boolean(m.currentTarget.full))
         {
            if(_closeCallback != null)
            {
               _closeCallback(_availShards[m.currentTarget.index]);
            }
         }
         else if(_closeCallback != null)
         {
            _closeCallback(_availShards[m.currentTarget.index]);
         }
      }
      
      private static function onShardNamesCallback(glId:int, locStrings:Array) : void
      {
         _serverNames = locStrings;
      }
      
      private static function onCloseBtn(evt:MouseEvent) : void
      {
         destroy();
      }
      
      private static function onNamesBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_SERVERS);
      }
      
      private static function addListeners() : void
      {
         _serverAllPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,onCloseBtn,false,0,true);
      }
      
      private static function removeListeners() : void
      {
         _serverAllPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,onCloseBtn);
      }
   }
}

