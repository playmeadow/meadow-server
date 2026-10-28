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
      
      public static const UV_TUTORIALS:int = 379;
      
      public static const ACHIEVEMENT_REQUEST_INTERVAL:int = 10000;
      
      public function AchievementXtCommManager()
      {
         super();
      }
      
      public static function init(inMingame:Function, onUserVarsReceived:Function, setGemBonusValues:Function) : void
      {
         _inMinigame = inMingame;
         _onUserVarsReceived = onUserVarsReceived;
         _setGemBonusValues = setGemBonusValues;
         _zsCallbacks = new Object();
      }
      
      public static function destroy() : void
      {
         _zsCallbacks = null;
      }
      
      public static function requestAchievements(userName:String, callback:Function = null) : void
      {
         var milliSecSinceLastRequestForThisUser:Number = NaN;
         var now:Number = NaN;
         var ui:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
         if(Boolean(ui))
         {
            milliSecSinceLastRequestForThisUser = ui.getTimeOfLastAchievementRequest();
            now = new Date().getTime();
            if(now - milliSecSinceLastRequestForThisUser > ACHIEVEMENT_REQUEST_INTERVAL)
            {
               _zaCallback = callback;
               ui.setTimeOfLastAchievementRequest(now);
               if(milliSecSinceLastRequestForThisUser == 0)
               {
                  gMainFrame.server.setXtObject_Str("za",[userName,-1]);
               }
               else
               {
                  gMainFrame.server.setXtObject_Str("za",[userName,int((now - milliSecSinceLastRequestForThisUser) / 1000)]);
               }
            }
            else if(callback != null)
            {
               callback(ui.achievements);
            }
         }
      }
      
      public static function requestSetUserVar(userVarId:int, setValue:int, callback:Function = null, bitState:Boolean = true) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(userVarId <= 0)
            {
               trace("ERROR: Illegal userVarId=" + userVarId);
               return;
            }
            if(callback != null)
            {
               _zsCallbacks[userVarId] = {
                  "uv":userVarId,
                  "c":callback
               };
            }
            gMainFrame.server.setXtObject_Str("zs",[userVarId,setValue,bitState ? 1 : 0]);
         }
      }
      
      public static function requestAllUserVars() : void
      {
         gMainFrame.server.setXtObject_Str("zg",[]);
      }
      
      public static function requestDeleteAllAchievementsAndUserVars() : void
      {
         gMainFrame.server.setXtObject_Str("zd",[]);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         switch(data[0])
         {
            case "za":
               getAchievementsResponse(data);
               break;
            case "zs":
               setUserVarResponse(data);
               break;
            case "zg":
               getUserVarsResponse(data);
               break;
            default:
               throw new Error("Did not expect ext cmd=" + data[0]);
         }
      }
      
      private static function setUserVarResponse(data:Object) : void
      {
         var userVarDefId:int = 0;
         var shouldRequestAchievements:Boolean = false;
         var newAchievements:Array = null;
         var value:int = 0;
         var a:Achievement = null;
         var j:int = 2;
         var numUserVars:int = 1;
         for(var i:int = 0; i < numUserVars; i++)
         {
            userVarDefId = int(data[j++]);
            value = int(data[j++]);
            gMainFrame.userInfo.userVarCache.updateUserVar(userVarDefId,value);
            if(userVarDefId == UV_DAILY_GEM_BONUS)
            {
               _setGemBonusValues(value);
            }
         }
         var numAchievementsTriggered:int = int(data[j++]);
         if(numAchievementsTriggered > 0)
         {
            newAchievements = [];
            if(!gMainFrame.userInfo.playerUserInfo.achievements)
            {
               shouldRequestAchievements = true;
            }
            for(i = 0; i < numAchievementsTriggered; i++)
            {
               a = new Achievement();
               a.init(int(data[j++]),int(data[j++]),int(data[j++]),int(data[j++]),data[j++],true);
               newAchievements.unshift(a);
               AchievementManager.addAchievement(a.clone());
            }
         }
         if(shouldRequestAchievements)
         {
            requestAchievements(gMainFrame.userInfo.playerUserInfo.userName);
         }
         else if(Boolean(newAchievements))
         {
            for(i = 0; i < numAchievementsTriggered; i++)
            {
               gMainFrame.userInfo.playerUserInfo.achievements.unshift(newAchievements[i]);
            }
         }
         if(!_inMinigame())
         {
            AchievementManager.displayNewAchievements();
         }
         var callbackObj:Object = _zsCallbacks[userVarDefId];
         if(Boolean(callbackObj))
         {
            callbackObj.c(userVarDefId,value);
         }
      }
      
      private static function getUserVarsResponse(data:Object) : void
      {
         var j:int = 2;
         var numUserVars:int = int(data[j++]);
         var userVars:Object = new Object();
         for(var i:int = 0; i < numUserVars; i++)
         {
            userVars[int(data[j++])] = {
               "type":int(data[j++]),
               "value":int(data[j++])
            };
         }
         gMainFrame.userInfo.userVarCache.playerUserVars = userVars;
         if(!_bMyUserVarsReceived)
         {
            _onUserVarsReceived();
         }
      }
      
      private static function getAchievementsResponse(data:Object) : void
      {
         var aList:Array = null;
         var i:int = 0;
         var a:Achievement = null;
         var j:int = 2;
         var userName:String = data[j++];
         var numAchievements:int = int(data[j++]);
         var ui:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
         if(numAchievements > 0)
         {
            aList = new Array(numAchievements);
            for(i = 0; i < numAchievements; i++)
            {
               a = new Achievement();
               a.init(int(data[j++]),int(data[j++]),int(data[j++]),int(data[j++]),data[j++],userName == gMainFrame.userInfo.playerUserInfo.userName);
               aList[i] = a;
            }
            aList.sortOn("invId",Array.NUMERIC | Array.DESCENDING);
            if(Boolean(ui))
            {
               ui.addAchievementsTolist(aList);
            }
         }
         if(_zaCallback != null)
         {
            if(userName == gMainFrame.userInfo.myUserName)
            {
               _zaCallback(Boolean(ui) ? ui.achievements : null);
            }
            else
            {
               _zaCallback(Boolean(ui) ? ui.achievements : null,numAchievements == -1);
            }
         }
      }
   }
}

