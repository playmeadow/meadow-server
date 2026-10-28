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
      
      public function heartbeat(inFrameTime:Number) : Boolean
      {
         var hitActor:QuestActor = null;
         var key:Object = null;
         var avView:AvatarWorldView = null;
         var hitX:Number = NaN;
         var hitY:Number = NaN;
         if(this._timer == 0)
         {
            if(this._projectileMC != null)
            {
               x += this._aimX * PROJECTILE_VELOCITY * inFrameTime;
               y += this._aimY * PROJECTILE_VELOCITY * inFrameTime;
               this._distanceTravelled += PROJECTILE_VELOCITY * inFrameTime;
               if(this._distanceTravelled > PROJECTILE_RANGE || RoomManagerWorld.instance.collisionTestGrid(x + this._collisionOffset.x,y + this._collisionOffset.y) == 1)
               {
                  this.handleHit(true,null,null,false);
               }
               else if(this._npc != null || this._healProjectile)
               {
                  for(key in AvatarManager.avatarViewList)
                  {
                     avView = AvatarManager.avatarViewList[key];
                     if(avView != null)
                     {
                        hitX = x + this._collisionOffset.x - (avView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX);
                        hitY = y + this._collisionOffset.y - (avView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
                        if(hitX * hitX + hitY * hitY < (PROJECTILE_RADIUS + QuestManager.QUEST_PLAYER_AVATAR_RADIUS) * (PROJECTILE_RADIUS + QuestManager.QUEST_PLAYER_AVATAR_RADIUS))
                        {
                           this.handleHit(false,null,avView,this._localPlayerLaunched);
                        }
                     }
                  }
                  hitActor = QuestManager.projectileRadiusCheck(x + this._collisionOffset.x,y + this._collisionOffset.y,PROJECTILE_RADIUS,true);
                  if(hitActor != null)
                  {
                     this.handleHit(false,hitActor,null,true);
                  }
               }
               else
               {
                  hitActor = QuestManager.projectileRadiusCheck(x + this._collisionOffset.x,y + this._collisionOffset.y,PROJECTILE_RADIUS,false);
                  if(hitActor != null)
                  {
                     this.handleHit(false,hitActor,null,this._localPlayerLaunched);
                  }
               }
            }
         }
         else
         {
            this._timer -= inFrameTime;
            if(this._timer <= 0)
            {
               this._timer = 0;
               return true;
            }
         }
         return false;
      }
      
      public function handleHit(inHitCollision:Boolean, inQuestActor:QuestActor, playerAvView:AvatarWorldView, localHit:Boolean) : void
      {
         var actorOffset:Point = null;
         this._projectileMC.visible = false;
         this._timer = 2;
         if(inHitCollision == false)
         {
            if(inQuestActor != null)
            {
               inQuestActor.handleHit(localHit,this._weaponItem.defId);
               actorOffset = inQuestActor.actorOffset;
               x = inQuestActor.x + actorOffset.x;
               y = inQuestActor.y + actorOffset.y;
            }
            else
            {
               if(!this._healProjectile)
               {
                  if(playerAvView == AvatarManager.playerAvatarWorldView)
                  {
                     QuestManager.questActorAttacked("",this._weaponItem.defId,0,0,this._npc);
                  }
               }
               else if(this._localPlayerLaunched)
               {
                  QuestXtCommManager.questPlayerHeal(this._weaponItem.defId,playerAvView.avatarData.sfsUserId);
               }
               actorOffset = new Point(QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
               x = actorOffset.x + playerAvView.x;
               y = actorOffset.y + playerAvView.y;
            }
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onEffectLoaded);
         }
      }
      
      private function setAngle() : void
      {
         var toTargetX:Number = this._aimX - x;
         var toTargetY:Number = this._aimY - y;
         if(toTargetX == 0 && toTargetY == 0)
         {
            toTargetX = 1;
         }
         var distance:Number = Math.sqrt(toTargetX * toTargetX + toTargetY * toTargetY);
         this._aimX = toTargetX / distance;
         this._aimY = toTargetY / distance;
         var angle:Number = Math.asin(this._aimX);
         if(this._aimY > 0)
         {
            angle = -(Math.PI + angle);
         }
         this._angle = angle * 180 / Math.PI;
      }
      
      public function relaunch(inItemDefID:int, inColor:uint, inLayer:Sprite, inTargetX:int, inTargetY:int, inNPC:QuestActor, inAvatarView:AvatarView) : Boolean
      {
         var cp:Point = null;
         this._color = inColor;
         this._aimX = inTargetX;
         this._aimY = inTargetY;
         this._healProjectile = false;
         this._distanceTravelled = 0;
         this._timer = 0;
         if(inNPC == null)
         {
            if(Boolean(inAvatarView))
            {
               this._localPlayerLaunched = inAvatarView.userId == AvatarManager.playerSfsUserId;
               if(this._localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestProjectileLaunch(this._weaponItem.defId,inTargetX,inTargetY,"",inAvatarView.userId,inColor);
               }
               this._healProjectile = this._weaponItem.attack < 0;
               x = this._strikeMC.x = inAvatarView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX;
               y = this._strikeMC.y = inAvatarView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY;
               this.setAngle();
               this._strikeMC.strike(this._angle);
               inLayer.addChild(this._strikeMC);
               this._projectileMC.visible = true;
               this._projectileMC.projectile(this._angle);
            }
         }
         else
         {
            this._localPlayerLaunched = false;
            cp = inNPC.actorOffset;
            this._npc = inNPC;
            x = this._strikeMC.x = this._npc.x + cp.x;
            y = this._strikeMC.x = this._npc.y + cp.y;
            this.setAngle();
            this._strikeMC.strike(this._angle);
            inLayer.addChild(this._strikeMC);
            this._projectileMC.visible = true;
            this._projectileMC.projectile(this._angle);
         }
         inLayer.addChild(this);
         return true;
      }
      
      public function launch(inItemDefID:int, inColor:uint, inLayer:Sprite, inTargetX:int, inTargetY:int, inNPC:QuestActor, inAvatarView:AvatarView) : Boolean
      {
         var weaponItem:Object = null;
         var cp:Point = null;
         this._color = inColor;
         this._weaponItem = ItemXtCommManager.getItemDef(inItemDefID);
         this._aimX = inTargetX;
         this._aimY = inTargetY;
         this._healProjectile = false;
         if(inNPC == null)
         {
            if(Boolean(inAvatarView))
            {
               this._localPlayerLaunched = inAvatarView.userId == AvatarManager.playerSfsUserId;
               if(this._localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestProjectileLaunch(this._weaponItem.defId,inTargetX,inTargetY,"",inAvatarView.userId,inColor);
               }
               weaponItem = ItemXtCommManager.getItemDef(inItemDefID);
               if(Boolean(weaponItem))
               {
                  this._healProjectile = weaponItem.attack < 0;
               }
               x = inAvatarView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX;
               y = inAvatarView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY;
               this._mediaHelperObj = new MediaHelper();
               this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onStrikeLoaded);
            }
         }
         else
         {
            this._localPlayerLaunched = false;
            cp = inNPC.actorOffset;
            this._npc = inNPC;
            x = this._npc.x + cp.x;
            y = this._npc.y + cp.y;
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onStrikeLoaded);
         }
         if(this._mediaHelperObj != null)
         {
            this.setAngle();
            inLayer.addChild(this);
            return true;
         }
         return false;
      }
      
      private function onStrikeLoaded(img:MovieClip) : void
      {
         var colorArray:Array = null;
         var colors:Array = null;
         if(parent != null)
         {
            colorArray = PaletteHelper.getRGBColors(this._color);
            colors = new Array(new Array(colorArray[0].r,colorArray[0].g,colorArray[0].b),new Array(colorArray[1].r,colorArray[1].g,colorArray[1].b),new Array(colorArray[2].r,colorArray[2].g,colorArray[2].b),new Array(colorArray[3].r,colorArray[3].g,colorArray[3].b));
            img.rgbColors = colors;
            img.setColors();
            img.x += x;
            img.y += y;
            img.strike(this._angle);
            parent.addChild(img);
            this._strikeMC = img;
            if(this._mediaHelperObj != null)
            {
               this._mediaHelperObj.destroy();
               this._mediaHelperObj = null;
            }
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onProjectileLoaded);
         }
      }
      
      private function onEffectLoaded(img:MovieClip) : void
      {
         addChild(img);
         img.effect();
         if(this._mediaHelperObj != null)
         {
            this._mediaHelperObj.destroy();
            this._mediaHelperObj = null;
         }
      }
      
      private function onProjectileLoaded(img:MovieClip) : void
      {
         var colorArray:Array = PaletteHelper.getRGBColors(this._color);
         var colors:Array = new Array(new Array(colorArray[0].r,colorArray[0].g,colorArray[0].b),new Array(colorArray[1].r,colorArray[1].g,colorArray[1].b),new Array(colorArray[2].r,colorArray[2].g,colorArray[2].b),new Array(colorArray[3].r,colorArray[3].g,colorArray[3].b));
         img.rgbColors = colors;
         img.setColors();
         this._projectileMC = img;
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

