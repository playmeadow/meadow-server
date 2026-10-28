package quest
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
   import com.carlcalderon.arthropod.Debug;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.math.Collision;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBParchmentPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.MinigameManager;
   import game.SoundManager;
   import gui.*;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import room.LayerManager;
   import room.RoomManagerWorld;
   import ru.etcs.utils.getDefinitionNames;
   
   public class QuestManager
   {
      
      private static var _gameCardDefs:Object;
      
      private static var _npcDefs:Object;
      
      public static var _questScriptTimeStamp:String;
      
      private static var _questActorDictionary:Dictionary;
      
      private static var _questActors:Dictionary;
      
      private static var _questPlayersDict:Dictionary;
      
      private static var _questActorGroups:Dictionary;
      
      public static var _layerManager:LayerManager;
      
      private static var _lastGoodAvatarX:int;
      
      private static var _lastGoodAvatarY:int;
      
      private static var _lastClearAvatarX:int;
      
      private static var _lastClearAvatarY:int;
      
      private static var _mediaLoader:MediaHelper;
      
      private static var _talkingPopup:MovieClip;
      
      private static var _adventureJoin:AdventureJoin;
      
      private static var _lastTime:Number;
      
      private static var _frameTime:Number;
      
      private static var _questProjectiles:Array;
      
      private static var _questMelees:Array;
      
      private static var _projectileKeyDown:Boolean;
      
      private static var _currentMeleeID:int;
      
      private static var _inQuestRoom:Boolean;
      
      private static var _playerWeaponTimerProjectile:Number;
      
      private static var _playerWeaponTimerMelee:Number;
      
      private static var _talkingLoadingSpiral:LoadingSpiral;
      
      private static var _levelShapeHelper:MediaHelper;
      
      private static var _actorPriority:int;
      
      private static var _talkingPopupCurrTextPage:int;
      
      private static var _talkingPopupFullText:Array;
      
      private static var _questCommandActor:String;
      
      private static var _questCommandActorState:int;
      
      private static var _questExitPending:Boolean;
      
      private static var _soundMan:SoundManager;
      
      private static var _sounds:Dictionary;
      
      private static var _maxVolumes:Dictionary;
      
      private static var _SFX_Music:Dictionary;
      
      private static var _SFX_AmbientSC:SoundChannel;
      
      private static var _currentMusic:String;
      
      private static var _currentAmbient:String;
      
      private static var _isLoadingTalkingPopup:Boolean;
      
      private static var _paused:Boolean;
      
      private static var _assetPool:Dictionary;
      
      private static var _playerLeftObjects:Array;
      
      private static var _reportWindow:WindowGenerator;
      
      private static var _reportAPlayer:ReportAPlayer;
      
      private static var _questScriptDefId:int;
      
      public static var _questStartingPlayerCount:int;
      
      private static var _questObjectiveText:String;
      
      private static var _draggedSeed:MovieClip;
      
      private static var _defeatedPopUpTimer:Number;
      
      private static var _nearestRespawnPoint:Object;
      
      public static var _playerInStealthVolume:Boolean;
      
      private static var _gameIdleTimer:Number;
      
      private static var _kickPopup:SBOkPopup;
      
      private static var _adventureRewardsPopup:MovieClip;
      
      private static var _rewardsGiftPopup:GiftPopup;
      
      private static var _hasJustJoinedQuest:Boolean;
      
      public static const QUEST_WEAPON_TYPE_MELEE:int = 0;
      
      public static const QUEST_WEAPON_TYPE_PROJECTILE:int = 1;
      
      public static const QUEST_WEAPON_TYPE_BOMB:int = 2;
      
      public static const QUEST_WEAPON_DEFAULT_MELEE:int = 123;
      
      public static const QUEST_WEAPON_DEFAULT_PROJECTILE:int = 0;
      
      public static const QUEST_PLAYER_AVATAR_OFFSETX:int = -15;
      
      public static const QUEST_PLAYER_AVATAR_OFFSETY:int = -40;
      
      public static const QUEST_PLAYER_AVATAR_RADIUS:int = 50;
      
      public static const QUEST_CMD_SET_STATE:int = 1;
      
      public static const QUEST_CMD_SAY:int = 2;
      
      public static const QUEST_CMD_ASK:int = 3;
      
      public static const QUEST_CMD_GAME:int = 4;
      
      public static const QUEST_CMD_TAKE_ITEM:int = 7;
      
      public static const QUEST_CMD_TELEPORT:int = 14;
      
      public static const QUEST_CMD_FOCUS:int = 15;
      
      public static const QUEST_CMD_ON_EXIT:int = 19;
      
      public static const QUEST_CMD_NOTIFY:int = 38;
      
      public static const QUEST_CMD_DEBUGSAY:int = 1001;
      
      public static const QUEST_TINT_TIME:Number = 0.6;
      
      public static const LEVEL_SHAPES:Array = new Array(1845,1844,1847,1848,1849);
      
      private static const TALKING_DIALOGUE_ID:int = 1789;
      
      private static const ADVENTURE_REWARDS_ID:int = 2251;
      
      public function QuestManager()
      {
         super();
      }
      
      public static function get hasJustJoinedQuest() : Boolean
      {
         return _hasJustJoinedQuest;
      }
      
      public static function set hasJustJoinedQuest(param1:Boolean) : void
      {
         _hasJustJoinedQuest = param1;
      }
      
      public static function checkQuestOffScreenUsers() : void
      {
         if(_hasJustJoinedQuest)
         {
            _hasJustJoinedQuest = false;
         }
         else
         {
            AvatarManager.updateAvatarOffscreenToMyPosition();
         }
      }
      
      public static function get projectileKeyDown() : Boolean
      {
         return _inQuestRoom && _projectileKeyDown;
      }
      
      public static function getQuestPlayerData(param1:int) : QuestPlayerData
      {
         if(_questPlayersDict[param1] == null && AvatarManager.avatarViewList[param1] != null)
         {
            _questPlayersDict[param1] = new QuestPlayerData();
            _questPlayersDict[param1].init(param1);
         }
         return _questPlayersDict[param1];
      }
      
      public static function initInitialActorStatus(param1:Object, param2:String) : void
      {
         param1.pendingSwfStateName = "";
         param1.spawnedFromActor = param2;
         switch(param1.type)
         {
            case QuestActor.QUEST_ACTOR_TYPE_DROPPED_TREASURE:
               param1.pickedUp = false;
            case QuestActor.QUEST_ACTOR_TYPE_PLACED_TREASURE:
               param1.status = 0;
               break;
            case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
            case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
            case QuestActor.QUEST_ACTOR_TYPE_PLANT:
               param1.healthPercent = 100;
               param1.respawned = false;
         }
      }
      
      private static function loadQuestSfx(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(param1,onSfxLoaded,true);
      }
      
      private static function onSfxLoaded(param1:MovieClip) : void
      {
         var _loc2_:Class = null;
         var _loc5_:String = null;
         var _loc3_:Array = getDefinitionNames(param1.loaderInfo,false,true);
         param1.initVolumes();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length - 1)
         {
            _loc5_ = _loc3_[_loc4_];
            if((Boolean(_loc5_)) && _loc5_ != "")
            {
               _loc2_ = param1.loaderInfo.applicationDomain.getDefinition(_loc5_) as Class;
               _soundMan.addSound(_loc2_,param1.volumes[_loc5_],_loc5_);
               _sounds[_loc5_.toLowerCase()] = _loc2_;
            }
            _loc4_++;
         }
         param1.mediaHelper.destroy();
         delete param1.mediaHelper;
         delete param1.passback;
      }
      
      public static function playMusic(param1:String, param2:DisplayObject = null) : void
      {
         if(_currentMusic)
         {
            if(_currentMusic != param1)
            {
               _SFX_Music[_currentMusic].stop();
               _soundMan.playStream(_SFX_Music[param1],0,99999);
            }
         }
         else
         {
            _soundMan.playStream(_SFX_Music[param1],0,99999);
         }
         _currentMusic = param1;
      }
      
      public static function playSound(param1:String, param2:DisplayObject = null) : void
      {
         if(param2 == null || isOnscreen(param2))
         {
            _soundMan.play(_sounds[param1.toLowerCase()]);
         }
      }
      
      public static function playLoopingSound(param1:String) : SoundChannel
      {
         return _soundMan.play(_sounds[param1],0,99999);
      }
      
      public static function stopLoopingSound(param1:SoundChannel) : void
      {
         _soundMan.stop(param1);
      }
      
      private static function getStageX(param1:DisplayObject) : Number
      {
         var _loc2_:Number = param1.x;
         var _loc3_:Object = param1;
         while(_loc3_.parent)
         {
            _loc3_ = _loc3_.parent;
            _loc2_ += _loc3_.x;
         }
         return _loc2_;
      }
      
      private static function isOnscreen(param1:DisplayObject) : Boolean
      {
         var _loc2_:Number = param1.x;
         var _loc3_:Number = param1.y;
         var _loc4_:Object = param1;
         while(_loc4_.parent != _layerManager.bkg)
         {
            _loc4_ = _loc4_.parent;
            _loc2_ += _loc4_.x;
            _loc3_ += _loc4_.y;
         }
         _loc4_ = AvatarManager.playerAvatarWorldView;
         var _loc5_:Number = Number(_loc4_.x);
         var _loc6_:Number = Number(_loc4_.y);
         while(_loc4_.parent != _layerManager.bkg)
         {
            _loc4_ = _loc4_.parent;
            _loc5_ += _loc4_.x;
            _loc6_ += _loc4_.y;
         }
         _loc2_ -= _loc5_;
         _loc3_ -= _loc6_;
         return _loc2_ * _loc2_ + _loc3_ * _loc3_ < 360000;
      }
      
      public static function setSoundLevel(param1:SoundChannel, param2:Number, param3:DisplayObject) : void
      {
         var _loc4_:SoundTransform = null;
         var _loc5_:Number = NaN;
         if(param1 != null)
         {
            if(_maxVolumes[param1] == null)
            {
               _maxVolumes[param1] = param1.soundTransform.volume;
            }
            _loc4_ = param1.soundTransform;
            _loc4_.volume = _maxVolumes[param1] * param2;
            _loc5_ = getStageX(param3);
            _loc4_.pan = Math.min(Math.max(_loc5_ / 450 - 1,-1),1);
            param1.soundTransform = _loc4_;
         }
      }
      
      public static function init(param1:LayerManager) : void
      {
         _lastTime = 0;
         _paused = true;
         _questExitPending = false;
         _currentMeleeID = 1;
         _layerManager = param1;
         _questActors = new Dictionary();
         _questPlayersDict = new Dictionary();
         _questProjectiles = new Array();
         _questMelees = new Array();
         _playerWeaponTimerProjectile = 0;
         _playerWeaponTimerMelee = 0;
         _actorPriority = 0;
         _soundMan = new SoundManager(null,2);
         _sounds = new Dictionary(true);
         _maxVolumes = new Dictionary(true);
         _SFX_Music = new Dictionary();
         _SFX_Music["ajq_musquest"] = _soundMan.addStream("ajq_musQuest",0.3);
         _SFX_Music["ajq_musdungeon"] = _soundMan.addStream("ajq_musDungeon",0.3);
         _SFX_Music["ajq_muscave"] = _soundMan.addStream("ajq_musCave",0.3);
         _SFX_Music["ajq_mustutorial"] = _soundMan.addStream("ajq_musTutorial",0.3);
         _SFX_Music["ajq_muscavebossbattle"] = _soundMan.addStream("ajq_musCaveBossBattle",0.3);
         _SFX_Music["ajq_musbunnyburrow"] = _soundMan.addStream("ajq_musbunnyBurrow",0.3);
         _assetPool = new Dictionary();
         _playerLeftObjects = [{
            "icon":new (getDefinitionByName("leaveAdvTxt") as Class)(),
            "hasLeft":false,
            "complete":false
         },{
            "icon":new (getDefinitionByName("leaveAdvTxt") as Class)(),
            "hasLeft":false,
            "complete":false
         },{
            "icon":new (getDefinitionByName("leaveAdvTxt") as Class)(),
            "hasLeft":false,
            "complete":false
         }];
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_UP,keyHandleUp);
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyHandleDown);
         gMainFrame.stage.addEventListener(QuestEvent.LOAD_SFX,onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener(QuestEvent.PLAY_SFX,onQuestEvent,false,0,true);
      }
      
      public static function destroy() : void
      {
         gMainFrame.stage.removeEventListener(KeyboardEvent.KEY_UP,keyHandleUp);
         gMainFrame.stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyHandleDown);
         gMainFrame.stage.removeEventListener(QuestEvent.LOAD_SFX,onQuestEvent);
         gMainFrame.stage.removeEventListener(QuestEvent.PLAY_SFX,onQuestEvent);
         onExitRoom();
         setActorDictionary(null,null);
         clearPlayerDictionary();
      }
      
      private static function onQuestEvent(param1:QuestEvent) : void
      {
         var _loc2_:int = 0;
         switch(param1.type)
         {
            case QuestEvent.LOAD_SFX:
               _loc2_ = int(param1.secondaryType);
               if(_loc2_ > 0)
               {
                  loadQuestSfx(int(param1.secondaryType));
               }
               break;
            case QuestEvent.PLAY_SFX:
               playSound(param1.secondaryType,param1.target as DisplayObject);
         }
      }
      
      public static function actorCollisionTest(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc4_:QuestActor = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc3_:QuestActor = _questActors[param1];
         if(_loc3_)
         {
            _loc5_ = _loc3_.actorOffset;
            _loc5_.x += _loc3_.x;
            _loc5_.y += _loc3_.y;
            _loc6_ = new Point(AvatarManager.playerAvatarWorldView.x + QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.playerAvatarWorldView.y + QUEST_PLAYER_AVATAR_OFFSETY);
            if(Collision.circleHitCircle(_loc5_,_loc3_.collisionRadiusMoving,_loc6_,QUEST_PLAYER_AVATAR_RADIUS))
            {
               return true;
            }
            if(param2)
            {
               return false;
            }
            for each(_loc4_ in _questActors)
            {
               if(!_loc4_.isDead && !_loc4_.isDying && _loc4_.priority > _loc3_.priority && _loc4_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER)
               {
                  _loc6_ = _loc4_.actorOffset;
                  _loc6_.x += _loc4_.x;
                  _loc6_.y += _loc4_.y;
                  if(Collision.circleHitCircle(_loc5_,_loc3_.collisionRadiusMoving,_loc6_,_loc4_.collisionRadiusMoving))
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      public static function mouseHandleDown(param1:MouseEvent) : Boolean
      {
         var _loc3_:Object = null;
         var _loc2_:Point = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
         if(projectileKeyDown)
         {
            playerLaunchWeapon(_loc2_,true);
            if(Boolean(AvatarManager.playerAvatarWorldView) && AvatarManager.playerAvatarWorldView.moving)
            {
               RoomManagerWorld.instance.forceStopMovement();
            }
            AvatarManager.playerAvatarWorldView.faceAnim(_loc2_.x - AvatarManager.playerAvatarWorldView.avatarPos.x,_loc2_.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
            return true;
         }
         for each(_loc3_ in _questActors)
         {
            if(_loc3_.handleMouseDown(_loc2_))
            {
               AvatarManager.playerAvatarWorldView.faceAnim(_loc2_.x - AvatarManager.playerAvatarWorldView.avatarPos.x,_loc2_.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
               return true;
            }
         }
         return false;
      }
      
      private static function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case Keyboard.SHIFT:
               _projectileKeyDown = false;
         }
      }
      
      private static function keyHandleDown(param1:KeyboardEvent) : void
      {
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
         switch(param1.keyCode)
         {
            case Keyboard.SHIFT:
         }
      }
      
      public static function muteChanged(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in _questActors)
         {
            if(_loc2_.alertLP)
            {
               stopLoopingSound(_loc2_.alertLP);
               _loc2_.alertLP = null;
            }
         }
      }
      
      public static function onExitRoom() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         if(_questExitPending)
         {
            _questScriptDefId = 0;
            AvatarManager.setPlayerAttachmentEmot(0,null,0);
            _questExitPending = false;
            gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId).questHealthPercentage = 100;
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = 1;
            _questActorDictionary = null;
            gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,resetMouseDownIdleTimer);
            gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_MOVE,resetMouseMoveIdleTimer);
            if(_kickPopup != null)
            {
               _kickPopup.destroy();
               _kickPopup = null;
            }
            for(_loc2_ in _assetPool)
            {
               delete _assetPool[_loc2_];
            }
            _loc1_ = 0;
            while(_loc1_ < _playerLeftObjects.length)
            {
               _loc3_ = _playerLeftObjects[_loc1_];
               if(Boolean(_loc3_) && Boolean(_loc3_.icon.parent) && _loc3_.icon.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc3_.icon);
               }
               _loc3_.hasLeft = false;
               _loc3_.complete = false;
               _loc1_++;
            }
            RoomManagerWorld.instance.setGridDepth(128);
            if(_currentMusic)
            {
               _SFX_Music[_currentMusic].stop();
            }
            if(Boolean(_currentAmbient) && Boolean(_SFX_AmbientSC))
            {
               _SFX_AmbientSC.stop();
            }
            _currentMusic = _currentAmbient = null;
         }
         _loc1_ = 0;
         while(_loc1_ < _questProjectiles.length)
         {
            _questProjectiles[_loc1_].destroy();
            _loc1_++;
         }
         _questProjectiles.splice(0,_questProjectiles.length);
         _loc1_ = 0;
         while(_loc1_ < _questMelees.length)
         {
            _questMelees[_loc1_].destroy();
            _loc1_++;
         }
         _questMelees.splice(0,_questMelees.length);
         for(_loc2_ in _questActors)
         {
            _questActors[_loc2_].destroy();
            delete _questActors[_loc2_];
         }
         for(_loc2_ in _questPlayersDict)
         {
            _questPlayersDict[_loc2_].destroy();
            delete _questPlayersDict[_loc2_];
         }
         if(_talkingLoadingSpiral)
         {
            _talkingLoadingSpiral.destroy();
            _talkingLoadingSpiral = null;
         }
         _talkingPopup = null;
         _paused = true;
      }
      
      public static function getNearestPlant(param1:Number, param2:Number, param3:Number, param4:int) : QuestActor
      {
         var _loc7_:QuestActor = null;
         var _loc8_:Object = null;
         var _loc9_:Point = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc5_:Number = -1;
         var _loc6_:QuestActor = null;
         param3 *= param3;
         for each(_loc7_ in _questActors)
         {
            if(_loc7_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT && _loc7_.plantTargettable())
            {
               _loc8_ = _loc7_.npcDef;
               if(_loc8_ != null && _loc8_.level <= param4)
               {
                  _loc9_ = _loc7_.actorOffset;
                  _loc10_ = param1 - (_loc7_._actorData.actorPos.x + _loc9_.x);
                  _loc11_ = param2 - (_loc7_._actorData.actorPos.y + _loc9_.y);
                  _loc12_ = _loc10_ * _loc10_ + _loc11_ * _loc11_;
                  if(_loc12_ < param3 && (_loc5_ == -1 || _loc12_ < _loc5_))
                  {
                     _loc6_ = _loc7_;
                     _loc5_ = _loc12_;
                  }
               }
            }
         }
         return _loc6_;
      }
      
      public static function getNearestActivePhantom(param1:Number, param2:Number, param3:Number, param4:int) : QuestActor
      {
         var _loc7_:QuestActor = null;
         var _loc8_:Object = null;
         var _loc9_:Point = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc5_:Number = -1;
         var _loc6_:QuestActor = null;
         param3 *= param3;
         for each(_loc7_ in _questActors)
         {
            if(_loc7_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER && !_loc7_.isDead && _loc7_._seekActive != QuestActor.SEEKTYPE_OFF)
            {
               _loc8_ = _loc7_.npcDef;
               if(_loc8_ != null && _loc8_.level <= param4)
               {
                  _loc9_ = _loc7_.actorOffset;
                  _loc10_ = param1 - (_loc7_.x + _loc9_.x);
                  _loc11_ = param2 - (_loc7_.y + _loc9_.y);
                  _loc12_ = _loc10_ * _loc10_ + _loc11_ * _loc11_;
                  if(_loc12_ < param3 && (_loc5_ == -1 || _loc12_ < _loc5_))
                  {
                     _loc6_ = _loc7_;
                     _loc5_ = _loc12_;
                  }
               }
            }
         }
         return _loc6_;
      }
      
      public static function heartbeat() : void
      {
         var _loc1_:Object = null;
         var _loc2_:* = 0;
         if(!_paused)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_questActorDictionary != null)
            {
               _gameIdleTimer += _frameTime;
               if(_gameIdleTimer > 3 * 60)
               {
                  if(_gameIdleTimer > 4 * 60)
                  {
                     _gameIdleTimer = 0;
                     commandExit(0,null);
                  }
                  else if(_kickPopup == null)
                  {
                     _kickPopup = new SBOkPopup(GuiManager.guiLayer,"Are you still there? Click OK to keep playing.",true,onKickWarningPopup);
                     AJAudio.playIdleWarningSound();
                  }
               }
            }
            if(_defeatedPopUpTimer > 0)
            {
               RoomManagerWorld.instance.forceStopMovement();
               _defeatedPopUpTimer -= _frameTime;
               if(_defeatedPopUpTimer <= 0)
               {
                  new SBParchmentPopup(GuiManager.guiLayer,SBParchmentPopup.TYPE_CONTINUE_ONLY,"The Phantoms have put you in a deep sleep.",true,onDeathAccept);
               }
            }
            if(_playerWeaponTimerProjectile > 0)
            {
               _playerWeaponTimerProjectile -= _frameTime;
            }
            if(_playerWeaponTimerMelee > 0)
            {
               _playerWeaponTimerMelee -= _frameTime;
            }
            actorRadiusCheck();
            for each(_loc1_ in _questActors)
            {
               if(_loc1_.isDead)
               {
                  _loc1_.destroy();
                  delete _questActors[_loc1_._actorId];
               }
               else
               {
                  _loc1_.heartbeat(_frameTime);
               }
            }
            _loc2_ = int(_questProjectiles.length - 1);
            while(_loc2_ >= 0)
            {
               if(_questProjectiles[_loc2_].heartbeat(_frameTime))
               {
                  _questProjectiles[_loc2_].destroy();
                  _questProjectiles.splice(_loc2_,1);
               }
               _loc2_--;
            }
            _loc2_ = int(_questMelees.length - 1);
            while(_loc2_ >= 0)
            {
               if(_questMelees[_loc2_].heartbeat(_frameTime))
               {
                  _questMelees[_loc2_].destroy();
                  _questMelees.splice(_loc2_,1);
               }
               _loc2_--;
            }
         }
      }
      
      public static function meleeRadiusCheck(param1:int, param2:Point, param3:int, param4:Boolean) : Array
      {
         var _loc6_:QuestActor = null;
         var _loc5_:Array = null;
         if(_questActorDictionary != null)
         {
            for each(_loc6_ in _questActors)
            {
               if((param4 ? Boolean(_loc6_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT) : Boolean(_loc6_._actorData.type != QuestActor.QUEST_ACTOR_TYPE_PLANT)) && _loc6_.meleeHitTest(param1,param2,param3))
               {
                  if(_loc5_ == null)
                  {
                     _loc5_ = new Array();
                  }
                  _loc5_.push(_loc6_);
               }
            }
         }
         return _loc5_;
      }
      
      public static function projectileRadiusCheck(param1:int, param2:int, param3:int, param4:Boolean) : QuestActor
      {
         var _loc5_:Point = null;
         var _loc6_:QuestActor = null;
         if(_questActorDictionary != null)
         {
            _loc5_ = new Point(param1,param2);
            for each(_loc6_ in _questActors)
            {
               if((param4 ? Boolean(_loc6_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT) : Boolean(_loc6_._actorData.type != QuestActor.QUEST_ACTOR_TYPE_PLANT)) && _loc6_.hitTest(_loc5_,param3))
               {
                  return _loc6_;
               }
            }
         }
         return null;
      }
      
      private static function actorRadiusCheck() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         if(!AvatarManager.playerAvatarWorldView || !AvatarManager.playerAvatarWorldView.moving)
         {
            return;
         }
         if(_questActorDictionary != null)
         {
            _loc2_ = false;
            for each(_loc3_ in _questActors)
            {
               if(_loc3_.onRadiusTest())
               {
                  _loc2_ = true;
               }
            }
            if(!_loc2_)
            {
               _lastGoodAvatarX = AvatarManager.playerAvatarWorldView.avatarPos.x;
               _lastGoodAvatarY = AvatarManager.playerAvatarWorldView.avatarPos.y;
            }
         }
         var _loc1_:Object = RoomManagerWorld.instance.getNearestQuestRespawnPointPlayerIsIn(AvatarManager.playerAvatarWorldView.avatarPos);
         if(_loc1_ != null)
         {
            _nearestRespawnPoint = _loc1_;
         }
         _playerInStealthVolume = RoomManagerWorld.instance.volumeManager.testStealthVolumes(AvatarManager.playerAvatarWorldView.avatarPos) != null;
      }
      
      public static function setActorDictionary(param1:Dictionary, param2:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         _defeatedPopUpTimer = 0;
         _questScriptTimeStamp = param2;
         if(_questActors != null)
         {
            for(_loc4_ in _questActors)
            {
               _questActors[_loc4_].destroy();
               delete _questActors[_loc4_];
            }
         }
         _questActorDictionary = param1;
         _gameIdleTimer = 0;
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,resetMouseDownIdleTimer,false);
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_MOVE,resetMouseMoveIdleTimer,false);
         _questActorGroups = new Dictionary();
         for(_loc3_ in _questActorDictionary)
         {
            _loc5_ = _loc3_.lastIndexOf("__");
            if(_loc5_ != -1)
            {
               _loc6_ = _loc3_.substring(0,_loc5_);
               _loc7_ = _questActorGroups[_loc6_];
               if(_loc7_ == null)
               {
                  _loc7_ = new Array();
                  _questActorGroups[_loc6_] = _loc7_;
               }
               _loc7_.push(_loc3_);
            }
         }
      }
      
      public static function clearPlayerDictionary() : void
      {
         var _loc1_:Object = null;
         if(_questPlayersDict != null)
         {
            for(_loc1_ in _questPlayersDict)
            {
               _questPlayersDict[_loc1_].destroy();
               delete _questPlayersDict[_loc1_];
            }
         }
         _questPlayersDict = null;
      }
      
      public static function sceneAssetsLoaded() : void
      {
         var _loc1_:String = null;
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:Point = null;
         var _loc6_:Array = null;
         var _loc7_:Object = null;
         if(_questActorDictionary != null)
         {
            _nearestRespawnPoint = null;
            if(_questObjectiveText != null && GuiManager.mainHud.objBar != null)
            {
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#notify/" + _questObjectiveText);
               GuiManager.mainHud.questObjectiveTxt.text = _questObjectiveText;
               GuiManager.mainHud.objBar.gotoAndPlay("on");
            }
            else
            {
               GuiManager.mainHud.questObjectiveTxt.text = "";
            }
            if(GuiManager.mainHud.questReportBtn != null)
            {
               GuiManager.mainHud.questReportBtn.activateGrayState(_questStartingPlayerCount <= 1);
            }
            GuiManager.mainHud["inventoriesWindow0"].visible = false;
            GuiManager.mainHud["inventoriesWindow1"].visible = false;
            GuiManager.mainHud["inventoriesWindow2"].visible = false;
            GuiManager.mainHud["inventoriesWindow3"].visible = false;
            GuiManager.mainHud["inventoriesWindow4"].visible = false;
            _paused = false;
            if(AvatarManager.playerAvatarWorldView)
            {
               _lastGoodAvatarX = AvatarManager.playerAvatarWorldView.avatarPos.x;
               _lastGoodAvatarY = AvatarManager.playerAvatarWorldView.avatarPos.y;
            }
            else
            {
               _lastGoodAvatarX = 0;
               _lastGoodAvatarY = 0;
            }
            for(_loc1_ in _questActorDictionary)
            {
               _loc2_ = _questActorDictionary[_loc1_];
               if(_loc2_ == null)
               {
                  continue;
               }
               switch(_loc2_.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMEPLACEMENT:
                     _loc3_ = RoomManagerWorld.instance.volumeManager.findVolume(_loc1_);
                     if(_loc3_ != null)
                     {
                        initQuestActor(_loc1_,0,0,null,null);
                     }
                     break;
                  case QuestActor.QUEST_ACTOR_TYPE_SPAWN:
                     _loc4_ = RoomManagerWorld.instance.findSpawn(null,_loc1_);
                     if(_loc4_ != null)
                     {
                        _loc5_ = new Point(_loc4_.x,_loc4_.y);
                        RoomManagerWorld.instance.convertToWorldSpace(_loc5_);
                        initQuestActor(_loc1_,0,0,null,_loc5_);
                     }
                     break;
                  case QuestActor.QUEST_ACTOR_TYPE_TILE:
                     if(_loc2_.state > 0)
                     {
                        _loc6_ = RoomManagerWorld.instance.findLayers(_loc1_);
                        if(_loc6_ != null)
                        {
                           for each(_loc7_ in _loc6_)
                           {
                              if(_loc7_.s.content["setState"] != null)
                              {
                                 _loc7_.s.content.setState(_loc2_.state,true);
                              }
                              else
                              {
                                 _loc1_ = _loc1_;
                              }
                           }
                        }
                     }
                     break;
                  default:
                     if(_loc2_.spawnedFromActor != null)
                     {
                        doSpawnToRoot(_loc2_);
                     }
               }
            }
         }
      }
      
      public static function recycle(param1:int, param2:Object) : void
      {
         if(_assetPool[param1] == null)
         {
            _assetPool[param1] = new Array();
         }
         _assetPool[param1].push(param2);
      }
      
      private static function getQuestAsset(param1:int) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Array = _assetPool[param1];
         if(Boolean(_loc3_) && _loc3_.length > 0)
         {
            return _loc3_.pop();
         }
         return null;
      }
      
      public static function initQuestActor(param1:String, param2:int, param3:int, param4:Object = null, param5:Point = null, param6:Point = null) : void
      {
         var _loc7_:Boolean = false;
         var _loc8_:QuestActor = null;
         var _loc9_:Array = null;
         var _loc10_:Object = null;
         if(_questActorDictionary != null)
         {
            if(param4 == null)
            {
               param4 = _questActorDictionary[param1];
            }
            if(param4 != null)
            {
               if(!param4.hasOwnProperty("actorPos"))
               {
                  param4.actorPos = param5;
               }
               if(_questActors[param1] != null)
               {
                  _questActors[param1].destroy();
               }
               _loc7_ = true;
               switch(param4.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
                  case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
                     if(param4.healthPercent == 0)
                     {
                     }
               }
               if(_loc7_)
               {
                  if(param4.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER || param4.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY || param4.type == QuestActor.QUEST_ACTOR_TYPE_PLANT || param4.type == QuestActor.QUEST_ACTOR_TYPE_NPC)
                  {
                  }
                  if(_loc8_ == null)
                  {
                     _loc8_ = new QuestActor();
                     _loc8_.initActor(param1,param4,param2,param3,_actorPriority++,param6);
                  }
                  else
                  {
                     _loc8_.resetActor(param1,param4,param2,param3,_actorPriority++,param6);
                  }
                  _loc8_.setRequireClick(param4.requireClick);
                  _loc8_.setVisible(param4.visible);
                  _questActors[param1] = _loc8_;
                  switch(param4.type)
                  {
                     case QuestActor.QUEST_ACTOR_TYPE_TILE:
                        _loc9_ = RoomManagerWorld.instance.findLayers(param1);
                        if(_loc9_ != null)
                        {
                           for each(_loc10_ in _loc9_)
                           {
                              if(_loc10_.s.content["setState"] != null)
                              {
                                 _loc10_.s.content.setState(param4.state,true);
                              }
                              else
                              {
                                 param1 = param1;
                              }
                           }
                        }
                  }
               }
            }
         }
      }
      
      public static function commandDebugSay(param1:int, param2:Object) : void
      {
         new SBOkPopup(GuiManager.guiLayer,param2[param1++],true);
      }
      
      public static function commandNotify(param1:int, param2:Object) : void
      {
         _questObjectiveText = param2[param1++];
         if(GuiManager.mainHud.questObjectiveTxt != null && GuiManager.mainHud.objBar != null)
         {
            SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#notify/" + _questObjectiveText);
            GuiManager.mainHud.questObjectiveTxt.text = _questObjectiveText;
            GuiManager.mainHud.objBar.gotoAndPlay("on");
            playSound("ajq_questNotification");
         }
      }
      
      public static function commandSay(param1:int, param2:Object) : void
      {
         if(_talkingPopup != null)
         {
            onTalkingPopupClose(null);
         }
         _questCommandActor = null;
         _questCommandActorState = -1;
         var _loc3_:QuestActor = _questActors[param2[param1++]];
         var _loc4_:String = param2[param1++];
         var _loc5_:int = int(param2[param1++]);
         if(_loc5_ == 1)
         {
            if(_loc3_ != null)
            {
               _loc3_.setChatBalloonText(_loc4_);
            }
         }
         else
         {
            showTalkingDialog(GuiManager.guiLayer,_loc4_.split("|"),_loc3_ != null ? _loc3_.talkingHeadMediaRef : 0);
         }
      }
      
      public static function commandAsk(param1:int, param2:Object) : void
      {
         if(_talkingPopup != null)
         {
            onTalkingPopupClose(null);
         }
         var _loc3_:int = int(param2[param1++]);
         _questCommandActor = param2[param1++];
         _questCommandActorState = param2[param1++];
         var _loc4_:QuestActor = _questActors[_questCommandActor];
         showTalkingDialog(GuiManager.guiLayer,param2[param1++].split("|"),_loc4_ != null ? _loc4_.talkingHeadMediaRef : 0,-1,_loc3_ == 1);
      }
      
      private static function onCommandAskConfirm(param1:Boolean) : void
      {
         if(_questCommandActor != "" && _questCommandActorState != -1)
         {
            QuestXtCommManager.questAskComplete(_questCommandActor,_questCommandActorState,param1 == true ? 1 : 0);
            _questCommandActor = null;
            _questCommandActorState = -1;
         }
      }
      
      public static function commandSetState(param1:int, param2:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Array = null;
         var _loc9_:Object = null;
         _loc4_ = param2[param1++];
         _loc3_ = _questActorDictionary[_loc4_];
         if(_loc3_ != null)
         {
            _loc5_ = int(param2[param1++]);
            _loc6_ = param2[param1++] == 1;
            _loc7_ = param2[param1++] == 1;
            _loc3_.requireClick = _loc7_;
            _loc3_.visible = _loc6_;
            _loc3_.state = _loc5_;
            switch(_loc3_.type)
            {
               case QuestActor.QUEST_ACTOR_TYPE_TILE:
                  _loc8_ = RoomManagerWorld.instance.findLayers(_loc4_);
                  if(_loc8_ != null)
                  {
                     for each(_loc9_ in _loc8_)
                     {
                        if(_loc9_.s != null && _loc9_.s.content != null)
                        {
                           if(_loc9_.s.content["setState"] != null)
                           {
                              _loc9_.s.content.setState(_loc3_.state);
                           }
                           else
                           {
                              _loc4_ = _loc4_;
                           }
                        }
                     }
                  }
                  break;
               case QuestActor.QUEST_ACTOR_TYPE_VARIABLE:
                  QuestXtCommManager.questActorTriggered(_loc4_);
                  break;
               default:
                  _loc3_ = _questActors[_loc4_];
                  if(_loc3_ != null)
                  {
                     _loc3_.setRequireClick(_loc7_);
                     _loc3_.setVisible(_loc6_);
                     _loc3_.onRadiusTest();
                  }
            }
         }
      }
      
      public static function commandTeleport(param1:int, param2:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc5_:Boolean = param2[param1++] == "1";
         if(_loc5_)
         {
            _loc4_ = param2[param1++];
            _loc3_ = _questActors[_loc4_];
            if(_loc3_ != null)
            {
               RoomManagerWorld.instance.teleportPlayer(_loc3_.x,_loc3_.y,true);
            }
         }
         else
         {
            _loc6_ = param2[param1++];
            RoomManagerWorld.instance.setGotoSpawnPoint(_loc6_);
         }
      }
      
      public static function commandFocus(param1:int, param2:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         _loc4_ = param2[param1++];
         _loc3_ = _questActors[_loc4_];
         if(_loc3_ != null)
         {
            RoomManagerWorld.instance.setCameraFocus(new Point(_loc3_.x,_loc3_.y),0.75,1.5,0.75,true);
         }
      }
      
      public static function commandExit(param1:int, param2:Object) : void
      {
         _questExitPending = true;
         _questObjectiveText = "";
         AvatarManager.setPlayerAttachmentEmot(0,null,0);
         RoomManagerWorld.instance.setGotoSpawnPoint("quest_end");
         QuestXtCommManager.sendQuestExit();
      }
      
      public static function commandTakeItem(param1:int, param2:Object) : void
      {
         AvatarManager.setPlayerAttachmentEmot(0,null,0);
      }
      
      public static function commandGame(param1:int, param2:Object) : void
      {
         var _loc3_:int = int(param2[param1++]);
         _questCommandActor = param2[param1++];
         _questCommandActorState = param2[param1++];
         DarkenManager.showLoadingSpiral(true);
         MinigameManager.handleGameClick({
            "idx":5,
            "r":30,
            "spawn":"spawn",
            "type":0,
            "typeDefId":_loc3_,
            "x":0,
            "y":0
         },null,true,null);
         RoomManagerWorld.instance.setGotoSpawnLocation(_lastGoodAvatarX,_lastGoodAvatarY);
      }
      
      public static function handleCommand(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         switch(_loc3_)
         {
            case QUEST_CMD_SET_STATE:
               commandSetState(_loc2_,param1);
               break;
            case QUEST_CMD_NOTIFY:
               commandNotify(_loc2_,param1);
               break;
            case QUEST_CMD_SAY:
               DebugUtility.debugTrace("receiving quest ask command with actor:" + param1[_loc2_],Debug.RED);
               commandSay(_loc2_,param1);
               break;
            case QUEST_CMD_ASK:
               DebugUtility.debugTrace("receiving quest ask command with actor:" + param1[_loc2_ + 1],Debug.RED);
               commandAsk(_loc2_,param1);
               break;
            case QUEST_CMD_GAME:
               commandGame(_loc2_,param1);
               break;
            case QUEST_CMD_TELEPORT:
               commandTeleport(_loc2_,param1);
               break;
            case QUEST_CMD_FOCUS:
               commandFocus(_loc2_,param1);
               break;
            case QUEST_CMD_ON_EXIT:
               commandExit(_loc2_,param1);
               break;
            case QUEST_CMD_TAKE_ITEM:
               commandTakeItem(_loc2_,param1);
               break;
            case QUEST_CMD_DEBUGSAY:
               commandDebugSay(_loc2_,param1);
         }
      }
      
      public static function showTalkingDialog(param1:DisplayLayer, param2:Array, param3:int = 0, param4:int = -1, param5:Boolean = false) : void
      {
         var avt:AvatarView = null;
         var o:Object = null;
         var popupLayer:DisplayLayer = param1;
         var fullTextSplit:Array = param2;
         var talkingHeadMediaRef:int = param3;
         var streamId:int = param4;
         var useYesNo:Boolean = param5;
         if(_talkingPopup)
         {
            SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#dialog/" + (fullTextSplit.length > 1 ? fullTextSplit[1].substr(0,30) : fullTextSplit[0].substr(0,30)));
            _talkingPopup.txt.autoSize = TextFieldAutoSize.CENTER;
            DarkenManager.showLoadingSpiral(false);
            if(talkingHeadMediaRef == 0)
            {
               _talkingPopup.gotoAndStop("questingPopup");
               _talkingPopup.txt.text = fullTextSplit.length > 1 ? fullTextSplit[1] : fullTextSplit[0];
            }
            else
            {
               _talkingPopup.gotoAndStop("talkingHead");
               _talkingPopup.talkingHeadTitleTxt.text = fullTextSplit[0];
               _talkingPopup.txt.text = fullTextSplit[1];
               while(_talkingPopup.viewHolder.itemWindow.numChildren > 1)
               {
                  o = _talkingPopup.viewHolder.itemWindow.getChildAt(1);
                  if(o is Avatar)
                  {
                     o.destroy();
                  }
                  _talkingPopup.viewHolder.itemWindow.removeChildAt(1);
               }
               if(!_talkingLoadingSpiral)
               {
                  _talkingLoadingSpiral = new LoadingSpiral(_talkingPopup.itemRenderPlaceholder.itemWindow,_talkingPopup.itemRenderPlaceholder.itemWindow.width * 0.5,_talkingPopup.itemRenderPlaceholder.itemWindow.height * 0.5);
               }
               else
               {
                  _talkingLoadingSpiral.visible = true;
               }
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(talkingHeadMediaRef,onTalkingHeadMediaLoaded);
            }
            _talkingPopupFullText = fullTextSplit;
            _talkingPopupCurrTextPage = 1;
            if(useYesNo)
            {
               _talkingPopup.okBtn.visible = false;
               _talkingPopup.nextBtn.visible = false;
               _talkingPopup.yesBtn.addEventListener(MouseEvent.MOUSE_DOWN,onYesBtn,false,0,true);
               _talkingPopup.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,onNoBtn,false,0,true);
            }
            else
            {
               _talkingPopup.yesBtn.visible = false;
               _talkingPopup.noBtn.visible = false;
               if(_talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
               {
                  _talkingPopup.nextBtn.visible = false;
               }
               else
               {
                  _talkingPopup.okBtn.visible = false;
               }
               _talkingPopup.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,onOkBtn,false,0,true);
               _talkingPopup.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,onOkBtn,false,0,true);
            }
            updateTalkingPopupSize();
            with(_talkingPopup)
            {
               
               addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
               bx.addEventListener(MouseEvent.MOUSE_DOWN,onTalkingPopupClose,false,0,true);
               if(useYesNo)
               {
                  bx.visible = false;
               }
               else
               {
                  bx.visible = true;
               }
               x = MainFrame.VIEW_WIDTH * 0.5;
               y = MainFrame.VIEW_HEIGHT * 0.5;
            }
            popupLayer.addChild(_talkingPopup);
            DarkenManager.darken(_talkingPopup);
         }
         else if(!_isLoadingTalkingPopup)
         {
            _isLoadingTalkingPopup = true;
            DarkenManager.showLoadingSpiral(true);
            _mediaLoader = new MediaHelper();
            _mediaLoader.init(TALKING_DIALOGUE_ID,onTalkingDialogLoaded,{
               "popupLayer":popupLayer,
               "fullTextSplit":fullTextSplit,
               "talkingHeadMediaRef":talkingHeadMediaRef,
               "streamId":streamId,
               "useYesNo":useYesNo
            });
         }
      }
      
      private static function updateTalkingPopupSize() : void
      {
         with(_talkingPopup)
         {
            bg.m.height = Math.floor(currentFrameLabel == "questingPopup" ? txt.textHeight + (txt.y + (txt.y + 93 + 5)) : Math.max(73.05,txt.textHeight + (txt.y + (txt.y + 93 + 5))));
            bg.b.y = Math.floor(bg.m.y + bg.m.height);
            yesBtn.y = noBtn.y = txt.y + txt.textHeight + yesBtn.height * 0.5;
            okBtn.y = yesBtn.y + 3;
            nextBtn.y = okBtn.y;
         }
      }
      
      private static function onLevelShapeLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            GuiManager.updateXPShape(param1);
         }
      }
      
      private static function onTalkingDialogLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = null;
         if(param1)
         {
            _isLoadingTalkingPopup = false;
            _talkingPopup = MovieClip(param1.getChildAt(0));
            _loc2_ = param1.passback;
            showTalkingDialog(_loc2_.popupLayer,_loc2_.fullTextSplit,_loc2_.talkingHeadMediaRef,_loc2_.streamId,_loc2_.useYesNo);
         }
      }
      
      private static function onTalkingHeadMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_talkingPopup != null)
            {
               _talkingPopup.itemRenderPlaceholder.itemWindow.addChild(param1);
               _talkingLoadingSpiral.visible = false;
            }
         }
      }
      
      private static function onAdventureRewardsLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _adventureRewardsPopup = MovieClip(param1.getChildAt(0));
            _adventureRewardsPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _adventureRewardsPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            _adventureRewardsPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            _loc2_ = 1;
            while(_loc2_ <= 5)
            {
               _adventureRewardsPopup["opt" + _loc2_].addEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions,false,0,true);
               _adventureRewardsPopup["opt" + _loc2_].index = _loc2_ - 1;
               _adventureRewardsPopup["opt" + _loc2_].prize = param1.passback[_loc2_ - 1];
               _loc2_++;
            }
            GuiManager.guiLayer.addChild(_adventureRewardsPopup);
            DarkenManager.darken(_adventureRewardsPopup);
         }
      }
      
      private static function onAdventureRewardsOptions(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         _adventureRewardsPopup.giftIndexChosen = param1.currentTarget.index;
         switch(param1.currentTarget.prize.type)
         {
            case 1:
               _loc2_ = new DenItem();
               _loc2_.initShopItem(param1.currentTarget.prize.defID,param1.currentTarget.prize.versionId);
               _loc3_ = GiftPopup.GIFT_TYPE_DEN_ACC;
               break;
            case 2:
               _loc2_ = new Item();
               _loc2_.init(param1.currentTarget.prize.defID,0,param1.currentTarget.prize.color,0,0,true);
               _loc3_ = GiftPopup.GIFT_TYPE_CLOTHING;
               break;
            case 3:
               _loc3_ = GiftPopup.GIFT_TYPE_GEMS;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(StartupPopups.GEMS_MEDIA_ID,rewardsGemOrOrbLoaded,{
                  "giftType":_loc3_,
                  "amount":param1.currentTarget.prize.amount + " Gems"
               });
               return;
            case 4:
               _loc3_ = GiftPopup.GIFT_TYPE_ORBS;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(StartupPopups.DIAMOND_MEDIA_ID,rewardsGemOrOrbLoaded,{
                  "giftType":_loc3_,
                  "amount":param1.currentTarget.prize.amount + " Orbs"
               });
               return;
         }
         _rewardsGiftPopup = new GiftPopup();
         _rewardsGiftPopup.init(GuiManager.guiLayer,_loc2_.largeIcon,_loc2_.name,GiftPopup.POPUP_TYPE_ADVENTURES,_loc3_,onKeepRewardsGift,onKeepRewardsGift,null,false,GiftPopup.BUTTONS_TYPE_KEEP_DISCARD);
      }
      
      private static function rewardsGemOrOrbLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _rewardsGiftPopup = new GiftPopup();
         _rewardsGiftPopup.init(GuiManager.guiLayer,param1,param1.passback.amount,GiftPopup.POPUP_TYPE_ADVENTURES,param1.passback.giftType,onKeepRewardsGift,onKeepRewardsGift,null,false,GiftPopup.BUTTONS_TYPE_KEEP_DISCARD);
      }
      
      private static function onKeepRewardsGift() : void
      {
         QuestXtCommManager.sendPickGiftResult(_adventureRewardsPopup.giftIndexChosen);
         _rewardsGiftPopup.destroy();
         _rewardsGiftPopup = null;
         _adventureRewardsPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
         var _loc1_:int = 1;
         while(_loc1_ <= 5)
         {
            _adventureRewardsPopup["opt" + _loc1_].removeEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions);
            _loc1_++;
         }
         DarkenManager.unDarken(_adventureRewardsPopup);
         GuiManager.guiLayer.removeChild(_adventureRewardsPopup);
         _adventureRewardsPopup = null;
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onTalkingPopupClose(param1:MouseEvent) : void
      {
         if(param1 != null)
         {
            param1.stopPropagation();
         }
         if(_talkingPopup)
         {
            _talkingPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            _talkingPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onTalkingPopupClose);
            if(_talkingPopup.currentFrameLabel == "response")
            {
               _talkingPopup.yesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onYesBtn);
               _talkingPopup.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onNoBtn);
            }
            else if(_talkingPopup.currentFrameLabel == "ok")
            {
               _talkingPopup.okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onOkBtn);
            }
            _talkingPopup.parent.removeChild(_talkingPopup);
            DarkenManager.unDarken(_talkingPopup);
            _talkingPopup = null;
            onCommandAskConfirm(true);
         }
      }
      
      private static function onYesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onCommandAskConfirm(true);
         onTalkingPopupClose(param1);
      }
      
      private static function onNoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onCommandAskConfirm(false);
         onTalkingPopupClose(param1);
      }
      
      private static function onOkBtn(param1:MouseEvent) : void
      {
         if(_talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
         {
            onTalkingPopupClose(param1);
            return;
         }
         if(_talkingPopup)
         {
            ++_talkingPopupCurrTextPage;
            _talkingPopup.txt.text = _talkingPopupFullText[_talkingPopupCurrTextPage];
            if(_talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
            {
               _talkingPopup.nextBtn.visible = false;
               _talkingPopup.okBtn.visible = true;
            }
            else
            {
               _talkingPopup.okBtn.visible = false;
               _talkingPopup.nextBtn.visible = true;
            }
            updateTalkingPopupSize();
         }
      }
      
      public static function handleQuestStartResponse(param1:Object) : void
      {
         var _loc2_:* = 2;
         _questScriptDefId = param1[_loc2_++];
         _questStartingPlayerCount = param1[_loc2_++];
         _questObjectiveText = "";
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#NumPlayers/" + _questStartingPlayerCount);
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
         }
         loadQuestSfx(1970);
         RoomManagerWorld.instance.setGridDepth(25);
      }
      
      public static function handleQuestWaitResponse(param1:Object) : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.handleWaitResponse(param1);
         }
      }
      
      public static function handleQuestJoinCancelResponse(param1:Object) : void
      {
      }
      
      public static function handleQuestJoinResponse(param1:Object) : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
         }
         _adventureJoin = new AdventureJoin();
         _adventureJoin.init(param1[4],adventureJoinClose);
      }
      
      public static function handleAttackPlayer(param1:Object) : void
      {
         var _loc2_:QuestActor = null;
         var _loc3_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:uint = 0;
         var _loc4_:* = 2;
         _loc3_ = param1[_loc4_++];
         _loc2_ = _questActors[_loc3_];
         if(_loc2_ != null)
         {
            _loc5_ = int(param1[_loc4_++]);
            _loc6_ = int(param1[_loc4_++]);
            _loc7_ = uint(param1[_loc4_++]);
            _loc2_.handleAttackPlayer(_loc6_,_loc7_,_loc5_);
         }
      }
      
      public static function handleQuestActorPositionUpdateResponse(param1:Object) : void
      {
         var _loc2_:QuestActor = null;
         var _loc3_:String = null;
         var _loc4_:* = 2;
         _loc3_ = param1[_loc4_++];
         var _loc5_:int = int(param1[_loc4_++]);
         var _loc6_:int = int(param1[_loc4_++]);
         var _loc7_:Object = _questActorDictionary[_loc3_];
         if(_loc7_ != null)
         {
            _loc7_.actorPos = new Point(_loc5_,_loc6_);
         }
         _loc2_ = _questActors[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handlePositionUpdate(_loc5_,_loc6_,param1[_loc4_++],param1[_loc4_++]);
         }
      }
      
      public static function handleQuestActorRequestSeekResponse(param1:Object) : void
      {
         var _loc2_:QuestActor = null;
         var _loc3_:String = null;
         var _loc4_:* = 2;
         _loc3_ = param1[_loc4_++];
         _loc2_ = _questActors[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handleRequestSeekResponse(param1[_loc4_++]);
         }
      }
      
      public static function handleLaunchProjectile(param1:Object) : void
      {
         var _loc10_:AvatarWorldView = null;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:String = param1[_loc2_++];
         var _loc7_:int = int(param1[_loc2_++]);
         var _loc8_:uint = uint(param1[_loc2_++]);
         var _loc9_:QuestActor = null;
         if(_loc7_ > 0)
         {
            _loc10_ = AvatarManager.avatarViewList[_loc7_];
            if(_loc10_ == null)
            {
               return;
            }
            _loc10_.faceAnim(_loc4_ - _loc10_.avatarPos.x,_loc5_ - _loc10_.avatarPos.y,false);
         }
         else
         {
            _loc9_ = _questActors[_loc6_];
         }
         launchProjectile(_loc3_,_loc8_,_loc4_,_loc5_,_loc9_,_loc10_);
      }
      
      public static function handleSetSwfState(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:String = param1[_loc2_++];
         var _loc5_:Object = _questActorDictionary[_loc3_];
         if(_loc5_ != null)
         {
            _loc5_.pendingSwfStateName = _loc4_;
         }
         var _loc6_:QuestActor = _questActors[_loc3_];
         if(_loc6_ != null)
         {
            _loc6_.setSwfState(_loc4_);
         }
      }
      
      public static function handleLoadMediaLib(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         loadQuestSfx(_loc3_);
      }
      
      public static function handlePickUpItem(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:Boolean = false;
         var _loc7_:QuestActor = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         switch(_loc3_)
         {
            case 0:
               new SBOkPopup(GuiManager.guiLayer,"You already have an item!");
               break;
            case 1:
            case 3:
               _loc4_ = param1[_loc2_++];
               _loc5_ = _questActorDictionary[_loc4_];
               if(_loc5_ != null)
               {
                  _loc6_ = _loc3_ == 3 || _loc5_.type == QuestActor.QUEST_ACTOR_TYPE_GROUP_ITEM;
                  _loc5_.visible = _loc6_;
                  _loc7_ = _questActors[_loc4_];
                  if(_loc7_ != null)
                  {
                     _loc8_ = int(param1[_loc2_++]);
                     _loc7_.setVisible(_loc6_);
                     if(_loc8_ == AvatarManager.playerSfsUserId)
                     {
                        _loc9_ = _loc3_ == 3 ? 0 : UserCommXtCommManager.getEmoticonDefId(_loc7_._actorData.defId);
                        AvatarManager.setPlayerAttachmentEmot(_loc9_,null,0);
                        AvatarManager._setAvatarAttachmentEmot(_loc3_ == 3 ? 0 : int(_loc7_._actorData.defId),"",_loc8_);
                        if(Boolean(_loc7_._mediaObject) && _loc7_._mediaObject.hasOwnProperty("playPickupSound"))
                        {
                           _loc7_._mediaObject.playPickupSound();
                        }
                     }
                  }
               }
               break;
            case 2:
               new SBOkPopup(GuiManager.guiLayer,"Another player has picked up this item!");
         }
      }
      
      public static function handleStatsUpdate(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
         if(_loc3_ != null)
         {
            _loc3_.attackBase = param1[_loc2_++];
            _loc3_.attackMax = param1[_loc2_++];
            _loc3_.defenseBase = param1[_loc2_++];
            _loc3_.defenseMax = param1[_loc2_++];
            gMainFrame.userInfo.setAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId,_loc3_);
         }
      }
      
      public static function handleLevelUp(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:QuestPlayerData = getQuestPlayerData(_loc3_);
         if(_loc5_ != null)
         {
            _loc5_.levelUp(_loc4_);
         }
      }
      
      public static function handleXpUpdate(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:int = int(param1[_loc2_++]);
         var _loc7_:Number = Number(param1[_loc2_++]);
         var _loc8_:String = param1[_loc2_++];
         var _loc9_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
         _loc9_.questXp = _loc4_;
         _loc9_.questLevel = _loc6_;
         _loc9_.questXPPercentage = _loc7_;
         GuiManager.addQuestXP(_loc7_);
         var _loc10_:QuestActor = _questActors[_loc8_];
         if(_loc10_ != null)
         {
            _loc10_.setActorText("courage +" + _loc3_);
         }
         if(_loc5_ < _loc6_)
         {
            SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#levelUp/" + _loc6_);
            if(_loc6_ % 5 == 0)
            {
               loadLevelShape(_loc6_);
            }
            else
            {
               GuiManager.updateShapeXP(_loc6_);
            }
            if(AvatarManager.playerAvatarWorldView)
            {
               AvatarManager.playerAvatarWorldView.updateNameBarLevelShape(_loc6_);
            }
         }
      }
      
      public static function handleQuestActorTriggerTreasure(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:QuestActor = _questActors[_loc3_];
         if(_loc4_ != null)
         {
            _loc5_ = int(param1[_loc2_++]);
            _loc6_ = int(param1[_loc2_++]);
            _loc7_ = int(param1[_loc2_++]);
            _loc4_.handleTriggerTreasure(_loc5_,_loc6_,_loc7_);
         }
      }
      
      public static function handleSpawn(param1:Object) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:String = param1[_loc2_++];
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:int = int(param1[_loc2_++]);
         var _loc7_:Object = new Object();
         _loc7_.visible = true;
         _loc7_.requireClick = true;
         _loc7_.type = _loc5_;
         _loc7_.defId = _loc6_;
         _loc7_.state = 0;
         _loc7_.actorName = _loc4_;
         initInitialActorStatus(_loc7_,_loc3_);
         switch(_loc5_)
         {
            case QuestActor.QUEST_ACTOR_TYPE_DROPPED_TREASURE:
               _loc8_ = int(param1[_loc2_++]);
               _loc7_.subType = _loc8_;
               switch(_loc8_)
               {
                  case QuestActor.GIVE_DEN_ITEM:
                     _loc9_ = int(param1[_loc2_++]);
                     _loc7_.denDefId = _loc9_;
                     break;
                  case QuestActor.GIVE_ACCESSORY:
                     _loc10_ = int(param1[_loc2_++]);
                     _loc11_ = int(param1[_loc2_++]);
                     _loc7_.itemDefId = _loc10_;
                     _loc7_.itemData = _loc11_;
                     break;
                  case QuestActor.GIVE_GEMS:
                     _loc12_ = int(param1[_loc2_++]);
                     _loc7_.gems = _loc12_;
                     break;
                  case QuestActor.GIVE_ORBS:
                     _loc13_ = int(param1[_loc2_++]);
                     _loc7_.gems = _loc13_;
               }
               break;
            case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
               _loc7_.spawnOffsetX = param1[_loc2_++];
               _loc7_.spawnOffsetY = param1[_loc2_++];
         }
         _questActorDictionary[_loc4_] = _loc7_;
         doSpawn(_loc7_,_loc3_);
      }
      
      public static function doSpawnToRoot(param1:Object) : void
      {
         var _loc2_:QuestActor = null;
         var _loc3_:Object = null;
         if(param1.spawnedFromActor != null)
         {
            if(param1.type == QuestActor.QUEST_ACTOR_TYPE_DROPPED_TREASURE && param1.pickedUp == true)
            {
               return;
            }
            _loc2_ = _questActors[param1.spawnedFromActor];
            if(_loc2_ == null)
            {
               _loc3_ = _questActorDictionary[param1.spawnedFromActor];
               if(_loc3_ != null && _loc3_.spawnedFromActor != null)
               {
                  doSpawnToRoot(_loc3_);
               }
            }
            doSpawn(param1,param1.spawnedFromActor);
         }
      }
      
      public static function doSpawn(param1:Object, param2:String) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Point = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc3_:QuestActor = _questActors[param1.spawnedFromActor];
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            _loc5_ = null;
            if(param1.actorPos == null)
            {
               _loc6_ = _loc3_.x;
               _loc7_ = _loc3_.y;
               switch(param1.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
                     if(_loc3_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY)
                     {
                        _loc8_ = 2 * _loc3_._actorDefaultInnerRadius * param1.spawnOffsetX / 1000 - _loc3_._actorDefaultInnerRadius;
                        _loc9_ = 2 * _loc3_._actorDefaultInnerRadius * param1.spawnOffsetY / 1000 - _loc3_._actorDefaultInnerRadius;
                        _loc6_ += _loc8_;
                        _loc7_ += _loc9_;
                        _loc5_ = new Point(-_loc8_,-_loc9_);
                     }
               }
               param1.actorPos = new Point(_loc6_,_loc7_);
               initQuestActor(param1.actorName,0,_loc4_,param1,null,_loc5_);
            }
            switch(param1.type)
            {
               case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
                  param1.respawned = true;
                  if(_loc3_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY)
                  {
                     _loc4_ = _loc3_._actorDefaultOuterRadius;
                  }
            }
            initQuestActor(param1.actorName,0,_loc4_,param1,null,_loc5_);
         }
      }
      
      public static function loadLevelShape(param1:int) : void
      {
         _levelShapeHelper = new MediaHelper();
         _levelShapeHelper.init(LEVEL_SHAPES[Math.floor(param1 / 5)],onLevelShapeLoaded,param1);
         AvatarManager.playerAvatarWorldView.updateNameBarLevelShape(param1);
      }
      
      public static function handleActorHealthStatus(param1:Object) : void
      {
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:QuestActor = _questActors[_loc3_];
         if(_loc4_ == -1)
         {
            if(_loc5_ != null)
            {
            }
         }
         else
         {
            _loc6_ = _questActorDictionary[_loc3_];
            if(_loc6_ != null)
            {
               _loc6_.healthPercent = _loc4_;
            }
            if(_loc5_ != null)
            {
               _loc7_ = int(param1[_loc2_++]);
               _loc8_ = int(param1[_loc2_++]);
               _loc5_.healthUpdate(_loc4_,_loc7_,_loc8_ == 1);
            }
         }
      }
      
      public static function handleHealthUpdate(param1:Object, param2:Boolean) : void
      {
         var _loc10_:AvatarWorldView = null;
         var _loc11_:AvatarInfo = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc3_:* = 2;
         var _loc4_:int = int(param1[_loc3_++]);
         var _loc5_:int = int(param1[_loc3_++]);
         var _loc6_:int = int(param1[_loc3_++]);
         var _loc7_:int = int(param1[_loc3_++]);
         var _loc8_:int = int(param1[_loc3_++]);
         var _loc9_:QuestPlayerData = getQuestPlayerData(_loc4_);
         if(_loc5_ == -1 && _loc6_ == 0)
         {
            if(_loc9_ != null)
            {
            }
         }
         else
         {
            _loc10_ = AvatarManager.avatarViewList[_loc4_];
            if(_loc9_ != null)
            {
               if(_loc6_ < 0)
               {
                  _loc9_.playerDamaged(_loc8_,_loc7_ + -_loc6_,_loc7_);
               }
               if(_loc10_)
               {
                  _loc11_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc10_.userName);
                  _loc11_.questHealthPercentage = _loc5_;
                  _loc11_.healthBase = _loc8_;
                  if(_loc11_.isDead && _loc5_ > 0)
                  {
                     _loc11_.isDead = false;
                     _loc10_.playAnim(LayerAnim.AN_IDLE_NE);
                  }
               }
               if(_loc6_ < 0)
               {
                  _loc9_.handleHit(_loc6_);
               }
               else
               {
                  _loc9_.handleHealing(_loc6_);
               }
            }
            if(_loc10_)
            {
               if(param2 && _loc10_ != AvatarManager.playerAvatarWorldView)
               {
                  _loc12_ = int(param1[_loc3_++]);
                  _loc13_ = int(param1[_loc3_++]);
                  _loc10_.setPos(_loc12_,_loc13_,false);
               }
               if(_loc5_ > 0)
               {
                  _loc10_.holdAnimId = 0;
               }
               _loc10_.updateNameBarHealth(_loc5_);
               if(_loc4_ == gMainFrame.server.userId)
               {
                  GuiManager.setQuestHearts(_loc5_);
               }
            }
         }
      }
      
      public static function handleQuestSetPath(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:String = param1[_loc2_++];
         var _loc5_:QuestActor = _questActors[_loc3_];
         var _loc6_:Object = _questActorDictionary[_loc3_];
         if(_loc6_ != null)
         {
            _loc6_.pathName = _loc4_;
         }
         if(_loc5_ != null)
         {
            _loc5_.setPath(_loc4_);
         }
      }
      
      public static function handleQuestRoomChange(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:String = param1[_loc2_++];
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:int = int(param1[_loc2_++]);
         AvatarManager.setOffScreenMapBySfsId(_loc3_,new Point(_loc5_,_loc6_),_loc4_);
      }
      
      public static function handlePlayerLeftQuest(param1:Object) : void
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:AvatarWorldView = AvatarManager.getAvatarWorldViewBySfsUserId(_loc3_);
         if(_loc4_)
         {
            _loc5_ = _loc4_.avName;
         }
         AvatarManager.removeAvatar(_loc3_,true);
         if(Boolean(_loc4_) && AvatarManager.playerSfsUserId != _loc3_)
         {
            _loc7_ = 0;
            while(_loc7_ < _playerLeftObjects.length)
            {
               _loc6_ = _playerLeftObjects[_loc7_];
               if(!_loc6_.hasLeft)
               {
                  _loc6_.icon.txtMc.txt.autoSize = TextFieldAutoSize.CENTER;
                  _loc6_.icon.txtMc.txt.text = _loc5_ + " has left the Adventure";
                  _loc6_.icon.x = MainFrame.VIEW_WIDTH * 0.5;
                  if(_loc7_ != 0 && !_playerLeftObjects[_loc7_ - 1].complete)
                  {
                     _playerLeftObjects[_loc7_ - 1].icon.y -= _loc6_.icon.height * _loc7_;
                  }
                  _loc6_.icon.y = MainFrame.VIEW_HEIGHT * 0.5;
                  GuiManager.guiLayer.addChild(_loc6_.icon);
                  _loc6_.icon.startLeaveText(onLeaveTextComplete,_loc7_);
                  _loc6_.hasLeft = true;
                  break;
               }
               _loc7_++;
            }
         }
      }
      
      private static function onLeaveTextComplete(param1:Object) : void
      {
         _playerLeftObjects[param1].complete = true;
      }
      
      public static function handlePickGift(param1:Object) : void
      {
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Array = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc6_ = new Object();
            _loc7_ = int(param1[_loc2_++]);
            _loc8_ = int(param1[_loc2_++]);
            _loc9_ = int(param1[_loc2_++]);
            _loc6_.type = _loc7_;
            switch(_loc6_.type)
            {
               case 1:
                  _loc6_.defID = _loc8_;
                  break;
               case 2:
                  _loc6_.defID = _loc8_;
                  _loc6_.color = _loc9_;
                  break;
               case 3:
                  _loc6_.amount = _loc8_;
                  break;
               case 4:
                  _loc6_.amount = _loc8_;
            }
            _loc4_.push(_loc6_);
            _loc5_++;
         }
         _mediaLoader = new MediaHelper();
         _mediaLoader.init(ADVENTURE_REWARDS_ID,onAdventureRewardsLoaded,_loc4_);
      }
      
      public static function handlePhantomZap(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:QuestActor = _questActors[_loc3_];
         if(_loc5_ != null)
         {
            _loc5_.handlePhantomZap(_loc4_);
         }
      }
      
      public static function handleEatPhantom(param1:String, param2:String) : void
      {
         var _loc3_:QuestActor = _questActors[param1];
         var _loc4_:Object = _questActorDictionary[param1];
         if(_loc4_ != null)
         {
            _loc4_.plantEaten = true;
         }
         if(_loc3_ != null)
         {
            _loc3_.setPlantEats(_questActors[param2]);
         }
      }
      
      public static function handlePlantSeed(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:int = int(param1[_loc2_++]);
         var _loc7_:Object = new Object();
         _loc7_.visible = true;
         _loc7_.requireClick = false;
         _loc7_.type = QuestActor.QUEST_ACTOR_TYPE_PLANT;
         _loc7_.defId = _loc4_;
         _loc7_.state = 0;
         _loc7_.actorName = _loc3_;
         initInitialActorStatus(_loc7_,null);
         _loc7_.actorPos = new Point(_loc5_,_loc6_);
         _questActorDictionary[_loc3_] = _loc7_;
         initQuestActor(_loc7_.actorName,0,100,_loc7_,null,null);
      }
      
      public static function handleQuestPlayerDead(param1:Object) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:AvatarWorldView = AvatarManager.avatarViewList[_loc3_];
         if(_loc4_)
         {
            _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc4_.userName);
            if(_loc5_ != null)
            {
               _loc5_.isDead = true;
            }
            _loc4_.playAnim(LayerAnim.AN_SLEEP);
            _loc4_.holdAnimId = LayerAnim.AN_SLEEP;
            if(_loc4_ == AvatarManager.playerAvatarWorldView)
            {
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#death/" + Math.round(_loc4_.avatarPos.x / 250) * 250 + "x" + Math.round(_loc4_.avatarPos.y / 250) * 250);
               RoomManagerWorld.instance.forceStopMovement();
               _defeatedPopUpTimer = 2;
               playSound("ajq_playerdeath");
            }
         }
      }
      
      public static function handleSwipe(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:int = int(param1[_loc2_++]);
         var _loc6_:String = param1[_loc2_++];
         var _loc7_:int = int(param1[_loc2_++]);
         var _loc8_:uint = uint(param1[_loc2_++]);
         var _loc9_:QuestActor = null;
         var _loc10_:AvatarWorldView = null;
         if(_loc7_ > 0)
         {
            _loc10_ = AvatarManager.avatarViewList[_loc7_];
            if(_loc10_ == null)
            {
               return;
            }
            _loc10_.faceAnim(_loc4_ - _loc10_.avatarPos.x,_loc5_ - _loc10_.avatarPos.y,false);
         }
         else
         {
            _loc9_ = _questActors[_loc6_];
         }
         swipeMelee(_loc3_,_loc8_,_loc4_,_loc5_,_loc9_,_loc10_);
      }
      
      public static function handleActorDeath(param1:Object) : void
      {
         var _loc2_:QuestActor = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:* = 2;
         _loc3_ = param1[_loc5_++];
         var _loc6_:Object = _questActorDictionary[_loc3_];
         _loc2_ = _questActors[_loc3_];
         _loc4_ = int(param1[_loc5_++]);
         var _loc7_:Boolean = param1[_loc5_++] == "1";
         var _loc8_:int = int(param1[_loc5_++]);
         var _loc9_:int = int(param1[_loc5_++]);
         if(_loc6_ != null)
         {
            _loc6_.healthPercent = 0;
         }
         if(_loc2_ != null)
         {
            if(_loc7_)
            {
               _loc2_.x = _loc8_;
               _loc2_.y = _loc9_;
               _loc2_.handlePositionUpdate(_loc8_,_loc9_,0,QuestActor.SEEKTYPE_OFF);
            }
            if(_loc2_.handleDeath(_loc4_))
            {
               _loc2_.destroy();
               delete _questActors[_loc3_];
            }
         }
      }
      
      public static function onQuestExit(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(GuiManager.guiLayer,"Are you sure you want to leave?  If you quit you will lose your progress.",true,onLeaveQuestConfirm);
      }
      
      private static function onLeaveQuestConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            commandExit(0,null);
         }
      }
      
      private static function onDeathAccept(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1.status)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            QuestXtCommManager.sendQuestPlayerRequestRespawn(0,_nearestRespawnPoint != null ? int(_nearestRespawnPoint.pos.x) : int(AvatarManager.playerAvatarWorldView.x),_nearestRespawnPoint != null ? int(_nearestRespawnPoint.pos.y) : int(AvatarManager.playerAvatarWorldView.y));
         }
         else
         {
            commandExit(0,null);
         }
      }
      
      public static function respawnPlayer() : void
      {
         var _loc1_:Point = null;
         if(_nearestRespawnPoint != null)
         {
            _loc1_ = new Point(RoomManagerWorld.instance.scrollOffset.x,RoomManagerWorld.instance.scrollOffset.y);
            RoomManagerWorld.instance.teleportPlayer(_nearestRespawnPoint.pos.x,_nearestRespawnPoint.pos.y,true);
            RoomManagerWorld.instance.setCameraFocus(_loc1_,0,0,1,false);
            playSound("ajq_respawn");
         }
      }
      
      public static function handleQuestPlayerRequestRespawn(param1:Object) : void
      {
         respawnPlayer();
      }
      
      private static function onNotEnoughGems(param1:Object) : void
      {
         commandExit(0,null);
      }
      
      private static function startNowHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         QuestXtCommManager.sendQuestStartRequest();
      }
      
      public static function closeAdventureJoinPopup() : void
      {
         if(_adventureJoin)
         {
            QuestXtCommManager.sendQuestJoinCancel();
            _adventureJoin.destroy();
            _adventureJoin = null;
         }
      }
      
      private static function onPopupOK(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
      }
      
      public static function set gameCardDefs(param1:Object) : void
      {
         _gameCardDefs = param1;
      }
      
      public static function set npcDefs(param1:Object) : void
      {
         _npcDefs = param1;
      }
      
      public static function getGameCardDef(param1:int) : Object
      {
         if(_gameCardDefs)
         {
            return _gameCardDefs[param1];
         }
         return null;
      }
      
      public static function getNPCDef(param1:int) : Object
      {
         if(_npcDefs)
         {
            return _npcDefs[param1];
         }
         return null;
      }
      
      public static function questRoomJoined(param1:Boolean) : void
      {
         _inQuestRoom = param1;
      }
      
      public static function playerLaunchWeapon(param1:Point, param2:Boolean) : Number
      {
         return 0;
      }
      
      public static function launchProjectile(param1:int, param2:uint, param3:Number, param4:Number, param5:QuestActor, param6:AvatarView) : Number
      {
         var _loc8_:QuestProjectile = null;
         var _loc9_:Boolean = false;
         var _loc7_:Number = 0;
         if(param1 != 0)
         {
            _loc8_ = getQuestAsset(ItemXtCommManager.getItemDef(param1).attackMediaRefId) as QuestProjectile;
            if(_loc8_ == null)
            {
               _loc8_ = new QuestProjectile();
               _loc9_ = _loc8_.launch(param1,param2,_layerManager.room_chat,param3,param4,param5,param6);
            }
            else
            {
               _loc9_ = _loc8_.relaunch(param1,param2,_layerManager.room_chat,param3,param4,param5,param6);
            }
            if(_loc9_)
            {
               _loc7_ = _loc8_.angle;
               _questProjectiles.push(_loc8_);
            }
         }
         return _loc7_;
      }
      
      public static function swipeMelee(param1:int, param2:uint, param3:Number, param4:Number, param5:QuestActor, param6:AvatarView) : Number
      {
         var _loc8_:QuestMelee = null;
         var _loc7_:Number = 0;
         if(param1 != 0)
         {
            _loc8_ = new QuestMelee(_currentMeleeID++);
            if(_loc8_.swipe(param1,param2,_layerManager.room_chat,param3,param4,param5,param6))
            {
               _loc7_ = _loc8_.angle;
               _questMelees.push(_loc8_);
            }
         }
         return _loc7_;
      }
      
      public static function getPlayerActiveWeapon(param1:Boolean) : Object
      {
         var _loc6_:Item = null;
         var _loc7_:Object = null;
         var _loc2_:Item = null;
         var _loc3_:Array = AvatarManager.playerAvatar.inventoryClothing.itemArray;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc4_];
            if(_loc6_.getInUse(AvatarManager.playerAvatar.dbAvId) && _loc6_.attackMediaRefId != 0)
            {
               if(param1 && _loc6_.combatType == QUEST_WEAPON_TYPE_PROJECTILE || param1 == false && _loc6_.combatType == QUEST_WEAPON_TYPE_MELEE)
               {
                  if(_loc2_ == null || _loc2_.attack < _loc6_.attack)
                  {
                     _loc2_ = _loc6_;
                  }
               }
            }
            _loc4_++;
         }
         var _loc5_:Object = new Object();
         if(_loc2_ == null)
         {
            _loc5_.itemDefId = param1 ? QUEST_WEAPON_DEFAULT_PROJECTILE : QUEST_WEAPON_DEFAULT_MELEE;
            _loc7_ = ItemXtCommManager.getItemDef(_loc5_.itemDefId);
            if(_loc7_ != null)
            {
               _loc5_.color = _loc7_.colors[0];
            }
            else
            {
               _loc5_.color = 0;
            }
         }
         else
         {
            _loc5_.itemDefId = _loc2_.defId;
            _loc5_.color = _loc2_.color;
         }
         return _loc5_;
      }
      
      public static function handleQuestMiniGameComplete(param1:int) : void
      {
         if(_questCommandActor != "" && _questCommandActorState != -1)
         {
            QuestXtCommManager.questMiniGameComplete(_questCommandActor,_questCommandActorState,param1);
            _questCommandActor = null;
            _questCommandActorState = -1;
         }
      }
      
      public static function stopItemEmoticonSound(param1:AvatarWorldView) : void
      {
         var _loc2_:Object = null;
         var _loc3_:QuestPlayerData = null;
         for(_loc2_ in _questPlayersDict)
         {
            _loc3_ = _questPlayersDict[_loc2_];
            if(_loc3_ != null && _loc3_._avatarWorldView == param1)
            {
               _loc3_.stopItemEmoticonSound();
               break;
            }
         }
      }
      
      public static function playItemEmoticonSound(param1:AvatarWorldView, param2:String) : void
      {
         var _loc3_:Object = null;
         var _loc4_:QuestPlayerData = null;
         for each(_loc4_ in _questPlayersDict)
         {
            if(_loc4_ != null && _loc4_._avatarWorldView == param1)
            {
               _loc4_.playItemEmoticonSound(param2);
               break;
            }
         }
      }
      
      public static function onQuestReportBtn(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:AvatarWorldView = null;
         var _loc6_:UserInfo = null;
         var _loc7_:AvatarInfo = null;
         if(!param1.currentTarget.isGray)
         {
            _loc2_ = GuiManager.mainHud.reportPlayerCont;
            if(_loc2_.visible)
            {
               _loc2_.visible = false;
               return;
            }
            _loc2_.visible = true;
            if(_reportWindow)
            {
               _reportWindow.destroy();
               _reportWindow = null;
            }
            _loc3_ = AvatarManager.avatarViewList;
            _loc4_ = [];
            for each(_loc5_ in _loc3_)
            {
               if(_loc5_.userName != gMainFrame.userInfo.myUserName)
               {
                  _loc6_ = gMainFrame.userInfo.getUserInfoByUserName(_loc5_.userName);
                  _loc7_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(_loc6_.currDbAvId);
                  _loc4_.push({
                     "isMember":_loc6_.isMember,
                     "nameBarData":_loc6_.nameBarData,
                     "userName":_loc6_.userName,
                     "avName":_loc7_.avName,
                     "isBuddy":BuddyManager.isBuddy(_loc6_.userName),
                     "isBlocked":BuddyManager.isBlocked(_loc6_.userName)
                  });
               }
            }
            if(_loc4_.length > 0)
            {
               while(_loc2_.itemWindow.numChildren > 0)
               {
                  _loc2_.itemWindow.removeChildAt(0);
               }
               _reportWindow = new WindowGenerator();
               _reportWindow.init(1,_loc4_.length,_loc4_.length,0,0,0,ItemWindowNameBar,null,"",{
                  "mouseDown":onReportPlayer,
                  "mouseOver":null,
                  "mouseOut":null
               },_loc4_,onReportWindowsLoaded);
               _loc2_.itemWindow.addChild(_reportWindow);
            }
         }
      }
      
      private static function onReportWindowsLoaded() : void
      {
         var containerWindow:MovieClip = GuiManager.mainHud.reportPlayerCont;
         with(containerWindow)
         {
            m.height = Math.round(_reportWindow.height);
            m.width = t.width = b.width = _reportWindow.width + 2;
            m.y = b.y - m.height;
            t.y = m.y - t.height;
            x = Math.min(GuiManager.mainHud.questReportBtn.x - width * 0.5,MainFrame.VIEW_WIDTH - width - 2);
            _reportWindow.y = t.y + t.height * 0.5 - 5;
            _reportWindow.x = m.x - 4;
         }
      }
      
      private static function setupInventoryIcons() : void
      {
         var seedCont:MovieClip = null;
         var seed:MovieClip = null;
         var i:int = 0;
         while(i < 4)
         {
            seedCont = new (getDefinitionByName("vftCont") as Class)();
            seed = new (getDefinitionByName("venusFlyTrapIcon") as Class)();
            seed.xOut.visible = false;
            seedCont.itemWindow.addChild(seed);
            with(GuiManager.mainHud["inventoriesWindow" + i])
            {
               
               addChild(seedCont);
               addEventListener(MouseEvent.MOUSE_DOWN,onSeedsDown,false,0,true);
            }
            i++;
         }
      }
      
      private static function onSeedsDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_draggedSeed == null || _draggedSeed.windowName != param1.currentTarget.name)
         {
            if(Boolean(_draggedSeed) && _draggedSeed.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_draggedSeed);
            }
            _draggedSeed = new (getDefinitionByName("venusFlyTrapIcon") as Class)();
            _draggedSeed.addEventListener(MouseEvent.MOUSE_UP,onSeedsUp,false,0,true);
            _draggedSeed.addEventListener(MouseEvent.MOUSE_MOVE,onSeedMove,false,0,true);
            _draggedSeed.windowName = param1.currentTarget.name;
            _draggedSeed.x = param1.currentTarget.x;
            _draggedSeed.y = param1.currentTarget.y;
            _draggedSeed.prevPositionX = 0;
            _draggedSeed.prevPositionY = 0;
            _draggedSeed.xOut.visible = false;
            GuiManager.guiLayer.addChild(_draggedSeed);
         }
         _draggedSeed.startDrag(true);
      }
      
      private static function onSeedMove(param1:MouseEvent) : void
      {
         var _loc5_:Point = null;
         param1.stopPropagation();
         var _loc2_:Number = param1.stageX - _draggedSeed.prevPositionX;
         var _loc3_:Number = param1.stageY - _draggedSeed.prevPositionY;
         var _loc4_:Number = _loc2_ * _loc2_ + _loc3_ * _loc3_;
         if(_loc4_ > 9)
         {
            _draggedSeed.prevPositionX = param1.stageX;
            _draggedSeed.prevPositionY = param1.stageY;
            _loc5_ = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            if(validatePlantSeedLocation(_loc5_) == false)
            {
               if(!param1.currentTarget.xOut.visible)
               {
                  param1.currentTarget.xOut.visible = true;
               }
            }
            else if(param1.currentTarget.xOut.visible)
            {
               param1.currentTarget.xOut.visible = false;
            }
         }
      }
      
      private static function onSeedsUp(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         param1.stopPropagation();
         if(_draggedSeed)
         {
            _loc2_ = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            if(validatePlantSeedLocation(_loc2_))
            {
               if(_draggedSeed.windowName == "inventoriesWindow0")
               {
                  QuestXtCommManager.sendPlantSeed(99,_loc2_.x,_loc2_.y);
               }
               else
               {
                  QuestXtCommManager.sendPlantSeed(100,_loc2_.x,_loc2_.y);
               }
            }
            if(_draggedSeed.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_draggedSeed);
            }
            _draggedSeed.stopDrag();
            _draggedSeed = null;
         }
      }
      
      private static function validatePlantSeedLocation(param1:Point) : Boolean
      {
         var _loc2_:QuestActor = null;
         var _loc3_:QuestActor = null;
         for each(_loc2_ in _questActors)
         {
            if(_loc2_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_VOLUMEPLACEMENT)
            {
               if(_loc2_.testPointInActorVolumes(param1))
               {
                  _loc3_ = getNearestPlant(param1.x,param1.y,75,999999);
                  if(_loc3_ != null)
                  {
                     return false;
                  }
                  return true;
               }
            }
         }
         return false;
      }
      
      private static function onReportPlayer(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
         }
         else
         {
            _reportAPlayer = new ReportAPlayer();
            _reportAPlayer.init(GuiManager.guiLayer,onReportAPlayerClose,true,param1.currentTarget.userName,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
      }
      
      private static function onReportAPlayerClose(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
      }
      
      private static function resetMouseMoveIdleTimer(param1:MouseEvent) : void
      {
         if(_kickPopup == null)
         {
            _gameIdleTimer = 0;
         }
      }
      
      private static function resetMouseDownIdleTimer(param1:Event) : void
      {
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
      }
      
      private static function onKickWarningPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         _kickPopup = null;
         _gameIdleTimer = 0;
      }
      
      private static function adventureJoinClose() : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
         }
      }
      
      public static function getNearestActorPathInGroupToPlayerInRange(param1:QuestActor) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:QuestActor = null;
         var _loc2_:int = param1._actorId.lastIndexOf("__");
         if(_loc2_ != -1)
         {
            _loc3_ = param1._actorId.substring(0,_loc2_);
            _loc4_ = _questActorGroups[_loc3_];
            if(_loc4_ != null)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_.length)
               {
                  _loc6_ = _loc4_[_loc5_];
                  _loc7_ = _questActors[_loc6_];
                  if(_loc7_ != null)
                  {
                     if(_loc7_.pathToPlayerInRange())
                     {
                        return true;
                     }
                  }
                  _loc5_++;
               }
            }
            return false;
         }
         return param1.pathToPlayerInRange();
      }
   }
}

