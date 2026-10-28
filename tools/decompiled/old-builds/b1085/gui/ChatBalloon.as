package gui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFieldAutoSize;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public dynamic class ChatBalloon extends MovieClip
   {
      
      private const CHAT_TIMEOUT_MS:int = 8000;
      
      private const BALLOON_BEGIN_FADEOUT:Number = 1000;
      
      private const BALLOON_MAX_ALPHA:Number = 0.75;
      
      private const TEXT_COLOR_NORMAL:uint = 4477529;
      
      private const TEXT_COLOR_BAD_TEXT:uint = 13369344;
      
      private var _maxAlpha:Number;
      
      private var _timeout:int = 0;
      
      private var _avType:int = 0;
      
      private var _originalFrameId:int = 0;
      
      private var _originalCustomMsgText:String;
      
      private var _emoteBG:MovieClip = null;
      
      private var _emote:Sprite = null;
      
      private var _permEmoteMediaId:int = -1;
      
      private var _permEmoteMediaHelper:MediaHelper;
      
      private var _hasSbTextfield:Boolean;
      
      public var msgTxt:Object;
      
      public var balloonBG:MovieClip;
      
      private var btnBallonBG:MovieClip;
      
      private var btnBalloonMouseBG:MovieClip;
      
      private var btnBalloonUpBG:MovieClip;
      
      private var btnBalloonDownBg:MovieClip;
      
      private var btnBalloonGrayBG:MovieClip;
      
      private var _onCustomAdventureBtn:Function;
      
      private var _onCustomPVPBtn:Function;
      
      private var _emoteBGOffsetFunc:Function;
      
      public function ChatBalloon()
      {
         super();
      }
      
      public function init(param1:int, param2:Function, param3:Boolean = false, param4:int = 1, param5:Class = null, param6:Function = null, param7:Function = null) : void
      {
         this._originalFrameId = param4;
         this.gotoAndStop(param4);
         this.balloonBG = this["balloon_bg"];
         this.msgTxt = this["message_txt"];
         this._onCustomAdventureBtn = param6;
         this._onCustomPVPBtn = param7;
         this._emoteBGOffsetFunc = param2;
         this._avType = param1;
         visible = false;
         this.msgTxt.autoSize = TextFieldAutoSize.CENTER;
         if(param3)
         {
            this._maxAlpha = 1;
         }
         else
         {
            this._maxAlpha = this.BALLOON_MAX_ALPHA;
         }
         this._emoteBG = GETDEFINITIONBYNAME("emo_bubble");
         this.setEmoteBgOffsets();
      }
      
      public function setText(param1:String, param2:Boolean = false, param3:Boolean = true) : void
      {
         var _loc4_:int = 0;
         if(this._emote)
         {
            this._permEmoteMediaId = -1;
            this._emoteBG.itemWindow.removeChild(this._emote);
            this._emote = null;
         }
         if(contains(this._emoteBG))
         {
            removeChild(this._emoteBG);
         }
         if(param1 != this.msgTxt.text && this._hasSbTextfield)
         {
            this.balloonBG.visible = false;
            this.setAlpha(this._maxAlpha);
            this.visible = false;
         }
         else
         {
            this.balloonBG.visible = true;
            this.setAlpha(this._maxAlpha);
            this.visible = true;
         }
         this.msgTxt.text = param1;
         if(!this._hasSbTextfield)
         {
            if(param3)
            {
               if(Math.abs(this.msgTxt.height - Math.floor(this.msgTxt.height) - 0.5) < 0.3)
               {
                  _loc4_ = 1;
               }
               this.balloonBG.m.height = Math.floor(this.msgTxt.height - _loc4_);
               this.balloonBG.m.y = this.balloonBG.b.y - this.balloonBG.m.height;
               this.balloonBG.t.y = this.balloonBG.m.y - this.balloonBG.t.height;
               this.msgTxt.y = -this.balloonBG.b.height - this.msgTxt.height - (this.msgTxt.height - this.balloonBG.m.height);
            }
            else
            {
               this.balloonBG.m.height = Math.floor(this.msgTxt.height);
               this.balloonBG.b.y = Math.round(this.balloonBG.m.y + this.balloonBG.m.height);
               this.msgTxt.y = this.balloonBG.t.height + (this.balloonBG.m.height * 0.5 - this.msgTxt.height * 0.5) + 3;
            }
            if(this.currentFrameLabel == "advBtn")
            {
               this.btnBallonBG.y = this.balloonBG.y + this.balloonBG.t.y - this.btnBallonBG.height + this.balloonBG.t.height;
            }
         }
         if(param2)
         {
            this.msgTxt.textColor = this.TEXT_COLOR_BAD_TEXT;
         }
         else
         {
            this.msgTxt.textColor = this.TEXT_COLOR_NORMAL;
         }
         this._timeout = this.CHAT_TIMEOUT_MS;
         if(param3 && Boolean(this.parent))
         {
            this.parent.addChild(this);
         }
      }
      
      public function setCustomAdventureMessage(param1:String, param2:String, param3:int, param4:Boolean = false, param5:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = param2.split("|");
         if(param5)
         {
            param2 = _loc8_[0];
            _loc6_ = int(_loc8_[1]);
         }
         else
         {
            param2 = _loc8_[0];
            _loc7_ = int(_loc8_[1]);
         }
         if(param2 == "on")
         {
            if(Boolean(this._emote) && Boolean(this._emoteBG))
            {
               this._emoteBG.itemWindow.removeChild(this._emote);
               this._emote = null;
               if(contains(this._emoteBG))
               {
                  removeChild(this._emoteBG);
               }
            }
            if(this.currentFrameLabel != "advBtn")
            {
               this.gotoAndStop("advBtn");
            }
            this.balloonBG = this["balloon_bg"];
            this.btnBallonBG = this["btnBalloon_bg"];
            this.btnBalloonMouseBG = this.btnBallonBG.mouse.mouse;
            this.btnBalloonUpBG = this.btnBallonBG.mouse.up;
            this.btnBalloonDownBg = this.btnBallonBG.down;
            this.btnBalloonGrayBG = this.btnBallonBG.gray;
            this.btnBallonBG.isForPVP = param5;
            this.btnBallonBG.PVPGameId = _loc6_;
            this.btnBallonBG.scriptDefId = _loc7_;
            this.btnBallonBG.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnBG,false,0,true);
            this.msgTxt = this["message_txt"];
            this.msgTxt.autoSize = TextFieldAutoSize.CENTER;
            this.btnBalloonMouseBG.message_txt.autoSize = this.btnBalloonUpBG.message_txt.autoSize = this.btnBalloonDownBg.message_txt.autoSize = this.btnBalloonGrayBG.message_txt.autoSize = TextFieldAutoSize.CENTER;
            LocalizationManager.translateId(this.btnBalloonMouseBG.message_txt,11259);
            LocalizationManager.translateId(this.btnBalloonUpBG.message_txt,11259);
            LocalizationManager.translateId(this.btnBalloonDownBg.message_txt,11259);
            LocalizationManager.translateId(this.btnBalloonGrayBG.message_txt,11259);
            this.btnBallonBG["redDot"].visible = param3 > 0;
            this.msgTxt.text = param1;
            this._originalCustomMsgText = param1;
            this.balloonBG.m.height = Math.floor(this.msgTxt.height);
            this.balloonBG.m.y = this.balloonBG.b.y - this.balloonBG.m.height;
            this.balloonBG.t.y = this.balloonBG.m.y - this.balloonBG.t.height;
            this.msgTxt.y = -this.balloonBG.b.height - this.msgTxt.height - (this.msgTxt.height - this.balloonBG.m.height);
            this.btnBallonBG.y = this.balloonBG.y + this.balloonBG.t.y - this.btnBallonBG.height + this.balloonBG.t.height;
            if(this.itemWindow)
            {
               this.itemWindow.y = this.btnBallonBG.y;
            }
            this.balloonBG.t.alpha = 0;
            this.setAlpha(this._maxAlpha);
            this.visible = true;
            this._timeout = this.CHAT_TIMEOUT_MS;
            if(this.parent)
            {
               this.parent.addChild(this);
            }
         }
         else
         {
            if(this.btnBallonBG)
            {
               if(this.btnBallonBG.isForPVP != param5)
               {
                  return;
               }
               this.btnBallonBG.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnBG);
            }
            if(this.currentFrameLabel == "advBtn")
            {
               this.gotoAndStop(this._originalFrameId);
            }
            this.balloonBG = this["balloon_bg"];
            this.msgTxt = this["message_txt"];
            this.msgTxt.autoSize = TextFieldAutoSize.CENTER;
            this.visible = false;
         }
      }
      
      public function get isPvpCustom() : Boolean
      {
         if(this.btnBallonBG)
         {
            return this.btnBallonBG.isForPVP;
         }
         return false;
      }
      
      public function get pvpGameId() : int
      {
         if(this.btnBallonBG)
         {
            return this.btnBallonBG.PVPGameId;
         }
         return 0;
      }
      
      public function setCustomPVPImage(param1:MovieClip) : void
      {
         if(this.currentFrameLabel == "advBtn")
         {
            while(this.itemWindow.numChildren > 0)
            {
               this.itemWindow.removeChildAt(0);
            }
            this.itemWindow.addChild(param1);
         }
      }
      
      private function onBtnBG(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isForPVP)
         {
            this._onCustomPVPBtn(param1.currentTarget.PVPGameId);
         }
         else
         {
            this._onCustomAdventureBtn(param1.currentTarget.scriptDefId);
         }
      }
      
      private function updateCustAdventureBGSize(param1:MovieClip, param2:Object) : void
      {
         this.balloonBG.m.height = Math.floor(this.msgTxt.height);
         this.balloonBG.m.y = this.balloonBG.b.y - this.balloonBG.m.height;
         this.balloonBG.t.y = this.balloonBG.m.y - this.balloonBG.t.height;
         this.msgTxt.y = -this.balloonBG.b.height - this.msgTxt.height - (this.msgTxt.height - this.balloonBG.m.height);
         this.btnBallonBG.y = this.balloonBG.y + this.balloonBG.t.y - this.btnBallonBG.height + this.balloonBG.t.height;
         if(this.itemWindow)
         {
            this.itemWindow.y = this.btnBallonBG.y;
         }
      }
      
      private function updateSizeFunction() : void
      {
         this.balloonBG.m.height = Math.floor(this.msgTxt.height);
         this.balloonBG.m.y = Math.floor(this.balloonBG.b.y - this.balloonBG.m.height);
         this.balloonBG.t.y = Math.floor(this.balloonBG.m.y - this.balloonBG.t.height);
         var _loc1_:Number = Number(this.msgTxt.y);
         this.msgTxt.y = -this.balloonBG.b.height - this.msgTxt.height - (this.msgTxt.height - this.balloonBG.m.height);
         this.msgTxt.adjustSmileys(_loc1_ - this.msgTxt.y);
         this.balloonBG.visible = true;
         this.visible = true;
      }
      
      public function setEmote(param1:Sprite, param2:int = -1) : void
      {
         this._permEmoteMediaId = param2;
         if(this._emote)
         {
            this._emoteBG.itemWindow.removeChild(this._emote);
            this._emote = null;
         }
         if(this._permEmoteMediaId >= 0)
         {
            param1 = new Sprite();
            this._permEmoteMediaHelper = new MediaHelper();
            this._permEmoteMediaHelper.init(this._permEmoteMediaId,this.permEmoteMediaCallback);
         }
         if(param1)
         {
            this.msgTxt.text = "";
            addChild(this._emoteBG);
            this._emote = param1;
            this._emote.y = -5;
            this._emoteBG.itemWindow.addChild(this._emote);
            if(this._emote is MovieClip)
            {
               MovieClip(this._emote).gotoAndPlay(1);
            }
            if(this.currentFrameLabel != "advBtn")
            {
               this._timeout = this.CHAT_TIMEOUT_MS;
            }
            this.balloonBG.visible = false;
            this.setAlpha(1);
            this._emoteBG.bubble.alpha = this._maxAlpha;
            this._emoteBG.itemWindow.alpha = 1;
            this.visible = true;
         }
      }
      
      public function setReadyForClear() : void
      {
         if(this.visible && this._timeout > this.BALLOON_BEGIN_FADEOUT)
         {
            this._timeout = this.BALLOON_BEGIN_FADEOUT;
         }
         this._permEmoteMediaId = -1;
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function heartbeat(param1:int) : void
      {
         if(Boolean(this._timeout) && this._permEmoteMediaId < 0)
         {
            if(param1 >= this._timeout)
            {
               this._timeout = 0;
               if(this._emote)
               {
                  this._emoteBG.itemWindow.removeChild(this._emote);
                  this._emote = null;
               }
               if(this.currentFrameLabel != "advBtn")
               {
                  this.visible = false;
               }
               else
               {
                  this.msgTxt.text = this._originalCustomMsgText;
                  this.updateCustAdventureBGSize(this.balloonBG,this.msgTxt);
               }
            }
            else
            {
               this._timeout -= param1;
               if(this.currentFrameLabel != "advBtn" && this._timeout < this.BALLOON_BEGIN_FADEOUT)
               {
                  this.setAlpha(this._timeout / this.BALLOON_BEGIN_FADEOUT * this._maxAlpha);
               }
            }
         }
      }
      
      public function set avType(param1:int) : void
      {
         if(param1 != this._avType)
         {
            this._avType = param1;
            this.setEmoteBgOffsets();
         }
      }
      
      public function updateEmoteBgOffsets() : void
      {
         this.setEmoteBgOffsets();
      }
      
      private function setAlpha(param1:Number) : void
      {
         this.alpha = param1;
         this.msgTxt.alpha = 1;
      }
      
      private function permEmoteMediaCallback(param1:MovieClip) : void
      {
         if(Boolean(param1) && Boolean(this._emote) && this._permEmoteMediaId >= 0)
         {
            param1.scaleX = 0.5;
            param1.scaleY = 0.5;
            param1.x = -(param1.width * 0.5);
            param1.y = -(param1.height * 0.5);
            this._emote.addChild(param1);
         }
      }
      
      private function setEmoteBgOffsets() : void
      {
         var _loc1_:Point = this._emoteBGOffsetFunc(this._avType);
         this._emoteBG.x = _loc1_.x;
         this._emoteBG.y = _loc1_.y;
      }
   }
}

