package com.sbi.client
{
   import com.sbi.popup.SBOkPopup;
   import flash.display.*;
   import flash.events.*;
   import flash.utils.Timer;
   import localization.LocalizationManager;
   
   public class KeepAlive
   {
      
      public static var popupLayer:DisplayObjectContainer;
      
      private static var _keepAliveTimer:Timer;
      
      private static var _timeLeftTimer:Timer;
      
      private static var _bInputReceived:Boolean;
      
      private static var _mcsToKeepAlive:Array;
      
      private static var _lastMsgSentToServer:Number;
      
      private static var _inputTimer:Timer;
      
      private static var _kickWarningPopupShowing:Boolean;
      
      private static var _isConnected:Function;
      
      private static var _disconnectClient:Function;
      
      private static var _playIdleWarningSound:Function;
      
      private static var KICK_INTERVAL:int = 360000;
      
      private static var SEND_MSG_INTERVAL:int = 180000;
      
      private static var NOTIFY_USER_INTERVAL:int = 10000;
      
      private static var NOTIFY_USER_TIME:int = 30000;
      
      public function KeepAlive()
      {
         super();
      }
      
      public static function init(init_popupLayer:DisplayObjectContainer, initIsConnected:Function, disconnectClient:Function = null, playIdleWarningSound:Function = null) : void
      {
         popupLayer = init_popupLayer;
         _keepAliveTimer = new Timer(SEND_MSG_INTERVAL);
         _keepAliveTimer.addEventListener(TimerEvent.TIMER,sendKeepAliveMsg);
         _timeLeftTimer = new Timer(NOTIFY_USER_INTERVAL);
         _timeLeftTimer.addEventListener(TimerEvent.TIMER,timeLeftTimer);
         _timeLeftTimer.start();
         _lastMsgSentToServer = new Date().getTime();
         _mcsToKeepAlive = new Array();
         _isConnected = initIsConnected;
         _disconnectClient = disconnectClient;
         _playIdleWarningSound = playIdleWarningSound;
      }
      
      public static function startKATimer(mcToKeepAlive:DisplayObjectContainer) : void
      {
         mcToKeepAlive.addEventListener(MouseEvent.MOUSE_DOWN,inputReceivedHandler,false,0,true);
         mcToKeepAlive.addEventListener(KeyboardEvent.KEY_DOWN,inputReceivedHandler,false,0,true);
         _mcsToKeepAlive.push(mcToKeepAlive);
         _bInputReceived = true;
         sendKeepAliveMsg(null);
         _keepAliveTimer.start();
      }
      
      public static function stopKATimer(mcToStop:DisplayObjectContainer) : void
      {
         gMainFrame.server.setXtObject_Str("ka",[],gMainFrame.server.isWorldZone);
         _keepAliveTimer.stop();
         for(var i:int = 0; i < _mcsToKeepAlive.length; i++)
         {
            if(_mcsToKeepAlive[i] == mcToStop)
            {
               _mcsToKeepAlive[i].removeEventListener(MouseEvent.MOUSE_DOWN,inputReceivedHandler);
               _mcsToKeepAlive[i].removeEventListener(KeyboardEvent.KEY_DOWN,inputReceivedHandler);
               _mcsToKeepAlive.splice(i,1);
               break;
            }
         }
      }
      
      public static function restartTimeLeftTimer() : void
      {
         if(Boolean(_timeLeftTimer))
         {
            _lastMsgSentToServer = new Date().getTime();
            _timeLeftTimer.stop();
            _timeLeftTimer.start();
         }
      }
      
      private static function sendKeepAliveMsg(evt:TimerEvent) : void
      {
         if(_bInputReceived)
         {
            gMainFrame.server.setXtObject_Str("ka",[],gMainFrame.server.isWorldZone);
            _lastMsgSentToServer = new Date().getTime();
            _bInputReceived = false;
         }
      }
      
      private static function timeLeftTimer(evt:TimerEvent) : void
      {
         var rustPop:DisplayObject = null;
         var elapsedTime:Number = new Date().getTime() - _lastMsgSentToServer;
         if(!_kickWarningPopupShowing && elapsedTime > KICK_INTERVAL - NOTIFY_USER_TIME)
         {
            rustPop = new SBOkPopup(popupLayer,LocalizationManager.translateIdOnly(14681),true,onKickWarningPopup);
            _kickWarningPopupShowing = true;
            if(_playIdleWarningSound != null)
            {
               _playIdleWarningSound();
            }
            if(Boolean(gMainFrame.userInfo.isModerator))
            {
               _bInputReceived = true;
               sendKeepAliveMsg(null);
               _kickWarningPopupShowing = false;
               SBOkPopup.destroyInParentChain(rustPop);
            }
         }
         if(elapsedTime > KICK_INTERVAL)
         {
            if(Boolean(_isConnected()))
            {
               if(_disconnectClient != null)
               {
                  _disconnectClient();
               }
            }
         }
      }
      
      private static function onKickWarningPopup(evt:MouseEvent) : void
      {
         _bInputReceived = true;
         sendKeepAliveMsg(null);
         evt.stopPropagation();
         SBOkPopup.destroyInParentChain(evt.target.parent);
         _kickWarningPopupShowing = false;
      }
      
      public static function inputReceivedHandler(evt:Event) : void
      {
         if(!_bInputReceived)
         {
            _bInputReceived = true;
         }
         if(new Date().getTime() - _lastMsgSentToServer > SEND_MSG_INTERVAL)
         {
            sendKeepAliveMsg(null);
         }
      }
   }
}

