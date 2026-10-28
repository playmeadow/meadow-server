package quest
{
   import avatar.AvatarManager;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   
   public class QuestProjectile extends Sprite
   {
      
      private static const PROJECTILE_VELOCITY:int = 400;
      
      private static const PROJECTILE_RANGE:int = 600;
      
      private static const PROJECTILE_RADIUS:int = 10;
      
      private var _weaponItem:Object;
      
      private var _npc:QuestActor;
      
      private var _mediaHelperObj:MediaHelper;
      
      private var _strikeMC:MovieClip;
      
      private var _projectileMC:MovieClip;
      
      private var _aimX:Number;
      
      private var _aimY:Number;
      
      private var _distanceTravelled:Number;
      
      private var _timer:Number;
      
      private var _angle:Number;
      
      private var _collisionOffset:Point;
      
      private var _color:uint;
      
      private var _localPlayerLaunched:Boolean;
      
      private var _healProjectile:Boolean;
      
      public function QuestProjectile()
      {
         super();
         this._distanceTravelled = 0;
         this._timer = 0;
      }
      
      public function get angle() : Number
      {
         return this._angle;
      }
      
      public function destroy() : void
      {
         if(this._strikeMC != null && this._strikeMC.parent != null)
         {
            this._strikeMC.parent.removeChild(this._strikeMC);
         }
         if(this._mediaHelperObj != null)
         {
            this._mediaHelperObj.destroy();
            this._mediaHelperObj = null;
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._strikeMC.weapon.rotation = 0;
         QuestManager.recycle(this._weaponItem.attackMediaRefId,this);
      }
      
      public function heartbeat(param1:Number) : Boolean
      {
         var _loc2_:QuestActor = null;
         var _loc3_:Object = null;
         var _loc4_:AvatarWorldView = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(this._timer == 0)
         {
            if(this._projectileMC != null)
            {
               x += this._aimX * PROJECTILE_VELOCITY * param1;
               y += this._aimY * PROJECTILE_VELOCITY * param1;
               this._distanceTravelled += PROJECTILE_VELOCITY * param1;
               if(this._distanceTravelled > PROJECTILE_RANGE || RoomManagerWorld.instance.collisionTestGrid(x + this._collisionOffset.x,y + this._collisionOffset.y) == 1)
               {
                  this.handleHit(true,null,null,false);
               }
               else if(this._npc != null || this._healProjectile)
               {
                  for(_loc3_ in AvatarManager.avatarViewList)
                  {
                     _loc4_ = AvatarManager.avatarViewList[_loc3_];
                     if(_loc4_ != null)
                     {
                        _loc5_ = x + this._collisionOffset.x - (_loc4_.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX);
                        _loc6_ = y + this._collisionOffset.y - (_loc4_.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
                        if(_loc5_ * _loc5_ + _loc6_ * _loc6_ < (PROJECTILE_RADIUS + QuestManager.QUEST_PLAYER_AVATAR_RADIUS) * (PROJECTILE_RADIUS + QuestManager.QUEST_PLAYER_AVATAR_RADIUS))
                        {
                           this.handleHit(false,null,_loc4_,this._localPlayerLaunched);
                        }
                     }
                  }
                  _loc2_ = QuestManager.projectileRadiusCheck(x + this._collisionOffset.x,y + this._collisionOffset.y,PROJECTILE_RADIUS,true);
                  if(_loc2_ != null)
                  {
                     this.handleHit(false,_loc2_,null,true);
                  }
               }
               else
               {
                  _loc2_ = QuestManager.projectileRadiusCheck(x + this._collisionOffset.x,y + this._collisionOffset.y,PROJECTILE_RADIUS,false);
                  if(_loc2_ != null)
                  {
                     this.handleHit(false,_loc2_,null,this._localPlayerLaunched);
                  }
               }
            }
         }
         else
         {
            this._timer -= param1;
            if(this._timer <= 0)
            {
               this._timer = 0;
               return true;
            }
         }
         return false;
      }
      
      public function handleHit(param1:Boolean, param2:QuestActor, param3:AvatarWorldView, param4:Boolean) : void
      {
         var _loc5_:Point = null;
         this._projectileMC.visible = false;
         this._timer = 2;
         if(param1 == false)
         {
            if(param2 != null)
            {
               param2.handleHit(param4,this._weaponItem.defId);
               _loc5_ = param2.actorOffset;
               x = param2.x + _loc5_.x;
               y = param2.y + _loc5_.y;
            }
            else
            {
               if(!this._healProjectile)
               {
                  if(param3 == AvatarManager.playerAvatarWorldView)
                  {
                     QuestXtCommManager.questActorAttacked("",this._weaponItem.defId);
                  }
               }
               else if(this._localPlayerLaunched)
               {
                  QuestXtCommManager.questPlayerHeal(this._weaponItem.defId,param3.avatarData.sfsUserId);
               }
               _loc5_ = new Point(QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
               x = _loc5_.x + param3.x;
               y = _loc5_.y + param3.y;
            }
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onEffectLoaded);
         }
      }
      
      private function setAngle() : void
      {
         var _loc1_:Number = this._aimX - x;
         var _loc2_:Number = this._aimY - y;
         if(_loc1_ == 0 && _loc2_ == 0)
         {
            _loc1_ = 1;
         }
         var _loc3_:Number = Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_);
         this._aimX = _loc1_ / _loc3_;
         this._aimY = _loc2_ / _loc3_;
         var _loc4_:Number = Math.asin(this._aimX);
         if(this._aimY > 0)
         {
            _loc4_ = -(Math.PI + _loc4_);
         }
         this._angle = _loc4_ * 180 / Math.PI;
      }
      
      public function relaunch(param1:int, param2:uint, param3:Sprite, param4:int, param5:int, param6:QuestActor, param7:AvatarView) : Boolean
      {
         var _loc8_:Point = null;
         this._color = param2;
         this._aimX = param4;
         this._aimY = param5;
         this._healProjectile = false;
         this._distanceTravelled = 0;
         if(param6 == null)
         {
            if(param7)
            {
               this._localPlayerLaunched = param7.userId == AvatarManager.playerSfsUserId;
               if(this._localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestProjectileLaunch(this._weaponItem.defId,param4,param5,"",param7.userId,param2);
               }
               this._healProjectile = this._weaponItem.attack < 0;
               x = this._strikeMC.x = param7.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX;
               y = this._strikeMC.y = param7.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY;
               this.setAngle();
               this._strikeMC.strike(this._angle);
               param3.addChild(this._strikeMC);
               this._projectileMC.visible = true;
               this._projectileMC.projectile(this._angle);
            }
         }
         else
         {
            this._localPlayerLaunched = false;
            _loc8_ = param6.actorOffset;
            this._npc = param6;
            x = this._strikeMC.x = this._npc.x + _loc8_.x;
            y = this._strikeMC.x = this._npc.y + _loc8_.y;
            this.setAngle();
            this._strikeMC.strike(this._angle);
            param3.addChild(this._strikeMC);
            this._projectileMC.visible = true;
            this._projectileMC.projectile(this._angle);
         }
         param3.addChild(this);
         return true;
      }
      
      public function launch(param1:int, param2:uint, param3:Sprite, param4:int, param5:int, param6:QuestActor, param7:AvatarView) : Boolean
      {
         var _loc8_:Object = null;
         var _loc9_:Point = null;
         this._color = param2;
         this._weaponItem = ItemXtCommManager.getItemDef(param1);
         this._aimX = param4;
         this._aimY = param5;
         this._healProjectile = false;
         if(param6 == null)
         {
            if(param7)
            {
               this._localPlayerLaunched = param7.userId == AvatarManager.playerSfsUserId;
               if(this._localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestProjectileLaunch(this._weaponItem.defId,param4,param5,"",param7.userId,param2);
               }
               _loc8_ = ItemXtCommManager.getItemDef(param1);
               if(_loc8_)
               {
                  this._healProjectile = _loc8_.attack < 0;
               }
               x = param7.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX;
               y = param7.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY;
               this._mediaHelperObj = new MediaHelper();
               this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onStrikeLoaded);
            }
         }
         else
         {
            this._localPlayerLaunched = false;
            _loc9_ = param6.actorOffset;
            this._npc = param6;
            x = this._npc.x + _loc9_.x;
            y = this._npc.y + _loc9_.y;
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onStrikeLoaded);
         }
         if(this._mediaHelperObj != null)
         {
            this.setAngle();
            param3.addChild(this);
            return true;
         }
         return false;
      }
      
      private function onStrikeLoaded(param1:MovieClip) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         if(parent != null)
         {
            _loc2_ = PaletteHelper.getRGBColors(this._color);
            _loc3_ = new Array(new Array(_loc2_[0].r,_loc2_[0].g,_loc2_[0].b),new Array(_loc2_[1].r,_loc2_[1].g,_loc2_[1].b),new Array(_loc2_[2].r,_loc2_[2].g,_loc2_[2].b),new Array(_loc2_[3].r,_loc2_[3].g,_loc2_[3].b));
            param1.rgbColors = _loc3_;
            param1.setColors();
            param1.x += x;
            param1.y += y;
            param1.strike(this._angle);
            parent.addChild(param1);
            this._strikeMC = param1;
            if(this._mediaHelperObj != null)
            {
               this._mediaHelperObj.destroy();
               this._mediaHelperObj = null;
            }
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onProjectileLoaded);
         }
      }
      
      private function onEffectLoaded(param1:MovieClip) : void
      {
         addChild(param1);
         param1.effect();
         if(this._mediaHelperObj != null)
         {
            this._mediaHelperObj.destroy();
            this._mediaHelperObj = null;
         }
      }
      
      private function onProjectileLoaded(param1:MovieClip) : void
      {
         var _loc2_:Array = PaletteHelper.getRGBColors(this._color);
         var _loc3_:Array = new Array(new Array(_loc2_[0].r,_loc2_[0].g,_loc2_[0].b),new Array(_loc2_[1].r,_loc2_[1].g,_loc2_[1].b),new Array(_loc2_[2].r,_loc2_[2].g,_loc2_[2].b),new Array(_loc2_[3].r,_loc2_[3].g,_loc2_[3].b));
         param1.rgbColors = _loc3_;
         param1.setColors();
         this._projectileMC = param1;
         addChild(this._projectileMC);
         this._projectileMC.projectile(this._angle);
         this._collisionOffset = this._projectileMC.getCollisionPoint();
         if(this._mediaHelperObj != null)
         {
            this._mediaHelperObj.destroy();
            this._mediaHelperObj = null;
         }
      }
   }
}

