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
      
      public static function init(param1:Function) : void
      {
         _roomMgr = RoomManagerWorld.instance;
         _denListCallback = param1;
         _denChangePending = false;
         _pendingDenChangeItems = null;
         var _loc2_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc2_.init(DefPacksDefHelper.DEF_DEN_ITEM,denItemDefsResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ITEM] = _loc2_;
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
         var _loc2_:Array = [];
         var _loc3_:* = 0;
         var _loc5_:Number;
         _loc2_[_loc5_ = _loc3_++] = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            var _loc6_:Number;
            _loc2_[_loc6_ = _loc3_++] = param1[_loc4_].r;
            var _loc7_:Number;
            _loc2_[_loc7_ = _loc3_++] = param1[_loc4_].i;
            var _loc8_:Number;
            _loc2_[_loc8_ = _loc3_++] = param1[_loc4_].d;
            var _loc9_:Number;
            _loc2_[_loc9_ = _loc3_++] = param1[_loc4_].x;
            var _loc10_:Number;
            _loc2_[_loc10_ = _loc3_++] = param1[_loc4_].y;
            var _loc11_:Number;
            _loc2_[_loc11_ = _loc3_++] = param1[_loc4_].f ? param1[_loc4_].f : 0;
            var _loc12_:Number;
            _loc2_[_loc12_ = _loc3_++] = param1[_loc4_].userNameLink == "" ? "off" : param1[_loc4_].userNameLink;
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
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Boolean = false;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:DenItem = null;
         var _loc24_:Object = null;
         var _loc2_:* = 2;
         DenSwitch.activeDenIdx = int(param1[_loc2_++]);
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:Array = new Array(_loc3_);
         var _loc18_:Array = [];
         var _loc19_:Boolean = true;
         _loc20_ = 0;
         while(_loc20_ < _loc3_)
         {
            _loc21_ = new DenItem();
            _loc6_ = int(param1[_loc2_++]);
            _loc7_ = int(param1[_loc2_++]);
            _loc8_ = int(param1[_loc2_++]);
            _loc12_ = int(param1[_loc2_++]);
            if(getDenItemDef(_loc7_).sortCat == DenItem.SORT_AUDIO && _loc8_ > 0)
            {
               _loc19_ = false;
            }
            _loc21_.init(_loc7_,_loc6_,_loc8_,_loc12_);
            _loc5_[_loc20_] = _loc21_;
            if(_loc21_.minigameDefId > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc21_.minigameDefId))
            {
               _loc18_.push(_loc21_.minigameDefId);
            }
            _loc20_++;
         }
         _loc5_.sortOn("invIdx",Array.NUMERIC | Array.DESCENDING);
         _loc21_ = new DenItem();
         _loc21_.init(DenItem.DEF_AUDIO_DEF_ID,DenItem.DEF_AUDIO_INVIDX,_loc19_ ? 7 : 0);
         _loc5_.unshift(_loc21_);
         var _loc22_:Array = PetManager.myPetList;
         var _loc23_:Array = new Array(_loc22_.length);
         _loc20_ = 0;
         while(_loc20_ < _loc22_.length)
         {
            _loc24_ = _loc22_[_loc20_];
            _loc21_ = new DenItem();
            _loc21_.init(_loc24_.defId,_loc24_.idx,0,_loc24_.lBits,DenItem.REF_ID_PET_ITEM,_loc24_.uBits,_loc24_.eBits);
            _loc23_[_loc20_] = _loc21_;
            _loc20_++;
         }
         _loc23_.sortOn("invIdx",Array.NUMERIC | Array.DESCENDING);
         var _loc25_:int = 0;
         while(_loc25_ < _loc4_)
         {
            _loc6_ = int(param1[_loc2_ + _loc25_]);
            _loc20_ = 0;
            while(_loc20_ < _loc23_.length)
            {
               if(_loc23_[_loc20_].invIdx == _loc6_)
               {
                  _loc23_[_loc20_].categoryId = DenItem.PLACE_CAT_FLOOR;
                  break;
               }
               _loc20_++;
            }
            _loc25_++;
         }
         if(_loc18_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc18_);
         }
         if(AvatarManager.playerAvatar != null)
         {
            AvatarManager.playerAvatar.inventoryDenPartial.itemArray = gMainFrame.userInfo.playerUserInfo.denItemsPartial = enviroItems(_loc5_);
            AvatarManager.playerAvatar.inventoryDenFull.itemArray = _loc5_;
         }
         gMainFrame.userInfo.playerUserInfo.denItemsFull = _loc5_;
         gMainFrame.userInfo.myPetsInDen = _loc23_;
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
         _loc2_.init(param1.defId,param1.idx,0,param1.lBits,DenItem.REF_ID_PET_ITEM,param1.uBits,param1.eBits);
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
         var _loc2_:Array = gMainFrame.userInfo.myPetsInDen;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_].invIdx == param1)
            {
               _loc2_.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
         GuiManager.onPetsChanged();
      }
      
      public static function reloadPetInDen(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc7_:DenItem = null;
         var _loc5_:Array = gMainFrame.userInfo.myPetsInDen;
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.length)
         {
            _loc7_ = _loc5_[_loc6_];
            if(_loc7_.invIdx == param1)
            {
               _loc7_.version = param2;
               _loc7_.version2 = param3;
               _loc7_.version3 = param4;
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
         var _loc4_:int = 0;
         var _loc2_:int = int(param1[2]);
         var _loc3_:int = int(param1[5]);
         var _loc5_:int = int(param1[4]);
         if(param1[3] == "")
         {
            switch(_loc3_)
            {
               case Item.GEM_CURRENCY:
                  _loc4_ = int(gMainFrame.clientInfo.gemCount);
                  break;
               case Item.TICKET_CURRENCY:
                  _loc4_ = int(gMainFrame.clientInfo.ticketCount);
                  break;
               case Item.CRYSTAL_CURRENCY:
                  _loc4_ = int(gMainFrame.clientInfo.crystalCount);
                  break;
               case Item.DIAMOND_CURRENCY:
                  _loc4_ = int(gMainFrame.clientInfo.diamondCount);
                  break;
               default:
                  throw new Error("DenXtCommManager: Received unknown currencyType: " + _loc3_);
            }
         }
         else
         {
            _loc4_ = int(param1[3]);
         }
         if(_loc2_ == 1 && _loc4_ >= 0)
         {
            switch(_loc3_)
            {
               case Item.GEM_CURRENCY:
                  gMainFrame.clientInfo.gemCount = _loc4_;
                  break;
               case Item.TICKET_CURRENCY:
                  gMainFrame.clientInfo.ticketCount = _loc4_;
                  break;
               case Item.CRYSTAL_CURRENCY:
                  gMainFrame.clientInfo.crystalCount = _loc4_;
                  break;
               case Item.DIAMOND_CURRENCY:
                  gMainFrame.clientInfo.diamondCount = _loc4_;
                  break;
               default:
                  throw new Error("ItemManager: Received unknown currencyType: " + _loc3_);
            }
         }
         if(_itemBuyCallback != null)
         {
            _itemBuyCallback(_loc2_,_loc4_);
         }
      }
      
      private static function denRecycleResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1[2] == "1";
         var _loc3_:int = int(gMainFrame.clientInfo.gemCount);
         var _loc4_:int = param1[3] == "" ? _loc3_ : int(param1[3]);
         if(_loc2_ && _loc4_ >= 0)
         {
            gMainFrame.clientInfo.gemCount = _loc4_;
            if(_loc3_ < _loc4_)
            {
               GuiManager.startGemsFlash();
            }
         }
         if(_denRecycleCallback != null)
         {
            _denRecycleCallback(_loc2_);
         }
      }
      
      private static function denHighestResponse(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Array = new Array(_loc3_);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_[_loc5_] = param1[_loc2_++];
            _loc5_++;
         }
         if(_denHighestCallback != null)
         {
            _denHighestCallback(_loc4_);
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
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Boolean = param1[_loc2_++] == "1";
         var _loc5_:String = param1[_loc2_++];
         GuiManager.updateDenRoomCount(_loc3_,_loc4_,_loc5_);
      }
      
      private static function denListResponse(param1:Object) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:DenRoomItem = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         if(gMainFrame.userInfo.denRoomDefs)
         {
            _loc2_ = 2;
            _loc3_ = int(param1[_loc2_++]);
            _loc4_ = new Array(_loc3_);
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc6_ = new DenRoomItem();
               _loc7_ = int(param1[_loc2_++]);
               _loc8_ = int(param1[_loc2_++]);
               _loc9_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc8_);
               if(_loc9_)
               {
                  _loc6_.init(_loc7_,_loc8_,_loc9_.mediaId,_loc9_.value,_loc9_.name,_loc9_.enviroType,_loc9_.membersOnly);
                  _loc4_[_loc7_] = _loc6_;
               }
               _loc5_++;
            }
            if(_denListCallback != null)
            {
               _denListCallback(_loc4_);
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
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ROOM] = null;
         var _loc3_:Object = new Object();
         for each(_loc5_ in param1.def)
         {
            _loc4_ = {
               "value":int(_loc5_.cost),
               "enviroType":int(_loc5_.enviroType),
               "mediaIdLarge":int(_loc5_.iconMediaRef),
               "defId":Number(_loc5_.id),
               "mediaId":int(_loc5_.mediaRef),
               "name":LocalizationManager.translateIdOnly(_loc5_.titleStrRef),
               "titleStrRef":int(_loc5_.titleStrRef),
               "xRoomName":_loc5_.pathName,
               "status":int(_loc5_.storeStatus),
               "membersOnly":_loc5_.membersOnly == "1"
            };
            _loc3_[_loc4_.defId] = _loc4_;
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
         var _loc2_:Object = null;
         var _loc1_:Object = gMainFrame.userInfo.denRoomDefs;
         for each(_loc2_ in _loc1_)
         {
            _loc2_.name = LocalizationManager.translateIdOnly(_loc2_.titleStrRef);
         }
         gMainFrame.userInfo.denRoomDefs = _loc1_;
      }
      
      private static function denStateResponse(param1:Object) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:uint = 0;
         var _loc17_:int = 0;
         var _loc18_:Object = null;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:Boolean = false;
         var _loc25_:int = 0;
         var _loc26_:Object = null;
         var _loc27_:Object = null;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:Boolean = param1[_loc2_++] == "1";
         var _loc6_:Array = [];
         var _loc19_:Array = [];
         _loc20_ = 0;
         while(_loc20_ < _loc3_)
         {
            _loc7_ = int(param1[_loc2_++]);
            _loc8_ = int(param1[_loc2_++]);
            _loc18_ = getDenItemDef(_loc8_);
            if(!_loc18_)
            {
               _loc6_[_loc20_] = {
                  "i":_loc7_,
                  "x":0,
                  "y":0,
                  "r":DenItem.REF_ID_DEN_ITEM,
                  "c":0,
                  "userNameLink":""
               };
            }
            else
            {
               _loc9_ = param1[_loc2_++] == "1";
               _loc10_ = int(param1[_loc2_++]);
               _loc11_ = int(param1[_loc2_++]);
               _loc12_ = int(param1[_loc2_++]);
               _loc13_ = int(param1[_loc2_++]);
               _loc14_ = param1[_loc2_] == "null" ? "" : param1[_loc2_];
               _loc2_++;
               _loc15_ = int(_loc18_.sortCat);
               if(_loc9_)
               {
                  if(_loc15_ == DenItem.SORT_FLOOR || _loc15_ == DenItem.SORT_PET)
                  {
                     _loc15_ = DenItem.PLACE_CAT_FLOOR;
                  }
                  else if(_loc15_ == DenItem.SORT_WALL)
                  {
                     _loc15_ = DenItem.PLACE_CAT_WALL;
                  }
                  else if(_loc15_ == DenItem.SORT_AUDIO)
                  {
                     _loc15_ = DenItem.PLACE_CAT_ICONL;
                  }
                  else if(_loc15_ == DenItem.SORT_FLOORING || _loc15_ == DenItem.SORT_WALLPAPER)
                  {
                     _loc15_ = _roomMgr.denCatId;
                  }
                  else
                  {
                     _loc15_ = -1;
                  }
               }
               else
               {
                  _loc15_ = -1;
               }
               _loc16_ = uint(_loc8_ << 16 | _loc15_);
               _loc17_ = int(_loc18_.gameDefId);
               if(_loc17_ > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc17_))
               {
                  _loc19_.push(_loc17_);
               }
               _loc6_[_loc20_] = {
                  "i":_loc7_,
                  "p":_loc16_,
                  "x":_loc10_,
                  "y":_loc11_,
                  "v":_loc12_,
                  "f":_loc13_,
                  "c":_loc15_,
                  "r":DenItem.REF_ID_DEN_ITEM,
                  "s":_loc18_.sortCat,
                  "mg":_loc18_.gameDefId,
                  "l":_loc18_.layer,
                  "v2":_loc18_.flag,
                  "v3":0,
                  "zone":_loc18_.enviroType,
                  "strmName":_loc18_.abbrName,
                  "defId":_loc8_,
                  "userNameLink":_loc14_,
                  "specialType":_loc18_.specialType
               };
            }
            _loc20_++;
         }
         _loc20_ = 0;
         while(_loc20_ < _loc4_)
         {
            _loc7_ = int(param1[_loc2_++]);
            _loc21_ = int(param1[_loc2_++]);
            _loc22_ = int(param1[_loc2_++]);
            _loc23_ = int(param1[_loc2_++]);
            _loc8_ = PetManager.getDefIdFromLBits(_loc21_);
            _loc18_ = PetManager.getPetDef(_loc8_);
            if(_loc18_)
            {
               _loc15_ = int(param1[_loc2_++]);
               _loc10_ = int(param1[_loc2_++]);
               _loc11_ = int(param1[_loc2_++]);
               _loc13_ = int(param1[_loc2_++]);
               _loc8_ = denItemDefIdForPetDefId(_loc8_);
               _loc16_ = uint(_loc8_ << 16 | _loc15_);
               _loc6_[_loc3_ + _loc20_] = {
                  "i":_loc7_,
                  "p":_loc16_,
                  "x":_loc10_,
                  "y":_loc11_,
                  "v":_loc21_,
                  "v2":_loc22_,
                  "v3":_loc23_,
                  "f":_loc13_,
                  "c":_loc15_,
                  "r":DenItem.REF_ID_PET_ITEM,
                  "s":DenItem.SORT_PET,
                  "strmName":"",
                  "l":DenItem.DEN_PET_LAYER_ID,
                  "zone":_loc18_.enviroType,
                  "mg":0,
                  "defId":_loc8_,
                  "userNameLink":""
               };
            }
            _loc20_++;
         }
         if(_loc19_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc19_);
         }
         if(Boolean(_pendingDenChangeItems) && _pendingDenChangeItems.length > 0)
         {
            _loc25_ = int(_pendingDenChangeItems.length);
            _loc2_ = 0;
            while(_loc2_ < _loc6_.length)
            {
               _loc24_ = false;
               _loc20_ = 0;
               while(_loc20_ < _loc25_)
               {
                  if(_loc6_[_loc2_].r == _pendingDenChangeItems[_loc20_].r && _loc6_[_loc2_].i == _pendingDenChangeItems[_loc20_].i)
                  {
                     _loc24_ = true;
                     _loc26_ = _pendingDenChangeItems[_loc20_];
                     _loc27_ = _loc6_[_loc2_];
                     _loc26_.x = _loc27_.x;
                     _loc26_.y = _loc27_.y;
                     _loc26_.v = _loc27_.v;
                     _loc26_.v2 = _loc27_.v2;
                     _loc26_.f = _loc27_.f;
                     _loc26_.c = _loc27_.c;
                     _loc26_.userNameLink = _loc27_.userNameLink;
                     break;
                  }
                  _loc20_++;
               }
               if(!_loc24_)
               {
                  _pendingDenChangeItems.push(_loc6_[_loc2_]);
               }
               _loc2_++;
            }
         }
         else
         {
            _pendingDenChangeItems = _loc6_;
         }
         if(!_denChangePending || _loc5_)
         {
            setDenItems();
         }
         if(_loc5_)
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
         var _loc3_:Object = gMainFrame.userInfo.getDenRoomDefByDefId(_loc2_);
         if(_denChangeCallback != null)
         {
            _denChangeCallback(true);
            _denChangeCallback = null;
         }
         _roomMgr.loadRoom(_loc3_.xRoomName,_loc3_.enviroType,SbiConstants.ROOMTYPE_DEN,_loc3_.defId,100);
      }
      
      public static function handleDenShopList(param1:Array, param2:int, param3:int, param4:Function) : void
      {
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:DenRoomItem = null;
         var _loc11_:Object = null;
         var _loc5_:* = 6;
         var _loc6_:String = param1[4];
         var _loc7_:int = int(param1[_loc5_++]);
         if(param3 == DefPacksDefHelper.DEF_DEN_ITEM)
         {
            _loc8_ = generateDenShopList(_loc7_,param1.splice(_loc5_++,param1.length));
         }
         else
         {
            _loc8_ = new Array(_loc7_);
            _loc9_ = 0;
            while(_loc9_ < _loc7_)
            {
               _loc10_ = new DenRoomItem();
               _loc11_ = gMainFrame.userInfo.getDenRoomDefByDefId(param1[_loc5_++]);
               _loc10_.initShopItem(_loc9_,_loc11_.defId,_loc11_.mediaId,_loc11_.mediaIdLarge,_loc11_.value,_loc11_.name,_loc11_.enviroType,_loc11_.membersOnly,_loc11_.status);
               _loc8_[_loc9_] = _loc10_;
               _loc9_++;
            }
         }
         if(param4 != null)
         {
            param4(_loc8_,_loc6_);
         }
      }
      
      public static function generateDenShopList(param1:int, param2:Object) : Array
      {
         var _loc5_:DenItem = null;
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < param1)
         {
            _loc5_ = new DenItem();
            _loc5_.initShopItem(int(param2[_loc4_]),-1);
            _loc3_.push(_loc5_);
            _loc4_++;
         }
         return _loc3_;
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
         if(!_pendingDenChangeItems || _pendingDenChangeItems.length <= 0)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < _pendingDenChangeItems.length)
         {
            _loc1_ = _pendingDenChangeItems[_loc2_];
            if(_loc1_.s == DenItem.SORT_FLOORING || _loc1_.s == DenItem.SORT_WALLPAPER)
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
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc2_:Object = new Object();
         for each(_loc4_ in param1.def)
         {
            _loc3_ = {
               "abbrName":_loc4_.abbrName,
               "cost":int(_loc4_.cost),
               "currencyType":int(_loc4_.currencyType),
               "enviroType":int(_loc4_.enviroType),
               "fileType":int(_loc4_.fileType),
               "flag":int(_loc4_.flag),
               "gameDefId":int(_loc4_.gameDefId),
               "id":int(_loc4_.id),
               "itemStatus":int(_loc4_.itemStatus),
               "layer":int(_loc4_.layer),
               "membersOnly":int(_loc4_.membersOnly),
               "name":LocalizationManager.translateIdOnly(int(_loc4_.nameStrId)),
               "nameStrId":int(_loc4_.nameStrId),
               "recycleValue":int(_loc4_.recycleValue),
               "scalePercent":int(_loc4_.scalePercent),
               "sortCat":int(_loc4_.sortCat),
               "specialType":int(_loc4_.specialType)
            };
            _loc2_[_loc3_.id] = _loc3_;
         }
         _denItemDefs = _loc2_;
         delete DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ITEM];
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ITEM] = null;
      }
      
      public static function relocalizeDenItems() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in _denItemDefs)
         {
            _loc1_.name = LocalizationManager.translateIdOnly(_loc1_.nameStrId);
         }
      }
      
      private static function enviroItems(param1:Array) : Array
      {
         var _loc3_:DenItem = null;
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
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
            case PetBase.DEF_ID_PANDA:
               return 1868;
            case PetBase.DEF_ID_POLAR_BEAR_CUB:
               return 1867;
            case PetBase.DEF_ID_GECKO:
               return 1946;
            case PetBase.DEF_ID_PONY:
               return 1995;
            case PetBase.DEF_ID_PIGLET:
               return 2032;
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

