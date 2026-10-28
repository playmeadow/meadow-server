package avatar
{
   import com.sbi.client.SFClient;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.FileServerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   
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
      
      private static var _avatarsInRoom:Object;
      
      private static var _gameAvatarAdCallback:Function;
      
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
      
      public static function requestADForAvatar(param1:int, param2:Boolean = true, param3:Function = null, param4:Avatar = null) : void
      {
         _adAvatarQueue.push({
            "a":param4,
            "c":(param2 ? null : param3)
         });
         var _loc5_:Boolean = ItemXtCommManager.hasRequestedFullItemList;
         var _loc6_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByDbAvId(param1);
         if((Boolean(_loc6_)) && _loc6_.type != -1)
         {
            avatarDataResponseIntegrate([_loc6_.dbAvId,_loc6_.avName,_loc6_.userName,_loc6_.type,_loc6_.colors[0],_loc6_.colors[1],_loc6_.colors[2]]);
            if(param2)
            {
               if(param4 == null)
               {
                  throw new Error("requestAvatarData got requestItemList=true but getAvDataAvatar=null!");
               }
               ItemXtCommManager.requestItemListForAvatar(param3,param4,_loc5_);
            }
         }
         else
         {
            if(param2)
            {
               ItemXtCommManager.insertIntoILAvatarQueue(param1,param3,param4);
            }
            sendAvatarDataRequest([param1,param2 ? (_loc5_ ? "2" : "1") : "0"]);
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
      
      public static function requestAvatarShopBuy(param1:Array, param2:Function) : void
      {
         _aaCallback = param2;
         gMainFrame.server.setXtObject_Str("asb",param1,gMainFrame.server.isWorldZone);
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
      
      public static function setGameAvatarAdCallback(param1:Function) : void
      {
         _gameAvatarAdCallback = param1;
      }
      
      public static function sendAvatarFiveMinutesUpdate(param1:Array) : void
      {
         gMainFrame.server.setXtObject_Str("af",param1);
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
               "iconMediaId":int(_loc6_.iconMediaRefId)
            };
         }
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            gMainFrame.setAvatarOffsets(_loc5_);
            gMainFrame.userInfo.setAvatarDefs(_loc4_);
         }
         var _loc7_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc7_.init(DefPacksDefHelper.DEF_LAYER,liDefPacksResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LAYER] = _loc7_;
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
         var _loc13_:Boolean = false;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc25_:AvatarInfo = null;
         var _loc26_:AvatarInfo = null;
         var _loc27_:UserInfo = null;
         var _loc28_:Array = null;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:String = param1[_loc2_++];
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:uint = uint(param1[_loc2_++]);
         var _loc7_:uint = uint(param1[_loc2_++]);
         var _loc8_:uint = uint(param1[_loc2_++]);
         var _loc9_:String = param1[_loc2_++];
         var _loc10_:int = int(param1[_loc2_++]);
         var _loc11_:int = int(param1[_loc2_++]);
         var _loc12_:int = int(param1[_loc2_++]);
         var _loc14_:int = -1;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         if(_loc4_ == gMainFrame.userInfo.myUserName)
         {
            _loc13_ = true;
            _loc14_ = int(param1[_loc2_++]);
            _loc15_ = int(param1[_loc2_++]);
            _loc16_ = int(param1[_loc2_++]);
            _loc19_ = int(param1[_loc2_++]);
            _loc20_ = int(param1[_loc2_++]);
            _loc21_ = int(param1[_loc2_++]);
            _loc22_ = int(param1[_loc2_++]);
            _loc23_ = int(param1[_loc2_++]);
         }
         var _loc24_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc4_);
         if(_loc24_)
         {
            for each(_loc26_ in _loc24_.avList)
            {
               if(_loc26_.dbAvId == _loc3_)
               {
                  _loc25_ = _loc26_;
                  break;
               }
            }
            _loc24_.nameBarData = _loc10_;
         }
         if(_loc25_)
         {
            _loc25_.avName = _loc9_;
            _loc25_.userName = _loc4_;
            _loc25_.type = _loc5_;
            _loc25_.colors = [_loc6_,_loc7_,_loc8_];
            _loc25_.currEnviroType = _loc11_;
            _loc25_.questLevel = _loc12_;
            if(_loc13_)
            {
               if(_loc14_ >= 0)
               {
                  avSlotInfo[_loc25_.dbAvId].avInvId = _loc14_;
               }
               _loc25_.landPetInvId = _loc15_;
               _loc25_.oceanPetInvId = _loc16_;
               _loc25_.questXp = _loc17_;
               _loc25_.healthBase = _loc23_;
               _loc25_.attackBase = _loc19_;
               _loc25_.attackMax = _loc20_;
               _loc25_.defenseBase = _loc21_;
               _loc25_.defenseMax = _loc22_;
            }
         }
         else
         {
            _loc25_ = new AvatarInfo();
            _loc25_.init(_loc3_,_loc9_,_loc4_,_loc5_,[_loc6_,_loc7_,_loc8_]);
            _loc25_.questLevel = _loc12_;
            if(_loc13_)
            {
               if(_loc14_ >= 0)
               {
                  avSlotInfo[_loc25_.dbAvId] = {
                     "slotId":-1,
                     "avInvId":_loc14_
                  };
               }
               _loc25_.landPetInvId = _loc15_;
               _loc25_.oceanPetInvId = _loc16_;
               _loc25_.questXp = _loc17_;
               _loc25_.healthBase = _loc23_;
               _loc25_.attackBase = _loc19_;
               _loc25_.attackMax = _loc20_;
               _loc25_.defenseBase = _loc21_;
               _loc25_.defenseMax = _loc22_;
            }
            if(_loc24_)
            {
               _loc24_.addAvatarToList(_loc25_);
               _loc24_.nameBarData = _loc10_;
            }
            else
            {
               _loc27_ = new UserInfo();
               _loc28_ = new Array();
               _loc28_[_loc25_.dbAvId] = _loc25_;
               _loc27_.init(_loc4_,_loc28_,_loc25_.dbAvId);
               _loc27_.nameBarData = _loc10_;
               gMainFrame.userInfo.setUserInfoByUserName(_loc4_,_loc27_);
            }
         }
         avatarDataResponseIntegrate([_loc3_,_loc9_,_loc4_,_loc5_,_loc6_,_loc7_,_loc8_]);
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
               if(_adAvatarQueue[_loc5_].a.dbAvId == param1[0])
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
            _loc2_.dbAvId = int(param1[_loc8_++]);
            _loc2_.avName = param1[_loc8_++];
            _loc2_.userName = param1[_loc8_++];
            _loc2_.avTypeId = int(param1[_loc8_++]);
            _loc2_.setColors(uint(param1[_loc8_++]),uint(param1[_loc8_++]),uint(param1[_loc8_++]));
            if(!_loc4_)
            {
               if(_loc3_ != null)
               {
                  _loc3_();
                  _loc3_ = null;
               }
               if(_gameAvatarAdCallback != null)
               {
                  _gameAvatarAdCallback(_loc2_);
               }
            }
            _buddyCardUpdateDropDownHandler(_loc2_.userName);
         }
         else if(_loc3_ != null)
         {
            DebugUtility.debugTrace("calling loadDataAvatarResult even though dataAvatar was null...");
            _loc3_();
            _loc3_ = null;
         }
      }
      
      private static function avatarGetResponse(param1:Array) : void
      {
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Array = null;
         var _loc13_:String = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:Array = null;
         var _loc21_:* = 0;
         var _loc22_:UserInfo = null;
         var _loc23_:AvatarInfo = null;
         var _loc24_:Item = null;
         var _loc25_:Array = null;
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:int = _loc4_ == 0 ? SFClient.STATUS_OFFLINE_ACTIVE : (_loc4_ == 1 ? SFClient.STATUS_ONLINE : (_loc4_ == 2 ? SFClient.STATUS_OFFLINE_ARCHIVED : SFClient.STATUS_OFFLINE_UNKNOWN));
         if(_loc4_ <= 1)
         {
            _loc7_ = int(param1[_loc2_++]);
            _loc8_ = param1[_loc2_++] == "1";
            _loc9_ = int(param1[_loc2_++]);
            _loc10_ = int(param1[_loc2_++]);
            _loc11_ = int(param1[_loc2_++]);
            _loc12_ = new Array(3);
            _loc12_[0] = uint(param1[_loc2_++]);
            _loc12_[1] = uint(param1[_loc2_++]);
            _loc12_[2] = uint(param1[_loc2_++]);
            _loc13_ = param1[_loc2_++];
            _loc14_ = int(param1[_loc2_++]);
            _loc15_ = int(param1[_loc2_++]);
            _loc16_ = int(param1[_loc2_++]);
            _loc17_ = int(param1[_loc2_++]);
            _loc18_ = int(param1[_loc2_++]);
            _loc19_ = _loc15_ > 0 ? 3 : 2;
            _loc20_ = new Array(_loc17_ + _loc19_);
            _loc21_ = 0;
            var _loc26_:Number;
            _loc20_[_loc26_ = _loc21_++] = ItemXtCommManager.getBodyModFromDefId(1,_loc11_,true);
            var _loc27_:Number;
            _loc20_[_loc27_ = _loc21_++] = ItemXtCommManager.getBodyModFromDefId(_loc14_,_loc11_,true);
            if(_loc15_ > 0)
            {
               var _loc28_:Number;
               _loc20_[_loc28_ = _loc21_++] = ItemXtCommManager.getBodyModFromDefId(_loc15_,_loc11_,true);
            }
            while(_loc21_ < _loc17_ + _loc19_)
            {
               _loc24_ = new Item();
               _loc24_.init(int(param1[_loc2_++]),_loc21_,uint(param1[_loc2_++]));
               _loc24_.setInUse(_loc9_,true);
               _loc20_[_loc21_] = _loc24_;
               _loc21_++;
            }
            _loc22_ = gMainFrame.userInfo.getUserInfoByUserName(_loc3_);
            _loc23_ = new AvatarInfo();
            _loc23_.init(_loc9_,_loc13_,_loc3_,_loc11_,_loc12_,0,0,0,0,_loc16_);
            if(!_loc22_)
            {
               _loc25_ = new Array(1);
               _loc25_[_loc9_] = _loc23_;
               _loc22_ = new UserInfo();
               _loc22_.init(_loc3_,_loc25_,_loc9_,_loc7_);
            }
            else
            {
               _loc22_.currDbAvId = _loc9_;
               _loc22_.accountType = _loc7_;
               _loc22_.addAvatarToList(_loc23_);
            }
            _loc22_.nameBarData = _loc10_;
            _loc22_.isGuide = _loc8_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc3_,_loc22_);
         }
         var _loc6_:String = _loc3_.toLowerCase();
         if(_agQueue[_loc6_])
         {
            _agQueue[_loc6_](_loc3_,_loc4_ < 3,_loc5_);
            delete _agQueue[_loc6_];
         }
         if(_agsQueue[_loc18_])
         {
            _agsQueue[_loc18_](_loc3_,_loc4_ < 3,_loc5_,_loc18_);
            delete _agsQueue[_loc18_];
         }
      }
      
      private static function avatarListResponse(param1:Array) : void
      {
         var _loc5_:Boolean = false;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:UserInfo = null;
         var _loc12_:int = 0;
         var _loc13_:UserInfo = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc17_:AvatarInfo = null;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = -1;
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_)
         {
            _loc7_ = param1[_loc2_++];
            if(_loc7_ == gMainFrame.server.userName)
            {
               _loc5_ = true;
               _loc4_ = int(param1[_loc2_++]);
            }
            _loc8_ = int(param1[_loc2_++]);
            _loc9_ = [];
            _loc11_ = gMainFrame.userInfo.getUserInfoByUserName(_loc7_);
            _loc12_ = 0;
            while(_loc12_ < _loc8_)
            {
               _loc14_ = int(param1[_loc2_++]);
               if(_loc12_ == 0)
               {
                  _loc10_ = _loc14_;
               }
               _loc15_ = int(param1[_loc2_++]);
               _loc16_ = param1[_loc2_++];
               if(_loc11_)
               {
                  _loc17_ = _loc11_.getAvatarInfoByDbAvId(_loc14_);
                  if(!_loc17_)
                  {
                     _loc17_ = new AvatarInfo();
                     _loc17_.init(_loc14_,_loc16_,_loc7_);
                     if(_loc5_)
                     {
                        avSlotInfo[_loc14_] = {
                           "slotId":_loc12_,
                           "avInvId":_loc15_
                        };
                     }
                  }
                  _loc9_[_loc14_] = _loc17_;
               }
               else
               {
                  _loc17_ = new AvatarInfo();
                  _loc17_.init(_loc14_,_loc16_,_loc7_);
                  if(_loc5_)
                  {
                     avSlotInfo[_loc14_] = {
                        "slotId":_loc12_,
                        "avInvId":_loc15_
                     };
                  }
                  _loc9_[_loc14_] = _loc17_;
               }
               _loc12_++;
            }
            _loc13_ = new UserInfo();
            _loc13_.init(_loc7_,_loc9_,_loc10_);
            gMainFrame.userInfo.setUserInfoByUserName(_loc7_,_loc13_);
            _loc6_++;
         }
         if(_loc7_ != gMainFrame.server.userName)
         {
            if(_avatarListResponse != null)
            {
               _avatarListResponse();
            }
         }
         if(_alCallback != null)
         {
            if(_loc4_ >= 0)
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
   }
}

