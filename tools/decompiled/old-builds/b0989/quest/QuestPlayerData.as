package quest
{
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.media.SoundChannel;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getDefinitionByName;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Linear;
   import loader.MediaHelper;
   
   public class QuestPlayerData extends Sprite
   {
      
      private var _levelUpHelperBottom:MediaHelper;
      
      private var _levelUpHelperTop:MediaHelper;
      
      private var _levelUpMCBottom:MovieClip;
      
      private var _levelUpMCTop:MovieClip;
      
      private var _levelUpLoaded:Boolean;
      
      public var _avatarWorldView:AvatarWorldView;
      
      private var _tintFrames:int;
      
      private var _statusText:TextField;
      
      private var _statusTextTween:GTween;
      
      private var _healingTween:GTween;
      
      private var _healingHeart:MovieClip;
      
      private var _uID:int;
      
      private var _itemEmoticonSound:SoundChannel;
      
      private var _itemEmoticonSoundName:String;
      
      private var _playerDamageMC:MovieClip;
      
      private var _playerDamageMH:MediaHelper;
      
      private var _pendingPlayerDamageMax:int;
      
      private var _pendingPlayerDamageBefore:int;
      
      private var _pendingPlayerDamageAfter:int;
      
      public function QuestPlayerData()
      {
         super();
      }
      
      private function updateAvatarStatus() : void
      {
         if(this._avatarWorldView == null)
         {
            this._avatarWorldView = AvatarManager.avatarViewList[this._uID];
            if(this._avatarWorldView)
            {
               this._avatarWorldView.addChild(this._statusText);
               this._avatarWorldView.addChild(this._healingHeart);
            }
         }
      }
      
      public function init(param1:int) : void
      {
         this._uID = param1;
         this._statusText = new TextField();
         this._statusText.multiline = false;
         this._statusText.selectable = false;
         this._statusText.embedFonts = true;
         this._statusText.defaultTextFormat = new TextFormat("Tiki-Island",36,65280);
         this._statusText.filters = [new GlowFilter(0,1,3,3,10,2)];
         this._statusText.visible = false;
         this._healingHeart = new (getDefinitionByName("questHeartsCont") as Class)();
         this._healingHeart.visible = false;
         this._pendingPlayerDamageMax = 0;
         this._playerDamageMH = new MediaHelper();
         this._playerDamageMH.init(2252,this.onPlayerDamageLoaded);
         this.updateAvatarStatus();
      }
      
      private function playLevelUpEffect() : void
      {
         if(this._levelUpLoaded)
         {
            this._levelUpMCTop.gotoAndPlay("tintOn");
            this._levelUpMCBottom.gotoAndPlay("tintOn");
            this._levelUpLoaded = false;
            this._levelUpMCTop.addEventListener(Event.ENTER_FRAME,this.levelUpEnterFrameHandler);
            this.updateAvatarStatus();
            if(this._avatarWorldView)
            {
               this._avatarWorldView.setBlendColor(4290903190,7534606);
            }
            QuestManager.playSound("ajq_stingerLevelUp");
         }
         else
         {
            this._levelUpLoaded = true;
         }
      }
      
      public function playerDamaged(param1:int, param2:int, param3:int) : void
      {
         if(this._playerDamageMC != null && this._avatarWorldView != null)
         {
            if(this._playerDamageMC.parent != QuestManager._layerManager.room_chat)
            {
               this._pendingPlayerDamageMax = 0;
               this._playerDamageMC.x = this._avatarWorldView.x;
               this._playerDamageMC.y = this._avatarWorldView.y;
               QuestManager._layerManager.room_chat.addChild(this._playerDamageMC);
               this._playerDamageMC.hit(param1,param2,param3);
               this._playerDamageMC.addEventListener(Event.ENTER_FRAME,this.playerDamageFrameHandler);
            }
         }
         else
         {
            this._pendingPlayerDamageMax = param1;
            this._pendingPlayerDamageBefore = param2;
            this._pendingPlayerDamageAfter = param3;
         }
      }
      
      private function onPlayerDamageLoaded(param1:MovieClip) : void
      {
         this._playerDamageMC = param1;
         this._playerDamageMH.destroy();
         this._playerDamageMH = null;
         if(this._pendingPlayerDamageMax > 0)
         {
            this.playerDamaged(this._pendingPlayerDamageMax,this._pendingPlayerDamageBefore,this._pendingPlayerDamageAfter);
         }
      }
      
      private function onLevelUpTopLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(Boolean(this._levelUpMCTop) && Boolean(this._levelUpMCTop.parent))
            {
               this._levelUpMCTop.parent.removeChild(this._levelUpMCTop);
            }
            this._levelUpMCTop = param1;
            this.updateAvatarStatus();
            if(this._avatarWorldView)
            {
               this._levelUpMCTop.x = this._avatarWorldView.x;
               this._levelUpMCTop.y = this._avatarWorldView.y;
               QuestManager._layerManager.room_chat.addChild(this._levelUpMCTop);
            }
            this.playLevelUpEffect();
         }
      }
      
      private function onLevelUpBottomLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(Boolean(this._levelUpMCBottom) && Boolean(this._levelUpMCBottom.parent))
            {
               this._levelUpMCBottom.parent.removeChild(this._levelUpMCBottom);
            }
            this._levelUpMCBottom = param1;
            this.updateAvatarStatus();
            if(this._avatarWorldView)
            {
               this._avatarWorldView.addChildAt(this._levelUpMCBottom,0);
            }
            this.playLevelUpEffect();
         }
      }
      
      private function playerDamageFrameHandler(param1:Event) : void
      {
         this._playerDamageMC.x = this._avatarWorldView.x;
         this._playerDamageMC.y = this._avatarWorldView.y;
         if(this._playerDamageMC != null && Boolean(this._playerDamageMC.finished))
         {
            this._playerDamageMC.removeEventListener(Event.ENTER_FRAME,this.playerDamageFrameHandler);
            if(this._playerDamageMC.parent == QuestManager._layerManager.room_chat)
            {
               QuestManager._layerManager.room_chat.removeChild(this._playerDamageMC);
            }
         }
      }
      
      private function levelUpEnterFrameHandler(param1:Event) : void
      {
         if(this._levelUpMCTop != null)
         {
            this._levelUpMCTop.x = this._avatarWorldView.x;
            this._levelUpMCTop.y = this._avatarWorldView.y;
         }
         if(this._levelUpMCTop.currentFrameLabel == "tintOff")
         {
            this.updateAvatarStatus();
            if(this._avatarWorldView)
            {
               this._avatarWorldView.setBlendColor(0);
            }
         }
         if(this._levelUpMCTop.currentFrameLabel == "finished")
         {
            this._levelUpMCTop.removeEventListener(Event.ENTER_FRAME,this.levelUpEnterFrameHandler);
         }
      }
      
      private function onTweenComplete(param1:GTween) : void
      {
         if(this._avatarWorldView)
         {
            if(Boolean(this._healingHeart) && Boolean(this._healingHeart.parent) && this._healingHeart.parent == this._avatarWorldView)
            {
               this._avatarWorldView.removeChild(this._healingHeart);
            }
         }
      }
      
      private function onTweenStatusTextComplete(param1:GTween) : void
      {
         if(this._avatarWorldView)
         {
            if(Boolean(this._statusText) && Boolean(this._statusText.parent) && this._statusText.parent == this._avatarWorldView)
            {
               this._avatarWorldView.removeChild(this._statusText);
            }
         }
      }
      
      public function levelUp(param1:int) : void
      {
         if(this._avatarWorldView)
         {
            this._avatarWorldView.updateNameBarLevelShape(param1);
         }
         this._levelUpHelperTop = new MediaHelper();
         this._levelUpHelperTop.init(1823,this.onLevelUpTopLoaded);
         this._levelUpHelperBottom = new MediaHelper();
         this._levelUpHelperBottom.init(1875,this.onLevelUpBottomLoaded);
      }
      
      public function handleHit(param1:int) : void
      {
         var _loc2_:AvatarInfo = null;
         if(this._avatarWorldView != null)
         {
            _loc2_ = gMainFrame.userInfo.getAvatarInfoByUserName(this._avatarWorldView.userName);
            if(_loc2_ != null)
            {
               if(_loc2_.questHealthPercentage > 0)
               {
                  this._tintFrames = 13;
                  this.playHitText(String(param1));
                  if(this._avatarWorldView)
                  {
                     this._avatarWorldView.handleOffScreenHit();
                     addEventListener(Event.ENTER_FRAME,this.hitEnterFrameHandler);
                     if(this._avatarWorldView == AvatarManager.playerAvatarWorldView)
                     {
                        QuestManager.playSound("ajq_playerhit");
                     }
                  }
               }
               else if(this._avatarWorldView)
               {
                  this._avatarWorldView.handleOffScreenSleep();
               }
            }
         }
      }
      
      public function playHitText(param1:String) : void
      {
         this.updateAvatarStatus();
         if(!this._avatarWorldView)
         {
         }
      }
      
      public function playStatusText(param1:String) : void
      {
         this._statusText.visible = true;
         this._statusText.alpha = 2;
         this._statusText.text = param1;
         this._statusText.x = this.x - this._statusText.textWidth * 0.5 - this._avatarWorldView.radius * 0.5;
         this._statusText.y = this.y - this._avatarWorldView.radius * 2;
         if(this._statusTextTween)
         {
            this._statusTextTween.resetValues({
               "y":this._statusText.y - 90,
               "alpha":0
            });
            this._statusTextTween.beginning();
            this._statusTextTween.paused = false;
         }
         else
         {
            this._statusTextTween = new GTween(this._statusText,1,{
               "y":this._statusText.y - 90,
               "alpha":0
            },{
               "onComplete":this.onTweenComplete,
               "ease":Linear.easeNone
            });
         }
      }
      
      public function handleHealing(param1:int) : void
      {
         this.updateAvatarStatus();
         if(this._avatarWorldView)
         {
            this._healingHeart.visible = true;
            this._healingHeart.alpha = 2;
            this._healingHeart.x = this.x - this._avatarWorldView.radius * 0.5;
            this._healingHeart.y = this.y - this._avatarWorldView.radius * 2 - 35;
            if(this._healingTween)
            {
               this._healingTween.resetValues({
                  "y":this._healingHeart.y,
                  "alpha":0
               });
               this._healingTween.beginning();
               this._healingTween.paused = false;
            }
            else
            {
               this._healingTween = new GTween(this._healingHeart,1.5,{
                  "y":this._healingHeart.y,
                  "alpha":0
               },{
                  "onComplete":this.onTweenComplete,
                  "ease":Linear.easeNone
               });
            }
            this._avatarWorldView.handleOffScreenSleep(true);
         }
      }
      
      public function destroy() : void
      {
         this.stopItemEmoticonSound();
         if(hasEventListener(Event.ENTER_FRAME))
         {
            removeEventListener(Event.ENTER_FRAME,this.hitEnterFrameHandler);
         }
         if(Boolean(this._levelUpMCTop) && this._levelUpMCTop.hasEventListener(Event.ENTER_FRAME))
         {
            this._levelUpMCTop.removeEventListener(Event.ENTER_FRAME,this.levelUpEnterFrameHandler);
         }
         if(this._playerDamageMC != null)
         {
            this._playerDamageMC.removeEventListener(Event.ENTER_FRAME,this.playerDamageFrameHandler);
         }
         if(this._playerDamageMH != null)
         {
            this._playerDamageMH.destroy();
            this._playerDamageMH = null;
         }
      }
      
      private function soundEnterFrameHandler(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(this._avatarWorldView)
         {
            if(this._itemEmoticonSoundName != null)
            {
               _loc2_ = 1;
               if(this._avatarWorldView != AvatarManager.playerAvatarWorldView)
               {
                  _loc3_ = AvatarManager.playerAvatarWorldView.x - this._avatarWorldView.x;
                  _loc4_ = AvatarManager.playerAvatarWorldView.y - this._avatarWorldView.y;
                  _loc5_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
                  _loc6_ = 5 * 5;
                  _loc7_ = 600 * 600;
                  if(_loc5_ > _loc7_)
                  {
                     _loc2_ = 0;
                  }
                  else if(_loc5_ >= _loc6_)
                  {
                     _loc2_ = 1 - (_loc5_ - _loc6_) / (_loc7_ - _loc6_);
                  }
               }
               if(_loc2_ > 0)
               {
                  if(this._itemEmoticonSound == null)
                  {
                     this._itemEmoticonSound = QuestManager.playLoopingSound(this._itemEmoticonSoundName);
                  }
                  QuestManager.setSoundLevel(this._itemEmoticonSound,_loc2_,this._avatarWorldView);
               }
               else if(this._itemEmoticonSound != null)
               {
                  this._itemEmoticonSound.stop();
                  this._itemEmoticonSound = null;
               }
            }
         }
      }
      
      private function hitEnterFrameHandler(param1:Event) : void
      {
         this.updateAvatarStatus();
         if(this._avatarWorldView)
         {
            if(this._avatarWorldView.isValid())
            {
               --this._tintFrames;
               switch(this._tintFrames)
               {
                  case 10:
                  case 6:
                  case 2:
                     this._avatarWorldView.setBlendColor(0);
                     break;
                  case 12:
                  case 8:
                  case 4:
                     this._avatarWorldView.setBlendColor(3439329279,0,true);
                     break;
                  case 0:
                     removeEventListener(Event.ENTER_FRAME,this.hitEnterFrameHandler);
               }
            }
            else
            {
               removeEventListener(Event.ENTER_FRAME,this.hitEnterFrameHandler);
            }
         }
      }
      
      public function stopItemEmoticonSound() : void
      {
         if(this._itemEmoticonSound != null)
         {
            this._itemEmoticonSound.stop();
            this._itemEmoticonSound = null;
         }
         if(this._itemEmoticonSoundName != null)
         {
            removeEventListener(Event.ENTER_FRAME,this.soundEnterFrameHandler);
            this._itemEmoticonSoundName = null;
         }
      }
      
      public function playItemEmoticonSound(param1:String) : void
      {
         this.stopItemEmoticonSound();
         var _loc2_:int = param1.lastIndexOf(".wav");
         if(_loc2_ > 0)
         {
            param1 = param1.substring(0,_loc2_);
         }
         param1 = param1.toLowerCase();
         this._itemEmoticonSoundName = param1;
         addEventListener(Event.ENTER_FRAME,this.soundEnterFrameHandler);
      }
   }
}

