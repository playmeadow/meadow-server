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
      
      public function init(closeCallback:Function) : void
      {
         this._guiLayer = GuiManager.guiLayer;
         DarkenManager.showLoadingSpiral(true);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(1546,this.onMediaLoaded);
         this._closeCallback = closeCallback;
         this._donationAmounts = [10,25,50,100,250,500,1000,2500,5000];
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         if(Boolean(this._mediaHelper))
         {
            this._mediaHelper.destroy();
            this._mediaHelper = null;
         }
         this._closeCallback = null;
         DarkenManager.unDarken(this._popup);
         this._guiLayer.removeChild(this._popup);
         this._popup = null;
      }
      
      private function onMediaLoaded(mc:MovieClip) : void
      {
         if(Boolean(mc))
         {
            this._popup = MovieClip(mc.getChildAt(0));
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
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
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
      
      private function onUpBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var currAmount:int = int(this._popup.donationAmountTxt.text);
         if(this._donationIndex < this._donationAmounts.length - 1)
         {
            ++this._donationIndex;
            currAmount = int(this._donationAmounts[this._donationIndex]);
         }
         if(currAmount > this._myGemCount)
         {
            this._popup.donateRedBtn.visible = true;
         }
         else
         {
            this._popup.donateRedBtn.visible = false;
         }
         this._popup.donationAmountTxt.text = currAmount;
      }
      
      private function onDownBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var currAmount:int = int(this._popup.donationAmountTxt.text);
         if(this._donationIndex > 0)
         {
            --this._donationIndex;
            currAmount = int(this._donationAmounts[this._donationIndex]);
         }
         if(currAmount > this._myGemCount)
         {
            this._popup.donateRedBtn.visible = true;
         }
         else
         {
            this._popup.donateRedBtn.visible = false;
         }
         this._popup.donationAmountTxt.text = currAmount;
      }
      
      private function onDonateBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
      
      private function onConfirm(o:Object) : void
      {
         if(Boolean(o.status))
         {
            ItemXtCommManager.requestDonateGems(this._popup.donationAmountTxt.text,this.onDonateDone);
            FeedbackManager.setupRequest(new UserImageUpload(),this._lastChosenString + "|" + this._popup.donationAmountTxt.text,FeedbackManager.TYPE_DONATION,0,this.onSuccess,this.onError);
         }
      }
      
      private function onError(evt:Event) : void
      {
      }
      
      private function onSuccess(evt:Event) : void
      {
      }
      
      private function onDonateDone(status:Boolean) : void
      {
         if(status)
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
      
      private function onDonationThanks(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBOkPopup.destroyInParentChain(evt.target.parent);
         this.onClose(null);
      }
      
      private function onRadioBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._radioBtn1._circle.visible = false;
         this._radioBtn2._circle.visible = false;
         this._radioBtn3._circle.visible = false;
         var currObj:Object = evt.currentTarget;
         currObj._circle.visible = !currObj._circle.visible;
         if(Boolean(currObj._circle.visible))
         {
            this._lastChosenString = this._popup["selectionLabelTxt" + currObj.name.substr(8)].text;
         }
         if(Boolean(this._popup.donateBtn.isGray))
         {
            this._popup.donateBtn.activateGrayState(false);
         }
      }
      
      private function onPlayMovBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         GenericListGuiManager.genericListVolumeClicked(evt.currentTarget.name.split("_")[1],{"shouldRepeat":false});
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

