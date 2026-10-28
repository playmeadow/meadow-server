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
      
      private static var _tabMediaHelper:MediaHelper;
      
      private static var _tabTemplate:MovieClip;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _worldLayer:DisplayLayer;
      
      private static var _pollPopup:SBPollPopup;
      
      private static const POLL_MEDIA_ID_TAB:int = 153;
      
      private static const POLL_TAB_FRAME_LABEL:String = "poll";
      
      private static const POLL_IMAGE_TAB_FRAME_LABEL:String = "tshirtPoll";
      
      private static const POLL_COUNT_USERVAR:int = 113;
      
      public function PollManager()
      {
         super();
      }
      
      public static function init(initGuiLayer:DisplayLayer, initWorldLayer:DisplayLayer) : void
      {
         _guiLayer = initGuiLayer;
         _worldLayer = initWorldLayer;
         _pollDefCache = [];
         _tabMediaHelper = new MediaHelper();
         _tabMediaHelper.init(POLL_MEDIA_ID_TAB,mediaHelperHandler,true);
      }
      
      public static function setUpPolls(pollDefIds:Array, pollLocs:Array) : void
      {
         var def:Object = null;
         var pdh:PollDefHelper = null;
         _pollLocs = pollLocs;
         _pollDefHelpers = [];
         for(var i:int = 0; i < pollDefIds.length; i++)
         {
            def = _pollDefCache[pollDefIds[i]];
            if(!def)
            {
               pdh = new PollDefHelper();
               pdh.init(pollDefIds[i],onPollDefReceived);
               _pollDefHelpers[pollDefIds[i]] = pdh;
            }
            else
            {
               setUpPoll(def);
            }
         }
      }
      
      private static function onPollDefReceived(pdh:PollDefHelper) : void
      {
         var o:Object = pdh.def;
         var def:Object = {
            "id":int(o.id),
            "mediaId":int(o.mediaRef),
            "userVarId":int(o.userVarRef),
            "poll":LocalizationManager.translateIdOnly(int(o.pollStrRef)),
            "title":LocalizationManager.translateIdOnly(int(o.titleStrRef))
         };
         _pollDefCache[def.id] = def;
         _pollDefHelpers[def.id] = null;
         setUpPoll(def);
      }
      
      private static function setUpPoll(def:Object) : void
      {
         var tab:MovieClip = null;
         var defId:int = 0;
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(int(def.userVarId)) < 0)
         {
            if(Boolean(_tabTemplate))
            {
               tab = new _tabTemplate.constructor();
               tab.def = def;
               defId = int(tab.id = int(def.id));
               tab.x = _pollLocs[defId].x;
               tab.y = _pollLocs[defId].y;
               if(def.id == 27)
               {
                  tab.gotoAndPlay(POLL_IMAGE_TAB_FRAME_LABEL);
               }
               else
               {
                  tab.gotoAndPlay(POLL_TAB_FRAME_LABEL);
               }
               tab.addEventListener(MouseEvent.MOUSE_DOWN,onTabMouseDown,false,0,true);
               _worldLayer.addChild(tab);
            }
         }
      }
      
      private static function mediaHelperHandler(mc:MovieClip) : void
      {
         var pid:int = int(mc.mediaHelper.id);
         _tabTemplate = MovieClip(mc.getChildAt(0));
         _tabMediaHelper.destroy();
         _tabMediaHelper = null;
      }
      
      private static function onTabMouseDown(m:MouseEvent) : void
      {
         m.stopPropagation();
         var tab:MovieClip = MovieClip(m.currentTarget);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/vote/" + tab.def.id);
         if(m.currentTarget.currentFrameLabel == POLL_IMAGE_TAB_FRAME_LABEL)
         {
            ImagePoll.displayPoll(tab.def.userVarId,ImagePoll.POLL_MEDIA_ID,ImagePoll.TSHIRT_IMAGES_MEDIA_ID,10,3,tab,onImagePollClose);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _pollPopup = new SBPollPopup();
            _pollPopup.init(_guiLayer,tab,onPollVote,onPollDone,true);
         }
      }
      
      private static function onImagePollClose(tab:MovieClip) : void
      {
         if(Boolean(tab.parent))
         {
            tab.parent.removeChild(tab);
         }
         tab.removeEventListener(MouseEvent.MOUSE_DOWN,onTabMouseDown);
         SBTracker.pop();
      }
      
      private static function onPollVote(tab:MovieClip, option:int) : void
      {
         if(Boolean(tab.parent))
         {
            tab.parent.removeChild(tab);
         }
         tab.removeEventListener(MouseEvent.MOUSE_DOWN,onTabMouseDown);
         AchievementXtCommManager.requestSetUserVar(tab.def.userVarId,option);
         AchievementXtCommManager.requestSetUserVar(POLL_COUNT_USERVAR,1);
      }
      
      private static function onPollDone() : void
      {
         SBTracker.pop();
         _pollPopup.destroy();
         _pollPopup = null;
      }
   }
}

