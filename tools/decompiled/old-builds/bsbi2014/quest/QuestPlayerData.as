package quest
{
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import avatar.NPCView;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.media.SoundChannel;
   import flash.text.TextField;
   import flash.text.TextFormat;
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
      
      private var _avSwitchedNPC:NPCView;
      
      private var _avSwitchNPCID:int;
      
      private var _dropOrbMC:MovieClip;
      
      private var _dropOrbMH:MediaHelper;
      
      public function QuestPlayerData()
      {
         super();
      }
      
      private function updateAvatarStatus() : void
      {
         if(this._avatarWorldView == null)
         {
            this._avatarWorldView = AvatarManager.avatarViewList[this._uID];
            if(Boolean(this._avatarWorldView))
            {
               this._avatarWorldView.addChild(this._statusText);
               this._avatarWorldView.addChild(this._healingHeart);
            }
         }
      }
      
      public function init(uID:int) : void
      {
         this._uID = uID;
         this._avSwitchedNPC = null;
         this._statusText = new TextField();
         this._statusText.multiline = false;
         this._statusText.selectable = false;
         this._statusText.embedFonts = true;
         this._statusText.defaultTextFormat = new TextFormat("TikiIsland-Regular",36,65280);
         this._statusText.filters = [new GlowFilter(0,1,3,3,10,2)];
         this._statusText.visible = false;
         this._healingHeart = GETDEFINITIONBYNAME("questHeartsCont");
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
            this._levelUpLoaded = false;
            if(Boolean(this._levelUpMCTop) && Boolean(this._levelUpMCBottom))
            {
               this._levelUpMCTop.gotoAndPlay("tintOn");
               this._levelUpMCTop.addEventListener(Event.ENTER_FRAME,this.levelUpEnterFrameHandler);
               this._levelUpMCBottom.gotoAndPlay("tintOn");
               this.updateAvatarStatus();
               if(Boolean(this._avatarWorldView))
               {
                  this._avatarWorldView.setBlendColor(4290903190,7534606);
               }
               QuestManager.playSound("ajq_stingerLevelUp");
            }
         }
         else
         {
            this._levelUpLoaded = true;
         }
      }
      
      public function playerDamaged(inMaxHearts:int, inHeartsBeforeDamage:int, inHeartsAfterDamage:int) : void
      {
         if(this._playerDamageMC != null && this._avatarWorldView != null)
         {
            if(this._playerDamageMC.parent != QuestManager._layerManager.room_chat)
            {
               this._pendingPlayerDamageMax = 0;
               this._playerDamageMC.x = this._avatarWorldView.x;
               this._playerDamageMC.y = this._avatarWorldView.y;
               QuestManager._layerManager.room_chat.addChild(this._playerDamageMC);
               this._playerDamageMC.hit(inMaxHearts,inHeartsBeforeDamage,inHeartsAfterDamage);
               this._playerDamageMC.addEventListener(Event.ENTER_FRAME,this.playerDamageFrameHandler);
            }
         }
         else
         {
            this._pendingPlayerDamageMax = inMaxHearts;
            this._pendingPlayerDamageBefore = inHeartsBeforeDamage;
            this._pendingPlayerDamageAfter = inHeartsAfterDamage;
         }
      }
      
      private function onPlayerDamageLoaded(img:MovieClip) : void
      {
         this._playerDamageMC = img;
         this._playerDamageMH.destroy();
         this._playerDamageMH = null;
         if(this._pendingPlayerDamageMax > 0)
         {
            this.playerDamaged(this._pendingPlayerDamageMax,this._pendingPlayerDamageBefore,this._pendingPlayerDamageAfter);
         }
      }
      
      private function onLevelUpTopLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            if(Boolean(this._levelUpMCTop) && Boolean(this._levelUpMCTop.parent))
            {
               this._levelUpMCTop.parent.removeChild(this._levelUpMCTop);
            }
            this._levelUpMCTop = img;
            this.updateAvatarStatus();
            if(Boolean(this._avatarWorldView))
            {
               this._levelUpMCTop.x = this._avatarWorldView.x;
               this._levelUpMCTop.y = this._avatarWorldView.y;
               QuestManager._layerManager.room_chat.addChild(this._levelUpMCTop);
            }
            this.playLevelUpEffect();
         }
      }
      
      private function onLevelUpBottomLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            if(Boolean(this._levelUpMCBottom) && Boolean(this._levelUpMCBottom.parent))
            {
               this._levelUpMCBottom.parent.removeChild(this._levelUpMCBottom);
            }
            this._levelUpMCBottom = img;
            this.updateAvatarStatus();
            if(Boolean(this._avatarWorldView))
            {
               this._avatarWorldView.addChildAt(this._levelUpMCBottom,0);
            }
            this.playLevelUpEffect();
         }
      }
      
      private function playerDamageFrameHandler(e:Event) : void
      {
         if(Boolean(this._avatarWorldView))
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
      }
      
      private function levelUpEnterFrameHandler(e:Event) : void
      {
         if(this._levelUpMCTop != null)
         {
            this._levelUpMCTop.x = this._avatarWorldView.x;
            this._levelUpMCTop.y = this._avatarWorldView.y;
         }
         if(this._levelUpMCTop.currentFrameLabel == "tintOff")
         {
            this.updateAvatarStatus();
            if(Boolean(this._avatarWorldView))
            {
               this._avatarWorldView.setBlendColor(0);
            }
         }
         if(this._levelUpMCTop.currentFrameLabel == "finished")
         {
            this._levelUpMCTop.removeEventListener(Event.ENTER_FRAME,this.levelUpEnterFrameHandler);
         }
      }
      
      private function onTweenComplete(gtween:GTween) : void
      {
         if(Boolean(this._avatarWorldView))
         {
            if(Boolean(this._healingHeart) && Boolean(this._healingHeart.parent) && this._healingHeart.parent == this._avatarWorldView)
            {
               this._avatarWorldView.removeChild(this._healingHeart);
            }
         }
      }
      
      private function onTweenStatusTextComplete(gtween:GTween) : void
      {
         if(Boolean(this._avatarWorldView))
         {
            if(Boolean(this._statusText) && Boolean(this._statusText.parent) && this._statusText.parent == this._avatarWorldView)
            {
               this._avatarWorldView.removeChild(this._statusText);
            }
         }
      }
      
      public function levelUp(newLevel:int) : void
      {
         if(Boolean(this._avatarWorldView))
         {
            this._avatarWorldView.updateNameBarLevelShape(newLevel);
         }
         this._levelUpHelperTop = new MediaHelper();
         this._levelUpHelperTop.init(1823,this.onLevelUpTopLoaded);
         this._levelUpHelperBottom = new MediaHelper();
         this._levelUpHelperBottom.init(1875,this.onLevelUpBottomLoaded);
      }
      
      public function handleHit(healthChange:int) : void
      {
         var ai:AvatarInfo = null;
         if(this._avatarWorldView != null)
         {
            ai = gMainFrame.userInfo.getAvatarInfoByUserName(this._avatarWorldView.userName);
            if(ai != null)
            {
               if(ai.questHealthPercentage > 0)
               {
                  this._tintFrames = 13;
                  this.playHitText(String(healthChange));
                  if(Boolean(this._avatarWorldView))
                  {
                     this._avatarWorldView.handleOffScreenHit();
                     addEventListener(Event.ENTER_FRAME,this.hitEnterFrameHandler);
                     if(this._avatarWorldView == AvatarManager.playerAvatarWorldView)
                     {
                        QuestManager.playSound("ajq_playerhit");
                     }
                  }
               }
               else if(Boolean(this._avatarWorldView))
               {
                  this._avatarWorldView.handleOffScreenSleep();
               }
            }
         }
      }
      
      public function playHitText(hitText:String) : void
      {
         this.updateAvatarStatus();
         if(Boolean(this._avatarWorldView))
         {
         }
      }
      
      public function playStatusText(statusText:String) : void
      {
         this._statusText.visible = true;
         this._statusText.alpha = 2;
         this._statusText.text = statusText;
         this._statusText.x = this.x - this._statusText.textWidth * 0.5 - this._avatarWorldView.radius * 0.5;
         this._statusText.y = this.y - this._avatarWorldView.radius * 2;
         if(Boolean(this._statusTextTween))
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
      
      public function handleHealing(healthChange:int) : void
      {
         this.updateAvatarStatus();
         if(Boolean(this._avatarWorldView))
         {
            this._healingHeart.visible = true;
            this._healingHeart.alpha = 2;
            this._healingHeart.x = this.x - this._avatarWorldView.radius * 0.5;
            this._healingHeart.y = this.y - this._avatarWorldView.radius * 2 - 35;
            if(Boolean(this._healingTween))
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
         if(this._dropOrbMH != null)
         {
            this._dropOrbMH.destroy();
            this._dropOrbMH = null;
         }
         if(this._dropOrbMC != null)
         {
            if(this._dropOrbMC.parent != null)
            {
               this._dropOrbMC.parent.removeChild(this._dropOrbMC);
            }
            this._dropOrbMC = null;
         }
      }
      
      private function soundEnterFrameHandler(e:Event) : void
      {
         var volume:Number = NaN;
         var toTargetX:Number = NaN;
         var toTargetY:Number = NaN;
         var targetRadius:Number = NaN;
         var minRadiusSquared:Number = NaN;
         var maxRadiusSquared:Number = NaN;
         if(Boolean(this._avatarWorldView))
         {
            if(this._itemEmoticonSoundName != null)
            {
               volume = 1;
               if(this._avatarWorldView != AvatarManager.playerAvatarWorldView && Boolean(AvatarManager.playerAvatarWorldView))
               {
                  toTargetX = AvatarManager.playerAvatarWorldView.x - this._avatarWorldView.x;
                  toTargetY = AvatarManager.playerAvatarWorldView.y - this._avatarWorldView.y;
                  targetRadius = toTargetX * toTargetX + toTargetY * toTargetY;
                  minRadiusSquared = 5 * 5;
                  maxRadiusSquared = 600 * 600;
                  if(targetRadius > maxRadiusSquared)
                  {
                     volume = 0;
                  }
                  else if(targetRadius >= minRadiusSquared)
                  {
                     volume = 1 - (targetRadius - minRadiusSquared) / (maxRadiusSquared - minRadiusSquared);
                  }
               }
               if(volume > 0)
               {
                  if(this._itemEmoticonSound == null)
                  {
                     this._itemEmoticonSound = QuestManager.playLoopingSound(this._itemEmoticonSoundName);
                  }
                  QuestManager.setSoundLevel(this._itemEmoticonSound,volume,this._avatarWorldView);
               }
               else if(this._itemEmoticonSound != null)
               {
                  this._itemEmoticonSound.stop();
                  this._itemEmoticonSound = null;
               }
            }
         }
      }
      
      private function hitEnterFrameHandler(e:Event) : void
      {
         this.updateAvatarStatus();
         if(Boolean(this._avatarWorldView))
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
      
      public function playItemEmoticonSound(inSound:String) : void
      {
         this.stopItemEmoticonSound();
         var index:int = inSound.lastIndexOf(".wav");
         if(index > 0)
         {
            inSound = inSound.substring(0,index);
         }
         inSound = inSound.toLowerCase();
         this._itemEmoticonSoundName = inSound;
         addEventListener(Event.ENTER_FRAME,this.soundEnterFrameHandler);
      }
      
      public function setAvatarSwitched(inNpcId:int) : void
      {
         this.updateAvatarStatus();
         if(this._avSwitchedNPC != null)
         {
            if(this._avSwitchedNPC.parent != null)
            {
               this._avSwitchedNPC.parent.removeChild(this._avSwitchedNPC);
            }
            this._avSwitchedNPC.destroy();
            this._avSwitchedNPC = null;
         }
         if(this._avatarWorldView != null)
         {
            this._avatarWorldView.showAvatar();
         }
         this._avSwitchNPCID = inNpcId;
      }
      
      public function onNpcLoaded() : void
      {
         if(this._avatarWorldView != null)
         {
            if(this._avSwitchedNPC != null)
            {
               this._avSwitchedNPC.x = this._avatarWorldView.x;
               this._avSwitchedNPC.y = this._avatarWorldView.y;
               this._avSwitchedNPC.npcMC.setVision(0);
               this._avSwitchedNPC.setNpcState(NPCView.NPC_STATE_IDLE);
            }
         }
      }
      
      public function playerLeftRoom() : void
      {
         if(this._avSwitchedNPC != null)
         {
            if(this._avSwitchedNPC.parent != null)
            {
               this._avSwitchedNPC.parent.removeChild(this._avSwitchedNPC);
            }
            this._avSwitchedNPC.destroy();
            this._avSwitchedNPC = null;
         }
         this._avatarWorldView = null;
      }
      
      public function heartbeat() : void
      {
         if(this._avatarWorldView != null)
         {
            if(this._avSwitchedNPC != null)
            {
               if(this._avSwitchedNPC.x != this._avatarWorldView.x || this._avSwitchedNPC.y != this._avatarWorldView.y)
               {
                  this._avSwitchedNPC.setNpcState(NPCView.NPC_STATE_MOVE,this._avSwitchedNPC.x < this._avatarWorldView.x ? 90 : 270);
                  this._avSwitchedNPC.x = this._avatarWorldView.x;
                  this._avSwitchedNPC.y = this._avatarWorldView.y;
               }
               else
               {
                  this._avSwitchedNPC.setNpcState(NPCView.NPC_STATE_IDLE);
               }
            }
            else if(this._avSwitchNPCID != 0)
            {
               if(this._avatarWorldView.isValid())
               {
                  this._avatarWorldView.hideAvatar();
                  this._avSwitchedNPC = new NPCView();
                  this._avSwitchedNPC.x = this._avatarWorldView.x;
                  this._avSwitchedNPC.y = this._avatarWorldView.y;
                  this._avSwitchedNPC.init(this._avSwitchNPCID,0,-1,false,this.onNpcLoaded);
                  QuestManager._layerManager.room_avatars.addChild(this._avSwitchedNPC);
               }
            }
            if(this._dropOrbMC != null)
            {
               if(Boolean(this._dropOrbMC.removeMe))
               {
                  this._dropOrbMC.parent.removeChild(this._dropOrbMC);
                  this._dropOrbMC = null;
               }
            }
         }
      }
      
      private function onDropOrbLoaded(img:MovieClip) : void
      {
         this._dropOrbMC = img;
         this._dropOrbMC.x = this._avatarWorldView.x;
         this._dropOrbMC.y = this._avatarWorldView.y;
         QuestManager._layerManager.room_chat.addChild(this._dropOrbMC);
      }
      
      public function dropOrb() : void
      {
         if(this._avatarWorldView != null)
         {
            if(this._dropOrbMH != null)
            {
               this._dropOrbMH.destroy();
            }
            this._dropOrbMH = new MediaHelper();
            this._dropOrbMH.init(3588,this.onDropOrbLoaded);
         }
      }
   }
}

