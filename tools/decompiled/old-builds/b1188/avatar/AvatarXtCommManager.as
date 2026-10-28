package avatar
{
   import com.sbi.client.SFClient;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.FileServerEvent;
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
         avSlotInfo = new Object();
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
            _loc2_.init(DefPacksDefHelper.DEF_AVATAR,avatarInfoResponse,null,FileServerEvent.AMF3_TYPE);
            DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_AVATAR] = _loc2_;
         }
      }
      
      public static function requestADForAvatar(param1:int, param2:Boolean, param3:Function, param4:Avatar) : void
      {
         _adAvatarQueue.push({
            "a":param4,
            "c":(param2 ? null : param3)
         });
         var _loc5_:Boolean = gMainFrame.userInfo.myUserName.toLowerCase() == param4.userName.toLowerCase() ? ItemXtCommManager.hasRequestedFullItemList : true;
         var _loc6_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(param4.userName,param1);
         if((Boolean(_loc6_)) && _loc6_.type != -1)
         {
            avatarDataResponseIntegrate([_loc6_.perUserAvId,_loc6_.avName,_loc6_.userName,_loc6_.uuid,_loc6_.type,_loc6_.customAvId,_loc6_.colors[0],_loc6_.colors[1],_loc6_.colors[2]]);
            if(param2)
            {
               if(param4 == null)
               {
                  throw new Error("requestAvatarData got requestItemList=true but getAvDataAvatar=null!");
               }
               if(param4.userName != gMainFrame.userInfo.myUserName)
               {
                  ItemXtCommManager.requestItemListForAvatar(param3,param4,!_loc5_);
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
            sendAvatarDataRequest([param4.userName,param1,param2 ? (_loc5_ ? "2" : "1") : "0"]);
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
            default:
               throw new Error("AvatarXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function avatarInfoResponse(param1:DefPacksDefHelper) : void
      {
         var _loc3_:int = 0;
         var _loc6_:Object = null;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_AVATAR] = null;
         var _loc2_:Object = param1.def;
         var _loc4_:Object = new Object();
         var _loc5_:Array = [];
         for each(_loc6_ in _loc2_)
         {
            _loc5_[int(_loc6_.id)] = new Point(_loc6_.x,_loc6_.y);
            _loc4_[int(_loc6_.id)] = {
               "colorLayer1":uint(_loc6_.colorLayer1),
               "colorLayer2":uint(_loc6_.colorLayer2),
               "colorLayer3":uint(_loc6_.colorLayer3),
               "defPattern":int(_loc6_.basePatternId),
               "defEyes":int(_loc6_.baseEyesId),
               "isMemOnly":Boolean(_loc6_.membersOnly == "1"),
               "enviroTypeFlag":int(_loc6_.enviroTypeFlags),
               "cost":int(_loc6_.cost),
               "titleStrRef":int(_loc6_.titleStrRef),
               "availability":int(_loc6_.availability),
               "attackItemRefId":int(_loc6_.attackItemRefId),
               "iconMediaId":int(_loc6_.iconMediaRefId),
               "status":int(_loc6_.status)
            };
         }
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            gMainFrame.setAvatarOffsets(_loc5_);
            gMainFrame.userInfo.setAvatarDefs(_loc4_);
         }
         var _loc7_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc7_.init(DefPacksDefHelper.DEF_AVATAR_CUSTOM,customAvatarDefPacksResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_AVATAR_CUSTOM] = _loc7_;
      }
      
      private static function customAvatarDefPacksResponse(param1:DefPacksDefHelper) : void
      {
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:DefPacksDefHelper = null;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_AVATAR_CUSTOM] = null;
         var _loc2_:Object = param1.def;
         var _loc4_:Object = new Object();
         for each(_loc5_ in _loc2_)
         {
            if(_loc5_.avatarIconRefId != "0")
            {
               _loc4_[int(_loc5_.id)] = {
                  "id":int(_loc5_.id),
                  "avatarRefId":int(_loc5_.avatarRef),
                  "iconRefId":int(_loc5_.iconRefId),
                  "particleRefId":int(_loc5_.particleRefId),
                  "patternRefId":int(_loc5_.patternRefId),
                  "titleStrRef":int(_loc5_.titleStrRef),
                  "iconMediaId":int(_loc5_.avatarIconRefId)
               };
            }
         }
         gMainFrame.userInfo.setCustomAvatarDefs(_loc4_);
         _loc6_ = new DefPacksDefHelper();
         _loc6_.init(DefPacksDefHelper.DEF_LAYER,liDefPacksResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LAYER] = _loc6_;
      }
      
      private static function liDefPacksResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LAYER] = null;
         var _loc2_:Object = param1.def;
         var _loc3_:Object = {};
         for each(_loc4_ in _loc2_)
         {
            _loc3_[int(_loc4_.id)] = int(_loc4_.layerId);
         }
         gMainFrame.layerInfo = _loc3_;
         if(_avatarInfoCallback != null)
         {
            _avatarInfoCallback();
            _avatarInfoCallback = null;
         }
      }
      
      private static function avatarDataResponse(param1:Array) : void
      {
         var _loc16_:Boolean = false;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc27_:int = 0;
         var _loc28_:int = 0;
         var _loc29_:int = 0;
         var _loc32_:AvatarInfo = null;
         var _loc34_:AvatarInfo = null;
         var _loc35_:UserInfo = null;
         var _loc36_:Array = null;
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:String = param1[_loc2_++];
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:int = int(param1[_loc2_++]);
         var _loc7_:int = int(param1[_loc2_++]);
         var _loc8_:int = int(param1[_loc2_++]);
         var _loc9_:int = int(param1[_loc2_++]);
         var _loc10_:int = int(param1[_loc2_++]);
         var _loc11_:uint = uint(param1[_loc2_++]);
         var _loc12_:uint = uint(param1[_loc2_++]);
         var _loc13_:uint = uint(param1[_loc2_++]);
         var _loc14_:String = param1[_loc2_++];
         var _loc15_:int = int(param1[_loc2_++]);
         var _loc17_:int = -1;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc30_:String = "";
         if(_loc3_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _loc16_ = true;
            _loc17_ = int(param1[_loc2_++]);
            _loc18_ = int(param1[_loc2_++]);
            _loc19_ = int(param1[_loc2_++]);
            _loc22_ = int(param1[_loc2_++]);
            _loc23_ = int(param1[_loc2_++]);
            _loc24_ = int(param1[_loc2_++]);
            _loc25_ = int(param1[_loc2_++]);
            _loc26_ = int(param1[_loc2_++]);
         }
         else
         {
            _loc27_ = int(param1[_loc2_++]);
            _loc28_ = int(param1[_loc2_++]);
            _loc29_ = int(param1[_loc2_++]);
            _loc30_ = param1[_loc2_++];
         }
         var _loc31_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc3_);
         if(_loc31_)
         {
            for each(_loc34_ in _loc31_.avList)
            {
               if(_loc34_.perUserAvId == _loc8_)
               {
                  _loc32_ = _loc34_;
                  break;
               }
            }
            _loc31_.uuid = _loc4_;
            _loc31_.nameBarData = _loc5_;
            _loc31_.userNameModeratedFlag = _loc7_;
         }
         var _loc33_:Object = {
            "name":_loc30_,
            "lBits":_loc27_,
            "uBits":_loc28_,
            "eBits":_loc29_
         };
         _loc33_.defId = PetManager.getDefIdFromLBits(_loc33_.lBits);
         _loc33_.type = PetManager.petTypeForDefId(_loc33_.defId);
         _loc33_.isGround = PetManager.isGround(_loc33_.type);
         if(_loc32_)
         {
            _loc32_.avName = _loc14_;
            _loc32_.userName = _loc3_;
            _loc32_.uuid = _loc4_;
            _loc32_.type = _loc9_;
            _loc32_.colors = [_loc11_,_loc12_,_loc13_];
            _loc32_.currEnviroType = _loc6_;
            _loc32_.questLevel = _loc15_;
            _loc32_.currPet = _loc33_;
            _loc32_.customAvId = _loc10_;
            if(_loc16_)
            {
               if(_loc17_ >= 0)
               {
                  avSlotInfo[_loc32_.perUserAvId].avInvId = _loc17_;
               }
               _loc32_.landPetInvId = _loc18_;
               _loc32_.oceanPetInvId = _loc19_;
               _loc32_.questXp = _loc20_;
               _loc32_.healthBase = _loc26_;
               _loc32_.attackBase = _loc22_;
               _loc32_.attackMax = _loc23_;
               _loc32_.defenseBase = _loc24_;
               _loc32_.defenseMax = _loc25_;
            }
         }
         else
         {
            _loc32_ = new AvatarInfo();
            _loc32_.init(_loc8_,_loc14_,_loc3_,_loc4_,_loc9_,[_loc11_,_loc12_,_loc13_],0,_loc33_,_loc10_);
            _loc32_.questLevel = _loc15_;
            if(_loc16_)
            {
               if(_loc17_ >= 0)
               {
                  avSlotInfo[_loc32_.perUserAvId] = {
                     "slotId":-1,
                     "avInvId":_loc17_
                  };
               }
               _loc32_.landPetInvId = _loc18_;
               _loc32_.oceanPetInvId = _loc19_;
               _loc32_.questXp = _loc20_;
               _loc32_.healthBase = _loc26_;
               _loc32_.attackBase = _loc22_;
               _loc32_.attackMax = _loc23_;
               _loc32_.defenseBase = _loc24_;
               _loc32_.defenseMax = _loc25_;
            }
            if(_loc31_)
            {
               _loc31_.addAvatarToList(_loc32_);
               _loc31_.uuid = _loc4_;
               _loc31_.nameBarData = _loc5_;
               _loc31_.userNameModeratedFlag = _loc7_;
            }
            else
            {
               _loc35_ = new UserInfo();
               _loc36_ = new Array();
               _loc36_[_loc32_.perUserAvId] = _loc32_;
               _loc35_.init(_loc3_,_loc4_,_loc36_,_loc32_.perUserAvId,1,_loc7_);
               _loc35_.nameBarData = _loc5_;
               gMainFrame.userInfo.setUserInfoByUserName(_loc3_,_loc35_);
            }
         }
         avatarDataResponseIntegrate([_loc8_,_loc14_,_loc3_,_loc4_,_loc9_,_loc10_,_loc11_,_loc12_,_loc13_]);
      }
      
      private static function avatarDataResponseIntegrate(param1:Array) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Avatar = null;
         var _loc8_:* = 0;
         var _loc2_:Avatar = null;
         var _loc3_:Function = null;
         if(Boolean(_adAvatarQueue) && _adAvatarQueue.length > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _adAvatarQueue.length)
            {
               if(_adAvatarQueue[_loc5_].a.perUserAvId == param1[0])
               {
                  _loc2_ = _adAvatarQueue[_loc5_].a;
                  _loc3_ = _adAvatarQueue[_loc5_].c;
                  _adAvatarQueue.splice(_loc5_,1);
                  break;
               }
               _loc5_++;
            }
         }
         else if(_avatarsInRoom)
         {
            _loc6_ = param1[2];
            if(_getAvatarByUsername != null)
            {
               _loc7_ = _getAvatarByUsername(_loc6_);
            }
            if(_loc7_)
            {
               _loc2_ = _loc7_;
               _loc4_ = true;
            }
         }
         if(_loc2_)
         {
            _loc8_ = 0;
            _loc2_.perUserAvId = param1[_loc8_++];
            _loc2_.avName = param1[_loc8_++];
            _loc2_.userName = param1[_loc8_++];
            _loc2_.uuid = param1[_loc8_++];
            _loc2_.avTypeId = int(param1[_loc8_++]);
            _loc2_.customAvId = int(param1[_loc8_++]);
            _loc2_.setColors(uint(param1[_loc8_++]),uint(param1[_loc8_++]),uint(param1[_loc8_++]));
            if(!_loc4_)
            {
               if(_loc3_ != null)
               {
                  _loc3_(true);
                  _loc3_ = null;
               }
            }
            _buddyCardUpdateDropDownHandler(_loc2_.userName);
         }
         else if(_loc3_ != null)
         {
            DebugUtility.debugTrace("calling loadDataAvatarResult even though dataAvatar was null...");
            _loc3_(false);
            _loc3_ = null;
         }
      }
      
      private static function avatarGetResponse(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Array = null;
         var _loc15_:String = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:String = null;
         var _loc26_:int = 0;
         var _loc27_:Array = null;
         var _loc28_:* = 0;
         var _loc29_:Object = null;
         var _loc30_:UserInfo = null;
         var _loc31_:AvatarInfo = null;
         var _loc32_:Item = null;
         var _loc33_:Array = null;
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:String = param1[_loc2_++];
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:int = _loc5_ == 0 ? SFClient.STATUS_OFFLINE_ACTIVE : (_loc5_ == 1 ? SFClient.STATUS_ONLINE : (_loc5_ == 2 ? SFClient.STATUS_OFFLINE_ARCHIVED : SFClient.STATUS_OFFLINE_UNKNOWN));
         if(_loc5_ >= 2 && GuiManager.isVersionPopupOpen())
         {
            _loc5_ = SFClient.STATUS_OFFLINE_UNKNOWN;
            _loc6_ = SFClient.STATUS_DIFFERENT_VERSION;
         }
         if(_loc5_ == 0 || _loc5_ == 1)
         {
            _loc8_ = int(param1[_loc2_++]);
            _loc9_ = param1[_loc2_++] == "1";
            _loc10_ = int(param1[_loc2_++]);
            _loc11_ = int(param1[_loc2_++]);
            _loc12_ = int(param1[_loc2_++]);
            _loc13_ = int(param1[_loc2_++]);
            _loc14_ = new Array(3);
            _loc14_[0] = uint(param1[_loc2_++]);
            _loc14_[1] = uint(param1[_loc2_++]);
            _loc14_[2] = uint(param1[_loc2_++]);
            _loc15_ = param1[_loc2_++];
            _loc16_ = int(param1[_loc2_++]);
            _loc17_ = int(param1[_loc2_++]);
            _loc18_ = int(param1[_loc2_++]);
            _loc19_ = int(param1[_loc2_++]);
            _loc20_ = int(param1[_loc2_++]);
            _loc21_ = int(param1[_loc2_++]);
            _loc22_ = int(param1[_loc2_++]);
            _loc23_ = int(param1[_loc2_++]);
            _loc24_ = int(param1[_loc2_++]);
            _loc25_ = param1[_loc2_++];
            _loc26_ = _loc17_ > 0 ? 3 : 2;
            _loc27_ = new Array(_loc19_ + _loc26_);
            _loc28_ = 0;
            var _loc34_:Number;
            _loc27_[_loc34_ = _loc28_++] = ItemXtCommManager.getBodyModFromDefId(1,_loc10_,true);
            var _loc35_:Number;
            _loc27_[_loc35_ = _loc28_++] = ItemXtCommManager.getBodyModFromDefId(_loc16_,_loc10_,true);
            if(_loc17_ > 0)
            {
               var _loc36_:Number;
               _loc27_[_loc36_ = _loc28_++] = ItemXtCommManager.getBodyModFromDefId(_loc17_,_loc10_,true);
            }
            DebugUtility.debugTrace("avatarGetResponse userName:" + _loc3_ + " numClothingItems:" + _loc19_ + " numBodyModItems:" + _loc26_ + " pattDefId:" + _loc17_);
            while(_loc28_ < _loc19_ + _loc26_)
            {
               _loc32_ = new Item();
               _loc32_.init(int(param1[_loc2_++]),_loc28_,uint(param1[_loc2_++]));
               _loc32_.setInUse(_loc10_,true);
               _loc27_[_loc28_] = _loc32_;
               _loc28_++;
            }
            _loc29_ = {
               "name":_loc25_,
               "lBits":_loc22_,
               "uBits":_loc23_,
               "eBits":_loc24_
            };
            _loc29_.defId = PetManager.getDefIdFromLBits(_loc29_.lBits);
            _loc29_.type = PetManager.petTypeForDefId(_loc29_.defId);
            _loc29_.isGround = PetManager.isGround(_loc29_.type);
            _loc30_ = gMainFrame.userInfo.getUserInfoByUserName(_loc3_);
            _loc31_ = new AvatarInfo();
            _loc31_.init(_loc10_,_loc15_,_loc3_,_loc4_,_loc12_,_loc14_,0,_loc29_,_loc13_,0,0,0,_loc18_);
            if(!_loc30_)
            {
               _loc33_ = new Array(1);
               _loc33_[_loc10_] = _loc31_;
               _loc30_ = new UserInfo();
               _loc30_.init(_loc3_,_loc4_,_loc33_,_loc10_,_loc8_);
            }
            else
            {
               _loc30_.currPerUserAvId = _loc10_;
               _loc30_.accountType = _loc8_;
               _loc30_.addAvatarToList(_loc31_);
            }
            _loc30_.userNameModeratedFlag = _loc21_;
            _loc30_.nameBarData = _loc11_;
            _loc30_.isGuide = _loc9_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc3_,_loc30_);
         }
         var _loc7_:String = _loc3_.toLowerCase();
         if(_agQueue[_loc7_])
         {
            _agQueue[_loc7_](_loc3_,_loc5_ < 3,_loc6_);
            delete _agQueue[_loc7_];
         }
         if(_agsQueue[_loc20_])
         {
            _agsQueue[_loc20_](_loc3_,_loc5_ < 3,_loc6_,_loc20_);
            delete _agsQueue[_loc20_];
         }
      }
      
      private static function avatarListResponse(param1:Array) : void
      {
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:UserInfo = null;
         var _loc13_:int = 0;
         var _loc14_:UserInfo = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:String = null;
         var _loc18_:AvatarInfo = null;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:uint = 0;
         var _loc7_:int = 0;
         while(_loc7_ < _loc3_)
         {
            _loc8_ = param1[_loc2_++];
            if(_loc8_.toLowerCase() == gMainFrame.server.userName.toLowerCase())
            {
               _loc6_ = true;
               _loc4_ = uint(param1[_loc2_++]);
               _loc5_ = param1[_loc2_++];
            }
            _loc9_ = int(param1[_loc2_++]);
            _loc10_ = [];
            _loc12_ = gMainFrame.userInfo.getUserInfoByUserName(_loc8_);
            _loc13_ = 0;
            while(_loc13_ < _loc9_)
            {
               _loc15_ = int(param1[_loc2_++]);
               if(_loc13_ == 0)
               {
                  _loc11_ = _loc15_;
               }
               _loc16_ = int(param1[_loc2_++]);
               _loc17_ = param1[_loc2_++];
               if(_loc12_)
               {
                  _loc18_ = _loc12_.getAvatarInfoByPerUserAvId(_loc15_);
                  if(!_loc18_)
                  {
                     _loc18_ = new AvatarInfo();
                     _loc18_.init(_loc15_,_loc17_,_loc8_);
                  }
                  _loc10_[_loc15_] = _loc18_;
               }
               else
               {
                  _loc18_ = new AvatarInfo();
                  _loc18_.init(_loc15_,_loc17_,_loc8_);
                  _loc10_[_loc15_] = _loc18_;
               }
               if(_loc6_)
               {
                  avSlotInfo[_loc15_] = {
                     "slotId":_loc13_,
                     "avInvId":_loc16_
                  };
               }
               _loc13_++;
            }
            _loc14_ = new UserInfo();
            if(_loc12_)
            {
               _loc12_.avList = _loc10_;
               _loc12_.currPerUserAvId = _loc11_;
               _loc12_.uuid = _loc5_;
               _loc14_ = _loc12_;
            }
            else
            {
               _loc14_.init(_loc8_,_loc5_,_loc10_,_loc11_);
            }
            gMainFrame.userInfo.setUserInfoByUserName(_loc8_,_loc14_);
            _loc7_++;
         }
         if(_loc8_ != gMainFrame.server.userName)
         {
            if(_avatarListResponse != null)
            {
               _avatarListResponse();
            }
         }
         if(_alCallback != null)
         {
            if(_loc6_)
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
   }
}

