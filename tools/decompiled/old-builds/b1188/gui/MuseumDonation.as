package gui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class MuseumDonation
   {
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _myGemCount:int;
      
      private var _donationAmounts:Array;
      
      private var _donationIndex:int;
      
      private var _radioBtn1:MovieClip;
      
      private var _radioBtn2:MovieClip;
      
      private var _radioBtn3:MovieClip;
      
      private var _lastChosenString:String;
      
      public function MuseumDonation()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         this._guiLayer = GuiManager.guiLayer;
         DarkenManager.showLoadingSpiral(true);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(1546,this.onMediaLoaded);
         this._closeCallback = param1;
         this._donationAmounts = [10,25,50,100,250,500,1000,2500,5000];
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         if(this._mediaHelper)
         {
            this._mediaHelper.destroy();
            this._mediaHelper = null;
         }
         this._closeCallback = null;
         DarkenManager.unDarken(this._popup);
         this._guiLayer.removeChild(this._popup);
         this._popup = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._popup = MovieClip(param1.getChildAt(0));
            this._popup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._popup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._myGemCount = gMainFrame.clientInfo.gemCount;
            this._popup.donateRedBtn.visible = false;
            this._radioBtn1 = this._popup.radioBtn1;
            this._radioBtn2 = this._popup.radioBtn2;
            this._radioBtn3 = this._popup.radioBtn3;
            this._popup.donateBtn.activateGrayState(true);
            this._radioBtn1._circle.visible = false;
            this._radioBtn2._circle.visible = false;
            this._radioBtn3._circle.visible = false;
            this.addEventListeners();
            DarkenManager.showLoadingSpiral(false);
            this._guiLayer.addChild(this._popup);
            DarkenManager.darken(this._popup);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onUpBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(this._popup.donationAmountTxt.text);
         if(this._donationIndex < this._donationAmounts.length - 1)
         {
            ++this._donationIndex;
            _loc2_ = int(this._donationAmounts[this._donationIndex]);
         }
         if(_loc2_ > this._myGemCount)
         {
            this._popup.donateRedBtn.visible = true;
         }
         else
         {
            this._popup.donateRedBtn.visible = false;
         }
         this._popup.donationAmountTxt.text = _loc2_;
      }
      
      private function onDownBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(this._popup.donationAmountTxt.text);
         if(this._donationIndex > 0)
         {
            --this._donationIndex;
            _loc2_ = int(this._donationAmounts[this._donationIndex]);
         }
         if(_loc2_ > this._myGemCount)
         {
            this._popup.donateRedBtn.visible = true;
         }
         else
         {
            this._popup.donateRedBtn.visible = false;
         }
         this._popup.donationAmountTxt.text = _loc2_;
      }
      
      private function onDonateBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._myGemCount < this._popup.donationAmountTxt.text)
         {
            SBTracker.trackPageview("/game/play/popup/donate/donation/notEnoughGems/#" + this._myGemCount,-1,SBTracker.TYPE_EVENT);
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14770));
         }
         else
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14771,Utility.convertNumberToString(this._popup.donationAmountTxt.text)),true,this.onConfirm);
         }
      }
      
      private function onConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            ItemXtCommManager.requestDonateGems(this._popup.donationAmountTxt.text,this.onDonateDone);
            FeedbackManager.setupRequest(new UserImageUpload(),this._lastChosenString + "|" + this._popup.donationAmountTxt.text,FeedbackManager.TYPE_DONATION,0,this.onSuccess,this.onError);
         }
      }
      
      private function onError(param1:Event) : void
      {
      }
      
      private function onSuccess(param1:Event) : void
      {
      }
      
      private function onDonateDone(param1:Boolean) : void
      {
         if(param1)
         {
            this._popup.visible = false;
            SBTracker.trackPageview("/game/play/popup/donate/donation/#" + this._popup.donationAmountTxt.text);
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14772),true,this.onDonationThanks);
         }
         else
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14773));
         }
      }
      
      private function onDonationThanks(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         this.onClose(null);
      }
      
      private function onRadioBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._radioBtn1._circle.visible = false;
         this._radioBtn2._circle.visible = false;
         this._radioBtn3._circle.visible = false;
         var _loc2_:Object = param1.currentTarget;
         _loc2_._circle.visible = !_loc2_._circle.visible;
         if(_loc2_._circle.visible)
         {
            this._lastChosenString = this._popup["selectionLabelTxt" + _loc2_.name.substr(8)].text;
         }
         if(this._popup.donateBtn.isGray)
         {
            this._popup.donateBtn.activateGrayState(false);
         }
      }
      
      private function onPlayMovBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         GenericListGuiManager.genericListVolumeClicked(param1.currentTarget.name.split("_")[1],{"shouldRepeat":false});
      }
      
      private function addEventListeners() : void
      {
         this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._popup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._popup.upBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onUpBtn,false,0,true);
         this._popup.downBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDownBtn,false,0,true);
         this._popup.donateBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDonateBtn,false,0,true);
         this._popup.donateRedBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDonateBtn,false,0,true);
         this._popup.radioBtn1.addEventListener(MouseEvent.MOUSE_DOWN,this.onRadioBtn,false,0,true);
         this._popup.radioBtn2.addEventListener(MouseEvent.MOUSE_DOWN,this.onRadioBtn,false,0,true);
         this._popup.radioBtn3.addEventListener(MouseEvent.MOUSE_DOWN,this.onRadioBtn,false,0,true);
         this._popup.playMovBtn1_131.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayMovBtn,false,0,true);
         this._popup.playMovBtn2_130.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayMovBtn,false,0,true);
         this._popup.playMovBtn3_129.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayMovBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._popup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._popup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._popup.upBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onUpBtn);
         this._popup.downBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDownBtn);
         this._popup.donateBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDonateBtn);
         this._popup.donateRedBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDonateBtn);
         this._popup.radioBtn1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRadioBtn);
         this._popup.radioBtn2.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRadioBtn);
         this._popup.radioBtn3.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRadioBtn);
         this._popup.playMovBtn1_131.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayMovBtn);
         this._popup.playMovBtn2_130.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayMovBtn);
         this._popup.playMovBtn3_129.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayMovBtn);
      }
   }
}

