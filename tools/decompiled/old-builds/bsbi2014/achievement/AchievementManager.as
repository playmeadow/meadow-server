package achievement
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class AchievementManager
   {
      
      private static var _newAchievements:Array;
      
      private static var _finishedCallbacks:Array;
      
      private static var _popupMediaHelper:MediaHelper;
      
      private static var _achievementPopup:MovieClip;
      
      private static var _achievementImg:Sprite;
      
      private static var _popupDisplayTimer:Timer;
      
      private static var _popupDelayTimer:Timer;
      
      private static var _state:int;
      
      private static var _fpsLayer:DisplayObjectContainer;
      
      private static const ACHIEVEMENT_POPUP_MEDIA_ID:int = 2721;
      
      private static const STATE_IDLE:int = 0;
      
      private static const STATE_DISPLAYING:int = 1;
      
      public function AchievementManager()
      {
         super();
      }
      
      public static function init(initFpsLayer:DisplayObjectContainer) : void
      {
         _fpsLayer = initFpsLayer;
         _finishedCallbacks = [];
         _newAchievements = [];
         _popupDisplayTimer = new Timer(3000);
         _popupDelayTimer = new Timer(500);
         _state = STATE_IDLE;
      }
      
      public static function destroy() : void
      {
         _newAchievements.splice(0,_newAchievements.length);
         _newAchievements = null;
         _finishedCallbacks.splice(0,_finishedCallbacks.length);
         _finishedCallbacks = null;
         if(Boolean(_popupDisplayTimer))
         {
            _popupDisplayTimer.stop();
            _popupDisplayTimer = null;
         }
         if(Boolean(_popupDelayTimer))
         {
            _popupDelayTimer.stop();
            _popupDelayTimer = null;
         }
      }
      
      public static function hasAchievement() : Boolean
      {
         return false;
      }
      
      public static function displayNewAchievements(finishedCallback:Function = null) : void
      {
         if(finishedCallback != null)
         {
            if(_finishedCallbacks.indexOf(finishedCallback) < 0 && _newAchievements.length > 0)
            {
               _finishedCallbacks.push(finishedCallback);
            }
            else
            {
               finishedCallback();
            }
         }
         if(_state == STATE_IDLE && _newAchievements.length > 0)
         {
            _state = STATE_DISPLAYING;
            displayNextAchievement();
         }
      }
      
      private static function finishedDisplayingNewAchievements() : void
      {
         var length:int = int(_finishedCallbacks.length);
         for(var i:int = 0; i < length; i++)
         {
            _finishedCallbacks[i]();
         }
         _finishedCallbacks.splice(0,_finishedCallbacks.length);
      }
      
      private static function displayNextAchievement() : void
      {
         var a:Achievement = _newAchievements[0];
         _achievementImg = a.image;
         a.setScale(2);
         a.setPosition(0.5,0.5);
         if(Boolean(_achievementPopup))
         {
            _achievementPopup.achievementWindow.itemBlock.addChild(_achievementImg);
            LocalizationManager.updateToFit(_achievementPopup.achievementWindow.acmtNameTxt,a.name,false,false);
            _fpsLayer.addChild(_achievementPopup);
            _achievementPopup.gotoAndPlay(1);
            _achievementPopup.achievementWindow.gotoAndPlay(1);
            AJAudio.playAchievementSound();
            _popupDisplayTimer.start();
            _popupDisplayTimer.addEventListener("timer",onDisplayTimerFinished,false,0,true);
         }
         else
         {
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(ACHIEVEMENT_POPUP_MEDIA_ID,popupHelperCallback);
         }
      }
      
      private static function onDisplayTimerFinished(e:TimerEvent) : void
      {
         _popupDisplayTimer.stop();
         _fpsLayer.removeChild(_achievementPopup);
         _achievementPopup.achievementWindow.itemBlock.removeChild(_achievementImg);
         _newAchievements.splice(0,1);
         if(_newAchievements.length > 0)
         {
            _popupDelayTimer.start();
            _popupDelayTimer.addEventListener("timer",onDelayTimerFinished,false,0,true);
         }
         else
         {
            _state = STATE_IDLE;
            finishedDisplayingNewAchievements();
         }
      }
      
      private static function onDelayTimerFinished(e:TimerEvent) : void
      {
         _popupDelayTimer.stop();
         displayNextAchievement();
      }
      
      private static function popupHelperCallback(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _achievementPopup = new MovieClip();
            _achievementPopup = img;
            _achievementPopup.visible = true;
            _achievementPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopupDown,false,0,true);
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
            displayNextAchievement();
         }
      }
      
      private static function onPopupDown(m:MouseEvent) : void
      {
         m.stopPropagation();
      }
      
      public static function addAchievement(a:Achievement) : void
      {
         if(Boolean(a))
         {
            _newAchievements.push(a);
         }
      }
   }
}

