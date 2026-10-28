package gui
{
   import avatar.AvatarUtility;
   import com.sbi.analytics.SBTracker;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.SortLayer;
   import com.sbi.loader.LoaderCache;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class FirstFiveMinutes extends Sprite
   {
      
      public static const MIRA_HIGHLIGHT_MEDIA_ID:int = 45;
      
      public static const GO_HERE_MEDIA_ID:int = 46;
      
      public static const COLOR_TAB_HIGHLIGHT_MEDIA_ID:int = 51;
      
      public static const EYE_TAB_HIGHLIGHT_MEDIA_ID:int = 52;
      
      public static const PATTERN_TAB_HIGHLIGHT_MEDIA_ID:int = 53;
      
      public static const AVATAR_EDITOR_X_BTN_HIGHLIGHT_MEDIA_ID:int = 54;
      
      public static const CHAR_WINDOW_MEDIA_ID:int = 55;
      
      public static const ACHIEVEMENT_POPUP_MEDIA_ID:int = 56;
      
      public static const SKIP_BUTTON:int = 392;
      
      public static const AVATAR_EDITOR_X_BTN:int = 0;
      
      public static const AVATAR_EDITOR_BLOCK:int = 1;
      
      public static const COLOR_FUNCTION_ID:int = 2;
      
      public static const EYE_FUNCTION_ID:int = 3;
      
      public static const PATTERN_FUNCTION_ID:int = 4;
      
      public static const ARROW_U_MEDIA_ID:int = 47;
      
      public static const ARROW_D_MEDIA_ID:int = 48;
      
      public static const ARROW_R_MEDIA_ID:int = 49;
      
      public static const ARROW_L_MEDIA_ID:int = 50;
      
      public var isHelpBubble:Boolean;
      
      private const REPLAY_STREAM_TIME:int = 10;
      
      private var _streamBaseURL:String;
      
      private var _sets:Array;
      
      private var _fullCommandSets:Array;
      
      private var _avtMC:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _worldLayer:SortLayer;
      
      private var _chatLayer:DisplayLayer;
      
      private var _doneCallback:Function;
      
      private var _shardRequestSent:Boolean;
      
      private var _currSetProcessed:Boolean;
      
      private var _setNumber:int;
      
      private var _currSound:Sound;
      
      private var _currSoundChannel:SoundChannel;
      
      private var _currSoundTransform:SoundTransform;
      
      private var _currSoundAdvances:Boolean;
      
      private var _currSoundTimer:Timer;
      
      private var _currSoundMcOn:MovieClip;
      
      private var _currSoundMcOff:MovieClip;
      
      private var _shamanShouldTalk:Boolean;
      
      private var _repeatStream:Boolean;
      
      private var _currSoundMustFinishBeforeAdvancing:Boolean;
      
      private var _advanceOnEventTriggered:Boolean;
      
      private var _advanceOnWalkIn:Boolean;
      
      private var _isSkipping:Boolean;
      
      private var _delayTimer:Timer;
      
      private var _standAloneDelay:Boolean;
      
      private var _timerTriggered:Boolean;
      
      private var _popup:ChatBalloon;
      
      private var _chatPopup:ChatBalloon;
      
      private var _delayPopupVisibility:Boolean;
      
      private var _helpBubble:GuiHelpTextBubble;
      
      private var _mediaHelpers:Array;
      
      private var _modifiedObject:String;
      
      private var _nextControl:String;
      
      private var _soundTimer:Timer;
      
      private var _uArrow:MovieClip;
      
      private var _dArrow:MovieClip;
      
      private var _lArrow:MovieClip;
      
      private var _rArrow:MovieClip;
      
      private var _goToCircle:MovieClip;
      
      private var _miraHighlight:MovieClip;
      
      private var _colorTabHighlight:MovieClip;
      
      private var _eyeTabHighlight:MovieClip;
      
      private var _patternTabHighlight:MovieClip;
      
      private var _avtEditorXBtnHighlight:MovieClip;
      
      private var _charWindowHighlight:MovieClip;
      
      private var _achievementPopup:MovieClip;
      
      private var _skipBtn:MovieClip;
      
      private var _avatarEditor:AvatarEditor;
      
      private var _roomMgr:RoomManagerWorld;
      
      private var _trackingNames:Array;
      
      public function FirstFiveMinutes()
      {
         super();
      }
      
      public function init(commandSet:Array, avt:MovieClip, guiLayer:DisplayLayer, worldLayer:SortLayer, chatLayer:DisplayLayer, doneCallback:Function, HelpBubble:Boolean = false) : void
      {
         this._streamBaseURL = gMainFrame.clientInfo.contentURL;
         this._sets = commandSet;
         this._fullCommandSets = commandSet.slice();
         this._setNumber = 0;
         this._avtMC = avt;
         this._guiLayer = guiLayer;
         this._worldLayer = worldLayer;
         this._chatLayer = chatLayer;
         this._roomMgr = RoomManagerWorld.instance;
         this._doneCallback = doneCallback;
         this._roomMgr.callback_TriggerWalkIn = this.advanceOnWalkIn;
         this._isSkipping = false;
         this._mediaHelpers = [];
         this._trackingNames = ["Welcome to Jamaa","Click the mouse","Hello there","I am Liza","We Shamans","Do you see that statue","That is Mira","You\'ll learn about Mira","Every animal is special","Make yourself unique","Click on the animal picture","Great job!","Click on the color tab","Click on the eye tab","Click on the pattern tab","Click on the x","Excellent work","By changing your colors","Achievements are awards","You have done so well","I want to give you gems","Gems can be used","Point to the gems","Your training is finished","I think you are ready","Good luck"];
         this.isHelpBubble = HelpBubble;
         this.initAssets();
         this.processCurrentSet();
      }
      
      public function destroy() : void
      {
         var i:int = 0;
         this._sets.splice(0,this._sets.length);
         this._sets = null;
         this._doneCallback = null;
         this._currSound = null;
         if(Boolean(this._currSoundChannel))
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = null;
         }
         if(Boolean(this._currSoundTimer))
         {
            this._currSoundTimer.stop();
            this._currSoundTimer = null;
         }
         if(Boolean(this._delayTimer))
         {
            this._delayTimer.stop();
            this._delayTimer = null;
         }
         if(Boolean(this._soundTimer))
         {
            this._soundTimer.stop();
            this._soundTimer = null;
         }
         if(Boolean(this._mediaHelpers))
         {
            for(i = 0; i < this._mediaHelpers.length; i++)
            {
               this._mediaHelpers[0].destroy();
            }
            this._mediaHelpers.splice(0,this._mediaHelpers.length);
         }
         if(Boolean(this._avatarEditor))
         {
            this._avatarEditor = null;
         }
         if(Boolean(this._skipBtn))
         {
            this._skipBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.skipFFM);
            this._guiLayer.removeChild(this._skipBtn);
            this._skipBtn.visible = false;
            this._skipBtn = null;
         }
         if(Boolean(this._avtMC))
         {
            this._worldLayer.removeChild(this._avtMC.parent);
            this._avtMC = null;
         }
      }
      
      public function skipFFM(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._delayPopupVisibility = false;
         this._currSoundMustFinishBeforeAdvancing = false;
         this._isSkipping = true;
         this.processAllSets();
         this.delayCompleteHandler(null);
         this._sets.splice(0,this._sets.length);
         this._doneCallback();
      }
      
      public function processAndSplice(modify:String = null, next:String = null) : void
      {
         this.processCurrentSet();
         this._sets.splice(0,1);
      }
      
      public function doNextSet(setNeedsDeactivation:Boolean, set:Array = null) : void
      {
         if(setNeedsDeactivation)
         {
            if(set != null)
            {
               this._sets = set;
               this._currSetProcessed = false;
               this.processCurrentSet();
            }
         }
         else
         {
            this.processCurrentSet();
            this._sets.splice(0,1);
            this.processCurrentSet();
         }
      }
      
      public function reloadSets(set:Array = null) : void
      {
         if(set == null)
         {
            this.processCurrentSet();
         }
         else
         {
            if(Boolean(this._delayTimer))
            {
               this._delayTimer.removeEventListener(TimerEvent.TIMER,this.delayCompleteHandler);
               this._delayTimer.stop();
               this._delayTimer = null;
            }
            this._sets = set;
            this._currSetProcessed = false;
            this.processCurrentSet();
         }
      }
      
      public function processAllSets() : void
      {
         var j:int = 0;
         var currSet:Array = null;
         var i:int = 0;
         if(Boolean(this._fullCommandSets) && this._fullCommandSets.length >= this._setNumber)
         {
            for(j = 0; j <= this._setNumber; j++)
            {
               currSet = this._fullCommandSets[j];
               if(Boolean(currSet) && currSet.length > 0)
               {
                  for(i = 0; i < currSet.length; i++)
                  {
                     this.processCommand(currSet[i]);
                  }
               }
            }
         }
      }
      
      public function processCurrentSet() : void
      {
         var currSet:Array = null;
         var i:int = 0;
         if(Boolean(this._sets) && this._sets.length > 0)
         {
            currSet = this._sets[0];
            if(Boolean(currSet) && currSet.length > 0)
            {
               for(i = 0; i < currSet.length; i++)
               {
                  this.processCommand(currSet[i]);
               }
               this._currSetProcessed = !this._currSetProcessed;
            }
         }
         else if(this._doneCallback != null)
         {
            this._doneCallback();
            this._doneCallback = null;
         }
      }
      
      public function setAvatarEditor(avtEditor:AvatarEditor) : void
      {
         this._avatarEditor = avtEditor;
      }
      
      public function trackUserFFMStateChange(stateName:String) : void
      {
         SBTracker.trackPageview("/game/play/FFM/#" + stateName);
      }
      
      public function advanceOnCallback() : void
      {
         this.advanceOnClickHandler(null);
      }
      
      private function initAssets() : void
      {
         if(this.isHelpBubble)
         {
            this._helpBubble = GETDEFINITIONBYNAME("HelpTxtBubble");
            this._helpBubble.init();
         }
         else
         {
            this._popup = GETDEFINITIONBYNAME("ChatBalloonShamanBlockNEW");
            this._popup.init(10,AvatarUtility.getAvatarEmoteBgOffset,true);
            this._guiLayer.addChild(this._popup);
            this._popup.visible = false;
            this._chatPopup = GETDEFINITIONBYNAME("ChatBalloonShamanNEW");
            this._chatPopup.init(10,AvatarUtility.getAvatarEmoteBgOffset);
            this._guiLayer.addChild(this._chatPopup);
            this._chatPopup.visible = false;
            this._uArrow = new MovieClip();
            this._dArrow = new MovieClip();
            this._lArrow = new MovieClip();
            this._rArrow = new MovieClip();
            this._goToCircle = new MovieClip();
            this._miraHighlight = new MovieClip();
            this._colorTabHighlight = new MovieClip();
            this._eyeTabHighlight = new MovieClip();
            this._patternTabHighlight = new MovieClip();
            this._avtEditorXBtnHighlight = new MovieClip();
            this._charWindowHighlight = new MovieClip();
            this._achievementPopup = new MovieClip();
            this._skipBtn = new MovieClip();
         }
      }
      
      private function mediaHelperCallback(mc:MovieClip) : void
      {
         var i:int = 0;
         if(Boolean(mc))
         {
            switch(mc.mediaHelper.id)
            {
               case ARROW_U_MEDIA_ID:
                  this._uArrow.addChild(mc);
                  break;
               case ARROW_D_MEDIA_ID:
                  this._dArrow.addChild(mc);
                  break;
               case ARROW_L_MEDIA_ID:
                  this._lArrow.addChild(mc);
                  break;
               case ARROW_R_MEDIA_ID:
                  this._rArrow.addChild(mc);
                  break;
               case GO_HERE_MEDIA_ID:
                  this._goToCircle.addChild(mc);
                  this._worldLayer.addChild(this._goToCircle);
                  this._goToCircle.visible = false;
                  this._goToCircle.x = 620;
                  this._goToCircle.y = 550;
                  MovieClip(this._goToCircle.getChildAt(0)).arrow.gotoAndStop(1);
                  MovieClip(this._goToCircle.getChildAt(0)).circle.gotoAndStop(1);
                  break;
               case MIRA_HIGHLIGHT_MEDIA_ID:
                  this._miraHighlight.addChild(mc);
                  this._worldLayer.addChild(this._miraHighlight);
                  this._miraHighlight.visible = false;
                  this._miraHighlight.x = 352;
                  this._miraHighlight.y = 118;
                  break;
               case COLOR_TAB_HIGHLIGHT_MEDIA_ID:
                  this._colorTabHighlight.addChild(mc);
                  break;
               case EYE_TAB_HIGHLIGHT_MEDIA_ID:
                  this._eyeTabHighlight.addChild(mc);
                  break;
               case PATTERN_TAB_HIGHLIGHT_MEDIA_ID:
                  this._patternTabHighlight.addChild(mc);
                  break;
               case AVATAR_EDITOR_X_BTN_HIGHLIGHT_MEDIA_ID:
                  this._avtEditorXBtnHighlight.addChild(mc);
                  this._avtEditorXBtnHighlight.mouseEnabled = false;
                  this._avtEditorXBtnHighlight.mouseChildren = false;
                  break;
               case CHAR_WINDOW_MEDIA_ID:
                  this._charWindowHighlight.addChild(mc);
                  this._charWindowHighlight.mouseEnabled = false;
                  this._charWindowHighlight.mouseChildren = false;
                  break;
               case ACHIEVEMENT_POPUP_MEDIA_ID:
                  this._achievementPopup.addChild(mc);
                  this._guiLayer.addChild(this._achievementPopup);
                  this._achievementPopup.x = 0;
                  this._achievementPopup.visible = false;
                  break;
               case SKIP_BUTTON:
                  this._skipBtn.addChild(mc);
                  this._guiLayer.addChild(this._skipBtn);
                  this._skipBtn.x = 810;
                  this._skipBtn.y = 420;
                  this._skipBtn.visible = true;
                  this._skipBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.skipFFM,false,0,true);
            }
         }
         if(Boolean(mc) && Boolean(mc.mediaHelper))
         {
            for(i = 0; i < this._mediaHelpers.length; i++)
            {
               if(mc.mediaHelper == this._mediaHelpers[i])
               {
                  this._mediaHelpers.splice(i,1);
                  break;
               }
            }
            mc.mediaHelper.destroy();
            delete mc.mediaHelper;
         }
      }
      
      private function endSet() : void
      {
         this.nextSet();
      }
      
      private function nextSet() : void
      {
         if(!this._delayTimer)
         {
            if(!this._timerTriggered)
            {
               this.processCurrentSet();
               if(Boolean(this._sets))
               {
                  this._sets.splice(0,1);
                  ++this._setNumber;
               }
            }
            else
            {
               this._timerTriggered = false;
            }
            this.processCurrentSet();
         }
         else
         {
            this.processCurrentSet();
            if(Boolean(this._sets))
            {
               this._sets.splice(0,1);
               ++this._setNumber;
               this._delayTimer.start();
            }
         }
      }
      
      private function processCommand(o:Object) : void
      {
         if(Boolean(o))
         {
            switch(o.cmd)
            {
               case "preload":
                  this.processPreload(o);
                  break;
               case "playStream":
                  this.processStream(o);
                  break;
               case "playSound":
                  this.processSound(o);
                  break;
               case "shaman":
                  this.processShaman(o);
                  break;
               case "avatarPlayAnim":
                  this.processAvatarPlayAnim(o);
                  break;
               case "delay":
                  this.processDelay(o);
                  break;
               case "popup":
                  this.processPopup(o);
                  break;
               case "arrow":
                  this.processArrow(o);
                  break;
               case "functionCall":
                  this.processFunctionCall(o);
                  break;
               case "visibility":
                  this.processVisibility(o);
                  break;
               case "advanceOnEvent":
                  this.processAdvanceOnEvent(o);
                  break;
               case "roomSpawn":
                  this.processRoomSpawn(o);
                  break;
               case "shamanOut":
                  this.processShamanOut(o);
            }
         }
      }
      
      private function processPreload(o:Object) : void
      {
         var helper:MediaHelper = null;
         if(!this._currSetProcessed && !this._isSkipping)
         {
            helper = new MediaHelper();
            helper.init(o.src,this.mediaHelperCallback,true);
            this._mediaHelpers.push(helper);
         }
      }
      
      private function processStream(o:Object) : void
      {
         var cdnStreamURLRequest:URLRequest = null;
         if(!this._currSetProcessed && !this._isSkipping)
         {
            if(o.repeatAfter != null && o.repeatAfter > 0)
            {
               this._currSoundTimer = new Timer(o.repeatAfter * 1000);
            }
            else
            {
               this._currSoundTimer = new Timer(this.REPLAY_STREAM_TIME * 1000);
            }
            if(!this.isHelpBubble)
            {
               this._currSoundTimer.addEventListener(TimerEvent.TIMER,this.currSoundTimerCompleteHandler,false,0,true);
            }
            this._currSound = new Sound();
            cdnStreamURLRequest = LoaderCache.fetchCDNURLRequest("/streams/" + o.src + ".mp3");
            this._currSound.load(cdnStreamURLRequest);
            if(o.repeatStream != null && o.repeatStream == true)
            {
               this._repeatStream = true;
            }
            addEventListener(Event.ENTER_FRAME,this.enterFrameHandler,false,0,true);
            if(o.shamanTalk != null && o.shamanTalk == true)
            {
               this._shamanShouldTalk = true;
            }
            if(o.volume != null && o.volume > 0)
            {
               this._currSoundTransform = new SoundTransform();
               this._currSoundTransform.volume = o.volume;
            }
            else
            {
               this._currSoundTransform = null;
            }
            if(Boolean(o.advances))
            {
               this._currSoundAdvances = o.advances;
            }
            else
            {
               this._currSoundAdvances = false;
            }
            if(o.mustFinish != null && o.mustFinish == true)
            {
               this._currSoundMustFinishBeforeAdvancing = true;
            }
            else
            {
               this._currSoundMustFinishBeforeAdvancing = false;
            }
            if(Boolean(o.off))
            {
               this._currSoundMcOff = o.off;
               this._currSoundMcOff.visible = false;
            }
            if(Boolean(o.on))
            {
               this._currSoundMcOn = o.on;
               this._currSoundMcOn.visible = true;
            }
         }
         else
         {
            if(Boolean(this._currSoundChannel))
            {
               this._currSoundChannel.stop();
               if(this._shamanShouldTalk)
               {
                  this.avatarPlayAnim({
                     "userName":"Liza",
                     "anim":"idle",
                     "hFlip":true
                  });
               }
               this._shamanShouldTalk = false;
               if(this._shamanShouldTalk)
               {
                  this._shamanShouldTalk = false;
               }
               this._currSoundChannel = null;
            }
            if(Boolean(this._soundTimer))
            {
               this._soundTimer.removeEventListener(TimerEvent.TIMER,this.soundCompleteHandler,false);
               if(this._shamanShouldTalk)
               {
                  this.avatarPlayAnim({
                     "userName":"Liza",
                     "anim":"idle",
                     "hFlip":true
                  });
               }
               this._shamanShouldTalk = false;
               if(this._shamanShouldTalk)
               {
                  this._shamanShouldTalk = false;
               }
            }
            if(Boolean(this._currSound))
            {
               this._currSound = null;
            }
            if(Boolean(this._currSoundTimer) && this._currSoundTimer.running)
            {
               this._currSoundTimer.stop();
            }
            if(Boolean(this._currSoundMcOff))
            {
               this._currSoundMcOff.visible = true;
            }
            if(Boolean(this._currSoundMcOn))
            {
               this._currSoundMcOn.visible = false;
            }
         }
      }
      
      private function processSound(o:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping)
         {
            switch(o.src)
            {
               case "subMenuClick":
                  AJAudio.playSubMenuBtnClick();
                  break;
               case "gemsEarned":
                  AJAudio.playGemsEarnedSound();
            }
         }
      }
      
      private function enterFrameHandler(evt:Event) : void
      {
         var loadPercent:Number = NaN;
         if(this._currSound != null)
         {
            loadPercent = this._currSound.bytesLoaded / this._currSound.bytesTotal;
            if(loadPercent == 1)
            {
               if(!this._repeatStream)
               {
                  this._currSoundChannel = this._currSound.play();
                  this._soundTimer = new Timer(this._currSound.length + 300);
                  this._soundTimer.start();
                  this._soundTimer.addEventListener(TimerEvent.TIMER,this.soundCompleteHandler,false,0,true);
                  if(Boolean(this._currSoundTransform) && Boolean(this._currSoundChannel))
                  {
                     this._currSoundChannel.soundTransform = this._currSoundTransform;
                  }
                  if(this._shamanShouldTalk)
                  {
                     this.avatarPlayAnim({
                        "userName":"Liza",
                        "anim":"sleep",
                        "hFlip":true
                     });
                  }
               }
               else
               {
                  this._helpBubble.soundBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSoundBtn,false,0,true);
               }
               removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
            }
         }
      }
      
      private function processShaman(o:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping)
         {
            this._avtMC.idle();
            this._avtMC.parent.name = this._avtMC.getSortHeight();
            this._worldLayer.addChild(this._avtMC.parent);
            this._avtMC.x = o.x;
            this._avtMC.y = o.y;
            this._avtMC.scaleX *= -1;
         }
      }
      
      private function processAvatarPlayAnim(o:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping)
         {
            this.avatarPlayAnim(o);
         }
      }
      
      private function avatarPlayAnim(o:Object) : void
      {
         if(o.anim == "sleep")
         {
            this._avtMC.talking();
         }
         else if(o.anim == "idle")
         {
            this._avtMC.idle();
         }
      }
      
      private function idForAnim(anim:String) : int
      {
         switch(anim)
         {
            case "sleep":
               return LayerAnim.AN_SLEEP;
            case "dance":
               return LayerAnim.AN_DANCE;
            case "idle":
               return LayerAnim.AN_IDLE_SE;
            case "play":
               return LayerAnim.AN_PLAY;
            case "hop":
               return LayerAnim.AN_HOP;
            default:
               return LayerAnim.AN_IDLE_SE;
         }
      }
      
      private function processDelay(o:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping)
         {
            if(Boolean(this._delayTimer))
            {
               this._delayTimer = null;
            }
            this._delayTimer = new Timer(o.sec * 1000);
            this._delayTimer.addEventListener(TimerEvent.TIMER,this.delayCompleteHandler,false,0,true);
            if(Boolean(o.type) && o.type == "standAlone")
            {
               this._standAloneDelay = true;
               this._timerTriggered = false;
               this._delayTimer.start();
            }
            else
            {
               this._standAloneDelay = false;
            }
         }
      }
      
      private function processPopup(o:Object) : void
      {
         var popup:ChatBalloon = null;
         var helpBubble:GuiHelpTextBubble = null;
         if(o.type == "helpBubble")
         {
            helpBubble = this._helpBubble;
         }
         else if(o.type == "chat")
         {
            popup = this._chatPopup;
         }
         else
         {
            popup = this._popup;
         }
         popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onSrcDown,false,0,true);
         if(!this._currSetProcessed && !this._isSkipping)
         {
            this.trackUserFFMStateChange(this._trackingNames[0]);
            this._trackingNames.splice(0,1);
            if(o.btn != null && GuiManager[o.btn] == false || o.btn == "ffmDenCustomizeBtn" && DenEditor.staticEditor.bottomHud.visible == false)
            {
               this._currSetProcessed = true;
               this.nextSet();
               return;
            }
            if(Boolean(helpBubble))
            {
               if(Boolean(o.world) && o.world == true)
               {
                  this._worldLayer.addChild(this._helpBubble);
               }
               else
               {
                  this._guiLayer.addChild(this._helpBubble);
               }
               helpBubble.bringToFront();
               helpBubble.setText(o.txt);
               helpBubble.setPos(o.x,o.y);
               helpBubble.visible = true;
               this._helpBubble.setTails(o.top,o.left,o.twoTails);
            }
            else
            {
               popup.setText(o.txt);
               popup.x = o.x;
               popup.y = o.y;
               popup.visible = true;
            }
            if(o.delay != null && o.delay == true)
            {
               this._delayPopupVisibility = true;
            }
         }
         else if(!this._delayPopupVisibility)
         {
            if(Boolean(helpBubble))
            {
               helpBubble.visible = false;
            }
            else
            {
               popup.visible = false;
            }
            popup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSrcDown);
         }
      }
      
      private function processVisibility(o:Object) : void
      {
         var mc:MovieClip = null;
         if(Boolean(o.type) && (o.type == "mediaId" || o.type == "mediaIdAnimated"))
         {
            mc = this.getMCForMediaId(o.src);
         }
         else
         {
            mc = o.src;
         }
         if(o.src != GO_HERE_MEDIA_ID)
         {
            mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onSrcDown,false,0,true);
         }
         if(!this._currSetProcessed && !this._isSkipping)
         {
            mc.visible = o.visibility;
            if(o.goHere != null && o.goHere == true)
            {
               if(mc.numChildren > 1)
               {
                  MovieClip(mc.getChildAt(0)).arrow.gotoAndPlay(1);
                  MovieClip(mc.getChildAt(0)).circle.gotoAndPlay(1);
               }
            }
            if(Boolean(o.type) && o.type == "mediaIdAnimated")
            {
               MovieClip(mc.getChildAt(0)).turnOn();
            }
            if(Boolean(o.layer))
            {
               if(o.layer == "gui")
               {
                  this._guiLayer.addChild(mc);
               }
               else
               {
                  this._worldLayer.addChild(mc);
               }
            }
            if(Boolean(o.x))
            {
               mc.x = o.x;
            }
            if(Boolean(o.y))
            {
               mc.y = o.y;
            }
         }
         else if(o.revert != null && o.revert == true || this._isSkipping)
         {
            if(o.goHere != null && o.goHere == true)
            {
               if(Boolean(mc) && mc.numChildren > 0)
               {
                  MovieClip(mc.getChildAt(0)).arrow.gotoAndStop(1);
                  MovieClip(mc.getChildAt(0)).circle.gotoAndStop(1);
               }
            }
            if(Boolean(o.type) && o.type == "mediaIdAnimated")
            {
               if(Boolean(mc) && mc.numChildren > 0)
               {
                  MovieClip(mc.getChildAt(0)).turnOff();
               }
            }
            else if(Boolean(o.type) && o.type == "mediaId")
            {
               this.getMCForMediaId(o.src).visible = !o.visibility;
            }
            else
            {
               o.src.visible = !o.visibility;
            }
            if(Boolean(o.layer) && Boolean(mc) && Boolean(mc.parent))
            {
               mc.parent.removeChild(mc);
            }
            if(o.src != GO_HERE_MEDIA_ID && Boolean(mc))
            {
               mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSrcDown);
            }
         }
      }
      
      private function processFunctionCall(o:Object) : void
      {
         var temp:Function = null;
         if(!this._currSetProcessed && !this._isSkipping)
         {
            temp = this.getFunctionForFunctionId(o.src);
            if(o.param != null)
            {
               temp(o.param);
            }
            else
            {
               temp();
            }
         }
      }
      
      private function processAdvanceOnEvent(o:Object) : void
      {
         var mc:MovieClip = null;
         if(o.type == "mediaId")
         {
            mc = this.getMCForMediaId(o.src);
         }
         else if(o.type == "mc")
         {
            mc = o.src;
         }
         else if(o.type == "den")
         {
            mc = DenEditor.staticEditor[o.src];
         }
         if(o.modifyOnClick != null)
         {
            this._modifiedObject = o.modifyOnClick;
         }
         if(o.nextToGo != null)
         {
            this._nextControl = o.nextToGo;
         }
         if(!this._currSetProcessed && !this._isSkipping)
         {
            if(o.type == "volume")
            {
               this._advanceOnWalkIn = true;
            }
            else if(Boolean(mc))
            {
               mc.addEventListener(o.event,this.advanceOnClickHandler,false,0,true);
            }
         }
         else
         {
            if(this._modifiedObject != null)
            {
               this._modifiedObject = null;
            }
            if(this._nextControl != null)
            {
               this._nextControl = null;
            }
            if(o.type == "volume")
            {
               this._advanceOnWalkIn = true;
               this._advanceOnEventTriggered = false;
            }
            else
            {
               this._advanceOnEventTriggered = false;
               if(Boolean(mc))
               {
                  mc.removeEventListener(o.event,this.advanceOnClickHandler);
               }
            }
         }
      }
      
      private function processArrow(o:Object) : void
      {
         var currArrow:MovieClip = null;
         var src:MovieClip = null;
         switch(o.dir)
         {
            case "up":
               currArrow = this._uArrow;
               break;
            case "down":
               currArrow = this._dArrow;
               break;
            case "left":
               currArrow = this._lArrow;
               break;
            case "right":
               currArrow = this._rArrow;
               break;
            default:
               throw new Error("Arrow type not recognized - type: " + o.type);
         }
         if(!this._currSetProcessed && !this._isSkipping)
         {
            if(o.visibility == true)
            {
               if(o.layer != null && o.layer == "world")
               {
                  this._worldLayer.addChild(currArrow);
               }
               else
               {
                  this._guiLayer.addChild(currArrow);
               }
               currArrow.visible = true;
               if(o.src != null)
               {
                  if(o.type != null && o.type == "mediaId")
                  {
                     src = this.getMCForMediaId(o.src);
                  }
                  else
                  {
                     src = o.src;
                  }
               }
               if(o.x != null)
               {
                  if(src != null)
                  {
                     currArrow.x = src.x + o.x;
                  }
                  else
                  {
                     currArrow.x = o.x;
                  }
               }
               else if(src != null)
               {
                  currArrow.x = src.x;
               }
               if(o.y != null)
               {
                  if(src != null)
                  {
                     currArrow.y = src.y + o.y;
                  }
                  else
                  {
                     currArrow.y = o.y;
                  }
               }
               else if(src != null)
               {
                  currArrow.y = src.y;
               }
            }
            else
            {
               currArrow.visible = false;
            }
         }
         else if(o.revert != null && o.revert == true || this._isSkipping)
         {
            if(Boolean(currArrow) && Boolean(currArrow.parent))
            {
               currArrow.parent.removeChild(currArrow);
            }
            currArrow.visible = false;
         }
      }
      
      private function processRoomSpawn(o:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping && !this._shardRequestSent)
         {
            this._shardRequestSent = true;
            this._roomMgr.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest(o.room + this._roomMgr.shardId);
            this._currSetProcessed = true;
            this.endSet();
         }
         else if(this._isSkipping && !this._shardRequestSent)
         {
            this._shardRequestSent = true;
            this._currSetProcessed = true;
            this._roomMgr.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest(o.room + this._roomMgr.shardId);
         }
      }
      
      private function processShamanOut(o:Object) : void
      {
      }
      
      public function getSets() : Array
      {
         return this._sets;
      }
      
      private function onSoundBtn(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(Boolean(this._currSoundChannel))
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = this._currSound.play();
         }
         else
         {
            this._currSoundChannel = this._currSound.play();
         }
      }
      
      private function onSrcDown(e:MouseEvent) : void
      {
         e.stopPropagation();
      }
      
      private function getMCForMediaId(mediaId:int) : MovieClip
      {
         switch(mediaId)
         {
            case MIRA_HIGHLIGHT_MEDIA_ID:
               return this._miraHighlight;
            case GO_HERE_MEDIA_ID:
               return this._goToCircle;
            case COLOR_TAB_HIGHLIGHT_MEDIA_ID:
               return this._colorTabHighlight;
            case EYE_TAB_HIGHLIGHT_MEDIA_ID:
               return this._eyeTabHighlight;
            case PATTERN_TAB_HIGHLIGHT_MEDIA_ID:
               return this._patternTabHighlight;
            case AVATAR_EDITOR_X_BTN:
               return this._avatarEditor.xBtn;
            case AVATAR_EDITOR_BLOCK:
               return MovieClip(this._avatarEditor.block);
            case AVATAR_EDITOR_X_BTN_HIGHLIGHT_MEDIA_ID:
               return this._avtEditorXBtnHighlight;
            case CHAR_WINDOW_MEDIA_ID:
               return this._charWindowHighlight;
            case ACHIEVEMENT_POPUP_MEDIA_ID:
               return this._achievementPopup;
            default:
               return null;
         }
      }
      
      private function getFunctionForFunctionId(functionId:int) : Function
      {
         switch(functionId)
         {
            case COLOR_FUNCTION_ID:
            case EYE_FUNCTION_ID:
            case PATTERN_FUNCTION_ID:
               return this._avatarEditor.openTab;
            default:
               return null;
         }
      }
      
      private function onBtnClick(evt:MouseEvent) : void
      {
         this.endSet();
      }
      
      private function soundCompleteHandler(evt:Event) : void
      {
         this._currSoundMustFinishBeforeAdvancing = false;
         if(Boolean(this._soundTimer) && this._soundTimer.running)
         {
            this._soundTimer.stop();
         }
         if(this._shamanShouldTalk)
         {
            this.avatarPlayAnim({
               "userName":"Liza",
               "anim":"idle",
               "hFlip":true
            });
         }
         if(this._currSoundAdvances || this._advanceOnEventTriggered)
         {
            this.endSet();
         }
         else
         {
            if(Boolean(this._currSoundMcOff))
            {
               this._currSoundMcOff.visible = true;
               this._currSoundMcOff = null;
            }
            if(Boolean(this._currSoundMcOn))
            {
               this._currSoundMcOn.visible = false;
               this._currSoundMcOn = null;
            }
            this._currSoundTimer.start();
         }
      }
      
      private function delayCompleteHandler(evt:TimerEvent) : void
      {
         if(this._delayPopupVisibility || this._isSkipping)
         {
            if(Boolean(this._helpBubble))
            {
               this._helpBubble.visible = false;
            }
            else
            {
               this._popup.visible = false;
            }
            this._delayPopupVisibility = false;
         }
         if(Boolean(this._delayTimer))
         {
            this._delayTimer.stop();
            this._delayTimer.removeEventListener(TimerEvent.TIMER,this.delayCompleteHandler);
            this._delayTimer = null;
         }
         if(!this._standAloneDelay)
         {
            this._timerTriggered = true;
         }
         else
         {
            this._standAloneDelay = false;
         }
         if(!this._isSkipping)
         {
            this.nextSet();
         }
      }
      
      private function currSoundTimerCompleteHandler(evt:TimerEvent) : void
      {
         this._currSoundTimer.stop();
         if(this._shamanShouldTalk)
         {
            this.avatarPlayAnim({
               "userName":"Liza",
               "anim":"sleep",
               "hFlip":true
            });
         }
         if(this._currSoundChannel != null)
         {
            this._currSoundChannel = this._currSound.play();
         }
         this._soundTimer.start();
         this._soundTimer.addEventListener(TimerEvent.TIMER,this.soundCompleteHandler,false,0,true);
      }
      
      private function advanceOnClickHandler(evt:MouseEvent) : void
      {
         if(!this._currSoundMustFinishBeforeAdvancing)
         {
            this.nextSet();
         }
         else
         {
            this._advanceOnEventTriggered = true;
            this._delayPopupVisibility = false;
         }
      }
      
      private function advanceOnWalkIn(msg:String) : void
      {
         if(this._advanceOnWalkIn)
         {
            this._roomMgr.callback_TriggerWalkIn = null;
            if(!this._currSoundMustFinishBeforeAdvancing)
            {
               this.endSet();
            }
            else
            {
               this._advanceOnEventTriggered = true;
               this._delayPopupVisibility = false;
            }
            this._goToCircle.visible = false;
         }
      }
   }
}

