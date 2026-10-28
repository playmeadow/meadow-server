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
      
      private static var _playerOrbCount:int;
      
      private static var _playerOrbCountTotal:int;
      
      private static var _gameIdleTimer:Number;
      
      private static var _kickPopup:SBOkPopup;
      
      private static var _adventureRewardsPopup:MovieClip;
      
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
      
      public static var _questActorToolSortedActorNames:Array;
      
      public static var _questActorToolScrollbar:SBScrollbar;
      
      public static var _questActorToolItemWindow:WindowGenerator;
      
      public static var _questActorToolScrollIndex:int;
      
      public static var _questActorToolEnabled:Boolean;
      
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
      
      private static var _addTorchQueue:Array = [];
      
      private static const torch:Class = QuestManager_torch;
      
      private static var _actorLightQueue:Array = [];
      
      private static var _fallingPhantoms:Array = [];
      
      private static var _guiElementsAvatarEditor:Array = ["gui_21","tradeBtnDown","gui_22","nonmember","gui_23","colorsTabDnBtn","gui_24","eyesTabDnBtn","gui_25","patternTabDnBtn","gui_26","bx","gui_27","sortBtn","gui_28","recycleClothesBtn","gui_29","shopBtn","gui_30","petsBtn","gui_31","colorsTabUp","gui_32","eyesTabUp","gui_33","patternTabUp"];
      
      private static var _guiElementsGuiManager:Array = ["gui_1","eCardBtn","gui_2","buddyListBtn","gui_3","newsBtn","gui_4","awardsBtn","gui_5","book","gui_6","partyBtn","gui_7","gemsBtn","gui_8","mySettingsBtn","gui_9","reportBtn","gui_10","charWindow","gui_11","swapBtn","gui_12","actionsBtn","gui_13","emotesBtn","gui_14","safeChatBtn","gui_15","chatHistUpDownBtn","gui_16","sendChatBtn","gui_17","denBtn","gui_18","soundBtn","gui_19","worldMapBtn","gui_35","zoneName","gui_36","ansChatBtn","gui_37","chatRepeatBtn"];
      
      private static var _guiElementsShop:Array = ["gui_34","reserved for close button callback"];
      
      public function QuestManager()
      {
         super();
      }
      
      public static function get hasJustJoinedQuest() : Boolean
      {
         return _hasJustJoinedQuest;
      }
      
      public static function set hasJustJoinedQuest(b:Boolean) : void
      {
         _hasJustJoinedQuest = b;
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
      
      public static function getQuestPlayerData(userId:int) : QuestPlayerData
      {
         if(_questPlayersDict[userId] == null && AvatarManager.avatarViewList[userId] != null)
         {
            _questPlayersDict[userId] = new QuestPlayerData();
            _questPlayersDict[userId].init(userId);
         }
         return _questPlayersDict[userId];
      }
      
      public static function initInitialActorStatus(inActorData:Object, inSpawningActorName:String) : void
      {
         inActorData.pendingSwfStateName = "";
         inActorData.spawnedFromActor = inSpawningActorName;
         inActorData.progress = 0;
         inActorData.seekType = 0;
         inActorData.seekTypeSfsId = 0;
         inActorData.torchEnabled = false;
         inActorData.iconShowing = false;
         switch(inActorData.type)
         {
            case QuestActor.QUEST_ACTOR_TYPE_DROPPED_TREASURE:
               inActorData.pickedUp = false;
            case QuestActor.QUEST_ACTOR_TYPE_PLACED_TREASURE:
               inActorData.status = 0;
               break;
            case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
            case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
            case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
            case QuestActor.QUEST_ACTOR_TYPE_PLANT:
               inActorData.damageDelay = 0;
               inActorData.healthPercent = 100;
               inActorData.respawned = false;
         }
      }
      
      public static function loadQuestSfx(mediaId:int, callback:Function = null) : void
      {
         if(mediaId == 2604 || mediaId == 2608)
         {
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_FRE)
            {
               if(mediaId == 2604)
               {
                  mediaId = 2698;
               }
               if(mediaId == 2608)
               {
                  mediaId = 2699;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
            {
               if(mediaId == 2604)
               {
                  mediaId = 2730;
               }
               if(mediaId == 2608)
               {
                  mediaId = 2731;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_DE)
            {
               if(mediaId == 2604)
               {
                  mediaId = 2755;
               }
               if(mediaId == 2608)
               {
                  mediaId = 2756;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
            {
               if(mediaId == 2604)
               {
                  mediaId = 2910;
               }
               if(mediaId == 2608)
               {
                  mediaId = 2911;
               }
            }
         }
         var mh:MediaHelper = new MediaHelper();
         mh.init(mediaId,callback != null ? callback : onSfxLoaded,true);
      }
      
      private static function onGlobalSfxLoaded(sfxMC:MovieClip) : void
      {
         _globalPackLoaded = true;
         onSfxLoaded(sfxMC);
         if(Boolean(_soundPacksToLoad))
         {
            while(Boolean(_soundPacksToLoad.length))
            {
               onSfxLoaded(_soundPacksToLoad.pop());
            }
         }
      }
      
      private static function onSfxLoaded(sfxMC:MovieClip) : void
      {
         var tempClass:Class = null;
         var libraryAssetNames:Array = null;
         var i:int = 0;
         var sfxClassName:String = null;
         var classLower:String = null;
         if(_globalPackLoaded)
         {
            libraryAssetNames = getDefinitionNames(sfxMC.loaderInfo,false,true);
            if(sfxMC.hasOwnProperty("initVolumes"))
            {
               sfxMC.initVolumes();
               _soundMan.setVolumes(sfxMC.volumes);
            }
            for(i = 0; i < libraryAssetNames.length - 1; i++)
            {
               sfxClassName = libraryAssetNames[i];
               classLower = sfxClassName.toLowerCase();
               if(Boolean(sfxClassName) && sfxClassName != "")
               {
                  tempClass = sfxMC.loaderInfo.applicationDomain.getDefinition(sfxClassName) as Class;
                  _soundMan.addSound(tempClass,-1,sfxClassName);
                  if(_sounds[classLower] == null)
                  {
                     _sounds[classLower] = tempClass;
                  }
               }
            }
            sfxMC.mediaHelper.destroy();
            delete sfxMC.mediaHelper;
            delete sfxMC.passback;
         }
         else
         {
            if(_soundPacksToLoad == null)
            {
               _soundPacksToLoad = new Array();
            }
            _soundPacksToLoad.push(sfxMC);
         }
      }
      
      public static function playMusic(name:String, caller:DisplayObject = null) : void
      {
         var loops:int = 0;
         var start:int = 0;
         var o:Object = null;
         if(Boolean(_currentMusic))
         {
            if(_currentMusic != name)
            {
               if(_currentMusic != "0")
               {
                  if(Boolean(_SFX_Music[_currentMusic]))
                  {
                     _soundMan.fadeOut(_SFX_Music[_currentMusic]);
                     if(name != "0")
                     {
                        _playMusicOnLoad = true;
                     }
                  }
               }
               else
               {
                  loops = 9999;
                  if(name == "ajq_phntmprisoner")
                  {
                     loops = 0;
                  }
                  if(_SFX_Music[name] == null)
                  {
                     o = _streamsLUT[name];
                     _SFX_Music[name] = _soundMan.addStream(o.name,o.vol);
                  }
                  start = 0;
                  _soundMan.playStream(_SFX_Music[name],start,loops,true);
               }
            }
         }
         else
         {
            _playMusicOnLoad = true;
         }
         _currentMusic = name;
      }
      
      public static function playSound(name:String, caller:DisplayObject = null, isVO:Boolean = false) : void
      {
         var o:Object = null;
         var prevTime:int = 0;
         var nameLC:String = name.toLowerCase();
         if(caller == null && Boolean(_streamsLUT[nameLC]))
         {
            if(_SFX_Music[nameLC] == null)
            {
               o = _streamsLUT[nameLC];
               _SFX_Music[nameLC] = _soundMan.addStream(o.name,o.vol);
            }
            _soundMan.playStream(_SFX_Music[nameLC]);
         }
         else if(caller == null || isOnscreen(caller))
         {
            prevTime = _sfxTimer[nameLC] == null ? -1 : int(_sfxTimer[nameLC]);
            if(prevTime < 0 || getTimer() - prevTime > 500)
            {
               if(isVO)
               {
                  if(Boolean(_currentVOSC))
                  {
                     _currentVOSC.stop();
                  }
                  _currentVOSC = _soundMan.play(_sounds[nameLC]);
               }
               else
               {
                  _soundMan.play(_sounds[nameLC]);
               }
               _sfxTimer[nameLC] = _lastTime;
            }
         }
      }
      
      public static function playLoopingSound(name:String) : SoundChannel
      {
         return _soundMan.play(_sounds[name],0,99999);
      }
      
      public static function stopLoopingSound(sc:SoundChannel) : void
      {
         _soundMan.stop(sc);
      }
      
      public static function getAvailableScriptDefs(loadedCallback:Function) : Array
      {
         if(_availableScriptDefs == null)
         {
            GenericListXtCommManager.requestGenericList(ADVENTURE_SCRIPTS_ID,onAvailableScriptsLoaded,loadedCallback);
            return null;
         }
         return _availableScriptDefs;
      }
      
      private static function onAvailableScriptsLoaded(glId:int, scriptItems:Array, passback:Object) : void
      {
         _availableScriptDefs = scriptItems;
         if(passback != null)
         {
            passback();
         }
      }
      
      private static function getStageX(obj:DisplayObject) : Number
      {
         var returnX:Number = obj.x;
         var tempObj:Object = obj;
         while(Boolean(tempObj.parent))
         {
            tempObj = tempObj.parent;
            returnX += tempObj.x;
         }
         return returnX;
      }
      
      private static function isOnscreen(caller:DisplayObject) : Boolean
      {
         if(caller.parent == GuiManager.guiLayer)
         {
            return true;
         }
         var obj1X:Number = caller.x;
         var obj1Y:Number = caller.y;
         var obj:Object = caller;
         while(obj.parent != null && obj.parent != _layerManager.bkg)
         {
            obj = obj.parent;
            obj1X += obj.x;
            obj1Y += obj.y;
         }
         obj = AvatarManager.playerAvatarWorldView;
         if(obj == null)
         {
            return false;
         }
         var obj2X:Number = Number(obj.x);
         var obj2Y:Number = Number(obj.y);
         while(obj.parent != null && obj.parent != _layerManager.bkg)
         {
            obj = obj.parent;
            obj2X += obj.x;
            obj2Y += obj.y;
         }
         obj1X -= obj2X;
         obj1Y -= obj2Y;
         return obj1X * obj1X + obj1Y * obj1Y < 810000;
      }
      
      public static function setSoundLevel(sc:SoundChannel, percentage:Number, obj:DisplayObject) : void
      {
         var sndTransformTemp:SoundTransform = null;
         var stageX:Number = NaN;
         if(sc != null)
         {
            if(_maxVolumes[sc] == null)
            {
               _maxVolumes[sc] = sc.soundTransform.volume;
            }
            sndTransformTemp = sc.soundTransform;
            sndTransformTemp.volume = _maxVolumes[sc] * percentage;
            stageX = getStageX(obj);
            sndTransformTemp.pan = Math.min(Math.max(stageX / 450 - 1,-1),1);
            sc.soundTransform = sndTransformTemp;
         }
      }
      
      public static function init(inLayerManager:LayerManager) : void
      {
         _fallingPhantomTimer = 0;
         _lastTime = 0;
         _paused = true;
         _questExitPending = false;
         _currentMeleeID = 1;
         _layerManager = inLayerManager;
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
         _streamsLUT["ajq_muscornmaze"] = {
            "name":"ajq_musCornMaze",
            "vol":0.5
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
      
      private static function onQuestEvent(evt:QuestEvent) : void
      {
         var sfxMediaId:int = 0;
         if(_questActorDictionary != null)
         {
            switch(evt.type)
            {
               case QuestEvent.LOAD_SFX:
                  sfxMediaId = int(evt.secondaryType);
                  if(sfxMediaId > 0)
                  {
                     loadQuestSfx(int(evt.secondaryType));
                  }
                  break;
               case QuestEvent.PLAY_SFX:
                  playSound(evt.secondaryType,evt.target as DisplayObject);
                  break;
               case QuestEvent.TORCH:
                  if(evt.secondaryType == "on")
                  {
                     addTorch(evt.target);
                  }
                  else
                  {
                     removeTorch(evt.target);
                  }
                  break;
               case QuestEvent.TRIGGER_CAMERASHAKE:
                  _shaketimer = 0.5;
            }
         }
      }
      
      public static function actorCollisionTest(actorID:String, playerOnly:Boolean = false) : Boolean
      {
         var otherActor:QuestActor = null;
         var thisCollisionPoint:Point = null;
         var otherCollisionPoint:Point = null;
         var thisActor:QuestActor = _questActors[actorID];
         if(Boolean(thisActor))
         {
            thisCollisionPoint = thisActor.actorOffset;
            thisCollisionPoint.x += thisActor.x;
            thisCollisionPoint.y += thisActor.y;
            otherCollisionPoint = new Point(AvatarManager.playerAvatarWorldView.x + QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.playerAvatarWorldView.y + QUEST_PLAYER_AVATAR_OFFSETY);
            if(Collision.circleHitCircle(thisCollisionPoint,thisActor.collisionRadiusMoving,otherCollisionPoint,QUEST_PLAYER_AVATAR_RADIUS))
            {
               return true;
            }
            if(playerOnly)
            {
               return false;
            }
            for each(otherActor in _questActors)
            {
               if(!otherActor.isDead && !otherActor.isDying && otherActor.priority > thisActor.priority && otherActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER)
               {
                  otherCollisionPoint = otherActor.actorOffset;
                  otherCollisionPoint.x += otherActor.x;
                  otherCollisionPoint.y += otherActor.y;
                  if(Collision.circleHitCircle(thisCollisionPoint,thisActor.collisionRadiusMoving,otherCollisionPoint,otherActor.collisionRadiusMoving))
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      public static function mouseHandleDown(evt:MouseEvent) : Boolean
      {
         var questActor:Object = null;
         var worldAim:Point = RoomManagerWorld.instance.convertScreenToWorldSpace(evt.stageX,evt.stageY);
         if(projectileKeyDown)
         {
            playerLaunchWeapon(worldAim,true);
            if(Boolean(AvatarManager.playerAvatarWorldView) && AvatarManager.playerAvatarWorldView.moving)
            {
               RoomManagerWorld.instance.forceStopMovement();
            }
            AvatarManager.playerAvatarWorldView.faceAnim(worldAim.x - AvatarManager.playerAvatarWorldView.avatarPos.x,worldAim.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
            return true;
         }
         for each(questActor in _questActors)
         {
            if(Boolean(questActor.handleMouseDown(worldAim)))
            {
               AvatarManager.playerAvatarWorldView.faceAnim(worldAim.x - AvatarManager.playerAvatarWorldView.avatarPos.x,worldAim.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
               return true;
            }
         }
         return false;
      }
      
      private static function keyHandleUp(event:KeyboardEvent) : void
      {
         switch(event.keyCode)
         {
            case Keyboard.SHIFT:
               _projectileKeyDown = false;
         }
      }
      
      private static function keyHandleDown(event:KeyboardEvent) : void
      {
         var playerWorldView:AvatarWorldView = null;
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
         switch(event.keyCode)
         {
            case Keyboard.SHIFT:
         }
         switch(event.keyCode)
         {
            case Keyboard.NUMPAD_4:
               playerWorldView = AvatarManager.playerAvatarWorldView;
               if(Boolean(playerWorldView))
               {
                  addTorch(playerWorldView,-15,-50);
               }
               break;
            case Keyboard.F7:
               invokeQuestActorTool();
         }
      }
      
      public static function muteChanged(muted:Boolean) : void
      {
         var questActor:Object = null;
         for each(questActor in _questActors)
         {
            if(Boolean(questActor.alertLP))
            {
               stopLoopingSound(questActor.alertLP);
               questActor.alertLP = null;
            }
         }
      }
      
      public static function onExitRoom() : void
      {
         var i:int = 0;
         var key:Object = null;
         var ai:AvatarInfo = null;
         var guiIndex:int = 0;
         var avEd:AvatarEditor = null;
         var currLeftObj:Object = null;
         var goalIndex:int = 0;
         if(_questExitPending)
         {
            ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(Boolean(ai))
            {
               ai.questTorchStatus = false;
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
            if(Boolean(_guiElementsSkipBtnMh))
            {
               _guiElementsSkipBtnMh.destroy();
               _guiElementsSkipBtnMh = null;
            }
            if(Boolean(_guiElementsSkipBtn))
            {
               _guiElementsSkipBtn.removeEventListener(MouseEvent.MOUSE_DOWN,guiElementsSkipBtnPress);
               if(Boolean(_guiElementsSkipBtn.parent))
               {
                  _guiElementsSkipBtn.parent.removeChild(_guiElementsSkipBtn);
               }
               _guiElementsSkipBtn.visible = false;
               _guiElementsSkipBtn = null;
            }
            for(guiIndex = 0; guiIndex < _guiElementsGuiManager.length; guiIndex += 2)
            {
               if(Boolean(GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]]))
               {
                  if(Boolean(GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].hasOwnProperty("setButtonState")))
                  {
                     GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].setButtonState(1);
                  }
                  GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].removeEventListener(MouseEvent.MOUSE_DOWN,guiDownHandler);
                  GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].removeEventListener(MouseEvent.MOUSE_OVER,guiDownHandler);
               }
            }
            GuiManager.grayHudAvatar(false);
            avEd = GuiManager.avatarEditor;
            if(avEd != null)
            {
               for(guiIndex = 0; guiIndex < _guiElementsAvatarEditor.length; guiIndex += 2)
               {
                  if(Boolean(avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]]))
                  {
                     if(Boolean(avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]].hasOwnProperty("setButtonState")))
                     {
                        avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]].setButtonState(1);
                     }
                     avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]].removeEventListener(MouseEvent.MOUSE_DOWN,avEdDownHandler);
                  }
               }
            }
            _questPlayersSwitched = null;
            _questScriptDefId = 0;
            AvatarManager.setPlayerAttachmentEmot(0,null,0,false);
            _questExitPending = false;
            gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId).questHealthPercentage = 100;
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = 1;
            _questActorDictionary = null;
            gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,resetMouseDownIdleTimer);
            gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_MOVE,resetMouseMoveIdleTimer);
            if(_kickPopup != null)
            {
               _kickPopup.destroy();
               _kickPopup = null;
            }
            if(Boolean(_progressingSC))
            {
               _progressingSC.stop();
            }
            if(Boolean(_progressingSCnot))
            {
               _progressingSCnot.stop();
            }
            for(key in _assetPool)
            {
               delete _assetPool[key];
            }
            for(i = 0; i < _playerLeftObjects.length; i++)
            {
               currLeftObj = _playerLeftObjects[i];
               if(Boolean(currLeftObj) && Boolean(currLeftObj.icon.parent) && currLeftObj.icon.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(currLeftObj.icon);
               }
               currLeftObj.hasLeft = false;
               currLeftObj.complete = false;
            }
            _questActorToolSortedActorNames = null;
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
            _playMusicOnLoad = false;
            if(Boolean(_seedInventory))
            {
               _seedInventory.destroy();
               _seedInventory = null;
            }
            RoomManagerWorld.instance.removeAndClearMiniMap();
            if(Boolean(_fader))
            {
               if(Boolean(_fader.parent))
               {
                  _fader.parent.removeChild(_fader);
               }
               _fader = null;
            }
            _queueFadeIn = false;
         }
         _soundMan.destroy();
         if(Boolean(_adventureTimer) && Boolean(_adventureTimer.parent))
         {
            _adventureTimer.parent.removeChild(_adventureTimer);
            _adventureTimer = null;
         }
         if(Boolean(_adventureGoals))
         {
            for(goalIndex = 1; goalIndex <= 5; goalIndex++)
            {
               if(Boolean(_adventureGoals[goalIndex]) && Boolean(_adventureGoals[goalIndex].parent))
               {
                  _adventureGoals[goalIndex].parent.removeChild(_adventureGoals[goalIndex]);
                  _adventureGoals[goalIndex] = null;
               }
            }
            _adventureGoals = null;
         }
         if(Boolean(_playSwfMCSC))
         {
            _playSwfMCSC.stop();
            _playSwfMCSC = null;
         }
         if(Boolean(_currentVOSC))
         {
            _currentVOSC.stop();
            _currentVOSC = null;
         }
         if(Boolean(_fader) && Boolean(_fader.parent))
         {
            _fader.parent.removeChild(_fader);
            _fader = null;
         }
         if(Boolean(_darknessMask))
         {
            removeDarkness();
         }
         for(i = 0; i < _questProjectiles.length; i++)
         {
            _questProjectiles[i].destroy();
         }
         _questProjectiles.splice(0,_questProjectiles.length);
         for(i = 0; i < _questMelees.length; i++)
         {
            _questMelees[i].destroy();
         }
         _questMelees.splice(0,_questMelees.length);
         for(key in _questActors)
         {
            _questActors[key].destroy();
            delete _questActors[key];
         }
         for(key in _questPlayersDict)
         {
            _questPlayersDict[key].destroy();
            delete _questPlayersDict[key];
         }
         if(_fallingPhantoms.length > 0)
         {
            for(i = 0; i < _fallingPhantoms.length; i++)
            {
               key = _fallingPhantoms[i];
               if(key != null)
               {
                  if(key.mh != null)
                  {
                     key.mh.destroy();
                     key.mh = null;
                  }
                  if(key.theSprite != null && key.theSprite.parent != null)
                  {
                     key.theSprite.parent.removeChild(key.theSprite);
                     key.theSprite = null;
                     key.npc = null;
                  }
               }
            }
            _fallingPhantoms.splice(0,_fallingPhantoms.length);
         }
         _fallingPhantomVolumeActors = null;
         if(Boolean(_talkingLoadingSpiral))
         {
            _talkingLoadingSpiral.destroy();
            _talkingLoadingSpiral = null;
         }
         _talkingPopup = null;
         _paused = true;
         _sceneLoaded = false;
      }
      
      public static function getNearestPlant(inPosX:Number, inPosY:Number, maxDistance:Number, maxLevel:int) : QuestActor
      {
         var questActor:QuestActor = null;
         var npcDef:Object = null;
         var collisionPt:Point = null;
         var xDiff:Number = NaN;
         var yDiff:Number = NaN;
         var dist:Number = NaN;
         var distanceSq:Number = -1;
         var nearestPlant:QuestActor = null;
         maxDistance *= maxDistance;
         for each(questActor in _questActors)
         {
            if(questActor._visible && questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT && questActor.plantTargettable())
            {
               npcDef = questActor.npcDef;
               if(npcDef != null && npcDef.level <= maxLevel)
               {
                  collisionPt = questActor.actorOffset;
                  xDiff = inPosX - (questActor._actorData.actorPos.x + collisionPt.x);
                  yDiff = inPosY - (questActor._actorData.actorPos.y + collisionPt.y);
                  dist = xDiff * xDiff + yDiff * yDiff;
                  if(dist < maxDistance && (distanceSq == -1 || dist < distanceSq))
                  {
                     nearestPlant = questActor;
                     distanceSq = dist;
                  }
               }
            }
         }
         return nearestPlant;
      }
      
      public static function getNearestActivePhantom(inPosX:Number, inPosY:Number, maxDistance:Number, maxLevel:int, bCheckAllPhantoms:Boolean, bIncludeFactoriesDestuctibles:Boolean, bCanDamage:Boolean) : Array
      {
         var nearestPhantoms:Array = null;
         var distanceSq:Number = NaN;
         var questActor:QuestActor = null;
         var npcDef:Object = null;
         var actorOffset:Point = null;
         var xDiff:Number = NaN;
         var yDiff:Number = NaN;
         var dist:Number = NaN;
         var nearestPhantom:QuestActor = null;
         maxDistance *= maxDistance;
         for each(questActor in _questActors)
         {
            if(questActor._visible && !questActor.isDead)
            {
               if(questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER && (bCheckAllPhantoms || questActor._seekActive != QuestActor.SEEKTYPE_OFF) || bIncludeFactoriesDestuctibles && (questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE || questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY))
               {
                  npcDef = questActor.npcDef;
                  if(questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE || questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY || npcDef != null && questActor.isVulnerable() && (npcDef.level <= maxLevel || bCanDamage))
                  {
                     actorOffset = questActor.actorOffset;
                     xDiff = inPosX - (questActor.x + actorOffset.x);
                     yDiff = inPosY - (questActor.y + actorOffset.y);
                     dist = xDiff * xDiff + yDiff * yDiff;
                     if(dist < maxDistance)
                     {
                        if(nearestPhantoms == null)
                        {
                           nearestPhantoms = new Array();
                           distanceSq = dist;
                           nearestPhantoms.push(questActor);
                        }
                        else if(dist < distanceSq)
                        {
                           distanceSq = dist;
                           nearestPhantoms.unshift(questActor);
                        }
                        else
                        {
                           nearestPhantoms.push(questActor);
                        }
                     }
                  }
               }
            }
         }
         return nearestPhantoms;
      }
      
      public static function createDarkness() : void
      {
         if(Boolean(_darknessMask))
         {
            throw new Error("Error creating darkness! Darkness is already created!");
         }
         _darknessMask = new Sprite();
         _darknessMask.blendMode = BlendMode.LAYER;
         _darknessMask.mouseEnabled = false;
         _darknessMask.mouseChildren = false;
         var spr:Sprite = new Sprite();
         spr.graphics.beginFill(0);
         spr.graphics.drawRect(0,0,900,550);
         spr.graphics.endFill();
         _darknessMask.addChild(spr);
         _layerManager.bkg.addChild(_darknessMask);
         _torchLUT = new Dictionary();
      }
      
      public static function removeDarkness() : void
      {
         if(Boolean(_darknessMask))
         {
            if(Boolean(_darknessMask.parent))
            {
               _darknessMask.parent.removeChild(_darknessMask);
            }
            _darknessMask = null;
            _torches = null;
            trace("removing darkness");
         }
      }
      
      public static function addTorch(actor:Object, scale:Number = 1, offsetX:int = 0, offsetY:int = 0) : MovieClip
      {
         var o:Object = null;
         var darknessCreated:Boolean = false;
         if(!_sceneLoaded)
         {
            _addTorchQueue.push({
               "actor":actor,
               "scale":scale,
               "offsetX":offsetX,
               "offsetY":offsetY
            });
            return null;
         }
         if(_darknessMask == null)
         {
            darknessCreated = createDarknessFromScene();
            if(!darknessCreated)
            {
               _actorLightQueue.push(actor);
               return null;
            }
            for each(o in _actorLightQueue)
            {
               addTorch(o);
            }
            _actorLightQueue = [];
         }
         if(Boolean(_torches))
         {
            for each(o in _torches)
            {
               if(o.actor == actor)
               {
                  if(o.actor == AvatarManager.playerAvatarWorldView)
                  {
                     o.light.scaleX = o.light.scaleY = scale;
                  }
                  return null;
               }
            }
         }
         else
         {
            _torches = new Array();
         }
         o = new Object();
         var swfTorch:Object = null;
         if(actor.hasOwnProperty("torch"))
         {
            swfTorch = actor.torch;
            if(actor.parent == _layerManager.room_chat)
            {
               o.layer = 1;
               swfTorch.x = 650;
               swfTorch.y = 470;
            }
            else
            {
               actor = actor.parent;
               o.layer = 1;
               swfTorch.x = 320;
               swfTorch.y = 180;
            }
         }
         else if(actor.hasOwnProperty("s") && Boolean(actor.s.content.hasOwnProperty("torch")))
         {
            swfTorch = actor.s.content.torch;
            o.layer = 0;
         }
         if(Boolean(swfTorch))
         {
            o.light = swfTorch;
            o.light.visible = true;
            o.offsetX = o.light.x;
            o.offsetY = o.light.y;
         }
         else
         {
            o.light = new torch();
            o.light.scaleX = o.light.scaleY = scale;
            o.offsetX = offsetX;
            o.offsetY = offsetY;
            o.layer = 1;
         }
         _darknessMask.addChild(o.light);
         o.light.blendMode = BlendMode.ERASE;
         o.actor = actor;
         _torchLUT[actor] = o;
         _torches.push(o);
         return o.light;
      }
      
      public static function createDarknessFromScene() : Boolean
      {
         var o:Shape = null;
         var fgLayer:Sprite = null;
         var childIndex:int = 0;
         var child:DisplayObject = null;
         if(!_sceneLoaded)
         {
            trace("das not good");
         }
         var darknessLayers:Array = RoomManagerWorld.instance.getDarknessFromScene();
         trace("adding darkness");
         if(darknessLayers.length > 0)
         {
            trace("found darkness");
            _darknessMask = new Sprite();
            _darknessMask.blendMode = BlendMode.LAYER;
            _darknessMask.mouseEnabled = false;
            _darknessMask.mouseChildren = false;
            for each(o in darknessLayers)
            {
               _darknessMask.addChild(o);
            }
            _darknessMask.x = _layerManager.room_avatars.x + _layerManager.room_bkg_group.x;
            _darknessMask.y = _layerManager.room_avatars.y + _layerManager.room_bkg_group.y;
            fgLayer = _layerManager.room_fg;
            if(fgLayer.numChildren > 0)
            {
               for(childIndex = fgLayer.numChildren - 1; childIndex >= 0; childIndex--)
               {
                  child = fgLayer.getChildAt(childIndex);
                  if(!child.hasOwnProperty("eye") && !child.hasOwnProperty("watcher"))
                  {
                     break;
                  }
               }
               fgLayer.addChildAt(_darknessMask,childIndex >= 0 ? childIndex : 0);
            }
            else
            {
               fgLayer.addChild(_darknessMask);
            }
            _torchLUT = new Dictionary();
         }
         return darknessLayers.length > 0;
      }
      
      public static function removeTorch(actor:Object) : void
      {
         var o:Object = null;
         var index:int = 0;
         if(_torches != null)
         {
            index = 0;
            for each(o in _torches)
            {
               if(o.actor == actor)
               {
                  if(actor == AvatarManager.playerAvatarWorldView)
                  {
                     o.light.scaleX = o.light.scaleY = QUEST_TORCH_UNLITSIZE;
                  }
                  else
                  {
                     o.light.parent.removeChild(o.light);
                     _torches.splice(index,1);
                  }
                  break;
               }
               index++;
            }
         }
      }
      
      public static function heartbeat() : void
      {
         var playerView:AvatarWorldView = null;
         var o:Object = null;
         var questActor:Object = null;
         var i:int = 0;
         var swfCurrentFrame:int = 0;
         var player:QuestPlayerData = null;
         var actorData:Object = null;
         var origseconds:int = 0;
         var seconds:int = 0;
         var minutes:int = 0;
         var min:int = 0;
         var sec:int = 0;
         var goalIndex:int = 0;
         var goalName:String = null;
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
               if(Boolean(_playSwfMC.bFinished))
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
                     swfCurrentFrame = _playSwfMCTimeElapsed * 24;
                     if(swfCurrentFrame >= _playSwfMC.totalFrames)
                     {
                        swfCurrentFrame = _playSwfMC.totalFrames;
                     }
                     _playSwfMC.gotoAndStop(swfCurrentFrame);
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
            playerView = AvatarManager.playerAvatarWorldView;
            if(_questActorDictionary != null)
            {
               if(Boolean(AvatarManager.playerAvatarWorldView))
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
               for each(player in _questPlayersDict)
               {
                  if(player != null)
                  {
                     player.heartbeat();
                  }
               }
               if(_guiTimerLocal > 0)
               {
                  origseconds = int(_guiTimerLocal) % 60;
                  _guiTimerLocal -= _frameTime;
                  seconds = int(_guiTimerLocal) % 60;
                  if(origseconds > seconds)
                  {
                     _soundMan.play(_sounds["aj_play_timer_tick1"]);
                  }
                  if(Boolean(_adventureTimer))
                  {
                     _adventureTimer.time = _guiTimerLocal;
                     minutes = int(_adventureTimer.time / 60);
                     seconds = int(_adventureTimer.time) % 60;
                     _adventureTimer.clock.clockText_1.text = minutes;
                     _adventureTimer.clock.clockText_2.text = (seconds >= 10 ? "" : "0") + seconds;
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
               actorData = _questActorDictionary["gui_timer"];
               if(actorData != null)
               {
                  if(Boolean(_adventureTimer))
                  {
                     _adventureTimer.time = actorData.state;
                     min = int(_adventureTimer.time / 60);
                     sec = int(_adventureTimer.time) % 60;
                     _adventureTimer.clock.clockText_1.text = min;
                     _adventureTimer.clock.clockText_2.text = (sec >= 10 ? "" : "0") + sec;
                     if(_adventureTimer.time < 60 && _adventureTimer.time + _frameTime > 60)
                     {
                        _adventureTimer.startPulse();
                     }
                  }
               }
               if(_adventureGoals != null)
               {
                  switch(getAdventureType())
                  {
                     case QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:
                        if(Boolean(_questActorDictionary["gui_goal1"]))
                        {
                           if(Boolean(_adventureGoals[1]))
                           {
                              _adventureGoals[1].setValue(_playerOrbCount);
                              for(goalIndex = 1; goalIndex <= 5; goalIndex++)
                              {
                                 goalName = "gui_goal" + goalIndex + "a";
                                 if(goalIndex == 5 || _questActorDictionary[goalName] != null && _questActorDictionary[goalName].state > _playerOrbCountTotal)
                                 {
                                    _adventureGoals[1].setMaxValue(_questActorDictionary[goalName].state);
                                    break;
                                 }
                              }
                           }
                        }
                        break;
                     default:
                        for(goalIndex = 1; goalIndex <= 5; goalIndex++)
                        {
                           goalName = "gui_goal" + goalIndex;
                           if(!Boolean(_questActorDictionary[goalName]))
                           {
                              break;
                           }
                           if(Boolean(_adventureGoals[goalIndex]))
                           {
                              _adventureGoals[goalIndex].setValue(_questActorDictionary[goalName].state);
                           }
                        }
                  }
               }
            }
            for each(o in _torches)
            {
               if(o.actor != null)
               {
                  o.light.x = o.actor.x + o.offsetX;
                  o.light.y = o.actor.y + o.offsetY;
                  if(o.layer == 0)
                  {
                     o.light.x -= _layerManager.room_avatars.x;
                     o.light.y -= _layerManager.room_avatars.y;
                  }
                  else
                  {
                     o.light.x -= o.light.width * 0.5;
                     o.light.y -= o.light.height * 0.5;
                  }
               }
            }
            if(Boolean(_darknessMask))
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
            for each(questActor in _questActors)
            {
               if(Boolean(questActor.isDead))
               {
                  questActor.destroy();
                  delete _questActors[questActor._actorId];
               }
               else
               {
                  questActor.heartbeat(_frameTime);
               }
            }
            for(i = _questProjectiles.length - 1; i >= 0; i--)
            {
               if(Boolean(_questProjectiles[i].heartbeat(_frameTime)))
               {
                  _questProjectiles[i].destroy();
                  _questProjectiles.splice(i,1);
               }
            }
            for(i = _questMelees.length - 1; i >= 0; i--)
            {
               if(Boolean(_questMelees[i].heartbeat(_frameTime)))
               {
                  _questMelees[i].destroy();
                  _questMelees.splice(i,1);
               }
            }
         }
      }
      
      private static function onFallingPhantomLoaded(img:MovieClip) : void
      {
         var fallingPhantom:Object = img.passback;
         fallingPhantom.mh.destroy();
         fallingPhantom.mh = null;
         fallingPhantom.npc = img;
         fallingPhantom.npc.x = 0;
         fallingPhantom.npc.y = 0;
         img.updateFallHeight(fallingPhantom.phantomStartY,0);
         img.setInit();
         img.appear();
         fallingPhantom.theSprite = new Sprite();
         fallingPhantom.theSprite.x = fallingPhantom.posX;
         fallingPhantom.theSprite.y = fallingPhantom.posY;
         fallingPhantom.theSprite.addChild(img);
         _layerManager.room_avatars.addChild(fallingPhantom.theSprite);
         if(isOnscreen(fallingPhantom.npc))
         {
            _soundMan.play(_sounds[Math.random() < 0.5 ? (Math.random() < 0.5 ? "ajq_phntmflame1" : "ajq_phntmflame2") : (Math.random() < 0.5 ? "ajq_phntmfall1" : "ajq_phntmfall2")]);
         }
      }
      
      public static function updateFallingPhantoms() : void
      {
         var fallingPhantom:Object = null;
         var fallingPhantomIndex:int = 0;
         var percentComplete:Number = NaN;
         var ai:AvatarInfo = null;
         var collisionPoint:Point = null;
         var toTargetX:Number = NaN;
         var toTargetY:Number = NaN;
         var targetRadius:Number = NaN;
         var posX:Number = NaN;
         var pointIntersect1:Point = null;
         var pointIntersect2:Point = null;
         var pointStart:Point = null;
         var pointEnd:Point = null;
         var iVol:int = 0;
         var iFallingPhantomVolumeActor:int = 0;
         var intersectVolume:Object = null;
         var fallingPhantomActor:QuestActor = null;
         var rateMin:Number = NaN;
         var rateMax:Number = NaN;
         var tempPoint1:Point = null;
         var tempPoint2:Point = null;
         var speedMin:Number = NaN;
         var speedMax:Number = NaN;
         var iMessageParam:int = 0;
         var messageParams:Array = null;
         var messageParam:Array = null;
         if(_fallingPhantoms.length > 0)
         {
            for(fallingPhantomIndex = _fallingPhantoms.length - 1; fallingPhantomIndex >= 0; fallingPhantomIndex--)
            {
               fallingPhantom = _fallingPhantoms[fallingPhantomIndex];
               if(fallingPhantom.npc != null)
               {
                  if(fallingPhantom.timerElapsed < fallingPhantom.timerMax)
                  {
                     fallingPhantom.timerElapsed += _frameTime;
                     if(fallingPhantom.timerElapsed > fallingPhantom.timerMax)
                     {
                        fallingPhantom.timerElapsed = fallingPhantom.timerMax;
                     }
                     percentComplete = fallingPhantom.timerElapsed / fallingPhantom.timerMax;
                     fallingPhantom.npc.updateFallHeight(fallingPhantom.phantomStartY * (1 - percentComplete),percentComplete);
                     if(percentComplete >= 1 && isOnscreen(fallingPhantom.npc))
                     {
                        _soundMan.play(_sounds[Math.random() < 0.5 ? "ajq_phntmfdeath1" : "ajq_phntmfdeath2"]);
                     }
                  }
                  if(Boolean(fallingPhantom.npc.attacking) && AvatarManager.playerAvatarWorldView != null)
                  {
                     ai = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                     if(ai.questHealthPercentage > 0)
                     {
                        collisionPoint = fallingPhantom.npc.getCollisionPoint(2);
                        toTargetX = AvatarManager.playerAvatarWorldView.x + QUEST_PLAYER_AVATAR_OFFSETX - (fallingPhantom.posX + collisionPoint.x);
                        toTargetY = AvatarManager.playerAvatarWorldView.y + QUEST_PLAYER_AVATAR_OFFSETY - (fallingPhantom.posY + collisionPoint.y);
                        targetRadius = Number(fallingPhantom.npc.getCollisionRadius(2));
                        QUEST_PLAYER_AVATAR_RADIUS;
                        if(toTargetX * toTargetX + toTargetY * toTargetY < targetRadius * targetRadius)
                        {
                           QuestXtCommManager.questPhantomZap("FallingPhantom",AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
                        }
                     }
                     fallingPhantom.npc.attacking = false;
                  }
                  if(fallingPhantom.timerElapsed >= fallingPhantom.timerMax && fallingPhantom.npc.animActive == false)
                  {
                     if(fallingPhantom.theSprite != null && fallingPhantom.theSprite.parent != null)
                     {
                        fallingPhantom.theSprite.parent.removeChild(fallingPhantom.theSprite);
                     }
                     _fallingPhantoms.splice(fallingPhantomIndex,1);
                  }
               }
            }
         }
         if(AvatarManager.playerAvatarWorldView != null)
         {
            _fallingPhantomTimer -= _frameTime;
            if(_fallingPhantomTimer <= 0)
            {
               posX = AvatarManager.playerAvatarWorldView.avatarPos.x - 500 + Math.random() * 1000;
               pointIntersect1 = null;
               pointIntersect2 = null;
               pointStart = new Point(posX,AvatarManager.playerAvatarWorldView.avatarPos.y - 300);
               pointEnd = new Point(posX,AvatarManager.playerAvatarWorldView.avatarPos.y + 300);
               intersectVolume = null;
               iFallingPhantomVolumeActor = 0;
               while(iFallingPhantomVolumeActor < _fallingPhantomVolumeActors.length && pointIntersect1 == null)
               {
                  fallingPhantomActor = _questActors[_fallingPhantomVolumeActors[iFallingPhantomVolumeActor]];
                  if(fallingPhantomActor != null && fallingPhantomActor._visible)
                  {
                     iVol = 0;
                     while(iVol < fallingPhantomActor._volumes.length && pointIntersect1 == null)
                     {
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(pointStart,fallingPhantomActor._volumes[iVol]))
                        {
                           pointIntersect1 = pointStart;
                        }
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(pointEnd,fallingPhantomActor._volumes[iVol]))
                        {
                           if(pointIntersect1 == null)
                           {
                              pointIntersect1 = pointEnd;
                           }
                           else
                           {
                              pointIntersect2 = pointEnd;
                           }
                        }
                        if(pointIntersect1 != null)
                        {
                           intersectVolume = fallingPhantomActor._volumes[iVol];
                        }
                        iVol++;
                     }
                  }
                  iFallingPhantomVolumeActor++;
               }
               if(pointIntersect2 == null)
               {
                  tempPoint1 = new Point();
                  tempPoint2 = new Point();
                  if(pointIntersect1 == null)
                  {
                     for(iFallingPhantomVolumeActor = 0; iFallingPhantomVolumeActor < _fallingPhantomVolumeActors.length; iFallingPhantomVolumeActor++)
                     {
                        fallingPhantomActor = _questActors[_fallingPhantomVolumeActors[iFallingPhantomVolumeActor]];
                        if(fallingPhantomActor != null && fallingPhantomActor._visible)
                        {
                           for(iVol = 0; iVol < fallingPhantomActor._volumes.length; iVol++)
                           {
                              if(checkFallingPhantomVolumeIntersect(fallingPhantomActor._volumes[iVol].v,pointStart,pointEnd,tempPoint1,tempPoint2))
                              {
                                 pointIntersect1 = tempPoint1;
                                 pointIntersect2 = tempPoint2;
                                 intersectVolume = fallingPhantomActor._volumes[iVol];
                                 break;
                              }
                           }
                        }
                     }
                  }
                  else if(checkFallingPhantomVolumeIntersect(intersectVolume.v,pointStart,pointEnd,tempPoint1,tempPoint2))
                  {
                     pointIntersect2 = tempPoint1;
                  }
               }
               rateMin = 0.1;
               rateMax = 0.4;
               if(pointIntersect2 != null)
               {
                  speedMin = 0.75;
                  speedMax = 1.75;
                  if(intersectVolume != null && intersectVolume.message.length > 0)
                  {
                     messageParams = intersectVolume.message.split(",");
                     for(iMessageParam = 0; iMessageParam < messageParams.length; iMessageParam++)
                     {
                        messageParam = messageParams[iMessageParam].split("=");
                        if(messageParam.length != 2)
                        {
                           continue;
                        }
                        switch(messageParam[0])
                        {
                           case "ratemin":
                              rateMin = messageParam[1] / 1000;
                              break;
                           case "ratemax":
                              rateMax = messageParam[1] / 1000;
                              break;
                           case "speedmin":
                              speedMin = messageParam[1] / 1000;
                              break;
                           case "speedmax":
                              speedMax = messageParam[1] / 1000;
                        }
                     }
                  }
                  fallingPhantom = new Object();
                  fallingPhantom.phantomStartY = -750;
                  fallingPhantom.timerMax = speedMin + Math.random() * (speedMax - speedMin);
                  fallingPhantom.timerElapsed = 0;
                  fallingPhantom.posX = posX;
                  fallingPhantom.posY = pointIntersect1.y + Math.random() * (pointIntersect2.y - pointIntersect1.y);
                  fallingPhantom.mh = new MediaHelper();
                  fallingPhantom.mh.init(getNPCDef(36).mediaRefId,onFallingPhantomLoaded,fallingPhantom);
                  _fallingPhantoms.push(fallingPhantom);
               }
               _fallingPhantomTimer = rateMin + Math.random() * (rateMax - rateMin);
            }
         }
      }
      
      public static function checkFallingPhantomVolumeIntersect(inVolume:Array, inStart:Point, inEnd:Point, inTemp1:Point, inTemp2:Point) : Boolean
      {
         var intersect:Point = null;
         var n:Number = inVolume.length - 1;
         var intersect1:Point = null;
         var intersect2:Point = null;
         for(var i:int = 0; i < n; i++)
         {
            inTemp1.x = inVolume[i].x;
            inTemp1.y = inVolume[i].y;
            inTemp2.x = inVolume[i + 1].x;
            inTemp2.y = inVolume[i + 1].y;
            intersect = Collision.segIntersection(inStart,inEnd,inTemp1,inTemp2);
            if(intersect != null)
            {
               if(intersect1 != null)
               {
                  intersect2 = intersect;
                  break;
               }
               intersect1 = intersect;
            }
         }
         if(intersect1 != null)
         {
            inTemp1.x = intersect1.x;
            inTemp1.y = intersect1.y;
         }
         if(intersect2 != null)
         {
            inTemp2.x = intersect2.x;
            inTemp2.y = intersect2.y;
         }
         return intersect1 != null;
      }
      
      public static function meleeRadiusCheck(inMeleeID:int, collisionPoint:Point, inRadius:int, checkPlants:Boolean) : Array
      {
         var questActor:QuestActor = null;
         var actorsReturned:Array = null;
         if(_questActorDictionary != null)
         {
            for each(questActor in _questActors)
            {
               if((checkPlants ? Boolean(questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT) : Boolean(questActor._actorData.type != QuestActor.QUEST_ACTOR_TYPE_PLANT)) && questActor.meleeHitTest(inMeleeID,collisionPoint,inRadius))
               {
                  if(actorsReturned == null)
                  {
                     actorsReturned = new Array();
                  }
                  actorsReturned.push(questActor);
               }
            }
         }
         return actorsReturned;
      }
      
      public static function projectileRadiusCheck(inProjX:int, inProjY:int, inProjRadius:int, checkPlants:Boolean) : QuestActor
      {
         var projPoint:Point = null;
         var questActor:QuestActor = null;
         if(_questActorDictionary != null)
         {
            projPoint = new Point(inProjX,inProjY);
            for each(questActor in _questActors)
            {
               if((checkPlants ? Boolean(questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT) : Boolean(questActor._actorData.type != QuestActor.QUEST_ACTOR_TYPE_PLANT)) && questActor.hitTest(projPoint,inProjRadius))
               {
                  return questActor;
               }
            }
         }
         return null;
      }
      
      private static function actorRadiusCheck() : void
      {
         var nearestPoint:Object = null;
         var bInRadius:Boolean = false;
         var questActor:Object = null;
         var actorData:Object = null;
         if(Boolean(AvatarManager.playerAvatarWorldView) && (AvatarManager.playerAvatarWorldView.moving || _playerAvatarCurrentAnim != AvatarManager.playerAvatarWorldView.animId))
         {
            _playerAvatarCurrentAnim = AvatarManager.playerAvatarWorldView.animId;
            if(_questActorDictionary != null)
            {
               bInRadius = false;
               for each(questActor in _questActors)
               {
                  if(Boolean(questActor.onRadiusTest()))
                  {
                     bInRadius = true;
                  }
               }
               if(!bInRadius)
               {
                  _lastGoodAvatarX = AvatarManager.playerAvatarWorldView.avatarPos.x;
                  _lastGoodAvatarY = AvatarManager.playerAvatarWorldView.avatarPos.y;
               }
            }
            nearestPoint = RoomManagerWorld.instance.getNearestQuestRespawnPointPlayerIsIn(AvatarManager.playerAvatarWorldView.avatarPos);
            if(nearestPoint != null)
            {
               if(nearestPoint.hasOwnProperty("name"))
               {
                  actorData = _questActorDictionary[nearestPoint.name];
               }
               if(actorData == null || Boolean(actorData.visible))
               {
                  _nearestRespawnPoint = nearestPoint;
               }
            }
            _playerInStealthVolume = RoomManagerWorld.instance.volumeManager.testStealthVolumes(AvatarManager.playerAvatarWorldView.avatarPos) != null;
         }
      }
      
      public static function setActorDictionary(inDict:Dictionary, inTimeStamp:String) : void
      {
         var actorName:String = null;
         var key:Object = null;
         var actorGroupNameIndex:int = 0;
         var actorGroupName:String = null;
         var groupArray:Array = null;
         if(_questActorToolEnabled)
         {
            invokeQuestActorTool();
         }
         if(inDict != null)
         {
            _totalGemsEarned = 0;
            _totalXPEarned = 0;
            _playerOrbCount = 0;
            _playerOrbCountTotal = 0;
            _guiTimerLocal = 0;
         }
         _defeatedPopUpTimer = 0;
         _questScriptTimeStamp = inTimeStamp;
         if(_questActors != null)
         {
            for(key in _questActors)
            {
               _questActors[key].destroy();
               delete _questActors[key];
            }
         }
         _questActorDictionary = inDict;
         _gameIdleTimer = 0;
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,resetMouseDownIdleTimer,false);
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_MOVE,resetMouseMoveIdleTimer,false);
         var questActor:Object = _questActorDictionary["diff_level"];
         if(questActor != null)
         {
            _questDifficultyLevel = questActor.state;
         }
         else
         {
            _questDifficultyLevel = 0;
         }
         _questActorToolSortedActorNames = new Array();
         for(key in _questActorDictionary)
         {
            _questActorToolSortedActorNames.push(key);
         }
         _questActorToolSortedActorNames.sort();
         _questActorGroups = new Dictionary();
         for(actorName in _questActorDictionary)
         {
            actorGroupNameIndex = actorName.lastIndexOf("__");
            if(actorGroupNameIndex != -1)
            {
               actorGroupName = actorName.substring(0,actorGroupNameIndex);
               groupArray = _questActorGroups[actorGroupName];
               if(groupArray == null)
               {
                  groupArray = new Array();
                  _questActorGroups[actorGroupName] = groupArray;
               }
               groupArray.push(actorName);
            }
         }
         startFadeIn();
      }
      
      public static function clearPlayerDictionary() : void
      {
         var key:Object = null;
         if(_questPlayersDict != null)
         {
            for(key in _questPlayersDict)
            {
               _questPlayersDict[key].destroy();
               delete _questPlayersDict[key];
            }
         }
         _questPlayersDict = null;
      }
      
      private static function stopLightAnim(e:Event) : void
      {
         var myloader:Loader = _playerTorch.getChildAt(0) as Loader;
         (myloader.content as MovieClip).stop();
         _playerTorch.removeEventListener(Event.COMPLETE,stopLightAnim);
      }
      
      public static function sceneAssetsLoaded() : void
      {
         var o:Object = null;
         var actorID:String = null;
         var actorData:Object = null;
         var questActor:Object = null;
         var volumes:Array = null;
         var spawn:Object = null;
         var layers:Array = null;
         var pos:Point = null;
         var layer:Object = null;
         var torchToAdd:Object = null;
         var guiIndex:int = 0;
         var playerId:Object = null;
         var npcId:int = 0;
         var playerData:QuestPlayerData = null;
         var mh:MediaHelper = null;
         var goalIndex:int = 0;
         var goalName:String = null;
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
                  o = _streamsLUT[_currentMusic];
                  _SFX_Music[_currentMusic] = _soundMan.addStream(o.name,o.vol);
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
            if(Boolean(AvatarManager.playerAvatarWorldView))
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
            for(actorID in _questActorDictionary)
            {
               questActor = _questActorDictionary[actorID];
               if(questActor == null)
               {
                  continue;
               }
               switch(questActor.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMEPLACEMENT:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUMEINTERACTION:
                  case QuestActor.QUEST_ACTOR_TYPE_VOLUME_FALLING_PHANTOM:
                     volumes = RoomManagerWorld.instance.volumeManager.findVolume(actorID);
                     if(volumes != null)
                     {
                        initQuestActor(actorID,0,0,null,null);
                        if(questActor.type == QuestActor.QUEST_ACTOR_TYPE_VOLUME_FALLING_PHANTOM)
                        {
                           if(_fallingPhantomVolumeActors == null)
                           {
                              _fallingPhantomVolumeActors = new Array();
                           }
                           _fallingPhantomVolumeActors.push(actorID);
                        }
                     }
                     break;
                  case QuestActor.QUEST_ACTOR_TYPE_SPAWN:
                     spawn = RoomManagerWorld.instance.findSpawn(null,actorID);
                     if(spawn != null)
                     {
                        pos = new Point(spawn.x,spawn.y);
                        RoomManagerWorld.instance.convertToWorldSpace(pos);
                        initQuestActor(actorID,0,0,null,pos);
                     }
                     break;
                  case QuestActor.QUEST_ACTOR_TYPE_TILE:
                     layers = RoomManagerWorld.instance.findLayers(actorID);
                     if(layers != null)
                     {
                        for each(layer in layers)
                        {
                           if(questActor.state > 0)
                           {
                              if(layer.s.content["setState"] != null)
                              {
                                 layer.s.content.setState(questActor.state,true);
                              }
                           }
                           if(Boolean(layer.s.content.hasOwnProperty("setProgress")))
                           {
                              layer.s.content.setProgress(questActor.progress);
                           }
                           layer.s.content.visible = questActor.visible;
                        }
                     }
                     break;
                  default:
                     if(questActor.spawnedFromActor != null)
                     {
                        doSpawnToRoot(questActor);
                     }
               }
            }
            RoomManagerWorld.instance.createMiniMap();
            _sceneLoaded = true;
            _playerTorch = addTorch(AvatarManager.playerAvatarWorldView,QUEST_TORCH_UNLITSIZE,-15,-50);
            if(Boolean(_playerTorch))
            {
               _playerTorch.addEventListener(Event.COMPLETE,stopLightAnim,false,0,true);
            }
            while(Boolean(_addTorchQueue.length))
            {
               torchToAdd = _addTorchQueue.pop();
               addTorch(torchToAdd.actor,torchToAdd.scale,torchToAdd.offsetX,torchToAdd.offsetY);
            }
            if(Boolean(_questActorDictionary["gui_ffm"]))
            {
               _guiElementsSkipBtn = new MovieClip();
               _guiElementsSkipBtnMh = new MediaHelper();
               _guiElementsSkipBtnMh.init(FirstFiveMinutes.SKIP_BUTTON,skipButtonMediaCallback,true);
               for(guiIndex = 0; guiIndex < _guiElementsGuiManager.length; guiIndex += 2)
               {
                  if(Boolean(GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]]))
                  {
                     actorData = _questActorDictionary[_guiElementsGuiManager[guiIndex]];
                     if(actorData.state >= 0 && actorData.state <= 2)
                     {
                        if(Boolean(GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].hasOwnProperty("setButtonState")))
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].setButtonState(actorData.state);
                        }
                        if(_guiElementsGuiManager[guiIndex + 1] == "gemsBtn")
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].addEventListener(MouseEvent.MOUSE_OVER,guiDownHandler,false,0,true);
                        }
                        else
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].addEventListener(MouseEvent.MOUSE_DOWN,guiDownHandler,false,0,true);
                        }
                        if(_guiElementsGuiManager[guiIndex + 1] == "charWindow")
                        {
                           GuiManager.grayHudAvatar(actorData.state == 0);
                        }
                     }
                  }
               }
            }
            if(Boolean(_questPlayersSwitched))
            {
               for(playerId in _questPlayersSwitched)
               {
                  npcId = int(_questPlayersSwitched[playerId]);
                  playerData = getQuestPlayerData(playerId as int);
                  if(playerData != null)
                  {
                     playerData.setAvatarSwitched(npcId);
                  }
               }
            }
            if(_questActorDictionary["gui_timer"] != null || Boolean(_questActorDictionary["gui_time_max"]))
            {
               mh = new MediaHelper();
               mh.init(2710,onTimerLoaded);
            }
            switch(getAdventureType())
            {
               case QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:
                  mh = new MediaHelper();
                  mh.init(2745,onGuiGoalLoaded,{"goalId":1});
                  break;
               default:
                  for(goalIndex = 1; goalIndex <= 5; goalIndex++)
                  {
                     goalName = "gui_goal" + goalIndex + "a";
                     if(!Boolean(_questActorDictionary[goalName]))
                     {
                        break;
                     }
                     mh = new MediaHelper();
                     mh.init(2745,onGuiGoalLoaded,{"goalId":goalIndex});
                  }
            }
         }
      }
      
      private static function guiDownHandler(evt:MouseEvent) : void
      {
         var guiIndex:int = 0;
         if(!evt.currentTarget.isGray)
         {
            for(guiIndex = 0; guiIndex < _guiElementsGuiManager.length; guiIndex += 2)
            {
               if(evt.currentTarget == GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]])
               {
                  QuestXtCommManager.questActorTriggered(_guiElementsGuiManager[guiIndex]);
                  break;
               }
            }
         }
      }
      
      private static function avEdDownHandler(evt:MouseEvent) : void
      {
         var guiIndex:int = 0;
         if(!evt.currentTarget.isGray)
         {
            for(guiIndex = 0; guiIndex < _guiElementsAvatarEditor.length; guiIndex += 2)
            {
               if(evt.currentTarget.name == _guiElementsAvatarEditor[guiIndex + 1])
               {
                  QuestXtCommManager.questActorTriggered(_guiElementsAvatarEditor[guiIndex]);
                  break;
               }
            }
         }
      }
      
      private static function skipButtonMediaCallback(mc:MovieClip) : void
      {
         _guiElementsSkipBtn.addChild(mc);
         GuiManager.guiLayer.addChild(_guiElementsSkipBtn);
         _guiElementsSkipBtn.x = 810;
         _guiElementsSkipBtn.y = 420;
         _guiElementsSkipBtn.visible = true;
         _guiElementsSkipBtn.addEventListener(MouseEvent.MOUSE_DOWN,guiElementsSkipBtnPress,false,0,true);
         _guiElementsSkipBtnMh.destroy();
         _guiElementsSkipBtnMh = null;
      }
      
      public static function guiElementsSkipBtnPress(e:MouseEvent) : void
      {
         e.stopPropagation();
         QuestXtCommManager.questActorTriggered("gui_20");
         gMainFrame.userInfo.firstFiveMinutes = 1;
         _guiElementsSkipBtn.visible = false;
      }
      
      public static function recycle(mediaRefId:int, o:Object) : void
      {
         if(_assetPool[mediaRefId] == null)
         {
            _assetPool[mediaRefId] = new Array();
         }
         _assetPool[mediaRefId].push(o);
      }
      
      private static function getQuestAsset(mediaRefId:int) : Object
      {
         var o:Object = null;
         var assetList:Array = _assetPool[mediaRefId];
         if(Boolean(assetList) && assetList.length > 0)
         {
            return assetList.pop();
         }
         return null;
      }
      
      public static function initQuestActor(inActorName:String, inInnerRadius:int, inOuterRadius:int, inActorData:Object = null, inPos:Point = null, inSpawnedFromPos:Point = null, filterPreviouslyPickedUp:Boolean = false, inExtendedParameters:String = null) : void
      {
         var bSpawnActor:Boolean = false;
         var questActor:QuestActor = null;
         var layers:Array = null;
         var layer:Object = null;
         if(_questActorDictionary != null)
         {
            if(inActorData == null)
            {
               inActorData = _questActorDictionary[inActorName];
            }
            if(inActorData != null && inExtendedParameters != null && inExtendedParameters.length > 0)
            {
               inActorData.extendedParameters = inExtendedParameters;
            }
            if(inActorData != null)
            {
               if(filterPreviouslyPickedUp)
               {
                  if(inActorData.hasOwnProperty("previouslyPickedUp") && Boolean(inActorData.previouslyPickedUp))
                  {
                     return;
                  }
               }
               if(!inActorData.hasOwnProperty("actorPos"))
               {
                  inActorData.actorPos = inPos;
               }
               if(_questActors[inActorName] != null)
               {
                  _questActors[inActorName].destroy();
               }
               bSpawnActor = true;
               switch(inActorData.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
                  case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
                  case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
                     if(inActorData.healthPercent == 0)
                     {
                     }
               }
               if(bSpawnActor)
               {
                  if(inActorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER || inActorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY || inActorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE || inActorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT || inActorData.type == QuestActor.QUEST_ACTOR_TYPE_NPC || inActorData.type == QuestActor.QUEST_ACTOR_TYPE_LIGHT_BEAM)
                  {
                  }
                  if(questActor == null)
                  {
                     questActor = new QuestActor();
                     questActor.initActor(inActorName,inActorData,inInnerRadius,inOuterRadius,_actorPriority++,inSpawnedFromPos);
                  }
                  else
                  {
                     questActor.resetActor(inActorName,inActorData,inInnerRadius,inOuterRadius,_actorPriority++,inSpawnedFromPos);
                  }
                  questActor.setRequireClick(inActorData.requireClick);
                  questActor.setVisible(inActorData.visible);
                  _questActors[inActorName] = questActor;
                  switch(inActorData.type)
                  {
                     case QuestActor.QUEST_ACTOR_TYPE_TILE:
                        layers = RoomManagerWorld.instance.findLayers(inActorName);
                        if(layers != null)
                        {
                           for each(layer in layers)
                           {
                              if(layer.s.content["setState"] != null)
                              {
                                 layer.s.content.setState(inActorData.state,true);
                              }
                              if(Boolean(layer.s.content.hasOwnProperty("setProgress")))
                              {
                                 layer.s.content.setProgress(inActorData.progress);
                              }
                              layer.s.content.visible = inActorData.visible;
                           }
                        }
                  }
               }
            }
         }
      }
      
      public static function commandDebugSay(paramIndex:int, inParams:Object) : void
      {
         new SBOkPopup(GuiManager.guiLayer,inParams[paramIndex++],true);
      }
      
      public static function commandNotify(paramIndex:int, inParams:Object) : void
      {
         _questObjectiveText = inParams[paramIndex++];
         if(GuiManager.mainHud.questObjectiveTxt != null && GuiManager.mainHud.objBar != null)
         {
            SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#notify/" + _questObjectiveText);
            LocalizationManager.translateId(GuiManager.mainHud.questObjectiveTxt,int(_questObjectiveText));
            GuiManager.mainHud.objBar.gotoAndPlay("on");
            playSound("ajq_questNotification");
         }
      }
      
      public static function commandSay(paramIndex:int, inParams:Object) : void
      {
         _questCommandActor = null;
         _questCommandActorState = -1;
         var questActor:QuestActor = _questActors[inParams[paramIndex++]];
         var textId:int = int(inParams[paramIndex++]);
         var sayText:String = LocalizationManager.translateIdOnly(textId);
         var chatBubble:int = int(inParams[paramIndex++]);
         switch(chatBubble)
         {
            case 1:
               if(questActor != null)
               {
                  questActor.setChatBalloonText(sayText);
                  GuiManager.chatHist.addMessage("","",sayText);
               }
               break;
            case 2:
               if(questActor != null)
               {
                  questActor.setChatBalloonText(sayText,true);
               }
               break;
            default:
               if(_talkingPopup != null)
               {
                  onTalkingPopupClose(null);
               }
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#dialog/" + textId);
               showTalkingDialog(GuiManager.guiLayer,sayText.split("|"),questActor != null ? questActor.talkingHeadMediaRef : 0);
         }
      }
      
      public static function commandAsk(paramIndex:int, inParams:Object) : void
      {
         if(_talkingPopup != null)
         {
            onTalkingPopupClose(null);
         }
         var yesNoParam:int = int(inParams[paramIndex++]);
         _questCommandActor = inParams[paramIndex++];
         _questCommandActorState = inParams[paramIndex++];
         var questActor:QuestActor = _questActors[_questCommandActor];
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#dialog/" + inParams[paramIndex]);
         showTalkingDialog(GuiManager.guiLayer,LocalizationManager.translateIdOnly(inParams[paramIndex++]).split("|"),questActor != null && _questCommandActor != "ask_actor" ? questActor.talkingHeadMediaRef : (_questCommandActor == "ask_actor" ? -1 : 0),-1,yesNoParam == 1);
      }
      
      private static function onCommandAskConfirm(confirmed:Boolean) : void
      {
         if(_questCommandActor != "" && _questCommandActorState != -1)
         {
            QuestXtCommManager.questAskComplete(_questCommandActor,_questCommandActorState,confirmed == true ? 1 : 0);
            _questCommandActor = null;
            _questCommandActorState = -1;
         }
      }
      
      public static function commandSetState(paramIndex:int, inParams:Object, inNoReply:Boolean) : void
      {
         var actorData:Object = null;
         var actorID:String = null;
         var actorState:int = 0;
         var actorVisible:Boolean = false;
         var actorRequireClick:Boolean = false;
         var bGuiHandled:Boolean = false;
         var guiIndex:int = 0;
         var layers:Array = null;
         var avEd:AvatarEditor = null;
         var layer:Object = null;
         if(_questActorDictionary != null)
         {
            actorID = inParams[paramIndex++];
            actorData = _questActorDictionary[actorID];
            if(actorID == "gui_timer")
            {
               _soundMan.play(_sounds["aj_play_timer_tick1"]);
            }
            if(actorData != null)
            {
               actorState = int(inParams[paramIndex++]);
               if(actorID == "gui_time_max")
               {
                  _guiTimerLocal = actorState;
                  if(_adventureTimer != null && actorState > 0)
                  {
                     _adventureTimer.visible = true;
                  }
               }
               if(actorID == "live_players")
               {
                  if(GuiManager.mainHud.questPlayersBtn != null)
                  {
                     GuiManager.mainHud.questPlayersBtn.activateGrayState(actorState <= 1);
                     if(Boolean(GuiManager.mainHud.playersCont.visible))
                     {
                        if(actorState <= 1)
                        {
                           GuiManager.mainHud.playersCont.visible = false;
                           GuiManager.mainHud.questPlayersBtn.downToUpState();
                        }
                     }
                  }
               }
               if(inNoReply)
               {
                  actorData.state = actorState;
               }
               else
               {
                  actorVisible = inParams[paramIndex++] == 1;
                  actorRequireClick = inParams[paramIndex++] == 1;
                  actorData.requireClick = actorRequireClick;
                  actorData.visible = actorVisible;
                  actorData.state = actorState;
                  if(ExternalInterface.available)
                  {
                     ExternalInterface.call("mrc",["dm","ACS," + actorID + "," + actorState]);
                  }
                  switch(actorData.type)
                  {
                     case QuestActor.QUEST_ACTOR_TYPE_GUI:
                        bGuiHandled = false;
                        for(guiIndex = 0; guiIndex <= _guiElementsGuiManager.length; guiIndex += 2)
                        {
                           if(actorID == _guiElementsGuiManager[guiIndex])
                           {
                              if(Boolean(GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]]))
                              {
                                 if(Boolean(GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].hasOwnProperty("setButtonState")))
                                 {
                                    GuiManager.mainHud[_guiElementsGuiManager[guiIndex + 1]].setButtonState(actorData.state);
                                 }
                                 if(_guiElementsGuiManager[guiIndex + 1] == "charWindow")
                                 {
                                    GuiManager.grayHudAvatar(actorData.state == 0);
                                 }
                              }
                              bGuiHandled = true;
                              break;
                           }
                        }
                        if(!bGuiHandled)
                        {
                           avEd = GuiManager.avatarEditor;
                           if(avEd != null && avEd.avEditor != null)
                           {
                              for(guiIndex = 0; guiIndex <= _guiElementsAvatarEditor.length; guiIndex += 2)
                              {
                                 if(actorID == _guiElementsAvatarEditor[guiIndex])
                                 {
                                    if(Boolean(avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]]))
                                    {
                                       if(Boolean(avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]].hasOwnProperty("setButtonState")))
                                       {
                                          if(actorData.state == 1 || actorData.state == 2)
                                          {
                                             switch(_guiElementsAvatarEditor[guiIndex + 1])
                                             {
                                                case "colorsTabUp":
                                                   avEd.openTab(AvatarEditor.COLOR_TAB_ID);
                                                   break;
                                                case "eyesTabUp":
                                                   avEd.openTab(AvatarEditor.EYE_TAB_ID);
                                                   break;
                                                case "patternTabUp":
                                                   avEd.openTab(AvatarEditor.PATTERN_TAB_ID);
                                             }
                                          }
                                          avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]].setButtonState(actorData.state);
                                       }
                                    }
                                    bGuiHandled = true;
                                    break;
                                 }
                              }
                           }
                        }
                        break;
                     case QuestActor.QUEST_ACTOR_TYPE_TILE:
                        layers = RoomManagerWorld.instance.findLayers(actorID);
                        if(layers != null)
                        {
                           for each(layer in layers)
                           {
                              if(layer.s != null && layer.s.content != null)
                              {
                                 if(layer.s.content["setState"] != null)
                                 {
                                    layer.s.content.setState(actorData.state);
                                 }
                                 layer.s.content.visible = actorVisible;
                              }
                           }
                        }
                        break;
                     case QuestActor.QUEST_ACTOR_TYPE_VARIABLE:
                        QuestXtCommManager.questActorTriggered(actorID);
                        break;
                     default:
                        actorData = _questActors[actorID];
                        if(actorData != null)
                        {
                           actorData.setRequireClick(actorRequireClick);
                           actorData.setVisible(actorVisible);
                           actorData.onRadiusTest();
                        }
                  }
               }
            }
            updateQuestActorTool();
         }
      }
      
      public static function commandTeleport(paramIndex:int, inParams:Object) : void
      {
         var actorData:Object = null;
         var actorID:String = null;
         var spawnpoint:String = null;
         var inRoom:Boolean = inParams[paramIndex++] == "1";
         if(inRoom)
         {
            actorID = inParams[paramIndex++];
            actorData = _questActors[actorID];
            if(actorData != null)
            {
               RoomManagerWorld.instance.teleportPlayer(actorData.x,actorData.y,true);
            }
         }
         else
         {
            spawnpoint = inParams[paramIndex++];
            RoomManagerWorld.instance.setGotoSpawnPoint(spawnpoint);
         }
      }
      
      public static function commandFocus(paramIndex:int, inParams:Object) : void
      {
         var actorData:Object = null;
         var actorID:String = null;
         var camToTime:Number = NaN;
         var camStayTime:Number = NaN;
         var camReturnTime:Number = NaN;
         var params:Array = null;
         var i:int = 0;
         var param:Array = null;
         actorID = inParams[paramIndex++];
         actorData = _questActors[actorID];
         if(actorData != null)
         {
            camToTime = 0.75;
            camStayTime = 1.5;
            camReturnTime = 0.75;
            if(actorData._actorData.extendedParameters != null)
            {
               params = actorData._actorData.extendedParameters.split(",");
               for(i = 0; i < params.length; i++)
               {
                  param = params[i].split("=");
                  switch(param[0])
                  {
                     case "camto":
                        camToTime = Number(param[1]);
                        break;
                     case "camstay":
                        camStayTime = Number(param[1]);
                        break;
                     case "camreturn":
                        camReturnTime = Number(param[1]);
                  }
               }
            }
            RoomManagerWorld.instance.setCameraFocus(new Point(actorData.x,actorData.y),camToTime,camStayTime,camReturnTime,true);
         }
      }
      
      public static function commandExit(paramIndex:int, inParams:Object) : void
      {
         _questExitPending = true;
         _questObjectiveText = "";
         AvatarManager.setPlayerAttachmentEmot(0,null,0,false);
         if(Boolean(_questActorDictionary["gui_ffm"]))
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
      
      public static function commandTakeItem(paramIndex:int, inParams:Object) : void
      {
         AvatarManager.setPlayerAttachmentEmot(0,null,0);
      }
      
      public static function commandGame(paramIndex:int, inParams:Object) : void
      {
         var gameID:int = int(inParams[paramIndex++]);
         _questCommandActor = inParams[paramIndex++];
         _questCommandActorState = inParams[paramIndex++];
         DarkenManager.showLoadingSpiral(true);
         MinigameManager.handleGameClick({
            "idx":5,
            "r":30,
            "spawn":"spawn",
            "type":0,
            "typeDefId":gameID,
            "x":0,
            "y":0
         },null,true,null);
         RoomManagerWorld.instance.setGotoSpawnLocation(_lastGoodAvatarX,_lastGoodAvatarY);
      }
      
      public static function handleCommand(inParams:Object, inNoReply:Boolean) : void
      {
         var i:int = 2;
         var cmd:int = int(inParams[i++]);
         switch(cmd)
         {
            case QUEST_CMD_SET_STATE:
               commandSetState(i,inParams,inNoReply);
               break;
            case QUEST_CMD_NOTIFY:
               commandNotify(i,inParams);
               break;
            case QUEST_CMD_SAY:
               commandSay(i,inParams);
               break;
            case QUEST_CMD_ASK:
               commandAsk(i,inParams);
               break;
            case QUEST_CMD_GAME:
               commandGame(i,inParams);
               break;
            case QUEST_CMD_TELEPORT:
               commandTeleport(i,inParams);
               break;
            case QUEST_CMD_FOCUS:
               commandFocus(i,inParams);
               break;
            case QUEST_CMD_ON_EXIT:
               commandExit(i,inParams);
               break;
            case QUEST_CMD_TAKE_ITEM:
               commandTakeItem(i,inParams);
               break;
            case QUEST_CMD_DEBUGSAY:
               commandDebugSay(i,inParams);
         }
      }
      
      public static function showTalkingDialog(popupLayer:DisplayLayer, fullTextSplit:Array, talkingHeadMediaRef:int = 0, streamId:int = -1, useYesNo:Boolean = false) : void
      {
         var textIndex:int = 0;
         var avt:AvatarView = null;
         var o:Object = null;
         if(Boolean(_talkingPopup))
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
               _talkingPopup.txt.autoSize = TextFieldAutoSize.CENTER;
               _talkingPopup.txt.text = fullTextSplit.length > 1 ? fullTextSplit[1] : fullTextSplit[0];
               GuiManager.chatHist.addMessage("","",_talkingPopup.txt.text);
            }
            else
            {
               _talkingPopup.gotoAndStop("talkingHead");
               _talkingPopup.txt.autoSize = TextFieldAutoSize.CENTER;
               _talkingPopup.talkingHeadTitleTxt.text = fullTextSplit[0];
               _talkingPopup.txt.text = fullTextSplit[1];
               for(textIndex = 1; textIndex < fullTextSplit.length; textIndex++)
               {
                  GuiManager.chatHist.addMessage("","",fullTextSplit[textIndex]);
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
      
      private static function onLevelShapeLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            GuiManager.updateXPShape(img);
         }
      }
      
      private static function onTalkingDialogLoaded(img:MovieClip) : void
      {
         var passback:Object = null;
         if(Boolean(img))
         {
            _isLoadingTalkingPopup = false;
            _talkingPopup = MovieClip(img.getChildAt(0));
            passback = img.passback;
            showTalkingDialog(passback.popupLayer,passback.fullTextSplit,passback.talkingHeadMediaRef,passback.streamId,passback.useYesNo);
         }
      }
      
      private static function onTalkingHeadMediaLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            if(_talkingPopup != null)
            {
               _talkingPopup.itemRenderPlaceholder.itemWindow.addChild(img);
               _talkingLoadingSpiral.visible = false;
            }
         }
      }
      
      private static function onAdventureGoalRewardsLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _adventureRewardsPopupStatus = new Array();
            if(_adventureRewardsPopup == null)
            {
               _adventureRewardsPopup = MovieClip(img.getChildAt(0));
               _adventureRewardsPopup.x = MainFrame.VIEW_WIDTH * 0.5;
               _adventureRewardsPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
               _adventureRewardsPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            }
            updateRewardsDisplay(img.passback);
            GuiManager.guiLayer.addChild(_adventureRewardsPopup);
            DarkenManager.darken(_adventureRewardsPopup);
         }
      }
      
      private static function updateRewardsDisplay(prizes:Array) : void
      {
         var adventureType:int = 0;
         var goalIndex:int = 0;
         var goalNameValue:String = null;
         var goalNameMax:String = null;
         var actorDataValue:Object = null;
         var actorDataMax:Object = null;
         var goalValue:int = 0;
         var goalThreshold:int = 0;
         if(Boolean(_adventureRewardsPopup))
         {
            adventureType = getAdventureType();
            switch(adventureType)
            {
               case QUEST_ADVENTURE_TYPE_MEMBER_PRIZE_SUPPORT:
                  _adventureRewardsPopup.setQuestType(3);
                  break;
               case QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:
                  _adventureRewardsPopup.setQuestType(2);
                  break;
               default:
                  _adventureRewardsPopup.setQuestType(1);
            }
            for(goalIndex = 1; goalIndex <= 5; goalIndex++)
            {
               goalNameValue = "gui_goal" + goalIndex;
               goalNameMax = "gui_goal" + goalIndex + "a";
               actorDataValue = _questActorDictionary[goalNameValue];
               actorDataMax = _questActorDictionary[goalNameMax];
               if(Boolean(actorDataMax) && Boolean(actorDataValue))
               {
                  goalValue = 0;
                  goalThreshold = int(actorDataMax.state);
                  switch(adventureType)
                  {
                     case QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:
                        goalValue = _playerOrbCountTotal;
                        if(goalIndex == 1 && goalValue < goalThreshold)
                        {
                           goalThreshold = 0;
                        }
                        break;
                     default:
                        goalValue = int(actorDataValue.state);
                  }
                  if(actorDataValue.hasOwnProperty("prizePicked"))
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[goalIndex] = true;
                     }
                     _adventureRewardsPopup.setState(goalIndex,3);
                     _adventureRewardsPopup["opt" + goalIndex].removeEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions);
                  }
                  else if(goalValue >= goalThreshold && prizes[goalIndex - 1].type != 0)
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[goalIndex] = false;
                     }
                     _adventureRewardsPopup.setState(goalIndex,2);
                     _adventureRewardsPopup["opt" + goalIndex].addEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions,false,0,true);
                     _adventureRewardsPopup["opt" + goalIndex].index = goalIndex - 1;
                     _adventureRewardsPopup["opt" + goalIndex].prize = prizes[goalIndex - 1];
                  }
                  else
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[goalIndex] = true;
                     }
                     _adventureRewardsPopup.setState(goalIndex,1);
                  }
                  _adventureRewardsPopup.setValue(goalIndex,goalValue);
                  _adventureRewardsPopup.setMaxValue(goalIndex,goalThreshold);
               }
               else if(adventureType == QUEST_ADVENTURE_TYPE_MEMBER_PRIZE_SUPPORT)
               {
                  switch(goalIndex)
                  {
                     case 1:
                        if(_adventureRewardsPopupStatus != null)
                        {
                           _adventureRewardsPopupStatus[goalIndex] = false;
                        }
                        _adventureRewardsPopup.setState(goalIndex,2);
                        _adventureRewardsPopup["opt" + goalIndex].addEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions,false,0,true);
                        _adventureRewardsPopup["opt" + goalIndex].index = goalIndex - 1;
                        _adventureRewardsPopup["opt" + goalIndex].prize = prizes[goalIndex - 1];
                        break;
                     case 2:
                        if(gMainFrame.userInfo.isMember)
                        {
                           if(_adventureRewardsPopupStatus != null)
                           {
                              _adventureRewardsPopupStatus[goalIndex] = false;
                           }
                           _adventureRewardsPopup.setState(goalIndex,2);
                           _adventureRewardsPopup["opt" + goalIndex].addEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions,false,0,true);
                           _adventureRewardsPopup["opt" + goalIndex].index = goalIndex - 1;
                           _adventureRewardsPopup["opt" + goalIndex].prize = prizes[goalIndex - 1];
                        }
                        else
                        {
                           if(_adventureRewardsPopupStatus != null)
                           {
                              _adventureRewardsPopupStatus[goalIndex] = true;
                           }
                           _adventureRewardsPopup.setState(goalIndex,4);
                           _adventureRewardsPopup["opt" + goalIndex].addEventListener(MouseEvent.MOUSE_DOWN,onAdventureNonMemberRewardsOptions,false,0,true);
                           _adventureRewardsPopup["opt" + goalIndex].index = goalIndex - 1;
                           _adventureRewardsPopup["opt" + goalIndex].prize = prizes[goalIndex - 1];
                        }
                  }
               }
               else
               {
                  _adventureRewardsPopup.setState(goalIndex,1);
                  _adventureRewardsPopup.setValue(0,0);
                  _adventureRewardsPopup.setMaxValue(goalIndex,0);
               }
            }
         }
      }
      
      private static function onAdventureRewardsLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _adventureRewardsPopup = MovieClip(img.getChildAt(0));
            _adventureRewardsPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _adventureRewardsPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            updateAdventureRewards(img.passback);
            _adventureRewardsPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            GuiManager.guiLayer.addChild(_adventureRewardsPopup);
            DarkenManager.darken(_adventureRewardsPopup);
         }
      }
      
      private static function updateAdventureRewards(prizes:Array) : void
      {
         var i:int = 0;
         if(Boolean(_adventureRewardsPopup))
         {
            for(i = 1; i <= 5; i++)
            {
               _adventureRewardsPopup["opt" + i].addEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions,false,0,true);
               _adventureRewardsPopup["opt" + i].index = i - 1;
               _adventureRewardsPopup["opt" + i].prize = prizes[i - 1];
            }
         }
      }
      
      private static function onAdventureNonMemberRewardsOptions(evt:MouseEvent) : void
      {
         UpsellManager.displayPopup(UpsellManager.ADVENTURES,"adventure/" + _questScriptDefId);
      }
      
      private static function onAdventureRewardsOptions(evt:MouseEvent) : void
      {
         var currItem:Object = null;
         var giftType:int = 0;
         var defId:int = 0;
         var goalIndex:int = 0;
         var goalNameValue:String = null;
         var actorDataValue:Object = null;
         _adventureRewardsPopup.giftIndexChosen = evt.currentTarget.index;
         if(Boolean(_adventureGoals) || getAdventureType() == QUEST_ADVENTURE_TYPE_MEMBER_PRIZE_SUPPORT)
         {
            goalIndex = _adventureRewardsPopup.giftIndexChosen + 1;
            goalNameValue = "gui_goal" + goalIndex;
            actorDataValue = _questActorDictionary[goalNameValue];
            if(Boolean(actorDataValue))
            {
               actorDataValue.prizePicked = true;
            }
            if(Boolean(_adventureRewardsPopup))
            {
               if(_adventureRewardsPopupStatus != null)
               {
                  _adventureRewardsPopupStatus[goalIndex] = true;
               }
               _adventureRewardsPopup.setState(goalIndex,3);
               _adventureRewardsPopup["opt" + goalIndex].removeEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions);
            }
         }
         switch(evt.currentTarget.prize.type)
         {
            case 1:
               currItem = new DenItem();
               currItem.initShopItem(evt.currentTarget.prize.defID,evt.currentTarget.prize.versionId);
               giftType = GiftPopup.GIFT_TYPE_DEN_ACC;
               defId = int(currItem.itemDefId);
               break;
            case 2:
               currItem = new Item();
               currItem.init(evt.currentTarget.prize.defID,0,evt.currentTarget.prize.color,0,0,true);
               giftType = GiftPopup.GIFT_TYPE_CLOTHING;
               defId = int(currItem.defId);
               break;
            case 3:
               giftType = GiftPopup.GIFT_TYPE_GEMS;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(StartupPopups.GEMS_MEDIA_ID,rewardsGemOrOrbLoaded,{
                  "giftType":giftType,
                  "amount":LocalizationManager.translateIdAndInsertOnly(LocalizationManager.GEMS_CAPITALIZED,evt.currentTarget.prize.amount)
               });
               return;
            case 4:
               giftType = GiftPopup.GIFT_TYPE_ORBS;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(StartupPopups.DIAMOND_MEDIA_ID,rewardsGemOrOrbLoaded,{
                  "giftType":giftType,
                  "amount":LocalizationManager.translateIdAndInsertOnly(LocalizationManager.ORBS_CAPITALIZED,evt.currentTarget.prize.amount)
               });
               return;
         }
         _rewardsGiftPopup = new GiftPopup();
         _rewardsGiftPopup.init(GuiManager.guiLayer,currItem.largeIcon,currItem.name,defId,GiftPopup.POPUP_TYPE_ADVENTURES,giftType,onKeepRewardsGift,onDiscardRewardsGift,null,false,GiftPopup.BUTTONS_TYPE_KEEP_DISCARD);
      }
      
      private static function rewardsGemOrOrbLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _rewardsGiftPopup = new GiftPopup();
         _rewardsGiftPopup.init(GuiManager.guiLayer,img,img.passback.amount,0,GiftPopup.POPUP_TYPE_ADVENTURES,img.passback.giftType,onKeepRewardsGift,onKeepRewardsGift,null,false,GiftPopup.BUTTONS_TYPE_OK);
      }
      
      private static function onDiscardRewardsGift() : void
      {
         removeGiftPopup();
      }
      
      private static function onKeepRewardsGift() : void
      {
         var actorDataMax:Object = _questActorDictionary["gui_goal1a"];
         if(getAdventureType() == QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT && actorDataMax != null && _playerOrbCountTotal < actorDataMax.state)
         {
            QuestXtCommManager.sendPickGiftResult(_adventureRewardsPopup.giftIndexChosen,true);
         }
         else
         {
            QuestXtCommManager.sendPickGiftResult(_adventureRewardsPopup.giftIndexChosen,false);
         }
         removeGiftPopup();
      }
      
      private static function removeGiftPopup() : void
      {
         var adventureType:int = 0;
         var goalIndex:int = 0;
         var goalNameValue:String = null;
         var goalNameMax:String = null;
         var actorDataValue:Object = null;
         var actorDataMax:Object = null;
         var goalValue:int = 0;
         var goalThreshold:int = 0;
         var i:int = 0;
         _rewardsGiftPopup.destroy();
         _rewardsGiftPopup = null;
         var pickGiftsComplete:Boolean = true;
         if(Boolean(_adventureGoals))
         {
            adventureType = getAdventureType();
            for(goalIndex = 1; goalIndex <= 5; goalIndex++)
            {
               goalNameValue = "gui_goal" + goalIndex;
               goalNameMax = "gui_goal" + goalIndex + "a";
               actorDataValue = _questActorDictionary[goalNameValue];
               actorDataMax = _questActorDictionary[goalNameMax];
               if(Boolean(actorDataValue) && Boolean(actorDataMax))
               {
                  goalValue = 0;
                  goalThreshold = int(actorDataMax.state);
                  switch(adventureType)
                  {
                     case QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:
                        goalValue = _playerOrbCountTotal;
                        break;
                     default:
                        goalValue = int(actorDataValue.state);
                  }
                  if(goalValue >= goalThreshold && !actorDataValue.hasOwnProperty("prizePicked"))
                  {
                     pickGiftsComplete = false;
                     break;
                  }
               }
            }
         }
         else if(getAdventureType() == QUEST_ADVENTURE_TYPE_MEMBER_PRIZE_SUPPORT)
         {
            if(_adventureRewardsPopupStatus != null && _adventureRewardsPopupStatus[1] == false || _adventureRewardsPopupStatus[2] == false)
            {
               pickGiftsComplete = false;
            }
         }
         if(pickGiftsComplete)
         {
            _adventureRewardsPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            for(i = 1; i <= 5; i++)
            {
               _adventureRewardsPopup["opt" + i].removeEventListener(MouseEvent.MOUSE_DOWN,onAdventureRewardsOptions);
            }
            DarkenManager.unDarken(_adventureRewardsPopup);
            GuiManager.guiLayer.removeChild(_adventureRewardsPopup);
            _adventureRewardsPopup = null;
         }
      }
      
      private static function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function onTalkingPopupClose(evt:MouseEvent) : void
      {
         if(evt != null)
         {
            evt.stopPropagation();
         }
         if(Boolean(_talkingPopup))
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
      
      private static function onConfirmBtn(o:Object) : void
      {
         onCommandAskConfirm(o.status);
      }
      
      private static function onYesBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         onCommandAskConfirm(true);
         onTalkingPopupClose(evt);
      }
      
      private static function onNoBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         onCommandAskConfirm(false);
         onTalkingPopupClose(evt);
      }
      
      private static function onOkBtn(evt:MouseEvent) : void
      {
         if(_talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
         {
            onTalkingPopupClose(evt);
            return;
         }
         if(Boolean(_talkingPopup))
         {
            ++_talkingPopupCurrTextPage;
            _talkingPopup.txt.text = _talkingPopupFullText[_talkingPopupCurrTextPage];
            if(_talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
            {
               _talkingPopup.nextBtn.visible = false;
               if(Boolean(_talkingPopup.useYesNo))
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
      
      public static function handleQuestStartResponse(inParams:Object) : void
      {
         var paramIndex:int = 2;
         _questScriptDefId = inParams[paramIndex++];
         _questStartingPlayerCount = inParams[paramIndex++];
         _questSeeds = new Dictionary();
         if(_seedInventory != null)
         {
            _seedInventory.destroy();
            _seedInventory = null;
         }
         _questObjectiveText = "";
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#NumPlayers/" + _questStartingPlayerCount);
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#Difficulty/" + _questDifficultyLevel);
         if(Boolean(_adventureJoin))
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
            AvatarManager.resetCustomAdventureState();
         }
         RoomManagerWorld.instance.setGridDepth(25);
      }
      
      public static function handleQuestWaitResponse(inParams:Object) : void
      {
         if(Boolean(_adventureJoin))
         {
            _adventureJoin.handleWaitResponse(inParams);
         }
         if(Boolean(_privateAdventureJoin))
         {
            _privateAdventureJoin.handleWaitResponse(inParams);
         }
      }
      
      public static function handleQuestJoinCancelResponse(inParams:Object) : void
      {
         if(Boolean(_adventureJoin))
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
         }
      }
      
      public static function handleQuestJoinResponse(inParams:Object, type:String, difficulty:int = 0) : void
      {
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         if(type == AdventureJoin.CUSTOM_SETTINGS_TYPE)
         {
            if(Boolean(_adventureJoin))
            {
               _adventureJoin.destroy();
               _adventureJoin = null;
            }
            if(Boolean(_privateAdventureJoin))
            {
               _privateAdventureJoin.destroy();
               _privateAdventureJoin = null;
            }
            _privateAdventureJoin = new PrivateAdventureJoin();
            _privateAdventureJoin.init(inParams[4],privateAdventureJoinClose);
            UserCommXtCommManager.sendCustomAdventureMessage(true);
         }
         else
         {
            openAdventureJoin(inParams[4],type,difficulty);
         }
      }
      
      public static function openAdventureJoin(scriptDefId:int, type:String, difficulty:int) : void
      {
         if(Boolean(_adventureJoin))
         {
            _adventureJoin.destroy();
         }
         _adventureJoin = new AdventureJoin();
         _adventureJoin.init(scriptDefId,type,difficulty,adventureJoinClose);
      }
      
      public static function get isInPrivateAdventureState() : Boolean
      {
         return _privateAdventureJoin != null;
      }
      
      public static function isBeYourPetQuest() : Boolean
      {
         var currScriptDef:Object = null;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            currScriptDef = QuestXtCommManager.getScriptDef(gMainFrame.clientInfo.secondaryDefId);
            if(currScriptDef != null && Boolean(currScriptDef.playAsPet))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function isDynamicallyJoinableQuest() : Boolean
      {
         var currScriptDef:Object = null;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            currScriptDef = QuestXtCommManager.getScriptDef(gMainFrame.clientInfo.secondaryDefId);
            if(currScriptDef != null && currScriptDef.time == 1)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function updatePrivateAdventureIndexComparedToMainHud() : void
      {
         if(Boolean(_privateAdventureJoin))
         {
            _privateAdventureJoin.updateDisplayIndex();
         }
      }
      
      public static function handleAttackPlayer(inParams:Object) : void
      {
         var actorData:QuestActor = null;
         var actorID:String = null;
         var playerSfsId:int = 0;
         var weaponItemDefId:int = 0;
         var weaponItemColor:uint = 0;
         var paramIndex:int = 2;
         actorID = inParams[paramIndex++];
         actorData = _questActors[actorID];
         if(actorData != null)
         {
            playerSfsId = int(inParams[paramIndex++]);
            weaponItemDefId = int(inParams[paramIndex++]);
            weaponItemColor = uint(inParams[paramIndex++]);
            actorData.handleAttackPlayer(weaponItemDefId,weaponItemColor,playerSfsId);
         }
      }
      
      public static function handleQuestActorPositionUpdateResponse(inParams:Object) : void
      {
         var actorData:QuestActor = null;
         var actorID:String = null;
         var paramIndex:int = 2;
         actorID = inParams[paramIndex++];
         var theX:int = int(inParams[paramIndex++]);
         var theY:int = int(inParams[paramIndex++]);
         var theVel:int = int(inParams[paramIndex++]);
         var theSeekType:int = int(inParams[paramIndex++]);
         var thePlayerX:int = int(inParams[paramIndex++]);
         var thePlayerY:int = int(inParams[paramIndex++]);
         var actorDataMaster:Object = _questActorDictionary[actorID];
         if(actorDataMaster != null)
         {
            actorDataMaster.actorPos = new Point(theX,theY);
         }
         actorData = _questActors[actorID];
         if(actorData != null)
         {
            actorData.handlePositionUpdate(theX,theY,theVel,theSeekType,thePlayerX,thePlayerY);
         }
      }
      
      public static function setQuestActorSeek(actor:QuestActor, requestSeek:int) : void
      {
         if(requestSeek > actor._actorData.seekType || AvatarManager.playerSfsUserId == actor._actorData.seekTypeSfsId)
         {
            QuestXtCommManager.questActorSeek(actor._actorId,requestSeek);
         }
      }
      
      public static function handleQuestActorRequestSeekResponse(inParams:Object) : void
      {
         var actorData:QuestActor = null;
         var actorID:String = null;
         var paramIndex:int = 2;
         actorID = inParams[paramIndex++];
         var seekState:int = int(inParams[paramIndex++]);
         var playerSfsId:int = int(inParams[paramIndex++]);
         var actorDataMaster:Object = _questActorDictionary[actorID];
         if(actorDataMaster != null)
         {
            if(seekState > actorDataMaster.seekType || playerSfsId == actorDataMaster.seekTypeSfsId)
            {
               actorDataMaster.seekType = seekState;
               actorDataMaster.seekTypeSfsId = playerSfsId;
            }
         }
         if(playerSfsId == AvatarManager.playerSfsUserId)
         {
            actorData = _questActors[actorID];
            if(actorData != null)
            {
               actorData.handleRequestSeekResponse(seekState);
            }
         }
      }
      
      public static function handleLaunchProjectile(inParams:Object) : void
      {
         var playerAvatarView:AvatarWorldView = null;
         var paramIndex:int = 2;
         var itemID:int = int(inParams[paramIndex++]);
         var aimX:int = int(inParams[paramIndex++]);
         var aimY:int = int(inParams[paramIndex++]);
         var actorID:String = inParams[paramIndex++];
         var sfsUserID:int = int(inParams[paramIndex++]);
         var weaponColor:uint = uint(inParams[paramIndex++]);
         var actorData:QuestActor = null;
         if(sfsUserID > 0)
         {
            playerAvatarView = AvatarManager.avatarViewList[sfsUserID];
            if(playerAvatarView == null)
            {
               return;
            }
            playerAvatarView.faceAnim(aimX - playerAvatarView.avatarPos.x,aimY - playerAvatarView.avatarPos.y,false);
         }
         else
         {
            actorData = _questActors[actorID];
         }
         launchProjectile(itemID,weaponColor,aimX,aimY,actorData,playerAvatarView);
      }
      
      public static function handleSetSwfState(inParams:Object) : void
      {
         var paramIndex:int = 0;
         var actorName:String = null;
         var swfStateName:String = null;
         var actorDataMaster:Object = null;
         var actorData:QuestActor = null;
         if(_questActorDictionary != null)
         {
            paramIndex = 2;
            actorName = inParams[paramIndex++];
            swfStateName = inParams[paramIndex++];
            actorDataMaster = _questActorDictionary[actorName];
            if(actorDataMaster != null)
            {
               actorDataMaster.pendingSwfStateName = swfStateName;
            }
            actorData = _questActors[actorName];
            if(actorData != null)
            {
               actorData.setSwfState(swfStateName);
            }
         }
      }
      
      public static function handleLoadMediaLib(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var mediaDefId:int = int(inParams[paramIndex++]);
         loadQuestSfx(mediaDefId);
      }
      
      public static function handleOrbsUpdate(inParams:Object) : void
      {
         var _playerOrbCountPreviousTotal:int = 0;
         var goalIndex:int = 0;
         var goalNameMax:String = null;
         var actorDataMax:Object = null;
         var paramIndex:int = 2;
         var playerOrbs:int = int(inParams[paramIndex++]);
         _playerOrbCount = playerOrbs;
         if(_playerOrbCountTotal < _playerOrbCount)
         {
            _playerOrbCountPreviousTotal = _playerOrbCountTotal;
            _playerOrbCountTotal = _playerOrbCount;
            if(_adventureGoals != null)
            {
               switch(getAdventureType())
               {
                  case QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:
                     if(Boolean(_questActorDictionary["gui_goal1"]))
                     {
                        if(Boolean(_adventureGoals[1]))
                        {
                           for(goalIndex = 1; goalIndex <= 5; goalIndex++)
                           {
                              goalNameMax = "gui_goal" + goalIndex + "a";
                              actorDataMax = _questActorDictionary[goalNameMax];
                              if(actorDataMax != null && _playerOrbCountPreviousTotal < actorDataMax.state && _playerOrbCountTotal >= actorDataMax.state)
                              {
                                 _adventureGoals[1].setGoalAchieved(goalIndex);
                              }
                           }
                        }
                     }
               }
            }
         }
      }
      
      public static function handlePickUpItem(inParams:Object) : void
      {
         var pickupItem:String = null;
         var actorID:String = null;
         var actorDataMaster:Object = null;
         var sfsUserID:int = 0;
         var setPosition:Point = null;
         var pickUpNextItem:String = null;
         var innerRadius:int = 0;
         var outerRadius:int = 0;
         var playerSfsId:int = 0;
         var actorVisible:Boolean = false;
         var actorData:QuestActor = null;
         var emoteDefId:int = 0;
         var paramIndex:int = 2;
         var responseType:int = int(inParams[paramIndex++]);
         switch(responseType)
         {
            case 0:
               pickupItem = inParams[paramIndex++];
               new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14812),true,onDropItemConfirm,pickupItem);
               break;
            case 1:
            case 3:
            case 4:
               actorID = inParams[paramIndex++];
               actorDataMaster = _questActorDictionary[actorID];
               sfsUserID = int(inParams[paramIndex++]);
               if(responseType == 4 || responseType == 3)
               {
                  setPosition = new Point(inParams[paramIndex++],inParams[paramIndex++]);
                  if(responseType == 4)
                  {
                     innerRadius = int(inParams[paramIndex++]);
                     outerRadius = int(inParams[paramIndex++]);
                     playerSfsId = int(inParams[paramIndex++]);
                     if(playerSfsId == AvatarManager.playerSfsUserId)
                     {
                        pickUpNextItem = inParams[paramIndex++];
                     }
                  }
               }
               if(actorDataMaster != null)
               {
                  if(actorDataMaster.type == QuestActor.QUEST_ACTOR_TYPE_ITEM)
                  {
                     actorDataMaster.previouslyPickedUp = true;
                  }
                  actorVisible = responseType == 4 || responseType == 3 || actorDataMaster.type == QuestActor.QUEST_ACTOR_TYPE_GROUP_ITEM;
                  if(setPosition != null && actorDataMaster.type != QuestActor.QUEST_ACTOR_TYPE_GROUP_ITEM)
                  {
                     actorDataMaster.actorPos = setPosition;
                  }
                  actorDataMaster.visible = actorVisible;
                  actorData = _questActors[actorID];
                  if(actorData != null)
                  {
                     if(setPosition != null && actorDataMaster.type != QuestActor.QUEST_ACTOR_TYPE_GROUP_ITEM)
                     {
                        actorData.x = setPosition.x;
                        actorData.y = setPosition.y;
                     }
                     actorData.setVisible(actorVisible);
                     if(sfsUserID == AvatarManager.playerSfsUserId && responseType != 4)
                     {
                        emoteDefId = responseType == 4 || responseType == 3 ? 0 : UserCommXtCommManager.getEmoticonDefId(actorData._actorData.defId);
                        AvatarManager.setPlayerAttachmentEmot(emoteDefId,null,0);
                        AvatarManager._setAvatarAttachmentEmot(responseType == 4 || responseType == 3 ? 0 : int(actorData._actorData.defId),"",sfsUserID);
                        if(Boolean(actorData._mediaObject) && actorData._mediaObject.hasOwnProperty("playPickupSound"))
                        {
                           actorData._mediaObject.playPickupSound();
                        }
                     }
                  }
                  else if(responseType == 4)
                  {
                     initQuestActor(actorID,innerRadius,outerRadius,null,new Point(setPosition.x,setPosition.y));
                  }
               }
               break;
            case 2:
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14813));
         }
      }
      
      public static function handleMovedItemList(data:Array) : void
      {
         var actorName:String = null;
         var innerRadius:int = 0;
         var outerRadius:int = 0;
         var pos:Point = null;
         var paramIndex:int = 2;
         while(paramIndex < data.length)
         {
            actorName = data[paramIndex++];
            innerRadius = int(data[paramIndex++]);
            outerRadius = int(data[paramIndex++]);
            pos = new Point(data[paramIndex++],data[paramIndex++]);
            if(Boolean(_questActors[actorName]))
            {
               paramIndex += 2;
            }
            else
            {
               initQuestActor(actorName,innerRadius,outerRadius,null,pos);
            }
         }
      }
      
      public static function handleStatsUpdate(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var ai:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         if(ai != null)
         {
            ai.attackBase = inParams[paramIndex++];
            ai.attackMax = inParams[paramIndex++];
            ai.defenseBase = inParams[paramIndex++];
            ai.defenseMax = inParams[paramIndex++];
            gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myPerUserAvId,ai);
         }
      }
      
      public static function handleLevelUp(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var playerSfsId:int = int(inParams[paramIndex++]);
         var newLevel:int = int(inParams[paramIndex++]);
         var playerData:QuestPlayerData = getQuestPlayerData(playerSfsId);
         if(playerData != null)
         {
            playerData.levelUp(newLevel);
         }
      }
      
      public static function handleXpUpdate(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var earnedXp:int = int(inParams[paramIndex++]);
         var xp:int = int(inParams[paramIndex++]);
         var curLevel:int = int(inParams[paramIndex++]);
         var newLevel:int = int(inParams[paramIndex++]);
         var percentage:Number = Number(inParams[paramIndex++]);
         var actorName:String = inParams[paramIndex++];
         var ai:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         _totalXPEarned += earnedXp;
         updateQuestActorTool();
         ai.questXp = xp;
         ai.questLevel = newLevel;
         ai.questXPPercentage = percentage;
         GuiManager.addQuestXP(percentage);
         var inActor:QuestActor = _questActors[actorName];
         if(inActor != null)
         {
            inActor.setActorText(LocalizationManager.translateIdAndInsertOnly(18481,earnedXp));
         }
         if(curLevel < newLevel)
         {
            SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#levelUp/" + newLevel);
            if(newLevel % 5 == 0)
            {
               loadLevelShape(newLevel);
            }
            else
            {
               GuiManager.updateShapeXP(newLevel);
            }
            if(Boolean(AvatarManager.playerAvatarWorldView))
            {
               AvatarManager.playerAvatarWorldView.updateNameBarLevelShape(newLevel);
            }
         }
      }
      
      public static function handleQuestActorTriggerTreasure(inParams:Object) : void
      {
         var giveType:int = 0;
         var giveDefId:int = 0;
         var giveData:int = 0;
         var paramIndex:int = 2;
         var actorName:String = inParams[paramIndex++];
         var inActor:QuestActor = _questActors[actorName];
         if(inActor != null)
         {
            giveType = int(inParams[paramIndex++]);
            giveDefId = int(inParams[paramIndex++]);
            giveData = int(inParams[paramIndex++]);
            inActor.handleTriggerTreasure(giveType,giveDefId,giveData);
         }
      }
      
      public static function handleAvSwitch(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var npcId:int = int(inParams[paramIndex++]);
         var sfsUserId:int = int(inParams[paramIndex++]);
         if(npcId != -1)
         {
            if(_questPlayersSwitched == null)
            {
               _questPlayersSwitched = new Dictionary();
            }
            _questPlayersSwitched[sfsUserId] = npcId;
         }
         else if(_questPlayersSwitched != null && _questPlayersSwitched[sfsUserId] != null)
         {
            delete _questPlayersSwitched[sfsUserId];
         }
         var playerData:QuestPlayerData = getQuestPlayerData(sfsUserId);
         if(playerData != null)
         {
            playerData.setAvatarSwitched(npcId);
         }
      }
      
      public static function handleExitByType(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var exitType:String = inParams[paramIndex++];
         if(exitType == "ffm")
         {
            AvatarXtCommManager.sendAvatarPendingFlagsUpdate(0);
            GuiManager.wasInFFM = true;
            GuiManager.isInFFM = false;
            RoomManagerWorld.instance.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest("jamaa_township.room_main#" + RoomManagerWorld.instance.shardId);
            LoadProgress.show(true);
            GuiManager.initPlayerEngagement(null);
         }
      }
      
      public static function handleSpawn(inParams:Object) : void
      {
         var subType:int = 0;
         var denDefId:int = 0;
         var itemDefId:int = 0;
         var itemData:int = 0;
         var gems:int = 0;
         var orbs:int = 0;
         var paramIndex:int = 2;
         var spawningActorName:String = inParams[paramIndex++];
         var actorName:String = inParams[paramIndex++];
         var actorType:int = int(inParams[paramIndex++]);
         var actordefId:int = int(inParams[paramIndex++]);
         var actorData:Object = new Object();
         actorData.visible = true;
         actorData.requireClick = true;
         actorData.type = actorType;
         actorData.defId = actordefId;
         actorData.state = 0;
         actorData.actorName = actorName;
         initInitialActorStatus(actorData,spawningActorName);
         switch(actorType)
         {
            case QuestActor.QUEST_ACTOR_TYPE_DROPPED_TREASURE:
               subType = int(inParams[paramIndex++]);
               actorData.subType = subType;
               switch(subType)
               {
                  case QuestActor.GIVE_DEN_ITEM:
                     denDefId = int(inParams[paramIndex++]);
                     actorData.denDefId = denDefId;
                     break;
                  case QuestActor.GIVE_ACCESSORY:
                     itemDefId = int(inParams[paramIndex++]);
                     itemData = int(inParams[paramIndex++]);
                     actorData.itemDefId = itemDefId;
                     actorData.itemData = itemData;
                     break;
                  case QuestActor.GIVE_GEMS:
                     gems = int(inParams[paramIndex++]);
                     actorData.gems = gems;
                     break;
                  case QuestActor.GIVE_ORBS:
                     orbs = int(inParams[paramIndex++]);
                     actorData.gems = orbs;
               }
               break;
            case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
            case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
               actorData.spawnOffsetX = inParams[paramIndex++];
               actorData.spawnOffsetY = inParams[paramIndex++];
         }
         _questActorDictionary[actorName] = actorData;
         doSpawn(actorData,spawningActorName);
      }
      
      public static function doSpawnToRoot(inActorData:Object) : void
      {
         var spawningActor:QuestActor = null;
         var spawningActorData:Object = null;
         if(inActorData.spawnedFromActor != null)
         {
            if(inActorData.type == QuestActor.QUEST_ACTOR_TYPE_DROPPED_TREASURE && inActorData.pickedUp == true)
            {
               return;
            }
            spawningActor = _questActors[inActorData.spawnedFromActor];
            if(spawningActor == null)
            {
               spawningActorData = _questActorDictionary[inActorData.spawnedFromActor];
               if(spawningActorData != null && spawningActorData.spawnedFromActor != null)
               {
                  doSpawnToRoot(spawningActorData);
               }
            }
            doSpawn(inActorData,inActorData.spawnedFromActor);
         }
      }
      
      public static function doSpawn(inActorData:Object, spawningActorName:String) : void
      {
         var innerRadius:int = 0;
         var outerRadius:int = 0;
         var offsetPoint:Point = null;
         var xPos:Number = NaN;
         var yPos:Number = NaN;
         var xPosOffset:Number = NaN;
         var yPosOffset:Number = NaN;
         var spawningActor:QuestActor = _questActors[inActorData.spawnedFromActor];
         if(spawningActor != null)
         {
            innerRadius = 0;
            outerRadius = 0;
            offsetPoint = null;
            if(inActorData.actorPos == null)
            {
               xPos = spawningActor.x;
               yPos = spawningActor.y;
               switch(inActorData.type)
               {
                  case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
                  case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
                     if(spawningActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY)
                     {
                        xPosOffset = 2 * spawningActor._actorDefaultInnerRadius * inActorData.spawnOffsetX / 1000 - spawningActor._actorDefaultInnerRadius;
                        yPosOffset = 2 * spawningActor._actorDefaultInnerRadius * inActorData.spawnOffsetY / 1000 - spawningActor._actorDefaultInnerRadius;
                        xPos += xPosOffset;
                        yPos += yPosOffset;
                        offsetPoint = new Point(-xPosOffset,-yPosOffset);
                     }
               }
               inActorData.actorPos = new Point(xPos,yPos);
               initQuestActor(inActorData.actorName,innerRadius,outerRadius,inActorData,null,offsetPoint);
            }
            switch(inActorData.type)
            {
               case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
               case QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE:
                  inActorData.respawned = true;
                  if(spawningActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_FACTORY)
                  {
                     innerRadius = QuestActor.DEFAULT_PHANTOM_VISION_RADIUS;
                     outerRadius = spawningActor._actorDefaultOuterRadius;
                  }
            }
            initQuestActor(inActorData.actorName,innerRadius,outerRadius,inActorData,null,offsetPoint);
         }
      }
      
      public static function loadLevelShape(curLevel:int) : void
      {
         var shapeId:int = 0;
         if(!GuiManager.isBeYourPetRoom())
         {
            _levelShapeHelper = new MediaHelper();
            shapeId = Math.floor(curLevel / 5) > NameBar.LEVEL_SHAPES.length - 1 ? int(NameBar.LEVEL_SHAPES[NameBar.LEVEL_SHAPES.length - 1]) : int(NameBar.LEVEL_SHAPES[Math.floor(curLevel / 5)]);
            _levelShapeHelper.init(shapeId,onLevelShapeLoaded,curLevel);
         }
         AvatarManager.playerAvatarWorldView.updateNameBarLevelShape(curLevel);
      }
      
      public static function handleActorHealthStatus(inParams:Object) : void
      {
         var actorDataMaster:Object = null;
         var damageAmount:int = 0;
         var criticalHit:int = 0;
         var paramIndex:int = 2;
         var actorName:String = inParams[paramIndex++];
         var healthPercent:int = int(inParams[paramIndex++]);
         var actorData:QuestActor = _questActors[actorName];
         if(healthPercent == -1)
         {
            if(actorData != null)
            {
               if(actorData._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE || actorData._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER && actorData._attackable > 0)
               {
                  actorData.setActorText("miss");
               }
            }
         }
         else
         {
            actorDataMaster = _questActorDictionary[actorName];
            if(actorDataMaster != null)
            {
               actorDataMaster.healthPercent = healthPercent;
            }
            if(actorData != null)
            {
               damageAmount = int(inParams[paramIndex++]);
               criticalHit = int(inParams[paramIndex++]);
               actorData.healthUpdate(healthPercent,damageAmount,criticalHit == 1);
            }
         }
      }
      
      public static function handleHealthUpdate(inParams:Object, isRespawn:Boolean) : void
      {
         var playerAvatarView:AvatarWorldView = null;
         var ai:AvatarInfo = null;
         var posX:int = 0;
         var posY:int = 0;
         var paramIndex:int = 2;
         var sfsUserId:int = int(inParams[paramIndex++]);
         var healthPercent:int = int(inParams[paramIndex++]);
         var healthChange:int = int(inParams[paramIndex++]);
         var health:int = int(inParams[paramIndex++]);
         var healthBase:int = int(inParams[paramIndex++]);
         var playerData:QuestPlayerData = getQuestPlayerData(sfsUserId);
         if(healthPercent == -1 && healthChange == 0)
         {
            if(playerData != null)
            {
            }
         }
         else
         {
            playerAvatarView = AvatarManager.avatarViewList[sfsUserId];
            if(playerData != null)
            {
               if(healthChange < 0)
               {
                  playerData.playerDamaged(healthBase,health + -healthChange,health);
               }
               if(Boolean(playerAvatarView))
               {
                  ai = gMainFrame.userInfo.getAvatarInfoByUserName(playerAvatarView.userName);
                  ai.questHealthPercentage = healthPercent;
                  ai.healthBase = healthBase;
                  if(ai.isDead && healthPercent > 0)
                  {
                     ai.isDead = false;
                     playerAvatarView.playAnim(LayerAnim.AN_IDLE_NE);
                  }
               }
               if(healthChange < 0)
               {
                  playerData.handleHit(healthChange);
               }
               else
               {
                  playerData.handleHealing(healthChange);
               }
            }
            if(Boolean(playerAvatarView))
            {
               if(isRespawn && playerAvatarView != AvatarManager.playerAvatarWorldView)
               {
                  posX = int(inParams[paramIndex++]);
                  posY = int(inParams[paramIndex++]);
                  playerAvatarView.setPos(posX,posY,false);
               }
               if(healthPercent > 0)
               {
                  playerAvatarView.holdAnimId = 0;
               }
               playerAvatarView.updateNameBarHealth(healthPercent);
               if(sfsUserId == gMainFrame.server.userId)
               {
                  GuiManager.setQuestHearts(healthPercent);
               }
            }
         }
      }
      
      public static function handleQuestSetPath(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var actorName:String = inParams[paramIndex++];
         var pathName:String = inParams[paramIndex++];
         var actorData:QuestActor = _questActors[actorName];
         var actorDataMaster:Object = _questActorDictionary[actorName];
         if(actorDataMaster != null)
         {
            actorDataMaster.pathName = pathName;
         }
         if(actorData != null)
         {
            actorData.setPath(pathName);
         }
      }
      
      public static function handleQuestVolumeInteractionUpdate(inParams:Object) : void
      {
         var actorDataMaster:Object = null;
         var layers:Array = null;
         var layer:Object = null;
         var paramIndex:int = 2;
         var linkedTileName:String = inParams[paramIndex++];
         var progressPercent:int = int(inParams[paramIndex++]);
         actorDataMaster = _questActorDictionary[linkedTileName];
         if(actorDataMaster != null)
         {
            if(actorDataMaster.progress == 0 && progressPercent > 0)
            {
               playSound("ajq_chainstart");
            }
            if(progressPercent > actorDataMaster.progress)
            {
               if(_progressingSC == null)
               {
                  _progressingSC = playLoopingSound("ajq_chain1lp");
                  if(Boolean(_progressingSCnot))
                  {
                     _progressingSCnot.stop();
                     _progressingSCnot = null;
                  }
               }
               _volumeInteractionProgressing = true;
            }
            else if(progressPercent < actorDataMaster.progress)
            {
               if(_volumeInteractionProgressing)
               {
                  playSound("ajq_chainstop");
               }
               if(_progressingSCnot == null)
               {
                  _progressingSCnot = playLoopingSound("ajq_chain2lp");
                  if(Boolean(_progressingSC))
                  {
                     _progressingSC.stop();
                     _progressingSC = null;
                  }
               }
               _volumeInteractionProgressing = false;
            }
            if(progressPercent == 100 && Boolean(_progressingSC))
            {
               _progressingSC.stop();
               _progressingSC = null;
               playSound("ajq_phoenixstinger");
            }
            if(progressPercent == 0 && Boolean(_progressingSCnot))
            {
               _progressingSCnot.stop();
               _progressingSCnot = null;
            }
            actorDataMaster.progress = progressPercent;
            layers = RoomManagerWorld.instance.findLayers(linkedTileName);
            if(layers != null)
            {
               for each(layer in layers)
               {
                  if(layer.s != null && layer.s.content != null)
                  {
                     if(Boolean(layer.s.content.hasOwnProperty("setProgress")))
                     {
                        layer.s.content.setProgress(actorDataMaster.progress);
                     }
                  }
               }
            }
         }
      }
      
      public static function handleQuestRoomChange(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var playerSfsId:int = int(inParams[paramIndex++]);
         var roomNameId:String = inParams[paramIndex++];
         var avatarX:int = int(inParams[paramIndex++]);
         var avatarY:int = int(inParams[paramIndex++]);
         AvatarManager.setOffScreenMapBySfsId(playerSfsId,new Point(avatarX,avatarY),roomNameId);
         if(_questPlayersDict[playerSfsId] != null)
         {
            _questPlayersDict[playerSfsId].playerLeftRoom();
         }
      }
      
      public static function handlePlayerLeftQuest(inParams:Object) : void
      {
         var ai:AvatarInfo = null;
         var currLeftObj:Object = null;
         var i:int = 0;
         var paramIndex:int = 2;
         var playerSfsId:int = int(inParams[paramIndex++]);
         var avtName:String = inParams[paramIndex++];
         var playerAvatarView:AvatarWorldView = AvatarManager.avatarViewList[playerSfsId];
         if(Boolean(playerAvatarView))
         {
            ai = gMainFrame.userInfo.getAvatarInfoByUserName(playerAvatarView.userName);
            ai.questTorchStatus = false;
         }
         AvatarManager.removeAvatar(playerSfsId,true);
         if(AvatarManager.playerSfsUserId != playerSfsId)
         {
            for(i = 0; i < _playerLeftObjects.length; i++)
            {
               currLeftObj = _playerLeftObjects[i];
               if(!currLeftObj.hasLeft)
               {
                  currLeftObj.icon.txtMc.txt.autoSize = TextFieldAutoSize.CENTER;
                  LocalizationManager.translateIdAndInsert(currLeftObj.icon.txtMc.txt,11393,LocalizationManager.translateAvatarName(avtName));
                  currLeftObj.icon.x = MainFrame.VIEW_WIDTH * 0.5;
                  if(i != 0 && !_playerLeftObjects[i - 1].complete)
                  {
                     _playerLeftObjects[i - 1].icon.y -= currLeftObj.icon.height * i;
                  }
                  currLeftObj.icon.y = MainFrame.VIEW_HEIGHT * 0.5;
                  GuiManager.guiLayer.addChild(currLeftObj.icon);
                  currLeftObj.icon.startLeaveText(onLeaveTextComplete,i);
                  currLeftObj.hasLeft = true;
                  break;
               }
            }
         }
         if(GuiManager.mainHud.playersCont != null)
         {
            if(Boolean(GuiManager.mainHud.playersCont.visible))
            {
               onQuestPlayersBtn(null);
            }
         }
      }
      
      private static function onLeaveTextComplete(passback:Object) : void
      {
         _playerLeftObjects[passback].complete = true;
      }
      
      public static function handleGiveSeed(inSeedPackId:int, inTotalInventory:int, inventoryMax:int) : void
      {
         var questInventory:Object = _questSeeds[inSeedPackId];
         if(questInventory == null)
         {
            questInventory = new Object();
         }
         if(questInventory.count == inventoryMax - 1 && inTotalInventory > questInventory.count)
         {
            playSound("ajq_boomSeedPluck");
         }
         questInventory.count = inTotalInventory;
         questInventory.max = inventoryMax;
         _questSeeds[inSeedPackId] = questInventory;
         _seedInventory.rebuildInventory(_questSeeds);
      }
      
      public static function handlePlantEatRecoil(inActorName:String) : void
      {
         var actorData:QuestActor = _questActors[inActorName];
         if(actorData != null)
         {
            actorData.recoil();
         }
      }
      
      public static function handlePlaySwf(mediaItemItemId:int) : void
      {
         if(mediaItemItemId == 2607)
         {
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_FRE)
            {
               mediaItemItemId = 2718;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
            {
               mediaItemItemId = 2736;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_DE)
            {
               mediaItemItemId = 2761;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
            {
               mediaItemItemId = 2913;
            }
         }
         var mh:MediaHelper = new MediaHelper();
         mh.init(mediaItemItemId,onPlaySwfLoaded,true);
         startFadeOut();
      }
      
      public static function handleFade(fadeIn:Boolean) : void
      {
         if(fadeIn)
         {
            _queueFadeIn = true;
         }
         else
         {
            startFadeOut();
         }
      }
      
      public static function handlPreloadSwf(mediaItemItemId:int) : void
      {
         var mh:MediaHelper = new MediaHelper();
         mh.init(mediaItemItemId);
      }
      
      public static function handleAward(awardId:int, triggerAmount:int) : void
      {
         var mh:MediaHelper = null;
         if(awardId == 78)
         {
            mh = new MediaHelper();
            mh.init(56,onColorMeRad);
         }
         else
         {
            AchievementXtCommManager.requestSetUserVar(awardId,triggerAmount);
         }
      }
      
      private static function onColorMeRad(img:MovieClip) : void
      {
         GuiManager.guiLayer.addChild(img);
         AJAudio.playAchievementSound();
         setTimeout(onRemoveColorMeRad,2000,img);
      }
      
      private static function onRemoveColorMeRad(img:MovieClip) : void
      {
         GuiManager.guiLayer.removeChild(img);
      }
      
      public static function handlePostUri(uri:String) : void
      {
         SBTracker.trackPageview(uri);
      }
      
      public static function handleShake(inMilliseconds:Number) : void
      {
         _shaketimer = inMilliseconds / 1000;
      }
      
      private static function onPlaySwfLoaded(theMC:MovieClip) : void
      {
         _playSwfMC = theMC;
      }
      
      private static function playSwf() : void
      {
         var tempClass:Class = null;
         var sfxClassName:String = null;
         var volume:Number = NaN;
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
            sfxClassName = _playSwfMC.playSoundOnLoad;
            if(Boolean(sfxClassName) && sfxClassName != "")
            {
               volume = 0.49;
               if(_playSwfMC.hasOwnProperty("playSoundOnLoadVolume"))
               {
                  volume = Number(_playSwfMC.playSoundOnLoadVolume);
               }
               tempClass = _playSwfMC.loaderInfo.applicationDomain.getDefinition(sfxClassName) as Class;
               _soundMan.addSound(tempClass,volume,sfxClassName);
               _playSwfMCSC = _soundMan.play(tempClass);
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
      
      public static function handleActorIcon(inActorName:String, inIconShow:String) : void
      {
         var actorData:QuestActor = null;
         var actorDataMaster:Object = _questActorDictionary[inActorName];
         if(actorDataMaster != null)
         {
            actorDataMaster.iconShowing = inIconShow == "1";
            actorData = _questActors[inActorName];
            if(actorData != null)
            {
               actorData.updateIcon(actorDataMaster.iconShowing);
            }
         }
      }
      
      public static function handleQuestTorch(inParams:Object) : void
      {
         var actorName:String = null;
         var actorDataMaster:Object = null;
         var layers:Array = null;
         var layer:Object = null;
         var actorData:QuestActor = null;
         var playerSfsId:int = 0;
         var playerAvatarView:AvatarWorldView = null;
         var ai:AvatarInfo = null;
         var paramIndex:int = 2;
         var lightOnActor:Boolean = inParams[paramIndex++] == 0;
         var lightOn:Boolean = inParams[paramIndex++] == 1;
         if(lightOnActor)
         {
            actorName = inParams[paramIndex++];
            actorDataMaster = _questActorDictionary[actorName];
            if(actorDataMaster != null)
            {
               actorDataMaster.torchEnabled = lightOn;
               if(actorDataMaster.type == QuestActor.QUEST_ACTOR_TYPE_TILE)
               {
                  layers = RoomManagerWorld.instance.findLayers(actorName);
                  if(layers != null)
                  {
                     for each(layer in layers)
                     {
                        if(lightOn)
                        {
                           addTorch(layer);
                        }
                        else
                        {
                           removeTorch(layer);
                        }
                     }
                  }
               }
               else
               {
                  actorData = _questActors[actorName];
                  if(actorData != null)
                  {
                     actorData.updateTorch();
                  }
               }
            }
         }
         else
         {
            playerSfsId = int(inParams[paramIndex++]);
            playerAvatarView = AvatarManager.avatarViewList[playerSfsId];
            if(Boolean(playerAvatarView))
            {
               ai = gMainFrame.userInfo.getAvatarInfoByUserName(playerAvatarView.userName);
               ai.questTorchStatus = lightOn;
               if(lightOn)
               {
                  addTorch(playerAvatarView,QUEST_TORCH_LITSIZE,-15,-50);
               }
               else
               {
                  removeTorch(playerAvatarView);
               }
            }
         }
      }
      
      public static function handlePickGift(inParams:Object) : void
      {
         var prize:Object = null;
         var i:int = 0;
         var type:int = 0;
         var data1:int = 0;
         var data2:int = 0;
         var key:Object = null;
         var actorDataMaster:Object = null;
         var prizes:Array = new Array();
         var paramIndex:int = 2;
         var prizeCount:int = int(inParams[paramIndex++]);
         var actorDataMax:Object = _questActorDictionary["gui_goal1a"];
         if(getAdventureType() == QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT && actorDataMax != null && _playerOrbCountTotal < actorDataMax.state)
         {
            prize = new Object();
            prize.type = 3;
            prize.amount = 150;
            prizes.push(prize);
            for(i = 1; i < prizeCount; i++)
            {
               prize = new Object();
               prize.type = 0;
               prizes.push(prize);
            }
         }
         else
         {
            for(i = 0; i < prizeCount; i++)
            {
               prize = new Object();
               type = int(inParams[paramIndex++]);
               data1 = int(inParams[paramIndex++]);
               data2 = int(inParams[paramIndex++]);
               prize.type = type;
               switch(prize.type)
               {
                  case 1:
                     prize.defID = data1;
                     break;
                  case 2:
                     prize.defID = data1;
                     prize.color = data2;
                     break;
                  case 3:
                     prize.amount = data1;
                     break;
                  case 4:
                     prize.amount = data1;
               }
               prizes.push(prize);
            }
         }
         _mediaLoader = new MediaHelper();
         var adventureType:int = getAdventureType();
         if(Boolean(_adventureGoals) || adventureType == QUEST_ADVENTURE_TYPE_MEMBER_PRIZE_SUPPORT)
         {
            if(Boolean(_adventureRewardsPopup))
            {
               updateRewardsDisplay(prizes);
            }
            else
            {
               _mediaLoader.init(ADVENTURE_GOAL_REWARDS_ID,onAdventureGoalRewardsLoaded,prizes);
            }
         }
         else if(Boolean(_adventureRewardsPopup))
         {
            updateAdventureRewards(prizes);
         }
         else
         {
            _mediaLoader.init(ADVENTURE_REWARDS_ID,onAdventureRewardsLoaded,prizes);
         }
         if(adventureType == QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT)
         {
            for(key in _questActors)
            {
               if(_questActors[key]._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DROPPED_TREASURE)
               {
                  actorDataMaster = _questActorDictionary[key];
                  if(actorDataMaster != null)
                  {
                     actorDataMaster.healthPercent = 0;
                  }
                  _questActors[key].destroy();
                  delete _questActors[key];
               }
            }
         }
      }
      
      public static function handleBeamZap(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var actorName:String = inParams[paramIndex++];
         var playerSfsId:int = int(inParams[paramIndex++]);
         var actorData:QuestActor = _questActors[actorName];
         if(actorData != null)
         {
            actorData.handleBeamZap(playerSfsId);
         }
      }
      
      public static function handleDropOrb(inParams:Object) : void
      {
         var playerData:QuestPlayerData = null;
         var paramIndex:int = 2;
         var actorName:String = inParams[paramIndex++];
         var playerSfsId:int = int(inParams[paramIndex++]);
         var origOrbsCollected:int = int(inParams[paramIndex++]);
         var currentOrbsCollected:int = int(inParams[paramIndex++]);
         var actorData:QuestActor = _questActors[actorName];
         if(actorData != null)
         {
            actorData.handlePhantomZap(playerSfsId);
         }
         if(origOrbsCollected > currentOrbsCollected)
         {
            playerData = getQuestPlayerData(playerSfsId);
            if(playerData != null)
            {
               playerData.dropOrb();
            }
         }
      }
      
      public static function handlePhantomZap(inParams:Object) : void
      {
         var paramIndex:int = 2;
         var actorName:String = inParams[paramIndex++];
         var playerSfsId:int = int(inParams[paramIndex++]);
         var actorData:QuestActor = _questActors[actorName];
         if(actorData != null)
         {
            actorData.handlePhantomZap(playerSfsId);
         }
      }
      
      public static function handlePlantAte(inPlantName:String, inPhantomName:String) : void
      {
         var actorData:QuestActor = _questActors[inPlantName];
         var actorDataMaster:Object = _questActorDictionary[inPlantName];
         if(actorDataMaster != null)
         {
            actorDataMaster.plantEaten = true;
         }
         if(actorData != null)
         {
            actorData.setPlantEats(_questActors[inPhantomName]);
         }
      }
      
      public static function handlePlantSeed(inParams:Object) : void
      {
         var actorName:String = null;
         var actorDefId:int = 0;
         var actorX:int = 0;
         var actorY:int = 0;
         var actorData:Object = null;
         var paramIndex:int = 2;
         var seedPlanted:Boolean = inParams[paramIndex++] == "1";
         var userName:String = inParams[paramIndex++];
         if(seedPlanted)
         {
            actorName = inParams[paramIndex++];
            actorDefId = int(inParams[paramIndex++]);
            actorX = int(inParams[paramIndex++]);
            actorY = int(inParams[paramIndex++]);
            actorData = new Object();
            actorData.visible = true;
            actorData.requireClick = false;
            actorData.type = QuestActor.QUEST_ACTOR_TYPE_PLANT;
            actorData.defId = actorDefId;
            actorData.state = 0;
            actorData.actorName = actorName;
            initInitialActorStatus(actorData,null);
            actorData.actorPos = new Point(actorX,actorY);
            _questActorDictionary[actorName] = actorData;
            initQuestActor(actorData.actorName,0,100,actorData,null,null);
         }
         if(Boolean(_seedInventory) && userName == gMainFrame.userInfo.myUserName)
         {
            _seedInventory.removeLastDraggedSeed();
         }
      }
      
      public static function handleQuestPlayerDead(inParams:Object) : void
      {
         var playerAvatarView:AvatarWorldView = null;
         var ai:AvatarInfo = null;
         var tempXValue:String = null;
         var tempYValue:String = null;
         var currRoom:String = null;
         var paramIndex:int = 2;
         var sfsUserId:int = int(inParams[paramIndex++]);
         playerAvatarView = AvatarManager.avatarViewList[sfsUserId];
         if(Boolean(playerAvatarView))
         {
            ai = gMainFrame.userInfo.getAvatarInfoByUserName(playerAvatarView.userName);
            if(ai != null)
            {
               ai.isDead = true;
            }
            if((playerAvatarView.avatarData.enviroTypeFlag & 1 << Utility.ENVIRO_LAND) != 0 || Boolean(playerAvatarView.avatarData.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
            {
               playerAvatarView.playAnim(LayerAnim.AN_SLEEP);
               playerAvatarView.holdAnimId = LayerAnim.AN_SLEEP;
            }
            else
            {
               playerAvatarView.playAnim(LayerAnim.AN_WATER_POSE);
               playerAvatarView.holdAnimId = LayerAnim.AN_WATER_POSE;
            }
            if(playerAvatarView == AvatarManager.playerAvatarWorldView)
            {
               tempXValue = uint(playerAvatarView.avatarPos.x).toString(16);
               tempYValue = uint(playerAvatarView.avatarPos.y).toString(16);
               while(tempXValue.length < 8)
               {
                  tempXValue = "0" + tempXValue;
               }
               while(tempYValue.length < 8)
               {
                  tempYValue = "0" + tempYValue;
               }
               currRoom = gMainFrame.server.getCurrentRoomName().split(".")[1];
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#death/" + currRoom + "#null#x" + tempXValue + tempYValue);
               RoomManagerWorld.instance.forceStopMovement();
               _defeatedPopUpTimer = 2;
               playSound("ajq_playerdeath");
               if(Boolean(_seedInventory))
               {
                  _seedInventory.removeLastDraggedSeed();
               }
            }
         }
      }
      
      public static function handleSwipe(inParams:Object) : void
      {
         var itemID:int = 0;
         var aimX:int = 0;
         var aimY:int = 0;
         var actorID:String = null;
         var sfsUserID:int = 0;
         var weaponColor:uint = 0;
         var actorData:QuestActor = null;
         var playerAvatarView:AvatarWorldView = null;
         var paramIndex:int = 2;
         itemID = int(inParams[paramIndex++]);
         aimX = int(inParams[paramIndex++]);
         aimY = int(inParams[paramIndex++]);
         actorID = inParams[paramIndex++];
         sfsUserID = int(inParams[paramIndex++]);
         weaponColor = uint(inParams[paramIndex++]);
         actorData = null;
         playerAvatarView = null;
         if(sfsUserID > 0)
         {
            playerAvatarView = AvatarManager.avatarViewList[sfsUserID];
            if(playerAvatarView == null)
            {
               return;
            }
            playerAvatarView.faceAnim(aimX - playerAvatarView.avatarPos.x,aimY - playerAvatarView.avatarPos.y,false);
         }
         else
         {
            actorData = _questActors[actorID];
         }
         swipeMelee(itemID,weaponColor,aimX,aimY,actorData,playerAvatarView);
      }
      
      public static function handleActorDeath(inParams:Object) : void
      {
         var actorData:QuestActor = null;
         var actorID:String = null;
         var damage:int = 0;
         var actorDataMaster:Object = null;
         var bSetPosition:Boolean = false;
         var posX:int = 0;
         var posY:int = 0;
         var linkActorId:String = null;
         var linkMaster:Object = null;
         var linkActorData:QuestActor = null;
         var paramIndex:int = 2;
         actorID = inParams[paramIndex++];
         actorDataMaster = _questActorDictionary[actorID];
         actorData = _questActors[actorID];
         damage = int(inParams[paramIndex++]);
         bSetPosition = inParams[paramIndex++] == "1";
         posX = int(inParams[paramIndex++]);
         posY = int(inParams[paramIndex++]);
         linkActorId = inParams[paramIndex++];
         if(linkActorId != "")
         {
            linkMaster = _questActorDictionary[linkActorId];
            if(linkMaster != null)
            {
               linkMaster.actorPos = new Point(posX,posY);
            }
            linkActorData = _questActors[linkActorId];
            if(linkActorData != null)
            {
               linkActorData.x = posX;
               linkActorData.y = posY;
               linkActorData.handlePositionUpdate(posX,posY,0,QuestActor.SEEKTYPE_OFF,0,0);
            }
         }
         if(actorDataMaster != null)
         {
            actorDataMaster.healthPercent = 0;
         }
         if(actorData != null)
         {
            if(bSetPosition)
            {
               actorData.x = posX;
               actorData.y = posY;
               actorData.handlePositionUpdate(posX,posY,0,QuestActor.SEEKTYPE_OFF,0,0);
            }
            if(actorData.handleDeath(damage))
            {
               actorData.destroy();
               delete _questActors[actorID];
            }
         }
      }
      
      public static function onQuestExit(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(LocalizationManager.ADVENTURE_CONFIRMEXIT),true,onLeaveQuestConfirm);
      }
      
      private static function onDropItemConfirm(o:Object) : void
      {
         if(Boolean(o.status))
         {
            QuestXtCommManager.sendQuestDropItem(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y,o.passback);
         }
      }
      
      private static function onLeaveQuestConfirm(o:Object) : void
      {
         if(Boolean(o.status))
         {
            commandExit(0,null);
         }
      }
      
      private static function onDeathAccept(o:Object) : void
      {
         var x:int = 0;
         var y:int = 0;
         if(Boolean(o.status))
         {
            x = 0;
            y = 0;
            QuestXtCommManager.sendQuestPlayerRequestRespawn(0,_nearestRespawnPoint != null ? int(_nearestRespawnPoint.pos.x) : int(AvatarManager.playerAvatarWorldView.x),_nearestRespawnPoint != null ? int(_nearestRespawnPoint.pos.y) : int(AvatarManager.playerAvatarWorldView.y));
         }
         else
         {
            commandExit(0,null);
         }
      }
      
      public static function respawnPlayer() : void
      {
         var cameraFocus:Point = null;
         if(_nearestRespawnPoint != null)
         {
            cameraFocus = new Point(RoomManagerWorld.instance.scrollOffset.x,RoomManagerWorld.instance.scrollOffset.y);
            RoomManagerWorld.instance.teleportPlayer(_nearestRespawnPoint.pos.x,_nearestRespawnPoint.pos.y,true);
            RoomManagerWorld.instance.setCameraFocus(cameraFocus,0,0,1,false);
            playSound("ajq_respawn");
         }
      }
      
      public static function handleQuestPlayerRequestRespawn(inParams:Object) : void
      {
         respawnPlayer();
      }
      
      private static function onNotEnoughGems(o:Object) : void
      {
         commandExit(0,null);
      }
      
      private static function startNowHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(Boolean(m.currentTarget.isGray))
         {
            return;
         }
         QuestXtCommManager.sendQuestStartRequest();
      }
      
      public static function closeAdventurePopups() : void
      {
         if(Boolean(_adventureJoin))
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
      
      private static function onPopupOK(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBOkPopup.destroyInParentChain(evt.target.parent);
      }
      
      public static function set npcDefs(o:Object) : void
      {
         _npcDefs = o;
      }
      
      public static function getNPCDef(defId:int) : Object
      {
         if(Boolean(_npcDefs))
         {
            return _npcDefs[defId];
         }
         return null;
      }
      
      public static function questRoomJoined(inJoined:Boolean) : void
      {
         _inQuestRoom = inJoined;
         if(inJoined)
         {
            QuestXtCommManager.sendQuestMovedItemsRequest();
            loadQuestSfx(1970,onGlobalSfxLoaded);
         }
      }
      
      private static function onTimerLoaded(img:MovieClip) : void
      {
         var actorData:Object = null;
         var timerValue:Number = NaN;
         actorData = _questActorDictionary["gui_timer"];
         timerValue = actorData != null ? actorData.state / 60 : 0;
         GuiManager.guiLayer.addChild(img);
         img.x = 400;
         img.y = 50;
         _adventureTimer = img;
         _adventureTimer.clock.clockText_1.text = timerValue;
         _adventureTimer.clock.clockText_2.text = "00";
         _adventureTimer.time = timerValue;
         if(timerValue == 0)
         {
            _adventureTimer.visible = false;
         }
      }
      
      private static function onGuiGoalLoaded(img:MovieClip) : void
      {
         var goalIndex:int = 0;
         var goalNameValue:String = null;
         var actorDataValue:Object = null;
         var goalNameMax:String = null;
         var actorDataMax:Object = null;
         goalIndex = int(img.passback.goalId);
         goalNameValue = "gui_goal" + goalIndex;
         actorDataValue = _questActorDictionary[goalNameValue];
         goalNameMax = "gui_goal" + goalIndex + "a";
         actorDataMax = _questActorDictionary[goalNameMax];
         if(Boolean(actorDataValue) && Boolean(actorDataMax))
         {
            img.setState(goalIndex);
            switch(getAdventureType())
            {
               case QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:
                  img.setQuestType(2);
                  img.setValue(_playerOrbCount);
                  img.setMaxValue(0);
                  break;
               default:
                  img.setValue(actorDataValue.state);
                  img.setMaxValue(actorDataMax.state);
            }
            GuiManager.guiLayer.addChild(img);
            img.x = 20;
            img.y = 25 + 50 * (goalIndex - 1);
            if(_adventureGoals == null)
            {
               _adventureGoals = new Array();
            }
            _adventureGoals[goalIndex] = img;
         }
      }
      
      public static function playerLaunchWeapon(inTarget:Point, inProjectile:Boolean) : Number
      {
         var returnAngle:Number = NaN;
         var ai:AvatarInfo = null;
         var activeWeaponObject:Object = null;
         returnAngle = 0;
         ai = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
         if(_playerWeaponTimerProjectile <= 0 && ai != null && ai.questHealthPercentage > 0)
         {
            activeWeaponObject = getPlayerActiveWeapon(inProjectile);
            _playerWeaponTimerProjectile = 0.5;
            if(inProjectile)
            {
               returnAngle = launchProjectile(activeWeaponObject.itemDefId,activeWeaponObject.color,inTarget.x,inTarget.y,null,AvatarManager.playerAvatarWorldView);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["dm","attack with weapon, ranged"]);
               }
            }
            else
            {
               returnAngle = swipeMelee(activeWeaponObject.itemDefId,activeWeaponObject.color,inTarget.x,inTarget.y,null,AvatarManager.playerAvatarWorldView);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["dm","attack with weapon, melee"]);
               }
            }
         }
         return returnAngle;
      }
      
      public static function launchProjectile(inItemDefId:int, inColors:uint, inX:Number, inY:Number, inNPC:QuestActor, inPlayerAvatarView:AvatarView) : Number
      {
         var returnAngle:Number = NaN;
         var qp:QuestProjectile = null;
         var isValid:Boolean = false;
         returnAngle = 0;
         if(inItemDefId != 0)
         {
            qp = null;
            if(qp == null)
            {
               qp = new QuestProjectile();
               isValid = qp.launch(inItemDefId,inColors,_layerManager.room_chat,inX,inY,inNPC,inPlayerAvatarView);
            }
            else
            {
               isValid = qp.relaunch(inItemDefId,inColors,_layerManager.room_chat,inX,inY,inNPC,inPlayerAvatarView);
            }
            if(isValid)
            {
               returnAngle = qp.angle;
               _questProjectiles.push(qp);
            }
         }
         return returnAngle;
      }
      
      public static function swipeMelee(inItemDefId:int, inColors:uint, inX:Number, inY:Number, inNPC:QuestActor, inPlayerAvatarView:AvatarView) : Number
      {
         var returnAngle:Number = NaN;
         var qm:QuestMelee = null;
         returnAngle = 0;
         if(inItemDefId != 0)
         {
            qm = new QuestMelee(_currentMeleeID++);
            if(qm.swipe(inItemDefId,inColors,_layerManager.room_chat,inX,inY,inNPC,inPlayerAvatarView))
            {
               returnAngle = qm.angle;
               _questMelees.push(qm);
            }
         }
         return returnAngle;
      }
      
      public static function getPlayerActiveWeapon(inProjectileType:Boolean) : Object
      {
         var weaponItem:Item = null;
         var returnObject:Object = null;
         var playerItems:Array = null;
         var i:int = 0;
         var anItem:Item = null;
         var weaopnItemDef:Object = null;
         weaponItem = null;
         if(!isBeYourPetQuest())
         {
            playerItems = AvatarManager.playerAvatar.inventoryClothing.itemArray;
            for(i = 0; i < playerItems.length; i++)
            {
               anItem = playerItems[i];
               if(anItem.getInUse(AvatarManager.playerAvatar.perUserAvId) && anItem.attackMediaRefId != 0)
               {
                  if(inProjectileType && anItem.combatType == QUEST_WEAPON_TYPE_PROJECTILE || inProjectileType == false && anItem.combatType == QUEST_WEAPON_TYPE_MELEE)
                  {
                     if(weaponItem == null || weaponItem.attack < anItem.attack)
                     {
                        weaponItem = anItem;
                     }
                  }
               }
            }
         }
         returnObject = new Object();
         if(weaponItem == null)
         {
            returnObject.itemDefId = inProjectileType ? QUEST_WEAPON_DEFAULT_PROJECTILE : QUEST_WEAPON_DEFAULT_MELEE;
            weaopnItemDef = ItemXtCommManager.getItemDef(returnObject.itemDefId);
            if(weaopnItemDef != null)
            {
               returnObject.color = weaopnItemDef.colors[0];
            }
            else
            {
               returnObject.color = 0;
            }
         }
         else
         {
            returnObject.itemDefId = weaponItem.defId;
            returnObject.color = weaponItem.color;
         }
         return returnObject;
      }
      
      public static function handleQuestMiniGameComplete(gameResult:int) : void
      {
         if(_questCommandActor != "" && _questCommandActorState != -1)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["dm","quest minigame complete, actor:" + _questCommandActor + " actorState:" + _questCommandActorState + " gameResult:" + gameResult]);
            }
            QuestXtCommManager.questMiniGameComplete(_questCommandActor,_questCommandActorState,gameResult);
            _questCommandActor = null;
            _questCommandActorState = -1;
         }
      }
      
      public static function stopItemEmoticonSound(inAvatarWorldView:AvatarWorldView) : void
      {
         var key:Object = null;
         var player:QuestPlayerData = null;
         for(key in _questPlayersDict)
         {
            player = _questPlayersDict[key];
            if(player != null && player._avatarWorldView == inAvatarWorldView)
            {
               player.stopItemEmoticonSound();
               break;
            }
         }
      }
      
      public static function playItemEmoticonSound(inAvatarWorldView:AvatarWorldView, sound:String) : void
      {
         var key:Object = null;
         var player:QuestPlayerData = null;
         for each(player in _questPlayersDict)
         {
            if(player != null && player._avatarWorldView == inAvatarWorldView)
            {
               player.playItemEmoticonSound(sound);
               break;
            }
         }
      }
      
      public static function onQuestPlayersBtn(evt:MouseEvent) : void
      {
         var containerWindow:MovieClip = null;
         var allUsersInMyRoom:Object = null;
         var usersNeededInfo:Array = null;
         var a:Object = null;
         if(evt == null || !evt.currentTarget.isGray)
         {
            containerWindow = GuiManager.mainHud.playersCont;
            if(evt != null && containerWindow.visible)
            {
               containerWindow.visible = false;
               return;
            }
            containerWindow.visible = true;
            if(Boolean(GuiManager.mainHud.miniMap.visible))
            {
               GuiManager.mainHud.miniMap.visible = false;
               GuiManager.mainHud.miniMap_btnQuest.downToUpState();
            }
            if(Boolean(_playersWindow))
            {
               _playersWindow.destroy();
               _playersWindow = null;
            }
            allUsersInMyRoom = AvatarManager.adventurePlayerData;
            usersNeededInfo = [];
            for each(a in allUsersInMyRoom)
            {
               if(a.userName != gMainFrame.userInfo.myUserName)
               {
                  usersNeededInfo.push({
                     "isMember":a.isMember,
                     "nameBarData":a.nameBarData,
                     "userName":a.userName,
                     "avName":a.avName,
                     "isBuddy":BuddyManager.isBuddy(a.userName),
                     "isBlocked":BuddyManager.isBlocked(a.userName)
                  });
               }
            }
            if(usersNeededInfo.length > 0)
            {
               while(containerWindow.itemWindow.numChildren > 0)
               {
                  containerWindow.itemWindow.removeChildAt(0);
               }
               _playersWindow = new WindowGenerator();
               _playersWindow.init(1,usersNeededInfo.length,usersNeededInfo.length,0,0,0,ItemWindowNameBar,null,"",{
                  "mouseDown":onSelectPlayer,
                  "mouseOver":null,
                  "mouseOut":null
               },usersNeededInfo,onReportWindowsLoaded);
            }
            else
            {
               containerWindow.visible = false;
               GuiManager.mainHud.questPlayersBtn.downToUpState();
               GuiManager.mainHud.questPlayersBtn.activateGrayState(true);
            }
         }
      }
      
      private static function onReportWindowsLoaded() : void
      {
         var needsScrollbar:Boolean;
         var i:int = 0;
         var containerWindow:MovieClip = null;
         var maxHeight:int = 0;
         for(i = 0; i < _playersWindow.bg.numChildren; i++)
         {
            ItemWindowNameBar(_playersWindow.bg.getChildAt(i)).updateToBeCentered(_playersWindow.width);
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
      
      public static function validatePlantSeedLocation(inLocation:Point) : Boolean
      {
         var questActor:QuestActor = null;
         var nearestPlant:QuestActor = null;
         for each(questActor in _questActors)
         {
            if(questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_VOLUMEPLACEMENT)
            {
               if(questActor.testPointInActorVolumes(inLocation))
               {
                  nearestPlant = getNearestPlant(inLocation.x,inLocation.y,75,999999);
                  if(nearestPlant != null)
                  {
                     return false;
                  }
                  return true;
               }
            }
         }
         return false;
      }
      
      private static function onSelectPlayer(evt:MouseEvent) : void
      {
         var player:Object = null;
         evt.stopPropagation();
         player = {
            "userName":evt.currentTarget.userName,
            "onlineStatus":SFClient.STATUS_ONLINE
         };
         BuddyCard.showBuddyCard(player);
      }
      
      private static function resetMouseMoveIdleTimer(event:MouseEvent) : void
      {
         if(_kickPopup == null)
         {
            _gameIdleTimer = 0;
         }
      }
      
      private static function resetMouseDownIdleTimer(evt:Event) : void
      {
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
      }
      
      private static function onKickWarningPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBOkPopup.destroyInParentChain(evt.target.parent);
         _kickPopup = null;
         _gameIdleTimer = 0;
      }
      
      private static function adventureJoinClose() : void
      {
         if(Boolean(_adventureJoin))
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
      
      private static function onAdventureSelectLoaded(img:MovieClip = null) : void
      {
         var numItemsInCurrentArray:int = 0;
         if(Boolean(img))
         {
            DarkenManager.showLoadingSpiral(false);
            _adventureSelectPopup = MovieClip(img.getChildAt(0));
         }
         if(Boolean(_adventureSelectPopup))
         {
            if(Boolean(_availableScriptDefs))
            {
               _adventureSelectPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onAdventureSelectClose,false,0,true);
               if(Boolean(_adventureSelectScrollBar))
               {
                  _adventureSelectScrollBar.destroy();
                  _adventureSelectScrollBar = null;
               }
               if(Boolean(_adventureSelectItemWindow))
               {
                  _adventureSelectItemWindow.destroy();
                  _adventureSelectItemWindow = null;
               }
               numItemsInCurrentArray = Math.min(_availableScriptDefs.length,20);
               _adventureSelectItemWindow = new WindowGenerator();
               _adventureSelectItemWindow.init(1,numItemsInCurrentArray,numItemsInCurrentArray,0,3,0,ItemWindowAdventure,null,"",{"mouseDown":adventureMouseDown},{"scriptIds":_availableScriptDefs},onAdventureWindowsLoaded,false,false);
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
      
      private static function adventureMouseDown(evt:MouseEvent) : void
      {
         var funcObject:Object = null;
         evt.stopPropagation();
         funcObject = evt.currentTarget.performContinueChecks();
         if(funcObject != null)
         {
            onAdventureSelectClose(evt);
            funcObject.func(funcObject.defId);
            funcObject = null;
         }
      }
      
      private static function onAdventureSelectClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         _adventureSelectScrollBar.destroy();
         _adventureSelectScrollBar = null;
         _adventureSelectItemWindow.destroy();
         _adventureSelectItemWindow = null;
         DarkenManager.unDarken(_adventureSelectPopup);
         GuiManager.guiLayer.removeChild(_adventureSelectPopup);
         _adventureSelectPopup = null;
      }
      
      public static function privateAdventureJoinClose(bJoinCancel:Boolean) : void
      {
         if(Boolean(_privateAdventureJoin))
         {
            if(bJoinCancel)
            {
               QuestXtCommManager.sendQuestJoinCancel();
            }
            UserCommXtCommManager.sendCustomAdventureMessage(false);
            _privateAdventureJoin.destroy();
            _privateAdventureJoin = null;
         }
         GuiManager.setSwapBtnGray(false);
      }
      
      public static function getNearestActorPathInGroupToPlayerInRange(inActor:QuestActor) : Boolean
      {
         var actorGroupNameIndex:int = 0;
         var actorGroupName:String = null;
         var groupArray:Array = null;
         var index:int = 0;
         var actorInGroupName:String = null;
         var actorInGroup:QuestActor = null;
         actorGroupNameIndex = inActor._actorId.lastIndexOf("__");
         if(actorGroupNameIndex != -1)
         {
            actorGroupName = inActor._actorId.substring(0,actorGroupNameIndex);
            groupArray = _questActorGroups[actorGroupName];
            if(groupArray != null)
            {
               for(index = 0; index < groupArray.length; index++)
               {
                  actorInGroupName = groupArray[index];
                  actorInGroup = _questActors[actorInGroupName];
                  if(actorInGroup != null)
                  {
                     if(actorInGroup.pathToPlayerInRange())
                     {
                        return true;
                     }
                  }
               }
            }
            return false;
         }
         return inActor.pathToPlayerInRange();
      }
      
      public static function showLeaveQuestLobbyPopup(... args) : void
      {
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14815),true,onConfirmLeave,args);
      }
      
      private static function onConfirmLeave(o:Object) : void
      {
         var funcToCall:Function = null;
         if(Boolean(o.status))
         {
            privateAdventureJoinClose(true);
            funcToCall = o.passback[0];
            o.passback.splice(0,1);
            funcToCall.apply(null,o.passback);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private static function startShake() : void
      {
         var layer:Object = null;
         if(_layerManager != null)
         {
            layer = _layerManager.bkg;
            _shakeOrigPos = new Point(layer.x,layer.y);
            _soundMan.play(_sounds["ajq_volcanoerupt"]);
         }
      }
      
      private static function stopShake() : void
      {
         var layer:Object = null;
         if(_layerManager != null)
         {
            layer = _layerManager.bkg;
            layer.x = _shakeOrigPos.x;
            layer.y = _shakeOrigPos.y;
         }
         if(Boolean(_screenShakeSC))
         {
            _soundMan.stop(_screenShakeSC);
            _screenShakeSC = null;
         }
         _shakeOrigPos = null;
      }
      
      private static function shake() : void
      {
         var layer:Object = null;
         var amount:int = 0;
         if(_layerManager != null)
         {
            layer = _layerManager.bkg;
            amount = 16;
            layer.x = layer.x + Math.random() * amount - amount / 2;
            layer.y = layer.y + Math.random() * amount - amount / 2;
         }
      }
      
      public static function isPlayerInStealthVolume() : Boolean
      {
         return _playerInStealthVolume || _talkingPopup != null;
      }
      
      public static function currencyUpdate(gemsCollected:int) : void
      {
         if(_questActorDictionary != null)
         {
            _totalGemsEarned += gemsCollected;
            updateQuestActorTool();
         }
      }
      
      public static function onShopClick(volName:String) : Boolean
      {
         var bReturn:Boolean = false;
         var actorName:String = null;
         var actorData:Object = null;
         bReturn = true;
         if(_questActorDictionary != null)
         {
            actorName = "_" + volName;
            actorData = _questActorDictionary[actorName];
            if(actorData.state != 1)
            {
               bReturn = false;
            }
         }
         return bReturn;
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
         var guiIndex:int = 0;
         var avEd:AvatarEditor = null;
         var actorData:Object = null;
         if(_questActorDictionary != null && _questActorDictionary["gui_aved"] != null)
         {
            avEd = GuiManager.avatarEditor;
            if(avEd != null)
            {
               for(guiIndex = 0; guiIndex < _guiElementsAvatarEditor.length; guiIndex += 2)
               {
                  if(Boolean(avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]]))
                  {
                     actorData = _questActorDictionary[_guiElementsAvatarEditor[guiIndex]];
                     if(actorData.state >= 0 && actorData.state <= 2)
                     {
                        if(Boolean(avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]].hasOwnProperty("setButtonState")))
                        {
                           avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]].setButtonState(actorData.state);
                        }
                        avEd.avEditor[_guiElementsAvatarEditor[guiIndex + 1]].addEventListener(MouseEvent.MOUSE_DOWN,avEdDownHandler,false,0,true);
                     }
                  }
               }
            }
            QuestXtCommManager.questActorTriggered("gui_aved");
         }
      }
      
      public static function phantomAttackDestructible(inPhantomAttacker:String, inX:int, inY:int, inRadius:int) : void
      {
         var currentTime:int = 0;
         var questActor:QuestActor = null;
         var actorOffset:Point = null;
         var xDiff:Number = NaN;
         var yDiff:Number = NaN;
         var dist:Number = NaN;
         var maxDistance:int = 0;
         currentTime = getTimer();
         for each(questActor in _questActors)
         {
            if(questActor._visible && !questActor.isDead && questActor._actorData.type == QuestActor.QUEST_ACTOR_TYPE_DESTRUCTIBLE)
            {
               if(questActor._actorData.damageDelay + 2000 < currentTime)
               {
                  actorOffset = questActor.actorOffset;
                  xDiff = inX - (questActor.x + actorOffset.x);
                  yDiff = inY - (questActor.y + actorOffset.y);
                  dist = xDiff * xDiff + yDiff * yDiff;
                  maxDistance = (inRadius + inRadius) * (inRadius + inRadius);
                  if(dist < maxDistance)
                  {
                     QuestXtCommManager.questPhantomAttackDestructible(inPhantomAttacker,questActor._actorId);
                     questActor._actorData.damageDelay = currentTime;
                  }
               }
            }
         }
      }
      
      public static function playerJoinedQuestRoom(inSfsUserID:int) : void
      {
         var npcId:int = 0;
         var playerData:QuestPlayerData = null;
         if(_questActorDictionary != null)
         {
            if(isDynamicallyJoinableQuest())
            {
               if(GuiManager.mainHud.questPlayersBtn != null)
               {
                  GuiManager.mainHud.questPlayersBtn.activateGrayState(false);
                  if(Boolean(GuiManager.mainHud.playersCont.visible))
                  {
                     onQuestPlayersBtn(null);
                  }
               }
            }
            if(_questPlayersSwitched != null)
            {
               if(_questPlayersSwitched[inSfsUserID] != null)
               {
                  npcId = int(_questPlayersSwitched[inSfsUserID]);
                  playerData = getQuestPlayerData(inSfsUserID);
                  if(playerData != null)
                  {
                     playerData.setAvatarSwitched(npcId);
                  }
               }
            }
         }
      }
      
      public static function questPhantomZap(actorId:String, inPlayerSfsId:int, inX:int, inY:int, attackingActor:QuestActor) : void
      {
         if(attackingActor != null && attackingActor.isRunawayFromPlayer())
         {
            questActorAttacked(attackingActor._actorId,-1,0,0,attackingActor);
         }
         else
         {
            QuestXtCommManager.questPhantomZap(actorId,inPlayerSfsId,inX,inY);
         }
      }
      
      public static function questActorAttacked(actorId:String, defId:int, inX:int, inY:int, attackingActor:QuestActor) : void
      {
         if(actorId == "" && attackingActor != null && attackingActor.isRunawayFromPlayer())
         {
            QuestXtCommManager.questActorAttacked(attackingActor._actorId,-1,0,0);
         }
         else
         {
            QuestXtCommManager.questActorAttacked(actorId,defId,inX,inY);
         }
      }
      
      public static function getAdventureType() : int
      {
         var actorData:Object = null;
         actorData = _questActorDictionary["advtype1"];
         if(actorData != null)
         {
            return actorData.state;
         }
         return 0;
      }
      
      public static function livePlayerCount() : int
      {
         var actorData:Object = null;
         actorData = _questActorDictionary["live_players"];
         return actorData == null ? 1 : int(actorData.state);
      }
      
      public static function invokeQuestActorTool() : void
      {
         if(!_questActorToolEnabled)
         {
            if(_questActorToolSortedActorNames != null)
            {
               _questActorToolEnabled = true;
               updateQuestActorTool();
            }
         }
         else
         {
            _questActorToolEnabled = false;
            if(_questActorToolScrollbar != null)
            {
               _questActorToolScrollbar.destroy();
               _questActorToolScrollbar = null;
            }
            if(Boolean(_questActorToolItemWindow) && _questActorToolItemWindow.numChildren > 0)
            {
               _questActorToolItemWindow.destroy();
               _questActorToolItemWindow = null;
            }
         }
      }
      
      public static function updateQuestActorTool() : void
      {
         var actorArray:Array = null;
         var gemsEarned:String = null;
         var xpEarned:String = null;
         var i:int = 0;
         var numItemsInCurrentArray:int = 0;
         var questActor:Object = null;
         var text:String = null;
         var textItem:Object = null;
         if(_questActorToolEnabled)
         {
            if(_questActorToolSortedActorNames != null)
            {
               actorArray = new Array();
               gemsEarned = "Gems Earned: " + _totalGemsEarned;
               xpEarned = "XP Earned: " + _totalXPEarned;
               actorArray.push(_questScriptTimeStamp);
               actorArray.push(gemsEarned);
               actorArray.push(xpEarned);
               for(i = 0; i < _questActorToolSortedActorNames.length; i++)
               {
                  questActor = _questActorDictionary[_questActorToolSortedActorNames[i]];
                  if(questActor != null)
                  {
                     text = _questActorToolSortedActorNames[i] + " State = " + questActor.state;
                     actorArray.push(text);
                  }
               }
               numItemsInCurrentArray = int(actorArray.length);
               if(_questActorToolItemWindow == null)
               {
                  _questActorToolItemWindow = new WindowGenerator();
                  _questActorToolItemWindow.init(1,numItemsInCurrentArray,numItemsInCurrentArray,0,3,0,ItemWindowTextBar,actorArray,"",{"mouseDown":null},null,null,false,false);
                  GuiManager.guiLayer.addChild(_questActorToolItemWindow);
                  _questActorToolScrollbar = new SBScrollbar();
                  _questActorToolScrollbar.init(_questActorToolItemWindow,268,360,0,"scrollbar2",36,_questActorToolScrollIndex,_questActorToolItemWindow.boxHeight * numItemsInCurrentArray + numItemsInCurrentArray * 3);
               }
               else
               {
                  for(i = 0; i < numItemsInCurrentArray; i++)
                  {
                     textItem = _questActorToolItemWindow.bg.getChildAt(i);
                     textItem.setText(actorArray[i]);
                  }
               }
            }
         }
      }
   }
}

