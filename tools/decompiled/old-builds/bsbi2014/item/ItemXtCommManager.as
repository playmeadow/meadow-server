package item
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.UserInfo;
   import com.sbi.client.SFEvent;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.loader.FileServerEvent;
   import com.sbi.popup.SBOkPopup;
   import currency.CurrencyItem;
   import diamond.DiamondXtCommManager;
   import game.MinigameManager;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import quest.QuestManager;
   
   public class ItemXtCommManager
   {
      
      public static var guiManager:Object;
      
      public static var hasRequestedFullItemList:Boolean;
      
      public static var itemDefsHaveLoaded:Boolean;
      
      public static var functionToCallWhenDefsLoaded:Function;
      
      private static var _ilAvatarQueue:Vector.<Object>;
      
      private static var _acIlAvatarQueue:Vector.<Object>;
      
      private static var _ibQueue:Vector.<Object>;
      
      private static var _iuQueue:Vector.<Object>;
      
      private static var _slQueue:Vector.<Object>;
      
      private static var _denShopListHandler:Function;
      
      private static var _buddyCardUpdateDropDownHandler:Function;
      
      private static var _donateCallback:Function;
      
      private static var _currencyExchangeCallback:Function;
      
      private static var _irCallback:Function;
      
      private static var _recycleIlCallback:Function;
      
      private static var _hudAvtLayerAnim:LayerAnim;
      
      private static var _buyItemsIlCallback:Function;
      
      private static var _getAvatarFromAvatarManager:Function;
      
      private static var _processAcIlComboFromAvatarManager:Function;
      
      private static var _playerAvatar:Avatar;
      
      private static var _itemDefs:Object;
      
      private static var _currencyExchangeDefs:Object;
      
      private static var _ignoreAndCacheIlResponses:Boolean;
      
      private static var _ignoreIlCache:Object;
      
      private static var _bodyItemDefIds:Array = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,314,315,316,317,318,319,320,407,457,480];
      
      public function ItemXtCommManager()
      {
         super();
      }
      
      public static function init(initGetAvFunc:Function = null, initAcIlFunc:Function = null, initGuiManagerRef:Object = null, initDenShopListHandler:Function = null, initBuddyCardUpdateDropDown:Function = null) : void
      {
         _getAvatarFromAvatarManager = initGetAvFunc;
         _processAcIlComboFromAvatarManager = initAcIlFunc;
         guiManager = initGuiManagerRef;
         _denShopListHandler = initDenShopListHandler;
         _buddyCardUpdateDropDownHandler = initBuddyCardUpdateDropDown;
         _ilAvatarQueue = new Vector.<Object>();
         _acIlAvatarQueue = new Vector.<Object>();
         _ibQueue = new Vector.<Object>();
         _iuQueue = new Vector.<Object>();
         _slQueue = new Vector.<Object>();
         _ignoreIlCache = new Object();
         itemDefsHaveLoaded = false;
         var dpdh:DefPacksDefHelper = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_ITEM,itemDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_ITEM] = dpdh;
         var dpdhCurr:DefPacksDefHelper = new DefPacksDefHelper();
         dpdhCurr.init(DefPacksDefHelper.DEF_CURRENCY_EXCHANGE,currencyExchangeDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_CURRENCY_EXCHANGE] = dpdhCurr;
      }
      
      public static function destroy() : void
      {
         _ilAvatarQueue = null;
         _acIlAvatarQueue = null;
         _ibQueue = null;
         _iuQueue = null;
         _slQueue = null;
         _irCallback = null;
      }
      
      public static function set playerAvatar(setPlayerAvatar:Avatar) : void
      {
         _playerAvatar = setPlayerAvatar;
      }
      
      public static function set recycleIlCallback(callback:Function) : void
      {
         _recycleIlCallback = callback;
      }
      
      public static function requestItemBuy(buyResponseCallback:Function, shopId:int, itemId:int, itemColorIdx:int, isDiamond:int) : void
      {
         gMainFrame.server.setXtObject_Str("ib",[shopId,1,itemId,itemColorIdx,GenericListXtCommManager.getAvailListUniqueId(),isDiamond]);
         var sibr:Object = {};
         sibr[shopId] = {
            "c":buyResponseCallback,
            "i":itemId,
            "o":itemColorIdx
         };
         _ibQueue.push(sibr);
      }
      
      public static function requestItemRecycle(itemInvIdx:int, recycleResponseCallback:Function, recycleIlCallback:Function) : void
      {
         _irCallback = recycleResponseCallback;
         _recycleIlCallback = recycleIlCallback;
         gMainFrame.server.setXtObject_Str("ir",[itemInvIdx]);
      }
      
      public static function requestItemUse(useResponseCallback:Function, itemsOn:Array, itemsOff:Array) : void
      {
         var siur:Object = null;
         var params:Array = [itemsOn.length,itemsOff.length];
         params = params.concat(itemsOn.concat(itemsOff));
         if(!(params[0] == 0 && params[1] == 0))
         {
            gMainFrame.server.setXtObject_Str("iu",params,gMainFrame.server.isWorldZone);
            siur = {};
            siur[0] = {
               "c":useResponseCallback,
               "o":itemsOn,
               "f":itemsOff
            };
            _iuQueue.push(siur);
         }
      }
      
      public static function requestItemListForAvatar(gotItemListCallback:Function, listAvatar:Avatar, getFullList:Boolean, resetKeepAlive:Boolean = true) : void
      {
         var perUserAvId:int = listAvatar.perUserAvId;
         insertIntoILAvatarQueue(perUserAvId,gotItemListCallback,listAvatar);
         gMainFrame.server.setXtObject_Str("il",[listAvatar.userName,perUserAvId,getFullList ? "1" : "0"],gMainFrame.server.isWorldZone,false,resetKeepAlive);
      }
      
      public static function insertIntoILAvatarQueue(perUserAvId:int, gotItemListCallback:Function, listAvatar:Avatar) : void
      {
         if(listAvatar.userName == gMainFrame.userInfo.myUserName)
         {
            hasRequestedFullItemList = true;
         }
         var pai:Object = {};
         pai[listAvatar.userName] = {};
         pai[listAvatar.userName][perUserAvId] = {
            "c":gotItemListCallback,
            "a":listAvatar
         };
         _ilAvatarQueue.push(pai);
      }
      
      public static function removeFromILAvatarQueue(userName:String, perUserAvId:int) : void
      {
         for(var i:int = 0; i < _ilAvatarQueue.length; i++)
         {
            if(_ilAvatarQueue[i].hasOwnProperty(userName))
            {
               if(Boolean(_ilAvatarQueue[i][userName].hasOwnProperty(perUserAvId)))
               {
                  _ilAvatarQueue.splice(i,1);
                  break;
               }
            }
         }
      }
      
      public static function insertAvIntoAcIlQueue(perUserAvId:int, listAvatar:Avatar, gotItemListCallback:Function) : void
      {
         var _ilQueueLength:int = 0;
         var i:int = 0;
         var dataForUser:Object = null;
         if(Boolean(_ilAvatarQueue))
         {
            _ilQueueLength = int(_ilAvatarQueue.length);
            for(i = 0; i < _ilQueueLength; i++)
            {
               if(Boolean(_ilAvatarQueue[i]) && _ilAvatarQueue[i].hasOwnProperty(listAvatar.userName))
               {
                  if(Boolean(_ilAvatarQueue[i][listAvatar.userName].hasOwnProperty(perUserAvId)))
                  {
                     trace("WARNING: avatar is in ilAvatarQueue but shouldn\'t be yet.");
                     gotItemListCallback(perUserAvId,false);
                  }
               }
            }
         }
         else
         {
            insertIntoILAvatarQueue(perUserAvId,null,listAvatar);
            dataForUser = {};
            dataForUser[listAvatar.userName] = {
               "i":perUserAvId,
               "c":gotItemListCallback
            };
            _acIlAvatarQueue.push(dataForUser);
         }
      }
      
      public static function requestShopList(gotShopItemListCallback:Function, shopId:int) : void
      {
         var psi:Object = {};
         psi[shopId] = {"c":gotShopItemListCallback};
         _slQueue.push(psi);
         GenericListXtCommManager.requestGenericList(shopId);
      }
      
      public static function requestDonateGems(donateAmount:int, donateCallback:Function) : void
      {
         _donateCallback = donateCallback;
         gMainFrame.server.setXtObject_Str("cd",[donateAmount]);
      }
      
      public static function requestCurrencyExchange(shopId:int, itemDefId:int, exchangeCallback:Function) : void
      {
         gMainFrame.server.setXtObject_Str("ce",[shopId,itemDefId]);
         _currencyExchangeCallback = exchangeCallback;
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         switch(data[0])
         {
            case "il":
               itemListResponse(data);
               break;
            case "iu":
               itemUseResponse(data);
               break;
            case "ib":
               itemBuyResponse(data);
               break;
            case "ir":
               itemRecycleResponse(data);
               break;
            case "cu":
               currencyUpdateResponse(data);
               break;
            case "cd":
               currencyDonationResponse(data);
               break;
            case "ce":
               currencyExchangeResponse(data);
               break;
            case "ip":
               itemPrizeResponse(data);
               break;
            default:
               throw new Error("ItemManager: Received illegal cmd: " + data[0]);
         }
      }
      
      private static function getResponseItems(origData:Object, ilPerUserAvId:int, ilUserName:String) : Object
      {
         var ilAvatar:Avatar = null;
         var match:int = 0;
         var resp:Object = null;
         var ilQResponse:Object = null;
         var j:int = 0;
         var myAI:AvatarInfo = null;
         var returnObject:Object = {
            "ilCallback":null,
            "ilAvatar":null
         };
         var ilQueueLength:int = int(_ilAvatarQueue.length);
         if(ilQueueLength > 0)
         {
            for(j = 0; j < ilQueueLength; j++)
            {
               match = _ilAvatarQueue[j].hasOwnProperty(ilUserName) ? 1 : 0;
               if(match == 1)
               {
                  match = Boolean(_ilAvatarQueue[j][ilUserName].hasOwnProperty(ilPerUserAvId)) ? 1 : 0;
                  if(match == 0)
                  {
                     resp = _ilAvatarQueue[j][ilUserName][ilPerUserAvId];
                     if(Boolean(resp) && Boolean(resp["a"]))
                     {
                        match = (Boolean(resp["a"].isChattyAvt) ? resp["a"].ilperUserAvId == ilPerUserAvId : resp["a"].myChattyperUserAvId == ilPerUserAvId) ? 2 : 0;
                     }
                  }
                  if(match > 0)
                  {
                     ilQResponse = _ilAvatarQueue[j][ilUserName][int(match == 1 ? ilPerUserAvId : 0)];
                     returnObject.ilCallback = ilQResponse["c"];
                     ilAvatar = ilQResponse["a"];
                     _ilAvatarQueue.splice(j,1);
                     break;
                  }
               }
               else if(match == 0)
               {
                  resp = _ilAvatarQueue[j][0];
                  if(Boolean(resp) && Boolean(resp["a"]))
                  {
                     match = (Boolean(resp["a"].isChattyAvt) ? resp["a"].ilperUserAvId == ilPerUserAvId : resp["a"].myChattyperUserAvId == ilPerUserAvId) ? 2 : 0;
                  }
               }
            }
         }
         if(!ilAvatar && _getAvatarFromAvatarManager != null)
         {
            returnObject.ilCallback = null;
            ilAvatar = _getAvatarFromAvatarManager(ilUserName,ilPerUserAvId);
            if(!ilAvatar)
            {
               if(ilUserName == gMainFrame.userInfo.myUserName && ilPerUserAvId == gMainFrame.userInfo.myPerUserAvId && MinigameManager.inFullRoomGame)
               {
                  myAI = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,ilPerUserAvId);
                  ilAvatar = new Avatar();
                  ilAvatar.init(ilPerUserAvId,myAI.avName,myAI.type,myAI.colors,null,gMainFrame.userInfo.myUserName);
               }
               else if(_processAcIlComboFromAvatarManager != null)
               {
                  _processAcIlComboFromAvatarManager(ilUserName,ilPerUserAvId,false,origData);
               }
            }
         }
         returnObject.ilAvatar = ilAvatar;
         return returnObject;
      }
      
      private static function checkIlCallbacks(aiUserName:String) : void
      {
         if(_buyItemsIlCallback != null)
         {
            _buyItemsIlCallback();
         }
         if(_recycleIlCallback != null)
         {
            _recycleIlCallback();
         }
         guiManager.openAvEditorRecycle();
         _buddyCardUpdateDropDownHandler(aiUserName);
      }
      
      private static function itemsChangedListResponse(data:Object) : void
      {
         var ilCallback:Function = null;
         var ilAvatar:Avatar = null;
         var j:int = 0;
         var oldListFull:Array = null;
         var oldItemsLengthFull:int = 0;
         var newItem:Item = null;
         var hasFound:Boolean = false;
         var currDef:Object = null;
         var i:int = 0;
         var k:int = 0;
         var origData:Object = data.concat();
         var updateUseOnly:Boolean = data[2] == "3";
         var setInUse:Boolean = data[3] == "1";
         var ilPerUserAvId:int = int(data[4]);
         var ilUsername:String = data[5];
         var color:uint = uint(data[6]);
         var numItemsAddedDeletedOrTurnedOn:int = int(data[7]);
         var numItemsTurnedOff:int = int(data[8]);
         var startIndex:int = 9;
         var itemsDefIds:Array = new Array();
         var itemsAddedOrTurnedOn:Array = new Array();
         var itemsDeletedOrTurnedOff:Array = new Array();
         for(j = 0; j < numItemsAddedDeletedOrTurnedOn; j++)
         {
            itemsAddedOrTurnedOn.push(int(data[startIndex++]));
            itemsDefIds.push(int(data[startIndex++]));
         }
         for(j = 0; j < numItemsTurnedOff; j++)
         {
            itemsDeletedOrTurnedOff.push(int(data[startIndex++]));
         }
         var responseObject:Object = getResponseItems(origData,ilPerUserAvId,ilUsername);
         ilAvatar = responseObject.ilAvatar;
         ilCallback = responseObject.ilCallback;
         if(!ilAvatar)
         {
            return;
         }
         var ai:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(ilUsername,ilPerUserAvId);
         if(Boolean(ai) && ilAvatar.userName == gMainFrame.userInfo.myUserName)
         {
            oldListFull = ai.getFullItems(true);
            oldItemsLengthFull = int(oldListFull.length);
            if(Boolean(oldListFull))
            {
               for(j = 0; j < itemsAddedOrTurnedOn.length; j++)
               {
                  for(i = 0; i < oldItemsLengthFull; i++)
                  {
                     if(oldListFull[i].invIdx == itemsAddedOrTurnedOn[j])
                     {
                        oldListFull[i].setInUse(ai.perUserAvId,true);
                        hasFound = true;
                        break;
                     }
                  }
                  if(!updateUseOnly && !hasFound)
                  {
                     currDef = getItemDef(itemsDefIds[j]);
                     newItem = new Item();
                     newItem.init(currDef.defId,itemsAddedOrTurnedOn[j],color);
                     newItem.setInUse(ai.perUserAvId,setInUse);
                     oldListFull.unshift(newItem);
                  }
                  hasFound = false;
               }
               oldItemsLengthFull = int(oldListFull.length);
               for(j = 0; j < itemsDeletedOrTurnedOff.length; j++)
               {
                  for(i = 0; i < oldItemsLengthFull; i++)
                  {
                     if(oldListFull[i].invIdx == itemsDeletedOrTurnedOff[j])
                     {
                        oldListFull[i].setInUse(ai.perUserAvId,false);
                        if(!updateUseOnly)
                        {
                           oldListFull.splice(i,1);
                        }
                        break;
                     }
                  }
               }
               ai.fullItemList = oldListFull;
               gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(ai.perUserAvId,ai);
            }
         }
         ilAvatar.itemResponseIntegrate(ai.getItems(true));
         if(ilCallback != null)
         {
            ilCallback();
         }
         if(ilAvatar.userName == gMainFrame.userInfo.myUserName)
         {
            checkIlCallbacks(ai.userName);
         }
         var acIlLength:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && acIlLength > 0)
         {
            for(k = 0; k < acIlLength; k++)
            {
               if(_acIlAvatarQueue[k].hasOwnProperty(ilAvatar.userName))
               {
                  if(_acIlAvatarQueue[k][ilAvatar.userName].i == ilAvatar.perUserAvId)
                  {
                     _acIlAvatarQueue[k][ilAvatar.userName].c(ilAvatar.userName,ilAvatar.perUserAvId,false,origData);
                  }
                  _acIlAvatarQueue.splice(k,1);
                  break;
               }
            }
         }
      }
      
      private static function itemsInUseResponse(data:Object) : void
      {
         var ilCallback:Function = null;
         var ilAvatar:Avatar = null;
         var j:int = 0;
         var tempItemArray:Array = null;
         var i:int = 0;
         var fullLength:int = 0;
         var ai:AvatarInfo = null;
         var curItem:Object = null;
         var k:int = 0;
         var origData:Object = data.concat();
         var ilNumAvs:int = int(data[3]);
         var ilPerUserAvId:int = int(data[4]);
         var ilUsername:String = data[5];
         var ilPatternId:int = int(data[6]);
         var ilEyesId:int = int(data[7]);
         var numItems:int = int(data[8]);
         var dataArray:Array = data.splice(9,data.length);
         var responseObject:Object = getResponseItems(origData,ilPerUserAvId,ilUsername);
         ilAvatar = responseObject.ilAvatar;
         ilCallback = responseObject.ilCallback;
         if(!ilAvatar)
         {
            return;
         }
         var ui:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(ilAvatar.userName);
         if(ilAvatar.userName == gMainFrame.userInfo.myUserName)
         {
            tempItemArray = ui.fullItemList;
            fullLength = int(tempItemArray.length);
            for(i = 0; i < fullLength; i++)
            {
               curItem = tempItemArray[i];
               if(curItem.defId == 1 || curItem.defId == ilPatternId || curItem.defId == ilEyesId)
               {
                  curItem.setInUse(ilAvatar.perUserAvId,true);
               }
               else
               {
                  for(j = 1; j < numItems; j++)
                  {
                     if(curItem.invIdx == int(dataArray[j]))
                     {
                        curItem.setInUse(ilAvatar.perUserAvId,true);
                     }
                     j += 2;
                  }
               }
            }
            ui.fullItemList = tempItemArray;
            gMainFrame.userInfo.setUserInfoByUserName(ilAvatar.userName,ui);
         }
         else
         {
            tempItemArray = generateClothingList(numItems,dataArray,ilAvatar.perUserAvId,ilPatternId,ilEyesId,false);
            ui.fullItemList = tempItemArray;
            gMainFrame.userInfo.setUserInfoByUserName(ilAvatar.userName,ui);
         }
         ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(ilUsername,ilPerUserAvId);
         if(ai == null)
         {
            ai = new AvatarInfo();
            if(ilPerUserAvId == ilAvatar.perUserAvId)
            {
               ai.init(ilPerUserAvId,ilAvatar.avName,ilAvatar.userName,ilAvatar.avTypeId,ilAvatar.colors);
            }
            else
            {
               ai.init(ilPerUserAvId);
            }
         }
         gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(ilPerUserAvId,ai);
         ilAvatar.itemResponseIntegrate(ui.getPartialItemList(ai.type,true));
         if(ilCallback != null)
         {
            ilCallback();
         }
         if(ilAvatar.userName == gMainFrame.userInfo.myUserName)
         {
            checkIlCallbacks(ai.userName);
         }
         var acIlLength:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && acIlLength > 0)
         {
            for(k = 0; k < acIlLength; k++)
            {
               if(_acIlAvatarQueue[k].hasOwnProperty(ilAvatar.userName))
               {
                  if(_acIlAvatarQueue[k][ilAvatar.userName].i == ilAvatar.perUserAvId)
                  {
                     _acIlAvatarQueue[k][ilAvatar.userName].c(ilAvatar.userName,ilAvatar.perUserAvId,false,origData);
                  }
                  _acIlAvatarQueue.splice(k,1);
                  break;
               }
            }
         }
      }
      
      public static function handleIlWhenBeforeACAfterReceivingAC(data:Object) : void
      {
         itemListResponse(data);
      }
      
      private static function itemListResponse(data:Object) : void
      {
         var ilCallback:Function = null;
         var ilAvatar:Avatar = null;
         var ai:AvatarInfo = null;
         var k:int = 0;
         var origData:Object = data.concat();
         var isFullList:Boolean = data[2] == "0";
         if(!isFullList)
         {
            if(data[2] == "1")
            {
               itemsInUseResponse(data);
            }
            else
            {
               itemsChangedListResponse(data);
            }
            return;
         }
         var ilNumAvs:int = int(data[3]);
         var ilPerUserAvId:int = int(data[4]);
         var ilUsername:String = data[5];
         var ilPatternId:int = int(data[6]);
         var ilEyesId:int = int(data[7]);
         var numItems:int = int(data[8]);
         var dataArray:Array = data.splice(9,data.length);
         var ilQueueLength:int = int(_ilAvatarQueue.length);
         var responseObject:Object = getResponseItems(origData,ilPerUserAvId,ilUsername);
         ilAvatar = responseObject.ilAvatar;
         ilCallback = responseObject.ilCallback;
         if(!ilAvatar)
         {
            return;
         }
         var tempItemArray:Array = generateClothingList(numItems,dataArray,ilAvatar.perUserAvId,ilPatternId,ilEyesId,ilAvatar.userName == gMainFrame.userInfo.myUserName);
         var itemClones:Array = [];
         var fullLength:int = int(tempItemArray.length);
         for(var i:int = 0; i < fullLength; i++)
         {
            itemClones[i] = tempItemArray[i].clone();
         }
         tempItemArray = null;
         if(ilAvatar.userName != gMainFrame.userInfo.myUserName)
         {
            return;
         }
         var ui:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(ilAvatar.userName);
         ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(ilUsername,ilPerUserAvId);
         ui.fullItemList = itemClones;
         gMainFrame.userInfo.setUserInfoByUserName(ilAvatar.userName,ui);
         ilAvatar.itemResponseIntegrate(ui.getPartialItemList(ai.type,true));
         if(ilCallback != null)
         {
            ilCallback();
         }
         checkIlCallbacks(ai.userName);
         var acIlLength:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && acIlLength > 0)
         {
            for(k = 0; k < acIlLength; k++)
            {
               if(_acIlAvatarQueue[k].hasOwnProperty(ilAvatar.userName))
               {
                  if(_acIlAvatarQueue[k][ilAvatar.userName].i == ilAvatar.perUserAvId)
                  {
                     _acIlAvatarQueue[k][ilAvatar.userName].c(ilAvatar.userName,ilAvatar.perUserAvId,false,origData);
                  }
                  _acIlAvatarQueue.splice(k,1);
                  break;
               }
            }
         }
         itemClones = null;
      }
      
      private static function itemUseResponse(data:Object) : void
      {
         var allowed:Boolean = false;
         var iuCallback:Function = null;
         var iuQResponse:Object = null;
         if(_iuQueue.length > 0)
         {
            iuQResponse = _iuQueue.shift()[0];
            iuCallback = iuQResponse["c"];
         }
         else
         {
            iuCallback = null;
         }
         allowed = false;
         if(data[2] == "1")
         {
            allowed = true;
         }
         if(iuCallback != null)
         {
            iuCallback(iuQResponse["o"],iuQResponse["f"],allowed);
         }
      }
      
      private static function itemBuyResponse(data:Object) : void
      {
         var ibCallback:Function = null;
         var currencyCount:int = 0;
         var ibQResponse:Object = null;
         var shopId:int = int(data[3]);
         var status:int = int(data[2]);
         var currencyType:int = int(data[5]);
         if(data[4] == "")
         {
            switch(currencyType)
            {
               case Item.GEM_CURRENCY:
                  currencyCount = int(gMainFrame.clientInfo.gemCount);
                  break;
               case Item.TICKET_CURRENCY:
                  currencyCount = int(gMainFrame.clientInfo.ticketCount);
                  break;
               case Item.ORB_CURRENCY:
                  currencyCount = int(gMainFrame.clientInfo.orbCount);
                  break;
               case Item.DIAMOND_CURRENCY:
                  currencyCount = int(gMainFrame.clientInfo.diamondCount);
                  break;
               default:
                  throw new Error("ItemManager: Received unknown currencyType: " + currencyType);
            }
         }
         else
         {
            currencyCount = int(data[4]);
         }
         if(status == 1 && currencyCount >= 0)
         {
            switch(currencyType)
            {
               case Item.GEM_CURRENCY:
                  gMainFrame.clientInfo.gemCount = currencyCount;
                  break;
               case Item.TICKET_CURRENCY:
                  gMainFrame.clientInfo.ticketCount = currencyCount;
                  break;
               case Item.ORB_CURRENCY:
                  gMainFrame.clientInfo.orbCount = currencyCount;
                  break;
               case Item.DIAMOND_CURRENCY:
                  gMainFrame.clientInfo.diamondCount = currencyCount;
                  break;
               default:
                  throw new Error("ItemManager: Received unknown currencyType: " + currencyType);
            }
         }
         if(_ibQueue.length > 0 && _ibQueue[0].hasOwnProperty(shopId))
         {
            ibQResponse = _ibQueue.shift()[shopId];
            ibCallback = ibQResponse["c"];
         }
         else
         {
            ibCallback = null;
         }
         if(ibCallback != null)
         {
            ibCallback(status,currencyCount);
         }
      }
      
      private static function itemRecycleResponse(data:Object) : void
      {
         var status:Boolean = data[2] == "1";
         var oldCount:int = int(gMainFrame.clientInfo.gemCount);
         var gemCount:int = data[3] == "" ? oldCount : int(data[3]);
         if(status && gemCount >= 0)
         {
            gMainFrame.clientInfo.gemCount = gemCount;
            if(oldCount < gemCount)
            {
               guiManager.startGemsFlash();
            }
         }
         if(_irCallback != null)
         {
            _irCallback(status);
         }
      }
      
      private static function itemPrizeResponse(data:Object) : void
      {
         guiManager.onItemPrize(data);
      }
      
      private static function itemDefResponse(dfdh:DefPacksDefHelper) : void
      {
         var itemDef:Object = null;
         var data:Object = null;
         var colors:Array = null;
         var i:int = 0;
         _itemDefs = new Object();
         for each(data in dfdh.def)
         {
            itemDef = {
               "defId":int(data.id),
               "accId":int(data.layerDefId),
               "layerId":int(data.layerId),
               "type":int(data.type),
               "cost":int(data.value),
               "name":"",
               "titleStrId":int(data.titleStrId),
               "isGiftable":data.isGiftable == "1",
               "isMembersOnly":data.membersOnly == "1",
               "isNew":data.itemStatus == "1",
               "isOnSale":data.itemStatus == "2",
               "enviroType":int(data.enviroType),
               "avatarUseFlag":int(data.avatarUseFlags),
               "itemStatus":int(data.itemStatus),
               "recycleValue":int(data.recycleValue),
               "currencyType":int(data.currencyType),
               "defense":int(data.defense),
               "attack":int(data.attack),
               "attackMediaRefId":int(data.attackMediaRefId),
               "combatType":int(data.combatType),
               "modifierType":int(data.modifierType),
               "modifierValue":int(data.modifierValue),
               "criticalHit":int(data.criticalHit)
            };
            colors = data.colors.split(",");
            for(i = 0; i < colors.length; i++)
            {
               colors[i] = uint(colors[i]);
            }
            itemDef.colors = colors;
            _itemDefs[itemDef.defId] = itemDef;
            _itemDefs[int(data.id)].name = LocalizationManager.translateIdOnly(data.titleStrId);
         }
         itemDefsHaveLoaded = true;
         if(functionToCallWhenDefsLoaded != null)
         {
            functionToCallWhenDefsLoaded();
            functionToCallWhenDefsLoaded = null;
         }
      }
      
      public static function relocalizeItems() : void
      {
         var currItem:Object = null;
         for each(currItem in _itemDefs)
         {
            currItem.name = LocalizationManager.translateIdOnly(currItem.titleStrId);
         }
      }
      
      private static function currencyExchangeDefResponse(dfdh:DefPacksDefHelper) : void
      {
         var def:Object = null;
         var data:Object = null;
         _currencyExchangeDefs = new Object();
         for each(data in dfdh.def)
         {
            def = {
               "defId":data.id,
               "mediaId":data.mediaRefId,
               "result":data.result,
               "resultType":data.resultType,
               "value":data.cost,
               "currencyType":data.costType,
               "name":"",
               "titleStrId":int(data.titleStrId)
            };
            _currencyExchangeDefs[def.defId] = def;
            _currencyExchangeDefs[int(data.id)].name = LocalizationManager.translateIdOnly(data.titleStrId);
         }
      }
      
      public static function relocalizeCurrencyExchanges() : void
      {
         var c:Object = null;
         for each(c in _currencyExchangeDefs)
         {
            c.name = LocalizationManager.translateIdOnly(c.titleStrId);
         }
      }
      
      private static function currencyUpdateResponse(data:Object) : void
      {
         var currencyTypeLoc:int = 0;
         var currencyChange:int = 0;
         var ggp:SBOkPopup = null;
         var currencyType:int = int(data[2]);
         var newCurrency:int = int(data[3]);
         var wasGifted:Boolean = data[4] == 3 || data[4] == 4;
         var oldCurrency:int = -1;
         if(currencyType == Item.GEM_CURRENCY)
         {
            oldCurrency = int(gMainFrame.clientInfo.gemCount);
            gMainFrame.clientInfo.gemCount = newCurrency;
            currencyChange = newCurrency - oldCurrency;
            if(currencyChange != 1)
            {
               currencyTypeLoc = 14900;
            }
            else
            {
               currencyTypeLoc = 14901;
            }
         }
         else if(currencyType == Item.TICKET_CURRENCY)
         {
            oldCurrency = int(gMainFrame.clientInfo.ticketCount);
            gMainFrame.clientInfo.ticketCount = newCurrency;
            currencyChange = newCurrency - oldCurrency;
            if(currencyChange != 1)
            {
               currencyTypeLoc = 14902;
            }
            else
            {
               currencyTypeLoc = 14903;
            }
         }
         else if(currencyType == Item.ORB_CURRENCY)
         {
            oldCurrency = int(gMainFrame.clientInfo.orbCount);
            gMainFrame.clientInfo.orbCount = newCurrency;
            currencyChange = newCurrency - oldCurrency;
            if(currencyChange != 1)
            {
               currencyTypeLoc = 14904;
            }
            else
            {
               currencyTypeLoc = 14905;
            }
         }
         else
         {
            if(currencyType != Item.DIAMOND_CURRENCY)
            {
               throw new Error("ItemManager: Received unknown currencyType: " + currencyType);
            }
            oldCurrency = int(gMainFrame.clientInfo.diamondCount);
            gMainFrame.clientInfo.diamondCount = newCurrency;
            currencyChange = newCurrency - oldCurrency;
            if(currencyChange != 1)
            {
               currencyTypeLoc = 14906;
            }
            else
            {
               currencyTypeLoc = 14907;
            }
         }
         if(oldCurrency < newCurrency)
         {
            QuestManager.currencyUpdate(newCurrency - oldCurrency);
            if(guiManager != null)
            {
               if(guiManager.guiLayer != null)
               {
                  if(wasGifted)
                  {
                     ggp = new SBOkPopup(guiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(currencyTypeLoc,Utility.convertNumberToString(currencyChange)));
                  }
                  else if(data[4] == 15)
                  {
                     GuiManager.openJumpPopup(false,null,null,currencyChange);
                  }
                  else if(data[4] == 16)
                  {
                     guiManager.setupGemGiftPopup(currencyChange);
                  }
               }
               if(!gMainFrame.isInMinigame())
               {
                  guiManager.startGemsFlash();
               }
            }
         }
      }
      
      private static function currencyDonationResponse(data:Object) : void
      {
         if(_donateCallback != null)
         {
            _donateCallback(data[2]) == "1";
            _donateCallback = null;
         }
      }
      
      private static function currencyExchangeResponse(data:Object) : void
      {
         if(_currencyExchangeCallback != null)
         {
            _currencyExchangeCallback(data[2] == "1",data[3]);
            _currencyExchangeCallback = null;
         }
      }
      
      public static function shopListResponse(data:Object, glDefType:int) : void
      {
         var i:int = 0;
         var numItems:int = 0;
         var shopItemArray:Array = null;
         var shopListCallback:Function = null;
         var slQResponse:Object = null;
         var shopItemColorsArray:Array = null;
         var colorsArray:Array = null;
         var j:int = 6;
         var glId:int = int(data[2]);
         var shopName:String = data[4];
         for(i = 0; i < _slQueue.length; i++)
         {
            if(_slQueue[i].hasOwnProperty(glId))
            {
               slQResponse = _slQueue.shift()[glId];
               shopListCallback = slQResponse["c"];
               break;
            }
         }
         if(glDefType == DefPacksDefHelper.DEF_ITEM)
         {
            numItems = int(data[j++]);
            shopItemColorsArray = [];
            shopItemArray = generateClothingShopList(numItems,data.splice(j++,data.length),shopItemColorsArray);
            if(shopListCallback != null)
            {
               shopListCallback(shopItemArray,shopName,shopItemColorsArray);
            }
         }
         else if(glDefType == DefPacksDefHelper.DEF_DEN_ITEM || glDefType == DefPacksDefHelper.DEF_DEN_ROOM)
         {
            if(_denShopListHandler != null)
            {
               _denShopListHandler(data,glId,glDefType,shopListCallback);
            }
         }
         else if(glDefType == DefPacksDefHelper.DEF_CURRENCY_EXCHANGE)
         {
            numItems = int(data[j++]);
            shopItemArray = generateCurrencyExchangeShopList(numItems,data.splice(j++,data.length));
            if(shopListCallback != null)
            {
               shopListCallback(shopItemArray,shopName);
            }
         }
         else
         {
            if(glDefType != DefPacksDefHelper.DEF_DIAMOND)
            {
               throw new Error("Unimplemented shopList response type: " + glDefType);
            }
            numItems = int(data[j++]);
            colorsArray = [];
            shopItemArray = DiamondXtCommManager.generateDiamondShopList(numItems,data.splice(j++,data.length),colorsArray);
            if(shopListCallback != null)
            {
               shopListCallback(shopItemArray,shopName,colorsArray);
            }
         }
      }
      
      public static function setItemBuyIlCallback(setBuyItemsIlCallback:Function) : void
      {
         _buyItemsIlCallback = setBuyItemsIlCallback;
      }
      
      public static function setHudAvtItemListLayerAnim(layerAnim:LayerAnim) : void
      {
         _hudAvtLayerAnim = layerAnim;
      }
      
      public static function generateBodyModList(perUserAvId:int, patternDefId:int = -1, eyesDefId:int = -1, isMyList:Boolean = true) : Array
      {
         var itemDefId:int = 0;
         var itemDef:Object = null;
         var tempItem:Item = null;
         var bodyModItems:Array = [];
         for(var i:int = 0; i < _bodyItemDefIds.length; i++)
         {
            itemDefId = int(_bodyItemDefIds[i]);
            itemDef = _itemDefs[itemDefId];
            if(itemDef == null)
            {
               throw new Error("ItemManager: unknown body itemDef=" + itemDefId);
            }
            tempItem = getBodyModFromDefId(itemDefId,perUserAvId,itemDefId == 1 || itemDefId == patternDefId || itemDefId == eyesDefId,isMyList);
            bodyModItems.push(tempItem);
         }
         return bodyModItems;
      }
      
      public static function getBodyModFromDefId(itemDefId:int, perUserAvId:int, inUse:Boolean = false, isMyList:Boolean = true) : Item
      {
         var tempItem:Item = new Item();
         if(isMyList)
         {
            tempItem.init(itemDefId,itemDefId * -1);
            tempItem.setInUse(perUserAvId,inUse);
         }
         else if(inUse)
         {
            tempItem.init(itemDefId,itemDefId * -1,0,-1,-1);
         }
         else
         {
            tempItem.init(itemDefId,itemDefId * -1,0,0,0);
         }
         return tempItem;
      }
      
      public static function generateClothingList(numItems:int, itemArray:Array, perUserAvId:int, patternInUseId:int, eyesInUseId:int, isMyList:Boolean) : Array
      {
         var itemListIdx:int = 0;
         var itemDefId:int = 0;
         var itemDef:Object = null;
         var tempItem:Item = null;
         var offset:int = 0;
         var itemList:Array = [];
         var bodMods:Array = generateBodyModList(perUserAvId,patternInUseId,eyesInUseId,isMyList);
         for(itemListIdx = 0; itemListIdx < numItems; itemListIdx++)
         {
            itemDefId = int(itemArray[offset++]);
            itemDef = _itemDefs[itemDefId];
            if(itemDef == null)
            {
               throw new Error("ItemXtCommManager: unknown clothing itemDef=" + itemDefId);
            }
            tempItem = new Item();
            if(isMyList)
            {
               tempItem.init(itemDefId,int(itemArray[offset++]),uint(itemArray[offset++]),int(itemArray[offset++]),int(itemArray[offset++]));
            }
            else
            {
               tempItem.init(itemDefId,int(itemArray[offset++]),uint(itemArray[offset++]),-1,-1);
               tempItem.setInUse(perUserAvId,true);
            }
            itemList[itemListIdx] = tempItem;
         }
         itemList = bodMods.concat(itemList);
         if(isMyList)
         {
            itemList.sortOn("invIdx",Array.NUMERIC | Array.DESCENDING);
         }
         return itemList;
      }
      
      private static function generateClothingShopList(numItems:int, itemArray:Array, itemColorsArray:Array) : Array
      {
         var currDef:Object = null;
         var newItem:Item = null;
         var pAvType:int = _playerAvatar.avTypeId;
         var items:Array = [];
         for(var i:int = 0; i < numItems; i++)
         {
            newItem = new Item();
            currDef = ItemXtCommManager.getItemDef(int(itemArray[i]));
            itemColorsArray[i] = currDef.colors.concat();
            newItem.init(currDef.defId,i,currDef.colors[0],0,0,true);
            items.push(newItem);
         }
         return items;
      }
      
      private static function generateCurrencyExchangeShopList(numItems:int, data:Array) : Array
      {
         var defId:int = 0;
         var def:Object = null;
         var currencyItem:CurrencyItem = null;
         var items:Array = [];
         var j:int = 0;
         for(var i:int = 0; i < numItems; i++)
         {
            defId = int(data[j++]);
            def = getCurrencyExchangeDef(defId);
            if(!def)
            {
               i--;
            }
            else
            {
               currencyItem = new CurrencyItem();
               currencyItem.init(defId,def.mediaId,def.result,def.resultType,def.value,def.currencyType,def.name);
               items[i] = currencyItem;
            }
         }
         return items;
      }
      
      public static function getItemDef(defId:int) : Object
      {
         return _itemDefs[defId];
      }
      
      public static function getCurrencyExchangeDef(defId:int) : Object
      {
         return _currencyExchangeDefs[defId];
      }
      
      public static function canUseItem(defId:int, avTypeId:int) : Boolean
      {
         return (_itemDefs[defId].avatarUseFlag & 1 << avTypeId - 1) != 0;
      }
      
      public static function avTypeThatCanUseItem(defId:int) : Array
      {
         var count:int = 0;
         var skipped:int = 0;
         var useFlag:int = int(_itemDefs[defId].avatarUseFlag);
         var usableAvTypes:Array = [];
         while(useFlag > 0)
         {
            if((useFlag & 1) == 1)
            {
               count += 1;
               usableAvTypes.push(count + skipped);
            }
            else
            {
               skipped++;
            }
            useFlag >>= 1;
         }
         return usableAvTypes;
      }
   }
}

