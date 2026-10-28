package avatar
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import gui.GuiManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import pet.PetManager;
   
   public class AvatarXtCommManager
   {
      
      public static var avSlotInfo:Object;
      
      private static var _adAvatarQueue:Array;
      
      private static var _agQueue:Dictionary;
      
      private static var _agsQueue:Dictionary;
      
      private static var _avatarCreateResponse:Function;
      
      private static var _avatarUpdateResponse:Function;
      
      private static var _avatarPaintResponse:Function;
      
      private static var _avatarRemoveResponse:Function;
      
      private static var _avatarListResponse:Function;
      
      private static var _getAvatarByUsername:Function;
      
      private static var _buddyCardUpdateDropDownHandler:Function;
      
      private static var _avatarInfoCallback:Function;
      
      private static var _abCallback:Function;
      
      private static var _asCallback:Function;
      
      private static var _aaCallback:Function;
      
      private static var _alCallback:Function;
      
      private static var _handleCreateAvatarData:Function;
      
      private static var _akCallback:Function;
      
      private static var _aoCallback:Function;
      
      private static var _photoTakeCallback:Function;
      
      private static var _afpCallback:Function;
      
      private static var _avatarsInRoom:Object;
      
      public function AvatarXtCommManager()
      {
         super();
      }
      
      public static function init(param1:Function = null, param2:Function = null, param3:Function = null, param4:Function = null, param5:Function = null, param6:Object = null, param7:Function = null, param8:Function = null, param9:Function = null) : void
      {
         _avatarCreateResponse = param1;
         _avatarUpdateResponse = param2;
         _avatarPaintResponse = param3;
         _avatarRemoveResponse = param4;
         _avatarListResponse = param5;
         _getAvatarByUsername = param7;
         _asCallback = param8;
         _buddyCardUpdateDropDownHandler = param9;
         _adAvatarQueue = [];
         avSlotInfo = {};
         _agQueue = new Dictionary(false);
         _agsQueue = new Dictionary(false);
         _avatarsInRoom = param6;
         XtReplyDemuxer.addModule(handleXtReply,"a");
      }
      
      public static function destroy() : void
      {
         _adAvatarQueue = null;
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function requestAvatarMake(param1:Function) : void
      {
         _handleCreateAvatarData = param1;
         gMainFrame.server.setXtObject_Str("am",[],gMainFrame.server.isWorldZone);
      }
      
      public static function requestAvatarInfo(param1:Function) : void
      {
         var _loc2_:DefPacksDefHelper = null;
         _avatarInfoCallback = param1;
         if(gMainFrame.userInfo.avtDefsCached)
         {
            if(_avatarInfoCallback != null)
            {
               _avatarInfoCallback();
               _avatarInfoCallback = null;
            }
         }
         else
         {
            _loc2_ = new DefPacksDefHelper();
            _loc2_.init(1003,avatarInfoResponse,null,2);
            DefPacksDefHelper.mediaArray[1003] = _loc2_;
         }
      }
      
      public static function requestADForAvatar(param1:int, param2:Boolean, param3:Function, param4:Avatar) : void
      {
         _adAvatarQueue.push({
            "a":param4,
            "c":(param2 ? null : param3)
         });
         var _loc6_:Boolean = gMainFrame.userInfo.myUserName.toLowerCase() == param4.userName.toLowerCase() ? ItemXtCommManager.hasRequestedFullItemList : true;
         var _loc5_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(param4.userName,param1);
         if(_loc5_ && _loc5_.type != -1)
         {
            avatarDataResponseIntegrate([_loc5_.perUserAvId,_loc5_.avName,_loc5_.userName,_loc5_.uuid,_loc5_.type,_loc5_.customAvId,_loc5_.colors[0],_loc5_.colors[1],_loc5_.colors[2]]);
            if(param2)
            {
               if(param4 == null)
               {
                  throw new Error("requestAvatarData got requestItemList=true but getAvDataAvatar=null!");
               }
               if(param4.userName != gMainFrame.userInfo.myUserName)
               {
                  ItemXtCommManager.requestItemListForAvatar(param3,param4,!_loc6_);
               }
               else
               {
                  param3();
               }
            }
         }
         else
         {
            if(param2)
            {
               ItemXtCommManager.insertIntoILAvatarQueue(param1,param3,param4);
            }
            sendAvatarDataRequest([param4.userName,param1,param2 ? (_loc6_ ? "2" : "1") : "0"]);
         }
      }
      
      public static function requestAvatarList(param1:Array, param2:Function = null) : void
      {
         _alCallback = param2;
         gMainFrame.server.setXtObject_Str("al",param1,gMainFrame.server.isWorldZone);
      }
      
      public static function requestAvatarBuy(param1:Function) : void
      {
         _abCallback = param1;
         gMainFrame.server.setXtObject_Str("ab",[]);
      }
      
      public static function requestAvatarSwitch(param1:Array) : void
      {
         gMainFrame.server.setXtObject_Str("as",param1);
      }
      
      public static function requestAvatarAdd(param1:Array, param2:Function) : void
      {
         _aaCallback = param2;
         gMainFrame.server.setXtObject_Str("aa",param1,gMainFrame.server.isWorldZone);
      }
      
      public static function requestAvatarKill(param1:Array, param2:Function) : void
      {
         _akCallback = param2;
         gMainFrame.server.setXtObject_Str("ak",param1);
      }
      
      public static function requestAvatarOrdain(param1:Array, param2:Function) : void
      {
         _aoCallback = param2;
         gMainFrame.server.setXtObject_Str("ao",param1);
      }
      
      public static function requestAvatarGet(param1:String, param2:Function, param3:Boolean = false) : void
      {
         _agQueue[param1.toLowerCase()] = param2;
         gMainFrame.server.setXtObject_Str("ag",[param1,param3 ? "1" : "0"]);
      }
      
      public static function requestAvatarGetBySfsId(param1:int, param2:Function) : void
      {
         _agsQueue[param1] = param2;
         gMainFrame.server.setXtObject_Str("ags",[param1,"0"]);
      }
      
      public static function requestColorChange(param1:Array, param2:int, param3:Function = null) : void
      {
         if(param3 != null)
         {
            _avatarPaintResponse = param3;
         }
         gMainFrame.server.setXtObject_Str("ap",[param1[0],param1[1],param1[2],param2],gMainFrame.server.isWorldZone);
      }
      
      public static function sendAvatarPendingFlagsUpdate(param1:int) : void
      {
         gMainFrame.server.setXtObject_Str("af",[param1]);
         gMainFrame.userInfo.pendingFlags |= 1 << param1;
      }
      
      public static function sendAvatarPhotoTakeCheck(param1:Function) : void
      {
         _photoTakeCallback = param1;
         gMainFrame.server.setXtObject_Str("apc",[]);
      }
      
      public static function sendAvatarPhotoTake(param1:Function) : void
      {
         _photoTakeCallback = param1;
         gMainFrame.server.setXtObject_Str("apb",[]);
      }
      
      public static function requestAvatarFastPassAdd(param1:Array, param2:Function) : void
      {
         _afpCallback = param2;
         gMainFrame.server.setXtObject_Str("afp",param1,gMainFrame.server.isWorldZone);
      }
      
      private static function sendAvatarDataRequest(param1:Array) : void
      {
         gMainFrame.server.setXtObject_Str("ad",param1,gMainFrame.server.isWorldZone);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: AvatarXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "au":
               if(_avatarUpdateResponse != null)
               {
                  _avatarUpdateResponse(_loc2_);
               }
               break;
            case "ad":
               avatarDataResponse(_loc2_);
               break;
            case "ac":
               if(_avatarCreateResponse != null)
               {
                  _avatarCreateResponse(_loc2_);
               }
               break;
            case "ap":
               if(_avatarPaintResponse != null)
               {
                  _avatarPaintResponse(_loc2_);
               }
               break;
            case "ag":
               avatarGetResponse(_loc2_);
               break;
            case "ar":
               if(_avatarRemoveResponse != null)
               {
                  _avatarRemoveResponse(_loc2_);
               }
               break;
            case "al":
               avatarListResponse(_loc2_);
               break;
            case "ab":
               avatarBuyResponse(_loc2_);
               break;
            case "as":
               avatarSwitchResponse(_loc2_);
               break;
            case "aa":
               avatarAddResponse(_loc2_);
               break;
            case "ak":
               avatarKillResponse(_loc2_);
               break;
            case "am":
               _handleCreateAvatarData(_loc2_);
               break;
            case "ao":
               avatarOrdainResponse(_loc2_);
               break;
            case "apb":
            case "apc":
               if(_photoTakeCallback != null)
               {
                  _photoTakeCallback(_loc2_);
                  _photoTakeCallback = null;
               }
               break;
            case "afp":
               avatarFastPassResponse(_loc2_);
               break;
            case "an":
               avatarNamebarUpdateResponse(_loc2_);
               break;
            default:
               throw new Error("AvatarXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function avatarInfoResponse(param1:DefPacksDefHelper) : void
      {
         var _loc3_:int = 0;
         DefPacksDefHelper.mediaArray[1003] = null;
         var _loc6_:Object = param1.def;
         var _loc4_:Object = {};
         var _loc7_:Array = [];
         for each(var _loc2_:Object in _loc6_)
         {
            _loc7_[int(_loc2_.id)] = new Point(_loc2_.x,_loc2_.y);
            _loc4_[int(_loc2_.id)] = {
               "colorLayer1":uint(_loc2_.colorLayer1),
               "colorLayer2":uint(_loc2_.colorLayer2),
               "colorLayer3":uint(_loc2_.colorLayer3),
               "defPattern":int(_loc2_.basePatternId),
               "defEyes":int(_loc2_.baseEyesId),
               "isMemOnly":_loc2_.membersOnly == "1",
               "enviroTypeFlag":int(_loc2_.enviroTypeFlags),
               "cost":int(_loc2_.cost),
               "titleStrRef":int(_loc2_.titleStrRef),
               "availability":int(_loc2_.availability),
               "attackItemRefId":int(_loc2_.attackItemRefId),
               "iconMediaId":int(_loc2_.iconMediaRefId),
               "status":int(_loc2_.status)
            };
         }
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            gMainFrame.setAvatarOffsets(_loc7_);
            gMainFrame.userInfo.setAvatarDefs(_loc4_);
         }
         var _loc5_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc5_.init(1057,customAvatarDefPacksResponse,null,2);
         DefPacksDefHelper.mediaArray[1057] = _loc5_;
      }
      
      private static function customAvatarDefPacksResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:int = 0;
         DefPacksDefHelper.mediaArray[1057] = null;
         var _loc5_:Object = param1.def;
         var _loc3_:Object = {};
         for each(var _loc6_:Object in _loc5_)
         {
            if(_loc6_.avatarIconRefId != "0")
            {
               _loc3_[int(_loc6_.id)] = {
                  "id":int(_loc6_.id),
                  "avatarRefId":int(_loc6_.avatarRef),
                  "iconRefId":int(_loc6_.iconRefId),
                  "particleRefId":int(_loc6_.particleRefId),
                  "patternRefId":int(_loc6_.patternRefId),
                  "titleStrRef":int(_loc6_.titleStrRef),
                  "iconMediaId":int(_loc6_.avatarIconRefId)
               };
            }
         }
         gMainFrame.userInfo.setCustomAvatarDefs(_loc3_);
         var _loc4_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc4_.init(1027,liDefPacksResponse,null,2);
         DefPacksDefHelper.mediaArray[1027] = _loc4_;
      }
      
      private static function liDefPacksResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[1027] = null;
         var _loc3_:Object = param1.def;
         var _loc4_:Object = {};
         for each(var _loc2_:Object in _loc3_)
         {
            _loc4_[int(_loc2_.id)] = int(_loc2_.layerId);
         }
         gMainFrame.layerInfo = _loc4_;
         if(_avatarInfoCallback != null)
         {
            _avatarInfoCallback();
            _avatarInfoCallback = null;
         }
      }
      
      private static function avatarDataResponse(param1:Array) : void
      {
         var _loc12_:Boolean = false;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc35_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc2_:int = 0;
         var _loc29_:int = 0;
         var _loc28_:int = 0;
         var _loc7_:AvatarInfo = null;
         var _loc26_:UserInfo = null;
         var _loc10_:Array = null;
         var _loc8_:int = 2;
         var _loc34_:String = param1[_loc8_++];
         var _loc23_:String = param1[_loc8_++];
         var _loc22_:int = int(param1[_loc8_++]);
         var _loc37_:int = int(param1[_loc8_++]);
         var _loc24_:int = int(param1[_loc8_++]);
         var _loc27_:int = int(param1[_loc8_++]);
         var _loc4_:int = int(param1[_loc8_++]);
         var _loc18_:int = int(param1[_loc8_++]);
         var _loc21_:int = int(param1[_loc8_++]);
         var _loc33_:uint = uint(param1[_loc8_++]);
         var _loc31_:uint = uint(param1[_loc8_++]);
         var _loc32_:uint = uint(param1[_loc8_++]);
         var _loc13_:String = param1[_loc8_++];
         var _loc25_:int = int(param1[_loc8_++]);
         var _loc20_:int = -1;
         var _loc30_:int = 0;
         var _loc36_:int = 0;
         var _loc15_:int = 0;
         var _loc14_:int = 0;
         var _loc9_:String = "";
         if(_loc34_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _loc12_ = true;
            _loc20_ = int(param1[_loc8_++]);
            _loc30_ = int(param1[_loc8_++]);
            _loc36_ = int(param1[_loc8_++]);
            _loc5_ = int(param1[_loc8_++]);
            _loc3_ = int(param1[_loc8_++]);
            _loc35_ = int(param1[_loc8_++]);
            _loc16_ = int(param1[_loc8_++]);
            _loc17_ = int(param1[_loc8_++]);
         }
         else
         {
            _loc2_ = int(param1[_loc8_++]);
            _loc29_ = int(param1[_loc8_++]);
            _loc28_ = int(param1[_loc8_++]);
            _loc9_ = param1[_loc8_++];
         }
         var _loc19_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc34_);
         if(_loc19_)
         {
            for each(var _loc6_:AvatarInfo in _loc19_.avList)
            {
               if(_loc6_.perUserAvId == _loc4_)
               {
                  _loc7_ = _loc6_;
                  break;
               }
            }
            _loc19_.uuid = _loc23_;
            _loc19_.nameBarData = _loc22_;
            _loc19_.userNameModeratedFlag = _loc24_;
            _loc19_.timeLeftHostingCustomParty = _loc27_;
         }
         var _loc11_:Object = {
            "name":_loc9_,
            "lBits":_loc2_,
            "uBits":_loc29_,
            "eBits":_loc28_
         };
         _loc11_.defId = PetManager.getDefIdFromLBits(_loc11_.lBits);
         _loc11_.type = PetManager.petTypeForDefId(_loc11_.defId);
         _loc11_.isGround = PetManager.isGround(_loc11_.type);
         if(_loc7_)
         {
            _loc7_.avName = _loc13_;
            _loc7_.userName = _loc34_;
            _loc7_.uuid = _loc23_;
            _loc7_.type = _loc18_;
            _loc7_.colors = [_loc33_,_loc31_,_loc32_];
            _loc7_.currEnviroType = _loc37_;
            _loc7_.questLevel = _loc25_;
            _loc7_.currPet = _loc11_;
            _loc7_.customAvId = _loc21_;
            if(_loc12_)
            {
               if(_loc20_ >= 0)
               {
                  avSlotInfo[_loc7_.perUserAvId].avInvId = _loc20_;
               }
               _loc7_.landPetInvId = _loc30_;
               _loc7_.oceanPetInvId = _loc36_;
               _loc7_.questXp = _loc15_;
               _loc7_.healthBase = _loc17_;
               _loc7_.attackBase = _loc5_;
               _loc7_.attackMax = _loc3_;
               _loc7_.defenseBase = _loc35_;
               _loc7_.defenseMax = _loc16_;
            }
         }
         else
         {
            _loc7_ = new AvatarInfo();
            _loc7_.init(_loc4_,_loc13_,_loc34_,_loc23_,_loc18_,[_loc33_,_loc31_,_loc32_],0,_loc11_,_loc21_);
            _loc7_.questLevel = _loc25_;
            if(_loc12_)
            {
               if(_loc20_ >= 0)
               {
                  avSlotInfo[_loc7_.perUserAvId] = {
                     "slotId":-1,
                     "avInvId":_loc20_
                  };
               }
               _loc7_.landPetInvId = _loc30_;
               _loc7_.oceanPetInvId = _loc36_;
               _loc7_.questXp = _loc15_;
               _loc7_.healthBase = _loc17_;
               _loc7_.attackBase = _loc5_;
               _loc7_.attackMax = _loc3_;
               _loc7_.defenseBase = _loc35_;
               _loc7_.defenseMax = _loc16_;
            }
            if(_loc19_)
            {
               _loc19_.addAvatarToList(_loc7_);
               _loc19_.uuid = _loc23_;
               _loc19_.nameBarData = _loc22_;
               _loc19_.userNameModeratedFlag = _loc24_;
               _loc19_.timeLeftHostingCustomParty = _loc27_;
            }
            else
            {
               _loc26_ = new UserInfo();
               _loc10_ = [];
               _loc10_[_loc7_.perUserAvId] = _loc7_;
               _loc26_.init(_loc34_,_loc23_,_loc10_,_loc7_.perUserAvId,1,_loc24_,_loc27_);
               _loc26_.nameBarData = _loc22_;
               gMainFrame.userInfo.setUserInfoByUserName(_loc34_,_loc26_);
            }
         }
         avatarDataResponseIntegrate([_loc4_,_loc13_,_loc34_,_loc23_,_loc18_,_loc21_,_loc33_,_loc31_,_loc32_]);
      }
      
      private static function avatarDataResponseIntegrate(param1:Array) : void
      {
         var _loc3_:Boolean = false;
         var _loc8_:int = 0;
         var _loc7_:String = null;
         var _loc2_:Avatar = null;
         var _loc5_:int = 0;
         var _loc4_:Avatar = null;
         var _loc6_:Function = null;
         if(_adAvatarQueue && _adAvatarQueue.length > 0)
         {
            _loc8_ = 0;
            while(_loc8_ < _adAvatarQueue.length)
            {
               if(_adAvatarQueue[_loc8_].a.perUserAvId == param1[0])
               {
                  _loc4_ = _adAvatarQueue[_loc8_].a;
                  _loc6_ = _adAvatarQueue[_loc8_].c;
                  _adAvatarQueue.splice(_loc8_,1);
                  break;
               }
               _loc8_++;
            }
         }
         else if(_avatarsInRoom)
         {
            _loc7_ = param1[2];
            if(_getAvatarByUsername != null)
            {
               _loc2_ = _getAvatarByUsername(_loc7_);
            }
            if(_loc2_)
            {
               _loc4_ = _loc2_;
               _loc3_ = true;
            }
         }
         if(_loc4_)
         {
            _loc5_ = 0;
            _loc4_.perUserAvId = param1[_loc5_++];
            _loc4_.avName = param1[_loc5_++];
            _loc4_.userName = param1[_loc5_++];
            _loc4_.uuid = param1[_loc5_++];
            _loc4_.avTypeId = int(param1[_loc5_++]);
            _loc4_.customAvId = int(param1[_loc5_++]);
            _loc4_.setColors(uint(param1[_loc5_++]),uint(param1[_loc5_++]),uint(param1[_loc5_++]));
            if(!_loc3_)
            {
               if(_loc6_ != null)
               {
                  _loc6_(true);
                  _loc6_ = null;
               }
            }
            _buddyCardUpdateDropDownHandler(_loc4_.userName);
         }
         else if(_loc6_ != null)
         {
            DebugUtility.debugTrace("calling loadDataAvatarResult even though dataAvatar was null...");
            _loc6_(false);
            _loc6_ = null;
         }
      }
      
      private static function avatarGetResponse(param1:Array) : void
      {
         var _loc31_:int = 0;
         var _loc21_:Boolean = false;
         var _loc28_:int = 0;
         var _loc4_:int = 0;
         var _loc12_:int = 0;
         var _loc17_:int = 0;
         var _loc22_:Array = null;
         var _loc16_:String = null;
         var _loc6_:int = 0;
         var _loc20_:int = 0;
         var _loc18_:int = 0;
         var _loc24_:int = 0;
         var _loc14_:int = 0;
         var _loc29_:int = 0;
         var _loc2_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc8_:String = null;
         var _loc3_:int = 0;
         var _loc30_:Array = null;
         var _loc27_:int = 0;
         var _loc11_:Item = null;
         var _loc10_:Object = null;
         var _loc15_:UserInfo = null;
         var _loc5_:AvatarInfo = null;
         var _loc9_:Array = null;
         var _loc23_:int = 2;
         var _loc13_:String = param1[_loc23_++];
         var _loc33_:String = param1[_loc23_++];
         var _loc19_:int = int(param1[_loc23_++]);
         var _loc7_:int = _loc19_ == 0 ? 0 : (_loc19_ == 1 ? 1 : (_loc19_ == 2 ? -1 : -2));
         if(_loc19_ >= 2 && GuiManager.isVersionPopupOpen())
         {
            _loc19_ = -2;
            _loc7_ = -3;
         }
         if(_loc19_ == 0 || _loc19_ == 1)
         {
            _loc31_ = int(param1[_loc23_++]);
            _loc21_ = param1[_loc23_++] == "1";
            _loc28_ = int(param1[_loc23_++]);
            _loc4_ = int(param1[_loc23_++]);
            _loc12_ = int(param1[_loc23_++]);
            _loc17_ = int(param1[_loc23_++]);
            _loc22_ = new Array(3);
            _loc22_[0] = uint(param1[_loc23_++]);
            _loc22_[1] = uint(param1[_loc23_++]);
            _loc22_[2] = uint(param1[_loc23_++]);
            _loc16_ = param1[_loc23_++];
            _loc6_ = int(param1[_loc23_++]);
            _loc20_ = int(param1[_loc23_++]);
            _loc18_ = int(param1[_loc23_++]);
            _loc24_ = int(param1[_loc23_++]);
            _loc14_ = int(param1[_loc23_++]);
            _loc29_ = int(param1[_loc23_++]);
            _loc2_ = int(param1[_loc23_++]);
            _loc25_ = int(param1[_loc23_++]);
            _loc26_ = int(param1[_loc23_++]);
            _loc8_ = param1[_loc23_++];
            _loc3_ = _loc20_ > 0 ? 3 : 2;
            _loc30_ = new Array(_loc24_ + _loc3_);
            _loc27_ = 0;
            _loc30_[_loc27_++] = ItemXtCommManager.getBodyModFromDefId(1,_loc28_,true);
            _loc30_[_loc27_++] = ItemXtCommManager.getBodyModFromDefId(_loc6_,_loc28_,true);
            if(_loc20_ > 0)
            {
               _loc30_[_loc27_++] = ItemXtCommManager.getBodyModFromDefId(_loc20_,_loc28_,true);
            }
            DebugUtility.debugTrace("avatarGetResponse userName:" + _loc13_ + " numClothingItems:" + _loc24_ + " numBodyModItems:" + _loc3_ + " pattDefId:" + _loc20_);
            while(_loc27_ < _loc24_ + _loc3_)
            {
               _loc11_ = new Item();
               _loc11_.init(int(param1[_loc23_++]),_loc27_,uint(param1[_loc23_++]));
               _loc11_.setInUse(_loc28_,true);
               _loc30_[_loc27_] = _loc11_;
               _loc27_++;
            }
            _loc10_ = {
               "name":_loc8_,
               "lBits":_loc2_,
               "uBits":_loc25_,
               "eBits":_loc26_
            };
            _loc10_.defId = PetManager.getDefIdFromLBits(_loc10_.lBits);
            _loc10_.type = PetManager.petTypeForDefId(_loc10_.defId);
            _loc10_.isGround = PetManager.isGround(_loc10_.type);
            _loc15_ = gMainFrame.userInfo.getUserInfoByUserName(_loc13_);
            _loc5_ = new AvatarInfo();
            _loc5_.init(_loc28_,_loc16_,_loc13_,_loc33_,_loc12_,_loc22_,0,_loc10_,_loc17_,0,0,0,_loc18_);
            if(!_loc15_)
            {
               _loc9_ = new Array(1);
               _loc9_[_loc28_] = _loc5_;
               _loc15_ = new UserInfo();
               _loc15_.init(_loc13_,_loc33_,_loc9_,_loc28_,_loc31_);
            }
            else
            {
               _loc15_.currPerUserAvId = _loc28_;
               _loc15_.accountType = _loc31_;
               _loc15_.addAvatarToList(_loc5_);
            }
            _loc15_.userNameModeratedFlag = _loc29_;
            _loc15_.nameBarData = _loc4_;
            _loc15_.isGuide = _loc21_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc13_,_loc15_);
         }
         var _loc32_:String = _loc13_.toLowerCase();
         if(_agQueue[_loc32_])
         {
            _agQueue[_loc32_](_loc13_,_loc19_ < 3,_loc7_);
            delete _agQueue[_loc32_];
         }
         if(_agsQueue[_loc14_])
         {
            _agsQueue[_loc14_](_loc13_,_loc19_ < 3,_loc7_,_loc14_);
            delete _agsQueue[_loc14_];
         }
      }
      
      private static function avatarListResponse(param1:Array) : void
      {
         var _loc16_:String = null;
         var _loc11_:Boolean = false;
         var _loc8_:int = 0;
         var _loc15_:String = null;
         var _loc14_:int = 0;
         var _loc9_:Array = null;
         var _loc13_:int = 0;
         var _loc18_:UserInfo = null;
         var _loc6_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:int = 0;
         var _loc17_:String = null;
         var _loc5_:AvatarInfo = null;
         var _loc7_:UserInfo = null;
         var _loc12_:int = 2;
         var _loc3_:int = int(param1[_loc12_++]);
         var _loc4_:uint = 0;
         _loc8_ = 0;
         while(_loc8_ < _loc3_)
         {
            _loc15_ = param1[_loc12_++];
            if(_loc15_.toLowerCase() == gMainFrame.server.userName.toLowerCase())
            {
               _loc11_ = true;
               _loc4_ = uint(param1[_loc12_++]);
               _loc16_ = param1[_loc12_++];
            }
            _loc14_ = int(param1[_loc12_++]);
            _loc9_ = [];
            _loc18_ = gMainFrame.userInfo.getUserInfoByUserName(_loc15_);
            _loc6_ = 0;
            while(_loc6_ < _loc14_)
            {
               _loc10_ = int(param1[_loc12_++]);
               if(_loc6_ == 0)
               {
                  _loc13_ = _loc10_;
               }
               _loc2_ = int(param1[_loc12_++]);
               _loc17_ = param1[_loc12_++];
               if(_loc18_)
               {
                  _loc5_ = _loc18_.getAvatarInfoByPerUserAvId(_loc10_);
                  if(!_loc5_)
                  {
                     _loc5_ = new AvatarInfo();
                     _loc5_.init(_loc10_,_loc17_,_loc15_);
                  }
                  _loc9_[_loc10_] = _loc5_;
               }
               else
               {
                  _loc5_ = new AvatarInfo();
                  _loc5_.init(_loc10_,_loc17_,_loc15_);
                  _loc9_[_loc10_] = _loc5_;
               }
               if(_loc11_)
               {
                  avSlotInfo[_loc10_] = {
                     "slotId":_loc6_,
                     "avInvId":_loc2_
                  };
               }
               _loc6_++;
            }
            _loc7_ = new UserInfo();
            if(_loc18_)
            {
               _loc18_.avList = _loc9_;
               _loc18_.currPerUserAvId = _loc13_;
               _loc18_.uuid = _loc16_;
               _loc7_ = _loc18_;
            }
            else
            {
               _loc7_.init(_loc15_,_loc16_,_loc9_,_loc13_);
            }
            gMainFrame.userInfo.setUserInfoByUserName(_loc15_,_loc7_);
            _loc8_++;
         }
         if(_loc15_ != gMainFrame.server.userName)
         {
            if(_avatarListResponse != null)
            {
               _avatarListResponse();
            }
         }
         if(_alCallback != null)
         {
            if(_loc11_)
            {
               _alCallback(_loc4_);
            }
            else
            {
               _alCallback(_loc3_ == -1);
            }
            _alCallback = null;
         }
      }
      
      private static function avatarBuyResponse(param1:Array) : void
      {
         if(_abCallback != null)
         {
            _abCallback(Boolean(int(param1[2])));
         }
      }
      
      private static function avatarSwitchResponse(param1:Array) : void
      {
         if(_asCallback != null)
         {
            _asCallback(param1);
         }
      }
      
      private static function avatarAddResponse(param1:Array) : void
      {
         if(_aaCallback != null)
         {
            _aaCallback(int(param1[2]),int(param1[3]),int(param1[4]));
         }
      }
      
      private static function avatarKillResponse(param1:Array) : void
      {
         if(_akCallback != null)
         {
            _akCallback(Boolean(int(param1[2])),int(param1[3]));
         }
      }
      
      private static function avatarOrdainResponse(param1:Array) : void
      {
         if(_aoCallback != null)
         {
            _aoCallback(Boolean(int(param1[2])));
         }
      }
      
      private static function avatarFastPassResponse(param1:Array) : void
      {
         if(_afpCallback != null)
         {
            _afpCallback(Boolean(int(param1[2])));
         }
      }
      
      private static function avatarNamebarUpdateResponse(param1:Array) : void
      {
         var _loc3_:int = 2;
         var _loc5_:int = int(param1[_loc3_++]);
         var _loc4_:AvatarWorldView = AvatarManager.avatarViewList[_loc5_];
         if(_loc4_ == null)
         {
            DebugUtility.debugTrace("ERROR: invalid avatar worldview when updating namebar data");
            return;
         }
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc4_.userName);
         if(_loc2_ == null)
         {
            DebugUtility.debugTrace("ERROR: invalid user info when updating namebar data");
            return;
         }
         _loc2_.nameBarData = int(param1[_loc3_++]);
         _loc4_.currAvatar.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
      }
   }
}

