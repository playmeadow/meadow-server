package quest
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import avatar.AvatarXtCommManager;
   import avatar.NPCView;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.input.SBTextField;
   import com.sbi.corelib.math.Collision;
   import com.sbi.graphics.LayerAnim;
   import den.DenItem;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundChannel;
   import flash.utils.Timer;
   import gui.ChatBalloon;
   import gui.GiftPopup;
   import gui.GuiManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class QuestActor extends Sprite
   {
      
      public static const DEFAULT_PHANTOM_VISION_RADIUS:int = 225;
      
      public static const SEEKTYPE_OFF:int = 0;
      
      public static const SEEKTYPE_PATH:int = 1;
      
      public static const SEEKTYPE_PLAYER:int = 2;
      
      public static const SEEKTYPE_PLANT:int = 3;
      
      public static const GIVE_DEN_ITEM:int = 1;
      
      public static const GIVE_ACCESSORY:int = 2;
      
      public static const GIVE_GEMS:int = 3;
      
      public static const GIVE_ORBS:int = 4;
      
      public static const GIVE_FAILED:int = 5;
      
      public static const GIVE_ORBS_NO_POPUP:int = 6;
      
      public static const GIVE_OPEN_CHEST:int = 7;
      
      private static const ITEM_CLICK_OFFSET_X:int = 0;
      
      private static const ITEM_CLICK_OFFSET_Y:int = -40;
      
      private static const TREASURE_CLICK_OFFSET_X:int = 0;
      
      private static const TREASURE_CLICK_OFFSET_Y:int = -40;
      
      private static const GEMS_MEDIA_ID:int = 1086;
      
      private static const ORBS_MEDIA_ID:int = 2057;
      
      private static const NPC_PATH_VELOCITY:int = 125;
      
      private static const ATTACKER_VELOCITY:int = 40;
      
      private static const ATTACKER_VELOCITY_RANGE:int = 60;
      
      private static const ATTACKER_RANGE_WEAPON_PROJECTILE:int = 350;
      
      private static const ATTACKER_RANGE_WEAPON_MIN_PROJECTILE:int = 100;
      
      private static const PHANTOM_OUT_OF_RANGE_SQ:int = 640000;
      
      private static const DROPPED_ORB_RADIUS:int = 60;
      
      private static const DROPPED_TREASURE_RADIUS:int = 25;
      
      private static const PLACED_TREASURE_RADIUS:int = 50;
      
      public static const QUEST_ACTOR_TYPE_NPC:int = 1;
      
      public static const QUEST_ACTOR_TYPE_TILE:int = 2;
      
      public static const QUEST_ACTOR_TYPE_VOLUMETRIGGER:int = 3;
      
      public static const QUEST_ACTOR_TYPE_CIRCLETRIGGER:int = 4;
      
      public static const QUEST_ACTOR_TYPE_VOLUMEBLOCKER:int = 5;
      
      public static const QUEST_ACTOR_TYPE_CIRCLECLOCKER:int = 6;
      
      public static const QUEST_ACTOR_TYPE_VARIABLE:int = 7;
      
      public static const QUEST_ACTOR_TYPE_TIMER:int = 8;
      
      public static const QUEST_ACTOR_TYPE_SPAWN:int = 9;
      
      public static const QUEST_ACTOR_TYPE_CAMERA:int = 10;
      
      public static const QUEST_ACTOR_TYPE_ATTACKER:int = 11;
      
      public static const QUEST_ACTOR_TYPE_FACTORY:int = 12;
      
      public static const QUEST_ACTOR_TYPE_PLACED_TREASURE:int = 13;
      
      public static const QUEST_ACTOR_TYPE_VOLUME_HEALTH:int = 14;
      
      public static const QUEST_ACTOR_TYPE_ITEM:int = 15;
      
      public static const QUEST_ACTOR_TYPE_SPEAKER:int = 16;
      
      public static const QUEST_ACTOR_TYPE_GROUP_ITEM:int = 17;
      
      public static const QUEST_ACTOR_TYPE_PLANT:int = 21;
      
      public static const QUEST_ACTOR_TYPE_VOLUMEPLACEMENT:int = 22;
      
      public static const QUEST_ACTOR_TYPE_DESTRUCTIBLE:int = 23;
      
      public static const QUEST_ACTOR_TYPE_VOLUMEINTERACTION:int = 24;
      
      public static const QUEST_ACTOR_TYPE_LIGHT_BEAM:int = 25;
      
      public static const QUEST_ACTOR_TYPE_VOLUME_FALLING_PHANTOM:int = 26;
      
      public static const QUEST_ACTOR_TYPE_GUI:int = 28;
      
      public static const QUEST_ACTOR_TYPE_BOUNCER:int = 29;
      
      public static const QUEST_ACTOR_TYPE_PLATFORM:int = 30;
      
      public static const QUEST_ACTOR_TYPE_DROPPED_TREASURE:int = 200;
      
      public var _spawnedFromPos:Point;
      
      public var _actorData:Object;
      
      public var _actorId:String;
      
      public var _actorDefaultInnerRadius:int;
      
      public var _actorDefaultOuterRadius:int;
      
      public var _visible:Boolean;
      
      public var _requireClick:Boolean;
      
      public var _inRadius:Boolean;
      
      public var _clickIcon:MovieClip;
      
      public var _mediaObject:MovieClip;
      
      private var _targetRangeMax:int;
      
      private var _targetRangeMin:int;
      
      private var _requestSeekTimer:Number;
      
      private var _updatePositionTimer:Number;
      
      private var _inSeekRadius:Boolean;
      
      public var _seekActive:int;
      
      private var _seekActor:QuestActor;
      
      private var _attackTimer:Number;
      
      private var _zapTimer:Number;
      
      private var _tellServerPosition:Boolean;
      
      private var _targetX:Number;
      
      private var _targetY:Number;
      
      private var _playerSeekingActor:Boolean;
      
      private var _seekVelocity:int;
      
      private var _seekPlayerOffsetX:int;
      
      private var _seekPlayerOffsetY:int;
      
      private var _attackPlayerWeaponItemDefId:int;
      
      private var _attackPlayerWeaponColor:uint;
      
      private var _attackPlayerSfsId:int;
      
      private var _priority:int;
      
      private var _directionOverride:Point;
      
      private var _directionTimer:Number;
      
      private var _chatBalloon:ChatBalloon;
      
      private var _alerted:Boolean;
      
      private var _alertLP:SoundChannel;
      
      private var _npcIsHotSpot:Boolean;
      
      private var _npcPath:Object;
      
      private var _pathDirectionForward:Boolean;
      
      private var _pathNode:int;
      
      private var _npcReachedPathEnd:Boolean;
      
      private var _npc:NPCView;
      
      public var _volumes:Array;
      
      private var _interactionAnimIds:Array;
      
      private var _lastMeleeID:int;
      
      private var _prizePopup:GiftPopup;
      
      private var _mh:MediaHelper;
      
      private var _prizeAmount:int;
      
      private var _torchActive:Boolean;
      
      private var _inCollision:Boolean;
      
      private var _speakerSoundChannel:SoundChannel;
      
      private var _hudViewHolder:MovieClip;
      
      private var _flashTimer:Timer;
      
      private var _offScreenAvtView:Object;
      
      private var _isOffScreen:Boolean;
      
      private var _showIcon:Boolean;
      
      public var _loadingComplete:Boolean;
      
      public var _attackable:int;
      
      private var _eyeInFG:Boolean;
      
      private var _beamInFG:Boolean;
      
      private var _plantTargets:Array;
      
      private var _radiusOverride:Boolean;
      
      public function QuestActor()
      {
         super();
      }
      
      public function get isDead() : Boolean
      {
         if(_npc != null)
         {
            if(_npc.isDead)
            {
               return true;
            }
            if(_npc.npcMC != null && "deathAnimComplete" in _npc.npcMC)
            {
               return _npc.npcMC.deathAnimComplete;
            }
         }
         return false;
      }
      
      public function get npcDef() : Object
      {
         if(_npc != null)
         {
            return _npc.npcDef;
         }
         return null;
      }
      
      public function isVulnerable() : Boolean
      {
         if(_npc != null && _npc.npcMC != null && _npc.npcMC.hasOwnProperty("vulnerable"))
         {
            return _npc.npcMC.vulnerable;
         }
         return true;
      }
      
      public function isRunawayFromPlayer() : Boolean
      {
         if(_npc != null && _npc.npcMC != null && _npc.npcMC.hasOwnProperty("runAwayFromPlayer"))
         {
            return _npc.npcMC.runAwayFromPlayer;
         }
         return false;
      }
      
      public function playPhantomLoopingSound() : Boolean
      {
         if(_npc != null && _npc.npcMC != null && _npc.npcMC.hasOwnProperty("ajq_phantomnoloop"))
         {
            return !_npc.npcMC.ajq_phantomnoloop;
         }
         return true;
      }
      
      public function get alertLP() : SoundChannel
      {
         return _alertLP;
      }
      
      public function set alertLP(param1:SoundChannel) : void
      {
         _alertLP = param1;
      }
      
      public function get talkingHeadMediaRef() : int
      {
         if(_npc != null)
         {
            return _npc.talkingHeadMediaId;
         }
         return 0;
      }
      
      public function get currAvatar() : Avatar
      {
         if(_npc != null)
         {
            return _npc.currAvatar;
         }
         return null;
      }
      
      public function get actorOffset() : Point
      {
         if(_npc != null)
         {
            return _npc.collisionMovingPoint;
         }
         return new Point(0,0);
      }
      
      public function get collisionMovingRadius() : Number
      {
         if(_npc != null)
         {
            return _npc.collisionRadiusMoving;
         }
         return 0;
      }
      
      public function get isDying() : Boolean
      {
         return _npc != null && _npc.isDying;
      }
      
      public function get collisionRadiusMoving() : Number
      {
         if(_npc != null)
         {
            return _npc.collisionRadiusMoving;
         }
         return 0;
      }
      
      public function get priority() : int
      {
         return _priority;
      }
      
      private function initVars(param1:String, param2:Object, param3:int, param4:int, param5:int, param6:Point) : void
      {
         _plantTargets = null;
         _attackable = 0;
         _torchActive = false;
         _seekActor = null;
         _attackTimer = 0;
         _zapTimer = 0;
         _lastMeleeID = 0;
         _actorData = param2;
         _actorId = param1;
         _actorDefaultInnerRadius = param3;
         _actorDefaultOuterRadius = param4;
         _visible = false;
         visible = false;
         _requireClick = false;
         _inRadius = false;
         _inSeekRadius = false;
         _seekActive = 0;
         _requestSeekTimer = 0;
         _updatePositionTimer = 0;
         _tellServerPosition = false;
         _playerSeekingActor = false;
         _attackPlayerSfsId = 0;
         _attackPlayerWeaponItemDefId = 0;
         _priority = param5;
         _spawnedFromPos = param6;
         _inCollision = true;
         _directionOverride = new Point();
         _directionTimer = 0;
         setPath(_actorData.pathName);
         if(_actorData.actorPos != null)
         {
            x = _actorData.actorPos.x;
            y = _actorData.actorPos.y;
         }
         if(_actorData.onReinitSwfStateName != null && (_actorData.pendingSwfStateName == null || _actorData.pendingSwfStateName.length == 0))
         {
            if(_actorData.pendingSwfStateName == null)
            {
               _actorData.pendingSwfStateName = [];
            }
            _actorData.pendingSwfStateName.push(_actorData.onReinitSwfStateName);
         }
      }
      
      public function resetActor(param1:String, param2:Object, param3:int, param4:int, param5:int, param6:Point) : void
      {
         initVars(param1,param2,param3,param4,param5,param6);
         switch(_actorData.type)
         {
            case 12:
            case 11:
            case 23:
               addEventListener("mouseDown",onMouseDownEvt_Attack);
               _targetX = x;
               _targetY = y;
               resetNPC(_actorData.actorPos);
               break;
            case 21:
            case 1:
            case 25:
               resetNPC(_actorData.actorPos);
               _targetX = -1;
               break;
            default:
               throw new Error("Trying to recycle an asset that is not a valid type");
         }
      }
      
      public function initActor(param1:String, param2:Object, param3:int, param4:int, param5:int, param6:Point) : void
      {
         var _loc7_:Object = null;
         var _loc8_:int = 0;
         _loadingComplete = false;
         initVars(param1,param2,param3,param4,param5,param6);
         switch(_actorData.type)
         {
            case 16:
               QuestManager._layerManager.room_avatars.addChild(this);
               _loadingComplete = true;
               break;
            case 12:
               addEventListener("mouseDown",onMouseDownEvt_Attack);
               _targetX = x;
               _targetY = y;
               initNPC(_actorData.actorPos,true);
               break;
            case 23:
            case 11:
               _loc7_ = QuestManager.getNPCDef(_actorData.defId);
               _attackable = _loc7_.attackable;
               addEventListener("mouseDown",onMouseDownEvt_Attack);
               _targetX = x;
               _targetY = y;
               initNPC(_actorData.actorPos,false);
               break;
            case 200:
            case 13:
               initNPC(_actorData.actorPos);
               break;
            case 21:
               if(_actorId.indexOf("_r_") == 0)
               {
                  _actorData.plantRespawns = true;
               }
               initNPC(_actorData.actorPos,false);
               break;
            case 1:
               initNPC(_actorData.actorPos,false,true);
               break;
            case 25:
               _targetX = -1;
               initNPC(_actorData.actorPos,false);
               break;
            case 30:
               _mh = new MediaHelper();
               _mh.init(_actorData.defId,onMediaHelperPlatformReceived);
               break;
            case 15:
            case 17:
               _mh = new MediaHelper();
               _mh.init(_actorData.defId,onMediaHelperItemReceived);
               break;
            case 29:
               _mh = new MediaHelper();
               _mh.init(_actorData.defId,onMediaHelperBouncerReceived);
               break;
            case 22:
            case 26:
               _volumes = RoomManagerWorld.instance.volumeManager.findVolume(param1);
               _loadingComplete = true;
               break;
            case 14:
            case 3:
            case 5:
            case 24:
               _volumes = RoomManagerWorld.instance.volumeManager.findVolume(param1);
               if(_volumes != null)
               {
                  if(_volumes[0].message.length)
                  {
                     _interactionAnimIds = _volumes[0].message.split(",");
                     _loc8_ = 0;
                     while(_loc8_ < _interactionAnimIds.length)
                     {
                        _interactionAnimIds[_loc8_] = int(_interactionAnimIds[_loc8_]);
                        _loc8_++;
                     }
                  }
                  else
                  {
                     _interactionAnimIds = null;
                  }
                  RoomManagerWorld.instance.enableVolume(param1,_visible);
               }
               _loadingComplete = true;
               break;
            default:
               _loadingComplete = true;
         }
      }
      
      private function resetNPC(param1:Point) : void
      {
         AvatarManager.addQuestActor(this,param1);
         var _loc2_:Object = QuestManager.getNPCDef(_actorData.defId);
         if(_loc2_ && _loc2_.type == 1)
         {
         }
         _npc.reset();
         onNpcLoaded();
      }
      
      private function initNPC(param1:Point, param2:Boolean = false, param3:Boolean = false) : void
      {
         var _loc4_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         if(param3)
         {
            _loc4_ = QuestManager.getNPCDef(_actorData.defId);
            if(_loc4_)
            {
               if(_loc4_.type == 1)
               {
                  _loc6_ = int(_loc4_.titleStrId);
               }
               _loc9_ = int(_loc4_.avatarRefId);
            }
         }
         _npcIsHotSpot = false;
         if(_actorData.extendedParameters != null)
         {
            _loc7_ = _actorData.extendedParameters.split(",");
            _loc8_ = 0;
            while(_loc8_ < _loc7_.length)
            {
               _loc5_ = _loc7_[_loc8_];
               if(_loc5_.search("hotspot") != -1)
               {
                  _npcIsHotSpot = true;
               }
               _loc8_++;
            }
         }
         _npc = new NPCView();
         _npc.init(_actorData.defId,0,_loc6_,_loc9_,param2,onNpcLoaded);
         AvatarManager.addQuestActor(this,param1);
      }
      
      public function handlePositionUpdate(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int) : void
      {
         if(_seekActive == 0)
         {
            if(_npc != null && _npc.npcMC != null)
            {
               if(_npc.npcMC.hasOwnProperty("setNearestPlayerLocation"))
               {
                  _npc.npcMC.setNearestPlayerLocation(new Point(param5,param6));
               }
               switch(param4 - 2)
               {
                  case 0:
                  case 1:
                     if(_npc.npcDef.damageTouch > 0 && _npc.npcMC.hasOwnProperty("alertStatus"))
                     {
                        _npc.npcMC.alertStatus(true);
                     }
                     break;
                  default:
                     if(_npc.npcDef.damageTouch > 0 && _npc.npcMC.hasOwnProperty("alertStatus"))
                     {
                        _npc.npcMC.alertStatus(false);
                     }
               }
            }
            if(_actorData.actorPos != null)
            {
               _actorData.actorPos.x = param1;
               _actorData.actorPos.y = param2;
            }
            _targetX = param1;
            _targetY = param2;
            _seekVelocity = param3;
         }
      }
      
      public function handleRequestSeekResponse(param1:int) : void
      {
         var _loc7_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:Point = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc6_:Number = NaN;
         _seekActive = param1;
         switch(param1 - 1)
         {
            case 0:
               _pathNode = 0;
               if(_npc != null && AvatarManager.playerAvatarWorldView != null && _npcPath != null)
               {
                  _loc7_ = -1;
                  _loc4_ = 0;
                  while(_loc4_ < _npcPath.points.length)
                  {
                     _loc5_ = _npc.collisionMovingPoint;
                     _loc2_ = _npcPath.points[_loc4_].x - (x + _loc5_.x);
                     _loc3_ = _npcPath.points[_loc4_].y - (y + _loc5_.y);
                     _loc6_ = _loc2_ * _loc2_ + _loc3_ * _loc3_;
                     if(_loc7_ == -1 || _loc6_ < _loc7_)
                     {
                        _loc7_ = _loc6_;
                        _pathNode = _loc4_;
                     }
                     _loc4_++;
                  }
               }
               break;
            case 1:
            case 2:
               _seekVelocity = 40 + Math.random() * 60;
               if(_npc != null && _npc.npcMC != null && _npc.npcDef.damageTouch > 0 && _npc.npcMC.hasOwnProperty("alertStatus"))
               {
                  _npc.npcMC.alertStatus(true);
               }
               break;
            default:
               if(_npc != null && _npc.npcMC != null && _npc.npcDef.damageTouch > 0 && _npc.npcMC.hasOwnProperty("alertStatus"))
               {
                  _npc.npcMC.alertStatus(false);
               }
         }
      }
      
      public function setRequireClick(param1:Boolean) : void
      {
         if(param1)
         {
            _inRadius = false;
         }
         else
         {
            removeClickIcon();
         }
         _requireClick = param1;
      }
      
      public function setVisible(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         if(param1)
         {
            switch(_actorData.type)
            {
               case 12:
               case 11:
               case 23:
               case 21:
                  if(_actorData.healthPercent <= 0)
                  {
                     param1 = false;
                  }
                  break;
               case 5:
                  if(_volumes != null && AvatarManager.playerAvatarWorldView != null && RoomManagerWorld.instance.volumeManager.testAvatarVolume(_actorId,new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y)))
                  {
                     _actorData.delayBlocker = true;
                     return;
                  }
            }
         }
         if(param1 != _visible)
         {
            _loc2_ = _inRadius;
            _inRadius = false;
            visible = param1;
            _visible = param1;
            if(!_visible)
            {
               removeClickIcon();
               if(_mediaObject && _mediaObject.hasOwnProperty("torchOn"))
               {
                  QuestManager.removeTorch(this);
               }
               if(_seekActive != 0)
               {
                  QuestManager.setQuestActorSeek(this,_seekActive);
               }
               if(_chatBalloon)
               {
                  if(_chatBalloon.parent != null)
                  {
                     _chatBalloon.parent.removeChild(_chatBalloon);
                     _chatBalloon = null;
                  }
               }
               if(_loc2_)
               {
                  if(_volumes != null)
                  {
                     switch(_actorData.type)
                     {
                        case 14:
                        case 5:
                        case 3:
                        case 24:
                           QuestXtCommManager.questActorUntriggered(_actorId);
                     }
                  }
               }
               if(_actorData.type == 200 || _actorData.type == 13)
               {
                  _actorData.status = 0;
                  _npc.setNpcState(5);
               }
            }
            if(_volumes != null)
            {
               switch(_actorData.type)
               {
                  case 14:
                  case 3:
                  case 24:
                     RoomManagerWorld.instance.enableVolume(_actorId,_visible);
                     break;
                  case 5:
                     RoomManagerWorld.instance.enableVolume(_actorId,_visible);
                     RoomManagerWorld.instance.updateMinimap();
                     _actorData.delayBlocker = false;
               }
            }
            updateTorch();
            updateIcon(_actorData.iconShowing);
         }
      }
      
      private function recycle() : void
      {
         if(_mh)
         {
            _mh.destroy();
            _mh = null;
         }
         removeClickIcon();
         if(_actorData.type != 1)
         {
            removeEventListener("mouseDown",onMouseDownEvt_Attack);
            gMainFrame.stage.removeEventListener("mouseDown",onMouseDownEvt_CancelAttack);
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
         QuestManager.recycle(QuestManager.getNPCDef(_actorData.defId).mediaRefId,this);
      }
      
      public function destroy() : void
      {
         if(_mh)
         {
            _mh.destroy();
            _mh = null;
         }
         if(_mediaObject)
         {
            if(_mediaObject.parent)
            {
               _mediaObject.parent.removeChild(_mediaObject);
            }
            _mediaObject = null;
         }
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
         removeClickIcon();
         switch(_actorData.type)
         {
            case 16:
               if(_speakerSoundChannel != null)
               {
                  _speakerSoundChannel.stop();
                  _speakerSoundChannel = null;
               }
               break;
            case 12:
            case 11:
            case 23:
               removeEventListener("mouseDown",onMouseDownEvt_Attack);
               gMainFrame.stage.removeEventListener("mouseDown",onMouseDownEvt_CancelAttack);
               destroyNPC();
               break;
            case 200:
               removeEventListener("mouseDown",onMouseDownEvt_DroppedTreasure);
               destroyNPC();
               break;
            case 25:
            case 1:
            case 21:
               destroyNPC();
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(_alertLP)
         {
            QuestManager.stopLoopingSound(_alertLP);
            _alertLP = null;
         }
         if(_torchActive)
         {
            _torchActive = false;
            QuestManager.removeTorch(this);
         }
         updateIcon(false);
         if(_hudViewHolder && _hudViewHolder.parent && _hudViewHolder.parent == GuiManager.guiLayer)
         {
            GuiManager.guiLayer.removeChild(_hudViewHolder);
         }
         _hudViewHolder = null;
      }
      
      public function trigger() : void
      {
         QuestXtCommManager.questActorTriggered(_actorId);
      }
      
      public function destroyNPC() : void
      {
         if(_npc)
         {
            if(_npc.parent)
            {
               _npc.parent.removeChild(_npc);
            }
            _npc.destroy();
            _npc = null;
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc25_:Point = null;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc9_:Boolean = false;
         var _loc20_:int = 0;
         var _loc36_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc45_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc43_:Boolean = false;
         var _loc3_:int = 0;
         var _loc17_:Number = NaN;
         var _loc42_:Number = NaN;
         var _loc30_:Point = null;
         var _loc22_:Point = null;
         var _loc10_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc14_:Object = null;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc41_:Boolean = false;
         var _loc7_:Point = null;
         var _loc8_:int = 0;
         var _loc11_:Array = null;
         var _loc18_:Object = null;
         var _loc33_:int = 0;
         var _loc32_:AvatarInfo = null;
         var _loc34_:Point = null;
         var _loc26_:int = 0;
         var _loc13_:int = 0;
         var _loc2_:int = 0;
         var _loc44_:int = 0;
         var _loc37_:Number = NaN;
         var _loc28_:Point = null;
         var _loc5_:Point = null;
         var _loc19_:Point = null;
         var _loc46_:* = _actorData.type;
         if(5 === _loc46_)
         {
            if(_actorData.delayBlocker == true)
            {
               setVisible(true);
            }
         }
         if(_visible && (_npc == null || _npc.isDying == false))
         {
            _loc6_ = 0;
            _loc4_ = 0;
            _loc15_ = 0;
            _loc9_ = false;
            _loc35_ = 0;
            _loc38_ = 0;
            _loc12_ = 0;
            _loc29_ = 0;
            if(_chatBalloon && _chatBalloon.visible)
            {
               _chatBalloon.heartbeat(10);
            }
            switch(_actorData.type)
            {
               case 29:
                  if(AvatarManager.playerAvatarWorldView != null && _mediaObject && _mediaObject.bounceState == 0)
                  {
                     _loc6_ = x + _mediaObject.collision.x;
                     _loc4_ = y + _mediaObject.collision.y;
                     if(AvatarManager.playerAvatarWorldView.x >= _loc6_ && AvatarManager.playerAvatarWorldView.y >= _loc4_)
                     {
                        _loc6_ = x + _mediaObject.collision.x + _mediaObject.collision.width;
                        _loc4_ = y + _mediaObject.collision.y + _mediaObject.collision.height;
                        if(AvatarManager.playerAvatarWorldView.x <= _loc6_ && AvatarManager.playerAvatarWorldView.y <= _loc4_)
                        {
                           AvatarManager.playerAvatarWorldView.doBounce();
                           _mediaObject.setBounceState(1);
                           QuestXtCommManager.questActorTriggered(_actorId);
                        }
                     }
                  }
                  break;
               case 30:
                  if(AvatarManager.playerAvatarWorldView != null && _mediaObject)
                  {
                     if(!_mediaObject.collisionOn && AvatarManager.playerAvatarWorldView.getPlatform() == this)
                     {
                        AvatarManager.playerAvatarWorldView.setPlatform(_mediaObject.collision,this,false);
                     }
                     else
                     {
                        _loc6_ = x + _mediaObject.collision.x;
                        _loc4_ = y + _mediaObject.collision.y;
                        if(AvatarManager.playerAvatarWorldView.x >= _loc6_ && AvatarManager.playerAvatarWorldView.y >= _loc4_ - 100)
                        {
                           _loc6_ = x + _mediaObject.collision.x + _mediaObject.collision.width;
                           _loc4_ = y + _mediaObject.collision.y + _mediaObject.collision.height;
                           if(AvatarManager.playerAvatarWorldView.x <= _loc6_ && AvatarManager.playerAvatarWorldView.y <= _loc4_)
                           {
                              if(AvatarManager.playerAvatarWorldView.getPlatform() != this && _mediaObject.collisionOn)
                              {
                                 AvatarManager.playerAvatarWorldView.setPlatform(_mediaObject.collision,this,true);
                              }
                           }
                        }
                     }
                  }
                  break;
               case 1:
                  if(_npcPath != null || _seekActive == 0)
                  {
                     if(_seekActive == 0)
                     {
                        if(_npcPath != null)
                        {
                           if(_requestSeekTimer > 0)
                           {
                              _requestSeekTimer -= param1;
                           }
                           else
                           {
                              QuestManager.setQuestActorSeek(this,1);
                           }
                        }
                        _seekVelocity = 125 * 0.9;
                     }
                     else if(_seekActive == 1)
                     {
                        _seekVelocity = 125;
                     }
                     if(_updatePositionTimer > 0)
                     {
                        _updatePositionTimer -= param1;
                     }
                     else if(_tellServerPosition)
                     {
                        if(_actorData.actorPos != null)
                        {
                           _actorData.actorPos.x = x;
                           _actorData.actorPos.y = y;
                        }
                        QuestXtCommManager.questActorPositionUpdate(_actorId,x,y,_seekVelocity,_seekActive,0,0);
                        if(_seekActive == 1)
                        {
                           _updatePositionTimer = 0.5 + 0.5 * Math.random();
                        }
                        _tellServerPosition = false;
                     }
                     _loc25_ = null;
                     _loc6_ = 0;
                     _loc4_ = 0;
                     _loc15_ = 0;
                     if(_seekActive == 1 && _npcPath && _pathNode < _npcPath.points.length)
                     {
                        _loc25_ = _npc.collisionMovingPoint;
                        _loc6_ = _npcPath.points[_pathNode].x - (x + _loc25_.x);
                        _loc4_ = _npcPath.points[_pathNode].y - (y + _loc25_.y);
                        _loc15_ = 20;
                        _loc9_ = true;
                     }
                     else
                     {
                        _loc15_ = 10;
                        _loc6_ = _targetX - x;
                        _loc4_ = _targetY - y;
                     }
                     if(_loc6_ != 0 || _loc4_ != 0)
                     {
                        _loc12_ = Math.sqrt(_loc6_ * _loc6_ + _loc4_ * _loc4_);
                        if(_loc12_ != 0)
                        {
                           _loc35_ = _loc6_ / _loc12_;
                           _loc38_ = _loc4_ / _loc12_;
                        }
                        else
                        {
                           _loc35_ = 1;
                           _loc38_ = 0;
                        }
                        _loc29_ = Math.asin(_loc35_);
                        if(_loc4_ > 0)
                        {
                           _loc29_ = -(3.141592653589793 + _loc29_);
                        }
                        _loc20_ = 1;
                        _loc36_ = _loc29_ * 180 / 3.141592653589793;
                     }
                     if(_loc12_ > _loc15_)
                     {
                        _loc45_ = Math.abs(_loc35_);
                        _loc40_ = Math.abs(_loc38_);
                        _loc35_ *= param1 * _seekVelocity;
                        _loc38_ *= param1 * _seekVelocity;
                        if(Math.abs(_loc6_) - Math.abs(_loc35_) < 0)
                        {
                           _loc35_ = _loc6_;
                        }
                        if(Math.abs(_loc4_) - Math.abs(_loc38_) < 0)
                        {
                           _loc38_ = _loc4_;
                        }
                        if(_inCollision)
                        {
                           _inCollision = inCollision(x,y);
                        }
                        if(_loc9_ && !_inCollision)
                        {
                           if(inCollision(x + _loc35_,y + _loc38_))
                           {
                              _loc16_ = 0.1;
                              _loc31_ = param1 * _seekVelocity * (_loc38_ > 0 ? 1 : -1);
                              if(inCollision(x,y + _loc31_))
                              {
                                 _loc31_ = param1 * _seekVelocity * (_loc35_ > 0 ? 1 : -1);
                                 if(inCollision(x + _loc31_,y))
                                 {
                                    _loc35_ = 0;
                                    _loc38_ = 0;
                                 }
                                 else
                                 {
                                    _loc35_ = _loc31_;
                                    _loc38_ = 0;
                                 }
                              }
                              else
                              {
                                 _loc35_ = 0;
                                 _loc38_ = _loc31_;
                              }
                           }
                        }
                        if(_loc35_ != 0 || _loc38_ != 0)
                        {
                           x += _loc35_;
                           y += _loc38_;
                           if(_seekActive != 0)
                           {
                              _targetX = x;
                              _targetY = y;
                              _tellServerPosition = true;
                           }
                        }
                     }
                     else
                     {
                        switch(_seekActive)
                        {
                           case 0:
                              _loc20_ = 0;
                              _loc36_ = 0;
                              break;
                           case 1:
                              _loc43_ = false;
                              if(_npcPath && _npcPath.points.length > 1)
                              {
                                 if(_npcPath.isClosedLoop)
                                 {
                                    _pathDirectionForward = true;
                                    _pathNode = _pathNode + 1;
                                    if(_pathNode >= _npcPath.points.length)
                                    {
                                       _pathNode = 0;
                                    }
                                 }
                                 else
                                 {
                                    _pathNode = _pathNode + 1;
                                    if(_pathNode >= _npcPath.points.length)
                                    {
                                       _loc20_ = 0;
                                       _loc36_ = 0;
                                       _loc43_ = true;
                                    }
                                 }
                              }
                              else
                              {
                                 _loc20_ = 0;
                                 _loc36_ = 0;
                                 _loc43_ = true;
                              }
                              if(_loc43_ && !_npcReachedPathEnd)
                              {
                                 _npcReachedPathEnd = true;
                                 QuestXtCommManager.questActorTriggered(_actorId,2);
                              }
                        }
                     }
                     if(_loc20_ != 0 || _npc.npcState != _loc20_)
                     {
                        _npc.setNpcState(_loc20_,_loc36_);
                        if(_loc20_ == 0 && _actorData.pendingSwfStateName != null && _actorData.pendingSwfStateName.length > 0)
                        {
                           setSwfState(_actorData.pendingSwfStateName.shift());
                        }
                     }
                  }
                  else
                  {
                     QuestManager.setQuestActorSeek(this,0);
                  }
                  if(_npcIsHotSpot && AvatarManager.playerAvatarWorldView)
                  {
                     _loc3_ = 0;
                     _loc17_ = Math.sqrt((AvatarManager.playerAvatarWorldView.x - _actorData.actorPos.x) * (AvatarManager.playerAvatarWorldView.x - _actorData.actorPos.x) + (AvatarManager.playerAvatarWorldView.y - _actorData.actorPos.y) * (AvatarManager.playerAvatarWorldView.y - _actorData.actorPos.y));
                     if(_loc17_ < _actorDefaultInnerRadius)
                     {
                        _loc3_ = 6;
                     }
                     else if(_loc17_ < _actorDefaultOuterRadius)
                     {
                        _loc17_ -= _actorDefaultInnerRadius;
                        _loc42_ = _actorDefaultOuterRadius - _actorDefaultInnerRadius;
                        _loc3_ = Math.floor((_loc42_ - _loc17_) / _loc42_ * 5) + 1;
                     }
                     QuestManager.setHotColdStatus(_loc3_);
                  }
                  break;
               case 25:
                  if(_zapTimer > 0)
                  {
                     _zapTimer -= param1;
                  }
                  if(_npc != null && _npc.npcMC != null)
                  {
                     if(_npc.npcMC.bLightEnabled)
                     {
                        if(_actorData.lightParamSpeed != 0)
                        {
                           _actorData.lightParamAngle += _actorData.lightParamSpeed * param1;
                           if(_actorData.lightParamSpeed > 0)
                           {
                              if(_actorData.lightParamEndAngle != -1)
                              {
                                 if(_actorData.lightParamAngle >= _actorData.lightParamEndAngle)
                                 {
                                    _actorData.lightParamAngle = _actorData.lightParamEndAngle;
                                    _actorData.lightParamSpeed = -_actorData.lightParamSpeed;
                                 }
                              }
                              else if(_actorData.lightParamAngle >= 360)
                              {
                                 _actorData.lightParamAngle -= 360;
                              }
                           }
                           else if(_actorData.lightParamEndAngle != -1)
                           {
                              if(_actorData.lightParamAngle <= _actorData.lightParamStartAngle)
                              {
                                 _actorData.lightParamAngle = _actorData.lightParamStartAngle;
                                 _actorData.lightParamSpeed = -_actorData.lightParamSpeed;
                              }
                           }
                           else if(_actorData.lightParamAngle <= 0)
                           {
                              _actorData.lightParamAngle = 360;
                           }
                           _npc.npcMC.setAngle(_actorData.lightParamAngle);
                           _loc30_ = _npc.npcMC.getStartPoint();
                           _loc30_.x = _loc30_.x + x;
                           _loc30_.y += y;
                           _loc22_ = _npc.npcMC.getEndPoint();
                           _loc22_.x = _loc22_.x + x;
                           _loc22_.y += y;
                           _targetY = RoomManagerWorld.instance.getLengthLineIntersectGrid(_loc30_,_loc22_,_actorData.lightParamMaxLength);
                           if(_targetX != _targetY)
                           {
                              if(_targetX != -1)
                              {
                                 _loc10_ = Math.abs(_targetX - _targetY);
                                 if(_loc10_ > 10)
                                 {
                                    if(_targetX < _targetY)
                                    {
                                       _targetX += _loc10_ * (param1 * 6);
                                       if(_targetX > _targetY)
                                       {
                                          _targetX = _targetY;
                                       }
                                    }
                                    else
                                    {
                                       _targetX -= _loc10_ * (param1 * 6);
                                       if(_targetX < _targetY)
                                       {
                                          _targetX = _targetY;
                                       }
                                    }
                                 }
                              }
                              else
                              {
                                 _targetX = _targetY;
                              }
                           }
                           _npc.npcMC.setLength(_targetX);
                        }
                        if(_zapTimer <= 0)
                        {
                           testBeamIntersectPlayer();
                        }
                     }
                  }
                  break;
               case 15:
               case 17:
                  if(_updatePositionTimer > 0)
                  {
                     _updatePositionTimer -= param1;
                  }
                  break;
               case 16:
                  if(AvatarManager.playerAvatarWorldView != null)
                  {
                     _loc6_ = AvatarManager.playerAvatarWorldView.x + -15 - x;
                     _loc4_ = AvatarManager.playerAvatarWorldView.y + -40 - y;
                     _loc15_ = _loc6_ * _loc6_ + _loc4_ * _loc4_;
                     _loc27_ = _actorDefaultInnerRadius * _actorDefaultInnerRadius;
                     _loc21_ = _actorDefaultOuterRadius * _actorDefaultOuterRadius;
                     _loc39_ = 1;
                     if(_loc15_ > _loc21_ || SBAudio.isMusicMuted)
                     {
                        _loc39_ = 0;
                     }
                     else if(_loc15_ >= _loc27_)
                     {
                        _loc39_ = 1 - (_loc15_ - _loc27_) / (_loc21_ - _loc27_);
                     }
                     if(_loc39_ > 0 || _actorDefaultInnerRadius == 0)
                     {
                        if(_speakerSoundChannel == null)
                        {
                           _speakerSoundChannel = QuestManager.playLoopingSound(_actorData.defName);
                        }
                        if(_actorDefaultInnerRadius > 0)
                        {
                           QuestManager.setSoundLevel(_speakerSoundChannel,_loc39_,this);
                        }
                        else if(SBAudio.isMusicMuted)
                        {
                           if(_speakerSoundChannel != null)
                           {
                              _speakerSoundChannel.stop();
                              _speakerSoundChannel = null;
                           }
                        }
                        else if(_speakerSoundChannel == null)
                        {
                           _speakerSoundChannel = QuestManager.playLoopingSound(_actorData.defName);
                        }
                     }
                     else if(_speakerSoundChannel != null)
                     {
                        _speakerSoundChannel.stop();
                        _speakerSoundChannel = null;
                     }
                  }
                  break;
               case 200:
                  if(_npc != null && _npc.npcState == 6 && _npc.npcStateComplete)
                  {
                     _npc.setNpcState(7);
                     _actorData.pickedUp = true;
                  }
                  break;
               case 12:
                  _npc.setNpcState(0,0);
                  break;
               case 23:
                  break;
               case 11:
                  if(_spawnedFromPos != null)
                  {
                     if(_updatePositionTimer > 0)
                     {
                        _updatePositionTimer -= param1;
                        if(_updatePositionTimer <= 0)
                        {
                           _updatePositionTimer = 0;
                           _spawnedFromPos = null;
                        }
                     }
                  }
                  else
                  {
                     if(_seekActive != 0 && _npc != null && _npc.npcMC != null)
                     {
                        if(_seekActive == 1)
                        {
                           if(_npcPath.points.length >= 1)
                           {
                              _seekVelocity = _npc.npcMC.velocity;
                           }
                           else
                           {
                              _seekVelocity = 0;
                           }
                        }
                        else
                        {
                           if(_seekActive == 2)
                           {
                              if(_npc.npcMC.hasOwnProperty("setNearestPlayerLocation") && AvatarManager.playerAvatarWorldView != null)
                              {
                                 _npc.npcMC.setNearestPlayerLocation(new Point(AvatarManager.playerAvatarWorldView.x + -15 - x,AvatarManager.playerAvatarWorldView.y + -40 - y));
                              }
                           }
                           _seekVelocity = _npc.npcMC.velocity;
                           if(_seekActive == 2 && isRunawayFromPlayer())
                           {
                              _seekVelocity = -_seekVelocity;
                           }
                        }
                     }
                     if(_npc != null && _npc.npcMC != null && _npc.npcMC.hasOwnProperty("canSeekPlant") && _npc.npcMC.canSeekPlant)
                     {
                        checkPlantRadius();
                     }
                     if(_seekActor == null)
                     {
                        onAttackRadius();
                     }
                     if(_attackPlayerSfsId != 0 && _attackPlayerWeaponItemDefId != 0)
                     {
                        if(_npc != null && _npc.readyToLaunchAttack)
                        {
                           if(AvatarManager.avatarViewList[_attackPlayerSfsId] != null)
                           {
                              _loc14_ = ItemXtCommManager.getItemDef(_attackPlayerWeaponItemDefId);
                              if(_loc14_)
                              {
                                 _loc41_ = false;
                                 if(_seekActive == 3)
                                 {
                                    if(_seekActor != null)
                                    {
                                       _loc7_ = _seekActor.actorOffset;
                                       _loc23_ = _seekActor._actorData.actorPos.x + _loc7_.x;
                                       _loc24_ = _seekActor._actorData.actorPos.y + _loc7_.y;
                                       _loc41_ = true;
                                    }
                                 }
                                 else if(_npc != null && _npc.npcDef.damageTouch <= 0)
                                 {
                                    _loc23_ = AvatarManager.avatarViewList[_attackPlayerSfsId].avatarPos.x + -15;
                                    _loc24_ = AvatarManager.avatarViewList[_attackPlayerSfsId].avatarPos.y + -40;
                                    _loc41_ = true;
                                 }
                                 if(_loc41_)
                                 {
                                    switch(_loc14_.combatType)
                                    {
                                       case 1:
                                          QuestManager.launchProjectile(_attackPlayerWeaponItemDefId,_attackPlayerWeaponColor,_loc23_,_loc24_,this,null);
                                          break;
                                       case 2:
                                       case 0:
                                          QuestManager.swipeMelee(_attackPlayerWeaponItemDefId,_attackPlayerWeaponColor,_loc23_,_loc24_,this,null);
                                    }
                                 }
                              }
                           }
                           _attackPlayerSfsId = 0;
                           _attackPlayerWeaponItemDefId = 0;
                        }
                     }
                     if(_attackTimer > 0)
                     {
                        _attackTimer -= param1;
                     }
                     if(_requestSeekTimer > 0)
                     {
                        _requestSeekTimer -= param1;
                     }
                     if(_zapTimer > 0)
                     {
                        _zapTimer -= param1;
                     }
                     if(_updatePositionTimer > 0)
                     {
                        _updatePositionTimer -= param1;
                     }
                     else if(_tellServerPosition)
                     {
                        if(_actorData.actorPos != null)
                        {
                           _actorData.actorPos.x = x;
                           _actorData.actorPos.y = y;
                        }
                        _loc8_ = _seekVelocity;
                        if(_seekActive == 2 && isRunawayFromPlayer())
                        {
                           _loc8_ = Math.abs(_seekVelocity);
                        }
                        if(_seekActive == 2 && AvatarManager.playerAvatarWorldView != null)
                        {
                           QuestXtCommManager.questActorPositionUpdate(_actorId,x,y,_loc8_,_seekActive,AvatarManager.playerAvatarWorldView.x + -15 - x,AvatarManager.playerAvatarWorldView.y + -40 - y);
                        }
                        else
                        {
                           QuestXtCommManager.questActorPositionUpdate(_actorId,x,y,_loc8_,_seekActive,0,0);
                        }
                        if(_seekActive == 1)
                        {
                           _updatePositionTimer = 1 + Math.random();
                        }
                        else
                        {
                           _updatePositionTimer = 1 + Math.random();
                        }
                        _tellServerPosition = false;
                     }
                     if(AvatarManager.playerAvatarWorldView != null)
                     {
                        _loc11_ = null;
                        _loc9_ = false;
                        if(_zapTimer <= 0 && _npc != null && _npc.npcDef.damageTouch != 0)
                        {
                           _zapTimer = 0.3;
                           _loc32_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                           if(_loc32_.questHealthPercentage > 0 && QuestManager.isPlayerInStealthVolume() == false)
                           {
                              if(_npc.npcMC != null && _npc.npcMC.hasOwnProperty("getCustomCollisionPoints"))
                              {
                                 _loc11_ = _npc.npcMC.getCustomCollisionPoints();
                                 if(_loc11_ != null)
                                 {
                                    _loc33_ = 0;
                                    while(_loc33_ < _loc11_.length)
                                    {
                                       _loc18_ = _loc11_[_loc33_];
                                       if(_loc18_.Type == 1)
                                       {
                                          _loc6_ = AvatarManager.playerAvatarWorldView.x + -15 - (x + _loc18_.x);
                                          _loc4_ = AvatarManager.playerAvatarWorldView.y + -40 - (y + _loc18_.y);
                                          _loc15_ = _loc18_.Radius + 50;
                                          if(_loc6_ * _loc6_ + _loc4_ * _loc4_ < _loc15_ * _loc15_)
                                          {
                                             QuestManager.questPhantomZap(_actorId,AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y,this);
                                             _zapTimer = 2;
                                             break;
                                          }
                                       }
                                       _loc33_++;
                                    }
                                 }
                              }
                              if(_loc11_ == null)
                              {
                                 _loc25_ = _npc.collisionZapPoint;
                                 _loc6_ = AvatarManager.playerAvatarWorldView.x + -15 - (x + _loc25_.x);
                                 _loc4_ = AvatarManager.playerAvatarWorldView.y + -40 - (y + _loc25_.y);
                                 _loc15_ = _npc.collisionZapRadius + 50;
                                 if(_loc6_ * _loc6_ + _loc4_ * _loc4_ < _loc15_ * _loc15_)
                                 {
                                    QuestManager.questPhantomZap(_actorId,AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y,this);
                                    _zapTimer = 2;
                                 }
                              }
                           }
                        }
                        _loc25_ = null;
                        _loc6_ = 0;
                        _loc4_ = 0;
                        _loc15_ = 0;
                        switch(_seekActive - 1)
                        {
                           case 0:
                              _loc25_ = _npc.collisionMovingPoint;
                              _loc6_ = _npcPath.points[_pathNode].x - (x + _loc25_.x);
                              _loc4_ = _npcPath.points[_pathNode].y - (y + _loc25_.y);
                              _loc15_ = 20;
                              _loc9_ = true;
                              if(_npc != null && _npc.npcMC != null && _npc.npcDef.damageTouch > 0 && _npc.npcMC.hasOwnProperty("alertStatus"))
                              {
                                 _npc.npcMC.alertStatus(false);
                                 _alerted = false;
                                 if(_alertLP)
                                 {
                                    QuestManager.stopLoopingSound(_alertLP);
                                    _alertLP = null;
                                 }
                              }
                              break;
                           case 1:
                              if(_npc.npcMC != null && _npc.npcMC.hasOwnProperty("getCustomCollisionPoints"))
                              {
                                 _loc11_ = _npc.npcMC.getCustomCollisionPoints();
                                 if(_loc11_ != null)
                                 {
                                    _loc33_ = 0;
                                    while(_loc33_ < _loc11_.length)
                                    {
                                       switch((_loc18_ = _loc11_[_loc33_]).Type)
                                       {
                                          case 2:
                                             _loc6_ = AvatarManager.playerAvatarWorldView.x + -15 - (x + _loc18_.x);
                                             _loc4_ = AvatarManager.playerAvatarWorldView.y + -40 - (y + _loc18_.y);
                                             _loc15_ = Number(_loc18_.Radius);
                                             break;
                                          case 3:
                                             QuestManager.phantomAttackDestructible(_actorId,x + _loc18_.x,y + _loc18_.y,_loc18_.Radius);
                                       }
                                       _loc33_++;
                                    }
                                 }
                              }
                              if(_loc15_ == 0)
                              {
                                 _loc25_ = _npc.collisionMovingPoint;
                                 _loc6_ = AvatarManager.playerAvatarWorldView.x + -15 - (x + _loc25_.x);
                                 _loc4_ = AvatarManager.playerAvatarWorldView.y + -40 - (y + _loc25_.y);
                                 if(_npc.npcDef.damageTouch > 0)
                                 {
                                    _loc15_ = 0;
                                 }
                                 else
                                 {
                                    _loc15_ = _npc.collisionRadiusAttack + 0.9 * 50;
                                 }
                              }
                              _loc9_ = true;
                              if(_npc != null && _npc.npcMC != null && _npc.npcDef.damageTouch > 0 && _npc.npcMC.hasOwnProperty("alertStatus"))
                              {
                                 if(!_alerted)
                                 {
                                    _alerted = true;
                                    if(isRunawayFromPlayer())
                                    {
                                       QuestManager.playSound("ajq_protoAlert");
                                    }
                                    else
                                    {
                                       QuestManager.playSound("ajq_phantomAlert");
                                    }
                                 }
                                 _npc.npcMC.alertStatus(true);
                                 if(_alertLP != null && !_npc.npcMC.attacking)
                                 {
                                    QuestManager.stopLoopingSound(_alertLP);
                                    _alertLP = null;
                                 }
                              }
                              break;
                           case 2:
                              if(_seekActor != null)
                              {
                                 _loc34_ = _seekActor.actorOffset;
                                 _loc25_ = _npc.collisionMovingPoint;
                                 _loc6_ = _seekActor._actorData.actorPos.x + _loc34_.x - (x + _loc25_.x);
                                 _loc4_ = _seekActor._actorData.actorPos.y + _loc34_.y - (y + _loc25_.y);
                                 _loc15_ = 90;
                                 _loc9_ = true;
                              }
                              else
                              {
                                 _loc6_ = 0;
                                 _loc4_ = 0;
                                 _loc15_ = 10;
                              }
                              if(_npc != null && _npc.npcMC != null && _npc.npcDef.damageTouch > 0 && _npc.npcMC.hasOwnProperty("alertStatus"))
                              {
                                 _npc.npcMC.alertStatus(true);
                              }
                              break;
                           default:
                              _loc15_ = 10;
                              _loc6_ = _targetX - x;
                              _loc4_ = _targetY - y;
                              _alerted = false;
                              if(_alertLP != null && !_npc.npcMC.attacking)
                              {
                                 QuestManager.stopLoopingSound(_alertLP);
                                 _alertLP = null;
                              }
                        }
                        if(_npc && _npc.npcMC && _npc.npcMC.attacking)
                        {
                           updateAlertLP();
                        }
                        if(_directionTimer > 0)
                        {
                           _loc20_ = 1;
                           _loc35_ = _directionOverride.x;
                           _loc38_ = _directionOverride.y;
                           _loc29_ = Math.asin(_loc35_);
                           if(_loc38_ > 0)
                           {
                              _loc29_ = -(3.141592653589793 + _loc29_);
                           }
                           _loc36_ = _loc29_ * 180 / 3.141592653589793;
                           _loc12_ = Math.sqrt(_loc6_ * _loc6_ + _loc4_ * _loc4_);
                        }
                        else if(_loc6_ != 0 || _loc4_ != 0)
                        {
                           _loc12_ = Math.sqrt(_loc6_ * _loc6_ + _loc4_ * _loc4_);
                           if(_loc12_ != 0)
                           {
                              _loc35_ = _loc6_ / _loc12_;
                              _loc38_ = _loc4_ / _loc12_;
                           }
                           else
                           {
                              _loc35_ = 1;
                              _loc38_ = 0;
                           }
                           _loc29_ = Math.asin(_loc35_);
                           if(_loc4_ > 0)
                           {
                              _loc29_ = -(3.141592653589793 + _loc29_);
                           }
                           _loc20_ = 1;
                           _loc36_ = _loc29_ * 180 / 3.141592653589793;
                        }
                        if(_loc12_ > _loc15_ || isRunawayFromPlayer())
                        {
                           if(_directionTimer <= 0)
                           {
                              switch(_seekActive - 2)
                              {
                                 case 0:
                                 case 1:
                                    if(!_inCollision && _attackTimer <= 0 && _npc.readyToAttack)
                                    {
                                       if(_loc12_ < _targetRangeMax && _loc12_ > _targetRangeMin)
                                       {
                                          _attackPlayerWeaponItemDefId = getActiveWeapon(true);
                                          if(_attackPlayerWeaponItemDefId != 0)
                                          {
                                             _loc20_ = 2;
                                             _attackTimer = 1.5 + 4 * Math.random();
                                          }
                                       }
                                    }
                              }
                           }
                           _loc45_ = Math.abs(_loc35_);
                           _loc40_ = Math.abs(_loc38_);
                           _loc35_ *= param1 * _seekVelocity;
                           _loc38_ *= param1 * _seekVelocity;
                           if(Math.abs(_loc6_) - Math.abs(_loc35_) < 0)
                           {
                              _loc35_ = _loc6_;
                           }
                           if(Math.abs(_loc4_) - Math.abs(_loc38_) < 0)
                           {
                              _loc38_ = _loc4_;
                           }
                           if(_inCollision)
                           {
                              _inCollision = inCollision(x,y);
                           }
                           if(_loc9_ && !_inCollision)
                           {
                              if(inCollision(x + _loc35_,y + _loc38_))
                              {
                                 _loc16_ = 0.1;
                                 _loc26_ = _seekVelocity;
                                 if(_loc26_ < 0 && isRunawayFromPlayer())
                                 {
                                    _loc26_ = -_seekVelocity;
                                 }
                                 _loc31_ = param1 * _loc26_ * (_loc38_ > 0 ? 1 : -1);
                                 if(inCollision(x,y + _loc31_))
                                 {
                                    _loc31_ = param1 * _loc26_ * (_loc35_ > 0 ? 1 : -1);
                                    if(inCollision(x + _loc31_,y))
                                    {
                                       _loc35_ = 0;
                                       _loc38_ = 0;
                                    }
                                    else
                                    {
                                       _loc35_ = _loc31_;
                                       _loc38_ = 0;
                                    }
                                 }
                                 else
                                 {
                                    _loc35_ = 0;
                                    _loc38_ = _loc31_;
                                 }
                              }
                           }
                           if(_loc35_ != 0 || _loc38_ != 0)
                           {
                              x += _loc35_;
                              y += _loc38_;
                              switch(_seekActive - 2)
                              {
                              }
                              if(_seekActive != 0)
                              {
                                 _targetX = x;
                                 _targetY = y;
                                 _tellServerPosition = true;
                              }
                           }
                           if(_directionTimer > 0)
                           {
                              _directionTimer -= param1;
                           }
                        }
                        if(_loc12_ <= _loc15_)
                        {
                           switch(_seekActive)
                           {
                              case 0:
                              case 2:
                              case 3:
                                 if(_seekActive != 0)
                                 {
                                    if(!_inCollision && _attackTimer <= 0 && _npc.readyToAttack)
                                    {
                                       _attackPlayerWeaponItemDefId = getActiveWeapon(false);
                                       if(_attackPlayerWeaponItemDefId == 0)
                                       {
                                          _attackPlayerWeaponItemDefId = getActiveWeapon(true);
                                       }
                                       if(_attackPlayerWeaponItemDefId != 0)
                                       {
                                          _loc20_ = 2;
                                          _attackTimer = 1.5 + 4 * Math.random();
                                       }
                                    }
                                 }
                                 break;
                              case 1:
                                 _directionTimer = 0;
                                 if(_npcPath.points.length > 1)
                                 {
                                    if(_npcPath.isClosedLoop)
                                    {
                                       _pathDirectionForward = true;
                                       _pathNode = _pathNode + 1;
                                       if(_pathNode >= _npcPath.points.length)
                                       {
                                          _pathNode = 0;
                                       }
                                    }
                                    else if(_pathDirectionForward)
                                    {
                                       _pathNode = _pathNode + 1;
                                       if(_pathNode >= _npcPath.points.length)
                                       {
                                          _pathDirectionForward = false;
                                          _pathNode -= 2;
                                       }
                                    }
                                    else if(_pathNode == 0)
                                    {
                                       _pathDirectionForward = true;
                                       _pathNode = _pathNode + 1;
                                    }
                                    else
                                    {
                                       _pathNode = _pathNode - 1;
                                    }
                                    break;
                                 }
                                 _loc20_ = 0;
                                 _loc36_ = 0;
                           }
                        }
                        if(_loc20_ != 2 && _npc != null && _npc.npcMC != null)
                        {
                           if(_npc.readyToAttack && _npc.npcMC.hasOwnProperty("counterAttacking") && _npc.npcMC.counterAttacking)
                           {
                              _attackPlayerWeaponItemDefId = getActiveWeapon(false);
                              if(_attackPlayerWeaponItemDefId == 0)
                              {
                                 _attackPlayerWeaponItemDefId = getActiveWeapon(true);
                              }
                              if(_attackPlayerWeaponItemDefId != 0)
                              {
                                 _loc20_ = 2;
                                 _attackTimer = 1.5 + 4 * Math.random();
                              }
                           }
                        }
                        if(_loc20_ == 2)
                        {
                           handleAttackPlayer(_attackPlayerWeaponItemDefId,_attackPlayerWeaponColor,AvatarManager.playerSfsUserId);
                           QuestXtCommManager.sendAttackPlayer(_actorId,_attackPlayerSfsId,_attackPlayerWeaponItemDefId,_attackPlayerWeaponColor);
                        }
                        else
                        {
                           _npc.setNpcState(_loc20_,_loc36_);
                        }
                     }
                  }
                  break;
               case 21:
                  if(_npc != null && _npc.npcMC != null)
                  {
                     _loc13_ = int(_npc.npcMC.hasOwnProperty("attackType") ? _npc.npcMC.attackType : -1);
                     if(_plantTargets != null)
                     {
                        if(_npc.npcMC.attacking)
                        {
                           _loc2_ = 1;
                           if(_loc13_ != -1)
                           {
                              if(_npc.npcMC.attackType >= 1)
                              {
                                 _loc2_ = int(_plantTargets.length);
                                 if(_npc.npcMC.attackType == 3)
                                 {
                                    _npc._npcAttackTriggered = true;
                                    _npc.npcMC.readyForExplode();
                                 }
                              }
                           }
                           _loc44_ = 0;
                           while(_loc44_ < _loc2_)
                           {
                              QuestXtCommManager.sendEatPhantom(_actorId,_plantTargets[_loc44_]._actorId,_plantTargets[_loc44_].x,_plantTargets[_loc44_].y);
                              _loc44_++;
                           }
                           _plantTargets = null;
                        }
                     }
                     else if(_npc.npcMC.readyForAttack)
                     {
                        switch(_loc13_ - 3)
                        {
                           case 0:
                              _loc37_ = (AvatarManager.playerAvatarWorldView.x - _actorData.actorPos.x) * (AvatarManager.playerAvatarWorldView.x - _actorData.actorPos.x) + (AvatarManager.playerAvatarWorldView.y - _actorData.actorPos.y) * (AvatarManager.playerAvatarWorldView.y - _actorData.actorPos.y);
                              if(_loc37_ < _actorDefaultOuterRadius * _actorDefaultOuterRadius)
                              {
                                 AvatarManager.playerAvatarWorldView.setPlatform(_npc.npcMC.platform,this,true);
                              }
                              break;
                           default:
                              if(_attackTimer > 0)
                              {
                                 _attackTimer -= param1;
                                 break;
                              }
                              _loc28_ = _npc.collisionPointAttack;
                              if(!QuestManager.isSideScrollQuest() || Math.abs(AvatarManager.playerAvatarWorldView.x + -15 - x) < 1000 && Math.abs(AvatarManager.playerAvatarWorldView.y + -40 - y) < 650)
                              {
                                 _plantTargets = QuestManager.getNearestActivePhantom(_actorData.actorPos.x + _loc28_.x,_actorData.actorPos.y + _loc28_.y,_npc.collisionRadiusAttack,_npc.npcDef.level,_npc.npcMC.hasOwnProperty("selfDestruct") && _npc.npcMC.selfDestruct,_npc.npcMC.hasOwnProperty("attackType") && _npc.npcMC.attackType == 2,_npc.npcDef.damageTouch > 0);
                                 if(_plantTargets != null && _plantTargets.length > 0)
                                 {
                                    QuestXtCommManager.sendPlantAte(_actorId,_plantTargets[0]._actorId);
                                    QuestManager.handlePlantAte(_actorId,_plantTargets[0]._actorId);
                                 }
                                 else if(_npc.npcMC.hasOwnProperty("selfDestruct") && _npc.npcMC.selfDestruct)
                                 {
                                    QuestXtCommManager.sendPlantAte(_actorId,"");
                                    QuestManager.handlePlantAte(_actorId,"");
                                 }
                                 _attackTimer = 0;
                              }
                        }
                     }
                     else if(_npc.npcState == 2)
                     {
                        if(_npc.npcMC.animActive != false)
                        {
                           switch(_loc13_ - 3)
                           {
                              case 0:
                                 if(_npc._npcAttackTriggered == false && _npc.npcMC.hasOwnProperty("grenadeExplosionPoint"))
                                 {
                                    _loc5_ = _npc.npcMC.grenadeExplosionPoint;
                                    _plantTargets = QuestManager.getNearestActivePhantom(_actorData.actorPos.x + _npc.npcMC.grenadeExplosionPoint.x,_actorData.actorPos.y + _npc.npcMC.grenadeExplosionPoint.y,_npc.collisionRadiusAttack,_npc.npcDef.level,true,true,_npc.npcDef.damageTouch > 0);
                                    if(_plantTargets == null && _npc.npcMC.attacking && RoomManagerWorld.instance.collisionTestGrid(_actorData.actorPos.x + _npc.npcMC.grenadeExplosionPoint.x,_actorData.actorPos.y + _npc.npcMC.grenadeExplosionPoint.y) != 0 && (_npc.npcMC.NPC.attackAngle >= 5 || !RoomManagerWorld.instance.checkCollisionThickness(_actorData.actorPos.x + _npc.npcMC.grenadeExplosionPoint.x,_actorData.actorPos.y + _npc.npcMC.grenadeExplosionPoint.y,2)))
                                    {
                                       _npc._npcAttackTriggered = true;
                                       _npc.npcMC.readyForExplode();
                                    }
                                 }
                           }
                        }
                        else if(_loc13_ == 3)
                        {
                           setSwfState("revive");
                        }
                        else if(_actorData.plantRespawns)
                        {
                           _npc.setNpcState(0,0);
                           QuestXtCommManager.questActorTriggered(_actorId);
                        }
                        else
                        {
                           _npc.setNpcState(4,0);
                        }
                     }
                  }
            }
            if(_npc)
            {
               if(_showIcon)
               {
                  updateOffScreenPositions();
               }
               if(_npc._eye && QuestManager._darknessMask)
               {
                  if(!_eyeInFG)
                  {
                     QuestManager._layerManager.room_fg.addChild(_npc._eye);
                     _eyeInFG = true;
                  }
                  _npc._eye.x = _npc.npcMC.x + _npc.npcMC.parent.parent.x + _npc.npcMC.parent.parent.parent.x + _npc.npcMC.parent.parent.parent.parent.x;
                  _npc._eye.y = _npc.npcMC.y + _npc.npcMC.parent.parent.y + _npc.npcMC.parent.parent.parent.y + _npc.npcMC.parent.parent.parent.parent.y;
               }
               if(_npc._beam && QuestManager._darknessMask)
               {
                  if(!_beamInFG)
                  {
                     QuestManager._layerManager.room_fg.addChild(_npc._beam);
                     _beamInFG = true;
                  }
                  _npc._beam.x = _npc.npcMC.x + _npc.npcMC.parent.parent.x + _npc.npcMC.parent.parent.parent.x + _npc.npcMC.parent.parent.parent.parent.x;
                  _npc._beam.y = _npc.npcMC.y + _npc.npcMC.parent.parent.y + _npc.npcMC.parent.parent.parent.y + _npc.npcMC.parent.parent.parent.parent.y;
               }
            }
            if(_chatBalloon)
            {
               try
               {
                  _loc19_ = _npc.npcMC.getAttachmentPoint();
               }
               catch(e:Error)
               {
                  _loc19_ = new Point(-10,-90);
               }
               _chatBalloon.x = x + _loc19_.x;
               _chatBalloon.y = y + _loc19_.y;
            }
         }
      }
      
      private function updateOffScreenPositions() : void
      {
         var _loc1_:Number = NaN;
         var _loc8_:Point = null;
         var _loc6_:int = 0;
         if(!_hudViewHolder)
         {
            _hudViewHolder = GETDEFINITIONBYNAME("offScreenIconQuest");
            _hudViewHolder.mouse.gotoAndStop("up");
            _hudViewHolder.questChatBalloon.init(0,AvatarUtility.getAvatarEmoteBgOffset,false,7,SBTextField);
            if(_flashTimer)
            {
               _flashTimer.reset();
            }
            _flashTimer = new Timer(2500);
            _flashTimer.addEventListener("timer",onFlashTimer,false,0,true);
         }
         var _loc4_:Point = RoomManagerWorld.instance.bkgScalePoint();
         var _loc5_:Point = RoomManagerWorld.instance.convertWorldToScreen(this.x * _loc4_.x,this.y * _loc4_.y);
         var _loc9_:int = _hudViewHolder.mouse.height * 0.5 * _loc4_.x;
         var _loc7_:int = _hudViewHolder.mouse.width * 0.5 * _loc4_.y;
         var _loc3_:int = 73.5 * _loc4_.y;
         var _loc2_:Rectangle = new Rectangle(0,0,900 - _loc7_,550 - _loc9_ - _loc3_ + 60 * _loc4_.x);
         if(!_loc2_.containsPoint(_loc5_))
         {
            AvatarWorldView.updateScreenPositionAndDirection(_hudViewHolder,_loc2_,_loc5_);
            if(!_isOffScreen)
            {
               if(_hudViewHolder.mouse.currentFrameLabel != "up")
               {
                  _hudViewHolder.mouse.gotoAndStop("up");
               }
               if(_npc.currAvatar != null)
               {
                  _offScreenAvtView = new AvatarView();
                  (_offScreenAvtView as AvatarView).init(_npc.currAvatar,updateHudViewPosition,onHudViewChanged);
                  _offScreenAvtView.playAnim(15,false,1,onHudAvtView,true);
               }
               else
               {
                  if(!_npc.secondaryNpcMC)
                  {
                     return;
                  }
                  while(_hudViewHolder.charLayer.numChildren > 0)
                  {
                     _hudViewHolder.charLayer.removeChildAt(0);
                  }
                  _offScreenAvtView = _npc.secondaryNpcMC;
                  _offScreenAvtView.scaleX = _offScreenAvtView.scaleY = 1;
                  _loc1_ = 41 / _offScreenAvtView.width;
                  if(_offScreenAvtView.height * _loc1_ > 41)
                  {
                     _loc1_ = 41 / _offScreenAvtView.height;
                  }
                  _offScreenAvtView.scaleX = _loc1_;
                  _offScreenAvtView.scaleY = _loc1_;
                  try
                  {
                     _loc8_ = _npc.secondaryNpcMC.getCenterPoint();
                  }
                  catch(e:Error)
                  {
                     _loc8_ = new Point(0,0);
                  }
                  _offScreenAvtView.x = _loc8_.x * _loc1_;
                  _offScreenAvtView.y = _loc8_.y * _loc1_;
                  _hudViewHolder.charLayer.addChild(_offScreenAvtView);
                  _loc6_ = GuiManager.guiLayer.getChildIndex(GuiManager.mainHud);
                  GuiManager.guiLayer.addChildAt(_hudViewHolder,_loc6_);
               }
               _isOffScreen = true;
               _hudViewHolder.visible = true;
               if(_chatBalloon && _chatBalloon.parent == QuestManager._layerManager.room_orbs)
               {
                  QuestManager._layerManager.room_orbs.removeChild(_chatBalloon);
               }
            }
            _hudViewHolder.x = _loc5_.x;
            _hudViewHolder.y = _loc5_.y;
         }
         else if(_isOffScreen || _hudViewHolder.visible)
         {
            removeOffScreenHudView();
         }
      }
      
      private function onHudViewChanged(param1:AvatarView) : void
      {
         if(_offScreenAvtView)
         {
            _offScreenAvtView.playAnim(15,false,1,null,true);
         }
      }
      
      private function removeOffScreenHudView() : void
      {
         if(_hudViewHolder)
         {
            if(_hudViewHolder.mouse.currentFrameLabel != "up")
            {
               _hudViewHolder.mouse.gotoAndStop("up");
            }
            if(_hudViewHolder && _hudViewHolder.parent && _hudViewHolder.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_hudViewHolder);
            }
            _hudViewHolder.visible = false;
            _isOffScreen = false;
            if(_chatBalloon)
            {
               QuestManager._layerManager.room_orbs.addChild(_chatBalloon);
            }
            if(_npc && _npc.currAvatar != null)
            {
            }
         }
      }
      
      private function onFlashTimer(param1:TimerEvent) : void
      {
         if(_flashTimer)
         {
            _flashTimer.reset();
         }
         if(_hudViewHolder)
         {
            _hudViewHolder.mouse.gotoAndStop("up");
         }
      }
      
      private function onHudAvtView(param1:LayerAnim, param2:int) : void
      {
         updateHudViewPosition(null);
         while(_hudViewHolder.charLayer.numChildren > 0)
         {
            _hudViewHolder.charLayer.removeChildAt(0);
         }
         _hudViewHolder.charLayer.addChild(_offScreenAvtView);
         var _loc3_:int = GuiManager.guiLayer.getChildIndex(GuiManager.mainHud);
         GuiManager.guiLayer.addChildAt(_hudViewHolder,_loc3_);
      }
      
      private function updateHudViewPosition(param1:AvatarView) : void
      {
         var _loc3_:Point = AvatarUtility.getAvatarHudPosition(_offScreenAvtView.avTypeId);
         _offScreenAvtView.scaleX = _offScreenAvtView.scaleY = 1;
         var _loc2_:Number = 41 / _offScreenAvtView.width;
         if(_offScreenAvtView.height * _loc2_ > 41)
         {
            _loc2_ = 41 / _offScreenAvtView.height;
         }
         _offScreenAvtView.scaleX = _loc2_;
         _offScreenAvtView.scaleY = _loc2_;
         _offScreenAvtView.x = _loc3_.x * _loc2_;
         _offScreenAvtView.y = _loc3_.y * _loc2_;
      }
      
      private function updateAlertLP() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc5_:Number = NaN;
         if(AvatarManager.playerAvatarWorldView != null)
         {
            _loc3_ = AvatarManager.playerAvatarWorldView.x + -15 - x;
            _loc1_ = AvatarManager.playerAvatarWorldView.y + -40 - y;
            _loc4_ = _loc3_ * _loc3_ + _loc1_ * _loc1_;
            _loc2_ = 490000;
            _loc5_ = 1;
            if(_loc4_ > _loc2_)
            {
               _loc5_ = 0;
            }
            else if(_loc4_ >= 0)
            {
               _loc5_ = 1 - _loc4_ / _loc2_;
            }
            if(_loc5_ > 0)
            {
               if(_alertLP == null)
               {
                  if(isRunawayFromPlayer())
                  {
                     _alertLP = QuestManager.playLoopingSound("ajq_prototearslp");
                  }
                  else if(playPhantomLoopingSound())
                  {
                     _alertLP = QuestManager.playLoopingSound("ajq_phntmsquidlp");
                  }
               }
               QuestManager.setSoundLevel(_alertLP,_loc5_,this);
            }
            else if(_alertLP != null)
            {
               QuestManager.stopLoopingSound(_alertLP);
               _alertLP = null;
            }
         }
      }
      
      public function setPlantEats(param1:QuestActor) : void
      {
         var _loc2_:Number = 0;
         if(param1 != null)
         {
            _loc2_ = getAngleToTarget(param1.x,param1.y);
         }
         _npc.setNpcState(2,_loc2_);
         if(_npc.npcMC && _npc.npcMC.hasOwnProperty("readyForAttack"))
         {
            _npc.npcMC.readyForAttack = false;
         }
      }
      
      private function inCollision(param1:int, param2:int) : Boolean
      {
         var _loc3_:uint = RoomManagerWorld.instance.collisionTestGrid(param1,param2);
         return _loc3_ != 0 && _loc3_ != 3;
      }
      
      public function checkPlantRadius() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Point = null;
         if(_npc != null && _requestSeekTimer <= 0)
         {
            _loc1_ = 250;
            _loc2_ = _npc.collisionZapPoint;
            _seekActor = QuestManager.getNearestPlant(_actorData.actorPos.x + _loc2_.x,_actorData.actorPos.y + _loc2_.y,_loc1_,_npc.npcDef.level);
            if(_seekActive != 3)
            {
               if(_seekActor != null)
               {
                  QuestManager.setQuestActorSeek(this,3);
                  _requestSeekTimer = 1.5;
               }
            }
            else if(_seekActor == null)
            {
               QuestManager.setQuestActorSeek(this,0);
            }
            else
            {
               _requestSeekTimer = 1.5;
            }
         }
      }
      
      public function onAttackRadius() : void
      {
         var _loc1_:AvatarInfo = null;
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(AvatarManager.playerAvatarWorldView != null && _visible && (_npc == null || _npc.isDead == false))
         {
            _loc1_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
            if(QuestManager.isPlayerInStealthVolume() == false && _loc1_.questHealthPercentage > 0)
            {
               _loc3_ = distanceSqToPlayer();
               if(_npc != null && _npc.npcMC != null)
               {
                  _npc.npcMC.setDistanceToTarget(_loc3_);
               }
               if(_seekActive == 2)
               {
                  _loc2_ = _actorDefaultOuterRadius + 50;
                  if(!_radiusOverride && _loc3_ > _loc2_ * _loc2_)
                  {
                     _requestSeekTimer = 1.5;
                     _seekActive = _npcPath != null ? 1 : 0;
                     if(_npc != null && _npc.npcMC != null && _npc.npcDef.damageTouch > 0 && _npc.npcMC.hasOwnProperty("alertStatus"))
                     {
                        _npc.npcMC.alertStatus(false);
                        _alerted = false;
                        if(_alertLP)
                        {
                           QuestManager.stopLoopingSound(_alertLP);
                           _alertLP = null;
                        }
                     }
                     QuestManager.setQuestActorSeek(this,_seekActive);
                  }
               }
               else if(_requestSeekTimer <= 0)
               {
                  _requestSeekTimer = 1;
                  _loc2_ = _actorDefaultInnerRadius + 50;
                  if(_radiusOverride && _loc3_ < _loc2_ * _loc2_ * 25 || _loc3_ < _loc2_ * _loc2_)
                  {
                     QuestManager.setQuestActorSeek(this,2);
                     if(_radiusOverride && _loc3_ < _loc2_ * _loc2_)
                     {
                        _radiusOverride = false;
                     }
                  }
                  else if(!QuestManager.getNearestActorPathInGroupToPlayerInRange(this))
                  {
                     if(_seekActive != 0)
                     {
                        QuestManager.setQuestActorSeek(this,0);
                     }
                  }
                  else if(_npcPath != null && _seekActive != 1)
                  {
                     QuestManager.setQuestActorSeek(this,1);
                  }
               }
            }
            else if(_npcPath != null)
            {
               if(!QuestManager.getNearestActorPathInGroupToPlayerInRange(this))
               {
                  if(_seekActive != 0)
                  {
                     _requestSeekTimer = 1;
                     QuestManager.setQuestActorSeek(this,0);
                  }
               }
               else if(_seekActive == 2 || _seekActive == 0 && _requestSeekTimer <= 0)
               {
                  _requestSeekTimer = 1;
                  QuestManager.setQuestActorSeek(this,1);
               }
            }
            else if(_seekActive != 0)
            {
               _requestSeekTimer = 1;
               QuestManager.setQuestActorSeek(this,0);
            }
         }
      }
      
      public function meleeHitTest(param1:int, param2:Point, param3:int) : Boolean
      {
         if(_lastMeleeID != param1 && (_npc == null || _npc.isDead == false))
         {
            if(_actorData.type != 23 || _actorData.healthPercent > 0)
            {
               if(hitTest(param2,param3))
               {
                  _lastMeleeID = param1;
                  return true;
               }
            }
         }
         return false;
      }
      
      public function hitTest(param1:Point, param2:int) : Boolean
      {
         var _loc3_:Point = null;
         if(_visible && (_npc == null || _npc.isDying == false))
         {
            switch(_actorData.type)
            {
               case 23:
               case 11:
               case 12:
                  _loc3_ = _npc.collisionMovingPoint;
                  if(Collision.circleHitCircle(param1,param2,new Point(x + _loc3_.x,y + _loc3_.y),_npc.collisionRadiusMoving))
                  {
                     return true;
                  }
                  break;
               case 21:
                  if(plantTargettable())
                  {
                     _loc3_ = _npc.collisionMovingPoint;
                     if(Collision.circleHitCircle(param1,param2,new Point(x + _loc3_.x,y + _loc3_.y),_npc.collisionRadiusMoving))
                     {
                        return true;
                     }
                  }
            }
         }
         return false;
      }
      
      private function onMediaHelperNpcIconReceived(param1:MovieClip) : void
      {
         if(_mh)
         {
            _clickIcon = param1;
            _mh.destroy();
            _mh = null;
            showNpcClickIcon();
         }
      }
      
      public function showNpcClickIcon() : void
      {
         var _loc1_:Point = null;
         try
         {
            _loc1_ = _npc.npcMC.getAttachmentPoint();
         }
         catch(e:Error)
         {
            _loc1_ = new Point(-10,-90);
         }
         _clickIcon.x = x + _loc1_.x;
         _clickIcon.y = y + _loc1_.y;
         QuestManager._layerManager.room_orbs.addChild(_clickIcon);
         QuestManager.playSound("ajq_popup");
         _clickIcon.addEventListener("mouseDown",onMouseDownEvt_Click,false,0,true);
         _clickIcon.addEventListener("rollOver",onMouseOverEvt_Click,false,0,true);
         _clickIcon.addEventListener("rollOut",onMouseOutEvt_Click,false,0,true);
      }
      
      public function onRadiusTest() : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc7_:Number = NaN;
         var _loc8_:Point = null;
         var _loc1_:Point = null;
         var _loc6_:int = 0;
         var _loc5_:Point = null;
         var _loc3_:AvatarInfo = null;
         var _loc9_:QuestPlayerData = null;
         var _loc2_:String = null;
         if(AvatarManager.playerAvatarWorldView != null && _visible && (_npc == null || _npc.isDead == false))
         {
            _loc4_ = false;
            if(_volumes != null)
            {
               switch(_actorData.type)
               {
                  case 14:
                  case 4:
                  case 3:
                  case 24:
                     _loc6_ = 0;
                     while(_loc6_ < _volumes.length)
                     {
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y),_volumes[_loc6_]))
                        {
                           if(_actorData.type != 24 || _interactionAnimIds == null || _interactionAnimIds.indexOf(AvatarManager.playerAvatarWorldView.animId) >= 0)
                           {
                              _loc4_ = true;
                           }
                           break;
                        }
                        _loc6_++;
                     }
               }
            }
            else
            {
               _loc8_ = new Point(x,y);
               switch(_actorData.type)
               {
                  case 12:
                     _loc7_ = _actorDefaultOuterRadius;
                     break;
                  case 13:
                     _loc7_ = _actorDefaultInnerRadius;
                     break;
                  case 200:
                     var _loc10_:* = _actorData.subType;
                     if(4 !== _loc10_)
                     {
                        _loc7_ = 25;
                     }
                     else
                     {
                        _loc7_ = 60;
                     }
                     break;
                  case 1:
                     if(_npc != null)
                     {
                        _loc1_ = _npc.collisionMovingPoint;
                        _loc8_.x += _loc1_.x;
                        _loc8_.y += _loc1_.y;
                     }
                     _loc7_ = _actorDefaultOuterRadius;
                     break;
                  case 16:
                     _loc7_ = _actorDefaultOuterRadius;
                     break;
                  default:
                     if(_npc != null)
                     {
                        _loc1_ = _npc.collisionMovingPoint;
                        _loc8_.x += _loc1_.x;
                        _loc8_.y += _loc1_.y;
                        _loc7_ = _npc.collisionRadiusMoving;
                     }
                     else
                     {
                        _loc7_ = _actorDefaultOuterRadius;
                     }
               }
               if(_loc7_ > 0)
               {
                  _loc4_ = Collision.circleHitCircle(_loc8_,_loc7_,new Point(AvatarManager.playerAvatarWorldView.avatarPos.x + -15,AvatarManager.playerAvatarWorldView.avatarPos.y + -40),50 * 1.5);
               }
            }
            if(_loc4_)
            {
               if(_playerSeekingActor)
               {
                  if(_npc)
                  {
                     switch(_actorData.type)
                     {
                        case 12:
                           _loc1_ = _npc.collisionMovingPoint;
                           _loc8_.x += _loc1_.x;
                           _loc8_.y += _loc1_.y;
                           _loc7_ = _npc.collisionRadiusMoving;
                           if(!Collision.circleHitCircle(_loc8_,_loc7_,new Point(AvatarManager.playerAvatarWorldView.avatarPos.x + -15,AvatarManager.playerAvatarWorldView.avatarPos.y + -40),50 * 1.5))
                           {
                              break;
                           }
                        case 11:
                        case 23:
                           if(_loc8_ && _attackable == 1 && _actorData.healthPercent > 0)
                           {
                              QuestManager.playerLaunchWeapon(_loc8_,false);
                           }
                           _playerSeekingActor = false;
                           gMainFrame.stage.removeEventListener("mouseDown",onMouseDownEvt_CancelAttack);
                           RoomManagerWorld.instance.forceStopMovement();
                           AvatarManager.playerAvatarWorldView.faceAnim(_loc8_.x - AvatarManager.playerAvatarWorldView.avatarPos.x,_loc8_.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
                     }
                  }
               }
               if(_inRadius != _loc4_ || _actorData.type == 15 && _clickIcon == null || _actorData.type == 17 && _clickIcon == null || _actorData.type == 200 && _clickIcon == null || _actorData.type == 13 && _clickIcon == null || _actorData.type == 1 && _clickIcon == null && _mh == null)
               {
                  removeClickIcon();
                  switch(_actorData.type)
                  {
                     case 16:
                        break;
                     case 12:
                        QuestXtCommManager.questActorTriggered(_actorId);
                        break;
                     case 13:
                        if(_actorData.status == 0 && _npc.npcState != 6)
                        {
                           _clickIcon = GETDEFINITIONBYNAME("QuestPickupIcon");
                           if(_npc != null && _npc.npcMC != null && _npc.npcMC.hasOwnProperty("getTreasureIconOffsetPoint"))
                           {
                              _loc5_ = _npc.npcMC.getTreasureIconOffsetPoint();
                              _clickIcon.x = x + _loc5_.x;
                              _clickIcon.y = y + _loc5_.y;
                           }
                           else
                           {
                              _clickIcon.x = x + 0;
                              _clickIcon.y = y + -40;
                           }
                           QuestManager._layerManager.room_orbs.addChild(_clickIcon);
                           QuestManager.playSound("ajq_popup");
                           _clickIcon.addEventListener("mouseDown",onMouseDownEvt_Click,false,0,true);
                           _clickIcon.addEventListener("rollOver",onMouseOverEvt_Click,false,0,true);
                           _clickIcon.addEventListener("rollOut",onMouseOutEvt_Click,false,0,true);
                        }
                        break;
                     case 15:
                     case 17:
                        if(_updatePositionTimer <= 0)
                        {
                           _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                           if(_loc3_.questHealthPercentage > 0)
                           {
                              _clickIcon = GETDEFINITIONBYNAME("QuestPickupIcon");
                              _clickIcon.x = x + 0;
                              _clickIcon.y = y + -40;
                              QuestManager._layerManager.room_orbs.addChild(_clickIcon);
                              QuestManager.playSound("ajq_popup");
                              _clickIcon.addEventListener("mouseDown",onMouseDownEvt_Click,false,0,true);
                              _clickIcon.addEventListener("rollOver",onMouseOverEvt_Click,false,0,true);
                              _clickIcon.addEventListener("rollOut",onMouseOutEvt_Click,false,0,true);
                           }
                        }
                        break;
                     case 1:
                        if(_npc)
                        {
                           if(_requireClick && _npcPath == null && (_chatBalloon == null || !_chatBalloon.visible || _chatBalloon.alpha == 0))
                           {
                              if(_npc.npcDef.iconMediaRefId != 0)
                              {
                                 _mh = new MediaHelper();
                                 _mh.init(_npc.npcDef.iconMediaRefId,onMediaHelperNpcIconReceived);
                              }
                           }
                        }
                        break;
                     case 14:
                     case 4:
                     case 3:
                     case 24:
                        QuestXtCommManager.questActorTriggered(_actorId);
                        break;
                     case 5:
                        break;
                     case 200:
                        if(_actorData.subType == 3 || _actorData.subType == 4)
                        {
                           if(_npc != null && _npc.npcState == 5)
                           {
                              _loc9_ = QuestManager.getQuestPlayerData(AvatarManager.playerSfsUserId);
                              if(_loc9_)
                              {
                                 _loc2_ = "+" + _actorData.gems;
                                 _loc9_.playStatusText(_loc2_);
                              }
                              _npc.setNpcState(6);
                              QuestXtCommManager.questActorTriggered(_actorId,1);
                              _actorData.pickedUp = true;
                           }
                        }
                  }
               }
            }
            else
            {
               if(_inRadius != _loc4_)
               {
                  switch(_actorData.type)
                  {
                     case 16:
                        if(_speakerSoundChannel != null)
                        {
                           _speakerSoundChannel.stop();
                           _speakerSoundChannel = null;
                        }
                        break;
                     case 24:
                     case 14:
                        QuestXtCommManager.questActorUntriggered(_actorId);
                        break;
                     case 12:
                        QuestXtCommManager.questActorUntriggered(_actorId);
                  }
               }
               removeClickIcon();
            }
            _inRadius = _loc4_;
            return _inRadius;
         }
         removeClickIcon();
         _loc10_ = _actorData.type;
         if(16 === _loc10_)
         {
            if(_speakerSoundChannel != null)
            {
               _speakerSoundChannel.stop();
               _speakerSoundChannel = null;
            }
         }
         return false;
      }
      
      private function removeClickIcon() : void
      {
         if(_actorData.type == 12 || _actorData.type == 1)
         {
            if(_mh)
            {
               _mh.destroy();
               _mh = null;
            }
         }
         if(_clickIcon)
         {
            if(_clickIcon.parent)
            {
               _clickIcon.parent.removeChild(_clickIcon);
            }
            _clickIcon = null;
         }
      }
      
      public function handleMouseDown(param1:Point) : Boolean
      {
         var _loc3_:Point = null;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
         switch(_actorData.type)
         {
            case 12:
            case 11:
            case 23:
               if(_actorData.type != 23 || npcDef == null || npcDef.defense != 99999)
               {
                  if(AvatarManager.playerAvatarWorldView != null && _npc != null && _npc.isDead == false)
                  {
                     if(_visible)
                     {
                        _loc3_ = _npc.collisionMovingPoint;
                        _loc3_.x += x;
                        _loc3_.y += y;
                        _loc6_ = (param1.x - _loc3_.x) * (param1.x - _loc3_.x) + (param1.y - _loc3_.y) * (param1.y - _loc3_.y);
                        if(_loc6_ < _npc.collisionRadiusMoving * _npc.collisionRadiusMoving)
                        {
                           _loc4_ = AvatarManager.playerAvatarWorldView.avatarPos.x + -15 - _loc3_.x;
                           _loc5_ = AvatarManager.playerAvatarWorldView.avatarPos.y + -40 - _loc3_.y;
                           _loc2_ = _npc.collisionRadiusMoving + 1.75 * 50;
                           if(_loc4_ * _loc4_ + _loc5_ * _loc5_ <= _loc2_ * _loc2_)
                           {
                              if(_attackable == 1 && _actorData.healthPercent > 0)
                              {
                                 QuestManager.playerLaunchWeapon(_loc3_,false);
                              }
                              _playerSeekingActor = false;
                              gMainFrame.stage.removeEventListener("mouseDown",onMouseDownEvt_CancelAttack);
                              return true;
                           }
                        }
                     }
                  }
               }
         }
         return false;
      }
      
      private function treasurePopupType(param1:int = 1) : int
      {
         if(param1 == 2)
         {
            return 15;
         }
         switch(_actorData.defId)
         {
            case 260:
               return 10;
            case 261:
               return 12;
            case 262:
               return 11;
            case 263:
               return 9;
            case 266:
               return 13;
            case 385:
               return 18;
            case 483:
               return 19;
            default:
               return 7;
         }
      }
      
      private function onMouseDownEvt_DroppedTreasure(param1:MouseEvent) : void
      {
         var _loc3_:DenItem = null;
         var _loc2_:Item = null;
         if(_visible)
         {
            if(_npc != null && _npc.npcStateComplete)
            {
               _npc.setNpcState(6);
               removeEventListener("mouseDown",onMouseDownEvt_DroppedTreasure);
               switch(_actorData.subType)
               {
                  case 1:
                     _loc3_ = new DenItem();
                     _loc3_.initShopItem(_actorData.denDefId,0);
                     _prizePopup = new GiftPopup();
                     _prizePopup.init(QuestManager._layerManager.gui,_loc3_.icon,_loc3_.name,_loc3_.defId,treasurePopupType(),2,keptItem,rejectedItem,destroyPrizePopup);
                     break;
                  case 2:
                     _prizePopup = new GiftPopup();
                     _loc2_ = new Item();
                     _loc2_.init(_actorData.defId,0,_actorData.itemData,0,0,true);
                     _prizePopup.init(QuestManager._layerManager.gui,_loc2_.largeIcon,_loc2_.name,_loc2_.defId,treasurePopupType(),1,keptItem,rejectedItem,destroyPrizePopup);
                     break;
                  case 3:
                     _mh = new MediaHelper();
                     _mh.init(1086,onMediaHelperGemIconReceived);
                     break;
                  case 4:
                     _mh = new MediaHelper();
                     _mh.init(2057,onMediaHelperOrbIconReceived);
                     break;
                  default:
                     QuestXtCommManager.questActorTriggered(_actorId);
               }
               param1.stopPropagation();
            }
         }
      }
      
      private function onMediaHelperBouncerReceived(param1:MovieClip) : void
      {
         _mediaObject = param1;
         _mediaObject.x = 0;
         _mediaObject.y = 0;
         addChild(_mediaObject);
         QuestManager._layerManager.room_avatars.addChild(this);
         _mh.destroy();
         _mh = null;
         _loadingComplete = true;
      }
      
      private function onMediaHelperItemReceived(param1:MovieClip) : void
      {
         _mediaObject = param1;
         _mediaObject.setPlace(1);
         _mediaObject.x = 0;
         _mediaObject.y = 0;
         addChild(_mediaObject);
         QuestManager._layerManager.room_avatars.addChild(this);
         _mh.destroy();
         _mh = null;
         _loadingComplete = true;
      }
      
      private function onMediaHelperPlatformReceived(param1:MovieClip) : void
      {
         _mediaObject = param1;
         _mediaObject.x = 0;
         _mediaObject.y = 0;
         addChild(_mediaObject);
         QuestManager._layerManager.room_avatars.addChild(this);
         if(_mediaObject.hasOwnProperty("getSortHeight"))
         {
            name = _mediaObject.getSortHeight();
         }
         _mh.destroy();
         _mh = null;
         _loadingComplete = true;
      }
      
      private function onMediaHelperOrbIconReceived(param1:MovieClip) : void
      {
         _prizePopup = new GiftPopup();
         _prizePopup.init(QuestManager._layerManager.gui,param1,LocalizationManager.translateIdAndInsertOnly(11117,_actorData.gems),_actorData.gems,2,7,keptItem,keptItem,destroyPrizePopup,false,1);
         _mh.destroy();
         _mh = null;
      }
      
      private function onMediaHelperGemIconReceived(param1:MovieClip) : void
      {
         _prizePopup = new GiftPopup();
         _prizePopup.init(QuestManager._layerManager.gui,param1,LocalizationManager.translateIdAndInsertOnly(11097,_actorData.gems),_actorData.gems,2,0,keptItem,keptItem,destroyPrizePopup,false,1);
         _mh.destroy();
         _mh = null;
      }
      
      private function keptItem() : void
      {
         QuestXtCommManager.questActorTriggered(_actorId,1);
         _prizePopup.close();
      }
      
      private function rejectedItem() : void
      {
         QuestXtCommManager.questActorTriggered(_actorId,0);
         _prizePopup.close();
      }
      
      private function destroyPrizePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
      }
      
      public function testForClickAttack(param1:Point) : Boolean
      {
         var _loc4_:Point = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:* = _actorData.type;
         if(11 === _loc5_)
         {
            if(_npc != null && _npc.npcMC != null && _actorData.healthPercent > 0)
            {
               if(_npc.npcMC.hasOwnProperty("clickTarget"))
               {
                  if(_npc.npcMC.hasOwnProperty("clickOnPhantom"))
                  {
                     _loc4_ = _npc.collisionMovingPoint;
                     _loc2_ = param1.x - (x + _loc4_.x);
                     _loc3_ = param1.y - (y + _loc4_.y);
                     if(_loc2_ == 0 && _loc3_ == 0 || _loc2_ * _loc2_ + _loc3_ * _loc3_ < 2500)
                     {
                        if(_npc.npcMC.clickOnPhantom())
                        {
                           QuestManager.questActorAttacked(_actorId,-1,0,0,this);
                           return true;
                        }
                     }
                  }
               }
            }
         }
         return false;
      }
      
      private function onMouseDownEvt_Attack(param1:MouseEvent) : void
      {
         var _loc3_:Point = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
         switch(_actorData.type)
         {
            case 23:
            case 11:
               if(_attackable == 1 && _visible && AvatarManager.playerAvatarWorldView != null && _npc != null && _npc.isDead == false && QuestManager.projectileKeyDown == false)
               {
                  _loc3_ = _npc.collisionMovingPoint;
                  _loc3_.x += x;
                  _loc3_.y += y;
                  _loc4_ = AvatarManager.playerAvatarWorldView.avatarPos.x + -15 - _loc3_.x;
                  _loc5_ = AvatarManager.playerAvatarWorldView.avatarPos.y + -40 - _loc3_.y;
                  _loc2_ = _npc.collisionRadiusMoving + 1.75 * 50;
                  if(_loc4_ * _loc4_ + _loc5_ * _loc5_ > _loc2_ * _loc2_)
                  {
                     _playerSeekingActor = true;
                     gMainFrame.stage.addEventListener("mouseDown",onMouseDownEvt_CancelAttack);
                  }
               }
         }
      }
      
      private function onMouseDownEvt_CancelAttack(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         while(_loc2_ != null)
         {
            if(_loc2_ == this)
            {
               return;
            }
            _loc2_ = _loc2_.parent;
         }
         _playerSeekingActor = false;
         gMainFrame.stage.removeEventListener("mouseDown",onMouseDownEvt_CancelAttack);
      }
      
      private function handleClick() : void
      {
         var _loc1_:AvatarInfo = null;
         switch(_actorData.type)
         {
            case 13:
               if(_npc != null)
               {
                  _actorData.status = 1;
                  QuestXtCommManager.questActorTriggered(_actorId);
               }
               break;
            case 15:
            case 17:
               if(AvatarManager.playerAvatarWorldView != null)
               {
                  _loc1_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                  if(_loc1_.questHealthPercentage > 0)
                  {
                     QuestXtCommManager.questPickUpItem(_actorId);
                     _updatePositionTimer = 1;
                  }
               }
               break;
            default:
               QuestXtCommManager.questActorTriggered(_actorId);
         }
         removeClickIcon();
      }
      
      private function onMouseDownEvt_Click(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         handleClick();
      }
      
      private function onMouseOverEvt_Click(param1:MouseEvent) : void
      {
         MovieClip(param1.currentTarget).transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
      }
      
      private function onMouseOutEvt_Click(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
         MovieClip(param1.currentTarget).transform.colorTransform = new ColorTransform(1,1,1);
      }
      
      public function onNpcLoaded() : void
      {
         var _loc1_:* = null;
         var _loc6_:Array = null;
         var _loc4_:String = null;
         var _loc3_:Array = null;
         var _loc8_:int = 0;
         var _loc5_:Array = null;
         var _loc7_:int = 0;
         var _loc2_:Array = null;
         if(_npc == null)
         {
            return;
         }
         _npc.x = 0;
         _npc.y = 0;
         addChild(_npc);
         switch(_actorData.type)
         {
            case 12:
            case 11:
            case 23:
               _npc.updateHealthBar(_actorData.healthPercent,0,false,_actorData.type == 23);
               if(_spawnedFromPos != null)
               {
                  _updatePositionTimer = 1;
                  _npc.npcMC.appear(180,_spawnedFromPos);
                  if(_actorData.type == 11)
                  {
                     _radiusOverride = true;
                     _npc.npcMC.setVisionAnim(false);
                  }
               }
               else if(_actorData.respawned)
               {
                  _npc.setNpcState(0);
               }
               if(_actorData.type == 11)
               {
                  if(_npc.npcMC.hasOwnProperty("setVision"))
                  {
                     _npc.npcMC.setVision(_actorDefaultInnerRadius);
                  }
                  if(_npc.npcMC.hasOwnProperty("setBubbleTrail"))
                  {
                     _npc.npcMC.setBubbleTrail(QuestManager._layerManager.room_avatars);
                  }
                  _targetRangeMin = 100;
                  _targetRangeMax = 350;
                  if(_actorData.extendedParameters != null)
                  {
                     _loc6_ = _actorData.extendedParameters.split(",");
                     _loc8_ = 0;
                     while(_loc8_ < _loc6_.length)
                     {
                        _loc4_ = _loc6_[_loc8_];
                        if(_loc4_.search("=") != -1)
                        {
                           _loc3_ = _loc4_.split("=");
                           switch(_loc3_[0])
                           {
                              case "normalspeed":
                                 if(_npc.npcMC.hasOwnProperty("setSpeeds"))
                                 {
                                    _npc.npcMC.setSpeeds("normalspeed",_loc3_[1]);
                                 }
                                 break;
                              case "alertedspeed":
                                 if(_npc.npcMC.hasOwnProperty("setSpeeds"))
                                 {
                                    _npc.npcMC.setSpeeds("alertedspeed",_loc3_[1]);
                                 }
                                 break;
                              case "targetrangemax":
                                 _targetRangeMax = _loc3_[1];
                                 break;
                              case "targetrangemin":
                                 _targetRangeMin = _loc3_[1];
                           }
                        }
                        _loc8_++;
                     }
                  }
               }
               if(_npc.npcMC.hasOwnProperty("setHealth"))
               {
                  _npc.npcMC.setHealth(_actorData.healthPercent);
               }
               if(_npc._eye && QuestManager._darknessMask)
               {
                  QuestManager._layerManager.room_fg.addChild(_npc._eye);
                  _eyeInFG = true;
               }
               if(_npc._beam && QuestManager._darknessMask)
               {
                  QuestManager._layerManager.room_fg.addChild(_npc._beam);
                  _beamInFG = true;
               }
               break;
            case 200:
               _npc.setNpcState(5);
               switch(_actorData.subType)
               {
                  case 4:
                  case 3:
                     QuestManager._layerManager.room_bkg_main.addChild(this);
                     break;
                  default:
                     addEventListener("mouseDown",onMouseDownEvt_DroppedTreasure);
               }
               break;
            case 13:
               if(_actorData.status == 0)
               {
                  _npc.setNpcState(5);
               }
               else
               {
                  _npc.setNpcState(6);
               }
               break;
            case 21:
               if(_npc.npcMC.hasOwnProperty("setAttackStartPosition") && _actorData.hasOwnProperty("seedLaunchX"))
               {
                  _npc.npcMC.setAttackStartPosition(_actorData.seedLaunchX - _loc8_,_actorData.seedLaunchY - y);
               }
               mouseEnabled = false;
               mouseChildren = false;
               _npc.updateHealthBar(_actorData.healthPercent,0,false,_actorData.type == 23);
               if(_actorData["plantEaten"] != null && _actorData.plantEaten)
               {
                  setPlantEats(null);
                  _actorData.pendingSwfStateName = null;
               }
               else
               {
                  _npc.npcMC.appear(180,_spawnedFromPos);
               }
               break;
            case 1:
               mouseEnabled = false;
               mouseChildren = false;
               if(_npc.npcMC && _npc.npcMC.hasOwnProperty("setBubbleTrail"))
               {
                  _npc.npcMC.setBubbleTrail(QuestManager._layerManager.room_avatars);
               }
               break;
            case 25:
               mouseEnabled = false;
               mouseChildren = false;
               _actorData.lightParamSpeed = 0;
               _actorData.lightParamStartAngle = 0;
               _actorData.lightParamEndAngle = -1;
               _actorData.lightParamMaxLength = _actorDefaultOuterRadius;
               if(_actorData.extendedParameters != null)
               {
                  _loc5_ = _actorData.extendedParameters.split(",");
                  _loc7_ = 0;
                  while(_loc7_ < _loc5_.length)
                  {
                     _loc2_ = _loc5_[_loc7_].split("=");
                     switch(_loc2_[0])
                     {
                        case "speed":
                           _actorData.lightParamSpeed = Number(_loc2_[1]);
                           break;
                        case "start":
                           _actorData.lightParamStartAngle = Number(_loc2_[1]);
                           break;
                        case "end":
                           _actorData.lightParamEndAngle = Number(_loc2_[1]);
                     }
                     _loc7_++;
                  }
                  if(_actorData.lightParamEndAngle != -1 && _actorData.lightParamEndAngle < _actorData.lightParamStartAngle)
                  {
                     _actorData.lightParamEndAngle += 360;
                  }
               }
               _actorData.lightParamAngle = _actorData.lightParamStartAngle;
               _npc.npcMC.setLength(_actorData.lightParamMaxLength);
               _npc.npcMC.setAngle(_actorData.lightParamAngle);
         }
         _npc.setNpcState(0,0);
         _loadingComplete = true;
         if(_actorData.pendingSwfStateName != null && _actorData.pendingSwfStateName.length > 0)
         {
            while(_actorData.pendingSwfStateName.length > 0)
            {
               setSwfState(_actorData.pendingSwfStateName.shift());
            }
         }
      }
      
      public function getActiveWeapon(param1:Boolean) : int
      {
         var _loc2_:Object = QuestManager.getNPCDef(_actorData.defId);
         var _loc3_:int = 0;
         _loc3_ = evaluateWeapon(param1,_loc2_.backItemRefId,_loc2_.backColor,_loc3_);
         _loc3_ = evaluateWeapon(param1,_loc2_.eyesItemRefId,_loc2_.eyesColor,_loc3_);
         _loc3_ = evaluateWeapon(param1,_loc2_.legItemRefId,_loc2_.legColor,_loc3_);
         _loc3_ = evaluateWeapon(param1,_loc2_.headItemRefId,_loc2_.headColor,_loc3_);
         _loc3_ = evaluateWeapon(param1,_loc2_.neckItemRefId,_loc2_.neckColor,_loc3_);
         return evaluateWeapon(param1,_loc2_.tailItemRefId,_loc2_.tailColor,_loc3_);
      }
      
      public function evaluateWeapon(param1:Boolean, param2:int, param3:Number, param4:int) : int
      {
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         if(param2 != 0)
         {
            _loc5_ = ItemXtCommManager.getItemDef(param2);
            if(_loc5_ && _loc5_.attackMediaRefId != 0)
            {
               if(param1 && _loc5_.combatType == 1 || param1 == false && (_loc5_.combatType == 0 || _loc5_.combatType == 2))
               {
                  if(param4 != 0)
                  {
                     _loc6_ = ItemXtCommManager.getItemDef(param4);
                     if(_loc5_.damage > _loc6_.damage)
                     {
                        _attackPlayerWeaponColor = param3;
                        param4 = param2;
                     }
                  }
                  else
                  {
                     _attackPlayerWeaponColor = param3;
                     param4 = param2;
                  }
               }
            }
         }
         return param4;
      }
      
      public function recoil() : void
      {
         _npc.setNpcState(3,0);
      }
      
      public function handleHit(param1:Boolean, param2:int) : void
      {
         if(_npc != null && _npc.isDying == false)
         {
            if(param1)
            {
               if(_actorData.type == 23 || _actorData.type == 11 && _attackable > 0)
               {
                  QuestManager.questActorAttacked(_actorId,param2,x,y,this);
               }
               if(_actorData.type == 11 && _seekActive < 2)
               {
                  _requestSeekTimer = 2;
                  QuestManager.setQuestActorSeek(this,2);
               }
            }
            if(_actorData.type == 23 || _actorData.type == 11 && _attackable > 0)
            {
               recoil();
            }
         }
      }
      
      public function getAngleToTarget(param1:Number, param2:Number) : Number
      {
         var _loc7_:Point = _npc.collisionMovingPoint;
         var _loc5_:Number = param1 - (x + _loc7_.x);
         var _loc4_:Number = param2 - (y + _loc7_.y);
         if(_loc5_ == 0 && _loc4_ == 0)
         {
            _loc5_ = 1;
         }
         var _loc3_:Number = Math.sqrt(_loc5_ * _loc5_ + _loc4_ * _loc4_);
         if(_loc3_ != 0)
         {
            _loc5_ /= _loc3_;
            _loc4_ /= _loc3_;
         }
         else
         {
            _loc5_ = 1;
            _loc4_ = 0;
         }
         var _loc6_:Number = Math.asin(_loc5_);
         if(_loc4_ > 0)
         {
            _loc6_ = -(3.141592653589793 + _loc6_);
         }
         return _loc6_ * 180 / 3.141592653589793;
      }
      
      public function handleAttackPlayer(param1:int, param2:uint, param3:int) : void
      {
         var _loc4_:Number = NaN;
         if(_npc != null && AvatarManager.avatarViewList[param3] != null)
         {
            _attackPlayerSfsId = param3;
            _attackPlayerWeaponItemDefId = param1;
            _attackPlayerWeaponColor = param2;
            _loc4_ = getAngleToTarget(AvatarManager.avatarViewList[param3].avatarPos.x + -15,AvatarManager.avatarViewList[param3].avatarPos.y + -40);
            _npc.setNpcState(2,_loc4_);
         }
      }
      
      public function healthUpdate(param1:int, param2:int, param3:Boolean) : void
      {
         if(_npc != null)
         {
            _npc.updateHealthBar(param1,param2,param3,_actorData.type == 23);
            if(_npc.npcMC != null && _npc.npcMC.hasOwnProperty("setHealth"))
            {
               _npc.npcMC.setHealth(param1);
            }
         }
      }
      
      public function handleDeath(param1:int) : Boolean
      {
         if(_npc != null)
         {
            _npc.updateHealthBar(0,param1,false,_actorData.type == 23);
         }
         if(_alertLP)
         {
            QuestManager.stopLoopingSound(_alertLP);
            _alertLP = null;
         }
         switch(_actorData.type)
         {
            case 12:
            case 11:
            case 23:
               removeEventListener("mouseDown",onMouseDownEvt_Attack);
               if(_npc != null)
               {
                  _npc.setNpcState(4,0);
                  return false;
               }
               break;
            default:
               if(_npc != null && _npc.npcMC != null && _npc.npcMC.hasOwnProperty("deathAnimComplete"))
               {
                  return _npc.npcMC.deathAnimComplete;
               }
         }
         return true;
      }
      
      public function handleTriggerTreasure(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc6_:DenItem = null;
         var _loc5_:Item = null;
         switch(param1 - 1)
         {
            case 0:
               _loc6_ = new DenItem();
               _loc6_.initShopItem(param2,0);
               _prizePopup = new GiftPopup();
               _prizePopup.init(QuestManager._layerManager.gui,_loc6_.icon,_loc6_.name,_loc6_.defId,treasurePopupType(param4),2,keptPlacedTreasure,rejectedPlacedTreasure,destroyPlacedTreasurePopup,false,0,AvatarManager.roomEnviroType);
               break;
            case 1:
               _prizePopup = new GiftPopup();
               _loc5_ = new Item();
               _loc5_.init(param2,0,param3,0,0,true);
               _prizePopup.init(QuestManager._layerManager.gui,_loc5_.largeIcon,_loc5_.name,_loc5_.defId,treasurePopupType(param4),1,keptPlacedTreasure,rejectedPlacedTreasure,destroyPlacedTreasurePopup,false,0,AvatarManager.roomEnviroType);
               break;
            case 2:
               _prizeAmount = param2;
               _mh = new MediaHelper();
               _mh.init(1086,onMediaHelperGemIconDroppedTreasureReceived);
               break;
            case 3:
               _prizeAmount = param2;
               _mh = new MediaHelper();
               _mh.init(2057,onMediaHelperCrystalIconDroppedTreasureReceived);
               break;
            case 4:
               _actorData.status = 0;
               break;
            case 5:
               if(_npc != null && _npc.npcState == 5)
               {
                  _npc.setNpcState(6);
               }
               break;
            case 6:
               if(_npc != null && _npc.npcState == 5)
               {
                  _npc.setNpcState(6);
               }
         }
      }
      
      private function onMediaHelperCrystalIconDroppedTreasureReceived(param1:MovieClip) : void
      {
         _prizePopup = new GiftPopup();
         _prizePopup.init(QuestManager._layerManager.gui,param1,LocalizationManager.translateIdAndInsertOnly(11117,_prizeAmount),_prizeAmount,treasurePopupType(),7,keptDroppedTreasure,keptDroppedTreasure,destroyDroppedTreasurePopup,false,1,AvatarManager.roomEnviroType);
         _mh.destroy();
         _mh = null;
      }
      
      private function onMediaHelperGemIconDroppedTreasureReceived(param1:MovieClip) : void
      {
         _prizePopup = new GiftPopup();
         _prizePopup.init(QuestManager._layerManager.gui,param1,LocalizationManager.translateIdAndInsertOnly(11097,_prizeAmount),_prizeAmount,treasurePopupType(),0,keptDroppedTreasure,keptDroppedTreasure,destroyDroppedTreasurePopup,false,1,AvatarManager.roomEnviroType);
         _mh.destroy();
         _mh = null;
      }
      
      private function keptPlacedTreasure() : void
      {
         QuestXtCommManager.questActorTreasureTriggered(_actorId,1);
         _prizePopup.close();
         _actorData.status = 1;
         _npc.setNpcState(6);
      }
      
      private function rejectedPlacedTreasure() : void
      {
         QuestXtCommManager.questActorTreasureTriggered(_actorId,0);
         _prizePopup.close();
         _actorData.status = 1;
         _npc.setNpcState(6);
      }
      
      private function destroyPlacedTreasurePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
      }
      
      private function keptDroppedTreasure() : void
      {
         switch(_actorData.type)
         {
            case 200:
            case 13:
               if(_npc != null && _npc.npcState == 5)
               {
                  _npc.setNpcState(6);
               }
         }
         if(GuiManager.isInFFM)
         {
            AvatarXtCommManager.sendAvatarPendingFlagsUpdate(0);
            gMainFrame.userInfo.firstFiveMinutes = 1;
         }
         QuestXtCommManager.questActorTreasureTriggered(_actorId,1);
         _prizePopup.close();
      }
      
      private function destroyDroppedTreasurePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
      }
      
      public function setSwfState(param1:String) : void
      {
         if(param1 == "attack" && _actorData.type == 21)
         {
            QuestXtCommManager.sendPlantAte(_actorId,"");
            QuestManager.handlePlantAte(_actorId,"");
            return;
         }
         if(_actorData.type == 30)
         {
            if(_mediaObject && _mediaObject.collisionOn)
            {
               _mediaObject.setStateByScript(param1);
            }
            return;
         }
         var _loc2_:* = _actorData.type;
         if(13 === _loc2_)
         {
            if(param1 == "appear")
            {
               if(_actorData.status != 0)
               {
                  param1 = "opened";
               }
            }
         }
         if(_npc != null && _loadingComplete)
         {
            _updatePositionTimer = _npc.setSwfState(param1);
            if(_updatePositionTimer > 0)
            {
               _spawnedFromPos = new Point(x,y);
            }
         }
         else
         {
            if(_actorData.pendingSwfStateName == null)
            {
               _actorData.pendingSwfStateName = [];
            }
            _actorData.pendingSwfStateName.push(param1);
         }
      }
      
      public function setActorText(param1:String) : void
      {
         if(_npc != null)
         {
            _npc.playHitText(param1);
         }
      }
      
      private function initChatBalloon(param1:int) : void
      {
         var _loc2_:Point = null;
         _chatBalloon = GETDEFINITIONBYNAME("ChatBalloonAsset");
         _chatBalloon.init(0,AvatarUtility.getAvatarEmoteBgOffset,param1 == 9 ? true : false,param1,QuestManager._layerManager.bkg.scaleX);
         try
         {
            _loc2_ = _npc.npcMC.getAttachmentPoint();
         }
         catch(e:Error)
         {
            _loc2_ = new Point(-10,-90);
         }
         _chatBalloon.setPos(x + _loc2_.x,y + _loc2_.y);
         QuestManager._layerManager.room_orbs.addChild(_chatBalloon);
      }
      
      public function setEmote(param1:Sprite) : void
      {
         if(!_chatBalloon)
         {
            initChatBalloon(1);
         }
         if(_chatBalloon)
         {
            _chatBalloon.setEmote(param1,-1);
         }
      }
      
      public function setChatBalloonText(param1:String, param2:Boolean = false, param3:Boolean = false) : void
      {
         var _loc4_:int = 0;
         if(!_chatBalloon)
         {
            _loc4_ = 1;
            if(param2)
            {
               _loc4_ = 2;
            }
            else if(param3)
            {
               _loc4_ = 9;
            }
            initChatBalloon(_loc4_);
         }
         if(_chatBalloon)
         {
            _chatBalloon.setText(param1);
         }
      }
      
      public function setPath(param1:String) : void
      {
         if(param1 != null)
         {
            _npcPath = RoomManagerWorld.instance.findPathByName(param1);
            if(_npcPath != null)
            {
               removeClickIcon();
               _npcReachedPathEnd = false;
               _pathDirectionForward = true;
               _pathNode = Math.min(_npcPath.points.length - 1,1);
               if(_seekActive == 0)
               {
                  _requestSeekTimer = 0;
               }
            }
         }
         else
         {
            _npcPath = null;
         }
      }
      
      public function plantTargettable() : Boolean
      {
         if(_actorData.type == 21 && !isDead && _npc != null && _npc.npcMC != null && _npc.npcMC.phantomCanTarget)
         {
            return true;
         }
         return false;
      }
      
      public function handleBeamZap(param1:int) : void
      {
         if(_npc != null && _npc.npcMC != null)
         {
            _npc.npcMC.zap(_actorData.lightParamAngle);
         }
      }
      
      public function handlePhantomZap(param1:int) : void
      {
         var _loc2_:Number = NaN;
         if(_npc != null && _npc.npcMC != null && _npc.npcState != 4)
         {
            _loc2_ = getAngleToTarget(AvatarManager.avatarViewList[param1].avatarPos.x + -15,AvatarManager.avatarViewList[param1].avatarPos.y + -40);
            _npc.npcMC.zap(_loc2_);
         }
      }
      
      public function testPointInActorVolumes(param1:Point) : Boolean
      {
         var _loc2_:int = 0;
         if(_visible && _volumes != null)
         {
            _loc2_ = 0;
            while(_loc2_ < _volumes.length)
            {
               if(RoomManagerWorld.instance.volumeManager.testPointInVolume(param1,_volumes[_loc2_]))
               {
                  return true;
               }
               _loc2_++;
            }
         }
         return false;
      }
      
      public function distanceSqToPlayer() : Number
      {
         var _loc3_:Point = null;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         if(_npc != null && AvatarManager.playerAvatarWorldView != null)
         {
            _loc3_ = _npc.collisionZapPoint;
            _loc3_.x += x;
            _loc3_.y += y;
            _loc1_ = _loc3_.x - (AvatarManager.playerAvatarWorldView.avatarPos.x + -15);
            _loc2_ = _loc3_.y - (AvatarManager.playerAvatarWorldView.avatarPos.y + -40);
            return _loc1_ * _loc1_ + _loc2_ * _loc2_;
         }
         return -1;
      }
      
      public function pathToPlayerInRange() : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc3_:int = 0;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc5_:Number = distanceSqToPlayer();
         if(_loc5_ != -1 && _loc5_ < 640000)
         {
            return true;
         }
         if(_npc != null && AvatarManager.playerAvatarWorldView != null && _npcPath != null)
         {
            _loc4_ = -1;
            _loc3_ = 0;
            while(_loc3_ < _npcPath.points.length)
            {
               _loc1_ = _npcPath.points[_loc3_].x - (AvatarManager.playerAvatarWorldView.avatarPos.x + -15);
               _loc2_ = _npcPath.points[_loc3_].y - (AvatarManager.playerAvatarWorldView.avatarPos.y + -40);
               _loc5_ = _loc1_ * _loc1_ + _loc2_ * _loc2_;
               if(_loc4_ == -1 || _loc5_ < _loc4_)
               {
                  _loc4_ = _loc5_;
               }
               if(_loc4_ < 640000)
               {
                  return true;
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      public function updateTorch() : void
      {
         if(_visible && _actorData.torchEnabled)
         {
            _torchActive = true;
            QuestManager.addTorch(this,_actorDefaultOuterRadius / 100);
         }
         else if(_torchActive)
         {
            _torchActive = false;
            QuestManager.removeTorch(this);
         }
      }
      
      public function updateIcon(param1:Boolean) : void
      {
         if(param1 && _visible)
         {
            _showIcon = param1;
         }
         else
         {
            _showIcon = false;
            removeOffScreenHudView();
         }
      }
      
      public function testBeamIntersectPlayer() : void
      {
         var _loc4_:AvatarInfo = null;
         var _loc1_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc9_:Point = null;
         var _loc7_:Number = NaN;
         var _loc2_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Object = null;
         var _loc8_:AvatarWorldView = AvatarManager.playerAvatarWorldView;
         if(_loc8_ != null)
         {
            _zapTimer = 0.3;
            _loc4_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
            if(_loc4_.questHealthPercentage > 0)
            {
               _loc1_ = _loc8_.x + -15;
               _loc3_ = _loc8_.y + -40;
               _loc9_ = _npc.npcMC.getStartPoint();
               _loc9_.x = _loc9_.x + x;
               _loc9_.y += y;
               _loc7_ = (_loc9_.x - _loc1_) * (_loc9_.x - _loc1_) + (_loc9_.y - _loc3_) * (_loc9_.y - _loc3_);
               if(_loc7_ <= (_actorData.lightParamMaxLength + 50) * (_actorData.lightParamMaxLength + 50))
               {
                  _loc2_ = new Point(_loc1_,_loc3_);
                  _loc5_ = _npc.npcMC.getEndPoint();
                  _loc5_.x = _loc5_.x + x;
                  _loc5_.y += y;
                  _loc6_ = lineIntersectCircle(_loc9_,_loc5_,_loc2_,50);
                  if(_loc6_ != null && (_loc6_.inside || _loc6_.intersects))
                  {
                     QuestXtCommManager.questBeamZap(_actorId,AvatarManager.playerAvatarWorldView.userId);
                     _npc.npcMC.zap(_actorData.lightParamAngle);
                     _zapTimer = 2;
                  }
               }
            }
         }
      }
      
      public function lineIntersectCircle(param1:Point, param2:Point, param3:Point, param4:Number = 1) : Object
      {
         var _loc6_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:Object = {};
         _loc5_.inside = false;
         _loc5_.tangent = false;
         _loc5_.intersects = false;
         _loc5_.enter = null;
         _loc5_.exit = null;
         var _loc11_:Number = (param2.x - param1.x) * (param2.x - param1.x) + (param2.y - param1.y) * (param2.y - param1.y);
         var _loc8_:Number = 2 * ((param2.x - param1.x) * (param1.x - param3.x) + (param2.y - param1.y) * (param1.y - param3.y));
         var _loc12_:Number = param3.x * param3.x + param3.y * param3.y + param1.x * param1.x + param1.y * param1.y - 2 * (param3.x * param1.x + param3.y * param1.y) - param4 * param4;
         var _loc10_:Number = _loc8_ * _loc8_ - 4 * _loc11_ * _loc12_;
         if(_loc10_ <= 0)
         {
            _loc5_.inside = false;
         }
         else
         {
            _loc6_ = Math.sqrt(_loc10_);
            _loc9_ = (-_loc8_ + _loc6_) / (2 * _loc11_);
            _loc7_ = (-_loc8_ - _loc6_) / (2 * _loc11_);
            if((_loc9_ < 0 || _loc9_ > 1) && (_loc7_ < 0 || _loc7_ > 1))
            {
               if(_loc9_ < 0 && _loc7_ < 0 || _loc9_ > 1 && _loc7_ > 1)
               {
                  _loc5_.inside = false;
               }
               else
               {
                  _loc5_.inside = true;
               }
            }
            else
            {
               if(0 <= _loc7_ && _loc7_ <= 1)
               {
                  _loc5_.enter = Point.interpolate(param1,param2,1 - _loc7_);
               }
               if(0 <= _loc9_ && _loc9_ <= 1)
               {
                  _loc5_.exit = Point.interpolate(param1,param2,1 - _loc9_);
               }
               _loc5_.intersects = true;
               if(_loc5_.exit != null && _loc5_.enter != null && _loc5_.exit.equals(_loc5_.enter))
               {
                  _loc5_.tangent = true;
               }
            }
         }
         return _loc5_;
      }
      
      public function handleKeyDown(param1:uint) : void
      {
         switch(int(param1) - 32)
         {
            case 0:
               if(_clickIcon)
               {
                  handleClick();
               }
         }
      }
      
      public function playerJumpLand() : void
      {
         if(_npc.npcMC && _npc.npcMC.readyForAttack)
         {
            QuestXtCommManager.sendPlantAte(_actorId,"");
            QuestManager.handlePlantAte(_actorId,"");
         }
      }
   }
}

