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
      
      private static var _avatarsInRoom:Object;
      
      private static var _gameAvatarAdCallback:Function;
      
      public function AvatarXtCommManager()
      {
         super();
      }
      
      public static function init(initACResponse:Function = null, initAUResponse:Function = null, initAPResponse:Function = null, initARResponse:Function = null, initALResponse:Function = null, initAvatarsInRoom:Object = null, initGetAvatarByUserName:Function = null, initASResponse:Function = null, initBuddyCardUpdateDropDown:Function = null) : void
      {
         _avatarCreateResponse = initACResponse;
         _avatarUpdateResponse = initAUResponse;
         _avatarPaintResponse = initAPResponse;
         _avatarRemoveResponse = initARResponse;
         _avatarListResponse = initALResponse;
         _getAvatarByUsername = initGetAvatarByUserName;
         _asCallback = initASResponse;
         _buddyCardUpdateDropDownHandler = initBuddyCardUpdateDropDown;
         _adAvatarQueue = [];
         avSlotInfo = new Object();
         _agQueue = new Dictionary(false);
         _agsQueue = new Dictionary(false);
         _avatarsInRoom = initAvatarsInRoom;
         XtReplyDemuxer.addModule(handleXtReply,"a");
      }
      
      public static function destroy() : void
      {
         _adAvatarQueue = null;
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function requestAvatarMake(initHandleCreateAvatarData:Function) : void
      {
         _handleCreateAvatarData = initHandleCreateAvatarData;
         gMainFrame.server.setXtObject_Str("am",[],gMainFrame.server.isWorldZone);
      }
      
      public static function requestAvatarInfo(setAvatarInfoCallback:Function) : void
      {
         var dpdh:DefPacksDefHelper = null;
         _avatarInfoCallback = setAvatarInfoCallback;
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
            dpdh = new DefPacksDefHelper();
            dpdh.init(DefPacksDefHelper.DEF_AVATAR,avatarInfoResponse,null,FileServerEvent.AMF3_TYPE);
            DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_AVATAR] = dpdh;
         }
      }
      
      public static function requestADForAvatar(getPerUserAvId:int, requestItemList:Boolean, getAvDataCallback:Function, getAvDataAvatar:Avatar) : void
      {
         _adAvatarQueue.push({
            "a":getAvDataAvatar,
            "c":(requestItemList ? null : getAvDataCallback)
         });
         var wasItemListAlreadyRequested:Boolean = gMainFrame.userInfo.myUserName == getAvDataAvatar.userName ? ItemXtCommManager.hasRequestedFullItemList : true;
         var cachedInfo:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(getAvDataAvatar.userName,getPerUserAvId);
         if(Boolean(cachedInfo) && cachedInfo.type != -1)
         {
            avatarDataResponseIntegrate([cachedInfo.perUserAvId,cachedInfo.avName,cachedInfo.userName,cachedInfo.type,cachedInfo.colors[0],cachedInfo.colors[1],cachedInfo.colors[2]]);
            if(requestItemList)
            {
               if(getAvDataAvatar == null)
               {
                  throw new Error("requestAvatarData got requestItemList=true but getAvDataAvatar=null!");
               }
               if(getAvDataAvatar.userName != gMainFrame.userInfo.myUserName)
               {
                  ItemXtCommManager.requestItemListForAvatar(getAvDataCallback,getAvDataAvatar,!wasItemListAlreadyRequested);
               }
               else
               {
                  getAvDataCallback();
               }
            }
         }
         else
         {
            if(requestItemList)
            {
               ItemXtCommManager.insertIntoILAvatarQueue(getPerUserAvId,getAvDataCallback,getAvDataAvatar);
            }
            sendAvatarDataRequest([getAvDataAvatar.userName,getPerUserAvId,requestItemList ? (wasItemListAlreadyRequested ? "2" : "1") : "0"]);
         }
      }
      
      public static function requestAvatarList(alParams:Array, alCallback:Function = null) : void
      {
         _alCallback = alCallback;
         gMainFrame.server.setXtObject_Str("al",alParams,gMainFrame.server.isWorldZone);
      }
      
      public static function requestAvatarBuy(abCallback:Function) : void
      {
         _abCallback = abCallback;
         gMainFrame.server.setXtObject_Str("ab",[]);
      }
      
      public static function requestAvatarSwitch(asParams:Array) : void
      {
         gMainFrame.server.setXtObject_Str("as",asParams);
      }
      
      public static function requestAvatarAdd(aaParams:Array, aaCallback:Function) : void
      {
         _aaCallback = aaCallback;
         gMainFrame.server.setXtObject_Str("aa",aaParams,gMainFrame.server.isWorldZone);
      }
      
      public static function requestAvatarShopBuy(asbParams:Array, asbCallback:Function) : void
      {
         _aaCallback = asbCallback;
         gMainFrame.server.setXtObject_Str("asb",asbParams,gMainFrame.server.isWorldZone);
      }
      
      public static function requestAvatarKill(akParams:Array, akCallback:Function) : void
      {
         _akCallback = akCallback;
         gMainFrame.server.setXtObject_Str("ak",akParams);
      }
      
      public static function requestAvatarOrdain(avIdxs:Array, aoCallback:Function) : void
      {
         _aoCallback = aoCallback;
         gMainFrame.server.setXtObject_Str("ao",avIdxs);
      }
      
      public static function requestAvatarGet(userName:String, callback:Function, isPlayerSearchLookup:Boolean = false) : void
      {
         _agQueue[userName.toLowerCase()] = callback;
         gMainFrame.server.setXtObject_Str("ag",[userName,isPlayerSearchLookup ? "1" : "0"]);
      }
      
      public static function requestAvatarGetBySfsId(sfsUserId:int, callback:Function) : void
      {
         _agsQueue[sfsUserId] = callback;
         gMainFrame.server.setXtObject_Str("ags",[sfsUserId,"0"]);
      }
      
      public static function requestColorChange(colors:Array, nameBarColor:int, requestColorsCallback:Function = null) : void
      {
         if(requestColorsCallback != null)
         {
            _avatarPaintResponse = requestColorsCallback;
         }
         gMainFrame.server.setXtObject_Str("ap",[colors[0],colors[1],colors[2],nameBarColor],gMainFrame.server.isWorldZone);
      }
      
      public static function setGameAvatarAdCallback(callback:Function) : void
      {
         _gameAvatarAdCallback = callback;
      }
      
      public static function sendAvatarPendingFlagsUpdate(bit:int) : void
      {
         gMainFrame.server.setXtObject_Str("af",[bit]);
         gMainFrame.userInfo.pendingFlags |= 1 << bit;
      }
      
      public static function sendAvatarPhotoTakeCheck(callback:Function) : void
      {
         _photoTakeCallback = callback;
         gMainFrame.server.setXtObject_Str("apc",[]);
      }
      
      public static function sendAvatarPhotoTake(callback:Function) : void
      {
         _photoTakeCallback = callback;
         gMainFrame.server.setXtObject_Str("apb",[]);
      }
      
      private static function sendAvatarDataRequest(radParams:Array) : void
      {
         gMainFrame.server.setXtObject_Str("ad",radParams,gMainFrame.server.isWorldZone);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         if(!evt.status)
         {
            DebugUtility.debugTrace("ERROR: AvatarXtCommManager handleXtReply was called with bad evt.status:" + evt.status);
            return;
         }
         var data:Array = evt.obj;
         switch(data[0])
         {
            case "au":
               if(_avatarUpdateResponse != null)
               {
                  _avatarUpdateResponse(data);
               }
               break;
            case "ad":
               avatarDataResponse(data);
               break;
            case "ac":
               if(_avatarCreateResponse != null)
               {
                  _avatarCreateResponse(data);
               }
               break;
            case "ap":
               if(_avatarPaintResponse != null)
               {
                  _avatarPaintResponse(data);
               }
               break;
            case "ag":
               avatarGetResponse(data);
               break;
            case "ar":
               if(_avatarRemoveResponse != null)
               {
                  _avatarRemoveResponse(data);
               }
               break;
            case "al":
               avatarListResponse(data);
               break;
            case "ab":
               avatarBuyResponse(data);
               break;
            case "as":
               avatarSwitchResponse(data);
               break;
            case "aa":
               avatarAddResponse(data);
               break;
            case "ak":
               avatarKillResponse(data);
               break;
            case "am":
               _handleCreateAvatarData(data);
               break;
            case "ao":
               avatarOrdainResponse(data);
               break;
            case "apb":
            case "apc":
               if(_photoTakeCallback != null)
               {
                  _photoTakeCallback(data);
                  _photoTakeCallback = null;
               }
               break;
            default:
               throw new Error("AvatarXtCommManager illegal data:" + data[0]);
         }
      }
      
      private static function avatarInfoResponse(df:DefPacksDefHelper) : void
      {
         var numTypes:int = 0;
         var currObj:Object = null;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_AVATAR] = null;
         var data:Object = df.def;
         var avtDefs:Object = new Object();
         var avtOffsets:Array = [];
         for each(currObj in data)
         {
            avtOffsets[int(currObj.id)] = new Point(currObj.x,currObj.y);
            avtDefs[int(currObj.id)] = {
               "colorLayer1":uint(currObj.colorLayer1),
               "colorLayer2":uint(currObj.colorLayer2),
               "colorLayer3":uint(currObj.colorLayer3),
               "defPattern":int(currObj.basePatternId),
               "defEyes":int(currObj.baseEyesId),
               "isMemOnly":Boolean(currObj.membersOnly == "1"),
               "enviroTypeFlag":int(currObj.enviroTypeFlags),
               "cost":int(currObj.cost),
               "titleStrRef":int(currObj.titleStrRef),
               "availability":int(currObj.availability),
               "attackItemRefId":int(currObj.attackItemRefId),
               "iconMediaId":int(currObj.iconMediaRefId),
               "status":int(currObj.status)
            };
         }
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            gMainFrame.setAvatarOffsets(avtOffsets);
            gMainFrame.userInfo.setAvatarDefs(avtDefs);
         }
         var dpdh:DefPacksDefHelper = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_LAYER,liDefPacksResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LAYER] = dpdh;
      }
      
      private static function liDefPacksResponse(df:DefPacksDefHelper) : void
      {
         var currObj:Object = null;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LAYER] = null;
         var data:Object = df.def;
         var layerInfoObj:Object = {};
         for each(currObj in data)
         {
            layerInfoObj[int(currObj.id)] = int(currObj.layerId);
         }
         gMainFrame.layerInfo = layerInfoObj;
         if(_avatarInfoCallback != null)
         {
            _avatarInfoCallback();
            _avatarInfoCallback = null;
         }
      }
      
      private static function avatarDataResponse(data:Array) : void
      {
         var isForSelf:Boolean = false;
         var attackBase:int = 0;
         var attackMax:int = 0;
         var defenseBase:int = 0;
         var defenseMax:int = 0;
         var healthBase:int = 0;
         var lBits:int = 0;
         var uBits:int = 0;
         var eBits:int = 0;
         var avatarInfo:AvatarInfo = null;
         var avInfo:AvatarInfo = null;
         var setCacheInfo:UserInfo = null;
         var avList:Array = null;
         var adri:int = 2;
         var adUserName:String = data[adri++];
         var adNameBarData:int = int(data[adri++]);
         var currEnviroType:int = int(data[adri++]);
         var userNameModerationFlag:int = int(data[adri++]);
         var adPerUserAvId:int = int(data[adri++]);
         var adType:int = int(data[adri++]);
         var adColor1:uint = uint(data[adri++]);
         var adColor2:uint = uint(data[adri++]);
         var adColor3:uint = uint(data[adri++]);
         var adAvName:String = data[adri++];
         var questLevel:int = int(data[adri++]);
         var adAvInvId:int = -1;
         var landPetInvId:int = 0;
         var oceanPetInvId:int = 0;
         var questXp:int = 0;
         var questXPPercentage:int = 0;
         var petName:String = "";
         if(adUserName == gMainFrame.userInfo.myUserName)
         {
            isForSelf = true;
            adAvInvId = int(data[adri++]);
            landPetInvId = int(data[adri++]);
            oceanPetInvId = int(data[adri++]);
            attackBase = int(data[adri++]);
            attackMax = int(data[adri++]);
            defenseBase = int(data[adri++]);
            defenseMax = int(data[adri++]);
            healthBase = int(data[adri++]);
         }
         else
         {
            lBits = int(data[adri++]);
            uBits = int(data[adri++]);
            eBits = int(data[adri++]);
            petName = data[adri++];
         }
         var userInfo:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(adUserName);
         if(Boolean(userInfo))
         {
            for each(avInfo in userInfo.avList)
            {
               if(avInfo.perUserAvId == adPerUserAvId)
               {
                  avatarInfo = avInfo;
                  break;
               }
            }
            userInfo.nameBarData = adNameBarData;
            userInfo.userNameModeratedFlag = userNameModerationFlag;
         }
         var currPet:Object = {
            "name":petName,
            "lBits":lBits,
            "uBits":uBits,
            "eBits":eBits
         };
         currPet.defId = PetManager.getDefIdFromLBits(currPet.lBits);
         currPet.type = PetManager.petTypeForDefId(currPet.defId);
         currPet.isGround = PetManager.isGround(currPet.type);
         if(Boolean(avatarInfo))
         {
            avatarInfo.avName = adAvName;
            avatarInfo.userName = adUserName;
            avatarInfo.type = adType;
            avatarInfo.colors = [adColor1,adColor2,adColor3];
            avatarInfo.currEnviroType = currEnviroType;
            avatarInfo.questLevel = questLevel;
            avatarInfo.currPet = currPet;
            if(isForSelf)
            {
               if(adAvInvId >= 0)
               {
                  avSlotInfo[avatarInfo.perUserAvId].avInvId = adAvInvId;
               }
               avatarInfo.landPetInvId = landPetInvId;
               avatarInfo.oceanPetInvId = oceanPetInvId;
               avatarInfo.questXp = questXp;
               avatarInfo.healthBase = healthBase;
               avatarInfo.attackBase = attackBase;
               avatarInfo.attackMax = attackMax;
               avatarInfo.defenseBase = defenseBase;
               avatarInfo.defenseMax = defenseMax;
            }
         }
         else
         {
            avatarInfo = new AvatarInfo();
            avatarInfo.init(adPerUserAvId,adAvName,adUserName,adType,[adColor1,adColor2,adColor3],0,currPet);
            avatarInfo.questLevel = questLevel;
            if(isForSelf)
            {
               if(adAvInvId >= 0)
               {
                  avSlotInfo[avatarInfo.perUserAvId] = {
                     "slotId":-1,
                     "avInvId":adAvInvId
                  };
               }
               avatarInfo.landPetInvId = landPetInvId;
               avatarInfo.oceanPetInvId = oceanPetInvId;
               avatarInfo.questXp = questXp;
               avatarInfo.healthBase = healthBase;
               avatarInfo.attackBase = attackBase;
               avatarInfo.attackMax = attackMax;
               avatarInfo.defenseBase = defenseBase;
               avatarInfo.defenseMax = defenseMax;
            }
            if(Boolean(userInfo))
            {
               userInfo.addAvatarToList(avatarInfo);
               userInfo.nameBarData = adNameBarData;
               userInfo.userNameModeratedFlag = userNameModerationFlag;
            }
            else
            {
               setCacheInfo = new UserInfo();
               avList = new Array();
               avList[avatarInfo.perUserAvId] = avatarInfo;
               setCacheInfo.init(adUserName,avList,avatarInfo.perUserAvId,1,userNameModerationFlag);
               setCacheInfo.nameBarData = adNameBarData;
               gMainFrame.userInfo.setUserInfoByUserName(adUserName,setCacheInfo);
            }
         }
         avatarDataResponseIntegrate([adPerUserAvId,adAvName,adUserName,adType,adColor1,adColor2,adColor3]);
      }
      
      private static function avatarDataResponseIntegrate(newAvData:Array) : void
      {
         var avtNotInQueueButInRoom:Boolean = false;
         var i:int = 0;
         var userName:String = null;
         var avt:Avatar = null;
         var di:int = 0;
         var dataAvatar:Avatar = null;
         var loadDataAvatarResult:Function = null;
         if(Boolean(_adAvatarQueue) && _adAvatarQueue.length > 0)
         {
            for(i = 0; i < _adAvatarQueue.length; i++)
            {
               if(_adAvatarQueue[i].a.perUserAvId == newAvData[0])
               {
                  dataAvatar = _adAvatarQueue[i].a;
                  loadDataAvatarResult = _adAvatarQueue[i].c;
                  _adAvatarQueue.splice(i,1);
                  break;
               }
            }
         }
         else if(Boolean(_avatarsInRoom))
         {
            userName = newAvData[2];
            if(_getAvatarByUsername != null)
            {
               avt = _getAvatarByUsername(userName);
            }
            if(Boolean(avt))
            {
               dataAvatar = avt;
               avtNotInQueueButInRoom = true;
            }
         }
         if(Boolean(dataAvatar))
         {
            di = 0;
            dataAvatar.perUserAvId = newAvData[di++];
            dataAvatar.avName = newAvData[di++];
            dataAvatar.userName = newAvData[di++];
            dataAvatar.avTypeId = int(newAvData[di++]);
            dataAvatar.setColors(uint(newAvData[di++]),uint(newAvData[di++]),uint(newAvData[di++]));
            if(!avtNotInQueueButInRoom)
            {
               if(loadDataAvatarResult != null)
               {
                  loadDataAvatarResult();
                  loadDataAvatarResult = null;
               }
               if(_gameAvatarAdCallback != null)
               {
                  _gameAvatarAdCallback(dataAvatar);
               }
            }
            _buddyCardUpdateDropDownHandler(dataAvatar.userName);
         }
         else if(loadDataAvatarResult != null)
         {
            DebugUtility.debugTrace("calling loadDataAvatarResult even though dataAvatar was null...");
            loadDataAvatarResult();
            loadDataAvatarResult = null;
         }
      }
      
      private static function avatarGetResponse(data:Array) : void
      {
         var accountType:int = 0;
         var isGuide:Boolean = false;
         var perUserAvId:int = 0;
         var nameBarData:int = 0;
         var avType:int = 0;
         var colors:Array = null;
         var avName:String = null;
         var eyeDefId:int = 0;
         var pattDefId:int = 0;
         var questLevel:int = 0;
         var numClothingItems:int = 0;
         var sfsUserId:int = 0;
         var userNameModeratedFlag:int = 0;
         var lBits:int = 0;
         var uBits:int = 0;
         var eBits:int = 0;
         var petName:String = null;
         var numBodyModItems:int = 0;
         var items:Array = null;
         var i:int = 0;
         var currPet:Object = null;
         var userInfo:UserInfo = null;
         var avInfo:AvatarInfo = null;
         var aItem:Item = null;
         var avList:Array = null;
         var j:int = 2;
         var userName:String = data[j++];
         var avatarGetStatus:int = int(data[j++]);
         var onlineStatus:int = avatarGetStatus == 0 ? SFClient.STATUS_OFFLINE_ACTIVE : (avatarGetStatus == 1 ? SFClient.STATUS_ONLINE : (avatarGetStatus == 2 ? SFClient.STATUS_OFFLINE_ARCHIVED : SFClient.STATUS_OFFLINE_UNKNOWN));
         if(avatarGetStatus <= 1)
         {
            accountType = int(data[j++]);
            isGuide = data[j++] == "1";
            perUserAvId = int(data[j++]);
            nameBarData = int(data[j++]);
            avType = int(data[j++]);
            colors = new Array(3);
            colors[0] = uint(data[j++]);
            colors[1] = uint(data[j++]);
            colors[2] = uint(data[j++]);
            avName = data[j++];
            eyeDefId = int(data[j++]);
            pattDefId = int(data[j++]);
            questLevel = int(data[j++]);
            numClothingItems = int(data[j++]);
            sfsUserId = int(data[j++]);
            userNameModeratedFlag = int(data[j++]);
            lBits = int(data[j++]);
            uBits = int(data[j++]);
            eBits = int(data[j++]);
            petName = data[j++];
            numBodyModItems = pattDefId > 0 ? 3 : 2;
            items = new Array(numClothingItems + numBodyModItems);
            i = 0;
            items[i++] = ItemXtCommManager.getBodyModFromDefId(1,perUserAvId,true);
            items[i++] = ItemXtCommManager.getBodyModFromDefId(eyeDefId,perUserAvId,true);
            if(pattDefId > 0)
            {
               items[i++] = ItemXtCommManager.getBodyModFromDefId(pattDefId,perUserAvId,true);
            }
            for(DebugUtility.debugTrace("avatarGetResponse userName:" + userName + " numClothingItems:" + numClothingItems + " numBodyModItems:" + numBodyModItems + " pattDefId:" + pattDefId); i < numClothingItems + numBodyModItems; )
            {
               aItem = new Item();
               aItem.init(int(data[j++]),i,uint(data[j++]));
               aItem.setInUse(perUserAvId,true);
               items[i] = aItem;
               i++;
            }
            currPet = {
               "name":petName,
               "lBits":lBits,
               "uBits":uBits,
               "eBits":eBits
            };
            currPet.defId = PetManager.getDefIdFromLBits(currPet.lBits);
            currPet.type = PetManager.petTypeForDefId(currPet.defId);
            currPet.isGround = PetManager.isGround(currPet.type);
            userInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
            avInfo = new AvatarInfo();
            avInfo.init(perUserAvId,avName,userName,avType,colors,0,currPet,0,0,0,questLevel);
            if(!userInfo)
            {
               avList = new Array(1);
               avList[perUserAvId] = avInfo;
               userInfo = new UserInfo();
               userInfo.init(userName,avList,perUserAvId,accountType);
            }
            else
            {
               userInfo.currPerUserAvId = perUserAvId;
               userInfo.accountType = accountType;
               userInfo.addAvatarToList(avInfo);
            }
            userInfo.userNameModeratedFlag = userNameModeratedFlag;
            userInfo.nameBarData = nameBarData;
            userInfo.isGuide = isGuide;
            gMainFrame.userInfo.setUserInfoByUserName(userName,userInfo);
         }
         var lcUserName:String = userName.toLowerCase();
         if(Boolean(_agQueue[lcUserName]))
         {
            _agQueue[lcUserName](userName,avatarGetStatus < 3,onlineStatus);
            delete _agQueue[lcUserName];
         }
         if(Boolean(_agsQueue[sfsUserId]))
         {
            _agsQueue[sfsUserId](userName,avatarGetStatus < 3,onlineStatus,sfsUserId);
            delete _agsQueue[sfsUserId];
         }
      }
      
      private static function avatarListResponse(data:Array) : void
      {
         var isForSelf:Boolean = false;
         var userName:String = null;
         var numAvNames:int = 0;
         var avList:Array = null;
         var currPerUserAvId:int = 0;
         var userInfo:UserInfo = null;
         var j:int = 0;
         var setUserInfo:UserInfo = null;
         var perUserAvId:int = 0;
         var avSlotIdx:int = 0;
         var avName:String = null;
         var avInfo:AvatarInfo = null;
         var al:int = 2;
         var numUserNames:int = int(data[al++]);
         var slotsAvailFlags:int = -1;
         for(var i:int = 0; i < numUserNames; i++)
         {
            userName = data[al++];
            if(userName == gMainFrame.server.userName)
            {
               isForSelf = true;
               slotsAvailFlags = int(data[al++]);
            }
            numAvNames = int(data[al++]);
            avList = [];
            userInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
            for(j = 0; j < numAvNames; j++)
            {
               perUserAvId = int(data[al++]);
               if(j == 0)
               {
                  currPerUserAvId = perUserAvId;
               }
               avSlotIdx = int(data[al++]);
               avName = data[al++];
               if(Boolean(userInfo))
               {
                  avInfo = userInfo.getAvatarInfoByPerUserAvId(perUserAvId);
                  if(!avInfo)
                  {
                     avInfo = new AvatarInfo();
                     avInfo.init(perUserAvId,avName,userName);
                  }
                  avList[perUserAvId] = avInfo;
               }
               else
               {
                  avInfo = new AvatarInfo();
                  avInfo.init(perUserAvId,avName,userName);
                  avList[perUserAvId] = avInfo;
               }
               if(isForSelf)
               {
                  avSlotInfo[perUserAvId] = {
                     "slotId":j,
                     "avInvId":avSlotIdx
                  };
               }
            }
            setUserInfo = new UserInfo();
            if(Boolean(userInfo))
            {
               userInfo.avList = avList;
               userInfo.currPerUserAvId = currPerUserAvId;
               setUserInfo = userInfo;
            }
            else
            {
               setUserInfo.init(userName,avList,currPerUserAvId);
            }
            gMainFrame.userInfo.setUserInfoByUserName(userName,setUserInfo);
         }
         if(userName != gMainFrame.server.userName)
         {
            if(_avatarListResponse != null)
            {
               _avatarListResponse();
            }
         }
         if(_alCallback != null)
         {
            if(slotsAvailFlags >= 0)
            {
               _alCallback(slotsAvailFlags);
            }
            else
            {
               _alCallback(numUserNames == -1);
            }
            _alCallback = null;
         }
      }
      
      private static function avatarBuyResponse(data:Array) : void
      {
         if(_abCallback != null)
         {
            _abCallback(Boolean(int(data[2])));
         }
      }
      
      private static function avatarSwitchResponse(data:Array) : void
      {
         if(_asCallback != null)
         {
            _asCallback(data);
         }
      }
      
      private static function avatarAddResponse(data:Array) : void
      {
         if(_aaCallback != null)
         {
            _aaCallback(int(data[2]),int(data[3]),int(data[4]));
         }
      }
      
      private static function avatarKillResponse(data:Array) : void
      {
         if(_akCallback != null)
         {
            _akCallback(Boolean(int(data[2])),int(data[3]));
         }
      }
      
      private static function avatarOrdainResponse(data:Array) : void
      {
         if(_aoCallback != null)
         {
            _aoCallback(Boolean(int(data[2])));
         }
      }
   }
}

