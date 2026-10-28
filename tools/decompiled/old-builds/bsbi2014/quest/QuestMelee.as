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
   
   public class QuestMelee extends Sprite
   {
      
      private var _weaponItem:Object;
      
      private var _npc:QuestActor;
      
      private var _mediaHelperObj:MediaHelper;
      
      private var _swipeMC:MovieClip;
      
      private var _localPlayerLaunched:Boolean;
      
      private var _angle:Number;
      
      private var _timer:Number;
      
      private var _meleeID:int;
      
      private var _players:Array;
      
      private var _color:uint;
      
      public function QuestMelee(meleeID:int)
      {
         super();
         this._meleeID = meleeID;
      }
      
      public function get angle() : Number
      {
         return this._angle;
      }
      
      public function destroy() : void
      {
         if(this._mediaHelperObj != null)
         {
            this._mediaHelperObj.destroy();
            this._mediaHelperObj = null;
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function heartbeat(inFrameTime:Number) : Boolean
      {
         var collisionPoint:Point = null;
         var hitActors:Array = null;
         var questActor:QuestActor = null;
         var i:int = 0;
         var avView:AvatarWorldView = null;
         var hitX:Number = NaN;
         var hitY:Number = NaN;
         if(this._timer > 0)
         {
            this._timer -= inFrameTime;
            if(this._timer <= 0)
            {
               return true;
            }
         }
         else if(this._swipeMC != null)
         {
            if(Boolean(this._swipeMC.weaponDone))
            {
               this._timer = 2;
            }
            else if(Boolean(this._swipeMC.hitActive))
            {
               collisionPoint = this._swipeMC.getCollisionPoint();
               collisionPoint.x += x;
               collisionPoint.y += y;
               if(this._npc != null)
               {
                  if(Boolean(this._players))
                  {
                     for(i = this._players.length - 1; i >= 0; i--)
                     {
                        avView = AvatarManager.avatarViewList[this._players[i]];
                        if(avView != null)
                        {
                           hitX = collisionPoint.x - (avView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX);
                           hitY = collisionPoint.y - (avView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
                           if(hitX * hitX + hitY * hitY < (this._swipeMC.radius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS) * (this._swipeMC.radius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS))
                           {
                              this.handleHit(null,avView,this._localPlayerLaunched);
                              this._players.splice(i,1);
                           }
                        }
                        else
                        {
                           this._players.splice(i,1);
                        }
                     }
                  }
                  hitActors = QuestManager.meleeRadiusCheck(this._meleeID,collisionPoint,this._swipeMC.radius,true);
                  if(hitActors != null)
                  {
                     for each(questActor in hitActors)
                     {
                        this.handleHit(questActor,null,true);
                     }
                  }
               }
               else
               {
                  hitActors = QuestManager.meleeRadiusCheck(this._meleeID,collisionPoint,this._swipeMC.radius,false);
                  if(hitActors != null)
                  {
                     for each(questActor in hitActors)
                     {
                        this.handleHit(questActor,null,this._localPlayerLaunched);
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public function handleHit(inQuestActor:QuestActor, playerAvView:AvatarWorldView, localHit:Boolean) : void
      {
         var actorOffset:Point = null;
         if(inQuestActor != null)
         {
            inQuestActor.handleHit(localHit,this._weaponItem.defId);
            actorOffset = inQuestActor.actorOffset;
            actorOffset.x += inQuestActor.x - x;
            actorOffset.y += inQuestActor.y - y;
         }
         else
         {
            if(playerAvView == AvatarManager.playerAvatarWorldView)
            {
               QuestManager.questActorAttacked("",this._weaponItem.defId,0,0,this._npc);
            }
            actorOffset = new Point(QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
            actorOffset.x += playerAvView.x - x;
            actorOffset.y += playerAvView.y - y;
         }
         var mediaHelper:MediaHelper = new MediaHelper();
         mediaHelper.init(this._weaponItem.attackMediaRefId,this.onEffectLoaded,actorOffset);
      }
      
      public function swipe(inItemDefID:int, inColors:uint, inLayer:Sprite, inTargetX:int, inTargetY:int, inNPC:QuestActor, inAvatarView:AvatarView) : Boolean
      {
         var key:Object = null;
         var cp:Point = null;
         var toTargetX:Number = NaN;
         var toTargetY:Number = NaN;
         var distance:Number = NaN;
         var angle:Number = NaN;
         this._weaponItem = ItemXtCommManager.getItemDef(inItemDefID);
         this._color = inColors;
         if(inNPC == null)
         {
            if(inAvatarView != null)
            {
               this._localPlayerLaunched = inAvatarView.userId == AvatarManager.playerSfsUserId;
               if(this._localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestSwipe(this._weaponItem.defId,inTargetX,inTargetY,"",inAvatarView.userId,inColors);
               }
               x = inAvatarView.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX;
               y = inAvatarView.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY;
               this._mediaHelperObj = new MediaHelper();
               this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onSwipeLoaded,this);
            }
         }
         else
         {
            this._localPlayerLaunched = false;
            this._players = new Array();
            for(key in AvatarManager.avatarViewList)
            {
               this._players.push(key);
            }
            cp = inNPC.actorOffset;
            this._npc = inNPC;
            x = this._npc.x + cp.x;
            y = this._npc.y + cp.y;
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onSwipeLoaded,this);
         }
         if(this._mediaHelperObj != null)
         {
            toTargetX = inTargetX - x;
            toTargetY = inTargetY - y;
            if(toTargetX == 0 && toTargetY == 0)
            {
               toTargetX = 1;
            }
            distance = Math.sqrt(toTargetX * toTargetX + toTargetY * toTargetY);
            toTargetX /= distance;
            toTargetY /= distance;
            angle = Math.asin(toTargetX);
            if(toTargetY > 0)
            {
               angle = -(Math.PI + angle);
            }
            this._angle = angle * 180 / Math.PI;
            inLayer.addChild(this);
            return true;
         }
         return false;
      }
      
      private function onEffectLoaded(img:MovieClip) : void
      {
         img.x = img.passback.x;
         img.y = img.passback.y;
         img.effect();
         addChild(img);
         img.mediaHelper.destroy();
      }
      
      private function onSwipeLoaded(img:MovieClip) : void
      {
         var colorArray:Array = PaletteHelper.getRGBColors(this._color);
         var colors:Array = new Array(new Array(colorArray[0].r,colorArray[0].g,colorArray[0].b),new Array(colorArray[1].r,colorArray[1].g,colorArray[1].b),new Array(colorArray[2].r,colorArray[2].g,colorArray[2].b),new Array(colorArray[3].r,colorArray[3].g,colorArray[3].b));
         img.rgbColors = colors;
         img.setColors();
         addChild(img);
         img.strike(this._angle);
         this._swipeMC = img;
         img.mediaHelper.destroy();
      }
   }
}

