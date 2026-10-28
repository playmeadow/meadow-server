package gui
{
   import avatar.AvatarInfo;
   import avatar.UserInfo;
   import buddy.Buddy;
   import buddy.BuddyEvent;
   import buddy.BuddyTimer;
   import buddy.BuddyXtCommManager;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopupManager;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import localization.LocalizationManager;
   import playerWall.PlayerWallManager;
   
   public class BuddyManager
   {
      
      public static const MAX_BUDDY_COUNT:int = 100;
      
      public static const WARNING_BUDDY_COUNT:int = 95;
      
      private static const PERMISSION_TIMEOUT:int = 20000;
      
      private static const BUDDY_REQUEST_TIMEOUT:int = 30000;
      
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
      
      private static var _timeSinceLastHostingUpdate:Number;
      
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
         _timeSinceLastHostingUpdate = 0;
         _popupLayer = param1;
         _eventDispatcher = new EventDispatcher();
         BuddyCard.init(_popupLayer);
         BuddyList.init(_popupLayer,param2);
         _buddyRequestCleanupTimer = new Timer(30000);
         _buddyRequestCleanupTimer.addEventListener("timer",buddyRequestCleanupTimerHandler,false,0,true);
         _buddyRequestCleanupTimer.start();
      }
      
      public static function destroy() : void
      {
         for each(var _loc4_:Buddy in _buddyList)
         {
            _loc4_ = null;
         }
         for each(var _loc2_:Object in _blockedList)
         {
            _loc2_ = null;
         }
         for each(var _loc5_:Object in _buddyRequestList)
         {
            _loc5_ = null;
         }
         for each(var _loc3_:Object in _buddyRequestPopups)
         {
            _loc3_ = null;
         }
         for each(var _loc1_:Object in _confirmBuddyRequestPopups)
         {
            _loc1_ = null;
         }
         _eventDispatcher = null;
         _buddyList = null;
         _blockedList = null;
         BuddyCard.destroy();
         BuddyList.destroy();
      }
      
      public static function heartbeat(param1:int) : void
      {
         _timeSinceLastHostingUpdate += param1 / 1000;
         if(_timeSinceLastHostingUpdate >= 10)
         {
            for each(var _loc2_:Buddy in _buddyList)
            {
               _loc2_.timeLeftHostingCustomParty -= 10;
            }
            BuddyList.updateBuddyTimeLeftHosting();
            _timeSinceLastHostingUpdate = 0;
         }
      }
      
      public static function get eventDispatcher() : EventDispatcher
      {
         return _eventDispatcher;
      }
      
      public static function isBuddy(param1:String) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         return _buddyList[param1.toLowerCase()] != null;
      }
      
      public static function isBlocked(param1:String) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         return _blockedList[param1.toLowerCase()] != null;
      }
      
      public static function getBuddyByUserName(param1:String) : Buddy
      {
         return _buddyList[param1.toLowerCase()];
      }
      
      public static function get buddyCount() : int
      {
         var _loc2_:int = 0;
         for(var _loc1_:Object in _buddyList)
         {
            _loc2_++;
         }
         return _loc2_;
      }
      
      public static function addRemoveBuddy(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc4_:String = null;
         var _loc6_:* = null;
         var _loc5_:Object = null;
         if(param3)
         {
            _loc4_ = param1.toLowerCase();
            if(buddyCount < 100)
            {
               _loc5_ = _buddyRequestList[_loc4_];
               if(_loc5_ == null || _loc5_.expires < new Date().getTime())
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
            delete PlayerWallManager.tokenMap[param1.toLowerCase()];
         }
      }
      
      private static function buddyAddRequestCallback(param1:Object) : void
      {
         var _loc3_:Timer = _confirmBuddyRequestPopups[param1.passback.toLowerCase()].timer;
         if(_loc3_)
         {
            _loc3_.reset();
            _loc3_ = null;
         }
         var _loc2_:BuddyRequest = _confirmBuddyRequestPopups[param1.passback.toLowerCase()].popup;
         if(_loc2_)
         {
            _loc2_.destroy();
            _loc2_ = null;
         }
         delete _confirmBuddyRequestPopups[param1.passback.toLowerCase()];
         if(buddyCount < 100)
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
         var _loc12_:int = 0;
         var _loc19_:Buddy = null;
         var _loc16_:String = null;
         var _loc18_:String = null;
         var _loc3_:int = 0;
         var _loc20_:String = null;
         var _loc15_:int = 0;
         var _loc21_:int = 0;
         var _loc7_:int = 0;
         var _loc14_:UserInfo = null;
         var _loc10_:AvatarInfo = null;
         var _loc8_:Buddy = null;
         var _loc23_:String = null;
         var _loc17_:String = null;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc22_:int = 0;
         var _loc9_:int = 0;
         _buddyList = new Dictionary(true);
         var _loc13_:int = 3;
         var _loc6_:int = int(param1[_loc13_++]);
         _loc12_ = 0;
         while(_loc12_ < _loc6_)
         {
            _loc19_ = new Buddy();
            _loc16_ = param1[_loc13_++];
            _loc18_ = param1[_loc13_++];
            _loc3_ = int(param1[_loc13_++]);
            _loc20_ = param1[_loc13_++];
            _loc15_ = int(param1[_loc13_++]);
            _loc21_ = int(param1[_loc13_++]);
            _loc7_ = int(param1[_loc13_++]);
            _loc19_.init(_loc16_,_loc18_,_loc3_,1,_loc21_,0,_loc7_);
            _buddyList[_loc16_.toLowerCase()] = _loc19_;
            _loc14_ = gMainFrame.userInfo.getUserInfoByUserName(_loc16_);
            if(!_loc14_)
            {
               if(_loc15_ > -1)
               {
                  _loc10_ = new AvatarInfo();
                  _loc10_.init(_loc15_,_loc20_,_loc16_,_loc18_);
                  _loc14_ = new UserInfo();
                  _loc14_.init(_loc16_,_loc18_,null,_loc15_,_loc21_,_loc3_,_loc7_);
                  _loc14_.addAvatarToList(_loc10_);
                  gMainFrame.userInfo.setUserInfoByUserName(_loc16_,_loc14_);
               }
            }
            else
            {
               if(_loc15_ > -1 && !_loc14_.getAvatarInfoByPerUserAvId(_loc15_))
               {
                  _loc10_ = new AvatarInfo();
                  _loc10_.init(_loc15_,_loc20_,_loc16_,_loc18_);
                  _loc14_.addAvatarToList(_loc10_);
               }
               _loc14_.uuid = _loc18_;
               _loc14_.userNameModeratedFlag = _loc3_;
               _loc14_.accountType = _loc21_;
               _loc14_.timeLeftHostingCustomParty = _loc7_;
               if(_loc15_ > -1)
               {
                  _loc14_.currPerUserAvId = _loc15_;
               }
            }
            _loc12_++;
         }
         var _loc11_:int = int(param1[_loc13_++]);
         _loc12_ = 0;
         while(_loc12_ < _loc11_)
         {
            _loc8_ = new Buddy();
            _loc23_ = param1[_loc13_++];
            _loc17_ = param1[_loc13_++];
            _loc5_ = int(param1[_loc13_++]);
            _loc2_ = int(param1[_loc13_++]);
            _loc22_ = int(param1[_loc13_++]);
            _loc9_ = _loc2_ > -1 ? 0 : -1;
            if(_loc9_ == -1)
            {
               _loc5_ = 1;
            }
            _loc8_.init(_loc23_,_loc17_,_loc5_,_loc9_,_loc22_,_loc2_,-1);
            _buddyList[_loc23_.toLowerCase()] = _loc8_;
            _loc12_++;
         }
         BuddyList.listRequested = true;
         var _loc4_:BuddyEvent = new BuddyEvent("OnBuddyList");
         _eventDispatcher.dispatchEvent(_loc4_);
      }
      
      public static function blockedListResponseHandler(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 3;
         var _loc2_:int = int(param1[_loc4_++]);
         _blockedList = new Dictionary(true);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _blockedList[param1[_loc4_++].toLowerCase()] = "1";
            _loc3_++;
         }
      }
      
      public static function buddyAddRequestResponseHandler(param1:int, param2:String, param3:int) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:BuddyTimer = null;
         var _loc4_:String = param3 > 0 ? param2 : LocalizationManager.translateIdOnly(11098);
         if(param1 == 0)
         {
            if(!_buddyList[param2.toLowerCase()])
            {
               _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(param2);
               _loc6_ = new BuddyTimer(30000);
               _loc6_.userName = param2.toLowerCase();
               _loc6_.addEventListener("timer",confirmPopupTimerHandler,false,0,true);
               _confirmBuddyRequestPopups[param2.toLowerCase()] = {
                  "popup":new BuddyRequest(param2,buddyAddRequestCallback,1),
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
      
      public static function buddyStatusResponseHandler(param1:String, param2:String, param3:int, param4:Boolean, param5:int, param6:int, param7:String = null, param8:String = null, param9:int = -1, param10:int = -1) : void
      {
         var _loc12_:AvatarInfo = null;
         var _loc13_:String = null;
         var _loc14_:String = param1.toLowerCase();
         var _loc16_:Buddy = _buddyList[_loc14_];
         var _loc15_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1);
         if(!_loc15_)
         {
            _loc15_ = new UserInfo();
            _loc15_.init(param1,param2);
            _loc15_.userNameModeratedFlag = param3;
            _loc15_.timeLeftHostingCustomParty = param10;
            gMainFrame.userInfo.setUserInfoByUserName(param1,_loc15_);
         }
         _loc15_.accountType = param5;
         if(param8)
         {
            _loc12_ = _loc15_.getAvatarInfoByPerUserAvId(param9);
            if(param9 > 0)
            {
               if(!_loc12_)
               {
                  _loc12_ = new AvatarInfo();
                  _loc12_.init(param9,param8,param1,param2);
                  _loc15_.addAvatarToList(_loc12_);
               }
               _loc15_.currPerUserAvId = param9;
            }
         }
         if(param6 != 3 && param6 != 4)
         {
            if(_loc16_)
            {
               _loc16_.userName = param1;
               _loc16_.userNameModeratedFlag = param3;
               _loc16_.timeLeftHostingCustomParty = param10;
               if(_loc16_.isOnline && !param4)
               {
                  _numOnlineBuddies = _numOnlineBuddies - 1;
                  _loc16_.numDaysSinceLastLogin = 0;
               }
               else if(!_loc16_.isOnline && param4)
               {
                  if(Utility.canBuddy())
                  {
                     BuddyList.startBuddyListBtnGlow();
                  }
                  _numOnlineBuddies = _numOnlineBuddies + 1;
               }
               _loc16_.onlineStatus = param4 ? 1 : 0;
            }
            else
            {
               _loc16_ = new Buddy();
               _loc16_.init(param1,param2,param3,param4 ? 1 : 0,param5,0,param10);
               _buddyList[_loc14_] = _loc16_;
               if(param6 == 1)
               {
                  if(_buddyRequestPopups[_loc14_] != null)
                  {
                     _buddyRequestPopups[_loc14_].destroy();
                     delete _buddyRequestPopups[_loc14_];
                  }
                  SBPopupManager.nonSBPopups.push(new BuddyRequest(param1,null,2));
               }
               else if(param6 == 2)
               {
                  SBPopupManager.nonSBPopups.push(new BuddyRequest(param1,null,2));
               }
            }
         }
         else
         {
            if(_loc16_)
            {
               _loc16_.userName = param7;
               _loc16_.userNameModeratedFlag = param3;
               _loc16_.timeLeftHostingCustomParty = param10;
               if(_loc16_.isOnline && !param4)
               {
                  _numOnlineBuddies = _numOnlineBuddies - 1;
               }
               else if(!_loc16_.isOnline && param4)
               {
                  BuddyList.startBuddyListBtnGlow();
                  _numOnlineBuddies = _numOnlineBuddies + 1;
               }
               _loc16_.onlineStatus = param4 ? 1 : 0;
               delete _buddyList[_loc14_];
               _buddyList[param7.toLowerCase()] = _loc16_;
               BuddyCard.userNameChange(param1,param7,_loc16_.userNameModerated);
               gMainFrame.userInfo.changeUserName(param1,param7,param3);
               param1 = param7;
            }
            if(isBlocked(_loc14_))
            {
               _loc13_ = param3 > 0 ? param7 : LocalizationManager.translateIdOnly(11098);
               BuddyCard.userNameChange(param1,param7,_loc13_);
               gMainFrame.userInfo.changeUserName(param1,param7,param3);
               param1 = param7;
               delete _blockedList[_loc14_];
               _blockedList[param7.toLowerCase()] = "1";
            }
         }
         var _loc11_:BuddyEvent = new BuddyEvent("OnBuddyChanged");
         _loc11_.userName = param1;
         _eventDispatcher.dispatchEvent(_loc11_);
      }
      
      public static function buddyDeleteResponseHandler(param1:String) : void
      {
         var _loc2_:BuddyEvent = null;
         var _loc3_:String = param1.toLowerCase();
         if(_buddyList[_loc3_])
         {
            delete _buddyList[_loc3_];
            delete _buddyRequestList[_loc3_];
            _loc2_ = new BuddyEvent("OnBuddyChanged");
            _loc2_.userName = param1;
            _eventDispatcher.dispatchEvent(_loc2_);
         }
      }
      
      public static function buddyBlockResponseHandler(param1:String, param2:Boolean) : void
      {
         var _loc3_:BuddyEvent = null;
         if(param2)
         {
            _blockedList[param1.toLowerCase()] = "1";
            _loc3_ = new BuddyEvent("OnBuddyChanged");
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
            _loc3_ = new BuddyEvent("OnBuddyChanged");
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
         var _loc1_:BuddyEvent = new BuddyEvent("OnBuddyList");
         BuddyManager.eventDispatcher.dispatchEvent(_loc1_);
      }
      
      private static function buddyRequestCleanupTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:String = null;
         for each(var _loc3_:Object in _buddyRequestList)
         {
            _loc2_ = _loc3_.userName.toLowerCase();
            if(_loc3_ == null || _loc3_.expires < new Date().getTime())
            {
               delete _buddyRequestList[_loc2_];
               if(_buddyRequestPopups[_loc2_] != null)
               {
                  delete _buddyRequestPopups[_loc2_];
               }
            }
         }
      }
      
      private static function confirmPopupTimerHandler(param1:TimerEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = null;
         var _loc4_:BuddyTimer = BuddyTimer(param1.currentTarget);
         if(_loc4_)
         {
            _loc3_ = _loc4_.userName;
            _loc4_.stop();
            _loc4_ = null;
            _loc2_ = _confirmBuddyRequestPopups[_loc3_];
            if(_loc2_ != null)
            {
               if(_loc2_.popup)
               {
                  _loc2_.popup.destroy();
                  _loc2_.popup = null;
               }
               delete _confirmBuddyRequestPopups[_loc3_];
            }
         }
      }
   }
}

