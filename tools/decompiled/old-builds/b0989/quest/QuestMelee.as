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
      
      public function QuestMelee(param1:int)
      {
         super();
         this._meleeID = param1;
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
      
      public function heartbeat(param1:Number) : Boolean
      {
         var _loc2_:Point = null;
         var _loc3_:Array = null;
         var _loc4_:QuestActor = null;
         var _loc5_:* = 0;
         var _loc6_:AvatarWorldView = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(this._timer > 0)
         {
            this._timer -= param1;
            if(this._timer <= 0)
            {
               return true;
            }
         }
         else if(this._swipeMC != null)
         {
            if(this._swipeMC.weaponDone)
            {
               this._timer = 2;
            }
            else if(this._swipeMC.hitActive)
            {
               _loc2_ = this._swipeMC.getCollisionPoint();
               _loc2_.x += x;
               _loc2_.y += y;
               if(this._npc != null)
               {
                  if(this._players)
                  {
                     _loc5_ = int(this._players.length - 1);
                     while(_loc5_ >= 0)
                     {
                        _loc6_ = AvatarManager.avatarViewList[this._players[_loc5_]];
                        if(_loc6_ != null)
                        {
                           _loc7_ = _loc2_.x - (_loc6_.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX);
                           _loc8_ = _loc2_.y - (_loc6_.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
                           if(_loc7_ * _loc7_ + _loc8_ * _loc8_ < (this._swipeMC.radius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS) * (this._swipeMC.radius + QuestManager.QUEST_PLAYER_AVATAR_RADIUS))
                           {
                              this.handleHit(null,_loc6_,this._localPlayerLaunched);
                              this._players.splice(_loc5_,1);
                           }
                        }
                        else
                        {
                           this._players.splice(_loc5_,1);
                        }
                        _loc5_--;
                     }
                  }
                  _loc3_ = QuestManager.meleeRadiusCheck(this._meleeID,_loc2_,this._swipeMC.radius,true);
                  if(_loc3_ != null)
                  {
                     for each(_loc4_ in _loc3_)
                     {
                        this.handleHit(_loc4_,null,true);
                     }
                  }
               }
               else
               {
                  _loc3_ = QuestManager.meleeRadiusCheck(this._meleeID,_loc2_,this._swipeMC.radius,false);
                  if(_loc3_ != null)
                  {
                     for each(_loc4_ in _loc3_)
                     {
                        this.handleHit(_loc4_,null,this._localPlayerLaunched);
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public function handleHit(param1:QuestActor, param2:AvatarWorldView, param3:Boolean) : void
      {
         var _loc4_:Point = null;
         if(param1 != null)
         {
            param1.handleHit(param3,this._weaponItem.defId);
            _loc4_ = param1.actorOffset;
            _loc4_.x += param1.x - x;
            _loc4_.y += param1.y - y;
         }
         else
         {
            if(param2 == AvatarManager.playerAvatarWorldView)
            {
               QuestXtCommManager.questActorAttacked("",this._weaponItem.defId);
            }
            _loc4_ = new Point(QuestManager.QUEST_PLAYER_AVATAR_OFFSETX,QuestManager.QUEST_PLAYER_AVATAR_OFFSETY);
            _loc4_.x += param2.x - x;
            _loc4_.y += param2.y - y;
         }
         var _loc5_:MediaHelper = new MediaHelper();
         _loc5_.init(this._weaponItem.attackMediaRefId,this.onEffectLoaded,_loc4_);
      }
      
      public function swipe(param1:int, param2:uint, param3:Sprite, param4:int, param5:int, param6:QuestActor, param7:AvatarView) : Boolean
      {
         var _loc8_:Object = null;
         var _loc9_:Point = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         this._weaponItem = ItemXtCommManager.getItemDef(param1);
         this._color = param2;
         if(param6 == null)
         {
            if(param7 != null)
            {
               this._localPlayerLaunched = param7.userId == AvatarManager.playerSfsUserId;
               if(this._localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestSwipe(this._weaponItem.defId,param4,param5,"",param7.userId,param2);
               }
               x = param7.x + QuestManager.QUEST_PLAYER_AVATAR_OFFSETX;
               y = param7.y + QuestManager.QUEST_PLAYER_AVATAR_OFFSETY;
               this._mediaHelperObj = new MediaHelper();
               this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onSwipeLoaded,this);
            }
         }
         else
         {
            this._localPlayerLaunched = false;
            this._players = new Array();
            for(_loc8_ in AvatarManager.avatarViewList)
            {
               this._players.push(_loc8_);
            }
            _loc9_ = param6.actorOffset;
            this._npc = param6;
            x = this._npc.x + _loc9_.x;
            y = this._npc.y + _loc9_.y;
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._weaponItem.attackMediaRefId,this.onSwipeLoaded,this);
         }
         if(this._mediaHelperObj != null)
         {
            _loc10_ = param4 - x;
            _loc11_ = param5 - y;
            if(_loc10_ == 0 && _loc11_ == 0)
            {
               _loc10_ = 1;
            }
            _loc12_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
            _loc10_ /= _loc12_;
            _loc11_ /= _loc12_;
            _loc13_ = Math.asin(_loc10_);
            if(_loc11_ > 0)
            {
               _loc13_ = -(Math.PI + _loc13_);
            }
            this._angle = _loc13_ * 180 / Math.PI;
            param3.addChild(this);
            return true;
         }
         return false;
      }
      
      private function onEffectLoaded(param1:MovieClip) : void
      {
         param1.x = param1.passback.x;
         param1.y = param1.passback.y;
         param1.effect();
         addChild(param1);
         param1.mediaHelper.destroy();
      }
      
      private function onSwipeLoaded(param1:MovieClip) : void
      {
         var _loc2_:Array = PaletteHelper.getRGBColors(this._color);
         var _loc3_:Array = new Array(new Array(_loc2_[0].r,_loc2_[0].g,_loc2_[0].b),new Array(_loc2_[1].r,_loc2_[1].g,_loc2_[1].b),new Array(_loc2_[2].r,_loc2_[2].g,_loc2_[2].b),new Array(_loc2_[3].r,_loc2_[3].g,_loc2_[3].b));
         param1.rgbColors = _loc3_;
         param1.setColors();
         addChild(param1);
         param1.strike(this._angle);
         this._swipeMC = param1;
         param1.mediaHelper.destroy();
      }
   }
}

