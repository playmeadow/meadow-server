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
      
      public function init(avType:int, emoteBGOffsetFunc:Function, opaque:Boolean = false, frameId:int = 1, sbtextField:Class = null, onCustomAdventureBtn:Function = null, onCustomPVPBtn:Function = null) : void
      {
         this._originalFrameId = frameId;
         this.gotoAndStop(frameId);
         this.balloonBG = this["balloon_bg"];
         this.msgTxt = this["message_txt"];
         this._onCustomAdventureBtn = onCustomAdventureBtn;
         this._onCustomPVPBtn = onCustomPVPBtn;
         this._emoteBGOffsetFunc = emoteBGOffsetFunc;
         this._avType = avType;
         visible = false;
         this.msgTxt.autoSize = TextFieldAutoSize.CENTER;
         if(opaque)
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
      
      public function setText(txt:String, changeFontColor:Boolean = false, addToParent:Boolean = true) : void
      {
         var adjustment:int = 0;
         if(Boolean(this._emote))
         {
            this._permEmoteMediaId = -1;
            this._emoteBG.itemWindow.removeChild(this._emote);
            this._emote = null;
         }
         if(contains(this._emoteBG))
         {
            removeChild(this._emoteBG);
         }
         if(txt != this.msgTxt.text && this._hasSbTextfield)
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
         this.msgTxt.text = txt;
         if(!this._hasSbTextfield)
         {
            if(addToParent)
            {
               if(Math.abs(this.msgTxt.height - Math.floor(this.msgTxt.height) - 0.5) < 0.3)
               {
                  adjustment = 1;
               }
               this.balloonBG.m.height = Math.floor(this.msgTxt.height - adjustment);
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
         if(changeFontColor)
         {
            this.msgTxt.textColor = this.TEXT_COLOR_BAD_TEXT;
         }
         else
         {
            this.msgTxt.textColor = this.TEXT_COLOR_NORMAL;
         }
         this._timeout = this.CHAT_TIMEOUT_MS;
         if(addToParent && Boolean(this.parent))
         {
            this.parent.addChild(this);
         }
      }
      
      public function setCustomAdventureMessage(infoText:String, userText:String, difficulty:int, changeFontColor:Boolean = false, isForPVP:Boolean = false) : void
      {
         var pvpGameId:int = 0;
         var scriptDefId:int = 0;
         var splitText:Array = userText.split("|");
         if(isForPVP)
         {
            userText = splitText[0];
            pvpGameId = int(splitText[1]);
         }
         else
         {
            userText = splitText[0];
            scriptDefId = int(splitText[1]);
         }
         if(userText == "on")
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
            this.btnBallonBG.isForPVP = isForPVP;
            this.btnBallonBG.PVPGameId = pvpGameId;
            this.btnBallonBG.scriptDefId = scriptDefId;
            this.btnBallonBG.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnBG,false,0,true);
            this.msgTxt = this["message_txt"];
            this.msgTxt.autoSize = TextFieldAutoSize.CENTER;
            LocalizationManager.translateId(this.btnBalloonMouseBG.message_txt,11259);
            LocalizationManager.translateId(this.btnBalloonUpBG.message_txt,11259);
            LocalizationManager.translateId(this.btnBalloonDownBg.message_txt,11259);
            LocalizationManager.translateId(this.btnBalloonGrayBG.message_txt,11259);
            if(difficulty > 0)
            {
               this.btnBalloonMouseBG.message_txt.x = 3;
               this.btnBalloonUpBG.message_txt.x = 3;
               this.btnBalloonDownBg.message_txt.x = 3;
               this.btnBalloonGrayBG.message_txt.x = 3;
               this.btnBallonBG["redDot"].visible = true;
            }
            else
            {
               this.btnBalloonMouseBG.message_txt.x = 17;
               this.btnBalloonUpBG.message_txt.x = 17;
               this.btnBalloonDownBg.message_txt.x = 17;
               this.btnBalloonGrayBG.message_txt.x = 17;
               this.btnBallonBG["redDot"].visible = false;
            }
            this.msgTxt.text = infoText;
            this._originalCustomMsgText = infoText;
            this.balloonBG.m.height = Math.floor(this.msgTxt.height);
            this.balloonBG.m.y = this.balloonBG.b.y - this.balloonBG.m.height;
            this.balloonBG.t.y = this.balloonBG.m.y - this.balloonBG.t.height;
            this.msgTxt.y = -this.balloonBG.b.height - this.msgTxt.height - (this.msgTxt.height - this.balloonBG.m.height);
            this.btnBallonBG.y = this.balloonBG.y + this.balloonBG.t.y - this.btnBallonBG.height + this.balloonBG.t.height;
            if(Boolean(this.itemWindow))
            {
               this.itemWindow.y = this.btnBallonBG.y;
            }
            this.balloonBG.t.alpha = 0;
            this.setAlpha(this._maxAlpha);
            this.visible = true;
            this._timeout = this.CHAT_TIMEOUT_MS;
            if(Boolean(this.parent))
            {
               this.parent.addChild(this);
            }
         }
         else
         {
            if(Boolean(this.btnBallonBG))
            {
               if(this.btnBallonBG.isForPVP != isForPVP)
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
         if(Boolean(this.btnBallonBG))
         {
            return this.btnBallonBG.isForPVP;
         }
         return false;
      }
      
      public function get pvpGameId() : int
      {
         if(Boolean(this.btnBallonBG))
         {
            return this.btnBallonBG.PVPGameId;
         }
         return 0;
      }
      
      public function setCustomPVPImage(img:MovieClip) : void
      {
         if(this.currentFrameLabel == "advBtn")
         {
            while(this.itemWindow.numChildren > 0)
            {
               this.itemWindow.removeChildAt(0);
            }
            this.itemWindow.addChild(img);
         }
      }
      
      private function onBtnBG(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(evt.currentTarget.isForPVP))
         {
            this._onCustomPVPBtn(evt.currentTarget.PVPGameId);
         }
         else
         {
            this._onCustomAdventureBtn(evt.currentTarget.scriptDefId);
         }
      }
      
      private function updateCustAdventureBGSize(bg:MovieClip, messageText:Object) : void
      {
         this.balloonBG.m.height = Math.floor(this.msgTxt.height);
         this.balloonBG.m.y = this.balloonBG.b.y - this.balloonBG.m.height;
         this.balloonBG.t.y = this.balloonBG.m.y - this.balloonBG.t.height;
         this.msgTxt.y = -this.balloonBG.b.height - this.msgTxt.height - (this.msgTxt.height - this.balloonBG.m.height);
         this.btnBallonBG.y = this.balloonBG.y + this.balloonBG.t.y - this.btnBallonBG.height + this.balloonBG.t.height;
         if(Boolean(this.itemWindow))
         {
            this.itemWindow.y = this.btnBallonBG.y;
         }
      }
      
      private function updateSizeFunction() : void
      {
         this.balloonBG.m.height = Math.floor(this.msgTxt.height);
         this.balloonBG.m.y = Math.floor(this.balloonBG.b.y - this.balloonBG.m.height);
         this.balloonBG.t.y = Math.floor(this.balloonBG.m.y - this.balloonBG.t.height);
         var adjustedBy:Number = Number(this.msgTxt.y);
         this.msgTxt.y = -this.balloonBG.b.height - this.msgTxt.height - (this.msgTxt.height - this.balloonBG.m.height);
         this.msgTxt.adjustSmileys(adjustedBy - this.msgTxt.y);
         this.balloonBG.visible = true;
         this.visible = true;
      }
      
      public function setEmote(emoteRef:Sprite, permEmoteMediaId:int = -1) : void
      {
         if(this.currentFrameLabel != "advBtn")
         {
            this._permEmoteMediaId = permEmoteMediaId;
            if(Boolean(this._emote))
            {
               this._emoteBG.itemWindow.removeChild(this._emote);
               this._emote = null;
            }
            if(this._permEmoteMediaId >= 0)
            {
               emoteRef = new Sprite();
               this._permEmoteMediaHelper = new MediaHelper();
               this._permEmoteMediaHelper.init(this._permEmoteMediaId,this.permEmoteMediaCallback);
            }
            if(Boolean(emoteRef))
            {
               this.msgTxt.text = "";
               addChild(this._emoteBG);
               this._emote = emoteRef;
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
      }
      
      public function setReadyForClear() : void
      {
         if(this.visible && this._timeout > this.BALLOON_BEGIN_FADEOUT)
         {
            this._timeout = this.BALLOON_BEGIN_FADEOUT;
         }
         this._permEmoteMediaId = -1;
      }
      
      public function setPos(x:int, y:int) : void
      {
         this.x = x;
         this.y = y;
      }
      
      public function heartbeat(ms:int) : void
      {
         if(Boolean(this._timeout) && this._permEmoteMediaId < 0)
         {
            if(ms >= this._timeout)
            {
               this._timeout = 0;
               if(Boolean(this._emote))
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
               this._timeout -= ms;
               if(this.currentFrameLabel != "advBtn" && this._timeout < this.BALLOON_BEGIN_FADEOUT)
               {
                  this.setAlpha(this._timeout / this.BALLOON_BEGIN_FADEOUT * this._maxAlpha);
               }
            }
         }
      }
      
      public function set avType(value:int) : void
      {
         if(value != this._avType)
         {
            this._avType = value;
            this.setEmoteBgOffsets();
         }
      }
      
      public function updateEmoteBgOffsets() : void
      {
         this.setEmoteBgOffsets();
      }
      
      private function setAlpha(alpha:Number) : void
      {
         this.alpha = alpha;
         this.msgTxt.alpha = 1;
      }
      
      private function permEmoteMediaCallback(img:MovieClip) : void
      {
         if(Boolean(img) && Boolean(this._emote) && this._permEmoteMediaId >= 0)
         {
            img.scaleX = 0.5;
            img.scaleY = 0.5;
            img.x = -(img.width * 0.5);
            img.y = -(img.height * 0.5);
            this._emote.addChild(img);
         }
      }
      
      private function setEmoteBgOffsets() : void
      {
         var p:Point = this._emoteBGOffsetFunc(this._avType);
         this._emoteBG.x = p.x;
         this._emoteBG.y = p.y;
      }
   }
}

