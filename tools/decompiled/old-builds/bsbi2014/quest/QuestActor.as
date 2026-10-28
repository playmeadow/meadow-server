package quest
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
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
   import room.RoomGrid;
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
         if(this._npc != null)
         {
            if(this._npc.isDead)
            {
               return true;
            }
            if(this._npc.npcMC != null && this._npc.npcMC.hasOwnProperty("deathAnimComplete"))
            {
               return this._npc.npcMC.deathAnimComplete;
            }
         }
         return false;
      }
      
      public function get npcDef() : Object
      {
         if(this._npc != null)
         {
            return this._npc.npcDef;
         }
         return null;
      }
      
      public function isVulnerable() : Boolean
      {
         if(this._npc != null && this._npc.npcMC != null && this._npc.npcMC.hasOwnProperty("vulnerable"))
         {
            return this._npc.npcMC.vulnerable;
         }
         return true;
      }
      
      public function isRunawayFromPlayer() : Boolean
      {
         if(this._npc != null && this._npc.npcMC != null && this._npc.npcMC.hasOwnProperty("runAwayFromPlayer"))
         {
            return this._npc.npcMC.runAwayFromPlayer;
         }
         return false;
      }
      
      public function get alertLP() : SoundChannel
      {
         return this._alertLP;
      }
      
      public function set alertLP(sc:SoundChannel) : void
      {
         this._alertLP = sc;
      }
      
      public function get talkingHeadMediaRef() : int
      {
         if(this._npc != null)
         {
            return this._npc.talkingHeadMediaId;
         }
         return 0;
      }
      
      public function get avatar() : Avatar
      {
         if(this._npc != null)
         {
            return this._npc.avatar;
         }
         return null;
      }
      
      public function get actorOffset() : Point
      {
         if(this._npc != null)
         {
            return this._npc.collisionMovingPoint;
         }
         return new Point(0,0);
      }
      
      public function get collisionMovingRadius() : Number
      {
         if(this._npc != null)
         {
            return this._npc.collisionRadiusMoving;
         }
         return 0;
      }
      
      public function get isDying() : Boolean
      {
         return this._npc != null && this._npc.isDying;
      }
      
      public function get collisionRadiusMoving() : Number
      {
         if(this._npc != null)
         {
            return this._npc.collisionRadiusMoving;
         }
         return 0;
      }
      
      public function get priority() : int
      {
         return this._priority;
      }
      
      private function initVars(inActorId:String, inActorData:Object, inInnerRadius:int, inOuterRadius:int, inPriority:int, inSpawnedFromPos:Point) : void
      {
         this._plantTargets = null;
         this._attackable = 0;
         this._torchActive = false;
         this._seekActor = null;
         this._attackTimer = 0;
         this._zapTimer = 0;
         this._lastMeleeID = 0;
         this._actorData = inActorData;
         this._actorId = inActorId;
         this._actorDefaultInnerRadius = inInnerRadius;
         this._actorDefaultOuterRadius = inOuterRadius;
         this._visible = false;
         visible = false;
         this._requireClick = false;
         this._inRadius = false;
         this._inSeekRadius = false;
         this._seekActive = SEEKTYPE_OFF;
         this._requestSeekTimer = 0;
         this._updatePositionTimer = 0;
         this._tellServerPosition = false;
         this._playerSeekingActor = false;
         this._attackPlayerSfsId = 0;
         this._attackPlayerWeaponItemDefId = 0;
         this._priority = inPriority;
         this._spawnedFromPos = inSpawnedFromPos;
         this._inCollision = true;
         this._directionOverride = new Point();
         this._directionTimer = 0;
         this.setPath(this._actorData.pathName);
         if(this._actorData.actorPos != null)
         {
            x = this._actorData.actorPos.x;
            y = this._actorData.actorPos.y;
         }
      }
      
      public function resetActor(inActorId:String, inActorData:Object, inInnerRadius:int, inOuterRadius:int, inPriority:int, inSpawnedFromPos:Point) : void
      {
         this.initVars(inActorId,inActorData,inInnerRadius,inOuterRadius,inPriority,inSpawnedFromPos);
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_FACTORY:
            case QUEST_ACTOR_TYPE_ATTACKER:
            case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
               addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
               this._targetX = x;
               this._targetY = y;
               this.resetNPC(this._actorData.actorPos);
               break;
            case QUEST_ACTOR_TYPE_PLANT:
            case QUEST_ACTOR_TYPE_NPC:
            case QUEST_ACTOR_TYPE_LIGHT_BEAM:
               this.resetNPC(this._actorData.actorPos);
               this._targetX = -1;
               break;
            default:
               throw new Error("Trying to recycle an asset that is not a valid type");
         }
      }
      
      public function initActor(inActorId:String, inActorData:Object, inInnerRadius:int, inOuterRadius:int, inPriority:int, inSpawnedFromPos:Point) : void
      {
         var npcDef:Object = null;
         var i:int = 0;
         this._loadingComplete = false;
         this.initVars(inActorId,inActorData,inInnerRadius,inOuterRadius,inPriority,inSpawnedFromPos);
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_SPEAKER:
               QuestManager._layerManager.room_avatars.addChild(this);
               this._loadingComplete = true;
               break;
            case QUEST_ACTOR_TYPE_FACTORY:
               addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
               this._targetX = x;
               this._targetY = y;
               this.initNPC(this._actorData.actorPos,true);
               break;
            case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
            case QUEST_ACTOR_TYPE_ATTACKER:
               npcDef = QuestManager.getNPCDef(this._actorData.defId);
               this._attackable = npcDef.attackable;
               addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
               this._targetX = x;
               this._targetY = y;
               this.initNPC(this._actorData.actorPos,false);
               break;
            case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
            case QUEST_ACTOR_TYPE_PLACED_TREASURE:
               this.initNPC(this._actorData.actorPos);
               break;
            case QUEST_ACTOR_TYPE_PLANT:
               this.initNPC(this._actorData.actorPos,false);
               break;
            case QUEST_ACTOR_TYPE_NPC:
               this.initNPC(this._actorData.actorPos,false,true);
               break;
            case QUEST_ACTOR_TYPE_LIGHT_BEAM:
               this._targetX = -1;
               this.initNPC(this._actorData.actorPos,false);
               break;
            case QUEST_ACTOR_TYPE_ITEM:
            case QUEST_ACTOR_TYPE_GROUP_ITEM:
               this._mh = new MediaHelper();
               this._mh.init(this._actorData.defId,this.onMediaHelperItemReceived);
               break;
            case QUEST_ACTOR_TYPE_VOLUMEPLACEMENT:
            case QUEST_ACTOR_TYPE_VOLUME_FALLING_PHANTOM:
               this._volumes = RoomManagerWorld.instance.volumeManager.findVolume(inActorId);
               this._loadingComplete = true;
               break;
            case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
            case QUEST_ACTOR_TYPE_VOLUMETRIGGER:
            case QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
            case QUEST_ACTOR_TYPE_VOLUMEINTERACTION:
               this._volumes = RoomManagerWorld.instance.volumeManager.findVolume(inActorId);
               if(this._volumes != null)
               {
                  if(Boolean(this._volumes[0].message.length))
                  {
                     this._interactionAnimIds = this._volumes[0].message.split(",");
                     for(i = 0; i < this._interactionAnimIds.length; i++)
                     {
                        this._interactionAnimIds[i] = int(this._interactionAnimIds[i]);
                     }
                  }
                  else
                  {
                     this._interactionAnimIds = null;
                  }
                  RoomManagerWorld.instance.enableVolume(inActorId,this._visible);
               }
               this._loadingComplete = true;
               break;
            default:
               this._loadingComplete = true;
         }
      }
      
      private function resetNPC(inPos:Point) : void
      {
         AvatarManager.addQuestActor(this,inPos);
         var npcDef:Object = QuestManager.getNPCDef(this._actorData.defId);
         if(Boolean(npcDef) && npcDef.type == 1)
         {
         }
         this._npc.reset();
         this.onNpcLoaded();
      }
      
      private function initNPC(inPos:Point, hasHealthBar:Boolean = false, displayNameBar:Boolean = false) : void
      {
         var npcDef:Object = null;
         var namebarStrId:int = 0;
         if(displayNameBar)
         {
            npcDef = QuestManager.getNPCDef(this._actorData.defId);
            if(Boolean(npcDef) && npcDef.type == 1)
            {
               namebarStrId = int(npcDef.titleStrId);
            }
         }
         this._npc = new NPCView();
         this._npc.init(this._actorData.defId,0,namebarStrId,hasHealthBar,this.onNpcLoaded);
         AvatarManager.addQuestActor(this,inPos);
      }
      
      public function handlePositionUpdate(inX:int, inY:int, velocity:int, inSeekType:int, inPlayerX:int, inPlayerY:int) : void
      {
         if(this._seekActive == SEEKTYPE_OFF)
         {
            if(this._npc != null && this._npc.npcMC != null)
            {
               if(this._npc.npcMC.hasOwnProperty("setNearestPlayerLocation"))
               {
                  this._npc.npcMC.setNearestPlayerLocation(new Point(inPlayerX,inPlayerY));
               }
               switch(inSeekType)
               {
                  case SEEKTYPE_PLANT:
                  case SEEKTYPE_PLAYER:
                     if(this._npc.npcDef.damageTouch > 0 && this._npc.npcMC.hasOwnProperty("alertStatus"))
                     {
                        this._npc.npcMC.alertStatus(true);
                     }
                     break;
                  default:
                     if(this._npc.npcDef.damageTouch > 0 && this._npc.npcMC.hasOwnProperty("alertStatus"))
                     {
                        this._npc.npcMC.alertStatus(false);
                     }
               }
            }
            if(this._actorData.actorPos != null)
            {
               this._actorData.actorPos.x = inX;
               this._actorData.actorPos.y = inY;
            }
            this._targetX = inX;
            this._targetY = inY;
            this._seekVelocity = velocity;
         }
      }
      
      public function handleRequestSeekResponse(inSeek:int) : void
      {
         var nearest:Number = NaN;
         var index:int = 0;
         var collisionPoint:Point = null;
         var toX:Number = NaN;
         var toY:Number = NaN;
         var distSq:Number = NaN;
         this._seekActive = inSeek;
         switch(inSeek)
         {
            case SEEKTYPE_PLAYER:
            case SEEKTYPE_PLANT:
               this._seekVelocity = ATTACKER_VELOCITY + Math.random() * ATTACKER_VELOCITY_RANGE;
               if(this._npc != null && this._npc.npcMC != null && this._npc.npcDef.damageTouch > 0 && this._npc.npcMC.hasOwnProperty("alertStatus"))
               {
                  this._npc.npcMC.alertStatus(true);
               }
               break;
            case SEEKTYPE_PATH:
               this._pathNode = 0;
               if(this._npc != null && AvatarManager.playerAvatarWorldView != null && this._npcPath != null)
               {
                  nearest = -1;
                  for(index = 0; index < this._npcPath.points.length; index++)
                  {
                     collisionPoint = this._npc.collisionMovingPoint;
                     toX = this._npcPath.points[index].x - (x + collisionPoint.x);
                     toY = this._npcPath.points[index].y - (y + collisionPoint.y);
                     distSq = toX * toX + toY * toY;
                     if(nearest == -1 || distSq < nearest)
                     {
                        nearest = distSq;
                        this._pathNode = index;
                     }
                  }
               }
               break;
            default:
               if(this._npc != null && this._npc.npcMC != null && this._npc.npcDef.damageTouch > 0 && this._npc.npcMC.hasOwnProperty("alertStatus"))
               {
                  this._npc.npcMC.alertStatus(false);
               }
         }
      }
      
      public function setRequireClick(inRequireClick:Boolean) : void
      {
         if(inRequireClick)
         {
            this._inRadius = false;
         }
         else
         {
            this.removeClickIcon();
         }
         this._requireClick = inRequireClick;
      }
      
      public function setVisible(inVisible:Boolean) : void
      {
         var wasInRadius:Boolean = false;
         if(inVisible)
         {
            switch(this._actorData.type)
            {
               case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
               case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
               case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
               case QuestActor.QUEST_ACTOR_TYPE_PLANT:
                  if(this._actorData.healthPercent <= 0)
                  {
                     inVisible = false;
                  }
            }
         }
         if(inVisible != this._visible)
         {
            wasInRadius = this._inRadius;
            this._inRadius = false;
            visible = inVisible;
            this._visible = inVisible;
            if(!this._visible)
            {
               this.removeClickIcon();
               if(Boolean(this._mediaObject) && this._mediaObject.hasOwnProperty("torchOn"))
               {
                  QuestManager.removeTorch(this);
               }
               if(this._seekActive != SEEKTYPE_OFF)
               {
                  QuestManager.setQuestActorSeek(this,this._seekActive);
               }
               if(Boolean(this._chatBalloon))
               {
                  if(this._chatBalloon.parent != null)
                  {
                     this._chatBalloon.parent.removeChild(this._chatBalloon);
                     this._chatBalloon = null;
                  }
               }
               if(wasInRadius)
               {
                  if(this._volumes != null)
                  {
                     switch(this._actorData.type)
                     {
                        case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                        case QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
                        case QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                        case QUEST_ACTOR_TYPE_VOLUMEINTERACTION:
                           QuestXtCommManager.questActorUntriggered(this._actorId);
                     }
                  }
               }
            }
            if(this._volumes != null)
            {
               switch(this._actorData.type)
               {
                  case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                  case QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                  case QUEST_ACTOR_TYPE_VOLUMEINTERACTION:
                     RoomManagerWorld.instance.enableVolume(this._actorId,this._visible);
                     break;
                  case QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
                     RoomManagerWorld.instance.enableVolume(this._actorId,this._visible);
                     RoomManagerWorld.instance.updateMinimap();
               }
            }
            this.updateTorch();
            this.updateIcon(this._actorData.iconShowing);
         }
      }
      
      private function recycle() : void
      {
         if(Boolean(this._mh))
         {
            this._mh.destroy();
            this._mh = null;
         }
         this.removeClickIcon();
         if(this._actorData.type != QUEST_ACTOR_TYPE_NPC)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
            gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
         QuestManager.recycle(QuestManager.getNPCDef(this._actorData.defId).mediaRefId,this);
      }
      
      public function destroy() : void
      {
         if(Boolean(this._mh))
         {
            this._mh.destroy();
            this._mh = null;
         }
         if(Boolean(this._mediaObject))
         {
            if(Boolean(this._mediaObject.parent))
            {
               this._mediaObject.parent.removeChild(this._mediaObject);
            }
            this._mediaObject = null;
         }
         if(Boolean(this._prizePopup))
         {
            this._prizePopup.destroy();
            this._prizePopup = null;
         }
         this.removeClickIcon();
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_SPEAKER:
               if(this._speakerSoundChannel != null)
               {
                  this._speakerSoundChannel.stop();
                  this._speakerSoundChannel = null;
               }
               break;
            case QUEST_ACTOR_TYPE_FACTORY:
            case QUEST_ACTOR_TYPE_ATTACKER:
            case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
               removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
               gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
               this.destroyNPC();
               break;
            case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
               removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_DroppedTreasure);
               this.destroyNPC();
               break;
            case QUEST_ACTOR_TYPE_LIGHT_BEAM:
            case QUEST_ACTOR_TYPE_NPC:
            case QUEST_ACTOR_TYPE_PLANT:
               this.destroyNPC();
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(Boolean(this._alertLP))
         {
            QuestManager.stopLoopingSound(this._alertLP);
            this._alertLP = null;
         }
         if(this._torchActive)
         {
            this._torchActive = false;
            QuestManager.removeTorch(this);
         }
         this.updateIcon(false);
         if(Boolean(this._hudViewHolder) && Boolean(this._hudViewHolder.parent) && this._hudViewHolder.parent == GuiManager.guiLayer)
         {
            GuiManager.guiLayer.removeChild(this._hudViewHolder);
         }
         this._hudViewHolder = null;
      }
      
      public function destroyNPC() : void
      {
         if(Boolean(this._npc))
         {
            if(Boolean(this._npc.parent))
            {
               this._npc.parent.removeChild(this._npc);
            }
            this._npc.destroy();
            this._npc = null;
         }
      }
      
      public function heartbeat(inFrameTime:Number) : void
      {
         var collisionPoint:Point = null;
         var toTargetX:Number = NaN;
         var toTargetY:Number = NaN;
         var targetRadius:Number = NaN;
         var useGrid:Boolean = false;
         var npcState:int = 0;
         var npcAngle:Number = NaN;
         var px:Number = NaN;
         var py:Number = NaN;
         var distance:Number = NaN;
         var angle:Number = NaN;
         var dirX:Number = NaN;
         var dirY:Number = NaN;
         var epsilon:Number = NaN;
         var newDir:Number = NaN;
         var pathEndReached:Boolean = false;
         var startPt:Point = null;
         var endPt:Point = null;
         var targetDiff:Number = NaN;
         var minRadiusSquared:Number = NaN;
         var maxRadiusSquared:Number = NaN;
         var volume:Number = NaN;
         var weaopnItem:Object = null;
         var targetX:int = 0;
         var targetY:int = 0;
         var targetActive:Boolean = false;
         var plantCollision:Point = null;
         var sendVel:int = 0;
         var customCollisionPoints:Array = null;
         var colPoint:Object = null;
         var colPointIndex:int = 0;
         var ai:AvatarInfo = null;
         var seekActorOffset:Point = null;
         var colVelocity:int = 0;
         var total:int = 0;
         var phantomIndex:int = 0;
         var attackPoint:Point = null;
         var attachmentPoint:Point = null;
         if(this._visible && (this._npc == null || this._npc.isDying == false))
         {
            toTargetX = 0;
            toTargetY = 0;
            targetRadius = 0;
            useGrid = false;
            px = 0;
            py = 0;
            distance = 0;
            angle = 0;
            if(Boolean(this._chatBalloon) && this._chatBalloon.visible)
            {
               this._chatBalloon.heartbeat(10);
            }
            switch(this._actorData.type)
            {
               case QUEST_ACTOR_TYPE_NPC:
                  if(this._npcPath != null || this._seekActive == SEEKTYPE_OFF)
                  {
                     if(this._seekActive == SEEKTYPE_OFF)
                     {
                        if(this._npcPath != null)
                        {
                           if(this._requestSeekTimer > 0)
                           {
                              this._requestSeekTimer -= inFrameTime;
                           }
                           else
                           {
                              QuestManager.setQuestActorSeek(this,SEEKTYPE_PATH);
                           }
                        }
                        this._seekVelocity = NPC_PATH_VELOCITY * 0.9;
                     }
                     else if(this._seekActive == SEEKTYPE_PATH)
                     {
                        this._seekVelocity = NPC_PATH_VELOCITY;
                     }
                     if(this._updatePositionTimer > 0)
                     {
                        this._updatePositionTimer -= inFrameTime;
                     }
                     else if(this._tellServerPosition)
                     {
                        if(this._actorData.actorPos != null)
                        {
                           this._actorData.actorPos.x = x;
                           this._actorData.actorPos.y = y;
                        }
                        QuestXtCommManager.questActorPositionUpdate(this._actorId,x,y,this._seekVelocity,this._seekActive,0,0);
                        if(this._seekActive == SEEKTYPE_PATH)
                        {
                           this._updatePositionTimer = 0.5 + 0.5 * Math.random();
                        }
                        this._tellServerPosition = false;
                     }
                     collisionPoint = null;
                     toTargetX = 0;
                     toTargetY = 0;
                     targetRadius = 0;
                     if(Boolean(this._seekActive == SEEKTYPE_PATH) && Boolean(this._npcPath) && this._pathNode < this._npcPath.points.length)
                     {
                        collisionPoint = this._npc.collisionMovingPoint;
                        toTargetX = this._npcPath.points[this._pathNode].x - (x + collisionPoint.x);
                        toTargetY = this._npcPath.points[this._pathNode].y - (y + collisionPoint.y);
                        targetRadius = 20;
                        useGrid = true;
                     }
                     else
                     {
                        targetRadius = 10;
                        toTargetX = this._targetX - x;
                        toTargetY = this._targetY - y;
                     }
                     if(toTargetX != 0 || toTargetY != 0)
                     {
                        distance = Math.sqrt(toTargetX * toTargetX + toTargetY * toTargetY);
                        if(distance != 0)
                        {
                           px = toTargetX / distance;
                           py = toTargetY / distance;
                        }
                        else
                        {
                           px = 1;
                           py = 0;
                        }
                        angle = Math.asin(px);
                        if(toTargetY > 0)
                        {
                           angle = -(Math.PI + angle);
                        }
                        npcState = NPCView.NPC_STATE_MOVE;
                        npcAngle = angle * 180 / Math.PI;
                     }
                     if(distance > targetRadius)
                     {
                        dirX = Math.abs(px);
                        dirY = Math.abs(py);
                        px *= inFrameTime * this._seekVelocity;
                        py *= inFrameTime * this._seekVelocity;
                        if(Math.abs(toTargetX) - Math.abs(px) < 0)
                        {
                           px = toTargetX;
                        }
                        if(Math.abs(toTargetY) - Math.abs(py) < 0)
                        {
                           py = toTargetY;
                        }
                        if(this._inCollision)
                        {
                           this._inCollision = this.inCollision(x,y);
                        }
                        if(useGrid && !this._inCollision)
                        {
                           if(this.inCollision(x + px,y + py))
                           {
                              epsilon = 0.1;
                              newDir = inFrameTime * this._seekVelocity * (py > 0 ? 1 : -1);
                              if(this.inCollision(x,y + newDir))
                              {
                                 newDir = inFrameTime * this._seekVelocity * (px > 0 ? 1 : -1);
                                 if(this.inCollision(x + newDir,y))
                                 {
                                    px = 0;
                                    py = 0;
                                 }
                                 else
                                 {
                                    px = newDir;
                                    py = 0;
                                 }
                              }
                              else
                              {
                                 px = 0;
                                 py = newDir;
                              }
                           }
                        }
                        if(px != 0 || py != 0)
                        {
                           x += px;
                           y += py;
                           if(this._seekActive != SEEKTYPE_OFF)
                           {
                              this._targetX = x;
                              this._targetY = y;
                              this._tellServerPosition = true;
                           }
                        }
                     }
                     else
                     {
                        switch(this._seekActive)
                        {
                           case SEEKTYPE_OFF:
                              npcState = NPCView.NPC_STATE_IDLE;
                              npcAngle = 0;
                              break;
                           case SEEKTYPE_PATH:
                              pathEndReached = false;
                              if(Boolean(this._npcPath) && this._npcPath.points.length > 1)
                              {
                                 if(Boolean(this._npcPath.isClosedLoop))
                                 {
                                    this._pathDirectionForward = true;
                                    ++this._pathNode;
                                    if(this._pathNode >= this._npcPath.points.length)
                                    {
                                       this._pathNode = 0;
                                    }
                                 }
                                 else
                                 {
                                    ++this._pathNode;
                                    if(this._pathNode >= this._npcPath.points.length)
                                    {
                                       npcState = NPCView.NPC_STATE_IDLE;
                                       npcAngle = 0;
                                       pathEndReached = true;
                                    }
                                 }
                              }
                              else
                              {
                                 npcState = NPCView.NPC_STATE_IDLE;
                                 npcAngle = 0;
                                 pathEndReached = true;
                              }
                              if(pathEndReached && !this._npcReachedPathEnd)
                              {
                                 this._npcReachedPathEnd = true;
                                 QuestXtCommManager.questActorTriggered(this._actorId,2);
                              }
                        }
                     }
                     if(npcState != NPCView.NPC_STATE_IDLE || this._npc.npcState != npcState)
                     {
                        this._npc.setNpcState(npcState,npcAngle);
                        if(npcState == NPCView.NPC_STATE_IDLE && this._actorData.pendingSwfStateName != "")
                        {
                           this.setSwfState(this._actorData.pendingSwfStateName);
                        }
                     }
                  }
                  else
                  {
                     QuestManager.setQuestActorSeek(this,SEEKTYPE_OFF);
                  }
                  break;
               case QUEST_ACTOR_TYPE_LIGHT_BEAM:
                  if(this._zapTimer > 0)
                  {
                     this._zapTimer -= inFrameTime;
                  }
                  if(this._npc != null && this._npc.npcMC != null)
                  {
                     if(Boolean(this._npc.npcMC.bLightEnabled))
                     {
                        if(this._actorData.lightParamSpeed != 0)
                        {
                           this._actorData.lightParamAngle += this._actorData.lightParamSpeed * inFrameTime;
                           if(this._actorData.lightParamSpeed > 0)
                           {
                              if(this._actorData.lightParamEndAngle != -1)
                              {
                                 if(this._actorData.lightParamAngle >= this._actorData.lightParamEndAngle)
                                 {
                                    this._actorData.lightParamAngle = this._actorData.lightParamEndAngle;
                                    this._actorData.lightParamSpeed = -this._actorData.lightParamSpeed;
                                 }
                              }
                              else if(this._actorData.lightParamAngle >= 360)
                              {
                                 this._actorData.lightParamAngle -= 360;
                              }
                           }
                           else if(this._actorData.lightParamEndAngle != -1)
                           {
                              if(this._actorData.lightParamAngle <= this._actorData.lightParamStartAngle)
                              {
                                 this._actorData.lightParamAngle = this._actorData.lightParamStartAngle;
                                 this._actorData.lightParamSpeed = -this._actorData.lightParamSpeed;
                              }
                           }
                           else if(this._actorData.lightParamAngle <= 0)
                           {
                              this._actorData.lightParamAngle = 360;
                           }
                           this._npc.npcMC.setAngle(this._actorData.lightParamAngle);
                           startPt = this._npc.npcMC.getStartPoint();
                           startPt.x += x;
                           startPt.y += y;
                           endPt = this._npc.npcMC.getEndPoint();
                           endPt.x += x;
                           endPt.y += y;
                           this._targetY = RoomManagerWorld.instance.getLengthLineIntersectGrid(startPt,endPt,this._actorData.lightParamMaxLength);
                           if(this._targetX != this._targetY)
                           {
                              if(this._targetX != -1)
                              {
                                 targetDiff = Math.abs(this._targetX - this._targetY);
                                 if(targetDiff > 10)
                                 {
                                    if(this._targetX < this._targetY)
                                    {
                                       this._targetX += targetDiff * (inFrameTime * 6);
                                       if(this._targetX > this._targetY)
                                       {
                                          this._targetX = this._targetY;
                                       }
                                    }
                                    else
                                    {
                                       this._targetX -= targetDiff * (inFrameTime * 6);
                                       if(this._targetX < this._targetY)
                                       {
                                          this._targetX = this._targetY;
                                       }
                                    }
                                 }
                              }
                              else
                              {
                                 this._targetX = this._targetY;
                              }
                           }
                           this._npc.npcMC.setLength(this._targetX);
                        }
                        if(this._zapTimer <= 0)
                        {
                           this.testBeamIntersectPlayer();
                        }
                     }
                  }
                  break;
               case QUEST_ACTOR_TYPE_ITEM:
               case QUEST_ACTOR_TYPE_GROUP_ITEM:
                  if(this._updatePositionTimer > 0)
                  {
                     this._updatePositionTimer -= inFrameTime;
                  }
                  break;
               case QUEST_ACTOR_TYPE_SPEAKER:
                  if(AvatarManager.playerAvatarWorldView != null)
                  {
                     toTargetX = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - x;
                     toTargetY = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - y;
                     targetRadius = toTargetX * toTargetX + toTargetY * toTargetY;
                     minRadiusSquared = this._actorDefaultInnerRadius * this._actorDefaultInnerRadius;
                     maxRadiusSquared = this._actorDefaultOuterRadius * this._actorDefaultOuterRadius;
                     volume = 1;
                     if(targetRadius > maxRadiusSquared || SBAudio.isMusicMuted)
                     {
                        volume = 0;
                     }
                     else if(targetRadius >= minRadiusSquared)
                     {
                        volume = 1 - (targetRadius - minRadiusSquared) / (maxRadiusSquared - minRadiusSquared);
                     }
                     if(volume > 0 || this._actorDefaultInnerRadius == 0)
                     {
                        if(this._speakerSoundChannel == null)
                        {
                           this._speakerSoundChannel = QuestManager.playLoopingSound(this._actorData.defName);
                        }
                        if(this._actorDefaultInnerRadius > 0)
                        {
                           QuestManager.setSoundLevel(this._speakerSoundChannel,volume,this);
                        }
                        else if(SBAudio.isMusicMuted)
                        {
                           if(this._speakerSoundChannel != null)
                           {
                              this._speakerSoundChannel.stop();
                              this._speakerSoundChannel = null;
                           }
                        }
                        else if(this._speakerSoundChannel == null)
                        {
                           this._speakerSoundChannel = QuestManager.playLoopingSound(this._actorData.defName);
                        }
                     }
                     else if(this._speakerSoundChannel != null)
                     {
                        this._speakerSoundChannel.stop();
                        this._speakerSoundChannel = null;
                     }
                  }
                  break;
               case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
                  if(this._npc != null && this._npc.npcState == NPCView.NPC_STATE_TREASURE_OPEN && this._npc.npcStateComplete)
                  {
                     this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_DISAPPEAR);
                     this._actorData.pickedUp = true;
                  }
                  break;
               case QUEST_ACTOR_TYPE_FACTORY:
                  this._npc.setNpcState(NPCView.NPC_STATE_IDLE,0);
                  break;
               case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
                  break;
               case QUEST_ACTOR_TYPE_ATTACKER:
                  if(this._spawnedFromPos != null)
                  {
                     if(this._updatePositionTimer > 0)
                     {
                        this._updatePositionTimer -= inFrameTime;
                        if(this._updatePositionTimer <= 0)
                        {
                           this._updatePositionTimer = 0;
                           this._spawnedFromPos = null;
                        }
                     }
                  }
                  else
                  {
                     if(this._seekActive != SEEKTYPE_OFF && this._npc != null && this._npc.npcMC != null)
                     {
                        if(this._seekActive == SEEKTYPE_PATH)
                        {
                           if(this._npcPath.points.length >= 1)
                           {
                              this._seekVelocity = this._npc.npcMC.velocity;
                           }
                           else
                           {
                              this._seekVelocity = 0;
                           }
                        }
                        else
                        {
                           if(this._seekActive == SEEKTYPE_PLAYER)
                           {
                              if(this._npc.npcMC.hasOwnProperty("setNearestPlayerLocation") && AvatarManager.playerAvatarWorldView != null)
                              {
                                 this._npc.npcMC.setNearestPlayerLocation(new Point(AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - x,AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - y));
                              }
                           }
                           this._seekVelocity = this._npc.npcMC.velocity;
                           if(this._seekActive == SEEKTYPE_PLAYER && this.isRunawayFromPlayer())
                           {
                              this._seekVelocity = -this._seekVelocity;
                           }
                        }
                     }
                     if(this._npc != null && this._npc.npcMC != null && this._npc.npcMC.hasOwnProperty("canSeekPlant") && Boolean(this._npc.npcMC.canSeekPlant))
                     {
                        this.checkPlantRadius();
                     }
                     if(this._seekActor == null)
                     {
                        this.onAttackRadius();
                     }
                     if(this._attackPlayerSfsId != 0 && this._attackPlayerWeaponItemDefId != 0)
                     {
                        if(this._npc != null && this._npc.readyToLaunchAttack)
                        {
                           if(AvatarManager.avatarViewList[this._attackPlayerSfsId] != null)
                           {
                              weaopnItem = ItemXtCommManager.getItemDef(this._attackPlayerWeaponItemDefId);
                              if(Boolean(weaopnItem))
                              {
                                 targetActive = false;
                                 if(this._seekActive == SEEKTYPE_PLANT)
                                 {
                                    if(this._seekActor != null)
                                    {
                                       plantCollision = this._seekActor.actorOffset;
                                       targetX = this._seekActor._actorData.actorPos.x + plantCollision.x;
                                       targetY = this._seekActor._actorData.actorPos.y + plantCollision.y;
                                       targetActive = true;
                                    }
                                 }
                                 else if(this._npc != null && this._npc.npcDef.damageTouch <= 0)
                                 {
                                    targetX = AvatarManager.avatarViewList[this._attackPlayerSfsId].avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX;
                                    targetY = AvatarManager.avatarViewList[this._attackPlayerSfsId].avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY;
                                    targetActive = true;
                                 }
                                 if(targetActive)
                                 {
                                    switch(weaopnItem.combatType)
                                    {
                                       case QuestManager.QUEST_WEAPON_TYPE_PROJECTILE:
                                          QuestManager.launchProjectile(this._attackPlayerWeaponItemDefId,this._attackPlayerWeaponColor,targetX,targetY,this,null);
                                          break;
                                       case QuestManager.QUEST_WEAPON_TYPE_BOMB:
                                       case QuestManager.QUEST_WEAPON_TYPE_MELEE:
                                          QuestManager.swipeMelee(this._attackPlayerWeaponItemDefId,this._attackPlayerWeaponColor,targetX,targetY,this,null);
                                    }
                                 }
                              }
                           }
                           this._attackPlayerSfsId = 0;
                           this._attackPlayerWeaponItemDefId = 0;
                        }
                     }
                     if(this._attackTimer > 0)
                     {
                        this._attackTimer -= inFrameTime;
                     }
                     if(this._requestSeekTimer > 0)
                     {
                        this._requestSeekTimer -= inFrameTime;
                     }
                     if(this._zapTimer > 0)
                     {
                        this._zapTimer -= inFrameTime;
                     }
                     if(this._updatePositionTimer > 0)
                     {
                        this._updatePositionTimer -= inFrameTime;
                     }
                     else if(this._tellServerPosition)
                     {
                        if(this._actorData.actorPos != null)
                        {
                           this._actorData.actorPos.x = x;
                           this._actorData.actorPos.y = y;
                        }
                        sendVel = this._seekVelocity;
                        if(this._seekActive == SEEKTYPE_PLAYER && this.isRunawayFromPlayer())
                        {
                           sendVel = Math.abs(this._seekVelocity);
                        }
                        if(this._seekActive == SEEKTYPE_PLAYER)
                        {
                           QuestXtCommManager.questActorPositionUpdate(this._actorId,x,y,sendVel,this._seekActive,AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - x,AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - y);
                        }
                        else
                        {
                           QuestXtCommManager.questActorPositionUpdate(this._actorId,x,y,sendVel,this._seekActive,0,0);
                        }
                        if(this._seekActive == SEEKTYPE_PATH)
                        {
                           this._updatePositionTimer = 1 + Math.random();
                        }
                        else
                        {
                           this._updatePositionTimer = 1 + Math.random();
                        }
                        this._tellServerPosition = false;
                     }
                     if(AvatarManager.playerAvatarWorldView != null)
                     {
                        customCollisionPoints = null;
                        useGrid = false;
                        if(this._zapTimer <= 0 && this._npc != null && this._npc.npcDef.damageTouch != 0)
                        {
                           this._zapTimer = 0.3;
                           ai = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                           if(ai.questHealthPercentage > 0 && QuestManager.isPlayerInStealthVolume() == false)
                           {
                              if(this._npc.npcMC != null && this._npc.npcMC.hasOwnProperty("getCustomCollisionPoints"))
                              {
                                 customCollisionPoints = this._npc.npcMC.getCustomCollisionPoints();
                                 if(customCollisionPoints != null)
                                 {
                                    for(colPointIndex = 0; colPointIndex < customCollisionPoints.length; colPointIndex++)
                                    {
                                       colPoint = customCollisionPoints[colPointIndex];
                                       if(colPoint.Type == 1)
                                       {
                                          toTargetX = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - (x + colPoint.x);
                                          toTargetY = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - (y + colPoint.y);
                                          targetRadius = colPoint.Radius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                                          if(toTargetX * toTargetX + toTargetY * toTargetY < targetRadius * targetRadius)
                                          {
                                             QuestManager.questPhantomZap(this._actorId,AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y,this);
                                             this._zapTimer = 2;
                                             break;
                                          }
                                       }
                                    }
                                 }
                              }
                              if(customCollisionPoints == null)
                              {
                                 collisionPoint = this._npc.collisionZapPoint;
                                 toTargetX = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - (x + collisionPoint.x);
                                 toTargetY = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - (y + collisionPoint.y);
                                 targetRadius = this._npc.collisionZapRadius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                                 if(toTargetX * toTargetX + toTargetY * toTargetY < targetRadius * targetRadius)
                                 {
                                    QuestManager.questPhantomZap(this._actorId,AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y,this);
                                    this._zapTimer = 2;
                                 }
                              }
                           }
                        }
                        collisionPoint = null;
                        toTargetX = 0;
                        toTargetY = 0;
                        targetRadius = 0;
                        switch(this._seekActive)
                        {
                           case SEEKTYPE_PATH:
                              collisionPoint = this._npc.collisionMovingPoint;
                              toTargetX = this._npcPath.points[this._pathNode].x - (x + collisionPoint.x);
                              toTargetY = this._npcPath.points[this._pathNode].y - (y + collisionPoint.y);
                              targetRadius = 20;
                              useGrid = true;
                              if(this._npc != null && this._npc.npcMC != null && this._npc.npcDef.damageTouch > 0 && this._npc.npcMC.hasOwnProperty("alertStatus"))
                              {
                                 this._npc.npcMC.alertStatus(false);
                                 this._alerted = false;
                                 if(Boolean(this._alertLP))
                                 {
                                    QuestManager.stopLoopingSound(this._alertLP);
                                    this._alertLP = null;
                                 }
                              }
                              break;
                           case SEEKTYPE_PLAYER:
                              if(this._npc.npcMC != null && this._npc.npcMC.hasOwnProperty("getCustomCollisionPoints"))
                              {
                                 customCollisionPoints = this._npc.npcMC.getCustomCollisionPoints();
                                 if(customCollisionPoints != null)
                                 {
                                    for(colPointIndex = 0; colPointIndex < customCollisionPoints.length; colPointIndex++)
                                    {
                                       colPoint = customCollisionPoints[colPointIndex];
                                       switch(colPoint.Type)
                                       {
                                          case 2:
                                             toTargetX = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - (x + colPoint.x);
                                             toTargetY = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - (y + colPoint.y);
                                             targetRadius = Number(colPoint.Radius);
                                             break;
                                          case 3:
                                             QuestManager.phantomAttackDestructible(this._actorId,x + colPoint.x,y + colPoint.y,colPoint.Radius);
                                       }
                                    }
                                 }
                              }
                              if(targetRadius == 0)
                              {
                                 collisionPoint = this._npc.collisionMovingPoint;
                                 toTargetX = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - (x + collisionPoint.x);
                                 toTargetY = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - (y + collisionPoint.y);
                                 if(this._npc.npcDef.damageTouch > 0)
                                 {
                                    targetRadius = 0;
                                 }
                                 else
                                 {
                                    targetRadius = this._npc.collisionRadiusAttack + 0.9 * QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                                 }
                              }
                              useGrid = true;
                              if(this._npc != null && this._npc.npcMC != null && this._npc.npcDef.damageTouch > 0 && this._npc.npcMC.hasOwnProperty("alertStatus"))
                              {
                                 if(!this._alerted)
                                 {
                                    this._alerted = true;
                                    if(this.isRunawayFromPlayer())
                                    {
                                       QuestManager.playSound("ajq_protoAlert");
                                    }
                                    else
                                    {
                                       QuestManager.playSound("ajq_phantomAlert");
                                    }
                                 }
                                 this._npc.npcMC.alertStatus(true);
                                 if(this._alertLP != null && !this._npc.npcMC.attacking)
                                 {
                                    QuestManager.stopLoopingSound(this._alertLP);
                                    this._alertLP = null;
                                 }
                              }
                              break;
                           case SEEKTYPE_PLANT:
                              if(this._seekActor != null)
                              {
                                 seekActorOffset = this._seekActor.actorOffset;
                                 collisionPoint = this._npc.collisionMovingPoint;
                                 toTargetX = this._seekActor._actorData.actorPos.x + seekActorOffset.x - (x + collisionPoint.x);
                                 toTargetY = this._seekActor._actorData.actorPos.y + seekActorOffset.y - (y + collisionPoint.y);
                                 targetRadius = 90;
                                 useGrid = true;
                              }
                              else
                              {
                                 toTargetX = 0;
                                 toTargetY = 0;
                                 targetRadius = 10;
                              }
                              if(this._npc != null && this._npc.npcMC != null && this._npc.npcDef.damageTouch > 0 && this._npc.npcMC.hasOwnProperty("alertStatus"))
                              {
                                 this._npc.npcMC.alertStatus(true);
                              }
                              break;
                           default:
                              targetRadius = 10;
                              toTargetX = this._targetX - x;
                              toTargetY = this._targetY - y;
                              this._alerted = false;
                              if(this._alertLP != null && !this._npc.npcMC.attacking)
                              {
                                 QuestManager.stopLoopingSound(this._alertLP);
                                 this._alertLP = null;
                              }
                        }
                        if(Boolean(this._npc) && Boolean(this._npc.npcMC) && Boolean(this._npc.npcMC.attacking))
                        {
                           this.updateAlertLP();
                        }
                        if(this._directionTimer > 0)
                        {
                           npcState = NPCView.NPC_STATE_MOVE;
                           px = this._directionOverride.x;
                           py = this._directionOverride.y;
                           angle = Math.asin(px);
                           if(py > 0)
                           {
                              angle = -(Math.PI + angle);
                           }
                           npcAngle = angle * 180 / Math.PI;
                           distance = Math.sqrt(toTargetX * toTargetX + toTargetY * toTargetY);
                        }
                        else if(toTargetX != 0 || toTargetY != 0)
                        {
                           distance = Math.sqrt(toTargetX * toTargetX + toTargetY * toTargetY);
                           if(distance != 0)
                           {
                              px = toTargetX / distance;
                              py = toTargetY / distance;
                           }
                           else
                           {
                              px = 1;
                              py = 0;
                           }
                           angle = Math.asin(px);
                           if(toTargetY > 0)
                           {
                              angle = -(Math.PI + angle);
                           }
                           npcState = NPCView.NPC_STATE_MOVE;
                           npcAngle = angle * 180 / Math.PI;
                        }
                        if(distance > targetRadius || this.isRunawayFromPlayer())
                        {
                           if(this._directionTimer <= 0)
                           {
                              switch(this._seekActive)
                              {
                                 case SEEKTYPE_PLAYER:
                                 case SEEKTYPE_PLANT:
                                    if(!this._inCollision && this._attackTimer <= 0 && this._npc.readyToAttack)
                                    {
                                       if(distance < ATTACKER_RANGE_WEAPON_PROJECTILE && distance > ATTACKER_RANGE_WEAPON_MIN_PROJECTILE)
                                       {
                                          this._attackPlayerWeaponItemDefId = this.getActiveWeapon(true);
                                          if(this._attackPlayerWeaponItemDefId != 0)
                                          {
                                             npcState = NPCView.NPC_STATE_ATTACK;
                                             this._attackTimer = 1.5 + 4 * Math.random();
                                          }
                                       }
                                    }
                              }
                           }
                           dirX = Math.abs(px);
                           dirY = Math.abs(py);
                           px *= inFrameTime * this._seekVelocity;
                           py *= inFrameTime * this._seekVelocity;
                           if(Math.abs(toTargetX) - Math.abs(px) < 0)
                           {
                              px = toTargetX;
                           }
                           if(Math.abs(toTargetY) - Math.abs(py) < 0)
                           {
                              py = toTargetY;
                           }
                           if(this._inCollision)
                           {
                              this._inCollision = this.inCollision(x,y);
                           }
                           if(useGrid && !this._inCollision)
                           {
                              if(this.inCollision(x + px,y + py))
                              {
                                 epsilon = 0.1;
                                 colVelocity = this._seekVelocity;
                                 if(colVelocity < 0 && this.isRunawayFromPlayer())
                                 {
                                    colVelocity = -this._seekVelocity;
                                 }
                                 newDir = inFrameTime * colVelocity * (py > 0 ? 1 : -1);
                                 if(this.inCollision(x,y + newDir))
                                 {
                                    newDir = inFrameTime * colVelocity * (px > 0 ? 1 : -1);
                                    if(this.inCollision(x + newDir,y))
                                    {
                                       px = 0;
                                       py = 0;
                                    }
                                    else
                                    {
                                       px = newDir;
                                       py = 0;
                                    }
                                 }
                                 else
                                 {
                                    px = 0;
                                    py = newDir;
                                 }
                              }
                           }
                           if(px != 0 || py != 0)
                           {
                              x += px;
                              y += py;
                              switch(this._seekActive)
                              {
                                 case SEEKTYPE_PLAYER:
                                 case SEEKTYPE_PLANT:
                              }
                              if(this._seekActive != SEEKTYPE_OFF)
                              {
                                 this._targetX = x;
                                 this._targetY = y;
                                 this._tellServerPosition = true;
                              }
                           }
                           if(this._directionTimer > 0)
                           {
                              this._directionTimer -= inFrameTime;
                           }
                        }
                        if(distance <= targetRadius)
                        {
                           switch(this._seekActive)
                           {
                              case SEEKTYPE_OFF:
                              case SEEKTYPE_PLAYER:
                              case SEEKTYPE_PLANT:
                                 npcState = NPCView.NPC_STATE_IDLE;
                                 npcAngle = 0;
                                 if(this._seekActive != SEEKTYPE_OFF)
                                 {
                                    if(!this._inCollision && this._attackTimer <= 0 && this._npc.readyToAttack)
                                    {
                                       this._attackPlayerWeaponItemDefId = this.getActiveWeapon(false);
                                       if(this._attackPlayerWeaponItemDefId == 0)
                                       {
                                          this._attackPlayerWeaponItemDefId = this.getActiveWeapon(true);
                                       }
                                       if(this._attackPlayerWeaponItemDefId != 0)
                                       {
                                          npcState = NPCView.NPC_STATE_ATTACK;
                                          this._attackTimer = 1.5 + 4 * Math.random();
                                       }
                                    }
                                 }
                                 break;
                              case SEEKTYPE_PATH:
                                 this._directionTimer = 0;
                                 if(this._npcPath.points.length > 1)
                                 {
                                    if(Boolean(this._npcPath.isClosedLoop))
                                    {
                                       this._pathDirectionForward = true;
                                       ++this._pathNode;
                                       if(this._pathNode >= this._npcPath.points.length)
                                       {
                                          this._pathNode = 0;
                                       }
                                    }
                                    else if(this._pathDirectionForward)
                                    {
                                       ++this._pathNode;
                                       if(this._pathNode >= this._npcPath.points.length)
                                       {
                                          this._pathDirectionForward = false;
                                          this._pathNode -= 2;
                                       }
                                    }
                                    else if(this._pathNode == 0)
                                    {
                                       this._pathDirectionForward = true;
                                       ++this._pathNode;
                                    }
                                    else
                                    {
                                       --this._pathNode;
                                    }
                                 }
                                 else
                                 {
                                    npcState = NPCView.NPC_STATE_IDLE;
                                    npcAngle = 0;
                                 }
                           }
                        }
                        if(npcState != NPCView.NPC_STATE_ATTACK && this._npc != null && this._npc.npcMC != null)
                        {
                           if(this._npc.readyToAttack && this._npc.npcMC.hasOwnProperty("counterAttacking") && Boolean(this._npc.npcMC.counterAttacking))
                           {
                              this._attackPlayerWeaponItemDefId = this.getActiveWeapon(false);
                              if(this._attackPlayerWeaponItemDefId == 0)
                              {
                                 this._attackPlayerWeaponItemDefId = this.getActiveWeapon(true);
                              }
                              if(this._attackPlayerWeaponItemDefId != 0)
                              {
                                 npcState = NPCView.NPC_STATE_ATTACK;
                                 this._attackTimer = 1.5 + 4 * Math.random();
                              }
                           }
                        }
                        if(npcState == NPCView.NPC_STATE_ATTACK)
                        {
                           this.handleAttackPlayer(this._attackPlayerWeaponItemDefId,this._attackPlayerWeaponColor,AvatarManager.playerSfsUserId);
                           QuestXtCommManager.sendAttackPlayer(this._actorId,this._attackPlayerSfsId,this._attackPlayerWeaponItemDefId,this._attackPlayerWeaponColor);
                        }
                        else
                        {
                           this._npc.setNpcState(npcState,npcAngle);
                        }
                     }
                  }
                  break;
               case QUEST_ACTOR_TYPE_PLANT:
                  if(this._npc != null && this._npc.npcMC != null)
                  {
                     if(this._plantTargets != null)
                     {
                        if(Boolean(this._npc.npcMC.attacking))
                        {
                           total = 1;
                           if(this._npc.npcMC.hasOwnProperty("attackType"))
                           {
                              if(this._npc.npcMC.attackType >= 1)
                              {
                                 total = int(this._plantTargets.length);
                              }
                           }
                           for(phantomIndex = 0; phantomIndex < total; phantomIndex++)
                           {
                              QuestXtCommManager.sendEatPhantom(this._actorId,this._plantTargets[phantomIndex]._actorId,this._plantTargets[phantomIndex].x,this._plantTargets[phantomIndex].y);
                           }
                           this._plantTargets = null;
                        }
                     }
                     else if(Boolean(this._npc.npcMC.readyForAttack))
                     {
                        if(this._attackTimer > 0)
                        {
                           this._attackTimer -= inFrameTime;
                        }
                        else
                        {
                           attackPoint = this._npc.collisionPointAttack;
                           this._plantTargets = QuestManager.getNearestActivePhantom(this._actorData.actorPos.x + attackPoint.x,this._actorData.actorPos.y + attackPoint.y,this._npc.collisionRadiusAttack,this._npc.npcDef.level - 1,this._npc.npcMC.hasOwnProperty("selfDestruct") && Boolean(this._npc.npcMC.selfDestruct),this._npc.npcMC.hasOwnProperty("attackType") && this._npc.npcMC.attackType == 2,this._npc.npcDef.damageTouch > 0);
                           if(this._plantTargets != null && this._plantTargets.length > 0)
                           {
                              QuestXtCommManager.sendPlantAte(this._actorId,this._plantTargets[0]._actorId);
                              QuestManager.handlePlantAte(this._actorId,this._plantTargets[0]._actorId);
                           }
                           else if(this._npc.npcMC.hasOwnProperty("selfDestruct") && Boolean(this._npc.npcMC.selfDestruct))
                           {
                              QuestXtCommManager.sendPlantAte(this._actorId,"");
                              QuestManager.handlePlantAte(this._actorId,"");
                           }
                           this._attackTimer = 0;
                        }
                     }
                  }
            }
            if(Boolean(this._npc))
            {
               if(this._showIcon)
               {
                  this.updateOffScreenPositions();
               }
               if(Boolean(this._npc._eye) && Boolean(QuestManager._darknessMask))
               {
                  if(!this._eyeInFG)
                  {
                     QuestManager._layerManager.room_fg.addChild(this._npc._eye);
                     this._eyeInFG = true;
                  }
                  this._npc._eye.x = this._npc.npcMC.x + this._npc.npcMC.parent.parent.x + this._npc.npcMC.parent.parent.parent.x + this._npc.npcMC.parent.parent.parent.parent.x;
                  this._npc._eye.y = this._npc.npcMC.y + this._npc.npcMC.parent.parent.y + this._npc.npcMC.parent.parent.parent.y + this._npc.npcMC.parent.parent.parent.parent.y;
               }
               if(Boolean(this._npc._beam) && Boolean(QuestManager._darknessMask))
               {
                  if(!this._beamInFG)
                  {
                     QuestManager._layerManager.room_fg.addChild(this._npc._beam);
                     this._beamInFG = true;
                  }
                  this._npc._beam.x = this._npc.npcMC.x + this._npc.npcMC.parent.parent.x + this._npc.npcMC.parent.parent.parent.x + this._npc.npcMC.parent.parent.parent.parent.x;
                  this._npc._beam.y = this._npc.npcMC.y + this._npc.npcMC.parent.parent.y + this._npc.npcMC.parent.parent.parent.y + this._npc.npcMC.parent.parent.parent.parent.y;
               }
            }
            if(Boolean(this._chatBalloon))
            {
               try
               {
                  attachmentPoint = this._npc.npcMC.getAttachmentPoint();
               }
               catch(e:Error)
               {
                  attachmentPoint = new Point(-10,-90);
               }
               this._chatBalloon.x = x + attachmentPoint.x;
               this._chatBalloon.y = y + attachmentPoint.y;
            }
         }
      }
      
      private function updateOffScreenPositions() : void
      {
         var scalePoint:Point;
         var myScreenPoint:Point;
         var holderHeight:int;
         var holderWidth:int;
         var hudHeight:int;
         var iconRect:Rectangle;
         var scale:Number = NaN;
         var attachmentPoint:Point = null;
         var mainHudIndex:int = 0;
         if(!this._hudViewHolder)
         {
            this._hudViewHolder = GETDEFINITIONBYNAME("offScreenIconQuest");
            this._hudViewHolder.mouse.gotoAndStop("up");
            this._hudViewHolder.questChatBalloon.init(0,AvatarUtility.getAvatarEmoteBgOffset,false,7,SBTextField);
            if(Boolean(this._flashTimer))
            {
               this._flashTimer.reset();
            }
            this._flashTimer = new Timer(2500);
            this._flashTimer.addEventListener(TimerEvent.TIMER,this.onFlashTimer,false,0,true);
         }
         scalePoint = RoomManagerWorld.instance.bkgScalePoint();
         myScreenPoint = RoomManagerWorld.instance.convertWorldToScreen(this.x * scalePoint.x,this.y * scalePoint.y);
         holderHeight = this._hudViewHolder.mouse.height * 0.5 * scalePoint.x;
         holderWidth = this._hudViewHolder.mouse.width * 0.5 * scalePoint.y;
         hudHeight = 73.5 * scalePoint.y;
         iconRect = new Rectangle(0,0,MainFrame.VIEW_WIDTH - holderWidth,MainFrame.VIEW_HEIGHT - holderHeight - hudHeight + 30 * 2 * scalePoint.x);
         if(!iconRect.containsPoint(myScreenPoint))
         {
            AvatarWorldView.updateScreenPositionAndDirection(this._hudViewHolder,iconRect,myScreenPoint);
            if(!this._isOffScreen)
            {
               if(this._hudViewHolder.mouse.currentFrameLabel != "up")
               {
                  this._hudViewHolder.mouse.gotoAndStop("up");
               }
               if(this._npc.avatar != null)
               {
                  this._offScreenAvtView = new AvatarView();
                  this._offScreenAvtView.init(this._npc.avatar);
                  this._offScreenAvtView.playAnim(LayerAnim.AN_HUD_AVT,false,LayerAnim.PLAY_ONE_SHOT,this.onHudAvtView);
                  this._offScreenAvtView.avTypeChangedCallback = this.updateHudViewPosition;
               }
               else
               {
                  if(!Boolean(this._npc.secondaryNpcMC))
                  {
                     return;
                  }
                  while(this._hudViewHolder.charLayer.numChildren > 0)
                  {
                     this._hudViewHolder.charLayer.removeChildAt(0);
                  }
                  this._offScreenAvtView = this._npc.secondaryNpcMC;
                  this._offScreenAvtView.scaleX = this._offScreenAvtView.scaleY = 1;
                  scale = 41 / this._offScreenAvtView.width;
                  if(this._offScreenAvtView.height * scale > 41)
                  {
                     scale = 41 / this._offScreenAvtView.height;
                  }
                  this._offScreenAvtView.scaleX = scale;
                  this._offScreenAvtView.scaleY = scale;
                  try
                  {
                     attachmentPoint = this._npc.secondaryNpcMC.getCenterPoint();
                  }
                  catch(e:Error)
                  {
                     attachmentPoint = new Point(0,0);
                  }
                  this._offScreenAvtView.x = attachmentPoint.x * scale;
                  this._offScreenAvtView.y = attachmentPoint.y * scale;
                  this._hudViewHolder.charLayer.addChild(this._offScreenAvtView);
                  mainHudIndex = GuiManager.guiLayer.getChildIndex(GuiManager.mainHud);
                  GuiManager.guiLayer.addChildAt(this._hudViewHolder,mainHudIndex);
               }
               this._isOffScreen = true;
               this._hudViewHolder.visible = true;
               if(Boolean(this._chatBalloon) && this._chatBalloon.parent == QuestManager._layerManager.room_orbs)
               {
                  QuestManager._layerManager.room_orbs.removeChild(this._chatBalloon);
               }
            }
            this._hudViewHolder.x = myScreenPoint.x;
            this._hudViewHolder.y = myScreenPoint.y;
         }
         else if(this._isOffScreen || this._hudViewHolder.visible)
         {
            if(this._hudViewHolder.mouse.currentFrameLabel != "up")
            {
               this._hudViewHolder.mouse.gotoAndStop("up");
            }
            if(Boolean(this._hudViewHolder) && Boolean(this._hudViewHolder.parent) && this._hudViewHolder.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(this._hudViewHolder);
            }
            this._hudViewHolder.visible = false;
            this._isOffScreen = false;
            if(Boolean(this._chatBalloon))
            {
               QuestManager._layerManager.room_orbs.addChild(this._chatBalloon);
            }
            if(this._npc.avatar != null)
            {
            }
         }
      }
      
      private function onFlashTimer(t:TimerEvent) : void
      {
         if(Boolean(this._flashTimer))
         {
            this._flashTimer.reset();
         }
         if(Boolean(this._hudViewHolder))
         {
            this._hudViewHolder.mouse.gotoAndStop("up");
         }
      }
      
      private function onHudAvtView(layer:LayerAnim, animId:int) : void
      {
         this.updateHudViewPosition();
         while(this._hudViewHolder.charLayer.numChildren > 0)
         {
            this._hudViewHolder.charLayer.removeChildAt(0);
         }
         this._hudViewHolder.charLayer.addChild(this._offScreenAvtView);
         var mainHudIndex:int = GuiManager.guiLayer.getChildIndex(GuiManager.mainHud);
         GuiManager.guiLayer.addChildAt(this._hudViewHolder,mainHudIndex);
      }
      
      private function updateHudViewPosition() : void
      {
         var avatarOffset:Point = AvatarUtility.getAvatarHudPosition(this._offScreenAvtView.avTypeId);
         this._offScreenAvtView.scaleX = this._offScreenAvtView.scaleY = 1;
         var scale:Number = 41 / this._offScreenAvtView.width;
         if(this._offScreenAvtView.height * scale > 41)
         {
            scale = 41 / this._offScreenAvtView.height;
         }
         this._offScreenAvtView.scaleX = scale;
         this._offScreenAvtView.scaleY = scale;
         this._offScreenAvtView.x = avatarOffset.x * scale;
         this._offScreenAvtView.y = avatarOffset.y * scale;
      }
      
      private function updateAlertLP() : void
      {
         var toTargetX:Number = NaN;
         var toTargetY:Number = NaN;
         var targetRadius:Number = NaN;
         var maxRadiusSquared:Number = NaN;
         var volume:Number = NaN;
         if(AvatarManager.playerAvatarWorldView != null)
         {
            toTargetX = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - x;
            toTargetY = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - y;
            targetRadius = toTargetX * toTargetX + toTargetY * toTargetY;
            maxRadiusSquared = 700 * 700;
            volume = 1;
            if(targetRadius > maxRadiusSquared)
            {
               volume = 0;
            }
            else if(targetRadius >= 0)
            {
               volume = 1 - targetRadius / maxRadiusSquared;
            }
            if(volume > 0)
            {
               if(this._alertLP == null)
               {
                  if(this.isRunawayFromPlayer())
                  {
                     this._alertLP = QuestManager.playLoopingSound("ajq_prototearslp");
                  }
                  else
                  {
                     this._alertLP = QuestManager.playLoopingSound("ajq_phntmsquidlp");
                  }
               }
               QuestManager.setSoundLevel(this._alertLP,volume,this);
            }
            else if(this._alertLP != null)
            {
               QuestManager.stopLoopingSound(this._alertLP);
               this._alertLP = null;
            }
         }
      }
      
      public function setPlantEats(inPhantom:QuestActor) : void
      {
         var angle:Number = 0;
         if(inPhantom != null)
         {
            angle = this.getAngleToTarget(inPhantom.x,inPhantom.y);
         }
         this._npc.setNpcState(NPCView.NPC_STATE_ATTACK,angle);
         if(Boolean(this._npc.npcMC) && this._npc.npcMC.hasOwnProperty("readyForAttack"))
         {
            this._npc.npcMC.readyForAttack = false;
         }
      }
      
      private function inCollision(x:int, y:int) : Boolean
      {
         var collisionResult:uint = RoomManagerWorld.instance.collisionTestGrid(x,y);
         return collisionResult != RoomGrid.GRID_CELL_OPEN && collisionResult != RoomGrid.GRID_CELL_PHANTOM;
      }
      
      public function checkPlantRadius() : void
      {
         var attackRadius:Number = NaN;
         var collisionPoint:Point = null;
         if(this._npc != null && this._requestSeekTimer <= 0)
         {
            attackRadius = 250;
            collisionPoint = this._npc.collisionZapPoint;
            this._seekActor = QuestManager.getNearestPlant(this._actorData.actorPos.x + collisionPoint.x,this._actorData.actorPos.y + collisionPoint.y,attackRadius,this._npc.npcDef.level);
            if(this._seekActive != SEEKTYPE_PLANT)
            {
               if(this._seekActor != null)
               {
                  QuestManager.setQuestActorSeek(this,SEEKTYPE_PLANT);
                  this._requestSeekTimer = 1.5;
               }
            }
            else if(this._seekActor == null)
            {
               QuestManager.setQuestActorSeek(this,SEEKTYPE_OFF);
            }
            else
            {
               this._requestSeekTimer = 1.5;
            }
         }
      }
      
      public function onAttackRadius() : void
      {
         var ai:AvatarInfo = null;
         var distSq:Number = NaN;
         var followRadius:Number = NaN;
         if(AvatarManager.playerAvatarWorldView != null && this._visible && (this._npc == null || this._npc.isDead == false))
         {
            ai = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
            if(QuestManager.isPlayerInStealthVolume() == false && ai.questHealthPercentage > 0)
            {
               distSq = this.distanceSqToPlayer();
               if(this._npc != null && this._npc.npcMC != null)
               {
                  this._npc.npcMC.setDistanceToTarget(distSq);
               }
               if(this._seekActive == SEEKTYPE_PLAYER)
               {
                  followRadius = this._actorDefaultOuterRadius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                  if(!this._radiusOverride && distSq > followRadius * followRadius)
                  {
                     this._requestSeekTimer = 1.5;
                     this._seekActive = this._npcPath != null ? SEEKTYPE_PATH : SEEKTYPE_OFF;
                     if(this._npc != null && this._npc.npcMC != null && this._npc.npcDef.damageTouch > 0 && this._npc.npcMC.hasOwnProperty("alertStatus"))
                     {
                        this._npc.npcMC.alertStatus(false);
                        this._alerted = false;
                        if(Boolean(this._alertLP))
                        {
                           QuestManager.stopLoopingSound(this._alertLP);
                           this._alertLP = null;
                        }
                     }
                     QuestManager.setQuestActorSeek(this,this._seekActive);
                  }
               }
               else if(this._requestSeekTimer <= 0)
               {
                  this._requestSeekTimer = 1;
                  followRadius = this._actorDefaultInnerRadius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                  if(this._radiusOverride && distSq < followRadius * followRadius * 25 || distSq < followRadius * followRadius)
                  {
                     QuestManager.setQuestActorSeek(this,SEEKTYPE_PLAYER);
                     if(this._radiusOverride && distSq < followRadius * followRadius)
                     {
                        this._radiusOverride = false;
                     }
                  }
                  else if(!QuestManager.getNearestActorPathInGroupToPlayerInRange(this))
                  {
                     if(this._seekActive != SEEKTYPE_OFF)
                     {
                        QuestManager.setQuestActorSeek(this,SEEKTYPE_OFF);
                     }
                  }
                  else if(this._npcPath != null && this._seekActive != SEEKTYPE_PATH)
                  {
                     QuestManager.setQuestActorSeek(this,SEEKTYPE_PATH);
                  }
               }
            }
            else if(this._npcPath != null)
            {
               if(!QuestManager.getNearestActorPathInGroupToPlayerInRange(this))
               {
                  if(this._seekActive != SEEKTYPE_OFF)
                  {
                     this._requestSeekTimer = 1;
                     QuestManager.setQuestActorSeek(this,SEEKTYPE_OFF);
                  }
               }
               else if(this._seekActive == SEEKTYPE_PLAYER || this._seekActive == SEEKTYPE_OFF && this._requestSeekTimer <= 0)
               {
                  this._requestSeekTimer = 1;
                  QuestManager.setQuestActorSeek(this,SEEKTYPE_PATH);
               }
            }
            else if(this._seekActive != SEEKTYPE_OFF)
            {
               this._requestSeekTimer = 1;
               QuestManager.setQuestActorSeek(this,SEEKTYPE_OFF);
            }
         }
      }
      
      public function meleeHitTest(inMeleeID:int, inPoint:Point, inRadius:int) : Boolean
      {
         if(this._lastMeleeID != inMeleeID && (this._npc == null || this._npc.isDead == false))
         {
            if(this._actorData.type != QUEST_ACTOR_TYPE_DESTRUCTIBLE || this._actorData.healthPercent > 0)
            {
               if(this.hitTest(inPoint,inRadius))
               {
                  this._lastMeleeID = inMeleeID;
                  return true;
               }
            }
         }
         return false;
      }
      
      public function hitTest(inPoint:Point, inRadius:int) : Boolean
      {
         var collisionPoint:Point = null;
         if(this._visible && (this._npc == null || this._npc.isDying == false))
         {
            switch(this._actorData.type)
            {
               case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
               case QUEST_ACTOR_TYPE_ATTACKER:
               case QUEST_ACTOR_TYPE_FACTORY:
                  collisionPoint = this._npc.collisionMovingPoint;
                  if(Collision.circleHitCircle(inPoint,inRadius,new Point(x + collisionPoint.x,y + collisionPoint.y),this._npc.collisionRadiusMoving))
                  {
                     return true;
                  }
                  break;
               case QUEST_ACTOR_TYPE_PLANT:
                  if(this.plantTargettable())
                  {
                     collisionPoint = this._npc.collisionMovingPoint;
                     if(Collision.circleHitCircle(inPoint,inRadius,new Point(x + collisionPoint.x,y + collisionPoint.y),this._npc.collisionRadiusMoving))
                     {
                        return true;
                     }
                  }
            }
         }
         return false;
      }
      
      private function onMediaHelperNpcIconReceived(img:MovieClip) : void
      {
         if(Boolean(this._mh))
         {
            this._clickIcon = img;
            this._mh.destroy();
            this._mh = null;
            this.showNpcClickIcon();
         }
      }
      
      public function showNpcClickIcon() : void
      {
         var attachmentPoint:Point = null;
         try
         {
            attachmentPoint = this._npc.npcMC.getAttachmentPoint();
         }
         catch(e:Error)
         {
            attachmentPoint = new Point(-10,-90);
         }
         this._clickIcon.x = x + attachmentPoint.x;
         this._clickIcon.y = y + attachmentPoint.y;
         QuestManager._layerManager.room_orbs.addChild(this._clickIcon);
         QuestManager.playSound("ajq_popup");
         this._clickIcon.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Click,false,0,true);
         this._clickIcon.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOverEvt_Click,false,0,true);
         this._clickIcon.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOutEvt_Click,false,0,true);
      }
      
      public function onRadiusTest() : Boolean
      {
         var inRadius:Boolean = false;
         var actorRadius:Number = NaN;
         var collisionPoint:Point = null;
         var collisionOffset:Point = null;
         var volumeIndex:int = 0;
         var ai:AvatarInfo = null;
         var playerData:QuestPlayerData = null;
         var gems:String = null;
         if(AvatarManager.playerAvatarWorldView != null && this._visible && (this._npc == null || this._npc.isDead == false))
         {
            inRadius = false;
            if(this._volumes != null)
            {
               switch(this._actorData.type)
               {
                  case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                  case QUEST_ACTOR_TYPE_CIRCLETRIGGER:
                  case QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                  case QUEST_ACTOR_TYPE_VOLUMEINTERACTION:
                     for(volumeIndex = 0; volumeIndex < this._volumes.length; volumeIndex++)
                     {
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y),this._volumes[volumeIndex]))
                        {
                           if(this._actorData.type != QUEST_ACTOR_TYPE_VOLUMEINTERACTION || this._interactionAnimIds == null || this._interactionAnimIds.indexOf(AvatarManager.playerAvatarWorldView.animId) >= 0)
                           {
                              inRadius = true;
                           }
                           break;
                        }
                     }
               }
            }
            else
            {
               collisionPoint = new Point(x,y);
               switch(this._actorData.type)
               {
                  case QUEST_ACTOR_TYPE_FACTORY:
                     actorRadius = this._actorDefaultOuterRadius;
                     break;
                  case QUEST_ACTOR_TYPE_PLACED_TREASURE:
                     actorRadius = this._actorDefaultInnerRadius;
                     break;
                  case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
                     switch(this._actorData.subType)
                     {
                        case GIVE_ORBS:
                           actorRadius = DROPPED_ORB_RADIUS;
                           break;
                        default:
                           actorRadius = DROPPED_TREASURE_RADIUS;
                     }
                     break;
                  case QUEST_ACTOR_TYPE_NPC:
                     if(this._npc != null)
                     {
                        collisionOffset = this._npc.collisionMovingPoint;
                        collisionPoint.x += collisionOffset.x;
                        collisionPoint.y += collisionOffset.y;
                     }
                     actorRadius = this._actorDefaultOuterRadius;
                     break;
                  case QUEST_ACTOR_TYPE_SPEAKER:
                     actorRadius = this._actorDefaultOuterRadius;
                     break;
                  default:
                     if(this._npc != null)
                     {
                        collisionOffset = this._npc.collisionMovingPoint;
                        collisionPoint.x += collisionOffset.x;
                        collisionPoint.y += collisionOffset.y;
                        actorRadius = this._npc.collisionRadiusMoving;
                     }
                     else
                     {
                        actorRadius = this._actorDefaultOuterRadius;
                     }
               }
               if(actorRadius > 0)
               {
                  inRadius = Collision.circleHitCircle(collisionPoint,actorRadius,new Point(AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY),QuestManager.QUEST_PLAYER_AVATAR_RADIUS * 1.5);
               }
            }
            if(inRadius)
            {
               if(this._playerSeekingActor)
               {
                  if(Boolean(this._npc))
                  {
                     switch(this._actorData.type)
                     {
                        case QUEST_ACTOR_TYPE_FACTORY:
                           collisionOffset = this._npc.collisionMovingPoint;
                           collisionPoint.x += collisionOffset.x;
                           collisionPoint.y += collisionOffset.y;
                           actorRadius = this._npc.collisionRadiusMoving;
                           if(!Collision.circleHitCircle(collisionPoint,actorRadius,new Point(AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY),QuestManager.QUEST_PLAYER_AVATAR_RADIUS * 1.5))
                           {
                              break;
                           }
                        case QUEST_ACTOR_TYPE_ATTACKER:
                        case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
                           if(Boolean(collisionPoint) && (Boolean(this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE || this._attackable > 0)) && this._actorData.healthPercent > 0)
                           {
                              QuestManager.playerLaunchWeapon(collisionPoint,false);
                           }
                           this._playerSeekingActor = false;
                           gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
                           RoomManagerWorld.instance.forceStopMovement();
                           AvatarManager.playerAvatarWorldView.faceAnim(collisionPoint.x - AvatarManager.playerAvatarWorldView.avatarPos.x,collisionPoint.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
                     }
                  }
               }
               if(this._inRadius != inRadius || this._actorData.type == QUEST_ACTOR_TYPE_ITEM && this._clickIcon == null || this._actorData.type == QUEST_ACTOR_TYPE_GROUP_ITEM && this._clickIcon == null || this._actorData.type == QUEST_ACTOR_TYPE_DROPPED_TREASURE && this._clickIcon == null || this._actorData.type == QUEST_ACTOR_TYPE_PLACED_TREASURE && this._clickIcon == null || this._actorData.type == QUEST_ACTOR_TYPE_NPC && this._clickIcon == null && this._mh == null)
               {
                  this.removeClickIcon();
                  switch(this._actorData.type)
                  {
                     case QUEST_ACTOR_TYPE_SPEAKER:
                        break;
                     case QUEST_ACTOR_TYPE_FACTORY:
                        QuestXtCommManager.questActorTriggered(this._actorId);
                        break;
                     case QUEST_ACTOR_TYPE_PLACED_TREASURE:
                        if(this._actorData.status == 0)
                        {
                           this._clickIcon = GETDEFINITIONBYNAME("QuestPickupIcon");
                           this._clickIcon.x = x + TREASURE_CLICK_OFFSET_X;
                           this._clickIcon.y = y + TREASURE_CLICK_OFFSET_Y;
                           QuestManager._layerManager.room_orbs.addChild(this._clickIcon);
                           QuestManager.playSound("ajq_popup");
                           this._clickIcon.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Click,false,0,true);
                           this._clickIcon.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOverEvt_Click,false,0,true);
                           this._clickIcon.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOutEvt_Click,false,0,true);
                        }
                        break;
                     case QUEST_ACTOR_TYPE_ITEM:
                     case QUEST_ACTOR_TYPE_GROUP_ITEM:
                        if(this._updatePositionTimer <= 0)
                        {
                           ai = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                           if(ai.questHealthPercentage > 0)
                           {
                              this._clickIcon = GETDEFINITIONBYNAME("QuestPickupIcon");
                              this._clickIcon.x = x + ITEM_CLICK_OFFSET_X;
                              this._clickIcon.y = y + ITEM_CLICK_OFFSET_Y;
                              QuestManager._layerManager.room_orbs.addChild(this._clickIcon);
                              QuestManager.playSound("ajq_popup");
                              this._clickIcon.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Click,false,0,true);
                              this._clickIcon.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOverEvt_Click,false,0,true);
                              this._clickIcon.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOutEvt_Click,false,0,true);
                           }
                        }
                        break;
                     case QUEST_ACTOR_TYPE_NPC:
                        if(Boolean(this._npc))
                        {
                           if(this._requireClick && this._npcPath == null && (this._chatBalloon == null || !this._chatBalloon.visible || this._chatBalloon.alpha == 0))
                           {
                              if(this._npc.npcDef.iconMediaRefId != 0)
                              {
                                 this._mh = new MediaHelper();
                                 this._mh.init(this._npc.npcDef.iconMediaRefId,this.onMediaHelperNpcIconReceived);
                              }
                           }
                        }
                        break;
                     case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                     case QUEST_ACTOR_TYPE_CIRCLETRIGGER:
                     case QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                     case QUEST_ACTOR_TYPE_VOLUMEINTERACTION:
                        QuestXtCommManager.questActorTriggered(this._actorId);
                        break;
                     case QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
                        break;
                     case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
                        if(this._actorData.subType == GIVE_GEMS || this._actorData.subType == GIVE_ORBS)
                        {
                           if(this._npc != null && this._npc.npcState == NPCView.NPC_STATE_TREASURE_APPEAR)
                           {
                              playerData = QuestManager.getQuestPlayerData(AvatarManager.playerSfsUserId);
                              if(Boolean(playerData))
                              {
                                 gems = "+" + this._actorData.gems;
                                 playerData.playStatusText(gems);
                              }
                              this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_OPEN);
                              QuestXtCommManager.questActorTriggered(this._actorId,1);
                              this._actorData.pickedUp = true;
                           }
                        }
                  }
               }
            }
            else
            {
               if(this._inRadius != inRadius)
               {
                  switch(this._actorData.type)
                  {
                     case QUEST_ACTOR_TYPE_SPEAKER:
                        if(this._speakerSoundChannel != null)
                        {
                           this._speakerSoundChannel.stop();
                           this._speakerSoundChannel = null;
                        }
                        break;
                     case QUEST_ACTOR_TYPE_VOLUMEINTERACTION:
                     case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                        QuestXtCommManager.questActorUntriggered(this._actorId);
                        break;
                     case QUEST_ACTOR_TYPE_FACTORY:
                        QuestXtCommManager.questActorUntriggered(this._actorId);
                  }
               }
               this.removeClickIcon();
            }
            this._inRadius = inRadius;
            return this._inRadius;
         }
         this.removeClickIcon();
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_SPEAKER:
               if(this._speakerSoundChannel != null)
               {
                  this._speakerSoundChannel.stop();
                  this._speakerSoundChannel = null;
               }
         }
         return false;
      }
      
      private function removeClickIcon() : void
      {
         if(this._actorData.type == QUEST_ACTOR_TYPE_FACTORY || this._actorData.type == QUEST_ACTOR_TYPE_NPC)
         {
            if(Boolean(this._mh))
            {
               this._mh.destroy();
               this._mh = null;
            }
         }
         if(Boolean(this._clickIcon))
         {
            if(Boolean(this._clickIcon.parent))
            {
               this._clickIcon.parent.removeChild(this._clickIcon);
            }
            this._clickIcon = null;
         }
      }
      
      public function handleMouseDown(inAim:Point) : Boolean
      {
         var collisionOffset:Point = null;
         var distSq:Number = NaN;
         var toPlayerX:Number = NaN;
         var toPlayerY:Number = NaN;
         var attackRadius:Number = NaN;
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_FACTORY:
            case QUEST_ACTOR_TYPE_ATTACKER:
            case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
               if(this._actorData.type != QUEST_ACTOR_TYPE_DESTRUCTIBLE || this.npcDef == null || this.npcDef.defense != 99999)
               {
                  if(AvatarManager.playerAvatarWorldView != null && this._npc != null && this._npc.isDead == false)
                  {
                     if(this._visible)
                     {
                        collisionOffset = this._npc.collisionMovingPoint;
                        collisionOffset.x += x;
                        collisionOffset.y += y;
                        distSq = (inAim.x - collisionOffset.x) * (inAim.x - collisionOffset.x) + (inAim.y - collisionOffset.y) * (inAim.y - collisionOffset.y);
                        if(distSq < this._npc.collisionRadiusMoving * this._npc.collisionRadiusMoving)
                        {
                           toPlayerX = AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - collisionOffset.x;
                           toPlayerY = AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - collisionOffset.y;
                           attackRadius = this._npc.collisionRadiusMoving + 1.75 * QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                           if(toPlayerX * toPlayerX + toPlayerY * toPlayerY <= attackRadius * attackRadius)
                           {
                              if((this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE || this._attackable > 0) && this._actorData.healthPercent > 0)
                              {
                                 QuestManager.playerLaunchWeapon(collisionOffset,false);
                              }
                              this._playerSeekingActor = false;
                              gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
                              return true;
                           }
                        }
                     }
                  }
               }
         }
         return false;
      }
      
      private function onMouseDownEvt_DroppedTreasure(evt:MouseEvent) : void
      {
         var prizeDenItem:DenItem = null;
         var prizeAccessory:Item = null;
         if(this._visible)
         {
            if(this._npc != null && this._npc.npcStateComplete)
            {
               this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_OPEN);
               removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_DroppedTreasure);
               switch(this._actorData.subType)
               {
                  case GIVE_DEN_ITEM:
                     prizeDenItem = new DenItem();
                     prizeDenItem.initShopItem(this._actorData.denDefId,0);
                     this._prizePopup = new GiftPopup();
                     this._prizePopup.init(QuestManager._layerManager.gui,prizeDenItem.icon,prizeDenItem.name,prizeDenItem.itemDefId,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_DEN_ACC,this.keptItem,this.rejectedItem,this.destroyPrizePopup);
                     break;
                  case GIVE_ACCESSORY:
                     this._prizePopup = new GiftPopup();
                     prizeAccessory = new Item();
                     prizeAccessory.init(this._actorData.itemDefId,0,this._actorData.itemData,0,0,true);
                     this._prizePopup.init(QuestManager._layerManager.gui,prizeAccessory.largeIcon,prizeAccessory.name,prizeAccessory.defId,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_CLOTHING,this.keptItem,this.rejectedItem,this.destroyPrizePopup);
                     break;
                  case GIVE_GEMS:
                     this._mh = new MediaHelper();
                     this._mh.init(GEMS_MEDIA_ID,this.onMediaHelperGemIconReceived);
                     break;
                  case GIVE_ORBS:
                     this._mh = new MediaHelper();
                     this._mh.init(ORBS_MEDIA_ID,this.onMediaHelperOrbIconReceived);
                     break;
                  default:
                     QuestXtCommManager.questActorTriggered(this._actorId);
               }
               evt.stopPropagation();
            }
         }
      }
      
      private function onMediaHelperItemReceived(img:MovieClip) : void
      {
         this._mediaObject = img;
         this._mediaObject.setPlace(1);
         this._mediaObject.x = 0;
         this._mediaObject.y = 0;
         addChild(this._mediaObject);
         QuestManager._layerManager.room_avatars.addChild(this);
         this._mh.destroy();
         this._mh = null;
         this._loadingComplete = true;
      }
      
      private function onMediaHelperOrbIconReceived(img:MovieClip) : void
      {
         this._prizePopup = new GiftPopup();
         this._prizePopup.init(QuestManager._layerManager.gui,img,LocalizationManager.translateIdAndInsertOnly(LocalizationManager.ORBS_CAPITALIZED,this._actorData.gems),this._actorData.gems,GiftPopup.POPUP_TYPE_PRIZE,GiftPopup.GIFT_TYPE_ORBS,this.keptItem,this.keptItem,this.destroyPrizePopup,false,GiftPopup.BUTTONS_TYPE_OK);
         this._mh.destroy();
         this._mh = null;
      }
      
      private function onMediaHelperGemIconReceived(img:MovieClip) : void
      {
         this._prizePopup = new GiftPopup();
         this._prizePopup.init(QuestManager._layerManager.gui,img,LocalizationManager.translateIdAndInsertOnly(LocalizationManager.GEMS_CAPITALIZED,this._actorData.gems),this._actorData.gems,GiftPopup.POPUP_TYPE_PRIZE,GiftPopup.GIFT_TYPE_GEMS,this.keptItem,this.keptItem,this.destroyPrizePopup,false,GiftPopup.BUTTONS_TYPE_OK);
         this._mh.destroy();
         this._mh = null;
      }
      
      private function keptItem() : void
      {
         QuestXtCommManager.questActorTriggered(this._actorId,1);
         this._prizePopup.close();
      }
      
      private function rejectedItem() : void
      {
         QuestXtCommManager.questActorTriggered(this._actorId,0);
         this._prizePopup.close();
      }
      
      private function destroyPrizePopup() : void
      {
         if(Boolean(this._prizePopup))
         {
            this._prizePopup.destroy();
            this._prizePopup = null;
         }
      }
      
      public function testForClickAttack(clickPoint:Point) : Boolean
      {
         var collisionPoint:Point = null;
         var toX:Number = NaN;
         var toY:Number = NaN;
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_ATTACKER:
               if(this._npc != null && this._npc.npcMC != null && this._actorData.healthPercent > 0)
               {
                  if(this._npc.npcMC.hasOwnProperty("clickTarget"))
                  {
                     if(this._npc.npcMC.hasOwnProperty("clickOnPhantom"))
                     {
                        collisionPoint = this._npc.collisionMovingPoint;
                        toX = clickPoint.x - (x + collisionPoint.x);
                        toY = clickPoint.y - (y + collisionPoint.y);
                        if(toX == 0 && toY == 0 || toX * toX + toY * toY < 50 * 50)
                        {
                           if(Boolean(this._npc.npcMC.clickOnPhantom()))
                           {
                              QuestManager.questActorAttacked(this._actorId,-1,0,0,this);
                              return true;
                           }
                        }
                     }
                  }
               }
         }
         return false;
      }
      
      private function onMouseDownEvt_Attack(evt:MouseEvent) : void
      {
         var collisionOffset:Point = null;
         var toPlayerX:Number = NaN;
         var toPlayerY:Number = NaN;
         var attackRadius:Number = NaN;
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
            case QUEST_ACTOR_TYPE_ATTACKER:
               if(this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE || this._attackable > 0)
               {
                  if(AvatarManager.playerAvatarWorldView != null && this._npc != null && this._npc.isDead == false)
                  {
                     if(this._visible)
                     {
                        if(QuestManager.projectileKeyDown == false)
                        {
                           collisionOffset = this._npc.collisionMovingPoint;
                           collisionOffset.x += x;
                           collisionOffset.y += y;
                           toPlayerX = AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - collisionOffset.x;
                           toPlayerY = AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - collisionOffset.y;
                           attackRadius = this._npc.collisionRadiusMoving + 1.75 * QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                           if(toPlayerX * toPlayerX + toPlayerY * toPlayerY > attackRadius * attackRadius)
                           {
                              this._playerSeekingActor = true;
                              gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
                           }
                        }
                     }
                  }
               }
         }
      }
      
      private function onMouseDownEvt_CancelAttack(evt:MouseEvent) : void
      {
         var root:DisplayObject = DisplayObject(evt.target);
         while(root != null)
         {
            if(root == this)
            {
               return;
            }
            root = root.parent;
         }
         this._playerSeekingActor = false;
         gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
      }
      
      private function onMouseDownEvt_Click(evt:MouseEvent) : void
      {
         var ai:AvatarInfo = null;
         evt.stopPropagation();
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_PLACED_TREASURE:
               if(this._npc != null)
               {
                  this._actorData.status = 1;
                  QuestXtCommManager.questActorTriggered(this._actorId);
               }
               break;
            case QUEST_ACTOR_TYPE_ITEM:
            case QUEST_ACTOR_TYPE_GROUP_ITEM:
               if(AvatarManager.playerAvatarWorldView != null)
               {
                  ai = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                  if(ai.questHealthPercentage > 0)
                  {
                     QuestXtCommManager.questPickUpItem(this._actorId);
                     this._updatePositionTimer = 1;
                  }
               }
               break;
            default:
               QuestXtCommManager.questActorTriggered(this._actorId);
         }
         this.removeClickIcon();
      }
      
      private function onMouseOverEvt_Click(evt:MouseEvent) : void
      {
         MovieClip(evt.currentTarget).transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
      }
      
      private function onMouseOutEvt_Click(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
         MovieClip(evt.currentTarget).transform.colorTransform = new ColorTransform(1,1,1);
      }
      
      public function onNpcLoaded() : void
      {
         var npcMC:MovieClip = null;
         var params:Array = null;
         var i:int = 0;
         var param:Array = null;
         if(this._npc == null)
         {
            return;
         }
         this._npc.x = 0;
         this._npc.y = 0;
         addChild(this._npc);
         switch(this._actorData.type)
         {
            case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
            case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
            case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
               this._npc.updateHealthBar(this._actorData.healthPercent,0,false,this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE);
               if(this._spawnedFromPos != null)
               {
                  this._updatePositionTimer = 1;
                  this._npc.npcMC.appear(180,this._spawnedFromPos);
                  if(this._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER)
                  {
                     this._radiusOverride = true;
                     this._npc.npcMC.setVisionAnim(false);
                  }
               }
               else if(Boolean(this._actorData.respawned))
               {
                  this._npc.setNpcState(NPCView.NPC_STATE_IDLE);
               }
               if(this._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER)
               {
                  if(this._npc.npcMC.hasOwnProperty("setVision"))
                  {
                     this._npc.npcMC.setVision(this._actorDefaultInnerRadius);
                  }
                  if(this._npc.npcMC.hasOwnProperty("setBubbleTrail"))
                  {
                     this._npc.npcMC.setBubbleTrail(QuestManager._layerManager.room_avatars);
                  }
               }
               if(this._npc.npcMC.hasOwnProperty("setHealth"))
               {
                  this._npc.npcMC.setHealth(this._actorData.healthPercent);
               }
               if(Boolean(this._npc._eye) && Boolean(QuestManager._darknessMask))
               {
                  QuestManager._layerManager.room_fg.addChild(this._npc._eye);
                  this._eyeInFG = true;
               }
               if(Boolean(this._npc._beam) && Boolean(QuestManager._darknessMask))
               {
                  QuestManager._layerManager.room_fg.addChild(this._npc._beam);
                  this._beamInFG = true;
               }
               break;
            case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
               this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_APPEAR);
               switch(this._actorData.subType)
               {
                  case GIVE_ORBS:
                  case GIVE_GEMS:
                     break;
                  default:
                     addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_DroppedTreasure);
               }
               break;
            case QUEST_ACTOR_TYPE_PLACED_TREASURE:
               if(this._actorData.status == 0)
               {
                  this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_APPEAR);
               }
               else
               {
                  this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_OPEN);
               }
               break;
            case QUEST_ACTOR_TYPE_PLANT:
               mouseEnabled = false;
               mouseChildren = false;
               this._npc.updateHealthBar(this._actorData.healthPercent,0,false,this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE);
               if(this._actorData["plantEaten"] != null && Boolean(this._actorData.plantEaten))
               {
                  this.setPlantEats(null);
                  this._actorData.pendingSwfStateName = "";
               }
               else
               {
                  this._npc.npcMC.appear(180,this._spawnedFromPos);
               }
               break;
            case QUEST_ACTOR_TYPE_NPC:
               mouseEnabled = false;
               mouseChildren = false;
               if(Boolean(this._npc.npcMC) && this._npc.npcMC.hasOwnProperty("setBubbleTrail"))
               {
                  this._npc.npcMC.setBubbleTrail(QuestManager._layerManager.room_avatars);
               }
               break;
            case QUEST_ACTOR_TYPE_LIGHT_BEAM:
               mouseEnabled = false;
               mouseChildren = false;
               this._actorData.lightParamSpeed = 0;
               this._actorData.lightParamStartAngle = 0;
               this._actorData.lightParamEndAngle = -1;
               this._actorData.lightParamMaxLength = this._actorDefaultOuterRadius;
               if(this._actorData.extendedParameters != null)
               {
                  params = this._actorData.extendedParameters.split(",");
                  for(i = 0; i < params.length; i++)
                  {
                     param = params[i].split("=");
                     switch(param[0])
                     {
                        case "speed":
                           this._actorData.lightParamSpeed = Number(param[1]);
                           break;
                        case "start":
                           this._actorData.lightParamStartAngle = Number(param[1]);
                           break;
                        case "end":
                           this._actorData.lightParamEndAngle = Number(param[1]);
                     }
                  }
                  if(this._actorData.lightParamEndAngle != -1 && this._actorData.lightParamEndAngle < this._actorData.lightParamStartAngle)
                  {
                     this._actorData.lightParamEndAngle += 360;
                  }
               }
               this._actorData.lightParamAngle = this._actorData.lightParamStartAngle;
               this._npc.npcMC.setLength(this._actorData.lightParamMaxLength);
               this._npc.npcMC.setAngle(this._actorData.lightParamAngle);
         }
         this._npc.setNpcState(NPCView.NPC_STATE_IDLE,0);
         this._loadingComplete = true;
         if(this._actorData.pendingSwfStateName != "")
         {
            this.setSwfState(this._actorData.pendingSwfStateName);
         }
      }
      
      public function getActiveWeapon(inProjectileType:Boolean) : int
      {
         var npcDef:Object = QuestManager.getNPCDef(this._actorData.defId);
         var bestWeaponItemDefId:int = 0;
         bestWeaponItemDefId = this.evaluateWeapon(inProjectileType,npcDef.backItemRefId,npcDef.backColor,bestWeaponItemDefId);
         bestWeaponItemDefId = this.evaluateWeapon(inProjectileType,npcDef.eyesItemRefId,npcDef.eyesColor,bestWeaponItemDefId);
         bestWeaponItemDefId = this.evaluateWeapon(inProjectileType,npcDef.legItemRefId,npcDef.legColor,bestWeaponItemDefId);
         bestWeaponItemDefId = this.evaluateWeapon(inProjectileType,npcDef.headItemRefId,npcDef.headColor,bestWeaponItemDefId);
         bestWeaponItemDefId = this.evaluateWeapon(inProjectileType,npcDef.neckItemRefId,npcDef.neckColor,bestWeaponItemDefId);
         return this.evaluateWeapon(inProjectileType,npcDef.tailItemRefId,npcDef.tailColor,bestWeaponItemDefId);
      }
      
      public function evaluateWeapon(inProjectileType:Boolean, itemDefId:int, itemColor:Number, bestItemDefId:int) : int
      {
         var newItem:Object = null;
         var bestItem:Object = null;
         if(itemDefId != 0)
         {
            newItem = ItemXtCommManager.getItemDef(itemDefId);
            if(Boolean(newItem) && newItem.attackMediaRefId != 0)
            {
               if(inProjectileType && newItem.combatType == QuestManager.QUEST_WEAPON_TYPE_PROJECTILE || inProjectileType == false && (newItem.combatType == QuestManager.QUEST_WEAPON_TYPE_MELEE || newItem.combatType == QuestManager.QUEST_WEAPON_TYPE_BOMB))
               {
                  if(bestItemDefId != 0)
                  {
                     bestItem = ItemXtCommManager.getItemDef(bestItemDefId);
                     if(newItem.damage > bestItem.damage)
                     {
                        this._attackPlayerWeaponColor = itemColor;
                        bestItemDefId = itemDefId;
                     }
                  }
                  else
                  {
                     this._attackPlayerWeaponColor = itemColor;
                     bestItemDefId = itemDefId;
                  }
               }
            }
         }
         return bestItemDefId;
      }
      
      public function recoil() : void
      {
         this._npc.setNpcState(NPCView.NPC_STATE_RECOIL,0);
      }
      
      public function handleHit(inLocal:Boolean, inWeaponDefId:int) : void
      {
         if(this._npc != null && this._npc.isDying == false)
         {
            if(inLocal)
            {
               if(this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE || this._actorData.type == QUEST_ACTOR_TYPE_ATTACKER && this._attackable > 0)
               {
                  QuestManager.questActorAttacked(this._actorId,inWeaponDefId,x,y,this);
               }
               if(this._actorData.type == QUEST_ACTOR_TYPE_ATTACKER && this._seekActive < SEEKTYPE_PLAYER)
               {
                  this._requestSeekTimer = 2;
                  QuestManager.setQuestActorSeek(this,SEEKTYPE_PLAYER);
               }
            }
            if(this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE || this._actorData.type == QUEST_ACTOR_TYPE_ATTACKER && this._attackable > 0)
            {
               this.recoil();
            }
         }
      }
      
      public function getAngleToTarget(targetX:Number, targetY:Number) : Number
      {
         var collisionPoint:Point = this._npc.collisionMovingPoint;
         var toTargetX:Number = targetX - (x + collisionPoint.x);
         var toTargetY:Number = targetY - (y + collisionPoint.y);
         if(toTargetX == 0 && toTargetY == 0)
         {
            toTargetX = 1;
         }
         var distance:Number = Math.sqrt(toTargetX * toTargetX + toTargetY * toTargetY);
         if(distance != 0)
         {
            toTargetX /= distance;
            toTargetY /= distance;
         }
         else
         {
            toTargetX = 1;
            toTargetY = 0;
         }
         var npcAngle:Number = Math.asin(toTargetX);
         if(toTargetY > 0)
         {
            npcAngle = -(Math.PI + npcAngle);
         }
         return npcAngle * 180 / Math.PI;
      }
      
      public function handleAttackPlayer(inWeaponItemDefId:int, inColor:uint, inPlayerSfsId:int) : void
      {
         var npcAngle:Number = NaN;
         if(this._npc != null && AvatarManager.avatarViewList[inPlayerSfsId] != null)
         {
            this._attackPlayerSfsId = inPlayerSfsId;
            this._attackPlayerWeaponItemDefId = inWeaponItemDefId;
            this._attackPlayerWeaponColor = inColor;
            npcAngle = this.getAngleToTarget(AvatarManager.avatarViewList[inPlayerSfsId].avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.avatarViewList[inPlayerSfsId].avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
            this._npc.setNpcState(NPCView.NPC_STATE_ATTACK,npcAngle);
         }
      }
      
      public function healthUpdate(healthPercent:int, damageAmount:int, criticalHit:Boolean) : void
      {
         if(this._npc != null)
         {
            this._npc.updateHealthBar(healthPercent,damageAmount,criticalHit,this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE);
            if(this._npc.npcMC != null && this._npc.npcMC.hasOwnProperty("setHealth"))
            {
               this._npc.npcMC.setHealth(healthPercent);
            }
         }
      }
      
      public function handleDeath(damage:int) : Boolean
      {
         if(this._npc != null)
         {
            this._npc.updateHealthBar(0,damage,false,this._actorData.type == QUEST_ACTOR_TYPE_DESTRUCTIBLE);
         }
         if(Boolean(this._alertLP))
         {
            QuestManager.stopLoopingSound(this._alertLP);
            this._alertLP = null;
         }
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_FACTORY:
            case QUEST_ACTOR_TYPE_ATTACKER:
            case QUEST_ACTOR_TYPE_DESTRUCTIBLE:
               removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
               if(this._npc != null)
               {
                  this._npc.setNpcState(NPCView.NPC_STATE_DEATH,0);
                  return false;
               }
               break;
            default:
               if(this._npc != null && this._npc.npcMC != null && this._npc.npcMC.hasOwnProperty("deathAnimComplete"))
               {
                  return this._npc.npcMC.deathAnimComplete;
               }
         }
         return true;
      }
      
      public function handleTriggerTreasure(inType:int, inDefId:int, inData:int) : void
      {
         var prizeDenItem:DenItem = null;
         var prizeAccessory:Item = null;
         switch(inType)
         {
            case GIVE_DEN_ITEM:
               prizeDenItem = new DenItem();
               prizeDenItem.initShopItem(inDefId,0);
               this._prizePopup = new GiftPopup();
               this._prizePopup.init(QuestManager._layerManager.gui,prizeDenItem.icon,prizeDenItem.name,prizeDenItem.itemDefId,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_DEN_ACC,this.keptPlacedTreasure,this.rejectedPlacedTreasure,this.destroyPlacedTreasurePopup,false,GiftPopup.BUTTONS_TYPE_KEEP_DISCARD,AvatarManager.roomEnviroType);
               break;
            case GIVE_ACCESSORY:
               this._prizePopup = new GiftPopup();
               prizeAccessory = new Item();
               prizeAccessory.init(inDefId,0,inData,0,0,true);
               this._prizePopup.init(QuestManager._layerManager.gui,prizeAccessory.largeIcon,prizeAccessory.name,prizeAccessory.defId,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_CLOTHING,this.keptPlacedTreasure,this.rejectedPlacedTreasure,this.destroyPlacedTreasurePopup,false,GiftPopup.BUTTONS_TYPE_KEEP_DISCARD,AvatarManager.roomEnviroType);
               break;
            case GIVE_GEMS:
               this._prizeAmount = inDefId;
               this._mh = new MediaHelper();
               this._mh.init(GEMS_MEDIA_ID,this.onMediaHelperGemIconDroppedTreasureReceived);
               break;
            case GIVE_ORBS:
               this._prizeAmount = inDefId;
               this._mh = new MediaHelper();
               this._mh.init(ORBS_MEDIA_ID,this.onMediaHelperOrbIconDroppedTreasureReceived);
               break;
            case GIVE_FAILED:
               this._actorData.status = 0;
         }
      }
      
      private function onMediaHelperOrbIconDroppedTreasureReceived(img:MovieClip) : void
      {
         this._prizePopup = new GiftPopup();
         this._prizePopup.init(QuestManager._layerManager.gui,img,LocalizationManager.translateIdAndInsertOnly(LocalizationManager.ORBS_CAPITALIZED,this._prizeAmount),this._prizeAmount,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_ORBS,this.keptDroppedTreasure,this.keptDroppedTreasure,this.destroyDroppedTreasurePopup,false,GiftPopup.BUTTONS_TYPE_OK,AvatarManager.roomEnviroType);
         this._mh.destroy();
         this._mh = null;
      }
      
      private function onMediaHelperGemIconDroppedTreasureReceived(img:MovieClip) : void
      {
         this._prizePopup = new GiftPopup();
         this._prizePopup.init(QuestManager._layerManager.gui,img,LocalizationManager.translateIdAndInsertOnly(LocalizationManager.GEMS_CAPITALIZED,this._prizeAmount),this._prizeAmount,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_GEMS,this.keptDroppedTreasure,this.keptDroppedTreasure,this.destroyDroppedTreasurePopup,false,GiftPopup.BUTTONS_TYPE_OK,AvatarManager.roomEnviroType);
         this._mh.destroy();
         this._mh = null;
      }
      
      private function keptPlacedTreasure() : void
      {
         QuestXtCommManager.questActorTreasureTriggered(this._actorId,1);
         this._prizePopup.close();
         this._actorData.status = 1;
         this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_OPEN);
      }
      
      private function rejectedPlacedTreasure() : void
      {
         QuestXtCommManager.questActorTreasureTriggered(this._actorId,0);
         this._prizePopup.close();
         this._actorData.status = 1;
         this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_OPEN);
      }
      
      private function destroyPlacedTreasurePopup() : void
      {
         if(Boolean(this._prizePopup))
         {
            this._prizePopup.destroy();
            this._prizePopup = null;
         }
      }
      
      private function keptDroppedTreasure() : void
      {
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
            case QUEST_ACTOR_TYPE_PLACED_TREASURE:
               if(this._npc != null && this._npc.npcState == NPCView.NPC_STATE_TREASURE_APPEAR)
               {
                  this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_OPEN);
               }
         }
         QuestXtCommManager.questActorTreasureTriggered(this._actorId,1);
         this._prizePopup.close();
      }
      
      private function destroyDroppedTreasurePopup() : void
      {
         if(Boolean(this._prizePopup))
         {
            this._prizePopup.destroy();
            this._prizePopup = null;
         }
      }
      
      public function setSwfState(swfStateName:String) : void
      {
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_PLACED_TREASURE:
               if(swfStateName == "appear")
               {
                  if(this._actorData.status != 0)
                  {
                     swfStateName = "opened";
                  }
               }
         }
         if(this._npc != null && this._loadingComplete)
         {
            this._updatePositionTimer = this._npc.setSwfState(swfStateName);
            if(this._updatePositionTimer > 0)
            {
               this._spawnedFromPos = new Point(x,y);
            }
         }
         else
         {
            this._actorData.pendingSwfStateName = swfStateName;
         }
      }
      
      public function setActorText(text:String) : void
      {
         if(this._npc != null)
         {
            this._npc.playHitText(text);
         }
      }
      
      public function setChatBalloonText(txt:String, useInfoStyle:Boolean = false) : void
      {
         var attachmentPoint:Point = null;
         if(Boolean(this._chatBalloon))
         {
            this._chatBalloon.setText(txt);
         }
         else
         {
            this._chatBalloon = GETDEFINITIONBYNAME("ChatBalloonAsset");
            this._chatBalloon.init(0,AvatarUtility.getAvatarEmoteBgOffset,false,useInfoStyle ? 9 : 1);
            try
            {
               attachmentPoint = this._npc.npcMC.getAttachmentPoint();
            }
            catch(e:Error)
            {
               attachmentPoint = new Point(-10,-90);
            }
            this._chatBalloon.setPos(x + attachmentPoint.x,y + attachmentPoint.y);
            QuestManager._layerManager.room_orbs.addChild(this._chatBalloon);
            this._chatBalloon.setText(txt);
         }
      }
      
      public function setPath(inPathName:String) : void
      {
         if(inPathName != null)
         {
            this._npcPath = RoomManagerWorld.instance.findPathByName(inPathName);
            if(this._npcPath != null)
            {
               this.removeClickIcon();
               this._npcReachedPathEnd = false;
               this._pathDirectionForward = true;
               this._pathNode = Math.min(this._npcPath.points.length - 1,1);
               if(this._seekActive == SEEKTYPE_OFF)
               {
                  this._requestSeekTimer = 0;
               }
            }
         }
         else
         {
            this._npcPath = null;
         }
      }
      
      public function plantTargettable() : Boolean
      {
         if(this._actorData.type == QuestActor.QUEST_ACTOR_TYPE_PLANT && !this.isDead && this._npc != null && this._npc.npcMC != null && Boolean(this._npc.npcMC.phantomCanTarget))
         {
            return true;
         }
         return false;
      }
      
      public function handleBeamZap(inPlayerSfsId:int) : void
      {
         if(this._npc != null && this._npc.npcMC != null)
         {
            this._npc.npcMC.zap(this._actorData.lightParamAngle);
         }
      }
      
      public function handlePhantomZap(inPlayerSfsId:int) : void
      {
         var npcAngle:Number = NaN;
         if(this._npc != null && this._npc.npcMC != null && this._npc.npcState != NPCView.NPC_STATE_DEATH)
         {
            npcAngle = this.getAngleToTarget(AvatarManager.avatarViewList[inPlayerSfsId].avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.avatarViewList[inPlayerSfsId].avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
            this._npc.npcMC.zap(npcAngle);
         }
      }
      
      public function testPointInActorVolumes(inLocation:Point) : Boolean
      {
         var volumeIndex:int = 0;
         if(this._visible && this._volumes != null)
         {
            for(volumeIndex = 0; volumeIndex < this._volumes.length; volumeIndex++)
            {
               if(RoomManagerWorld.instance.volumeManager.testPointInVolume(inLocation,this._volumes[volumeIndex]))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function distanceSqToPlayer() : Number
      {
         var collisionPoint:Point = null;
         var toX:Number = NaN;
         var toY:Number = NaN;
         if(this._npc != null && AvatarManager.playerAvatarWorldView != null)
         {
            collisionPoint = this._npc.collisionZapPoint;
            collisionPoint.x += x;
            collisionPoint.y += y;
            toX = collisionPoint.x - (AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX);
            toY = collisionPoint.y - (AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
            return toX * toX + toY * toY;
         }
         return -1;
      }
      
      public function pathToPlayerInRange() : Boolean
      {
         var nearest:Number = NaN;
         var index:int = 0;
         var toX:Number = NaN;
         var toY:Number = NaN;
         var distSq:Number = this.distanceSqToPlayer();
         if(distSq != -1 && distSq < PHANTOM_OUT_OF_RANGE_SQ)
         {
            return true;
         }
         if(this._npc != null && AvatarManager.playerAvatarWorldView != null && this._npcPath != null)
         {
            nearest = -1;
            for(index = 0; index < this._npcPath.points.length; index++)
            {
               toX = this._npcPath.points[index].x - (AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX);
               toY = this._npcPath.points[index].y - (AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
               distSq = toX * toX + toY * toY;
               if(nearest == -1 || distSq < nearest)
               {
                  nearest = distSq;
               }
               if(nearest < PHANTOM_OUT_OF_RANGE_SQ)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function updateTorch() : void
      {
         if(this._visible && Boolean(this._actorData.torchEnabled))
         {
            this._torchActive = true;
            QuestManager.addTorch(this,this._actorDefaultOuterRadius / 100);
         }
         else if(this._torchActive)
         {
            this._torchActive = false;
            QuestManager.removeTorch(this);
         }
      }
      
      public function updateIcon(inShow:Boolean) : void
      {
         if(inShow && this._visible)
         {
            this._showIcon = inShow;
         }
         else
         {
            this._showIcon = false;
         }
      }
      
      public function testBeamIntersectPlayer() : void
      {
         var ai:AvatarInfo = null;
         var hitX:Number = NaN;
         var hitY:Number = NaN;
         var startPt:Point = null;
         var distSquaredToPlayer:Number = NaN;
         var playerPt:Point = null;
         var endPt:Point = null;
         var intersectResult:Object = null;
         var avView:AvatarWorldView = AvatarManager.playerAvatarWorldView;
         if(avView != null)
         {
            this._zapTimer = 0.3;
            ai = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
            if(ai.questHealthPercentage > 0)
            {
               hitX = avView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX;
               hitY = avView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY;
               startPt = this._npc.npcMC.getStartPoint();
               startPt.x += x;
               startPt.y += y;
               distSquaredToPlayer = (startPt.x - hitX) * (startPt.x - hitX) + (startPt.y - hitY) * (startPt.y - hitY);
               if(distSquaredToPlayer <= (this._actorData.lightParamMaxLength + QuestManager.QUEST_PLAYER_AVATAR_RADIUS) * (this._actorData.lightParamMaxLength + QuestManager.QUEST_PLAYER_AVATAR_RADIUS))
               {
                  playerPt = new Point(hitX,hitY);
                  endPt = this._npc.npcMC.getEndPoint();
                  endPt.x += x;
                  endPt.y += y;
                  intersectResult = this.lineIntersectCircle(startPt,endPt,playerPt,QuestManager.QUEST_PLAYER_AVATAR_RADIUS);
                  if(intersectResult != null && (Boolean(intersectResult.inside) || Boolean(intersectResult.intersects)))
                  {
                     QuestXtCommManager.questBeamZap(this._actorId,AvatarManager.playerAvatarWorldView.userId);
                     this._npc.npcMC.zap(this._actorData.lightParamAngle);
                     this._zapTimer = 2;
                  }
               }
            }
         }
      }
      
      public function lineIntersectCircle(A:Point, B:Point, C:Point, r:Number = 1) : Object
      {
         var e:Number = NaN;
         var u1:Number = NaN;
         var u2:Number = NaN;
         var result:Object = new Object();
         result.inside = false;
         result.tangent = false;
         result.intersects = false;
         result.enter = null;
         result.exit = null;
         var a:Number = (B.x - A.x) * (B.x - A.x) + (B.y - A.y) * (B.y - A.y);
         var b:Number = 2 * ((B.x - A.x) * (A.x - C.x) + (B.y - A.y) * (A.y - C.y));
         var cc:Number = C.x * C.x + C.y * C.y + A.x * A.x + A.y * A.y - 2 * (C.x * A.x + C.y * A.y) - r * r;
         var deter:Number = b * b - 4 * a * cc;
         if(deter <= 0)
         {
            result.inside = false;
         }
         else
         {
            e = Math.sqrt(deter);
            u1 = (-b + e) / (2 * a);
            u2 = (-b - e) / (2 * a);
            if((u1 < 0 || u1 > 1) && (u2 < 0 || u2 > 1))
            {
               if(u1 < 0 && u2 < 0 || u1 > 1 && u2 > 1)
               {
                  result.inside = false;
               }
               else
               {
                  result.inside = true;
               }
            }
            else
            {
               if(0 <= u2 && u2 <= 1)
               {
                  result.enter = Point.interpolate(A,B,1 - u2);
               }
               if(0 <= u1 && u1 <= 1)
               {
                  result.exit = Point.interpolate(A,B,1 - u1);
               }
               result.intersects = true;
               if(result.exit != null && result.enter != null && Boolean(result.exit.equals(result.enter)))
               {
                  result.tangent = true;
               }
            }
         }
         return result;
      }
   }
}

