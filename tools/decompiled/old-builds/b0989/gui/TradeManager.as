package gui
{
   import avatar.Avatar;
   import avatar.AvatarEvent;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.utils.setTimeout;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TradeXtCommManager;
   
   public class TradeManager
   {
      
      public static var isCurrentlyTrading:Boolean;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _requestTradePopup:MovieClip;
      
      private static var _requestSentPopup:MovieClip;
      
      private static var _tradeRequestedPopup:MovieClip;
      
      private static var _tradeDonePopup:MovieClip;
      
      private static var _currDownMC:MovieClip;
      
      private static var _mediaViews:Array;
      
      private static var _initiationTradeList:Array;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      private static var _itemWindows:WindowGenerator;
      
      private static var _itemToTradeFor:Object;
      
      private static var _numClothingItemsInTradeList:int;
      
      private static var _numDenItemsInTradeList:int;
      
      private static var _numClothingItemsInInitiateTradeList:int;
      
      private static var _numDenItemsInInitiateTradeList:int;
      
      private static var _denClothesSelectPopup:DenAndClothesItemSelect;
      
      private static var _jammerRoomName:String;
      
      private static const REQUEST_TRADE:int = 430;
      
      private static const TRADE_REQUESTED:int = 431;
      
      private static const TRADE_DONE:int = 432;
      
      private static const ITEM_WINDOW_SIZE:int = 84;
      
      private static const TRADING_SOUNDS_MEDIA_ID:int = 1333;
      
      public static const CLOTHING_TYPE:int = 0;
      
      public static const DEN_TYPE:int = 1;
      
      public function TradeManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer) : void
      {
         _guiLayer = param1;
         _mediaViews = [];
         _initiationTradeList = [];
         _loadingSpiral = new LoadingSpiral();
         _denClothesSelectPopup = new DenAndClothesItemSelect();
      }
      
      public static function destroy() : void
      {
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
      }
      
      public static function closeAllTradingRelatedPopups() : void
      {
         if(Boolean(_requestTradePopup) && _requestTradePopup.visible)
         {
            DarkenManager.unDarken(_requestTradePopup);
            if(_requestTradePopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_requestTradePopup);
            }
            _requestTradePopup.visible = false;
            removeRequestTradeListeners();
         }
         if(Boolean(_requestSentPopup) && _requestSentPopup.visible)
         {
            DarkenManager.unDarken(_requestSentPopup);
            if(_requestSentPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_requestSentPopup);
            }
            _requestSentPopup.visible = false;
            removeRequestSentListeners();
         }
         if(Boolean(_tradeRequestedPopup) && _tradeRequestedPopup.visible)
         {
            DarkenManager.unDarken(_tradeRequestedPopup);
            if(_tradeRequestedPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeRequestedPopup);
            }
            _tradeRequestedPopup.visible = false;
            removeTradeRequestedListeners();
         }
         if(Boolean(_tradeDonePopup) && _tradeDonePopup.visible)
         {
            DarkenManager.unDarken(_tradeDonePopup);
            if(_tradeDonePopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeDonePopup);
            }
            _tradeDonePopup.visible = false;
            removeTradeDoneListeners();
         }
         _denClothesSelectPopup.destroy();
         isCurrentlyTrading = false;
      }
      
      public static function displayRequestTrade(param1:Object, param2:MovieClip = null) : void
      {
         if(Boolean(param2) && _requestTradePopup == null)
         {
            _requestTradePopup = param2.TradeInitiatePopup;
            _requestSentPopup = param2.TradeRequestSentPopup;
            _requestTradePopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _requestTradePopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            _requestSentPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _requestSentPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            _guiLayer.addChild(_requestTradePopup);
            DarkenManager.darken(_requestTradePopup);
            addRequestTradeListeners();
            _loadingSpiral.setNewParent(_requestTradePopup.itemBlock);
            _loadingSpiral.visible = true;
            buildItemWindows(_requestTradePopup.itemBlock);
            _requestTradePopup.itemBlockTheirs.itemName = _itemToTradeFor.name;
            _requestTradePopup.itemBlockTheirs.iconLayer.addChild(_itemToTradeFor.icon);
            setupItemBlock(_requestTradePopup.itemBlockTheirs,_itemToTradeFor);
            if(Boolean(param1 is DenItem) && Boolean(param1.isOcean) && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,"You will need an ocean den to see and place this item.");
            }
         }
         else if(_requestTradePopup)
         {
            _guiLayer.addChild(_requestTradePopup);
            DarkenManager.darken(_requestTradePopup);
            _requestTradePopup.visible = true;
            addRequestTradeListeners();
            _loadingSpiral.scaleX = 1;
            _loadingSpiral.scaleY = 1;
            _loadingSpiral.setNewParent(_requestTradePopup.itemBlock);
            _loadingSpiral.visible = true;
            _initiationTradeList.splice(0);
            _numClothingItemsInInitiateTradeList = 0;
            _numDenItemsInInitiateTradeList = 0;
            buildItemWindows(_requestTradePopup.itemBlock);
            while(_requestTradePopup.itemBlockTheirs.iconLayer.numChildren > 0)
            {
               _requestTradePopup.itemBlockTheirs.iconLayer.removeChildAt(0);
            }
            setupItemToTradeFor(param1);
            _requestTradePopup.itemBlockTheirs.itemName = _itemToTradeFor.name;
            _requestTradePopup.itemBlockTheirs.iconLayer.addChild(_itemToTradeFor.icon);
            setupItemBlock(_requestTradePopup.itemBlockTheirs,_itemToTradeFor);
            if(Boolean(param1 is DenItem) && Boolean(param1.isOcean) && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,"You will need an ocean den to see and place this item.");
            }
         }
         else
         {
            loadPopup(REQUEST_TRADE);
            setupItemToTradeFor(param1);
         }
      }
      
      public static function displayRequestSent() : void
      {
         if(_requestSentPopup)
         {
            _guiLayer.addChild(_requestSentPopup);
            DarkenManager.darken(_requestSentPopup);
            _requestSentPopup.visible = true;
            _loadingSpiral.scaleX = 0.5;
            _loadingSpiral.scaleY = 0.5;
            _loadingSpiral.setNewParent(_requestSentPopup.itemBlock,_requestSentPopup.itemBlock.width * 0.5,_requestSentPopup.itemBlock.height * 0.5);
            _loadingSpiral.visible = true;
            addRequestSentListeners();
         }
      }
      
      public static function displayTradeRequested(param1:Object, param2:MovieClip = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:* = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Boolean = false;
         var _loc14_:Array = null;
         var _loc15_:* = 0;
         var _loc16_:* = 0;
         var _loc17_:* = 0;
         var _loc18_:* = 0;
         if(Boolean(param2) && _tradeRequestedPopup == null)
         {
            _tradeRequestedPopup = param2.TradeRequestedPopup;
            _tradeRequestedPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _tradeRequestedPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         }
         if(_tradeRequestedPopup)
         {
            AJAudio.playTradeRequestSound();
            _tradeRequestedPopup.userNameTxt.text = param1[3];
            _tradeRequestedPopup.inventoryIsFull = false;
            _loc7_ = 6;
            _loc4_ = int(param1[_loc7_++]);
            _loc5_ = int(param1[_loc7_++]);
            _loc8_ = 0;
            _loc9_ = 0;
            _loc10_ = 0;
            _loc11_ = 0;
            _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock" + (_loc4_ + _loc5_));
            _loc12_ = 1;
            while(_loc12_ <= _loc4_)
            {
               while(_tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_].iconLayer.numChildren > 0)
               {
                  _tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_].iconLayer.removeChildAt(0);
               }
               _loc6_ = new Item();
               _loc6_.init(int(param1[_loc7_++]),0,uint(param1[_loc7_++]));
               if(_loc6_.enviroType == Utility.ENVIRO_LAND)
               {
                  _loc8_++;
               }
               else
               {
                  _loc9_++;
               }
               _tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_].itemName = _loc6_.name;
               _tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_].iconLayer.addChild(_loc6_.icon);
               setupItemBlock(_tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_],_loc6_);
               _loc12_++;
            }
            _loc12_ = 1;
            while(_loc12_ <= _loc5_)
            {
               while(_tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc4_)].iconLayer.numChildren > 0)
               {
                  _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc4_)].iconLayer.removeChildAt(0);
               }
               _loc6_ = new DenItem();
               _loc6_.init(param1[_loc7_++],0,0,param1[_loc7_++],0);
               if(_loc6_.enviroType == Utility.ENVIRO_LAND)
               {
                  _loc10_++;
               }
               else
               {
                  _loc11_++;
               }
               if(!_loc13_ && _loc6_.enviroType == Utility.ENVIRO_OCEAN && !DenSwitch.haveOceanDen())
               {
                  _loc13_ = true;
               }
               _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc4_)].itemName = _loc6_.name;
               _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc4_)].iconLayer.addChild(_loc6_.icon);
               setupItemBlock(_tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc4_)],_loc6_);
               _loc12_++;
            }
            while(_tradeRequestedPopup.itemBlockTheirs.iconLayer.numChildren > 0)
            {
               _tradeRequestedPopup.itemBlockTheirs.iconLayer.removeChildAt(0);
            }
            if(!AvatarManager.playerAvatar)
            {
               onDeclineTrade(null);
               return;
            }
            _loc15_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,Utility.ENVIRO_LAND);
            _loc16_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,Utility.ENVIRO_OCEAN);
            _loc17_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),Utility.ENVIRO_LAND);
            _loc18_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),Utility.ENVIRO_OCEAN);
            if(int(param1[4]) < 2)
            {
               _loc14_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               if(int(param1[4]) == 0)
               {
                  _loc17_--;
               }
               else
               {
                  _loc18_--;
               }
            }
            else
            {
               if(int(param1[4]) == 2)
               {
                  _loc15_--;
               }
               else
               {
                  _loc16_--;
               }
               _loc14_ = AvatarManager.playerAvatar.inventoryDenFull.itemArray;
            }
            if(_loc15_ + _loc10_ > Shop.maxDenItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc16_ + _loc11_ > Shop.maxDenItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc17_ + _loc8_ > Shop.maxItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc18_ + _loc9_ > Shop.maxItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            if(Boolean(_loc14_) && _loc14_.length > 0)
            {
               _loc12_ = 0;
               while(_loc12_ < _loc14_.length)
               {
                  if(_loc14_[_loc12_].invIdx == int(param1[5]))
                  {
                     _tradeRequestedPopup.itemBlockTheirs.iconLayer.addChild(_loc14_[_loc12_].clone().icon);
                     _tradeRequestedPopup.itemBlockTheirs.itemName = _loc14_[_loc12_].name;
                     setupItemBlock(_tradeRequestedPopup.itemBlockTheirs,_loc14_[_loc12_]);
                     break;
                  }
                  _loc12_++;
               }
            }
            _guiLayer.addChild(_tradeRequestedPopup);
            DarkenManager.darken(_tradeRequestedPopup);
            addTradeRequestedListeners();
            _tradeRequestedPopup.yesBtn.visible = false;
            _tradeRequestedPopup.noBtn.visible = false;
            setTimeout(showTradeButtonsAfterDelay,2000);
            _tradeRequestedPopup.visible = true;
            if(_loc13_)
            {
               new SBOkPopup(_guiLayer,"You will need an ocean den to see and place this item.");
            }
         }
         else
         {
            loadPopup(TRADE_REQUESTED,param1);
         }
      }
      
      public static function displayTradeDone(param1:Object, param2:MovieClip = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:UserInfo = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Avatar = null;
         var _loc10_:AvatarInfo = null;
         var _loc11_:* = 0;
         var _loc12_:Object = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Array = null;
         var _loc19_:Array = null;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:Array = null;
         var _loc24_:Array = null;
         var _loc25_:Array = null;
         var _loc26_:int = 0;
         var _loc27_:Array = null;
         var _loc28_:Array = null;
         var _loc29_:DenItem = null;
         if(Boolean(param2) && _tradeDonePopup == null)
         {
            _tradeDonePopup = param2.TradeDonePopup;
            if(_tradeDonePopup)
            {
               _tradeDonePopup.x = MainFrame.VIEW_WIDTH * 0.5;
               _tradeDonePopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            }
         }
         if(_tradeDonePopup)
         {
            AJAudio.playTradeSuccessSound();
            _loc3_ = int(param1[3]);
            _tradeDonePopup.gotoAndStop(_loc3_);
            _loc5_ = gMainFrame.userInfo.playerUserInfo;
            _loc6_ = gMainFrame.userInfo.playerUserInfo.avList;
            _loc7_ = int(gMainFrame.userInfo.playerAvatarInfo.type);
            _loc8_ = int(gMainFrame.userInfo.playerAvatarInfo.dbAvId);
            _loc9_ = AvatarManager.getAvatarByDbAvId(_loc8_);
            _loc11_ = 4;
            _loc13_ = 1;
            while(_loc13_ <= _loc3_)
            {
               while(_tradeDonePopup["itemBlock" + _loc13_].iconLayer.numChildren > 0)
               {
                  _tradeDonePopup["itemBlock" + _loc13_].iconLayer.removeChildAt(0);
               }
               if(param1[_loc11_++] == "0")
               {
                  _loc4_ = new Item();
                  _loc4_.init(int(param1[_loc11_++]),int(param1[_loc11_++]),uint(param1[_loc11_++]));
                  _loc19_ = _loc5_.fullItemList;
                  _loc19_.unshift(_loc4_);
                  _loc5_.fullItemList = _loc19_;
                  if(AvatarManager.roomEnviroType == _loc4_.enviroType)
                  {
                     _loc9_.inventoryClothing.itemArray.unshift(_loc4_);
                  }
                  _tradeDonePopup["itemBlock" + _loc13_].itemName = _loc4_.name;
                  _tradeDonePopup["itemBlock" + _loc13_].iconLayer.addChild(_loc4_.icon);
                  setupItemBlock(_tradeDonePopup["itemBlock" + _loc13_],_loc4_);
               }
               else
               {
                  _loc20_ = int(param1[_loc11_++]);
                  _loc21_ = int(param1[_loc11_++]);
                  _loc22_ = int(param1[_loc11_++]);
                  _loc4_ = new DenItem();
                  _loc4_.init(_loc21_,_loc20_,0,_loc22_,0);
                  _loc5_.denItemsFull.unshift(_loc4_.clone());
                  _tradeDonePopup["itemBlock" + _loc13_].itemName = _loc4_.name;
                  _tradeDonePopup["itemBlock" + _loc13_].iconLayer.addChild(_loc4_.icon);
                  setupItemBlock(_tradeDonePopup["itemBlock" + _loc13_],_loc4_);
               }
               _loc13_++;
            }
            SBTracker.push();
            if(_loc3_ == 1)
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted/#" + _loc4_.name);
            }
            else
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted");
            }
            _loc16_ = int(param1[_loc11_++]);
            _loc18_ = [];
            _loc13_ = 0;
            while(_loc13_ < _loc16_)
            {
               _loc17_ = int(param1[_loc11_++]);
               _loc15_ = int(param1[_loc11_++]);
               if(_loc17_ == 0)
               {
                  _loc24_ = _loc5_.getFullItemList(true);
                  _loc14_ = 0;
                  while(_loc14_ < _loc24_.length)
                  {
                     if(_loc24_[_loc14_].invIdx == _loc15_)
                     {
                        _loc24_.splice(_loc14_,1);
                        break;
                     }
                     _loc14_++;
                  }
                  _loc5_.fullItemList = _loc24_;
                  _loc25_ = _loc9_.inventoryClothing.itemArray;
                  _loc14_ = 0;
                  while(_loc14_ < _loc25_.length)
                  {
                     if(_loc25_[_loc14_].invIdx == _loc15_)
                     {
                        _loc9_.accStateHideAccessory(_loc25_[_loc14_],false);
                        _loc25_.splice(_loc14_,1);
                        break;
                     }
                     _loc14_++;
                  }
               }
               else
               {
                  _loc27_ = _loc5_.denItemsFull;
                  _loc14_ = 0;
                  while(_loc14_ < _loc27_.length)
                  {
                     if(_loc27_[_loc14_].invIdx == _loc15_)
                     {
                        if(_loc27_[_loc14_].sortId == DenItem.SORT_AUDIO && _loc27_[_loc14_].categoryId != 0)
                        {
                           _loc26_ = 0;
                           while(_loc26_ < _loc27_.length)
                           {
                              if(_loc27_[_loc26_].itemDefId == DenItem.DEF_AUDIO_DEF_ID)
                              {
                                 _loc27_[_loc26_].categoryId = 1;
                                 break;
                              }
                              _loc26_++;
                           }
                        }
                        _loc18_.push({
                           "i":_loc15_,
                           "catId":0,
                           "r":_loc27_[_loc14_].refId
                        });
                        _loc27_.splice(_loc14_,1);
                     }
                     _loc14_++;
                  }
                  _loc28_ = _loc9_.inventoryDenFull.itemArray;
                  _loc14_ = 0;
                  while(_loc14_ < _loc28_.length)
                  {
                     if(_loc28_[_loc14_].invIdx == _loc15_)
                     {
                        if(_loc28_[_loc14_].sortId == DenItem.SORT_AUDIO && _loc28_[_loc14_].categoryId != 0)
                        {
                           _loc26_ = 0;
                           while(_loc26_ < _loc28_.length)
                           {
                              if(_loc28_[_loc26_].itemDefId == DenItem.DEF_AUDIO_DEF_ID)
                              {
                                 _loc28_[_loc26_].categoryId = 1;
                                 break;
                              }
                              _loc26_++;
                           }
                        }
                        _loc28_.splice(_loc14_,1);
                     }
                     _loc14_++;
                  }
                  _loc9_.inventoryDenPartial.itemArray = [];
                  _loc5_.denItemsPartial = [];
                  for each(_loc29_ in _loc9_.inventoryDenFull.itemArray)
                  {
                     if(_loc29_.enviroType == AvatarManager.roomEnviroType)
                     {
                        _loc9_.inventoryDenPartial.itemArray.push(_loc29_);
                        _loc5_.denItemsPartial.push(_loc29_);
                     }
                  }
               }
               _loc23_ = gMainFrame.userInfo.getMyTradeList();
               _loc14_ = 0;
               while(_loc14_ < _loc23_.length)
               {
                  if(_loc23_[_loc14_].type == _loc17_ && _loc23_[_loc14_].invIdx == _loc15_)
                  {
                     _loc23_.splice(_loc14_,1);
                     if(_loc17_ == 0)
                     {
                        --_numClothingItemsInTradeList;
                     }
                     else
                     {
                        --_numDenItemsInTradeList;
                     }
                     break;
                  }
                  _loc14_++;
               }
               _loc13_++;
            }
            if(_loc18_.length > 0 && gMainFrame.server.getCurrentRoomName(false) == "den" + gMainFrame.userInfo.myUserName)
            {
               RoomManagerWorld.instance.denItemHolder.setItems(_loc18_);
            }
            if(GuiManager.denEditor)
            {
               GuiManager.denEditor.reloadDenItems();
            }
            _loc9_.dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
            GuiManager.showHudAvt();
            closeRequestSentPopup();
            _guiLayer.addChild(_tradeDonePopup);
            DarkenManager.darken(_tradeDonePopup);
            _tradeDonePopup.visible = true;
            addTradeDoneListeners();
         }
         else
         {
            loadPopup(TRADE_DONE,param1);
         }
      }
      
      private static function popupsMediaCallback(param1:MovieClip) : void
      {
         var _loc2_:Function = null;
         var _loc3_:Object = null;
         var _loc4_:MediaHelper = null;
         if(param1)
         {
            switch(param1.mediaHelper.id)
            {
               case REQUEST_TRADE:
                  _loc2_ = displayRequestTrade;
                  _loc3_ = _itemToTradeFor;
                  break;
               case TRADE_REQUESTED:
                  _loc2_ = displayTradeRequested;
                  _loc3_ = param1.passback;
                  break;
               case TRADE_DONE:
                  _loc2_ = displayTradeDone;
                  _loc3_ = param1.passback;
            }
            if(!AJAudio.hasLoadedTradeSfx)
            {
               _loc4_ = new MediaHelper();
               _loc4_.init(TRADING_SOUNDS_MEDIA_ID,onSoundsLoaded,{
                  "funcToCall":_loc2_,
                  "data":_loc3_,
                  "img":param1
               });
               _mediaViews.push(_loc4_);
            }
            else
            {
               DarkenManager.showLoadingSpiral(false);
               _loc2_(_loc3_,param1);
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
         }
      }
      
      private static function onSoundsLoaded(param1:MovieClip) : void
      {
         var _loc2_:ApplicationDomain = null;
         if(param1)
         {
            if(!AJAudio.hasLoadedTradeSfx)
            {
               _loc2_ = param1.loaderInfo.applicationDomain;
               AJAudio.loadSfx("TradeSuccessSound",_loc2_.getDefinition("TradeSuccessSound") as Class,0.5);
               AJAudio.loadSfx("TradeFailedSound",_loc2_.getDefinition("TradeFailedSound") as Class,0.5);
               AJAudio.loadSfx("TradeRequestSound",_loc2_.getDefinition("TradeRequestSound") as Class,0.7);
               AJAudio.hasLoadedTradeSfx = true;
            }
            DarkenManager.showLoadingSpiral(false);
            param1.passback.funcToCall(param1.passback.data,param1.passback.img);
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            delete param1.passback;
         }
      }
      
      private static function showTradeButtonsAfterDelay() : void
      {
         if(_tradeRequestedPopup)
         {
            _tradeRequestedPopup.yesBtn.visible = true;
            _tradeRequestedPopup.noBtn.visible = true;
         }
      }
      
      private static function loadPopup(param1:int, param2:Object = null) : void
      {
         var _loc3_:MediaHelper = null;
         DarkenManager.showLoadingSpiral(true);
         _loc3_ = new MediaHelper();
         _loc3_.init(param1,popupsMediaCallback,param2 ? param2 : true);
         _mediaViews[_mediaViews.length + 1] = _loc3_;
      }
      
      public static function onTradeItemsResponse(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = int(param1[2]);
         if(_loc2_ == 0)
         {
            if(isCurrentlyTrading)
            {
               TradeXtCommManager.sendTradeItemAcceptOrReject(2);
            }
            else
            {
               isCurrentlyTrading = true;
               SBTracker.push();
               SBTracker.trackPageview("/game/play/trading/request/received");
               displayTradeRequested(param1);
            }
         }
         else if(_loc2_ == 1)
         {
            displayTradeDone(param1);
         }
         else
         {
            isCurrentlyTrading = false;
            SBTracker.push();
            if(_loc2_ == 2)
            {
               _loc3_ = param1[3] + " has declined your trade.";
               SBTracker.trackPageview("/game/play/trading/request/denied/#" + _itemToTradeFor.name);
            }
            else if(_loc2_ == 3)
            {
               _loc3_ = param1[3] + " no longer has that item.";
               SBTracker.trackPageview("/game/play/trading/request/itemAlreadyTraded");
            }
            else if(_loc2_ == 4)
            {
               _loc3_ = param1[3] + " can\'t trade right now.";
               SBTracker.trackPageview("/game/play/trading/request/alreadyInTrade");
            }
            else
            {
               if(_loc2_ != 5)
               {
                  if(_loc2_ == 6)
                  {
                     closeTradeRequestedPopup();
                     return;
                  }
                  if(_loc2_ == 7)
                  {
                     new SBYesNoPopup(_guiLayer,"Only Jammers in the same world can trade. Do you want to join this Jammer\'s world?",true,onConfirmServerSwitch);
                     SBTracker.trackPageview("/game/play/trading/request/diffShard");
                     _jammerRoomName = param1[4];
                     closeRequestSentPopup();
                     return;
                  }
                  DebugUtility.debugTrace("This should never happen... flag=" + _loc2_);
                  closeRequestSentPopup();
                  return;
               }
               _loc3_ = param1[3] + " doesn\'t have enough inventory slots to accept this trade.";
               SBTracker.trackPageview("/game/play/trading/request/fullInventoryReceiver");
            }
            closeRequestSentPopup();
            new SBOkPopup(_guiLayer,_loc3_,true,onSBOkBtn);
         }
      }
      
      public static function onTradeListReceived(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:uint = 0;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:String = param1[2];
         var _loc4_:* = 3;
         if(gMainFrame.userInfo.myUserName == _loc3_)
         {
            _numClothingItemsInTradeList = int(param1[_loc4_++]);
            _loc5_ = 0;
            while(_loc5_ < _numClothingItemsInTradeList)
            {
               _loc4_ += 1;
               _loc2_.push({
                  "invIdx":int(param1[_loc4_++]),
                  "type":CLOTHING_TYPE
               });
               _loc4_ += 1;
               _loc5_++;
            }
            _loc6_ = int(param1[_loc4_++]);
            _numDenItemsInTradeList = _loc6_;
            _loc5_ = 0;
            while(_loc5_ < _loc6_)
            {
               _loc4_ += 1;
               _loc2_.push({
                  "invIdx":int(param1[_loc4_++]),
                  "type":DEN_TYPE
               });
               _loc4_ += 1;
               _loc5_++;
            }
            gMainFrame.userInfo.myTradeList = _loc2_;
         }
         else
         {
            _loc11_ = int(param1[_loc4_++]);
            _loc5_ = 0;
            while(_loc5_ < _loc11_)
            {
               _loc7_ = int(param1[_loc4_++]);
               _loc9_ = int(param1[_loc4_++]);
               _loc8_ = uint(param1[_loc4_++]);
               _loc10_ = new Item();
               _loc10_.init(_loc7_,_loc9_,_loc8_);
               _loc2_.push(_loc10_);
               _loc5_++;
            }
            _loc6_ = int(param1[_loc4_++]);
            _loc5_ = 0;
            while(_loc5_ < _loc6_)
            {
               _loc7_ = int(param1[_loc4_++]);
               _loc9_ = int(param1[_loc4_++]);
               _loc8_ = uint(int(param1[_loc4_++]));
               _loc10_ = new DenItem();
               _loc10_.init(_loc7_,_loc9_,0,_loc8_,0);
               _loc2_.push(_loc10_);
               _loc5_++;
            }
            BuddyCard.onTradeListReceived(_loc3_,_loc2_);
         }
      }
      
      public static function changeTradeList(param1:Array, param2:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Array = gMainFrame.userInfo.getMyTradeList();
         _loc4_ = 0;
         while(_loc4_ < param2.length)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc3_.length)
            {
               if(param2[_loc4_].invIdx == _loc3_[_loc5_].invIdx)
               {
                  _loc3_.splice(_loc5_,1);
                  break;
               }
               _loc5_++;
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_.push(param1[_loc4_]);
            _loc4_++;
         }
         gMainFrame.userInfo.myTradeList = _loc3_;
         TradeXtCommManager.sendTradeSetRequest(param1,param2);
      }
      
      public static function get initiationTradeList() : Array
      {
         return _initiationTradeList;
      }
      
      public static function get numClothingItemsInInitiateTradeList() : int
      {
         return _numClothingItemsInInitiateTradeList;
      }
      
      public static function get numDenItemsInInitiateTradeList() : int
      {
         return _numDenItemsInInitiateTradeList;
      }
      
      public static function adjustByOnNumClothingItemsInInitiateTradeList(param1:int) : void
      {
         _numClothingItemsInInitiateTradeList += param1;
      }
      
      public static function adjustByOnNumDenItemsInInitiateTradeList(param1:int) : void
      {
         _numDenItemsInInitiateTradeList += param1;
      }
      
      public static function get numClothingItemsInMyTradeList() : int
      {
         return _numClothingItemsInTradeList;
      }
      
      public static function get numDenItemsInMyTradeList() : int
      {
         return _numDenItemsInTradeList;
      }
      
      public static function adjustByOnNumClothingItemsInMyTradeList(param1:int) : void
      {
         _numClothingItemsInTradeList += param1;
      }
      
      public static function adjustByOnNumDenItemsInMyTradeList(param1:int) : void
      {
         _numDenItemsInTradeList += param1;
      }
      
      public static function resetNumTradeItems(param1:int, param2:int) : void
      {
         if(param1 != -1 && param2 != -1)
         {
            _numClothingItemsInTradeList = param2;
            _numDenItemsInTradeList = param2;
         }
      }
      
      private static function onConfirmServerSwitch(param1:Object) : void
      {
         if(Boolean(param1.status) && _jammerRoomName != "")
         {
            DarkenManager.showLoadingSpiral(true);
            RoomXtCommManager.sendRoomJoinRequest(_jammerRoomName);
         }
         _jammerRoomName = "";
      }
      
      private static function buildItemWindows(param1:MovieClip) : void
      {
         if(Boolean(_itemWindows) && _itemWindows.parent == param1)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(param1 == _requestTradePopup.itemBlock)
         {
            while(_requestTradePopup.itemBlock.numChildren > 0)
            {
               _requestTradePopup.itemBlock.removeChildAt(0);
            }
            if(_initiationTradeList.length < 1)
            {
               if(_requestTradePopup.doneBtn.hasGrayState)
               {
                  _requestTradePopup.doneBtn.activateGrayState(true);
               }
            }
            else if(_requestTradePopup.doneBtn.hasGrayState)
            {
               _requestTradePopup.doneBtn.activateGrayState(false);
            }
         }
         var _loc2_:int = 4;
         var _loc3_:int = Math.min(_loc2_,2);
         _itemWindows = new WindowGenerator();
         _itemWindows.init(_loc3_,_loc3_,_loc2_,2,2,0,ItemWindowOriginal,_initiationTradeList,"icon",{
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut
         },{
            "isTradeManager":true,
            "loadImmediately":true
         });
         param1.addChild(_itemWindows);
         _loadingSpiral.visible = false;
      }
      
      private static function addRequestTradeListeners() : void
      {
         _requestTradePopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopoup,false,0,true);
         _requestTradePopup.doneBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDoneBtn,false,0,true);
         _requestTradePopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
      }
      
      private static function removeRequestTradeListeners() : void
      {
         _requestTradePopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopoup);
         _requestTradePopup.doneBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDoneBtn);
         _requestTradePopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
      }
      
      private static function addRequestSentListeners() : void
      {
         _requestSentPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopoup,false,0,true);
         _requestSentPopup.cancelBtn.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
      }
      
      private static function removeRequestSentListeners() : void
      {
         _requestSentPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopoup);
         _requestSentPopup.cancelBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
      }
      
      private static function addTradeRequestedListeners() : void
      {
         _tradeRequestedPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopoup,false,0,true);
         _tradeRequestedPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onDeclineTrade,false,0,true);
         _tradeRequestedPopup.yesBtn.addEventListener(MouseEvent.MOUSE_DOWN,onAcceptTrade,false,0,true);
         _tradeRequestedPopup.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDeclineTrade,false,0,true);
      }
      
      private static function removeTradeRequestedListeners() : void
      {
         _tradeRequestedPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopoup);
         _tradeRequestedPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onDeclineTrade);
         _tradeRequestedPopup.yesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onAcceptTrade);
         _tradeRequestedPopup.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDeclineTrade);
      }
      
      private static function addTradeDoneListeners() : void
      {
         _tradeDonePopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopoup,false,0,true);
         _tradeDonePopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
         _tradeDonePopup.yesBtn.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
      }
      
      private static function removeTradeDoneListeners() : void
      {
         _tradeDonePopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopoup);
         _tradeDonePopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
         _tradeDonePopup.yesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
      }
      
      private static function addTradeItem(param1:Object) : void
      {
         _initiationTradeList.push(param1);
         buildItemWindows(_requestTradePopup.itemBlock);
      }
      
      private static function setupItemBlock(param1:MovieClip, param2:Object) : void
      {
         var _loc3_:String = null;
         param1.removeBtn.visible = false;
         param1.addBtn.visible = false;
         param1.gray.visible = false;
         param1.lock.visible = false;
         param1.lockOpen.visible = false;
         param1.gift.visible = false;
         param1.ocean.visible = false;
         param1.rare.visible = false;
         param1.avtSpecific.visible = false;
         param1.avtSpecificHighlight.visible = false;
         param1.avtSpecificIcon.visible = false;
         param1.addEventListener(MouseEvent.MOUSE_OVER,onItemWindowOver,false,0,true);
         param1.addEventListener(MouseEvent.MOUSE_OUT,onItemWindowOut,false,0,true);
         if(param2)
         {
            if(param2.isMemberOnly)
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  param1.lock.visible = true;
               }
               else
               {
                  param1.lockOpen.visible = true;
               }
            }
            param1.extraToolTipText = param2.extraTooltipInfo;
            if(param2 is Item)
            {
               param1.defId = param2.defId;
               if(param2.getInUse(0))
               {
                  param1.cir.gotoAndStop("down");
               }
               if(Boolean(AvatarManager.playerAvatar) && Boolean(!ItemXtCommManager.canUseItem(param2.defId,AvatarManager.playerAvatar.avTypeId)) && ItemXtCommManager.isItemSpecificToSomeAvatar(param2.defId,param2.enviroType))
               {
                  _loc3_ = String(ItemXtCommManager.getFirstAvTypeThatCanUseItem(param2.defId));
                  if(_loc3_ != "-1")
                  {
                     if(param1.avtSpecific.currentFrameLabel != _loc3_)
                     {
                        param1.avtSpecific.gotoAndStop(_loc3_);
                     }
                     param1.avtSpecific.visible = true;
                  }
               }
            }
            else if(param2 is DenItem)
            {
               if(param2.categoryId != 0)
               {
                  param1.cir.gotoAndStop("down");
               }
            }
            if(param2.isOcean)
            {
               param1.ocean.visible = true;
            }
            if(param2.isRare)
            {
               param1.rare.visible = true;
            }
         }
      }
      
      private static function findItem(param1:Object) : Object
      {
         var _loc2_:Array = BuddyCard.getTradeList();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if((param1.type == CLOTHING_TYPE && _loc2_[_loc3_] is Item || param1.type == DEN_TYPE && _loc2_[_loc3_] is DenItem) && param1.invIdx == _loc2_[_loc3_].invIdx)
            {
               return _loc2_[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      private static function setupItemToTradeFor(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         if(param1 != null)
         {
            _loc3_ = findItem(param1);
            if(_loc3_)
            {
               if(param1.type == CLOTHING_TYPE)
               {
                  _loc2_ = new Item();
                  _loc2_.init(_loc3_.defId,_loc3_.invIdx,_loc3_.color,_loc3_.inUseFlagLand > 0 ? -1 : 0,_loc3_.inUseFlagOcean > 0 ? -1 : 0);
               }
               else
               {
                  _loc2_ = new DenItem();
                  _loc2_.init(_loc3_.itemDefId,_loc3_.invIdx,_loc3_.categoryId,_loc3_.version,0);
               }
               _itemToTradeFor = _loc2_;
            }
            else
            {
               DebugUtility.debugTrace("cannot find that trade item!");
            }
         }
         else
         {
            DebugUtility.debugTrace("itemToTrade is null???");
         }
      }
      
      private static function winMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         param1.stopPropagation();
         if(param1.currentTarget.isAvatarSpecific)
         {
            _loc2_ = String(ItemXtCommManager.getFirstAvTypeThatCanUseItem(param1.currentTarget.defId));
            if(_loc2_ != "-1")
            {
               if(param1.currentTarget.avtSpecificIcon.currentFrameLabel != _loc2_)
               {
                  param1.currentTarget.avtSpecificIcon.gotoAndStop(_loc2_);
               }
               param1.currentTarget.avtSpecificIcon.visible = true;
               param1.currentTarget.avtSpecificHighlight.visible = true;
               return;
            }
         }
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "down")
            {
               param1.currentTarget.cir.gotoAndStop("downMouse");
            }
            else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("over");
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private static function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isAvatarSpecific)
         {
            param1.currentTarget.avtSpecificIcon.visible = false;
            param1.currentTarget.avtSpecificHighlight.visible = false;
            return;
         }
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("down");
            }
            else
            {
               param1.currentTarget.cir.gotoAndStop("up");
            }
         }
      }
      
      private static function winMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(param1.currentTarget.removeBtn.visible)
         {
            if(_initiationTradeList[param1.currentTarget.index] is Item)
            {
               adjustByOnNumClothingItemsInInitiateTradeList(-1);
            }
            else
            {
               adjustByOnNumDenItemsInInitiateTradeList(-1);
            }
            _initiationTradeList.splice(param1.currentTarget.index,1);
            buildItemWindows(_requestTradePopup.itemBlock);
         }
         else if(param1.currentTarget.addBtn.visible)
         {
            _denClothesSelectPopup.init(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),AvatarManager.playerAvatar.inventoryDenFull.itemArray,_guiLayer,null,addTradeItem,false,true);
         }
      }
      
      private static function onPopoup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onSBOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         SBTracker.flush(true);
      }
      
      private static function onDoneBtn(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         param1.stopPropagation();
         if(!_requestTradePopup.doneBtn.isGray)
         {
            _loc2_ = [];
            _loc3_ = [];
            _loc4_ = [];
            _loc5_ = [];
            _loc6_ = 0;
            while(_loc6_ < 3)
            {
               _loc4_[_loc6_] = 0;
               _loc5_[_loc6_] = 0;
               _loc6_++;
            }
            _loc7_ = 0;
            _loc8_ = 0;
            while(_loc8_ < _initiationTradeList.length)
            {
               if(_initiationTradeList[_loc8_] is Item)
               {
                  ++_loc4_[_initiationTradeList[_loc8_].enviroType];
                  _loc2_.push(_initiationTradeList[_loc8_].invIdx);
               }
               else if(_initiationTradeList[_loc8_] is DenItem)
               {
                  if(_initiationTradeList[_loc8_].sortId == DenItem.SORT_AUDIO)
                  {
                     _loc7_++;
                  }
                  else
                  {
                     ++_loc5_[_initiationTradeList[_loc8_].enviroType];
                  }
                  _loc3_.push(_initiationTradeList[_loc8_].invIdx);
               }
               _loc8_++;
            }
            _numClothingItemsInInitiateTradeList = 0;
            _numDenItemsInInitiateTradeList = 0;
            SBTracker.push();
            _loc9_ = true;
            if(_itemToTradeFor is Item)
            {
               if(_itemToTradeFor.enviroType == Utility.ENVIRO_LAND)
               {
                  if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),Utility.ENVIRO_LAND) + 1 - _loc4_[Utility.ENVIRO_LAND] > Shop.maxItems)
                  {
                     _loc9_ = false;
                  }
               }
               else if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),Utility.ENVIRO_OCEAN) + 1 - _loc4_[Utility.ENVIRO_OCEAN] > Shop.maxItems)
               {
                  _loc9_ = false;
               }
            }
            else if(_itemToTradeFor.sortId == DenItem.SORT_AUDIO)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,-1,true) + 1 - _loc7_ > Shop.maxAudioItems)
               {
                  _loc9_ = false;
               }
            }
            else if(_itemToTradeFor.enviroType == Utility.ENVIRO_LAND)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,Utility.ENVIRO_LAND) + 1 - _loc5_[Utility.ENVIRO_LAND] > Shop.maxDenItems)
               {
                  _loc9_ = false;
               }
            }
            else if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,Utility.ENVIRO_OCEAN) + 1 - _loc5_[Utility.ENVIRO_OCEAN] > Shop.maxDenItems)
            {
               _loc9_ = false;
            }
            if(_loc9_)
            {
               SBTracker.trackPageview("/game/play/trading/request/initiated");
               TradeXtCommManager.sendTradeItemsRequest(BuddyCard.currBuddyCardUserName,_itemToTradeFor.invIdx,_itemToTradeFor is Item,_loc2_,_loc3_,_loc7_);
               onClose(param1);
               displayRequestSent();
            }
            else
            {
               onClose(param1);
               TradeXtCommManager.sendTradeBusyRequest(false);
               isCurrentlyTrading = false;
               SBTracker.trackPageview("/game/play/trading/request/fullInventorySender");
               new SBOkPopup(_guiLayer,"You don\'t have enough inventory slots to complete this trade! Recycle items to free up space.",true,onSBOkBtn);
            }
            BuddyCard.closeBuddyCard();
         }
      }
      
      private static function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.unDarken(param1.currentTarget.parent);
         if(param1.currentTarget.parent.parent == _guiLayer)
         {
            _guiLayer.removeChild(param1.currentTarget.parent);
         }
         param1.currentTarget.parent.visible = false;
         switch(param1.currentTarget.parent)
         {
            case _requestTradePopup:
               removeRequestTradeListeners();
               if(param1.currentTarget.name == "bx")
               {
                  SBTracker.flush(true);
                  TradeXtCommManager.sendTradeBusyRequest(false);
                  isCurrentlyTrading = false;
               }
               break;
            case _tradeRequestedPopup:
               SBTracker.flush(true);
               removeTradeRequestedListeners();
               break;
            case _requestSentPopup:
               SBTracker.flush(true);
               TradeXtCommManager.sendTradeItemCancel();
               TradeXtCommManager.sendTradeBusyRequest(false);
               removeRequestSentListeners();
               isCurrentlyTrading = false;
               break;
            case _tradeDonePopup:
               SBTracker.flush(true);
               removeTradeDoneListeners();
               TradeXtCommManager.sendTradeBusyRequest(false);
               isCurrentlyTrading = false;
               GuiManager.closeAnyInventoryRelatedWindows();
         }
      }
      
      private static function closeRequestSentPopup() : void
      {
         if(Boolean(_requestSentPopup) && _requestSentPopup.visible)
         {
            AJAudio.playTradeFailedSound();
            DarkenManager.unDarken(_requestSentPopup);
            if(_requestSentPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_requestSentPopup);
            }
            _requestSentPopup.visible = false;
            removeRequestSentListeners();
         }
      }
      
      private static function closeTradeRequestedPopup() : void
      {
         if(Boolean(_tradeRequestedPopup) && _tradeRequestedPopup.visible)
         {
            DarkenManager.unDarken(_tradeRequestedPopup);
            if(_tradeRequestedPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeRequestedPopup);
            }
            _tradeRequestedPopup.visible = false;
            removeTradeRequestedListeners();
         }
      }
      
      private static function onAcceptTrade(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(_guiLayer,"Are you sure you want to accept this trade?",true,onConfirmAcceptTrade,param1);
      }
      
      private static function onConfirmAcceptTrade(param1:Object) : void
      {
         if(param1.status)
         {
            if(_tradeRequestedPopup.inventoryIsFull)
            {
               new SBOkPopup(_guiLayer,"You don\'t have enough inventory slots to complete this trade! Recycle items to free up space.",true,onSBOkBtn);
               isCurrentlyTrading = false;
            }
            TradeXtCommManager.sendTradeItemAcceptOrReject(1);
            onClose(param1.passback);
         }
      }
      
      private static function onDeclineTrade(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         TradeXtCommManager.sendTradeItemAcceptOrReject(0);
         if(param1)
         {
            onClose(param1);
         }
         else
         {
            closeTradeRequestedPopup();
         }
         TradeXtCommManager.sendTradeBusyRequest(false);
         isCurrentlyTrading = false;
      }
      
      private static function onItemWindowOver(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1.currentTarget.avtSpecific.visible)
         {
            _loc2_ = String(ItemXtCommManager.getFirstAvTypeThatCanUseItem(param1.currentTarget.defId));
            if(_loc2_ != "-1")
            {
               if(param1.currentTarget.avtSpecificIcon.currentFrameLabel != _loc2_)
               {
                  param1.currentTarget.avtSpecificIcon.gotoAndStop(_loc2_);
               }
               param1.currentTarget.avtSpecificIcon.visible = true;
               param1.currentTarget.avtSpecificHighlight.visible = true;
               return;
            }
         }
         if(param1.currentTarget.itemName != null)
         {
            GuiManager.toolTip.init(MovieClip(param1.currentTarget),param1.currentTarget.itemName,ITEM_WINDOW_SIZE * 0.5,ITEM_WINDOW_SIZE);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private static function onItemWindowOut(param1:MouseEvent) : void
      {
         if(param1.currentTarget.avtSpecific.visible)
         {
            param1.currentTarget.avtSpecificIcon.visible = false;
            param1.currentTarget.avtSpecificHighlight.visible = false;
            return;
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
   }
}

