package gui
{
   import avatar.AvatarInfo;
   import avatar.UserInfo;
   import buddy.Buddy;
   import buddy.BuddyEvent;
   import buddy.BuddyTimer;
   import buddy.BuddyXtCommManager;
   import com.sbi.client.SFClient;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopupManager;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import localization.LocalizationManager;
   
   public class BuddyManager
   {
      
      private static var _numOnlineBuddies:int;
      
      private static var _buddyList:Dictionary;
      
      private static var _blockedList:Dictionary;
      
      private static var _buddyRequestList:Dictionary;
      
      private static var _buddyRequestCleanupTimer:Timer;
      
      private static var _buddyRequestPopups:Dictionary;
      
      private static var _confirmBuddyRequestPopups:Dictionary;
      
      private static var _eventDispatcher:EventDispatcher;
      
      private static var _mainHud:MovieClip;
      
      private static var _popupLayer:DisplayLayer;
      
      public static const MAX_BUDDY_COUNT:int = 100;
      
      public static const WARNING_BUDDY_COUNT:int = 95;
      
      private static const PERMISSION_TIMEOUT:int = 20000;
      
      private static const BUDDY_REQUEST_TIMEOUT:int = 30000;
      
      public function BuddyManager()
      {
         super();
      }
      
      public static function init(init_popupLayer:DisplayLayer, init_buddyListBtn:MovieClip) : void
      {
         _buddyList = new Dictionary(false);
         _blockedList = new Dictionary(false);
         _buddyRequestList = new Dictionary(false);
         _buddyRequestPopups = new Dictionary(false);
         _confirmBuddyRequestPopups = new Dictionary(false);
         _popupLayer = init_popupLayer;
         _eventDispatcher = new EventDispatcher();
         BuddyCard.init(_popupLayer);
         BuddyList.init(_popupLayer,init_buddyListBtn);
         _buddyRequestCleanupTimer = new Timer(BUDDY_REQUEST_TIMEOUT);
         _buddyRequestCleanupTimer.addEventListener(TimerEvent.TIMER,buddyRequestCleanupTimerHandler,false,0,true);
         _buddyRequestCleanupTimer.start();
      }
      
      public static function destroy() : void
      {
         var bud:Buddy = null;
         var b:Object = null;
         var br:Object = null;
         var brp:Object = null;
         var cbrp:Object = null;
         for each(bud in _buddyList)
         {
            bud = null;
         }
         for each(b in _blockedList)
         {
            b = null;
         }
         for each(br in _buddyRequestList)
         {
            br = null;
         }
         for each(brp in _buddyRequestPopups)
         {
            brp = null;
         }
         for each(cbrp in _confirmBuddyRequestPopups)
         {
            cbrp = null;
         }
         _eventDispatcher = null;
         _buddyList = null;
         _blockedList = null;
         BuddyCard.destroy();
         BuddyList.destroy();
      }
      
      public static function get eventDispatcher() : EventDispatcher
      {
         return _eventDispatcher;
      }
      
      public static function isBuddy(userName:String) : Boolean
      {
         return _buddyList[userName.toLowerCase()] != null;
      }
      
      public static function isBlocked(userName:String) : Boolean
      {
         return _blockedList[userName.toLowerCase()] != null;
      }
      
      public static function getBuddyByUserName(userName:String) : Buddy
      {
         return _buddyList[userName.toLowerCase()];
      }
      
      public static function get buddyCount() : int
      {
         var key:Object = null;
         var i:int = 0;
         for(key in _buddyList)
         {
            i++;
         }
         return i;
      }
      
      public static function addRemoveBuddy(userName:String, userNameModerated:String, add:Boolean) : void
      {
         var lcUserName:String = null;
         var msg:String = null;
         var br:Object = null;
         if(add)
         {
            lcUserName = userName.toLowerCase();
            if(buddyCount < MAX_BUDDY_COUNT)
            {
               br = _buddyRequestList[lcUserName];
               if(br == null || br.expires < new Date().getTime())
               {
                  BuddyXtCommManager.sendBuddyAddRequest(userName);
                  _buddyRequestList[lcUserName] = {
                     "userName":userName,
                     "expires":new Date().getTime() + 30000,
                     "isAccepting":true
                  };
               }
               else
               {
                  if(_buddyRequestList[lcUserName] != null)
                  {
                     if(!_buddyRequestList[lcUserName].isAccepting)
                     {
                        _buddyRequestPopups[lcUserName] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14706,userNameModerated));
                        return;
                     }
                  }
                  _buddyRequestPopups[lcUserName] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14707,userNameModerated));
               }
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14708));
            }
         }
         else
         {
            BuddyXtCommManager.sendBuddyDeleteRequest(userName);
         }
      }
      
      private static function buddyAddRequestCallback(o:Object) : void
      {
         var timer:Timer = _confirmBuddyRequestPopups[o.passback.toLowerCase()].timer;
         if(Boolean(timer))
         {
            timer.reset();
            timer = null;
         }
         var popup:BuddyRequest = _confirmBuddyRequestPopups[o.passback.toLowerCase()].popup;
         if(Boolean(popup))
         {
            popup.destroy();
            popup = null;
         }
         delete _confirmBuddyRequestPopups[o.passback.toLowerCase()];
         if(buddyCount < MAX_BUDDY_COUNT)
         {
            BuddyXtCommManager.sendBuddyConfirmRequest(o.passback,o.status);
         }
         else
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14708));
         }
      }
      
      public static function buddyListResponseHandler(data:Object) : void
      {
         var bud:Buddy = null;
         var userName:String = null;
         var userNameModerationFlag:int = 0;
         var avName:String = null;
         var perUserAvId:int = 0;
         var accountTypeId:int = 0;
         var budUserInfo:UserInfo = null;
         var avInfo:AvatarInfo = null;
         var offBud:Buddy = null;
         var offUserName:String = null;
         var offUserNameModerationFlag:int = 0;
         var offNumDaysSinceLastLogin:int = 0;
         var offAccountType:int = 0;
         var offOnlineStatus:int = 0;
         _buddyList = new Dictionary(true);
         var i:int = 3;
         var numOnlineBuddies:int = int(data[i++]);
         for(var j:int = 0; j < numOnlineBuddies; j++)
         {
            bud = new Buddy();
            userName = data[i++];
            userNameModerationFlag = int(data[i++]);
            avName = data[i++];
            perUserAvId = int(data[i++]);
            accountTypeId = int(data[i++]);
            bud.init(userName,userNameModerationFlag,SFClient.STATUS_ONLINE,accountTypeId);
            _buddyList[userName.toLowerCase()] = bud;
            budUserInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
            if(!budUserInfo)
            {
               avInfo = new AvatarInfo();
               avInfo.init(perUserAvId,avName,userName);
               budUserInfo = new UserInfo();
               budUserInfo.init(userName,null,perUserAvId);
               budUserInfo.addAvatarToList(avInfo);
               budUserInfo.accountType = accountTypeId;
               budUserInfo.userNameModeratedFlag = userNameModerationFlag;
               gMainFrame.userInfo.setUserInfoByUserName(userName,budUserInfo);
            }
            else
            {
               if(!budUserInfo.getAvatarInfoByPerUserAvId(perUserAvId))
               {
                  avInfo = new AvatarInfo();
                  avInfo.init(perUserAvId,avName,userName);
                  budUserInfo.addAvatarToList(avInfo);
               }
               budUserInfo.userNameModeratedFlag = userNameModerationFlag;
               budUserInfo.accountType = accountTypeId;
               budUserInfo.currPerUserAvId = perUserAvId;
            }
         }
         var numOfflineBuddies:int = int(data[i++]);
         for(j = 0; j < numOfflineBuddies; j++)
         {
            offBud = new Buddy();
            offUserName = data[i++];
            offUserNameModerationFlag = int(data[i++]);
            offNumDaysSinceLastLogin = int(data[i++]);
            offAccountType = int(data[i++]);
            offOnlineStatus = offNumDaysSinceLastLogin > -1 ? SFClient.STATUS_OFFLINE_ACTIVE : SFClient.STATUS_OFFLINE_ARCHIVED;
            if(offOnlineStatus == SFClient.STATUS_OFFLINE_ARCHIVED)
            {
               offUserNameModerationFlag = 1;
            }
            offBud.init(offUserName,offUserNameModerationFlag,offOnlineStatus,offAccountType,offNumDaysSinceLastLogin);
            _buddyList[offUserName.toLowerCase()] = offBud;
         }
         BuddyList.listRequested = true;
         var ble:BuddyEvent = new BuddyEvent(BuddyEvent.BUDDY_LIST);
         _eventDispatcher.dispatchEvent(ble);
      }
      
      public static function blockedListResponseHandler(data:Object) : void
      {
         var i:int = 3;
         var blockedCount:int = int(data[i++]);
         _blockedList = new Dictionary(true);
         for(var j:int = 0; j < blockedCount; j++)
         {
            _blockedList[data[i++].toLowerCase()] = "1";
         }
      }
      
      public static function buddyAddRequestResponseHandler(flag:int, userName:String, userNameModerationFlag:int) : void
      {
         var avInfo:AvatarInfo = null;
         var confirmTimer:BuddyTimer = null;
         var moderatedUserName:String = userNameModerationFlag > 0 ? userName : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
         if(flag == 0)
         {
            if(!_buddyList[userName.toLowerCase()])
            {
               avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
               confirmTimer = new BuddyTimer(BUDDY_REQUEST_TIMEOUT);
               confirmTimer.userName = userName.toLowerCase();
               confirmTimer.addEventListener(TimerEvent.TIMER,confirmPopupTimerHandler,false,0,true);
               _confirmBuddyRequestPopups[userName.toLowerCase()] = {
                  "popup":new BuddyRequest(userName,buddyAddRequestCallback,BuddyRequest.ACCEPT_REJECT),
                  "timer":confirmTimer
               };
               confirmTimer.start();
            }
         }
         else if(flag == 1)
         {
            _buddyRequestPopups[userName.toLowerCase()] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14707,moderatedUserName));
         }
         else if(flag == 2)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14710,userName));
         }
         else if(flag == 3)
         {
            if(_buddyRequestList[userName.toLowerCase()] != null)
            {
               _buddyRequestList[userName.toLowerCase()].isAccepting = false;
            }
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14706,moderatedUserName));
         }
      }
      
      public static function buddyStatusResponseHandler(userName:String, userNameModerationFlag:int, isOnline:Boolean, accountTypeId:int, buddyFlag:int, newUserName:String = null, avName:String = null, perUserAvId:int = -1) : void
      {
         var avInfo:AvatarInfo = null;
         var moderatedUserName:String = null;
         var lcUserName:String = userName.toLowerCase();
         var bud:Buddy = _buddyList[lcUserName];
         var userInfo:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
         if(!userInfo)
         {
            userInfo = new UserInfo();
            userInfo.init(userName);
            userInfo.userNameModeratedFlag = userNameModerationFlag;
            gMainFrame.userInfo.setUserInfoByUserName(userName,userInfo);
         }
         userInfo.accountType = accountTypeId;
         if(Boolean(avName))
         {
            avInfo = userInfo.getAvatarInfoByPerUserAvId(perUserAvId);
            if(!avInfo)
            {
               avInfo = new AvatarInfo();
               avInfo.init(perUserAvId,avName,userName);
               userInfo.addAvatarToList(avInfo);
            }
            if(perUserAvId > 0)
            {
               userInfo.currPerUserAvId = perUserAvId;
            }
         }
         if(buddyFlag != 3 && buddyFlag != 4)
         {
            if(Boolean(bud))
            {
               bud.userName = userName;
               bud.userNameModeratedFlag = userNameModerationFlag;
               if(bud.isOnline && !isOnline)
               {
                  --_numOnlineBuddies;
                  bud.numDaysSinceLastLogin = 0;
               }
               else if(!bud.isOnline && isOnline)
               {
                  if(Utility.canBuddy())
                  {
                     BuddyList.startBuddyListBtnGlow();
                  }
                  ++_numOnlineBuddies;
               }
               bud.onlineStatus = isOnline ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE;
            }
            else
            {
               bud = new Buddy();
               bud.init(userName,userNameModerationFlag,isOnline ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE,accountTypeId);
               _buddyList[lcUserName] = bud;
               if(buddyFlag == 1)
               {
                  if(_buddyRequestPopups[lcUserName] != null)
                  {
                     _buddyRequestPopups[lcUserName].destroy();
                     delete _buddyRequestPopups[lcUserName];
                  }
                  SBPopupManager.nonSBPopups.push(new BuddyRequest(userName,null,BuddyRequest.CONFIRMATION));
               }
               else if(buddyFlag == 2)
               {
                  SBPopupManager.nonSBPopups.push(new BuddyRequest(userName,null,BuddyRequest.CONFIRMATION));
               }
            }
         }
         else
         {
            if(Boolean(bud))
            {
               bud.userName = newUserName;
               bud.userNameModeratedFlag = userNameModerationFlag;
               if(bud.isOnline && !isOnline)
               {
                  --_numOnlineBuddies;
               }
               else if(!bud.isOnline && isOnline)
               {
                  BuddyList.startBuddyListBtnGlow();
                  ++_numOnlineBuddies;
               }
               bud.onlineStatus = isOnline ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE;
               delete _buddyList[lcUserName];
               _buddyList[newUserName.toLowerCase()] = bud;
               BuddyCard.userNameChange(userName,newUserName,bud.userNameModerated);
               gMainFrame.userInfo.changeUserName(userName,newUserName,userNameModerationFlag);
               userName = newUserName;
            }
            if(isBlocked(lcUserName))
            {
               moderatedUserName = userNameModerationFlag > 0 ? newUserName : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
               BuddyCard.userNameChange(userName,newUserName,moderatedUserName);
               gMainFrame.userInfo.changeUserName(userName,newUserName,userNameModerationFlag);
               userName = newUserName;
               delete _blockedList[lcUserName];
               _blockedList[newUserName.toLowerCase()] = "1";
            }
         }
         var ble:BuddyEvent = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
         ble.userName = userName;
         _eventDispatcher.dispatchEvent(ble);
      }
      
      public static function buddyDeleteResponseHandler(userName:String) : void
      {
         var ble:BuddyEvent = null;
         var lcUserName:String = userName.toLowerCase();
         if(Boolean(_buddyList[lcUserName]))
         {
            delete _buddyList[lcUserName];
            delete _buddyRequestList[lcUserName];
            ble = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
            ble.userName = userName;
            _eventDispatcher.dispatchEvent(ble);
         }
      }
      
      public static function buddyBlockResponseHandler(userName:String, didBlockSucceed:Boolean) : void
      {
         var ble:BuddyEvent = null;
         if(didBlockSucceed)
         {
            _blockedList[userName.toLowerCase()] = "1";
            ble = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
            ble.userName = userName;
            _eventDispatcher.dispatchEvent(ble);
         }
      }
      
      public static function buddyUnblockResponseHandler(userName:String, didUnblockSucceed:Boolean) : void
      {
         var ble:BuddyEvent = null;
         if(didUnblockSucceed)
         {
            delete _blockedList[userName.toLowerCase()];
            ble = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
            ble.userName = userName;
            _eventDispatcher.dispatchEvent(ble);
         }
      }
      
      public static function get buddyList() : Dictionary
      {
         return _buddyList;
      }
      
      public static function get blockedList() : Dictionary
      {
         return _blockedList;
      }
      
      public static function avatarListResponse() : void
      {
         var ble:BuddyEvent = new BuddyEvent(BuddyEvent.BUDDY_LIST);
         BuddyManager.eventDispatcher.dispatchEvent(ble);
      }
      
      private static function buddyRequestCleanupTimerHandler(evt:TimerEvent) : void
      {
         var br:Object = null;
         var userName:String = null;
         for each(br in _buddyRequestList)
         {
            userName = br.userName.toLowerCase();
            if(br == null || br.expires < new Date().getTime())
            {
               delete _buddyRequestList[userName];
               if(_buddyRequestPopups[userName] != null)
               {
                  delete _buddyRequestPopups[userName];
               }
            }
         }
      }
      
      private static function confirmPopupTimerHandler(evt:TimerEvent) : void
      {
         var userName:String = null;
         var o:Object = null;
         var confirmTimer:BuddyTimer = BuddyTimer(evt.currentTarget);
         if(Boolean(confirmTimer))
         {
            userName = confirmTimer.userName;
            confirmTimer.stop();
            confirmTimer = null;
            o = _confirmBuddyRequestPopups[userName];
            if(o != null)
            {
               if(Boolean(o.popup))
               {
                  o.popup.destroy();
                  o.popup = null;
               }
               delete _confirmBuddyRequestPopups[userName];
            }
         }
      }
   }
}

