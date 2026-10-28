package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.system.ApplicationDomain;
   import flash.utils.Timer;
   import loader.MediaHelper;
   
   public class GemBonusSpinWheel
   {
      
      private const WHEEL_SPIN_MEDIA_ID:int = 1025;
      
      private const WHEEL_SPIN_MEDIA_ID_MEMBER:int = 5533;
      
      // the daily spin in Earth Crystals: the members' wheel, for everyone,
      // with its diamonds drawn as crystals (the server's lib/crystals.js
      // SPIN_WHEEL_MEDIA, swf/crystal-wheel.swf)
      private const WHEEL_SPIN_MEDIA_ID_CRYSTALS:int = 990001;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _mediaHelpers:Array;
      
      private var _guiLayer:DisplayLayer;
      
      private var _spinWheelMC:MovieClip;
      
      private var _gems:int;
      
      private var _multiplier:uint;
      
      private var _spinEndPoint:int;
      
      private var _wheelNumbers:Array;
      
      private var _displayTimer:Timer;
      
      private var _callback:Function;
      
      private var _isDiamond:Boolean;
      
      private var _isGift:Boolean;
      
      public function GemBonusSpinWheel()
      {
         super();
      }
      
      public function init(param1:int, param2:Function) : void
      {
         _guiLayer = GuiManager.guiLayer;
         _callback = param2;
         _mediaHelpers = [];
         // its gift wedges (0) are double ones here, drawn so (the server's
         // tools/make-crystal-art.py): no gifts, two crystals
         _wheelNumbers = [2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1];
         _displayTimer = new Timer(375);
         _displayTimer.addEventListener("timer",onTimerComplete,false,0,true);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(WHEEL_SPIN_MEDIA_ID_CRYSTALS,onMediaItemLoaded,param1);
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         removeGeneralEventListeners();
         DarkenManager.unDarken(_spinWheelMC);
         if(_spinWheelMC && _guiLayer && _spinWheelMC.parent == _guiLayer)
         {
            _guiLayer.removeChild(_spinWheelMC);
         }
         _guiLayer = null;
         _mediaHelpers = null;
      }
      
      public function setupValuesAndSpin(param1:uint) : void
      {
         var _loc2_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         _gems = convertToGemsValue(param1 >> 24);
         _multiplier = param1 >> 16 & 0xFF;
         _spinEndPoint = calculateSpinEndPoint(_gems);
         // what it won is the server's to add (Earth Crystals, its "cu" once
         // this has the result): the game added it here, as diamonds.
         _loc2_ = 1;
         while(_loc2_ < 4)
         {
            if(_multiplier < _loc2_)
            {
               _spinWheelMC["x" + _loc2_ + "_on"].visible = false;
            }
            else
            {
               _spinWheelMC["x" + _loc2_ + "_on"].visible = true;
            }
            _loc2_++;
         }
         if(_isDiamond)
         {
            if(_gems > 1)
            {
               _spinWheelMC.spinTxtAnim.diamond.gotoAndStop(_gems);
            }
            _spinWheelMC.earnGifts(0);
            _spinWheelMC.earnDiamonds(_gems * _multiplier);
         }
         else if(_isGift)
         {
            _spinWheelMC.earnDiamonds(0);
            _spinWheelMC.earnGifts(1 * _multiplier);
         }
         else
         {
            _spinWheelMC.earnDiamonds(0);
            _spinWheelMC.earnGifts(0);
         }
         _spinWheelMC.spin(_spinEndPoint,onSpinComplete);
         AJAudio.playDailySpinSpin();
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc3_:ApplicationDomain = null;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         if(param1)
         {
            SBTracker.push();
            SBTracker.trackPageview("game/play/popup/spinBonus");
            _spinWheelMC = MovieClip(param1.getChildAt(0));
            DarkenManager.showLoadingSpiral(false);
            if(!AJAudio.hasLoadedDailySpinSfx)
            {
               _loc3_ = param1.loaderInfo.applicationDomain;
               AJAudio.loadSfx("DailySpinSpin",_loc3_.getDefinition("DailySpinSpin") as Class,0.5);
               AJAudio.loadSfx("DailySpinBub1",_loc3_.getDefinition("DailySpinBub1") as Class,0.5);
               AJAudio.loadSfx("DailySpinBub2",_loc3_.getDefinition("DailySpinBub2") as Class,0.5);
               AJAudio.loadSfx("DailySpinBub3",_loc3_.getDefinition("DailySpinBub3") as Class,0.5);
               AJAudio.hasLoadedDailySpinSfx = true;
            }
            _spinWheelMC.spinTxtAnim.spinTxt.text = "";
            _spinWheelMC.bonusTxtAnim.bonusTxt.text = "";
            _spinWheelMC.totalTxtAnim.totalTxt.text = "";
            if(gMainFrame.clientInfo.jamaaDate - (param1.passback & 0xFFFF) == 1)
            {
               _loc2_ = Math.min((param1.passback >> 16 & 0xFF) + 1,3);
            }
            else
            {
               _loc2_ = 1;
            }
            _loc4_ = 1;
            while(_loc4_ < 4)
            {
               if(_loc2_ < _loc4_)
               {
                  _spinWheelMC["x" + _loc4_ + "_on"].visible = false;
               }
               _loc4_++;
            }
            // its "?" told of the members' diamond spin
            if(_spinWheelMC.memberSpinBtn)
            {
               _spinWheelMC.memberSpinBtn.visible = false;
            }
            _spinWheelMC.x = 900 * 0.5;
            _spinWheelMC.y = 550 * 0.5;
            _guiLayer.addChild(_spinWheelMC);
            DarkenManager.darken(_spinWheelMC);
            _mediaHelpers = [];
            addGeneralEventListeners();
         }
      }
      
      private function convertToGemsValue(param1:int) : int
      {
         if(param1 < 4)
         {
            return (param1 + 1) * 25;
         }
         if(param1 == 4)
         {
            return 500;
         }
         if(param1 == 5)
         {
            _isDiamond = true;
            return 1;
         }
         if(param1 == 6)
         {
            _isGift = true;
            return 0;
         }
         if(param1 == 7)
         {
            _isDiamond = true;
            return 2;
         }
         return 25;
      }
      
      // a slot showing what was won, from a random one onwards, round the
      // wheel. (the decompiled loop went back to slot 1 for good, which held
      // the game still on a win slot 1 does not show.)
      private function calculateSpinEndPoint(param1:int) : int
      {
         var _loc2_:int = int(_wheelNumbers.length * Math.random());
         var _loc3_:int = 0;
         while(_loc3_ < _wheelNumbers.length)
         {
            if(_wheelNumbers[(_loc2_ + _loc3_) % _wheelNumbers.length] == param1)
            {
               return (_loc2_ + _loc3_) % _wheelNumbers.length;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_gems > 0)
         {
            SBTracker.trackPageview("game/play/popup/spinBonus/close/didSpin",-1,1);
         }
         else
         {
            SBTracker.trackPageview("game/play/popup/spinBonus/close/noSpin",-1,1);
         }
         SBTracker.pop();
         if(_callback != null)
         {
            _callback();
            _callback = null;
         }
         else
         {
            destroy();
         }
      }
      
      private function onSpinBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/spinBonus/spin",-1,1);
         _spinWheelMC.spinBtn.mouse.visible = false;
         _spinWheelMC.spinBtn.down.visible = true;
         _spinWheelMC.spinBtn.down.gotoAndStop(3);
         _spinWheelMC.spinBtn.mouseEnabled = false;
         _spinWheelMC.spinBtn.mouseChildren = false;
         _spinWheelMC.spinBtn.removeEventListener("mouseDown",onSpinBtn);
         _spinWheelMC.bx.mouse.visible = false;
         _spinWheelMC.bx.down.visible = true;
         _spinWheelMC.bx.down.gotoAndStop(3);
         _spinWheelMC.bx.mouseEnabled = false;
         _spinWheelMC.bx.mouseChildren = false;
         _spinWheelMC.bx.removeEventListener("mouseDown",onClose);
         AchievementXtCommManager.requestSetUserVar(214,1);
         DarkenManager.showLoadingSpiral(true);
      }
      
      private function onSpinComplete() : void
      {
         _displayTimer.start();
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         if(_spinWheelMC.spinTxtAnim.spinTxt.text == "")
         {
            _spinWheelMC.spinTxtAnim.spinTxt.text = _gems;
            _spinWheelMC.popupObject(0);
            AJAudio.playDailySpinBub1();
         }
         else if(_spinWheelMC.bonusTxtAnim.bonusTxt.text == "")
         {
            _spinWheelMC.bonusTxtAnim.bonusTxt.text = _multiplier;
            _displayTimer.delay = 750;
            _spinWheelMC.popupObject(1);
            AJAudio.playDailySpinBub2();
         }
         else if(_spinWheelMC.totalTxtAnim.totalTxt.text == "")
         {
            _spinWheelMC.totalTxtAnim.totalTxt.text = Utility.convertNumberToString(_gems * _multiplier);
            _displayTimer.delay = 3000;
            _spinWheelMC.popupObject(2);
            AJAudio.playDailySpinBub3();
            _spinWheelMC.bx.mouse.visible = true;
            _spinWheelMC.bx.down.visible = false;
            _spinWheelMC.bx.down.gotoAndStop(3);
            _spinWheelMC.bx.mouseEnabled = true;
            _spinWheelMC.bx.mouseChildren = true;
            _spinWheelMC.bx.addEventListener("mouseDown",onClose,false,0,true);
            if(_isGift)
            {
               GuiManager.initMessagePopups(true);
            }
         }
         else
         {
            _displayTimer.reset();
            _displayTimer.removeEventListener("timerComplete",onTimerComplete);
            if(!_isGift)
            {
               onClose();
            }
         }
      }
      
      private function onMemberSpinInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openDailySpinInfoPopup();
      }
      
      private function addGeneralEventListeners() : void
      {
         _spinWheelMC.addEventListener("mouseDown",onPopup,false,0,true);
         _spinWheelMC.bx.addEventListener("mouseDown",onClose,false,0,true);
         _spinWheelMC.spinBtn.addEventListener("mouseDown",onSpinBtn,false,0,true);
         if(_spinWheelMC.memberSpinBtn)
         {
            _spinWheelMC.memberSpinBtn.addEventListener("mouseDown",onMemberSpinInfoBtn,false,0,true);
         }
      }
      
      private function removeGeneralEventListeners() : void
      {
         _spinWheelMC.removeEventListener("mouseDown",onPopup);
         _spinWheelMC.bx.removeEventListener("mouseDown",onClose);
         _spinWheelMC.spinBtn.removeEventListener("mouseDown",onSpinBtn);
         if(_spinWheelMC.memberSpinBtn)
         {
            _spinWheelMC.memberSpinBtn.removeEventListener("mouseDown",onMemberSpinInfoBtn);
         }
      }
   }
}

