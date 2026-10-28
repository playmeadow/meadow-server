package den
{
   import avatar.AvatarManager;
   import collection.DenItemCollection;
   import collection.DenRoomItemCollection;
   import collection.DenStateItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import collection.PetItemCollection;
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
   import pet.PetItem;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class DenXtCommManager
   {
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _denChangePending:Boolean;
      
      private static var _pendingDenChangeItems:DenStateItemCollection;
      
      private static var _itemBuyCallback:Function;
      
      private static var _denEditorDIResponseCallback:Function;
      
      private static var _denItemsCallback:Function;
      
      private static var _denMasterpieceItemsCallback:Function;
      
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
      
      public static function requestDenMasterpieceItems(param1:String, param2:Function) : void
      {
         _denMasterpieceItemsCallback = param2;
         gMainFrame.server.setXtObject_Str("dmi",[param1]);
      }
      
      public static function requestDenRoomList() : void
      {
         gMainFrame.server.setXtObject_Str("dl",[]);
      }
      
      public static function requestBuy(param1:Boolean, param2:int, param3:int, param4:Function, param5:Function, param6:int = 0, param7:Function = null, param8:int = 0, param9:int = 0, param10:Boolean = false, param11:Boolean = false) : void
      {
         _itemBuyCallback = param4;
         _denEditorDIResponseCallback = param5;
         if(param1)
         {
            gMainFrame.server.setXtObject_Str("db",["0",param2,param3,param8,GenericListXtCommManager.getAvailListUniqueId(),param9,param10 ? "1" : "0",param11 ? "1" : "0"]);
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
         var _loc5_:String = null;
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
                  DarkenManager.showLoadingSpiral(false);
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
            _loc5_ = param4 ? "1" : "0";
            gMainFrame.server.setXtObject_Str("dj",[param1,_loc5_,param2]);
            if(param3 || _roomMgr.forceInvisMode)
            {
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
            case "dmi":
               denMasterpieceInventoryResponse(_loc2_);
               break;
            default:
               throw new Error("Did not expect ext cmd=" + _loc2_[0]);
         }
      }
      
      public static function denItemsResponse(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc11_:int = 0;
         var _loc20_:int = 0;
         var _loc25_:int = 0;
         var _loc24_:int = 0;
         var _loc19_:int = 0;
         var _loc8_:int = 0;
         var _loc31_:Boolean = false;
         var _loc14_:Boolean = false;
         var _loc28_:* = null;
         var _loc13_:int = 0;
         var _loc2_:int = 0;
         var _loc23_:int = 0;
         var _loc18_:String = null;
         var _loc16_:String = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc26_:int = 0;
         var _loc12_:DenItem = null;
         var _loc17_:Object = null;
         var _loc32_:PetItem = null;
         var _loc22_:int = 2;
         DenSwitch.activeDenIdx = int(param1[_loc22_++]);
         var _loc30_:int = int(param1[_loc22_++]);
         var _loc3_:int = int(param1[_loc22_++]);
         var _loc27_:DenItemCollection = new DenItemCollection();
         var _loc7_:Array = [];
         var _loc15_:Boolean = true;
         _loc26_ = 0;
         while(_loc26_ < _loc30_)
         {
            _loc12_ = new DenItem();
            _loc6_ = int(param1[_loc22_++]);
            _loc11_ = int(param1[_loc22_++]);
            _loc20_ = int(param1[_loc22_++]);
            _loc8_ = int(param1[_loc22_++]);
            _loc31_ = param1[_loc22_++] == "true";
            _loc18_ = param1[_loc22_++];
            _loc16_ = param1[_loc22_++];
            _loc9_ = int(param1[_loc22_++]);
            _loc10_ = param1[_loc22_++];
            _loc17_ = getDenItemDef(_loc11_);
            if(_loc17_)
            {
               if(_loc17_.sortCat == 4 && _loc20_ > 0)
               {
                  _loc15_ = false;
               }
               _loc12_.init(_loc11_,_loc6_,_loc20_,_loc8_,0,null,0,_loc31_,_loc18_,_loc16_,_loc9_,_loc10_);
               _loc27_.setDenItem(_loc26_,_loc12_);
               if(_loc12_.minigameDefId > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc12_.minigameDefId))
               {
                  _loc7_.push(_loc12_.minigameDefId);
               }
            }
            _loc26_++;
         }
         _loc27_.getCoreArray().sortOn("invIdx",0x10 | 2);
         _loc12_ = new DenItem();
         _loc12_.init(617,-1,_loc15_ ? 7 : 0);
         _loc27_.getCoreArray().unshift(_loc12_);
         var _loc4_:PetItemCollection = PetManager.myPetListAsIitem;
         var _loc5_:DenItemCollection = new DenItemCollection();
         var _loc29_:DenItemCollection = new DenItemCollection();
         _loc26_ = 0;
         while(_loc26_ < _loc4_.length)
         {
            _loc32_ = _loc4_.getPetItem(_loc26_);
            _loc12_ = new DenItem();
            _loc12_.init(_loc32_.defId,_loc32_.invIdx,0,0,1,_loc32_);
            if(PetManager.canPetGoInBothEnviroTypes(_loc12_.petType))
            {
               _loc5_.pushDenItem(_loc12_);
               _loc29_.pushDenItem(_loc12_);
            }
            else if(_loc12_.enviroType == 2 || _loc12_.enviroType == 0)
            {
               _loc5_.pushDenItem(_loc12_);
            }
            else
            {
               _loc29_.pushDenItem(_loc12_);
            }
            _loc26_++;
         }
         _loc5_.getCoreArray().sortOn("invIdx",0x10 | 2);
         _loc29_.getCoreArray().sortOn("invIdx",0x10 | 2);
         var _loc21_:int = 0;
         while(_loc21_ < _loc3_)
         {
            _loc6_ = int(param1[_loc22_ + _loc21_]);
            _loc26_ = 0;
            while(_loc26_ < _loc5_.length)
            {
               if(_loc5_.getDenItem(_loc26_).invIdx == _loc6_)
               {
                  _loc5_.getDenItem(_loc26_).categoryId = 1;
                  break;
               }
               _loc26_++;
            }
            _loc26_ = 0;
            while(_loc26_ < _loc29_.length)
            {
               if(_loc29_.getDenItem(_loc26_).invIdx == _loc6_)
               {
                  _loc29_.getDenItem(_loc26_).categoryId = 1;
                  break;
               }
               _loc26_++;
            }
            _loc21_++;
         }
         if(_loc7_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc7_);
         }
         gMainFrame.userInfo.playerUserInfo.denItemsPartial = enviroItems(_loc27_);
         if(AvatarManager.playerAvatar != null)
         {
            AvatarManager.playerAvatar.inventoryDenPartial.denItemCollection = gMainFrame.userInfo.playerUserInfo.denItemsPartial;
            AvatarManager.playerAvatar.inventoryDenFull.denItemCollection = _loc27_;
         }
         gMainFrame.userInfo.playerUserInfo.denItemsFull = _loc27_;
         gMainFrame.userInfo.setMyPetsInDenByEnviroType(_loc5_,0);
         gMainFrame.userInfo.setMyPetsInDenByEnviroType(_loc29_,1);
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
      
      public static function addPetToDen(param1:PetItem) : void
      {
         var _loc2_:DenItem = new DenItem();
         _loc2_.init(param1.defId,param1.invIdx,0,0,1,param1);
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
      
      public static function reloadPetInDen(param1:int, param2:Number, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int) : void
      {
         if(PetManager.canPetGoInBothEnviroTypes(param3))
         {
            updatePetInDenByEnviroType(param1,param2,0,param4,param5,param6,param7,param8,param9);
            updatePetInDenByEnviroType(param1,param2,1,param4,param5,param6,param7,param8,param9);
         }
         else
         {
            updatePetInDenByEnviroType(param1,param2,PetManager.getEnviroTypeByPetType(param3),param4,param5,param6,param7,param8,param9);
         }
         GuiManager.resetPetWindowListAndUpdateBtns();
      }
      
      private static function updatePetInDenByEnviroType(param1:int, param2:Number, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int) : void
      {
         var _loc11_:int = 0;
         var _loc10_:DenItem = null;
         var _loc12_:DenItemCollection = gMainFrame.userInfo.getMyPetsInDenByEnviroType(param3);
         if(!_loc12_)
         {
            return;
         }
         _loc11_ = 0;
         while(_loc11_ < _loc12_.length)
         {
            _loc10_ = _loc12_.getDenItem(_loc11_);
            if(_loc10_.invIdx == param1)
            {
               _loc10_.version = param4;
               _loc10_.version2 = param5;
               _loc10_.version3 = param6;
               _loc10_.petTraitDefId = param7;
               _loc10_.petFoodDefId = param8;
               _loc10_.petToyDefId = param9;
               _loc10_.createdTs = param2;
               break;
            }
            _loc11_++;
         }
      }
      
      public static function set denEditorDIResponseCallback(param1:Function) : void
      {
         _denEditorDIResponseCallback = param1;
      }
      
      private static function denBuyResponse(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc4_:int = int(param1[2]);
         var _loc6_:int = int(param1[5]);
         var _loc3_:int = int(param1[4]);
         var _loc5_:int = int(param1[6]);
         if(param1[3] == "")
         {
            _loc2_ = UserCurrency.getCurrency(_loc6_);
            if(_loc2_ == null)
            {
               throw new Error("DenXtCommManager: Received unknown currencyType: " + _loc6_);
            }
         }
         else
         {
            _loc2_ = param1[3];
         }
         if(_loc4_ == 1)
         {
            if(!UserCurrency.setCurrency(_loc2_,_loc6_))
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc6_);
            }
         }
         if(_itemBuyCallback != null)
         {
            _itemBuyCallback(_loc4_,_loc2_,_loc5_);
            _itemBuyCallback = null;
         }
      }
      
      private static function denRecycleResponse(param1:Object) : void
      {
         var _loc3_:Boolean = int(param1[2]) > 0;
         var _loc2_:int = UserCurrency.getCurrency(0) as int;
         var _loc4_:* = param1[3] == "" ? _loc2_ : param1[3];
         if(_loc3_)
         {
            UserCurrency.setCurrency(_loc4_,0);
         }
         if(_denRecycleCallback != null)
         {
            _denRecycleCallback(int(param1[2]));
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
         var _loc6_:DenRoomItemCollection = null;
         var _loc9_:int = 0;
         var _loc2_:DenRoomItem = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:Object = null;
         if(gMainFrame.userInfo.denRoomDefs)
         {
            _loc7_ = 2;
            _loc3_ = int(param1[_loc7_++]);
            _loc6_ = new DenRoomItemCollection();
            _loc9_ = 0;
            while(_loc9_ < _loc3_)
            {
               _loc2_ = new DenRoomItem();
               _loc5_ = int(param1[_loc7_++]);
               _loc4_ = int(param1[_loc7_++]);
               _loc8_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc4_);
               if(_loc8_)
               {
                  _loc2_.init(_loc5_,_loc4_,_loc8_);
                  _loc6_.setDenRoomItem(_loc5_,_loc2_);
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
         var _loc6_:int = 0;
         var _loc12_:int = 0;
         var _loc14_:Boolean = false;
         var _loc37_:int = 0;
         var _loc35_:int = 0;
         var _loc8_:int = 0;
         var _loc32_:int = 0;
         var _loc16_:String = null;
         var _loc19_:String = null;
         var _loc17_:String = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc33_:int = 0;
         var _loc20_:* = 0;
         var _loc21_:int = 0;
         var _loc25_:int = 0;
         var _loc18_:Object = null;
         var _loc2_:int = 0;
         var _loc23_:int = 0;
         var _loc22_:int = 0;
         var _loc4_:Number = NaN;
         var _loc29_:int = 0;
         var _loc26_:int = 0;
         var _loc3_:int = 0;
         var _loc34_:PetItem = null;
         var _loc31_:PetDef = null;
         var _loc36_:Boolean = false;
         var _loc30_:int = 0;
         var _loc13_:DenStateItem = null;
         var _loc28_:DenStateItem = null;
         var _loc24_:int = 2;
         var _loc27_:int = int(param1[_loc24_++]);
         var _loc15_:int = int(param1[_loc24_++]);
         var _loc9_:Boolean = param1[_loc24_++] == "1";
         var _loc5_:DenStateItemCollection = new DenStateItemCollection();
         DebugUtility.debugTrace("gettind den state with numItems=" + _loc27_ + "forceReload=" + _loc9_);
         var _loc7_:Array = [];
         _loc25_ = 0;
         while(_loc25_ < _loc27_)
         {
            _loc6_ = int(param1[_loc24_++]);
            _loc12_ = int(param1[_loc24_++]);
            _loc18_ = getDenItemDef(_loc12_);
            if(!_loc18_)
            {
               _loc5_.setDenStateItem(_loc25_,new DenStateItem(0,_loc6_,0,0,0,0,0,0,0,0,0,0,0,0,0,"",0,"",0,0,"","",-1,"",false,null,0,0,null));
            }
            else
            {
               _loc14_ = param1[_loc24_++] == "1";
               _loc37_ = int(param1[_loc24_++]);
               _loc35_ = int(param1[_loc24_++]);
               _loc8_ = int(param1[_loc24_++]);
               _loc32_ = int(param1[_loc24_++]);
               _loc16_ = param1[_loc24_] == "null" ? "" : param1[_loc24_];
               _loc24_++;
               _loc19_ = param1[_loc24_++];
               _loc17_ = param1[_loc24_++];
               _loc10_ = int(param1[_loc24_++]);
               _loc11_ = param1[_loc24_++];
               _loc33_ = int(_loc18_.sortCat);
               if(_loc14_)
               {
                  if(_loc33_ == 0 || _loc33_ == 99 || _loc33_ == 6 || _loc33_ == 5)
                  {
                     _loc33_ = 1;
                  }
                  else if(_loc33_ == 1)
                  {
                     _loc33_ = 2;
                  }
                  else if(_loc33_ == 4)
                  {
                     _loc33_ = 3;
                  }
                  else if(_loc33_ == 2 || _loc33_ == 3)
                  {
                     _loc33_ = _roomMgr.denCatId;
                  }
                  else
                  {
                     _loc33_ = -1;
                  }
               }
               else
               {
                  _loc33_ = -1;
               }
               _loc20_ = uint(_loc12_ << 16 | _loc33_);
               _loc21_ = int(_loc18_.gameDefId);
               if(_loc21_ > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc21_))
               {
                  _loc7_.push(_loc21_);
               }
               _loc5_.setDenStateItem(_loc25_,new DenStateItem(_loc12_,_loc6_,_loc20_,_loc37_,_loc35_,_loc8_,_loc18_.flag,0,_loc32_,_loc33_,0,_loc18_.sortCat,_loc18_.gameDefId,_loc18_.layer,_loc18_.enviroType,_loc18_.abbrName,_loc18_.nameStrId,_loc16_,_loc18_.specialType,_loc18_.listId,_loc19_,_loc17_,_loc10_,_loc11_,false,null,0,0,null));
            }
            _loc25_++;
         }
         _loc25_ = 0;
         while(_loc25_ < _loc15_)
         {
            _loc6_ = int(param1[_loc24_++]);
            _loc2_ = int(param1[_loc24_++]);
            _loc23_ = int(param1[_loc24_++]);
            _loc22_ = int(param1[_loc24_++]);
            _loc12_ = PetManager.getDefIdFromLBits(_loc2_);
            _loc31_ = PetManager.getPetDef(_loc12_);
            if(PetDef)
            {
               _loc33_ = int(param1[_loc24_++]);
               _loc37_ = int(param1[_loc24_++]);
               _loc35_ = int(param1[_loc24_++]);
               _loc32_ = int(param1[_loc24_++]);
               _loc4_ = Number(param1[_loc24_++]);
               _loc29_ = int(param1[_loc24_++]);
               _loc26_ = int(param1[_loc24_++]);
               _loc3_ = int(param1[_loc24_++]);
               _loc12_ = denItemDefIdForPetDefId(_loc12_);
               _loc20_ = uint(_loc12_ << 16 | _loc33_);
               _loc34_ = new PetItem();
               _loc34_.init(_loc4_,_loc31_.defId,[_loc2_,_loc23_,_loc22_],_loc29_,_loc26_,_loc3_,_loc6_);
               _loc5_.setDenStateItem(_loc27_ + _loc25_,new DenStateItem(_loc12_,_loc6_,_loc20_,_loc37_,_loc35_,_loc2_,_loc23_,_loc22_,_loc32_,_loc33_,1,99,0,0,PetManager.getEnviroTypeByPetType(_loc31_.type),"",_loc31_.titleStrId,"",0,0,"","",-1,"",false,null,0,0,_loc34_));
            }
            _loc25_++;
         }
         if(_loc7_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc7_);
         }
         if(_pendingDenChangeItems && _pendingDenChangeItems.length > 0)
         {
            _loc30_ = int(_pendingDenChangeItems.length);
            _loc24_ = 0;
            while(_loc24_ < _loc5_.getCoreArray().length)
            {
               _loc36_ = false;
               _loc25_ = 0;
               while(_loc25_ < _loc30_)
               {
                  if(_loc5_.getDenStateItem(_loc24_).refId == _pendingDenChangeItems.getDenStateItem(_loc25_).refId && _loc5_.getDenStateItem(_loc24_).invIdx == _pendingDenChangeItems.getDenStateItem(_loc25_).invIdx)
                  {
                     _loc36_ = true;
                     _loc28_ = _pendingDenChangeItems.getDenStateItem(_loc25_);
                     _loc13_ = _loc5_.getDenStateItem(_loc24_);
                     _loc28_.x = _loc13_.x;
                     _loc28_.y = _loc13_.y;
                     _loc28_.version = _loc13_.version;
                     _loc28_.version2 = _loc13_.version2;
                     _loc28_.flipped = _loc13_.flipped;
                     _loc28_.catId = _loc13_.catId;
                     _loc28_.userNameLink = _loc13_.userNameLink;
                     _loc28_.uniqueImageId = _loc13_.uniqueImageId;
                     _loc28_.uniqueImageCreator = _loc13_.uniqueImageCreator;
                     break;
                  }
                  _loc25_++;
               }
               if(!_loc36_)
               {
                  _pendingDenChangeItems.pushDenStateItem(_loc5_.getDenStateItem(_loc24_));
               }
               _loc24_++;
            }
         }
         else
         {
            _pendingDenChangeItems = _loc5_;
         }
         if(!_denChangePending || _loc9_)
         {
            setDenItems();
         }
         if(_loc9_)
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
         var _loc4_:Object = gMainFrame.userInfo.getDenRoomDefByDefId(_loc2_);
         var _loc3_:Object = _loc4_ != null ? RoomXtCommManager.getRoomDef(_loc4_.roomDefId) : null;
         if(_denChangeCallback != null)
         {
            _denChangeCallback(_loc3_ != null && _loc4_ != null);
            _denChangeCallback = null;
         }
         if(_loc3_ && _loc4_)
         {
            _roomMgr.loadRoom(_loc3_.pathName,_loc4_.enviroType,2,_loc4_.defId,100,_loc4_.roomDefId,null);
         }
      }
      
      private static function denMasterpieceInventoryResponse(param1:Object) : void
      {
         var _loc3_:DenItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = int(param1[2]);
         var _loc2_:DenItemCollection = new DenItemCollection();
         var _loc4_:int = 3;
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            _loc3_ = new DenItem();
            _loc3_.init(param1[_loc4_++],param1[_loc4_++],0,param1[_loc4_++],0,null,0,param1[_loc4_++],param1[_loc4_++],param1[_loc4_++],param1[_loc4_++],param1[_loc4_++]);
            _loc2_.pushDenItem(_loc3_);
            _loc5_++;
         }
         if(_denMasterpieceItemsCallback != null)
         {
            _denMasterpieceItemsCallback(_loc2_);
            _denMasterpieceItemsCallback = null;
         }
      }
      
      public static function handleDenShopList(param1:Array, param2:int, param3:Function) : IitemCollection
      {
         var _loc7_:IitemCollection = null;
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
            _loc7_ = new IitemCollection();
            _loc8_ = 0;
            while(_loc8_ < _loc9_)
            {
               _loc4_ = new DenRoomItem();
               _loc6_ = gMainFrame.userInfo.getDenRoomDefByDefId(param1[_loc10_++]);
               _loc4_.initShopItem(_loc8_,_loc6_.defId,_loc6_);
               _loc7_.setIitem(_loc8_,_loc4_);
               _loc8_++;
            }
         }
         if(param3 != null)
         {
            param3(_loc7_,_loc5_);
         }
         return _loc7_;
      }
      
      public static function generateDenShopList(param1:int, param2:Object) : IitemCollection
      {
         var _loc5_:int = 0;
         var _loc3_:DenItem = null;
         var _loc4_:IitemCollection = new IitemCollection();
         _loc5_ = 0;
         while(_loc5_ < param1)
         {
            _loc3_ = new DenItem();
            _loc3_.initShopItem(int(param2[_loc5_]),-1);
            _loc4_.pushIitem(_loc3_);
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
         var _loc1_:DenStateItem = null;
         var _loc2_:int = 0;
         if(!_pendingDenChangeItems || _pendingDenChangeItems.length <= 0)
         {
            return;
         }
         _loc2_ = 0;
         while(_loc2_ < _pendingDenChangeItems.length)
         {
            _loc1_ = _pendingDenChangeItems.getDenStateItem(_loc2_);
            if(_loc1_.sortCatId == 2 || _loc1_.sortCatId == 3)
            {
               _loc1_.catId = _roomMgr.denCatId;
               _loc1_.packedId = uint(_loc1_.defId << 16 | _loc1_.catId);
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
         _denItemDefs = {};
         for each(var _loc2_:Object in param1.def)
         {
            _denItemDefs[int(_loc2_.id)] = {
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
         }
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
         var _loc2_:DenItemCollection = new DenItemCollection();
         for each(var _loc3_:DenItem in param1.getCoreArray())
         {
            if(_loc3_.enviroType == AvatarManager.roomEnviroType)
            {
               _loc2_.pushDenItem(_loc3_);
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
            case 55:
               return 2775;
            case 56:
               return 2844;
            case 57:
               return 2861;
            case 58:
               return 2876;
            case 59:
               return 2877;
            case 60:
               return 2878;
            case 61:
               return 2884;
            case 62:
               return 2894;
            case 63:
               return 2977;
            case 41:
               return 2989;
            case 64:
               return 3039;
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

