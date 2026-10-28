package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBPollPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import loader.PollDefHelper;
   import localization.LocalizationManager;
   
   public class PollManager
   {
      
      private static var _pollDefCache:Array;
      
      private static var _pollLocs:Array;
      
      private static var _pollDefHelpers:Array;
      
      private static var _pollParams:Array;
      
      private static var _tabMediaHelper:MediaHelper;
      
      private static var _tabTemplate:MovieClip;
      
      private static var _dataToSetupPolls:Object;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _worldLayer:DisplayLayer;
      
      private static var _pollPopup:SBPollPopup;
      
      private static var _nonTabPollCloseCallback:Function;
      
      private static const POLL_MEDIA_ID_TAB:int = 153;
      
      private static const POLL_TAB_FRAME_LABEL:String = "poll";
      
      private static const POLL_IMAGE_TAB_FRAME_LABEL:String = "tshirtPoll";
      
      private static const POLL_COUNT_USERVAR:int = 113;
      
      public function PollManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:DisplayLayer) : void
      {
         _guiLayer = param1;
         _worldLayer = param2;
         _pollDefCache = [];
      }
      
      public static function setUpPolls(param1:Array, param2:Array, param3:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:PollDefHelper = null;
         _pollLocs = param2;
         _pollParams = param3;
         _pollDefHelpers = [];
         if(_tabTemplate == null)
         {
            _dataToSetupPolls = {
               "pollDefIds":param1,
               "pollLocs":param2,
               "pollParams":param3
            };
            _tabMediaHelper = new MediaHelper();
            _tabMediaHelper.init(POLL_MEDIA_ID_TAB,mediaHelperHandler,true);
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc5_ = _pollDefCache[param1[_loc4_]];
               if(!_loc5_)
               {
                  _loc6_ = new PollDefHelper();
                  _loc6_.init(param1[_loc4_],onPollDefReceived);
                  _pollDefHelpers[param1[_loc4_]] = _loc6_;
               }
               else
               {
                  setUpPoll(_loc5_);
               }
               _loc4_++;
            }
         }
      }
      
      public static function setupNonTabPoll(param1:int, param2:Function = null) : void
      {
         var _loc4_:PollDefHelper = null;
         DarkenManager.showLoadingSpiral(true);
         _pollDefHelpers = [];
         var _loc3_:Object = _pollDefCache[param1];
         _nonTabPollCloseCallback = param2;
         if(!_loc3_)
         {
            _loc4_ = new PollDefHelper();
            _loc4_.init(param1,onNonTabPollDefReceived);
            _pollDefHelpers[param1] = _loc4_;
         }
         else if(_pollDefHelpers[param1] == null)
         {
            setupNonTabPollPopup(_loc3_);
         }
      }
      
      private static function onPollDefReceived(param1:PollDefHelper) : void
      {
         setUpPoll(onDefReceivedSetup(param1));
      }
      
      private static function onNonTabPollDefReceived(param1:PollDefHelper) : void
      {
         setupNonTabPollPopup(onDefReceivedSetup(param1));
      }
      
      private static function onDefReceivedSetup(param1:PollDefHelper) : Object
      {
         var _loc2_:Object = param1.def;
         var _loc3_:Object = {
            "id":int(_loc2_.id),
            "mediaId":int(_loc2_.mediaRef),
            "userVarId":int(_loc2_.userVarRef),
            "poll":LocalizationManager.translateIdOnly(int(_loc2_.pollStrRef)),
            "title":LocalizationManager.translateIdOnly(int(_loc2_.titleStrRef))
         };
         _pollDefCache[_loc3_.id] = _loc3_;
         _pollDefHelpers[_loc3_.id] = null;
         return _loc3_;
      }
      
      private static function setUpPoll(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(int(param1.userVarId)) < 0)
         {
            if(_tabTemplate)
            {
               _loc2_ = new _tabTemplate.constructor();
               _loc2_.def = param1;
               _loc3_ = int(_loc2_.id = int(param1.id));
               _loc2_.x = _pollLocs[_loc3_].x;
               _loc2_.y = _pollLocs[_loc3_].y;
               if(param1.id == 27)
               {
                  _loc2_.gotoAndPlay(POLL_IMAGE_TAB_FRAME_LABEL);
               }
               else
               {
                  _loc2_.gotoAndPlay(POLL_TAB_FRAME_LABEL);
               }
               _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,onTabMouseDown,false,0,true);
               _worldLayer.addChild(_loc2_);
            }
         }
      }
      
      private static function setupNonTabPollPopup(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         if(_pollPopup == null)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = new MovieClip();
            _loc2_.def = param1;
            _loc2_.id = param1.id;
            _pollPopup = new SBPollPopup();
            _pollPopup.init(_guiLayer,_loc2_,SBPollPopup.POLL_POPUP_WOOD_MEDIA_ID,onPollVote,onPollDone,true);
         }
      }
      
      private static function mediaHelperHandler(param1:MovieClip) : void
      {
         var _loc2_:int = int(param1.mediaHelper.id);
         _tabTemplate = MovieClip(param1.getChildAt(0));
         _tabMediaHelper.destroy();
         _tabMediaHelper = null;
         if(_dataToSetupPolls != null)
         {
            setUpPolls(_dataToSetupPolls.pollDefIds,_dataToSetupPolls.pollLocs,_dataToSetupPolls.pollParams);
            _dataToSetupPolls = null;
         }
      }
      
      private static function onTabMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:MovieClip = MovieClip(param1.currentTarget);
         if(param1.currentTarget.currentFrameLabel == POLL_IMAGE_TAB_FRAME_LABEL)
         {
            ImagePoll.displayPoll(_loc2_.def.userVarId,_pollParams[_loc2_.id],ImagePoll.POLL_MEDIA_ID,ImagePoll.TSHIRT_IMAGES_MEDIA_ID,10,3,_loc2_,onImagePollClose);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _pollPopup = new SBPollPopup();
            _pollPopup.init(_guiLayer,_loc2_,SBPollPopup.POLL_POPUP_MEDIA_ID,onPollVote,onPollDone,true);
         }
      }
      
      private static function onImagePollClose(param1:MovieClip) : void
      {
         if(param1.parent)
         {
            param1.parent.removeChild(param1);
         }
         param1.removeEventListener(MouseEvent.MOUSE_DOWN,onTabMouseDown);
      }
      
      private static function onPollVote(param1:MovieClip, param2:int) : void
      {
         if(param1.parent)
         {
            param1.parent.removeChild(param1);
         }
         param1.removeEventListener(MouseEvent.MOUSE_DOWN,onTabMouseDown);
         if(param1.def.userVarId != 0)
         {
            AchievementXtCommManager.requestSetUserVar(param1.def.userVarId,_pollParams[param1.id]);
            AchievementXtCommManager.requestSetUserVar(POLL_COUNT_USERVAR,1);
         }
         if(gMainFrame.server.isWorldZone)
         {
            SBTracker.trackPageview("/game/play/poll/#" + param1.def.id + "/#0/#" + param2);
         }
         else
         {
            SBTracker.trackPageview("/login/poll/#" + param1.def.id + "/#0/#" + param2,0);
         }
      }
      
      private static function onPollDone() : void
      {
         _pollPopup.destroy();
         _pollPopup = null;
         if(_nonTabPollCloseCallback != null)
         {
            _nonTabPollCloseCallback();
            _nonTabPollCloseCallback = null;
         }
      }
   }
}

