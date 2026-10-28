package den
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.FileServerEvent;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.BuddyCard;
   import gui.DarkenManager;
   import gui.DenSwitch;
   import gui.GuiManager;
   import item.Item;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.PetBase;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class DenXtCommManager
   {
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _denChangePending:Boolean;
      
      private static var _pendingDenChangeItems:Array;
      
      private static var _itemBuyCallback:Function;
      
      private static var _denEditorDIResponseCallback:Function;
      
      private static var _denItemsCallback:Function;
      
      private static var _denListCallback:Function;
      
      private static var _denRecycleCallback:Function;
      
      private static var _recycleDiCallback:Function;
      
      private static var _denRoomBuyCallback:Function;
      
      private static var _denHighestCallback:Function;
      
      private static var _denPrivateCallback:Function;
      
      private static var _denChangeCallback:Function;
      
      private static var _isBuyingDenRoom:Boolean;
      
      private static var _cachedDlResponse:Object;
      
      private static var _denItemDefs:Object;
      
      public function DenXtCommManager()
      {
         super();
      }
      
      public static function init(initDenListCallback:Function) : void
      {
         _roomMgr = RoomManagerWorld.instance;
         _denListCallback = initDenListCallback;
         _denChangePending = false;
         _pendingDenChangeItems = null;
         var defPackHelper:DefPacksDefHelper = new DefPacksDefHelper();
         defPackHelper.init(DefPacksDefHelper.DEF_DEN_ITEM,denItemDefsResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ITEM] = defPackHelper;
         XtReplyDemuxer.addModule(handleXtReply,"d");
      }
      
      public static function destroy() : void
      {
         _denEditorDIResponseCallback = null;
         _denItemsCallback = null;
         _denRecycleCallback = null;
         _recycleDiCallback = null;
      }
      
      public static function requestDenStateChange(itemsChanged:Array) : void
      {
         var temp:Array = [];
         var j:int = 0;
         temp[j++] = itemsChanged.length;
         for(var i:int = 0; i < itemsChanged.length; i++)
         {
            temp[j++] = itemsChanged[i].r;
            temp[j++] = itemsChanged[i].i;
            temp[j++] = itemsChanged[i].d;
            temp[j++] = itemsChanged[i].x;
            temp[j++] = itemsChanged[i].y;
            temp[j++] = Boolean(itemsChanged[i].f) ? itemsChanged[i].f : 0;
            temp[j++] = itemsChanged[i].userNameLink == "" ? "off" : itemsChanged[i].userNameLink;
         }
         gMainFrame.server.setXtObject_Str("ds",temp);
      }
      
      public static function requestDenItems(denItemsCallback:Function = null) : void
      {
         _denItemsCallback = denItemsCallback;
         gMainFrame.server.setXtObject_Str("di",[]);
      }
      
      public static function requestDenRoomList() : void
      {
         gMainFrame.server.setXtObject_Str("dl",[]);
      }
      
      public static function requestBuy(isDenItem:Boolean, shopId:int, itemId:int, itemBuyCallback:Function, denItemIdx:int = 0, denRoomPurchaseCallback:Function = null, denItemVersion:int = 0, isDiamond:int = 0) : void
      {
         _itemBuyCallback = itemBuyCallback;
         if(isDenItem)
         {
            gMainFrame.server.setXtObject_Str("db",["0",shopId,itemId,denItemVersion,GenericListXtCommManager.getAvailListUniqueId(),isDiamond]);
         }
         else
         {
            _isBuyingDenRoom = true;
            gMainFrame.server.setXtObject_Str("db",["-1",shopId,itemId,denItemIdx,GenericListXtCommManager.getAvailListUniqueId(),isDiamond]);
            _denRoomBuyCallback = denRoomPurchaseCallback;
         }
      }
      
      public static function requestRecycle(isDenItem:Boolean, itemInvIdx:int, recycleResponseCallback:Function, recycleDiCallback:Function = null) : void
      {
         _denRecycleCallback = recycleResponseCallback;
         _recycleDiCallback = recycleDiCallback;
         gMainFrame.server.setXtObject_Str("dr",[isDenItem ? "0" : "-1",itemInvIdx]);
      }
      
      public static function requestDenChange(denIdx:int, dcCallback:Function) : void
      {
         _denChangeCallback = dcCallback;
         gMainFrame.server.setXtObject_Str("dc",[DenSwitch.denList[denIdx].invId]);
      }
      
      public static function requestDenJoinFull(denRoomName:String, portalInvId:int = -1, forceInvisMode:Boolean = true, confirmLanguageChange:Boolean = true) : void
      {
         var confirmLanguageChangeString:String = null;
         var forceInvisNow:Boolean = false;
         if(!RoomXtCommManager.isSwitching)
         {
            if(RoomXtCommManager.loadingNewRoom)
            {
               DebugUtility.debugTrace("INGORING requestDenJoinFull request because user is already joining a new room!");
               return;
            }
            DarkenManager.showLoadingSpiral(true);
            if(Boolean(gMainFrame.server.getCurrentRoom()))
            {
               if(denRoomName == gMainFrame.server.getCurrentRoomName())
               {
                  trace("WARNING: User is already in this den!");
                  return;
               }
            }
            AvatarManager.joiningNewRoom = true;
            if(RoomManagerWorld.instance.haveHadLastGoodRoomName())
            {
               SBTracker.trackPageview("/game/play/loading/changeRooms");
            }
            RoomXtCommManager.denJoinRequested(denRoomName);
            _denChangePending = true;
            confirmLanguageChangeString = confirmLanguageChange ? "1" : "0";
            forceInvisNow = forceInvisMode || _roomMgr.forceInvisMode;
            if(!forceInvisNow)
            {
               gMainFrame.server.setXtObject_Str("dj",[denRoomName,confirmLanguageChangeString,"0",portalInvId]);
            }
            else
            {
               gMainFrame.server.setXtObject_Str("dj",[denRoomName,confirmLanguageChangeString,"1",portalInvId]);
               _roomMgr.forceInvisMode = true;
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      public static function requestDenHighest() : void
      {
         gMainFrame.server.setXtObject_Str("dh",[]);
      }
      
      public static function requestSetDenPrivacy(isDenPrivate:Boolean, kickNonBuddies:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("dp",["0",isDenPrivate ? "1" : "0",kickNonBuddies ? "1" : "0"]);
      }
      
      public static function requestUserDenPrivacy(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("dp",["1",userName]);
      }
      
      public static function requestEmptyDen() : void
      {
         gMainFrame.server.setXtObject_Str("de",[]);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         switch(data[0])
         {
            case "ds":
               denStateResponse(data);
               break;
            case "dp":
               denPrivacyResponse(data);
               break;
            case "dpk":
               denPrivacyKickResponse();
               break;
            case "di":
               denItemsResponse(data);
               break;
            case "dc":
               denChangeResponse(data);
               break;
            case "db":
               denBuyResponse(data);
               break;
            case "dr":
               denRecycleResponse(data);
               break;
            case "dh":
               denHighestResponse(data);
               break;
            case "dl":
               denListResponse(data);
               break;
            case "drc":
               denRoomCount(data);
               break;
            case "de":
               denEmptyResponse(data);
               break;
            default:
               throw new Error("Did not expect ext cmd=" + data[0]);
         }
      }
      
      public static function denItemsResponse(data:Object) : void
      {
         var invIdx:int = 0;
         var itemDefId:int = 0;
         var categoryId:int = 0;
         var cost:int = 0;
         var layerId:int = 0;
         var sortId:int = 0;
         var version:int = 0;
         var isMemberOnly:Boolean = false;
         var strName:String = null;
         var enviroType:int = 0;
         var recycleValue:int = 0;
         var currencyType:int = 0;
         var i:int = 0;
         var newItem:DenItem = null;
         var pi:Object = null;
         var j:int = 2;
         DenSwitch.activeDenIdx = int(data[j++]);
         var numDenItems:int = int(data[j++]);
         var numPets:int = int(data[j++]);
         var denItems:Array = new Array(numDenItems);
         var mgDefIds:Array = [];
         var enableDefaultAudio:Boolean = true;
         for(i = 0; i < numDenItems; i++)
         {
            newItem = new DenItem();
            invIdx = int(data[j++]);
            itemDefId = int(data[j++]);
            categoryId = int(data[j++]);
            version = int(data[j++]);
            if(getDenItemDef(itemDefId).sortCat == DenItem.SORT_AUDIO && categoryId > 0)
            {
               enableDefaultAudio = false;
            }
            newItem.init(itemDefId,invIdx,categoryId,version);
            denItems[i] = newItem;
            if(newItem.minigameDefId > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(newItem.minigameDefId))
            {
               mgDefIds.push(newItem.minigameDefId);
            }
         }
         denItems.sortOn("invIdx",Array.NUMERIC | Array.DESCENDING);
         newItem = new DenItem();
         newItem.init(DenItem.DEF_AUDIO_DEF_ID,DenItem.DEF_AUDIO_INVIDX,enableDefaultAudio ? 7 : 0);
         denItems.unshift(newItem);
         var petList:Array = PetManager.myPetList;
         var petItems:Array = new Array(petList.length);
         for(i = 0; i < petList.length; i++)
         {
            pi = petList[i];
            newItem = new DenItem();
            newItem.init(pi.defId,pi.idx,0,pi.lBits,DenItem.REF_ID_PET_ITEM,pi.uBits,pi.eBits);
            petItems[i] = newItem;
         }
         petItems.sortOn("invIdx",Array.NUMERIC | Array.DESCENDING);
         var m:int = 0;
         while(m < numPets)
         {
            invIdx = int(data[j + m]);
            for(i = 0; i < petItems.length; i++)
            {
               if(petItems[i].invIdx == invIdx)
               {
                  petItems[i].categoryId = DenItem.PLACE_CAT_FLOOR;
                  break;
               }
            }
            m++;
         }
         if(mgDefIds.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(mgDefIds);
         }
         if(AvatarManager.playerAvatar != null)
         {
            AvatarManager.playerAvatar.inventoryDenPartial.itemArray = gMainFrame.userInfo.playerUserInfo.denItemsPartial = enviroItems(denItems);
            AvatarManager.playerAvatar.inventoryDenFull.itemArray = denItems;
         }
         gMainFrame.userInfo.playerUserInfo.denItemsFull = denItems;
         gMainFrame.userInfo.myPetsInDen = petItems;
         if(_denItemsCallback != null)
         {
            _denItemsCallback();
         }
         if(_denEditorDIResponseCallback != null)
         {
            _denEditorDIResponseCallback();
         }
         if(_recycleDiCallback != null)
         {
            _recycleDiCallback();
         }
      }
      
      public static function addPetToDen(pi:Object) : void
      {
         var newItem:DenItem = new DenItem();
         newItem.init(pi.defId,pi.idx,0,pi.lBits,DenItem.REF_ID_PET_ITEM,pi.uBits,pi.eBits);
         if(Boolean(gMainFrame.userInfo.myPetsInDen))
         {
            gMainFrame.userInfo.myPetsInDen.unshift(newItem);
         }
         else
         {
            gMainFrame.userInfo.myPetsInDen = [newItem];
         }
         GuiManager.onPetsChanged();
      }
      
      public static function removePetFromDen(invIdx:int) : void
      {
         var petsInDen:Array = gMainFrame.userInfo.myPetsInDen;
         if(!petsInDen)
         {
            return;
         }
         for(var i:int = 0; i < petsInDen.length; i++)
         {
            if(petsInDen[i].invIdx == invIdx)
            {
               petsInDen.splice(i,1);
               break;
            }
         }
         GuiManager.onPetsChanged();
      }
      
      public static function reloadPetInDen(invIdx:int, lBits:int, uBits:int, eBits:int) : void
      {
         var petInDen:DenItem = null;
         var petsInDen:Array = gMainFrame.userInfo.myPetsInDen;
         if(!petsInDen)
         {
            return;
         }
         for(var i:int = 0; i < petsInDen.length; i++)
         {
            petInDen = petsInDen[i];
            if(petInDen.invIdx == invIdx)
            {
               petInDen.version = lBits;
               petInDen.version2 = uBits;
               petInDen.version3 = eBits;
               break;
            }
         }
         GuiManager.onPetsChanged();
      }
      
      public static function set denEditorDIResponseCallback(value:Function) : void
      {
         _denEditorDIResponseCallback = value;
      }
      
      private static function denBuyResponse(data:Object) : void
      {
         var currencyCount:int = 0;
         var status:int = int(data[2]);
         var currencyType:int = int(data[5]);
         var shopType:int = int(data[4]);
         if(data[3] == "")
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
                  throw new Error("DenXtCommManager: Received unknown currencyType: " + currencyType);
            }
         }
         else
         {
            currencyCount = int(data[3]);
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
         if(_itemBuyCallback != null)
         {
            _itemBuyCallback(status,currencyCount);
         }
      }
      
      private static function denRecycleResponse(data:Object) : void
      {
         var status:Boolean = data[2] == "1";
         var oldCount:int = int(gMainFrame.clientInfo.gemCount);
         var gemCount:int = data[3] == "" ? oldCount : int(data[3]);
         if(status && gemCount >= 0)
         {
            gMainFrame.clientInfo.gemCount = gemCount;
            if(oldCount < gemCount)
            {
               GuiManager.startGemsFlash();
            }
         }
         if(_denRecycleCallback != null)
         {
            _denRecycleCallback(status);
         }
      }
      
      private static function denHighestResponse(data:Object) : void
      {
         var j:int = 2;
         var numNames:int = int(data[j++]);
         var names:Array = new Array(numNames);
         for(var i:int = 0; i < numNames; i++)
         {
            names[i] = data[j++];
         }
         if(_denHighestCallback != null)
         {
            _denHighestCallback(names);
         }
      }
      
      private static function denPrivateResponse(data:Object) : void
      {
         if(_denPrivateCallback != null)
         {
            _denPrivateCallback(data[3],data[4] == "1");
         }
      }
      
      private static function denRoomCount(data:Object) : void
      {
         var j:int = 2;
         var denRoomCount:int = int(data[j++]);
         var entering:Boolean = data[j++] == "1";
         var userNameEnteringLeaving:String = data[j++];
         GuiManager.updateDenRoomCount(denRoomCount,entering,userNameEnteringLeaving);
      }
      
      private static function denListResponse(data:Object) : void
      {
         var j:int = 0;
         var numRooms:int = 0;
         var denRoomList:Array = null;
         var i:int = 0;
         var dri:DenRoomItem = null;
         var idx:int = 0;
         var defId:int = 0;
         var denRoomDef:Object = null;
         if(Boolean(gMainFrame.userInfo.denRoomDefs))
         {
            j = 2;
            numRooms = int(data[j++]);
            denRoomList = new Array(numRooms);
            for(i = 0; i < numRooms; i++)
            {
               dri = new DenRoomItem();
               idx = int(data[j++]);
               defId = int(data[j++]);
               denRoomDef = gMainFrame.userInfo.getDenRoomDefByDefId(defId);
               if(Boolean(denRoomDef))
               {
                  dri.init(idx,defId,denRoomDef.mediaId,denRoomDef.value,denRoomDef.name,denRoomDef.enviroType,denRoomDef.membersOnly);
                  denRoomList[idx] = dri;
               }
            }
            if(_denListCallback != null)
            {
               _denListCallback(denRoomList);
            }
            if(_isBuyingDenRoom)
            {
               if(_denRoomBuyCallback != null)
               {
                  _denRoomBuyCallback();
               }
               _isBuyingDenRoom = false;
               _denRoomBuyCallback = null;
            }
         }
         else
         {
            _cachedDlResponse = data;
         }
      }
      
      public static function denRoomResponse(dfdh:DefPacksDefHelper) : void
      {
         var denRoomDef:Object = null;
         var data:Object = null;
         var newDef:Object = dfdh.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ROOM] = null;
         var denRoomDefs:Object = new Object();
         for each(data in dfdh.def)
         {
            denRoomDef = {
               "value":int(data.cost),
               "enviroType":int(data.enviroType),
               "mediaIdLarge":int(data.iconMediaRef),
               "defId":Number(data.id),
               "mediaId":int(data.mediaRef),
               "name":LocalizationManager.translateIdOnly(data.titleStrRef),
               "titleStrRef":int(data.titleStrRef),
               "xRoomName":data.pathName,
               "status":int(data.storeStatus),
               "membersOnly":data.membersOnly == "1"
            };
            denRoomDefs[denRoomDef.defId] = denRoomDef;
         }
         gMainFrame.userInfo.denRoomDefs = denRoomDefs;
         if(Boolean(_cachedDlResponse))
         {
            denListResponse(_cachedDlResponse);
            _cachedDlResponse = null;
         }
      }
      
      public static function relocalizeDenRooms() : void
      {
         var dr:Object = null;
         var denRoomDef:Object = gMainFrame.userInfo.denRoomDefs;
         for each(dr in denRoomDef)
         {
            dr.name = LocalizationManager.translateIdOnly(dr.titleStrRef);
         }
         gMainFrame.userInfo.denRoomDefs = denRoomDef;
      }
      
      private static function denStateResponse(data:Object) : void
      {
         var invIdx:int = 0;
         var defId:int = 0;
         var inUse:Boolean = false;
         var x:int = 0;
         var y:int = 0;
         var version:int = 0;
         var flipped:int = 0;
         var userName:String = null;
         var catId:int = 0;
         var packedId:uint = 0;
         var gameDefId:int = 0;
         var def:Object = null;
         var k:int = 0;
         var lBits:int = 0;
         var uBits:int = 0;
         var eBits:int = 0;
         var found:Boolean = false;
         var numExistingPendingChanges:int = 0;
         var o:Object = null;
         var o1:Object = null;
         var j:int = 2;
         var numItems:int = int(data[j++]);
         var numPetItems:int = int(data[j++]);
         var forceReload:Boolean = data[j++] == "1";
         var newPendingDenChanges:Array = [];
         var mgDefIds:Array = [];
         for(k = 0; k < numItems; k++)
         {
            invIdx = int(data[j++]);
            defId = int(data[j++]);
            def = getDenItemDef(defId);
            if(!def)
            {
               newPendingDenChanges[k] = {
                  "i":invIdx,
                  "x":0,
                  "y":0,
                  "r":DenItem.REF_ID_DEN_ITEM,
                  "c":0,
                  "userNameLink":""
               };
            }
            else
            {
               inUse = data[j++] == "1";
               x = int(data[j++]);
               y = int(data[j++]);
               version = int(data[j++]);
               flipped = int(data[j++]);
               userName = data[j] == "null" ? "" : data[j];
               j++;
               catId = int(def.sortCat);
               if(inUse)
               {
                  if(catId == DenItem.SORT_FLOOR || catId == DenItem.SORT_PET)
                  {
                     catId = DenItem.PLACE_CAT_FLOOR;
                  }
                  else if(catId == DenItem.SORT_WALL)
                  {
                     catId = DenItem.PLACE_CAT_WALL;
                  }
                  else if(catId == DenItem.SORT_AUDIO)
                  {
                     catId = DenItem.PLACE_CAT_ICONL;
                  }
                  else if(catId == DenItem.SORT_FLOORING || catId == DenItem.SORT_WALLPAPER)
                  {
                     catId = _roomMgr.denCatId;
                  }
                  else
                  {
                     catId = -1;
                  }
               }
               else
               {
                  catId = -1;
               }
               packedId = uint(defId << 16 | catId);
               gameDefId = int(def.gameDefId);
               if(gameDefId > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(gameDefId))
               {
                  mgDefIds.push(gameDefId);
               }
               newPendingDenChanges[k] = {
                  "i":invIdx,
                  "p":packedId,
                  "x":x,
                  "y":y,
                  "v":version,
                  "f":flipped,
                  "c":catId,
                  "r":DenItem.REF_ID_DEN_ITEM,
                  "s":def.sortCat,
                  "mg":def.gameDefId,
                  "l":def.layer,
                  "v2":def.flag,
                  "v3":0,
                  "zone":def.enviroType,
                  "strmName":def.abbrName,
                  "defId":defId,
                  "userNameLink":userName,
                  "specialType":def.specialType
               };
            }
         }
         for(k = 0; k < numPetItems; k++)
         {
            invIdx = int(data[j++]);
            lBits = int(data[j++]);
            uBits = int(data[j++]);
            eBits = int(data[j++]);
            defId = PetManager.getDefIdFromLBits(lBits);
            def = PetManager.getPetDef(defId);
            if(def)
            {
               catId = int(data[j++]);
               x = int(data[j++]);
               y = int(data[j++]);
               flipped = int(data[j++]);
               defId = denItemDefIdForPetDefId(defId);
               packedId = uint(defId << 16 | catId);
               newPendingDenChanges[numItems + k] = {
                  "i":invIdx,
                  "p":packedId,
                  "x":x,
                  "y":y,
                  "v":lBits,
                  "v2":uBits,
                  "v3":eBits,
                  "f":flipped,
                  "c":catId,
                  "r":DenItem.REF_ID_PET_ITEM,
                  "s":DenItem.SORT_PET,
                  "strmName":"",
                  "l":DenItem.DEN_PET_LAYER_ID,
                  "zone":def.enviroType,
                  "mg":0,
                  "defId":defId,
                  "userNameLink":""
               };
            }
         }
         if(mgDefIds.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(mgDefIds);
         }
         if(Boolean(_pendingDenChangeItems) && _pendingDenChangeItems.length > 0)
         {
            numExistingPendingChanges = int(_pendingDenChangeItems.length);
            for(j = 0; j < newPendingDenChanges.length; j++)
            {
               found = false;
               for(k = 0; k < numExistingPendingChanges; k++)
               {
                  if(newPendingDenChanges[j].r == _pendingDenChangeItems[k].r && newPendingDenChanges[j].i == _pendingDenChangeItems[k].i)
                  {
                     found = true;
                     o = _pendingDenChangeItems[k];
                     o1 = newPendingDenChanges[j];
                     o.x = o1.x;
                     o.y = o1.y;
                     o.v = o1.v;
                     o.v2 = o1.v2;
                     o.f = o1.f;
                     o.c = o1.c;
                     o.userNameLink = o1.userNameLink;
                     break;
                  }
               }
               if(!found)
               {
                  _pendingDenChangeItems.push(newPendingDenChanges[j]);
               }
            }
         }
         else
         {
            _pendingDenChangeItems = newPendingDenChanges;
         }
         if(!_denChangePending || forceReload)
         {
            setDenItems();
         }
         if(forceReload)
         {
            DarkenManager.showLoadingSpiral(false);
            RoomXtCommManager.loadingNewRoom = false;
            AvatarManager.joiningNewRoom = false;
         }
      }
      
      private static function denEmptyResponse(data:Object) : void
      {
         _roomMgr.denItemHolder.clearDen();
         if(Boolean(GuiManager.denEditor))
         {
            GuiManager.denEditor.clearDenInUseItems();
         }
      }
      
      private static function denPrivacyResponse(data:Object) : void
      {
         BuddyCard.onDenPrivacyResponse(data[2],data[3] == "1");
      }
      
      private static function denPrivacyKickResponse() : void
      {
         _roomMgr.needsToSeeKickFromDenMessage = true;
      }
      
      private static function denChangeResponse(data:Object) : void
      {
         _denChangePending = true;
         var newDenDefId:int = int(data[2]);
         if(data.length >= 4)
         {
            gMainFrame.userInfo.myPerUserAvId = int(data[3]);
            PetManager.myActivePetInvId = int(data[4]);
         }
         var denRoomDef:Object = gMainFrame.userInfo.getDenRoomDefByDefId(newDenDefId);
         if(_denChangeCallback != null)
         {
            _denChangeCallback(true);
            _denChangeCallback = null;
         }
         _roomMgr.loadRoom(denRoomDef.xRoomName,denRoomDef.enviroType,Utility.ROOMTYPE_DEN,denRoomDef.defId,100);
      }
      
      public static function handleDenShopList(data:Array, glId:int, glDefType:int, shopListCallback:Function) : void
      {
         var shopItemArray:Array = null;
         var j:int = 0;
         var dri:DenRoomItem = null;
         var o:Object = null;
         var i:int = 6;
         var shopName:String = data[4];
         var numItems:int = int(data[i++]);
         if(glDefType == DefPacksDefHelper.DEF_DEN_ITEM)
         {
            shopItemArray = generateDenShopList(numItems,data.splice(i++,data.length));
         }
         else
         {
            shopItemArray = new Array(numItems);
            for(j = 0; j < numItems; j++)
            {
               dri = new DenRoomItem();
               o = gMainFrame.userInfo.getDenRoomDefByDefId(data[i++]);
               dri.initShopItem(j,o.defId,o.mediaId,o.mediaIdLarge,o.value,o.name,o.enviroType,o.membersOnly,o.status);
               shopItemArray[j] = dri;
            }
         }
         if(shopListCallback != null)
         {
            shopListCallback(shopItemArray,shopName);
         }
      }
      
      public static function generateDenShopList(numItems:int, data:Object) : Array
      {
         var di:DenItem = null;
         var itemsArray:Array = [];
         for(var k:int = 0; k < numItems; k++)
         {
            di = new DenItem();
            di.initShopItem(int(data[k]),-1);
            itemsArray.push(di);
         }
         return itemsArray;
      }
      
      public static function setDenItems() : void
      {
         if(Boolean(_roomMgr))
         {
            if(Boolean(_pendingDenChangeItems))
            {
               _roomMgr.denItemHolder.setItems(_pendingDenChangeItems);
               _pendingDenChangeItems = null;
            }
         }
      }
      
      public static function denChangeDone() : void
      {
         _denChangePending = false;
         updateCatIdsForPendingFlooringAndWallpaper();
         setDenItems();
      }
      
      private static function updateCatIdsForPendingFlooringAndWallpaper() : void
      {
         var pendingItem:Object = null;
         if(!_pendingDenChangeItems || _pendingDenChangeItems.length <= 0)
         {
            return;
         }
         for(var i:int = 0; i < _pendingDenChangeItems.length; i++)
         {
            pendingItem = _pendingDenChangeItems[i];
            if(pendingItem.s == DenItem.SORT_FLOORING || pendingItem.s == DenItem.SORT_WALLPAPER)
            {
               pendingItem.c = _roomMgr.denCatId;
               pendingItem.p = uint(pendingItem.defId << 16 | pendingItem.c);
            }
         }
      }
      
      public static function saveDenItemsState() : void
      {
         _roomMgr.denItemHolder.saveState();
      }
      
      public static function set denChangePending(value:Boolean) : void
      {
         _denChangePending = value;
      }
      
      public static function set recycleDiCallback(callback:Function) : void
      {
         _recycleDiCallback = callback;
      }
      
      public static function set denHighestCallback(callback:Function) : void
      {
         _denHighestCallback = callback;
      }
      
      public static function set denPrivateCallback(callback:Function) : void
      {
         _denPrivateCallback = callback;
      }
      
      private static function denItemDefsResponse(dh:DefPacksDefHelper) : void
      {
         var denItemDef:Object = null;
         var data:Object = null;
         var denItemDefs:Object = new Object();
         for each(data in dh.def)
         {
            denItemDef = {
               "abbrName":data.abbrName,
               "cost":int(data.cost),
               "currencyType":int(data.currencyType),
               "enviroType":int(data.enviroType),
               "fileType":int(data.fileType),
               "flag":int(data.flag),
               "gameDefId":int(data.gameDefId),
               "id":int(data.id),
               "itemStatus":int(data.itemStatus),
               "layer":int(data.layer),
               "membersOnly":int(data.membersOnly),
               "name":LocalizationManager.translateIdOnly(int(data.nameStrId)),
               "nameStrId":int(data.nameStrId),
               "recycleValue":int(data.recycleValue),
               "scalePercent":int(data.scalePercent),
               "sortCat":int(data.sortCat),
               "specialType":int(data.specialType)
            };
            denItemDefs[denItemDef.id] = denItemDef;
         }
         _denItemDefs = denItemDefs;
         delete DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ITEM];
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ITEM] = null;
      }
      
      public static function relocalizeDenItems() : void
      {
         var di:Object = null;
         for each(di in _denItemDefs)
         {
            di.name = LocalizationManager.translateIdOnly(di.nameStrId);
         }
      }
      
      private static function enviroItems(items:Array) : Array
      {
         var denItem:DenItem = null;
         var modifiedItems:Array = [];
         for each(denItem in items)
         {
            if(denItem.enviroType == AvatarManager.roomEnviroType)
            {
               modifiedItems.push(denItem);
            }
         }
         return modifiedItems;
      }
      
      public static function denItemDefIdForPetDefId(petDefId:int) : int
      {
         switch(petDefId)
         {
            case PetBase.DEF_ID_ANGLER:
               return 863;
            case PetBase.DEF_ID_BAT:
               return 859;
            case PetBase.DEF_ID_BFLY:
               return 857;
            case PetBase.DEF_ID_CAT:
               return 853;
            case PetBase.DEF_ID_DOG:
               return 854;
            case PetBase.DEF_ID_DUCK:
               return 856;
            case PetBase.DEF_ID_FROG:
               return 855;
            case PetBase.DEF_ID_HAMS:
               return 858;
            case PetBase.DEF_ID_JELLYFISH:
               return 864;
            case PetBase.DEF_ID_REINDEER:
               return 860;
            case PetBase.DEF_ID_SEAHORSE:
               return 862;
            case PetBase.DEF_ID_SNAKE:
               return 861;
            case PetBase.DEF_ID_BUNNY:
               return 915;
            case PetBase.DEF_ID_HUMMINGBIRD:
               return 957;
            case PetBase.DEF_ID_TURTLE:
               return 1089;
            case PetBase.DEF_ID_MONKEY:
               return 1110;
            case PetBase.DEF_ID_TARANTUAL:
               return 1138;
            case PetBase.DEF_ID_FOX:
               return 1149;
            case PetBase.DEF_ID_OWL:
               return 1171;
            case PetBase.DEF_ID_TIGER:
               return 1180;
            case PetBase.DEF_ID_ARCTIC_WOLF:
               return 1206;
            case PetBase.DEF_ID_RACCOON:
               return 1275;
            case PetBase.DEF_ID_JOEY:
               return 1331;
            case PetBase.DEF_ID_EAGLET:
               return 1521;
            case PetBase.DEF_ID_CHEETAH:
               return 1567;
            case PetBase.DEF_ID_RHINO:
               return 1676;
            case PetBase.DEF_ID_GIRAFFE:
               return 1662;
            case PetBase.DEF_ID_SUGAR_GLIDER:
               return 1698;
            case PetBase.DEF_ID_LION_CUB:
               return 1780;
            default:
               return 853;
         }
      }
      
      public static function getDenItemDef(defId:int) : Object
      {
         return _denItemDefs[defId];
      }
   }
}

