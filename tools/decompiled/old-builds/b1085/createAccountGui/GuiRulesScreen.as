package createAccountGui
{
   import com.sbi.popup.SBScreen;
   import com.sbi.popup.SBWizard;
   import createAccountFlow.CreateAccountGui;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import gui.GuiCheckBox;
   
   public class GuiRulesScreen extends SBScreen
   {
      
      private var _login:Object;
      
      private var _rulesScreen:MovieClip;
      
      private var _fullRulesTxt:TextField;
      
      private var _rulesVoBtn:MovieClip;
      
      private var _checkBox:GuiCheckBox;
      
      private var _registrationPanel:MovieClip;
      
      private var _isCheckBoxChecked:Boolean;
      
      public function GuiRulesScreen(param1:Object, param2:SBWizard)
      {
         this._login = param1;
         this._rulesScreen = param1.accountCreation.registrationPanel.rules_popup;
         this._registrationPanel = MovieClip(this._rulesScreen.parent);
         this._checkBox = new GuiCheckBox(this._rulesScreen.agree_box,this.onAgreeChecked);
         this._fullRulesTxt = this._rulesScreen.pp_txt;
         this._rulesVoBtn = this._rulesScreen.vo_btn;
         super(this._rulesScreen,param2);
      }
      
      public function init() : void
      {
         onEnterFromPrev = this.enterFromBoth;
         onEnterFromNext = this.enterFromBoth;
         onLeaveToPrev = this.leaveToBoth;
         onLeaveToNext = null;
         onPlay = this.onPlayBtn;
         updateScreen = this.updateScreenAssets;
         this._rulesVoBtn.stop();
         this._rulesVoBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.voBtnClickHandler,false,0,true);
         this._checkBox.init(this._rulesScreen.agree_txt);
         this._checkBox.checked = false;
      }
      
      override public function destroy() : void
      {
         this._rulesVoBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.voBtnClickHandler);
         this._checkBox.destroy();
         this._checkBox = null;
         super.destroy();
      }
      
      public function enterFromBoth() : void
      {
         CreateAccountGui.trackUserCreateAccountPageChange("Rules");
         CreateAccountGui.vo5Sound.play();
         if(CreateAccountGui.vo5Sound.sc)
         {
            CreateAccountGui.vo5Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopRulesVO,false,0,true);
            this._rulesVoBtn.play();
         }
         this._registrationPanel.gotoAndPlay("playAJRules");
         MovieClip(this._registrationPanel.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("playAJRules");
         MovieClip(this._registrationPanel.parent).next_btn.visible = false;
         MovieClip(this._registrationPanel.parent).play_btn.visible = this._checkBox.checked;
      }
      
      public function leaveToBoth() : Boolean
      {
         MovieClip(this._registrationPanel.parent).next_btn.visible = true;
         MovieClip(this._registrationPanel.parent).play_btn.visible = false;
         CreateAccountGui.vo5Sound.stop();
         this._rulesVoBtn.stop();
         this._rulesVoBtn.gotoAndStop(1);
         this._registrationPanel.gotoAndPlay("backAJRules");
         MovieClip(this._registrationPanel.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("backAJRules");
         return true;
      }
      
      public function updateScreenAssets(param1:Boolean = false) : void
      {
         this._rulesScreen = this._registrationPanel.rules_popup;
         this._checkBox = new GuiCheckBox(this._rulesScreen.agree_box,this.onAgreeChecked);
         this._checkBox.init(this._rulesScreen.agree_txt);
         this._checkBox.checked = this._isCheckBoxChecked;
         this._fullRulesTxt = this._rulesScreen.pp_txt;
         this._rulesVoBtn = this._rulesScreen.vo_btn;
         if(param1)
         {
            if(CreateAccountGui.vo5Sound.sc)
            {
               this._rulesVoBtn.play();
            }
            MovieClip(this._registrationPanel.parent).next_btn.visible = false;
            MovieClip(this._registrationPanel.parent).play_btn.visible = this._checkBox.checked;
         }
         else
         {
            MovieClip(this._registrationPanel.parent).play_btn.visible = false;
         }
      }
      
      public function onPlayBtn() : void
      {
         DarkenManager.showLoadingSpiral(true);
         CreateAccountGui.vo5Sound.stop();
         this._rulesVoBtn.stop();
         this._rulesVoBtn.gotoAndStop(1);
         this._login.createNewAccountSetup(CreateAccountGui.currEmailAddress(),CreateAccountGui.emailValidationCallback());
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         if(CreateAccountGui.vo5Sound.isPlaying)
         {
            CreateAccountGui.vo5Sound.stop();
            this._rulesVoBtn.stop();
            this._rulesVoBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo5Sound.play();
            if(CreateAccountGui.vo5Sound.sc)
            {
               CreateAccountGui.vo5Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopRulesVO,false,0,true);
               this._rulesVoBtn.play();
            }
         }
      }
      
      private function stopRulesVO(param1:Event) : void
      {
         if(CreateAccountGui)
         {
            CreateAccountGui.vo5Sound.stop();
         }
         this._rulesVoBtn.stop();
         this._rulesVoBtn.gotoAndStop(1);
      }
      
      private function onAgreeChecked() : void
      {
         MovieClip(this._registrationPanel.parent).play_btn.visible = this._isCheckBoxChecked = this._checkBox.checked;
      }
   }
}

