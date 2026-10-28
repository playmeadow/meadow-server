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
         _meleeID = param1;
      }
      
      public function get angle() : Number
      {
         return _angle;
      }
      
      public function destroy() : void
      {
         if(_mediaHelperObj != null)
         {
            _mediaHelperObj.destroy();
            _mediaHelperObj = null;
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function heartbeat(param1:Number) : Boolean
      {
         var _loc7_:Point = null;
         var _loc4_:Array = null;
         var _loc5_:* = null;
         var _loc8_:int = 0;
         var _loc6_:AvatarWorldView = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(_timer > 0)
         {
            _timer -= param1;
            if(_timer <= 0)
            {
               return true;
            }
         }
         else if(_swipeMC != null)
         {
            if(_swipeMC.weaponDone)
            {
               _timer = 2;
            }
            else if(_swipeMC.hitActive)
            {
               _loc7_ = _swipeMC.getCollisionPoint();
               _loc7_.x = _loc7_.x + x;
               _loc7_.y += y;
               if(_npc != null)
               {
                  if(_players)
                  {
                     _loc8_ = _players.length - 1;
                     while(_loc8_ >= 0)
                     {
                        _loc6_ = AvatarManager.avatarViewList[_players[_loc8_]];
                        if(_loc6_ != null)
                        {
                           _loc2_ = _loc7_.x - (_loc6_.x + -15);
                           _loc3_ = _loc7_.y - (_loc6_.y + -40);
                           if(_loc2_ * _loc2_ + _loc3_ * _loc3_ < (_swipeMC.radius + 50) * (_swipeMC.radius + 50))
                           {
                              handleHit(null,_loc6_,_localPlayerLaunched);
                              _players.splice(_loc8_,1);
                           }
                        }
                        else
                        {
                           _players.splice(_loc8_,1);
                        }
                        _loc8_--;
                     }
                  }
                  _loc4_ = QuestManager.meleeRadiusCheck(_meleeID,_loc7_,_swipeMC.radius,true);
                  if(_loc4_ != null)
                  {
                     for each(_loc5_ in _loc4_)
                     {
                        handleHit(_loc5_,null,true);
                     }
                  }
               }
               else
               {
                  _loc4_ = QuestManager.meleeRadiusCheck(_meleeID,_loc7_,_swipeMC.radius,false);
                  if(_loc4_ != null)
                  {
                     for each(_loc5_ in _loc4_)
                     {
                        handleHit(_loc5_,null,_localPlayerLaunched);
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public function handleHit(param1:QuestActor, param2:AvatarWorldView, param3:Boolean) : void
      {
         var _loc5_:Point = null;
         if(param1 != null)
         {
            param1.handleHit(param3,_weaponItem.defId);
            _loc5_ = param1.actorOffset;
            _loc5_.x = _loc5_.x + (param1.x - x);
            _loc5_.y += param1.y - y;
         }
         else
         {
            if(param2 == AvatarManager.playerAvatarWorldView)
            {
               QuestManager.questActorAttacked("",_weaponItem.defId,0,0,_npc);
            }
            _loc5_ = new Point(-15,-40);
            _loc5_.x = _loc5_.x + (param2.x - x);
            _loc5_.y += param2.y - y;
         }
         var _loc4_:MediaHelper = new MediaHelper();
         _loc4_.init(_weaponItem.attackMediaRefId,onEffectLoaded,_loc5_);
      }
      
      public function swipe(param1:int, param2:uint, param3:Sprite, param4:int, param5:int, param6:QuestActor, param7:AvatarView) : Boolean
      {
         var _loc12_:Point = null;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc10_:Number = NaN;
         _weaponItem = ItemXtCommManager.getItemDef(param1);
         _color = param2;
         if(param6 == null)
         {
            if(param7 != null)
            {
               _localPlayerLaunched = param7.userId == AvatarManager.playerSfsUserId;
               if(_localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestSwipe(_weaponItem.defId,param4,param5,"",param7.userId,param2);
               }
               x = param7.x + -15;
               y = param7.y + -40;
               _mediaHelperObj = new MediaHelper();
               _mediaHelperObj.init(_weaponItem.attackMediaRefId,onSwipeLoaded,this);
            }
         }
         else
         {
            _localPlayerLaunched = false;
            _players = [];
            for(var _loc13_:Object in AvatarManager.avatarViewList)
            {
               _players.push(_loc13_);
            }
            _loc12_ = param6.actorOffset;
            _npc = param6;
            x = _npc.x + _loc12_.x;
            y = _npc.y + _loc12_.y;
            _mediaHelperObj = new MediaHelper();
            _mediaHelperObj.init(_weaponItem.attackMediaRefId,onSwipeLoaded,this);
         }
         if(_mediaHelperObj != null)
         {
            _loc9_ = param4 - x;
            _loc8_ = param5 - y;
            if(_loc9_ == 0 && _loc8_ == 0)
            {
               _loc9_ = 1;
            }
            _loc11_ = Math.sqrt(_loc9_ * _loc9_ + _loc8_ * _loc8_);
            _loc9_ /= _loc11_;
            _loc8_ /= _loc11_;
            _loc10_ = Math.asin(_loc9_);
            if(_loc8_ > 0)
            {
               _loc10_ = -(3.141592653589793 + _loc10_);
            }
            _angle = _loc10_ * 180 / 3.141592653589793;
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
         var _loc3_:Array = PaletteHelper.getRGBColors(_color);
         var _loc2_:Array = new Array(new Array(_loc3_[0].r,_loc3_[0].g,_loc3_[0].b),new Array(_loc3_[1].r,_loc3_[1].g,_loc3_[1].b),new Array(_loc3_[2].r,_loc3_[2].g,_loc3_[2].b),new Array(_loc3_[3].r,_loc3_[3].g,_loc3_[3].b));
         param1.rgbColors = _loc2_;
         param1.setColors();
         addChild(param1);
         param1.strike(_angle);
         _swipeMC = param1;
         param1.mediaHelper.destroy();
      }
   }
}

