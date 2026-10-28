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
      
      private static const POLL_POPUP_MEDIA_ID:int = 369;
      
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
      
      public function SBPollPopup()
      {
         super();
      }
      
      public function init(initParent:DisplayObjectContainer, initTab:MovieClip, initOnVoteCallback:Function, initOnDoneCallback:Function, initRandomizeOrder:Boolean) : void
      {
         this._popupLayer = initParent;
         this._tab = initTab;
         this._onVoteCallback = initOnVoteCallback;
         this._onDoneCallback = initOnDoneCallback;
         this._randomizeOrder = initRandomizeOrder;
         this._pollDef = this._tab.def;
         this._randOptionLookup = [0,1,2,3,4];
         this._thankYouPopup = new SBStandardTitlePopup(this._popupLayer,LocalizationManager.translateIdOnly(14680),null,370,this._onDoneCallback,false);
         this._pollMediaHelper = new MediaHelper();
         this._pollMediaHelper.init(POLL_POPUP_MEDIA_ID,this.onMediaLoaded,true);
      }
      
      public function destroy() : void
      {
         this._pollPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtnDown);
         this._pollPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown);
         this._pollPopup = null;
         this._thankYouPopup.destroy();
         this._thankYouPopup = null;
      }
      
      private function onMediaLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            if(img.mediaHelper.id == POLL_POPUP_MEDIA_ID)
            {
               this._pollMediaHelper.destroy();
               this._pollMediaHelper = null;
               this._pollPopup = MovieClip(img.getChildAt(0));
               this.setUpPollPopup();
            }
         }
      }
      
      private function setUpPollPopup() : void
      {
         this._pollPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtnDown,false,0,true);
         this._pollPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
         var text:String = this._pollDef.poll;
         var firstPipe:int = text.indexOf("|");
         this._pollPopup.bodyTxt.text = text.substring(0,firstPipe);
         var pollOptions:Array = text.substring(firstPipe + 1,text.length).split("|");
         if(this._randomizeOrder)
         {
            pollOptions = this.shuffleArray(pollOptions);
         }
         this._numOptions = pollOptions.length;
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
            this._pollPopup.answer2.visible = false;
            this._pollPopup.answer3.visible = false;
            this._pollPopup.answer4.visible = false;
            this._pollPopup.answer5.visible = true;
         }
         this._optionsGroup = new GuiRadioButtonGroup(this._answerSection.options);
         this._answerSection.voteBtn.activateGrayState(true);
         this._answerSection.voteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onVoteBtnDown,false,0,true);
         for(var i:int = 1; i < this._numOptions + 1; i++)
         {
            this._answerSection["answer" + i + "Txt"].text = pollOptions[i - 1];
            this._answerSection.options["option" + i].addEventListener(MouseEvent.MOUSE_DOWN,this.onOptionSelected,false,0,true);
         }
         DarkenManager.showLoadingSpiral(false);
         this.open(this._pollPopup);
      }
      
      private function shuffleArray(a:Array) : Array
      {
         var element:String = null;
         var i:int = 0;
         var rand:int = 0;
         var save:int = 0;
         var length:int = int(a.length);
         var shuffled:Array = a.slice();
         while(i < length)
         {
            element = shuffled[i];
            rand = Math.floor(Math.random() * length);
            if(i != rand)
            {
               shuffled[i] = shuffled[rand];
               shuffled[rand] = element;
               save = int(this._randOptionLookup[i]);
               this._randOptionLookup[i] = this._randOptionLookup[rand];
               this._randOptionLookup[rand] = save;
            }
            i++;
         }
         return shuffled;
      }
      
      private function open(popup:MovieClip) : void
      {
         this._popupLayer.addChild(popup);
         popup.x = MainFrame.VIEW_WIDTH * 0.5;
         popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         DarkenManager.darken(popup);
         popup.visible = true;
      }
      
      private function close(popup:MovieClip) : void
      {
         popup.visible = false;
         DarkenManager.unDarken(popup);
         this._popupLayer.removeChild(popup);
      }
      
      private function onVoteBtnDown(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(!e.currentTarget.isGray)
         {
            if(this._onVoteCallback != null)
            {
               this._onVoteCallback(this._tab,this._randOptionLookup[this._optionsGroup.selected] + 1);
            }
            this.close(this._pollPopup);
            this._thankYouPopup.open();
         }
      }
      
      private function onCloseBtnDown(e:MouseEvent) : void
      {
         e.stopPropagation();
         this.close(e.currentTarget.parent);
         this._onDoneCallback();
      }
      
      private function onOptionSelected(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(e.currentTarget == this._answerSection.options.option1)
         {
            this._answerSection.options.option1._circle.visible = true;
         }
         for(var i:int = 1; i < this._numOptions + 1; i++)
         {
            this._answerSection.options["option" + i].removeEventListener(MouseEvent.MOUSE_DOWN,this.onOptionSelected);
         }
         this._answerSection.voteBtn.activateGrayState(false);
      }
      
      private function onPopupDown(e:MouseEvent) : void
      {
         e.stopPropagation();
      }
   }
}

