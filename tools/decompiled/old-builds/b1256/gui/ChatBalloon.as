package gui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
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
         _originalFrameId = param4;
         this.gotoAndStop(param4);
         balloonBG = this["balloon_bg"];
         msgTxt = this["message_txt"];
         _onCustomAdventureBtn = param6;
         _onCustomPVPBtn = param7;
         _emoteBGOffsetFunc = param2;
         _avType = param1;
         visible = false;
         msgTxt.autoSize = "center";
         if(param3)
         {
            _maxAlpha = 1;
         }
         else
         {
            _maxAlpha = 0.75;
         }
         _emoteBG = GETDEFINITIONBYNAME("emo_bubble");
         setEmoteBgOffsets();
      }
      
      public function setText(param1:String, param2:Boolean = false, param3:Boolean = true) : void
      {
         if(_emote)
         {
            _permEmoteMediaId = -1;
            _emoteBG.itemWindow.removeChild(_emote);
            _emote = null;
         }
         if(contains(_emoteBG))
         {
            removeChild(_emoteBG);
         }
         if(param1 != msgTxt.text && _hasSbTextfield)
         {
            balloonBG.visible = false;
            setAlpha(_maxAlpha);
            this.visible = false;
         }
         else
         {
            balloonBG.visible = true;
            setAlpha(_maxAlpha);
            this.visible = true;
         }
         msgTxt.text = param1;
         if(!_hasSbTextfield)
         {
            if(param3)
            {
               balloonBG.m.height = msgTxt.height;
               balloonBG.m.y = balloonBG.b.y - balloonBG.m.height;
               balloonBG.t.y = balloonBG.m.y - balloonBG.t.height;
               msgTxt.y = -balloonBG.b.height - msgTxt.height - (msgTxt.height - balloonBG.m.height);
            }
            else
            {
               balloonBG.m.height = msgTxt.height;
               balloonBG.b.y = Math.round(balloonBG.m.y + balloonBG.m.height);
               msgTxt.y = balloonBG.t.height + (balloonBG.m.height * 0.5 - msgTxt.height * 0.5) + 3;
            }
            if(this.currentFrameLabel == "advBtn")
            {
               btnBallonBG.y = balloonBG.y + balloonBG.t.y - btnBallonBG.height + balloonBG.t.height;
            }
         }
         if(param2)
         {
            msgTxt.textColor = 13369344;
         }
         else
         {
            msgTxt.textColor = 4477529;
         }
         _timeout = 8000;
         if(param3 && this.parent)
         {
            this.parent.addChild(this);
         }
      }
      
      public function setCustomAdventureMessage(param1:String, param2:String, param3:int, param4:Boolean = false, param5:Boolean = false) : void
      {
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:Array = param2.split("|");
         if(param5)
         {
            param2 = _loc6_[0];
            _loc8_ = int(_loc6_[1]);
         }
         else
         {
            param2 = _loc6_[0];
            _loc7_ = int(_loc6_[1]);
         }
         if(param2 == "on")
         {
            if(_emote && _emoteBG)
            {
               _emoteBG.itemWindow.removeChild(_emote);
               _emote = null;
               if(contains(_emoteBG))
               {
                  removeChild(_emoteBG);
               }
            }
            if(this.currentFrameLabel != "advBtn")
            {
               this.gotoAndStop("advBtn");
            }
            balloonBG = this["balloon_bg"];
            btnBallonBG = this["btnBalloon_bg"];
            btnBalloonMouseBG = btnBallonBG.mouse.mouse;
            btnBalloonUpBG = btnBallonBG.mouse.up;
            btnBalloonDownBg = btnBallonBG.down;
            btnBalloonGrayBG = btnBallonBG.gray;
            btnBallonBG.isForPVP = param5;
            btnBallonBG.PVPGameId = _loc8_;
            btnBallonBG.scriptDefId = _loc7_;
            btnBallonBG.addEventListener("mouseDown",onBtnBG,false,0,true);
            msgTxt = this["message_txt"];
            msgTxt.autoSize = "center";
            LocalizationManager.translateId(btnBalloonMouseBG.message_txt,11259);
            LocalizationManager.translateId(btnBalloonUpBG.message_txt,11259);
            LocalizationManager.translateId(btnBalloonDownBg.message_txt,11259);
            LocalizationManager.translateId(btnBalloonGrayBG.message_txt,11259);
            if(param3 > 0)
            {
               btnBalloonMouseBG.message_txt.x = 3;
               btnBalloonUpBG.message_txt.x = 3;
               btnBalloonDownBg.message_txt.x = 3;
               btnBalloonGrayBG.message_txt.x = 3;
               btnBallonBG["redDot"].visible = true;
            }
            else
            {
               btnBalloonMouseBG.message_txt.x = 17;
               btnBalloonUpBG.message_txt.x = 17;
               btnBalloonDownBg.message_txt.x = 17;
               btnBalloonGrayBG.message_txt.x = 17;
               btnBallonBG["redDot"].visible = false;
            }
            msgTxt.text = param1;
            _originalCustomMsgText = param1;
            balloonBG.m.height = Math.floor(msgTxt.height);
            balloonBG.m.y = balloonBG.b.y - balloonBG.m.height;
            balloonBG.t.y = balloonBG.m.y - balloonBG.t.height;
            msgTxt.y = -balloonBG.b.height - msgTxt.height - (msgTxt.height - balloonBG.m.height);
            btnBallonBG.y = balloonBG.y + balloonBG.t.y - btnBallonBG.height + balloonBG.t.height;
            if(this.itemWindow)
            {
               this.itemWindow.y = btnBallonBG.y;
            }
            balloonBG.t.alpha = 0;
            setAlpha(_maxAlpha);
            this.visible = true;
            _timeout = 8000;
            if(this.parent)
            {
               this.parent.addChild(this);
            }
         }
         else
         {
            if(btnBallonBG)
            {
               if(btnBallonBG.isForPVP != param5)
               {
                  return;
               }
               btnBallonBG.removeEventListener("mouseDown",onBtnBG);
            }
            if(this.currentFrameLabel == "advBtn")
            {
               this.gotoAndStop(_originalFrameId);
            }
            balloonBG = this["balloon_bg"];
            msgTxt = this["message_txt"];
            msgTxt.autoSize = "center";
            this.visible = false;
         }
      }
      
      public function get isPvpCustom() : Boolean
      {
         if(btnBallonBG)
         {
            return btnBallonBG.isForPVP;
         }
         return false;
      }
      
      public function get pvpGameId() : int
      {
         if(btnBallonBG)
         {
            return btnBallonBG.PVPGameId;
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
            _onCustomPVPBtn(param1.currentTarget.PVPGameId);
         }
         else
         {
            _onCustomAdventureBtn(param1.currentTarget.scriptDefId);
         }
      }
      
      private function updateCustAdventureBGSize(param1:MovieClip, param2:Object) : void
      {
         balloonBG.m.height = Math.floor(msgTxt.height);
         balloonBG.m.y = balloonBG.b.y - balloonBG.m.height;
         balloonBG.t.y = balloonBG.m.y - balloonBG.t.height;
         msgTxt.y = -balloonBG.b.height - msgTxt.height - (msgTxt.height - balloonBG.m.height);
         btnBallonBG.y = balloonBG.y + balloonBG.t.y - btnBallonBG.height + balloonBG.t.height;
         if(this.itemWindow)
         {
            this.itemWindow.y = btnBallonBG.y;
         }
      }
      
      private function updateSizeFunction() : void
      {
         balloonBG.m.height = Math.floor(msgTxt.height);
         balloonBG.m.y = Math.floor(balloonBG.b.y - balloonBG.m.height);
         balloonBG.t.y = Math.floor(balloonBG.m.y - balloonBG.t.height);
         var _loc1_:Number = Number(msgTxt.y);
         msgTxt.y = -balloonBG.b.height - msgTxt.height - (msgTxt.height - balloonBG.m.height);
         msgTxt.adjustSmileys(_loc1_ - msgTxt.y);
         balloonBG.visible = true;
         this.visible = true;
      }
      
      public function setEmote(param1:Sprite, param2:int = -1) : void
      {
         if(this.currentFrameLabel != "advBtn")
         {
            _permEmoteMediaId = param2;
            if(_emote)
            {
               _emoteBG.itemWindow.removeChild(_emote);
               _emote = null;
            }
            if(_permEmoteMediaId >= 0)
            {
               param1 = new Sprite();
               _permEmoteMediaHelper = new MediaHelper();
               _permEmoteMediaHelper.init(_permEmoteMediaId,permEmoteMediaCallback);
            }
            if(param1)
            {
               msgTxt.text = "";
               addChild(_emoteBG);
               _emote = param1;
               _emote.y = -5;
               _emoteBG.itemWindow.addChild(_emote);
               if(_emote is MovieClip)
               {
                  MovieClip(_emote).gotoAndPlay(1);
               }
               if(this.currentFrameLabel != "advBtn")
               {
                  _timeout = 8000;
               }
               balloonBG.visible = false;
               setAlpha(1);
               _emoteBG.bubble.alpha = _maxAlpha;
               _emoteBG.itemWindow.alpha = 1;
               this.visible = true;
            }
         }
      }
      
      public function setReadyForClear() : void
      {
         if(this.visible && _timeout > 1000)
         {
            _timeout = 1000;
         }
         _permEmoteMediaId = -1;
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function heartbeat(param1:int) : void
      {
         if(_timeout && _permEmoteMediaId < 0)
         {
            if(param1 >= _timeout)
            {
               _timeout = 0;
               if(_emote)
               {
                  _emoteBG.itemWindow.removeChild(_emote);
                  _emote = null;
               }
               if(this.currentFrameLabel != "advBtn")
               {
                  this.visible = false;
               }
               else
               {
                  msgTxt.text = _originalCustomMsgText;
                  updateCustAdventureBGSize(balloonBG,msgTxt);
               }
            }
            else
            {
               _timeout -= param1;
               if(this.currentFrameLabel != "advBtn" && _timeout < 1000)
               {
                  setAlpha(_timeout / 1000 * _maxAlpha);
               }
            }
         }
      }
      
      public function set avType(param1:int) : void
      {
         if(param1 != _avType)
         {
            _avType = param1;
            setEmoteBgOffsets();
         }
      }
      
      public function updateEmoteBgOffsets() : void
      {
         setEmoteBgOffsets();
      }
      
      private function setAlpha(param1:Number) : void
      {
         this.alpha = param1;
         msgTxt.alpha = 1;
      }
      
      private function permEmoteMediaCallback(param1:MovieClip) : void
      {
         if(param1 && _emote && _permEmoteMediaId >= 0)
         {
            param1.scaleX = 0.5;
            param1.scaleY = 0.5;
            param1.x = -(param1.width * 0.5);
            param1.y = -(param1.height * 0.5);
            _emote.addChild(param1);
         }
      }
      
      private function setEmoteBgOffsets() : void
      {
         var _loc1_:Point = _emoteBGOffsetFunc(_avType);
         _emoteBG.x = _loc1_.x;
         _emoteBG.y = _loc1_.y;
      }
   }
}

