package achievement
{
   import avatar.UserInfo;
   import com.sbi.client.SFEvent;
   
   public class AchievementXtCommManager
   {
      
      private static var _zaCallback:Function;
      
      private static var _inMinigame:Function;
      
      private static var _onUserVarsReceived:Function;
      
      private static var _setGemBonusValues:Function;
      
      private static var _bMyUserVarsReceived:Boolean;
      
      private static var _zsCallbacks:Object;
      
      public static const UV_JAMAA_JOURNAL_TIMESTAMP:int = 112;
      
      public static const UV_JAMAA_JOURNAL_TIMESTAMP_STARTUP:int = 158;
      
      public static const UV_BRADY_BARR_COUNT:int = 128;
      
      public static const UV_TRADING:int = 129;
      
      public static const UV_PET_COUNTER:int = 212;
      
      public static const UV_DAILY_GEM_BONUS:int = 214;
      
      public static const UV_AVT_VIEWABLE_FLAG:int = 287;
      
      public static const UV_TIERNEY_THYS_COUNT:int = 297;
      
      public static const UV_PET_INVENTORY_MAX:int = 338;
      
      public static const UV_PET_VIEWABLE_FLAG:int = 342;
      
      public static const UV_SETTINGS:int = 363;
      
      public static const UV_PARTY_JB_ENTER:int = 366;
      
      public static const UV_PARTY_JB_ENTER_BIT_ARRAY:Array = [27];
      
      public static const ACHIEVEMENT_REQUEST_INTERVAL:int = 10000;
      
      public function AchievementXtCommManager()
      {
         super();
      }
      
      public static function init(param1:Function, param2:Function, param3:Function) : void
      {
         _inMinigame = param1;
         _onUserVarsReceived = param2;
         _setGemBonusValues = param3;
         _zsCallbacks = new Object();
      }
      
      public static function destroy() : void
      {
         _zsCallbacks = null;
      }
      
      public static function requestAchievements(param1:String, param2:Function = null) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1);
         if(_loc3_)
         {
            _loc4_ = _loc3_.getTimeOfLastAchievementRequest();
            _loc5_ = new Date().getTime();
            if(_loc5_ - _loc4_ > ACHIEVEMENT_REQUEST_INTERVAL)
            {
               _zaCallback = param2;
               _loc3_.setTimeOfLastAchievementRequest(_loc5_);
               if(_loc4_ == 0)
               {
                  gMainFrame.server.setXtObject_Str("za",[param1,-1]);
               }
               else
               {
                  gMainFrame.server.setXtObject_Str("za",[param1,int((_loc5_ - _loc4_) / 1000)]);
               }
            }
            else if(param2 != null)
            {
               param2(_loc3_.achievements);
            }
         }
      }
      
      public static function requestSetUserVar(param1:int, param2:int, param3:Function = null, param4:Boolean = true) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(param1 <= 0)
            {
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
      
      private static function setUserVarResponse(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:Achievement = null;
         var _loc2_:* = 2;
         var _loc3_:int = 1;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_ = int(param1[_loc2_++]);
            _loc10_ = int(param1[_loc2_++]);
            gMainFrame.userInfo.userVarCache.updateUserVar(_loc4_,_loc10_);
            if(_loc4_ == UV_DAILY_GEM_BONUS)
            {
               _setGemBonusValues(_loc10_);
            }
            _loc5_++;
         }
         var _loc6_:int = int(param1[_loc2_++]);
         if(_loc6_ > 0)
         {
            _loc8_ = [];
            if(!gMainFrame.userInfo.playerUserInfo.achievements)
            {
               _loc7_ = true;
            }
            _loc5_ = 0;
            while(_loc5_ < _loc6_)
            {
               _loc11_ = new Achievement();
               _loc11_.init(int(param1[_loc2_++]),int(param1[_loc2_++]),int(param1[_loc2_++]),param1[_loc2_++],param1[_loc2_++],true);
               _loc8_.unshift(_loc11_);
               AchievementManager.addAchievement(_loc11_.clone());
               _loc5_++;
            }
         }
         if(_loc7_)
         {
            requestAchievements(gMainFrame.userInfo.playerUserInfo.userName);
         }
         else if(_loc8_)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc6_)
            {
               gMainFrame.userInfo.playerUserInfo.achievements.unshift(_loc8_[_loc5_]);
               _loc5_++;
            }
         }
         if(!_inMinigame())
         {
            AchievementManager.displayNewAchievements();
         }
         var _loc9_:Object = _zsCallbacks[_loc4_];
         if(_loc9_)
         {
            _loc9_.c(_loc4_,_loc10_);
         }
      }
      
      private static function getUserVarsResponse(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Object = new Object();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_[int(param1[_loc2_++])] = {
               "type":int(param1[_loc2_++]),
               "value":int(param1[_loc2_++])
            };
            _loc5_++;
         }
         gMainFrame.userInfo.userVarCache.playerUserVars = _loc4_;
         if(!_bMyUserVarsReceived)
         {
            _onUserVarsReceived();
         }
      }
      
      private static function getAchievementsResponse(param1:Object) : void
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:Achievement = null;
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc3_);
         if(_loc4_ > 0)
         {
            _loc6_ = new Array(_loc4_);
            _loc7_ = 0;
            while(_loc7_ < _loc4_)
            {
               _loc8_ = new Achievement();
               _loc8_.init(int(param1[_loc2_++]),int(param1[_loc2_++]),int(param1[_loc2_++]),param1[_loc2_++],param1[_loc2_++],_loc3_ == gMainFrame.userInfo.playerUserInfo.userName);
               _loc6_[_loc7_] = _loc8_;
               _loc7_++;
            }
            _loc6_.sortOn("invId",Array.NUMERIC | Array.DESCENDING);
            if(_loc5_)
            {
               _loc5_.addAchievementsTolist(_loc6_);
            }
         }
         if(_zaCallback != null)
         {
            if(_loc3_ == gMainFrame.userInfo.myUserName)
            {
               _zaCallback(_loc5_ ? _loc5_.achievements : null);
            }
            else
            {
               _zaCallback(_loc5_ ? _loc5_.achievements : null,_loc4_ == -1);
            }
         }
      }
   }
}

