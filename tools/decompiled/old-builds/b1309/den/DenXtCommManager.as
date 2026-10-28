package den
{
   import avatar.AvatarManager;
   import collection.DenItemCollection;
   import collection.DenRoomItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import currency.UserCurrency;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.BuddyManager;
   import gui.DarkenManager;
   import gui.DenSwitch;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.PetDef;
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
         var _loc3_:int = 0;
         var _loc2_:Array = [];
         var _loc4_:int = 0;
         _loc2_[_loc4_++] = param1.length;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_[_loc4_++] = param1[_loc3_].r;
            _loc2_[_loc4_++] = param1[_loc3_].i;
            _loc2_[_loc4_++] = param1[_loc3_].d;
            _loc2_[_loc4_++] = param1[_loc3_].x;
            _loc2_[_loc4_++] = param1[_loc3_].y;
            _loc2_[_loc4_++] = param1[_loc3_].f ? param1[_loc3_].f : 0;
            _loc2_[_loc4_++] = param1[_loc3_].userNameLink == "" ? "off" : param1[_loc3_].userNameLink;
            _loc3_++;
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
      
      public static function requestBuy(param1:Boolean, param2:int, param3:int, param4:Function, param5:Function, param6:int = 0, param7:Function = null, param8:int = 0, param9:int = 0, param10:Boolean = false) : void
      {
         _itemBuyCallback = param4;
         _denEditorDIResponseCallback = param5;
         if(param1)
         {
            gMainFrame.server.setXtObject_Str("db",["0",param2,param3,param8,GenericListXtCommManager.getAvailListUniqueId(),param9,param10]);
         }
         else
         {
            _isBuyingDenRoom = true;
            gMainFrame.server.setXtObject_Str("db",["-1",param2,param3,param6,GenericListXtCommManager.getAvailListUniqueId(),param9]);
            _denRoomBuyCallback = param7;
         }
      }
      
      public static function requestRecycle(param1:Boolean, param2:IntItemCollection, param3:Function, param4:Function = null) : void
      {
         _denRecycleCallback = param3;
         _recycleDiCallback = param4;
         gMainFrame.server.setXtObject_Str("dr",[param1 ? "0" : "-1",param2.getCoreArray()]);
      }
      
      public static function requestDenChange(param1:int, param2:Function) : void
      {
         _denChangeCallback = param2;
         gMainFrame.server.setXtObject_Str("dc",[DenSwitch.denList.getDenRoomItem(param1).invIdx]);
      }
      
      public static function requestDenJoinFull(param1:String, param2:int = -1, param3:Boolean = true, param4:Boolean = true) : void
      {
         var _loc6_:String = null;
         var _loc5_:Boolean = false;
         if(!RoomXtCommManager.isSwitching)
         {
            if(RoomXtCommManager.loadingNewRoom)
            {
               DebugUtility.debugTrace("INGORING requestDenJoinFull request because user is already joining a new room!");
               return;
            }
            if(gMainFrame.server.getCurrentRoom())
            {
               if(param1 == gMainFrame.server.getCurrentRoomName())
               {
                  trace("WARNING: User is already in this den!");
                  return;
               }
            }
            DarkenManager.showLoadingSpiral(true);
            AvatarManager.joiningNewRoom = true;
            if(RoomManagerWorld.instance.haveHadLastGoodRoomName())
            {
               SBTracker.trackPageview("/game/play/loading/changeRooms");
            }
            RoomXtCommManager.denJoinRequested(param1);
            _denChangePending = true;
            _loc6_ = param4 ? "1" : "0";
            _loc5_ = param3 || _roomMgr.forceInvisMode;
            if(!_loc5_)
            {
               gMainFrame.server.setXtObject_Str("dj",[param1,_loc6_,"0",param2]);
            }
            else
            {
               gMainFrame.server.setXtObject_Str("dj",[param1,_loc6_,"1",param2]);
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
         var _loc27_:int = 0;
         var _loc24_:int = 0;
         var _loc28_:int = 0;
         var _loc14_:int = 0;
         var _loc25_:int = 0;
         var _loc9_:int = 0;
         var _loc21_:int = 0;
         var _loc12_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc10_:* = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc29_:String = null;
         var _loc20_:String = null;
         var _loc18_:int = 0;
         var _loc15_:DenItem = null;
         var _loc26_:Object = null;
         var _loc19_:int = 2;
         DenSwitch.activeDenIdx = int(param1[_loc19_++]);
         var _loc11_:int = int(param1[_loc19_++]);
         var _loc13_:int = int(param1[_loc19_++]);
         var _loc5_:DenItemCollection = new DenItemCollection();
         var _loc17_:Array = [];
         var _loc6_:Boolean = true;
         _loc18_ = 0;
         while(_loc18_ < _loc11_)
         {
            _loc15_ = new DenItem();
            _loc27_ = int(param1[_loc19_++]);
            _loc24_ = int(param1[_loc19_++]);
            _loc28_ = int(param1[_loc19_++]);
            _loc21_ = int(param1[_loc19_++]);
            _loc12_ = param1[_loc19_++] == "true";
            _loc29_ = param1[_loc19_++];
            _loc20_ = param1[_loc19_++];
            if(getDenItemDef(_loc24_).sortCat == 4 && _loc28_ > 0)
            {
               _loc6_ = false;
            }
            _loc15_.init(_loc24_,_loc27_,_loc28_,_loc21_,0,0,0,0,_loc12_,_loc29_,_loc20_);
            _loc5_.setDenItem(_loc18_,_loc15_);
            if(_loc15_.minigameDefId > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc15_.minigameDefId))
            {
               _loc17_.push(_loc15_.minigameDefId);
            }
            _loc18_++;
         }
         _loc5_.getCoreArray().sortOn("invIdx",0x10 | 2);
         _loc15_ = new DenItem();
         _loc15_.init(617,-1,_loc6_ ? 7 : 0);
         _loc5_.getCoreArray().unshift(_loc15_);
         var _loc3_:Array = PetManager.myPetList;
         var _loc23_:DenItemCollection = new DenItemCollection();
         var _loc16_:DenItemCollection = new DenItemCollection();
         _loc18_ = 0;
         while(_loc18_ < _loc3_.length)
         {
            _loc26_ = _loc3_[_loc18_];
            _loc15_ = new DenItem();
            _loc15_.init(_loc26_.defId,_loc26_.idx,0,_loc26_.lBits,1,_loc26_.uBits,_loc26_.eBits);
            if(PetManager.canPetGoInBothEnviroTypes(_loc15_.petType))
            {
               _loc23_.pushDenItem(_loc15_);
               _loc16_.pushDenItem(_loc15_);
            }
            else if(_loc15_.enviroType == 2 || _loc15_.enviroType == 0)
            {
               _loc23_.pushDenItem(_loc15_);
            }
            else
            {
               _loc16_.pushDenItem(_loc15_);
            }
            _loc18_++;
         }
         _loc23_.getCoreArray().sortOn("invIdx",0x10 | 2);
         _loc16_.getCoreArray().sortOn("invIdx",0x10 | 2);
         var _loc22_:int = 0;
         while(_loc22_ < _loc13_)
         {
            _loc27_ = int(param1[_loc19_ + _loc22_]);
            _loc18_ = 0;
            while(_loc18_ < _loc23_.length)
            {
               if(_loc23_.getDenItem(_loc18_).invIdx == _loc27_)
               {
                  _loc23_.getDenItem(_loc18_).categoryId = 1;
                  break;
               }
               _loc18_++;
            }
            _loc18_ = 0;
            while(_loc18_ < _loc16_.length)
            {
               if(_loc16_.getDenItem(_loc18_).invIdx == _loc27_)
               {
                  _loc16_.getDenItem(_loc18_).categoryId = 1;
                  break;
               }
               _loc18_++;
            }
            _loc22_++;
         }
         if(_loc17_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc17_);
         }
         gMainFrame.userInfo.playerUserInfo.denItemsPartial = enviroItems(_loc5_);
         if(AvatarManager.playerAvatar != null)
         {
            AvatarManager.playerAvatar.inventoryDenPartial.denItemCollection = gMainFrame.userInfo.playerUserInfo.denItemsPartial;
            AvatarManager.playerAvatar.inventoryDenFull.denItemCollection = _loc5_;
         }
         gMainFrame.userInfo.playerUserInfo.denItemsFull = _loc5_;
         gMainFrame.userInfo.setMyPetsInDenByEnviroType(_loc23_,0);
         gMainFrame.userInfo.setMyPetsInDenByEnviroType(_loc16_,1);
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
         if(PetManager.canPetGoInBothEnviroTypes(_loc2_.petType))
         {
            if(gMainFrame.userInfo.getMyPetsInDenByEnviroType(0))
            {
               gMainFrame.userInfo.getMyPetsInDenByEnviroType(0).getCoreArray().unshift(_loc2_);
            }
            else
            {
               gMainFrame.userInfo.setMyPetsInDenByEnviroType(new DenItemCollection(),0);
               gMainFrame.userInfo.getMyPetsInDenByEnviroType(0).pushDenItem(_loc2_);
            }
            if(gMainFrame.userInfo.getMyPetsInDenByEnviroType(1))
            {
               gMainFrame.userInfo.getMyPetsInDenByEnviroType(1).getCoreArray().unshift(_loc2_);
            }
            else
            {
               gMainFrame.userInfo.setMyPetsInDenByEnviroType(new DenItemCollection(),1);
               gMainFrame.userInfo.getMyPetsInDenByEnviroType(1).pushDenItem(_loc2_);
            }
         }
         else if(gMainFrame.userInfo.getMyPetsInDenByEnviroType(_loc2_.enviroType))
         {
            gMainFrame.userInfo.getMyPetsInDenByEnviroType(_loc2_.enviroType).getCoreArray().unshift(_loc2_);
         }
         else
         {
            gMainFrame.userInfo.setMyPetsInDenByEnviroType(new DenItemCollection(),_loc2_.enviroType);
            gMainFrame.userInfo.getMyPetsInDenByEnviroType(_loc2_.enviroType).pushDenItem(_loc2_);
         }
         GuiManager.resetPetWindowListAndUpdateBtns();
      }
      
      public static function removePetFromDen(param1:int, param2:int) : void
      {
         if(PetManager.canPetGoInBothEnviroTypes(param2))
         {
            removePetFromDenByEnviroType(param1,0);
            removePetFromDenByEnviroType(param1,1);
         }
         else
         {
            removePetFromDenByEnviroType(param1,PetManager.getEnviroTypeByPetType(param2));
         }
         GuiManager.resetPetWindowListAndUpdateBtns();
      }
      
      private static function removePetFromDenByEnviroType(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:DenItemCollection = gMainFrame.userInfo.getMyPetsInDenByEnviroType(param2);
         if(!_loc4_)
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            if(_loc4_.getDenItem(_loc3_).invIdx == param1)
            {
               _loc4_.getCoreArray().splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
      }
      
      public static function reloadPetInDen(param1:int, param2:int, param3:int, param4:int, param5:int) : void
      {
         if(PetManager.canPetGoInBothEnviroTypes(param2))
         {
            updatePetInDenByEnviroType(param1,0,param3,param4,param5);
            updatePetInDenByEnviroType(param1,1,param3,param4,param5);
         }
         else
         {
            updatePetInDenByEnviroType(param1,PetManager.getEnviroTypeByPetType(param2),param3,param4,param5);
         }
         GuiManager.resetPetWindowListAndUpdateBtns();
      }
      
      private static function updatePetInDenByEnviroType(param1:int, param2:int, param3:int, param4:int, param5:int) : void
      {
         var _loc6_:int = 0;
         var _loc8_:DenItem = null;
         var _loc7_:DenItemCollection = gMainFrame.userInfo.getMyPetsInDenByEnviroType(param2);
         if(!_loc7_)
         {
            return;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc7_.length)
         {
            _loc8_ = _loc7_.getDenItem(_loc6_);
            if(_loc8_.invIdx == param1)
            {
               _loc8_.version = param3;
               _loc8_.version2 = param4;
               _loc8_.version3 = param5;
               break;
            }
            _loc6_++;
         }
      }
      
      public static function set denEditorDIResponseCallback(param1:Function) : void
      {
         _denEditorDIResponseCallback = param1;
      }
      
      private static function denBuyResponse(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc6_:int = int(param1[2]);
         var _loc2_:int = int(param1[5]);
         var _loc4_:int = int(param1[4]);
         var _loc3_:int = int(param1[6]);
         if(param1[3] == "")
         {
            _loc5_ = UserCurrency.getCurrency(_loc2_);
            if(_loc5_ == null)
            {
               throw new Error("DenXtCommManager: Received unknown currencyType: " + _loc2_);
            }
         }
         else
         {
            _loc5_ = param1[3];
         }
         if(_loc6_ == 1)
         {
            if(!UserCurrency.setCurrency(_loc5_,_loc2_))
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc2_);
            }
         }
         if(_itemBuyCallback != null)
         {
            _itemBuyCallback(_loc6_,_loc5_,_loc3_);
            _itemBuyCallback = null;
         }
      }
      
      private static function denRecycleResponse(param1:Object) : void
      {
         var _loc4_:Boolean = int(param1[2]) > 0;
         var _loc3_:int = UserCurrency.getCurrency(0) as int;
         var _loc2_:* = param1[3] == "" ? _loc3_ : param1[3];
         if(_loc4_)
         {
            UserCurrency.setCurrency(_loc2_,0);
         }
         if(_denRecycleCallback != null)
         {
            _denRecycleCallback(int(param1[2]));
         }
      }
      
      private static function denHighestResponse(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 2;
         var _loc2_:int = int(param1[_loc5_++]);
         var _loc3_:Array = new Array(_loc2_);
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_[_loc4_] = param1[_loc5_++];
            _loc4_++;
         }
         if(_denHighestCallback != null)
         {
            _denHighestCallback(_loc3_);
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
         var _loc5_:int = 2;
         var _loc3_:int = int(param1[_loc5_++]);
         var _loc2_:Boolean = param1[_loc5_++] == "1";
         var _loc4_:String = param1[_loc5_++];
         GuiManager.updateDenRoomCount(_loc3_,_loc2_,_loc4_);
      }
      
      private static function denListResponse(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc9_:DenRoomItemCollection = null;
         var _loc5_:int = 0;
         var _loc7_:DenRoomItem = null;
         var _loc8_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(gMainFrame.userInfo.denRoomDefs)
         {
            _loc6_ = 2;
            _loc2_ = int(param1[_loc6_++]);
            _loc9_ = new DenRoomItemCollection();
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc7_ = new DenRoomItem();
               _loc8_ = int(param1[_loc6_++]);
               _loc3_ = int(param1[_loc6_++]);
               _loc4_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc3_);
               if(_loc4_)
               {
                  _loc7_.init(_loc8_,_loc3_,_loc4_);
                  _loc9_.setDenRoomItem(_loc8_,_loc7_);
               }
               _loc5_++;
            }
            if(_denListCallback != null)
            {
               _denListCallback(_loc9_);
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
         var _loc4_:Object = null;
         var _loc5_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1040] = null;
         var _loc2_:Object = {};
         for each(var _loc3_:Object in param1.def)
         {
            _loc4_ = {
               "value":int(_loc3_.cost),
               "enviroType":int(_loc3_.enviroType),
               "mediaIdLarge":int(_loc3_.iconMediaRef),
               "defId":Number(_loc3_.id),
               "mediaId":int(_loc3_.mediaRef),
               "name":LocalizationManager.translateIdOnly(_loc3_.titleStrRef),
               "titleStrRef":int(_loc3_.titleStrRef),
               "status":int(_loc3_.storeStatus),
               "membersOnly":_loc3_.membersOnly == "1",
               "roomDefId":int(_loc3_.roomDefId)
            };
            _loc2_[_loc4_.defId] = _loc4_;
         }
         gMainFrame.userInfo.denRoomDefs = _loc2_;
         if(_cachedDlResponse)
         {
            denListResponse(_cachedDlResponse);
            _cachedDlResponse = null;
         }
      }
      
      public static function relocalizeDenRooms() : void
      {
         var _loc1_:Object = gMainFrame.userInfo.denRoomDefs;
         for each(var _loc2_:Object in _loc1_)
         {
            _loc2_.name = LocalizationManager.translateIdOnly(_loc2_.titleStrRef);
         }
         gMainFrame.userInfo.denRoomDefs = _loc1_;
      }
      
      private static function denStateResponse(param1:Object) : void
      {
         var _loc29_:int = 0;
         var _loc23_:int = 0;
         var _loc9_:Boolean = false;
         var _loc27_:int = 0;
         var _loc28_:int = 0;
         var _loc20_:int = 0;
         var _loc2_:int = 0;
         var _loc18_:String = null;
         var _loc30_:String = null;
         var _loc16_:String = null;
         var _loc25_:int = 0;
         var _loc24_:* = 0;
         var _loc5_:int = 0;
         var _loc17_:int = 0;
         var _loc14_:Object = null;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc12_:int = 0;
         var _loc4_:PetDef = null;
         var _loc8_:Boolean = false;
         var _loc26_:int = 0;
         var _loc11_:Object = null;
         var _loc22_:Object = null;
         var _loc15_:int = 2;
         var _loc21_:int = int(param1[_loc15_++]);
         var _loc10_:int = int(param1[_loc15_++]);
         var _loc19_:Boolean = param1[_loc15_++] == "1";
         var _loc7_:Array = [];
         DebugUtility.debugTrace("gettind den state with numItems=" + _loc21_ + "forceReload=" + _loc19_);
         var _loc13_:Array = [];
         _loc17_ = 0;
         while(_loc17_ < _loc21_)
         {
            _loc29_ = int(param1[_loc15_++]);
            _loc23_ = int(param1[_loc15_++]);
            _loc14_ = getDenItemDef(_loc23_);
            if(!_loc14_)
            {
               _loc7_[_loc17_] = {
                  "i":_loc29_,
                  "x":0,
                  "y":0,
                  "r":0,
                  "c":0,
                  "userNameLink":"",
                  "uniqueImageCreator":""
               };
            }
            else
            {
               _loc9_ = param1[_loc15_++] == "1";
               _loc27_ = int(param1[_loc15_++]);
               _loc28_ = int(param1[_loc15_++]);
               _loc20_ = int(param1[_loc15_++]);
               _loc2_ = int(param1[_loc15_++]);
               _loc18_ = param1[_loc15_] == "null" ? "" : param1[_loc15_];
               _loc15_++;
               _loc30_ = param1[_loc15_++];
               _loc16_ = param1[_loc15_++];
               _loc25_ = int(_loc14_.sortCat);
               if(_loc9_)
               {
                  if(_loc25_ == 0 || _loc25_ == 99 || _loc25_ == 6 || _loc25_ == 5)
                  {
                     _loc25_ = 1;
                  }
                  else if(_loc25_ == 1)
                  {
                     _loc25_ = 2;
                  }
                  else if(_loc25_ == 4)
                  {
                     _loc25_ = 3;
                  }
                  else if(_loc25_ == 2 || _loc25_ == 3)
                  {
                     _loc25_ = _roomMgr.denCatId;
                  }
                  else
                  {
                     _loc25_ = -1;
                  }
               }
               else
               {
                  _loc25_ = -1;
               }
               _loc24_ = uint(_loc23_ << 16 | _loc25_);
               _loc5_ = int(_loc14_.gameDefId);
               if(_loc5_ > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc5_))
               {
                  _loc13_.push(_loc5_);
               }
               _loc7_[_loc17_] = {
                  "i":_loc29_,
                  "p":_loc24_,
                  "x":_loc27_,
                  "y":_loc28_,
                  "v":_loc20_,
                  "f":_loc2_,
                  "c":_loc25_,
                  "r":0,
                  "s":_loc14_.sortCat,
                  "mg":_loc14_.gameDefId,
                  "l":_loc14_.layer,
                  "v2":_loc14_.flag,
                  "v3":0,
                  "zone":_loc14_.enviroType,
                  "strmName":_loc14_.abbrName,
                  "defId":_loc23_,
                  "userNameLink":_loc18_,
                  "specialType":_loc14_.specialType,
                  "listLauncherId":_loc14_.listId,
                  "nameStrId":_loc14_.nameStrId,
                  "uniqueImageId":_loc30_,
                  "uniqueImageCreator":_loc16_
               };
            }
            _loc17_++;
         }
         _loc17_ = 0;
         while(_loc17_ < _loc10_)
         {
            _loc29_ = int(param1[_loc15_++]);
            _loc3_ = int(param1[_loc15_++]);
            _loc6_ = int(param1[_loc15_++]);
            _loc12_ = int(param1[_loc15_++]);
            _loc23_ = PetManager.getDefIdFromLBits(_loc3_);
            _loc4_ = PetManager.getPetDef(_loc23_);
            if(PetDef)
            {
               _loc25_ = int(param1[_loc15_++]);
               _loc27_ = int(param1[_loc15_++]);
               _loc28_ = int(param1[_loc15_++]);
               _loc2_ = int(param1[_loc15_++]);
               _loc23_ = denItemDefIdForPetDefId(_loc23_);
               _loc24_ = uint(_loc23_ << 16 | _loc25_);
               _loc7_[_loc21_ + _loc17_] = {
                  "i":_loc29_,
                  "p":_loc24_,
                  "x":_loc27_,
                  "y":_loc28_,
                  "v":_loc3_,
                  "v2":_loc6_,
                  "v3":_loc12_,
                  "f":_loc2_,
                  "c":_loc25_,
                  "r":1,
                  "s":99,
                  "strmName":"",
                  "l":0,
                  "zone":PetManager.getEnviroTypeByPetType(_loc4_.type),
                  "mg":0,
                  "defId":_loc23_,
                  "userNameLink":"",
                  "listLauncherId":0,
                  "nameStrId":_loc4_.titleStrId
               };
            }
            _loc17_++;
         }
         if(_loc13_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc13_);
         }
         if(_pendingDenChangeItems && _pendingDenChangeItems.length > 0)
         {
            _loc26_ = int(_pendingDenChangeItems.length);
            _loc15_ = 0;
            while(_loc15_ < _loc7_.length)
            {
               _loc8_ = false;
               _loc17_ = 0;
               while(_loc17_ < _loc26_)
               {
                  if(_loc7_[_loc15_].r == _pendingDenChangeItems[_loc17_].r && _loc7_[_loc15_].i == _pendingDenChangeItems[_loc17_].i)
                  {
                     _loc8_ = true;
                     _loc22_ = _pendingDenChangeItems[_loc17_];
                     _loc11_ = _loc7_[_loc15_];
                     _loc22_.x = _loc11_.x;
                     _loc22_.y = _loc11_.y;
                     _loc22_.v = _loc11_.v;
                     _loc22_.v2 = _loc11_.v2;
                     _loc22_.f = _loc11_.f;
                     _loc22_.c = _loc11_.c;
                     _loc22_.userNameLink = _loc11_.userNameLink;
                     _loc22_.uniqueImageId = _loc11_.uniqueImageId;
                     _loc22_.uniqueImageCreator = _loc11_.uniqueImageCreator;
                     break;
                  }
                  _loc17_++;
               }
               if(!_loc8_)
               {
                  _pendingDenChangeItems.push(_loc7_[_loc15_]);
               }
               _loc15_++;
            }
         }
         else
         {
            _pendingDenChangeItems = _loc7_;
         }
         if(!_denChangePending || _loc19_)
         {
            setDenItems();
         }
         if(_loc19_)
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
         BuddyManager.onDenPrivacyResponse(param1[2],param1[3] == "1");
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
         var _loc3_:Object = gMainFrame.userInfo.getDenRoomDefByDefId(_loc2_);
         var _loc4_:Object = _loc3_ != null ? RoomXtCommManager.getRoomDef(_loc3_.roomDefId) : null;
         if(_denChangeCallback != null)
         {
            _denChangeCallback(_loc4_ != null && _loc3_ != null);
            _denChangeCallback = null;
         }
         if(_loc4_ && _loc3_)
         {
            _roomMgr.loadRoom(_loc4_.pathName,_loc3_.enviroType,2,_loc3_.defId,100);
         }
      }
      
      public static function handleDenShopList(param1:Array, param2:int, param3:Function) : IitemCollection
      {
         var _loc8_:IitemCollection = null;
         var _loc6_:int = 0;
         var _loc7_:DenRoomItem = null;
         var _loc10_:Object = null;
         var _loc4_:int = 6;
         var _loc5_:String = param1[4];
         var _loc9_:int = int(param1[_loc4_++]);
         if(param2 == 1030)
         {
            _loc8_ = generateDenShopList(_loc9_,param1.splice(_loc4_++,param1.length));
         }
         else
         {
            _loc8_ = new IitemCollection();
            _loc6_ = 0;
            while(_loc6_ < _loc9_)
            {
               _loc7_ = new DenRoomItem();
               _loc10_ = gMainFrame.userInfo.getDenRoomDefByDefId(param1[_loc4_++]);
               _loc7_.initShopItem(_loc6_,_loc10_.defId,_loc10_);
               _loc8_.setIitem(_loc6_,_loc7_);
               _loc6_++;
            }
         }
         if(param3 != null)
         {
            param3(_loc8_,_loc5_);
         }
         return _loc8_;
      }
      
      public static function generateDenShopList(param1:int, param2:Object) : IitemCollection
      {
         var _loc4_:int = 0;
         var _loc3_:DenItem = null;
         var _loc5_:IitemCollection = new IitemCollection();
         _loc4_ = 0;
         while(_loc4_ < param1)
         {
            _loc3_ = new DenItem();
            _loc3_.initShopItem(int(param2[_loc4_]),-1);
            _loc5_.pushIitem(_loc3_);
            _loc4_++;
         }
         return _loc5_;
      }
      
      public static function setDenItems() : void
      {
         if(_roomMgr)
         {
            if(_pendingDenChangeItems)
            {
               DebugUtility.debugTrace("setting den items");
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
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         if(!_pendingDenChangeItems || _pendingDenChangeItems.length <= 0)
         {
            return;
         }
         _loc1_ = 0;
         while(_loc1_ < _pendingDenChangeItems.length)
         {
            _loc2_ = _pendingDenChangeItems[_loc1_];
            if(_loc2_.s == 2 || _loc2_.s == 3)
            {
               _loc2_.c = _roomMgr.denCatId;
               _loc2_.p = uint(_loc2_.defId << 16 | _loc2_.c);
            }
            _loc1_++;
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
         var _loc4_:Object = null;
         var _loc3_:Object = {};
         for each(var _loc2_:Object in param1.def)
         {
            _loc4_ = {
               "abbrName":_loc2_.abbrName,
               "cost":int(_loc2_.cost),
               "currencyType":int(_loc2_.currencyType),
               "enviroType":int(_loc2_.enviroType),
               "fileType":int(_loc2_.fileType),
               "flag":int(_loc2_.flag),
               "gameDefId":int(_loc2_.gameDefId),
               "id":int(_loc2_.id),
               "itemStatus":int(_loc2_.itemStatus),
               "layer":int(_loc2_.layer),
               "membersOnly":int(_loc2_.membersOnly),
               "name":LocalizationManager.translateIdOnly(int(_loc2_.nameStrId)),
               "nameStrId":int(_loc2_.nameStrId),
               "recycleValue":int(_loc2_.recycleValue),
               "scalePercent":int(_loc2_.scalePercent),
               "sortCat":int(_loc2_.sortCat),
               "typeCat":int(_loc2_.typeCat),
               "specialType":int(_loc2_.specialType),
               "combinedCurrencyString":_loc2_.combinedCost,
               "listId":int(_loc2_.parentArrayId),
               "isMasterpiece":int(_loc2_.id) == 2725
            };
            _loc3_[_loc4_.id] = _loc4_;
         }
         _denItemDefs = _loc3_;
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
      
      private static function enviroItems(param1:DenItemCollection) : DenItemCollection
      {
         var _loc3_:DenItemCollection = new DenItemCollection();
         for each(var _loc2_:DenItem in param1.getCoreArray())
         {
            if(_loc2_.enviroType == AvatarManager.roomEnviroType)
            {
               _loc3_.pushDenItem(_loc2_);
            }
         }
         return _loc3_;
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
            case 46:
               return 2589;
            case 47:
               return 2588;
            case 48:
               return 2587;
            case 49:
               return 2591;
            case 50:
               return 2590;
            case 51:
               return 2592;
            case 52:
               return 2622;
            case 53:
               return 2656;
            case 54:
               return 2715;
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

