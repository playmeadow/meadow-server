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
   import com.sbi.client.KeepAlive;
   import com.sbi.corelib.math.Collision;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBParchmentPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
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
      
      private static const ADVENTURE_GOAL_REWARDS_ID:int = 2754;
      
      public static const QUEST_ADVENTURE_TYPE_DEFAULT:int = 0;
      
      public static const QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:int = 1;
      
      public static const QUEST_ADVENTURE_TYPE_MEMBER_PRIZE_SUPPORT:int = 2;
      
      public static const QUEST_ADVENTURE_TYPE_GIFT_PICKUP_SUPPORT:int = 3;
      
      public static const QUEST_ADVENTURE_TYPE_LETTERS_MAILBOX_SUPPORT:int = 4;
      
      public static const QUEST_ADVENTURE_TYPE_LUCKY_ADVENTURE:int = 5;
      
      public static const QUEST_ADVENTURE_TYPE_EASTER_ADVENTURE:int = 6;
      
      public static const QUEST_ADVENTURE_TYPE_BITTERSWEET_ADVENTURE:int = 7;
      
      public static const QUEST_ADVENTURE_REWARDS_POPUP_TYPE_LUCKY:int = 3;
      
      public static const QUEST_ADVENTURE_REWARDS_POPUP_TYPE_EASTER:int = 4;
      
      public static const QUEST_ADVENTURE_REWARDS_POPUP_TYPE_EASTER_DELAY:int = 5;
      
      private static var _npcDefs:Object;
      
      public static var _questScriptTimeStamp:String;
      
      public static var _questActorDictionary:Dictionary;
      
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
      
      private static var _questCommandActorMiniGame:String;
      
      private static var _questCommandActorStateMiniGame:int;
      
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
      
      private static var _currentVOActor:String;
      
      private static var _globalPackLoaded:Boolean;
      
      private static var _soundPacksToLoad:Array;
      
      private static var _paused:Boolean;
      
      private static var _assetPool:Dictionary;
      
      private static var _playerLeftObjects:Array;
      
      private static var _playersWindow:WindowGenerator;
      
      private static var _playersWindowScrollBar:SBScrollbar;
      
      public static var _questScriptDefId:int;
      
      public static var _questStartingPlayerCount:int;
      
      private static var _questObjectiveText:String;
      
      private static var _defeatedPopUpTimer:Number;
      
      private static var _nearestRespawnPoint:Object;
      
      private static var _playerInStealthVolume:Boolean;
      
      private static var _playerCrystalCount:int;
      
      private static var _playerOrbCountTotal:int;
      
      private static var _gameIdleTimer:Number;
      
      private static var _kickPopup:SBOkPopup;
      
      private static var _adventureRewardsPopup:MovieClip;
      
      private static var _adventureRewardsPopupType:int;
      
      private static var _adventureRewardsPopupStatus:Array;
      
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
      
      private static var _adventureTimer:MovieClip;
      
      private static var _adventureGoals:Array;
      
      private static var _adventureSelectPopup:MovieClip;
      
      private static var _adventureSelectScrollBar:SBScrollbar;
      
      private static var _adventureSelectItemWindow:WindowGenerator;
      
      private static var _guiElementsSkipBtn:MovieClip;
      
      private static var _guiElementsSkipBtnMh:MediaHelper;
      
      private static var _guiTimerLocal:Number;
      
      private static var _handlePickGiftDelayData:Object;
      
      private static var _handlePickGiftDelayTimer:Number;
      
      public static var _delayMinigameLaunches:Boolean;
      
      private static var _delayMinigameID:int;
      
      private static var _addTorchQueue:Array = [];
      
      private static const torch:Class = torch_swf$7a21d65659ff67828e0cd97fb9cdcc2f790503733;
      
      private static var _actorLightQueue:Array = [];
      
      private static var _fallingPhantoms:Array = [];
      
      private static var _guiElementsAvatarEditor:Array = ["gui_21","tradeBtnDown","gui_22","nonmember","gui_23","colorsTabDnBtn","gui_24","eyesTabDnBtn","gui_25","patternTabDnBtn","gui_26","bx","gui_27","sortBtn","gui_28","recycleClothesBtn","gui_29","shopBtn","gui_30","petsBtn","gui_31","colorsTabUp","gui_32","eyesTabUp","gui_33","patternTabUp","gui_38","colorTableColor1","gui_39","colorTableColor2","gui_40","colorTablePatterns","gui_41","colorTableEyes","gui_42","arrowBtnL","gui_43","arrowBtnR","gui_44","fiveMinCursor","gui_45","trophy","gui_46","money"];
      
      private static var _guiElementsGuiManager:Array = ["gui_1","eCardBtn","gui_2","buddyListBtn","gui_3","newsBtn","gui_4","awardsBtn","gui_5","book","gui_6","partyBtn","gui_7","money","gui_8","mySettingsBtn","gui_9","reportBtn","gui_10","charWindow","gui_11","swapBtn","gui_12","actionsBtn","gui_13","emotesBtn","gui_14","safeChatBtn","gui_15","chatHistUpDownBtn","gui_16","sendChatBtn","gui_17","denBtn","gui_18","soundBtn","gui_19","worldMapBtn","gui_35","zoneName","gui_36","ansChatBtn","gui_37","chatRepeatBtn","gui_47","playerWall","gui_48","games"];
      
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
      
      public static function updateCombinedCurrency() : void
      {
         if(_seedInventory)
         {
            _seedInventory.updateCombinedCurrency();
         }
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
            case 200:
               param1.pickedUp = false;
            case 13:
               param1.status = 0;
               break;
            case 12:
            case 11:
            case 23:
            case 21:
               param1.damageDelay = 0;
               param1.healthPercent = 100;
               param1.respawned = false;
               param1.plantRespawns = false;
         }
      }
      
      public static function loadQuestSfx(param1:int, param2:Function = null) : void
      {
         if(param1 == 3752 || param1 == 3753)
         {
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_FRE)
            {
               if(param1 == 3752)
               {
                  param1 = 2698;
               }
               if(param1 == 3753)
               {
                  param1 = 2699;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
            {
               if(param1 == 3752)
               {
                  param1 = 2730;
               }
               if(param1 == 3753)
               {
                  param1 = 2731;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_DE)
            {
               if(param1 == 3752)
               {
                  param1 = 2755;
               }
               if(param1 == 3753)
               {
                  param1 = 2756;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
            {
               if(param1 == 3752)
               {
                  param1 = 2910;
               }
               if(param1 == 3753)
               {
                  param1 = 2911;
               }
            }
         }
         var _loc3_:MediaHelper = new MediaHelper();
         _loc3_.init(param1,param2 != null ? param2 : onSfxLoaded,true);
      }
      
      private static function onGlobalSfxLoaded(param1:MovieClip) : void
      {
         _globalPackLoaded = true;
         onSfxLoaded(param1);
         if(_soundPacksToLoad)
         {
            while(_soundPacksToLoad.length)
            {
               onSfxLoaded(_soundPacksToLoad.pop());
            }
         }
      }
      
      private static function onSfxLoaded(param1:MovieClip) : void
      {
         var _loc3_:Class = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc2_:String = null;
         var _loc4_:String = null;
         if(_globalPackLoaded)
         {
            _loc5_ = getDefinitionNames(param1.loaderInfo,false,true);
            if(param1.hasOwnProperty("initVolumes"))
            {
               param1.initVolumes();
               _soundMan.setVolumes(param1.volumes);
            }
            _loc6_ = 0;
            while(_loc6_ < _loc5_.length - 1)
            {
               _loc2_ = _loc5_[_loc6_];
               _loc4_ = _loc2_.toLowerCase();
               if(_loc2_ && _loc2_ != "")
               {
                  _loc3_ = param1.loaderInfo.applicationDomain.getDefinition(_loc2_) as Class;
                  _soundMan.addSound(_loc3_,-1,_loc2_);
                  if(_sounds[_loc4_] == null)
                  {
                     _sounds[_loc4_] = _loc3_;
                  }
               }
               _loc6_++;
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            delete param1.passback;
         }
         else
         {
            if(_soundPacksToLoad == null)
            {
               _soundPacksToLoad = [];
            }
            _soundPacksToLoad.push(param1);
         }
      }
      
      public static function playMusic(param1:String, param2:DisplayObject = null) : void
      {
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         var _loc4_:int = 0;
         if(_currentMusic)
         {
            if(_currentMusic != param1)
            {
               if(_currentMusic != "0")
               {
                  if(_SFX_Music[_currentMusic])
                  {
                     _soundMan.fadeOut(_SFX_Music[_currentMusic]);
                     if(param1 != "0")
                     {
                        _playMusicOnLoad = true;
                     }
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
                     _loc5_ = _streamsLUT[param1];
                     _SFX_Music[param1] = _soundMan.addStream(_loc5_.name,_loc5_.vol);
                  }
                  _loc4_ = 0;
                  _soundMan.playStream(_SFX_Music[param1],_loc4_,_loc3_,true);
               }
            }
         }
         else if(_sceneLoaded)
         {
            if(_SFX_Music[param1] == null)
            {
               _loc5_ = _streamsLUT[param1];
               _SFX_Music[param1] = _soundMan.addStream(_loc5_.name,_loc5_.vol);
            }
            _soundMan.playStream(_SFX_Music[param1],0,99999);
         }
         else
         {
            _playMusicOnLoad = true;
         }
         _currentMusic = param1;
      }
      
      public static function playSound(param1:String, param2:DisplayObject = null, param3:Boolean = false, param4:String = null) : void
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:String = param1.toLowerCase();
         if(param2 == null && _streamsLUT[_loc7_])
         {
            if(_SFX_Music[_loc7_] == null)
            {
               _loc5_ = _streamsLUT[_loc7_];
               _SFX_Music[_loc7_] = _soundMan.addStream(_loc5_.name,_loc5_.vol);
            }
            _soundMan.playStream(_SFX_Music[_loc7_]);
         }
         else if(param2 == null || isOnscreen(param2))
         {
            _loc6_ = int(_sfxTimer[_loc7_] == null ? -1 : _sfxTimer[_loc7_]);
            if(_loc6_ < 0 || getTimer() - _loc6_ > 500)
            {
               if(param3)
               {
                  if(_currentVOSC)
                  {
                     _currentVOSC.removeEventListener("soundComplete",voiceOverComplete);
                     _currentVOSC.stop();
                  }
                  _currentVOActor = param4;
                  _currentVOSC = _soundMan.play(_sounds[_loc7_]);
                  _currentVOSC.addEventListener("soundComplete",voiceOverComplete);
               }
               else
               {
                  _soundMan.play(_sounds[_loc7_]);
               }
               _sfxTimer[_loc7_] = _lastTime;
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
            GenericListXtCommManager.requestGenericList(201,onAvailableScriptsLoaded,param1);
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
         var _loc3_:Number = param1.x;
         var _loc2_:Object = param1;
         while(_loc2_.parent)
         {
            _loc2_ = _loc2_.parent;
            _loc3_ += _loc2_.x;
         }
         return _loc3_;
      }
      
      private static function isOnscreen(param1:DisplayObject) : Boolean
      {
         if(param1.parent == GuiManager.guiLayer)
         {
            return true;
         }
         var _loc6_:Number = param1.x;
         var _loc5_:Number = param1.y;
         var _loc4_:Object = param1;
         while(_loc4_.parent != null && _loc4_.parent != _layerManager.bkg)
         {
            _loc4_ = _loc4_.parent;
            _loc6_ += _loc4_.x;
            _loc5_ += _loc4_.y;
         }
         _loc4_ = AvatarManager.playerAvatarWorldView;
         if(_loc4_ == null)
         {
            return false;
         }
         var _loc3_:Number = Number(_loc4_.x);
         var _loc2_:Number = Number(_loc4_.y);
         while(_loc4_.parent != null && _loc4_.parent != _layerManager.bkg)
         {
            _loc4_ = _loc4_.parent;
            _loc3_ += _loc4_.x;
            _loc2_ += _loc4_.y;
         }
         _loc6_ -= _loc3_;
         _loc5_ -= _loc2_;
         return _loc6_ * _loc6_ + _loc5_ * _loc5_ < 810000;
      }
      
      public static function setSoundLevel(param1:SoundChannel, param2:Number, param3:DisplayObject) : void
      {
         var _loc5_:SoundTransform = null;
         var _loc4_:Number = NaN;
         if(param1 != null)
         {
            if(_maxVolumes[param1] == null)
            {
               _maxVolumes[param1] = param1.soundTransform.volume;
            }
            _loc5_ = param1.soundTransform;
            _loc5_.volume = _maxVolumes[param1] * param2;
            _loc4_ = getStageX(param3);
            _loc5_.pan = Math.min(Math.max(_loc4_ / 450 - 1,-1),1);
            param1.soundTransform = _loc5_;
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
         _questProjectiles = [];
         _questMelees = [];
         _playerWeaponTimerProjectile = 0;
         _playerWeaponTimerMelee = 0;
         _actorPriority = 0;
         _delayMinigameLaunches = false;
         _delayMinigameID = -1;
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
         _streamsLUT["ajq_musquest8"] = {
            "name":"ajq_musQuest8",
            "vol":0.47
         };
         _streamsLUT["ajq_musoceanquest9"] = {
            "name":"ajq_musOceanQuest9",
            "vol":0.55
         };
         _streamsLUT["ajq_musintodeep"] = {
            "name":"ajq_musInToDeep",
            "vol":0.9
         };
         _streamsLUT["ajq_musfactorybosslp"] = {
            "name":"ajq_musFactoryBossLp",
            "vol":0.45
         };
         _streamsLUT["ajq_muscharge"] = {
            "name":"ajq_musCharge",
            "vol":0.8
         };
         _streamsLUT["ajq_musturningthetide"] = {
            "name":"ajq_musTurningTheTide",
            "vol":0.45
         };
         _streamsLUT["ajq_mushauntedforest"] = {
            "name":"ajq_musHauntedForest",
            "vol":0.9
         };
         _streamsLUT["ajq_musgraveyard"] = {
            "name":"ajq_musGraveyard",
            "vol":0.9
         };
         _streamsLUT["ajq_musfroggymarsh"] = {
            "name":"ajq_musFroggyMarsh",
            "vol":0.96
         };
         _streamsLUT["ajq_musouterlimits"] = {
            "name":"ajq_musOuterLimits",
            "vol":1.06
         };
         _streamsLUT["ajq_muspumpkinpatch"] = {
            "name":"ajq_musPumpkinPatch",
            "vol":0.4
         };
         _streamsLUT["ajq_mussciencelab"] = {
            "name":"ajq_musScienceLab",
            "vol":0.5
         };
         _streamsLUT["muscornmaze"] = {
            "name":"MusCornMaze",
            "vol":0.17
         };
         _streamsLUT["ajq_muswinterfun"] = {
            "name":"ajq_musWinterFun",
            "vol":0.35
         };
         _streamsLUT["aj_musnpeintro"] = {
            "name":"aj_musNPEintro",
            "vol":0.4
         };
         _streamsLUT["ajq_musspecialfriends"] = {
            "name":"ajq_musSpecialFriends",
            "vol":0.65
         };
         _streamsLUT["daluckyadv"] = {
            "name":"DALuckyAdv",
            "vol":0.5
         };
         _streamsLUT["musspringfestival"] = {
            "name":"MusSpringFestival",
            "vol":0.6
         };
         _streamsLUT["ajq_mustugofwaridlelp"] = {
            "name":"ajq_musTugOfWarIdleLP",
            "vol":0.4
         };
         _streamsLUT["ajm_tugofwar"] = {
            "name":"ajm_tugOfWar",
            "vol":0.5
         };
         _streamsLUT["ajq_muscraftingvillage"] = {
            "name":"ajq_musCraftingVillage",
            "vol":0.4
         };
         _streamsLUT["ajq_musquest19cave"] = {
            "name":"ajq_musQuest19Cave",
            "vol":0.4
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
         gMainFrame.stage.addEventListener("keyUp",keyHandleUp);
         gMainFrame.stage.addEventListener("keyDown",keyHandleDown);
         gMainFrame.stage.addEventListener("QuestEventLoadSfx",onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener("QuestEventPlaySfx",onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener("QuestEventTorch",onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener("QuestEventTriggerCameraShake",onQuestEvent,false,0,true);
      }
      
      public static function destroy() : void
      {
         gMainFrame.stage.removeEventListener("keyUp",keyHandleUp);
         gMainFrame.stage.removeEventListener("keyDown",keyHandleDown);
         gMainFrame.stage.removeEventListener("QuestEventLoadSfx",onQuestEvent);
         gMainFrame.stage.removeEventListener("QuestEventPlaySfx",onQuestEvent);
         gMainFrame.stage.removeEventListener("QuestEventTorch",onQuestEvent);
         gMainFrame.stage.removeEventListener("QuestEventTriggerCameraShake",onQuestEvent);
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
               case "QuestEventLoadSfx":
                  _loc2_ = int(param1.secondaryType);
                  if(_loc2_ > 0)
                  {
                     loadQuestSfx(int(param1.secondaryType));
                  }
                  break;
               case "QuestEventPlaySfx":
                  playSound(param1.secondaryType,param1.target as DisplayObject);
                  break;
               case "QuestEventTorch":
                  if(param1.secondaryType == "on")
                  {
                     addTorch(param1.target);
                  }
                  else
                  {
                     removeTorch(param1.target);
                  }
                  break;
               case "QuestEventTriggerCameraShake":
                  _shaketimer = 0.5;
            }
         }
      }
      
      public static function actorCollisionTest(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc4_:* = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc3_:QuestActor = _questActors[param1];
         if(_loc3_)
         {
            _loc5_ = _loc3_.actorOffset;
            _loc5_.x = _loc5_.x + _loc3_.x;
            _loc5_.y += _loc3_.y;
            _loc6_ = new Point(AvatarManager.playerAvatarWorldView.x + -15,AvatarManager.playerAvatarWorldView.y + -40);
            if(Collision.circleHitCircle(_loc5_,_loc3_.collisionRadiusMoving,_loc6_,50))
            {
               return true;
            }
            if(param2)
            {
               return false;
            }
            for each(_loc4_ in _questActors)
            {
               if(!_loc4_.isDead && !_loc4_.isDying && _loc4_.priority > _loc3_.priority && _loc4_._actorData.type == 11)
               {
                  _loc6_ = _loc4_.actorOffset;
                  _loc6_.x = _loc6_.x + _loc4_.x;
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
         var _loc3_:Point = RoomManagerWorld.instance.convertScreenToWorldSpace(param1.stageX,param1.stageY);
         if(projectileKeyDown)
         {
            playerLaunchWeapon(_loc3_,true);
            if(AvatarManager.playerAvatarWorldView && AvatarManager.playerAvatarWorldView.moving)
            {
               RoomManagerWorld.instance.forceStopMovement();
            }
            AvatarManager.playerAvatarWorldView.faceAnim(_loc3_.x - AvatarManager.playerAvatarWorldView.avatarPos.x,_loc3_.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
            return true;
         }
         for each(var _loc2_:Object in _questActors)
         {
            if(_loc2_.handleMouseDown(_loc3_))
            {
               AvatarManager.playerAvatarWorldView.faceAnim(_loc3_.x - AvatarManager.playerAvatarWorldView.avatarPos.x,_loc3_.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
               return true;
            }
         }
         return false;
      }
      
      private static function voiceOverComplete(param1:Event) : void
      {
         if(_questActorDictionary != null)
         {
            if(_currentVOSC != null)
            {
               _currentVOSC.removeEventListener("soundComplete",voiceOverComplete);
            }
            if(_currentVOActor != null)
            {
               QuestXtCommManager.questActorTriggered(_currentVOActor);
               _currentVOActor = null;
            }
         }
      }
      
      private static function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 16)
         {
            case 0:
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
         switch(int(param1.keyCode) - 16)
         {
         }
      }
      
      public static function muteChanged(param1:Boolean) : void
      {
         for each(var _loc2_:Object in _questActors)
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
         var _loc8_:int = 0;
         var _loc2_:AvatarInfo = null;
         var _loc4_:int = 0;
         var _loc7_:AvatarEditor = null;
         var _loc1_:Object = null;
         var _loc3_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         if(_questExitPending)
         {
            _loc2_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(_loc2_)
            {
               _loc2_.questTorchStatus = false;
            }
            if(_playSwfMC != null)
            {
               if(_playSwfMC.parent != null)
               {
                  _playSwfMC.parent.removeChild(_playSwfMC);
               }
               _playSwfMC = null;
               UserCommXtCommManager.sendPermEmote(-1);
            }
            if(_guiElementsSkipBtnMh)
            {
               _guiElementsSkipBtnMh.destroy();
               _guiElementsSkipBtnMh = null;
            }
            if(_guiElementsSkipBtn)
            {
               _guiElementsSkipBtn.removeEventListener("mouseDown",guiElementsSkipBtnPress);
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
                  GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].removeEventListener("mouseDown",guiDownHandler);
                  GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].removeEventListener("mouseOver",guiDownHandler);
               }
               _loc4_ += 2;
            }
            GuiManager.grayHudAvatar(false);
            _loc7_ = GuiManager.avatarEditor;
            if(_loc7_ != null)
            {
               _loc4_ = 0;
               while(_loc4_ < _guiElementsAvatarEditor.length)
               {
                  _loc1_ = _loc7_.avEditor[_guiElementsAvatarEditor[_loc4_ + 1]];
                  if(_loc1_ == null)
                  {
                     _loc1_ = _loc7_[_guiElementsAvatarEditor[_loc4_ + 1]];
                  }
                  if(_loc1_)
                  {
                     if(_loc1_.hasOwnProperty("setButtonState"))
                     {
                        _loc1_.setButtonState(1);
                     }
                     _loc1_.removeEventListener("mouseDown",avEdDownHandler);
                  }
                  _loc4_ += 2;
               }
            }
            _questPlayersSwitched = null;
            _questScriptDefId = 0;
            AvatarManager.setPlayerAttachmentEmot(0,null,0,false);
            _questExitPending = false;
            gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId).questHealthPercentage = 100;
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = 1;
            _questActorDictionary = null;
            gMainFrame.stage.removeEventListener("mouseDown",resetMouseDownIdleTimer);
            gMainFrame.stage.removeEventListener("mouseMove",resetMouseMoveIdleTimer);
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
            for(_loc6_ in _assetPool)
            {
               delete _assetPool[_loc6_];
            }
            _loc8_ = 0;
            while(_loc8_ < _playerLeftObjects.length)
            {
               _loc3_ = _playerLeftObjects[_loc8_];
               if(_loc3_ && _loc3_.icon.parent && _loc3_.icon.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc3_.icon);
               }
               _loc3_.hasLeft = false;
               _loc3_.complete = false;
               _loc8_++;
            }
            RoomManagerWorld.instance.setGridDepth(128);
            if(_currentMusic && _SFX_Music[_currentMusic])
            {
               _SFX_Music[_currentMusic].stop();
            }
            if(_currentAmbient && _SFX_AmbientSC)
            {
               _SFX_AmbientSC.stop();
            }
            _currentMusic = _currentAmbient = null;
            _playMusicOnLoad = false;
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
         _delayMinigameLaunches = false;
         _delayMinigameID = -1;
         _soundMan.destroy();
         if(_adventureTimer && _adventureTimer.parent)
         {
            _adventureTimer.parent.removeChild(_adventureTimer);
            _adventureTimer = null;
         }
         if(_adventureGoals)
         {
            _loc5_ = 1;
            while(_loc5_ <= 5)
            {
               if(_adventureGoals[_loc5_] && _adventureGoals[_loc5_].parent)
               {
                  _adventureGoals[_loc5_].parent.removeChild(_adventureGoals[_loc5_]);
                  _adventureGoals[_loc5_] = null;
               }
               _loc5_++;
            }
            _adventureGoals = null;
         }
         if(_playSwfMCSC)
         {
            _playSwfMCSC.stop();
            _playSwfMCSC = null;
         }
         if(_currentVOSC)
         {
            _currentVOSC.removeEventListener("soundComplete",voiceOverComplete);
            _currentVOSC.stop();
            _currentVOSC = null;
            _currentVOActor = null;
         }
         if(_fader && _fader.parent)
         {
            _fader.parent.removeChild(_fader);
            _fader = null;
         }
         if(_darknessMask)
         {
            removeDarkness();
         }
         _loc8_ = 0;
         while(_loc8_ < _questProjectiles.length)
         {
            _questProjectiles[_loc8_].destroy();
            _loc8_++;
         }
         _questProjectiles.splice(0,_questProjectiles.length);
         _loc8_ = 0;
         while(_loc8_ < _questMelees.length)
         {
            _questMelees[_loc8_].destroy();
            _loc8_++;
         }
         _questMelees.splice(0,_questMelees.length);
         for(_loc6_ in _questActors)
         {
            _questActors[_loc6_].destroy();
            delete _questActors[_loc6_];
         }
         for(_loc6_ in _questPlayersDict)
         {
            _questPlayersDict[_loc6_].destroy();
            delete _questPlayersDict[_loc6_];
         }
         if(_fallingPhantoms.length > 0)
         {
            _loc8_ = 0;
            while(_loc8_ < _fallingPhantoms.length)
            {
               _loc6_ = _fallingPhantoms[_loc8_];
               if(_loc6_ != null)
               {
                  if(_loc6_.mh != null)
                  {
                     _loc6_.mh.destroy();
                     _loc6_.mh = null;
                  }
                  if(_loc6_.theSprite != null && _loc6_.theSprite.parent != null)
                  {
                     _loc6_.theSprite.parent.removeChild(_loc6_.theSprite);
                     _loc6_.theSprite = null;
                     _loc6_.npc = null;
                  }
               }
               _loc8_++;
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
         var _loc5_:Object = null;
         var _loc11_:Point = null;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc10_:Number = -1;
         var _loc6_:QuestActor = null;
         param3 *= param3;
         for each(var _loc7_:QuestActor in _questActors)
         {
            if(_loc7_._visible && _loc7_._actorData.type == 21 && _loc7_.plantTargettable())
            {
               _loc5_ = _loc7_.npcDef;
               if(_loc5_ != null && _loc5_.level <= param4)
               {
                  _loc11_ = _loc7_.actorOffset;
                  _loc9_ = param1 - (_loc7_._actorData.actorPos.x + _loc11_.x);
                  _loc8_ = param2 - (_loc7_._actorData.actorPos.y + _loc11_.y);
                  _loc12_ = _loc9_ * _loc9_ + _loc8_ * _loc8_;
                  if(_loc12_ < param3 && (_loc10_ == -1 || _loc12_ < _loc10_))
                  {
                     _loc6_ = _loc7_;
                     _loc10_ = _loc12_;
                  }
               }
            }
         }
         return _loc6_;
      }
      
      public static function getNearestActivePhantom(param1:Number, param2:Number, param3:Number, param4:int, param5:Boolean, param6:Boolean, param7:Boolean) : Array
      {
         var _loc14_:Array = null;
         var _loc13_:Number = NaN;
         var _loc8_:Object = null;
         var _loc12_:Point = null;
         var _loc11_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc15_:QuestActor = null;
         param3 *= param3;
         for each(var _loc9_:QuestActor in _questActors)
         {
            if(_loc9_._visible && !_loc9_.isDead)
            {
               if(_loc9_._actorData.type == 11 && (param5 || _loc9_._seekActive != 0) || param6 && (_loc9_._actorData.type == 23 || _loc9_._actorData.type == 12))
               {
                  _loc8_ = _loc9_.npcDef;
                  if(_loc9_._actorData.type == 23 || _loc9_._actorData.type == 12 || _loc8_ != null && _loc9_.isVulnerable() && (_loc8_.level <= param4 || param7))
                  {
                     _loc12_ = _loc9_.actorOffset;
                     _loc11_ = param1 - (_loc9_.x + _loc12_.x);
                     _loc10_ = param2 - (_loc9_.y + _loc12_.y);
                     _loc16_ = _loc11_ * _loc11_ + _loc10_ * _loc10_;
                     if(_loc16_ < param3)
                     {
                        if(_loc14_ == null)
                        {
                           _loc14_ = [];
                           _loc13_ = _loc16_;
                           _loc14_.push(_loc9_);
                        }
                        else if(_loc16_ < _loc13_)
                        {
                           _loc13_ = _loc16_;
                           _loc14_.unshift(_loc9_);
                        }
                        else
                        {
                           _loc14_.push(_loc9_);
                        }
                     }
                  }
               }
            }
         }
         return _loc14_;
      }
      
      public static function createDarkness() : void
      {
         if(_darknessMask)
         {
            throw new Error("Error creating darkness! Darkness is already created!");
         }
         _darknessMask = new Sprite();
         _darknessMask.blendMode = "layer";
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
            trace("removing darkness");
         }
      }
      
      public static function addTorch(param1:Object, param2:Number = 1, param3:int = 0, param4:int = 0) : MovieClip
      {
         var _loc7_:Object = null;
         var _loc5_:Boolean = false;
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
            _loc5_ = createDarknessFromScene();
            if(!_loc5_)
            {
               _actorLightQueue.push(param1);
               return null;
            }
            for each(_loc7_ in _actorLightQueue)
            {
               addTorch(_loc7_);
            }
            _actorLightQueue = [];
         }
         if(_torches)
         {
            for each(_loc7_ in _torches)
            {
               if(_loc7_.actor == param1)
               {
                  if(_loc7_.actor == AvatarManager.playerAvatarWorldView)
                  {
                     _loc7_.light.scaleX = _loc7_.light.scaleY = param2;
                  }
                  return null;
               }
            }
         }
         else
         {
            _torches = [];
         }
         _loc7_ = {};
         var _loc6_:Object = null;
         if(param1.hasOwnProperty("torch"))
         {
            _loc6_ = param1.torch;
            if(param1.parent == _layerManager.room_chat)
            {
               _loc7_.layer = 1;
               _loc6_.x = 650;
               _loc6_.y = 470;
            }
            else
            {
               param1 = param1.parent;
               _loc7_.layer = 1;
               _loc6_.x = 320;
               _loc6_.y = 180;
            }
         }
         else if(param1.hasOwnProperty("s") && param1.s.content.hasOwnProperty("torch"))
         {
            _loc6_ = param1.s.content.torch;
            _loc7_.layer = 0;
         }
         if(_loc6_)
         {
            _loc7_.light = _loc6_;
            _loc7_.light.visible = true;
            _loc7_.offsetX = _loc7_.light.x;
            _loc7_.offsetY = _loc7_.light.y;
         }
         else
         {
            _loc7_.light = new torch();
            _loc7_.light.scaleX = _loc7_.light.scaleY = param2;
            _loc7_.offsetX = param3;
            _loc7_.offsetY = param4;
            _loc7_.layer = 1;
         }
         _darknessMask.addChild(_loc7_.light);
         _loc7_.light.blendMode = "erase";
         _loc7_.actor = param1;
         _torchLUT[param1] = _loc7_;
         _torches.push(_loc7_);
         return _loc7_.light;
      }
      
      public static function createDarknessFromScene() : Boolean
      {
         var _loc2_:* = null;
         var _loc3_:Sprite = null;
         var _loc5_:int = 0;
         var _loc1_:DisplayObject = null;
         if(!_sceneLoaded)
         {
            trace("das not good");
         }
         var _loc4_:Array = RoomManagerWorld.instance.getDarknessFromScene();
         trace("adding darkness");
         if(_loc4_.length > 0)
         {
            trace("found darkness");
            _darknessMask = new Sprite();
            _darknessMask.blendMode = "layer";
            _darknessMask.mouseEnabled = false;
            _darknessMask.mouseChildren = false;
            for each(_loc2_ in _loc4_)
            {
               _darknessMask.addChild(_loc2_);
            }
            _darknessMask.x = _layerManager.room_avatars.x + _layerManager.room_bkg_group.x;
            _darknessMask.y = _layerManager.room_avatars.y + _layerManager.room_bkg_group.y;
            _loc3_ = _layerManager.room_fg;
            if(_loc3_.numChildren > 0)
            {
               _loc5_ = _loc3_.numChildren - 1;
               while(_loc5_ >= 0)
               {
                  _loc1_ = _loc3_.getChildAt(_loc5_);
                  if(!_loc1_.hasOwnProperty("eye") && !_loc1_.hasOwnProperty("watcher"))
                  {
                     break;
                  }
                  _loc5_--;
               }
               _loc3_.addChildAt(_darknessMask,_loc5_ >= 0 ? _loc5_ : 0);
            }
            else
            {
               _loc3_.addChild(_darknessMask);
            }
            _torchLUT = new Dictionary();
         }
         return _loc4_.length > 0;
      }
      
      public static function removeTorch(param1:Object) : void
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         if(_torches != null)
         {
            _loc2_ = 0;
            for each(_loc3_ in _torches)
            {
               if(_loc3_.actor == param1)
               {
                  if(param1 == AvatarManager.playerAvatarWorldView)
                  {
                     _loc3_.light.scaleX = _loc3_.light.scaleY = 0.7;
                  }
                  else
                  {
                     _loc3_.light.parent.removeChild(_loc3_.light);
                     _torches.splice(_loc2_,1);
                  }
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public static function heartbeat() : void
      {
         var _loc9_:int = 0;
         var _loc13_:AvatarWorldView = null;
         var _loc12_:int = 0;
         var _loc14_:int = 0;
         var _loc3_:int = 0;
         var _loc10_:Object = null;
         var _loc1_:int = 0;
         var _loc15_:int = 0;
         var _loc17_:int = 0;
         var _loc8_:String = null;
         var _loc16_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:* = null;
         var _loc11_:int = 0;
         if(!_paused)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_handlePickGiftDelayTimer > 0)
            {
               if(_handlePickGiftDelayData != null)
               {
                  _handlePickGiftDelayTimer -= _frameTime;
                  if(_handlePickGiftDelayTimer <= 0)
                  {
                     handlePickGift(_handlePickGiftDelayData,true);
                     _handlePickGiftDelayData = null;
                  }
               }
               else
               {
                  _handlePickGiftDelayTimer = 0;
               }
            }
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
                     _loc9_ = _playSwfMCTimeElapsed * 24;
                     if(_loc9_ >= _playSwfMC.totalFrames)
                     {
                        _loc9_ = _playSwfMC.totalFrames;
                     }
                     _playSwfMC.gotoAndStop(_loc9_);
                  }
               }
            }
            if(_fader && _fader.parent)
            {
               if(_faderState == 0 || _faderState == 3)
               {
                  _fader.alpha += _frameTime * 1;
                  if(_fader.alpha >= 1)
                  {
                     _fader.alpha = 1;
                     _faderState = _faderState + 1;
                     if(_faderState == 4)
                     {
                        QuestXtCommManager.sendPlaySwfComplete();
                        if(_playSwfMC.parent != null)
                        {
                           _playSwfMC.parent.removeChild(_playSwfMC);
                        }
                        _playSwfMC = null;
                        UserCommXtCommManager.sendPermEmote(-1);
                     }
                  }
               }
               else if(_playSwfMC || _faderState == 4)
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
            _loc13_ = AvatarManager.playerAvatarWorldView;
            if(_questActorDictionary != null)
            {
               if(AvatarManager.playerAvatarWorldView)
               {
                  RoomManagerWorld.instance.updatePlayerPos(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
               }
               _gameIdleTimer += _frameTime;
               if(_gameIdleTimer > 240)
               {
                  if((gMainFrame.userInfo.isModerator || gMainFrame.clientInfo.accountType == 4) && !gMainFrame.server.isBlueboxMode())
                  {
                     KeepAlive.sendKeepAliveReset();
                     _gameIdleTimer = 0;
                  }
                  else if(_gameIdleTimer > 300)
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
               for each(var _loc6_:QuestPlayerData in _questPlayersDict)
               {
                  if(_loc6_ != null)
                  {
                     _loc6_.heartbeat();
                  }
               }
               if(_guiTimerLocal > 0)
               {
                  _loc12_ = int(_guiTimerLocal) % 60;
                  _guiTimerLocal -= _frameTime;
                  _loc14_ = int(_guiTimerLocal) % 60;
                  if(_loc12_ > _loc14_)
                  {
                     _soundMan.play(_sounds["aj_play_timer_tick1"]);
                  }
                  if(_adventureTimer)
                  {
                     _adventureTimer.time = _guiTimerLocal;
                     _loc3_ = _adventureTimer.time / 60;
                     _loc14_ = int(_adventureTimer.time) % 60;
                     _adventureTimer.clock.clockText_1.text = _loc3_;
                     _adventureTimer.clock.clockText_2.text = (_loc14_ >= 10 ? "" : "0") + _loc14_;
                     if(_adventureTimer.time < 60 && _adventureTimer.time + _frameTime > 60)
                     {
                        _adventureTimer.startPulse();
                     }
                  }
                  if(_guiTimerLocal <= 0)
                  {
                     QuestXtCommManager.questActorTriggered("gui_time_min");
                     _adventureTimer.visible = false;
                     _guiTimerLocal = 0;
                  }
               }
               _loc10_ = _questActorDictionary["gui_timer"];
               if(_loc10_ != null)
               {
                  if(_adventureTimer)
                  {
                     _adventureTimer.time = _loc10_.state;
                     _loc1_ = _adventureTimer.time / 60;
                     _loc15_ = int(_adventureTimer.time) % 60;
                     _adventureTimer.clock.clockText_1.text = _loc1_;
                     _adventureTimer.clock.clockText_2.text = (_loc15_ >= 10 ? "" : "0") + _loc15_;
                     if(_adventureTimer.time < 60 && _adventureTimer.time + _frameTime > 60)
                     {
                        _adventureTimer.startPulse();
                     }
                  }
               }
               if(_adventureGoals != null)
               {
                  switch((_loc16_ = getAdventureType()) - 1)
                  {
                     case 0:
                     case 2:
                     case 3:
                     case 4:
                     case 5:
                     case 6:
                        if(_questActorDictionary["gui_goal1"])
                        {
                           if(_adventureGoals[1])
                           {
                              _loc5_ = getMaxQuestGoal(_loc16_);
                              _loc4_ = 0;
                              _loc17_ = 1;
                              while(_loc17_ <= _loc5_)
                              {
                                 _loc8_ = "gui_goal" + _loc17_ + "a";
                                 if(_loc17_ == _loc5_ || _questActorDictionary[_loc8_] != null && _questActorDictionary[_loc8_].state > _playerOrbCountTotal)
                                 {
                                    switch(_loc16_ - 5)
                                    {
                                       case 0:
                                          _loc4_ = _questActorDictionary[_loc8_].state + 1;
                                          break;
                                       default:
                                          _loc4_ = int(_questActorDictionary[_loc8_].state);
                                    }
                                    _adventureGoals[1].setMaxValue(_loc4_);
                                    break;
                                 }
                                 _loc17_++;
                              }
                              switch(_loc16_ - 4)
                              {
                                 case 0:
                                 case 1:
                                    _adventureGoals[1].setValue(_loc4_ - _playerCrystalCount);
                                    break;
                                 case 3:
                                    _adventureGoals[1].setValue(Math.min(_playerCrystalCount,_loc4_));
                                    break;
                                 default:
                                    _adventureGoals[1].setValue(_playerCrystalCount);
                              }
                           }
                        }
                        break;
                     default:
                        if(_questActorDictionary["showorbcount"] != null)
                        {
                           if(_adventureGoals[1])
                           {
                              _adventureGoals[1].setValue(_playerCrystalCount);
                           }
                           break;
                        }
                        _loc17_ = 1;
                        while(_loc17_ <= 5)
                        {
                           _loc8_ = "gui_goal" + _loc17_;
                           if(!_questActorDictionary[_loc8_])
                           {
                              break;
                           }
                           if(_adventureGoals[_loc17_])
                           {
                              _adventureGoals[_loc17_].setValue(_questActorDictionary[_loc8_].state);
                           }
                           _loc17_++;
                        }
                  }
               }
            }
            for each(_loc7_ in _torches)
            {
               if(_loc7_.actor != null)
               {
                  _loc7_.light.x = _loc7_.actor.x + _loc7_.offsetX;
                  _loc7_.light.y = _loc7_.actor.y + _loc7_.offsetY;
                  if(_loc7_.layer == 0)
                  {
                     _loc7_.light.x -= _layerManager.room_avatars.x;
                     _loc7_.light.y -= _layerManager.room_avatars.y;
                  }
                  else
                  {
                     _loc7_.light.x -= _loc7_.light.width * 0.5;
                     _loc7_.light.y -= _loc7_.light.height * 0.5;
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
                  new SBParchmentPopup(GuiManager.guiLayer,3,LocalizationManager.translateIdOnly(14811),true,onDeathAccept);
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
            for each(var _loc2_:Object in _questActors)
            {
               if(_loc2_.isDead)
               {
                  _loc2_.destroy();
                  delete _questActors[_loc2_._actorId];
               }
               else
               {
                  _loc2_.heartbeat(_frameTime);
               }
            }
            _loc11_ = _questProjectiles.length - 1;
            while(_loc11_ >= 0)
            {
               if(_questProjectiles[_loc11_].heartbeat(_frameTime))
               {
                  _questProjectiles[_loc11_].destroy();
                  _questProjectiles.splice(_loc11_,1);
               }
               _loc11_--;
            }
            _loc11_ = _questMelees.length - 1;
            while(_loc11_ >= 0)
            {
               if(_questMelees[_loc11_].heartbeat(_frameTime))
               {
                  _questMelees[_loc11_].destroy();
                  _questMelees.splice(_loc11_,1);
               }
               _loc11_--;
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
         var _loc9_:Object = null;
         var _loc8_:int = 0;
         var _loc15_:Number = NaN;
         var _loc23_:AvatarInfo = null;
         var _loc19_:Point = null;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc17_:Point = null;
         var _loc18_:Point = null;
         var _loc21_:Point = null;
         var _loc10_:Point = null;
         var _loc16_:int = 0;
         var _loc20_:int = 0;
         var _loc1_:Object = null;
         var _loc25_:QuestActor = null;
         var _loc2_:Point = null;
         var _loc6_:Point = null;
         var _loc14_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc4_:int = 0;
         var _loc24_:Array = null;
         var _loc11_:Array = null;
         if(_fallingPhantoms.length > 0)
         {
            _loc8_ = _fallingPhantoms.length - 1;
            while(_loc8_ >= 0)
            {
               _loc9_ = _fallingPhantoms[_loc8_];
               if(_loc9_.npc != null)
               {
                  if(_loc9_.timerElapsed < _loc9_.timerMax)
                  {
                     _loc9_.timerElapsed += _frameTime;
                     if(_loc9_.timerElapsed > _loc9_.timerMax)
                     {
                        _loc9_.timerElapsed = _loc9_.timerMax;
                     }
                     _loc15_ = _loc9_.timerElapsed / _loc9_.timerMax;
                     _loc9_.npc.updateFallHeight(_loc9_.phantomStartY * (1 - _loc15_),_loc15_);
                     if(_loc15_ >= 1 && isOnscreen(_loc9_.npc))
                     {
                        _soundMan.play(_sounds[Math.random() < 0.5 ? "ajq_phntmfdeath1" : "ajq_phntmfdeath2"]);
                     }
                  }
                  if(_loc9_.npc.attacking && AvatarManager.playerAvatarWorldView != null)
                  {
                     _loc23_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                     if(_loc23_.questHealthPercentage > 0)
                     {
                        _loc19_ = _loc9_.npc.getCollisionPoint(2);
                        _loc5_ = AvatarManager.playerAvatarWorldView.x + -15 - (_loc9_.posX + _loc19_.x);
                        _loc3_ = AvatarManager.playerAvatarWorldView.y + -40 - (_loc9_.posY + _loc19_.y);
                        _loc13_ = Number(_loc9_.npc.getCollisionRadius(2));
                        50;
                        if(_loc5_ * _loc5_ + _loc3_ * _loc3_ < _loc13_ * _loc13_)
                        {
                           QuestXtCommManager.questPhantomZap("FallingPhantom",AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
                        }
                     }
                     _loc9_.npc.attacking = false;
                  }
                  if(_loc9_.timerElapsed >= _loc9_.timerMax && _loc9_.npc.animActive == false)
                  {
                     if(_loc9_.theSprite != null && _loc9_.theSprite.parent != null)
                     {
                        _loc9_.theSprite.parent.removeChild(_loc9_.theSprite);
                     }
                     _fallingPhantoms.splice(_loc8_,1);
                  }
               }
               _loc8_--;
            }
         }
         if(AvatarManager.playerAvatarWorldView != null)
         {
            _fallingPhantomTimer -= _frameTime;
            if(_fallingPhantomTimer <= 0)
            {
               _loc7_ = AvatarManager.playerAvatarWorldView.avatarPos.x - 500 + Math.random() * 1000;
               _loc17_ = null;
               _loc18_ = null;
               _loc21_ = new Point(_loc7_,AvatarManager.playerAvatarWorldView.avatarPos.y - 300);
               _loc10_ = new Point(_loc7_,AvatarManager.playerAvatarWorldView.avatarPos.y + 300);
               _loc1_ = null;
               _loc20_ = 0;
               while(_loc20_ < _fallingPhantomVolumeActors.length && _loc17_ == null)
               {
                  _loc25_ = _questActors[_fallingPhantomVolumeActors[_loc20_]];
                  if(_loc25_ != null && _loc25_._visible)
                  {
                     _loc16_ = 0;
                     while(_loc16_ < _loc25_._volumes.length && _loc17_ == null)
                     {
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(_loc21_,_loc25_._volumes[_loc16_]))
                        {
                           _loc17_ = _loc21_;
                        }
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(_loc10_,_loc25_._volumes[_loc16_]))
                        {
                           if(_loc17_ == null)
                           {
                              _loc17_ = _loc10_;
                           }
                           else
                           {
                              _loc18_ = _loc10_;
                           }
                        }
                        if(_loc17_ != null)
                        {
                           _loc1_ = _loc25_._volumes[_loc16_];
                        }
                        _loc16_++;
                     }
                  }
                  _loc20_++;
               }
               if(_loc18_ == null)
               {
                  _loc2_ = new Point();
                  _loc6_ = new Point();
                  if(_loc17_ == null)
                  {
                     _loc20_ = 0;
                     while(_loc20_ < _fallingPhantomVolumeActors.length)
                     {
                        _loc25_ = _questActors[_fallingPhantomVolumeActors[_loc20_]];
                        if(_loc25_ != null && _loc25_._visible)
                        {
                           _loc16_ = 0;
                           while(_loc16_ < _loc25_._volumes.length)
                           {
                              if(checkFallingPhantomVolumeIntersect(_loc25_._volumes[_loc16_].v,_loc21_,_loc10_,_loc2_,_loc6_))
                              {
                                 _loc17_ = _loc2_;
                                 _loc18_ = _loc6_;
                                 _loc1_ = _loc25_._volumes[_loc16_];
                                 break;
                              }
                              _loc16_++;
                           }
                        }
                        _loc20_++;
                     }
                  }
                  else if(checkFallingPhantomVolumeIntersect(_loc1_.v,_loc21_,_loc10_,_loc2_,_loc6_))
                  {
                     _loc18_ = _loc2_;
                  }
               }
               _loc14_ = 0.1;
               _loc22_ = 0.4;
               if(_loc18_ != null)
               {
                  _loc12_ = 0.75;
                  _loc26_ = 1.75;
                  if(_loc1_ != null && _loc1_.message.length > 0)
                  {
                     _loc24_ = _loc1_.message.split(",");
                     _loc4_ = 0;
                     while(_loc4_ < _loc24_.length)
                     {
                        _loc11_ = _loc24_[_loc4_].split("=");
                        if(_loc11_.length == 2)
                        {
                           switch(_loc11_[0])
                           {
                              case "ratemin":
                                 _loc14_ = _loc11_[1] / 1000;
                                 break;
                              case "ratemax":
                                 _loc22_ = _loc11_[1] / 1000;
                                 break;
                              case "speedmin":
                                 _loc12_ = _loc11_[1] / 1000;
                                 break;
                              case "speedmax":
                                 _loc26_ = _loc11_[1] / 1000;
                           }
                        }
                        _loc4_++;
                     }
                  }
                  _loc9_ = {};
                  _loc9_.phantomStartY = -750;
                  _loc9_.timerMax = _loc12_ + Math.random() * (_loc26_ - _loc12_);
                  _loc9_.timerElapsed = 0;
                  _loc9_.posX = _loc7_;
                  _loc9_.posY = _loc17_.y + Math.random() * (_loc18_.y - _loc17_.y);
                  _loc9_.mh = new MediaHelper();
                  _loc9_.mh.init(getNPCDef(36).mediaRefId,onFallingPhantomLoaded,_loc9_);
                  _fallingPhantoms.push(_loc9_);
               }
               _fallingPhantomTimer = _loc14_ + Math.random() * (_loc22_ - _loc14_);
            }
         }
      }
      
      public static function checkFallingPhantomVolumeIntersect(param1:Array, param2:Point, param3:Point, param4:Point, param5:Point) : Boolean
      {
         var _loc9_:int = 0;
         var _loc6_:Point = null;
         var _loc7_:Number = param1.length - 1;
         var _loc8_:Point = null;
         var _loc10_:Point = null;
         _loc9_ = 0;
         while(_loc9_ < _loc7_)
         {
            param4.x = param1[_loc9_].x;
            param4.y = param1[_loc9_].y;
            param5.x = param1[_loc9_ + 1].x;
            param5.y = param1[_loc9_ + 1].y;
            _loc6_ = Collision.segIntersection(param2,param3,param4,param5);
            if(_loc6_ != null)
            {
               if(_loc8_ != null)
               {
                  _loc10_ = _loc6_;
                  break;
               }
               _loc8_ = _loc6_;
            }
            _loc9_++;
         }
         if(_loc8_ != null)
         {
            param4.x = _loc8_.x;
            param4.y = _loc8_.y;
         }
         if(_loc10_ != null)
         {
            param5.x = _loc10_.x;
            param5.y = _loc10_.y;
         }
         return _loc8_ != null;
      }
      
      public static function meleeRadiusCheck(param1:int, param2:Point, param3:int, param4:Boolean) : Array
      {
         var _loc6_:Array = null;
         if(_questActorDictionary != null)
         {
            for each(var _loc5_:QuestActor in _questActors)
            {
               if((param4 ? _loc5_._actorData.type == 21 : _loc5_._actorData.type != 21) && _loc5_.meleeHitTest(param1,param2,param3))
               {
                  if(_loc6_ == null)
                  {
                     _loc6_ = [];
                  }
                  _loc6_.push(_loc5_);
               }
            }
         }
         return _loc6_;
      }
      
      public static function projectileRadiusCheck(param1:int, param2:int, param3:int, param4:Boolean) : QuestActor
      {
         var _loc5_:Point = null;
         if(_questActorDictionary != null)
         {
            _loc5_ = new Point(param1,param2);
            for each(var _loc6_:QuestActor in _questActors)
            {
               if((param4 ? _loc6_._actorData.type == 21 : _loc6_._actorData.type != 21) && _loc6_.hitTest(_loc5_,param3))
               {
                  return _loc6_;
               }
            }
         }
         return null;
      }
      
      private static function actorRadiusCheck() : void
      {
         var _loc3_:Boolean = false;
         var _loc1_:Object = null;
         var _loc4_:Object = null;
         if(AvatarManager.playerAvatarWorldView && (AvatarManager.playerAvatarWorldView.moving || _playerAvatarCurrentAnim != AvatarManager.playerAvatarWorldView.animId))
         {
            _playerAvatarCurrentAnim = AvatarManager.playerAvatarWorldView.animId;
            if(_questActorDictionary != null)
            {
               _loc3_ = false;
               for each(var _loc2_:Object in _questActors)
               {
                  if(_loc2_.onRadiusTest())
                  {
                     _loc3_ = true;
                  }
               }
               if(!_loc3_)
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
               if(_loc4_ == null || _loc4_.visible)
               {
                  _nearestRespawnPoint = _loc1_;
               }
            }
            _playerInStealthVolume = RoomManagerWorld.instance.volumeManager.testStealthVolumes(AvatarManager.playerAvatarWorldView.avatarPos) != null;
         }
      }
      
      public static function setActorDictionary(param1:Dictionary, param2:String) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         if(param1 != null)
         {
            _totalGemsEarned = 0;
            _totalXPEarned = 0;
            _playerCrystalCount = 0;
            _playerOrbCountTotal = 0;
            _guiTimerLocal = 0;
         }
         _defeatedPopUpTimer = 0;
         _questScriptTimeStamp = param2;
         if(_questActors != null)
         {
            for(var _loc8_:Object in _questActors)
            {
               _questActors[_loc8_].destroy();
               delete _questActors[_loc8_];
            }
         }
         _questActorDictionary = param1;
         _gameIdleTimer = 0;
         gMainFrame.stage.addEventListener("mouseDown",resetMouseDownIdleTimer,false);
         gMainFrame.stage.addEventListener("mouseMove",resetMouseMoveIdleTimer,false);
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
         for(var _loc7_:String in _questActorDictionary)
         {
            _loc4_ = _loc7_.lastIndexOf("__");
            if(_loc4_ != -1)
            {
               _loc5_ = _loc7_.substring(0,_loc4_);
               _loc6_ = _questActorGroups[_loc5_];
               if(_loc6_ == null)
               {
                  _loc6_ = [];
                  _questActorGroups[_loc5_] = _loc6_;
               }
               _loc6_.push(_loc7_);
            }
         }
         startFadeIn();
      }
      
      public static function clearPlayerDictionary() : void
      {
         if(_questPlayersDict != null)
         {
            for(var _loc1_:Object in _questPlayersDict)
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
         _playerTorch.removeEventListener("complete",stopLightAnim);
      }
      
      public static function sceneAssetsLoaded() : void
      {
         var _loc4_:Object = null;
         var _loc1_:Object = null;
         var _loc6_:Array = null;
         var _loc11_:Object = null;
         var _loc9_:Point = null;
         var _loc2_:Array = null;
         var _loc17_:Object = null;
         var _loc8_:Object = null;
         var _loc15_:int = 0;
         var _loc10_:int = 0;
         var _loc5_:QuestPlayerData = null;
         var _loc14_:MediaHelper = null;
         var _loc16_:int = 0;
         var _loc7_:String = null;
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
                  _loc4_ = _streamsLUT[_currentMusic];
                  _SFX_Music[_currentMusic] = _soundMan.addStream(_loc4_.name,_loc4_.vol);
               }
               _soundMan.playStream(_SFX_Music[_currentMusic],0,99999);
               _playMusicOnLoad = false;
            }
            if(_questObjectiveText != null && _questObjectiveText.length > 0 && GuiManager.mainHud.objBar != null)
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
            for(var _loc12_:String in _questActorDictionary)
            {
               _loc1_ = _questActorDictionary[_loc12_];
               if(_loc1_ != null)
               {
                  switch(_loc1_.type)
                  {
                     case 14:
                     case 5:
                     case 3:
                     case 22:
                     case 24:
                     case 26:
                        _loc6_ = RoomManagerWorld.instance.volumeManager.findVolume(_loc12_);
                        if(_loc6_ != null)
                        {
                           initQuestActor(_loc12_,0,0,null,null);
                           if(_loc1_.type == 26)
                           {
                              if(_fallingPhantomVolumeActors == null)
                              {
                                 _fallingPhantomVolumeActors = [];
                              }
                              _fallingPhantomVolumeActors.push(_loc12_);
                           }
                        }
                        break;
                     case 9:
                        _loc11_ = RoomManagerWorld.instance.findSpawn(null,_loc12_);
                        if(_loc11_ != null)
                        {
                           _loc9_ = new Point(_loc11_.x,_loc11_.y);
                           RoomManagerWorld.instance.convertToWorldSpace(_loc9_);
                           initQuestActor(_loc12_,0,0,null,_loc9_);
                        }
                        break;
                     case 2:
                        _loc2_ = RoomManagerWorld.instance.findLayers(_loc12_);
                        if(_loc2_ != null)
                        {
                           for each(var _loc3_:Object in _loc2_)
                           {
                              if(_loc1_.state > 0)
                              {
                                 if(_loc3_.s.content["setState"] != null)
                                 {
                                    _loc3_.s.content.setState(_loc1_.state,true);
                                 }
                              }
                              if(_loc3_.s.content.hasOwnProperty("setProgress"))
                              {
                                 _loc3_.s.content.setProgress(_loc1_.progress);
                              }
                              _loc3_.s.content.visible = _loc1_.visible;
                           }
                        }
                        break;
                     default:
                        if(_loc1_.spawnedFromActor != null)
                        {
                           doSpawnToRoot(_loc1_);
                        }
                  }
               }
            }
            RoomManagerWorld.instance.createMiniMap();
            _sceneLoaded = true;
            _playerTorch = addTorch(AvatarManager.playerAvatarWorldView,0.7,-15,-50);
            if(_playerTorch)
            {
               _playerTorch.addEventListener("complete",stopLightAnim,false,0,true);
            }
            while(_addTorchQueue.length)
            {
               _loc17_ = _addTorchQueue.pop();
               addTorch(_loc17_.actor,_loc17_.scale,_loc17_.offsetX,_loc17_.offsetY);
            }
            _loc8_ = _questActorDictionary["questready"];
            if(_loc8_ != null && _loc8_.state == 0)
            {
               QuestXtCommManager.questActorTriggered("questready");
            }
            if(_questActorDictionary["gui_ffm"])
            {
               _guiElementsSkipBtn = new MovieClip();
               _guiElementsSkipBtnMh = new MediaHelper();
               _guiElementsSkipBtnMh.init(392,skipButtonMediaCallback,true);
               _loc15_ = 0;
               while(_loc15_ < _guiElementsGuiManager.length)
               {
                  if(GuiManager.mainHud[_guiElementsGuiManager[_loc15_ + 1]])
                  {
                     _loc8_ = _questActorDictionary[_guiElementsGuiManager[_loc15_]];
                     if(_loc8_.state >= 0 && _loc8_.state <= 2)
                     {
                        if(GuiManager.mainHud[_guiElementsGuiManager[_loc15_ + 1]].hasOwnProperty("setButtonState"))
                        {
                           if(GuiManager.mainHud[_guiElementsGuiManager[_loc15_ + 1]].currentFrameLabel == "old")
                           {
                              GuiManager.mainHud[_guiElementsGuiManager[_loc15_ + 1]].gotoAndStop("new");
                           }
                           GuiManager.mainHud[_guiElementsGuiManager[_loc15_ + 1]].setButtonState(_loc8_.state);
                        }
                        if(_guiElementsGuiManager[_loc15_ + 1] == "money")
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[_loc15_ + 1]].addEventListener("mouseOver",guiDownHandler,false,0,true);
                        }
                        else
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[_loc15_ + 1]].addEventListener("mouseDown",guiDownHandler,false,0,true);
                        }
                        if(_guiElementsGuiManager[_loc15_ + 1] == "charWindow")
                        {
                           GuiManager.grayHudAvatar(_loc8_.state == 0);
                        }
                     }
                  }
                  _loc15_ += 2;
               }
            }
            if(_questPlayersSwitched)
            {
               for(var _loc13_:Object in _questPlayersSwitched)
               {
                  _loc10_ = int(_questPlayersSwitched[_loc13_]);
                  _loc5_ = getQuestPlayerData(_loc13_ as int);
                  if(_loc5_ != null)
                  {
                     _loc5_.setAvatarSwitched(_loc10_);
                  }
               }
            }
            if(_questActorDictionary["gui_timer"] != null || _questActorDictionary["gui_time_max"])
            {
               _loc14_ = new MediaHelper();
               _loc14_.init(2710,onTimerLoaded);
            }
            switch(getAdventureType() - 1)
            {
               case 0:
               case 2:
               case 3:
               case 4:
               case 5:
               case 6:
                  _loc14_ = new MediaHelper();
                  _loc14_.init(2745,onGuiGoalLoaded,{"goalId":1});
                  break;
               default:
                  if(_questActorDictionary["showorbcount"] != null)
                  {
                     _loc14_ = new MediaHelper();
                     _loc14_.init(2745,onGuiGoalLoaded,{"goalId":1});
                     break;
                  }
                  _loc16_ = 1;
                  while(_loc16_ <= 5)
                  {
                     _loc7_ = "gui_goal" + _loc16_ + "a";
                     if(!_questActorDictionary[_loc7_])
                     {
                        break;
                     }
                     _loc14_ = new MediaHelper();
                     _loc14_.init(2745,onGuiGoalLoaded,{"goalId":_loc16_});
                     _loc16_++;
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
         if(!param1.currentTarget.hasOwnProperty("isGray") || !param1.currentTarget.isGray)
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
         _guiElementsSkipBtn.addEventListener("mouseDown",guiElementsSkipBtnPress,false,0,true);
         _guiElementsSkipBtnMh.destroy();
         _guiElementsSkipBtnMh = null;
      }
      
      public static function guiElementsSkipBtnPress(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         commandExit(0,null);
         AvatarXtCommManager.sendAvatarPendingFlagsUpdate(0);
         gMainFrame.userInfo.firstFiveMinutes = 1;
         _guiElementsSkipBtn.visible = false;
      }
      
      public static function recycle(param1:int, param2:Object) : void
      {
         if(_assetPool[param1] == null)
         {
            _assetPool[param1] = [];
         }
         _assetPool[param1].push(param2);
      }
      
      private static function getQuestAsset(param1:int) : Object
      {
         var _loc3_:* = null;
         var _loc2_:Array = _assetPool[param1];
         if(_loc2_ && _loc2_.length > 0)
         {
            return _loc2_.pop();
         }
         return null;
      }
      
      public static function initQuestActor(param1:String, param2:int, param3:int, param4:Object = null, param5:Point = null, param6:Point = null, param7:Boolean = false, param8:String = null) : void
      {
         var _loc11_:Boolean = false;
         var _loc9_:QuestActor = null;
         var _loc10_:Array = null;
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
                  if(param4.hasOwnProperty("previouslyPickedUp") && param4.previouslyPickedUp)
                  {
                     return;
                  }
               }
               if(!param4.hasOwnProperty("actorPos"))
               {
                  if(param4.type == 11)
                  {
                     param4.actorOrigPos = new Point(param5.x,param5.y);
                     param4.origInnerRadius = param2;
                     param4.origOuterRadius = param3;
                     param4.origPriority = _actorPriority;
                  }
                  param4.actorPos = param5;
               }
               if(_questActors[param1] != null)
               {
                  _questActors[param1].destroy();
               }
               _loc11_ = true;
               switch(param4.type)
               {
                  case 12:
                  case 11:
                  case 23:
                     if(param4.healthPercent == 0)
                     {
                     }
               }
               if(_loc11_)
               {
                  if(param4.type == 11 || param4.type == 12 || param4.type == 23 || param4.type == 21 || param4.type == 1 || param4.type == 25)
                  {
                  }
                  if(_loc9_ == null)
                  {
                     _loc9_ = new QuestActor();
                     _loc9_.initActor(param1,param4,param2,param3,_actorPriority++,param6);
                  }
                  else
                  {
                     _loc9_.resetActor(param1,param4,param2,param3,_actorPriority++,param6);
                  }
                  _loc9_.setRequireClick(param4.requireClick);
                  _loc9_.setVisible(param4.visible);
                  _questActors[param1] = _loc9_;
                  var _loc13_:* = param4.type;
                  if(2 === _loc13_)
                  {
                     _loc10_ = RoomManagerWorld.instance.findLayers(param1);
                     if(_loc10_ != null)
                     {
                        for each(var _loc12_:Object in _loc10_)
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
         var _loc3_:int = 0;
         _questCommandActor = null;
         _questCommandActorState = -1;
         var _loc5_:QuestActor = _questActors[param2[param1++]];
         var _loc6_:int = int(param2[param1++]);
         var _loc4_:String = LocalizationManager.translateIdOnly(_loc6_);
         var _loc7_:Object = EmoticonUtility.matchEmoteString(_loc4_,true);
         if(_loc7_ != null && _loc7_.sprite != null)
         {
            _loc5_.setEmote(_loc7_.sprite);
         }
         else
         {
            _loc3_ = int(param2[param1++]);
            switch(_loc3_ - 1)
            {
               case 0:
                  if(_loc5_ != null)
                  {
                     _loc5_.setChatBalloonText(_loc4_,_loc5_.npcDef.avatarRefId == 32);
                     GuiManager.chatHist.addMessage("","",_loc4_);
                  }
                  break;
               case 1:
                  if(_loc5_ != null)
                  {
                     _loc5_.setChatBalloonText(_loc4_,false,true);
                  }
                  break;
               default:
                  if(_talkingPopup != null)
                  {
                     onTalkingPopupClose(null);
                  }
                  SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#dialog/" + _loc6_);
                  showTalkingDialog(GuiManager.guiLayer,_loc4_.split("|"),_loc5_ != null ? _loc5_.talkingHeadMediaRef : 0);
            }
         }
      }
      
      public static function commandAsk(param1:int, param2:Object) : void
      {
         if(_talkingPopup != null)
         {
            onTalkingPopupClose(null);
         }
         var _loc4_:int = int(param2[param1++]);
         _questCommandActor = param2[param1++];
         _questCommandActorState = param2[param1++];
         var _loc3_:QuestActor = _questActors[_questCommandActor];
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#dialog/" + param2[param1]);
         showTalkingDialog(GuiManager.guiLayer,LocalizationManager.translateIdOnly(param2[param1++]).split("|"),_loc3_ != null && _questCommandActor != "ask_actor" ? _loc3_.talkingHeadMediaRef : (_questCommandActor == "ask_actor" ? -1 : 0),-1,_loc4_ == 1);
      }
      
      private static function onCommandAskConfirm(param1:Boolean) : void
      {
         if(_questCommandActor != "" && _questCommandActorState != -1)
         {
            QuestXtCommManager.questAskComplete(_questCommandActor,_questCommandActorState,param1 == true ? 1 : 0);
            _questCommandActor = null;
            _questCommandActorState = -1;
         }
         if(getAdventureType() == 4)
         {
            if(_adventureGoals[1])
            {
               _adventureGoals[1].setOKPressed();
            }
         }
      }
      
      public static function commandSetState(param1:int, param2:Object, param3:Boolean) : void
      {
         var _loc7_:Object = null;
         var _loc10_:String = null;
         var _loc13_:int = 0;
         var _loc11_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc14_:int = 0;
         var _loc8_:AvatarEditor = null;
         var _loc9_:Object = null;
         var _loc5_:Array = null;
         if(_questActorDictionary != null)
         {
            _loc10_ = param2[param1++];
            _loc7_ = _questActorDictionary[_loc10_];
            if(_loc10_ == "gui_timer")
            {
               _soundMan.play(_sounds["aj_play_timer_tick1"]);
            }
            if(_loc7_ != null)
            {
               _loc13_ = int(param2[param1++]);
               if(_loc10_ == "gui_time_max")
               {
                  _guiTimerLocal = _loc13_;
                  if(_adventureTimer != null && _loc13_ > 0)
                  {
                     _adventureTimer.visible = true;
                  }
               }
               if(_loc10_ == "live_players")
               {
                  if(GuiManager.mainHud.questPlayersBtn != null)
                  {
                     GuiManager.mainHud.questPlayersBtn.activateGrayState(_loc13_ <= 1);
                     if(GuiManager.mainHud.playersCont.visible)
                     {
                        if(_loc13_ <= 1)
                        {
                           GuiManager.mainHud.playersCont.visible = false;
                           GuiManager.mainHud.questPlayersBtn.downToUpState();
                        }
                     }
                  }
               }
               if(param3)
               {
                  _loc7_.state = _loc13_;
               }
               else
               {
                  _loc11_ = param2[param1++] == 1;
                  _loc4_ = param2[param1++] == 1;
                  if(_loc7_.type == 15 && isDynamicallyJoinableQuest())
                  {
                     if(_loc7_.state == _loc13_ && _loc7_.visible != _loc11_)
                     {
                        return;
                     }
                  }
                  _loc7_.requireClick = _loc4_;
                  _loc7_.visible = _loc11_;
                  _loc7_.state = _loc13_;
                  if(ExternalInterface.available)
                  {
                     ExternalInterface.call("mrc",["dm","ACS," + _loc10_ + "," + _loc13_]);
                  }
                  switch(_loc7_.type)
                  {
                     case 28:
                        _loc12_ = false;
                        _loc14_ = 0;
                        while(_loc14_ <= _guiElementsGuiManager.length)
                        {
                           if(_loc10_ == _guiElementsGuiManager[_loc14_])
                           {
                              if(GuiManager.mainHud[_guiElementsGuiManager[_loc14_ + 1]])
                              {
                                 if(GuiManager.mainHud[_guiElementsGuiManager[_loc14_ + 1]].hasOwnProperty("setButtonState"))
                                 {
                                    if(GuiManager.mainHud[_guiElementsGuiManager[_loc14_ + 1]].currentFrameLabel == "old")
                                    {
                                       GuiManager.mainHud[_guiElementsGuiManager[_loc14_ + 1]].gotoAndStop("new");
                                    }
                                    GuiManager.mainHud[_guiElementsGuiManager[_loc14_ + 1]].setButtonState(_loc7_.state);
                                 }
                                 if(_guiElementsGuiManager[_loc14_ + 1] == "charWindow")
                                 {
                                    GuiManager.grayHudAvatar(_loc7_.state == 0);
                                 }
                              }
                              _loc12_ = true;
                              break;
                           }
                           _loc14_ += 2;
                        }
                        if(!_loc12_)
                        {
                           _loc8_ = GuiManager.avatarEditor;
                           if(_loc8_ != null && _loc8_.avEditor != null)
                           {
                              _loc14_ = 0;
                              while(_loc14_ <= _guiElementsAvatarEditor.length)
                              {
                                 if(_loc10_ == _guiElementsAvatarEditor[_loc14_])
                                 {
                                    _loc9_ = _loc8_.avEditor[_guiElementsAvatarEditor[_loc14_ + 1]];
                                    if(_loc9_ == null)
                                    {
                                       _loc9_ = _loc8_[_guiElementsAvatarEditor[_loc14_ + 1]];
                                    }
                                    if(_loc9_)
                                    {
                                       if(_loc7_.state == 2)
                                       {
                                          switch(_guiElementsAvatarEditor[_loc14_ + 1])
                                          {
                                             case "colorsTabUp":
                                                _loc8_.openTab(0);
                                                break;
                                             case "eyesTabUp":
                                                _loc8_.openTab(2);
                                                break;
                                             case "patternTabUp":
                                                _loc8_.openTab(1);
                                          }
                                       }
                                       if(_loc9_.hasOwnProperty("setButtonState"))
                                       {
                                          if(_loc9_.currentFrameLabel == "old")
                                          {
                                             _loc9_.gotoAndStop("new");
                                          }
                                          _loc9_.setButtonState(_loc7_.state);
                                       }
                                       else if(_guiElementsAvatarEditor[_loc14_ + 1] == "fiveMinCursor")
                                       {
                                          _loc9_.visible = _loc7_.state != 0;
                                          if(_loc7_.state != 0)
                                          {
                                             _loc9_.gotoAndPlay("state" + _loc7_.state);
                                          }
                                       }
                                    }
                                    _loc12_ = true;
                                    break;
                                 }
                                 _loc14_ += 2;
                              }
                           }
                        }
                        break;
                     case 2:
                        _loc5_ = RoomManagerWorld.instance.findLayers(_loc10_);
                        if(_loc5_ != null)
                        {
                           for each(var _loc6_:Object in _loc5_)
                           {
                              if(_loc6_.s != null && _loc6_.s.content != null)
                              {
                                 if(_loc6_.s.content["setState"] != null)
                                 {
                                    _loc6_.s.content.setState(_loc7_.state);
                                 }
                                 _loc6_.s.content.visible = _loc11_;
                              }
                           }
                        }
                        break;
                     case 7:
                        QuestXtCommManager.questActorTriggered(_loc10_);
                        break;
                     default:
                        _loc7_ = _questActors[_loc10_];
                        if(_loc7_ != null)
                        {
                           _loc7_.setRequireClick(_loc4_);
                           _loc7_.setVisible(_loc11_);
                           _loc7_.onRadiusTest();
                        }
                  }
               }
            }
         }
      }
      
      public static function commandTeleport(param1:int, param2:Object) : void
      {
         var _loc5_:Object = null;
         var _loc3_:String = null;
         var _loc6_:String = null;
         var _loc4_:Boolean = param2[param1++] == "1";
         if(_loc4_)
         {
            _loc3_ = param2[param1++];
            _loc5_ = _questActors[_loc3_];
            if(_loc5_ != null)
            {
               RoomManagerWorld.instance.teleportPlayer(_loc5_.x,_loc5_.y,true);
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
         var _loc9_:Object = null;
         var _loc5_:String = null;
         var _loc4_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc8_:Array = null;
         var _loc10_:int = 0;
         var _loc6_:Array = null;
         _loc5_ = param2[param1++];
         _loc9_ = _questActors[_loc5_];
         if(_loc9_ != null)
         {
            _loc4_ = 0.75;
            _loc7_ = 1.5;
            _loc3_ = 0.75;
            if(_loc9_._actorData.extendedParameters != null)
            {
               _loc8_ = _loc9_._actorData.extendedParameters.split(",");
               _loc10_ = 0;
               while(_loc10_ < _loc8_.length)
               {
                  switch((_loc6_ = _loc8_[_loc10_].split("="))[0])
                  {
                     case "camto":
                        _loc4_ = Number(_loc6_[1]);
                        break;
                     case "camstay":
                        _loc7_ = Number(_loc6_[1]);
                        break;
                     case "camreturn":
                        _loc3_ = Number(_loc6_[1]);
                  }
                  _loc10_++;
               }
            }
            RoomManagerWorld.instance.setCameraFocus(new Point(_loc9_.x,_loc9_.y),_loc4_,_loc7_,_loc3_,true);
         }
      }
      
      public static function commandExit(param1:int, param2:Object) : void
      {
         _questExitPending = true;
         _questObjectiveText = "";
         AvatarManager.setPlayerAttachmentEmot(0,null,0,false);
         if(_questActorDictionary["gui_ffm"])
         {
            QuestXtCommManager.sendQuestExit("ffm");
            gMainFrame.userInfo.firstFiveMinutes = 1;
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
         _delayMinigameLaunches = true;
      }
      
      public static function commandGame(param1:int, param2:Object) : void
      {
         var _loc3_:int = int(param2[param1++]);
         _questCommandActorMiniGame = param2[param1++];
         _questCommandActorStateMiniGame = param2[param1++];
         if(!_delayMinigameLaunches)
         {
            launchMinigame(_loc3_);
         }
         else
         {
            _delayMinigameID = _loc3_;
         }
      }
      
      public static function launchQueuedGame() : void
      {
         _delayMinigameLaunches = false;
         if(_delayMinigameID >= 0)
         {
            launchMinigame(_delayMinigameID);
            _delayMinigameID = -1;
         }
      }
      
      public static function launchMinigame(param1:int) : void
      {
         DarkenManager.showLoadingSpiral(true);
         MinigameManager.handleGameClick({
            "idx":5,
            "r":30,
            "spawn":"spawn",
            "type":0,
            "typeDefId":param1,
            "x":0,
            "y":0
         },null,true,null);
         RoomManagerWorld.instance.setGotoSpawnLocation(_lastGoodAvatarX,_lastGoodAvatarY);
      }
      
      public static function handleCommand(param1:Object, param2:Boolean) : void
      {
         var _loc4_:int = 2;
         var _loc3_:int = int(param1[_loc4_++]);
         switch(_loc3_)
         {
            case 1:
               commandSetState(_loc4_,param1,param2);
               break;
            case 38:
               commandNotify(_loc4_,param1);
               break;
            case 2:
               commandSay(_loc4_,param1);
               break;
            case 3:
               commandAsk(_loc4_,param1);
               break;
            case 4:
               commandGame(_loc4_,param1);
               break;
            case 14:
               commandTeleport(_loc4_,param1);
               break;
            case 15:
               commandFocus(_loc4_,param1);
               break;
            case 19:
               commandExit(_loc4_,param1);
               break;
            case 7:
               commandTakeItem(_loc4_,param1);
               break;
            case 1001:
               commandDebugSay(_loc4_,param1);
         }
      }
      
      public static function showTalkingDialog(param1:DisplayLayer, param2:Array, param3:int = 0, param4:int = -1, param5:Boolean = false) : void
      {
         var textIndex:int;
         var avt:AvatarView;
         var o:Object;
         var popupLayer:DisplayLayer = param1;
         var fullTextSplit:Array = param2;
         var talkingHeadMediaRef:int = param3;
         var streamId:int = param4;
         var useYesNo:Boolean = param5;
         if(_talkingPopup)
         {
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
               _talkingPopup.txt.autoSize = "center";
               _talkingPopup.txt.text = fullTextSplit.length > 1 ? fullTextSplit[1] : fullTextSplit[0];
               GuiManager.chatHist.addMessage("","",_talkingPopup.txt.text);
            }
            else
            {
               _talkingPopup.gotoAndStop("talkingHead");
               _talkingPopup.txt.autoSize = "center";
               _talkingPopup.talkingHeadTitleTxt.text = fullTextSplit[0];
               _talkingPopup.txt.text = fullTextSplit[1];
               textIndex = 1;
               while(textIndex < fullTextSplit.length)
               {
                  GuiManager.chatHist.addMessage("","",fullTextSplit[textIndex]);
                  textIndex = textIndex + 1;
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
               _talkingPopup.yesBtn.addEventListener("mouseDown",onYesBtn,false,0,true);
               _talkingPopup.noBtn.addEventListener("mouseDown",onNoBtn,false,0,true);
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
                     _talkingPopup.yesBtn.addEventListener("mouseDown",onYesBtn,false,0,true);
                     _talkingPopup.noBtn.addEventListener("mouseDown",onNoBtn,false,0,true);
                  }
               }
               _talkingPopup.okBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
               _talkingPopup.nextBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
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
            _mediaLoader.init(1789,onTalkingDialogLoaded,{
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
      
      private static function onAdventureGoalRewardsLoaded(param1:MovieClip) : void
      {
         if(_questActorDictionary != null && param1)
         {
            _adventureRewardsPopupStatus = [];
            if(_adventureRewardsPopup == null)
            {
               _adventureRewardsPopup = MovieClip(param1.getChildAt(0));
               _adventureRewardsPopup.x = 900 * 0.5;
               _adventureRewardsPopup.y = 550 * 0.5;
               _adventureRewardsPopup.addEventListener("mouseDown",onPopup,false,0,true);
            }
            updateRewardsDisplay(param1.passback);
            GuiManager.guiLayer.addChild(_adventureRewardsPopup);
            DarkenManager.darken(_adventureRewardsPopup);
         }
      }
      
      private static function updateRewardsDisplay(param1:Array) : void
      {
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:String = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc3_:Object = null;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         if(_adventureRewardsPopup)
         {
            switch((_loc7_ = getAdventureType()) - 1)
            {
               case 0:
                  _adventureRewardsPopup.setQuestType(2);
                  break;
               case 1:
               case 2:
               case 3:
               case 4:
               case 5:
               case 6:
                  _adventureRewardsPopup.setQuestType(3);
                  break;
               default:
                  _adventureRewardsPopup.setQuestType(1);
            }
            _loc9_ = 1;
            while(_loc9_ <= 5)
            {
               _loc2_ = "gui_goal" + _loc9_;
               _loc4_ = "gui_goal" + _loc9_ + "a";
               _loc5_ = _questActorDictionary[_loc2_];
               _loc3_ = _questActorDictionary[_loc4_];
               if(_loc3_ && _loc5_ && (_loc7_ != 3 && _loc7_ != 6 && _loc7_ != 7 && _loc7_ != 4 && _loc7_ != 5))
               {
                  _loc6_ = 0;
                  _loc8_ = int(_loc3_.state);
                  switch(_loc7_ - 1)
                  {
                     case 0:
                        _loc6_ = _playerOrbCountTotal;
                        if(_loc9_ == 1 && _loc6_ < _loc8_)
                        {
                           _loc8_ = 0;
                        }
                        break;
                     default:
                        _loc6_ = int(_loc5_.state);
                  }
                  if(_loc5_.hasOwnProperty("prizePicked"))
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[_loc9_] = true;
                     }
                     _adventureRewardsPopup.setState(_loc9_,3);
                     _adventureRewardsPopup["opt" + _loc9_].removeEventListener("mouseDown",onAdventureRewardsOptions);
                  }
                  else if(_loc6_ >= _loc8_ && param1[_loc9_ - 1].type != 0)
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[_loc9_] = false;
                     }
                     _adventureRewardsPopup.setState(_loc9_,2);
                     _adventureRewardsPopup["opt" + _loc9_].addEventListener("mouseDown",onAdventureRewardsOptions,false,0,true);
                     _adventureRewardsPopup["opt" + _loc9_].index = _loc9_ - 1;
                     _adventureRewardsPopup["opt" + _loc9_].prize = param1[_loc9_ - 1];
                  }
                  else
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[_loc9_] = true;
                     }
                     _adventureRewardsPopup.setState(_loc9_,1);
                  }
                  _adventureRewardsPopup.setValue(_loc9_,_loc6_);
                  _adventureRewardsPopup.setMaxValue(_loc9_,_loc8_);
               }
               else if(_loc7_ == 2 || _loc7_ == 3 || _loc7_ == 6 || _loc7_ == 7 || _loc7_ == 4 || _loc7_ == 5)
               {
                  switch(_loc9_ - 1)
                  {
                     case 0:
                        if(_adventureRewardsPopupStatus != null)
                        {
                           _adventureRewardsPopupStatus[_loc9_] = false;
                        }
                        switch(_adventureRewardsPopupType - 3)
                        {
                           case 0:
                              _adventureRewardsPopup.setState(_loc9_,14);
                              break;
                           case 1:
                           case 2:
                              _adventureRewardsPopup.setState(_loc9_,20);
                              break;
                           default:
                              if(_loc7_ == 7)
                              {
                                 _adventureRewardsPopup.setState(_loc9_,26);
                                 break;
                              }
                              _adventureRewardsPopup.setState(_loc9_,2);
                        }
                        _adventureRewardsPopup["opt" + _loc9_].addEventListener("mouseDown",onAdventureRewardsOptions,false,0,true);
                        _adventureRewardsPopup["opt" + _loc9_].index = _loc9_ - 1;
                        _adventureRewardsPopup["opt" + _loc9_].prize = param1[_loc9_ - 1];
                        break;
                     case 1:
                        if(gMainFrame.userInfo.isMember)
                        {
                           if(_adventureRewardsPopupStatus != null)
                           {
                              _adventureRewardsPopupStatus[_loc9_] = false;
                           }
                           switch(_adventureRewardsPopupType - 3)
                           {
                              case 0:
                                 _adventureRewardsPopup.setState(_loc9_,17);
                                 break;
                              case 1:
                              case 2:
                                 _adventureRewardsPopup.setState(_loc9_,23);
                                 break;
                              default:
                                 if(_loc7_ == 7)
                                 {
                                    _adventureRewardsPopup.setState(_loc9_,29);
                                    break;
                                 }
                                 _adventureRewardsPopup.setState(_loc9_,5);
                           }
                           _adventureRewardsPopup["opt" + _loc9_].addEventListener("mouseDown",onAdventureRewardsOptions,false,0,true);
                           _adventureRewardsPopup["opt" + _loc9_].index = _loc9_ - 1;
                           _adventureRewardsPopup["opt" + _loc9_].prize = param1[_loc9_ - 1];
                           break;
                        }
                        if(_adventureRewardsPopupStatus != null)
                        {
                           _adventureRewardsPopupStatus[_loc9_] = true;
                        }
                        switch(_adventureRewardsPopupType - 3)
                        {
                           case 0:
                              _adventureRewardsPopup.setState(_loc9_,16);
                              break;
                           case 1:
                           case 2:
                              _adventureRewardsPopup.setState(_loc9_,22);
                              break;
                           default:
                              if(_loc7_ == 7)
                              {
                                 _adventureRewardsPopup.setState(_loc9_,28);
                                 break;
                              }
                              _adventureRewardsPopup.setState(_loc9_,4);
                        }
                        _adventureRewardsPopup["opt" + _loc9_].addEventListener("mouseDown",onAdventureNonMemberRewardsOptions,false,0,true);
                        _adventureRewardsPopup["opt" + _loc9_].index = _loc9_ - 1;
                        _adventureRewardsPopup["opt" + _loc9_].prize = param1[_loc9_ - 1];
                  }
               }
               else
               {
                  _adventureRewardsPopup.setState(_loc9_,1);
                  _adventureRewardsPopup.setValue(0,0);
                  _adventureRewardsPopup.setMaxValue(_loc9_,0);
               }
               _loc9_++;
            }
         }
      }
      
      private static function onAdventureRewardsLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _adventureRewardsPopup = MovieClip(param1.getChildAt(0));
            _adventureRewardsPopup.x = 900 * 0.5;
            _adventureRewardsPopup.y = 550 * 0.5;
            updateAdventureRewards(param1.passback);
            _adventureRewardsPopup.addEventListener("mouseDown",onPopup,false,0,true);
            GuiManager.guiLayer.addChild(_adventureRewardsPopup);
            DarkenManager.darken(_adventureRewardsPopup);
         }
      }
      
      private static function updateAdventureRewards(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(_adventureRewardsPopup)
         {
            _loc2_ = 1;
            while(_loc2_ <= 5)
            {
               _adventureRewardsPopup["opt" + _loc2_].addEventListener("mouseDown",onAdventureRewardsOptions,false,0,true);
               _adventureRewardsPopup["opt" + _loc2_].index = _loc2_ - 1;
               _adventureRewardsPopup["opt" + _loc2_].prize = param1[_loc2_ - 1];
               _loc2_++;
            }
         }
      }
      
      private static function onAdventureNonMemberRewardsOptions(param1:MouseEvent) : void
      {
         UpsellManager.displayPopup(16,"adventure/" + _questScriptDefId);
      }
      
      private static function onAdventureRewardsOptions(param1:MouseEvent) : void
      {
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:String = null;
         var _loc7_:Object = null;
         var _loc8_:int = getAdventureType();
         _adventureRewardsPopup.giftIndexChosen = param1.currentTarget.index;
         if(_adventureGoals || _loc8_ == 2 || _loc8_ == 3 || _loc8_ == 6 || _loc8_ == 7 || _loc8_ == 5 || _loc8_ == 4)
         {
            _loc9_ = _adventureRewardsPopup.giftIndexChosen + 1;
            _loc2_ = "gui_goal" + _loc9_;
            _loc7_ = _questActorDictionary[_loc2_];
            if(_loc7_)
            {
               _loc7_.prizePicked = true;
            }
            if(_adventureRewardsPopup)
            {
               if(_adventureRewardsPopupStatus != null)
               {
                  _adventureRewardsPopupStatus[_loc9_] = true;
               }
               switch(_adventureRewardsPopupType - 3)
               {
                  case 0:
                     _adventureRewardsPopup.setState(_loc9_,15);
                     break;
                  case 1:
                  case 2:
                     _adventureRewardsPopup.setState(_loc9_,21);
                     break;
                  default:
                     if(_loc8_ == 7)
                     {
                        _adventureRewardsPopup.setState(_loc9_,27);
                        break;
                     }
                     _adventureRewardsPopup.setState(_loc9_,3);
               }
               _adventureRewardsPopup["opt" + _loc9_].removeEventListener("mouseDown",onAdventureRewardsOptions);
            }
         }
         switch(param1.currentTarget.prize.type)
         {
            case 1:
               _loc4_ = new DenItem();
               _loc4_.initShopItem(param1.currentTarget.prize.defID,param1.currentTarget.prize.versionId);
               _loc6_ = 2;
               _loc3_ = int(_loc4_.itemDefId);
               break;
            case 2:
               _loc4_ = new Item();
               _loc4_.init(param1.currentTarget.prize.defID,0,param1.currentTarget.prize.color,0,0,true);
               _loc6_ = 1;
               _loc3_ = int(_loc4_.defId);
               break;
            case 3:
               _loc6_ = 0;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(1086,rewardsGemOrCrystalLoaded,{
                  "giftType":_loc6_,
                  "amount":LocalizationManager.translateIdAndInsertOnly(11097,param1.currentTarget.prize.amount)
               });
               return;
            case 4:
               _loc6_ = 7;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(2221,rewardsGemOrCrystalLoaded,{
                  "giftType":_loc6_,
                  "amount":LocalizationManager.translateIdAndInsertOnly(11117,param1.currentTarget.prize.amount)
               });
               return;
         }
         _rewardsGiftPopup = new GiftPopup();
         var _loc5_:int = 8;
         switch(_adventureRewardsPopupType - 3)
         {
            case 0:
               _loc5_ = 15;
               break;
            case 1:
            case 2:
               _loc5_ = 16;
               break;
            default:
               switch(_loc8_ - 2)
               {
                  case 0:
                  case 1:
                  case 2:
                     _loc5_ = 14;
                     break;
                  case 5:
                     _loc5_ = 17;
                     break;
                  default:
                     _loc5_ = 8;
               }
         }
         _rewardsGiftPopup.init(GuiManager.guiLayer,_loc4_.largeIcon,_loc4_.name,_loc3_,_loc5_,_loc6_,onKeepRewardsGift,onDiscardRewardsGift,null,false,0);
      }
      
      private static function rewardsGemOrCrystalLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _rewardsGiftPopup = new GiftPopup();
         _rewardsGiftPopup.init(GuiManager.guiLayer,param1,param1.passback.amount,0,8,param1.passback.giftType,onKeepRewardsGift,onKeepRewardsGift,null,false,1);
      }
      
      private static function onDiscardRewardsGift() : void
      {
         QuestXtCommManager.sendPickGiftResult(-1,false,true);
         removeGiftPopup();
      }
      
      private static function onKeepRewardsGift() : void
      {
         var _loc1_:Object = _questActorDictionary["gui_goal1a"];
         if((getAdventureType() == 1 || getAdventureType() == 4) && _loc1_ != null && _playerOrbCountTotal < _loc1_.state)
         {
            QuestXtCommManager.sendPickGiftResult(_adventureRewardsPopup.giftIndexChosen,true,false);
         }
         else
         {
            QuestXtCommManager.sendPickGiftResult(_adventureRewardsPopup.giftIndexChosen,false,false);
         }
         removeGiftPopup();
      }
      
      private static function removeGiftPopup() : void
      {
         var _loc9_:int = 0;
         var _loc1_:String = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc2_:Object = null;
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         _rewardsGiftPopup.destroy();
         _rewardsGiftPopup = null;
         var _loc7_:Boolean = true;
         var _loc6_:int = getAdventureType();
         if(_adventureGoals && _loc6_ != 5 && _loc6_ != 3 && _loc6_ != 6 && _loc6_ != 7 && _loc6_ != 4)
         {
            _loc9_ = 1;
            while(_loc9_ <= 5)
            {
               _loc1_ = "gui_goal" + _loc9_;
               _loc3_ = "gui_goal" + _loc9_ + "a";
               _loc4_ = _questActorDictionary[_loc1_];
               _loc2_ = _questActorDictionary[_loc3_];
               if(_loc4_ && _loc2_)
               {
                  _loc5_ = 0;
                  _loc8_ = int(_loc2_.state);
                  switch(_loc6_ - 1)
                  {
                     case 0:
                     case 3:
                        _loc5_ = _playerOrbCountTotal;
                        break;
                     default:
                        _loc5_ = int(_loc4_.state);
                  }
                  if(_loc5_ >= _loc8_ && !_loc4_.hasOwnProperty("prizePicked"))
                  {
                     _loc7_ = false;
                     break;
                  }
               }
               _loc9_++;
            }
         }
         else if(_loc6_ == 2 || _loc6_ == 3 || _loc6_ == 6 || _loc6_ == 7 || _loc6_ == 5 || _loc6_ == 4)
         {
            if(_adventureRewardsPopupStatus != null && _adventureRewardsPopupStatus[1] == false || _adventureRewardsPopupStatus[2] == false)
            {
               _loc7_ = false;
            }
         }
         if(_loc7_)
         {
            _adventureRewardsPopup.removeEventListener("mouseDown",onPopup);
            _loc10_ = 1;
            while(_loc10_ <= 5)
            {
               _adventureRewardsPopup["opt" + _loc10_].removeEventListener("mouseDown",onAdventureRewardsOptions);
               _loc10_++;
            }
            DarkenManager.unDarken(_adventureRewardsPopup);
            GuiManager.guiLayer.removeChild(_adventureRewardsPopup);
            _adventureRewardsPopup = null;
            QuestXtCommManager.sendPickGiftComplete();
         }
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
            _talkingPopup.removeEventListener("mouseDown",onPopup);
            _talkingPopup.bx.removeEventListener("mouseDown",onTalkingPopupClose);
            if(_talkingPopup.currentFrameLabel == "response")
            {
               _talkingPopup.yesBtn.removeEventListener("mouseDown",onYesBtn);
               _talkingPopup.noBtn.removeEventListener("mouseDown",onNoBtn);
            }
            else if(_talkingPopup.currentFrameLabel == "ok")
            {
               _talkingPopup.okBtn.removeEventListener("mouseDown",onOkBtn);
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
            _talkingPopupCurrTextPage = _talkingPopupCurrTextPage + 1;
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
         var _loc2_:int = 2;
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
         if(param2 == "custSettings")
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
            _privateAdventureJoin.init(param1[4],privateAdventureJoinClose);
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
      
      public static function isBeYourPetQuest() : Boolean
      {
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType == 7)
         {
            _loc1_ = QuestXtCommManager.getScriptDef(gMainFrame.clientInfo.secondaryDefId);
            if(_loc1_ != null && _loc1_.playAsPet)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function isDynamicallyJoinableQuest() : Boolean
      {
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType == 7)
         {
            _loc1_ = QuestXtCommManager.getScriptDef(gMainFrame.clientInfo.secondaryDefId);
            if(_loc1_ != null && _loc1_.time == 1)
            {
               return true;
            }
         }
         return false;
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
         var _loc7_:QuestActor = null;
         var _loc5_:String = null;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:* = 0;
         var _loc3_:int = 2;
         _loc5_ = param1[_loc3_++];
         _loc7_ = _questActors[_loc5_];
         if(_loc7_ != null)
         {
            _loc2_ = int(param1[_loc3_++]);
            _loc6_ = int(param1[_loc3_++]);
            _loc4_ = uint(param1[_loc3_++]);
            _loc7_.handleAttackPlayer(_loc6_,_loc4_,_loc2_);
         }
      }
      
      public static function handleQuestActorPositionUpdateResponse(param1:Object) : void
      {
         var _loc10_:QuestActor = null;
         var _loc6_:String = null;
         var _loc5_:int = 2;
         _loc6_ = param1[_loc5_++];
         var _loc8_:int = int(param1[_loc5_++]);
         var _loc4_:int = int(param1[_loc5_++]);
         var _loc2_:int = int(param1[_loc5_++]);
         var _loc7_:int = int(param1[_loc5_++]);
         var _loc9_:int = int(param1[_loc5_++]);
         var _loc11_:int = int(param1[_loc5_++]);
         var _loc3_:Object = _questActorDictionary[_loc6_];
         if(_loc3_ != null)
         {
            _loc3_.actorPos = new Point(_loc8_,_loc4_);
         }
         _loc10_ = _questActors[_loc6_];
         if(_loc10_ != null)
         {
            _loc10_.handlePositionUpdate(_loc8_,_loc4_,_loc2_,_loc7_,_loc9_,_loc11_);
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
         var _loc7_:QuestActor = null;
         var _loc5_:String = null;
         var _loc4_:int = 2;
         _loc5_ = param1[_loc4_++];
         var _loc6_:int = int(param1[_loc4_++]);
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc2_:Object = _questActorDictionary[_loc5_];
         if(_loc2_ != null)
         {
            if(_loc6_ > _loc2_.seekType || _loc3_ == _loc2_.seekTypeSfsId)
            {
               _loc2_.seekType = _loc6_;
               _loc2_.seekTypeSfsId = _loc3_;
            }
         }
         if(_loc3_ == AvatarManager.playerSfsUserId)
         {
            _loc7_ = _questActors[_loc5_];
            if(_loc7_ != null)
            {
               _loc7_.handleRequestSeekResponse(_loc6_);
            }
         }
      }
      
      public static function handleLaunchProjectile(param1:Object) : void
      {
         var _loc10_:AvatarWorldView = null;
         var _loc4_:int = 2;
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc6_:int = int(param1[_loc4_++]);
         var _loc2_:int = int(param1[_loc4_++]);
         var _loc5_:String = param1[_loc4_++];
         var _loc7_:int = int(param1[_loc4_++]);
         var _loc8_:uint = uint(param1[_loc4_++]);
         var _loc9_:QuestActor = null;
         if(_loc7_ > 0)
         {
            _loc10_ = AvatarManager.avatarViewList[_loc7_];
            if(_loc10_ == null)
            {
               return;
            }
            _loc10_.faceAnim(_loc6_ - _loc10_.avatarPos.x,_loc2_ - _loc10_.avatarPos.y,false);
         }
         else
         {
            _loc9_ = _questActors[_loc5_];
         }
         launchProjectile(_loc3_,_loc8_,_loc6_,_loc2_,_loc9_,_loc10_);
      }
      
      public static function handleSetSwfState(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc6_:String = null;
         var _loc4_:String = null;
         var _loc2_:Object = null;
         var _loc5_:QuestActor = null;
         if(_questActorDictionary != null)
         {
            _loc3_ = 2;
            _loc6_ = param1[_loc3_++];
            _loc4_ = param1[_loc3_++];
            _loc2_ = _questActorDictionary[_loc6_];
            if(_loc2_ != null)
            {
               _loc2_.pendingSwfStateName = _loc4_;
            }
            _loc5_ = _questActors[_loc6_];
            if(_loc5_ != null)
            {
               _loc5_.setSwfState(_loc4_);
            }
         }
      }
      
      public static function handleLoadMediaLib(param1:Object) : void
      {
         var _loc2_:int = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         loadQuestSfx(_loc3_);
      }
      
      public static function getMaxQuestGoal(param1:int) : int
      {
         switch(param1 - 1)
         {
            case 0:
            case 6:
               return 5;
            case 4:
               return 1;
            default:
               return 4;
         }
      }
      
      public static function handleOrbsUpdate(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:String = null;
         var _loc2_:Object = null;
         var _loc3_:int = 2;
         var _loc8_:int;
         _playerCrystalCount = _loc8_ = int(param1[_loc3_++]);
         if(_playerOrbCountTotal < _playerCrystalCount)
         {
            _loc4_ = _playerOrbCountTotal;
            _playerOrbCountTotal = _playerCrystalCount;
            if(_adventureGoals != null)
            {
               switch((_loc7_ = getAdventureType()) - 1)
               {
                  case 0:
                  case 2:
                  case 3:
                  case 4:
                  case 5:
                  case 6:
                     if(_questActorDictionary["gui_goal1"])
                     {
                        if(_adventureGoals[1])
                        {
                           _loc6_ = getMaxQuestGoal(_loc7_);
                           _loc9_ = 1;
                           while(_loc9_ <= _loc6_)
                           {
                              _loc5_ = "gui_goal" + _loc9_ + "a";
                              _loc2_ = _questActorDictionary[_loc5_];
                              if(_loc2_ != null && _loc4_ < _loc2_.state && _playerOrbCountTotal >= _loc2_.state)
                              {
                                 _adventureGoals[1].setGoalAchieved(_loc9_);
                                 if(_loc7_ == 3 || _loc7_ == 6 || _loc7_ == 7 || _loc7_ == 4 || _loc7_ == 5)
                                 {
                                    QuestXtCommManager.questActorTriggered("gui_goal" + _loc9_);
                                 }
                              }
                              _loc9_++;
                           }
                        }
                     }
               }
            }
         }
      }
      
      public static function handlePickUpItem(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc12_:String = null;
         var _loc2_:Object = null;
         var _loc15_:int = 0;
         var _loc4_:Point = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc14_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Boolean = false;
         var _loc6_:QuestActor = null;
         var _loc5_:int = 0;
         var _loc7_:int = 2;
         var _loc13_:int;
         switch(_loc13_ = int(param1[_loc7_++]))
         {
            case 0:
               if(getAdventureType() != 5)
               {
                  _loc3_ = param1[_loc7_++];
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14812),true,onDropItemConfirm,_loc3_);
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(21617));
               }
               break;
            case 1:
            case 3:
            case 4:
               _loc12_ = param1[_loc7_++];
               _loc2_ = _questActorDictionary[_loc12_];
               _loc15_ = int(param1[_loc7_++]);
               if(_loc13_ == 4 || _loc13_ == 3)
               {
                  _loc4_ = new Point(param1[_loc7_++],param1[_loc7_++]);
                  if(_loc13_ == 4)
                  {
                     _loc9_ = int(param1[_loc7_++]);
                     _loc14_ = int(param1[_loc7_++]);
                     _loc10_ = int(param1[_loc7_++]);
                     if(_loc10_ == AvatarManager.playerSfsUserId)
                     {
                        _loc8_ = param1[_loc7_++];
                     }
                  }
               }
               if(_loc2_ != null)
               {
                  if(_loc2_.type == 15)
                  {
                     _loc2_.previouslyPickedUp = true;
                  }
                  _loc11_ = _loc13_ == 4 || _loc13_ == 3 || _loc2_.type == 17;
                  if(_loc4_ != null && _loc2_.type != 17)
                  {
                     _loc2_.actorPos = _loc4_;
                  }
                  _loc2_.visible = _loc11_;
                  _loc6_ = _questActors[_loc12_];
                  if(_loc6_ != null)
                  {
                     if(_loc4_ != null && _loc2_.type != 17)
                     {
                        _loc6_.x = _loc4_.x;
                        _loc6_.y = _loc4_.y;
                     }
                     _loc6_.setVisible(_loc11_);
                     if(_loc15_ == AvatarManager.playerSfsUserId && _loc13_ != 4)
                     {
                        _loc5_ = int(_loc13_ == 4 || _loc13_ == 3 ? 0 : UserCommXtCommManager.getEmoticonDefId(_loc6_._actorData.defId));
                        AvatarManager.setPlayerAttachmentEmot(_loc5_,null,0);
                        AvatarManager._setAvatarAttachmentEmot(_loc13_ == 4 || _loc13_ == 3 ? 0 : _loc6_._actorData.defId,"",_loc15_);
                        if(_loc6_._mediaObject && _loc6_._mediaObject.hasOwnProperty("playPickupSound"))
                        {
                           _loc6_._mediaObject.playPickupSound();
                        }
                     }
                  }
                  else if(_loc13_ == 4)
                  {
                     initQuestActor(_loc12_,_loc9_,_loc14_,null,new Point(_loc4_.x,_loc4_.y));
                  }
               }
               break;
            case 2:
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14813));
         }
      }
      
      public static function handleMovedItemList(param1:Array) : void
      {
         var _loc5_:String = null;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:Point = null;
         var _loc3_:int = 2;
         while(_loc3_ < param1.length)
         {
            _loc5_ = param1[_loc3_++];
            _loc2_ = int(param1[_loc3_++]);
            _loc4_ = int(param1[_loc3_++]);
            _loc6_ = new Point(param1[_loc3_++],param1[_loc3_++]);
            if(_questActors[_loc5_])
            {
               _loc3_ += 2;
            }
            else
            {
               initQuestActor(_loc5_,_loc2_,_loc4_,null,_loc6_);
            }
         }
      }
      
      public static function handleStatsUpdate(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc2_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         if(_loc2_ != null)
         {
            _loc2_.attackBase = param1[_loc3_++];
            _loc2_.attackMax = param1[_loc3_++];
            _loc2_.defenseBase = param1[_loc3_++];
            _loc2_.defenseMax = param1[_loc3_++];
            gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myPerUserAvId,_loc2_);
         }
      }
      
      public static function handleLevelUp(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc2_:int = int(param1[_loc3_++]);
         var _loc5_:int = int(param1[_loc3_++]);
         var _loc4_:QuestPlayerData = getQuestPlayerData(_loc2_);
         if(_loc4_ != null)
         {
            _loc4_.levelUp(_loc5_);
         }
      }
      
      public static function handleXpUpdate(param1:Object) : void
      {
         var _loc8_:Object = null;
         var _loc4_:int = 2;
         var _loc11_:int = int(param1[_loc4_++]);
         var _loc7_:int = int(param1[_loc4_++]);
         var _loc6_:int = int(param1[_loc4_++]);
         var _loc10_:int = int(param1[_loc4_++]);
         var _loc5_:Number = Number(param1[_loc4_++]);
         var _loc9_:String = param1[_loc4_++];
         var _loc3_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         _totalXPEarned += _loc11_;
         _loc3_.questXp = _loc7_;
         _loc3_.questLevel = _loc10_;
         _loc3_.questXPPercentage = _loc5_;
         GuiManager.addQuestXP(_loc5_);
         var _loc2_:QuestActor = _questActors[_loc9_];
         if(_loc2_ != null)
         {
            _loc2_.setActorText(LocalizationManager.translateIdAndInsertOnly(18481,_loc11_));
         }
         if(_loc6_ < _loc10_)
         {
            _loc8_ = QuestXtCommManager.getScriptDef(_questScriptDefId);
            if(_loc8_ && _loc8_.levelMin == 0)
            {
               gMainFrame.userInfo.updateAllAvatarInfoQuestXPIfZeroByUserName(gMainFrame.userInfo.myUserName,_loc7_,_loc10_);
            }
            SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#levelUp/" + _loc10_);
            if(_loc10_ % 5 == 0)
            {
               loadLevelShape(_loc10_);
            }
            else
            {
               GuiManager.updateShapeXP(_loc10_);
            }
            if(AvatarManager.playerAvatarWorldView)
            {
               AvatarManager.playerAvatarWorldView.updateNameBarLevelShape(_loc10_);
            }
         }
      }
      
      public static function handleQuestActorTriggerTreasure(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = 2;
         var _loc8_:String = param1[_loc3_++];
         var _loc2_:QuestActor = _questActors[_loc8_];
         if(_loc2_ != null)
         {
            _loc4_ = int(param1[_loc3_++]);
            _loc5_ = int(param1[_loc3_++]);
            _loc6_ = int(param1[_loc3_++]);
            _loc7_ = int(param1[_loc3_++]);
            _loc2_.handleTriggerTreasure(_loc4_,_loc5_,_loc6_,_loc7_);
         }
      }
      
      public static function handleRestore(param1:Object) : void
      {
         var _loc5_:QuestActor = null;
         var _loc3_:int = 2;
         var _loc6_:String = param1[_loc3_++];
         var _loc4_:int = int(param1[_loc3_++]);
         var _loc2_:Object = _questActorDictionary[_loc6_];
         if(_loc2_ != null && _loc2_.hasOwnProperty("actorPos"))
         {
            _loc2_.healthPercent = _loc4_;
            if(_loc2_.type == 11)
            {
               _loc2_.actorPos = new Point(_loc2_.actorOrigPos.x,_loc2_.actorOrigPos.y);
               _loc2_.seekType = 0;
               _loc2_.seekTypeSfsId = 0;
            }
            _loc5_ = _questActors[_loc6_];
            if(_loc5_ != null)
            {
               _questActors[_loc6_].destroy();
               delete _questActors[_loc6_];
            }
            _loc5_ = new QuestActor();
            _loc5_.initActor(_loc6_,_loc2_,_loc2_.origInnerRadius,_loc2_.origOuterRadius,_loc2_.origPriority,null);
            _loc5_.setRequireClick(_loc2_.requireClick);
            _loc5_.setVisible(_loc2_.visible);
            _questActors[_loc6_] = _loc5_;
            if(_loc5_ != null)
            {
               _loc5_.healthUpdate(_loc4_,0,false);
            }
         }
      }
      
      public static function handleAvSwitch(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc2_:int = int(param1[_loc3_++]);
         var _loc5_:int = int(param1[_loc3_++]);
         if(_loc2_ != -1)
         {
            if(_questPlayersSwitched == null)
            {
               _questPlayersSwitched = new Dictionary();
            }
            _questPlayersSwitched[_loc5_] = _loc2_;
         }
         else if(_questPlayersSwitched != null && _questPlayersSwitched[_loc5_] != null)
         {
            delete _questPlayersSwitched[_loc5_];
         }
         var _loc4_:QuestPlayerData = getQuestPlayerData(_loc5_);
         if(_loc4_ != null)
         {
            _loc4_.setAvatarSwitched(_loc2_);
         }
      }
      
      public static function handleExitByType(param1:Object) : void
      {
         var _loc2_:int = 2;
         var _loc3_:String = param1[_loc2_++];
         if(_loc3_ == "ffm")
         {
            GuiManager.isInFFM = false;
            RoomManagerWorld.instance.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest("jamaa_township.room_main#" + RoomManagerWorld.instance.shardId);
            LoadProgress.show(true);
            SBTracker.trackPageview("/game/play/popup/playerEngagement",-1,1);
            GuiManager.initPlayerEngagement(null);
            GuiManager.reAddEmotes();
         }
      }
      
      public static function handleSpawn(param1:Object) : void
      {
         var _loc10_:int = 0;
         var _loc9_:int = 0;
         var _loc14_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc11_:Object = null;
         var _loc8_:int = 2;
         var _loc4_:String = param1[_loc8_++];
         var _loc12_:String = param1[_loc8_++];
         var _loc5_:int = int(param1[_loc8_++]);
         var _loc13_:int = int(param1[_loc8_++]);
         var _loc3_:Object = {};
         _loc3_.visible = true;
         _loc3_.requireClick = true;
         _loc3_.type = _loc5_;
         _loc3_.defId = _loc13_;
         _loc3_.state = 0;
         _loc3_.actorName = _loc12_;
         initInitialActorStatus(_loc3_,_loc4_);
         switch(_loc5_)
         {
            case 200:
               _loc10_ = int(param1[_loc8_++]);
               _loc3_.subType = _loc10_;
               switch(_loc10_ - 1)
               {
                  case 0:
                     _loc9_ = int(param1[_loc8_++]);
                     _loc3_.denDefId = _loc9_;
                     break;
                  case 1:
                     _loc14_ = int(param1[_loc8_++]);
                     _loc6_ = int(param1[_loc8_++]);
                     _loc3_.itemDefId = _loc14_;
                     _loc3_.itemData = _loc6_;
                     break;
                  case 2:
                     _loc7_ = int(param1[_loc8_++]);
                     _loc3_.gems = _loc7_;
                     break;
                  case 3:
                     _loc2_ = int(param1[_loc8_++]);
                     _loc11_ = _questActorDictionary["orbnpcid"];
                     _loc3_.gems = _loc2_;
                     if(_loc11_ != null && _loc11_.state != 0)
                     {
                        _loc3_.defId = _loc11_.state;
                     }
               }
               break;
            case 11:
            case 23:
               _loc3_.spawnOffsetX = param1[_loc8_++];
               _loc3_.spawnOffsetY = param1[_loc8_++];
         }
         _questActorDictionary[_loc12_] = _loc3_;
         doSpawn(_loc3_,_loc4_);
      }
      
      public static function doSpawnToRoot(param1:Object) : void
      {
         var _loc3_:QuestActor = null;
         var _loc2_:Object = null;
         if(param1.spawnedFromActor != null)
         {
            if(param1.type == 200 && param1.pickedUp == true)
            {
               return;
            }
            _loc3_ = _questActors[param1.spawnedFromActor];
            if(_loc3_ == null)
            {
               _loc2_ = _questActorDictionary[param1.spawnedFromActor];
               if(_loc2_ != null && _loc2_.spawnedFromActor != null)
               {
                  doSpawnToRoot(_loc2_);
               }
            }
            doSpawn(param1,param1.spawnedFromActor);
         }
      }
      
      public static function doSpawn(param1:Object, param2:String) : void
      {
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc10_:Point = null;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc9_:QuestActor = _questActors[param1.spawnedFromActor];
         if(_loc9_ != null)
         {
            _loc4_ = 0;
            _loc6_ = 0;
            _loc10_ = null;
            if(param1.actorPos == null)
            {
               _loc5_ = _loc9_.x;
               _loc3_ = _loc9_.y;
               switch(param1.type)
               {
                  case 11:
                  case 23:
                     if(_loc9_._actorData.type == 12)
                     {
                        _loc8_ = 2 * _loc9_._actorDefaultInnerRadius * param1.spawnOffsetX / 1000 - _loc9_._actorDefaultInnerRadius;
                        _loc7_ = 2 * _loc9_._actorDefaultInnerRadius * param1.spawnOffsetY / 1000 - _loc9_._actorDefaultInnerRadius;
                        _loc5_ += _loc8_;
                        _loc3_ += _loc7_;
                        _loc10_ = new Point(-_loc8_,-_loc7_);
                     }
               }
               param1.actorPos = new Point(_loc5_,_loc3_);
               initQuestActor(param1.actorName,_loc4_,_loc6_,param1,null,_loc10_);
            }
            switch(param1.type)
            {
               case 11:
               case 23:
                  param1.respawned = true;
                  if(_loc9_._actorData.type == 12)
                  {
                     _loc4_ = 225;
                     _loc6_ = _loc9_._actorDefaultOuterRadius;
                  }
            }
            initQuestActor(param1.actorName,_loc4_,_loc6_,param1,null,_loc10_);
         }
      }
      
      public static function loadLevelShape(param1:int) : void
      {
         var _loc2_:int = 0;
         if(!GuiManager.isBeYourPetRoom())
         {
            _levelShapeHelper = new MediaHelper();
            _loc2_ = int(Math.floor(param1 / 5) > NameBar.LEVEL_SHAPES.length - 1 ? NameBar.LEVEL_SHAPES[NameBar.LEVEL_SHAPES.length - 1] : NameBar.LEVEL_SHAPES[Math.floor(param1 / 5)]);
            _levelShapeHelper.init(_loc2_,onLevelShapeLoaded,param1);
         }
         AvatarManager.playerAvatarWorldView.updateNameBarLevelShape(param1);
      }
      
      public static function handleActorHealthStatus(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:int = 2;
         var _loc8_:String = param1[_loc3_++];
         var _loc4_:int = int(param1[_loc3_++]);
         var _loc7_:QuestActor = _questActors[_loc8_];
         if(_loc4_ == -1)
         {
            if(_loc7_ != null)
            {
               if(_loc7_._actorData.type == 23 || _loc7_._actorData.type == 11 && _loc7_._attackable > 0)
               {
                  _loc7_.setActorText("miss");
               }
            }
         }
         else
         {
            _loc2_ = _questActorDictionary[_loc8_];
            if(_loc2_ != null)
            {
               _loc2_.healthPercent = _loc4_;
            }
            if(_loc7_ != null)
            {
               _loc6_ = int(param1[_loc3_++]);
               _loc5_ = int(param1[_loc3_++]);
               _loc7_.healthUpdate(_loc4_,_loc6_,_loc5_ == 1);
            }
         }
      }
      
      public static function handleHealthUpdate(param1:Object, param2:Boolean) : void
      {
         var _loc13_:AvatarWorldView = null;
         var _loc3_:AvatarInfo = null;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 2;
         var _loc10_:int = int(param1[_loc4_++]);
         var _loc7_:int = int(param1[_loc4_++]);
         var _loc12_:int = int(param1[_loc4_++]);
         var _loc11_:int = int(param1[_loc4_++]);
         var _loc8_:int = int(param1[_loc4_++]);
         var _loc9_:QuestPlayerData = getQuestPlayerData(_loc10_);
         if(_loc7_ == -1 && _loc12_ == 0)
         {
            if(_loc9_ != null)
            {
            }
         }
         else
         {
            _loc13_ = AvatarManager.avatarViewList[_loc10_];
            if(_loc9_ != null)
            {
               if(_loc12_ < 0)
               {
                  _loc9_.playerDamaged(_loc8_,_loc11_ + -_loc12_,_loc11_);
               }
               if(_loc13_)
               {
                  _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc13_.userName);
                  _loc3_.questHealthPercentage = _loc7_;
                  _loc3_.healthBase = _loc8_;
                  if(_loc3_.isDead && _loc7_ > 0)
                  {
                     _loc3_.isDead = false;
                     _loc13_.playAnim(16);
                  }
               }
               if(_loc12_ < 0)
               {
                  _loc9_.handleHit(_loc12_);
               }
               else
               {
                  _loc9_.handleHealing(_loc12_);
               }
            }
            if(_loc13_)
            {
               if(param2 && _loc13_ != AvatarManager.playerAvatarWorldView)
               {
                  _loc6_ = int(param1[_loc4_++]);
                  _loc5_ = int(param1[_loc4_++]);
                  _loc13_.setPos(_loc6_,_loc5_,false);
               }
               if(_loc7_ > 0)
               {
                  _loc13_.holdAnimId = 0;
               }
               _loc13_.updateNameBarHealth(_loc7_);
               if(_loc10_ == gMainFrame.server.userId)
               {
                  GuiManager.setQuestHearts(_loc7_);
               }
            }
         }
      }
      
      public static function handleQuestSetPath(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc6_:String = param1[_loc3_++];
         var _loc4_:String = param1[_loc3_++];
         var _loc5_:QuestActor = _questActors[_loc6_];
         var _loc2_:Object = _questActorDictionary[_loc6_];
         if(_loc2_ != null)
         {
            _loc2_.pathName = _loc4_;
         }
         if(_loc5_ != null)
         {
            _loc5_.setPath(_loc4_);
         }
      }
      
      public static function handleQuestVolumeInteractionUpdate(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc5_:Array = null;
         var _loc3_:int = 2;
         var _loc6_:String = param1[_loc3_++];
         var _loc4_:int = int(param1[_loc3_++]);
         _loc2_ = _questActorDictionary[_loc6_];
         if(_loc2_ != null)
         {
            if(_loc2_.progress == 0 && _loc4_ > 0)
            {
               playSound("ajq_chainstart");
            }
            if(_loc4_ > _loc2_.progress)
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
            else if(_loc4_ < _loc2_.progress)
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
            if(_loc4_ == 100 && _progressingSC)
            {
               _progressingSC.stop();
               _progressingSC = null;
               playSound("ajq_phoenixstinger");
            }
            if(_loc4_ == 0 && _progressingSCnot)
            {
               _progressingSCnot.stop();
               _progressingSCnot = null;
            }
            _loc2_.progress = _loc4_;
            _loc5_ = RoomManagerWorld.instance.findLayers(_loc6_);
            if(_loc5_ != null)
            {
               for each(var _loc7_:Object in _loc5_)
               {
                  if(_loc7_.s != null && _loc7_.s.content != null)
                  {
                     if(_loc7_.s.content.hasOwnProperty("setProgress"))
                     {
                        _loc7_.s.content.setProgress(_loc2_.progress);
                     }
                  }
               }
            }
         }
      }
      
      public static function handleQuestRoomChange(param1:Object) : void
      {
         var _loc4_:int = 2;
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc5_:String = param1[_loc4_++];
         var _loc6_:int = int(param1[_loc4_++]);
         var _loc2_:int = int(param1[_loc4_++]);
         AvatarManager.setOffScreenMapBySfsId(_loc3_,new Point(_loc6_,_loc2_),_loc5_);
         if(_questPlayersDict[_loc3_] != null)
         {
            _questPlayersDict[_loc3_].playerLeftRoom();
         }
      }
      
      public static function handlePlayerLeftQuest(param1:Object) : void
      {
         var _loc2_:AvatarInfo = null;
         var _loc5_:Object = null;
         var _loc8_:int = 0;
         var _loc4_:int = 2;
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc6_:String = param1[_loc4_++];
         var _loc10_:AvatarWorldView = AvatarManager.avatarViewList[_loc3_];
         if(_loc10_)
         {
            _loc2_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc10_.userName);
            _loc2_.questTorchStatus = false;
         }
         AvatarManager.removeAvatar(_loc3_,true);
         var _loc7_:Object = QuestXtCommManager.getScriptDef(_questScriptDefId);
         var _loc9_:Boolean = true;
         if(_loc7_)
         {
            _loc9_ = _loc7_.time != 1;
         }
         if(_loc9_ && AvatarManager.playerSfsUserId != _loc3_)
         {
            _loc8_ = 0;
            while(_loc8_ < _playerLeftObjects.length)
            {
               _loc5_ = _playerLeftObjects[_loc8_];
               if(!_loc5_.hasLeft)
               {
                  _loc5_.icon.txtMc.txt.autoSize = "center";
                  LocalizationManager.translateIdAndInsert(_loc5_.icon.txtMc.txt,11393,LocalizationManager.translateAvatarName(_loc6_));
                  _loc5_.icon.x = 900 * 0.5;
                  if(_loc8_ != 0 && !_playerLeftObjects[_loc8_ - 1].complete)
                  {
                     _playerLeftObjects[_loc8_ - 1].icon.y -= _loc5_.icon.height * _loc8_;
                  }
                  _loc5_.icon.y = 550 * 0.5;
                  GuiManager.guiLayer.addChild(_loc5_.icon);
                  _loc5_.icon.startLeaveText(onLeaveTextComplete,_loc8_);
                  _loc5_.hasLeft = true;
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
            _loc4_ = {};
         }
         if(_loc4_.count == param3 - 1 && param2 > _loc4_.count)
         {
            playSound("ajq_boomSeedPluck");
         }
         _loc4_.count = param2;
         _loc4_.max = param3;
         _questSeeds[param1] = _loc4_;
         if(_seedInventory != null)
         {
            _seedInventory.rebuildInventory(_questSeeds);
         }
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
         if(param1 == 2607)
         {
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_FRE)
            {
               param1 = 2718;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
            {
               param1 = 2736;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_DE)
            {
               param1 = 2761;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
            {
               param1 = 2913;
            }
         }
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
         var _loc2_:Class = null;
         var _loc1_:String = null;
         var _loc3_:Number = NaN;
         UserCommXtCommManager.sendPermEmote(542);
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
            _loc1_ = _playSwfMC.playSoundOnLoad;
            if(_loc1_ && _loc1_ != "")
            {
               _loc3_ = 0.49;
               if(_playSwfMC.hasOwnProperty("playSoundOnLoadVolume"))
               {
                  _loc3_ = Number(_playSwfMC.playSoundOnLoadVolume);
               }
               _loc2_ = _playSwfMC.loaderInfo.applicationDomain.getDefinition(_loc1_) as Class;
               _soundMan.addSound(_loc2_,_loc3_,_loc1_);
               _playSwfMCSC = _soundMan.play(_loc2_);
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
         if(_guiElementsSkipBtn && _guiElementsSkipBtn.parent)
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
         var _loc11_:String = null;
         var _loc4_:Object = null;
         var _loc7_:Array = null;
         var _loc10_:QuestActor = null;
         var _loc3_:int = 0;
         var _loc12_:AvatarWorldView = null;
         var _loc2_:AvatarInfo = null;
         var _loc6_:int = 2;
         var _loc5_:Boolean = param1[_loc6_++] == 0;
         var _loc9_:Boolean = param1[_loc6_++] == 1;
         if(_loc5_)
         {
            _loc11_ = param1[_loc6_++];
            _loc4_ = _questActorDictionary[_loc11_];
            if(_loc4_ != null)
            {
               _loc4_.torchEnabled = _loc9_;
               if(_loc4_.type == 2)
               {
                  _loc7_ = RoomManagerWorld.instance.findLayers(_loc11_);
                  if(_loc7_ != null)
                  {
                     for each(var _loc8_:Object in _loc7_)
                     {
                        _loc9_ ? addTorch(_loc8_) : removeTorch(_loc8_);
                     }
                  }
               }
               else
               {
                  _loc10_ = _questActors[_loc11_];
                  if(_loc10_ != null)
                  {
                     _loc10_.updateTorch();
                  }
               }
            }
         }
         else
         {
            _loc3_ = int(param1[_loc6_++]);
            _loc12_ = AvatarManager.avatarViewList[_loc3_];
            if(_loc12_)
            {
               _loc2_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc12_.userName);
               _loc2_.questTorchStatus = _loc9_;
               if(_loc9_)
               {
                  addTorch(_loc12_,1.3,-15,-50);
               }
               else
               {
                  removeTorch(_loc12_);
               }
            }
         }
      }
      
      public static function handlePickGift(param1:Object, param2:Boolean) : void
      {
         var _loc11_:Object = null;
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc14_:Object = null;
         var _loc3_:Object = null;
         var _loc12_:Array = [];
         var _loc9_:int = 2;
         var _loc7_:int = int(param1[_loc9_++]);
         _adventureRewardsPopupType = param1[_loc9_++];
         if(!param2 && _adventureRewardsPopupType == 5)
         {
            _handlePickGiftDelayData = param1;
            _handlePickGiftDelayTimer = 1.5;
            return;
         }
         var _loc10_:Object = _questActorDictionary["gui_goal1a"];
         if((getAdventureType() == 1 || getAdventureType() == 4) && _loc10_ != null && _playerOrbCountTotal < _loc10_.state)
         {
            _loc11_ = {};
            _loc11_.type = 3;
            _loc11_.amount = 150;
            _loc12_.push(_loc11_);
            _loc8_ = 1;
            while(_loc8_ < _loc7_)
            {
               _loc11_ = {};
               _loc11_.type = 0;
               _loc12_.push(_loc11_);
               _loc8_++;
            }
         }
         else
         {
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               _loc11_ = {};
               _loc6_ = int(param1[_loc9_++]);
               _loc4_ = int(param1[_loc9_++]);
               _loc5_ = int(param1[_loc9_++]);
               _loc11_.type = _loc6_;
               switch(_loc11_.type)
               {
                  case 1:
                     _loc11_.defID = _loc4_;
                     break;
                  case 2:
                     _loc11_.defID = _loc4_;
                     _loc11_.color = _loc5_;
                     break;
                  case 3:
                     _loc11_.amount = _loc4_;
                     break;
                  case 4:
                     _loc11_.amount = _loc4_;
               }
               _loc12_.push(_loc11_);
               _loc8_++;
            }
         }
         _mediaLoader = new MediaHelper();
         var _loc13_:int = getAdventureType();
         if(_adventureGoals || _loc13_ == 5 || _loc13_ == 2 || _loc13_ == 7 || _loc13_ == 3 || _loc13_ == 6 || _loc13_ == 4)
         {
            if(_adventureRewardsPopup)
            {
               updateRewardsDisplay(_loc12_);
            }
            else
            {
               _mediaLoader.init(2754,onAdventureGoalRewardsLoaded,_loc12_);
            }
         }
         else if(_adventureRewardsPopup)
         {
            updateAdventureRewards(_loc12_);
         }
         else
         {
            _mediaLoader.init(2251,onAdventureRewardsLoaded,_loc12_);
         }
         if(_loc13_ == 1)
         {
            for(_loc14_ in _questActors)
            {
               if(_questActors[_loc14_]._actorData.type == 200)
               {
                  _loc3_ = _questActorDictionary[_loc14_];
                  if(_loc3_ != null)
                  {
                     _loc3_.healthPercent = 0;
                  }
                  _questActors[_loc14_].destroy();
                  delete _questActors[_loc14_];
               }
            }
         }
      }
      
      public static function handleBeamZap(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc5_:String = param1[_loc3_++];
         var _loc2_:int = int(param1[_loc3_++]);
         var _loc4_:QuestActor = _questActors[_loc5_];
         if(_loc4_ != null)
         {
            _loc4_.handleBeamZap(_loc2_);
         }
      }
      
      public static function handlePhantomZap(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc5_:String = param1[_loc3_++];
         var _loc2_:int = int(param1[_loc3_++]);
         var _loc4_:QuestActor = _questActors[_loc5_];
         if(_loc4_ != null)
         {
            _loc4_.handlePhantomZap(_loc2_);
         }
      }
      
      public static function handlePlantAte(param1:String, param2:String) : void
      {
         var _loc4_:QuestActor = _questActors[param1];
         var _loc3_:Object = _questActorDictionary[param1];
         if(_loc3_ != null)
         {
            _loc3_.plantEaten = true;
         }
         if(_loc4_ != null)
         {
            _loc4_.setPlantEats(_questActors[param2]);
         }
      }
      
      public static function handlePlantSeed(param1:Object) : void
      {
         var _loc10_:String = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc11_:AvatarWorldView = null;
         var _loc3_:int = 2;
         var _loc7_:Boolean = param1[_loc3_++] == "1";
         var _loc6_:String = param1[_loc3_++];
         if(_loc7_)
         {
            _loc10_ = param1[_loc3_++];
            _loc5_ = int(param1[_loc3_++]);
            _loc4_ = int(param1[_loc3_++]);
            _loc2_ = int(param1[_loc3_++]);
            _loc8_ = int(param1[_loc3_++]);
            _loc9_ = {};
            _loc9_.visible = true;
            _loc9_.requireClick = false;
            _loc9_.type = 21;
            _loc9_.defId = _loc5_;
            _loc9_.state = 0;
            _loc9_.actorName = _loc10_;
            initInitialActorStatus(_loc9_,null);
            _loc9_.actorPos = new Point(_loc4_,_loc2_);
            _loc11_ = AvatarManager.avatarViewList[_loc8_];
            if(_loc11_)
            {
               _loc9_.seedLaunchX = _loc11_.avatarPos.x;
               _loc9_.seedLaunchY = _loc11_.avatarPos.y;
            }
            _questActorDictionary[_loc10_] = _loc9_;
            initQuestActor(_loc9_.actorName,0,100,_loc9_,null,null);
         }
         if(_seedInventory && _loc6_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _seedInventory.removeLastDraggedSeed();
         }
      }
      
      public static function handleQuestPlayerDead(param1:Object) : void
      {
         var _loc3_:AvatarInfo = null;
         var _loc2_:String = null;
         var _loc7_:String = null;
         var _loc5_:String = null;
         var _loc4_:int = 2;
         var _loc6_:int = int(param1[_loc4_++]);
         var _loc8_:AvatarWorldView = AvatarManager.avatarViewList[_loc6_];
         if(_loc8_)
         {
            _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc8_.userName);
            if(_loc3_ != null)
            {
               _loc3_.isDead = true;
            }
            if((_loc8_.avatarData.enviroTypeFlag & 1 << 0) != 0 || _loc8_.avatarData.enviroTypeFlag & 1 << 2)
            {
               _loc8_.playAnim(22);
               _loc8_.holdAnimId = 22;
            }
            else
            {
               _loc8_.playAnim(40);
               _loc8_.holdAnimId = 40;
            }
            if(_loc8_ == AvatarManager.playerAvatarWorldView)
            {
               _loc2_ = uint(_loc8_.avatarPos.x).toString(16);
               _loc7_ = uint(_loc8_.avatarPos.y).toString(16);
               while(_loc2_.length < 8)
               {
                  _loc2_ = "0" + _loc2_;
               }
               while(_loc7_.length < 8)
               {
                  _loc7_ = "0" + _loc7_;
               }
               _loc5_ = gMainFrame.server.getCurrentRoomName().split(".")[1];
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#death/" + _loc5_ + "#null#x" + _loc2_ + _loc7_);
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
         var _loc4_:int = 2;
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc6_:int = int(param1[_loc4_++]);
         var _loc2_:int = int(param1[_loc4_++]);
         var _loc5_:String = param1[_loc4_++];
         var _loc7_:int = int(param1[_loc4_++]);
         var _loc8_:uint = uint(param1[_loc4_++]);
         var _loc9_:QuestActor = null;
         var _loc10_:AvatarWorldView = null;
         if(_loc7_ > 0)
         {
            _loc10_ = AvatarManager.avatarViewList[_loc7_];
            if(_loc10_ == null)
            {
               return;
            }
            _loc10_.faceAnim(_loc6_ - _loc10_.avatarPos.x,_loc2_ - _loc10_.avatarPos.y,false);
         }
         else
         {
            _loc9_ = _questActors[_loc5_];
         }
         swipeMelee(_loc3_,_loc8_,_loc6_,_loc2_,_loc9_,_loc10_);
      }
      
      public static function handleRDNE() : void
      {
         if(_questExitPending == false && _questActorDictionary != null)
         {
            commandExit(0,null);
            onExitRoom();
         }
      }
      
      public static function handleActorDeath(param1:Object) : void
      {
         var _loc12_:QuestActor = null;
         var _loc6_:String = null;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc11_:QuestActor = null;
         var _loc4_:int = 2;
         _loc6_ = param1[_loc4_++];
         var _loc3_:Object = _questActorDictionary[_loc6_];
         _loc12_ = _questActors[_loc6_];
         _loc9_ = int(param1[_loc4_++]);
         var _loc2_:Boolean = param1[_loc4_++] == "1";
         var _loc7_:int = int(param1[_loc4_++]);
         var _loc5_:int = int(param1[_loc4_++]);
         var _loc8_:String = param1[_loc4_++];
         if(_loc8_ != "")
         {
            _loc10_ = _questActorDictionary[_loc8_];
            if(_loc10_ != null)
            {
               _loc10_.actorPos = new Point(_loc7_,_loc5_);
            }
            _loc11_ = _questActors[_loc8_];
            if(_loc11_ != null)
            {
               _loc11_.x = _loc7_;
               _loc11_.y = _loc5_;
               _loc11_.handlePositionUpdate(_loc7_,_loc5_,0,0,0,0);
            }
         }
         if(_loc3_ != null)
         {
            _loc3_.healthPercent = 0;
         }
         if(_loc12_ != null)
         {
            if(_loc2_)
            {
               _loc12_.x = _loc7_;
               _loc12_.y = _loc5_;
               _loc12_.handlePositionUpdate(_loc7_,_loc5_,0,0,0,0);
            }
            if(_loc12_.handleDeath(_loc9_))
            {
               _loc12_.destroy();
               delete _questActors[_loc6_];
            }
         }
      }
      
      public static function onQuestExit(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(10683),true,onLeaveQuestConfirm);
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
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1.status)
         {
            _loc3_ = 0;
            _loc2_ = 0;
            QuestXtCommManager.sendQuestPlayerRequestRespawn(0,_nearestRespawnPoint != null ? _nearestRespawnPoint.pos.x : AvatarManager.playerAvatarWorldView.x,_nearestRespawnPoint != null ? _nearestRespawnPoint.pos.y : AvatarManager.playerAvatarWorldView.y);
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
            loadQuestSfx(1970,onGlobalSfxLoaded);
         }
      }
      
      private static function onTimerLoaded(param1:MovieClip) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Number = NaN;
         if(_questActorDictionary != null)
         {
            _loc3_ = _questActorDictionary["gui_timer"];
            _loc2_ = _loc3_ != null ? _loc3_.state / 60 : 0;
            GuiManager.guiLayer.addChild(param1);
            param1.x = 400;
            param1.y = 50;
            _adventureTimer = param1;
            _adventureTimer.clock.clockText_1.text = _loc2_;
            _adventureTimer.clock.clockText_2.text = "00";
            _adventureTimer.time = _loc2_;
            if(_loc2_ == 0)
            {
               _adventureTimer.visible = false;
            }
         }
      }
      
      private static function onGuiGoalLoaded(param1:MovieClip) : void
      {
         var _loc6_:int = 0;
         var _loc2_:String = null;
         var _loc5_:Object = null;
         var _loc4_:String = null;
         var _loc3_:Object = null;
         if(_questActorDictionary != null)
         {
            _loc6_ = int(param1.passback.goalId);
            _loc2_ = "gui_goal" + _loc6_;
            _loc5_ = _questActorDictionary[_loc2_];
            _loc4_ = "gui_goal" + _loc6_ + "a";
            _loc3_ = _questActorDictionary[_loc4_];
            if(_loc5_ && _loc3_)
            {
               param1.setState(_loc6_);
               switch(getAdventureType() - 1)
               {
                  case 0:
                     param1.setQuestType(2);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 2:
                     param1.setQuestType(3);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 3:
                     param1.setQuestType(4);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 4:
                     param1.setQuestType(5);
                     param1.setValue(_loc3_.state + 1 - _playerCrystalCount);
                     param1.setMaxValue(_loc3_.state + 1);
                     break;
                  case 5:
                     param1.setQuestType(6);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 6:
                     param1.setQuestType(2);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  default:
                     param1.setValue(_loc5_.state);
                     param1.setMaxValue(_loc3_.state);
               }
               GuiManager.guiLayer.addChild(param1);
               param1.x = 20;
               param1.y = 25 + 50 * (_loc6_ - 1);
               if(_adventureGoals == null)
               {
                  _adventureGoals = [];
               }
               _adventureGoals[_loc6_] = param1;
            }
            else if(_questActorDictionary["showorbcount"] != null)
            {
               param1.setState(_loc6_);
               param1.setQuestType(7);
               param1.setValue(_playerCrystalCount);
               GuiManager.guiLayer.addChild(param1);
               param1.x = 20;
               param1.y = 25 + 50 * (_loc6_ - 1);
               if(_adventureGoals == null)
               {
                  _adventureGoals = [];
               }
               _adventureGoals[_loc6_] = param1;
            }
         }
      }
      
      public static function playerLaunchWeapon(param1:Point, param2:Boolean) : Number
      {
         var _loc4_:Object = null;
         var _loc5_:Number = 0;
         var _loc3_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
         if(_playerWeaponTimerProjectile <= 0 && _loc3_ != null && _loc3_.questHealthPercentage > 0)
         {
            _loc4_ = getPlayerActiveWeapon(param2);
            _playerWeaponTimerProjectile = 0.5;
            if(param2)
            {
               _loc5_ = launchProjectile(_loc4_.itemDefId,_loc4_.color,param1.x,param1.y,null,AvatarManager.playerAvatarWorldView);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["dm","attack with weapon, ranged"]);
               }
            }
            else
            {
               _loc5_ = swipeMelee(_loc4_.itemDefId,_loc4_.color,param1.x,param1.y,null,AvatarManager.playerAvatarWorldView);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["dm","attack with weapon, melee"]);
               }
            }
         }
         return _loc5_;
      }
      
      public static function launchProjectile(param1:int, param2:uint, param3:Number, param4:Number, param5:QuestActor, param6:AvatarView) : Number
      {
         var _loc7_:QuestProjectile = null;
         var _loc8_:Boolean = false;
         var _loc9_:Number = 0;
         if(param1 != 0)
         {
            _loc7_ = null;
            if(_loc7_ == null)
            {
               _loc7_ = new QuestProjectile();
               _loc8_ = _loc7_.launch(param1,param2,_layerManager.room_chat,param3,param4,param5,param6);
            }
            else
            {
               _loc8_ = _loc7_.relaunch(param1,param2,_layerManager.room_chat,param3,param4,param5,param6);
            }
            if(_loc8_)
            {
               _loc9_ = _loc7_.angle;
               _questProjectiles.push(_loc7_);
            }
         }
         return _loc9_;
      }
      
      public static function swipeMelee(param1:int, param2:uint, param3:Number, param4:Number, param5:QuestActor, param6:AvatarView) : Number
      {
         var _loc7_:QuestMelee = null;
         var _loc8_:Number = 0;
         if(param1 != 0)
         {
            _loc7_ = new QuestMelee(_currentMeleeID++);
            if(_loc7_.swipe(param1,param2,_layerManager.room_chat,param3,param4,param5,param6))
            {
               _loc8_ = _loc7_.angle;
               _questMelees.push(_loc7_);
            }
         }
         return _loc8_;
      }
      
      public static function getPlayerActiveWeapon(param1:Boolean) : Object
      {
         var _loc4_:Array = null;
         var _loc7_:int = 0;
         var _loc2_:Item = null;
         var _loc3_:Object = null;
         var _loc6_:Item = null;
         if(!isBeYourPetQuest())
         {
            _loc4_ = AvatarManager.playerAvatar.inventoryClothing.itemArray;
            _loc7_ = 0;
            while(_loc7_ < _loc4_.length)
            {
               _loc2_ = _loc4_[_loc7_];
               if(_loc2_.getInUse(AvatarManager.playerAvatar.perUserAvId) && _loc2_.attackMediaRefId != 0)
               {
                  if(param1 && _loc2_.combatType == 1 || param1 == false && _loc2_.combatType == 0)
                  {
                     if(_loc6_ == null || _loc6_.attack < _loc2_.attack)
                     {
                        _loc6_ = _loc2_;
                     }
                  }
               }
               _loc7_++;
            }
         }
         var _loc5_:Object = {};
         if(_loc6_ == null)
         {
            _loc5_.itemDefId = param1 ? 0 : 123;
            _loc3_ = ItemXtCommManager.getItemDef(_loc5_.itemDefId);
            if(_loc3_ != null)
            {
               _loc5_.color = _loc3_.colors[0];
            }
            else
            {
               _loc5_.color = 0;
            }
         }
         else
         {
            _loc5_.itemDefId = _loc6_.defId;
            _loc5_.color = _loc6_.color;
         }
         return _loc5_;
      }
      
      public static function handleQuestMiniGameComplete(param1:int) : void
      {
         if(_questCommandActorMiniGame != "" && _questCommandActorStateMiniGame != -1)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["dm","quest minigame complete, actor:" + _questCommandActorMiniGame + " actorState:" + _questCommandActorStateMiniGame + " gameResult:" + param1]);
            }
            QuestXtCommManager.questMiniGameComplete(_questCommandActorMiniGame,_questCommandActorStateMiniGame,param1);
            _questCommandActorMiniGame = null;
            _questCommandActorStateMiniGame = -1;
         }
      }
      
      public static function stopItemEmoticonSound(param1:AvatarWorldView) : void
      {
         var _loc3_:Object = null;
         var _loc2_:QuestPlayerData = null;
         for(_loc3_ in _questPlayersDict)
         {
            _loc2_ = _questPlayersDict[_loc3_];
            if(_loc2_ != null && _loc2_._avatarWorldView == param1)
            {
               _loc2_.stopItemEmoticonSound();
               break;
            }
         }
      }
      
      public static function playItemEmoticonSound(param1:AvatarWorldView, param2:String) : void
      {
         var _loc4_:* = null;
         for each(var _loc3_:QuestPlayerData in _questPlayersDict)
         {
            if(_loc3_ != null && _loc3_._avatarWorldView == param1)
            {
               _loc3_.playItemEmoticonSound(param2);
               break;
            }
         }
      }
      
      public static function onQuestPlayersBtn(param1:MouseEvent) : void
      {
         var _loc4_:MovieClip = null;
         var _loc3_:Object = null;
         var _loc5_:Array = null;
         if(param1 == null || !param1.currentTarget.isGray)
         {
            _loc4_ = GuiManager.mainHud.playersCont;
            if(param1 != null && _loc4_.visible)
            {
               _loc4_.visible = false;
               return;
            }
            _loc4_.visible = true;
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
            _loc5_ = [];
            for each(var _loc2_:Object in _loc3_)
            {
               if(_loc2_.userName != gMainFrame.userInfo.myUserName)
               {
                  _loc5_.push({
                     "isMember":_loc2_.isMember,
                     "nameBarData":_loc2_.nameBarData,
                     "userName":_loc2_.userName,
                     "avName":_loc2_.avName,
                     "isBuddy":BuddyManager.isBuddy(_loc2_.userName),
                     "isBlocked":BuddyManager.isBlocked(_loc2_.userName)
                  });
               }
            }
            if(_loc5_.length > 0)
            {
               while(_loc4_.itemWindow.numChildren > 0)
               {
                  _loc4_.itemWindow.removeChildAt(0);
               }
               _playersWindow = new WindowGenerator();
               _playersWindow.init(1,_loc5_.length,_loc5_.length,0,0,0,ItemWindowNameBar,null,"",{
                  "mouseDown":onSelectPlayer,
                  "mouseOver":null,
                  "mouseOut":null
               },_loc5_,onReportWindowsLoaded);
            }
            else
            {
               _loc4_.visible = false;
               GuiManager.mainHud.questPlayersBtn.downToUpState();
               GuiManager.mainHud.questPlayersBtn.activateGrayState(true);
            }
         }
      }
      
      private static function onReportWindowsLoaded() : void
      {
         var containerWindow:MovieClip;
         var maxHeight:int;
         var needsScrollbar:Boolean;
         var i:int = 0;
         while(i < _playersWindow.bg.numChildren)
         {
            ItemWindowNameBar(_playersWindow.bg.getChildAt(i)).updateToBeCentered(_playersWindow.width);
            i = i + 1;
         }
         containerWindow = GuiManager.mainHud.playersCont;
         containerWindow.itemWindow.addChild(_playersWindow);
         maxHeight = _playersWindow.boxHeight * 10;
         needsScrollbar = _playersWindow.height >= maxHeight;
         with(containerWindow)
         {
            m.height = Math.min(maxHeight,Math.round(_playersWindow.height));
            if(needsScrollbar)
            {
               m.width = t.width = b.width = _playersWindow.width + 2 + 31;
            }
            else
            {
               m.width = t.width = b.width = _playersWindow.width + 2;
            }
            m.y = b.y - m.height;
            t.y = m.y - t.height;
            x = Math.min(GuiManager.mainHud.questPlayersBtn.x - width * 0.5,MainFrame.VIEW_WIDTH - width - 10);
            if(needsScrollbar)
            {
               itemWindow.y = t.y + t.height + 20;
            }
            else
            {
               itemWindow.y = t.y + t.height + 10;
            }
            itemWindow.x = m.x + (m.width - _playersWindow.width) * 0.35;
            title.y = t.y + 5;
            title.x = m.width * 0.5 - title.width * 0.5;
         }
         if(_playersWindow.height >= maxHeight)
         {
            containerWindow.itemWindow.x -= 15;
            _playersWindowScrollBar = new SBScrollbar();
            _playersWindowScrollBar.init(_playersWindow,_playersWindow.width,maxHeight,-2,"scrollbar2",_playersWindow.boxHeight);
         }
      }
      
      public static function validatePlantSeedLocation(param1:Point) : Boolean
      {
         var _loc3_:* = null;
         var _loc2_:QuestActor = null;
         for each(_loc3_ in _questActors)
         {
            if(_loc3_._actorData.type == 22)
            {
               if(_loc3_.testPointInActorVolumes(param1))
               {
                  _loc2_ = getNearestPlant(param1.x,param1.y,75,999999);
                  if(_loc2_ != null)
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
            "onlineStatus":1
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
               _adventureSelectPopup.bx.addEventListener("mouseDown",onAdventureSelectClose,false,0,true);
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
         _adventureSelectPopup.x = 900 * 0.5;
         _adventureSelectPopup.y = 550 * 0.5;
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
      
      public static function privateAdventureJoinClose(param1:Boolean, param2:Boolean = true) : void
      {
         if(_privateAdventureJoin)
         {
            if(param1)
            {
               QuestXtCommManager.sendQuestJoinCancel();
            }
            if(param2)
            {
               UserCommXtCommManager.sendCustomAdventureMessage(false);
            }
            _privateAdventureJoin.destroy();
            _privateAdventureJoin = null;
         }
         GuiManager.setSwapBtnGray(false);
      }
      
      public static function getNearestActorPathInGroupToPlayerInRange(param1:QuestActor) : Boolean
      {
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc2_:QuestActor = null;
         var _loc5_:int = param1._actorId.lastIndexOf("__");
         if(_loc5_ != -1)
         {
            _loc6_ = param1._actorId.substring(0,_loc5_);
            _loc7_ = _questActorGroups[_loc6_];
            if(_loc7_ != null)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc7_.length)
               {
                  _loc4_ = _loc7_[_loc3_];
                  _loc2_ = _questActors[_loc4_];
                  if(_loc2_ != null)
                  {
                     if(_loc2_.pathToPlayerInRange())
                     {
                        return true;
                     }
                  }
                  _loc3_++;
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
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         if(_layerManager != null)
         {
            _loc2_ = _layerManager.bkg;
            _loc1_ = 16;
            _loc2_.x = _loc2_.x + Math.random() * _loc1_ - _loc1_ / 2;
            _loc2_.y = _loc2_.y + Math.random() * _loc1_ - _loc1_ / 2;
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
         var _loc4_:String = null;
         var _loc3_:Object = null;
         var _loc2_:Boolean = true;
         if(_questActorDictionary != null)
         {
            _loc4_ = "_" + param1;
            _loc3_ = _questActorDictionary[_loc4_];
            if(_loc3_.state != 1)
            {
               _loc2_ = false;
            }
         }
         return _loc2_;
      }
      
      public static function onShopClose() : void
      {
         updateCombinedCurrency();
         if(_questActorDictionary != null && _questActorDictionary["gui_34"] != null)
         {
            QuestXtCommManager.questActorTriggered("gui_34");
         }
      }
      
      public static function avatarEditorInitComplete() : void
      {
         var _loc2_:int = 0;
         var _loc4_:AvatarEditor = null;
         var _loc1_:Object = null;
         var _loc3_:Object = null;
         if(_questActorDictionary != null && _questActorDictionary["gui_aved"] != null)
         {
            _loc4_ = GuiManager.avatarEditor;
            if(_loc4_ != null)
            {
               _loc2_ = 0;
               while(_loc2_ < _guiElementsAvatarEditor.length)
               {
                  _loc1_ = _loc4_.avEditor[_guiElementsAvatarEditor[_loc2_ + 1]];
                  if(_loc1_ == null)
                  {
                     _loc1_ = _loc4_[_guiElementsAvatarEditor[_loc2_ + 1]];
                  }
                  if(_loc1_)
                  {
                     _loc3_ = _questActorDictionary[_guiElementsAvatarEditor[_loc2_]];
                     if(_loc3_.state >= 0 && _loc3_.state <= 2)
                     {
                        if(_loc1_.hasOwnProperty("setButtonState"))
                        {
                           _loc1_.setButtonState(_loc3_.state);
                        }
                        _loc1_.addEventListener("mouseDown",avEdDownHandler,false,0,true);
                        if(_loc1_.name != _guiElementsAvatarEditor[_loc2_ + 1])
                        {
                           _loc1_.name = _guiElementsAvatarEditor[_loc2_ + 1];
                        }
                     }
                  }
                  _loc2_ += 2;
               }
            }
            QuestXtCommManager.questActorTriggered("gui_aved");
         }
      }
      
      public static function phantomAttackDestructible(param1:String, param2:int, param3:int, param4:int) : void
      {
         var _loc10_:Point = null;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc7_:int = 0;
         var _loc5_:int = getTimer();
         for each(var _loc6_:QuestActor in _questActors)
         {
            if(_loc6_._visible && !_loc6_.isDead && _loc6_._actorData.type == 23)
            {
               if(_loc6_._actorData.damageDelay + 2000 < _loc5_)
               {
                  _loc10_ = _loc6_.actorOffset;
                  _loc9_ = param2 - (_loc6_.x + _loc10_.x);
                  _loc8_ = param3 - (_loc6_.y + _loc10_.y);
                  _loc11_ = _loc9_ * _loc9_ + _loc8_ * _loc8_;
                  _loc7_ = (param4 + param4) * (param4 + param4);
                  if(_loc11_ < _loc7_)
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
            if(isDynamicallyJoinableQuest())
            {
               if(GuiManager.mainHud.questPlayersBtn != null)
               {
                  GuiManager.mainHud.questPlayersBtn.activateGrayState(false);
                  if(GuiManager.mainHud.playersCont.visible)
                  {
                     onQuestPlayersBtn(null);
                  }
               }
            }
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
      
      public static function questPhantomZap(param1:String, param2:int, param3:int, param4:int, param5:QuestActor) : void
      {
         if(param5 != null && param5.isRunawayFromPlayer())
         {
            questActorAttacked(param5._actorId,-1,0,0,param5);
         }
         else
         {
            QuestXtCommManager.questPhantomZap(param1,param2,param3,param4);
         }
      }
      
      public static function questActorAttacked(param1:String, param2:int, param3:int, param4:int, param5:QuestActor) : void
      {
         if(param1 == "" && param5 != null && param5.isRunawayFromPlayer())
         {
            QuestXtCommManager.questActorAttacked(param5._actorId,-1,0,0);
         }
         else
         {
            QuestXtCommManager.questActorAttacked(param1,param2,param3,param4);
         }
      }
      
      public static function getAdventureType() : int
      {
         var _loc1_:Object = _questActorDictionary["advtype1"];
         if(_loc1_ != null)
         {
            return 1;
         }
         _loc1_ = _questActorDictionary["advtype2"];
         if(_loc1_ != null)
         {
            return 2;
         }
         _loc1_ = _questActorDictionary["advtype3"];
         if(_loc1_ != null)
         {
            return 3;
         }
         _loc1_ = _questActorDictionary["advtype4"];
         if(_loc1_ != null)
         {
            return 4;
         }
         _loc1_ = _questActorDictionary["advtype5"];
         if(_loc1_ != null)
         {
            return 5;
         }
         _loc1_ = _questActorDictionary["advtype6"];
         if(_loc1_ != null)
         {
            return 6;
         }
         _loc1_ = _questActorDictionary["advtype7"];
         if(_loc1_ != null)
         {
            return 7;
         }
         return 0;
      }
      
      public static function livePlayerCount() : int
      {
         var _loc1_:Object = _questActorDictionary["live_players"];
         return _loc1_ == null ? 1 : _loc1_.state;
      }
      
      public static function getPlayerCrystalCount() : int
      {
         if(_questActorDictionary != null)
         {
            return _playerCrystalCount;
         }
         return 0;
      }
   }
}

