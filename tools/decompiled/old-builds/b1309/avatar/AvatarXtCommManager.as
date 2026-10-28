package avatar
{
   import collection.AvatarDefCollection;
   import collection.CustomAvatarDefCollection;
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
         var _loc5_:Boolean = gMainFrame.userInfo.myUserName.toLowerCase() == param4.userName.toLowerCase() ? ItemXtCommManager.hasRequestedFullItemList : true;
         var _loc6_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(param4.userName,param1);
         if(_loc6_ && _loc6_.type != -1)
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
            case "an":
               avatarNamebarUpdateResponse(_loc2_);
               break;
            default:
               throw new Error("AvatarXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function avatarInfoResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:int = 0;
         DefPacksDefHelper.mediaArray[1003] = null;
         var _loc3_:Object = param1.def;
         var _loc5_:AvatarDefCollection = new AvatarDefCollection();
         var _loc4_:Array = [];
         for each(var _loc6_:Object in _loc3_)
         {
            _loc4_[int(_loc6_.id)] = new Point(_loc6_.x,_loc6_.y);
            _loc5_.setAvatrDefItem(int(_loc6_.id),new AvatarDef(int(_loc6_.id),uint(_loc6_.colorLayer1),uint(_loc6_.colorLayer2),uint(_loc6_.colorLayer3),int(_loc6_.basePatternId),int(_loc6_.baseEyesId),_loc6_.membersOnly == "1",int(_loc6_.enviroTypeFlags),int(_loc6_.cost),int(_loc6_.titleStrRef),int(_loc6_.availability),int(_loc6_.attackItemRefId),int(_loc6_.iconMediaRefId),int(_loc6_.status)));
         }
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            gMainFrame.setAvatarOffsets(_loc4_);
            gMainFrame.userInfo.setAvatarDefs(_loc5_);
         }
         var _loc7_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc7_.init(1057,customAvatarDefPacksResponse,null,2);
         DefPacksDefHelper.mediaArray[1057] = _loc7_;
      }
      
      private static function customAvatarDefPacksResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:int = 0;
         var _loc5_:CustomAvatarDef = null;
         DefPacksDefHelper.mediaArray[1057] = null;
         var _loc4_:Object = param1.def;
         var _loc3_:CustomAvatarDefCollection = new CustomAvatarDefCollection();
         for each(var _loc6_:Object in _loc4_)
         {
            if(_loc6_.avatarIconRefId != "0")
            {
               _loc5_ = new CustomAvatarDef(int(_loc6_.id),int(_loc6_.avatarRef),int(_loc6_.iconRefId),int(_loc6_.particleRefId),int(_loc6_.patternRefId),int(_loc6_.titleStrRef),int(_loc6_.avatarIconRefId));
               _loc3_.setCustomAvatarDefItem(_loc5_.defId,_loc5_);
            }
         }
         gMainFrame.userInfo.setCustomAvatarDefs(_loc3_);
         var _loc7_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc7_.init(1027,liDefPacksResponse,null,2);
         DefPacksDefHelper.mediaArray[1027] = _loc7_;
      }
      
      private static function liDefPacksResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[1027] = null;
         var _loc2_:Object = param1.def;
         var _loc3_:Object = {};
         for each(var _loc4_:Object in _loc2_)
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
         var _loc27_:Boolean = false;
         var _loc35_:int = 0;
         var _loc5_:int = 0;
         var _loc30_:int = 0;
         var _loc29_:int = 0;
         var _loc19_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc23_:int = 0;
         var _loc11_:AvatarInfo = null;
         var _loc31_:UserInfo = null;
         var _loc18_:Array = null;
         var _loc34_:int = 2;
         var _loc37_:String = param1[_loc34_++];
         var _loc20_:String = param1[_loc34_++];
         var _loc21_:int = int(param1[_loc34_++]);
         var _loc14_:int = int(param1[_loc34_++]);
         var _loc25_:int = int(param1[_loc34_++]);
         var _loc12_:int = int(param1[_loc34_++]);
         var _loc32_:int = int(param1[_loc34_++]);
         var _loc9_:int = int(param1[_loc34_++]);
         var _loc10_:int = int(param1[_loc34_++]);
         var _loc28_:int = int(param1[_loc34_++]);
         var _loc13_:uint = uint(param1[_loc34_++]);
         var _loc15_:uint = uint(param1[_loc34_++]);
         var _loc16_:uint = uint(param1[_loc34_++]);
         var _loc26_:String = param1[_loc34_++];
         var _loc4_:int = int(param1[_loc34_++]);
         var _loc36_:int = -1;
         var _loc17_:int = 0;
         var _loc38_:int = 0;
         var _loc33_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:String = "";
         if(_loc37_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _loc27_ = true;
            _loc36_ = int(param1[_loc34_++]);
            _loc17_ = int(param1[_loc34_++]);
            _loc38_ = int(param1[_loc34_++]);
            _loc35_ = int(param1[_loc34_++]);
            _loc5_ = int(param1[_loc34_++]);
            _loc30_ = int(param1[_loc34_++]);
            _loc29_ = int(param1[_loc34_++]);
            _loc19_ = int(param1[_loc34_++]);
         }
         else
         {
            _loc3_ = int(param1[_loc34_++]);
            _loc7_ = int(param1[_loc34_++]);
            _loc23_ = int(param1[_loc34_++]);
            _loc8_ = param1[_loc34_++];
         }
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc37_);
         if(_loc2_)
         {
            for each(var _loc22_:AvatarInfo in _loc2_.avList)
            {
               if(_loc22_.perUserAvId == _loc9_)
               {
                  _loc11_ = _loc22_;
                  break;
               }
            }
            _loc2_.uuid = _loc20_;
            _loc2_.nameBarData = _loc21_;
            _loc2_.userNameModeratedFlag = _loc25_;
            _loc2_.timeLeftHostingCustomParty = _loc12_;
            _loc2_.daysSinceLastLogin = _loc32_;
         }
         var _loc24_:Object = {
            "name":_loc8_,
            "lBits":_loc3_,
            "uBits":_loc7_,
            "eBits":_loc23_
         };
         _loc24_.defId = PetManager.getDefIdFromLBits(_loc24_.lBits);
         _loc24_.type = PetManager.petTypeForDefId(_loc24_.defId);
         _loc24_.isGround = PetManager.isGround(_loc24_.type);
         if(_loc11_)
         {
            _loc11_.avName = _loc26_;
            _loc11_.userName = _loc37_;
            _loc11_.uuid = _loc20_;
            _loc11_.type = _loc10_;
            _loc11_.colors = [_loc13_,_loc15_,_loc16_];
            _loc11_.currEnviroType = _loc14_;
            _loc11_.questLevel = _loc4_;
            _loc11_.currPet = _loc24_;
            _loc11_.customAvId = _loc28_;
            if(_loc27_)
            {
               if(_loc36_ >= 0)
               {
                  avSlotInfo[_loc11_.perUserAvId].avInvId = _loc36_;
               }
               _loc11_.landPetInvId = _loc17_;
               _loc11_.oceanPetInvId = _loc38_;
               _loc11_.questXp = _loc33_;
               _loc11_.healthBase = _loc19_;
               _loc11_.attackBase = _loc35_;
               _loc11_.attackMax = _loc5_;
               _loc11_.defenseBase = _loc30_;
               _loc11_.defenseMax = _loc29_;
            }
         }
         else
         {
            _loc11_ = new AvatarInfo();
            _loc11_.init(_loc9_,_loc26_,_loc37_,_loc20_,_loc10_,[_loc13_,_loc15_,_loc16_],0,_loc24_,_loc28_);
            _loc11_.questLevel = _loc4_;
            if(_loc27_)
            {
               if(_loc36_ >= 0)
               {
                  avSlotInfo[_loc11_.perUserAvId].avInvId = _loc36_;
               }
               _loc11_.landPetInvId = _loc17_;
               _loc11_.oceanPetInvId = _loc38_;
               _loc11_.questXp = _loc33_;
               _loc11_.healthBase = _loc19_;
               _loc11_.attackBase = _loc35_;
               _loc11_.attackMax = _loc5_;
               _loc11_.defenseBase = _loc30_;
               _loc11_.defenseMax = _loc29_;
            }
            if(_loc2_)
            {
               _loc2_.addAvatarToList(_loc11_);
               _loc2_.uuid = _loc20_;
               _loc2_.nameBarData = _loc21_;
               _loc2_.userNameModeratedFlag = _loc25_;
               _loc2_.timeLeftHostingCustomParty = _loc12_;
               _loc2_.daysSinceLastLogin = _loc32_;
            }
            else
            {
               _loc31_ = new UserInfo();
               _loc18_ = [];
               _loc18_[_loc11_.perUserAvId] = _loc11_;
               _loc31_.init(_loc37_,_loc20_,_loc18_,_loc11_.perUserAvId,1,_loc25_,_loc12_,_loc32_);
               _loc31_.nameBarData = _loc21_;
               gMainFrame.userInfo.setUserInfoByUserName(_loc37_,_loc31_);
            }
         }
         avatarDataResponseIntegrate([_loc9_,_loc26_,_loc37_,_loc20_,_loc10_,_loc28_,_loc13_,_loc15_,_loc16_]);
      }
      
      private static function avatarDataResponseIntegrate(param1:Array) : void
      {
         var _loc4_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Avatar = null;
         var _loc3_:int = 0;
         var _loc5_:Avatar = null;
         var _loc2_:Function = null;
         if(_adAvatarQueue && _adAvatarQueue.length > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < _adAvatarQueue.length)
            {
               if(_adAvatarQueue[_loc6_].a.perUserAvId == param1[0])
               {
                  _loc5_ = _adAvatarQueue[_loc6_].a;
                  _loc2_ = _adAvatarQueue[_loc6_].c;
                  _adAvatarQueue.splice(_loc6_,1);
                  break;
               }
               _loc6_++;
            }
         }
         else if(_avatarsInRoom)
         {
            _loc7_ = param1[2];
            if(_getAvatarByUsername != null)
            {
               _loc8_ = _getAvatarByUsername(_loc7_);
            }
            if(_loc8_)
            {
               _loc5_ = _loc8_;
               _loc4_ = true;
            }
         }
         if(_loc5_)
         {
            _loc3_ = 0;
            _loc5_.perUserAvId = param1[_loc3_++];
            _loc5_.avName = param1[_loc3_++];
            _loc5_.userName = param1[_loc3_++];
            _loc5_.uuid = param1[_loc3_++];
            _loc5_.avTypeId = int(param1[_loc3_++]);
            _loc5_.customAvId = int(param1[_loc3_++]);
            _loc5_.setColors(uint(param1[_loc3_++]),uint(param1[_loc3_++]),uint(param1[_loc3_++]));
            if(!_loc4_)
            {
               if(_loc2_ != null)
               {
                  _loc2_(true);
                  _loc2_ = null;
               }
            }
            _buddyCardUpdateDropDownHandler(_loc5_.userName);
         }
         else if(_loc2_ != null)
         {
            DebugUtility.debugTrace("calling loadDataAvatarResult even though dataAvatar was null...");
            _loc2_(false);
            _loc2_ = null;
         }
      }
      
      private static function avatarGetResponse(param1:Array) : void
      {
         var _loc23_:int = 0;
         var _loc31_:Boolean = false;
         var _loc30_:int = 0;
         var _loc24_:int = 0;
         var _loc6_:int = 0;
         var _loc18_:int = 0;
         var _loc29_:int = 0;
         var _loc10_:Array = null;
         var _loc7_:String = null;
         var _loc16_:int = 0;
         var _loc33_:int = 0;
         var _loc5_:int = 0;
         var _loc13_:int = 0;
         var _loc12_:int = 0;
         var _loc17_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         var _loc20_:int = 0;
         var _loc11_:String = null;
         var _loc15_:int = 0;
         var _loc34_:Array = null;
         var _loc25_:int = 0;
         var _loc28_:Item = null;
         var _loc22_:Object = null;
         var _loc2_:UserInfo = null;
         var _loc19_:AvatarInfo = null;
         var _loc14_:Array = null;
         var _loc26_:int = 2;
         var _loc27_:String = param1[_loc26_++];
         var _loc9_:String = param1[_loc26_++];
         var _loc32_:int = int(param1[_loc26_++]);
         var _loc4_:int = _loc32_ == 0 ? 0 : (_loc32_ == 1 ? 1 : (_loc32_ == 2 ? -1 : -2));
         if(_loc32_ >= 2 && GuiManager.isVersionPopupOpen())
         {
            _loc32_ = -2;
            _loc4_ = -3;
         }
         if(_loc32_ == 0 || _loc32_ == 1)
         {
            _loc23_ = int(param1[_loc26_++]);
            _loc31_ = param1[_loc26_++] == "1";
            _loc30_ = int(param1[_loc26_++]);
            _loc24_ = int(param1[_loc26_++]);
            _loc6_ = int(param1[_loc26_++]);
            _loc18_ = int(param1[_loc26_++]);
            _loc29_ = int(param1[_loc26_++]);
            _loc10_ = new Array(3);
            _loc10_[0] = uint(param1[_loc26_++]);
            _loc10_[1] = uint(param1[_loc26_++]);
            _loc10_[2] = uint(param1[_loc26_++]);
            _loc7_ = param1[_loc26_++];
            _loc16_ = int(param1[_loc26_++]);
            _loc33_ = int(param1[_loc26_++]);
            _loc5_ = int(param1[_loc26_++]);
            _loc13_ = int(param1[_loc26_++]);
            _loc12_ = int(param1[_loc26_++]);
            _loc17_ = int(param1[_loc26_++]);
            _loc3_ = int(param1[_loc26_++]);
            _loc8_ = int(param1[_loc26_++]);
            _loc20_ = int(param1[_loc26_++]);
            _loc11_ = param1[_loc26_++];
            _loc15_ = _loc33_ > 0 ? 3 : 2;
            _loc34_ = new Array(_loc13_ + _loc15_);
            _loc25_ = 0;
            _loc34_[_loc25_++] = ItemXtCommManager.getBodyModFromDefId(1,_loc24_,true);
            _loc34_[_loc25_++] = ItemXtCommManager.getBodyModFromDefId(_loc16_,_loc24_,true);
            if(_loc33_ > 0)
            {
               _loc34_[_loc25_++] = ItemXtCommManager.getBodyModFromDefId(_loc33_,_loc24_,true);
            }
            DebugUtility.debugTrace("avatarGetResponse userName:" + _loc27_ + " numClothingItems:" + _loc13_ + " numBodyModItems:" + _loc15_ + " pattDefId:" + _loc33_);
            while(_loc25_ < _loc13_ + _loc15_)
            {
               _loc28_ = new Item();
               _loc28_.init(int(param1[_loc26_++]),_loc25_,uint(param1[_loc26_++]));
               _loc28_.setInUse(_loc24_,true);
               _loc34_[_loc25_] = _loc28_;
               _loc25_++;
            }
            _loc22_ = {
               "name":_loc11_,
               "lBits":_loc3_,
               "uBits":_loc8_,
               "eBits":_loc20_
            };
            _loc22_.defId = PetManager.getDefIdFromLBits(_loc22_.lBits);
            _loc22_.type = PetManager.petTypeForDefId(_loc22_.defId);
            _loc22_.isGround = PetManager.isGround(_loc22_.type);
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_loc27_);
            _loc19_ = new AvatarInfo();
            _loc19_.init(_loc24_,_loc7_,_loc27_,_loc9_,_loc18_,_loc10_,0,_loc22_,_loc29_,0,0,0,_loc5_);
            if(!_loc2_)
            {
               _loc14_ = new Array(1);
               _loc14_[_loc24_] = _loc19_;
               _loc2_ = new UserInfo();
               _loc2_.init(_loc27_,_loc9_,_loc14_,_loc24_,_loc23_,0,-1,_loc30_);
            }
            else
            {
               _loc2_.currPerUserAvId = _loc24_;
               _loc2_.accountType = _loc23_;
               _loc2_.addAvatarToList(_loc19_);
               _loc2_.daysSinceLastLogin = _loc30_;
            }
            _loc2_.userNameModeratedFlag = _loc17_;
            _loc2_.nameBarData = _loc6_;
            _loc2_.isGuide = _loc31_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc27_,_loc2_);
         }
         var _loc21_:String = _loc27_.toLowerCase();
         if(_agQueue[_loc21_])
         {
            _agQueue[_loc21_](_loc27_,_loc32_ < 3,_loc4_);
            delete _agQueue[_loc21_];
         }
         if(_agsQueue[_loc12_])
         {
            _agsQueue[_loc12_](_loc27_,_loc32_ < 3,_loc4_,_loc12_);
            delete _agsQueue[_loc12_];
         }
      }
      
      private static function avatarListResponse(param1:Array) : void
      {
         var _loc12_:String = null;
         var _loc13_:Boolean = false;
         var _loc6_:int = 0;
         var _loc11_:String = null;
         var _loc16_:int = 0;
         var _loc17_:Array = null;
         var _loc2_:int = 0;
         var _loc4_:UserInfo = null;
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         var _loc15_:int = 0;
         var _loc8_:String = null;
         var _loc5_:AvatarInfo = null;
         var _loc14_:UserInfo = null;
         var _loc10_:int = 2;
         var _loc3_:int = int(param1[_loc10_++]);
         var _loc18_:uint = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc3_)
         {
            _loc11_ = param1[_loc10_++];
            if(_loc11_.toLowerCase() == gMainFrame.server.userName.toLowerCase())
            {
               _loc13_ = true;
               _loc18_ = uint(param1[_loc10_++]);
               _loc12_ = param1[_loc10_++];
            }
            _loc16_ = int(param1[_loc10_++]);
            _loc17_ = [];
            _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(_loc11_);
            _loc9_ = 0;
            while(_loc9_ < _loc16_)
            {
               _loc7_ = int(param1[_loc10_++]);
               if(_loc9_ == 0)
               {
                  _loc2_ = _loc7_;
               }
               _loc15_ = int(param1[_loc10_++]);
               _loc8_ = param1[_loc10_++];
               if(_loc4_)
               {
                  _loc5_ = _loc4_.getAvatarInfoByPerUserAvId(_loc7_);
                  if(!_loc5_)
                  {
                     _loc5_ = new AvatarInfo();
                     _loc5_.init(_loc7_,_loc8_,_loc11_);
                  }
                  _loc17_[_loc7_] = _loc5_;
               }
               else
               {
                  _loc5_ = new AvatarInfo();
                  _loc5_.init(_loc7_,_loc8_,_loc11_);
                  _loc17_[_loc7_] = _loc5_;
               }
               if(_loc13_)
               {
                  avSlotInfo[_loc7_] = {
                     "slotId":_loc9_,
                     "avInvId":_loc15_
                  };
               }
               _loc9_++;
            }
            _loc14_ = new UserInfo();
            if(_loc4_)
            {
               _loc4_.avList = _loc17_;
               _loc4_.currPerUserAvId = _loc2_;
               _loc4_.uuid = _loc12_;
               _loc14_ = _loc4_;
            }
            else
            {
               _loc14_.init(_loc11_,_loc12_,_loc17_,_loc2_);
            }
            gMainFrame.userInfo.setUserInfoByUserName(_loc11_,_loc14_);
            _loc6_++;
         }
         if(_loc11_ != gMainFrame.server.userName)
         {
            if(_avatarListResponse != null)
            {
               _avatarListResponse();
            }
         }
         if(_alCallback != null)
         {
            if(_loc13_)
            {
               _alCallback(_loc18_);
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
         var _loc5_:int = 2;
         var _loc2_:int = int(param1[_loc5_++]);
         var _loc4_:AvatarWorldView = AvatarManager.avatarViewList[_loc2_];
         if(_loc4_ == null)
         {
            DebugUtility.debugTrace("ERROR: invalid avatar worldview when updating namebar data");
            return;
         }
         var _loc3_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc4_.userName);
         if(_loc3_ == null)
         {
            DebugUtility.debugTrace("ERROR: invalid user info when updating namebar data");
            return;
         }
         _loc3_.nameBarData = int(param1[_loc5_++]);
         _loc4_.currAvatar.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
      }
   }
}

