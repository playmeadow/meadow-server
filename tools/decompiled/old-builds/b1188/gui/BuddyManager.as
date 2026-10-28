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
      
      public static function init(param1:DisplayLayer, param2:MovieClip) : void
      {
         _buddyList = new Dictionary(false);
         _blockedList = new Dictionary(false);
         _buddyRequestList = new Dictionary(false);
         _buddyRequestPopups = new Dictionary(false);
         _confirmBuddyRequestPopups = new Dictionary(false);
         _popupLayer = param1;
         _eventDispatcher = new EventDispatcher();
         BuddyCard.init(_popupLayer);
         BuddyList.init(_popupLayer,param2);
         _buddyRequestCleanupTimer = new Timer(BUDDY_REQUEST_TIMEOUT);
         _buddyRequestCleanupTimer.addEventListener(TimerEvent.TIMER,buddyRequestCleanupTimerHandler,false,0,true);
         _buddyRequestCleanupTimer.start();
      }
      
      public static function destroy() : void
      {
         var _loc1_:Buddy = null;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         for each(_loc1_ in _buddyList)
         {
            _loc1_ = null;
         }
         for each(_loc2_ in _blockedList)
         {
            _loc2_ = null;
         }
         for each(_loc3_ in _buddyRequestList)
         {
            _loc3_ = null;
         }
         for each(_loc4_ in _buddyRequestPopups)
         {
            _loc4_ = null;
         }
         for each(_loc5_ in _confirmBuddyRequestPopups)
         {
            _loc5_ = null;
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
      
      public static function isBuddy(param1:String) : Boolean
      {
         return _buddyList[param1.toLowerCase()] != null;
      }
      
      public static function isBlocked(param1:String) : Boolean
      {
         return _blockedList[param1.toLowerCase()] != null;
      }
      
      public static function getBuddyByUserName(param1:String) : Buddy
      {
         return _buddyList[param1.toLowerCase()];
      }
      
      public static function get buddyCount() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         for(_loc2_ in _buddyList)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      public static function addRemoveBuddy(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         if(param3)
         {
            _loc4_ = param1.toLowerCase();
            if(buddyCount < MAX_BUDDY_COUNT)
            {
               _loc6_ = _buddyRequestList[_loc4_];
               if(_loc6_ == null || _loc6_.expires < new Date().getTime())
               {
                  BuddyXtCommManager.sendBuddyAddRequest(param1);
                  _buddyRequestList[_loc4_] = {
                     "userName":param1,
                     "expires":new Date().getTime() + 30000,
                     "isAccepting":true
                  };
               }
               else
               {
                  if(_buddyRequestList[_loc4_] != null)
                  {
                     if(!_buddyRequestList[_loc4_].isAccepting)
                     {
                        _buddyRequestPopups[_loc4_] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14706,param2));
                        return;
                     }
                  }
                  _buddyRequestPopups[_loc4_] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14707,param2));
               }
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14708));
            }
         }
         else
         {
            BuddyXtCommManager.sendBuddyDeleteRequest(param1);
         }
      }
      
      private static function buddyAddRequestCallback(param1:Object) : void
      {
         var _loc2_:Timer = _confirmBuddyRequestPopups[param1.passback.toLowerCase()].timer;
         if(_loc2_)
         {
            _loc2_.reset();
            _loc2_ = null;
         }
         var _loc3_:BuddyRequest = _confirmBuddyRequestPopups[param1.passback.toLowerCase()].popup;
         if(_loc3_)
         {
            _loc3_.destroy();
            _loc3_ = null;
         }
         delete _confirmBuddyRequestPopups[param1.passback.toLowerCase()];
         if(buddyCount < MAX_BUDDY_COUNT)
         {
            BuddyXtCommManager.sendBuddyConfirmRequest(param1.passback,param1.status);
         }
         else
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14708));
         }
      }
      
      public static function buddyListResponseHandler(param1:Object) : void
      {
         var _loc7_:Buddy = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:UserInfo = null;
         var _loc15_:AvatarInfo = null;
         var _loc16_:Buddy = null;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         _buddyList = new Dictionary(true);
         var _loc2_:* = 3;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc7_ = new Buddy();
            _loc8_ = param1[_loc2_++];
            _loc9_ = param1[_loc2_++];
            _loc10_ = int(param1[_loc2_++]);
            _loc11_ = param1[_loc2_++];
            _loc12_ = int(param1[_loc2_++]);
            _loc13_ = int(param1[_loc2_++]);
            _loc7_.init(_loc8_,_loc9_,_loc10_,SFClient.STATUS_ONLINE,_loc13_);
            _buddyList[_loc8_.toLowerCase()] = _loc7_;
            _loc14_ = gMainFrame.userInfo.getUserInfoByUserName(_loc8_);
            if(!_loc14_)
            {
               if(_loc12_ > -1)
               {
                  _loc15_ = new AvatarInfo();
                  _loc15_.init(_loc12_,_loc11_,_loc8_,_loc9_);
                  _loc14_ = new UserInfo();
                  _loc14_.init(_loc8_,_loc9_,null,_loc12_);
                  _loc14_.addAvatarToList(_loc15_);
                  _loc14_.accountType = _loc13_;
                  _loc14_.userNameModeratedFlag = _loc10_;
                  gMainFrame.userInfo.setUserInfoByUserName(_loc8_,_loc14_);
               }
            }
            else
            {
               if(_loc12_ > -1 && !_loc14_.getAvatarInfoByPerUserAvId(_loc12_))
               {
                  _loc15_ = new AvatarInfo();
                  _loc15_.init(_loc12_,_loc11_,_loc8_,_loc9_);
                  _loc14_.addAvatarToList(_loc15_);
               }
               _loc14_.uuid = _loc9_;
               _loc14_.userNameModeratedFlag = _loc10_;
               _loc14_.accountType = _loc13_;
               if(_loc12_ > -1)
               {
                  _loc14_.currPerUserAvId = _loc12_;
               }
            }
            _loc4_++;
         }
         var _loc5_:int = int(param1[_loc2_++]);
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            _loc16_ = new Buddy();
            _loc17_ = param1[_loc2_++];
            _loc18_ = param1[_loc2_++];
            _loc19_ = int(param1[_loc2_++]);
            _loc20_ = int(param1[_loc2_++]);
            _loc21_ = int(param1[_loc2_++]);
            _loc22_ = _loc20_ > -1 ? SFClient.STATUS_OFFLINE_ACTIVE : SFClient.STATUS_OFFLINE_ARCHIVED;
            if(_loc22_ == SFClient.STATUS_OFFLINE_ARCHIVED)
            {
               _loc19_ = 1;
            }
            _loc16_.init(_loc17_,_loc18_,_loc19_,_loc22_,_loc21_,_loc20_);
            _buddyList[_loc17_.toLowerCase()] = _loc16_;
            _loc4_++;
         }
         BuddyList.listRequested = true;
         var _loc6_:BuddyEvent = new BuddyEvent(BuddyEvent.BUDDY_LIST);
         _eventDispatcher.dispatchEvent(_loc6_);
      }
      
      public static function blockedListResponseHandler(param1:Object) : void
      {
         var _loc2_:* = 3;
         var _loc3_:int = int(param1[_loc2_++]);
         _blockedList = new Dictionary(true);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _blockedList[param1[_loc2_++].toLowerCase()] = "1";
            _loc4_++;
         }
      }
      
      public static function buddyAddRequestResponseHandler(param1:int, param2:String, param3:int) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:BuddyTimer = null;
         var _loc4_:String = param3 > 0 ? param2 : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
         if(param1 == 0)
         {
            if(!_buddyList[param2.toLowerCase()])
            {
               _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(param2);
               _loc6_ = new BuddyTimer(BUDDY_REQUEST_TIMEOUT);
               _loc6_.userName = param2.toLowerCase();
               _loc6_.addEventListener(TimerEvent.TIMER,confirmPopupTimerHandler,false,0,true);
               _confirmBuddyRequestPopups[param2.toLowerCase()] = {
                  "popup":new BuddyRequest(param2,buddyAddRequestCallback,BuddyRequest.ACCEPT_REJECT),
                  "timer":_loc6_
               };
               _loc6_.start();
            }
         }
         else if(param1 == 1)
         {
            _buddyRequestPopups[param2.toLowerCase()] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14707,_loc4_));
         }
         else if(param1 == 2)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14710,_loc4_));
         }
         else if(param1 == 3)
         {
            if(_buddyRequestList[param2.toLowerCase()] != null)
            {
               _buddyRequestList[param2.toLowerCase()].isAccepting = false;
            }
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14706,_loc4_));
         }
         else if(param1 == 4)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14708));
         }
      }
      
      public static function buddyStatusResponseHandler(param1:String, param2:String, param3:int, param4:Boolean, param5:int, param6:int, param7:String = null, param8:String = null, param9:int = -1) : void
      {
         var _loc14_:AvatarInfo = null;
         var _loc15_:String = null;
         var _loc10_:String = param1.toLowerCase();
         var _loc11_:Buddy = _buddyList[_loc10_];
         var _loc12_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1);
         if(!_loc12_)
         {
            _loc12_ = new UserInfo();
            _loc12_.init(param1,param2);
            _loc12_.userNameModeratedFlag = param3;
            gMainFrame.userInfo.setUserInfoByUserName(param1,_loc12_);
         }
         _loc12_.accountType = param5;
         if(param8)
         {
            _loc14_ = _loc12_.getAvatarInfoByPerUserAvId(param9);
            if(param9 > 0)
            {
               if(!_loc14_)
               {
                  _loc14_ = new AvatarInfo();
                  _loc14_.init(param9,param8,param1,param2);
                  _loc12_.addAvatarToList(_loc14_);
               }
               _loc12_.currPerUserAvId = param9;
            }
         }
         if(param6 != 3 && param6 != 4)
         {
            if(_loc11_)
            {
               _loc11_.userName = param1;
               _loc11_.userNameModeratedFlag = param3;
               if(_loc11_.isOnline && !param4)
               {
                  --_numOnlineBuddies;
                  _loc11_.numDaysSinceLastLogin = 0;
               }
               else if(!_loc11_.isOnline && param4)
               {
                  if(Utility.canBuddy())
                  {
                     BuddyList.startBuddyListBtnGlow();
                  }
                  ++_numOnlineBuddies;
               }
               _loc11_.onlineStatus = param4 ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE;
            }
            else
            {
               _loc11_ = new Buddy();
               _loc11_.init(param1,param2,param3,param4 ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE,param5);
               _buddyList[_loc10_] = _loc11_;
               if(param6 == 1)
               {
                  if(_buddyRequestPopups[_loc10_] != null)
                  {
                     _buddyRequestPopups[_loc10_].destroy();
                     delete _buddyRequestPopups[_loc10_];
                  }
                  SBPopupManager.nonSBPopups.push(new BuddyRequest(param1,null,BuddyRequest.CONFIRMATION));
               }
               else if(param6 == 2)
               {
                  SBPopupManager.nonSBPopups.push(new BuddyRequest(param1,null,BuddyRequest.CONFIRMATION));
               }
            }
         }
         else
         {
            if(_loc11_)
            {
               _loc11_.userName = param7;
               _loc11_.userNameModeratedFlag = param3;
               if(_loc11_.isOnline && !param4)
               {
                  --_numOnlineBuddies;
               }
               else if(!_loc11_.isOnline && param4)
               {
                  BuddyList.startBuddyListBtnGlow();
                  ++_numOnlineBuddies;
               }
               _loc11_.onlineStatus = param4 ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE;
               delete _buddyList[_loc10_];
               _buddyList[param7.toLowerCase()] = _loc11_;
               BuddyCard.userNameChange(param1,param7,_loc11_.userNameModerated);
               gMainFrame.userInfo.changeUserName(param1,param7,param3);
               param1 = param7;
            }
            if(isBlocked(_loc10_))
            {
               _loc15_ = param3 > 0 ? param7 : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
               BuddyCard.userNameChange(param1,param7,_loc15_);
               gMainFrame.userInfo.changeUserName(param1,param7,param3);
               param1 = param7;
               delete _blockedList[_loc10_];
               _blockedList[param7.toLowerCase()] = "1";
            }
         }
         var _loc13_:BuddyEvent = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
         _loc13_.userName = param1;
         _eventDispatcher.dispatchEvent(_loc13_);
      }
      
      public static function buddyDeleteResponseHandler(param1:String) : void
      {
         var _loc3_:BuddyEvent = null;
         var _loc2_:String = param1.toLowerCase();
         if(_buddyList[_loc2_])
         {
            delete _buddyList[_loc2_];
            delete _buddyRequestList[_loc2_];
            _loc3_ = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
            _loc3_.userName = param1;
            _eventDispatcher.dispatchEvent(_loc3_);
         }
      }
      
      public static function buddyBlockResponseHandler(param1:String, param2:Boolean) : void
      {
         var _loc3_:BuddyEvent = null;
         if(param2)
         {
            _blockedList[param1.toLowerCase()] = "1";
            _loc3_ = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
            _loc3_.userName = param1;
            _eventDispatcher.dispatchEvent(_loc3_);
         }
      }
      
      public static function buddyUnblockResponseHandler(param1:String, param2:Boolean) : void
      {
         var _loc3_:BuddyEvent = null;
         if(param2)
         {
            delete _blockedList[param1.toLowerCase()];
            _loc3_ = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
            _loc3_.userName = param1;
            _eventDispatcher.dispatchEvent(_loc3_);
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
         var _loc1_:BuddyEvent = new BuddyEvent(BuddyEvent.BUDDY_LIST);
         BuddyManager.eventDispatcher.dispatchEvent(_loc1_);
      }
      
      private static function buddyRequestCleanupTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         for each(_loc2_ in _buddyRequestList)
         {
            _loc3_ = _loc2_.userName.toLowerCase();
            if(_loc2_ == null || _loc2_.expires < new Date().getTime())
            {
               delete _buddyRequestList[_loc3_];
               if(_buddyRequestPopups[_loc3_] != null)
               {
                  delete _buddyRequestPopups[_loc3_];
               }
            }
         }
      }
      
      private static function confirmPopupTimerHandler(param1:TimerEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc2_:BuddyTimer = BuddyTimer(param1.currentTarget);
         if(_loc2_)
         {
            _loc3_ = _loc2_.userName;
            _loc2_.stop();
            _loc2_ = null;
            _loc4_ = _confirmBuddyRequestPopups[_loc3_];
            if(_loc4_ != null)
            {
               if(_loc4_.popup)
               {
                  _loc4_.popup.destroy();
                  _loc4_.popup = null;
               }
               delete _confirmBuddyRequestPopups[_loc3_];
            }
         }
      }
   }
}

