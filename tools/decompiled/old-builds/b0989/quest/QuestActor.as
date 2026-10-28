package quest
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.NPCView;
   import com.sbi.corelib.math.Collision;
   import den.DenItem;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import gui.ChatBalloon;
   import gui.GiftPopup;
   import gui.GuiManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import room.RoomGrid;
   import room.RoomManagerWorld;
   
   public class QuestActor extends Sprite
   {
      
      public static const SEEKTYPE_OFF:int = 0;
      
      public static const SEEKTYPE_PATH:int = 1;
      
      public static const SEEKTYPE_PLAYER:int = 2;
      
      public static const SEEKTYPE_PLANT:int = 3;
      
      public static const GIVE_DEN_ITEM:int = 1;
      
      public static const GIVE_ACCESSORY:int = 2;
      
      public static const GIVE_GEMS:int = 3;
      
      public static const GIVE_ORBS:int = 4;
      
      private static const ITEM_CLICK_OFFSET_X:int = 0;
      
      private static const ITEM_CLICK_OFFSET_Y:int = -40;
      
      private static const TREASURE_CLICK_OFFSET_X:int = 0;
      
      private static const TREASURE_CLICK_OFFSET_Y:int = -40;
      
      private static const GEMS_MEDIA_ID:int = 1086;
      
      private static const ORBS_MEDIA_ID:int = 2057;
      
      private static const ATTACKER_VELOCITY:int = 40;
      
      private static const ATTACKER_VELOCITY_RANGE:int = 60;
      
      private static const ATTACKER_RANGE_WEAPON_PROJECTILE:int = 350;
      
      private static const ATTACKER_RANGE_WEAPON_MIN_PROJECTILE:int = 100;
      
      private static const PHANTOM_OUT_OF_RANGE_SQ:int = 640000;
      
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
      
      private var _npc:NPCView;
      
      private var _volumes:Array;
      
      private var _lastMeleeID:int;
      
      private var _prizePopup:GiftPopup;
      
      private var _mh:MediaHelper;
      
      private var _prizeAmount:int;
      
      private var _inCollision:Boolean;
      
      private var _speakerSoundChannel:SoundChannel;
      
      public var _loadingComplete:Boolean;
      
      public function QuestActor()
      {
         super();
      }
      
      public function get isDead() : Boolean
      {
         return this._npc != null && this._npc.isDead;
      }
      
      public function get npcDef() : Object
      {
         if(this._npc != null)
         {
            return this._npc.npcDef;
         }
         return null;
      }
      
      public function get alertLP() : SoundChannel
      {
         return this._alertLP;
      }
      
      public function set alertLP(param1:SoundChannel) : void
      {
         this._alertLP = param1;
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
            return this._npc.collisionPoint;
         }
         return new Point(0,0);
      }
      
      public function get collisionRadius() : Number
      {
         if(this._npc != null)
         {
            return this._npc.collisionRadius;
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
      
      private function initVars(param1:String, param2:Object, param3:int, param4:int, param5:int, param6:Point) : void
      {
         this._seekActor = null;
         this._attackTimer = 0;
         this._zapTimer = 0;
         this._lastMeleeID = 0;
         this._actorData = param2;
         this._actorId = param1;
         this._actorDefaultInnerRadius = param3;
         this._actorDefaultOuterRadius = param4;
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
         this._priority = param5;
         this._spawnedFromPos = param6;
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
      
      public function resetActor(param1:String, param2:Object, param3:int, param4:int, param5:int, param6:Point) : void
      {
         this.initVars(param1,param2,param3,param4,param5,param6);
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_FACTORY:
            case QUEST_ACTOR_TYPE_ATTACKER:
               addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
               this._targetX = x;
               this._targetY = y;
               this.resetNPC(this._actorData.actorPos);
               break;
            case QUEST_ACTOR_TYPE_PLANT:
            case QUEST_ACTOR_TYPE_NPC:
               this.resetNPC(this._actorData.actorPos);
               break;
            default:
               throw new Error("Trying to recycle an asset that is not a valid type");
         }
      }
      
      public function initActor(param1:String, param2:Object, param3:int, param4:int, param5:int, param6:Point) : void
      {
         this._loadingComplete = false;
         this.initVars(param1,param2,param3,param4,param5,param6);
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
            case QUEST_ACTOR_TYPE_ATTACKER:
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
            case QUEST_ACTOR_TYPE_ITEM:
            case QUEST_ACTOR_TYPE_GROUP_ITEM:
               this._mh = new MediaHelper();
               this._mh.init(this._actorData.defId,this.onMediaHelperItemReceived);
               break;
            case QUEST_ACTOR_TYPE_VOLUMEPLACEMENT:
               this._volumes = RoomManagerWorld.instance.volumeManager.findVolume(param1);
               this._loadingComplete = true;
               break;
            case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
            case QUEST_ACTOR_TYPE_VOLUMETRIGGER:
            case QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
               this._volumes = RoomManagerWorld.instance.volumeManager.findVolume(param1);
               if(this._volumes != null)
               {
                  RoomManagerWorld.instance.enableVolume(param1,this._visible);
               }
               this._loadingComplete = true;
               break;
            default:
               this._loadingComplete = true;
         }
      }
      
      private function resetNPC(param1:Point) : void
      {
         AvatarManager.addQuestActor(this,param1);
         var _loc2_:Object = QuestManager.getNPCDef(this._actorData.defId);
         if(Boolean(_loc2_) && _loc2_.type == 1)
         {
         }
         this._npc.reset();
         this.onNpcLoaded();
      }
      
      private function initNPC(param1:Point, param2:Boolean = false, param3:Boolean = false) : void
      {
         var _loc5_:Object = null;
         var _loc4_:int = 0;
         if(param3)
         {
            _loc5_ = QuestManager.getNPCDef(this._actorData.defId);
            if((Boolean(_loc5_)) && _loc5_.type == 1)
            {
               _loc4_ = int(_loc5_.titleStrId);
            }
         }
         this._npc = new NPCView();
         this._npc.init(this._actorData.defId,0,_loc4_,param2,this.onNpcLoaded);
         AvatarManager.addQuestActor(this,param1);
      }
      
      public function handlePositionUpdate(param1:int, param2:int, param3:int, param4:int) : void
      {
         if(this._seekActive == SEEKTYPE_OFF)
         {
            if(this._npc != null && this._npc.npcMC != null)
            {
               switch(param4)
               {
                  case SEEKTYPE_PLANT:
                  case SEEKTYPE_PLAYER:
                     this._npc.npcMC.alertStatus(true);
                     break;
                  default:
                     this._npc.npcMC.alertStatus(false);
               }
            }
            if(this._actorData.actorPos != null)
            {
               this._actorData.actorPos.x = param1;
               this._actorData.actorPos.y = param2;
            }
            this._targetX = param1;
            this._targetY = param2;
            this._seekVelocity = param3;
         }
      }
      
      public function handleRequestSeekResponse(param1:int) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:Point = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         this._seekActive = param1;
         switch(param1)
         {
            case SEEKTYPE_PLAYER:
            case SEEKTYPE_PLANT:
               this._seekVelocity = ATTACKER_VELOCITY + Math.random() * ATTACKER_VELOCITY_RANGE;
               if(this._npc != null && this._npc.npcMC != null)
               {
                  this._npc.npcMC.alertStatus(true);
               }
               break;
            case SEEKTYPE_PATH:
               this._pathNode = 0;
               if(this._npc != null && AvatarManager.playerAvatarWorldView != null && this._npcPath != null)
               {
                  _loc2_ = -1;
                  _loc3_ = 0;
                  while(_loc3_ < this._npcPath.points.length)
                  {
                     _loc4_ = this._npc.collisionPoint;
                     _loc5_ = this._npcPath.points[_loc3_].x - (x + _loc4_.x);
                     _loc6_ = this._npcPath.points[_loc3_].y - (y + _loc4_.y);
                     _loc7_ = _loc5_ * _loc5_ + _loc6_ * _loc6_;
                     if(_loc2_ == -1 || _loc7_ < _loc2_)
                     {
                        _loc2_ = _loc7_;
                        this._pathNode = _loc3_;
                     }
                     _loc3_++;
                  }
               }
               break;
            default:
               if(this._npc != null && this._npc.npcMC != null)
               {
                  this._npc.npcMC.alertStatus(false);
               }
         }
      }
      
      public function setRequireClick(param1:Boolean) : void
      {
         if(param1)
         {
            this._inRadius = false;
         }
         else
         {
            this.removeClickIcon();
         }
         this._requireClick = param1;
      }
      
      public function setVisible(param1:Boolean) : void
      {
         if(param1)
         {
            switch(this._actorData.type)
            {
               case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
               case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
               case QuestActor.QUEST_ACTOR_TYPE_PLANT:
                  if(this._actorData.healthPercent <= 0)
                  {
                     param1 = false;
                  }
            }
         }
         if(param1 != this._visible)
         {
            this._inRadius = false;
            visible = param1;
            this._visible = param1;
            if(!this._visible)
            {
               this.removeClickIcon();
               if(this._seekActive != SEEKTYPE_OFF)
               {
                  QuestXtCommManager.questActorSeek(this._actorId,this._seekActive);
               }
            }
            if(this._volumes != null)
            {
               switch(this._actorData.type)
               {
                  case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                  case QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
                  case QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                     RoomManagerWorld.instance.enableVolume(this._actorId,this._visible);
               }
            }
         }
      }
      
      private function recycle() : void
      {
         if(this._mh)
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
         if(Boolean(this._npc) && Boolean(this._npc.npcMC) && (this._actorData.type == QUEST_ACTOR_TYPE_ATTACKER || this._actorData.type == QUEST_ACTOR_TYPE_FACTORY || this._actorData.type == QUEST_ACTOR_TYPE_NPC || this._actorData.type == QUEST_ACTOR_TYPE_PLANT))
         {
            this.recycle();
         }
         else
         {
            if(this._mh)
            {
               this._mh.destroy();
               this._mh = null;
            }
            if(this._mediaObject)
            {
               if(this._mediaObject.parent)
               {
                  this._mediaObject.parent.removeChild(this._mediaObject);
               }
               this._mediaObject = null;
            }
            if(this._prizePopup)
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
                  removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
                  gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
                  this.destroyNPC();
                  break;
               case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
                  removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_DroppedTreasure);
                  this.destroyNPC();
                  break;
               case QUEST_ACTOR_TYPE_NPC:
               case QUEST_ACTOR_TYPE_PLANT:
                  this.destroyNPC();
            }
            if(parent != null)
            {
               parent.removeChild(this);
            }
         }
         if(this._alertLP)
         {
            QuestManager.stopLoopingSound(this._alertLP);
            this._alertLP = null;
         }
      }
      
      public function destroyNPC() : void
      {
         if(this._npc)
         {
            if(this._npc.parent)
            {
               this._npc.parent.removeChild(this._npc);
            }
            this._npc.destroy();
            this._npc = null;
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Boolean = false;
         var _loc13_:Point = null;
         var _loc14_:Boolean = false;
         var _loc15_:int = 0;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:AvatarInfo = null;
         var _loc22_:Point = null;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Point = null;
         var _loc28_:QuestActor = null;
         if(this._visible && (this._npc == null || this._npc.isDying == false))
         {
            _loc3_ = 0;
            _loc4_ = 0;
            _loc5_ = 0;
            if(Boolean(this._chatBalloon) && this._chatBalloon.visible)
            {
               this._chatBalloon.heartbeat(10);
            }
            switch(this._actorData.type)
            {
               case QUEST_ACTOR_TYPE_ITEM:
               case QUEST_ACTOR_TYPE_GROUP_ITEM:
                  if(this._updatePositionTimer > 0)
                  {
                     this._updatePositionTimer -= param1;
                  }
                  break;
               case QUEST_ACTOR_TYPE_SPEAKER:
                  if(AvatarManager.playerAvatarWorldView != null)
                  {
                     _loc3_ = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - x;
                     _loc4_ = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - y;
                     _loc5_ = _loc3_ * _loc3_ + _loc4_ * _loc4_;
                     _loc6_ = this._actorDefaultInnerRadius * this._actorDefaultInnerRadius;
                     _loc7_ = this._actorDefaultOuterRadius * this._actorDefaultOuterRadius;
                     _loc8_ = 1;
                     if(_loc5_ > _loc7_)
                     {
                        _loc8_ = 0;
                     }
                     else if(_loc5_ >= _loc6_)
                     {
                        _loc8_ = 1 - (_loc5_ - _loc6_) / (_loc7_ - _loc6_);
                     }
                     if(_loc8_ > 0)
                     {
                        if(this._speakerSoundChannel == null)
                        {
                           this._speakerSoundChannel = QuestManager.playLoopingSound(this._actorData.defName);
                        }
                        QuestManager.setSoundLevel(this._speakerSoundChannel,_loc8_,this);
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
               case QUEST_ACTOR_TYPE_ATTACKER:
                  if(this._spawnedFromPos != null)
                  {
                     if(this._updatePositionTimer > 0)
                     {
                        this._updatePositionTimer -= param1;
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
                           this._seekVelocity = this._npc.npcMC.velocity;
                        }
                     }
                     this.checkPlantRadius();
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
                              _loc9_ = ItemXtCommManager.getItemDef(this._attackPlayerWeaponItemDefId);
                              if(_loc9_)
                              {
                                 _loc12_ = false;
                                 if(this._seekActive == SEEKTYPE_PLANT)
                                 {
                                    if(this._seekActor != null)
                                    {
                                       _loc13_ = this._seekActor.actorOffset;
                                       _loc10_ = this._seekActor._actorData.actorPos.x + _loc13_.x;
                                       _loc11_ = this._seekActor._actorData.actorPos.y + _loc13_.y;
                                       _loc12_ = true;
                                    }
                                 }
                                 if(_loc12_)
                                 {
                                    switch(_loc9_.combatType)
                                    {
                                       case QuestManager.QUEST_WEAPON_TYPE_PROJECTILE:
                                          QuestManager.launchProjectile(this._attackPlayerWeaponItemDefId,this._attackPlayerWeaponColor,_loc10_,_loc11_,this,null);
                                          break;
                                       case QuestManager.QUEST_WEAPON_TYPE_BOMB:
                                       case QuestManager.QUEST_WEAPON_TYPE_MELEE:
                                          QuestManager.swipeMelee(this._attackPlayerWeaponItemDefId,this._attackPlayerWeaponColor,_loc10_,_loc11_,this,null);
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
                        this._attackTimer -= param1;
                     }
                     if(this._requestSeekTimer > 0)
                     {
                        this._requestSeekTimer -= param1;
                     }
                     if(this._zapTimer > 0)
                     {
                        this._zapTimer -= param1;
                     }
                     if(this._updatePositionTimer > 0)
                     {
                        this._updatePositionTimer -= param1;
                     }
                     else if(this._tellServerPosition)
                     {
                        if(this._actorData.actorPos != null)
                        {
                           this._actorData.actorPos.x = x;
                           this._actorData.actorPos.y = y;
                        }
                        QuestXtCommManager.questActorPositionUpdate(this._actorId,x,y,this._seekVelocity,this._seekActive);
                        if(this._seekActive == SEEKTYPE_PATH)
                        {
                           this._updatePositionTimer = 0.8 + 0.4 * Math.random();
                        }
                        else
                        {
                           this._updatePositionTimer = 0.25 + 0.25 * Math.random();
                        }
                        this._tellServerPosition = false;
                     }
                     if(AvatarManager.playerAvatarWorldView != null)
                     {
                        _loc14_ = false;
                        if(this._zapTimer <= 0 && this._npc != null)
                        {
                           this._zapTimer = 0.3;
                           _loc21_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                           if(_loc21_.questHealthPercentage > 0)
                           {
                              _loc2_ = this._npc.collisionZapPoint;
                              _loc3_ = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - (x + _loc2_.x);
                              _loc4_ = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - (y + _loc2_.y);
                              _loc5_ = this._npc.collisionRadius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                              if(_loc3_ * _loc3_ + _loc4_ * _loc4_ < _loc5_ * _loc5_)
                              {
                                 QuestXtCommManager.questPhantomZap(this._actorId,AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
                                 this._zapTimer = 2;
                              }
                           }
                        }
                        _loc2_ = null;
                        _loc3_ = 0;
                        _loc4_ = 0;
                        _loc5_ = 0;
                        switch(this._seekActive)
                        {
                           case SEEKTYPE_PATH:
                              _loc2_ = this._npc.collisionPoint;
                              _loc3_ = this._npcPath.points[this._pathNode].x - (x + _loc2_.x);
                              _loc4_ = this._npcPath.points[this._pathNode].y - (y + _loc2_.y);
                              _loc5_ = 20;
                              _loc14_ = true;
                              if(this._npc != null && this._npc.npcMC != null)
                              {
                                 this._npc.npcMC.alertStatus(false);
                                 this._alerted = false;
                                 if(this._alertLP)
                                 {
                                    QuestManager.stopLoopingSound(this._alertLP);
                                    this._alertLP = null;
                                 }
                              }
                              break;
                           case SEEKTYPE_PLAYER:
                              _loc2_ = this._npc.collisionPoint;
                              _loc3_ = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - (x + _loc2_.x);
                              _loc4_ = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - (y + _loc2_.y);
                              _loc5_ = 0;
                              _loc14_ = true;
                              if(this._npc != null && this._npc.npcMC != null)
                              {
                                 if(!this._alerted)
                                 {
                                    this._alerted = true;
                                    QuestManager.playSound("ajq_phantomAlert");
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
                                 _loc22_ = this._seekActor.actorOffset;
                                 _loc2_ = this._npc.collisionPoint;
                                 _loc3_ = this._seekActor._actorData.actorPos.x + _loc22_.x - (x + _loc2_.x);
                                 _loc4_ = this._seekActor._actorData.actorPos.y + _loc22_.y - (y + _loc2_.y);
                                 _loc5_ = 90;
                                 _loc14_ = true;
                              }
                              else
                              {
                                 _loc3_ = 0;
                                 _loc4_ = 0;
                                 _loc5_ = 10;
                              }
                              if(this._npc != null && this._npc.npcMC != null)
                              {
                                 this._npc.npcMC.alertStatus(true);
                              }
                              break;
                           default:
                              _loc5_ = 10;
                              _loc3_ = this._targetX - x;
                              _loc4_ = this._targetY - y;
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
                        _loc17_ = 0;
                        _loc18_ = 0;
                        _loc19_ = 0;
                        _loc20_ = 0;
                        if(this._directionTimer > 0)
                        {
                           _loc15_ = NPCView.NPC_STATE_MOVE;
                           _loc17_ = this._directionOverride.x;
                           _loc18_ = this._directionOverride.y;
                           _loc20_ = Math.asin(_loc17_);
                           if(_loc18_ > 0)
                           {
                              _loc20_ = -(Math.PI + _loc20_);
                           }
                           _loc16_ = _loc20_ * 180 / Math.PI;
                           _loc19_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
                        }
                        else if(_loc3_ != 0 || _loc4_ != 0)
                        {
                           _loc19_ = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
                           if(_loc19_ != 0)
                           {
                              _loc17_ = _loc3_ / _loc19_;
                              _loc18_ = _loc4_ / _loc19_;
                           }
                           else
                           {
                              _loc17_ = 1;
                              _loc18_ = 0;
                           }
                           _loc20_ = Math.asin(_loc17_);
                           if(_loc4_ > 0)
                           {
                              _loc20_ = -(Math.PI + _loc20_);
                           }
                           _loc15_ = NPCView.NPC_STATE_MOVE;
                           _loc16_ = _loc20_ * 180 / Math.PI;
                        }
                        if(_loc19_ > _loc5_)
                        {
                           if(this._directionTimer <= 0)
                           {
                              switch(this._seekActive)
                              {
                                 case SEEKTYPE_PLAYER:
                                 case SEEKTYPE_PLANT:
                                    if(!this._inCollision && this._attackTimer <= 0 && this._npc.readyToAttack)
                                    {
                                       if(_loc19_ < ATTACKER_RANGE_WEAPON_PROJECTILE && _loc19_ > ATTACKER_RANGE_WEAPON_MIN_PROJECTILE)
                                       {
                                          this._attackPlayerWeaponItemDefId = this.getActiveWeapon(true);
                                          if(this._attackPlayerWeaponItemDefId != 0)
                                          {
                                             _loc15_ = NPCView.NPC_STATE_ATTACK;
                                             this._attackTimer = 1.5 + 4 * Math.random();
                                          }
                                       }
                                    }
                              }
                           }
                           _loc23_ = Math.abs(_loc17_);
                           _loc24_ = Math.abs(_loc18_);
                           _loc17_ *= param1 * this._seekVelocity;
                           _loc18_ *= param1 * this._seekVelocity;
                           if(Math.abs(_loc3_) - Math.abs(_loc17_) < 0)
                           {
                              _loc17_ = _loc3_;
                           }
                           if(Math.abs(_loc4_) - Math.abs(_loc18_) < 0)
                           {
                              _loc18_ = _loc4_;
                           }
                           if(this._inCollision)
                           {
                              this._inCollision = this.inCollision(x,y);
                           }
                           if(_loc14_ && !this._inCollision)
                           {
                              if(this.inCollision(x + _loc17_,y + _loc18_))
                              {
                                 _loc25_ = 0.1;
                                 _loc26_ = param1 * this._seekVelocity * (_loc18_ > 0 ? 1 : -1);
                                 if(this.inCollision(x,y + _loc26_))
                                 {
                                    _loc26_ = param1 * this._seekVelocity * (_loc17_ > 0 ? 1 : -1);
                                    if(this.inCollision(x + _loc26_,y))
                                    {
                                       _loc17_ = 0;
                                       _loc18_ = 0;
                                    }
                                    else
                                    {
                                       _loc17_ = _loc26_;
                                       _loc18_ = 0;
                                    }
                                 }
                                 else
                                 {
                                    _loc17_ = 0;
                                    _loc18_ = _loc26_;
                                 }
                              }
                           }
                           if(_loc17_ != 0 || _loc18_ != 0)
                           {
                              x += _loc17_;
                              y += _loc18_;
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
                              this._directionTimer -= param1;
                           }
                        }
                        else
                        {
                           switch(this._seekActive)
                           {
                              case SEEKTYPE_OFF:
                              case SEEKTYPE_PLAYER:
                              case SEEKTYPE_PLANT:
                                 _loc15_ = NPCView.NPC_STATE_IDLE;
                                 _loc16_ = 0;
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
                                          _loc15_ = NPCView.NPC_STATE_ATTACK;
                                          this._attackTimer = 1.5 + 4 * Math.random();
                                       }
                                    }
                                 }
                                 break;
                              case SEEKTYPE_PATH:
                                 this._directionTimer = 0;
                                 if(this._npcPath.points.length > 1)
                                 {
                                    if(this._npcPath.isClosedLoop)
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
                           }
                        }
                        if(_loc15_ == NPCView.NPC_STATE_ATTACK)
                        {
                           this.handleAttackPlayer(this._attackPlayerWeaponItemDefId,this._attackPlayerWeaponColor,AvatarManager.playerSfsUserId);
                           QuestXtCommManager.sendAttackPlayer(this._actorId,this._attackPlayerSfsId,this._attackPlayerWeaponItemDefId,this._attackPlayerWeaponColor);
                        }
                        else
                        {
                           this._npc.setNpcState(_loc15_,_loc16_);
                        }
                     }
                  }
                  break;
               case QUEST_ACTOR_TYPE_PLANT:
                  if(this._npc != null && this._npc.npcMC != null && Boolean(this._npc.npcMC.readyForAttack))
                  {
                     if(this._attackTimer > 0)
                     {
                        this._attackTimer -= param1;
                     }
                     else
                     {
                        _loc27_ = this._npc.collisionPointAttack;
                        _loc28_ = QuestManager.getNearestActivePhantom(this._actorData.actorPos.x + _loc27_.x,this._actorData.actorPos.y + _loc27_.y,this._npc.collisionRadiusAttack,this._npc.npcDef.level - 1);
                        if(_loc28_)
                        {
                           QuestXtCommManager.sendEatPhantom(this._actorId,_loc28_._actorId,_loc28_.x,_loc28_.y);
                           QuestManager.handleEatPhantom(this._actorId,_loc28_._actorId);
                        }
                        this._attackTimer = 0;
                     }
                  }
            }
         }
      }
      
      private function updateAlertLP() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(AvatarManager.playerAvatarWorldView != null)
         {
            _loc1_ = AvatarManager.playerAvatarWorldView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - x;
            _loc2_ = AvatarManager.playerAvatarWorldView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - y;
            _loc3_ = _loc1_ * _loc1_ + _loc2_ * _loc2_;
            _loc4_ = 700 * 700;
            _loc5_ = 1;
            if(_loc3_ > _loc4_)
            {
               _loc5_ = 0;
            }
            else if(_loc3_ >= 0)
            {
               _loc5_ = 1 - _loc3_ / _loc4_;
            }
            if(_loc5_ > 0)
            {
               if(this._alertLP == null)
               {
                  this._alertLP = QuestManager.playLoopingSound("ajq_phntmsquidlp");
               }
               QuestManager.setSoundLevel(this._alertLP,_loc5_,this);
            }
            else if(this._alertLP != null)
            {
               QuestManager.stopLoopingSound(this._alertLP);
               this._alertLP = null;
            }
         }
      }
      
      public function setPlantEats(param1:QuestActor) : void
      {
         var _loc2_:Number = 0;
         if(param1 != null)
         {
            _loc2_ = this.getAngleToTarget(param1.x,param1.y);
         }
         this._npc.setNpcState(NPCView.NPC_STATE_ATTACK,_loc2_);
         this._npc.npcMC.readyForAttack = false;
      }
      
      private function inCollision(param1:int, param2:int) : Boolean
      {
         var _loc3_:uint = RoomManagerWorld.instance.collisionTestGrid(param1,param2);
         return _loc3_ != RoomGrid.GRID_CELL_OPEN && _loc3_ != RoomGrid.GRID_CELL_PHANTOM;
      }
      
      public function checkPlantRadius() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Point = null;
         if(this._npc != null && this._requestSeekTimer <= 0)
         {
            _loc1_ = 250;
            _loc2_ = this._npc.collisionZapPoint;
            this._seekActor = QuestManager.getNearestPlant(this._actorData.actorPos.x + _loc2_.x,this._actorData.actorPos.y + _loc2_.y,_loc1_,this._npc.npcDef.level);
            if(this._seekActive != SEEKTYPE_PLANT)
            {
               if(this._seekActor != null)
               {
                  QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_PLANT);
                  this._requestSeekTimer = 1.5;
               }
            }
            else if(this._seekActor == null)
            {
               QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_OFF);
            }
            else
            {
               this._requestSeekTimer = 1.5;
            }
         }
      }
      
      public function onAttackRadius() : void
      {
         var _loc1_:AvatarInfo = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(AvatarManager.playerAvatarWorldView != null && this._visible && (this._npc == null || this._npc.isDead == false))
         {
            _loc1_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
            if(QuestManager._playerInStealthVolume == false && _loc1_.questHealthPercentage > 0)
            {
               _loc2_ = this.distanceSqToPlayer();
               if(this._npc != null && this._npc.npcMC != null)
               {
                  this._npc.npcMC.setDistanceToTarget(_loc2_);
               }
               if(this._seekActive == SEEKTYPE_PLAYER)
               {
                  _loc3_ = this._actorDefaultOuterRadius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                  if(_loc2_ > _loc3_ * _loc3_)
                  {
                     this._requestSeekTimer = 1;
                     this._seekActive = this._npcPath != null ? SEEKTYPE_PATH : SEEKTYPE_OFF;
                     if(this._npc != null && this._npc.npcMC != null)
                     {
                        this._npc.npcMC.alertStatus(false);
                        this._alerted = false;
                        if(this._alertLP)
                        {
                           QuestManager.stopLoopingSound(this._alertLP);
                           this._alertLP = null;
                        }
                     }
                     QuestXtCommManager.questActorSeek(this._actorId,this._seekActive);
                  }
               }
               else if(this._requestSeekTimer <= 0)
               {
                  this._requestSeekTimer = 0.5;
                  _loc3_ = this._actorDefaultInnerRadius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                  if(_loc2_ < _loc3_ * _loc3_)
                  {
                     QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_PLAYER);
                  }
                  else if(!QuestManager.getNearestActorPathInGroupToPlayerInRange(this))
                  {
                     if(this._seekActive != SEEKTYPE_OFF)
                     {
                        QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_OFF);
                     }
                  }
                  else if(this._npcPath != null && this._seekActive != SEEKTYPE_PATH)
                  {
                     QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_PATH);
                  }
               }
            }
            else if(this._npcPath != null)
            {
               if(!QuestManager.getNearestActorPathInGroupToPlayerInRange(this))
               {
                  if(this._seekActive != SEEKTYPE_OFF)
                  {
                     this._requestSeekTimer = 0.5;
                     QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_OFF);
                  }
               }
               else if(this._seekActive == SEEKTYPE_PLAYER || this._seekActive == SEEKTYPE_OFF && this._requestSeekTimer <= 0)
               {
                  this._requestSeekTimer = 0.5;
                  QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_PATH);
               }
            }
            else if(this._seekActive != SEEKTYPE_OFF)
            {
               this._requestSeekTimer = 0.5;
               QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_OFF);
            }
         }
      }
      
      public function meleeHitTest(param1:int, param2:Point, param3:int) : Boolean
      {
         if(this._lastMeleeID != param1 && (this._npc == null || this._npc.isDead == false))
         {
            if(this.hitTest(param2,param3))
            {
               this._lastMeleeID = param1;
               return true;
            }
         }
         return false;
      }
      
      public function hitTest(param1:Point, param2:int) : Boolean
      {
         var _loc3_:Point = null;
         if(this._visible && (this._npc == null || this._npc.isDying == false))
         {
            switch(this._actorData.type)
            {
               case QUEST_ACTOR_TYPE_ATTACKER:
               case QUEST_ACTOR_TYPE_FACTORY:
                  _loc3_ = this._npc.collisionPoint;
                  if(Collision.circleHitCircle(param1,param2,new Point(x + _loc3_.x,y + _loc3_.y),this._npc.collisionRadius))
                  {
                     return true;
                  }
                  break;
               case QUEST_ACTOR_TYPE_PLANT:
                  if(this.plantTargettable())
                  {
                     _loc3_ = this._npc.collisionPoint;
                     if(Collision.circleHitCircle(param1,param2,new Point(x + _loc3_.x,y + _loc3_.y),this._npc.collisionRadius))
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
         if(this._mh)
         {
            this._clickIcon = param1;
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
         var _loc1_:Boolean = false;
         var _loc2_:Number = NaN;
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         var _loc6_:QuestPlayerData = null;
         var _loc7_:String = null;
         if(AvatarManager.playerAvatarWorldView != null && this._visible && (this._npc == null || this._npc.isDead == false))
         {
            _loc1_ = false;
            if(this._volumes != null)
            {
               switch(this._actorData.type)
               {
                  case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                  case QUEST_ACTOR_TYPE_CIRCLETRIGGER:
                  case QUEST_ACTOR_TYPE_VOLUMETRIGGER:
                     _loc5_ = 0;
                     while(_loc5_ < this._volumes.length)
                     {
                        if(RoomManagerWorld.instance.volumeManager.testPointInVolume(new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y),this._volumes[_loc5_]))
                        {
                           _loc1_ = true;
                           break;
                        }
                        _loc5_++;
                     }
               }
            }
            else
            {
               _loc3_ = new Point(x,y);
               switch(this._actorData.type)
               {
                  case QUEST_ACTOR_TYPE_FACTORY:
                     _loc2_ = this._actorDefaultOuterRadius;
                     break;
                  case QUEST_ACTOR_TYPE_PLACED_TREASURE:
                     _loc2_ = this._actorDefaultInnerRadius;
                     break;
                  case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
                     _loc2_ = DROPPED_TREASURE_RADIUS;
                     break;
                  case QUEST_ACTOR_TYPE_NPC:
                     if(this._npc != null)
                     {
                        _loc4_ = this._npc.collisionPoint;
                        _loc3_.x += _loc4_.x;
                        _loc3_.y += _loc4_.y;
                     }
                     _loc2_ = this._actorDefaultOuterRadius;
                     break;
                  case QUEST_ACTOR_TYPE_SPEAKER:
                     _loc2_ = this._actorDefaultOuterRadius;
                     break;
                  default:
                     if(this._npc != null)
                     {
                        _loc4_ = this._npc.collisionPoint;
                        _loc3_.x += _loc4_.x;
                        _loc3_.y += _loc4_.y;
                        _loc2_ = this._npc.collisionRadius;
                     }
                     else
                     {
                        _loc2_ = this._actorDefaultInnerRadius;
                     }
               }
               if(_loc2_ > 0)
               {
                  _loc1_ = Collision.circleHitCircle(_loc3_,_loc2_,new Point(AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY),QuestManager.QUEST_PLAYER_AVATAR_RADIUS * 1.5);
               }
            }
            if(_loc1_)
            {
               if(this._playerSeekingActor)
               {
                  if(this._npc)
                  {
                     switch(this._actorData.type)
                     {
                        case QUEST_ACTOR_TYPE_FACTORY:
                           _loc4_ = this._npc.collisionPoint;
                           _loc3_.x += _loc4_.x;
                           _loc3_.y += _loc4_.y;
                           _loc2_ = this._npc.collisionRadius;
                           if(!Collision.circleHitCircle(_loc3_,_loc2_,new Point(AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY),QuestManager.QUEST_PLAYER_AVATAR_RADIUS * 1.5))
                           {
                              break;
                           }
                        case QUEST_ACTOR_TYPE_ATTACKER:
                           if(_loc3_)
                           {
                              QuestManager.playerLaunchWeapon(_loc3_,false);
                           }
                           this._playerSeekingActor = false;
                           gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
                           RoomManagerWorld.instance.forceStopMovement();
                           AvatarManager.playerAvatarWorldView.faceAnim(_loc3_.x - AvatarManager.playerAvatarWorldView.avatarPos.x,_loc3_.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
                     }
                  }
               }
               if(this._inRadius != _loc1_ || this._actorData.type == QUEST_ACTOR_TYPE_ITEM && this._clickIcon == null || this._actorData.type == QUEST_ACTOR_TYPE_GROUP_ITEM && this._clickIcon == null || this._actorData.type == QUEST_ACTOR_TYPE_DROPPED_TREASURE && this._clickIcon == null || this._actorData.type == QUEST_ACTOR_TYPE_PLACED_TREASURE && this._clickIcon == null || this._actorData.type == QUEST_ACTOR_TYPE_NPC && this._clickIcon == null && this._mh == null)
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
                           this._clickIcon = new (getDefinitionByName("QuestPickupIcon") as Class)();
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
                           this._clickIcon = new (getDefinitionByName("QuestPickupIcon") as Class)();
                           this._clickIcon.x = x + ITEM_CLICK_OFFSET_X;
                           this._clickIcon.y = y + ITEM_CLICK_OFFSET_Y;
                           QuestManager._layerManager.room_orbs.addChild(this._clickIcon);
                           QuestManager.playSound("ajq_popup");
                           this._clickIcon.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Click,false,0,true);
                           this._clickIcon.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOverEvt_Click,false,0,true);
                           this._clickIcon.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOutEvt_Click,false,0,true);
                        }
                        break;
                     case QUEST_ACTOR_TYPE_NPC:
                        if(this._npc)
                        {
                           if(this._requireClick)
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
                        QuestXtCommManager.questActorTriggered(this._actorId);
                        break;
                     case QUEST_ACTOR_TYPE_VOLUMEBLOCKER:
                        break;
                     case QUEST_ACTOR_TYPE_DROPPED_TREASURE:
                        if(this._actorData.subType == GIVE_GEMS || this._actorData.subType == GIVE_ORBS)
                        {
                           if(this._npc != null && this._npc.npcState == NPCView.NPC_STATE_TREASURE_APPEAR)
                           {
                              _loc6_ = QuestManager.getQuestPlayerData(AvatarManager.playerSfsUserId);
                              if(_loc6_)
                              {
                                 _loc7_ = "+" + this._actorData.gems;
                                 _loc6_.playStatusText(_loc7_);
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
               if(this._inRadius != _loc1_)
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
                     case QUEST_ACTOR_TYPE_VOLUME_HEALTH:
                        QuestXtCommManager.questActorUntriggered(this._actorId);
                        break;
                     case QUEST_ACTOR_TYPE_FACTORY:
                        QuestXtCommManager.questActorUntriggered(this._actorId);
                  }
               }
               this.removeClickIcon();
            }
            this._inRadius = _loc1_;
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
            if(this._mh)
            {
               this._mh.destroy();
               this._mh = null;
            }
         }
         if(this._clickIcon)
         {
            if(this._clickIcon.parent)
            {
               this._clickIcon.parent.removeChild(this._clickIcon);
            }
            this._clickIcon = null;
         }
      }
      
      public function handleMouseDown(param1:Point) : Boolean
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_FACTORY:
            case QUEST_ACTOR_TYPE_ATTACKER:
               if(AvatarManager.playerAvatarWorldView != null && this._npc != null && this._npc.isDead == false)
               {
                  if(this._visible)
                  {
                     _loc2_ = this._npc.collisionPoint;
                     _loc2_.x += x;
                     _loc2_.y += y;
                     _loc3_ = (param1.x - _loc2_.x) * (param1.x - _loc2_.x) + (param1.y - _loc2_.y) * (param1.y - _loc2_.y);
                     if(_loc3_ < this._npc.collisionRadius * this._npc.collisionRadius)
                     {
                        _loc4_ = AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX - _loc2_.x;
                        _loc5_ = AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY - _loc2_.y;
                        _loc6_ = this._npc.collisionRadius + 1.75 * QuestManager.QUEST_PLAYER_AVATAR_RADIUS;
                        if(_loc4_ * _loc4_ + _loc5_ * _loc5_ <= _loc6_ * _loc6_)
                        {
                           QuestManager.playerLaunchWeapon(_loc2_,false);
                           this._playerSeekingActor = false;
                           gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
                           return true;
                        }
                     }
                  }
               }
         }
         return false;
      }
      
      private function onMouseDownEvt_DroppedTreasure(param1:MouseEvent) : void
      {
         var _loc2_:DenItem = null;
         var _loc3_:Item = null;
         if(this._visible)
         {
            if(this._npc != null && this._npc.npcStateComplete)
            {
               this._npc.setNpcState(NPCView.NPC_STATE_TREASURE_OPEN);
               removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_DroppedTreasure);
               switch(this._actorData.subType)
               {
                  case GIVE_DEN_ITEM:
                     _loc2_ = new DenItem();
                     _loc2_.initShopItem(this._actorData.denDefId,0);
                     this._prizePopup = new GiftPopup();
                     this._prizePopup.init(QuestManager._layerManager.gui,_loc2_.icon,_loc2_.name,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_DEN_ACC,this.keptItem,this.rejectedItem,this.destroyPrizePopup);
                     break;
                  case GIVE_ACCESSORY:
                     this._prizePopup = new GiftPopup();
                     _loc3_ = new Item();
                     _loc3_.init(this._actorData.itemDefId,0,this._actorData.itemData,0,0,true);
                     this._prizePopup.init(QuestManager._layerManager.gui,_loc3_.largeIcon,_loc3_.name,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_CLOTHING,this.keptItem,this.rejectedItem,this.destroyPrizePopup);
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
               param1.stopPropagation();
            }
         }
      }
      
      private function onMediaHelperItemReceived(param1:MovieClip) : void
      {
         this._mediaObject = param1;
         this._mediaObject.setPlace(1);
         this._mediaObject.x = 0;
         this._mediaObject.y = 0;
         addChild(this._mediaObject);
         QuestManager._layerManager.room_avatars.addChild(this);
         this._mh.destroy();
         this._mh = null;
         this._loadingComplete = true;
      }
      
      private function onMediaHelperOrbIconReceived(param1:MovieClip) : void
      {
         this._prizePopup = new GiftPopup();
         this._prizePopup.init(QuestManager._layerManager.gui,param1,this._actorData.gems + " Orbs",GiftPopup.POPUP_TYPE_PRIZE,GiftPopup.GIFT_TYPE_ORBS,this.keptItem,this.keptItem,this.destroyPrizePopup,false,GiftPopup.BUTTONS_TYPE_OK);
         this._mh.destroy();
         this._mh = null;
      }
      
      private function onMediaHelperGemIconReceived(param1:MovieClip) : void
      {
         this._prizePopup = new GiftPopup();
         this._prizePopup.init(QuestManager._layerManager.gui,param1,this._actorData.gems + " Gems",GiftPopup.POPUP_TYPE_PRIZE,GiftPopup.GIFT_TYPE_GEMS,this.keptItem,this.keptItem,this.destroyPrizePopup,false,GiftPopup.BUTTONS_TYPE_OK);
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
         if(this._prizePopup)
         {
            this._prizePopup.destroy();
            this._prizePopup = null;
         }
      }
      
      private function onMouseDownEvt_Attack(param1:MouseEvent) : void
      {
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
         this._playerSeekingActor = false;
         gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_CancelAttack);
      }
      
      private function onMouseDownEvt_Click(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
               QuestXtCommManager.questPickUpItem(this._actorId);
               this._updatePositionTimer = 1;
               break;
            default:
               QuestXtCommManager.questActorTriggered(this._actorId);
         }
         this.removeClickIcon();
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
         var _loc1_:MovieClip = null;
         this._npc.x = 0;
         this._npc.y = 0;
         addChild(this._npc);
         switch(this._actorData.type)
         {
            case QuestActor.QUEST_ACTOR_TYPE_FACTORY:
            case QuestActor.QUEST_ACTOR_TYPE_ATTACKER:
               this._npc.updateHealthBar(this._actorData.healthPercent,0,false);
               if(this._spawnedFromPos != null)
               {
                  this._updatePositionTimer = 1;
                  this._npc.npcMC.appear(180,this._spawnedFromPos);
               }
               else if(this._actorData.respawned)
               {
                  this._npc.setNpcState(NPCView.NPC_STATE_IDLE);
               }
               if(this._actorData.type == QuestActor.QUEST_ACTOR_TYPE_ATTACKER && this._npc.npcMC.hasOwnProperty("setVision"))
               {
                  this._npc.npcMC.setVision(this._actorDefaultInnerRadius);
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
               this._npc.updateHealthBar(this._actorData.healthPercent,0,false);
               if(this._actorData["plantEaten"] != null && Boolean(this._actorData.plantEaten))
               {
                  this.setPlantEats(null);
               }
               else
               {
                  this._npc.npcMC.appear(180,this._spawnedFromPos);
               }
               break;
            case QUEST_ACTOR_TYPE_NPC:
               mouseEnabled = false;
               mouseChildren = false;
         }
         this._npc.setNpcState(NPCView.NPC_STATE_IDLE,0);
         this._loadingComplete = true;
         if(this._actorData.pendingSwfStateName != "")
         {
            this.setSwfState(this._actorData.pendingSwfStateName);
            this._actorData.pendingSwfStateName = "";
         }
      }
      
      public function getActiveWeapon(param1:Boolean) : int
      {
         var _loc2_:Object = QuestManager.getNPCDef(this._actorData.defId);
         var _loc3_:int = 0;
         _loc3_ = this.evaluateWeapon(param1,_loc2_.backItemRefId,_loc2_.backColor,_loc3_);
         _loc3_ = this.evaluateWeapon(param1,_loc2_.eyesItemRefId,_loc2_.eyesColor,_loc3_);
         _loc3_ = this.evaluateWeapon(param1,_loc2_.legItemRefId,_loc2_.legColor,_loc3_);
         _loc3_ = this.evaluateWeapon(param1,_loc2_.headItemRefId,_loc2_.headColor,_loc3_);
         _loc3_ = this.evaluateWeapon(param1,_loc2_.neckItemRefId,_loc2_.neckColor,_loc3_);
         return this.evaluateWeapon(param1,_loc2_.tailItemRefId,_loc2_.tailColor,_loc3_);
      }
      
      public function evaluateWeapon(param1:Boolean, param2:int, param3:Number, param4:int) : int
      {
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         if(param2 != 0)
         {
            _loc5_ = ItemXtCommManager.getItemDef(param2);
            if((Boolean(_loc5_)) && _loc5_.attackMediaRefId != 0)
            {
               if(param1 && _loc5_.combatType == QuestManager.QUEST_WEAPON_TYPE_PROJECTILE || param1 == false && (_loc5_.combatType == QuestManager.QUEST_WEAPON_TYPE_MELEE || _loc5_.combatType == QuestManager.QUEST_WEAPON_TYPE_BOMB))
               {
                  if(param4 != 0)
                  {
                     _loc6_ = ItemXtCommManager.getItemDef(param4);
                     if(_loc5_.damage > _loc6_.damage)
                     {
                        this._attackPlayerWeaponColor = param3;
                        param4 = param2;
                     }
                  }
                  else
                  {
                     this._attackPlayerWeaponColor = param3;
                     param4 = param2;
                  }
               }
            }
         }
         return param4;
      }
      
      public function handleHit(param1:Boolean, param2:int) : void
      {
         if(this._npc != null && this._npc.isDying == false)
         {
            if(param1)
            {
               QuestXtCommManager.questActorAttacked(this._actorId,param2);
               if(this._actorData.type == QUEST_ACTOR_TYPE_ATTACKER && this._seekActive < SEEKTYPE_PLAYER)
               {
                  this._requestSeekTimer = 1.5;
                  QuestXtCommManager.questActorSeek(this._actorId,SEEKTYPE_PLAYER);
               }
            }
            this._npc.setNpcState(NPCView.NPC_STATE_RECOIL,0);
         }
      }
      
      public function getAngleToTarget(param1:Number, param2:Number) : Number
      {
         var _loc3_:Point = this._npc.collisionPoint;
         var _loc4_:Number = param1 - (x + _loc3_.x);
         var _loc5_:Number = param2 - (y + _loc3_.y);
         if(_loc4_ == 0 && _loc5_ == 0)
         {
            _loc4_ = 1;
         }
         var _loc6_:Number = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
         if(_loc6_ != 0)
         {
            _loc4_ /= _loc6_;
            _loc5_ /= _loc6_;
         }
         else
         {
            _loc4_ = 1;
            _loc5_ = 0;
         }
         var _loc7_:Number = Math.asin(_loc4_);
         if(_loc5_ > 0)
         {
            _loc7_ = -(Math.PI + _loc7_);
         }
         return _loc7_ * 180 / Math.PI;
      }
      
      public function handleAttackPlayer(param1:int, param2:uint, param3:int) : void
      {
         var _loc4_:Number = NaN;
         if(this._npc != null && AvatarManager.avatarViewList[param3] != null)
         {
            this._attackPlayerSfsId = param3;
            this._attackPlayerWeaponItemDefId = param1;
            this._attackPlayerWeaponColor = param2;
            _loc4_ = this.getAngleToTarget(AvatarManager.avatarViewList[param3].avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.avatarViewList[param3].avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
            this._npc.setNpcState(NPCView.NPC_STATE_ATTACK,_loc4_);
         }
      }
      
      public function healthUpdate(param1:int, param2:int, param3:Boolean) : void
      {
         if(this._npc != null)
         {
            this._npc.updateHealthBar(param1,param2,param3);
         }
      }
      
      public function handleDeath(param1:int) : Boolean
      {
         if(this._npc != null)
         {
            this._npc.updateHealthBar(0,param1,false);
         }
         if(this._alertLP)
         {
            QuestManager.stopLoopingSound(this._alertLP);
            this._alertLP = null;
         }
         switch(this._actorData.type)
         {
            case QUEST_ACTOR_TYPE_FACTORY:
            case QUEST_ACTOR_TYPE_ATTACKER:
               removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownEvt_Attack);
               if(this._npc != null)
               {
                  this._npc.setNpcState(NPCView.NPC_STATE_DEATH,0);
                  return false;
               }
         }
         return true;
      }
      
      public function handleTriggerTreasure(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:DenItem = null;
         var _loc5_:Item = null;
         switch(param1)
         {
            case GIVE_DEN_ITEM:
               _loc4_ = new DenItem();
               _loc4_.initShopItem(param2,0);
               this._prizePopup = new GiftPopup();
               this._prizePopup.init(QuestManager._layerManager.gui,_loc4_.icon,_loc4_.name,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_DEN_ACC,this.keptPlacedTreasure,this.rejectedPlacedTreasure,this.destroyPlacedTreasurePopup,false,GiftPopup.BUTTONS_TYPE_KEEP_DISCARD);
               break;
            case GIVE_ACCESSORY:
               this._prizePopup = new GiftPopup();
               _loc5_ = new Item();
               _loc5_.init(param2,0,param3,0,0,true);
               this._prizePopup.init(QuestManager._layerManager.gui,_loc5_.largeIcon,_loc5_.name,GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_CLOTHING,this.keptPlacedTreasure,this.rejectedPlacedTreasure,this.destroyPlacedTreasurePopup,false,GiftPopup.BUTTONS_TYPE_KEEP_DISCARD);
               break;
            case GIVE_GEMS:
               this._prizeAmount = param2;
               this._mh = new MediaHelper();
               this._mh.init(GEMS_MEDIA_ID,this.onMediaHelperGemIconDroppedTreasureReceived);
               break;
            case GIVE_ORBS:
               this._prizeAmount = param2;
               this._mh = new MediaHelper();
               this._mh.init(ORBS_MEDIA_ID,this.onMediaHelperOrbIconDroppedTreasureReceived);
         }
      }
      
      private function onMediaHelperOrbIconDroppedTreasureReceived(param1:MovieClip) : void
      {
         this._prizePopup = new GiftPopup();
         this._prizePopup.init(QuestManager._layerManager.gui,param1,this._prizeAmount + " Orbs",GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_ORBS,this.keptDroppedTreasure,this.keptDroppedTreasure,this.destroyDroppedTreasurePopup,false,GiftPopup.BUTTONS_TYPE_OK);
         this._mh.destroy();
         this._mh = null;
      }
      
      private function onMediaHelperGemIconDroppedTreasureReceived(param1:MovieClip) : void
      {
         this._prizePopup = new GiftPopup();
         this._prizePopup.init(QuestManager._layerManager.gui,param1,this._prizeAmount + " Gems",GiftPopup.POPUP_TYPE_TREASURE,GiftPopup.GIFT_TYPE_GEMS,this.keptDroppedTreasure,this.keptDroppedTreasure,this.destroyDroppedTreasurePopup,false,GiftPopup.BUTTONS_TYPE_OK);
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
         if(this._prizePopup)
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
         if(this._prizePopup)
         {
            this._prizePopup.destroy();
            this._prizePopup = null;
         }
      }
      
      public function setSwfState(param1:String) : void
      {
         if(this._npc != null && this._loadingComplete)
         {
            this._updatePositionTimer = this._npc.setSwfState(param1);
            if(this._updatePositionTimer > 0)
            {
               this._spawnedFromPos = new Point(x,y);
            }
         }
         else
         {
            this._actorData.pendingSwfStateName = param1;
         }
      }
      
      public function setActorText(param1:String) : void
      {
         if(this._npc != null)
         {
            this._npc.playHitText(param1);
         }
      }
      
      public function setChatBalloonText(param1:String) : void
      {
         var attachmentPoint:Point = null;
         var txt:String = param1;
         if(this._chatBalloon)
         {
            this._chatBalloon.setText(txt);
         }
         else
         {
            this._chatBalloon = new (getDefinitionByName("ChatBalloonAsset") as Class)();
            this._chatBalloon.init(0);
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
      
      public function setPath(param1:String) : void
      {
         if(param1 != null)
         {
            this._npcPath = RoomManagerWorld.instance.findPathByName(param1);
            if(this._npcPath != null)
            {
               this._pathDirectionForward = true;
               this._pathNode = Math.min(this._npcPath.points.length - 1,1);
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
      
      public function handlePhantomZap(param1:int) : void
      {
         var _loc2_:Number = NaN;
         if(this._npc != null && this._npc.npcMC != null && this._npc.npcState != NPCView.NPC_STATE_DEATH)
         {
            _loc2_ = this.getAngleToTarget(AvatarManager.avatarViewList[param1].avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,AvatarManager.avatarViewList[param1].avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
            this._npc.npcMC.zap(_loc2_);
         }
      }
      
      public function testPointInActorVolumes(param1:Point) : Boolean
      {
         var _loc2_:int = 0;
         if(this._visible && this._volumes != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this._volumes.length)
            {
               if(RoomManagerWorld.instance.volumeManager.testPointInVolume(param1,this._volumes[_loc2_]))
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
         var _loc1_:Point = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._npc != null && AvatarManager.playerAvatarWorldView != null)
         {
            _loc1_ = this._npc.collisionZapPoint;
            _loc1_.x += x;
            _loc1_.y += y;
            _loc2_ = _loc1_.x - (AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX);
            _loc3_ = _loc1_.y - (AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
            return _loc2_ * _loc2_ + _loc3_ * _loc3_;
         }
         return -1;
      }
      
      public function pathToPlayerInRange() : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:Number = this.distanceSqToPlayer();
         if(_loc1_ != -1 && _loc1_ < PHANTOM_OUT_OF_RANGE_SQ)
         {
            return true;
         }
         if(this._npc != null && AvatarManager.playerAvatarWorldView != null && this._npcPath != null)
         {
            _loc2_ = -1;
            _loc3_ = 0;
            while(_loc3_ < this._npcPath.points.length)
            {
               _loc4_ = this._npcPath.points[_loc3_].x - (AvatarManager.playerAvatarWorldView.avatarPos.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX);
               _loc5_ = this._npcPath.points[_loc3_].y - (AvatarManager.playerAvatarWorldView.avatarPos.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
               _loc1_ = _loc4_ * _loc4_ + _loc5_ * _loc5_;
               if(_loc2_ == -1 || _loc1_ < _loc2_)
               {
                  _loc2_ = _loc1_;
               }
               if(_loc2_ < PHANTOM_OUT_OF_RANGE_SQ)
               {
                  return true;
               }
               _loc3_++;
            }
         }
         return false;
      }
   }
}

