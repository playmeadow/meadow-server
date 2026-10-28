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
      
      private static var _serverFiveContent:MovieClip;
      
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
      
      private static const NUM_Y_WIN:int = 10;
      
      public function ServerSelector()
      {
         super();
      }
      
      public static function init(param1:DisplayObjectContainer, param2:Object, param3:Function = null, param4:int = 450, param5:int = 275) : void
      {
         _popupLayer = param1;
         _closeCallback = param3;
         _availShards = [];
         _serverNames = [];
         _numBuddies = [];
         _languageIds = [];
         _popuplation = [];
         _nameIdx = 0;
         fillArray(param2);
         fillNamesArray();
         _serverFiveContent = GETDEFINITIONBYNAME("ServerPopups");
         _serverFiveContent.x = param4;
         _serverFiveContent.y = param5;
         _popupLayer.addChild(_serverFiveContent);
         _serverAllContent = GETDEFINITIONBYNAME("ServerAllPopupContent");
         _serverAllPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ServerAllPopupSkin"),_serverAllContent,false,true,false,false,true);
         _serverAllPopup.bxClosesPopup = false;
         _serverAllPopup.x = param4;
         _serverAllPopup.y = param5;
         setInitialConditions();
         addListeners();
      }
      
      public static function closeAllServerPopup() : void
      {
         if(_serverAllPopup.visible)
         {
            _serverAllPopup.close();
         }
      }
      
      public static function isOpen() : Boolean
      {
         if(Boolean(_serverFiveContent) || Boolean(_serverAllPopup))
         {
            return true;
         }
         return false;
      }
      
      public static function destroy() : void
      {
         removeListeners();
         if(_serverAllPopup)
         {
            _serverAllPopup.x = undefined;
            _serverAllPopup.y = undefined;
            _serverAllPopup.destroy();
            _serverAllPopup = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _popupLayer.removeChild(_serverFiveContent);
         _serverFiveContent = null;
         _closeCallback = null;
      }
      
      public static function setupAllShards(param1:Object) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         var _loc6_:int = -1;
         _availShards = [];
         _languageIds = [];
         _popuplation = [];
         _numBuddies = [];
         while(param1[_loc2_] != null)
         {
            _loc4_ = param1[_loc2_ + 2] == 0;
            if((_loc4_) && _loc3_ > 4)
            {
               if(_loc6_ == -1)
               {
                  _loc6_ = int(param1[_loc2_]);
               }
               _loc2_ += 4;
            }
            else
            {
               _availShards[_loc3_] = param1[_loc2_++];
               _languageIds[_loc3_] = param1[_loc2_++];
               _loc5_ += int(param1[_loc2_]);
               _popuplation[_loc3_] = param1[_loc2_++];
               _numBuddies[_loc3_] = param1[_loc2_++];
               _loc3_++;
            }
         }
         if(_loc5_ >= _availShards.length * 3 && _loc3_ < _serverNames.length)
         {
            if(_loc6_ == -1)
            {
               _loc7_ = _loc3_ + 1;
               _loc8_ = LocalizationManager.accountLanguage;
            }
            else
            {
               _loc7_ = _loc6_;
               _loc8_ = int(_languageIds[_loc6_]);
            }
            _availShards.push(String(_loc7_));
            _languageIds.push(String(_loc8_));
            _popuplation.push(String(0));
            _numBuddies.push(String(0));
         }
         createServerButtons();
      }
      
      public static function getShardName(param1:int) : String
      {
         var _loc2_:int = param1 - 1;
         if(Boolean(_serverNames) && 0 <= _loc2_)
         {
            return LocalizationManager.translateIdOnly(_serverNames[_loc2_ % _serverNames.length]);
         }
         return "Nullandria" + param1;
      }
      
      public static function fillArray(param1:Object) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         _availShards = [];
         _languageIds = [];
         _popuplation = [];
         _numBuddies = [];
         while(param1[_loc2_] != null)
         {
            _availShards[_loc3_] = param1[_loc2_++];
            _languageIds[_loc3_] = param1[_loc2_++];
            _popuplation[_loc3_] = param1[_loc2_++];
            _numBuddies[_loc3_] = param1[_loc2_++];
            _loc3_++;
         }
      }
      
      public static function reloadServerSelector(param1:Object) : Function
      {
         closeAllServerPopup();
         fillArray(param1);
         setupButtons();
         return null;
      }
      
      private static function setInitialConditions() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < 5)
         {
            _serverFiveContent["s" + (_loc1_ + 1)].buddy.visible = false;
            _serverFiveContent["s" + (_loc1_ + 1)].buddy.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].o1.visible = false;
            _serverFiveContent["s" + (_loc1_ + 1)].o1.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].o2.visible = false;
            _serverFiveContent["s" + (_loc1_ + 1)].o2.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].o3.visible = false;
            _serverFiveContent["s" + (_loc1_ + 1)].o3.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].g1.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].g2.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].g3.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].full.visible = false;
            _serverFiveContent["s" + (_loc1_ + 1)].full.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].full.mouseChildren = false;
            _serverFiveContent["s" + (_loc1_ + 1)].txt.mouseEnabled = false;
            _serverFiveContent["s" + (_loc1_ + 1)].txt.text = "";
            _loc1_++;
         }
      }
      
      public static function setupButtons() : void
      {
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         MovieClip(_serverAllPopup.content).helpNameBtn.visible = false;
         var _loc2_:int = 0;
         while(_loc2_ < _availShards.length)
         {
            _loc1_ = (_availShards[_loc2_] - 1) % _serverNames.length;
            LocalizationManager.translateId(_serverFiveContent["s" + (_loc2_ + 1)].txt,_serverNames[_loc1_]);
            _serverFiveContent["s" + (_loc2_ + 1)].serverId = _availShards[_loc2_];
            if(_numBuddies[_loc2_] > 0)
            {
               _serverFiveContent["s" + (_loc2_ + 1)].buddy.visible = true;
            }
            else
            {
               _serverFiveContent["s" + (_loc2_ + 1)].buddy.visible = false;
            }
            _loc3_ = int(_languageIds[_loc2_]);
            _serverFiveContent["s" + (_loc2_ + 1)].flag.gotoAndStop(_loc3_ + 1);
            if(_popuplation[_loc2_] > 0)
            {
               switch(_popuplation[_loc2_])
               {
                  case "1":
                     _serverFiveContent["s" + (_loc2_ + 1)].o1.visible = true;
                     break;
                  case "2":
                     _serverFiveContent["s" + (_loc2_ + 1)].o1.visible = true;
                     _serverFiveContent["s" + (_loc2_ + 1)].o2.visible = true;
                     break;
                  case "3":
                     _serverFiveContent["s" + (_loc2_ + 1)].o1.visible = true;
                     _serverFiveContent["s" + (_loc2_ + 1)].o2.visible = true;
                     _serverFiveContent["s" + (_loc2_ + 1)].o3.visible = true;
                     break;
                  case "4":
                     _serverFiveContent["s" + (_loc2_ + 1)].full.visible = true;
               }
            }
            _loc2_++;
         }
      }
      
      public static function fillNamesArray(param1:Boolean = false) : void
      {
         if(_serverNames == null || _serverNames.length == 0)
         {
            GenericListXtCommManager.requestGenericList(16,onShardNamesCallback,null,param1);
         }
      }
      
      private static function setupMoreServers(param1:MovieClip) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = (_availShards[_nameIdx] - 1) % _serverNames.length;
         if(_loc2_ < _serverNames.length)
         {
            LocalizationManager.translateId(param1.textField,_serverNames[_loc2_]);
            if(_numBuddies[param1.index] > 0)
            {
               param1.buddy = true;
            }
            else
            {
               param1.buddy = false;
            }
            _loc3_ = int(_languageIds[param1.index]);
            param1.flag = _loc3_ + 1;
            if(_popuplation[param1.index] > 0)
            {
               param1.population = _popuplation[param1.index];
            }
            else
            {
               param1.population = "0";
            }
            ++_nameIdx;
            return;
         }
         _nameIdx = 0;
         setupMoreServers(param1);
      }
      
      private static function createServerButtons() : void
      {
         var _loc5_:MovieClip = null;
         if(_scrollButtons)
         {
            _scrollButtons.destroy();
            _scrollButtons = null;
         }
         if(Boolean(_itemWindows) && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         var _loc1_:int = int(_availShards.length);
         var _loc2_:int = Math.min(_loc1_,2);
         var _loc3_:int = Math.min(_loc1_,NUM_Y_WIN);
         _itemWindows = new WindowGenerator();
         _itemWindows.init(_loc2_,_loc3_,_loc1_,20,8,10,ItemWindowServer,null,"",{"mouseDown":winMouseDown},null,null,false,false);
         _serverAllContent.itemBlock.addChild(_itemWindows);
         _itemWindows.x = 0;
         _itemWindows.y = 0;
         _nameIdx = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_)
         {
            _loc5_ = MovieClip(_itemWindows.bg.getChildAt(_loc4_));
            setupMoreServers(_loc5_);
            _loc4_++;
         }
         _scrollButtons = new SBScrollbar();
         _scrollButtons.init(_itemWindows,_serverAllContent.itemBlock.width - 31,_itemWindows.boxHeight * NUM_Y_WIN + 8 * NUM_Y_WIN,0,"scrollbar2",_itemWindows.boxHeight + 8);
         DarkenManager.showLoadingSpiral(false);
      }
      
      private static function winMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         if(param1.currentTarget.full)
         {
            if(_closeCallback != null)
            {
               _closeCallback(_availShards[param1.currentTarget.index]);
            }
         }
         else if(_closeCallback != null)
         {
            _closeCallback(_availShards[param1.currentTarget.index]);
         }
      }
      
      private static function onShardNamesCallback(param1:int, param2:Array) : void
      {
         _serverNames = param2;
         if(_serverFiveContent)
         {
            LoadProgress.show(false);
            DarkenManager.showLoadingSpiral(false);
            SBTracker.trackPageview("/game/play/shardSelection");
            setupButtons();
         }
      }
      
      private static function onServerBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         if(param1.currentTarget.full.visible == true)
         {
            if(_closeCallback != null)
            {
               _closeCallback(param1.currentTarget.parent[param1.currentTarget.name].serverId);
            }
         }
         else if(_closeCallback != null)
         {
            _closeCallback(param1.currentTarget.parent[param1.currentTarget.name].serverId);
         }
      }
      
      private static function onMoreBtn(param1:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/shardDetail");
         param1.stopPropagation();
         RoomXtCommManager.sendMoreShardRequest();
         _serverAllPopup.open();
         DarkenManager.showLoadingSpiral(true);
      }
      
      private static function onCloseBtn(param1:MouseEvent) : void
      {
         closeAllServerPopup();
         SBTracker.pop();
      }
      
      private static function onNamesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_SERVERS);
      }
      
      private static function addListeners() : void
      {
         _serverFiveContent.s1.addEventListener(MouseEvent.MOUSE_DOWN,onServerBtn,false,0,true);
         _serverFiveContent.s2.addEventListener(MouseEvent.MOUSE_DOWN,onServerBtn,false,0,true);
         _serverFiveContent.s3.addEventListener(MouseEvent.MOUSE_DOWN,onServerBtn,false,0,true);
         _serverFiveContent.s4.addEventListener(MouseEvent.MOUSE_DOWN,onServerBtn,false,0,true);
         _serverFiveContent.s5.addEventListener(MouseEvent.MOUSE_DOWN,onServerBtn,false,0,true);
         _serverFiveContent.seeMoreBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMoreBtn,false,0,true);
         _serverAllPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,onCloseBtn,false,0,true);
         MovieClip(_serverAllPopup.content).helpNameBtn.addEventListener(MouseEvent.MOUSE_DOWN,onNamesBtn,false,0,true);
      }
      
      private static function removeListeners() : void
      {
         _serverFiveContent.s1.removeEventListener(MouseEvent.MOUSE_DOWN,onServerBtn);
         _serverFiveContent.s2.removeEventListener(MouseEvent.MOUSE_DOWN,onServerBtn);
         _serverFiveContent.s3.removeEventListener(MouseEvent.MOUSE_DOWN,onServerBtn);
         _serverFiveContent.s4.removeEventListener(MouseEvent.MOUSE_DOWN,onServerBtn);
         _serverFiveContent.s5.removeEventListener(MouseEvent.MOUSE_DOWN,onServerBtn);
         _serverFiveContent.seeMoreBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMoreBtn);
         _serverAllPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,onCloseBtn);
         MovieClip(_serverAllPopup.content).helpNameBtn.addEventListener(MouseEvent.MOUSE_DOWN,onNamesBtn,false,0,true);
      }
   }
}

