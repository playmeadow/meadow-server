package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiRadioButtonGroup;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public dynamic class SBPollPopup
   {
      
      public static const POLL_POPUP_MEDIA_ID:int = 369;
      
      public static const POLL_POPUP_WOOD_MEDIA_ID:int = 3931;
      
      private static const POLL_TY_POPUP_MEDIA_ID:int = 370;
      
      private var _popupLayer:DisplayObjectContainer;
      
      private var _tab:MovieClip;
      
      private var _pollDef:Object;
      
      private var _onVoteCallback:Function;
      
      private var _onDoneCallback:Function;
      
      private var _pollPopup:MovieClip;
      
      private var _pollMediaHelper:MediaHelper;
      
      private var _thankYouPopup:SBStandardTitlePopup;
      
      private var _numOptions:int;
      
      private var _randomizeOrder:Boolean;
      
      private var _randOptionLookup:Array;
      
      private var _answerSection:MovieClip;
      
      private var _optionsGroup:GuiRadioButtonGroup;
      
      private var _pollMediaId:int;
      
      public function SBPollPopup()
      {
         super();
      }
      
      public function init(param1:DisplayObjectContainer, param2:MovieClip, param3:int, param4:Function, param5:Function, param6:Boolean) : void
      {
         this._popupLayer = param1;
         this._tab = param2;
         this._onVoteCallback = param4;
         this._onDoneCallback = param5;
         this._randomizeOrder = param6;
         this._pollMediaId = param3;
         this._pollDef = this._tab.def;
         this._pollMediaHelper = new MediaHelper();
         this._pollMediaHelper.init(param3,this.onMediaLoaded,true);
         this._randOptionLookup = [0,1,2,3,4];
         this._thankYouPopup = new SBStandardTitlePopup(this._popupLayer,LocalizationManager.translateIdOnly(14680),null,370,this._onDoneCallback,false);
      }
      
      public function destroy() : void
      {
         this._pollPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtnDown);
         this._pollPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown);
         this._pollPopup = null;
         this._thankYouPopup.destroy();
         this._thankYouPopup = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._pollMediaHelper.destroy();
            this._pollMediaHelper = null;
            this._pollPopup = MovieClip(param1.getChildAt(0));
            this.setUpPollPopup();
         }
      }
      
      private function setUpPollPopup() : void
      {
         this._pollPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtnDown,false,0,true);
         this._pollPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
         var _loc1_:String = this._pollDef.poll;
         var _loc2_:int = _loc1_.indexOf("|");
         this._pollPopup.bodyTxt.text = _loc1_.substring(0,_loc2_);
         var _loc3_:Array = _loc1_.substring(_loc2_ + 1,_loc1_.length).split("|");
         if(this._randomizeOrder)
         {
            _loc3_ = this.shuffleArray(_loc3_);
         }
         this._numOptions = _loc3_.length;
         this._pollPopup.titleTxt.text = this._pollDef.title;
         if(this._numOptions == 2)
         {
            this._answerSection = this._pollPopup.answer2;
            this._pollPopup.answer2.visible = true;
            this._pollPopup.answer3.visible = false;
            this._pollPopup.answer4.visible = false;
            this._pollPopup.answer5.visible = false;
         }
         else if(this._numOptions == 3)
         {
            this._answerSection = this._pollPopup.answer3;
            this._pollPopup.answer2.visible = false;
            this._pollPopup.answer3.visible = true;
            this._pollPopup.answer4.visible = false;
            this._pollPopup.answer5.visible = false;
         }
         else if(this._numOptions == 4)
         {
            this._answerSection = this._pollPopup.answer4;
            this._pollPopup.answer2.visible = false;
            this._pollPopup.answer3.visible = false;
            this._pollPopup.answer4.visible = true;
            this._pollPopup.answer5.visible = false;
         }
         else
         {
            this._answerSection = this._pollPopup.answer5;
            if(this._pollPopup.answer2)
            {
               this._pollPopup.answer2.visible = false;
            }
            if(this._pollPopup.answer3)
            {
               this._pollPopup.answer3.visible = false;
            }
            if(this._pollPopup.answer4)
            {
               this._pollPopup.answer4.visible = false;
            }
            this._pollPopup.answer5.visible = true;
         }
         this._optionsGroup = new GuiRadioButtonGroup(this._answerSection.options);
         if(this._answerSection.voteBtn)
         {
            this._answerSection.voteBtn.activateGrayState(true);
            this._answerSection.voteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onVoteBtnDown,false,0,true);
         }
         var _loc4_:int = 1;
         while(_loc4_ < this._numOptions + 1)
         {
            this._answerSection["answer" + _loc4_ + "Txt"].text = _loc3_[_loc4_ - 1];
            this._answerSection.options["option" + _loc4_].addEventListener(MouseEvent.CLICK,this.onOptionSelected,false,0,true);
            _loc4_++;
         }
         DarkenManager.showLoadingSpiral(false);
         this.open(this._pollPopup);
      }
      
      private function shuffleArray(param1:Array) : Array
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = int(param1.length);
         var _loc3_:Array = param1.slice();
         while(_loc5_ < _loc2_)
         {
            _loc4_ = _loc3_[_loc5_];
            _loc6_ = Math.floor(Math.random() * _loc2_);
            if(_loc5_ != _loc6_)
            {
               _loc3_[_loc5_] = _loc3_[_loc6_];
               _loc3_[_loc6_] = _loc4_;
               _loc7_ = int(this._randOptionLookup[_loc5_]);
               this._randOptionLookup[_loc5_] = this._randOptionLookup[_loc6_];
               this._randOptionLookup[_loc6_] = _loc7_;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      private function open(param1:MovieClip) : void
      {
         this._popupLayer.addChild(param1);
         param1.x = MainFrame.VIEW_WIDTH * 0.5;
         param1.y = MainFrame.VIEW_HEIGHT * 0.5;
         DarkenManager.darken(param1);
         param1.visible = true;
      }
      
      private function close(param1:MovieClip) : void
      {
         param1.visible = false;
         DarkenManager.unDarken(param1);
         this._popupLayer.removeChild(param1);
      }
      
      private function onVoteBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            this.processVote();
         }
      }
      
      private function processVote() : void
      {
         if(this._onVoteCallback != null)
         {
            this._onVoteCallback(this._tab,this._randOptionLookup[this._optionsGroup.selected] + 1);
         }
         if(this._pollMediaId == POLL_POPUP_WOOD_MEDIA_ID)
         {
            this.close(this._pollPopup);
            this._onDoneCallback();
         }
         else
         {
            this.close(this._pollPopup);
            this._thankYouPopup.open();
         }
      }
      
      private function onCloseBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.close(param1.currentTarget.parent);
         this._onDoneCallback();
      }
      
      private function onOptionSelected(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == this._answerSection.options.option1)
         {
            this._answerSection.options.option1._circle.visible = true;
         }
         var _loc2_:int = 1;
         while(_loc2_ < this._numOptions + 1)
         {
            this._answerSection.options["option" + _loc2_].removeEventListener(MouseEvent.MOUSE_DOWN,this.onOptionSelected);
            _loc2_++;
         }
         if(this._pollMediaId == POLL_POPUP_WOOD_MEDIA_ID)
         {
            this.processVote();
         }
         else
         {
            this._answerSection.voteBtn.activateGrayState(false);
         }
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

