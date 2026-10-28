package gui
{
   import Enums.TradeItem;
   import avatar.Avatar;
   import avatar.AvatarEvent;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.DenStateItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import collection.TradeItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import den.DenStateItem;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.utils.setTimeout;
   import gui.itemWindows.ItemWindowOriginal;
   import inventory.Iitem;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetItem;
   import pet.PetManager;
   import playerWall.PlayerWallManager;
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
      
      private static var _isCurrentlyTrading:Boolean;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _requestTradePopup:MovieClip;
      
      private static var _requestSentPopup:MovieClip;
      
      private static var _tradeRequestedPopup:MovieClip;
      
      private static var _tradeDonePopup:MovieClip;
      
      private static var _currDownMC:MovieClip;
      
      private static var _tradeConfirmPopup:MovieClip;
      
      private static var _mediaViews:Array;
      
      private static var _initiationTradeList:IitemCollection;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      private static var _itemWindows:WindowAndScrollbarGenerator;
      
      private static var _itemWindowTheirs:WindowAndScrollbarGenerator;
      
      private static var _itemToTradeFor:Iitem;
      
      private static var _listOfItemsBeingOffered:IitemCollection;
      
      private static var _itemBeingTaken:Iitem;
      
      private static var _isInventoryFull:Boolean;
      
      private static var _numClothingItemsInTradeList:int;
      
      private static var _numDenItemsInTradeList:int;
      
      private static var _numPetItemsInTradeList:int;
      
      private static var _numClothingItemsInInitiateTradeList:int;
      
      private static var _numDenItemsInInitiateTradeList:int;
      
      private static var _numPetItemsInInitiateTradeList:int;
      
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
         _initiationTradeList = new IitemCollection();
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
         if(_denClothesSelectPopup)
         {
            _denClothesSelectPopup.destroy();
            _denClothesSelectPopup = null;
         }
         isCurrentlyTrading = false;
      }
      
      public static function displayRequestTrade(param1:Object, param2:MovieClip = null) : void
      {
         var _loc5_:IitemCollection = null;
         var _loc4_:String = param1.currUsernameToTradeTo;
         var _loc3_:TradeItem = param1.itemToTrade;
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
            _requestTradePopup.currUsernameToTradeTo = _loc4_;
            buildItemWindows(_requestTradePopup.itemBlock,new IitemCollection(_initiationTradeList.concatCollection(null)));
            _loc5_ = new IitemCollection();
            _loc5_.pushIitem(_itemToTradeFor);
            buildItemWindows(_requestTradePopup.itemBlockTheirs,_loc5_,true);
            LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,23695,_initiationTradeList.length);
            if(_itemToTradeFor is DenItem && (_itemToTradeFor as DenItem).isOcean && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else if(_requestTradePopup)
         {
            setupItemToTradeFor(_loc3_);
            _guiLayer.addChild(_requestTradePopup);
            DarkenManager.darken(_requestTradePopup);
            _requestTradePopup.visible = true;
            addRequestTradeListeners();
            _loadingSpiral.scaleX = 1;
            _loadingSpiral.scaleY = 1;
            _loadingSpiral.setNewParent(_requestTradePopup.itemBlock);
            _loadingSpiral.visible = true;
            _initiationTradeList.getCoreArray().splice(0,_initiationTradeList.length);
            _numClothingItemsInInitiateTradeList = 0;
            _numDenItemsInInitiateTradeList = 0;
            _numPetItemsInInitiateTradeList = 0;
            _requestTradePopup.gotoAndStop("four");
            _requestTradePopup.currUsernameToTradeTo = _loc4_;
            buildItemWindows(_requestTradePopup.itemBlock,new IitemCollection(_initiationTradeList.concatCollection(null)));
            _loc5_ = new IitemCollection();
            _loc5_.pushIitem(_itemToTradeFor);
            buildItemWindows(_requestTradePopup.itemBlockTheirs,_loc5_,true);
            LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,23695,_initiationTradeList.length);
            if(_itemToTradeFor is DenItem && (_itemToTradeFor as DenItem).isOcean && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else
         {
            loadPopup(430,{
               "currUsernameToTradeTo":_loc4_,
               "itemToTrade":_loc3_
            });
            setupItemToTradeFor(_loc3_);
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
         var _loc22_:Iitem = null;
         var _loc18_:int = 0;
         var _loc24_:int = 0;
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc17_:int = 0;
         var _loc15_:int = 0;
         var _loc27_:int = 0;
         var _loc28_:int = 0;
         var _loc9_:int = 0;
         var _loc12_:IitemCollection = null;
         var _loc21_:* = null;
         var _loc23_:int = 0;
         var _loc13_:int = 0;
         var _loc26_:int = 0;
         var _loc3_:int = 0;
         var _loc16_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:AvatarInfo = null;
         var _loc7_:Boolean = false;
         var _loc25_:IitemCollection = null;
         var _loc20_:int = 0;
         var _loc19_:Boolean = false;
         var _loc4_:Number = NaN;
         var _loc8_:int = 0;
         var _loc14_:int = 0;
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
            _loc18_ = 7;
            _loc24_ = int(param1[_loc18_++]);
            _loc11_ = int(param1[_loc18_++]);
            _loc10_ = int(param1[_loc18_++]);
            _loc17_ = 0;
            _loc15_ = 0;
            _loc27_ = 0;
            _loc28_ = 0;
            _loc9_ = 0;
            if(!AvatarManager.playerAvatar)
            {
               onDeclineTrade(null);
               return;
            }
            _loc23_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,0);
            _loc13_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,1);
            _loc26_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),0);
            _loc3_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),1);
            _loc16_ = int(PetManager.myPetList.length);
            if(int(param1[5]) < 2)
            {
               _loc12_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems() as IitemCollection;
               if(int(param1[5]) == 0)
               {
                  _loc26_--;
               }
               else
               {
                  _loc3_--;
               }
            }
            else if(int(param1[5]) == 4)
            {
               _loc16_--;
               _loc12_ = PetManager.myPetListAsIitem;
            }
            else
            {
               if(int(param1[5]) == 2)
               {
                  _loc23_--;
               }
               else
               {
                  _loc13_--;
               }
               _loc12_ = AvatarManager.playerAvatar.inventoryDenFull.denItemCollection as IitemCollection;
            }
            _guiLayer.addChild(_tradeRequestedPopup);
            DarkenManager.darken(_tradeRequestedPopup);
            addTradeRequestedListeners();
            _tradeRequestedPopup.yesBtn.visible = false;
            _tradeRequestedPopup.noBtn.visible = false;
            _tradeRequestedPopup.visible = true;
            _loc5_ = _loc24_ + _loc11_ + _loc10_;
            _tradeRequestedPopup.totalNumOfItems = _loc5_;
            _loc6_ = gMainFrame.userInfo.getAvatarInfoByUserName(_tradeRequestedPlayerUsername);
            if(!_loc6_)
            {
               AvatarXtCommManager.requestAvatarGet(_tradeRequestedPlayerUsername,onAvatarGetReceived);
            }
            else
            {
               onAvatarGetReceived(_tradeRequestedPlayerUsername,true,0,_loc6_);
            }
            if(_itemWindows)
            {
               _itemWindows.destroy();
               _itemWindows = null;
            }
            _loc25_ = new IitemCollection();
            if(_loc5_ > 4)
            {
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock1");
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock5");
               _loc7_ = true;
            }
            else
            {
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock5");
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock" + _loc5_);
               _loc7_ = false;
            }
            _loc20_ = 1;
            while(_loc20_ <= _loc24_)
            {
               _loc22_ = new Item();
               (_loc22_ as Item).init(int(param1[_loc18_++]),0,uint(param1[_loc18_++]));
               if(_loc22_.enviroType == 0)
               {
                  _loc17_++;
               }
               else
               {
                  _loc15_++;
               }
               _loc25_.pushIitem(_loc22_);
               _loc20_++;
            }
            _loc20_ = 1;
            while(_loc20_ <= _loc11_)
            {
               _loc22_ = new DenItem();
               (_loc22_ as DenItem).init(param1[_loc18_++],0,0,param1[_loc18_++],0,null,0,param1[_loc18_++],param1[_loc18_++],param1[_loc18_++],param1[_loc18_++],param1[_loc18_++]);
               if(_loc22_.enviroType == 0)
               {
                  _loc27_++;
               }
               else
               {
                  _loc28_++;
               }
               if(!_loc19_ && _loc22_.enviroType == 1 && !DenSwitch.haveOceanDen())
               {
                  _loc19_ = true;
               }
               _loc25_.pushIitem(_loc22_);
               _loc20_++;
            }
            _loc20_ = 1;
            while(_loc20_ <= _loc10_)
            {
               _loc22_ = new PetItem();
               _loc4_ = Number(param1[_loc18_++]);
               _loc8_ = int(param1[_loc18_++]);
               _loc14_ = int(param1[_loc18_++]);
               (_loc22_ as PetItem).init(_loc4_,_loc8_,[param1[_loc18_++],param1[_loc18_++],param1[_loc18_++]],param1[_loc18_++],param1[_loc18_++],param1[_loc18_++],_loc14_,param1[_loc18_++],false,0,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc8_,2)));
               _loc9_++;
               _loc25_.pushIitem(_loc22_);
               _loc20_++;
            }
            if(_loc23_ + _loc27_ > Shop.maxDenItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc13_ + _loc28_ > Shop.maxDenItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc26_ + _loc17_ > Shop.maxItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc3_ + _loc15_ > Shop.maxItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc16_ + _loc9_ > PetManager.getPetInventoryMax())
            {
               _isInventoryFull = true;
            }
            else
            {
               _isInventoryFull = false;
            }
            _listOfItemsBeingOffered = _loc25_;
            if(_loc7_)
            {
               LocalizationManager.translateIdAndInsert(_tradeRequestedPopup.itemBlocks.txtCounter_ba.counterTxt,23695,_loc25_.length);
            }
            buildItemWindows(_tradeRequestedPopup.itemBlocks.itemBlock,new IitemCollection(_loc25_.concatCollection(null)));
            if(_loc12_ && _loc12_.length > 0)
            {
               _loc20_ = 0;
               while(_loc20_ < _loc12_.length)
               {
                  if(_loc12_.getIitem(_loc20_).invIdx == int(param1[6]))
                  {
                     _itemBeingTaken = _loc22_ = _loc12_.getIitem(_loc20_).clone();
                     break;
                  }
                  _loc20_++;
               }
            }
            buildItemWindows(_tradeRequestedPopup.itemBlockTheirs,new IitemCollection([_itemBeingTaken.clone()]),true);
            setTimeout(showTradeButtonsAfterDelay,2000);
            if(_loc19_)
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
         var _loc3_:IitemCollection = null;
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
            _loc3_ = _listOfItemsBeingOffered != null ? _listOfItemsBeingOffered : _initiationTradeList;
            buildItemWindows(_tradeConfirmPopup.itemBlock,new IitemCollection(_loc3_.concatCollection(null)));
            buildItemWindows(_tradeConfirmPopup.itemBlockTheirs,new IitemCollection([_itemToTradeFor != null ? _itemToTradeFor : _itemBeingTaken]),true);
            LocalizationManager.translateIdAndInsert(_tradeConfirmPopup.txtCounter_ba.counterTxt,_loc3_.length == 1 ? 23696 : 23695,_loc3_.length);
         }
         else
         {
            loadPopup(4432);
         }
      }
      
      public static function displayTradeDone(param1:Object, param2:MovieClip = null) : void
      {
         var _loc4_:int = 0;
         var _loc40_:Iitem = null;
         var _loc38_:UserInfo = null;
         var _loc24_:Object = null;
         var _loc20_:int = 0;
         var _loc12_:int = 0;
         var _loc6_:Avatar = null;
         var _loc36_:* = null;
         var _loc35_:int = 0;
         var _loc43_:* = null;
         var _loc46_:IitemCollection = null;
         var _loc10_:int = 0;
         var _loc39_:int = 0;
         var _loc30_:AccItemCollection = null;
         var _loc13_:int = 0;
         var _loc16_:int = 0;
         var _loc11_:int = 0;
         var _loc17_:Boolean = false;
         var _loc26_:String = null;
         var _loc25_:String = null;
         var _loc14_:int = 0;
         var _loc15_:String = null;
         var _loc5_:Number = NaN;
         var _loc45_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:* = 0;
         var _loc34_:* = 0;
         var _loc33_:* = 0;
         var _loc41_:* = 0;
         var _loc28_:* = 0;
         var _loc21_:* = 0;
         var _loc27_:String = null;
         var _loc37_:int = 0;
         var _loc8_:int = 0;
         var _loc23_:int = 0;
         var _loc22_:DenStateItemCollection = null;
         var _loc18_:AccItemCollection = null;
         var _loc44_:AccItemCollection = null;
         var _loc29_:int = 0;
         var _loc19_:DenItemCollection = null;
         var _loc32_:IntItemCollection = null;
         var _loc7_:DenItemCollection = null;
         var _loc31_:TradeItemCollection = null;
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
            _loc4_ = int(param1[4]);
            _guiLayer.addChild(_tradeDonePopup);
            DarkenManager.darken(_tradeDonePopup);
            _tradeDonePopup.visible = true;
            addTradeDoneListeners();
            _tradeDonePopup.gotoAndStop(Math.min(5,_loc4_));
            _loc38_ = gMainFrame.userInfo.playerUserInfo;
            _loc24_ = gMainFrame.userInfo.playerUserInfo.avList;
            _loc20_ = int(gMainFrame.userInfo.playerAvatarInfo.type);
            _loc12_ = int(gMainFrame.userInfo.playerAvatarInfo.perUserAvId);
            _loc6_ = AvatarManager.getAvatarByUsernamePerUserAvId(_loc38_.userName,_loc12_);
            _loc35_ = 5;
            _loc46_ = new IitemCollection();
            _loc39_ = 1;
            while(_loc39_ <= _loc4_)
            {
               _loc10_ = int(param1[_loc35_++]);
               if(_loc10_ == 0)
               {
                  _loc40_ = new Item();
                  (_loc40_ as Item).init(int(param1[_loc35_++]),int(param1[_loc35_++]),uint(param1[_loc35_++]));
                  _loc30_ = _loc38_.fullItemList;
                  _loc30_.getCoreArray().unshift(_loc40_);
                  _loc38_.fullItemList = _loc30_;
                  if(AvatarManager.roomEnviroType == _loc40_.enviroType)
                  {
                     _loc6_.inventoryClothing.itemCollection.getCoreArray().unshift(_loc40_);
                  }
               }
               else if(_loc10_ == 1)
               {
                  _loc13_ = int(param1[_loc35_++]);
                  _loc16_ = int(param1[_loc35_++]);
                  _loc11_ = int(param1[_loc35_++]);
                  _loc17_ = param1[_loc35_++] == "true";
                  _loc26_ = param1[_loc35_++];
                  _loc25_ = param1[_loc35_++];
                  _loc14_ = int(param1[_loc35_++]);
                  _loc15_ = param1[_loc35_++];
                  _loc40_ = new DenItem();
                  (_loc40_ as DenItem).init(_loc16_,_loc13_,0,_loc11_,0,null,0,_loc17_,_loc26_,_loc25_,_loc14_,_loc15_);
                  _loc38_.denItemsFull.getCoreArray().unshift(_loc40_.clone());
               }
               else if(_loc10_ == 2)
               {
                  _loc5_ = Number(param1[_loc35_++]);
                  _loc45_ = int(param1[_loc35_++]);
                  _loc9_ = int(param1[_loc35_++]);
                  _loc40_ = new PetItem();
                  _loc3_ = uint(param1[_loc35_++]);
                  _loc34_ = uint(param1[_loc35_++]);
                  _loc33_ = uint(param1[_loc35_++]);
                  _loc41_ = uint(param1[_loc35_++]);
                  _loc28_ = uint(param1[_loc35_++]);
                  _loc21_ = uint(param1[_loc35_++]);
                  (_loc40_ as PetItem).init(_loc5_,_loc9_,[_loc3_,_loc34_,_loc33_],_loc41_,_loc28_,_loc21_,_loc45_,param1[_loc35_++],false,0,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc9_,2)));
                  PetManager.insertPet(_loc9_,_loc5_,_loc3_,_loc34_,_loc33_,_loc40_.name,_loc45_,_loc41_,_loc28_,_loc21_,false);
               }
               _loc46_.pushIitem(_loc40_);
               _loc39_++;
            }
            if(_loc46_.length > 4)
            {
               LocalizationManager.translateIdAndInsert(_tradeDonePopup.txtCounter_ba.counterTxt,_loc46_.length == 1 ? 23696 : 23695,_loc46_.length);
            }
            buildItemWindows(_tradeDonePopup.itemBlock,_loc46_);
            SBTracker.push();
            _loc27_ = "unknown";
            if(_loc40_ is Item)
            {
               _loc27_ = "accessory";
            }
            else if(_loc40_ is DenItem)
            {
               _loc27_ = "den item";
            }
            else if(_loc40_ is PetItem)
            {
               _loc27_ = "pet item";
            }
            if(_loc4_ == 1)
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted/#" + _loc27_ + "/#0#" + _loc40_.defId,-1,1);
            }
            else
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted",-1,1);
            }
            _loc23_ = int(param1[_loc35_++]);
            _loc22_ = new DenStateItemCollection();
            _loc39_ = 0;
            while(_loc39_ < _loc23_)
            {
               _loc10_ = int(param1[_loc35_++]);
               _loc8_ = int(param1[_loc35_++]);
               if(_loc10_ == 0)
               {
                  _loc18_ = _loc38_.getFullItemList(true);
                  _loc37_ = 0;
                  while(_loc37_ < _loc18_.length)
                  {
                     if(_loc18_.getAccItem(_loc37_).invIdx == _loc8_)
                     {
                        _loc18_.getCoreArray().splice(_loc37_,1);
                        break;
                     }
                     _loc37_++;
                  }
                  _loc38_.fullItemList = _loc18_;
                  _loc44_ = _loc6_.inventoryClothing.itemCollection;
                  _loc37_ = 0;
                  while(_loc37_ < _loc44_.length)
                  {
                     if(_loc44_.getAccItem(_loc37_).invIdx == _loc8_)
                     {
                        _loc6_.accStateHideAccessory(_loc44_.getAccItem(_loc37_),false);
                        _loc44_.getCoreArray().splice(_loc37_,1);
                        break;
                     }
                     _loc37_++;
                  }
               }
               else if(_loc10_ == 2)
               {
                  PetManager.removePetInvIdx([_loc8_]);
               }
               else
               {
                  _loc19_ = _loc38_.denItemsFull;
                  _loc32_ = new IntItemCollection();
                  _loc37_ = 0;
                  while(_loc37_ < _loc19_.length)
                  {
                     if(_loc19_.getDenItem(_loc37_).invIdx == _loc8_)
                     {
                        if(_loc19_.getDenItem(_loc37_).isCustom)
                        {
                           _loc32_.pushIntItem(_loc19_.getDenItem(_loc37_).invIdx);
                        }
                        if(_loc19_.getDenItem(_loc37_).sortId == 4 && _loc19_.getDenItem(_loc37_).categoryId != 0)
                        {
                           _loc29_ = 0;
                           while(_loc29_ < _loc19_.length)
                           {
                              if(_loc19_.getDenItem(_loc29_).defId == 617)
                              {
                                 _loc19_.getDenItem(_loc29_).categoryId = 1;
                                 break;
                              }
                              _loc29_++;
                           }
                        }
                        _loc22_.pushDenStateItem(new DenStateItem(0,_loc8_,0,0,0,0,0,0,0,0,_loc19_.getDenItem(_loc37_).refId,0,0,0,0,"",0,"",0,0,"","",-1,"",false,null,0,0,null));
                        _loc19_.getCoreArray().splice(_loc37_,1);
                     }
                     _loc37_++;
                  }
                  PlayerWallManager.checkAndRemoveMasterpieceItems(_loc32_);
                  _loc7_ = _loc6_.inventoryDenFull.denItemCollection;
                  _loc37_ = 0;
                  while(_loc37_ < _loc7_.length)
                  {
                     if(_loc7_.getDenItem(_loc37_).invIdx == _loc8_)
                     {
                        if(_loc7_.getDenItem(_loc37_).sortId == 4 && _loc7_.getDenItem(_loc37_).categoryId != 0)
                        {
                           _loc29_ = 0;
                           while(_loc29_ < _loc7_.length)
                           {
                              if(_loc7_.getDenItem(_loc29_).defId == 617)
                              {
                                 _loc7_.getDenItem(_loc29_).categoryId = 1;
                                 break;
                              }
                              _loc29_++;
                           }
                        }
                        _loc7_.getCoreArray().splice(_loc37_,1);
                     }
                     _loc37_++;
                  }
                  _loc6_.inventoryDenPartial.denItemCollection = new DenItemCollection();
                  _loc38_.denItemsPartial = new DenItemCollection();
                  for each(var _loc42_:DenItem in _loc6_.inventoryDenFull.denItemCollection.getCoreArray())
                  {
                     if(_loc42_.enviroType == AvatarManager.roomEnviroType)
                     {
                        _loc6_.inventoryDenPartial.denItemCollection.pushDenItem(_loc42_);
                        _loc38_.denItemsPartial.pushDenItem(_loc42_);
                     }
                  }
               }
               _loc31_ = gMainFrame.userInfo.getMyTradeList();
               _loc37_ = 0;
               while(_loc37_ < _loc31_.length)
               {
                  if(_loc31_.getTradeItem(_loc37_).itemType == _loc10_ && _loc31_.getTradeItem(_loc37_).invIdx == _loc8_)
                  {
                     _loc31_.getCoreArray().splice(_loc37_,1);
                     if(_loc10_ == 0)
                     {
                        _numClothingItemsInTradeList = _numClothingItemsInTradeList - 1;
                     }
                     else if(_loc10_ == 3)
                     {
                        _numPetItemsInTradeList = _numPetItemsInTradeList - 1;
                     }
                     else
                     {
                        _numDenItemsInTradeList = _numDenItemsInTradeList - 1;
                     }
                     break;
                  }
                  _loc37_++;
               }
               _loc39_++;
            }
            if(_loc22_.length > 0 && gMainFrame.server.getCurrentRoomName(false) == "den" + gMainFrame.userInfo.myUserName)
            {
               RoomManagerWorld.instance.denItemHolder.setItems(_loc22_);
            }
            if(GuiManager.denEditor)
            {
               GuiManager.denEditor.reloadDenItems();
            }
            if(_loc6_)
            {
               _loc6_.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
            }
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
                  _loc4_ = param1.passback;
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
         var _loc4_:Point = null;
         var _loc3_:MovieClip = null;
         if(_tradeRequestAvatarView)
         {
            _loc4_ = AvatarUtility.getAvOffsetByDefId(_tradeRequestAvatarView.avTypeId);
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
         }
         if(_loadingSpiralAvatar)
         {
            _loadingSpiralAvatar.visible = false;
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
         var _loc5_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:int = int(param1[2]);
         if(_loc4_ == 0)
         {
            if(isCurrentlyTrading || gMainFrame.clientInfo.extCallsActive)
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
         else if(_loc4_ == 1)
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
            _loc2_ = param1[3] == gMainFrame.userInfo.myUserName;
            if(_loc4_ == 2)
            {
               if(_loc2_)
               {
                  _loc5_ = LocalizationManager.translateIdOnly(25759);
               }
               else
               {
                  _loc3_ = "unknown";
                  if(_itemToTradeFor is Item)
                  {
                     _loc3_ = "accessory";
                  }
                  else if(_itemToTradeFor is DenItem)
                  {
                     _loc3_ = "den item";
                  }
                  else if(_itemToTradeFor is PetItem)
                  {
                     _loc3_ = "pet item";
                  }
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(11386,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  SBTracker.trackPageview("/game/play/trading/request/denied/#" + _loc3_ + "/#0/#" + _itemToTradeFor.defId,-1,1);
               }
            }
            else if(_loc4_ == 3)
            {
               if(_loc2_)
               {
                  _loc5_ = LocalizationManager.translateIdOnly(25760);
               }
               else
               {
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(11387,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  SBTracker.trackPageview("/game/play/trading/request/itemAlreadyTraded",-1,1);
               }
            }
            else if(_loc4_ == 4)
            {
               if(_loc2_)
               {
                  _loc5_ = LocalizationManager.translateIdOnly(25761);
               }
               else
               {
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(11388,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  SBTracker.trackPageview("/game/play/trading/request/alreadyInTrade",-1,1);
               }
            }
            else if(_loc4_ == 5)
            {
               if(_loc2_)
               {
                  _loc5_ = LocalizationManager.translateIdOnly(14804);
               }
               else
               {
                  _loc5_ = LocalizationManager.translateIdAndInsertOnly(11389,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  SBTracker.trackPageview("/game/play/trading/request/fullInventoryReceiver",-1,1);
               }
            }
            else
            {
               if(_loc4_ == 6)
               {
                  closeConfirmTradePopup();
                  closeTradeRequestedPopup();
                  isCurrentlyTrading = false;
                  return;
               }
               if(_loc4_ == 7)
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
               if(_loc4_ == 8)
               {
                  if(_loc2_)
                  {
                     _loc5_ = LocalizationManager.translateIdOnly(25759);
                  }
                  else
                  {
                     _loc5_ = LocalizationManager.translateIdAndInsertOnly(11386,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  }
               }
               else
               {
                  if(_loc4_ != 9)
                  {
                     DebugUtility.debugTrace("This should never happen... flag=" + _loc4_);
                     closeConfirmTradePopup();
                     closeRequestSentPopup();
                     isCurrentlyTrading = false;
                     return;
                  }
                  if(_loc2_)
                  {
                     _loc5_ = LocalizationManager.translateIdOnly(25754);
                  }
                  else
                  {
                     _loc5_ = LocalizationManager.translateIdAndInsertOnly(25755,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  }
               }
            }
            isCurrentlyTrading = false;
            closeConfirmTradePopup();
            closeRequestSentPopup();
            new SBOkPopup(_guiLayer,_loc5_,true,onSBOkBtn);
         }
      }
      
      public static function onTradeListReceived(param1:Object) : void
      {
         var _loc24_:int = 0;
         var _loc28_:int = 0;
         var _loc5_:TradeItemCollection = null;
         var _loc18_:IitemCollection = null;
         var _loc8_:int = 0;
         var _loc27_:* = 0;
         var _loc6_:int = 0;
         var _loc29_:Boolean = false;
         var _loc16_:String = null;
         var _loc14_:String = null;
         var _loc21_:int = 0;
         var _loc25_:Item = null;
         var _loc19_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc15_:DenItem = null;
         var _loc11_:int = 0;
         var _loc3_:Number = NaN;
         var _loc2_:* = 0;
         var _loc22_:* = 0;
         var _loc23_:* = 0;
         var _loc7_:String = null;
         var _loc26_:int = 0;
         var _loc17_:int = 0;
         var _loc13_:int = 0;
         var _loc4_:PetItem = null;
         var _loc12_:String = param1[2];
         var _loc20_:int = 3;
         if(gMainFrame.userInfo.myUserName.toLowerCase() == _loc12_.toLowerCase())
         {
            _loc5_ = new TradeItemCollection();
            _numClothingItemsInTradeList = int(param1[_loc20_++]);
            _loc24_ = 0;
            while(_loc24_ < _numClothingItemsInTradeList)
            {
               _loc20_ += 1;
               _loc5_.pushTradeItem(new TradeItem(int(param1[_loc20_++]),0));
               _loc20_ += 1;
               _loc24_++;
            }
            _numDenItemsInTradeList = _loc28_ = int(param1[_loc20_++]);
            _loc24_ = 0;
            while(_loc24_ < _loc28_)
            {
               _loc20_ += 1;
               _loc5_.pushTradeItem(new TradeItem(int(param1[_loc20_++]),1));
               _loc20_ += 6;
               _loc24_++;
            }
            _numPetItemsInTradeList = int(param1[_loc20_++]);
            _loc24_ = 0;
            while(_loc24_ < _numPetItemsInTradeList)
            {
               _loc20_ += 1;
               _loc5_.pushTradeItem(new TradeItem(int(param1[_loc20_++]),3));
               _loc20_ += 4;
               _loc24_++;
            }
            gMainFrame.userInfo.myTradeList = _loc5_;
         }
         else
         {
            _loc18_ = new IitemCollection();
            _loc21_ = int(param1[_loc20_++]);
            _loc24_ = 0;
            while(_loc24_ < _loc21_)
            {
               _loc8_ = int(param1[_loc20_++]);
               _loc6_ = int(param1[_loc20_++]);
               _loc27_ = uint(param1[_loc20_++]);
               _loc25_ = new Item();
               _loc25_.init(_loc8_,_loc6_,_loc27_);
               _loc18_.pushIitem(_loc25_);
               _loc24_++;
            }
            _loc28_ = int(param1[_loc20_++]);
            _loc24_ = 0;
            while(_loc24_ < _loc28_)
            {
               _loc8_ = int(param1[_loc20_++]);
               _loc6_ = int(param1[_loc20_++]);
               _loc27_ = uint(int(param1[_loc20_++]));
               _loc29_ = param1[_loc20_++] == "true";
               _loc16_ = param1[_loc20_++];
               _loc14_ = param1[_loc20_++];
               _loc9_ = int(param1[_loc20_++]);
               _loc10_ = param1[_loc20_++];
               _loc15_ = new DenItem();
               _loc15_.init(_loc8_,_loc6_,0,_loc27_,0,null,0,_loc29_,_loc16_,_loc14_,_loc9_,_loc10_);
               _loc18_.pushIitem(_loc15_);
               _loc24_++;
            }
            _loc11_ = int(param1[_loc20_++]);
            _loc24_ = 0;
            while(_loc24_ < _loc11_)
            {
               _loc8_ = int(param1[_loc20_++]);
               _loc6_ = int(param1[_loc20_++]);
               _loc3_ = Number(param1[_loc20_++]);
               _loc2_ = uint(param1[_loc20_++]);
               _loc22_ = uint(param1[_loc20_++]);
               _loc23_ = uint(param1[_loc20_++]);
               _loc7_ = param1[_loc20_++];
               _loc26_ = int(param1[_loc20_++]);
               _loc17_ = int(param1[_loc20_++]);
               _loc13_ = int(param1[_loc20_++]);
               _loc4_ = new PetItem();
               _loc4_.init(_loc3_,_loc8_,[_loc2_,_loc22_,_loc23_],_loc26_,_loc17_,_loc13_,_loc6_,_loc7_,false,0,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc8_,2)));
               _loc18_.pushIitem(_loc4_);
               _loc24_++;
            }
            BuddyManager.onTradeListReceived(_loc12_,_loc18_);
         }
      }
      
      public static function changeTradeList(param1:TradeItemCollection, param2:TradeItemCollection) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:TradeItemCollection = gMainFrame.userInfo.getMyTradeList();
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               if(param2.getTradeItem(_loc5_).isEqual(_loc3_.getTradeItem(_loc4_)))
               {
                  _loc3_.getCoreArray().splice(_loc4_,1);
                  break;
               }
               _loc4_++;
            }
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc3_.pushTradeItem(param1.getTradeItem(_loc5_));
            _loc5_++;
         }
         gMainFrame.userInfo.myTradeList = _loc3_;
         TradeXtCommManager.sendTradeSetRequest(param1,param2);
      }
      
      public static function get initiationTradeList() : IitemCollection
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
      
      public static function adjustByOnNumPetItemsInInitiateTradeList(param1:int) : void
      {
         _numPetItemsInInitiateTradeList += param1;
      }
      
      public static function get numClothingItemsInMyTradeList() : int
      {
         return _numClothingItemsInTradeList;
      }
      
      public static function get numDenItemsInMyTradeList() : int
      {
         return _numDenItemsInTradeList;
      }
      
      public static function get numPetItemsInMyTradeList() : int
      {
         return _numPetItemsInTradeList;
      }
      
      public static function adjustByOnNumClothingItemsInMyTradeList(param1:int) : void
      {
         _numClothingItemsInTradeList += param1;
      }
      
      public static function adjustByOnNumDenItemsInMyTradeList(param1:int) : void
      {
         _numDenItemsInTradeList += param1;
      }
      
      public static function adjustByOnNumPetItemsInMyTradeList(param1:int) : void
      {
         _numPetItemsInTradeList += param1;
      }
      
      public static function resetNumTradeItems(param1:int, param2:int, param3:int) : void
      {
         if(param1 != -1 && param2 != -1 && param3 != -1)
         {
            _numClothingItemsInTradeList = param2;
            _numDenItemsInTradeList = param2;
            _numPetItemsInTradeList = param3;
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
            _isInventoryFull = false;
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
      
      private static function buildItemWindows(param1:MovieClip, param2:IitemCollection, param3:Boolean = false) : void
      {
         var _loc12_:int = 0;
         var _loc11_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         var _loc7_:WindowAndScrollbarGenerator = param3 ? _itemWindowTheirs : _itemWindows;
         if(_loc7_)
         {
            _loc7_.destroy();
         }
         var _loc6_:int = int(param2.length);
         var _loc8_:Object = {
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut
         };
         if(_requestTradePopup && param1 == _requestTradePopup.itemBlock)
         {
            _loc10_ = true;
            _loc5_ = true;
            _loc12_ = 2;
            _loc6_ = 4;
            _loc11_ = true;
            _loc4_ = _loc9_ = Math.min(_loc6_,_loc12_);
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
            _loc10_ = true;
            _loc12_ = 1;
            _loc11_ = true;
            _loc9_ = _loc4_ = 1;
            while(_requestTradePopup.itemBlockTheirs.numChildren > 1)
            {
               _requestTradePopup.itemBlockTheirs.removeChildAt(_requestTradePopup.itemBlockTheirs.numChildren - 1);
            }
         }
         else if(_tradeDonePopup && param1 == _tradeDonePopup.itemBlock)
         {
            _loc10_ = true;
            if(_loc6_ > 4)
            {
               _loc9_ = 2;
               _loc4_ = _loc6_ / 2;
            }
            else
            {
               _loc9_ = _loc6_;
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
               _loc9_ = 2;
               _loc4_ = _loc6_ / 2;
            }
            else
            {
               _loc9_ = _loc6_;
               _loc4_ = 1;
            }
            while(_tradeConfirmPopup.itemBlock.numChildren > 1)
            {
               _tradeConfirmPopup.itemBlock.removeChildAt(_tradeConfirmPopup.itemBlock.numChildren - 1);
            }
         }
         else if(_tradeConfirmPopup && param1 == _tradeConfirmPopup.itemBlockTheirs)
         {
            _loc10_ = true;
            _loc12_ = 1;
            _loc11_ = true;
            _loc9_ = _loc4_ = 1;
            while(_tradeConfirmPopup.itemBlockTheirs.numChildren > 1)
            {
               _tradeConfirmPopup.itemBlockTheirs.removeChildAt(_tradeConfirmPopup.itemBlockTheirs.numChildren - 1);
            }
         }
         else if(_tradeRequestedPopup && param1 == _tradeRequestedPopup.itemBlocks.itemBlock)
         {
            _loc10_ = true;
            if(_loc6_ > 4)
            {
               _loc9_ = 2;
               _loc4_ = _loc6_ / 2;
            }
            else
            {
               _loc9_ = Math.min(2,_loc6_);
               _loc4_ = 1;
            }
            while(_tradeRequestedPopup.itemBlocks.itemBlock.numChildren > 1)
            {
               _tradeRequestedPopup.itemBlocks.itemBlock.removeChildAt(_tradeRequestedPopup.itemBlocks.itemBlock.numChildren - 1);
            }
         }
         else if(_tradeRequestedPopup && param1 == _tradeRequestedPopup.itemBlockTheirs)
         {
            _loc10_ = true;
            _loc12_ = 1;
            _loc11_ = true;
            _loc9_ = _loc4_ = 1;
            while(_tradeRequestedPopup.itemBlockTheirs.numChildren > 1)
            {
               _tradeRequestedPopup.itemBlockTheirs.removeChildAt(_tradeRequestedPopup.itemBlockTheirs.numChildren - 1);
            }
         }
         _loc7_ = new WindowAndScrollbarGenerator();
         _loc7_.init("widthCont" in param1 ? param1.widthCont.width : param1.width,"widthCont" in param1 ? param1.widthCont.height : param1.height,0,0,_loc9_,_loc4_,0,2,3,1,1.5,ItemWindowOriginal,param2.getCoreArray(),"icon",0,_loc8_,{
            "isTradeManager":_loc11_,
            "loadImmediately":false,
            "showAddRemoveBtns":_loc5_
         },null,false,false,true,false,_loc10_);
         param1.addChild(_loc7_);
         if(param3)
         {
            _itemWindowTheirs = _loc7_;
         }
         else
         {
            _itemWindows = _loc7_;
         }
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
      
      private static function addTradeItem(param1:Iitem) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _initiationTradeList.length)
         {
            if(param1 is DenItem)
            {
               if(_initiationTradeList.getIitem(_loc2_) is DenItem)
               {
                  if(param1.invIdx == _initiationTradeList.getIitem(_loc2_).invIdx)
                  {
                     return;
                  }
               }
            }
            else if(param1 is Item)
            {
               if(_initiationTradeList.getIitem(_loc2_) is Item)
               {
                  if(param1.invIdx == _initiationTradeList.getIitem(_loc2_).invIdx)
                  {
                     return;
                  }
               }
            }
            else if(param1 is PetItem)
            {
               if(_initiationTradeList.getIitem(_loc2_) is PetItem)
               {
                  if(param1.invIdx == _initiationTradeList.getIitem(_loc2_).invIdx)
                  {
                     return;
                  }
               }
            }
            _loc2_++;
         }
         _initiationTradeList.pushIitem(param1);
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
         if(_denClothesSelectPopup)
         {
            _denClothesSelectPopup.destroy();
            _denClothesSelectPopup = null;
         }
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
         param1.customDiamond.visible = false;
         param1.previewBtn.visible = false;
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
            param1.extraToolTipText = "extraTooltipInfo" in param2 ? param2.extraTooltipInfo : "";
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
            if(param2.isRareDiamond || param2.isRare && param2.isDiamond)
            {
               param1.rareDiamondTag.visible = true;
            }
            else if(param2.isCustom)
            {
               param1.customDiamond.visible = true;
               param1.previewBtn.visible = true;
               param1.previewBtn.addEventListener("mouseDown",onItemPreviewDown,false,0,true);
               param1.previewBtn.itemData = param2;
            }
            else
            {
               param1.rare.visible = param2.isRare;
               param1.diamond.visible = param2.isDiamond;
            }
         }
      }
      
      private static function findItem(param1:TradeItem) : Iitem
      {
         var _loc3_:int = 0;
         var _loc2_:IitemCollection = BuddyManager.getTradeListFromBuddyCard();
         if(_loc2_)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if((param1.itemType == 0 && _loc2_.getIitem(_loc3_) is Item || param1.itemType == 1 && _loc2_.getIitem(_loc3_) is DenItem || param1.itemType == 3 && _loc2_.getIitem(_loc3_) is PetItem) && param1.invIdx == _loc2_.getIitem(_loc3_).invIdx)
               {
                  return _loc2_.getIitem(_loc3_);
               }
               _loc3_++;
            }
         }
         return null;
      }
      
      private static function setupItemToTradeFor(param1:TradeItem) : void
      {
         var _loc2_:Iitem = null;
         var _loc3_:Iitem = null;
         if(param1 != null)
         {
            _loc3_ = findItem(param1);
            if(_loc3_)
            {
               if(param1.itemType == 0)
               {
                  _loc2_ = new Item();
                  (_loc2_ as Item).init(_loc3_.defId,_loc3_.invIdx,(_loc3_ as Item).color,(_loc3_ as Item).inUseFlagLand > 0 ? -1 : 0,(_loc3_ as Item).inUseFlagOcean > 0 ? -1 : 0);
               }
               else if(param1.itemType == 3)
               {
                  _loc2_ = new PetItem();
                  (_loc2_ as PetItem).init((_loc3_ as PetItem).createdTs,_loc3_.defId,(_loc3_ as PetItem).petBits,(_loc3_ as PetItem).traitDefId,(_loc3_ as PetItem).toyDefId,(_loc3_ as PetItem).foodDefId,_loc3_.invIdx,(_loc3_ as PetItem).name,_loc3_.isShopItem,_loc3_.endTime,null,(_loc3_ as PetItem).diamondItem);
               }
               else
               {
                  _loc2_ = new DenItem();
                  (_loc2_ as DenItem).init(_loc3_.defId,_loc3_.invIdx,(_loc3_ as DenItem).categoryId,(_loc3_ as DenItem).version,(_loc3_ as DenItem).refId,(_loc3_ as DenItem).petItem,(_loc3_ as DenItem).endTime,(_loc3_ as DenItem).isApproved,(_loc3_ as DenItem).uniqueImageId,(_loc3_ as DenItem).uniqueImageCreator,(_loc3_ as DenItem).uniqueImageCreatorDbId,(_loc3_ as DenItem).uniqueImageCreatorUUID);
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
            if(param1.currentTarget.cir.isActivePet)
            {
               param1.currentTarget.cir.gotoAndStop("green");
            }
            else if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
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
         var _loc2_:DenItem = null;
         var _loc3_:PetItem = null;
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(param1.currentTarget.name == "previewBtn")
         {
            _loc2_ = param1.currentTarget.parent.parent.currItem as DenItem;
            GuiManager.openMasterpiecePreview(_loc2_.uniqueImageId,_loc2_.uniqueImageCreator,_loc2_.uniqueImageCreatorDbId,_loc2_.uniqueImageCreatorUUID,_loc2_.version);
         }
         else if(param1.currentTarget.name == "certBtn")
         {
            _loc3_ = param1.currentTarget.parent.parent.currItem as PetItem;
            if(_loc3_)
            {
               GuiManager.openPetCertificatePopup(_loc3_.largeIcon as GuiPet,null);
            }
         }
         else if(param1.currentTarget.removeBtn.visible)
         {
            _initiationTradeList.getIitem(param1.currentTarget.index) is Item ? adjustByOnNumClothingItemsInInitiateTradeList(-1) : adjustByOnNumDenItemsInInitiateTradeList(-1);
            _itemWindows.updateItem(param1.currentTarget.index,null);
            if(_initiationTradeList.length > 3)
            {
               _itemWindows.deleteItem(param1.currentTarget.index,_initiationTradeList.getCoreArray());
               if(_initiationTradeList.length == 20 - 1)
               {
                  _itemWindows.insertItem(null,true);
               }
            }
            else
            {
               _initiationTradeList.getCoreArray().splice(Math.min(_initiationTradeList.length - 1,param1.currentTarget.index),1);
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
            if(_denClothesSelectPopup)
            {
               _denClothesSelectPopup.destroy();
            }
            else
            {
               _denClothesSelectPopup = new DenAndClothesItemSelect();
            }
            _denClothesSelectPopup.init(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,_guiLayer,null,addTradeItem,false,true);
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
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Iitem = null;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         param1.stopPropagation();
         if(!_requestTradePopup.doneBtn.isGray)
         {
            _loc7_ = 0;
            while(_loc7_ < _initiationTradeList.length)
            {
               _loc3_ = _initiationTradeList.getIitem(_loc7_);
               if(_loc3_.isDiamond)
               {
                  _loc5_++;
               }
               else if(_loc3_.isRare)
               {
                  _loc4_++;
               }
               else if(_loc3_.isRareDiamond)
               {
                  _loc2_++;
               }
               _loc7_++;
            }
            _loc6_ = 0;
            if(_loc2_ == 1)
            {
               _loc6_ = 6;
            }
            else if(_loc5_ > 0 && _loc4_ > 0 || _loc2_ > 1)
            {
               _loc6_ = 5;
            }
            else if(_loc5_ == 1)
            {
               _loc6_ = 3;
            }
            else if(_loc5_ > 1)
            {
               _loc6_ = 4;
            }
            else if(_loc4_ == 1)
            {
               _loc6_ = 1;
            }
            else if(_loc4_ > 1)
            {
               _loc6_ = 2;
            }
            if(_loc6_ != 0)
            {
               _requestTradePopup.tradeConfirmPopup = new TradeConfirmPopup(_guiLayer,_loc6_,false,onConfirmSendTradeRequest,param1);
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
         var _loc8_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:int = 0;
         var _loc9_:Array = [];
         var _loc7_:Array = [];
         var _loc10_:Array = [];
         var _loc6_:Array = [];
         var _loc5_:Array = [];
         _loc8_ = 0;
         while(_loc8_ < 3)
         {
            _loc10_[_loc8_] = 0;
            _loc6_[_loc8_] = 0;
            _loc8_++;
         }
         var _loc12_:int = 0;
         var _loc4_:int = 0;
         _loc11_ = 0;
         while(_loc11_ < _initiationTradeList.length)
         {
            if(_initiationTradeList.getIitem(_loc11_) is Item)
            {
               _loc10_[_initiationTradeList.getIitem(_loc11_).enviroType]++;
               _loc9_.push(_initiationTradeList.getIitem(_loc11_).invIdx);
            }
            else if(_initiationTradeList.getIitem(_loc11_) is DenItem)
            {
               if((_initiationTradeList.getIitem(_loc11_) as DenItem).sortId == 4)
               {
                  _loc12_++;
               }
               else
               {
                  _loc6_[_initiationTradeList.getIitem(_loc11_).enviroType]++;
               }
               _loc7_.push(_initiationTradeList.getIitem(_loc11_).invIdx);
            }
            else if(_initiationTradeList.getIitem(_loc11_) is PetItem)
            {
               _loc4_++;
               _loc5_.push(_initiationTradeList.getIitem(_loc11_).invIdx);
            }
            _loc11_++;
         }
         _numClothingItemsInInitiateTradeList = 0;
         _numDenItemsInInitiateTradeList = 0;
         _numPetItemsInInitiateTradeList = 0;
         SBTracker.push();
         var _loc2_:Boolean = true;
         if(_itemToTradeFor is Item)
         {
            if(_itemToTradeFor.enviroType == 0)
            {
               if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),0) + 1 - _loc10_[0] > Shop.maxItems)
               {
                  _loc2_ = false;
               }
            }
            else if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),1) + 1 - _loc10_[1] > Shop.maxItems)
            {
               _loc2_ = false;
            }
            _loc3_ = 0;
         }
         else if(_itemToTradeFor is PetItem)
         {
            if(PetManager.myPetList.length + 1 - _loc4_ > PetManager.getPetInventoryMax())
            {
               _loc2_ = false;
            }
            _loc3_ = 3;
         }
         else
         {
            if((_itemToTradeFor as DenItem).sortId == 4)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,-1,true) + 1 - _loc12_ > Shop.maxAudioItems)
               {
                  _loc2_ = false;
               }
            }
            else if(_itemToTradeFor.enviroType == 0)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,0) + 1 - _loc6_[0] > Shop.maxDenItems)
               {
                  _loc2_ = false;
               }
            }
            else if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,1) + 1 - _loc6_[1] > Shop.maxDenItems)
            {
               _loc2_ = false;
            }
            _loc3_ = 1;
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            onClose(param1);
            TradeXtCommManager.sendTradeBusyRequest(false);
            isCurrentlyTrading = false;
            BuddyManager.destroyBuddyCard();
            return;
         }
         if(_loc2_)
         {
            SBTracker.trackPageview("/game/play/trading/request/initiated",-1,1);
            TradeXtCommManager.sendTradeItemsRequest(_requestTradePopup.currUsernameToTradeTo,_itemToTradeFor.invIdx,_loc3_,_loc9_,_loc7_,_loc12_,_loc5_,_loc4_);
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
         BuddyManager.destroyBuddyCard();
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
               if(!_loc2_ || _isInventoryFull)
               {
                  closeRequestSentPopup();
                  TradeXtCommManager.sendTradeBusyRequest(false);
                  if(_isInventoryFull)
                  {
                     new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14804),true,onSBOkBtn);
                  }
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
         var _loc3_:int = 0;
         var _loc2_:Iitem = (_itemWindowTheirs.mediaWindows[0] as ItemWindowOriginal).currItem as Iitem;
         if(_loc2_.isRareDiamond || _loc2_.isDiamond && _loc2_.isRare)
         {
            _loc3_ = 5;
         }
         else if(_loc2_.isDiamond)
         {
            _loc3_ = 3;
         }
         else if(_loc2_.isRare)
         {
            _loc3_ = 1;
         }
         _tradeRequestedPopup.tradeConfirmPopup = new TradeConfirmPopup(_guiLayer,_loc3_,false,onConfirmAcceptTrade);
         _tradeRequestedPopup.currentMouseTarget = param1;
      }
      
      private static function onConfirmAcceptTrade(param1:Boolean) : void
      {
         _tradeRequestedPopup.tradeConfirmPopup.destroy();
         _tradeRequestedPopup.tradeConfirmPopup = null;
         if(param1)
         {
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
      
      private static function onItemPreviewDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Object = param1.currentTarget.itemData;
         if(_loc2_ is DenItem)
         {
            GuiManager.openMasterpiecePreview((_loc2_ as DenItem).uniqueImageId,(_loc2_ as DenItem).uniqueImageCreator,(_loc2_ as DenItem).uniqueImageCreatorDbId,(_loc2_ as DenItem).uniqueImageCreatorUUID,(_loc2_ as DenItem).version);
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

