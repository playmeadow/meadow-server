package gui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextFieldAutoSize;
   import flash.utils.getDefinitionByName;
   import loader.MediaHelper;
   
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
      
      private var _emoteBG:MovieClip = null;
      
      private var _emote:Sprite = null;
      
      private var _permEmoteMediaId:int = -1;
      
      private var _permEmoteMediaHelper:MediaHelper;
      
      private var _hasSbTextfield:Boolean;
      
      public var msgTxt:Object;
      
      public var balloonBG:MovieClip;
      
      public function ChatBalloon()
      {
         super();
      }
      
      public function init(param1:int, param2:Boolean = false, param3:int = 1, param4:Class = null) : void
      {
         this.gotoAndStop(param3);
         this.balloonBG = this["balloon_bg"];
         this.msgTxt = this["message_txt"];
         this._avType = param1;
         visible = false;
         this.msgTxt.autoSize = TextFieldAutoSize.CENTER;
         if(param2)
         {
            this._maxAlpha = 1;
         }
         else
         {
            this._maxAlpha = this.BALLOON_MAX_ALPHA;
         }
         this._emoteBG = new (getDefinitionByName("emo_bubble") as Class)();
         this.setEmoteBgOffsets();
      }
      
      public function setText(param1:String, param2:Boolean = false, param3:Boolean = true) : void
      {
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
               this.balloonBG.m.height = Math.floor(this.msgTxt.height);
               this.balloonBG.m.y = Math.round(this.balloonBG.b.y - this.balloonBG.m.height);
               this.balloonBG.t.y = Math.round(this.balloonBG.m.y - this.balloonBG.t.height);
               this.msgTxt.y = -this.balloonBG.b.height - this.msgTxt.height - (this.msgTxt.height - this.balloonBG.m.height);
            }
            else
            {
               this.balloonBG.m.height = Math.floor(this.msgTxt.height);
               this.balloonBG.b.y = Math.round(this.balloonBG.m.y + this.balloonBG.m.height);
               this.msgTxt.y = this.balloonBG.t.height + (this.balloonBG.m.height * 0.5 - this.msgTxt.height * 0.5) + 3;
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
            this._timeout = this.CHAT_TIMEOUT_MS;
            this.balloonBG.visible = false;
            this.setAlpha(1);
            this._emoteBG.bubble.alpha = this._maxAlpha;
            this._emoteBG.itemWindow.alpha = 1;
            this.visible = true;
         }
      }
      
      public function setReadyForClear() : void
      {
         this._timeout = this.BALLOON_BEGIN_FADEOUT;
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
            if(param1 > this._timeout)
            {
               this._timeout = 0;
               if(this._emote)
               {
                  this._emoteBG.itemWindow.removeChild(this._emote);
                  this._emote = null;
               }
               this.visible = false;
            }
            else
            {
               this._timeout -= param1;
               if(this._timeout < this.BALLOON_BEGIN_FADEOUT)
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
         switch(this._avType)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               this._emoteBG.x = -5;
               this._emoteBG.y = -30;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               this._emoteBG.x = -5;
               this._emoteBG.y = -45;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               this._emoteBG.x = 8;
               this._emoteBG.y = -40;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               this._emoteBG.x = 5;
               this._emoteBG.y = -35;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               this._emoteBG.x = -5;
               this._emoteBG.y = -35;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               this._emoteBG.x = -5;
               this._emoteBG.y = -35;
               break;
            case SharedAvatarAnimalConstants:
               this._emoteBG.x = 0;
               this._emoteBG.y = -40;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               this._emoteBG.x = -10;
               this._emoteBG.y = -25;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               this._emoteBG.x = 5;
               this._emoteBG.y = -15;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               this._emoteBG.x = 5;
               this._emoteBG.y = -35;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               this._emoteBG.x = 0;
               this._emoteBG.y = -30;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               this._emoteBG.x = 0;
               this._emoteBG.y = -20;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               this._emoteBG.x = 0;
               this._emoteBG.y = -30;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               this._emoteBG.x = 0;
               this._emoteBG.y = -45;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               this._emoteBG.x = 5;
               this._emoteBG.y = -37;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               this._emoteBG.x = 0;
               this._emoteBG.y = -30;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               this._emoteBG.x = -5;
               this._emoteBG.y = -55;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               this._emoteBG.x = 5;
               this._emoteBG.y = -42;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               this._emoteBG.x = 10;
               this._emoteBG.y = -33;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               this._emoteBG.x = -1;
               this._emoteBG.y = -35;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               this._emoteBG.x = -1;
               this._emoteBG.y = -15;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               this._emoteBG.x = -8;
               this._emoteBG.y = -24;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               this._emoteBG.x = -8;
               this._emoteBG.y = -28;
               break;
            default:
               this._emoteBG.x = -5;
               this._emoteBG.y = -45;
         }
      }
   }
}

