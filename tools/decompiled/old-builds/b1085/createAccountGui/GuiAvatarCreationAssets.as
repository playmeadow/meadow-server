package createAccountGui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class GuiAvatarCreationAssets extends Sprite
   {
      
      public var creationWiz:GuiCreateWizard;
      
      public var notifyPopup:MovieClip;
      
      public var tipsPopup:MovieClip;
      
      private var nextBtn:MovieClip;
      
      private var backBtn:MovieClip;
      
      private var playBtn:MovieClip;
      
      private var buyBtnRed:MovieClip;
      
      private var buyBtnGreen:MovieClip;
      
      private var closeBtn:MovieClip;
      
      private var _avatarAssets:MovieClip;
      
      public function GuiAvatarCreationAssets(param1:MovieClip, param2:Boolean = false)
      {
         var _loc3_:TextField = null;
         super();
         this._avatarAssets = param1;
         addChild(param1);
         this._avatarAssets.addEventListener("Localization",this.onFrameCompleteEvent,false,0,true);
         this.notifyPopup = param1.oopsPopup;
         this.notifyPopup.notifyTxt = param1.oopsPopup.oops_txt;
         this.notifyPopup.titleTxt = param1.oopsPopup.oops_title_txt;
         this.notifyPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.notifyPopupBxHandler,false,0,true);
         this.notifyPopup.visible = false;
         if(!param2)
         {
            this.tipsPopup = param1.tipsPopup;
            this.tipsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.tipsPopupBxHandler,false,0,true);
            _loc3_ = this.tipsPopup.tips_pp_txt;
            _loc3_.htmlText = _loc3_.text.replace("Privacy Policy","<a href=\'http://www.animaljam.com/privacy\' target=\'_blank\'><u>Privacy Policy</u></a>");
            this.playBtn = param1.play_btn;
            this.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
         }
         else
         {
            this.buyBtnRed = param1.buy_btn_red;
            this.buyBtnRed.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBtn,false,0,true);
            this.buyBtnGreen = param1.buy_btn_green;
            this.buyBtnGreen.addEventListener(MouseEvent.MOUSE_DOWN,this.onBuyBtn,false,0,true);
            this.closeBtn = param1.bx;
            this.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         this.nextBtn = param1.next_btn;
         this.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onNextBtn,false,0,true);
         this.backBtn = param1.back_btn;
         this.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBackBtn,false,0,true);
         this._avatarAssets.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
      }
      
      public function init(param1:Object, param2:Boolean) : void
      {
         this.creationWiz = new GuiCreateWizard(param1);
         this.creationWiz.init(this._avatarAssets,false,1,null,true,false,param2);
      }
      
      public function destroy() : void
      {
         this.creationWiz.destroy();
         this.creationWiz = null;
         removeChild(this._avatarAssets);
         this._avatarAssets = null;
      }
      
      public function get currAvatar() : MovieClip
      {
         return this.creationWiz.chooseAnimalScreen.currAvatar;
      }
      
      public function get currBG() : String
      {
         return this.creationWiz.chooseAnimalScreen.currBG;
      }
      
      public function get currType() : int
      {
         return this.creationWiz.chooseAnimalScreen.currType;
      }
      
      public function get hasEnoughGems() : Boolean
      {
         return this.creationWiz.chooseAnimalScreen.hasEnoughGems;
      }
      
      public function get currAvatarCost() : int
      {
         return this.creationWiz.chooseAnimalScreen.currAvatarCost;
      }
      
      public function get currAvatarName() : String
      {
         return this.creationWiz.chooseAnimalScreen.currAvatarName;
      }
      
      public function get isCreatingWithoutChoosing() : Boolean
      {
         return this.creationWiz.chooseAnimalScreen.isCreatingWithoutChoosing;
      }
      
      public function get currencyType() : int
      {
         return this.creationWiz.chooseAnimalScreen.currencyType;
      }
      
      public function get currEmailAddress() : String
      {
         return this.creationWiz.emailScreen.currEmail;
      }
      
      public function get emailValidationCallback() : Function
      {
         return this.creationWiz.emailScreen.emailValidCallback;
      }
      
      public function get currEmailSoFar() : String
      {
         return this.creationWiz.emailScreen.currEmail;
      }
      
      public function reloadChooser(param1:Boolean, param2:Boolean, param3:int = -1, param4:Boolean = false, param5:int = 0, param6:int = -1) : void
      {
         this.creationWiz.step = 1;
         this.creationWiz.chooseAnimalScreen.reload(param1,param2,param3,param4,param5,param6);
      }
      
      public function destroyReloadedItems() : void
      {
         this.creationWiz.chooseAnimalScreen.destroyReloadedItems();
      }
      
      public function loadNameLists() : void
      {
         this.creationWiz.createANameScreen.loadNameLists();
      }
      
      private function onFrameCompleteEvent(param1:Event = null) : void
      {
         this.creationWiz.updateCurrScreen();
      }
      
      private function notifyPopupBxHandler(param1:MouseEvent) : void
      {
         this.notifyPopup.visible = false;
      }
      
      private function tipsPopupBxHandler(param1:MouseEvent) : void
      {
         this.tipsPopup.visible = false;
      }
      
      private function onNextBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.next();
      }
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.prev();
      }
      
      private function onPlayBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.onPlay();
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.onPlay();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.creationWiz.onClose();
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

