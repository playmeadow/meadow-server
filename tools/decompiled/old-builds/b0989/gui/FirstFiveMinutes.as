package gui
{
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
   import flash.utils.getDefinitionByName;
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
      
      public function init(param1:Array, param2:MovieClip, param3:DisplayLayer, param4:SortLayer, param5:DisplayLayer, param6:Function, param7:Boolean = false) : void
      {
         this._streamBaseURL = gMainFrame.clientInfo.contentURL;
         this._sets = param1;
         this._fullCommandSets = param1.slice();
         this._setNumber = 0;
         this._avtMC = param2;
         this._guiLayer = param3;
         this._worldLayer = param4;
         this._chatLayer = param5;
         this._roomMgr = RoomManagerWorld.instance;
         this._doneCallback = param6;
         this._roomMgr.callback_TriggerWalkIn = this.advanceOnWalkIn;
         this._isSkipping = false;
         this._mediaHelpers = [];
         this._trackingNames = ["Welcome to Jamaa","Click the mouse","Hello there","I am Liza","We Shamans","Do you see that statue","That is Mira","You\'ll learn about Mira","Every animal is special","Make yourself unique","Click on the animal picture","Great job!","Click on the color tab","Click on the eye tab","Click on the pattern tab","Click on the x","Excellent work","By changing your colors","Achievements are awards","You have done so well","I want to give you gems","Gems can be used","Point to the gems","Your training is finished","I think you are ready","Good luck"];
         this.isHelpBubble = param7;
         this.initAssets();
         this.processCurrentSet();
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         this._sets.splice(0,this._sets.length);
         this._sets = null;
         this._doneCallback = null;
         this._currSound = null;
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = null;
         }
         if(this._currSoundTimer)
         {
            this._currSoundTimer.stop();
            this._currSoundTimer = null;
         }
         if(this._delayTimer)
         {
            this._delayTimer.stop();
            this._delayTimer = null;
         }
         if(this._soundTimer)
         {
            this._soundTimer.stop();
            this._soundTimer = null;
         }
         if(this._mediaHelpers)
         {
            _loc1_ = 0;
            while(_loc1_ < this._mediaHelpers.length)
            {
               this._mediaHelpers[0].destroy();
               _loc1_++;
            }
            this._mediaHelpers.splice(0,this._mediaHelpers.length);
         }
         if(this._avatarEditor)
         {
            this._avatarEditor = null;
         }
         if(this._skipBtn)
         {
            this._skipBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.skipFFM);
            this._guiLayer.removeChild(this._skipBtn);
            this._skipBtn.visible = false;
            this._skipBtn = null;
         }
         if(this._avtMC)
         {
            this._worldLayer.removeChild(this._avtMC.parent);
            this._avtMC = null;
         }
      }
      
      public function skipFFM(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._delayPopupVisibility = false;
         this._currSoundMustFinishBeforeAdvancing = false;
         this._isSkipping = true;
         this.processAllSets();
         this.delayCompleteHandler(null);
         this._sets.splice(0,this._sets.length);
         this._doneCallback();
      }
      
      public function processAndSplice(param1:String = null, param2:String = null) : void
      {
         this.processCurrentSet();
         this._sets.splice(0,1);
      }
      
      public function doNextSet(param1:Boolean, param2:Array = null) : void
      {
         if(param1)
         {
            if(param2 != null)
            {
               this._sets = param2;
               this._currSetProcessed = false;
               this.processCurrentSet();
               GuiManager.ffmProcessAgainCallback = this.processAndSplice;
            }
         }
         else
         {
            this.processCurrentSet();
            this._sets.splice(0,1);
            this.processCurrentSet();
         }
      }
      
      public function reloadSets(param1:Array = null) : void
      {
         if(param1 == null)
         {
            this.processCurrentSet();
         }
         else
         {
            if(this._delayTimer)
            {
               this._delayTimer.removeEventListener(TimerEvent.TIMER,this.delayCompleteHandler);
               this._delayTimer.stop();
               this._delayTimer = null;
            }
            this._sets = param1;
            this._currSetProcessed = false;
            this.processCurrentSet();
         }
      }
      
      public function processAllSets() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(Boolean(this._fullCommandSets) && this._fullCommandSets.length >= this._setNumber)
         {
            _loc1_ = 0;
            while(_loc1_ <= this._setNumber)
            {
               _loc2_ = this._fullCommandSets[_loc1_];
               if(Boolean(_loc2_) && _loc2_.length > 0)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_.length)
                  {
                     this.processCommand(_loc2_[_loc3_]);
                     _loc3_++;
                  }
               }
               _loc1_++;
            }
         }
      }
      
      public function processCurrentSet() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(Boolean(this._sets) && this._sets.length > 0)
         {
            _loc1_ = this._sets[0];
            if(Boolean(_loc1_) && _loc1_.length > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc1_.length)
               {
                  this.processCommand(_loc1_[_loc2_]);
                  _loc2_++;
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
      
      public function setAvatarEditor(param1:AvatarEditor) : void
      {
         this._avatarEditor = param1;
      }
      
      public function trackUserFFMStateChange(param1:String) : void
      {
         SBTracker.trackPageview("/game/play/FFM/#" + param1);
      }
      
      public function advanceOnCallback() : void
      {
         this.advanceOnClickHandler(null);
      }
      
      private function initAssets() : void
      {
         if(this.isHelpBubble)
         {
            this._helpBubble = new (getDefinitionByName("HelpTxtBubble") as Class)();
            this._helpBubble.init();
         }
         else
         {
            this._popup = new (getDefinitionByName("ChatBalloonShamanBlockNEW") as Class)();
            this._popup.init(10,true);
            this._guiLayer.addChild(this._popup);
            this._popup.visible = false;
            this._chatPopup = new (getDefinitionByName("ChatBalloonShamanNEW") as Class)();
            this._chatPopup.init(10);
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
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            switch(param1.mediaHelper.id)
            {
               case ARROW_U_MEDIA_ID:
                  this._uArrow.addChild(param1);
                  break;
               case ARROW_D_MEDIA_ID:
                  this._dArrow.addChild(param1);
                  break;
               case ARROW_L_MEDIA_ID:
                  this._lArrow.addChild(param1);
                  break;
               case ARROW_R_MEDIA_ID:
                  this._rArrow.addChild(param1);
                  break;
               case GO_HERE_MEDIA_ID:
                  this._goToCircle.addChild(param1);
                  this._worldLayer.addChild(this._goToCircle);
                  this._goToCircle.visible = false;
                  this._goToCircle.x = 620;
                  this._goToCircle.y = 550;
                  MovieClip(this._goToCircle.getChildAt(0)).arrow.gotoAndStop(1);
                  MovieClip(this._goToCircle.getChildAt(0)).circle.gotoAndStop(1);
                  break;
               case MIRA_HIGHLIGHT_MEDIA_ID:
                  this._miraHighlight.addChild(param1);
                  this._worldLayer.addChild(this._miraHighlight);
                  this._miraHighlight.visible = false;
                  this._miraHighlight.x = 352;
                  this._miraHighlight.y = 118;
                  break;
               case COLOR_TAB_HIGHLIGHT_MEDIA_ID:
                  this._colorTabHighlight.addChild(param1);
                  break;
               case EYE_TAB_HIGHLIGHT_MEDIA_ID:
                  this._eyeTabHighlight.addChild(param1);
                  break;
               case PATTERN_TAB_HIGHLIGHT_MEDIA_ID:
                  this._patternTabHighlight.addChild(param1);
                  break;
               case AVATAR_EDITOR_X_BTN_HIGHLIGHT_MEDIA_ID:
                  this._avtEditorXBtnHighlight.addChild(param1);
                  this._avtEditorXBtnHighlight.mouseEnabled = false;
                  this._avtEditorXBtnHighlight.mouseChildren = false;
                  break;
               case CHAR_WINDOW_MEDIA_ID:
                  this._charWindowHighlight.addChild(param1);
                  this._charWindowHighlight.mouseEnabled = false;
                  this._charWindowHighlight.mouseChildren = false;
                  break;
               case ACHIEVEMENT_POPUP_MEDIA_ID:
                  this._achievementPopup.addChild(param1);
                  this._guiLayer.addChild(this._achievementPopup);
                  this._achievementPopup.x = 0;
                  this._achievementPopup.visible = false;
                  break;
               case SKIP_BUTTON:
                  this._skipBtn.addChild(param1);
                  this._guiLayer.addChild(this._skipBtn);
                  this._skipBtn.x = 810;
                  this._skipBtn.y = 420;
                  this._skipBtn.visible = true;
                  this._skipBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.skipFFM,false,0,true);
            }
         }
         if(Boolean(param1) && Boolean(param1.mediaHelper))
         {
            _loc2_ = 0;
            while(_loc2_ < this._mediaHelpers.length)
            {
               if(param1.mediaHelper == this._mediaHelpers[_loc2_])
               {
                  this._mediaHelpers.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
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
               if(this._sets)
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
            if(this._sets)
            {
               this._sets.splice(0,1);
               ++this._setNumber;
               this._delayTimer.start();
            }
         }
      }
      
      private function processCommand(param1:Object) : void
      {
         if(param1)
         {
            switch(param1.cmd)
            {
               case "preload":
                  this.processPreload(param1);
                  break;
               case "playStream":
                  this.processStream(param1);
                  break;
               case "playSound":
                  this.processSound(param1);
                  break;
               case "shaman":
                  this.processShaman(param1);
                  break;
               case "avatarPlayAnim":
                  this.processAvatarPlayAnim(param1);
                  break;
               case "delay":
                  this.processDelay(param1);
                  break;
               case "popup":
                  this.processPopup(param1);
                  break;
               case "arrow":
                  this.processArrow(param1);
                  break;
               case "functionCall":
                  this.processFunctionCall(param1);
                  break;
               case "visibility":
                  this.processVisibility(param1);
                  break;
               case "advanceOnEvent":
                  this.processAdvanceOnEvent(param1);
                  break;
               case "roomSpawn":
                  this.processRoomSpawn(param1);
                  break;
               case "shamanOut":
                  this.processShamanOut(param1);
            }
         }
      }
      
      private function processPreload(param1:Object) : void
      {
         var _loc2_:MediaHelper = null;
         if(!this._currSetProcessed && !this._isSkipping)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(param1.src,this.mediaHelperCallback,true);
            this._mediaHelpers.push(_loc2_);
         }
      }
      
      private function processStream(param1:Object) : void
      {
         var _loc2_:URLRequest = null;
         if(!this._currSetProcessed && !this._isSkipping)
         {
            if(param1.repeatAfter != null && param1.repeatAfter > 0)
            {
               this._currSoundTimer = new Timer(param1.repeatAfter * 1000);
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
            _loc2_ = LoaderCache.fetchCDNURLRequest("/streams/" + param1.src + ".mp3");
            this._currSound.load(_loc2_);
            if(param1.repeatStream != null && param1.repeatStream == true)
            {
               this._repeatStream = true;
            }
            addEventListener(Event.ENTER_FRAME,this.enterFrameHandler,false,0,true);
            if(param1.shamanTalk != null && param1.shamanTalk == true)
            {
               this._shamanShouldTalk = true;
            }
            if(param1.volume != null && param1.volume > 0)
            {
               this._currSoundTransform = new SoundTransform();
               this._currSoundTransform.volume = param1.volume;
            }
            else
            {
               this._currSoundTransform = null;
            }
            if(param1.advances)
            {
               this._currSoundAdvances = param1.advances;
            }
            else
            {
               this._currSoundAdvances = false;
            }
            if(param1.mustFinish != null && param1.mustFinish == true)
            {
               this._currSoundMustFinishBeforeAdvancing = true;
            }
            else
            {
               this._currSoundMustFinishBeforeAdvancing = false;
            }
            if(param1.off)
            {
               this._currSoundMcOff = param1.off;
               this._currSoundMcOff.visible = false;
            }
            if(param1.on)
            {
               this._currSoundMcOn = param1.on;
               this._currSoundMcOn.visible = true;
            }
         }
         else
         {
            if(this._currSoundChannel)
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
            if(this._soundTimer)
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
            if(this._currSound)
            {
               this._currSound = null;
            }
            if(Boolean(this._currSoundTimer) && this._currSoundTimer.running)
            {
               this._currSoundTimer.stop();
            }
            if(this._currSoundMcOff)
            {
               this._currSoundMcOff.visible = true;
            }
            if(this._currSoundMcOn)
            {
               this._currSoundMcOn.visible = false;
            }
         }
      }
      
      private function processSound(param1:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping)
         {
            switch(param1.src)
            {
               case "subMenuClick":
                  AJAudio.playSubMenuBtnClick();
                  break;
               case "gemsEarned":
                  AJAudio.playGemsEarnedSound();
            }
         }
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         if(this._currSound != null)
         {
            _loc2_ = this._currSound.bytesLoaded / this._currSound.bytesTotal;
            if(_loc2_ == 1)
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
      
      private function processShaman(param1:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping)
         {
            this._avtMC.idle();
            this._avtMC.parent.name = this._avtMC.getSortHeight();
            this._worldLayer.addChild(this._avtMC.parent);
            this._avtMC.x = param1.x;
            this._avtMC.y = param1.y;
            this._avtMC.scaleX *= -1;
         }
      }
      
      private function processAvatarPlayAnim(param1:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping)
         {
            this.avatarPlayAnim(param1);
         }
      }
      
      private function avatarPlayAnim(param1:Object) : void
      {
         if(param1.anim == "sleep")
         {
            this._avtMC.talking();
         }
         else if(param1.anim == "idle")
         {
            this._avtMC.idle();
         }
      }
      
      private function idForAnim(param1:String) : int
      {
         switch(param1)
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
      
      private function processDelay(param1:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping)
         {
            if(this._delayTimer)
            {
               this._delayTimer = null;
            }
            this._delayTimer = new Timer(param1.sec * 1000);
            this._delayTimer.addEventListener(TimerEvent.TIMER,this.delayCompleteHandler,false,0,true);
            if(Boolean(param1.type) && param1.type == "standAlone")
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
      
      private function processPopup(param1:Object) : void
      {
         var _loc2_:ChatBalloon = null;
         var _loc3_:GuiHelpTextBubble = null;
         if(param1.type == "helpBubble")
         {
            _loc3_ = this._helpBubble;
         }
         else if(param1.type == "chat")
         {
            _loc2_ = this._chatPopup;
         }
         else
         {
            _loc2_ = this._popup;
         }
         _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onSrcDown,false,0,true);
         if(!this._currSetProcessed && !this._isSkipping)
         {
            this.trackUserFFMStateChange(this._trackingNames[0]);
            this._trackingNames.splice(0,1);
            if(param1.btn != null && GuiManager[param1.btn] == false || param1.btn == "ffmDenCustomizeBtn" && DenEditor.staticEditor.bottomHud.visible == false)
            {
               this._currSetProcessed = true;
               this.nextSet();
               return;
            }
            if(_loc3_)
            {
               if(Boolean(param1.world) && param1.world == true)
               {
                  this._worldLayer.addChild(this._helpBubble);
               }
               else
               {
                  this._guiLayer.addChild(this._helpBubble);
               }
               _loc3_.bringToFront();
               _loc3_.setText(param1.txt);
               _loc3_.setPos(param1.x,param1.y);
               _loc3_.visible = true;
               this._helpBubble.setTails(param1.top,param1.left,param1.twoTails);
            }
            else
            {
               _loc2_.setText(param1.txt);
               _loc2_.x = param1.x;
               _loc2_.y = param1.y;
               _loc2_.visible = true;
            }
            if(param1.delay != null && param1.delay == true)
            {
               this._delayPopupVisibility = true;
            }
         }
         else if(!this._delayPopupVisibility)
         {
            if(_loc3_)
            {
               _loc3_.visible = false;
            }
            else
            {
               _loc2_.visible = false;
            }
            _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSrcDown);
         }
      }
      
      private function processVisibility(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         if(Boolean(param1.type) && (param1.type == "mediaId" || param1.type == "mediaIdAnimated"))
         {
            _loc2_ = this.getMCForMediaId(param1.src);
         }
         else
         {
            _loc2_ = param1.src;
         }
         if(param1.src != GO_HERE_MEDIA_ID)
         {
            _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onSrcDown,false,0,true);
         }
         if(!this._currSetProcessed && !this._isSkipping)
         {
            _loc2_.visible = param1.visibility;
            if(param1.goHere != null && param1.goHere == true)
            {
               if(_loc2_.numChildren > 1)
               {
                  MovieClip(_loc2_.getChildAt(0)).arrow.gotoAndPlay(1);
                  MovieClip(_loc2_.getChildAt(0)).circle.gotoAndPlay(1);
               }
            }
            if(Boolean(param1.type) && param1.type == "mediaIdAnimated")
            {
               MovieClip(_loc2_.getChildAt(0)).turnOn();
            }
            if(param1.layer)
            {
               if(param1.layer == "gui")
               {
                  this._guiLayer.addChild(_loc2_);
               }
               else
               {
                  this._worldLayer.addChild(_loc2_);
               }
            }
            if(param1.x)
            {
               _loc2_.x = param1.x;
            }
            if(param1.y)
            {
               _loc2_.y = param1.y;
            }
         }
         else if(param1.revert != null && param1.revert == true || this._isSkipping)
         {
            if(param1.goHere != null && param1.goHere == true)
            {
               if(Boolean(_loc2_) && _loc2_.numChildren > 0)
               {
                  MovieClip(_loc2_.getChildAt(0)).arrow.gotoAndStop(1);
                  MovieClip(_loc2_.getChildAt(0)).circle.gotoAndStop(1);
               }
            }
            if(Boolean(param1.type) && param1.type == "mediaIdAnimated")
            {
               if(Boolean(_loc2_) && _loc2_.numChildren > 0)
               {
                  MovieClip(_loc2_.getChildAt(0)).turnOff();
               }
            }
            else if(Boolean(param1.type) && param1.type == "mediaId")
            {
               this.getMCForMediaId(param1.src).visible = !param1.visibility;
            }
            else
            {
               param1.src.visible = !param1.visibility;
            }
            if(Boolean(param1.layer) && Boolean(_loc2_) && Boolean(_loc2_.parent))
            {
               _loc2_.parent.removeChild(_loc2_);
            }
            if(param1.src != GO_HERE_MEDIA_ID && Boolean(_loc2_))
            {
               _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSrcDown);
            }
         }
      }
      
      private function processFunctionCall(param1:Object) : void
      {
         var _loc2_:Function = null;
         if(!this._currSetProcessed && !this._isSkipping)
         {
            _loc2_ = this.getFunctionForFunctionId(param1.src);
            if(param1.param != null)
            {
               _loc2_(param1.param);
            }
            else
            {
               _loc2_();
            }
         }
      }
      
      private function processAdvanceOnEvent(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.type == "mediaId")
         {
            _loc2_ = this.getMCForMediaId(param1.src);
         }
         else if(param1.type == "mc")
         {
            _loc2_ = param1.src;
         }
         else if(param1.type == "den")
         {
            _loc2_ = DenEditor.staticEditor[param1.src];
         }
         if(param1.modifyOnClick != null)
         {
            this._modifiedObject = param1.modifyOnClick;
         }
         if(param1.nextToGo != null)
         {
            this._nextControl = param1.nextToGo;
         }
         if(!this._currSetProcessed && !this._isSkipping)
         {
            if(param1.type == "volume")
            {
               this._advanceOnWalkIn = true;
            }
            else if(_loc2_)
            {
               _loc2_.addEventListener(param1.event,this.advanceOnClickHandler,false,0,true);
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
            if(param1.type == "volume")
            {
               this._advanceOnWalkIn = true;
               this._advanceOnEventTriggered = false;
            }
            else
            {
               this._advanceOnEventTriggered = false;
               if(_loc2_)
               {
                  _loc2_.removeEventListener(param1.event,this.advanceOnClickHandler);
               }
            }
         }
      }
      
      private function processArrow(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         switch(param1.dir)
         {
            case "up":
               _loc2_ = this._uArrow;
               break;
            case "down":
               _loc2_ = this._dArrow;
               break;
            case "left":
               _loc2_ = this._lArrow;
               break;
            case "right":
               _loc2_ = this._rArrow;
               break;
            default:
               throw new Error("Arrow type not recognized - type: " + param1.type);
         }
         if(!this._currSetProcessed && !this._isSkipping)
         {
            if(param1.visibility == true)
            {
               if(param1.layer != null && param1.layer == "world")
               {
                  this._worldLayer.addChild(_loc2_);
               }
               else
               {
                  this._guiLayer.addChild(_loc2_);
               }
               _loc2_.visible = true;
               if(param1.src != null)
               {
                  if(param1.type != null && param1.type == "mediaId")
                  {
                     _loc3_ = this.getMCForMediaId(param1.src);
                  }
                  else
                  {
                     _loc3_ = param1.src;
                  }
               }
               if(param1.x != null)
               {
                  if(_loc3_ != null)
                  {
                     _loc2_.x = _loc3_.x + param1.x;
                  }
                  else
                  {
                     _loc2_.x = param1.x;
                  }
               }
               else if(_loc3_ != null)
               {
                  _loc2_.x = _loc3_.x;
               }
               if(param1.y != null)
               {
                  if(_loc3_ != null)
                  {
                     _loc2_.y = _loc3_.y + param1.y;
                  }
                  else
                  {
                     _loc2_.y = param1.y;
                  }
               }
               else if(_loc3_ != null)
               {
                  _loc2_.y = _loc3_.y;
               }
            }
            else
            {
               _loc2_.visible = false;
            }
         }
         else if(param1.revert != null && param1.revert == true || this._isSkipping)
         {
            if(Boolean(_loc2_) && Boolean(_loc2_.parent))
            {
               _loc2_.parent.removeChild(_loc2_);
            }
            _loc2_.visible = false;
         }
      }
      
      private function processRoomSpawn(param1:Object) : void
      {
         if(!this._currSetProcessed && !this._isSkipping && !this._shardRequestSent)
         {
            this._shardRequestSent = true;
            this._roomMgr.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest(param1.room + this._roomMgr.shardId);
            this._currSetProcessed = true;
            this.endSet();
         }
         else if(this._isSkipping && !this._shardRequestSent)
         {
            this._shardRequestSent = true;
            this._currSetProcessed = true;
            this._roomMgr.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest(param1.room + this._roomMgr.shardId);
         }
      }
      
      private function processShamanOut(param1:Object) : void
      {
      }
      
      public function getSets() : Array
      {
         return this._sets;
      }
      
      private function onSoundBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._currSoundChannel)
         {
            this._currSoundChannel.stop();
            this._currSoundChannel = this._currSound.play();
         }
         else
         {
            this._currSoundChannel = this._currSound.play();
         }
      }
      
      private function onSrcDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function getMCForMediaId(param1:int) : MovieClip
      {
         switch(param1)
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
      
      private function getFunctionForFunctionId(param1:int) : Function
      {
         switch(param1)
         {
            case COLOR_FUNCTION_ID:
            case EYE_FUNCTION_ID:
            case PATTERN_FUNCTION_ID:
               return this._avatarEditor.openTab;
            default:
               return null;
         }
      }
      
      private function onBtnClick(param1:MouseEvent) : void
      {
         this.endSet();
      }
      
      private function soundCompleteHandler(param1:Event) : void
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
            if(this._currSoundMcOff)
            {
               this._currSoundMcOff.visible = true;
               this._currSoundMcOff = null;
            }
            if(this._currSoundMcOn)
            {
               this._currSoundMcOn.visible = false;
               this._currSoundMcOn = null;
            }
            this._currSoundTimer.start();
         }
      }
      
      private function delayCompleteHandler(param1:TimerEvent) : void
      {
         if(this._delayPopupVisibility || this._isSkipping)
         {
            if(this._helpBubble)
            {
               this._helpBubble.visible = false;
            }
            else
            {
               this._popup.visible = false;
            }
            this._delayPopupVisibility = false;
         }
         if(this._delayTimer)
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
      
      private function currSoundTimerCompleteHandler(param1:TimerEvent) : void
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
      
      private function advanceOnClickHandler(param1:MouseEvent) : void
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
      
      private function advanceOnWalkIn(param1:String) : void
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

