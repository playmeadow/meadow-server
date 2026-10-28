package den
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import currency.UserCurrency;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.BuddyCard;
   import gui.DarkenManager;
   import gui.DenSwitch;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
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
      
      public static function init(param1:Function) : void
      {
         _roomMgr = RoomManagerWorld.instance;
         _denListCallback = param1;
         _denChangePending = false;
         _pendingDenChangeItems = null;
         var _loc2_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc2_.init(1030,denItemDefsResponse,null,2);
         DefPacksDefHelper.mediaArray[1030] = _loc2_;
         XtReplyDemuxer.addModule(handleXtReply,"d");
      }
      
      public static function destroy() : void
      {
         _denEditorDIResponseCallback = null;
         _denItemsCallback = null;
         _denRecycleCallback = null;
         _recycleDiCallback = null;
      }
      
      public static function requestDenStateChange(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         _loc2_[_loc3_++] = param1.length;
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_[_loc3_++] = param1[_loc4_].r;
            _loc2_[_loc3_++] = param1[_loc4_].i;
            _loc2_[_loc3_++] = param1[_loc4_].d;
            _loc2_[_loc3_++] = param1[_loc4_].x;
            _loc2_[_loc3_++] = param1[_loc4_].y;
            _loc2_[_loc3_++] = param1[_loc4_].f ? param1[_loc4_].f : 0;
            _loc2_[_loc3_++] = param1[_loc4_].userNameLink == "" ? "off" : param1[_loc4_].userNameLink;
            _loc4_++;
         }
         gMainFrame.server.setXtObject_Str("ds",_loc2_);
      }
      
      public static function requestDenItems(param1:Function = null) : void
      {
         _denItemsCallback = param1;
         gMainFrame.server.setXtObject_Str("di",[]);
      }
      
      public static function requestDenRoomList() : void
      {
         gMainFrame.server.setXtObject_Str("dl",[]);
      }
      
      public static function requestBuy(param1:Boolean, param2:int, param3:int, param4:Function, param5:int = 0, param6:Function = null, param7:int = 0, param8:int = 0) : void
      {
         _itemBuyCallback = param4;
         if(param1)
         {
            gMainFrame.server.setXtObject_Str("db",["0",param2,param3,param7,GenericListXtCommManager.getAvailListUniqueId(),param8]);
         }
         else
         {
            _isBuyingDenRoom = true;
            gMainFrame.server.setXtObject_Str("db",["-1",param2,param3,param5,GenericListXtCommManager.getAvailListUniqueId(),param8]);
            _denRoomBuyCallback = param6;
         }
      }
      
      public static function requestRecycle(param1:Boolean, param2:int, param3:Function, param4:Function = null) : void
      {
         _denRecycleCallback = param3;
         _recycleDiCallback = param4;
         gMainFrame.server.setXtObject_Str("dr",[param1 ? "0" : "-1",param2]);
      }
      
      public static function requestDenChange(param1:int, param2:Function) : void
      {
         _denChangeCallback = param2;
         gMainFrame.server.setXtObject_Str("dc",[DenSwitch.denList[param1].invId]);
      }
      
      public static function requestDenJoinFull(param1:String, param2:int = -1, param3:Boolean = true, param4:Boolean = true) : void
      {
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         if(!RoomXtCommManager.isSwitching)
         {
            if(RoomXtCommManager.loadingNewRoom)
            {
               DebugUtility.debugTrace("INGORING requestDenJoinFull request because user is already joining a new room!");
               return;
            }
            DarkenManager.showLoadingSpiral(true);
            if(gMainFrame.server.getCurrentRoom())
            {
               if(param1 == gMainFrame.server.getCurrentRoomName())
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
            RoomXtCommManager.denJoinRequested(param1);
            _denChangePending = true;
            _loc5_ = param4 ? "1" : "0";
            _loc6_ = param3 || _roomMgr.forceInvisMode;
            if(!_loc6_)
            {
               gMainFrame.server.setXtObject_Str("dj",[param1,_loc5_,"0",param2]);
            }
            else
            {
               gMainFrame.server.setXtObject_Str("dj",[param1,_loc5_,"1",param2]);
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
      
      public static function requestSetDenPrivacy(param1:Boolean, param2:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("dp",["0",param1 ? "1" : "0",param2 ? "1" : "0"]);
      }
      
      public static function requestUserDenPrivacy(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("dp",["1",param1]);
      }
      
      public static function requestEmptyDen() : void
      {
         gMainFrame.server.setXtObject_Str("de",[]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "ds":
               denStateResponse(_loc2_);
               break;
            case "dp":
               denPrivacyResponse(_loc2_);
               break;
            case "dpk":
               denPrivacyKickResponse();
               break;
            case "di":
               denItemsResponse(_loc2_);
               break;
            case "dc":
               denChangeResponse(_loc2_);
               break;
            case "db":
               denBuyResponse(_loc2_);
               break;
            case "dr":
               denRecycleResponse(_loc2_);
               break;
            case "dh":
               denHighestResponse(_loc2_);
               break;
            case "dl":
               denListResponse(_loc2_);
               break;
            case "drc":
               denRoomCount(_loc2_);
               break;
            case "de":
               denEmptyResponse(_loc2_);
               break;
            default:
               throw new Error("Did not expect ext cmd=" + _loc2_[0]);
         }
      }
      
      public static function denItemsResponse(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc25_:int = 0;
         var _loc14_:int = 0;
         var _loc19_:int = 0;
         var _loc18_:int = 0;
         var _loc13_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:Boolean = false;
         var _loc22_:* = null;
         var _loc9_:int = 0;
         var _loc2_:int = 0;
         var _loc17_:int = 0;
         var _loc20_:int = 0;
         var _loc8_:DenItem = null;
         var _loc24_:Object = null;
         var _loc16_:int = 2;
         DenSwitch.activeDenIdx = int(param1[_loc16_++]);
         var _loc23_:int = int(param1[_loc16_++]);
         var _loc3_:int = int(param1[_loc16_++]);
         var _loc21_:Array = new Array(_loc23_);
         var _loc6_:Array = [];
         var _loc12_:Boolean = true;
         _loc20_ = 0;
         while(_loc20_ < _loc23_)
         {
            _loc8_ = new DenItem();
            _loc5_ = int(param1[_loc16_++]);
            _loc25_ = int(param1[_loc16_++]);
            _loc14_ = int(param1[_loc16_++]);
            _loc7_ = int(param1[_loc16_++]);
            if(getDenItemDef(_loc25_).sortCat == 4 && _loc14_ > 0)
            {
               _loc12_ = false;
            }
            _loc8_.init(_loc25_,_loc5_,_loc14_,_loc7_);
            _loc21_[_loc20_] = _loc8_;
            if(_loc8_.minigameDefId > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc8_.minigameDefId))
            {
               _loc6_.push(_loc8_.minigameDefId);
            }
            _loc20_++;
         }
         _loc21_.sortOn("invIdx",0x10 | 2);
         _loc8_ = new DenItem();
         _loc8_.init(617,-1,_loc12_ ? 7 : 0);
         _loc21_.unshift(_loc8_);
         var _loc11_:Array = PetManager.myPetList;
         var _loc4_:Array = new Array(_loc11_.length);
         _loc20_ = 0;
         while(_loc20_ < _loc11_.length)
         {
            _loc24_ = _loc11_[_loc20_];
            _loc8_ = new DenItem();
            _loc8_.init(_loc24_.defId,_loc24_.idx,0,_loc24_.lBits,1,_loc24_.uBits,_loc24_.eBits);
            _loc4_[_loc20_] = _loc8_;
            _loc20_++;
         }
         _loc4_.sortOn("invIdx",0x10 | 2);
         var _loc15_:int = 0;
         while(_loc15_ < _loc3_)
         {
            _loc5_ = int(param1[_loc16_ + _loc15_]);
            _loc20_ = 0;
            while(_loc20_ < _loc4_.length)
            {
               if(_loc4_[_loc20_].invIdx == _loc5_)
               {
                  _loc4_[_loc20_].categoryId = 1;
                  break;
               }
               _loc20_++;
            }
            _loc15_++;
         }
         if(_loc6_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc6_);
         }
         if(AvatarManager.playerAvatar != null)
         {
            AvatarManager.playerAvatar.inventoryDenPartial.itemArray = gMainFrame.userInfo.playerUserInfo.denItemsPartial = enviroItems(_loc21_);
            AvatarManager.playerAvatar.inventoryDenFull.itemArray = _loc21_;
         }
         gMainFrame.userInfo.playerUserInfo.denItemsFull = _loc21_;
         gMainFrame.userInfo.myPetsInDen = _loc4_;
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
      
      public static function addPetToDen(param1:Object) : void
      {
         var _loc2_:DenItem = new DenItem();
         _loc2_.init(param1.defId,param1.idx,0,param1.lBits,1,param1.uBits,param1.eBits);
         if(gMainFrame.userInfo.myPetsInDen)
         {
            gMainFrame.userInfo.myPetsInDen.unshift(_loc2_);
         }
         else
         {
            gMainFrame.userInfo.myPetsInDen = [_loc2_];
         }
         GuiManager.onPetsChanged();
      }
      
      public static function removePetFromDen(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = gMainFrame.userInfo.myPetsInDen;
         if(!_loc3_)
         {
            return;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(_loc3_[_loc2_].invIdx == param1)
            {
               _loc3_.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
         GuiManager.onPetsChanged();
      }
      
      public static function reloadPetInDen(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc6_:int = 0;
         var _loc5_:DenItem = null;
         var _loc7_:Array = gMainFrame.userInfo.myPetsInDen;
         if(!_loc7_)
         {
            return;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc7_.length)
         {
            _loc5_ = _loc7_[_loc6_];
            if(_loc5_.invIdx == param1)
            {
               _loc5_.version = param2;
               _loc5_.version2 = param3;
               _loc5_.version3 = param4;
               break;
            }
            _loc6_++;
         }
         GuiManager.onPetsChanged();
      }
      
      public static function set denEditorDIResponseCallback(param1:Function) : void
      {
         _denEditorDIResponseCallback = param1;
      }
      
      private static function denBuyResponse(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc4_:int = int(param1[2]);
         var _loc5_:int = int(param1[5]);
         var _loc3_:int = int(param1[4]);
         if(param1[3] == "")
         {
            _loc2_ = UserCurrency.getCurrency(_loc5_);
            if(_loc2_ == null)
            {
               throw new Error("DenXtCommManager: Received unknown currencyType: " + _loc5_);
            }
         }
         else
         {
            _loc2_ = param1[3];
         }
         if(_loc4_ == 1)
         {
            if(!UserCurrency.setCurrency(_loc2_,_loc5_))
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc5_);
            }
         }
         if(_itemBuyCallback != null)
         {
            _itemBuyCallback(_loc4_,_loc2_);
         }
      }
      
      private static function denRecycleResponse(param1:Object) : void
      {
         var _loc3_:Boolean = param1[2] == "1";
         var _loc2_:int = UserCurrency.getCurrency(0) as int;
         var _loc4_:* = param1[3] == "" ? _loc2_ : param1[3];
         if(_loc3_)
         {
            UserCurrency.setCurrency(_loc4_,0);
         }
         if(_denRecycleCallback != null)
         {
            _denRecycleCallback(_loc3_);
         }
      }
      
      private static function denHighestResponse(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 2;
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc2_:Array = new Array(_loc3_);
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            _loc2_[_loc5_] = param1[_loc4_++];
            _loc5_++;
         }
         if(_denHighestCallback != null)
         {
            _denHighestCallback(_loc2_);
         }
      }
      
      private static function denPrivateResponse(param1:Object) : void
      {
         if(_denPrivateCallback != null)
         {
            _denPrivateCallback(param1[3],param1[4] == "1");
         }
      }
      
      private static function denRoomCount(param1:Object) : void
      {
         var _loc4_:int = 2;
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc5_:Boolean = param1[_loc4_++] == "1";
         var _loc2_:String = param1[_loc4_++];
         GuiManager.updateDenRoomCount(_loc3_,_loc5_,_loc2_);
      }
      
      private static function denListResponse(param1:Object) : void
      {
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Array = null;
         var _loc9_:int = 0;
         var _loc2_:DenRoomItem = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:Object = null;
         if(gMainFrame.userInfo.denRoomDefs)
         {
            _loc7_ = 2;
            _loc3_ = int(param1[_loc7_++]);
            _loc6_ = new Array(_loc3_);
            _loc9_ = 0;
            while(_loc9_ < _loc3_)
            {
               _loc2_ = new DenRoomItem();
               _loc5_ = int(param1[_loc7_++]);
               _loc4_ = int(param1[_loc7_++]);
               _loc8_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc4_);
               if(_loc8_)
               {
                  _loc2_.init(_loc5_,_loc4_,_loc8_.mediaId,_loc8_.value,_loc8_.name,_loc8_.enviroType,_loc8_.membersOnly);
                  _loc6_[_loc5_] = _loc2_;
               }
               _loc9_++;
            }
            if(_denListCallback != null)
            {
               _denListCallback(_loc6_);
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
            _cachedDlResponse = param1;
         }
      }
      
      public static function denRoomResponse(param1:DefPacksDefHelper) : void
      {
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1040] = null;
         var _loc3_:Object = {};
         for each(var _loc4_:Object in param1.def)
         {
            _loc5_ = {
               "value":int(_loc4_.cost),
               "enviroType":int(_loc4_.enviroType),
               "mediaIdLarge":int(_loc4_.iconMediaRef),
               "defId":Number(_loc4_.id),
               "mediaId":int(_loc4_.mediaRef),
               "name":LocalizationManager.translateIdOnly(_loc4_.titleStrRef),
               "titleStrRef":int(_loc4_.titleStrRef),
               "status":int(_loc4_.storeStatus),
               "membersOnly":_loc4_.membersOnly == "1",
               "roomDefId":int(_loc4_.roomDefId)
            };
            _loc3_[_loc5_.defId] = _loc5_;
         }
         gMainFrame.userInfo.denRoomDefs = _loc3_;
         if(_cachedDlResponse)
         {
            denListResponse(_cachedDlResponse);
            _cachedDlResponse = null;
         }
      }
      
      public static function relocalizeDenRooms() : void
      {
         var _loc2_:Object = gMainFrame.userInfo.denRoomDefs;
         for each(var _loc1_:Object in _loc2_)
         {
            _loc1_.name = LocalizationManager.translateIdOnly(_loc1_.titleStrRef);
         }
         gMainFrame.userInfo.denRoomDefs = _loc2_;
      }
      
      private static function denStateResponse(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc26_:int = 0;
         var _loc25_:int = 0;
         var _loc6_:int = 0;
         var _loc23_:int = 0;
         var _loc12_:String = null;
         var _loc24_:int = 0;
         var _loc14_:* = 0;
         var _loc16_:int = 0;
         var _loc10_:Object = null;
         var _loc20_:int = 0;
         var _loc2_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc27_:Boolean = false;
         var _loc22_:int = 0;
         var _loc13_:Object = null;
         var _loc15_:Object = null;
         var _loc17_:int = 2;
         var _loc21_:int = int(param1[_loc17_++]);
         var _loc11_:int = int(param1[_loc17_++]);
         var _loc7_:Boolean = param1[_loc17_++] == "1";
         var _loc3_:Array = [];
         var _loc5_:Array = [];
         _loc20_ = 0;
         while(_loc20_ < _loc21_)
         {
            _loc4_ = int(param1[_loc17_++]);
            _loc8_ = int(param1[_loc17_++]);
            _loc10_ = getDenItemDef(_loc8_);
            if(!_loc10_)
            {
               _loc3_[_loc20_] = {
                  "i":_loc4_,
                  "x":0,
                  "y":0,
                  "r":0,
                  "c":0,
                  "userNameLink":""
               };
            }
            else
            {
               _loc9_ = param1[_loc17_++] == "1";
               _loc26_ = int(param1[_loc17_++]);
               _loc25_ = int(param1[_loc17_++]);
               _loc6_ = int(param1[_loc17_++]);
               _loc23_ = int(param1[_loc17_++]);
               _loc12_ = param1[_loc17_] == "null" ? "" : param1[_loc17_];
               _loc17_++;
               _loc24_ = int(_loc10_.sortCat);
               if(_loc9_)
               {
                  if(_loc24_ == 0 || _loc24_ == 5)
                  {
                     _loc24_ = 1;
                  }
                  else if(_loc24_ == 1)
                  {
                     _loc24_ = 2;
                  }
                  else if(_loc24_ == 4)
                  {
                     _loc24_ = 3;
                  }
                  else if(_loc24_ == 2 || _loc24_ == 3)
                  {
                     _loc24_ = _roomMgr.denCatId;
                  }
                  else
                  {
                     _loc24_ = -1;
                  }
               }
               else
               {
                  _loc24_ = -1;
               }
               _loc14_ = uint(_loc8_ << 16 | _loc24_);
               _loc16_ = int(_loc10_.gameDefId);
               if(_loc16_ > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc16_))
               {
                  _loc5_.push(_loc16_);
               }
               _loc3_[_loc20_] = {
                  "i":_loc4_,
                  "p":_loc14_,
                  "x":_loc26_,
                  "y":_loc25_,
                  "v":_loc6_,
                  "f":_loc23_,
                  "c":_loc24_,
                  "r":0,
                  "s":_loc10_.sortCat,
                  "mg":_loc10_.gameDefId,
                  "l":_loc10_.layer,
                  "v2":_loc10_.flag,
                  "v3":0,
                  "zone":_loc10_.enviroType,
                  "strmName":_loc10_.abbrName,
                  "defId":_loc8_,
                  "userNameLink":_loc12_,
                  "specialType":_loc10_.specialType,
                  "listLauncherId":_loc10_.listId,
                  "nameStrId":_loc10_.nameStrId
               };
            }
            _loc20_++;
         }
         _loc20_ = 0;
         while(_loc20_ < _loc11_)
         {
            _loc4_ = int(param1[_loc17_++]);
            _loc2_ = int(param1[_loc17_++]);
            _loc18_ = int(param1[_loc17_++]);
            _loc19_ = int(param1[_loc17_++]);
            _loc8_ = PetManager.getDefIdFromLBits(_loc2_);
            _loc10_ = PetManager.getPetDef(_loc8_);
            if(_loc10_)
            {
               _loc24_ = int(param1[_loc17_++]);
               _loc26_ = int(param1[_loc17_++]);
               _loc25_ = int(param1[_loc17_++]);
               _loc23_ = int(param1[_loc17_++]);
               _loc8_ = denItemDefIdForPetDefId(_loc8_);
               _loc14_ = uint(_loc8_ << 16 | _loc24_);
               _loc3_[_loc21_ + _loc20_] = {
                  "i":_loc4_,
                  "p":_loc14_,
                  "x":_loc26_,
                  "y":_loc25_,
                  "v":_loc2_,
                  "v2":_loc18_,
                  "v3":_loc19_,
                  "f":_loc23_,
                  "c":_loc24_,
                  "r":1,
                  "s":5,
                  "strmName":"",
                  "l":0,
                  "zone":_loc10_.enviroType,
                  "mg":0,
                  "defId":_loc8_,
                  "userNameLink":"",
                  "listLauncherId":0,
                  "nameStrId":_loc10_.titleStrId
               };
            }
            _loc20_++;
         }
         if(_loc5_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc5_);
         }
         if(_pendingDenChangeItems && _pendingDenChangeItems.length > 0)
         {
            _loc22_ = int(_pendingDenChangeItems.length);
            _loc17_ = 0;
            while(_loc17_ < _loc3_.length)
            {
               _loc27_ = false;
               _loc20_ = 0;
               while(_loc20_ < _loc22_)
               {
                  if(_loc3_[_loc17_].r == _pendingDenChangeItems[_loc20_].r && _loc3_[_loc17_].i == _pendingDenChangeItems[_loc20_].i)
                  {
                     _loc27_ = true;
                     _loc15_ = _pendingDenChangeItems[_loc20_];
                     _loc13_ = _loc3_[_loc17_];
                     _loc15_.x = _loc13_.x;
                     _loc15_.y = _loc13_.y;
                     _loc15_.v = _loc13_.v;
                     _loc15_.v2 = _loc13_.v2;
                     _loc15_.f = _loc13_.f;
                     _loc15_.c = _loc13_.c;
                     _loc15_.userNameLink = _loc13_.userNameLink;
                     break;
                  }
                  _loc20_++;
               }
               if(!_loc27_)
               {
                  _pendingDenChangeItems.push(_loc3_[_loc17_]);
               }
               _loc17_++;
            }
         }
         else
         {
            _pendingDenChangeItems = _loc3_;
         }
         if(!_denChangePending || _loc7_)
         {
            setDenItems();
         }
         if(_loc7_)
         {
            DarkenManager.showLoadingSpiral(false);
            RoomXtCommManager.loadingNewRoom = false;
            AvatarManager.joiningNewRoom = false;
         }
      }
      
      private static function denEmptyResponse(param1:Object) : void
      {
         _roomMgr.denItemHolder.clearDen();
         if(GuiManager.denEditor)
         {
            GuiManager.denEditor.clearDenInUseItems();
         }
      }
      
      private static function denPrivacyResponse(param1:Object) : void
      {
         BuddyCard.onDenPrivacyResponse(param1[2],param1[3] == "1");
      }
      
      private static function denPrivacyKickResponse() : void
      {
         _roomMgr.needsToSeeKickFromDenMessage = true;
      }
      
      private static function denChangeResponse(param1:Object) : void
      {
         _denChangePending = true;
         var _loc2_:int = int(param1[2]);
         if(param1.length >= 4)
         {
            gMainFrame.userInfo.myPerUserAvId = int(param1[3]);
            PetManager.myActivePetInvId = int(param1[4]);
         }
         var _loc4_:Object = gMainFrame.userInfo.getDenRoomDefByDefId(_loc2_);
         var _loc3_:Object = _loc4_ != null ? RoomXtCommManager.getRoomDef(_loc4_.roomDefId) : null;
         if(_denChangeCallback != null)
         {
            _denChangeCallback(_loc3_ != null && _loc4_ != null);
            _denChangeCallback = null;
         }
         if(_loc3_ && _loc4_)
         {
            _roomMgr.loadRoom(_loc3_.pathName,_loc4_.enviroType,2,_loc4_.defId,100);
         }
      }
      
      public static function handleDenShopList(param1:Array, param2:int, param3:Function) : Array
      {
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc4_:DenRoomItem = null;
         var _loc6_:Object = null;
         var _loc10_:int = 6;
         var _loc5_:String = param1[4];
         var _loc9_:int = int(param1[_loc10_++]);
         if(param2 == 1030)
         {
            _loc7_ = generateDenShopList(_loc9_,param1.splice(_loc10_++,param1.length));
         }
         else
         {
            _loc7_ = new Array(_loc9_);
            _loc8_ = 0;
            while(_loc8_ < _loc9_)
            {
               _loc4_ = new DenRoomItem();
               _loc6_ = gMainFrame.userInfo.getDenRoomDefByDefId(param1[_loc10_++]);
               _loc4_.initShopItem(_loc8_,_loc6_.defId,_loc6_.mediaId,_loc6_.mediaIdLarge,_loc6_.value,_loc6_.name,_loc6_.enviroType,_loc6_.membersOnly,_loc6_.status);
               _loc7_[_loc8_] = _loc4_;
               _loc8_++;
            }
         }
         if(param3 != null)
         {
            param3(_loc7_,_loc5_);
         }
         return _loc7_;
      }
      
      public static function generateDenShopList(param1:int, param2:Object) : Array
      {
         var _loc5_:int = 0;
         var _loc3_:DenItem = null;
         var _loc4_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < param1)
         {
            _loc3_ = new DenItem();
            _loc3_.initShopItem(int(param2[_loc5_]),-1);
            _loc4_.push(_loc3_);
            _loc5_++;
         }
         return _loc4_;
      }
      
      public static function setDenItems() : void
      {
         if(_roomMgr)
         {
            if(_pendingDenChangeItems)
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
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         if(!_pendingDenChangeItems || _pendingDenChangeItems.length <= 0)
         {
            return;
         }
         _loc2_ = 0;
         while(_loc2_ < _pendingDenChangeItems.length)
         {
            _loc1_ = _pendingDenChangeItems[_loc2_];
            if(_loc1_.s == 2 || _loc1_.s == 3)
            {
               _loc1_.c = _roomMgr.denCatId;
               _loc1_.p = uint(_loc1_.defId << 16 | _loc1_.c);
            }
            _loc2_++;
         }
      }
      
      public static function saveDenItemsState() : void
      {
         _roomMgr.denItemHolder.saveState();
      }
      
      public static function set denChangePending(param1:Boolean) : void
      {
         _denChangePending = param1;
      }
      
      public static function set recycleDiCallback(param1:Function) : void
      {
         _recycleDiCallback = param1;
      }
      
      public static function set denHighestCallback(param1:Function) : void
      {
         _denHighestCallback = param1;
      }
      
      public static function set denPrivateCallback(param1:Function) : void
      {
         _denPrivateCallback = param1;
      }
      
      private static function denItemDefsResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         var _loc4_:Object = {};
         for each(var _loc3_:Object in param1.def)
         {
            _loc2_ = {
               "abbrName":_loc3_.abbrName,
               "cost":int(_loc3_.cost),
               "currencyType":int(_loc3_.currencyType),
               "enviroType":int(_loc3_.enviroType),
               "fileType":int(_loc3_.fileType),
               "flag":int(_loc3_.flag),
               "gameDefId":int(_loc3_.gameDefId),
               "id":int(_loc3_.id),
               "itemStatus":int(_loc3_.itemStatus),
               "layer":int(_loc3_.layer),
               "membersOnly":int(_loc3_.membersOnly),
               "name":LocalizationManager.translateIdOnly(int(_loc3_.nameStrId)),
               "nameStrId":int(_loc3_.nameStrId),
               "recycleValue":int(_loc3_.recycleValue),
               "scalePercent":int(_loc3_.scalePercent),
               "sortCat":int(_loc3_.sortCat),
               "specialType":int(_loc3_.specialType),
               "combinedCurrencyString":_loc3_.combinedCost,
               "listId":int(_loc3_.parentArrayId)
            };
            _loc4_[_loc2_.id] = _loc2_;
         }
         _denItemDefs = _loc4_;
         delete DefPacksDefHelper.mediaArray[1030];
         DefPacksDefHelper.mediaArray[1030] = null;
      }
      
      public static function relocalizeDenItems() : void
      {
         for each(var _loc1_:Object in _denItemDefs)
         {
            _loc1_.name = LocalizationManager.translateIdOnly(_loc1_.nameStrId);
         }
      }
      
      private static function enviroItems(param1:Array) : Array
      {
         var _loc2_:Array = [];
         for each(var _loc3_:DenItem in param1)
         {
            if(_loc3_.enviroType == AvatarManager.roomEnviroType)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public static function denItemDefIdForPetDefId(param1:int) : int
      {
         switch(param1)
         {
            case 9:
               return 863;
            case 7:
               return 859;
            case 5:
               return 857;
            case 1:
               return 853;
            case 4:
               return 854;
            case 3:
               return 856;
            case 2:
               return 855;
            case 6:
               return 858;
            case 12:
               return 864;
            case 10:
               return 860;
            case 8:
               return 862;
            case 11:
               return 861;
            case 13:
               return 915;
            case 14:
               return 957;
            case 15:
               return 1089;
            case 16:
               return 1110;
            case 17:
               return 1138;
            case 18:
               return 1149;
            case 19:
               return 1171;
            case 20:
               return 1180;
            case 21:
               return 1206;
            case 22:
               return 1275;
            case 23:
               return 1331;
            case 24:
               return 1521;
            case 25:
               return 1567;
            case 26:
               return 1676;
            case 27:
               return 1662;
            case 28:
               return 1698;
            case 29:
               return 1780;
            case 30:
               return 1868;
            case 31:
               return 1867;
            case 32:
               return 1946;
            case 34:
               return 1995;
            case 35:
               return 2032;
            case 36:
               return 2292;
            case 37:
               return 2300;
            case 38:
               return 2301;
            case 39:
               return 2307;
            case 40:
               return 2350;
            case 42:
               return 2432;
            case 43:
               return 2463;
            case 44:
               return 2506;
            case 45:
               return 2513;
            default:
               return 853;
         }
      }
      
      public static function getDenItemDef(param1:int) : Object
      {
         return _denItemDefs[param1];
      }
   }
}

