package achievement
{
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import com.sbi.client.SFEvent;
   import gui.MySettings;
   import loader.DefPacksDefHelper;
   
   public class AchievementXtCommManager
   {
      
      public static const UV_JAMAA_JOURNAL_TIMESTAMP:int = 112;
      
      public static const UV_JAMAA_JOURNAL_TIMESTAMP_STARTUP:int = 158;
      
      public static const UV_BRADY_BARR_COUNT:int = 128;
      
      public static const UV_TRADING:int = 129;
      
      public static const UV_PET_COUNTER:int = 212;
      
      public static const UV_DAILY_GEM_BONUS:int = 214;
      
      public static const UV_AVT_VIEWABLE_FLAG:int = 287;
      
      public static const UV_TIERNEY_THYS_COUNT:int = 297;
      
      public static const UV_PLAYER_WALL_COUNT:int = 414;
      
      public static const UV_PET_INVENTORY_MAX:int = 338;
      
      public static const UV_SETTINGS:int = 363;
      
      public static const UV_PARTY_JB_ENTER:int = 366;
      
      public static const UV_TUTORIALS:int = 379;
      
      public static const UV_CUSTOM_AVT_VIEWABLE_FLAG:int = 410;
      
      public static const UV_COLOR_ME_RAD:int = 146;
      
      public static const UV_WALL_FLOORING_FIRST_BUY:int = 420;
      
      public static const UV_DEN_ITEM_BUY_COUNT:int = 3;
      
      public static const UV_ACTIVATION_POPUP_SEEN_TIME:int = 428;
      
      public static const UV_NUM_ACQUIRED_ADOPT_A_PETS:int = 426;
      
      public static const UV_PLATFORM_LEVEL_COMPLETED:int = 435;
      
      public static const UV_GABBY_WILD_COUNT:int = 436;
      
      public static const UV_CHAT_CORRECTION:int = 442;
      
      public static const UV_HAS_SET_CHAT_SETTING:int = 452;
      
      public static const ACHIEVEMENT_REQUEST_INTERVAL:int = 10000;
      
      private static var _zaCallback:Function;
      
      private static var _inMinigame:Function;
      
      private static var _onUserVarsReceived:Function;
      
      private static var _setGemBonusValues:Function;
      
      private static var _bMyUserVarsReceived:Boolean;
      
      private static var _zsCallbacks:Object;
      
      private static var _achievementRequestUsername:String;
      
      public static const UV_PARTY_JB_ENTER_BIT_ARRAY:Array = [27];
      
      public function AchievementXtCommManager()
      {
         super();
      }
      
      public static function init(param1:Function, param2:Function, param3:Function) : void
      {
         _inMinigame = param1;
         _onUserVarsReceived = param2;
         _setGemBonusValues = param3;
         _zsCallbacks = {};
      }
      
      public static function destroy() : void
      {
         _zsCallbacks = null;
      }
      
      public static function requestAchievements(param1:String, param2:Function = null) : void
      {
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1);
         if(_loc4_)
         {
            _loc3_ = _loc4_.getTimeOfLastAchievementRequest();
            _loc5_ = new Date().getTime();
            if(_loc5_ - _loc3_ > 10000)
            {
               _zaCallback = param2;
               _loc4_.setTimeOfLastAchievementRequest(_loc5_);
               if(_loc3_ == 0)
               {
                  gMainFrame.server.setXtObject_Str("za",[param1,-1]);
               }
               else
               {
                  gMainFrame.server.setXtObject_Str("za",[param1,int((_loc5_ - _loc3_) / 1000)]);
               }
            }
            else if(param2 != null)
            {
               param2(_loc4_.achievements,_loc4_.achievementsIndexed);
            }
         }
      }
      
      public static function requestSetUserVar(param1:int, param2:int, param3:Function = null, param4:Boolean = true) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(param1 <= 0)
            {
               trace("ERROR: Illegal userVarId=" + param1);
               return;
            }
            if(param3 != null)
            {
               _zsCallbacks[param1] = {
                  "uv":param1,
                  "c":param3
               };
            }
            gMainFrame.server.setXtObject_Str("zs",[param1,param2,param4 ? 1 : 0]);
         }
      }
      
      public static function requestAllUserVars() : void
      {
         gMainFrame.server.setXtObject_Str("zg",[]);
      }
      
      public static function requestDeleteAllAchievementsAndUserVars() : void
      {
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "za":
               getAchievementsResponse(_loc2_);
               break;
            case "zs":
               setUserVarResponse(_loc2_);
               break;
            case "zg":
               getUserVarsResponse(_loc2_);
               break;
            default:
               throw new Error("Did not expect ext cmd=" + _loc2_[0]);
         }
      }
      
      public static function onAchievementDefPacksResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:int = 0;
         DefPacksDefHelper.mediaArray[1042] = null;
         var _loc3_:Object = param1.def;
         var _loc6_:Object = {};
         var _loc5_:Object = {};
         for each(var _loc4_:Object in _loc3_)
         {
            _loc6_[int(_loc4_.id)] = {
               "id":int(_loc4_.id),
               "baseMediaRef":int(_loc4_.baseMediaRef),
               "descStrRef":int(_loc4_.descStrRef),
               "extraText":_loc4_.extraText,
               "iconMediaRef":int(_loc4_.iconMediaRef),
               "titleStrRef":int(_loc4_.titleStrRef),
               "type":int(_loc4_.type),
               "triggeredAmount":int(_loc4_.triggerAmount),
               "userVarRef":int(_loc4_.userVarRef),
               "sortIndex":int(_loc4_.name.split("_")[0])
            };
            if(_loc5_[int(_loc4_.type)])
            {
               _loc5_[int(_loc4_.type)].push(_loc6_[int(_loc4_.id)]);
            }
            else
            {
               _loc5_[int(_loc4_.type)] = [_loc6_[int(_loc4_.id)]];
            }
         }
         AchievementManager.achievementDefs = _loc6_;
         AchievementManager.achievementDefsIndexed = _loc5_;
      }
      
      private static function setUserVarResponse(param1:Object) : void
      {
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc8_:Number = NaN;
         var _loc2_:Boolean = false;
         var _loc7_:Array = null;
         var _loc5_:Achievement = null;
         var _loc4_:* = null;
         var _loc9_:int = 2;
         var _loc3_:int = 1;
         _loc12_ = 0;
         while(_loc12_ < _loc3_)
         {
            _loc11_ = int(param1[_loc9_++]);
            _loc8_ = Number(param1[_loc9_++]);
            gMainFrame.userInfo.userVarCache.updateUserVar(_loc11_,_loc8_);
            if(_loc11_ == 214)
            {
               _setGemBonusValues(_loc8_);
            }
            if(_loc11_ == 363 && (_loc8_ == 1 << MySettings.SETTINGS_USERNAME_BADGE || _loc8_ == 0))
            {
               AvatarManager.updateAvatarNameBarNames();
            }
            _loc12_++;
         }
         var _loc6_:int = int(param1[_loc9_++]);
         if(_loc6_ > 0)
         {
            _loc7_ = [];
            if(!gMainFrame.userInfo.playerUserInfo.achievements)
            {
               _loc2_ = true;
            }
            _loc12_ = _loc6_ - 1;
            while(_loc12_ >= 0)
            {
               _loc5_ = new Achievement();
               _loc5_.init(int(param1[_loc9_++]),int(param1[_loc9_++]),true);
               _loc7_[_loc12_] = _loc5_;
               AchievementManager.addAchievement(_loc5_.clone());
               _loc12_--;
            }
         }
         if(_loc2_)
         {
            requestAchievements(gMainFrame.userInfo.playerUserInfo.userName);
         }
         else if(_loc7_)
         {
            gMainFrame.userInfo.playerUserInfo.addAchievementsTolist(_loc7_);
         }
         if(!_inMinigame())
         {
            AchievementManager.displayNewAchievements();
         }
         var _loc10_:Object = _zsCallbacks[_loc11_];
         if(_loc10_)
         {
            _loc10_.c(_loc11_,_loc8_);
            delete _zsCallbacks[_loc11_];
         }
      }
      
      private static function getUserVarsResponse(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 2;
         var _loc2_:int = int(param1[_loc4_++]);
         var _loc3_:Object = {};
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            _loc3_[int(param1[_loc4_++])] = {
               "type":int(param1[_loc4_++]),
               "value":Number(param1[_loc4_++])
            };
            _loc5_++;
         }
         gMainFrame.userInfo.userVarCache.playerUserVars = _loc3_;
         if(!_bMyUserVarsReceived)
         {
            _onUserVarsReceived();
         }
      }
      
      private static function getAchievementsResponse(param1:Object) : void
      {
         var _loc4_:Array = null;
         var _loc7_:int = 0;
         var _loc3_:Achievement = null;
         var _loc6_:int = 2;
         var _loc5_:String = param1[_loc6_++];
         var _loc8_:int = int(param1[_loc6_++]);
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc5_);
         if(_loc8_ > 0)
         {
            _loc4_ = new Array(_loc8_);
            _loc7_ = 0;
            while(_loc7_ < _loc8_)
            {
               _loc3_ = new Achievement();
               _loc3_.init(int(param1[_loc6_++]),int(param1[_loc6_++]),_loc5_.toLowerCase() == gMainFrame.userInfo.playerUserInfo.userName.toLowerCase());
               _loc4_[_loc7_] = _loc3_;
               _loc7_++;
            }
            _loc4_.sortOn("invId",0x10 | 2);
            if(_loc2_)
            {
               _loc2_.addAchievementsTolist(_loc4_);
            }
         }
         if(_zaCallback != null)
         {
            if(_loc5_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               if(_loc2_)
               {
                  _zaCallback(_loc2_.achievements,_loc2_.achievementsIndexed);
               }
               else
               {
                  _zaCallback(null,null);
               }
            }
            else if(_loc2_)
            {
               _zaCallback(_loc2_.achievements,_loc2_.achievementsIndexed,_loc8_ == -1);
            }
            else
            {
               _zaCallback(null,null,_loc8_ == -1);
            }
         }
      }
   }
}

