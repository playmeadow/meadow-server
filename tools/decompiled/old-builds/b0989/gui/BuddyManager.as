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
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
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
      
      public static function addRemoveBuddy(param1:String, param2:Boolean) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         if(param2)
         {
            _loc3_ = param1.toLowerCase();
            if(buddyCount < MAX_BUDDY_COUNT)
            {
               _loc5_ = _buddyRequestList[_loc3_];
               if(_loc5_ == null || _loc5_.expires < new Date().getTime())
               {
                  BuddyXtCommManager.sendBuddyAddRequest(param1);
                  _buddyRequestList[_loc3_] = {
                     "userName":param1,
                     "expires":new Date().getTime() + 30000,
                     "isAccepting":true
                  };
               }
               else
               {
                  if(_buddyRequestList[_loc3_] != null)
                  {
                     if(_buddyRequestList[_loc3_].isAccepting)
                     {
                        _buddyRequestPopups[_loc3_] = new SBOkPopup(_popupLayer,param1 + " is not accepting buddy requests right now.");
                        return;
                     }
                  }
                  _buddyRequestPopups[_loc3_] = new SBOkPopup(_popupLayer,"Buddy request sent to " + param1 + ".");
               }
            }
            else
            {
               new SBOkPopup(_popupLayer,"Your buddy list is full! Remove a buddy to free up space.");
            }
         }
         else
         {
            BuddyXtCommManager.sendBuddyDeleteRequest(param1);
         }
      }
      
      private static function buddyAddRequestCallback(param1:Object) : void
      {
         if(buddyCount < MAX_BUDDY_COUNT)
         {
            BuddyXtCommManager.sendBuddyConfirmRequest(param1.passback,param1.status);
         }
         else
         {
            new SBOkPopup(_popupLayer,"Your buddy list is full! Remove a buddy to free up space.");
         }
      }
      
      public static function buddyListResponseHandler(param1:Object) : void
      {
         var _loc7_:Buddy = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:UserInfo = null;
         var _loc13_:AvatarInfo = null;
         var _loc14_:Buddy = null;
         var _loc15_:String = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
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
            _loc11_ = int(param1[_loc2_++]);
            _loc7_.init(_loc8_,SFClient.STATUS_ONLINE);
            _buddyList[_loc8_.toLowerCase()] = _loc7_;
            _loc12_ = gMainFrame.userInfo.getUserInfoByUserName(_loc8_);
            if(!_loc12_)
            {
               _loc13_ = new AvatarInfo();
               _loc13_.init(_loc10_,_loc9_,_loc8_);
               _loc12_ = new UserInfo();
               _loc12_.init(_loc8_,null,_loc10_);
               _loc12_.addAvatarToList(_loc13_);
               _loc12_.accountType = _loc11_;
               gMainFrame.userInfo.setUserInfoByUserName(_loc8_,_loc12_);
            }
            else
            {
               if(!_loc12_.getAvatarInfoByDbAvId(_loc10_))
               {
                  _loc13_ = new AvatarInfo();
                  _loc13_.init(_loc10_,_loc9_,_loc8_);
                  _loc12_.addAvatarToList(_loc13_);
               }
               _loc12_.accountType = _loc11_;
               _loc12_.currDbAvId = _loc10_;
            }
            _loc4_++;
         }
         var _loc5_:int = int(param1[_loc2_++]);
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            _loc14_ = new Buddy();
            _loc15_ = param1[_loc2_++];
            _loc16_ = int(param1[_loc2_++]);
            _loc17_ = _loc16_ > -1 ? SFClient.STATUS_OFFLINE_ACTIVE : SFClient.STATUS_OFFLINE_ARCHIVED;
            _loc14_.init(_loc15_,_loc17_,_loc16_);
            _buddyList[_loc15_.toLowerCase()] = _loc14_;
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
      
      public static function buddyAddRequestResponseHandler(param1:int, param2:String) : void
      {
         var _loc3_:AvatarInfo = null;
         var _loc4_:BuddyTimer = null;
         var _loc5_:SBYesNoPopup = null;
         if(param1 == 0)
         {
            if(!_buddyList[param2.toLowerCase()])
            {
               _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserName(param2);
               _loc4_ = new BuddyTimer(BUDDY_REQUEST_TIMEOUT);
               _loc4_.userName = param2.toLowerCase();
               _loc4_.addEventListener(TimerEvent.TIMER,confirmPopupTimerHandler,false,0,true);
               _loc5_ = new SBYesNoPopup(_popupLayer,"Do you want to be " + (_loc3_ != null ? _loc3_.avName : param2) + "\'s buddy?",true,buddyAddRequestCallback,param2);
               _confirmBuddyRequestPopups[param2.toLowerCase()] = {
                  "popup":_loc5_,
                  "timer":_loc4_
               };
               _loc4_.start();
            }
         }
         else if(param1 == 1)
         {
            _buddyRequestPopups[param2.toLowerCase()] = new SBOkPopup(_popupLayer,"Buddy request sent to " + param2 + ".");
         }
         else if(param1 == 2)
         {
            new SBOkPopup(_popupLayer,param2 + "\'s buddy list is full!");
         }
         else if(param1 == 3)
         {
            if(_buddyRequestList[param2.toLowerCase()] != null)
            {
               _buddyRequestList[param2.toLowerCase()].isAccepting = false;
            }
            new SBOkPopup(_popupLayer,param2 + " is not accepting buddy requests right now.");
         }
      }
      
      public static function buddyStatusResponseHandler(param1:String, param2:Boolean, param3:int, param4:int, param5:String = null, param6:String = null, param7:int = -1) : void
      {
         var _loc12_:AvatarInfo = null;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc8_:String = param1.toLowerCase();
         var _loc9_:Buddy = _buddyList[_loc8_];
         var _loc10_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1);
         if(!_loc10_)
         {
            _loc10_ = new UserInfo();
            _loc10_.init(param1);
            gMainFrame.userInfo.setUserInfoByUserName(param1,_loc10_);
         }
         _loc10_.accountType = param3;
         if(param6)
         {
            _loc12_ = _loc10_.getAvatarInfoByDbAvId(param7);
            if(!_loc12_)
            {
               _loc12_ = new AvatarInfo();
               _loc12_.init(param7,param6,param1);
               _loc10_.addAvatarToList(_loc12_);
            }
            if(param7 > 0)
            {
               _loc10_.currDbAvId = param7;
            }
         }
         if(param4 != 3 && param4 != 4)
         {
            if(_loc9_)
            {
               _loc9_.userName = param1;
               if(_loc9_.isOnline && !param2)
               {
                  --_numOnlineBuddies;
                  _loc9_.numDaysSinceLastLogin = 0;
               }
               else if(!_loc9_.isOnline && param2)
               {
                  if(Utility.canBuddy())
                  {
                     BuddyList.startBuddyListBtnGlow();
                  }
                  ++_numOnlineBuddies;
               }
               _loc9_.onlineStatus = param2 ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE;
            }
            else
            {
               _loc9_ = new Buddy();
               _loc9_.init(param1,param2 ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE);
               _buddyList[_loc8_] = _loc9_;
               _loc13_ = buddyCount;
               if(param4 == 1)
               {
                  if(_buddyRequestPopups[_loc8_] != null)
                  {
                     _buddyRequestPopups[_loc8_].destroy();
                     delete _buddyRequestPopups[_loc8_];
                  }
                  _loc14_ = param1 + " is now your buddy.";
                  if(_loc13_ >= WARNING_BUDDY_COUNT)
                  {
                     _loc14_ += " You have " + (MAX_BUDDY_COUNT - _loc13_) + " buddy slots remaining.";
                  }
                  new SBOkPopup(_popupLayer,_loc14_);
               }
               else if(param4 == 2 && _loc13_ >= WARNING_BUDDY_COUNT)
               {
                  new SBOkPopup(_popupLayer,param1 + " is now your buddy. You have " + (MAX_BUDDY_COUNT - _loc13_) + " buddy slots remaining.");
               }
            }
         }
         else
         {
            if(_loc9_)
            {
               _loc9_.userName = param5;
               if(_loc9_.isOnline && !param2)
               {
                  --_numOnlineBuddies;
               }
               else if(!_loc9_.isOnline && param2)
               {
                  BuddyList.startBuddyListBtnGlow();
                  ++_numOnlineBuddies;
               }
               _loc9_.onlineStatus = param2 ? SFClient.STATUS_ONLINE : SFClient.STATUS_OFFLINE_ACTIVE;
               delete _buddyList[_loc8_];
               _buddyList[param5.toLowerCase()] = _loc9_;
               BuddyCard.userNameChange(param1,param5);
               gMainFrame.userInfo.changeUserName(param1,param5);
               param1 = param5;
            }
            if(isBlocked(_loc8_))
            {
               BuddyCard.userNameChange(param1,param5);
               gMainFrame.userInfo.changeUserName(param1,param5);
               param1 = param5;
               delete _blockedList[_loc8_];
               _blockedList[param5.toLowerCase()] = "1";
            }
         }
         var _loc11_:BuddyEvent = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
         _loc11_.userName = param1;
         _eventDispatcher.dispatchEvent(_loc11_);
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

