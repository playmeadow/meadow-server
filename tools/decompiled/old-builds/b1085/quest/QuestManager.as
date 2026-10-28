package quest
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import avatar.AvatarXtCommManager;
   import avatar.NameBar;
   import avatar.UserCommXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFClient;
   import com.sbi.corelib.math.Collision;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBParchmentPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.text.TextFieldAutoSize;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import game.MinigameManager;
   import game.SoundManager;
   import gui.*;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.LayerManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import ru.etcs.utils.getDefinitionNames;
   
   public class QuestManager
   {
      
      private static var _npcDefs:Object;
      
      public static var _questScriptTimeStamp:String;
      
      private static var _questActorDictionary:Dictionary;
      
      private static var _questActors:Dictionary;
      
      private static var _questPlayersDict:Dictionary;
      
      private static var _questPlayersSwitched:Dictionary;
      
      private static var _questActorGroups:Dictionary;
      
      private static var _questSeeds:Dictionary;
      
      public static var _layerManager:LayerManager;
      
      private static var _lastGoodAvatarX:int;
      
      private static var _lastGoodAvatarY:int;
      
      private static var _lastClearAvatarX:int;
      
      private static var _lastClearAvatarY:int;
      
      private static var _mediaLoader:MediaHelper;
      
      private static var _talkingPopup:MovieClip;
      
      private static var _adventureJoin:AdventureJoin;
      
      private static var _privateAdventureJoin:PrivateAdventureJoin;
      
      private static var _seedInventory:SeedInventoryHandling;
      
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
      
      private static var _streamsLUT:Dictionary;
      
      private static var _SFX_AmbientSC:SoundChannel;
      
      private static var _currentMusic:String;
      
      private static var _currentAmbient:String;
      
      private static var _isLoadingTalkingPopup:Boolean;
      
      private static var _currentVOSC:SoundChannel;
      
      private static var _paused:Boolean;
      
      private static var _assetPool:Dictionary;
      
      private static var _playerLeftObjects:Array;
      
      private static var _playersWindow:WindowGenerator;
      
      public static var _questScriptDefId:int;
      
      public static var _questStartingPlayerCount:int;
      
      private static var _questObjectiveText:String;
      
      private static var _defeatedPopUpTimer:Number;
      
      private static var _nearestRespawnPoint:Object;
      
      private static var _playerInStealthVolume:Boolean;
      
      private static var _gameIdleTimer:Number;
      
      private static var _kickPopup:SBOkPopup;
      
      private static var _adventureRewardsPopup:MovieClip;
      
      private static var _rewardsGiftPopup:GiftPopup;
      
      private static var _hasJustJoinedQuest:Boolean;
      
      private static var _torches:Array;
      
      private static var _torchLUT:Dictionary;
      
      public static var _darknessMask:Sprite;
      
      private static var _playerTorch:MovieClip;
      
      private static var _playMusicOnLoad:Boolean;
      
      private static var _sceneLoaded:Boolean;
      
      public static var _questDifficultyLevel:int;
      
      private static var _playerAvatarCurrentAnim:int;
      
      public static var _volumeInteractionProgressing:Boolean;
      
      public static var _progressingSC:SoundChannel;
      
      public static var _progressingSCnot:SoundChannel;
      
      public static var _screenShakeSC:SoundChannel;
      
      public static var _sfxTimer:Dictionary;
      
      public static var _shaketimer:Number;
      
      public static var _shakeOrigPos:Point;
      
      public static var _playSwfMC:MovieClip;
      
      public static var _playSwfMCTimeElapsed:Number;
      
      public static var _playSwfMCSC:SoundChannel;
      
      private static var _fallingPhantomTimer:Number;
      
      private static var _fallingPhantomVolumeActors:Array;
      
      private static var _totalGemsEarned:int;
      
      private static var _totalXPEarned:int;
      
      private static var _fader:Shape;
      
      private static var _faderState:int;
      
      private static var _queueFadeIn:Boolean;
      
      private static var _availableScriptDefs:Array;
      
      private static var _adventureSelectPopup:MovieClip;
      
      private static var _adventureSelectScrollBar:SBScrollbar;
      
      private static var _adventureSelectItemWindow:WindowGenerator;
      
      private static var _guiElementsSkipBtn:MovieClip;
      
      private static var _guiElementsSkipBtnMh:MediaHelper;
      
      public static const ADVENTURE_SCRIPTS_ID:int = 201;
      
      public static const SCRIPT_EDITOR_IXM_KEYWORD:String = "adventure&";
      
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
      
      public static const QUEST_TORCH_UNLITSIZE:Number = 0.7;
      
      public static const QUEST_TORCH_LITSIZE:Number = 1.3;
      
      private static const TALKING_DIALOGUE_ID:int = 1789;
      
      private static const ADVENTURE_REWARDS_ID:int = 2251;
      
      private static var _addTorchQueue:Array = [];
      
      private static const torch:Class = QuestManager_torch;
      
      private static var _actorLightQueue:Array = [];
      
      private static var _fallingPhantoms:Array = [];
      
      private static var _guiElementsAvatarEditor:Array = ["gui_21","tradeBtnDown","gui_22","nonmember","gui_23","colorsTabDnBtn","gui_24","eyesTabDnBtn","gui_25","patternTabDnBtn","gui_26","bx","gui_27","sortBtn","gui_28","recycleClothesBtn","gui_29","shopBtn","gui_30","petsBtn","gui_31","colorsTabUp","gui_32","eyesTabUp","gui_33","patternTabUp"];
      
      private static var _guiElementsGuiManager:Array = ["gui_1","eCardBtn","gui_2","buddyListBtn","gui_3","newsBtn","gui_4","awardsBtn","gui_5","book","gui_6","partyBtn","gui_7","gemsBtn","gui_8","mySettingsBtn","gui_9","reportBtn","gui_10","charWindow","gui_11","swapBtn","gui_12","actionsBtn","gui_13","emotesBtn","gui_14","safeChatBtn","gui_15","chatHistUpDownBtn","gui_16","sendChatBtn","gui_17","denBtn","gui_18","soundBtn","gui_19","worldMapBtn","gui_35","zoneName","gui_36","ansChatBtn"];
      
      private static var _guiElementsShop:Array = ["gui_34","reserved for close button callback"];
      
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
      
      public static function get questExitPending() : Boolean
      {
         return _questExitPending;
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
         param1.progress = 0;
         param1.seekType = 0;
         param1.seekTypeSfsId = 0;
         param1.torchEnabled = false;
         param1.iconShowing = false;
         switch(param1.type)
         {
            case QuestActor.QUEST_ACTOR_TYPE_DROPPED_TREASURE:
               param1.pickedUp = false;
            case QuestActor.QUEST_ACTOR_TYPE_PLACED_TREASURE:
               param1.status = 0;
               break;
            case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
            case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
            case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
            case QuestActor.QUEST_ACTOR_TYPE_PLANT:
               param1.damageDelay = 0;
               param1.healthPercent = 100;
               param1.respawned = false;
         }
      }
      
      public static function loadQuestSfx(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(param1,onSfxLoaded,true);
      }
      
      private static function onSfxLoaded(param1:MovieClip) : void
      {
         var _loc2_:Class = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc3_:Array = getDefinitionNames(param1.loaderInfo,false,true);
         if(param1.hasOwnProperty("initVolumes"))
         {
            param1.initVolumes();
            _soundMan.setVolumes(param1.volumes);
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length - 1)
         {
            _loc5_ = _loc3_[_loc4_];
            _loc6_ = _loc5_.toLowerCase();
            if(Boolean(_loc5_) && _loc5_ != "")
            {
               _loc2_ = param1.loaderInfo.applicationDomain.getDefinition(_loc5_) as Class;
               _soundMan.addSound(_loc2_,-1,_loc5_);
               if(_sounds[_loc6_] == null)
               {
                  _sounds[_loc6_] = _loc2_;
               }
            }
            _loc4_++;
         }
         param1.mediaHelper.destroy();
         delete param1.mediaHelper;
         delete param1.passback;
      }
      
      public static function playMusic(param1:String, param2:DisplayObject = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(_currentMusic)
         {
            if(_currentMusic != param1)
            {
               if(_currentMusic != "0")
               {
                  _SFX_Music[_currentMusic].stop();
                  if(param1 != "0")
                  {
                     _playMusicOnLoad = true;
                  }
               }
               else
               {
                  _loc3_ = 9999;
                  if(param1 == "ajq_phntmprisoner")
                  {
                     _loc3_ = 0;
                  }
                  if(_SFX_Music[param1] == null)
                  {
                     _loc4_ = _streamsLUT[param1];
                     _SFX_Music[param1] = _soundMan.addStream(_loc4_.name,_loc4_.vol);
                  }
                  _soundMan.playStream(_SFX_Music[param1],0,_loc3_);
               }
            }
         }
         else
         {
            _playMusicOnLoad = true;
         }
         _currentMusic = param1;
      }
      
      public static function playSound(param1:String, param2:DisplayObject = null, param3:Boolean = false) : void
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc4_:String = param1.toLowerCase();
         if(param2 == null && Boolean(_streamsLUT[_loc4_]))
         {
            if(_SFX_Music[_loc4_] == null)
            {
               _loc5_ = _streamsLUT[_loc4_];
               _SFX_Music[_loc4_] = _soundMan.addStream(_loc5_.name,_loc5_.vol);
            }
            _soundMan.playStream(_SFX_Music[_loc4_]);
         }
         else if(param2 == null || isOnscreen(param2))
         {
            _loc6_ = _sfxTimer[_loc4_] == null ? -1 : int(_sfxTimer[_loc4_]);
            if(_loc6_ < 0 || getTimer() - _loc6_ > 500)
            {
               if(param3)
               {
                  if(_currentVOSC)
                  {
                     _currentVOSC.stop();
                  }
                  _currentVOSC = _soundMan.play(_sounds[_loc4_]);
               }
               else
               {
                  _soundMan.play(_sounds[_loc4_]);
               }
               _sfxTimer[_loc4_] = _lastTime;
            }
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
      
      public static function getAvailableScriptDefs(param1:Function) : Array
      {
         if(_availableScriptDefs == null)
         {
            GenericListXtCommManager.requestGenericList(ADVENTURE_SCRIPTS_ID,onAvailableScriptsLoaded,param1);
            return null;
         }
         return _availableScriptDefs;
      }
      
      private static function onAvailableScriptsLoaded(param1:int, param2:Array, param3:Object) : void
      {
         _availableScriptDefs = param2;
         if(param3 != null)
         {
            param3();
         }
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
         if(param1.parent == GuiManager.guiLayer)
         {
            return true;
         }
         var _loc2_:Number = param1.x;
         var _loc3_:Number = param1.y;
         var _loc4_:Object = param1;
         while(_loc4_.parent != null && _loc4_.parent != _layerManager.bkg)
         {
            _loc4_ = _loc4_.parent;
            _loc2_ += _loc4_.x;
            _loc3_ += _loc4_.y;
         }
         _loc4_ = AvatarManager.playerAvatarWorldView;
         if(_loc4_ == null)
         {
            return false;
         }
         var _loc5_:Number = Number(_loc4_.x);
         var _loc6_:Number = Number(_loc4_.y);
         while(_loc4_.parent != null && _loc4_.parent != _layerManager.bkg)
         {
            _loc4_ = _loc4_.parent;
            _loc5_ += _loc4_.x;
            _loc6_ += _loc4_.y;
         }
         _loc2_ -= _loc5_;
         _loc3_ -= _loc6_;
         return _loc2_ * _loc2_ + _loc3_ * _loc3_ < 810000;
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
         _fallingPhantomTimer = 0;
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
         _sfxTimer = new Dictionary(true);
         _SFX_Music = new Dictionary();
         _streamsLUT = new Dictionary();
         _streamsLUT["ajq_musquest"] = {
            "name":"ajq_musQuest",
            "vol":0.4
         };
         _streamsLUT["ajq_musdungeon"] = {
            "name":"ajq_musDungeon",
            "vol":0.64
         };
         _streamsLUT["ajq_muscave"] = {
            "name":"ajq_musCave",
            "vol":0.7
         };
         _streamsLUT["ajq_mustutorial"] = {
            "name":"ajq_musTutorial",
            "vol":0.5
         };
         _streamsLUT["ajq_muscavebossbattle"] = {
            "name":"ajq_musCaveBossBattle",
            "vol":0.55
         };
         _streamsLUT["ajq_musbunnyburrow"] = {
            "name":"ajq_musbunnyBurrow",
            "vol":0.9
         };
         _streamsLUT["ajq_musqueststealth"] = {
            "name":"ajq_musQuestStealth",
            "vol":0.4
         };
         _streamsLUT["ajq_muscosmomystical"] = {
            "name":"ajq_musCosmoMystical",
            "vol":0.36
         };
         _streamsLUT["ajq_musquest_3"] = {
            "name":"ajq_musQuest_3",
            "vol":0.3
         };
         _streamsLUT["ajq_mustreehutplayful"] = {
            "name":"ajq_musTreeHutPlayful",
            "vol":0.38
         };
         _streamsLUT["ajq_muscaveslides"] = {
            "name":"ajq_musCaveSlides",
            "vol":0.23
         };
         _streamsLUT["ajq_mussafelp"] = {
            "name":"ajq_musSafeLP",
            "vol":0.3
         };
         _streamsLUT["ajq_musspooky"] = {
            "name":"ajq_musSpooky",
            "vol":0.44
         };
         _streamsLUT["ajq_phntmprisoner"] = {
            "name":"ajq_phntmPrisoner",
            "vol":0.28
         };
         _streamsLUT["aj_musvolcanogreely"] = {
            "name":"aj_musVolcanoGreely",
            "vol":0.56
         };
         _streamsLUT["aj_musphntmkingintro"] = {
            "name":"aj_musPhntmKingIntro",
            "vol":0.48
         };
         _streamsLUT["ajq_musvolcanofreeze"] = {
            "name":"ajq_musVolcanoFreeze",
            "vol":0.45
         };
         _streamsLUT["ajq_musvolin"] = {
            "name":"ajq_musVolIn",
            "vol":0.35
         };
         _streamsLUT["ajq_musvolout"] = {
            "name":"ajq_musVolOut",
            "vol":0.4
         };
         _streamsLUT["ajq_musphntmkingintro"] = {
            "name":"ajq_musPhntmKingIntro",
            "vol":0.57
         };
         _streamsLUT["ajq_snowyvolerupt"] = {
            "name":"ajq_snowyVolErupt",
            "vol":0.5
         };
         _streamsLUT["aj_musnewjammaintro"] = {
            "name":"aj_musNewJammaIntro",
            "vol":0.47
         };
         _streamsLUT["ajq_musphntmcreepy"] = {
            "name":"ajq_musPhntmCreepy",
            "vol":0.55
         };
         _streamsLUT["ajq_mussearch4greelylp"] = {
            "name":"ajq_musSearch4GreelyLP",
            "vol":0.9
         };
         _streamsLUT["ajq_mus2phntmkings"] = {
            "name":"ajq_mus2PhntmKings",
            "vol":0.7
         };
         _assetPool = new Dictionary();
         _playerLeftObjects = [{
            "icon":GETDEFINITIONBYNAME("leaveAdvTxt"),
            "hasLeft":false,
            "complete":false
         },{
            "icon":GETDEFINITIONBYNAME("leaveAdvTxt"),
            "hasLeft":false,
            "complete":false
         },{
            "icon":GETDEFINITIONBYNAME("leaveAdvTxt"),
            "hasLeft":false,
            "complete":false
         }];
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_UP,keyHandleUp);
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyHandleDown);
         gMainFrame.stage.addEventListener(QuestEvent.LOAD_SFX,onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener(QuestEvent.PLAY_SFX,onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener(QuestEvent.TORCH,onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener(QuestEvent.TRIGGER_CAMERASHAKE,onQuestEvent,false,0,true);
      }
      
      public static function destroy() : void
      {
         gMainFrame.stage.removeEventListener(KeyboardEvent.KEY_UP,keyHandleUp);
         gMainFrame.stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyHandleDown);
         gMainFrame.stage.removeEventListener(QuestEvent.LOAD_SFX,onQuestEvent);
         gMainFrame.stage.removeEventListener(QuestEvent.PLAY_SFX,onQuestEvent);
         gMainFrame.stage.removeEventListener(QuestEvent.TORCH,onQuestEvent);
         gMainFrame.stage.removeEventListener(QuestEvent.TRIGGER_CAMERASHAKE,onQuestEvent);
         onExitRoom();
         setActorDictionary(null,null);
         clearPlayerDictionary();
      }
      
      private static function onQuestEvent(param1:QuestEvent) : void
      {
         var _loc2_:int = 0;
         if(_questActorDictionary != null)
         {
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
                  break;
               case QuestEvent.TORCH:
                  if(param1.secondaryType == "on")
                  {
                     addTorch(param1.target);
                  }
                  else
                  {
                     removeTorch(param1.target);
                  }
                  break;
               case QuestEvent.TRIGGER_CAMERASHAKE:
                  _shaketimer = 0.5;
            }
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
         var _loc3_:AvatarInfo = null;
         var _loc4_:int = 0;
         var _loc5_:AvatarEditor = null;
         var _loc6_:Object = null;
         if(_questExitPending)
         {
            _loc3_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
            if(_loc3_)
            {
               _loc3_.questTorchStatus = false;
            }
            if(_playSwfMC != null)
            {
               if(_playSwfMC.parent != null)
               {
                  _playSwfMC.parent.removeChild(_playSwfMC);
               }
               _playSwfMC = null;
               UserCommXtCommManager.sendPermEmote(-1,false);
            }
            if(_guiElementsSkipBtnMh)
            {
               _guiElementsSkipBtnMh.destroy();
               _guiElementsSkipBtnMh = null;
            }
            if(_guiElementsSkipBtn)
            {
               _guiElementsSkipBtn.removeEventListener(MouseEvent.MOUSE_DOWN,guiElementsSkipBtnPress);
               if(_guiElementsSkipBtn.parent)
               {
                  _guiElementsSkipBtn.parent.removeChild(_guiElementsSkipBtn);
               }
               _guiElementsSkipBtn.visible = false;
               _guiElementsSkipBtn = null;
            }
            _loc4_ = 0;
            while(_loc4_ < _guiElementsGuiManager.length)
            {
               if(GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]])
               {
                  if(GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].hasOwnProperty("setButtonState"))
                  {
                     GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].setButtonState(1);
                  }
                  GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].removeEventListener(MouseEvent.MOUSE_DOWN,guiDownHandler);
                  GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].removeEventListener(MouseEvent.MOUSE_OVER,guiDownHandler);
               }
               _loc4_ += 2;
            }
            GuiManager.grayHudAvatar(false);
            _loc5_ = GuiManager.avatarEditor;
            if(_loc5_ != null)
            {
               _loc4_ = 0;
               while(_loc4_ < _guiElementsAvatarEditor.length)
               {
                  if(_loc5_.avEditor[_guiElementsAvatarEditor[_loc4_ + 1]])
                  {
                     if(_loc5_.avEditor[_guiElementsAvatarEditor[_loc4_ + 1]].hasOwnProperty("setButtonState"))
                     {
                        _loc5_.avEditor[_guiElementsAvatarEditor[_loc4_ + 1]].setButtonState(1);
                     }
                     _loc5_.avEditor[_guiElementsAvatarEditor[_loc4_ + 1]].removeEventListener(MouseEvent.MOUSE_DOWN,avEdDownHandler);
                  }
                  _loc4_ += 2;
               }
            }
            _questPlayersSwitched = null;
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
            if(_progressingSC)
            {
               _progressingSC.stop();
            }
            if(_progressingSCnot)
            {
               _progressingSCnot.stop();
            }
            for(_loc2_ in _assetPool)
            {
               delete _assetPool[_loc2_];
            }
            _loc1_ = 0;
            while(_loc1_ < _playerLeftObjects.length)
            {
               _loc6_ = _playerLeftObjects[_loc1_];
               if((Boolean(_loc6_)) && Boolean(_loc6_.icon.parent) && _loc6_.icon.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc6_.icon);
               }
               _loc6_.hasLeft = false;
               _loc6_.complete = false;
               _loc1_++;
            }
            RoomManagerWorld.instance.setGridDepth(128);
            if(Boolean(_currentMusic) && Boolean(_SFX_Music[_currentMusic]))
            {
               _SFX_Music[_currentMusic].stop();
            }
            if(Boolean(_currentAmbient) && Boolean(_SFX_AmbientSC))
            {
               _SFX_AmbientSC.stop();
            }
            _currentMusic = _currentAmbient = null;
            if(_seedInventory)
            {
               _seedInventory.destroy();
               _seedInventory = null;
            }
            RoomManagerWorld.instance.removeAndClearMiniMap();
            if(_fader)
            {
               if(_fader.parent)
               {
                  _fader.parent.removeChild(_fader);
               }
               _fader = null;
            }
            _queueFadeIn = false;
         }
         if(_playSwfMCSC)
         {
            _playSwfMCSC.stop();
            _playSwfMCSC = null;
         }
         if(_currentVOSC)
         {
            _currentVOSC.stop();
            _currentVOSC = null;
         }
         if(Boolean(_fader) && Boolean(_fader.parent))
         {
            _fader.parent.removeChild(_fader);
            _fader = null;
         }
         if(_darknessMask)
         {
            removeDarkness();
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
         if(_fallingPhantoms.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _fallingPhantoms.length)
            {
               _loc2_ = _fallingPhantoms[_loc1_];
               if(_loc2_ != null)
               {
                  if(_loc2_.mh != null)
                  {
                     _loc2_.mh.destroy();
                     _loc2_.mh = null;
                  }
                  if(_loc2_.theSprite != null && _loc2_.theSprite.parent != null)
                  {
                     _loc2_.theSprite.parent.removeChild(_loc2_.theSprite);
                     _loc2_.theSprite = null;
                     _loc2_.npc = null;
                  }
               }
               _loc1_++;
            }
            _fallingPhantoms.splice(0,_fallingPhantoms.length);
         }
         _fallingPhantomVolumeActors = null;
         if(_talkingLoadingSpiral)
         {
            _talkingLoadingSpiral.destroy();
            _talkingLoadingSpiral = null;
         }
         _talkingPopup = null;
         _paused = true;
         _sceneLoaded = false;
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
            if(_loc7_._visible && _loc7_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT && _loc7_.plantTargettable())
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
      
      public static function getNearestActivePhantom(param1:Number, param2:Number, param3:Number, param4:int, param5:Boolean, param6:Boolean, param7:Boolean) : Array
      {
         var _loc8_:Array = null;
         var _loc9_:Number = NaN;
         var _loc11_:QuestActor = null;
         var _loc12_:Object = null;
         var _loc13_:Point = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc10_:QuestActor = null;
         param3 *= param3;
         for each(_loc11_ in _questActors)
         {
            if(_loc11_._visible && !_loc11_.isDead)
            {
               if(_loc11_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER && (param5 || _loc11_._seekActive != QuestActor.SEEKTYPE_OFF) || param6 && (_loc11_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE || _loc11_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY))
               {
                  _loc12_ = _loc11_.npcDef;
                  if(_loc11_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE || _loc11_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY || _loc12_ != null && _loc11_.isVulnerable() && (_loc12_.level <= param4 || param7))
                  {
                     _loc13_ = _loc11_.actorOffset;
                     _loc14_ = param1 - (_loc11_.x + _loc13_.x);
                     _loc15_ = param2 - (_loc11_.y + _loc13_.y);
                     _loc16_ = _loc14_ * _loc14_ + _loc15_ * _loc15_;
                     if(_loc16_ < param3)
                     {
                        if(_loc8_ == null)
                        {
                           _loc8_ = new Array();
                           _loc9_ = _loc16_;
                           _loc8_.push(_loc11_);
                        }
                        else if(_loc16_ < _loc9_)
                        {
                           _loc9_ = _loc16_;
                           _loc8_.unshift(_loc11_);
                        }
                        else
                        {
                           _loc8_.push(_loc11_);
                        }
                     }
                  }
               }
            }
         }
         return _loc8_;
      }
      
      public static function createDarkness() : void
      {
         if(_darknessMask)
         {
            throw new Error("Error creating darkness! Darkness is already created!");
         }
         _darknessMask = new Sprite();
         _darknessMask.blendMode = BlendMode.LAYER;
         _darknessMask.mouseEnabled = false;
         _darknessMask.mouseChildren = false;
         var _loc1_:Sprite = new Sprite();
         _loc1_.graphics.beginFill(0);
         _loc1_.graphics.drawRect(0,0,900,550);
         _loc1_.graphics.endFill();
         _darknessMask.addChild(_loc1_);
         _layerManager.bkg.addChild(_darknessMask);
         _torchLUT = new Dictionary();
      }
      
      public static function removeDarkness() : void
      {
         if(_darknessMask)
         {
            if(_darknessMask.parent)
            {
               _darknessMask.parent.removeChild(_darknessMask);
            }
            _darknessMask = null;
            _torches = null;
         }
      }
      
      public static function addTorch(param1:Object, param2:Number = 1, param3:int = 0, param4:int = 0) : MovieClip
      {
         var _loc5_:Object = null;
         var _loc7_:Boolean = false;
         if(!_sceneLoaded)
         {
            _addTorchQueue.push({
               "actor":param1,
               "scale":param2,
               "offsetX":param3,
               "offsetY":param4
            });
            return null;
         }
         if(_darknessMask == null)
         {
            _loc7_ = createDarknessFromScene();
            if(!_loc7_)
            {
               _actorLightQueue.push(param1);
               return null;
            }
            for each(_loc5_ in _actorLightQueue)
            {
               addTorch(_loc5_);
            }
            _actorLightQueue = [];
         }
         if(_torches)
         {
            for each(_loc5_ in _torches)
            {
               if(_loc5_.actor == param1)
               {
                  if(_loc5_.actor == AvatarManager.playerAvatarWorldView)
                  {
                     _loc5_.light.scaleX = _loc5_.light.scaleY = param2;
                  }
                  return null;
               }
            }
         }
         else
         {
            _torches = new Array();
         }
         _loc5_ = new Object();
         var _loc6_:Object = null;
         if(param1.hasOwnProperty("torch"))
         {
            _loc6_ = param1.torch;
            if(param1.parent == _layerManager.room_chat)
            {
               _loc5_.layer = 1;
               _loc6_.x = 650;
               _loc6_.y = 470;
            }
            else
            {
               param1 = param1.parent;
               _loc5_.layer = 1;
               _loc6_.x = 320;
               _loc6_.y = 180;
            }
         }
         else if(param1.hasOwnProperty("s") && Boolean(param1.s.content.hasOwnProperty("torch")))
         {
            _loc6_ = param1.s.content.torch;
            _loc5_.layer = 0;
         }
         if(_loc6_)
         {
            _loc5_.light = _loc6_;
            _loc5_.light.visible = true;
            _loc5_.offsetX = _loc5_.light.x;
            _loc5_.offsetY = _loc5_.light.y;
         }
         else
         {
            _loc5_.light = new torch();
            _loc5_.light.scaleX = _loc5_.light.scaleY = param2;
            _loc5_.offsetX = param3;
            _loc5_.offsetY = param4;
            _loc5_.layer = 1;
         }
         _darknessMask.addChild(_loc5_.light);
         _loc5_.light.blendMode = BlendMode.ERASE;
         _loc5_.actor = param1;
         _torchLUT[param1] = _loc5_;
         _torches.push(_loc5_);
         return _loc5_.light;
      }
      
      public static function createDarknessFromScene() : Boolean
      {
         var _loc2_:Shape = null;
         var _loc3_:Sprite = null;
         var _loc4_:* = 0;
         var _loc5_:DisplayObject = null;
         if(_sceneLoaded)
         {
         }
         var _loc1_:Array = RoomManagerWorld.instance.getDarknessFromScene();
         if(_loc1_.length > 0)
         {
            _darknessMask = new Sprite();
            _darknessMask.blendMode = BlendMode.LAYER;
            _darknessMask.mouseEnabled = false;
            _darknessMask.mouseChildren = false;
            for each(_loc2_ in _loc1_)
            {
               _darknessMask.addChild(_loc2_);
            }
            _darknessMask.x = _layerManager.room_avatars.x + _layerManager.room_bkg_group.x;
            _darknessMask.y = _layerManager.room_avatars.y + _layerManager.room_bkg_group.y;
            _loc3_ = _layerManager.room_fg;
            if(_loc3_.numChildren > 0)
            {
               _loc4_ = int(_loc3_.numChildren - 1);
               while(_loc4_ >= 0)
               {
                  _loc5_ = _loc3_.getChildAt(_loc4_);
                  if(!_loc5_.hasOwnProperty("eye") && !_loc5_.hasOwnProperty("watcher"))
                  {
                     break;
                  }
                  _loc4_--;
               }
               _loc3_.addChildAt(_darknessMask,_loc4_ >= 0 ? int(_loc4_) : 0);
            }
            else
            {
               _loc3_.addChild(_darknessMask);
            }
            _torchLUT = new Dictionary();
         }
         return _loc1_.length > 0;
      }
      
      public static function removeTorch(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(_torches != null)
         {
            _loc3_ = 0;
            for each(_loc2_ in _torches)
            {
               if(_loc2_.actor == param1)
               {
                  if(param1 == AvatarManager.playerAvatarWorldView)
                  {
                     _loc2_.light.scaleX = _loc2_.light.scaleY = QUEST_TORCH_UNLITSIZE;
                  }
                  else
                  {
                     _loc2_.light.parent.removeChild(_loc2_.light);
                     _torches.splice(_loc3_,1);
                  }
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      public static function heartbeat() : void
      {
         var _loc1_:AvatarWorldView = null;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:* = 0;
         var _loc5_:int = 0;
         var _loc6_:QuestPlayerData = null;
         if(!_paused)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_shaketimer > 0)
            {
               _shaketimer -= _frameTime;
               if(_shaketimer > 0)
               {
                  if(_shakeOrigPos != null)
                  {
                     shake();
                  }
                  else
                  {
                     startShake();
                  }
               }
               else
               {
                  _shaketimer = 0;
                  stopShake();
               }
            }
            if(_playSwfMC != null)
            {
               if(_playSwfMC.bFinished)
               {
                  if(_faderState < 3)
                  {
                     _faderState = 3;
                  }
               }
               else
               {
                  if(_faderState > 0)
                  {
                     RoomManagerWorld.instance.forceStopMovement();
                  }
                  if(_faderState >= 2)
                  {
                     _playSwfMCTimeElapsed += _frameTime;
                     _loc5_ = _playSwfMCTimeElapsed * 24;
                     if(_loc5_ >= _playSwfMC.totalFrames)
                     {
                        _loc5_ = _playSwfMC.totalFrames;
                     }
                     _playSwfMC.gotoAndStop(_loc5_);
                  }
               }
            }
            if(Boolean(_fader) && Boolean(_fader.parent))
            {
               if(_faderState == 0 || _faderState == 3)
               {
                  _fader.alpha += _frameTime * 1;
                  if(_fader.alpha >= 1)
                  {
                     _fader.alpha = 1;
                     ++_faderState;
                     if(_faderState == 4)
                     {
                        QuestXtCommManager.sendPlaySwfComplete();
                        if(_playSwfMC.parent != null)
                        {
                           _playSwfMC.parent.removeChild(_playSwfMC);
                        }
                        _playSwfMC = null;
                        UserCommXtCommManager.sendPermEmote(-1,false);
                     }
                  }
               }
               else if(Boolean(_playSwfMC) || _faderState == 4)
               {
                  if(_faderState == 1)
                  {
                     _faderState = 2;
                     playSwf();
                  }
                  if(_frameTime < 0.5)
                  {
                     _fader.alpha -= _frameTime * 1;
                     if(_fader.alpha <= 0)
                     {
                        _fader.alpha = 0;
                        if(_faderState == 4)
                        {
                           _fader.parent.removeChild(_fader);
                           _fader = null;
                        }
                     }
                  }
               }
            }
            _loc1_ = AvatarManager.playerAvatarWorldView;
            if(_questActorDictionary != null)
            {
               if(AvatarManager.playerAvatarWorldView)
               {
                  RoomManagerWorld.instance.updatePlayerPos(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
               }
               _gameIdleTimer += _frameTime;
               if(_gameIdleTimer > 4 * 60)
               {
                  if(_gameIdleTimer > 5 * 60)
                  {
                     _gameIdleTimer = 0;
                     commandExit(0,null);
                  }
                  else if(_kickPopup == null)
                  {
                     _kickPopup = new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14681),true,onKickWarningPopup);
                     AJAudio.playIdleWarningSound();
                  }
               }
               if(_fallingPhantomVolumeActors != null)
               {
                  updateFallingPhantoms();
               }
               for each(_loc6_ in _questPlayersDict)
               {
                  if(_loc6_ != null)
                  {
                     _loc6_.heartbeat();
                  }
               }
            }
            for each(_loc2_ in _torches)
            {
               if(_loc2_.actor != null)
               {
                  _loc2_.light.x = _loc2_.actor.x + _loc2_.offsetX;
                  _loc2_.light.y = _loc2_.actor.y + _loc2_.offsetY;
                  if(_loc2_.layer == 0)
                  {
                     _loc2_.light.x -= _layerManager.room_avatars.x;
                     _loc2_.light.y -= _layerManager.room_avatars.y;
                  }
                  else
                  {
                     _loc2_.light.x -= _loc2_.light.width * 0.5;
                     _loc2_.light.y -= _loc2_.light.height * 0.5;
                  }
               }
            }
            if(_darknessMask)
            {
               _darknessMask.x = _layerManager.room_avatars.x + _layerManager.room_bkg_group.x;
               _darknessMask.y = _layerManager.room_avatars.y + _layerManager.room_bkg_group.y;
            }
            if(_defeatedPopUpTimer > 0)
            {
               RoomManagerWorld.instance.forceStopMovement();
               _defeatedPopUpTimer -= _frameTime;
               if(_defeatedPopUpTimer <= 0)
               {
                  new SBParchmentPopup(GuiManager.guiLayer,SBParchmentPopup.TYPE_CONTINUE_ONLY,LocalizationManager.translateIdOnly(14811),true,onDeathAccept);
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
            for each(_loc3_ in _questActors)
            {
               if(_loc3_.isDead)
               {
                  _loc3_.destroy();
                  delete _questActors[_loc3_._actorId];
               }
               else
               {
                  _loc3_.heartbeat(_frameTime);
               }
            }
            _loc4_ = int(_questProjectiles.length - 1);
            while(_loc4_ >= 0)
            {
               if(_questProjectiles[_loc4_].heartbeat(_frameTime))
               {
                  _questProjectiles[_loc4_].destroy();
                  _questProjectiles.splice(_loc4_,1);
               }
               _loc4_--;
            }
            _loc4_ = int(_questMelees.length - 1);
            while(_loc4_ >= 0)
            {
               if(_questMelees[_loc4_].heartbeat(_frameTime))
               {
                  _questMelees[_loc4_].destroy();
                  _questMelees.splice(_loc4_,1);
               }
               _loc4_--;
            }
         }
      }
      
      private static function onFallingPhantomLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = param1.passback;
         _loc2_.mh.destroy();
         _loc2_.mh = null;
         _loc2_.npc = param1;
         _loc2_.npc.x = 0;
         _loc2_.npc.y = 0;
         param1.updateFallHeight(_loc2_.phantomStartY,0);
         param1.setInit();
         param1.appear();
         _loc2_.theSprite = new Sprite();
         _loc2_.theSprite.x = _loc2_.posX;
         _loc2_.theSprite.y = _loc2_.posY;
         _loc2_.theSprite.addChild(param1);
         _layerManager.room_avatars.addChild(_loc2_.theSprite);
         if(isOnscreen(_loc2_.npc))
         {
            _soundMan.play(_sounds[Math.random() < 0.5 ? (Math.random() < 0.5 ? "ajq_phntmflame1" : "ajq_phntmflame2") : (Math.random() < 0.5 ? "ajq_phntmfall1" : "ajq_phntmfall2")]);
         }
      }
      
      public static function updateFallingPhantoms() : void
      {
         var _loc1_:Object = null;
         var _loc2_:* = 0;
         var _loc3_:Number = NaN;
         var _loc4_:AvatarInfo = null;
         var _loc5_:Point = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Point = null;
         var _loc11_:Point = null;
         var _loc12_:Point = null;
         var _loc13_:Point = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:Object = null;
         var _loc17_:QuestActor = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Point = null;
         var _loc21_:Point = null;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:int = 0;
         var _loc25_:Array = null;
         var _loc26_:Array = null;
         if(_fallingPhantoms.length > 0)
         {
            _loc2_ = int(_fallingPhantoms.length - 1);
            while(_loc2_ >= 0)
            {
               _loc1_ = _fallingPhantoms[_loc2_];
               if(_loc1_.npc != null)
               {
                  if(_loc1_.timerElapsed < _loc1_.timerMax)
                  {
                     _loc1_.timerElapsed += _frameTime;
                     if(_loc1_.timerElapsed > _loc1_.timerMax)
                     {
                        _loc1_.timerElapsed = _loc1_.timerMax;
                     }
                     _loc3_ = _loc1_.timerElapsed / _loc1_.timerMax;
                     _loc1_.npc.updateFallHeight(_loc1_.phantomStartY * (1 - _loc3_),_loc3_);
                     if(_loc3_ >= 1 && isOnscreen(_loc1_.npc))
                     {
                        _soundMan.play(_sounds[Math.random() < 0.5 ? "ajq_phntmfdeath1" : "ajq_phntmfdeath2"]);
                     }
                  }
                  if(Boolean(_loc1_.npc.attacking) && AvatarManager.playerAvatarWorldView != null)
                  {
                     _loc4_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                     if(_loc4_.questHealthPercentage > 0)
                     {
                        _loc5_ = _loc1_.npc.getCollisionPoint(2);
                        _loc6_ = AvatarManager.playerAvatarWorldView.x + QUEST_PLAYER_AVATAR_OFFSETX - (_loc1_.posX + _loc5_.x);
                        _loc7_ = AvatarManager.playerAvatarWorldView.y + QUEST_PLAYER_AVATAR_OFFSETY - (_loc1_.posY + _loc5_.y);
                        _loc8_ = Number(_loc1_.npc.getCollisionRadius(2));
                        QUEST_PLAYER_AVATAR_RADIUS;
                        if(_loc6_ * _loc6_ + _loc7_ * _loc7_ < _loc8_ * _loc8_)
                        {
                           QuestXtCommManager.questPhantomZap("FallingPhantom",AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
                        }
                     }
                     _loc1_.npc.attacking = false;
                  }
                  if(_loc1_.timerElapsed >= _loc1_.timerMax && _loc1_.npc.animActive == false)
                  {
                     if(_loc1_.theSprite != null && _loc1_.theSprite.parent != null)
                     {
                        _loc1_.theSprite.parent.removeChild(_loc1_.theSprite);
                     }
                     _fallingPhantoms.splice(_loc2_,1);
                  }
               }
               _loc2_--;
            }
         }
         if(AvatarManager.playerAvatarWorldView != null)
         {
            _fallingPhantomTimer -= _frameTime;
            if(_fallingPhantomTimer <= 0)
            {
               _loc9_ = AvatarManager.playerAvatarWorldView.avatarPos.x - 500 + Math.random() * 1000;
               _loc10_ = null;
               _loc11_ = null;
               _loc12_ = new Point(_loc9_,AvatarManager.playerAvatarWorldView.avatarPos.y - 300);
               _loc13_ = new Point(_loc9_,AvatarManager.playerAvatarWorldView.avatarPos.y + 300);
               _loc16_ = null;
               _loc15_ = 0;
               while(_loc15_ < _fallingPhantomVolumeActors.length && _loc10_ == null)
               {
                  _loc17_ = _questActors[_fallingPhantomVolumeActors[_loc15_]];
                  if(_loc17_ != null && _loc17_._visible)
                  {
                     _loc14_ = 0;
                     while(_loc14_ < _loc17_._volumes.length && _loc10_ == null)
                     {
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(_loc12_,_loc17_._volumes[_loc14_]))
                        {
                           _loc10_ = _loc12_;
                        }
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(_loc13_,_loc17_._volumes[_loc14_]))
                        {
                           if(_loc10_ == null)
                           {
                              _loc10_ = _loc13_;
                           }
                           else
                           {
                              _loc11_ = _loc13_;
                           }
                        }
                        if(_loc10_ != null)
                        {
                           _loc16_ = _loc17_._volumes[_loc14_];
                        }
                        _loc14_++;
                     }
                  }
                  _loc15_++;
               }
               if(_loc11_ == null)
               {
                  _loc20_ = new Point();
                  _loc21_ = new Point();
                  if(_loc10_ == null)
                  {
                     _loc15_ = 0;
                     while(_loc15_ < _fallingPhantomVolumeActors.length)
                     {
                        _loc17_ = _questActors[_fallingPhantomVolumeActors[_loc15_]];
                        if(_loc17_ != null && _loc17_._visible)
                        {
                           _loc14_ = 0;
                           while(_loc14_ < _loc17_._volumes.length)
                           {
                              if(checkFallingPhantomVolumeIntersect(_loc17_._volumes[_loc14_].v,_loc12_,_loc13_,_loc20_,_loc21_))
                              {
                                 _loc10_ = _loc20_;
                                 _loc11_ = _loc21_;
                                 _loc16_ = _loc17_._volumes[_loc14_];
                                 break;
                              }
                              _loc14_++;
                           }
                        }
                        _loc15_++;
                     }
                  }
                  else if(checkFallingPhantomVolumeIntersect(_loc16_.v,_loc12_,_loc13_,_loc20_,_loc21_))
                  {
                     _loc11_ = _loc20_;
                  }
               }
               _loc18_ = 0.1;
               _loc19_ = 0.4;
               if(_loc11_ != null)
               {
                  _loc22_ = 0.75;
                  _loc23_ = 1.75;
                  if(_loc16_ != null && _loc16_.message.length > 0)
                  {
                     _loc25_ = _loc16_.message.split(",");
                     _loc24_ = 0;
                     for(; _loc24_ < _loc25_.length; _loc24_++)
                     {
                        _loc26_ = _loc25_[_loc24_].split("=");
                        if(_loc26_.length != 2)
                        {
                           continue;
                        }
                        switch(_loc26_[0])
                        {
                           case "ratemin":
                              _loc18_ = _loc26_[1] / 1000;
                              break;
                           case "ratemax":
                              _loc19_ = _loc26_[1] / 1000;
                              break;
                           case "speedmin":
                              _loc22_ = _loc26_[1] / 1000;
                              break;
                           case "speedmax":
                              _loc23_ = _loc26_[1] / 1000;
                        }
                     }
                  }
                  _loc1_ = new Object();
                  _loc1_.phantomStartY = -750;
                  _loc1_.timerMax = _loc22_ + Math.random() * (_loc23_ - _loc22_);
                  _loc1_.timerElapsed = 0;
                  _loc1_.posX = _loc9_;
                  _loc1_.posY = _loc10_.y + Math.random() * (_loc11_.y - _loc10_.y);
                  _loc1_.mh = new MediaHelper();
                  _loc1_.mh.init(getNPCDef(36).mediaRefId,onFallingPhantomLoaded,_loc1_);
                  _fallingPhantoms.push(_loc1_);
               }
               _fallingPhantomTimer = _loc18_ + Math.random() * (_loc19_ - _loc18_);
            }
         }
      }
      
      public static function checkFallingPhantomVolumeIntersect(param1:Array, param2:Point, param3:Point, param4:Point, param5:Point) : Boolean
      {
         var _loc10_:Point = null;
         var _loc6_:Number = param1.length - 1;
         var _loc7_:Point = null;
         var _loc8_:Point = null;
         var _loc9_:int = 0;
         while(_loc9_ < _loc6_)
         {
            param4.x = param1[_loc9_].x;
            param4.y = param1[_loc9_].y;
            param5.x = param1[_loc9_ + 1].x;
            param5.y = param1[_loc9_ + 1].y;
            _loc10_ = Collision.segIntersection(param2,param3,param4,param5);
            if(_loc10_ != null)
            {
               if(_loc7_ != null)
               {
                  _loc8_ = _loc10_;
                  break;
               }
               _loc7_ = _loc10_;
            }
            _loc9_++;
         }
         if(_loc7_ != null)
         {
            param4.x = _loc7_.x;
            param4.y = _loc7_.y;
         }
         if(_loc8_ != null)
         {
            param5.x = _loc8_.x;
            param5.y = _loc8_.y;
         }
         return _loc7_ != null;
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
         var _loc1_:Object = null;
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(Boolean(AvatarManager.playerAvatarWorldView) && (AvatarManager.playerAvatarWorldView.moving || _playerAvatarCurrentAnim != AvatarManager.playerAvatarWorldView.animId))
         {
            _playerAvatarCurrentAnim = AvatarManager.playerAvatarWorldView.animId;
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
            _loc1_ = RoomManagerWorld.instance.getNearestQuestRespawnPointPlayerIsIn(AvatarManager.playerAvatarWorldView.avatarPos);
            if(_loc1_ != null)
            {
               if(_loc1_.hasOwnProperty("name"))
               {
                  _loc4_ = _questActorDictionary[_loc1_.name];
               }
               if(_loc4_ == null || Boolean(_loc4_.visible))
               {
                  _nearestRespawnPoint = _loc1_;
               }
            }
            _playerInStealthVolume = RoomManagerWorld.instance.volumeManager.testStealthVolumes(AvatarManager.playerAvatarWorldView.avatarPos) != null;
         }
      }
      
      public static function setActorDictionary(param1:Dictionary, param2:String) : void
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         if(param1 != null)
         {
            _totalGemsEarned = 0;
            _totalXPEarned = 0;
         }
         _defeatedPopUpTimer = 0;
         _questScriptTimeStamp = param2;
         if(_questActors != null)
         {
            for(_loc5_ in _questActors)
            {
               _questActors[_loc5_].destroy();
               delete _questActors[_loc5_];
            }
         }
         _questActorDictionary = param1;
         _gameIdleTimer = 0;
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,resetMouseDownIdleTimer,false);
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_MOVE,resetMouseMoveIdleTimer,false);
         var _loc3_:Object = _questActorDictionary["diff_level"];
         if(_loc3_ != null)
         {
            _questDifficultyLevel = _loc3_.state;
         }
         else
         {
            _questDifficultyLevel = 0;
         }
         _questActorGroups = new Dictionary();
         for(_loc4_ in _questActorDictionary)
         {
            _loc6_ = _loc4_.lastIndexOf("__");
            if(_loc6_ != -1)
            {
               _loc7_ = _loc4_.substring(0,_loc6_);
               _loc8_ = _questActorGroups[_loc7_];
               if(_loc8_ == null)
               {
                  _loc8_ = new Array();
                  _questActorGroups[_loc7_] = _loc8_;
               }
               _loc8_.push(_loc4_);
            }
         }
         startFadeIn();
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
      
      private static function stopLightAnim(param1:Event) : void
      {
         var _loc2_:Loader = _playerTorch.getChildAt(0) as Loader;
         (_loc2_.content as MovieClip).stop();
         _playerTorch.removeEventListener(Event.COMPLETE,stopLightAnim);
      }
      
      public static function sceneAssetsLoaded() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:Point = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:Object = null;
         var _loc13_:int = 0;
         var _loc14_:QuestPlayerData = null;
         if(_questActorDictionary != null)
         {
            _nearestRespawnPoint = null;
            if(_queueFadeIn)
            {
               _queueFadeIn = false;
               startFadeIn();
            }
            if(_playMusicOnLoad)
            {
               if(_SFX_Music[_currentMusic] == null)
               {
                  _loc1_ = _streamsLUT[_currentMusic];
                  _SFX_Music[_currentMusic] = _soundMan.addStream(_loc1_.name,_loc1_.vol);
               }
               _soundMan.playStream(_SFX_Music[_currentMusic],0,99999);
               _playMusicOnLoad = false;
            }
            if(_questObjectiveText != null && GuiManager.mainHud.objBar != null)
            {
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#notify/" + _questObjectiveText);
               LocalizationManager.translateId(GuiManager.mainHud.questObjectiveTxt,int(_questObjectiveText));
               GuiManager.mainHud.objBar.gotoAndPlay("on");
            }
            else if(GuiManager.mainHud.questObjectiveTxt != null)
            {
               GuiManager.mainHud.questObjectiveTxt.text = "";
            }
            if(GuiManager.mainHud.questPlayersBtn != null)
            {
               GuiManager.mainHud.questPlayersBtn.activateGrayState(_questStartingPlayerCount <= 1);
            }
            if(_seedInventory == null)
            {
               _seedInventory = new SeedInventoryHandling();
               _seedInventory.init(_questSeeds);
            }
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
            RoomManagerWorld.instance.removeMiniMap();
            _fallingPhantomVolumeActors = null;
            for(_loc2_ in _questActorDictionary)
            {
               _loc3_ = _questActorDictionary[_loc2_];
               if(_loc3_ == null)
               {
                  continue;
               }
               switch(_loc3_.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMEPLACEMENT:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMEINTERACTION:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUME_FALLING_PHANTOM:
                     _loc4_ = RoomManagerWorld.instance.volumeManager.findVolume(_loc2_);
                     if(_loc4_ != null)
                     {
                        initQuestActor(_loc2_,0,0,null,null);
                        if(_loc3_.type == QuestActor.QUEST_ACTOR_TYPE_VOLUME_FALLING_PHANTOM)
                        {
                           if(_fallingPhantomVolumeActors == null)
                           {
                              _fallingPhantomVolumeActors = new Array();
                           }
                           _fallingPhantomVolumeActors.push(_loc2_);
                        }
                     }
                     break;
                  case QuestActor.QUEST_ACTOR_TYPE_SPAWN:
                     _loc5_ = RoomManagerWorld.instance.findSpawn(null,_loc2_);
                     if(_loc5_ != null)
                     {
                        _loc7_ = new Point(_loc5_.x,_loc5_.y);
                        RoomManagerWorld.instance.convertToWorldSpace(_loc7_);
                        initQuestActor(_loc2_,0,0,null,_loc7_);
                     }
                     break;
                  case QuestActor.QUEST_ACTOR_TYPE_TILE:
                     _loc6_ = RoomManagerWorld.instance.findLayers(_loc2_);
                     if(_loc6_ != null)
                     {
                        for each(_loc8_ in _loc6_)
                        {
                           if(_loc3_.state > 0)
                           {
                              if(_loc8_.s.content["setState"] != null)
                              {
                                 _loc8_.s.content.setState(_loc3_.state,true);
                              }
                           }
                           if(_loc8_.s.content.hasOwnProperty("setProgress"))
                           {
                              _loc8_.s.content.setProgress(_loc3_.progress);
                           }
                           _loc8_.s.content.visible = _loc3_.visible;
                        }
                     }
                     break;
                  default:
                     if(_loc3_.spawnedFromActor != null)
                     {
                        doSpawnToRoot(_loc3_);
                     }
               }
            }
            RoomManagerWorld.instance.createMiniMap();
            _sceneLoaded = true;
            _playerTorch = addTorch(AvatarManager.playerAvatarWorldView,QUEST_TORCH_UNLITSIZE,-15,-50);
            if(_playerTorch)
            {
               _playerTorch.addEventListener(Event.COMPLETE,stopLightAnim,false,0,true);
            }
            while(_addTorchQueue.length)
            {
               _loc9_ = _addTorchQueue.pop();
               addTorch(_loc9_.actor,_loc9_.scale,_loc9_.offsetX,_loc9_.offsetY);
            }
            if(_questActorDictionary["gui_ffm"])
            {
               _guiElementsSkipBtn = new MovieClip();
               _guiElementsSkipBtnMh = new MediaHelper();
               _guiElementsSkipBtnMh.init(FirstFiveMinutes.SKIP_BUTTON,skipButtonMediaCallback,true);
               _loc10_ = 0;
               while(_loc10_ < _guiElementsGuiManager.length)
               {
                  if(GuiManager.mainHud[_guiElementsGuiManager[_loc10_ + 1]])
                  {
                     _loc11_ = _questActorDictionary[_guiElementsGuiManager[_loc10_]];
                     if(_loc11_.state >= 0 && _loc11_.state <= 2)
                     {
                        if(GuiManager.mainHud[_guiElementsGuiManager[_loc10_ + 1]].hasOwnProperty("setButtonState"))
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[_loc10_ + 1]].setButtonState(_loc11_.state);
                        }
                        if(_guiElementsGuiManager[_loc10_ + 1] == "gemsBtn")
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[_loc10_ + 1]].addEventListener(MouseEvent.MOUSE_OVER,guiDownHandler,false,0,true);
                        }
                        else
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[_loc10_ + 1]].addEventListener(MouseEvent.MOUSE_DOWN,guiDownHandler,false,0,true);
                        }
                        if(_guiElementsGuiManager[_loc10_ + 1] == "charWindow")
                        {
                           GuiManager.grayHudAvatar(_loc11_.state == 0);
                        }
                     }
                  }
                  _loc10_ += 2;
               }
            }
            if(_questPlayersSwitched)
            {
               for(_loc12_ in _questPlayersSwitched)
               {
                  _loc13_ = int(_questPlayersSwitched[_loc12_]);
                  _loc14_ = getQuestPlayerData(_loc12_ as int);
                  if(_loc14_ != null)
                  {
                     _loc14_.setAvatarSwitched(_loc13_);
                  }
               }
            }
         }
      }
      
      private static function guiDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!param1.currentTarget.isGray)
         {
            _loc2_ = 0;
            while(_loc2_ < _guiElementsGuiManager.length)
            {
               if(param1.currentTarget == GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]])
               {
                  QuestXtCommManager.questActorTriggered(_guiElementsGuiManager[_loc2_]);
                  break;
               }
               _loc2_ += 2;
            }
         }
      }
      
      private static function avEdDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!param1.currentTarget.isGray)
         {
            _loc2_ = 0;
            while(_loc2_ < _guiElementsAvatarEditor.length)
            {
               if(param1.currentTarget.name == _guiElementsAvatarEditor[_loc2_ + 1])
               {
                  QuestXtCommManager.questActorTriggered(_guiElementsAvatarEditor[_loc2_]);
                  break;
               }
               _loc2_ += 2;
            }
         }
      }
      
      private static function skipButtonMediaCallback(param1:MovieClip) : void
      {
         _guiElementsSkipBtn.addChild(param1);
         GuiManager.guiLayer.addChild(_guiElementsSkipBtn);
         _guiElementsSkipBtn.x = 810;
         _guiElementsSkipBtn.y = 420;
         _guiElementsSkipBtn.visible = true;
         _guiElementsSkipBtn.addEventListener(MouseEvent.MOUSE_DOWN,guiElementsSkipBtnPress,false,0,true);
         _guiElementsSkipBtnMh.destroy();
         _guiElementsSkipBtnMh = null;
      }
      
      public static function guiElementsSkipBtnPress(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.questActorTriggered("gui_20");
         _guiElementsSkipBtn.visible = false;
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
      
      public static function initQuestActor(param1:String, param2:int, param3:int, param4:Object = null, param5:Point = null, param6:Point = null, param7:Boolean = false, param8:String = null) : void
      {
         var _loc9_:Boolean = false;
         var _loc10_:QuestActor = null;
         var _loc11_:Array = null;
         var _loc12_:Object = null;
         if(_questActorDictionary != null)
         {
            if(param4 == null)
            {
               param4 = _questActorDictionary[param1];
            }
            if(param4 != null && param8 != null && param8.length > 0)
            {
               param4.extendedParameters = param8;
            }
            if(param4 != null)
            {
               if(param7)
               {
                  if(param4.hasOwnProperty("previouslyPickedUp") && Boolean(param4.previouslyPickedUp))
                  {
                     return;
                  }
               }
               if(!param4.hasOwnProperty("actorPos"))
               {
                  param4.actorPos = param5;
               }
               if(_questActors[param1] != null)
               {
                  _questActors[param1].destroy();
               }
               _loc9_ = true;
               switch(param4.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
                  case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
                  case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
                     if(param4.healthPercent == 0)
                     {
                     }
               }
               if(_loc9_)
               {
                  if(param4.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER || param4.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY || param4.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE || param4.type == QuestActor.QUEST_ACTOR_TYPE_PLANT || param4.type == QuestActor.QUEST_ACTOR_TYPE_NPC || param4.type == QuestActor.QUEST_ACTOR_TYPE_LIGHT_BEAM)
                  {
                  }
                  if(_loc10_ == null)
                  {
                     _loc10_ = new QuestActor();
                     _loc10_.initActor(param1,param4,param2,param3,_actorPriority++,param6);
                  }
                  else
                  {
                     _loc10_.resetActor(param1,param4,param2,param3,_actorPriority++,param6);
                  }
                  _loc10_.setRequireClick(param4.requireClick);
                  _loc10_.setVisible(param4.visible);
                  _questActors[param1] = _loc10_;
                  switch(param4.type)
                  {
                     case QuestActor.QUEST_ACTOR_TYPE_TILE:
                        _loc11_ = RoomManagerWorld.instance.findLayers(param1);
                        if(_loc11_ != null)
                        {
                           for each(_loc12_ in _loc11_)
                           {
                              if(_loc12_.s.content["setState"] != null)
                              {
                                 _loc12_.s.content.setState(param4.state,true);
                              }
                              if(_loc12_.s.content.hasOwnProperty("setProgress"))
                              {
                                 _loc12_.s.content.setProgress(param4.progress);
                              }
                              _loc12_.s.content.visible = param4.visible;
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
            LocalizationManager.translateId(GuiManager.mainHud.questObjectiveTxt,int(_questObjectiveText));
            GuiManager.mainHud.objBar.gotoAndPlay("on");
            playSound("ajq_questNotification");
         }
      }
      
      public static function commandSay(param1:int, param2:Object) : void
      {
         _questCommandActor = null;
         _questCommandActorState = -1;
         var _loc3_:QuestActor = _questActors[param2[param1++]];
         var _loc4_:String = LocalizationManager.translateIdOnly(param2[param1++]);
         var _loc5_:int = int(param2[param1++]);
         switch(_loc5_)
         {
            case 1:
               if(_loc3_ != null)
               {
                  _loc3_.setChatBalloonText(_loc4_);
                  GuiManager.chatHist.addMessage("",_loc4_);
               }
               break;
            case 2:
               if(_loc3_ != null)
               {
                  _loc3_.setChatBalloonText(_loc4_,true);
               }
               break;
            default:
               if(_talkingPopup != null)
               {
                  onTalkingPopupClose(null);
               }
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
         showTalkingDialog(GuiManager.guiLayer,LocalizationManager.translateIdOnly(param2[param1++]).split("|"),_loc4_ != null && _questCommandActor != "ask_actor" ? _loc4_.talkingHeadMediaRef : (_questCommandActor == "ask_actor" ? -1 : 0),-1,_loc3_ == 1);
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
      
      public static function commandSetState(param1:int, param2:Object, param3:Boolean) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:Array = null;
         var _loc12_:AvatarEditor = null;
         var _loc13_:Object = null;
         if(_questActorDictionary != null)
         {
            _loc5_ = param2[param1++];
            _loc4_ = _questActorDictionary[_loc5_];
            if(_loc4_ != null)
            {
               _loc6_ = int(param2[param1++]);
               if(param3)
               {
                  _loc4_.state = _loc6_;
               }
               else
               {
                  _loc7_ = param2[param1++] == 1;
                  _loc8_ = param2[param1++] == 1;
                  _loc4_.requireClick = _loc8_;
                  _loc4_.visible = _loc7_;
                  _loc4_.state = _loc6_;
                  if(ExternalInterface.available)
                  {
                     ExternalInterface.call("mrc",["dm","ACS," + _loc5_ + "," + _loc6_]);
                  }
                  switch(_loc4_.type)
                  {
                     case QuestActor.QUEST_ACTOR_TYPE_GUI:
                        _loc9_ = false;
                        _loc10_ = 0;
                        while(_loc10_ <= _guiElementsGuiManager.length)
                        {
                           if(_loc5_ == _guiElementsGuiManager[_loc10_])
                           {
                              if(GuiManager.mainHud[_guiElementsGuiManager[_loc10_ + 1]])
                              {
                                 if(GuiManager.mainHud[_guiElementsGuiManager[_loc10_ + 1]].hasOwnProperty("setButtonState"))
                                 {
                                    GuiManager.mainHud[_guiElementsGuiManager[_loc10_ + 1]].setButtonState(_loc4_.state);
                                 }
                                 if(_guiElementsGuiManager[_loc10_ + 1] == "charWindow")
                                 {
                                    GuiManager.grayHudAvatar(_loc4_.state == 0);
                                 }
                              }
                              _loc9_ = true;
                              break;
                           }
                           _loc10_ += 2;
                        }
                        if(!_loc9_)
                        {
                           _loc12_ = GuiManager.avatarEditor;
                           if(_loc12_ != null)
                           {
                              _loc10_ = 0;
                              while(_loc10_ <= _guiElementsAvatarEditor.length)
                              {
                                 if(_loc5_ == _guiElementsAvatarEditor[_loc10_])
                                 {
                                    if(_loc12_.avEditor[_guiElementsAvatarEditor[_loc10_ + 1]])
                                    {
                                       if(_loc12_.avEditor[_guiElementsAvatarEditor[_loc10_ + 1]].hasOwnProperty("setButtonState"))
                                       {
                                          if(_loc4_.state == 1 || _loc4_.state == 2)
                                          {
                                             switch(_guiElementsAvatarEditor[_loc10_ + 1])
                                             {
                                                case "colorsTabUp":
                                                   _loc12_.openTab(AvatarEditor.COLOR_TAB_ID);
                                                   break;
                                                case "eyesTabUp":
                                                   _loc12_.openTab(AvatarEditor.EYE_TAB_ID);
                                                   break;
                                                case "patternTabUp":
                                                   _loc12_.openTab(AvatarEditor.PATTERN_TAB_ID);
                                             }
                                          }
                                          _loc12_.avEditor[_guiElementsAvatarEditor[_loc10_ + 1]].setButtonState(_loc4_.state);
                                       }
                                    }
                                    _loc9_ = true;
                                    break;
                                 }
                                 _loc10_ += 2;
                              }
                           }
                        }
                        break;
                     case QuestActor.QUEST_ACTOR_TYPE_TILE:
                        _loc11_ = RoomManagerWorld.instance.findLayers(_loc5_);
                        if(_loc11_ != null)
                        {
                           for each(_loc13_ in _loc11_)
                           {
                              if(_loc13_.s != null && _loc13_.s.content != null)
                              {
                                 if(_loc13_.s.content["setState"] != null)
                                 {
                                    _loc13_.s.content.setState(_loc4_.state);
                                 }
                                 _loc13_.s.content.visible = _loc7_;
                              }
                           }
                        }
                        break;
                     case QuestActor.QUEST_ACTOR_TYPE_VARIABLE:
                        QuestXtCommManager.questActorTriggered(_loc5_);
                        break;
                     default:
                        _loc4_ = _questActors[_loc5_];
                        if(_loc4_ != null)
                        {
                           _loc4_.setRequireClick(_loc8_);
                           _loc4_.setVisible(_loc7_);
                           _loc4_.onRadiusTest();
                        }
                  }
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
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         _loc4_ = param2[param1++];
         _loc3_ = _questActors[_loc4_];
         if(_loc3_ != null)
         {
            _loc5_ = 0.75;
            _loc6_ = 1.5;
            _loc7_ = 0.75;
            if(_loc3_._actorData.extendedParameters != null)
            {
               _loc8_ = _loc3_._actorData.extendedParameters.split(",");
               _loc9_ = 0;
               while(_loc9_ < _loc8_.length)
               {
                  _loc10_ = _loc8_[_loc9_].split("=");
                  switch(_loc10_[0])
                  {
                     case "camto":
                        _loc5_ = Number(_loc10_[1]);
                        break;
                     case "camstay":
                        _loc6_ = Number(_loc10_[1]);
                        break;
                     case "camreturn":
                        _loc7_ = Number(_loc10_[1]);
                  }
                  _loc9_++;
               }
            }
            RoomManagerWorld.instance.setCameraFocus(new Point(_loc3_.x,_loc3_.y),_loc5_,_loc6_,_loc7_,true);
         }
      }
      
      public static function commandExit(param1:int, param2:Object) : void
      {
         _questExitPending = true;
         _questObjectiveText = "";
         AvatarManager.setPlayerAttachmentEmot(0,null,0);
         if(_questActorDictionary["gui_ffm"])
         {
            QuestXtCommManager.sendQuestExit("ffm");
         }
         else
         {
            RoomManagerWorld.instance.setGotoSpawnPoint("quest_end");
            QuestXtCommManager.sendQuestExit("");
         }
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
      
      public static function handleCommand(param1:Object, param2:Boolean) : void
      {
         var _loc3_:* = 2;
         var _loc4_:int = int(param1[_loc3_++]);
         switch(_loc4_)
         {
            case QUEST_CMD_SET_STATE:
               commandSetState(_loc3_,param1,param2);
               break;
            case QUEST_CMD_NOTIFY:
               commandNotify(_loc3_,param1);
               break;
            case QUEST_CMD_SAY:
               commandSay(_loc3_,param1);
               break;
            case QUEST_CMD_ASK:
               commandAsk(_loc3_,param1);
               break;
            case QUEST_CMD_GAME:
               commandGame(_loc3_,param1);
               break;
            case QUEST_CMD_TELEPORT:
               commandTeleport(_loc3_,param1);
               break;
            case QUEST_CMD_FOCUS:
               commandFocus(_loc3_,param1);
               break;
            case QUEST_CMD_ON_EXIT:
               commandExit(_loc3_,param1);
               break;
            case QUEST_CMD_TAKE_ITEM:
               commandTakeItem(_loc3_,param1);
               break;
            case QUEST_CMD_DEBUGSAY:
               commandDebugSay(_loc3_,param1);
         }
      }
      
      public static function showTalkingDialog(param1:DisplayLayer, param2:Array, param3:int = 0, param4:int = -1, param5:Boolean = false) : void
      {
         var textIndex:int = 0;
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
            if(talkingHeadMediaRef == -1)
            {
               if(useYesNo)
               {
                  new SBYesNoPopup(popupLayer,fullTextSplit[0],true,onConfirmBtn);
               }
               else
               {
                  new SBOkPopup(popupLayer,fullTextSplit[0],true,onConfirmBtn);
               }
               return;
            }
            if(talkingHeadMediaRef == 0)
            {
               _talkingPopup.gotoAndStop("questingPopup");
               _talkingPopup.txt.text = fullTextSplit.length > 1 ? fullTextSplit[1] : fullTextSplit[0];
               GuiManager.chatHist.addMessage("",_talkingPopup.txt.text);
            }
            else
            {
               _talkingPopup.gotoAndStop("talkingHead");
               _talkingPopup.talkingHeadTitleTxt.text = fullTextSplit[0];
               _talkingPopup.txt.text = fullTextSplit[1];
               textIndex = 1;
               while(textIndex < fullTextSplit.length)
               {
                  GuiManager.chatHist.addMessage("",fullTextSplit[textIndex]);
                  textIndex++;
               }
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
            _talkingPopup.useYesNo = useYesNo;
            if(useYesNo && _talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
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
                  if(useYesNo)
                  {
                     _talkingPopup.yesBtn.addEventListener(MouseEvent.MOUSE_DOWN,onYesBtn,false,0,true);
                     _talkingPopup.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,onNoBtn,false,0,true);
                  }
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
                  "amount":LocalizationManager.translateIdAndInsertOnly(LocalizationManager.GEMS_CAPITALIZED,param1.currentTarget.prize.amount)
               });
               return;
            case 4:
               _loc3_ = GiftPopup.GIFT_TYPE_ORBS;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(StartupPopups.DIAMOND_MEDIA_ID,rewardsGemOrOrbLoaded,{
                  "giftType":_loc3_,
                  "amount":LocalizationManager.translateIdAndInsertOnly(LocalizationManager.ORBS_CAPITALIZED,param1.currentTarget.prize.amount)
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
      
      private static function onConfirmBtn(param1:Object) : void
      {
         onCommandAskConfirm(param1.status);
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
               if(_talkingPopup.useYesNo)
               {
                  _talkingPopup.yesBtn.visible = true;
                  _talkingPopup.noBtn.visible = true;
                  _talkingPopup.okBtn.visible = false;
                  _talkingPopup.nextBtn.visible = false;
               }
               else
               {
                  _talkingPopup.okBtn.visible = true;
               }
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
         _questSeeds = new Dictionary();
         if(_seedInventory != null)
         {
            _seedInventory.destroy();
            _seedInventory = null;
         }
         _questObjectiveText = "";
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#NumPlayers/" + _questStartingPlayerCount);
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#Difficulty/" + _questDifficultyLevel);
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
            AvatarManager.resetCustomAdventureState();
         }
         RoomManagerWorld.instance.setGridDepth(25);
      }
      
      public static function handleQuestWaitResponse(param1:Object) : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.handleWaitResponse(param1);
         }
         if(_privateAdventureJoin)
         {
            _privateAdventureJoin.handleWaitResponse(param1);
         }
      }
      
      public static function handleQuestJoinCancelResponse(param1:Object) : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
         }
      }
      
      public static function handleQuestJoinResponse(param1:Object, param2:String, param3:int = 0) : void
      {
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         if(param2 == AdventureJoin.CUSTOM_SETTINGS_TYPE)
         {
            if(_adventureJoin)
            {
               _adventureJoin.destroy();
               _adventureJoin = null;
            }
            if(_privateAdventureJoin)
            {
               _privateAdventureJoin.destroy();
               _privateAdventureJoin = null;
            }
            _privateAdventureJoin = new PrivateAdventureJoin();
            _privateAdventureJoin.init(privateAdventureJoinClose);
            UserCommXtCommManager.sendCustomAdventureMessage(true);
         }
         else
         {
            openAdventureJoin(param1[4],param2,param3);
         }
      }
      
      public static function openAdventureJoin(param1:int, param2:String, param3:int) : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
         }
         _adventureJoin = new AdventureJoin();
         _adventureJoin.init(param1,param2,param3,adventureJoinClose);
      }
      
      public static function get isInPrivateAdventureState() : Boolean
      {
         return _privateAdventureJoin != null;
      }
      
      public static function updatePrivateAdventureIndexComparedToMainHud() : void
      {
         if(_privateAdventureJoin)
         {
            _privateAdventureJoin.updateDisplayIndex();
         }
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
         var _loc7_:int = int(param1[_loc4_++]);
         var _loc8_:int = int(param1[_loc4_++]);
         var _loc9_:int = int(param1[_loc4_++]);
         var _loc10_:int = int(param1[_loc4_++]);
         var _loc11_:Object = _questActorDictionary[_loc3_];
         if(_loc11_ != null)
         {
            _loc11_.actorPos = new Point(_loc5_,_loc6_);
         }
         _loc2_ = _questActors[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handlePositionUpdate(_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,_loc10_);
         }
      }
      
      public static function setQuestActorSeek(param1:QuestActor, param2:int) : void
      {
         if(param2 > param1._actorData.seekType || AvatarManager.playerSfsUserId == param1._actorData.seekTypeSfsId)
         {
            QuestXtCommManager.questActorSeek(param1._actorId,param2);
         }
      }
      
      public static function handleQuestActorRequestSeekResponse(param1:Object) : void
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
            if(_loc5_ > _loc7_.seekType || _loc6_ == _loc7_.seekTypeSfsId)
            {
               _loc7_.seekType = _loc5_;
               _loc7_.seekTypeSfsId = _loc6_;
            }
         }
         if(_loc6_ == AvatarManager.playerSfsUserId)
         {
            _loc2_ = _questActors[_loc3_];
            if(_loc2_ != null)
            {
               _loc2_.handleRequestSeekResponse(_loc5_);
            }
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
         var _loc2_:* = 0;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:QuestActor = null;
         if(_questActorDictionary != null)
         {
            _loc2_ = 2;
            _loc3_ = param1[_loc2_++];
            _loc4_ = param1[_loc2_++];
            _loc5_ = _questActorDictionary[_loc3_];
            if(_loc5_ != null)
            {
               _loc5_.pendingSwfStateName = _loc4_;
            }
            _loc6_ = _questActors[_loc3_];
            if(_loc6_ != null)
            {
               _loc6_.setSwfState(_loc4_);
            }
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
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:Point = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Boolean = false;
         var _loc14_:QuestActor = null;
         var _loc15_:int = 0;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         switch(_loc3_)
         {
            case 0:
               _loc4_ = param1[_loc2_++];
               new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14812),true,onDropItemConfirm,_loc4_);
               break;
            case 1:
            case 3:
            case 4:
               _loc5_ = param1[_loc2_++];
               _loc6_ = _questActorDictionary[_loc5_];
               _loc7_ = int(param1[_loc2_++]);
               if(_loc3_ == 4 || _loc3_ == 3)
               {
                  _loc8_ = new Point(param1[_loc2_++],param1[_loc2_++]);
                  if(_loc3_ == 4)
                  {
                     _loc10_ = int(param1[_loc2_++]);
                     _loc11_ = int(param1[_loc2_++]);
                     _loc12_ = int(param1[_loc2_++]);
                     if(_loc12_ == AvatarManager.playerSfsUserId)
                     {
                        _loc9_ = param1[_loc2_++];
                     }
                  }
               }
               if(_loc6_ != null)
               {
                  if(_loc6_.type == QuestActor.QUEST_ACTOR_TYPE_ITEM)
                  {
                     _loc6_.previouslyPickedUp = true;
                  }
                  _loc13_ = _loc3_ == 4 || _loc3_ == 3 || _loc6_.type == QuestActor.QUEST_ACTOR_TYPE_GROUP_ITEM;
                  if(_loc8_ != null && _loc6_.type != QuestActor.QUEST_ACTOR_TYPE_GROUP_ITEM)
                  {
                     _loc6_.actorPos = _loc8_;
                  }
                  _loc6_.visible = _loc13_;
                  _loc14_ = _questActors[_loc5_];
                  if(_loc14_ != null)
                  {
                     if(_loc8_ != null && _loc6_.type != QuestActor.QUEST_ACTOR_TYPE_GROUP_ITEM)
                     {
                        _loc14_.x = _loc8_.x;
                        _loc14_.y = _loc8_.y;
                     }
                     _loc14_.setVisible(_loc13_);
                     if(_loc7_ == AvatarManager.playerSfsUserId && _loc3_ != 4)
                     {
                        _loc15_ = _loc3_ == 4 || _loc3_ == 3 ? 0 : UserCommXtCommManager.getEmoticonDefId(_loc14_._actorData.defId);
                        AvatarManager.setPlayerAttachmentEmot(_loc15_,null,0);
                        AvatarManager._setAvatarAttachmentEmot(_loc3_ == 4 || _loc3_ == 3 ? 0 : int(_loc14_._actorData.defId),"",_loc7_);
                        if(Boolean(_loc14_._mediaObject) && _loc14_._mediaObject.hasOwnProperty("playPickupSound"))
                        {
                           _loc14_._mediaObject.playPickupSound();
                        }
                     }
                  }
                  else if(_loc3_ == 4)
                  {
                     initQuestActor(_loc5_,_loc10_,_loc11_,null,new Point(_loc8_.x,_loc8_.y));
                  }
               }
               break;
            case 2:
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14813));
         }
      }
      
      public static function handleMovedItemList(param1:Array) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Point = null;
         var _loc2_:* = 2;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1[_loc2_++];
            _loc4_ = int(param1[_loc2_++]);
            _loc5_ = int(param1[_loc2_++]);
            _loc6_ = new Point(param1[_loc2_++],param1[_loc2_++]);
            if(_questActors[_loc3_])
            {
               _loc2_ += 2;
            }
            else
            {
               initQuestActor(_loc3_,_loc4_,_loc5_,null,_loc6_);
            }
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
         _totalXPEarned += _loc3_;
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
      
      public static function handleAvSwitch(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         if(_loc3_ != -1)
         {
            if(_questPlayersSwitched == null)
            {
               _questPlayersSwitched = new Dictionary();
            }
            _questPlayersSwitched[_loc4_] = _loc3_;
         }
         else if(_questPlayersSwitched != null && _questPlayersSwitched[_loc4_] != null)
         {
            delete _questPlayersSwitched[_loc4_];
         }
         var _loc5_:QuestPlayerData = getQuestPlayerData(_loc4_);
         if(_loc5_ != null)
         {
            _loc5_.setAvatarSwitched(_loc3_);
         }
      }
      
      public static function handleExitByType(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         if(_loc3_ == "ffm")
         {
            AvatarXtCommManager.sendAvatarFiveMinutesUpdate([0]);
            gMainFrame.userInfo.firstFiveMinutes = 1;
            GuiManager.wasInFFM = true;
            GuiManager.isInFFM = false;
            RoomManagerWorld.instance.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest("jamaa_township.room_main#" + RoomManagerWorld.instance.shardId);
            LoadProgress.show(true);
            GuiManager.initPlayerEngagement(null);
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
            case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
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
         var _loc5_:int = 0;
         var _loc6_:Point = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc3_:QuestActor = _questActors[param1.spawnedFromActor];
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            _loc5_ = 0;
            _loc6_ = null;
            if(param1.actorPos == null)
            {
               _loc7_ = _loc3_.x;
               _loc8_ = _loc3_.y;
               switch(param1.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
                  case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
                     if(_loc3_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY)
                     {
                        _loc9_ = 2 * _loc3_._actorDefaultInnerRadius * param1.spawnOffsetX / 1000 - _loc3_._actorDefaultInnerRadius;
                        _loc10_ = 2 * _loc3_._actorDefaultInnerRadius * param1.spawnOffsetY / 1000 - _loc3_._actorDefaultInnerRadius;
                        _loc7_ += _loc9_;
                        _loc8_ += _loc10_;
                        _loc6_ = new Point(-_loc9_,-_loc10_);
                     }
               }
               param1.actorPos = new Point(_loc7_,_loc8_);
               initQuestActor(param1.actorName,_loc4_,_loc5_,param1,null,_loc6_);
            }
            switch(param1.type)
            {
               case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
               case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
                  param1.respawned = true;
                  if(_loc3_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY)
                  {
                     _loc4_ = QuestActor.DEFAULT_PHANTOM_VISION_RADIUS;
                     _loc5_ = _loc3_._actorDefaultOuterRadius;
                  }
            }
            initQuestActor(param1.actorName,_loc4_,_loc5_,param1,null,_loc6_);
         }
      }
      
      public static function loadLevelShape(param1:int) : void
      {
         _levelShapeHelper = new MediaHelper();
         var _loc2_:int = Math.floor(param1 / 5) > NameBar.LEVEL_SHAPES.length - 1 ? int(NameBar.LEVEL_SHAPES[NameBar.LEVEL_SHAPES.length - 1]) : int(NameBar.LEVEL_SHAPES[Math.floor(param1 / 5)]);
         _levelShapeHelper.init(_loc2_,onLevelShapeLoaded,param1);
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
               if(_loc5_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE || _loc5_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER && _loc5_._attackable > 0)
               {
                  _loc5_.setActorText("miss");
               }
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
      
      public static function handleQuestVolumeInteractionUpdate(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:Object = null;
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:int = int(param1[_loc2_++]);
         _loc5_ = _questActorDictionary[_loc3_];
         if(_loc5_ != null)
         {
            if(_loc5_.progress == 0 && _loc4_ > 0)
            {
               playSound("ajq_chainstart");
            }
            if(_loc4_ > _loc5_.progress)
            {
               if(_progressingSC == null)
               {
                  _progressingSC = playLoopingSound("ajq_chain1lp");
                  if(_progressingSCnot)
                  {
                     _progressingSCnot.stop();
                     _progressingSCnot = null;
                  }
               }
               _volumeInteractionProgressing = true;
            }
            else if(_loc4_ < _loc5_.progress)
            {
               if(_volumeInteractionProgressing)
               {
                  playSound("ajq_chainstop");
               }
               if(_progressingSCnot == null)
               {
                  _progressingSCnot = playLoopingSound("ajq_chain2lp");
                  if(_progressingSC)
                  {
                     _progressingSC.stop();
                     _progressingSC = null;
                  }
               }
               _volumeInteractionProgressing = false;
            }
            if(_loc4_ == 100 && Boolean(_progressingSC))
            {
               _progressingSC.stop();
               _progressingSC = null;
               playSound("ajq_phoenixstinger");
            }
            if(_loc4_ == 0 && Boolean(_progressingSCnot))
            {
               _progressingSCnot.stop();
               _progressingSCnot = null;
            }
            _loc5_.progress = _loc4_;
            _loc6_ = RoomManagerWorld.instance.findLayers(_loc3_);
            if(_loc6_ != null)
            {
               for each(_loc7_ in _loc6_)
               {
                  if(_loc7_.s != null && _loc7_.s.content != null)
                  {
                     if(_loc7_.s.content.hasOwnProperty("setProgress"))
                     {
                        _loc7_.s.content.setProgress(_loc5_.progress);
                     }
                  }
               }
            }
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
         if(_questPlayersDict[_loc3_] != null)
         {
            _questPlayersDict[_loc3_].playerLeftRoom();
         }
      }
      
      public static function handlePlayerLeftQuest(param1:Object) : void
      {
         var _loc6_:AvatarInfo = null;
         var _loc7_:Object = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:Boolean = false;
         var _loc11_:Object = null;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:String = param1[_loc2_++];
         var _loc5_:AvatarWorldView = AvatarManager.avatarViewList[_loc3_];
         if(_loc5_)
         {
            _loc6_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc5_.userName);
            _loc6_.questTorchStatus = false;
         }
         AvatarManager.removeAvatar(_loc3_,true);
         if(AvatarManager.playerSfsUserId != _loc3_)
         {
            _loc8_ = 0;
            while(_loc8_ < _playerLeftObjects.length)
            {
               _loc7_ = _playerLeftObjects[_loc8_];
               if(!_loc7_.hasLeft)
               {
                  _loc7_.icon.txtMc.txt.autoSize = TextFieldAutoSize.CENTER;
                  LocalizationManager.translateIdAndInsert(_loc7_.icon.txtMc.txt,11393,_loc4_);
                  _loc7_.icon.x = MainFrame.VIEW_WIDTH * 0.5;
                  if(_loc8_ != 0 && !_playerLeftObjects[_loc8_ - 1].complete)
                  {
                     _playerLeftObjects[_loc8_ - 1].icon.y -= _loc7_.icon.height * _loc8_;
                  }
                  _loc7_.icon.y = MainFrame.VIEW_HEIGHT * 0.5;
                  GuiManager.guiLayer.addChild(_loc7_.icon);
                  _loc7_.icon.startLeaveText(onLeaveTextComplete,_loc8_);
                  _loc7_.hasLeft = true;
                  break;
               }
               _loc8_++;
            }
         }
         if(GuiManager.mainHud.playersCont != null)
         {
            if(GuiManager.mainHud.playersCont.visible)
            {
               onQuestPlayersBtn(null);
            }
            else
            {
               _loc9_ = AvatarManager.adventurePlayerData;
               for each(_loc11_ in _loc9_)
               {
                  if(_loc11_.userName != gMainFrame.userInfo.myUserName)
                  {
                     _loc10_ = true;
                  }
               }
               if(!_loc10_)
               {
                  if(GuiManager.mainHud.questPlayersBtn != null)
                  {
                     GuiManager.mainHud.questPlayersBtn.activateGrayState(true);
                  }
               }
            }
         }
      }
      
      private static function onLeaveTextComplete(param1:Object) : void
      {
         _playerLeftObjects[param1].complete = true;
      }
      
      public static function handleGiveSeed(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:Object = _questSeeds[param1];
         if(_loc4_ == null)
         {
            _loc4_ = new Object();
         }
         if(_loc4_.count == param3 - 1 && param2 > _loc4_.count)
         {
            playSound("ajq_boomSeedPluck");
         }
         _loc4_.count = param2;
         _loc4_.max = param3;
         _questSeeds[param1] = _loc4_;
         _seedInventory.rebuildInventory(_questSeeds);
      }
      
      public static function handlePlantEatRecoil(param1:String) : void
      {
         var _loc2_:QuestActor = _questActors[param1];
         if(_loc2_ != null)
         {
            _loc2_.recoil();
         }
      }
      
      public static function handlePlaySwf(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(param1,onPlaySwfLoaded,true);
         startFadeOut();
      }
      
      public static function handleFade(param1:Boolean) : void
      {
         if(param1)
         {
            _queueFadeIn = true;
         }
         else
         {
            startFadeOut();
         }
      }
      
      public static function handlPreloadSwf(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(param1);
      }
      
      public static function handleAward(param1:int, param2:int) : void
      {
         var _loc3_:MediaHelper = null;
         if(param1 == 78)
         {
            _loc3_ = new MediaHelper();
            _loc3_.init(56,onColorMeRad);
         }
         else
         {
            AchievementXtCommManager.requestSetUserVar(param1,param2);
         }
      }
      
      private static function onColorMeRad(param1:MovieClip) : void
      {
         GuiManager.guiLayer.addChild(param1);
         AJAudio.playAchievementSound();
         setTimeout(onRemoveColorMeRad,2000,param1);
      }
      
      private static function onRemoveColorMeRad(param1:MovieClip) : void
      {
         GuiManager.guiLayer.removeChild(param1);
      }
      
      public static function handlePostUri(param1:String) : void
      {
         SBTracker.trackPageview(param1);
      }
      
      public static function handleShake(param1:Number) : void
      {
         _shaketimer = param1 / 1000;
      }
      
      private static function onPlaySwfLoaded(param1:MovieClip) : void
      {
         _playSwfMC = param1;
      }
      
      private static function playSwf() : void
      {
         var _loc1_:Class = null;
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         UserCommXtCommManager.sendPermEmote(542,false);
         _playSwfMC.x = 0;
         _playSwfMC.y = 0;
         gMainFrame.stage.addChildAt(_playSwfMC,gMainFrame.stage.numChildren - 1);
         _playSwfMC.gotoAndStop(1);
         _playSwfMCTimeElapsed = 0;
         if(_playSwfMC.hasOwnProperty("soundToPlay"))
         {
            playSound(_playSwfMC.soundToPlay);
         }
         if(_playSwfMC.hasOwnProperty("playSoundOnLoad"))
         {
            _loc2_ = _playSwfMC.playSoundOnLoad;
            if(Boolean(_loc2_) && _loc2_ != "")
            {
               _loc3_ = 0.49;
               if(_playSwfMC.hasOwnProperty("playSoundOnLoadVolume"))
               {
                  _loc3_ = Number(_playSwfMC.playSoundOnLoadVolume);
               }
               _loc1_ = _playSwfMC.loaderInfo.applicationDomain.getDefinition(_loc2_) as Class;
               _soundMan.addSound(_loc1_,_loc3_,_loc2_);
               _playSwfMCSC = _soundMan.play(_loc1_);
            }
         }
      }
      
      private static function startFadeOut() : void
      {
         _fader = new Shape();
         _fader.graphics.beginFill(0);
         _fader.graphics.drawRect(0,0,900,550);
         _fader.graphics.endFill();
         gMainFrame.stage.addChild(_fader);
         _faderState = 0;
         _fader.alpha = 0;
         if(Boolean(_guiElementsSkipBtn) && Boolean(_guiElementsSkipBtn.parent))
         {
            gMainFrame.stage.addChild(_guiElementsSkipBtn);
         }
      }
      
      private static function startFadeIn() : void
      {
         _fader = new Shape();
         _fader.graphics.beginFill(0);
         _fader.graphics.drawRect(0,0,900,550);
         _fader.graphics.endFill();
         gMainFrame.stage.addChild(_fader);
         _faderState = 4;
         _fader.alpha = 1;
      }
      
      private static function endFade() : void
      {
      }
      
      public static function handleActorIcon(param1:String, param2:String) : void
      {
         var _loc4_:QuestActor = null;
         var _loc3_:Object = _questActorDictionary[param1];
         if(_loc3_ != null)
         {
            _loc3_.iconShowing = param2 == "1";
            _loc4_ = _questActors[param1];
            if(_loc4_ != null)
            {
               _loc4_.updateIcon(_loc3_.iconShowing);
            }
         }
      }
      
      public static function handleQuestTorch(param1:Object) : void
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:Object = null;
         var _loc9_:QuestActor = null;
         var _loc10_:int = 0;
         var _loc11_:AvatarWorldView = null;
         var _loc12_:AvatarInfo = null;
         var _loc2_:* = 2;
         var _loc3_:Boolean = param1[_loc2_++] == 0;
         var _loc4_:Boolean = param1[_loc2_++] == 1;
         if(_loc3_)
         {
            _loc5_ = param1[_loc2_++];
            _loc6_ = _questActorDictionary[_loc5_];
            if(_loc6_ != null)
            {
               _loc6_.torchEnabled = _loc4_;
               if(_loc6_.type == QuestActor.QUEST_ACTOR_TYPE_TILE)
               {
                  _loc7_ = RoomManagerWorld.instance.findLayers(_loc5_);
                  if(_loc7_ != null)
                  {
                     for each(_loc8_ in _loc7_)
                     {
                        if(_loc4_)
                        {
                           addTorch(_loc8_);
                        }
                        else
                        {
                           removeTorch(_loc8_);
                        }
                     }
                  }
               }
               else
               {
                  _loc9_ = _questActors[_loc5_];
                  if(_loc9_ != null)
                  {
                     _loc9_.updateTorch();
                  }
               }
            }
         }
         else
         {
            _loc10_ = int(param1[_loc2_++]);
            _loc11_ = AvatarManager.avatarViewList[_loc10_];
            if(_loc11_)
            {
               _loc12_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc11_.userName);
               _loc12_.questTorchStatus = _loc4_;
               if(_loc4_)
               {
                  addTorch(_loc11_,QUEST_TORCH_LITSIZE,-15,-50);
               }
               else
               {
                  removeTorch(_loc11_);
               }
            }
         }
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
      
      public static function handleBeamZap(param1:Object) : void
      {
         var _loc2_:* = 2;
         var _loc3_:String = param1[_loc2_++];
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:QuestActor = _questActors[_loc3_];
         if(_loc5_ != null)
         {
            _loc5_.handleBeamZap(_loc4_);
         }
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
      
      public static function handlePlantAte(param1:String, param2:String) : void
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
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc2_:* = 2;
         var _loc3_:Boolean = param1[_loc2_++] == "1";
         if(_loc3_)
         {
            _loc4_ = param1[_loc2_++];
            _loc5_ = int(param1[_loc2_++]);
            _loc6_ = int(param1[_loc2_++]);
            _loc7_ = int(param1[_loc2_++]);
            _loc8_ = new Object();
            _loc8_.visible = true;
            _loc8_.requireClick = false;
            _loc8_.type = QuestActor.QUEST_ACTOR_TYPE_PLANT;
            _loc8_.defId = _loc5_;
            _loc8_.state = 0;
            _loc8_.actorName = _loc4_;
            initInitialActorStatus(_loc8_,null);
            _loc8_.actorPos = new Point(_loc6_,_loc7_);
            _questActorDictionary[_loc4_] = _loc8_;
            initQuestActor(_loc8_.actorName,0,100,_loc8_,null,null);
         }
         if(_seedInventory)
         {
            _seedInventory.removeLastDraggedSeed();
         }
      }
      
      public static function handleQuestPlayerDead(param1:Object) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
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
               _loc6_ = uint(_loc4_.avatarPos.x).toString(16);
               _loc7_ = uint(_loc4_.avatarPos.y).toString(16);
               while(_loc6_.length < 8)
               {
                  _loc6_ = "0" + _loc6_;
               }
               while(_loc7_.length < 8)
               {
                  _loc7_ = "0" + _loc7_;
               }
               _loc8_ = gMainFrame.server.getCurrentRoomName().split(".")[1];
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#death/" + _loc8_ + "#null#x" + _loc6_ + _loc7_);
               RoomManagerWorld.instance.forceStopMovement();
               _defeatedPopUpTimer = 2;
               playSound("ajq_playerdeath");
               if(_seedInventory)
               {
                  _seedInventory.removeLastDraggedSeed();
               }
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
         var _loc11_:Object = null;
         var _loc12_:QuestActor = null;
         var _loc5_:* = 2;
         _loc3_ = param1[_loc5_++];
         var _loc6_:Object = _questActorDictionary[_loc3_];
         _loc2_ = _questActors[_loc3_];
         _loc4_ = int(param1[_loc5_++]);
         var _loc7_:Boolean = param1[_loc5_++] == "1";
         var _loc8_:int = int(param1[_loc5_++]);
         var _loc9_:int = int(param1[_loc5_++]);
         var _loc10_:String = param1[_loc5_++];
         if(_loc10_ != "")
         {
            _loc11_ = _questActorDictionary[_loc10_];
            if(_loc11_ != null)
            {
               _loc11_.actorPos = new Point(_loc8_,_loc9_);
            }
            _loc12_ = _questActors[_loc10_];
            if(_loc12_ != null)
            {
               _loc12_.x = _loc8_;
               _loc12_.y = _loc9_;
               _loc12_.handlePositionUpdate(_loc8_,_loc9_,0,QuestActor.SEEKTYPE_OFF,0,0);
            }
         }
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
               _loc2_.handlePositionUpdate(_loc8_,_loc9_,0,QuestActor.SEEKTYPE_OFF,0,0);
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
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(LocalizationManager.ADVENTURE_CONFIRMEXIT),true,onLeaveQuestConfirm);
      }
      
      private static function onDropItemConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            QuestXtCommManager.sendQuestDropItem(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y,param1.passback);
         }
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
      
      public static function closeAdventurePopups() : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
            QuestXtCommManager.sendQuestJoinCancel();
         }
         if(_talkingPopup != null)
         {
            onTalkingPopupClose(null);
         }
         if(_rewardsGiftPopup != null)
         {
            _rewardsGiftPopup.destroy();
            _rewardsGiftPopup = null;
         }
      }
      
      private static function onPopupOK(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
      }
      
      public static function set npcDefs(param1:Object) : void
      {
         _npcDefs = param1;
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
         if(param1)
         {
            QuestXtCommManager.sendQuestMovedItemsRequest();
            loadQuestSfx(1970);
         }
      }
      
      public static function playerLaunchWeapon(param1:Point, param2:Boolean) : Number
      {
         var _loc5_:Object = null;
         var _loc3_:Number = 0;
         var _loc4_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
         if(_playerWeaponTimerProjectile <= 0 && _loc4_ != null && _loc4_.questHealthPercentage > 0)
         {
            _loc5_ = getPlayerActiveWeapon(param2);
            _playerWeaponTimerProjectile = 0.5;
            if(param2)
            {
               _loc3_ = launchProjectile(_loc5_.itemDefId,_loc5_.color,param1.x,param1.y,null,AvatarManager.playerAvatarWorldView);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["dm","attack with weapon, ranged"]);
               }
            }
            else
            {
               _loc3_ = swipeMelee(_loc5_.itemDefId,_loc5_.color,param1.x,param1.y,null,AvatarManager.playerAvatarWorldView);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["dm","attack with weapon, melee"]);
               }
            }
         }
         return _loc3_;
      }
      
      public static function launchProjectile(param1:int, param2:uint, param3:Number, param4:Number, param5:QuestActor, param6:AvatarView) : Number
      {
         var _loc8_:QuestProjectile = null;
         var _loc9_:Boolean = false;
         var _loc7_:Number = 0;
         if(param1 != 0)
         {
            _loc8_ = null;
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
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["dm","quest minigame complete, actor:" + _questCommandActor + " actorState:" + _questCommandActorState + " gameResult:" + param1]);
            }
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
      
      public static function onQuestPlayersBtn(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         if(param1 == null || !param1.currentTarget.isGray)
         {
            _loc2_ = GuiManager.mainHud.playersCont;
            if(param1 != null && _loc2_.visible)
            {
               _loc2_.visible = false;
               return;
            }
            _loc2_.visible = true;
            if(GuiManager.mainHud.miniMap.visible)
            {
               GuiManager.mainHud.miniMap.visible = false;
               GuiManager.mainHud.miniMap_btnQuest.downToUpState();
            }
            if(_playersWindow)
            {
               _playersWindow.destroy();
               _playersWindow = null;
            }
            _loc3_ = AvatarManager.adventurePlayerData;
            _loc4_ = [];
            for each(_loc5_ in _loc3_)
            {
               if(_loc5_.userName != gMainFrame.userInfo.myUserName)
               {
                  _loc4_.push({
                     "isMember":_loc5_.isMember,
                     "nameBarData":_loc5_.nameBarData,
                     "userName":_loc5_.userName,
                     "avName":_loc5_.avName,
                     "isBuddy":BuddyManager.isBuddy(_loc5_.userName),
                     "isBlocked":BuddyManager.isBlocked(_loc5_.userName)
                  });
               }
            }
            if(_loc4_.length > 0)
            {
               while(_loc2_.itemWindow.numChildren > 0)
               {
                  _loc2_.itemWindow.removeChildAt(0);
               }
               _playersWindow = new WindowGenerator();
               _playersWindow.init(1,_loc4_.length,_loc4_.length,0,0,0,ItemWindowNameBar,null,"",{
                  "mouseDown":onSelectPlayer,
                  "mouseOver":null,
                  "mouseOut":null
               },_loc4_,onReportWindowsLoaded);
               _loc2_.itemWindow.addChild(_playersWindow);
            }
            else
            {
               _loc2_.visible = false;
               GuiManager.mainHud.questPlayersBtn.activateGrayState(true);
            }
         }
      }
      
      private static function onReportWindowsLoaded() : void
      {
         var containerWindow:MovieClip;
         var i:int = 0;
         while(i < _playersWindow.bg.numChildren)
         {
            ItemWindowNameBar(_playersWindow.bg.getChildAt(i)).updateToBeCentered(_playersWindow.width);
            i++;
         }
         containerWindow = GuiManager.mainHud.playersCont;
         with(containerWindow)
         {
            m.height = Math.round(_playersWindow.height);
            m.width = t.width = b.width = Math.max(containerWindow.title.width,_playersWindow.width + 2);
            m.y = b.y - m.height;
            t.y = m.y - t.height;
            x = Math.min(GuiManager.mainHud.questPlayersBtn.x - width * 0.5,MainFrame.VIEW_WIDTH - width - 2);
            _playersWindow.y = t.y + t.height * 0.5 - 5;
            _playersWindow.x = m.x - 4 + (m.width - _playersWindow.width) * 0.5;
            title.y = t.y + 5;
            title.x = m.width * 0.5 - title.width * 0.5;
         }
      }
      
      public static function validatePlantSeedLocation(param1:Point) : Boolean
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
      
      private static function onSelectPlayer(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Object = {
            "userName":param1.currentTarget.userName,
            "onlineStatus":SFClient.STATUS_ONLINE
         };
         BuddyCard.showBuddyCard(_loc2_);
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
      
      public static function openAdventureSelectPopup() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _mediaLoader = new MediaHelper();
         _mediaLoader.init(2603,onAdventureSelectLoaded);
      }
      
      private static function onAdventureSelectLoaded(param1:MovieClip = null) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _adventureSelectPopup = MovieClip(param1.getChildAt(0));
         }
         if(_adventureSelectPopup)
         {
            if(_availableScriptDefs)
            {
               _adventureSelectPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onAdventureSelectClose,false,0,true);
               if(_adventureSelectScrollBar)
               {
                  _adventureSelectScrollBar.destroy();
                  _adventureSelectScrollBar = null;
               }
               if(_adventureSelectItemWindow)
               {
                  _adventureSelectItemWindow.destroy();
                  _adventureSelectItemWindow = null;
               }
               _loc2_ = Math.min(_availableScriptDefs.length,20);
               _adventureSelectItemWindow = new WindowGenerator();
               _adventureSelectItemWindow.init(1,_loc2_,_loc2_,0,3,0,ItemWindowAdventure,null,"",{"mouseDown":adventureMouseDown},{"scriptIds":_availableScriptDefs},onAdventureWindowsLoaded,false,false);
            }
            else
            {
               getAvailableScriptDefs(onAdventureSelectLoaded);
            }
         }
      }
      
      private static function onAdventureWindowsLoaded() : void
      {
         while(_adventureSelectPopup.itemWindow.numChildren > 2)
         {
            _adventureSelectPopup.itemWindow.removeChildAt(_adventureSelectPopup.itemWindow.numChildren - 1);
         }
         _adventureSelectPopup.itemWindow.addChild(_adventureSelectItemWindow);
         _adventureSelectScrollBar = new SBScrollbar();
         _adventureSelectScrollBar.init(_adventureSelectItemWindow,267,337,3,"scrollbar2",54);
         _adventureSelectPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         _adventureSelectPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         GuiManager.guiLayer.addChild(_adventureSelectPopup);
         DarkenManager.darken(_adventureSelectPopup);
      }
      
      private static function adventureMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Object = param1.currentTarget.performContinueChecks();
         if(_loc2_ != null)
         {
            onAdventureSelectClose(param1);
            _loc2_.func(_loc2_.defId);
            _loc2_ = null;
         }
      }
      
      private static function onAdventureSelectClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _adventureSelectScrollBar.destroy();
         _adventureSelectScrollBar = null;
         _adventureSelectItemWindow.destroy();
         _adventureSelectItemWindow = null;
         DarkenManager.unDarken(_adventureSelectPopup);
         GuiManager.guiLayer.removeChild(_adventureSelectPopup);
         _adventureSelectPopup = null;
      }
      
      public static function privateAdventureJoinClose(param1:Boolean) : void
      {
         if(_privateAdventureJoin)
         {
            if(param1)
            {
               QuestXtCommManager.sendQuestJoinCancel();
            }
            UserCommXtCommManager.sendCustomAdventureMessage(false);
            _privateAdventureJoin.destroy();
            _privateAdventureJoin = null;
         }
         GuiManager.setSwapBtnGray(false);
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
      
      public static function showLeaveQuestLobbyPopup(... rest) : void
      {
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14815),true,onConfirmLeave,rest);
      }
      
      private static function onConfirmLeave(param1:Object) : void
      {
         var _loc2_:Function = null;
         if(param1.status)
         {
            privateAdventureJoinClose(true);
            _loc2_ = param1.passback[0];
            param1.passback.splice(0,1);
            _loc2_.apply(null,param1.passback);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private static function startShake() : void
      {
         var _loc1_:Object = null;
         if(_layerManager != null)
         {
            _loc1_ = _layerManager.bkg;
            _shakeOrigPos = new Point(_loc1_.x,_loc1_.y);
            _soundMan.play(_sounds["ajq_volcanoerupt"]);
         }
      }
      
      private static function stopShake() : void
      {
         var _loc1_:Object = null;
         if(_layerManager != null)
         {
            _loc1_ = _layerManager.bkg;
            _loc1_.x = _shakeOrigPos.x;
            _loc1_.y = _shakeOrigPos.y;
         }
         if(_screenShakeSC)
         {
            _soundMan.stop(_screenShakeSC);
            _screenShakeSC = null;
         }
         _shakeOrigPos = null;
      }
      
      private static function shake() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         if(_layerManager != null)
         {
            _loc1_ = _layerManager.bkg;
            _loc2_ = 16;
            _loc1_.x = _loc1_.x + Math.random() * _loc2_ - _loc2_ / 2;
            _loc1_.y = _loc1_.y + Math.random() * _loc2_ - _loc2_ / 2;
         }
      }
      
      public static function isPlayerInStealthVolume() : Boolean
      {
         return _playerInStealthVolume || _talkingPopup != null;
      }
      
      public static function currencyUpdate(param1:int) : void
      {
         if(_questActorDictionary != null)
         {
            _totalGemsEarned += param1;
         }
      }
      
      public static function onShopClick(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         _loc2_ = true;
         if(_questActorDictionary != null)
         {
            _loc3_ = "_" + param1;
            _loc4_ = _questActorDictionary[_loc3_];
            if(_loc4_.state != 1)
            {
               _loc2_ = false;
            }
         }
         return _loc2_;
      }
      
      public static function onShopClose() : void
      {
         if(_questActorDictionary != null && _questActorDictionary["gui_34"] != null)
         {
            QuestXtCommManager.questActorTriggered("gui_34");
         }
      }
      
      public static function avatarEditorInitComplete() : void
      {
         var _loc1_:int = 0;
         var _loc2_:AvatarEditor = null;
         var _loc3_:Object = null;
         if(_questActorDictionary != null && _questActorDictionary["gui_aved"] != null)
         {
            _loc2_ = GuiManager.avatarEditor;
            if(_loc2_ != null)
            {
               _loc1_ = 0;
               while(_loc1_ < _guiElementsAvatarEditor.length)
               {
                  if(_loc2_.avEditor[_guiElementsAvatarEditor[_loc1_ + 1]])
                  {
                     _loc3_ = _questActorDictionary[_guiElementsAvatarEditor[_loc1_]];
                     if(_loc3_.state >= 0 && _loc3_.state <= 2)
                     {
                        if(_loc2_.avEditor[_guiElementsAvatarEditor[_loc1_ + 1]].hasOwnProperty("setButtonState"))
                        {
                           _loc2_.avEditor[_guiElementsAvatarEditor[_loc1_ + 1]].setButtonState(_loc3_.state);
                        }
                        _loc2_.avEditor[_guiElementsAvatarEditor[_loc1_ + 1]].addEventListener(MouseEvent.MOUSE_DOWN,avEdDownHandler,false,0,true);
                     }
                  }
                  _loc1_ += 2;
               }
            }
            QuestXtCommManager.questActorTriggered("gui_aved");
         }
      }
      
      public static function phantomAttackDestructible(param1:String, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:QuestActor = null;
         var _loc7_:Point = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         _loc5_ = getTimer();
         for each(_loc6_ in _questActors)
         {
            if(_loc6_._visible && !_loc6_.isDead && _loc6_._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE)
            {
               if(_loc6_._actorData.damageDelay + 2000 < _loc5_)
               {
                  _loc7_ = _loc6_.actorOffset;
                  _loc8_ = param2 - (_loc6_.x + _loc7_.x);
                  _loc9_ = param3 - (_loc6_.y + _loc7_.y);
                  _loc10_ = _loc8_ * _loc8_ + _loc9_ * _loc9_;
                  _loc11_ = (param4 + param4) * (param4 + param4);
                  if(_loc10_ < _loc11_)
                  {
                     QuestXtCommManager.questPhantomAttackDestructible(param1,_loc6_._actorId);
                     _loc6_._actorData.damageDelay = _loc5_;
                  }
               }
            }
         }
      }
      
      public static function playerJoinedQuestRoom(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:QuestPlayerData = null;
         if(_questActorDictionary != null)
         {
            if(_questPlayersSwitched != null)
            {
               if(_questPlayersSwitched[param1] != null)
               {
                  _loc2_ = int(_questPlayersSwitched[param1]);
                  _loc3_ = getQuestPlayerData(param1);
                  if(_loc3_ != null)
                  {
                     _loc3_.setAvatarSwitched(_loc2_);
                  }
               }
            }
         }
      }
   }
}

