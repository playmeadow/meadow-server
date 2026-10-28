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
      
      private static const REQUEST_TRADE:int = 430;
      
      private static const TRADE_REQUESTED:int = 431;
      
      private static const TRADE_DONE:int = 432;
      
      private static const ITEM_WINDOW_SIZE:int = 84;
      
      private static const TRADE_REVIEW_CONFIRM:int = 4432;
      
      private static const TRADE_WAITING:int = 4456;
      
      private static const TRADING_SOUNDS_MEDIA_ID:int = 1333;
      
      public static const CLOTHING_TYPE:int = 0;
      
      public static const DEN_TYPE:int = 1;
      
      private static var _isCurrentlyTrading:Boolean;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _requestTradePopup:MovieClip;
      
      private static var _requestSentPopup:MovieClip;
      
      private static var _tradeRequestedPopup:MovieClip;
      
      private static var _tradeDonePopup:MovieClip;
      
      private static var _currDownMC:MovieClip;
      
      private static var _tradeConfirmPopup:MovieClip;
      
      private static var _mediaViews:Array;
      
      private static var _initiationTradeList:Array;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      private static var _itemWindows:WindowAndScrollbarGenerator;
      
      private static var _itemWindowTheirs:WindowAndScrollbarGenerator;
      
      private static var _itemToTradeFor:Object;
      
      private static var _listOfItemsBeingOffered:Array;
      
      private static var _itemBeingTaken:Object;
      
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
         if(_requestTradePopup && _requestTradePopup.visible)
         {
            DarkenManager.unDarken(_requestTradePopup);
            if(_requestTradePopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_requestTradePopup);
            }
            _requestTradePopup.visible = false;
            removeRequestTradeListeners();
         }
         if(_requestSentPopup && _requestSentPopup.visible)
         {
            DarkenManager.unDarken(_requestSentPopup);
            if(_requestSentPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_requestSentPopup);
            }
            _requestSentPopup.visible = false;
            removeRequestSentListeners();
         }
         if(_tradeRequestedPopup && _tradeRequestedPopup.visible)
         {
            DarkenManager.unDarken(_tradeRequestedPopup);
            if(_tradeRequestedPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeRequestedPopup);
            }
            _tradeRequestedPopup.visible = false;
            removeTradeRequestedListeners();
         }
         if(_tradeDonePopup && _tradeDonePopup.visible)
         {
            DarkenManager.unDarken(_tradeDonePopup);
            if(_tradeDonePopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeDonePopup);
            }
            _tradeDonePopup.visible = false;
            removeTradeDoneListeners();
         }
         if(_tradeConfirmPopup)
         {
            DarkenManager.unDarken(_tradeConfirmPopup);
            if(_tradeConfirmPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeConfirmPopup);
            }
            removeTradeConfirmListeners();
         }
         _denClothesSelectPopup.destroy();
         isCurrentlyTrading = false;
      }
      
      public static function displayRequestTrade(param1:Object, param2:MovieClip = null) : void
      {
         if(param2 && _requestTradePopup == null)
         {
            _requestTradePopup = param2.TradeInitiatePopup;
            _requestSentPopup = param2.TradeRequestSentPopup;
            _requestTradePopup.x = 900 * 0.5;
            _requestTradePopup.y = 550 * 0.5;
            _requestSentPopup.x = 900 * 0.5;
            _requestSentPopup.y = 550 * 0.5;
            _guiLayer.addChild(_requestTradePopup);
            DarkenManager.darken(_requestTradePopup);
            addRequestTradeListeners();
            _loadingSpiral.setNewParent(_requestTradePopup.itemBlock);
            _loadingSpiral.visible = true;
            buildItemWindows(_requestTradePopup.itemBlock,_initiationTradeList);
            buildItemWindows(_requestTradePopup.itemBlockTheirs,[_itemToTradeFor],true);
            LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,23695,_initiationTradeList.length);
            if(param1 is DenItem && param1.isOcean && !DenSwitch.haveOceanDen())
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
            _requestTradePopup.gotoAndStop("four");
            buildItemWindows(_requestTradePopup.itemBlock,_initiationTradeList);
            buildItemWindows(_requestTradePopup.itemBlockTheirs,[_itemToTradeFor],true);
            LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,23695,_initiationTradeList.length);
            if(param1 is DenItem && param1.isOcean && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else
         {
            loadPopup(430);
            setupItemToTradeFor(param1);
         }
      }
      
      public static function displayRequestSent(param1:Object = null, param2:MovieClip = null) : void
      {
         if(_requestSentPopup || param2)
         {
            if(param2)
            {
               _requestSentPopup = param2.TradeRequestSentPopup;
               _requestSentPopup.x = 900 * 0.5;
               _requestSentPopup.y = 550 * 0.5;
            }
            _guiLayer.addChild(_requestSentPopup);
            DarkenManager.darken(_requestSentPopup);
            _requestSentPopup.visible = true;
            _loadingSpiral.scaleX = 0.5;
            _loadingSpiral.scaleY = 0.5;
            _loadingSpiral.setNewParent(_requestSentPopup.itemBlock,_requestSentPopup.itemBlock.width * 0.5,_requestSentPopup.itemBlock.height * 0.5);
            _loadingSpiral.visible = true;
            addRequestSentListeners();
         }
         else
         {
            loadPopup(4456);
         }
      }
      
      public static function displayTradeRequested(param1:Object, param2:MovieClip = null) : void
      {
         var _loc17_:int = 0;
         var _loc15_:int = 0;
         var _loc13_:Object = null;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:int = 0;
         var _loc20_:int = 0;
         var _loc22_:int = 0;
         var _loc21_:Array = null;
         var _loc14_:int = 0;
         var _loc19_:int = 0;
         var _loc18_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:AvatarInfo = null;
         var _loc11_:Boolean = false;
         var _loc16_:Array = null;
         var _loc12_:int = 0;
         var _loc10_:Boolean = false;
         var _loc6_:MovieClip = null;
         if(param2 && _tradeRequestedPopup == null)
         {
            _tradeRequestedPopup = param2.TradeRequestedPopup;
            _tradeRequestedPopup.x = 900 * 0.5;
            _tradeRequestedPopup.y = 550 * 0.5;
         }
         if(_tradeRequestedPopup)
         {
            AJAudio.playTradeRequestSound();
            _loadingSpiralAvatar = new LoadingSpiral(_tradeRequestedPopup.charBox);
            _tradeRequestedPlayerUsername = param1[3];
            _tradeRequestedPopup.inventoryIsFull = false;
            _loc9_ = 7;
            _loc17_ = int(param1[_loc9_++]);
            _loc15_ = int(param1[_loc9_++]);
            _loc8_ = 0;
            _loc3_ = 0;
            _loc20_ = 0;
            _loc22_ = 0;
            if(!AvatarManager.playerAvatar)
            {
               onDeclineTrade(null);
               return;
            }
            _loc14_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,0);
            _loc19_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,1);
            _loc18_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),0);
            _loc4_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),1);
            if(int(param1[5]) < 2)
            {
               _loc21_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               if(int(param1[5]) == 0)
               {
                  _loc18_--;
               }
               else
               {
                  _loc4_--;
               }
            }
            else
            {
               if(int(param1[5]) == 2)
               {
                  _loc14_--;
               }
               else
               {
                  _loc19_--;
               }
               _loc21_ = AvatarManager.playerAvatar.inventoryDenFull.itemArray;
            }
            if(_loc14_ + _loc20_ > Shop.maxDenItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc19_ + _loc22_ > Shop.maxDenItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc18_ + _loc8_ > Shop.maxItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(_loc4_ + _loc3_ > Shop.maxItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            _guiLayer.addChild(_tradeRequestedPopup);
            DarkenManager.darken(_tradeRequestedPopup);
            addTradeRequestedListeners();
            _tradeRequestedPopup.yesBtn.visible = false;
            _tradeRequestedPopup.noBtn.visible = false;
            _tradeRequestedPopup.visible = true;
            _loc5_ = _loc17_ + _loc15_;
            _tradeRequestedPopup.totalNumOfItems = _loc5_;
            _loc7_ = gMainFrame.userInfo.getAvatarInfoByUserName(_tradeRequestedPlayerUsername);
            if(!_loc7_)
            {
               AvatarXtCommManager.requestAvatarGet(_tradeRequestedPlayerUsername,onAvatarGetReceived);
            }
            else
            {
               onAvatarGetReceived(_tradeRequestedPlayerUsername,true,0,_loc7_);
            }
            if(_itemWindows)
            {
               _itemWindows.destroy();
               _itemWindows = null;
            }
            _loc16_ = [];
            if(_loc5_ > 4)
            {
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock5");
               _loc11_ = true;
            }
            else
            {
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock" + _loc5_);
               _loc11_ = false;
            }
            _loc12_ = 1;
            while(_loc12_ <= _loc17_)
            {
               _loc13_ = new Item();
               _loc13_.init(int(param1[_loc9_++]),0,uint(param1[_loc9_++]));
               if(_loc13_.enviroType == 0)
               {
                  _loc8_++;
               }
               else
               {
                  _loc3_++;
               }
               _loc16_.push(_loc13_);
               if(!_loc11_)
               {
                  while(_tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_].iconLayer.numChildren > 0)
                  {
                     _tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_].iconLayer.removeChildAt(0);
                  }
                  _tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_].itemName = _loc13_.name;
                  _tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_].iconLayer.addChild(_loc13_.icon);
                  setupItemBlock(_tradeRequestedPopup.itemBlocks["itemBlock" + _loc12_],_loc13_);
               }
               _loc12_++;
            }
            _loc12_ = 1;
            while(_loc12_ <= _loc15_)
            {
               _loc13_ = new DenItem();
               _loc13_.init(param1[_loc9_++],0,0,param1[_loc9_++],0);
               if(_loc13_.enviroType == 0)
               {
                  _loc20_++;
               }
               else
               {
                  _loc22_++;
               }
               if(!_loc10_ && _loc13_.enviroType == 1 && !DenSwitch.haveOceanDen())
               {
                  _loc10_ = true;
               }
               _loc16_.push(_loc13_);
               if(!_loc11_)
               {
                  while(_tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc17_)].iconLayer.numChildren > 0)
                  {
                     _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc17_)].iconLayer.removeChildAt(0);
                  }
                  _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc17_)].itemName = _loc13_.name;
                  _tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc17_)].iconLayer.addChild(_loc13_.icon);
                  setupItemBlock(_tradeRequestedPopup.itemBlocks["itemBlock" + (_loc12_ + _loc17_)],_loc13_);
               }
               _loc12_++;
            }
            _listOfItemsBeingOffered = _loc16_;
            if(_loc11_)
            {
               _loc6_ = _tradeRequestedPopup.itemBlocks.itemBlock;
               while(_loc6_.numChildren > 3)
               {
                  _loc6_.removeChildAt(_loc6_.numChildren - 1);
               }
               _itemWindows = new WindowAndScrollbarGenerator();
               _itemWindows.init("widthCont" in _loc6_ ? _loc6_.widthCont.width : _loc6_.width,"widthCont" in _loc6_ ? _loc6_.widthCont.height : _loc6_.height,0,0,2,_loc16_.length / 2,0,2,3,0,ItemWindowOriginal,_loc16_,"icon",0,{
                  "mouseOver":onItemWindowOver,
                  "mouseOut":onItemWindowOut
               },{
                  "isTradeManager":true,
                  "loadImmediately":false,
                  "showAddRemoveBtns":false
               },null,false,false,true,false,true);
               _loc6_.addChild(_itemWindows);
               LocalizationManager.translateIdAndInsert(_tradeRequestedPopup.itemBlocks.txtCounter_ba.counterTxt,23695,_loc16_.length);
            }
            while(_tradeRequestedPopup.itemBlockTheirs.iconLayer.numChildren > 0)
            {
               _tradeRequestedPopup.itemBlockTheirs.iconLayer.removeChildAt(0);
            }
            if(_loc21_ && _loc21_.length > 0)
            {
               _loc12_ = 0;
               while(_loc12_ < _loc21_.length)
               {
                  if(_loc21_[_loc12_].invIdx == int(param1[6]))
                  {
                     _loc13_ = _loc21_[_loc12_].clone();
                     _tradeRequestedPopup.itemBlockTheirs.iconLayer.addChild(_loc13_.icon);
                     _tradeRequestedPopup.itemBlockTheirs.itemName = _loc13_.name;
                     setupItemBlock(_tradeRequestedPopup.itemBlockTheirs,_loc13_);
                     _itemBeingTaken = _loc13_;
                     break;
                  }
                  _loc12_++;
               }
            }
            setTimeout(showTradeButtonsAfterDelay,2000);
            if(_loc10_)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else
         {
            loadPopup(431,param1);
         }
      }
      
      public static function displayTradeConfirmPopup(param1:Object = null, param2:MovieClip = null) : void
      {
         var _loc4_:Array = null;
         var _loc3_:Object = null;
         if(param2 && _tradeConfirmPopup == null)
         {
            _tradeConfirmPopup = param2.tradeReviewConfirm;
            if(_tradeConfirmPopup)
            {
               _tradeConfirmPopup.x = 900 * 0.5;
               _tradeConfirmPopup.y = 550 * 0.5;
            }
         }
         if(_tradeConfirmPopup)
         {
            _tradeConfirmPopup.visible = true;
            _guiLayer.addChild(_tradeConfirmPopup);
            DarkenManager.darken(_tradeConfirmPopup);
            addTradeConfirmListeners();
            _loc4_ = _listOfItemsBeingOffered != null ? _listOfItemsBeingOffered : _initiationTradeList;
            buildItemWindows(_tradeConfirmPopup.itemBlock,_loc4_);
            while(_tradeConfirmPopup.itemBlockTheirs.iconLayer.numChildren > 0)
            {
               _tradeConfirmPopup.itemBlockTheirs.iconLayer.removeChildAt(0);
            }
            _loc3_ = _itemToTradeFor != null ? _itemToTradeFor : _itemBeingTaken;
            _tradeConfirmPopup.itemBlockTheirs.iconLayer.addChild(_loc3_.clone().icon);
            _tradeConfirmPopup.itemBlockTheirs.itemName = _loc3_.name;
            setupItemBlock(_tradeConfirmPopup.itemBlockTheirs,_loc3_);
            LocalizationManager.translateIdAndInsert(_tradeConfirmPopup.txtCounter_ba.counterTxt,_loc4_.length == 1 ? 23696 : 23695,_loc4_.length);
         }
         else
         {
            loadPopup(4432);
         }
      }
      
      public static function displayTradeDone(param1:Object, param2:MovieClip = null) : void
      {
         var _loc3_:int = 0;
         var _loc26_:Object = null;
         var _loc23_:UserInfo = null;
         var _loc17_:Object = null;
         var _loc14_:int = 0;
         var _loc9_:int = 0;
         var _loc4_:Avatar = null;
         var _loc22_:* = null;
         var _loc21_:int = 0;
         var _loc28_:* = null;
         var _loc30_:Array = null;
         var _loc25_:int = 0;
         var _loc19_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc8_:int = 0;
         var _loc24_:int = 0;
         var _loc6_:int = 0;
         var _loc15_:int = 0;
         var _loc7_:int = 0;
         var _loc16_:Array = null;
         var _loc12_:Array = null;
         var _loc29_:Array = null;
         var _loc18_:int = 0;
         var _loc13_:Array = null;
         var _loc5_:Array = null;
         var _loc20_:Array = null;
         if(param2 && _tradeDonePopup == null)
         {
            _tradeDonePopup = param2.TradeDonePopup;
            if(_tradeDonePopup)
            {
               _tradeDonePopup.x = 900 * 0.5;
               _tradeDonePopup.y = 550 * 0.5;
            }
         }
         if(_tradeDonePopup)
         {
            AJAudio.playTradeSuccessSound();
            _loc3_ = int(param1[4]);
            _guiLayer.addChild(_tradeDonePopup);
            DarkenManager.darken(_tradeDonePopup);
            _tradeDonePopup.visible = true;
            addTradeDoneListeners();
            _tradeDonePopup.gotoAndStop(Math.min(5,_loc3_));
            _loc23_ = gMainFrame.userInfo.playerUserInfo;
            _loc17_ = gMainFrame.userInfo.playerUserInfo.avList;
            _loc14_ = int(gMainFrame.userInfo.playerAvatarInfo.type);
            _loc9_ = int(gMainFrame.userInfo.playerAvatarInfo.perUserAvId);
            _loc4_ = AvatarManager.getAvatarByUsernamePerUserAvId(_loc23_.userName,_loc9_);
            _loc21_ = 5;
            _loc30_ = [];
            _loc25_ = 1;
            while(_loc25_ <= _loc3_)
            {
               if(param1[_loc21_++] == "0")
               {
                  _loc26_ = new Item();
                  _loc26_.init(int(param1[_loc21_++]),int(param1[_loc21_++]),uint(param1[_loc21_++]));
                  _loc19_ = _loc23_.fullItemList;
                  _loc19_.unshift(_loc26_);
                  _loc23_.fullItemList = _loc19_;
                  if(AvatarManager.roomEnviroType == _loc26_.enviroType)
                  {
                     _loc4_.inventoryClothing.itemArray.unshift(_loc26_);
                  }
               }
               else
               {
                  _loc10_ = int(param1[_loc21_++]);
                  _loc11_ = int(param1[_loc21_++]);
                  _loc8_ = int(param1[_loc21_++]);
                  _loc26_ = new DenItem();
                  _loc26_.init(_loc11_,_loc10_,0,_loc8_,0);
                  _loc23_.denItemsFull.unshift(_loc26_.clone());
               }
               _loc30_.push(_loc26_);
               _loc25_++;
            }
            if(_loc30_.length > 4)
            {
               LocalizationManager.translateIdAndInsert(_tradeDonePopup.txtCounter_ba.counterTxt,_loc30_.length == 1 ? 23696 : 23695,_loc30_.length);
            }
            buildItemWindows(_tradeDonePopup.itemBlock,_loc30_);
            SBTracker.push();
            if(_loc3_ == 1)
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted/#" + (_loc26_ is Item ? "accessory" : "den item") + "#0#" + _loc26_.itemDefId,-1,1);
            }
            else
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted",-1,1);
            }
            _loc15_ = int(param1[_loc21_++]);
            _loc16_ = [];
            _loc25_ = 0;
            while(_loc25_ < _loc15_)
            {
               _loc7_ = int(param1[_loc21_++]);
               _loc6_ = int(param1[_loc21_++]);
               if(_loc7_ == 0)
               {
                  _loc12_ = _loc23_.getFullItemList(true);
                  _loc24_ = 0;
                  while(_loc24_ < _loc12_.length)
                  {
                     if(_loc12_[_loc24_].invIdx == _loc6_)
                     {
                        _loc12_.splice(_loc24_,1);
                        break;
                     }
                     _loc24_++;
                  }
                  _loc23_.fullItemList = _loc12_;
                  _loc29_ = _loc4_.inventoryClothing.itemArray;
                  _loc24_ = 0;
                  while(_loc24_ < _loc29_.length)
                  {
                     if(_loc29_[_loc24_].invIdx == _loc6_)
                     {
                        _loc4_.accStateHideAccessory(_loc29_[_loc24_],false);
                        _loc29_.splice(_loc24_,1);
                        break;
                     }
                     _loc24_++;
                  }
               }
               else
               {
                  _loc13_ = _loc23_.denItemsFull;
                  _loc24_ = 0;
                  while(_loc24_ < _loc13_.length)
                  {
                     if(_loc13_[_loc24_].invIdx == _loc6_)
                     {
                        if(_loc13_[_loc24_].sortId == 4 && _loc13_[_loc24_].categoryId != 0)
                        {
                           _loc18_ = 0;
                           while(_loc18_ < _loc13_.length)
                           {
                              if(_loc13_[_loc18_].itemDefId == 617)
                              {
                                 _loc13_[_loc18_].categoryId = 1;
                                 break;
                              }
                              _loc18_++;
                           }
                        }
                        _loc16_.push({
                           "i":_loc6_,
                           "catId":0,
                           "r":_loc13_[_loc24_].refId
                        });
                        _loc13_.splice(_loc24_,1);
                     }
                     _loc24_++;
                  }
                  _loc5_ = _loc4_.inventoryDenFull.itemArray;
                  _loc24_ = 0;
                  while(_loc24_ < _loc5_.length)
                  {
                     if(_loc5_[_loc24_].invIdx == _loc6_)
                     {
                        if(_loc5_[_loc24_].sortId == 4 && _loc5_[_loc24_].categoryId != 0)
                        {
                           _loc18_ = 0;
                           while(_loc18_ < _loc5_.length)
                           {
                              if(_loc5_[_loc18_].itemDefId == 617)
                              {
                                 _loc5_[_loc18_].categoryId = 1;
                                 break;
                              }
                              _loc18_++;
                           }
                        }
                        _loc5_.splice(_loc24_,1);
                     }
                     _loc24_++;
                  }
                  _loc4_.inventoryDenPartial.itemArray = [];
                  _loc23_.denItemsPartial = [];
                  for each(var _loc27_:DenItem in _loc4_.inventoryDenFull.itemArray)
                  {
                     if(_loc27_.enviroType == AvatarManager.roomEnviroType)
                     {
                        _loc4_.inventoryDenPartial.itemArray.push(_loc27_);
                        _loc23_.denItemsPartial.push(_loc27_);
                     }
                  }
               }
               _loc20_ = gMainFrame.userInfo.getMyTradeList();
               _loc24_ = 0;
               while(_loc24_ < _loc20_.length)
               {
                  if(_loc20_[_loc24_].type == _loc7_ && _loc20_[_loc24_].invIdx == _loc6_)
                  {
                     _loc20_.splice(_loc24_,1);
                     if(_loc7_ == 0)
                     {
                        _numClothingItemsInTradeList = _numClothingItemsInTradeList - 1;
                     }
                     else
                     {
                        _numDenItemsInTradeList = _numDenItemsInTradeList - 1;
                     }
                     break;
                  }
                  _loc24_++;
               }
               _loc25_++;
            }
            if(_loc16_.length > 0 && gMainFrame.server.getCurrentRoomName(false) == "den" + gMainFrame.userInfo.myUserName)
            {
               RoomManagerWorld.instance.denItemHolder.setItems(_loc16_);
            }
            if(GuiManager.denEditor)
            {
               GuiManager.denEditor.reloadDenItems();
            }
            _loc4_.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
            GuiManager.showHudAvt();
            closeRequestSentPopup();
         }
         else
         {
            loadPopup(432,param1);
         }
      }
      
      private static function popupsMediaCallback(param1:MovieClip) : void
      {
         var _loc3_:Function = null;
         var _loc4_:Object = null;
         var _loc2_:MediaHelper = null;
         if(param1)
         {
            switch(param1.mediaHelper.id)
            {
               case 430:
                  _loc3_ = displayRequestTrade;
                  _loc4_ = _itemToTradeFor;
                  break;
               case 431:
                  _loc3_ = displayTradeRequested;
                  _loc4_ = param1.passback;
                  break;
               case 432:
                  _loc3_ = displayTradeDone;
                  _loc4_ = param1.passback;
                  break;
               case 4432:
                  _loc3_ = displayTradeConfirmPopup;
                  _loc4_ = param1.passback;
                  break;
               case 4456:
                  _loc3_ = displayRequestSent;
                  _loc4_ = param1.passback;
            }
            if(!AJAudio.hasLoadedTradeSfx)
            {
               _loc2_ = new MediaHelper();
               _loc2_.init(1333,onSoundsLoaded,{
                  "funcToCall":_loc3_,
                  "data":_loc4_,
                  "img":param1
               });
               _mediaViews.push(_loc2_);
            }
            else
            {
               DarkenManager.showLoadingSpiral(false);
               _loc3_(_loc4_,param1);
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
               _tradeRequestedPopup.member.setAvName(_loc5_.getModeratedUserName(),Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_loc5_,false);
               _tradeRequestedPopup.member.mouseEnabled = false;
               _tradeRequestedPopup.member.mouseChildren = false;
            }
            else
            {
               _tradeRequestedPopup.member.visible = false;
               _tradeRequestedPopup.userName_txt.visible = true;
               LocalizationManager.updateToFit(_tradeRequestedPopup.userName_txt,_loc5_.getModeratedUserName());
            }
            _tradeRequestAvatar = AvatarManager.getAvatarByUserName(_tradeRequestedPlayerUsername);
            if(_tradeRequestAvatar == null)
            {
               _tradeRequestAvatar = AvatarUtility.generateNew(param4.perUserAvId,null,_tradeRequestedPlayerUsername,-1,0,onAvatarItemData);
            }
            LocalizationManager.updateToFit(_tradeRequestedPopup.itemTxt,LocalizationManager.translateIdAndInsertOnly(_tradeRequestedPopup.totalNumOfItems == 1 ? 8334 : 8336,_loc5_.getModeratedUserName(),_tradeRequestedPopup.totalNumOfItems),true);
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
            _tradeRequestAvatarView.playAnim(13,false,1,positionAndAddMainAvatarView);
         }
      }
      
      private static function positionAndAddMainAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:Point = BuddyCard.getAvOffsetByDefId(_tradeRequestAvatarView.avTypeId);
         _tradeRequestAvatarView.x = _loc4_.x;
         _tradeRequestAvatarView.y = _loc4_.y;
         if(_tradeRequestedPopup && _tradeRequestAvatar)
         {
            if(Utility.isOcean(_tradeRequestAvatar.enviroTypeFlag))
            {
               if(Utility.isLand(_tradeRequestAvatar.enviroTypeFlag))
               {
                  _loc3_ = _tradeRequestedPopup.charBox.beach;
               }
               else
               {
                  _loc3_ = _tradeRequestedPopup.charBox.ocean;
               }
            }
            else
            {
               _loc3_ = _tradeRequestedPopup.charBox.land;
            }
            while(_loc3_.numChildren > 1)
            {
               _loc3_.removeChildAt(_loc3_.numChildren - 1);
            }
            _loc3_.addChild(_tradeRequestAvatarView);
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
               SBTracker.trackPageview("/game/play/trading/request/received",-1,1);
               displayTradeRequested(param1);
            }
         }
         else if(_loc2_ == 1)
         {
            if(int(param1[3]) == 0)
            {
               displayTradeConfirmPopup();
            }
            else
            {
               displayTradeDone(param1);
            }
         }
         else
         {
            SBTracker.push();
            if(_loc2_ == 2)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11386,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
               SBTracker.trackPageview("/game/play/trading/request/denied/#" + (_itemToTradeFor is Item ? "accessory" : "den item") + "/#0/#" + _itemToTradeFor.itemDefId,-1,1);
            }
            else if(_loc2_ == 3)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11387,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
               SBTracker.trackPageview("/game/play/trading/request/itemAlreadyTraded",-1,1);
            }
            else if(_loc2_ == 4)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11388,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
               SBTracker.trackPageview("/game/play/trading/request/alreadyInTrade",-1,1);
            }
            else if(_loc2_ == 5)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11389,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
               SBTracker.trackPageview("/game/play/trading/request/fullInventoryReceiver",-1,1);
            }
            else
            {
               if(_loc2_ == 6)
               {
                  closeConfirmTradePopup();
                  closeTradeRequestedPopup();
                  isCurrentlyTrading = false;
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
                  SBTracker.trackPageview("/game/play/trading/request/diffShard",-1,1);
                  _jammerRoomName = param1[3];
                  closeConfirmTradePopup();
                  closeRequestSentPopup();
                  isCurrentlyTrading = false;
                  return;
               }
               if(_loc2_ != 8)
               {
                  DebugUtility.debugTrace("This should never happen... flag=" + _loc2_);
                  closeConfirmTradePopup();
                  closeRequestSentPopup();
                  isCurrentlyTrading = false;
                  return;
               }
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11386,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
            }
            isCurrentlyTrading = false;
            closeConfirmTradePopup();
            closeRequestSentPopup();
            new SBOkPopup(_guiLayer,_loc3_,true,onSBOkBtn);
         }
      }
      
      public static function onTradeListReceived(param1:Object) : void
      {
         var _loc12_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:* = 0;
         var _loc9_:int = 0;
         var _loc3_:Object = null;
         var _loc10_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Array = [];
         var _loc8_:String = param1[2];
         var _loc11_:int = 3;
         if(gMainFrame.userInfo.myUserName.toLowerCase() == _loc8_.toLowerCase())
         {
            _numClothingItemsInTradeList = int(param1[_loc11_++]);
            _loc12_ = 0;
            while(_loc12_ < _numClothingItemsInTradeList)
            {
               _loc11_ += 1;
               _loc6_.push({
                  "invIdx":int(param1[_loc11_++]),
                  "type":0
               });
               _loc11_ += 1;
               _loc12_++;
            }
            _numDenItemsInTradeList = _loc7_ = int(param1[_loc11_++]);
            _loc12_ = 0;
            while(_loc12_ < _loc7_)
            {
               _loc11_ += 1;
               _loc6_.push({
                  "invIdx":int(param1[_loc11_++]),
                  "type":1
               });
               _loc11_ += 1;
               _loc12_++;
            }
            gMainFrame.userInfo.myTradeList = _loc6_;
         }
         else
         {
            _loc10_ = int(param1[_loc11_++]);
            _loc12_ = 0;
            while(_loc12_ < _loc10_)
            {
               _loc2_ = int(param1[_loc11_++]);
               _loc9_ = int(param1[_loc11_++]);
               _loc4_ = uint(param1[_loc11_++]);
               _loc3_ = new Item();
               _loc3_.init(_loc2_,_loc9_,_loc4_);
               _loc6_.push(_loc3_);
               _loc12_++;
            }
            _loc7_ = int(param1[_loc11_++]);
            _loc12_ = 0;
            while(_loc12_ < _loc7_)
            {
               _loc2_ = int(param1[_loc11_++]);
               _loc9_ = int(param1[_loc11_++]);
               _loc4_ = uint(int(param1[_loc11_++]));
               _loc3_ = new DenItem();
               _loc3_.init(_loc2_,_loc9_,0,_loc4_,0);
               _loc6_.push(_loc3_);
               _loc12_++;
            }
            BuddyCard.onTradeListReceived(_loc8_,_loc6_);
         }
      }
      
      public static function changeTradeList(param1:Array, param2:Array) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:Array = gMainFrame.userInfo.getMyTradeList();
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               if(param2[_loc5_].invIdx == _loc3_[_loc4_].invIdx)
               {
                  _loc3_.splice(_loc4_,1);
                  break;
               }
               _loc4_++;
            }
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc3_.push(param1[_loc5_]);
            _loc5_++;
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
      
      public static function get isCurrentlyTrading() : Boolean
      {
         return _isCurrentlyTrading;
      }
      
      public static function set isCurrentlyTrading(param1:Boolean) : void
      {
         _isCurrentlyTrading = param1;
         if(param1 == false)
         {
            _itemToTradeFor = null;
            _itemBeingTaken = null;
            _listOfItemsBeingOffered = null;
         }
      }
      
      private static function onConfirmServerSwitch(param1:Object) : void
      {
         if(param1.status && _jammerRoomName != "")
         {
            DarkenManager.showLoadingSpiral(true);
            RoomXtCommManager.sendRoomJoinRequest(_jammerRoomName);
         }
         _jammerRoomName = "";
      }
      
      private static function buildItemWindows(param1:MovieClip, param2:Array, param3:Boolean = false) : void
      {
         var _loc12_:int = 0;
         var _loc11_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc4_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:WindowAndScrollbarGenerator = param3 ? _itemWindowTheirs : _itemWindows;
         if(_loc7_)
         {
            _loc7_.destroy();
         }
         var _loc8_:Array = param2;
         var _loc6_:int = int(_loc8_.length);
         var _loc9_:Object = {
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut
         };
         if(_requestTradePopup && param1 == _requestTradePopup.itemBlock)
         {
            _loc5_ = true;
            _loc12_ = 2;
            _loc6_ = 4;
            _loc11_ = true;
            _loc4_ = _loc10_ = Math.min(_loc6_,_loc12_);
            while(_requestTradePopup.itemBlock.numChildren > 2)
            {
               _requestTradePopup.itemBlock.removeChildAt(_requestTradePopup.itemBlock.numChildren - 1);
            }
            if(_requestTradePopup.doneBtn.hasGrayState)
            {
               _requestTradePopup.doneBtn.activateGrayState(true);
            }
         }
         else if(_requestTradePopup && param1 == _requestTradePopup.itemBlockTheirs)
         {
            _loc12_ = 1;
            _loc11_ = true;
            _loc10_ = _loc4_ = 1;
            while(_requestTradePopup.itemBlockTheirs.numChildren > 1)
            {
               _requestTradePopup.itemBlockTheirs.removeChildAt(_requestTradePopup.itemBlockTheirs.numChildren - 1);
            }
         }
         else if(_tradeDonePopup && param1 == _tradeDonePopup.itemBlock)
         {
            if(_loc6_ > 4)
            {
               _loc10_ = 2;
               _loc4_ = _loc6_ / 2;
            }
            else
            {
               _loc10_ = _loc6_;
               _loc4_ = 1;
            }
            while(_tradeDonePopup.itemBlock.numChildren > 1)
            {
               _tradeDonePopup.itemBlock.removeChildAt(_tradeDonePopup.itemBlock.numChildren - 1);
            }
         }
         else if(_tradeConfirmPopup && param1 == _tradeConfirmPopup.itemBlock)
         {
            if(_loc6_ > 2)
            {
               _loc10_ = 2;
               _loc4_ = _loc6_ / 2;
            }
            else
            {
               _loc10_ = _loc6_;
               _loc4_ = 1;
            }
            while(_tradeConfirmPopup.itemBlock.numChildren > 1)
            {
               _tradeConfirmPopup.itemBlock.removeChildAt(_tradeConfirmPopup.itemBlock.numChildren - 1);
            }
         }
         _loc7_ = new WindowAndScrollbarGenerator();
         _loc7_.init("widthCont" in param1 ? param1.widthCont.width : param1.width,"widthCont" in param1 ? param1.widthCont.height : param1.height,0,0,_loc10_,_loc4_,0,2,3,0,ItemWindowOriginal,_loc8_,"icon",0,_loc9_,{
            "isTradeManager":_loc11_,
            "loadImmediately":false,
            "showAddRemoveBtns":_loc5_
         },null,false,false,true,false,true);
         param1.addChild(_loc7_);
         param3 ? _itemWindowTheirs : (_itemWindows = _loc7_);
         _loadingSpiral.visible = false;
      }
      
      private static function addRequestTradeListeners() : void
      {
         _requestTradePopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _requestTradePopup.doneBtn.addEventListener("mouseDown",onDoneBtn,false,0,true);
         _requestTradePopup.bx.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private static function removeRequestTradeListeners() : void
      {
         _requestTradePopup.removeEventListener("mouseDown",onPopoup);
         _requestTradePopup.doneBtn.removeEventListener("mouseDown",onDoneBtn);
         _requestTradePopup.bx.removeEventListener("mouseDown",onClose);
      }
      
      private static function addRequestSentListeners() : void
      {
         _requestSentPopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _requestSentPopup.cancelBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private static function removeRequestSentListeners() : void
      {
         _requestSentPopup.removeEventListener("mouseDown",onPopoup);
         _requestSentPopup.cancelBtn.removeEventListener("mouseDown",onClose);
      }
      
      private static function addTradeRequestedListeners() : void
      {
         _tradeRequestedPopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _tradeRequestedPopup.bx.addEventListener("mouseDown",onDeclineTrade,false,0,true);
         _tradeRequestedPopup.yesBtn.addEventListener("mouseDown",onAcceptTrade,false,0,true);
         _tradeRequestedPopup.noBtn.addEventListener("mouseDown",onDeclineTrade,false,0,true);
      }
      
      private static function removeTradeRequestedListeners() : void
      {
         _tradeRequestedPopup.removeEventListener("mouseDown",onPopoup);
         _tradeRequestedPopup.bx.removeEventListener("mouseDown",onDeclineTrade);
         _tradeRequestedPopup.yesBtn.removeEventListener("mouseDown",onAcceptTrade);
         _tradeRequestedPopup.noBtn.removeEventListener("mouseDown",onDeclineTrade);
      }
      
      private static function addTradeDoneListeners() : void
      {
         _tradeDonePopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _tradeDonePopup.bx.addEventListener("mouseDown",onClose,false,0,true);
         _tradeDonePopup.yesBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private static function removeTradeDoneListeners() : void
      {
         _tradeDonePopup.removeEventListener("mouseDown",onPopoup);
         _tradeDonePopup.bx.removeEventListener("mouseDown",onClose);
         _tradeDonePopup.yesBtn.removeEventListener("mouseDown",onClose);
      }
      
      private static function addTradeConfirmListeners() : void
      {
         _tradeConfirmPopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _tradeConfirmPopup.noBtn.addEventListener("mouseDown",onClose,false,0,true);
         _tradeConfirmPopup.yesBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private static function removeTradeConfirmListeners() : void
      {
         _tradeConfirmPopup.removeEventListener("mouseDown",onPopoup);
         _tradeConfirmPopup.noBtn.removeEventListener("mouseDown",onClose);
         _tradeConfirmPopup.yesBtn.removeEventListener("mouseDown",onClose);
      }
      
      private static function addTradeItem(param1:Object) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _initiationTradeList.length)
         {
            if(param1 is DenItem)
            {
               if(_initiationTradeList[_loc2_] is DenItem)
               {
                  if(param1["invIdx"] == _initiationTradeList[_loc2_].invIdx)
                  {
                     return;
                  }
               }
            }
            else if(param1 is Item)
            {
               if(_initiationTradeList[_loc2_] is Item)
               {
                  if(param1["invIdx"] == _initiationTradeList[_loc2_].invIdx)
                  {
                     return;
                  }
               }
            }
            _loc2_++;
         }
         _initiationTradeList.push(param1);
         if(_initiationTradeList.length >= 4)
         {
            if(_initiationTradeList.length == 4)
            {
               _requestTradePopup.gotoAndPlay("grow");
            }
            _itemWindows.findOpenWindowAndUpdate(param1);
            if(_initiationTradeList.length < 20)
            {
               _itemWindows.insertItem(null,true);
            }
         }
         else
         {
            _itemWindows.findOpenWindowAndUpdate(param1);
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
         LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,_initiationTradeList.length == 1 ? 23696 : 23695,_initiationTradeList.length);
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
         param1.addEventListener("mouseOver",onItemWindowOver,false,0,true);
         param1.addEventListener("mouseOut",onItemWindowOut,false,0,true);
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
         var _loc3_:int = 0;
         var _loc2_:Array = BuddyCard.getTradeList();
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            if((param1.type == 0 && _loc2_[_loc3_] is Item || param1.type == 1 && _loc2_[_loc3_] is DenItem) && param1.invIdx == _loc2_[_loc3_].invIdx)
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
               if(param1.type == 0)
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
            _initiationTradeList[param1.currentTarget.index] is Item ? adjustByOnNumClothingItemsInInitiateTradeList(-1) : adjustByOnNumDenItemsInInitiateTradeList(-1);
            _itemWindows.updateItem(param1.currentTarget.index,null);
            if(_initiationTradeList.length > 3)
            {
               _itemWindows.deleteItem(param1.currentTarget.index,_initiationTradeList);
               if(_initiationTradeList.length == 20 - 1)
               {
                  _itemWindows.insertItem(null,true);
               }
            }
            else
            {
               _initiationTradeList.splice(Math.min(_initiationTradeList.length - 1,param1.currentTarget.index),1);
            }
            if(_initiationTradeList.length <= 3 && _requestTradePopup.currentFrameLabel != "four")
            {
               _requestTradePopup.gotoAndPlay("shrink");
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
            LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,_initiationTradeList.length == 1 ? 23696 : 23695,_initiationTradeList.length);
         }
         else if(param1.currentTarget.addBtn.visible && _initiationTradeList.length < 20)
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
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         param1.stopPropagation();
         if(!_requestTradePopup.doneBtn.isGray)
         {
            _loc5_ = 0;
            while(_loc5_ < _initiationTradeList.length)
            {
               if(_initiationTradeList[_loc5_].isDiamond)
               {
                  _loc3_++;
               }
               if(_initiationTradeList[_loc5_].isRare)
               {
                  _loc2_++;
               }
               _loc5_++;
            }
            _loc4_ = 0;
            if(_loc3_ > 0 && _loc2_ > 0)
            {
               _loc4_ = 5;
            }
            else if(_loc3_ == 1)
            {
               _loc4_ = 3;
            }
            else if(_loc3_ > 1)
            {
               _loc4_ = 4;
            }
            else if(_loc2_ == 1)
            {
               _loc4_ = 1;
            }
            else if(_loc2_ > 1)
            {
               _loc4_ = 2;
            }
            if(_loc4_ != 0)
            {
               _requestTradePopup.tradeConfirmPopup = new TradeConfirmPopup(_guiLayer,_loc4_,onConfirmSendTradeRequest,param1);
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
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:Array = [];
         var _loc4_:Array = [];
         var _loc7_:Array = [];
         var _loc3_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < 3)
         {
            _loc7_[_loc5_] = 0;
            _loc3_[_loc5_] = 0;
            _loc5_++;
         }
         var _loc9_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < _initiationTradeList.length)
         {
            if(_initiationTradeList[_loc8_] is Item)
            {
               _loc7_[_initiationTradeList[_loc8_].enviroType]++;
               _loc6_.push(_initiationTradeList[_loc8_].invIdx);
            }
            else if(_initiationTradeList[_loc8_] is DenItem)
            {
               if(_initiationTradeList[_loc8_].sortId == 4)
               {
                  _loc9_++;
               }
               else
               {
                  _loc3_[_initiationTradeList[_loc8_].enviroType]++;
               }
               _loc4_.push(_initiationTradeList[_loc8_].invIdx);
            }
            _loc8_++;
         }
         _numClothingItemsInInitiateTradeList = 0;
         _numDenItemsInInitiateTradeList = 0;
         SBTracker.push();
         var _loc2_:Boolean = true;
         if(_itemToTradeFor is Item)
         {
            if(_itemToTradeFor.enviroType == 0)
            {
               if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),0) + 1 - _loc7_[0] > Shop.maxItems)
               {
                  _loc2_ = false;
               }
            }
            else if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),1) + 1 - _loc7_[1] > Shop.maxItems)
            {
               _loc2_ = false;
            }
         }
         else if(_itemToTradeFor.sortId == 4)
         {
            if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,-1,true) + 1 - _loc9_ > Shop.maxAudioItems)
            {
               _loc2_ = false;
            }
         }
         else if(_itemToTradeFor.enviroType == 0)
         {
            if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,0) + 1 - _loc3_[0] > Shop.maxDenItems)
            {
               _loc2_ = false;
            }
         }
         else if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,1) + 1 - _loc3_[1] > Shop.maxDenItems)
         {
            _loc2_ = false;
         }
         if(_loc2_)
         {
            SBTracker.trackPageview("/game/play/trading/request/initiated",-1,1);
            TradeXtCommManager.sendTradeItemsRequest(BuddyCard.currBuddyCardUserName,_itemToTradeFor.invIdx,_itemToTradeFor is Item,_loc6_,_loc4_,_loc9_);
            onClose(param1);
            displayRequestSent();
         }
         else
         {
            onClose(param1);
            TradeXtCommManager.sendTradeBusyRequest(false);
            isCurrentlyTrading = false;
            SBTracker.trackPageview("/game/play/trading/request/fullInventorySender",-1,1);
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14804),true,onSBOkBtn);
         }
         BuddyCard.closeBuddyCard();
      }
      
      private static function onClose(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
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
               if(_tradeRequestAvatarView)
               {
                  _tradeRequestAvatarView.destroy();
                  _tradeRequestAvatarView = null;
               }
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
               break;
            case _tradeConfirmPopup:
               SBTracker.flush(true);
               removeTradeConfirmListeners();
               _loc2_ = param1.currentTarget.name == "yesBtn";
               TradeXtCommManager.sendConfirmTrade(_loc2_);
               if(!_loc2_)
               {
                  closeRequestSentPopup();
                  TradeXtCommManager.sendTradeBusyRequest(false);
                  isCurrentlyTrading = false;
               }
               else
               {
                  displayRequestSent();
               }
         }
      }
      
      private static function closeRequestSentPopup() : void
      {
         if(_requestSentPopup && _requestSentPopup.visible)
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
      
      private static function closeConfirmTradePopup() : void
      {
         if(_tradeConfirmPopup)
         {
            AJAudio.playTradeFailedSound();
            DarkenManager.unDarken(_tradeConfirmPopup);
            if(_tradeConfirmPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeConfirmPopup);
            }
            removeTradeConfirmListeners();
         }
      }
      
      private static function closeTradeRequestedPopup() : void
      {
         if(_tradeRequestedPopup && _tradeRequestedPopup.visible)
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
            if(_tradeRequestAvatarView)
            {
               _tradeRequestAvatarView.destroy();
               _tradeRequestAvatarView = null;
            }
            removeTradeRequestedListeners();
         }
      }
      
      private static function onAcceptTrade(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = 0;
         if(_tradeRequestedPopup.itemBlockTheirs.diamond.visible)
         {
            _loc2_ = 3;
         }
         else if(_tradeRequestedPopup.itemBlockTheirs.rare.visible)
         {
            _loc2_ = 1;
         }
         else if(_tradeRequestedPopup.itemBlockTheirs.rareDiamondTag.visible)
         {
            _loc2_ = 5;
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
         if(!(param1.currentTarget is ItemWindowOriginal) && "itemName" in param1.currentTarget && param1.currentTarget.itemName != null)
         {
            GuiManager.toolTip.init(MovieClip(param1.currentTarget.parent),param1.currentTarget.itemName,84 * 0.5 + param1.currentTarget.x,84 + param1.currentTarget.y);
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

