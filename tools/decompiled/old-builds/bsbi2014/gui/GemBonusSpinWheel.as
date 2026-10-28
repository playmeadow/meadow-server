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
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _mediaHelpers:Array;
      
      private var _guiLayer:DisplayLayer;
      
      private var _spinWheelMC:MovieClip;
      
      private var _gems:int;
      
      private var _multiplier:int;
      
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
      
      public function init(dailyGemVarValue:int, callback:Function) : void
      {
         this._guiLayer = GuiManager.guiLayer;
         this._callback = callback;
         this._mediaHelpers = [];
         this._wheelNumbers = [500,100,25,50,1,75,25,100,0,100,25,50,1,75,1,100];
         this._displayTimer = new Timer(375);
         this._displayTimer.addEventListener(TimerEvent.TIMER,this.onTimerComplete,false,0,true);
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.WHEEL_SPIN_MEDIA_ID,this.onMediaItemLoaded,dailyGemVarValue);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         this.removeGeneralEventListeners();
         DarkenManager.unDarken(this._spinWheelMC);
         if(Boolean(this._spinWheelMC) && Boolean(this._guiLayer) && this._spinWheelMC.parent == this._guiLayer)
         {
            this._guiLayer.removeChild(this._spinWheelMC);
         }
         this._guiLayer = null;
         this._mediaHelpers = null;
      }
      
      public function setupValuesAndSpin(value:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         this._gems = this.convertToGemsValue(value >> 24);
         this._multiplier = value >> 16 & 0xFF;
         this._spinEndPoint = this.calculateSpinEndPoint(this._gems);
         if(!this._isGift)
         {
            if(this._isDiamond)
            {
               gMainFrame.clientInfo.diamondCount += this._gems * this._multiplier;
            }
            else
            {
               gMainFrame.clientInfo.gemCount += this._gems * this._multiplier;
            }
         }
         for(var i:int = 1; i < 4; i++)
         {
            if(this._multiplier < i)
            {
               this._spinWheelMC["x" + i + "_on"].visible = false;
            }
            else
            {
               this._spinWheelMC["x" + i + "_on"].visible = true;
            }
         }
         if(this._isDiamond)
         {
            this._spinWheelMC.earnGifts(0);
            this._spinWheelMC.earnDiamonds(this._gems * this._multiplier);
         }
         else if(this._isGift)
         {
            this._spinWheelMC.earnDiamonds(0);
            this._spinWheelMC.earnGifts(1 * this._multiplier);
         }
         else
         {
            this._spinWheelMC.earnDiamonds(0);
            this._spinWheelMC.earnGifts(0);
         }
         this._spinWheelMC.spin(this._spinEndPoint,this.onSpinComplete);
         AJAudio.playDailySpinSpin();
      }
      
      private function onMediaItemLoaded(img:MovieClip) : void
      {
         var multiplier:int = 0;
         var i:int = 0;
         var currLoaderAppDomain:ApplicationDomain = null;
         if(Boolean(img))
         {
            SBTracker.push();
            SBTracker.trackPageview("game/play/popup/spinBonus");
            this._spinWheelMC = MovieClip(img.getChildAt(0));
            DarkenManager.showLoadingSpiral(false);
            if(!AJAudio.hasLoadedDailySpinSfx)
            {
               currLoaderAppDomain = img.loaderInfo.applicationDomain;
               AJAudio.loadSfx("DailySpinSpin",currLoaderAppDomain.getDefinition("DailySpinSpin") as Class,0.5);
               AJAudio.loadSfx("DailySpinBub1",currLoaderAppDomain.getDefinition("DailySpinBub1") as Class,0.5);
               AJAudio.loadSfx("DailySpinBub2",currLoaderAppDomain.getDefinition("DailySpinBub2") as Class,0.5);
               AJAudio.loadSfx("DailySpinBub3",currLoaderAppDomain.getDefinition("DailySpinBub3") as Class,0.5);
               AJAudio.hasLoadedDailySpinSfx = true;
            }
            this._spinWheelMC.spinTxtAnim.spinTxt.text = "";
            this._spinWheelMC.bonusTxtAnim.bonusTxt.text = "";
            this._spinWheelMC.totalTxtAnim.totalTxt.text = "";
            if(gMainFrame.clientInfo.jamaaDate - (img.passback & 0xFFFF) == 1)
            {
               multiplier = Math.min((img.passback >> 16 & 0xFF) + 1,3);
            }
            else
            {
               multiplier = 1;
            }
            for(i = 1; i < 4; i++)
            {
               if(multiplier < i)
               {
                  this._spinWheelMC["x" + i + "_on"].visible = false;
               }
            }
            this._spinWheelMC.x = MainFrame.VIEW_WIDTH * 0.5;
            this._spinWheelMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._guiLayer.addChild(this._spinWheelMC);
            DarkenManager.darken(this._spinWheelMC);
            this._mediaHelpers = [];
            this.addGeneralEventListeners();
         }
      }
      
      private function convertToGemsValue(value:int) : int
      {
         if(value < 4)
         {
            return (value + 1) * 25;
         }
         if(value == 4)
         {
            return 500;
         }
         if(value == 5)
         {
            this._isDiamond = true;
            return 1;
         }
         if(value == 6)
         {
            this._isGift = true;
            return 0;
         }
         return 25;
      }
      
      private function calculateSpinEndPoint(value:int) : int
      {
         var randomIndex:Number = Math.random();
         randomIndex = int(this._wheelNumbers.length * randomIndex);
         while(this._wheelNumbers[randomIndex] != value)
         {
            if(randomIndex + 1 >= this._wheelNumbers.length)
            {
               randomIndex = 0;
            }
            else
            {
               randomIndex++;
            }
         }
         return randomIndex;
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onClose(evt:MouseEvent = null) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(this._gems > 0)
         {
            GuiManager.startGemsFlash();
            SBTracker.trackPageview("game/play/popup/spinBonus/close/didSpin",-1,SBTracker.TYPE_EVENT);
         }
         else
         {
            SBTracker.trackPageview("game/play/popup/spinBonus/close/noSpin",-1,SBTracker.TYPE_EVENT);
         }
         SBTracker.pop();
         if(this._callback != null)
         {
            this._callback();
            this._callback = null;
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onSpinBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.trackPageview("game/play/popup/spinBonus/spin",-1,SBTracker.TYPE_EVENT);
         this._spinWheelMC.spinBtn.mouse.visible = false;
         this._spinWheelMC.spinBtn.down.visible = true;
         this._spinWheelMC.spinBtn.down.gotoAndStop(3);
         this._spinWheelMC.spinBtn.mouseEnabled = false;
         this._spinWheelMC.spinBtn.mouseChildren = false;
         this._spinWheelMC.spinBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSpinBtn);
         this._spinWheelMC.bx.mouse.visible = false;
         this._spinWheelMC.bx.down.visible = true;
         this._spinWheelMC.bx.down.gotoAndStop(3);
         this._spinWheelMC.bx.mouseEnabled = false;
         this._spinWheelMC.bx.mouseChildren = false;
         this._spinWheelMC.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_DAILY_GEM_BONUS,1);
         DarkenManager.showLoadingSpiral(true);
      }
      
      private function onSpinComplete() : void
      {
         this._displayTimer.start();
      }
      
      private function onTimerComplete(te:TimerEvent) : void
      {
         if(this._spinWheelMC.spinTxtAnim.spinTxt.text == "")
         {
            this._spinWheelMC.spinTxtAnim.spinTxt.text = this._gems;
            this._spinWheelMC.popupObject(0);
            AJAudio.playDailySpinBub1();
         }
         else if(this._spinWheelMC.bonusTxtAnim.bonusTxt.text == "")
         {
            this._spinWheelMC.bonusTxtAnim.bonusTxt.text = this._multiplier;
            this._displayTimer.delay = 750;
            this._spinWheelMC.popupObject(1);
            AJAudio.playDailySpinBub2();
         }
         else if(this._spinWheelMC.totalTxtAnim.totalTxt.text == "")
         {
            this._spinWheelMC.totalTxtAnim.totalTxt.text = Utility.convertNumberToString(this._gems * this._multiplier);
            this._displayTimer.delay = 3000;
            this._spinWheelMC.popupObject(2);
            AJAudio.playDailySpinBub3();
            this._spinWheelMC.bx.mouse.visible = true;
            this._spinWheelMC.bx.down.visible = false;
            this._spinWheelMC.bx.down.gotoAndStop(3);
            this._spinWheelMC.bx.mouseEnabled = true;
            this._spinWheelMC.bx.mouseChildren = true;
            this._spinWheelMC.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
            if(this._isGift)
            {
               GuiManager.initMessagePopups(true);
            }
         }
         else
         {
            this._displayTimer.reset();
            this._displayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
            if(!this._isGift)
            {
               this.onClose();
            }
         }
      }
      
      private function addGeneralEventListeners() : void
      {
         this._spinWheelMC.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._spinWheelMC.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._spinWheelMC.spinBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSpinBtn,false,0,true);
      }
      
      private function removeGeneralEventListeners() : void
      {
         this._spinWheelMC.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._spinWheelMC.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._spinWheelMC.spinBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSpinBtn);
      }
   }
}

