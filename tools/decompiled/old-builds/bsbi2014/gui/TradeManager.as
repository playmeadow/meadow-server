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
      
      public static function init(guiLayer:DisplayLayer) : void
      {
         _guiLayer = guiLayer;
         _mediaViews = [];
         _initiationTradeList = [];
         _loadingSpiral = new LoadingSpiral();
         _denClothesSelectPopup = new DenAndClothesItemSelect();
      }
      
      public static function destroy() : void
      {
         if(Boolean(_itemWindows))
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
      
      public static function displayRequestTrade(itemToTrade:Object, img:MovieClip = null) : void
      {
         if(Boolean(img) && _requestTradePopup == null)
         {
            _requestTradePopup = img.TradeInitiatePopup;
            _requestSentPopup = img.TradeRequestSentPopup;
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
            if(Boolean(itemToTrade is DenItem) && Boolean(itemToTrade.isOcean) && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else if(Boolean(_requestTradePopup))
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
            setupItemToTradeFor(itemToTrade);
            _requestTradePopup.itemBlockTheirs.itemName = _itemToTradeFor.name;
            _requestTradePopup.itemBlockTheirs.iconLayer.addChild(_itemToTradeFor.icon);
            setupItemBlock(_requestTradePopup.itemBlockTheirs,_itemToTradeFor);
            if(Boolean(itemToTrade is DenItem) && Boolean(itemToTrade.isOcean) && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else
         {
            loadPopup(REQUEST_TRADE);
            setupItemToTradeFor(itemToTrade);
         }
      }
      
      public static function displayRequestSent() : void
      {
         if(Boolean(_requestSentPopup))
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
      
      public static function displayTradeRequested(data:Object, img:MovieClip = null) : void
      {
         var avInfo:AvatarInfo = null;
         var totalNumItems:int = 0;
         var numClothingItemsImGetting:int = 0;
         var numDenItemsImGetting:int = 0;
         var currItem:Object = null;
         var j:int = 0;
         var numClothingLandItemsOfferedMe:int = 0;
         var numClothingOceanItemsOfferedMe:int = 0;
         var numDenLandItemsOfferedMe:int = 0;
         var numDenOceanItemsOfferedMe:int = 0;
         var clothingOrDenArray:Array = null;
         var i:int = 0;
         var displayNeedOceanDenPopup:Boolean = false;
         var myDenLandTotal:int = 0;
         var myDenOceanTotal:int = 0;
         var myLandTotal:int = 0;
         var myOceanTotal:int = 0;
         if(Boolean(img) && _tradeRequestedPopup == null)
         {
            _tradeRequestedPopup = img.TradeRequestedPopup;
            _tradeRequestedPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _tradeRequestedPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         }
         if(Boolean(_tradeRequestedPopup))
         {
            AJAudio.playTradeRequestSound();
            _loadingSpiralAvatar = new LoadingSpiral(_tradeRequestedPopup.charBox);
            _tradeRequestedPlayerUsername = data[3];
            avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(_tradeRequestedPlayerUsername);
            if(!avInfo)
            {
               AvatarXtCommManager.requestAvatarGet(_tradeRequestedPlayerUsername,onAvatarGetReceived);
            }
            else
            {
               onAvatarGetReceived(_tradeRequestedPlayerUsername,true,0,avInfo);
            }
            _tradeRequestedPopup.inventoryIsFull = false;
            j = 7;
            numClothingItemsImGetting = int(data[j++]);
            numDenItemsImGetting = int(data[j++]);
            numClothingLandItemsOfferedMe = 0;
            numClothingOceanItemsOfferedMe = 0;
            numDenLandItemsOfferedMe = 0;
            numDenOceanItemsOfferedMe = 0;
            if(!Boolean(AvatarManager.playerAvatar))
            {
               onDeclineTrade(null);
               return;
            }
            myDenLandTotal = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,Utility.ENVIRO_LAND);
            myDenOceanTotal = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,Utility.ENVIRO_OCEAN);
            myLandTotal = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),Utility.ENVIRO_LAND);
            myOceanTotal = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),Utility.ENVIRO_OCEAN);
            if(int(data[5]) < 2)
            {
               clothingOrDenArray = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               if(int(data[5]) == 0)
               {
                  myLandTotal--;
               }
               else
               {
                  myOceanTotal--;
               }
            }
            else
            {
               if(int(data[5]) == 2)
               {
                  myDenLandTotal--;
               }
               else
               {
                  myDenOceanTotal--;
               }
               clothingOrDenArray = AvatarManager.playerAvatar.inventoryDenFull.itemArray;
            }
            if(myDenLandTotal + numDenLandItemsOfferedMe > Shop.maxDenItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(myDenOceanTotal + numDenOceanItemsOfferedMe > Shop.maxDenItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(myLandTotal + numClothingLandItemsOfferedMe > Shop.maxItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            else if(myOceanTotal + numClothingOceanItemsOfferedMe > Shop.maxItems)
            {
               _tradeRequestedPopup.inventoryIsFull = true;
            }
            _guiLayer.addChild(_tradeRequestedPopup);
            DarkenManager.darken(_tradeRequestedPopup);
            addTradeRequestedListeners();
            _tradeRequestedPopup.yesBtn.visible = false;
            _tradeRequestedPopup.noBtn.visible = false;
            _tradeRequestedPopup.visible = true;
            _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock" + (numClothingItemsImGetting + numDenItemsImGetting));
            for(i = 1; i <= numClothingItemsImGetting; i++)
            {
               while(_tradeRequestedPopup.itemBlocks["itemBlock" + i].iconLayer.numChildren > 0)
               {
                  _tradeRequestedPopup.itemBlocks["itemBlock" + i].iconLayer.removeChildAt(0);
               }
               currItem = new Item();
               currItem.init(int(data[j++]),0,uint(data[j++]));
               if(currItem.enviroType == Utility.ENVIRO_LAND)
               {
                  numClothingLandItemsOfferedMe++;
               }
               else
               {
                  numClothingOceanItemsOfferedMe++;
               }
               _tradeRequestedPopup.itemBlocks["itemBlock" + i].itemName = currItem.name;
               _tradeRequestedPopup.itemBlocks["itemBlock" + i].iconLayer.addChild(currItem.icon);
               setupItemBlock(_tradeRequestedPopup.itemBlocks["itemBlock" + i],currItem);
            }
            for(i = 1; i <= numDenItemsImGetting; i++)
            {
               while(_tradeRequestedPopup.itemBlocks["itemBlock" + (i + numClothingItemsImGetting)].iconLayer.numChildren > 0)
               {
                  _tradeRequestedPopup.itemBlocks["itemBlock" + (i + numClothingItemsImGetting)].iconLayer.removeChildAt(0);
               }
               currItem = new DenItem();
               currItem.init(data[j++],0,0,data[j++],0);
               if(currItem.enviroType == Utility.ENVIRO_LAND)
               {
                  numDenLandItemsOfferedMe++;
               }
               else
               {
                  numDenOceanItemsOfferedMe++;
               }
               if(!displayNeedOceanDenPopup && currItem.enviroType == Utility.ENVIRO_OCEAN && !DenSwitch.haveOceanDen())
               {
                  displayNeedOceanDenPopup = true;
               }
               _tradeRequestedPopup.itemBlocks["itemBlock" + (i + numClothingItemsImGetting)].itemName = currItem.name;
               _tradeRequestedPopup.itemBlocks["itemBlock" + (i + numClothingItemsImGetting)].iconLayer.addChild(currItem.icon);
               setupItemBlock(_tradeRequestedPopup.itemBlocks["itemBlock" + (i + numClothingItemsImGetting)],currItem);
            }
            while(_tradeRequestedPopup.itemBlockTheirs.iconLayer.numChildren > 0)
            {
               _tradeRequestedPopup.itemBlockTheirs.iconLayer.removeChildAt(0);
            }
            if(Boolean(clothingOrDenArray) && clothingOrDenArray.length > 0)
            {
               for(i = 0; i < clothingOrDenArray.length; i++)
               {
                  if(clothingOrDenArray[i].invIdx == int(data[6]))
                  {
                     _tradeRequestedPopup.itemBlockTheirs.iconLayer.addChild(clothingOrDenArray[i].clone().icon);
                     _tradeRequestedPopup.itemBlockTheirs.itemName = clothingOrDenArray[i].name;
                     setupItemBlock(_tradeRequestedPopup.itemBlockTheirs,clothingOrDenArray[i]);
                     break;
                  }
               }
            }
            setTimeout(showTradeButtonsAfterDelay,2000);
            if(displayNeedOceanDenPopup)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else
         {
            loadPopup(TRADE_REQUESTED,data);
         }
      }
      
      public static function displayTradeDone(data:Object, img:MovieClip = null) : void
      {
         var numItemsReceived:int = 0;
         var currItem:Object = null;
         var myUserInfo:UserInfo = null;
         var myAvInfoList:Object = null;
         var avType:int = 0;
         var myperUserAvId:int = 0;
         var myAv:Avatar = null;
         var myAvInfo:AvatarInfo = null;
         var j:int = 0;
         var itemDef:Object = null;
         var i:int = 0;
         var k:int = 0;
         var invIdx:int = 0;
         var numItemsRemoved:int = 0;
         var type:int = 0;
         var pendingDenChanges:Array = null;
         var list:Array = null;
         var dInvIdx:int = 0;
         var defId:int = 0;
         var version:int = 0;
         var myTradeList:Array = null;
         var myClothingCacheList:Array = null;
         var myCurrClothingList:Array = null;
         var l:int = 0;
         var myDenCacheList:Array = null;
         var myDenList:Array = null;
         var denItem:DenItem = null;
         if(Boolean(img) && _tradeDonePopup == null)
         {
            _tradeDonePopup = img.TradeDonePopup;
            if(Boolean(_tradeDonePopup))
            {
               _tradeDonePopup.x = MainFrame.VIEW_WIDTH * 0.5;
               _tradeDonePopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            }
         }
         if(Boolean(_tradeDonePopup))
         {
            AJAudio.playTradeSuccessSound();
            numItemsReceived = int(data[3]);
            _guiLayer.addChild(_tradeDonePopup);
            DarkenManager.darken(_tradeDonePopup);
            _tradeDonePopup.visible = true;
            addTradeDoneListeners();
            _tradeDonePopup.gotoAndStop(numItemsReceived);
            myUserInfo = gMainFrame.userInfo.playerUserInfo;
            myAvInfoList = gMainFrame.userInfo.playerUserInfo.avList;
            avType = int(gMainFrame.userInfo.playerAvatarInfo.type);
            myperUserAvId = int(gMainFrame.userInfo.playerAvatarInfo.perUserAvId);
            myAv = AvatarManager.getAvatarByUsernamePerUserAvId(myUserInfo.userName,myperUserAvId);
            j = 4;
            for(i = 1; i <= numItemsReceived; i++)
            {
               while(_tradeDonePopup["itemBlock" + i].iconLayer.numChildren > 0)
               {
                  _tradeDonePopup["itemBlock" + i].iconLayer.removeChildAt(0);
               }
               if(data[j++] == "0")
               {
                  currItem = new Item();
                  currItem.init(int(data[j++]),int(data[j++]),uint(data[j++]));
                  list = myUserInfo.fullItemList;
                  list.unshift(currItem);
                  myUserInfo.fullItemList = list;
                  if(AvatarManager.roomEnviroType == currItem.enviroType)
                  {
                     myAv.inventoryClothing.itemArray.unshift(currItem);
                  }
                  _tradeDonePopup["itemBlock" + i].itemName = currItem.name;
                  _tradeDonePopup["itemBlock" + i].iconLayer.addChild(currItem.icon);
                  setupItemBlock(_tradeDonePopup["itemBlock" + i],currItem);
               }
               else
               {
                  dInvIdx = int(data[j++]);
                  defId = int(data[j++]);
                  version = int(data[j++]);
                  currItem = new DenItem();
                  currItem.init(defId,dInvIdx,0,version,0);
                  myUserInfo.denItemsFull.unshift(currItem.clone());
                  _tradeDonePopup["itemBlock" + i].itemName = currItem.name;
                  _tradeDonePopup["itemBlock" + i].iconLayer.addChild(currItem.icon);
                  setupItemBlock(_tradeDonePopup["itemBlock" + i],currItem);
               }
            }
            SBTracker.push();
            if(numItemsReceived == 1)
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted/#" + (currItem is Item ? "accessory" : "den item") + "#0#" + currItem.itemDefId,-1,SBTracker.TYPE_EVENT);
            }
            else
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted",-1,SBTracker.TYPE_EVENT);
            }
            numItemsRemoved = int(data[j++]);
            pendingDenChanges = [];
            for(i = 0; i < numItemsRemoved; i++)
            {
               type = int(data[j++]);
               invIdx = int(data[j++]);
               if(type == 0)
               {
                  myClothingCacheList = myUserInfo.getFullItemList(true);
                  for(k = 0; k < myClothingCacheList.length; k++)
                  {
                     if(myClothingCacheList[k].invIdx == invIdx)
                     {
                        myClothingCacheList.splice(k,1);
                        break;
                     }
                  }
                  myUserInfo.fullItemList = myClothingCacheList;
                  myCurrClothingList = myAv.inventoryClothing.itemArray;
                  for(k = 0; k < myCurrClothingList.length; k++)
                  {
                     if(myCurrClothingList[k].invIdx == invIdx)
                     {
                        myAv.accStateHideAccessory(myCurrClothingList[k],false);
                        myCurrClothingList.splice(k,1);
                        break;
                     }
                  }
               }
               else
               {
                  myDenCacheList = myUserInfo.denItemsFull;
                  for(k = 0; k < myDenCacheList.length; k++)
                  {
                     if(myDenCacheList[k].invIdx == invIdx)
                     {
                        if(myDenCacheList[k].sortId == DenItem.SORT_AUDIO && myDenCacheList[k].categoryId != 0)
                        {
                           for(l = 0; l < myDenCacheList.length; l++)
                           {
                              if(myDenCacheList[l].itemDefId == DenItem.DEF_AUDIO_DEF_ID)
                              {
                                 myDenCacheList[l].categoryId = 1;
                                 break;
                              }
                           }
                        }
                        pendingDenChanges.push({
                           "i":invIdx,
                           "catId":0,
                           "r":myDenCacheList[k].refId
                        });
                        myDenCacheList.splice(k,1);
                     }
                  }
                  myDenList = myAv.inventoryDenFull.itemArray;
                  for(k = 0; k < myDenList.length; k++)
                  {
                     if(myDenList[k].invIdx == invIdx)
                     {
                        if(myDenList[k].sortId == DenItem.SORT_AUDIO && myDenList[k].categoryId != 0)
                        {
                           for(l = 0; l < myDenList.length; l++)
                           {
                              if(myDenList[l].itemDefId == DenItem.DEF_AUDIO_DEF_ID)
                              {
                                 myDenList[l].categoryId = 1;
                                 break;
                              }
                           }
                        }
                        myDenList.splice(k,1);
                     }
                  }
                  myAv.inventoryDenPartial.itemArray = [];
                  myUserInfo.denItemsPartial = [];
                  for each(denItem in myAv.inventoryDenFull.itemArray)
                  {
                     if(denItem.enviroType == AvatarManager.roomEnviroType)
                     {
                        myAv.inventoryDenPartial.itemArray.push(denItem);
                        myUserInfo.denItemsPartial.push(denItem);
                     }
                  }
               }
               myTradeList = gMainFrame.userInfo.getMyTradeList();
               for(k = 0; k < myTradeList.length; k++)
               {
                  if(myTradeList[k].type == type && myTradeList[k].invIdx == invIdx)
                  {
                     myTradeList.splice(k,1);
                     if(type == 0)
                     {
                        --_numClothingItemsInTradeList;
                     }
                     else
                     {
                        --_numDenItemsInTradeList;
                     }
                     break;
                  }
               }
            }
            if(pendingDenChanges.length > 0 && gMainFrame.server.getCurrentRoomName(false) == "den" + gMainFrame.userInfo.myUserName)
            {
               RoomManagerWorld.instance.denItemHolder.setItems(pendingDenChanges);
            }
            if(Boolean(GuiManager.denEditor))
            {
               GuiManager.denEditor.reloadDenItems();
            }
            myAv.dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
            GuiManager.showHudAvt();
            closeRequestSentPopup();
         }
         else
         {
            loadPopup(TRADE_DONE,data);
         }
      }
      
      private static function popupsMediaCallback(img:MovieClip) : void
      {
         var funcToCall:Function = null;
         var data:Object = null;
         var soundsMediaHelper:MediaHelper = null;
         if(Boolean(img))
         {
            switch(img.mediaHelper.id)
            {
               case REQUEST_TRADE:
                  funcToCall = displayRequestTrade;
                  data = _itemToTradeFor;
                  break;
               case TRADE_REQUESTED:
                  funcToCall = displayTradeRequested;
                  data = img.passback;
                  break;
               case TRADE_DONE:
                  funcToCall = displayTradeDone;
                  data = img.passback;
            }
            if(!AJAudio.hasLoadedTradeSfx)
            {
               soundsMediaHelper = new MediaHelper();
               soundsMediaHelper.init(TRADING_SOUNDS_MEDIA_ID,onSoundsLoaded,{
                  "funcToCall":funcToCall,
                  "data":data,
                  "img":img
               });
               _mediaViews.push(soundsMediaHelper);
            }
            else
            {
               DarkenManager.showLoadingSpiral(false);
               funcToCall(data,img);
            }
            img.mediaHelper.destroy();
            delete img.mediaHelper;
         }
      }
      
      private static function onSoundsLoaded(img:MovieClip) : void
      {
         var currLoaderAppDomain:ApplicationDomain = null;
         if(Boolean(img))
         {
            if(!AJAudio.hasLoadedTradeSfx)
            {
               currLoaderAppDomain = img.loaderInfo.applicationDomain;
               AJAudio.loadSfx("TradeSuccessSound",currLoaderAppDomain.getDefinition("TradeSuccessSound") as Class,0.5);
               AJAudio.loadSfx("TradeFailedSound",currLoaderAppDomain.getDefinition("TradeFailedSound") as Class,0.5);
               AJAudio.loadSfx("TradeRequestSound",currLoaderAppDomain.getDefinition("TradeRequestSound") as Class,0.7);
               AJAudio.hasLoadedTradeSfx = true;
            }
            DarkenManager.showLoadingSpiral(false);
            img.passback.funcToCall(img.passback.data,img.passback.img);
            img.mediaHelper.destroy();
            delete img.mediaHelper;
            delete img.passback;
         }
      }
      
      private static function showTradeButtonsAfterDelay() : void
      {
         if(Boolean(_tradeRequestedPopup))
         {
            _tradeRequestedPopup.yesBtn.visible = true;
            _tradeRequestedPopup.noBtn.visible = true;
         }
      }
      
      private static function onAvatarGetReceived(userName:String, status:Boolean, onlineStatus:int, avInfo:AvatarInfo = null) : void
      {
         var ui:UserInfo = null;
         if(status && userName == _tradeRequestedPlayerUsername)
         {
            if(!avInfo)
            {
               avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
               if(!avInfo)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            ui = gMainFrame.userInfo.getUserInfoByUserName(_tradeRequestedPlayerUsername);
            if(avInfo.isMember)
            {
               _tradeRequestedPopup.nonmember.visible = false;
               _tradeRequestedPopup.userName_txt.visible = false;
               _tradeRequestedPopup.member.setNubType("buddy",false);
               _tradeRequestedPopup.member.setColorAndBadge(ui.nameBarData);
               _tradeRequestedPopup.member.isBlocked = false;
               _tradeRequestedPopup.member.setAvName(ui.getModeratedUserName(),false);
               _tradeRequestedPopup.member.mouseEnabled = false;
               _tradeRequestedPopup.member.mouseChildren = false;
            }
            else
            {
               _tradeRequestedPopup.member.visible = false;
               _tradeRequestedPopup.userName_txt.visible = true;
               _tradeRequestedPopup.userName_txt.text = ui.getModeratedUserName();
            }
            _tradeRequestAvatar = AvatarManager.getAvatarByUserName(_tradeRequestedPlayerUsername);
            if(_tradeRequestAvatar == null)
            {
               _tradeRequestAvatar = AvatarUtility.generateNew(avInfo.perUserAvId,null,_tradeRequestedPlayerUsername,-1,0,onAvatarItemData);
            }
            drawMainAvatar(_tradeRequestAvatar);
         }
      }
      
      public static function onAvatarItemData() : void
      {
         if(_tradeRequestAvatar != null)
         {
            drawMainAvatar(_tradeRequestAvatar);
         }
      }
      
      private static function drawMainAvatar(avt:Avatar) : void
      {
         if(Utility.isOcean(avt.enviroTypeFlag))
         {
            if(Utility.isLand(avt.enviroTypeFlag))
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
         _tradeRequestAvatarView.init(avt);
         if(avt.avTypeId >= 0)
         {
            _tradeRequestAvatarView.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,positionAndAddMainAvatarView);
         }
      }
      
      private static function positionAndAddMainAvatarView(layerAnim:LayerAnim, animId:int) : void
      {
         var offset:Point = BuddyCard.getAvOffsetByDefId(_tradeRequestAvatarView.avTypeId);
         _tradeRequestAvatarView.x = offset.x;
         _tradeRequestAvatarView.y = offset.y;
         if(Boolean(_tradeRequestedPopup))
         {
            _tradeRequestedPopup.charBox.addChild(_tradeRequestAvatarView);
         }
         _loadingSpiralAvatar.visible = false;
      }
      
      private static function loadPopup(imgId:int, data:Object = null) : void
      {
         var popupsMediaHelper:MediaHelper = null;
         DarkenManager.showLoadingSpiral(true);
         popupsMediaHelper = new MediaHelper();
         popupsMediaHelper.init(imgId,popupsMediaCallback,Boolean(data) ? data : true);
         _mediaViews[_mediaViews.length + 1] = popupsMediaHelper;
      }
      
      public static function onTradeItemsResponse(data:Object) : void
      {
         var msg:String = null;
         var flag:int = int(data[2]);
         if(flag == 0)
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
               displayTradeRequested(data);
            }
         }
         else if(flag == 1)
         {
            displayTradeDone(data);
         }
         else
         {
            isCurrentlyTrading = false;
            SBTracker.push();
            if(flag == 2)
            {
               msg = LocalizationManager.translateIdAndInsertOnly(11386,int(data[4]) > 0 ? data[3] : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               SBTracker.trackPageview("/game/play/trading/request/denied/#" + (_itemToTradeFor is Item ? "accessory" : "den item") + "/#0/#" + _itemToTradeFor.itemDefId,-1,SBTracker.TYPE_EVENT);
            }
            else if(flag == 3)
            {
               msg = LocalizationManager.translateIdAndInsertOnly(11387,int(data[4]) > 0 ? data[3] : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               SBTracker.trackPageview("/game/play/trading/request/itemAlreadyTraded",-1,SBTracker.TYPE_EVENT);
            }
            else if(flag == 4)
            {
               msg = LocalizationManager.translateIdAndInsertOnly(11388,int(data[4]) > 0 ? data[3] : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               SBTracker.trackPageview("/game/play/trading/request/alreadyInTrade",-1,SBTracker.TYPE_EVENT);
            }
            else
            {
               if(flag != 5)
               {
                  if(flag == 6)
                  {
                     closeTradeRequestedPopup();
                     return;
                  }
                  if(flag == 7)
                  {
                     if(QuestManager.isInPrivateAdventureState)
                     {
                        QuestManager.showLeaveQuestLobbyPopup(onTradeItemsResponse,data);
                     }
                     else
                     {
                        new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14704),true,onConfirmServerSwitch);
                     }
                     SBTracker.trackPageview("/game/play/trading/request/diffShard",-1,SBTracker.TYPE_EVENT);
                     _jammerRoomName = data[3];
                     closeRequestSentPopup();
                     return;
                  }
                  DebugUtility.debugTrace("This should never happen... flag=" + flag);
                  closeRequestSentPopup();
                  return;
               }
               msg = LocalizationManager.translateIdAndInsertOnly(11389,int(data[4]) > 0 ? data[3] : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME));
               SBTracker.trackPageview("/game/play/trading/request/fullInventoryReceiver",-1,SBTracker.TYPE_EVENT);
            }
            closeRequestSentPopup();
            new SBOkPopup(_guiLayer,msg,true,onSBOkBtn);
         }
      }
      
      public static function onTradeListReceived(data:Object) : void
      {
         var i:int = 0;
         var numDenItems:int = 0;
         var id:int = 0;
         var color:uint = 0;
         var invIdx:int = 0;
         var currItem:Object = null;
         var numClothingItems:int = 0;
         var sortId:int = 0;
         var tradeList:Array = [];
         var userName:String = data[2];
         var j:int = 3;
         if(gMainFrame.userInfo.myUserName == userName)
         {
            _numClothingItemsInTradeList = int(data[j++]);
            for(i = 0; i < _numClothingItemsInTradeList; i++)
            {
               j += 1;
               tradeList.push({
                  "invIdx":int(data[j++]),
                  "type":CLOTHING_TYPE
               });
               j += 1;
            }
            numDenItems = int(data[j++]);
            _numDenItemsInTradeList = numDenItems;
            for(i = 0; i < numDenItems; i++)
            {
               j += 1;
               tradeList.push({
                  "invIdx":int(data[j++]),
                  "type":DEN_TYPE
               });
               j += 1;
            }
            gMainFrame.userInfo.myTradeList = tradeList;
         }
         else
         {
            numClothingItems = int(data[j++]);
            for(i = 0; i < numClothingItems; i++)
            {
               id = int(data[j++]);
               invIdx = int(data[j++]);
               color = uint(data[j++]);
               currItem = new Item();
               currItem.init(id,invIdx,color);
               tradeList.push(currItem);
            }
            numDenItems = int(data[j++]);
            for(i = 0; i < numDenItems; i++)
            {
               id = int(data[j++]);
               invIdx = int(data[j++]);
               color = uint(int(data[j++]));
               currItem = new DenItem();
               currItem.init(id,invIdx,0,color,0);
               tradeList.push(currItem);
            }
            BuddyCard.onTradeListReceived(userName,tradeList);
         }
      }
      
      public static function changeTradeList(itemsToAdd:Array, itemsToRemove:Array) : void
      {
         var i:int = 0;
         var j:int = 0;
         var tradeItems:Array = gMainFrame.userInfo.getMyTradeList();
         for(i = 0; i < itemsToRemove.length; i++)
         {
            for(j = 0; j < tradeItems.length; j++)
            {
               if(itemsToRemove[i].invIdx == tradeItems[j].invIdx)
               {
                  tradeItems.splice(j,1);
                  break;
               }
            }
         }
         for(i = 0; i < itemsToAdd.length; i++)
         {
            tradeItems.push(itemsToAdd[i]);
         }
         gMainFrame.userInfo.myTradeList = tradeItems;
         TradeXtCommManager.sendTradeSetRequest(itemsToAdd,itemsToRemove);
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
      
      public static function adjustByOnNumClothingItemsInInitiateTradeList(value:int) : void
      {
         _numClothingItemsInInitiateTradeList += value;
      }
      
      public static function adjustByOnNumDenItemsInInitiateTradeList(value:int) : void
      {
         _numDenItemsInInitiateTradeList += value;
      }
      
      public static function get numClothingItemsInMyTradeList() : int
      {
         return _numClothingItemsInTradeList;
      }
      
      public static function get numDenItemsInMyTradeList() : int
      {
         return _numDenItemsInTradeList;
      }
      
      public static function adjustByOnNumClothingItemsInMyTradeList(value:int) : void
      {
         _numClothingItemsInTradeList += value;
      }
      
      public static function adjustByOnNumDenItemsInMyTradeList(value:int) : void
      {
         _numDenItemsInTradeList += value;
      }
      
      public static function resetNumTradeItems(numClothingItems:int, numDenItems:int) : void
      {
         if(numClothingItems != -1 && numDenItems != -1)
         {
            _numClothingItemsInTradeList = numDenItems;
            _numDenItemsInTradeList = numDenItems;
         }
      }
      
      private static function onConfirmServerSwitch(o:Object) : void
      {
         if(Boolean(o.status) && _jammerRoomName != "")
         {
            DarkenManager.showLoadingSpiral(true);
            RoomXtCommManager.sendRoomJoinRequest(_jammerRoomName);
         }
         _jammerRoomName = "";
      }
      
      private static function buildItemWindows(parent:MovieClip) : void
      {
         if(Boolean(_itemWindows) && _itemWindows.parent == parent)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(parent == _requestTradePopup.itemBlock)
         {
            while(_requestTradePopup.itemBlock.numChildren > 0)
            {
               _requestTradePopup.itemBlock.removeChildAt(0);
            }
            if(_initiationTradeList.length < 1)
            {
               if(Boolean(_requestTradePopup.doneBtn.hasGrayState))
               {
                  _requestTradePopup.doneBtn.activateGrayState(true);
               }
            }
            else if(Boolean(_requestTradePopup.doneBtn.hasGrayState))
            {
               _requestTradePopup.doneBtn.activateGrayState(false);
            }
         }
         var numItemsInCurrentArray:int = 4;
         var numWin:int = Math.min(numItemsInCurrentArray,2);
         _itemWindows = new WindowGenerator();
         _itemWindows.init(numWin,numWin,numItemsInCurrentArray,2,2,0,ItemWindowOriginal,_initiationTradeList,"icon",{
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut
         },{
            "isTradeManager":true,
            "loadImmediately":true
         });
         parent.addChild(_itemWindows);
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
      
      private static function addTradeItem(item:Object) : void
      {
         _initiationTradeList.push(item);
         buildItemWindows(_requestTradePopup.itemBlock);
      }
      
      private static function setupItemBlock(itemBlock:MovieClip, itemData:Object) : void
      {
         itemBlock.removeBtn.visible = false;
         itemBlock.addBtn.visible = false;
         itemBlock.gray.visible = false;
         itemBlock.lock.visible = false;
         itemBlock.lockOpen.visible = false;
         itemBlock.gift.visible = false;
         itemBlock.ocean.visible = false;
         itemBlock.rare.visible = false;
         itemBlock.avtSpecific.visible = false;
         itemBlock.avtSpecificHighlight.visible = false;
         itemBlock.avtSpecificIcon.visible = false;
         itemBlock.addEventListener(MouseEvent.MOUSE_OVER,onItemWindowOver,false,0,true);
         itemBlock.addEventListener(MouseEvent.MOUSE_OUT,onItemWindowOut,false,0,true);
         if(Boolean(itemData))
         {
            if(Boolean(itemData.isMemberOnly))
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  itemBlock.lock.visible = true;
               }
               else
               {
                  itemBlock.lockOpen.visible = true;
               }
            }
            itemBlock.extraToolTipText = itemData.extraTooltipInfo;
            if(itemData is Item)
            {
               itemBlock.defId = itemData.defId;
               if(Boolean(itemData.getInUse(0)))
               {
                  itemBlock.cir.gotoAndStop("down");
               }
            }
            else if(itemData is DenItem)
            {
               if(itemData.categoryId != 0)
               {
                  itemBlock.cir.gotoAndStop("down");
               }
            }
            if(Boolean(itemData.isOcean))
            {
               itemBlock.ocean.visible = true;
            }
            if(Boolean(itemData.isRare))
            {
               itemBlock.rare.visible = true;
            }
         }
      }
      
      private static function findItem(itemToTrade:Object) : Object
      {
         var itemArray:Array = BuddyCard.getTradeList();
         for(var i:int = 0; i < itemArray.length; i++)
         {
            if((itemToTrade.type == CLOTHING_TYPE && itemArray[i] is Item || itemToTrade.type == DEN_TYPE && itemArray[i] is DenItem) && itemToTrade.invIdx == itemArray[i].invIdx)
            {
               return itemArray[i];
            }
         }
         return null;
      }
      
      private static function setupItemToTradeFor(itemToTrade:Object) : void
      {
         var currItem:Object = null;
         var tempItem:Object = null;
         if(itemToTrade != null)
         {
            tempItem = findItem(itemToTrade);
            if(Boolean(tempItem))
            {
               if(itemToTrade.type == CLOTHING_TYPE)
               {
                  currItem = new Item();
                  currItem.init(tempItem.defId,tempItem.invIdx,tempItem.color,tempItem.inUseFlagLand > 0 ? -1 : 0,tempItem.inUseFlagOcean > 0 ? -1 : 0);
               }
               else
               {
                  currItem = new DenItem();
                  currItem.init(tempItem.itemDefId,tempItem.invIdx,tempItem.categoryId,tempItem.version,0);
               }
               _itemToTradeFor = currItem;
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
      
      private static function winMouseOver(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(m.currentTarget.numChildren >= 2)
         {
            if(m.currentTarget.cir.currentFrameLabel == "down")
            {
               m.currentTarget.cir.gotoAndStop("downMouse");
            }
            else if(m.currentTarget.cir.currentFrameLabel != "downMouse")
            {
               m.currentTarget.cir.gotoAndStop("over");
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private static function winMouseOut(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(m.currentTarget.numChildren >= 2)
         {
            if(m.currentTarget.cir.currentFrameLabel == "downMouse")
            {
               m.currentTarget.cir.gotoAndStop("down");
            }
            else
            {
               m.currentTarget.cir.gotoAndStop("up");
            }
         }
      }
      
      private static function winMouseDown(m:MouseEvent) : void
      {
         m.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(Boolean(m.currentTarget.removeBtn.visible))
         {
            if(_initiationTradeList[m.currentTarget.index] is Item)
            {
               adjustByOnNumClothingItemsInInitiateTradeList(-1);
            }
            else
            {
               adjustByOnNumDenItemsInInitiateTradeList(-1);
            }
            _initiationTradeList.splice(m.currentTarget.index,1);
            buildItemWindows(_requestTradePopup.itemBlock);
         }
         else if(Boolean(m.currentTarget.addBtn.visible))
         {
            _denClothesSelectPopup.init(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),AvatarManager.playerAvatar.inventoryDenFull.itemArray,_guiLayer,null,addTradeItem,false,true);
         }
      }
      
      private static function onPopoup(m:MouseEvent) : void
      {
         m.stopPropagation();
      }
      
      private static function onSBOkBtn(m:MouseEvent) : void
      {
         m.stopPropagation();
         SBOkPopup.destroyInParentChain(m.target.parent);
         SBTracker.flush(true);
      }
      
      private static function onDoneBtn(m:MouseEvent) : void
      {
         var clothingInvIdxArray:Array = null;
         var denInvIdxArray:Array = null;
         var numClothingItemsByEnviro:Array = null;
         var numDenItemsByEnviro:Array = null;
         var k:int = 0;
         var numDenAudioItems:int = 0;
         var i:int = 0;
         var allow:Boolean = false;
         m.stopPropagation();
         if(!_requestTradePopup.doneBtn.isGray)
         {
            clothingInvIdxArray = [];
            denInvIdxArray = [];
            numClothingItemsByEnviro = [];
            numDenItemsByEnviro = [];
            for(k = 0; k < 3; k++)
            {
               numClothingItemsByEnviro[k] = 0;
               numDenItemsByEnviro[k] = 0;
            }
            numDenAudioItems = 0;
            for(i = 0; i < _initiationTradeList.length; i++)
            {
               if(_initiationTradeList[i] is Item)
               {
                  ++numClothingItemsByEnviro[_initiationTradeList[i].enviroType];
                  clothingInvIdxArray.push(_initiationTradeList[i].invIdx);
               }
               else if(_initiationTradeList[i] is DenItem)
               {
                  if(_initiationTradeList[i].sortId == DenItem.SORT_AUDIO)
                  {
                     numDenAudioItems++;
                  }
                  else
                  {
                     ++numDenItemsByEnviro[_initiationTradeList[i].enviroType];
                  }
                  denInvIdxArray.push(_initiationTradeList[i].invIdx);
               }
            }
            _numClothingItemsInInitiateTradeList = 0;
            _numDenItemsInInitiateTradeList = 0;
            SBTracker.push();
            allow = true;
            if(_itemToTradeFor is Item)
            {
               if(_itemToTradeFor.enviroType == Utility.ENVIRO_LAND)
               {
                  if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),Utility.ENVIRO_LAND) + 1 - numClothingItemsByEnviro[Utility.ENVIRO_LAND] > Shop.maxItems)
                  {
                     allow = false;
                  }
               }
               else if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),Utility.ENVIRO_OCEAN) + 1 - numClothingItemsByEnviro[Utility.ENVIRO_OCEAN] > Shop.maxItems)
               {
                  allow = false;
               }
            }
            else if(_itemToTradeFor.sortId == DenItem.SORT_AUDIO)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,-1,true) + 1 - numDenAudioItems > Shop.maxAudioItems)
               {
                  allow = false;
               }
            }
            else if(_itemToTradeFor.enviroType == Utility.ENVIRO_LAND)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,Utility.ENVIRO_LAND) + 1 - numDenItemsByEnviro[Utility.ENVIRO_LAND] > Shop.maxDenItems)
               {
                  allow = false;
               }
            }
            else if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.itemArray,Utility.ENVIRO_OCEAN) + 1 - numDenItemsByEnviro[Utility.ENVIRO_OCEAN] > Shop.maxDenItems)
            {
               allow = false;
            }
            if(allow)
            {
               SBTracker.trackPageview("/game/play/trading/request/initiated",-1,SBTracker.TYPE_EVENT);
               TradeXtCommManager.sendTradeItemsRequest(BuddyCard.currBuddyCardUserName,_itemToTradeFor.invIdx,_itemToTradeFor is Item,clothingInvIdxArray,denInvIdxArray,numDenAudioItems);
               onClose(m);
               displayRequestSent();
            }
            else
            {
               onClose(m);
               TradeXtCommManager.sendTradeBusyRequest(false);
               isCurrentlyTrading = false;
               SBTracker.trackPageview("/game/play/trading/request/fullInventorySender",-1,SBTracker.TYPE_EVENT);
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14804),true,onSBOkBtn);
            }
            BuddyCard.closeBuddyCard();
         }
      }
      
      private static function onClose(m:MouseEvent) : void
      {
         if(Boolean(m))
         {
            m.stopPropagation();
         }
         DarkenManager.unDarken(m.currentTarget.parent);
         if(m.currentTarget.parent.parent == _guiLayer)
         {
            _guiLayer.removeChild(m.currentTarget.parent);
         }
         m.currentTarget.parent.visible = false;
         switch(m.currentTarget.parent)
         {
            case _requestTradePopup:
               removeRequestTradeListeners();
               if(m.currentTarget.name == "bx")
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
      
      private static function onAcceptTrade(m:MouseEvent) : void
      {
         m.stopPropagation();
         new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14805),true,onConfirmAcceptTrade,m);
      }
      
      private static function onConfirmAcceptTrade(o:Object) : void
      {
         if(Boolean(o.status))
         {
            if(Boolean(_tradeRequestedPopup.inventoryIsFull))
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14804),true,onSBOkBtn);
               isCurrentlyTrading = false;
            }
            TradeXtCommManager.sendTradeItemAcceptOrReject(1);
            onClose(o.passback);
         }
      }
      
      private static function onDeclineTrade(m:MouseEvent) : void
      {
         if(Boolean(m))
         {
            m.stopPropagation();
         }
         TradeXtCommManager.sendTradeItemAcceptOrReject(0);
         if(Boolean(m))
         {
            onClose(m);
         }
         else
         {
            closeTradeRequestedPopup();
         }
         TradeXtCommManager.sendTradeBusyRequest(false);
         isCurrentlyTrading = false;
      }
      
      private static function onItemWindowOver(m:MouseEvent) : void
      {
         if(m.currentTarget.itemName != null)
         {
            GuiManager.toolTip.init(MovieClip(m.currentTarget.parent),m.currentTarget.itemName,ITEM_WINDOW_SIZE * 0.5 + m.currentTarget.x,ITEM_WINDOW_SIZE + m.currentTarget.y);
            GuiManager.toolTip.startTimer(m);
         }
      }
      
      private static function onItemWindowOut(m:MouseEvent) : void
      {
         if(Boolean(m.currentTarget.avtSpecific.visible))
         {
            m.currentTarget.avtSpecificIcon.visible = false;
            m.currentTarget.avtSpecificHighlight.visible = false;
            return;
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
   }
}

