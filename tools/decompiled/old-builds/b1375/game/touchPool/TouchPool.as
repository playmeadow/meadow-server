package game.touchPool
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import den.DenItem;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundChannel;
   import flash.ui.Mouse;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.SoundManager;
   import gui.GiftPopup;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class TouchPool extends GameBase implements IMinigame
   {
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const RIPPLE_TIME:int = 7;
      
      public var _background:Sprite;
      
      public var _layerStarUrchin:Sprite;
      
      public var _layerSeaslug:Sprite;
      
      public var _layerHermit:Sprite;
      
      public var _layerObstacles:Sprite;
      
      public var _layerSwimmers:Sprite;
      
      public var _layerGems:Sprite;
      
      private var _foreground:Sprite;
      
      private var _lastTime:int;
      
      private var _totalGameTime:Number;
      
      private var _ui:Object;
      
      public var _soundMan:SoundManager;
      
      public var _messageServer:Function;
      
      private var _leaveCallback:Function;
      
      private var _bInit:Boolean;
      
      private var _serialNumber:int;
      
      private var _prizeAwarded:int;
      
      public var _creatures:Array = [];
      
      public var _poolPoints:Array = [];
      
      private var _globalBox1:Point = new Point();
      
      private var _globalBox2:Point = new Point();
      
      private var _currentTouchTimer:Number = 0;
      
      private var _currentTouchTime:Number;
      
      private var _currentTouchingIndex:int;
      
      public var _ripple:Array = new Array(3);
      
      public var _currentRippleIndex:int;
      
      private var _rippleTimer:int;
      
      private var _prevPos:Point = new Point();
      
      private var _log:Object;
      
      private var _logActive:Boolean;
      
      private var _logBitVar1:uint;
      
      private var _logBitVar2:uint;
      
      private var _logArray:Array;
      
      private var _logCreatureCount:Array = [];
      
      private var _factPopup:MovieClip;
      
      private var _factPopupActive:Boolean;
      
      private var _factData:TouchPoolData;
      
      private var _queueShowFact:Boolean;
      
      private var _currentFactID:int;
      
      private var _currentLogID:int;
      
      private var _mediaObjectHelper:MediaHelper = new MediaHelper();
      
      public var _dustClouds:Array = [];
      
      private var _collectPopup:Object;
      
      private var _currentColor:int;
      
      private var _currentType:int;
      
      private var _gemsEarned:int;
      
      private var _gemsAwarded:int;
      
      private var _gemPool:Array;
      
      private var _gemsActive:Array;
      
      private var _minimap:Object;
      
      private var _minimapOffsetX:Number;
      
      private var _minimapOffsetY:Number;
      
      private var _minimapViewX:Number;
      
      private var _minimapViewY:Number;
      
      private var _prizeDenItems:Array = new Array(6);
      
      private var _prizePopup:GiftPopup;
      
      private var _raysInARow:int;
      
      public var _displayAchievementTimer:Number;
      
      private var _giftLogIndex:int;
      
      private var _awardGiftButton:Object;
      
      private var _sortedArray:Array = new Array(12);
      
      private var _isNew:Boolean;
      
      private var MOVEWINDOWWIDTH:int = 450;
      
      private var MOVEWINDOWHEIGHT:int = 300;
      
      private var _soundNameGemNew:String = TouchPoolData._audio[0];
      
      private var _soundNameCd4Sec:String = TouchPoolData._audio[1];
      
      private var _soundNameGemBurst:String = TouchPoolData._audio[2];
      
      internal var _soundNameGemCollision1:String = TouchPoolData._audio[3];
      
      internal var _soundNameGemCollision2:String = TouchPoolData._audio[4];
      
      internal var _soundNameGemCollision3:String = TouchPoolData._audio[5];
      
      private var _soundNameLoggedStinger:String = TouchPoolData._audio[6];
      
      internal var _soundNamePoof:String = TouchPoolData._audio[7];
      
      private var _soundNamePopUpEnter:String = TouchPoolData._audio[8];
      
      private var _soundNamePopUpExit:String = TouchPoolData._audio[9];
      
      private var _soundNamePopUpSuccess:String = TouchPoolData._audio[10];
      
      private var _soundNameRolloverCountDown:String = TouchPoolData._audio[11];
      
      private var _soundNameTileSelect:String = TouchPoolData._audio[12];
      
      private var _soundNameInMenuRollover:String = TouchPoolData._audio[13];
      
      private var _soundNameExitRollover:String = TouchPoolData._audio[14];
      
      private var _soundNameExitSelect:String = TouchPoolData._audio[15];
      
      public var _SFX_TouchPool_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public var _timerSound:SoundChannel;
      
      public function TouchPool()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_TouchPool_Music = _soundMan.addStream("aj_mus_touchPool",0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameGemNew],_soundNameGemNew,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCd4Sec],_soundNameCd4Sec,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameGemBurst],_soundNameGemBurst,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameGemCollision1],_soundNameGemCollision1,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameGemCollision2],_soundNameGemCollision2,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameGemCollision3],_soundNameGemCollision3,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameLoggedStinger],_soundNameLoggedStinger,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePoof],_soundNamePoof,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpEnter],_soundNamePopUpEnter,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpExit],_soundNamePopUpExit,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpSuccess],_soundNamePopUpSuccess,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameRolloverCountDown],_soundNameRolloverCountDown,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTileSelect],_soundNameTileSelect,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameInMenuRollover],_soundNameInMenuRollover,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameExitRollover],_soundNameExitRollover,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameExitSelect],_soundNameExitSelect,0.3);
      }
      
      public function start(param1:uint, param2:Array, param3:Function, param4:Function) : void
      {
         _messageServer = param3;
         _messageServer(["ts"]);
         _leaveCallback = param4;
         init();
      }
      
      private function init() : void
      {
         _lastTime = getTimer();
         if(!_bInit)
         {
            _background = new Sprite();
            _layerStarUrchin = new Sprite();
            _layerSeaslug = new Sprite();
            _layerHermit = new Sprite();
            _layerObstacles = new Sprite();
            _layerSwimmers = new Sprite();
            _layerGems = new Sprite();
            _foreground = new Sprite();
            _guiLayer = new Sprite();
            addChild(_background);
            addChild(_foreground);
            addChild(_guiLayer);
            loadScene("TouchPoolAssets/main_room.xroom",TouchPoolData._audio);
            _bInit = true;
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1[0] == "mm")
         {
            if(param1[2] == "ts")
            {
               _serialNumber = parseInt(param1[3]);
            }
         }
      }
      
      private function getWorldCoords(param1:Object, param2:Point) : void
      {
         param2.x = param1.x;
         param2.y = param1.y;
         var _loc3_:Object = param1;
         while(_loc3_.parent)
         {
            _loc3_ = _loc3_.parent;
            param2.x += _loc3_.x;
            param2.y += _loc3_.y;
         }
      }
      
      private function boxCollisionTestGlobal(param1:Object, param2:Object) : Boolean
      {
         var _loc10_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         getWorldCoords(param1,_globalBox1);
         getWorldCoords(param2,_globalBox2);
         _loc10_ = _globalBox1.x - param1.width * 0.5;
         _loc9_ = _globalBox2.x - param2.width * 0.5;
         _loc8_ = _globalBox1.x + param1.width * 0.5;
         _loc7_ = _globalBox2.x + param2.width * 0.5;
         _loc5_ = _globalBox1.y - param1.height * 0.5;
         _loc6_ = _globalBox2.y - param2.height * 0.5;
         _loc4_ = _globalBox1.y + param1.height * 0.5;
         _loc3_ = _globalBox2.y + param2.height * 0.5;
         if(_loc4_ < _loc6_)
         {
            return false;
         }
         if(_loc5_ > _loc3_)
         {
            return false;
         }
         if(_loc8_ < _loc9_)
         {
            return false;
         }
         if(_loc10_ > _loc7_)
         {
            return false;
         }
         return true;
      }
      
      public function end(param1:Array) : void
      {
         exit();
      }
      
      private function exit() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
         hideDlg();
         Mouse.show();
         addGemsToBalance(_gemsEarned - _gemsAwarded);
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",showTutKeyDown);
         removeEventListener("enterFrame",Heartbeat);
         _log.openLogButton.removeEventListener("click",logClick);
         _log.openLogButton.removeEventListener("mouseOver",logOver);
         _log.tierneyLog.x_btn.removeEventListener("click",closeLog);
         _log.tierneyLog.x_btn.removeEventListener("mouseOver",doneButtonOver);
         _log.tierneyLog.infoBtn1.removeEventListener("click",logFactPopup);
         _log.tierneyLog.infoBtn2.removeEventListener("click",logFactPopup);
         _log.tierneyLog.infoBtn3.removeEventListener("click",logFactPopup);
         _log.tierneyLog.infoBtn4.removeEventListener("click",logFactPopup);
         _log.tierneyLog.infoBtn5.removeEventListener("click",logFactPopup);
         _log.tierneyLog.infoBtn6.removeEventListener("click",logFactPopup);
         _log.tierneyLog.infoBtn1.removeEventListener("mouseOver",infoBtnOver);
         _log.tierneyLog.infoBtn2.removeEventListener("mouseOver",infoBtnOver);
         _log.tierneyLog.infoBtn3.removeEventListener("mouseOver",infoBtnOver);
         _log.tierneyLog.infoBtn4.removeEventListener("mouseOver",infoBtnOver);
         _log.tierneyLog.infoBtn5.removeEventListener("mouseOver",infoBtnOver);
         _log.tierneyLog.infoBtn6.removeEventListener("mouseOver",infoBtnOver);
         _factPopup.factPopup.doneButton.removeEventListener("mouseOver",doneButtonOver);
         _factPopup.factPopup.doneButton.removeEventListener("mouseOut",doneButtonOut);
         _factPopup.factPopup.doneButton.removeEventListener("click",doneButtonClick);
         _factPopup.factPopup.x_btn.removeEventListener("mouseOver",doneButtonOver);
         _factPopup.factPopup.x_btn.removeEventListener("mouseOut",doneButtonOut);
         _factPopup.factPopup.x_btn.removeEventListener("click",doneButtonClick);
         _background.removeChild(_layerStarUrchin);
         _background.removeChild(_layerSeaslug);
         _background.removeChild(_layerHermit);
         _background.removeChild(_layerObstacles);
         _background.removeChild(_layerSwimmers);
         _background.removeChild(_layerGems);
         removeLayer(_background);
         removeLayer(_foreground);
         removeLayer(_guiLayer);
         _background = null;
         _foreground = null;
         _guiLayer = null;
         if(_leaveCallback != null)
         {
            _leaveCallback();
         }
         _bInit = false;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc9_:int = 0;
         var _loc6_:* = null;
         var _loc3_:Object = null;
         var _loc8_:Array = null;
         var _loc4_:Object = null;
         var _loc2_:Sprite = null;
         var _loc7_:int = 0;
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_TouchPool_Music,0,999999);
         _raysInARow = 0;
         _displayAchievementTimer = 0;
         addEventListener("enterFrame",Heartbeat);
         _closeBtn = addBtn("CloseButton",847,5,showExitConfirmationDlg);
         var _loc5_:Object = _scene.getLayer("bg").loader;
         _background.addChild(_loc5_ as DisplayObject);
         _background.addChild(_layerStarUrchin);
         _background.addChild(_layerSeaslug);
         _background.addChild(_layerHermit);
         _background.addChild(_layerObstacles);
         _background.addChild(_layerSwimmers);
         _background.addChild(_layerGems);
         _minimapOffsetX = _loc5_.x;
         _minimapOffsetY = _loc5_.y;
         _prizeDenItems[0] = new DenItem();
         _prizeDenItems[0].initShopItem(867,0);
         _prizeDenItems[1] = new DenItem();
         _prizeDenItems[1].initShopItem(869,0);
         _prizeDenItems[2] = new DenItem();
         _prizeDenItems[2].initShopItem(872,0);
         _prizeDenItems[3] = new DenItem();
         _prizeDenItems[3].initShopItem(868,0);
         _prizeDenItems[4] = new DenItem();
         _prizeDenItems[4].initShopItem(870,0);
         _prizeDenItems[5] = new DenItem();
         _prizeDenItems[5].initShopItem(871,0);
         _loc8_ = _scene.getActorList("ActorSpawn");
         for each(_loc6_ in _loc8_)
         {
            _loc6_.used = false;
            _poolPoints.push(_loc6_);
         }
         _poolPoints = randomizeArray(_poolPoints);
         _loc8_ = _scene.getActorList("ActorLayer");
         for each(_loc6_ in _loc8_)
         {
            if(_loc6_.name == "anem")
            {
               _layerObstacles.addChild(_loc6_.s as DisplayObject);
            }
         }
         _loc9_ = 0;
         while(_loc9_ < 12)
         {
            _sortedArray[_loc9_] = {};
            _loc7_ = Math.floor(_loc9_ * 0.5);
            _loc2_ = getLayerFromType(_loc7_);
            _loc4_ = _poolPoints[_loc9_];
            _creatures[_loc9_] = new TouchPoolCreature(this);
            _creatures[_loc9_].init(_loc7_,_loc4_.x,_loc4_.y,_loc9_ % 2 == 0);
            if(_loc7_ > 3)
            {
               _poolPoints[_loc9_].used = true;
               _creatures[_loc9_]._spawnIndex = _loc9_;
            }
            if(_creatures[_loc9_]._wake)
            {
               for each(_loc6_ in _creatures[_loc9_]._wake)
               {
                  _background.addChildAt(_loc6_ as DisplayObject,1);
               }
            }
            _loc2_.addChild(_creatures[_loc9_]._clone.loader);
            _loc9_++;
         }
         _currentRippleIndex = 0;
         _loc9_ = 0;
         while(_loc9_ < _ripple.length)
         {
            _ripple[_loc9_] = GETDEFINITIONBYNAME("tierneyPool_ripple");
            _background.addChild(_ripple[_loc9_] as DisplayObject);
            _ripple[_loc9_].scaleX = _ripple[_loc9_].scaleY = 1.5;
            _loc9_++;
         }
         _loc3_ = _scene.getLayer("timer");
         _foreground.addChild(_scene.getLayer("paw").loader);
         _foreground.addChild(_loc3_.loader);
         _loc3_.loader.visible = false;
         _log = GETDEFINITIONBYNAME("tierneyPool_logBook");
         _guiLayer.addChild(_log as DisplayObject);
         _log.openLogButton.addEventListener("click",logClick,false,0,true);
         _log.openLogButton.addEventListener("mouseOver",logOver,false,0,true);
         _log.tierneyLog.x_btn.addEventListener("click",closeLog,false,0,true);
         _log.tierneyLog.x_btn.addEventListener("mouseOver",doneButtonOver,false,0,true);
         _log.tierneyLog.infoBtn1.addEventListener("click",logFactPopup,false,0,true);
         _log.tierneyLog.infoBtn2.addEventListener("click",logFactPopup,false,0,true);
         _log.tierneyLog.infoBtn3.addEventListener("click",logFactPopup,false,0,true);
         _log.tierneyLog.infoBtn4.addEventListener("click",logFactPopup,false,0,true);
         _log.tierneyLog.infoBtn5.addEventListener("click",logFactPopup,false,0,true);
         _log.tierneyLog.infoBtn6.addEventListener("click",logFactPopup,false,0,true);
         _log.tierneyLog.infoBtn1.addEventListener("mouseOver",infoBtnOver,false,0,true);
         _log.tierneyLog.infoBtn2.addEventListener("mouseOver",infoBtnOver,false,0,true);
         _log.tierneyLog.infoBtn3.addEventListener("mouseOver",infoBtnOver,false,0,true);
         _log.tierneyLog.infoBtn4.addEventListener("mouseOver",infoBtnOver,false,0,true);
         _log.tierneyLog.infoBtn5.addEventListener("mouseOver",infoBtnOver,false,0,true);
         _log.tierneyLog.infoBtn6.addEventListener("mouseOver",infoBtnOver,false,0,true);
         _logActive = false;
         _minimap = _scene.getLayer("minimap").loader;
         _foreground.addChild(_scene.getLayer("minimap").loader);
         _minimapViewX = _minimap.content.view.x;
         _minimapViewY = _minimap.content.view.y;
         setupLog();
         _factPopup = GETDEFINITIONBYNAME("tierneyPool_factPopup");
         _factPopup.factPopup.doneButton.addEventListener("mouseOver",doneButtonOver,false,0,true);
         _factPopup.factPopup.doneButton.addEventListener("mouseOut",doneButtonOut,false,0,true);
         _factPopup.factPopup.doneButton.addEventListener("click",doneButtonClick,false,0,true);
         _factPopup.factPopup.x_btn.addEventListener("mouseOver",doneButtonOver,false,0,true);
         _factPopup.factPopup.x_btn.addEventListener("mouseOut",doneButtonOut,false,0,true);
         _factPopup.factPopup.x_btn.addEventListener("click",doneButtonClick,false,0,true);
         _queueShowFact = false;
         _factPopupActive = false;
         _mediaObjectHelper.init(397,mediaObjectSpiralLoaded);
         _collectPopup = GETDEFINITIONBYNAME("tierneyPool_collect");
         _guiLayer.addChild(_collectPopup as DisplayObject);
         _guiLayer.addChild(_factPopup);
         _factData = new TouchPoolData();
         _totalGameTime = 0;
         _prevPos.x = mouseX;
         _prevPos.y = mouseY;
         _gemsEarned = 0;
         _gemsAwarded = 0;
         _log.gems.text = _gemsEarned.toString();
         _gemsActive = [];
         _gemPool = [];
         _loc9_ = 0;
         while(_loc9_ < 10)
         {
            _gemPool[_loc9_] = new TouchPoolGem(this);
            _loc9_++;
         }
         showTutorialDlg();
         super.sceneLoaded(param1);
      }
      
      private function respawnCreature(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = findFarthestPointIndex(param1._clone.loader.x,param1._clone.loader.y,param1._type > 3);
         _loc2_ = _poolPoints[_loc3_];
         param1._spawnIndex = _loc3_;
         param1._clone.loader.x = _loc2_.x;
         param1._clone.loader.y = _loc2_.y;
         param1._color = Math.floor(Math.random() * 5) + 1;
         param1._content.changeColor(param1._color);
      }
      
      private function awardGift(param1:int) : void
      {
         _pauseGame = true;
         _prizePopup = new GiftPopup();
         _prizeAwarded = param1;
         _prizePopup.init(this.parent,_prizeDenItems[param1].icon,_prizeDenItems[param1].name,_prizeDenItems[param1].defId,5,2,keptItem,rejectedItem,destroyPrizePopup);
      }
      
      private function keptItem() : void
      {
         var _loc2_:Number = _prizeAwarded * 5 + (gMainFrame.server.userId + 99) * 3 + (_serialNumber + 49) * 5;
         var _loc1_:Number = (_serialNumber + gMainFrame.server.userId + _prizeAwarded) * 3 + _prizeAwarded * 3;
         _messageServer(["tp",_loc2_,_loc1_]);
         _prizePopup.close();
         markGiftUnwrapped();
      }
      
      private function rejectedItem() : void
      {
         _prizePopup.close();
         markGiftUnwrapped();
      }
      
      private function markGiftUnwrapped() : void
      {
         _logArray[_giftLogIndex][0] = 2;
         if(_giftLogIndex == 6)
         {
            _logBitVar2 |= 1;
            AchievementXtCommManager.requestSetUserVar(300,_logBitVar2);
         }
         else
         {
            _logBitVar1 |= 1 << (_giftLogIndex - 1) * 6;
            AchievementXtCommManager.requestSetUserVar(299,_logBitVar1);
         }
         _log.tierneyLog.collectionList = _logArray;
         _log.tierneyLog.openWindow();
         _awardGiftButton.removeEventListener("click",presentClick);
      }
      
      private function destroyPrizePopup() : void
      {
         if(_prizePopup)
         {
            _pauseGame = false;
            _prizePopup.destroy();
            _prizePopup = null;
         }
      }
      
      public function getLayerFromType(param1:int) : Sprite
      {
         switch(param1)
         {
            case 0:
            case 1:
               return _layerSwimmers;
            case 2:
               return _layerSeaslug;
            case 3:
               return _layerHermit;
            case 4:
            case 5:
               return _layerStarUrchin;
            default:
               return null;
         }
      }
      
      public function spawnGems(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         _soundMan.playByName(_soundNameGemBurst);
         _loc5_ = 0;
         while(_loc5_ < param1)
         {
            if(_gemPool.length)
            {
               _loc4_ = _gemPool.pop();
            }
            else
            {
               _loc4_ = new TouchPoolGem(this);
            }
            _loc4_._clone.newGem();
            _loc4_.reset();
            _layerGems.addChild(_loc4_._clone as DisplayObject);
            _loc4_._clone.x = param2;
            _loc4_._clone.y = param3;
            _gemsActive.push(_loc4_);
            _loc5_++;
         }
      }
      
      public function creatureFlee(param1:Object) : void
      {
         if(_currentTouchingIndex >= 0 && _creatures[_currentTouchingIndex] == param1)
         {
            _currentTouchTimer = 0;
         }
      }
      
      private function logFactPopup(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         if(param1.currentTarget.currentLabel != "off")
         {
            _loc3_ = 1;
            _loc2_ = int(param1.currentTarget.name.charAt(7));
            _loc4_ = 1;
            while(_loc4_ < 6)
            {
               if(_logArray[_loc2_][_loc4_] == 1)
               {
                  break;
               }
               _loc4_++;
            }
            showFactPopup(TouchPoolCreature.getTypeFromLogIndex(parseInt(param1.currentTarget.name.charAt(7))),_loc4_,false);
         }
      }
      
      private function doneButtonOver(param1:MouseEvent) : void
      {
         param1.currentTarget.gotoAndStop("on");
         if(param1.currentTarget["buttonText"])
         {
            if(_isNew)
            {
               LocalizationManager.translateId(param1.currentTarget.buttonText.buttonLabel,11939);
            }
            else
            {
               LocalizationManager.translateId(param1.currentTarget.buttonText.buttonLabel,11940);
            }
         }
         _soundMan.playByName(_soundNameExitRollover);
      }
      
      private function doneButtonOut(param1:MouseEvent) : void
      {
         param1.currentTarget.gotoAndStop("off");
         if(param1.currentTarget["buttonText"])
         {
            if(_isNew)
            {
               LocalizationManager.translateId(param1.currentTarget.buttonText.buttonLabel,11939);
            }
            else
            {
               LocalizationManager.translateId(param1.currentTarget.buttonText.buttonLabel,11940);
            }
         }
      }
      
      private function doneButtonClick(param1:MouseEvent) : void
      {
         if(_factPopup.factPopup.result_pic.numChildren > 0)
         {
            if(!_logActive)
            {
               _factPopup.addFact();
               Mouse.hide();
            }
            else
            {
               _factPopup.factOff();
            }
            _factPopupActive = false;
            _soundMan.playByName(_soundNamePopUpExit);
         }
      }
      
      private function setupLog() : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         var _loc4_:* = 0;
         _logArray = [];
         _loc5_ = 0;
         while(_loc5_ < 6)
         {
            _logArray[_loc5_ + 1] = [];
            _loc5_++;
         }
         _logBitVar1 = gMainFrame.userInfo.userVarCache.getUserVarValueById(299);
         _logBitVar2 = gMainFrame.userInfo.userVarCache.getUserVarValueById(300);
         if(_logBitVar1 == 4294967295)
         {
            _logBitVar1 = 0;
         }
         if(_logBitVar2 == 4294967295)
         {
            _logBitVar2 = 0;
         }
         _loc4_ = _logBitVar1;
         _loc5_ = 0;
         while(_loc5_ < 6)
         {
            _logCreatureCount[_loc5_ + 1] = gMainFrame.userInfo.userVarCache.getUserVarValueById(301 + _loc5_);
            if(_logCreatureCount[_loc5_ + 1] < 0)
            {
               _logCreatureCount[_loc5_ + 1] = 0;
            }
            _log.tierneyLog["count" + (_loc5_ + 1)].text = _logCreatureCount[_loc5_ + 1];
            if(_loc5_ == 5)
            {
               _loc4_ = _logBitVar2;
            }
            _loc2_ = 0;
            _loc3_ = 1;
            while(_loc3_ < 6)
            {
               _loc1_ = int((_loc4_ & 1 << (_loc5_ * 6 + _loc3_) % 30) != 0);
               _logArray[_loc5_ + 1][_loc3_] = _loc1_;
               _loc2_ += _loc1_;
               _loc3_++;
            }
            if((_loc4_ & 1 << _loc5_ * 6 % 30) != 0)
            {
               _logArray[_loc5_ + 1][0] = 2;
            }
            else if(_loc2_ == 5)
            {
               _logArray[_loc5_ + 1][0] = 1;
               _log.tierneyLog["present" + (_loc5_ + 1)].addEventListener("click",presentClick,false,0,true);
            }
            else
            {
               _logArray[_loc5_ + 1][0] = 0;
            }
            _loc5_++;
         }
      }
      
      private function touchCreature() : void
      {
         var _loc2_:TouchPoolCreature = _creatures[_currentTouchingIndex];
         var _loc1_:int = TouchPoolCreature.getLogIndexFromType(_loc2_._type);
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_loc2_._type == 1)
         {
            _raysInARow = _raysInARow + 1;
            if(_raysInARow == 10)
            {
               AchievementXtCommManager.requestSetUserVar(309,10);
            }
         }
         else
         {
            _raysInARow = 0;
         }
         if(_logArray[_loc1_][_loc2_._color] == 0)
         {
            _logArray[_loc1_][_loc2_._color] = 1;
            if(_loc1_ == 6)
            {
               _logBitVar2 |= 1 << _loc2_._color;
               AchievementXtCommManager.requestSetUserVar(300,_logBitVar2);
            }
            else
            {
               _logBitVar1 |= 1 << (_loc1_ - 1) * 6 + _loc2_._color;
               AchievementXtCommManager.requestSetUserVar(299,_logBitVar1);
            }
            _queueShowFact = true;
            _currentType = _loc2_._type;
            _currentColor = _loc2_._color;
            _loc4_ = 1;
            while(_loc4_ < 6)
            {
               if(_logArray[_loc1_][_loc4_] == 0)
               {
                  break;
               }
               _loc4_++;
            }
            if(_loc4_ == 6)
            {
               _logArray[_loc1_][0] = 1;
               _log.tierneyLog["present" + _loc1_].addEventListener("click",presentClick,false,0,true);
            }
         }
         if(_loc2_._type > 3)
         {
            _poolPoints[_loc2_._spawnIndex].used = false;
         }
         spawnGems(_loc2_.getNumGems(),_loc2_._clone.loader.x,_loc2_._clone.loader.y);
         _logCreatureCount[_loc1_]++;
         _log.tierneyLog["count" + _loc1_].text = _logCreatureCount[_loc1_];
         AchievementXtCommManager.requestSetUserVar(300 + _loc1_,1);
         AchievementXtCommManager.requestSetUserVar(308,1);
         _collectPopup.x = _loc2_._clone.loader.x + _loc2_._clone.loader.parent.parent.x;
         _collectPopup.y = _loc2_._clone.loader.y + _loc2_._clone.loader.parent.parent.y;
         _collectPopup.counter.counterText.text = _logCreatureCount[_loc1_].toString();
         _collectPopup.gotoAndPlay("on");
         _collectPopup.critterIcons(_loc1_);
         _soundMan.playByName(_soundNameLoggedStinger);
         _loc4_ = 1;
         while(_loc4_ <= 6)
         {
            if(_logArray[_loc4_][0] == 0)
            {
               break;
            }
            _loc4_++;
         }
         if(_loc4_ == 7)
         {
            AchievementXtCommManager.requestSetUserVar(310,30);
         }
         else
         {
            _loc4_ = 1;
            while(_loc4_ <= 6)
            {
               if(_logCreatureCount[_loc4_] == 0)
               {
                  break;
               }
               _loc4_++;
            }
            if(_loc4_ == 7)
            {
               AchievementXtCommManager.requestSetUserVar(310,6);
            }
         }
         respawnCreature(_loc2_);
         _displayAchievementTimer = 1;
      }
      
      private function presentClick(param1:MouseEvent) : void
      {
         _giftLogIndex = parseInt(param1.currentTarget.name.charAt(7));
         _awardGiftButton = param1.currentTarget;
         awardGift(_giftLogIndex - 1);
      }
      
      private function closeLog(param1:MouseEvent) : void
      {
         Mouse.hide();
         _log.closeLog();
         _logActive = false;
         _soundMan.playByName(_soundNameExitSelect);
      }
      
      private function logClick(param1:MouseEvent) : void
      {
         if(!_pauseGame)
         {
            if(_logActive)
            {
               Mouse.hide();
               closeLog(null);
            }
            else
            {
               Mouse.show();
               _log.tierneyLog.collectionList = _logArray;
               _log.tierneyLog.openWindow();
               _log.openLog();
               _logActive = true;
               _soundMan.playByName(_soundNamePopUpEnter);
            }
         }
      }
      
      private function logOver(param1:MouseEvent) : void
      {
         _soundMan.playByName(_soundNameInMenuRollover);
      }
      
      private function infoBtnOver(param1:MouseEvent) : void
      {
         _soundMan.playByName(_soundNameInMenuRollover);
      }
      
      private function isColliding(param1:DisplayObject, param2:DisplayObject, param3:DisplayObjectContainer, param4:Boolean = true, param5:int = 255) : Boolean
      {
         var _loc6_:Rectangle = param1.getBounds(param3);
         var _loc8_:Rectangle = param2.getBounds(param3);
         var _loc13_:Rectangle = _loc6_.intersection(_loc8_);
         if(!param4)
         {
            return !_loc13_.isEmpty();
         }
         _loc13_.x = Math.floor(_loc13_.x);
         _loc13_.y = Math.floor(_loc13_.y);
         _loc13_.width = Math.ceil(_loc13_.width);
         _loc13_.height = Math.ceil(_loc13_.height);
         if(_loc13_.isEmpty())
         {
            return false;
         }
         var _loc11_:Matrix = param3.transform.concatenatedMatrix.clone();
         _loc11_.invert();
         var _loc7_:Matrix = param1.transform.concatenatedMatrix.clone();
         _loc7_.concat(_loc11_);
         var _loc10_:Matrix = param2.transform.concatenatedMatrix.clone();
         _loc10_.concat(_loc11_);
         _loc7_.translate(-_loc13_.x,-_loc13_.y);
         _loc10_.translate(-_loc13_.x,-_loc13_.y);
         var _loc12_:BitmapData = new BitmapData(_loc13_.width,_loc13_.height,false);
         _loc12_.draw(param1,_loc7_,new ColorTransform(1,1,1,1,255,-255,-255,param5),"normal");
         _loc12_.draw(param2,_loc10_,new ColorTransform(1,1,1,1,255,255,255,param5),"difference");
         var _loc9_:Rectangle = _loc12_.getColorBoundsRect(4294967295,4278255615);
         _loc9_.offset(_loc13_.x,_loc13_.y);
         _loc12_.dispose();
         return !_loc9_.isEmpty();
      }
      
      public function randomizeArray(param1:Array) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc5_:Number = param1.length - 1;
         _loc2_ = 0;
         while(_loc2_ < _loc5_)
         {
            _loc3_ = Math.round(Math.random() * _loc5_);
            _loc4_ = param1[_loc2_];
            param1[_loc2_] = param1[_loc3_];
            param1[_loc3_] = _loc4_;
            _loc2_++;
         }
         return param1;
      }
      
      public function findFarthestPointIndex(param1:Number, param2:Number, param3:Boolean) : int
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < _poolPoints.length)
         {
            _sortedArray[_loc5_].curDistSq = (param1 - _poolPoints[_loc5_].x) * (param1 - _poolPoints[_loc5_].x) + (param2 - _poolPoints[_loc5_].y) * (param2 - _poolPoints[_loc5_].y);
            _sortedArray[_loc5_].i = _loc5_;
            _loc5_++;
         }
         _sortedArray.sortOn("curDistSq",2 | 0x10);
         if(param3)
         {
            _loc5_ = 0;
            while(_loc5_ < _poolPoints.length)
            {
               if(_poolPoints[_sortedArray[_loc5_].i].used == false)
               {
                  _poolPoints[_sortedArray[_loc5_].i].used = true;
                  return _sortedArray[_loc5_].i;
               }
               _loc5_++;
            }
         }
         return _sortedArray[0].i;
      }
      
      private function Heartbeat(param1:Event) : void
      {
         var _loc6_:int = 0;
         var _loc4_:* = null;
         var _loc8_:Number = NaN;
         var _loc3_:* = null;
         var _loc18_:Object = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc5_:Number = (getTimer() - _lastTime) / 1000;
         var _loc11_:int = (900 - MOVEWINDOWWIDTH) * 0.5;
         var _loc12_:int = (550 - MOVEWINDOWHEIGHT) * 0.5;
         var _loc2_:int = 18;
         _lastTime = getTimer();
         if(_pauseGame || _logActive || _factPopupActive)
         {
            return;
         }
         if(!_queueShowFact && !_factPopupActive && _displayAchievementTimer > 0)
         {
            _displayAchievementTimer -= _loc5_;
            if(_displayAchievementTimer <= 0)
            {
               _displayAchievementTimer = 0;
               AchievementManager.displayNewAchievements();
            }
         }
         var _loc17_:Object = _background;
         var _loc16_:Object = _scene.getLayer("paw").loader;
         if(_queueShowFact)
         {
            if(_collectPopup.done)
            {
               _queueShowFact = false;
               showFactPopup(_currentType,_currentColor,true);
            }
         }
         _loc16_.x = mouseX;
         _loc16_.y = mouseY;
         var _loc7_:Number = Number(_loc17_.x);
         var _loc13_:Number = Number(_loc17_.y);
         if(mouseX >= _minimap.x - 20 && mouseY >= _minimap.y - 20)
         {
            _loc8_ = 0.3;
         }
         else
         {
            _loc8_ = 1;
         }
         if(_loc8_ > _minimap.alpha)
         {
            _minimap.alpha += _loc5_ * 2;
            if(_minimap.alpha > _loc8_)
            {
               _minimap.alpha = _loc8_;
            }
         }
         else if(_loc8_ < _minimap.alpha)
         {
            _minimap.alpha -= _loc5_ * 2;
            if(_minimap.alpha < _loc8_)
            {
               _minimap.alpha = _loc8_;
            }
         }
         if(mouseX < _loc11_)
         {
            _loc17_.x += _loc2_ * (_loc11_ - mouseX) / _loc11_;
            if(_loc17_.x > 675)
            {
               _loc17_.x = 675;
            }
         }
         else if(mouseX > 900 - _loc11_)
         {
            _loc17_.x -= _loc2_ * (mouseX - 900 + _loc11_) / 200;
            if(_loc17_.x < -1530)
            {
               _loc17_.x = -1530;
            }
         }
         if(mouseY < _loc12_)
         {
            _loc17_.y += _loc2_ * (_loc12_ - mouseY) / _loc12_;
            if(_loc17_.y > 330)
            {
               _loc17_.y = 330;
            }
         }
         else if(mouseY > 550 - _loc12_)
         {
            _loc17_.y -= _loc2_ * (mouseY - 550 + _loc12_) / _loc12_;
            if(_loc17_.y < -1530)
            {
               _loc17_.y = -1530;
            }
         }
         _loc7_ -= _loc17_.x;
         _loc13_ -= _loc17_.y;
         _minimap.content.view.x = (_minimapOffsetX - _background.x) * 0.05 + _minimapViewX;
         _minimap.content.view.y = (_minimapOffsetY - _background.y) * 0.05 + _minimapViewY;
         var _loc14_:Object = _scene.getLayer("timer");
         _loc14_.loader.visible = false;
         if(_currentTouchingIndex >= 0 && boxCollisionTestGlobal(_loc16_,_creatures[_currentTouchingIndex]._clone.loader))
         {
            _loc14_.loader.visible = true;
            _loc14_.loader.x = mouseX;
            _loc14_.loader.y = mouseY;
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < _creatures.length)
            {
               if(boxCollisionTestGlobal(_loc16_,_creatures[_loc6_]._clone.loader))
               {
                  _loc14_.loader.visible = true;
                  _loc14_.loader.x = mouseX;
                  _loc14_.loader.y = mouseY;
                  if(_currentTouchingIndex != _loc6_)
                  {
                     _currentTouchingIndex = _loc6_;
                     _currentTouchTimer = 0;
                     _currentTouchTime = _creatures[_loc6_].getTouchTime();
                     _timerSound = _soundMan.playByName(_soundNameCd4Sec);
                     _loc16_.content.gotoAndPlay("on");
                  }
                  break;
               }
               _loc6_++;
            }
         }
         for each(_loc3_ in _creatures)
         {
            _loc3_.heartbeat(_loc5_);
         }
         if(_loc14_.loader.visible)
         {
            _currentTouchTimer += _loc5_;
            if(_currentTouchTimer >= _currentTouchTime)
            {
               touchCreature();
               _currentTouchingIndex = -1;
            }
            _loc14_.loader.content.time(Math.floor(_currentTouchTimer * 1000 / _currentTouchTime));
         }
         else
         {
            _currentTouchTimer = 0;
            _loc16_.content.gotoAndPlay("off");
            _currentTouchingIndex = -1;
            if(_timerSound)
            {
               _timerSound.stop();
            }
         }
         _loc6_ = 0;
         while(_loc6_ < _gemsActive.length)
         {
            _loc18_ = _gemsActive[_loc6_]._clone;
            if(_loc18_.collectible)
            {
               _gemsActive[_loc6_].heartbeat(_loc5_);
               if(!_gemsActive[_loc6_]._collected && boxCollisionTestGlobal(_loc16_,_loc18_.gem.gem))
               {
                  _gemsActive[_loc6_].collect();
                  _gemsEarned = _gemsEarned + 1;
                  _log.gems.text = _gemsEarned.toString();
                  _soundMan.playByName(_soundNameGemNew);
                  if(_gemsEarned - _gemsAwarded == 300)
                  {
                     addGemsToBalance(300);
                     _gemsAwarded += 300;
                  }
               }
               else if(_loc18_.parent == null)
               {
                  _gemPool.push(_gemsActive[_loc6_]);
                  _gemsActive.splice(_loc6_,1);
                  _loc6_--;
               }
            }
            _loc6_++;
         }
         if(_rippleTimer == 0)
         {
            _loc9_ = _loc16_.x - _background.x;
            _loc10_ = _loc16_.y - _background.y;
            if(!(_loc10_ < -50 || _loc9_ > 2150 || _loc10_ > 1750 || _loc9_ < -350))
            {
               _loc15_ = Math.sqrt((mouseX - _prevPos.x + _loc7_) * (mouseX - _prevPos.x + _loc7_) + (mouseY - _prevPos.y + _loc13_) * (mouseY - _prevPos.y + _loc13_)) / _loc5_;
               if(_loc15_ > 625)
               {
                  _ripple[_currentRippleIndex].x = _loc16_.x - _background.x;
                  _ripple[_currentRippleIndex].y = _loc16_.y - _background.y;
                  _ripple[_currentRippleIndex].rippleOn();
                  _rippleTimer = 7;
                  _currentRippleIndex = _currentRippleIndex + 1;
                  if(_currentRippleIndex >= _ripple.length)
                  {
                     _currentRippleIndex = 0;
                  }
               }
            }
         }
         else
         {
            _rippleTimer -= 1;
         }
         _prevPos.x = mouseX;
         _prevPos.y = mouseY;
         _totalGameTime += _loc5_;
      }
      
      private function mediaObjectLoaded(param1:MovieClip) : void
      {
         param1.x = 0;
         param1.y = 0;
         _factPopup.factPopup.result_pic.addChild(param1);
      }
      
      private function mediaObjectSpiralLoaded(param1:MovieClip) : void
      {
         param1.x = 0;
         param1.y = 0;
         _factPopup.factPopup.loadArrowContainer.addChild(param1);
      }
      
      private function showFactPopup(param1:int, param2:int, param3:Boolean) : void
      {
         Mouse.show();
         _factPopupActive = true;
         _currentFactID = TouchPoolCreature.getFactIndexFromType(param1) * 5 + param2 - 1;
         _currentLogID = TouchPoolCreature.getLogIndexFromType(param1);
         _factPopup.factPopup.showIcons(_currentLogID,[false,Boolean(_logArray[_currentLogID][1]),Boolean(_logArray[_currentLogID][2]),Boolean(_logArray[_currentLogID][3]),Boolean(_logArray[_currentLogID][4]),Boolean(_logArray[_currentLogID][5])]);
         setFactButtons(param2);
         _isNew = param3;
         if(param3)
         {
            _factPopup.newFact();
            LocalizationManager.translateId(_factPopup.factPopup.factTitle,11941);
            LocalizationManager.translateId(_factPopup.factPopup.doneButton.buttonText.buttonLabel,11939);
            _factPopup.factPopup.x_btn.visible = false;
            _soundMan.playByName(_soundNamePopUpSuccess);
         }
         else
         {
            _factPopup.factOn();
            LocalizationManager.translateId(_factPopup.factPopup.factTitle,_factData._facts[_currentFactID].title);
            LocalizationManager.translateId(_factPopup.factPopup.doneButton.buttonText.buttonLabel,11940);
            _factPopup.factPopup.x_btn.visible = true;
            _soundMan.playByName(_soundNameTileSelect);
            _soundMan.playByName(_soundNamePopUpEnter);
         }
      }
      
      private function setFactButtons(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         _currentFactID = TouchPoolCreature.getFactIndexFromType(TouchPoolCreature.getTypeFromLogIndex(_currentLogID)) * 5 + param1 - 1;
         _factPopup.factPopup.factSelect.x = _factPopup.factPopup["item_" + param1].x;
         _factPopup.factPopup.factSelect.y = _factPopup.factPopup["item_" + param1].y;
         _loc3_ = 1;
         while(_loc3_ < 6)
         {
            _loc2_ = _factPopup.factPopup["item_" + _loc3_];
            if(_logArray[_currentLogID][_loc3_] == 1)
            {
               if(_loc3_ == param1)
               {
                  _loc2_.gotoAndPlay("on");
                  _loc2_.removeEventListener("mouseOver",factButtonEvent);
                  _loc2_.removeEventListener("mouseOut",factButtonEvent);
                  _loc2_.removeEventListener("mouseDown",factButtonEvent);
                  _loc2_.removeEventListener("click",factButtonEvent);
               }
               else if(!_loc2_.hasEventListener("mouseOver"))
               {
                  _loc2_.addEventListener("mouseOver",factButtonEvent,false,0,true);
                  _loc2_.addEventListener("mouseOut",factButtonEvent,false,0,true);
                  _loc2_.addEventListener("mouseDown",factButtonEvent,false,0,true);
                  _loc2_.addEventListener("click",factButtonEvent,false,0,true);
               }
            }
            else
            {
               _loc2_.gotoAndPlay("off");
               _loc2_.removeEventListener("mouseOver",factButtonEvent);
               _loc2_.removeEventListener("mouseOut",factButtonEvent);
               _loc2_.removeEventListener("mouseDown",factButtonEvent);
               _loc2_.removeEventListener("click",factButtonEvent);
            }
            _loc3_++;
         }
         LocalizationManager.translateId(_factPopup.factPopup.result_fact,_factData._facts[_currentFactID].text);
         if(_factPopup.factPopup.result_pic.numChildren > 0)
         {
            _factPopup.factPopup.result_pic.removeChildAt(0);
         }
         _mediaObjectHelper.init(_factData._facts[_currentFactID].imageID,mediaObjectLoaded);
      }
      
      private function factButtonEvent(param1:MouseEvent) : void
      {
         if(param1.type == "mouseOver")
         {
            param1.currentTarget.gotoAndPlay("rollover");
            _soundMan.playByName(_soundNameInMenuRollover);
         }
         else if(param1.type == "mouseOut")
         {
            param1.currentTarget.gotoAndPlay("on");
         }
         else if(param1.type == "mouseDown")
         {
            param1.currentTarget.gotoAndPlay("pressed");
            _soundMan.playByName(_soundNameTileSelect);
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
            setFactButtons(param1.currentTarget.name.charAt(5));
         }
      }
      
      private function showTutKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               onExit_No();
         }
      }
      
      private function showTutorialDlg() : void
      {
         var _loc1_:MovieClip = showDlg("tierneyPool_tutorial",[{
            "name":"doneButton",
            "f":onExit_No
         },{
            "name":"x_btn",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",showTutKeyDown);
         _minimap.alpha = 0;
         Mouse.show();
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("tierneyPool_exit",[{
            "name":"yesButton",
            "f":onExit_Yes
         },{
            "name":"noButton",
            "f":onExit_No
         },{
            "name":"x_btn",
            "f":onExit_No
         }]);
         LocalizationManager.translateIdAndInsert(_loc1_.gemsEarned,11577,_gemsEarned.toString());
         _loc1_.x = 450;
         _loc1_.y = 275;
         Mouse.show();
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         exit();
      }
      
      private function onExit_No() : void
      {
         stage.removeEventListener("keyDown",showTutKeyDown);
         Mouse.hide();
         hideDlg();
      }
   }
}

