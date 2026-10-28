package gui
{
   import avatar.Avatar;
   import avatar.AvatarEvent;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.utils.setTimeout;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TradeConfirmPopup;
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
      
      private static var _itemWindowTheirs:WindowGenerator;
      
      private static var _itemToTradeFor:Object;
      
      private static var _numClothingItemsInTradeList:int;
      
      private static var _numDenItemsInTradeList:int;
      
      private static var _numClothingItemsInInitiateTradeList:int;
      
      private static var _numDenItemsInInitiateTradeList:int;
      
      private static var _denClothesSelectPopup:DenAndClothesItemSelect;
      
      private static var _jammerRoomName:String;
      
      private static var _loadingSpiralAvatar:LoadingSpiral;
      
      private static var _tradeRequestedPlayerUsername:String;
      
      private static var _tradeRequestAvatar:Avatar;
      
      private static var _tradeRequestAvatarView:AvatarView;
      
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
            buildItemWindows(_requestTradePopup.itemBlock,_initiationTradeList);
            buildItemWindows(_requestTradePopup.itemBlockTheirs,[_itemToTradeFor],true);
            if(Boolean(param1 is DenItem) && Boolean(param1.isOcean) && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else if(_requestTradePopup)
         {
            setupItemToTradeFor(param1);
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
            buildItemWindows(_requestTradePopup.itemBlock,_initiationTradeList);
            buildItemWindows(_requestTradePopup.itemBlockTheirs,[_itemToTradeFor],true);
            if(Boolean(param1 is DenItem) && Boolean(param1.isOcean) && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
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
         var _loc3_:AvatarInfo = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:* = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:* = 0;
         var _loc17_:* = 0;
         var _loc18_:* = 0;
         var _loc19_:* = 0;
         if(Boolean(param2) && _tradeRequestedPopup == null)
         {
            _tradeRequestedPopup = param2.TradeRequestedPopup;
            _tradeRequestedPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _tradeRequestedPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         }
         if(_tradeRequestedPopup)
         {
            AJAudio.playTradeRequestSound();
            _loadingSpiralAvatar = new LoadingSpiral(_tradeRequestedPopup.charBox);
            _tradeRequestedPlayerUsername = param1[3];
            _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserName(_tradeRequestedPlayerUsername);
            if(!_loc3_)
            {
               AvatarXtCommManager.requestAvatarGet(_tradeRequestedPlayerUsername,onAvatarGetReceived);
            }
            else
            {
               onAvatarGetReceived(_tradeRequestedPlayerUsername,true,0,_loc3_);
            }
            _tradeRequestedPopup.inventoryIsFull = false;
            _loc8_ = 7;
            _loc5_ = int(param1[_loc8_++]);
            _loc6_ = int(param1[_loc8_++]);
            _loc9_ = 0;
            _loc10_ = 0;
            _loc11_ = 0;
            _loc12_ = 0;
            if(!AvatarManager.playerAvatar)
            {
               onDeclineTrade(null);
               return;
            }
            _loc16_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,SbiConstants.ENVIRO_LAND);
            _loc17_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,SbiConstants.ENVIRO_OCEAN);
            _loc18_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),SbiConstants.ENVIRO_LAND);
            _loc19_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),SbiConstants.ENVIRO_OCEAN);
            if(int(param1[5]) < 2)
            {
               _loc13_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               if(int(param1[5]) == 0)
               {
                  _loc18_--;
               }
               else
               {
                  _loc19_--;
               }
            }
            else
            {
               if(int(param1[5]) == 2)
               {
                  _loc16_--;
               }
               else
               {
                  _loc17_--;
               }
               _loc13_ = AvatarManager.playerAvatar.inventoryDenFull.itemArray;
            }
            if(_loc16_ + _loc11_ > Shop.maxDenItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc17_ + _loc12_ > Shop.maxDenItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc18_ + _loc9_ > Shop.maxItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc19_ + _loc10_ > Shop.maxItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            _guiLayer.addChild(_tradeRequestedPopup);
            DarkenManager.darken(_tradeRequestedPopup);
            addTradeRequestedListeners();
            _tradeRequestedPopup.yesBtn.visible = false;
            _tradeRequestedPopup.noBtn.visible = false;
            _tradeRequestedPopup.visible = true;
            _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock" + (_loc5_ + _loc6_));
            _loc14_ = 1;
            while(_loc14_ <= _loc5_)
            {
               while(_tradeRequestedPopup.itemBlocks["itemBlock" + _loc14_].iconLayer.numChildren > 0)
               {
                  _tradeRequestedPopup.itemBlocks["itemBlock" + _loc14_].iconLayer.removeChildAt(0);
               }
               _loc7_ = new Item();
               _loc7_.init(int(param1[_loc8_++]),0,uint(param1[_loc8_++]));
               if(_loc7_.enviroType == SbiConstants.ENVIRO_LAND)
               {
                  _loc9_++;
               }
               else
               {
                  _loc10_++;
               }
               _tradeRequestedPopup.itemBlocks["itemBlock" + _loc14_].itemName = _loc7_.name;
               _tradeRequestedPopup.itemBlocks["itemBlock" + _loc14_].iconLayer.addChild(_loc7_.icon);
               setupItemBlock(_tradeRequestedPopup.itemBlocks["itemBlock" + _loc14_],_loc7_);
               _loc14_++;
            }
            _loc14_ = 1;
            while(_loc14_ <= _loc6_)
            {
               while(_tradeRequestedPopup.itemBlocks["itemBlock" + (_loc14_ + _loc5_)].iconLayer.numChildren > 0)
               {
                  _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc14_ + _loc5_)].iconLayer.removeChildAt(0);
               }
               _loc7_ = new DenItem();
               _loc7_.init(param1[_loc8_++],0,0,param1[_loc8_++],0);
               if(_loc7_.enviroType == SbiConstants.ENVIRO_LAND)
               {
                  _loc11_++;
               }
               else
               {
                  _loc12_++;
               }
               if(!_loc15_ && _loc7_.enviroType == SbiConstants.ENVIRO_OCEAN && !DenSwitch.haveOceanDen())
               {
                  _loc15_ = true;
               }
               _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc14_ + _loc5_)].itemName = _loc7_.name;
               _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc14_ + _loc5_)].iconLayer.addChild(_loc7_.icon);
               setupItemBlock(_tradeRequestedPopup.itemBlocks["itemBlock" + (_loc14_ + _loc5_)],_loc7_);
               _loc14_++;
            }
            while(_tradeRequestedPopup.itemBlockTheirs.iconLayer.numChildren > 0)
            {
               _tradeRequestedPopup.itemBlockTheirs.iconLayer.removeChildAt(0);
            }
            if(Boolean(_loc13_) && _loc13_.length > 0)
            {
               _loc14_ = 0;
               while(_loc14_ < _loc13_.length)
               {
                  if(_loc13_[_loc14_].invIdx == int(param1[6]))
                  {
                     _tradeRequestedPopup.itemBlockTheirs.iconLayer.addChild(_loc13_[_loc14_].clone().icon);
                     _tradeRequestedPopup.itemBlockTheirs.itemName = _loc13_[_loc14_].name;
                     setupItemBlock(_tradeRequestedPopup.itemBlockTheirs,_loc13_[_loc14_]);
                     break;
                  }
                  _loc14_++;
               }
            }
            setTimeout(showTradeButtonsAfterDelay,2000);
            if(_loc15_)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
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
         var _loc13_:Array = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:Array = null;
         var _loc20_:Array = null;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:Array = null;
         var _loc25_:Array = null;
         var _loc26_:Array = null;
         var _loc27_:int = 0;
         var _loc28_:Array = null;
         var _loc29_:Array = null;
         var _loc30_:DenItem = null;
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
            _guiLayer.addChild(_tradeDonePopup);
            DarkenManager.darken(_tradeDonePopup);
            _tradeDonePopup.visible = true;
            addTradeDoneListeners();
            _tradeDonePopup.gotoAndStop(_loc3_);
            _loc5_ = gMainFrame.userInfo.playerUserInfo;
            _loc6_ = gMainFrame.userInfo.playerUserInfo.avList;
            _loc7_ = int(gMainFrame.userInfo.playerAvatarInfo.type);
            _loc8_ = int(gMainFrame.userInfo.playerAvatarInfo.perUserAvId);
            _loc9_ = AvatarManager.getAvatarByUsernamePerUserAvId(_loc5_.userName,_loc8_);
            _loc11_ = 4;
            _loc13_ = [];
            _loc14_ = 1;
            while(_loc14_ <= _loc3_)
            {
               if(param1[_loc11_++] == "0")
               {
                  _loc4_ = new Item();
                  _loc4_.init(int(param1[_loc11_++]),int(param1[_loc11_++]),uint(param1[_loc11_++]));
                  _loc20_ = _loc5_.fullItemList;
                  _loc20_.unshift(_loc4_);
                  _loc5_.fullItemList = _loc20_;
                  if(AvatarManager.roomEnviroType == _loc4_.enviroType)
                  {
                     _loc9_.inventoryClothing.itemArray.unshift(_loc4_);
                  }
               }
               else
               {
                  _loc21_ = int(param1[_loc11_++]);
                  _loc22_ = int(param1[_loc11_++]);
                  _loc23_ = int(param1[_loc11_++]);
                  _loc4_ = new DenItem();
                  _loc4_.init(_loc22_,_loc21_,0,_loc23_,0);
                  _loc5_.denItemsFull.unshift(_loc4_.clone());
               }
               _loc13_.push(_loc4_);
               _loc14_++;
            }
            buildItemWindows(_tradeDonePopup.itemBlock,_loc13_);
            SBTracker.push();
            if(_loc3_ == 1)
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted/#" + (_loc4_ is Item ? "accessory" : "den item") + "#0#" + _loc4_.itemDefId,-1,SBTracker.TYPE_EVENT);
            }
            else
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted",-1,SBTracker.TYPE_EVENT);
            }
            _loc17_ = int(param1[_loc11_++]);
            _loc19_ = [];
            _loc14_ = 0;
            while(_loc14_ < _loc17_)
            {
               _loc18_ = int(param1[_loc11_++]);
               _loc16_ = int(param1[_loc11_++]);
               if(_loc18_ == 0)
               {
                  _loc25_ = _loc5_.getFullItemList(true);
                  _loc15_ = 0;
                  while(_loc15_ < _loc25_.length)
                  {
                     if(_loc25_[_loc15_].invIdx == _loc16_)
                     {
                        _loc25_.splice(_loc15_,1);
                        break;
                     }
                     _loc15_++;
                  }
                  _loc5_.fullItemList = _loc25_;
                  _loc26_ = _loc9_.inventoryClothing.itemArray;
                  _loc15_ = 0;
                  while(_loc15_ < _loc26_.length)
                  {
                     if(_loc26_[_loc15_].invIdx == _loc16_)
                     {
                        _loc9_.accStateHideAccessory(_loc26_[_loc15_],false);
                        _loc26_.splice(_loc15_,1);
                        break;
                     }
                     _loc15_++;
                  }
               }
               else
               {
                  _loc28_ = _loc5_.denItemsFull;
                  _loc15_ = 0;
                  while(_loc15_ < _loc28_.length)
                  {
                     if(_loc28_[_loc15_].invIdx == _loc16_)
                     {
                        if(_loc28_[_loc15_].sortId == DenItem.SORT_AUDIO && _loc28_[_loc15_].categoryId != 0)
                        {
                           _loc27_ = 0;
                           while(_loc27_ < _loc28_.length)
                           {
                              if(_loc28_[_loc27_].itemDefId == DenItem.DEF_AUDIO_DEF_ID)
                              {
                                 _loc28_[_loc27_].categoryId = 1;
                                 break;
                              }
                              _loc27_++;
                           }
                        }
                        _loc19_.push({
                           "i":_loc16_,
                           "catId":0,
                           "r":_loc28_[_loc15_].refId
                        });
                        _loc28_.splice(_loc15_,1);
                     }
                     _loc15_++;
                  }
                  _loc29_ = _loc9_.inventoryDenFull.itemArray;
                  _loc15_ = 0;
                  while(_loc15_ < _loc29_.length)
                  {
                     if(_loc29_[_loc15_].invIdx == _loc16_)
                     {
                        if(_loc29_[_loc15_].sortId == DenItem.SORT_AUDIO && _loc29_[_loc15_].categoryId != 0)
                        {
                           _loc27_ = 0;
                           while(_loc27_ < _loc29_.length)
                           {
                              if(_loc29_[_loc27_].itemDefId == DenItem.DEF_AUDIO_DEF_ID)
                              {
                                 _loc29_[_loc27_].categoryId = 1;
                                 break;
                              }
                              _loc27_++;
                           }
                        }
                        _loc29_.splice(_loc15_,1);
                     }
                     _loc15_++;
                  }
                  _loc9_.inventoryDenPartial.itemArray = [];
                  _loc5_.denItemsPartial = [];
                  for each(_loc30_ in _loc9_.inventoryDenFull.itemArray)
                  {
                     if(_loc30_.enviroType == AvatarManager.roomEnviroType)
                     {
                        _loc9_.inventoryDenPartial.itemArray.push(_loc30_);
                        _loc5_.denItemsPartial.push(_loc30_);
                     }
                  }
               }
               _loc24_ = gMainFrame.userInfo.getMyTradeList();
               _loc15_ = 0;
               while(_loc15_ < _loc24_.length)
               {
                  if(_loc24_[_loc15_].type == _loc18_ && _loc24_[_loc15_].invIdx == _loc16_)
                  {
                     _loc24_.splice(_loc15_,1);
                     if(_loc18_ == 0)
                     {
                        --_numClothingItemsInTradeList;
                     }
                     else
                     {
                        --_numDenItemsInTradeList;
                     }
                     break;
                  }
                  _loc15_++;
               }
               _loc14_++;
            }
            if(_loc19_.length > 0 && gMainFrame.server.getCurrentRoomName(false) == "den" + gMainFrame.userInfo.myUserName)
            {
               RoomManagerWorld.instance.denItemHolder.setItems(_loc19_);
            }
            if(GuiManager.denEditor)
            {
               GuiManager.denEditor.reloadDenItems();
            }
            _loc9_.dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
            GuiManager.showHudAvt();
            closeRequestSentPopup();
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
      
      private static function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:AvatarInfo = null) : void
      {
         var _loc5_:UserInfo = null;
         if(param2 && param1.toLowerCase() == _tradeRequestedPlayerUsername.toLowerCase())
         {
            if(!param4)
            {
               param4 = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
               if(!param4)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(_tradeRequestedPlayerUsername);
            if(param4.isMember)
            {
               _tradeRequestedPopup.nonmember.visible = false;
               _tradeRequestedPopup.userName_txt.visible = false;
               _tradeRequestedPopup.member.setNubType("buddy",false);
               _tradeRequestedPopup.member.setColorAndBadge(_loc5_.nameBarData);
               _tradeRequestedPopup.member.isBlocked = false;
               _tradeRequestedPopup.member.setAvName(_loc5_.getModeratedUserName(),false);
               _tradeRequestedPopup.member.mouseEnabled = false;
               _tradeRequestedPopup.member.mouseChildren = false;
            }
            else
            {
               _tradeRequestedPopup.member.visible = false;
               _tradeRequestedPopup.userName_txt.visible = true;
               _tradeRequestedPopup.userName_txt.text = _loc5_.getModeratedUserName();
            }
            _tradeRequestAvatar = AvatarManager.getAvatarByUserName(_tradeRequestedPlayerUsername);
            if(_tradeRequestAvatar == null)
            {
               _tradeRequestAvatar = AvatarUtility.generateNew(param4.perUserAvId,null,_tradeRequestedPlayerUsername,-1,0,onAvatarItemData);
            }
            drawMainAvatar(_tradeRequestAvatar);
         }
         else
         {
            onDeclineTrade(null);
         }
      }
      
      public static function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && _tradeRequestAvatar != null)
         {
            drawMainAvatar(_tradeRequestAvatar);
         }
         else
         {
            onDeclineTrade(null);
         }
      }
      
      private static function drawMainAvatar(param1:Avatar) : void
      {
         if(Utility.isOcean(param1.enviroTypeFlag))
         {
            if(Utility.isLand(param1.enviroTypeFlag))
            {
               _tradeRequestedPopup.charBox.gotoAndStop(3);
            }
            else
            {
               _tradeRequestedPopup.charBox.gotoAndStop(2);
            }
         }
         else
         {
            _tradeRequestedPopup.charBox.gotoAndStop(1);
         }
         _tradeRequestAvatarView = new AvatarView();
         _tradeRequestAvatarView.init(param1);
         if(param1.avTypeId >= 0)
         {
            _tradeRequestAvatarView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,positionAndAddMainAvatarView);
         }
      }
      
      private static function positionAndAddMainAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc4_:MovieClip = null;
         var _loc3_:Point = BuddyCard.getAvOffsetByDefId(_tradeRequestAvatarView.avTypeId);
         _tradeRequestAvatarView.x = _loc3_.x;
         _tradeRequestAvatarView.y = _loc3_.y;
         if(Boolean(_tradeRequestedPopup) && Boolean(_tradeRequestAvatar))
         {
            if(Utility.isOcean(_tradeRequestAvatar.enviroTypeFlag))
            {
               if(Utility.isLand(_tradeRequestAvatar.enviroTypeFlag))
               {
                  _loc4_ = _tradeRequestedPopup.charBox.beach;
               }
               else
               {
                  _loc4_ = _tradeRequestedPopup.charBox.ocean;
               }
            }
            else
            {
               _loc4_ = _tradeRequestedPopup.charBox.land;
            }
            while(_loc4_.numChildren > 1)
            {
               _loc4_.removeChildAt(_loc4_.numChildren - 1);
            }
            _loc4_.addChild(_tradeRequestAvatarView);
         }
         _loadingSpiralAvatar.visible = false;
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
               SBTracker.trackPageview("/game/play/trading/request/received",-1,SBTracker.TYPE_EVENT);
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
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11386,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               SBTracker.trackPageview("/game/play/trading/request/denied/#" + (_itemToTradeFor is Item ? "accessory" : "den item") + "/#0/#" + _itemToTradeFor.itemDefId,-1,SBTracker.TYPE_EVENT);
            }
            else if(_loc2_ == 3)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11387,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               SBTracker.trackPageview("/game/play/trading/request/itemAlreadyTraded",-1,SBTracker.TYPE_EVENT);
            }
            else if(_loc2_ == 4)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11388,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               SBTracker.trackPageview("/game/play/trading/request/alreadyInTrade",-1,SBTracker.TYPE_EVENT);
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
                     if(QuestManager.isInPrivateAdventureState)
                     {
                        QuestManager.showLeaveQuestLobbyPopup(onTradeItemsResponse,param1);
                     }
                     else
                     {
                        new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14704),true,onConfirmServerSwitch);
                     }
                     SBTracker.trackPageview("/game/play/trading/request/diffShard",-1,SBTracker.TYPE_EVENT);
                     _jammerRoomName = param1[3];
                     closeRequestSentPopup();
                     return;
                  }
                  DebugUtility.debugTrace("This should never happen... flag=" + _loc2_);
                  closeRequestSentPopup();
                  return;
               }
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11389,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               SBTracker.trackPageview("/game/play/trading/request/fullInventoryReceiver",-1,SBTracker.TYPE_EVENT);
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
         if(gMainFrame.userInfo.myUserName.toLowerCase() == _loc3_.toLowerCase())
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
      
      private static function buildItemWindows(param1:MovieClip, param2:Array, param3:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc4_:WindowGenerator = param3 ? _itemWindowTheirs : _itemWindows;
         if(_loc4_)
         {
            _loc4_.destroy();
         }
         var _loc5_:Array = param2;
         var _loc8_:int = int(_loc5_.length);
         var _loc12_:Object = {
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut
         };
         if(Boolean(_requestTradePopup) && param1 == _requestTradePopup.itemBlock)
         {
            _loc9_ = true;
            _loc6_ = 2;
            _loc8_ = 4;
            _loc7_ = true;
            _loc10_ = _loc11_ = Math.min(_loc8_,_loc6_);
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
         else if(Boolean(_requestTradePopup) && param1 == _requestTradePopup.itemBlockTheirs)
         {
            _loc6_ = 1;
            _loc7_ = true;
            _loc11_ = _loc10_ = 1;
            while(_requestTradePopup.itemBlockTheirs.numChildren > 0)
            {
               _requestTradePopup.itemBlockTheirs.removeChildAt(0);
            }
         }
         else if(Boolean(_tradeDonePopup) && param1 == _tradeDonePopup.itemBlock)
         {
            _loc11_ = _loc8_;
            _loc10_ = 1;
            while(_tradeDonePopup.itemBlock.numChildren > 0)
            {
               _tradeDonePopup.itemBlock.removeChildAt(0);
            }
         }
         _loc4_ = new WindowGenerator();
         _loc4_.init(_loc11_,_loc10_,_loc8_,2,2,0,ItemWindowOriginal,_loc5_,"icon",_loc12_,{
            "isTradeManager":_loc7_,
            "loadImmediately":true,
            "showAddRemoveBtns":_loc9_
         });
         param1.addChild(_loc4_);
         if(param3)
         {
            _itemWindowTheirs;
         }
         else
         {
            _itemWindows = _loc4_;
         }
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
         buildItemWindows(_requestTradePopup.itemBlock,_initiationTradeList);
      }
      
      private static function setupItemBlock(param1:MovieClip, param2:Object) : void
      {
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
         param1.rareDiamondTag.visible = false;
         param1.diamond.visible = false;
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
            if(param2.isRareDiamond)
            {
               param1.rareDiamondTag.visible = true;
            }
            else
            {
               param1.rare.visible = param2.isRare;
               param1.diamond.visible = param2.isDiamond;
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
         param1.stopPropagation();
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
            buildItemWindows(_requestTradePopup.itemBlock,_initiationTradeList);
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
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         param1.stopPropagation();
         if(!_requestTradePopup.doneBtn.isGray)
         {
            _loc4_ = 0;
            while(_loc4_ < _initiationTradeList.length)
            {
               if(_initiationTradeList[_loc4_].isDiamond)
               {
                  _loc2_++;
               }
               if(_initiationTradeList[_loc4_].isRare)
               {
                  _loc3_++;
               }
               _loc4_++;
            }
            _loc5_ = TradeConfirmPopup.TYPE_NORMAL;
            if(_loc2_ > 0 && _loc3_ > 0)
            {
               _loc5_ = TradeConfirmPopup.TYPE_RARE_DIAMOND;
            }
            else if(_loc2_ == 1)
            {
               _loc5_ = TradeConfirmPopup.TYPE_DIAMOND;
            }
            else if(_loc2_ > 1)
            {
               _loc5_ = TradeConfirmPopup.TYPE_DIAMONDS;
            }
            else if(_loc3_ == 1)
            {
               _loc5_ = TradeConfirmPopup.TYPE_RARE;
            }
            else if(_loc3_ > 1)
            {
               _loc5_ = TradeConfirmPopup.TYPE_RARES;
            }
            if(_loc5_ != TradeConfirmPopup.TYPE_NORMAL)
            {
               _requestTradePopup.tradeConfirmPopup = new TradeConfirmPopup(_guiLayer,_loc5_,onConfirmSendTradeRequest,param1);
            }
            else
            {
               setupAndSendTradeRequest(param1);
            }
         }
      }
      
      private static function onConfirmSendTradeRequest(param1:Boolean, param2:Object) : void
      {
         _requestTradePopup.tradeConfirmPopup.destroy();
         _requestTradePopup.tradeConfirmPopup = null;
         if(param1)
         {
            setupAndSendTradeRequest(MouseEvent(param2));
         }
      }
      
      private static function setupAndSendTradeRequest(param1:MouseEvent) : void
      {
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:int = 0;
         while(_loc6_ < 3)
         {
            _loc4_[_loc6_] = 0;
            _loc5_[_loc6_] = 0;
            _loc6_++;
         }
         var _loc7_:int = 0;
         var _loc8_:int = 0;
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
         var _loc9_:Boolean = true;
         if(_itemToTradeFor is Item)
         {
            if(_itemToTradeFor.enviroType == SbiConstants.ENVIRO_LAND)
            {
               if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),SbiConstants.ENVIRO_LAND) + 1 - _loc4_[SbiConstants.ENVIRO_LAND] > Shop.maxItems)
               {
                  _loc9_ = false;
               }
            }
            else if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),SbiConstants.ENVIRO_OCEAN) + 1 - _loc4_[SbiConstants.ENVIRO_OCEAN] > Shop.maxItems)
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
         else if(_itemToTradeFor.enviroType == SbiConstants.ENVIRO_LAND)
         {
            if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,SbiConstants.ENVIRO_LAND) + 1 - _loc5_[SbiConstants.ENVIRO_LAND] > Shop.maxDenItems)
            {
               _loc9_ = false;
            }
         }
         else if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,SbiConstants.ENVIRO_OCEAN) + 1 - _loc5_[SbiConstants.ENVIRO_OCEAN] > Shop.maxDenItems)
         {
            _loc9_ = false;
         }
         if(_loc9_)
         {
            SBTracker.trackPageview("/game/play/trading/request/initiated",-1,SBTracker.TYPE_EVENT);
            TradeXtCommManager.sendTradeItemsRequest(BuddyCard.currBuddyCardUserName,_itemToTradeFor.invIdx,_itemToTradeFor is Item,_loc2_,_loc3_,_loc7_);
            onClose(param1);
            displayRequestSent();
         }
         else
         {
            onClose(param1);
            TradeXtCommManager.sendTradeBusyRequest(false);
            isCurrentlyTrading = false;
            SBTracker.trackPageview("/game/play/trading/request/fullInventorySender",-1,SBTracker.TYPE_EVENT);
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14804),true,onSBOkBtn);
         }
         BuddyCard.closeBuddyCard();
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
            if(_tradeRequestedPopup.tradeConfirmPopup)
            {
               _tradeRequestedPopup.tradeConfirmPopup.destroy();
               _tradeRequestedPopup.tradeConfirmPopup = null;
            }
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
         var _loc2_:int = TradeConfirmPopup.TYPE_NORMAL;
         if(_tradeRequestedPopup.itemBlockTheirs.diamond.visible)
         {
            _loc2_ = TradeConfirmPopup.TYPE_DIAMOND;
         }
         else if(_tradeRequestedPopup.itemBlockTheirs.rare.visible)
         {
            _loc2_ = TradeConfirmPopup.TYPE_RARE;
         }
         else if(_tradeRequestedPopup.itemBlockTheirs.rareDiamondTag.visible)
         {
            _loc2_ = TradeConfirmPopup.TYPE_RARE_DIAMOND;
         }
         _tradeRequestedPopup.tradeConfirmPopup = new TradeConfirmPopup(_guiLayer,_loc2_,onConfirmAcceptTrade);
         _tradeRequestedPopup.currentMouseTarget = param1;
      }
      
      private static function onConfirmAcceptTrade(param1:Boolean) : void
      {
         _tradeRequestedPopup.tradeConfirmPopup.destroy();
         _tradeRequestedPopup.tradeConfirmPopup = null;
         if(param1)
         {
            if(_tradeRequestedPopup.inventoryIsFull)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14804),true,onSBOkBtn);
               isCurrentlyTrading = false;
            }
            TradeXtCommManager.sendTradeItemAcceptOrReject(1);
            onClose(_tradeRequestedPopup.currentMouseTarget);
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
         if(param1.currentTarget.itemName != null)
         {
            GuiManager.toolTip.init(MovieClip(param1.currentTarget.parent),param1.currentTarget.itemName,ITEM_WINDOW_SIZE * 0.5 + param1.currentTarget.x,ITEM_WINDOW_SIZE + param1.currentTarget.y);
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

