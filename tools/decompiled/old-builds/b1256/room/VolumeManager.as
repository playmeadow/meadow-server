package room
{
   import com.sbi.loader.SceneLoader;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class VolumeManager
   {
      
      public static const VOLUMETYPE_NONE:int = 0;
      
      public static const VOLUMETYPE_GAME:int = 1;
      
      public static const VOLUMETYPE_DEN_VOLUME:int = 2;
      
      public static const VOLUMETYPE_SPLASH:int = 3;
      
      public static const VOLUMETYPE_STORE_PET:int = 4;
      
      public static const VOLUMETYPE_SOCIAL_GROUP:int = 5;
      
      public static const VOLUMETYPE_SOCIAL_EMOTICON:int = 6;
      
      public static const VOLUMETYPE_GUI_ACTION:int = 7;
      
      public static const VOLUMETYPE_RECYCLE_ACCESSORY:int = 8;
      
      public static const VOLUMETYPE_RECYCLE_DEN_ITEM:int = 9;
      
      public static const VOLUMETYPE_TRIGGER_WALKIN:int = 11;
      
      public static const VOLUMETYPE_GENERIC_LIST:int = 12;
      
      public static const VOLUMETYPE_CLICK_EMOTICON:int = 13;
      
      public static const VOLUMETYPE_AIR:int = 14;
      
      public static const VOLUMETYPE_DYNAMIC_COLLISION:int = 15;
      
      public static const VOLUMETYPE_DYNAMIC_AIR:int = 16;
      
      public static const VOLUMETYPE_DYNAMIC_PHANTOM_AIR:int = 17;
      
      public static const VOLUMETYPE_PLANT:int = 18;
      
      public static const VOLUMETYPE_STEALTH:int = 19;
      
      public static const VOLUMETYPE_ADVENTURE_INTERACT:int = 20;
      
      public static const VOLUMETYPE_DARKSOFT:int = 21;
      
      public static const VOLUMETYPE_DARKHARD:int = 22;
      
      public static const VOLUMETYPE_FALLINGPHANTOM:int = 23;
      
      private var _scene:SceneLoader;
      
      private var _volumes:Array;
      
      private var _layers:Array;
      
      private var _volumeActors:Array;
      
      private var _roomObjs:Array;
      
      private var _offset:Point;
      
      private var _socialTriggersVolumes:Array;
      
      private var _splashVolumes:Array;
      
      public function VolumeManager()
      {
         super();
      }
      
      public function setScene(param1:SceneLoader, param2:Point) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         release();
         _socialTriggersVolumes = [];
         _splashVolumes = [];
         _roomObjs = [];
         _volumeActors = [];
         _scene = param1;
         _offset = param2;
         _volumes = param1.getActorList("ActorVolume");
         _layers = _scene.getActorList("ActorLayer");
         if(_volumes)
         {
            _loc4_ = 0;
            while(_loc4_ < _volumes.length)
            {
               _loc3_ = _volumes[_loc4_];
               newVolume(_loc3_);
               _loc4_++;
            }
         }
      }
      
      public function release() : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         if(_volumeActors)
         {
            _loc3_ = 0;
            while(_loc3_ < _volumeActors.length)
            {
               for each(var _loc1_ in _volumeActors[_loc3_].interactiveObjs)
               {
                  _loc1_.release();
               }
               _loc3_++;
            }
         }
         if(_roomObjs)
         {
            for each(_loc2_ in _roomObjs)
            {
               _loc2_.release();
            }
         }
         _socialTriggersVolumes = null;
         _volumes = null;
         _layers = null;
         _splashVolumes = null;
      }
      
      public function get hasSplashVolume() : Boolean
      {
         return _splashVolumes && _splashVolumes.length;
      }
      
      public function clearHold(param1:Boolean = true) : void
      {
         for each(var _loc2_:RoomObject in _roomObjs)
         {
            if(param1)
            {
               _loc2_.mouseDown(false);
            }
            if(!_loc2_.hold)
            {
               _loc2_.setDir(-1);
            }
         }
      }
      
      public function testPointInVolume(param1:Point, param2:Object) : Boolean
      {
         return pointInVolume(param1,param2.v);
      }
      
      public function testMouseVolumes(param1:Point, param2:Boolean, param3:Function = null) : Object
      {
         var _loc4_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:Object = null;
         var _loc5_:RoomObject = null;
         if(_volumeActors)
         {
            clearHold(param2);
            if(param2)
            {
               _loc8_ = 0;
               while(_loc8_ < _volumeActors.length)
               {
                  _loc6_ = _volumeActors[_loc8_];
                  if(isMouseVolume(_loc6_.type) && pointInVolume(param1,_loc6_.v))
                  {
                     if(_loc6_.interactiveObjs)
                     {
                        _loc7_ = 0;
                        while(_loc7_ < _loc6_.interactiveObjs.length)
                        {
                           if(param3 == null || param3 != null && param3(_loc6_.name))
                           {
                              _loc5_ = _loc6_.interactiveObjs[_loc7_];
                              _loc5_.setDir(1);
                              _loc5_.mouseDown(true);
                           }
                           _loc7_++;
                        }
                     }
                     _loc4_ = _loc6_;
                  }
                  _loc8_++;
               }
            }
            _loc8_ = 0;
            while(_loc8_ < _volumeActors.length)
            {
               _loc6_ = _volumeActors[_loc8_];
               if(isMouseVolume(_loc6_.type) && _loc6_.interactiveObjs && pointInVolume(param1,_loc6_.v))
               {
                  _loc7_ = 0;
                  while(_loc7_ < _loc6_.interactiveObjs.length)
                  {
                     if(param3 == null || param3 != null && param3(_loc6_.name))
                     {
                        _loc5_ = _loc6_.interactiveObjs[_loc7_];
                        if(!_loc5_.hold)
                        {
                           _loc5_.setDir(1);
                        }
                     }
                     _loc7_++;
                  }
               }
               _loc8_++;
            }
         }
         return _loc4_;
      }
      
      public function testPlantVolumes(param1:Point) : Object
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         var _loc2_:Object = null;
         if(_volumeActors)
         {
            _loc4_ = 0;
            while(_loc4_ < _volumeActors.length)
            {
               _loc3_ = _volumeActors[_loc4_];
               if(isPlantVolume(_loc3_.type) && pointInVolume(param1,_loc3_.v))
               {
                  _loc2_ = _loc3_;
                  break;
               }
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      public function setVolumesEnabled(param1:String, param2:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         if(_volumeActors)
         {
            _loc4_ = 0;
            while(_loc4_ < _volumeActors.length)
            {
               _loc3_ = _volumeActors[_loc4_];
               if(_loc3_.name == param1)
               {
                  _loc3_.enabled = param2;
               }
               _loc4_++;
            }
         }
      }
      
      public function testStealthVolumes(param1:Point) : Object
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         var _loc2_:Object = null;
         if(_volumeActors)
         {
            _loc4_ = 0;
            while(_loc4_ < _volumeActors.length)
            {
               _loc3_ = _volumeActors[_loc4_];
               if(_loc3_.enabled && isStealthVolume(_loc3_.type) && pointInVolume(param1,_loc3_.v))
               {
                  _loc2_ = _loc3_;
                  break;
               }
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      public function testAvatarVolumes(param1:Point) : Object
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         var _loc2_:Object = null;
         if(_volumeActors)
         {
            _loc4_ = 0;
            while(_loc4_ < _volumeActors.length)
            {
               _loc3_ = _volumeActors[_loc4_];
               if(isAvatarVolume(_loc3_.type) && pointInVolume(param1,_loc3_.v))
               {
                  _loc2_ = _loc3_;
                  break;
               }
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      public function testAvatarVolume(param1:String, param2:Point) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         if(_volumeActors)
         {
            _loc4_ = 0;
            while(_loc4_ < _volumeActors.length)
            {
               _loc3_ = _volumeActors[_loc4_];
               if(_loc3_.name == param1)
               {
                  if(pointInVolume(param2,_loc3_.v))
                  {
                     return true;
                  }
                  break;
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      public function testSplashVolumes(param1:Point) : Object
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         var _loc2_:Object = null;
         _loc4_ = 0;
         while(_loc4_ < _splashVolumes.length)
         {
            _loc3_ = _splashVolumes[_loc4_];
            if(pointInVolume(param1,_loc3_.v))
            {
               _loc2_ = _loc3_;
               break;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function updateSocialTriggers(param1:Object) : void
      {
         var _loc2_:* = undefined;
         if(_socialTriggersVolumes && _socialTriggersVolumes.length)
         {
            clearSocialTriggers();
            for(var _loc3_:Object in param1)
            {
               _loc2_ = param1[_loc3_];
               testSocialTriggers(new Point(_loc2_.x,_loc2_.y),_loc2_.animId);
            }
            updateSocialTriggersStage();
         }
      }
      
      private function clearSocialTriggers() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         for each(_loc2_ in _socialTriggersVolumes)
         {
            for each(_loc1_ in _loc2_.interactiveObjs)
            {
               if(_loc1_ is RoomObject_SocialTrigger)
               {
                  _loc1_.clearCount();
               }
            }
         }
      }
      
      private function testSocialTriggers(param1:Point, param2:int) : void
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         for each(_loc4_ in _socialTriggersVolumes)
         {
            if(pointInVolume(param1,_loc4_.v) && (!_loc4_.animIds || _loc4_.animIds.indexOf(param2) >= 0))
            {
               for each(_loc3_ in _loc4_.interactiveObjs)
               {
                  if(_loc3_ is RoomObject_SocialTrigger)
                  {
                     _loc3_.incCount();
                  }
               }
            }
         }
      }
      
      private function updateSocialTriggersStage() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         for each(_loc2_ in _socialTriggersVolumes)
         {
            for each(_loc1_ in _loc2_.interactiveObjs)
            {
               if(_loc1_ is RoomObject_SocialTrigger)
               {
                  _loc1_.update();
               }
            }
         }
      }
      
      private function isMouseVolume(param1:int) : Boolean
      {
         return param1 == 0 || param1 == 1 || param1 == 4 || param1 == 7 || param1 == 8 || param1 == 9 || param1 == 10 || param1 == 12 || param1 == 13 || param1 == 24;
      }
      
      private function isSocialTriggerVolume(param1:int) : Boolean
      {
         return param1 == 5;
      }
      
      private function isAvatarVolume(param1:int) : Boolean
      {
         return param1 == 6 || param1 == 11;
      }
      
      private function isSplashVolume(param1:int) : Boolean
      {
         return param1 == 3;
      }
      
      private function isPlantVolume(param1:int) : Boolean
      {
         return param1 == 18;
      }
      
      private function isStealthVolume(param1:int) : Boolean
      {
         return param1 == 19;
      }
      
      private function newVolume(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc2_:Point = null;
         var _loc3_:Object = null;
         var _loc4_:Object = {
            "enabled":true,
            "name":param1.name,
            "v":param1.points.slice(),
            "status":0,
            "interactiveObjs":null,
            "message":param1.message,
            "type":param1.type,
            "typeDefId":param1.typeDefId,
            "bWalkTo":param1.walkTo
         };
         _loc5_ = 0;
         while(_loc5_ < _loc4_.v.length)
         {
            _loc2_ = new Point(_loc4_.v[_loc5_].x,_loc4_.v[_loc5_].y);
            convertToWorldSpace(_loc2_);
            _loc4_.v[_loc5_] = _loc2_;
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < _layers.length)
         {
            _loc3_ = _layers[_loc5_];
            if(_loc3_.name == param1.name)
            {
               if(!_loc4_.interactiveObjs)
               {
                  _loc4_.interactiveObjs = [];
               }
               _loc4_.interactiveObjs.push(getRoomObject(_loc3_,param1.message));
            }
            _loc5_++;
         }
         _volumeActors.push(_loc4_);
         if(isSplashVolume(_loc4_.type))
         {
            _splashVolumes.push(_loc4_);
         }
         if(isSocialTriggerVolume(_loc4_.type))
         {
            _loc4_.animIds = null;
            if(_loc4_.message.length)
            {
               _loc4_.animIds = _loc4_.message.split(",");
               _loc5_ = 0;
               while(_loc5_ < _loc4_.animIds.length)
               {
                  _loc4_.animIds[_loc5_] = int(_loc4_.animIds[_loc5_]);
                  _loc5_++;
               }
            }
            _socialTriggersVolumes.push(_loc4_);
         }
      }
      
      private function getRoomObject(param1:Object, param2:String) : Object
      {
         var _loc3_:MovieClip = null;
         var _loc4_:Class = null;
         var _loc5_:RoomObject = _roomObjs[param1.name];
         if(!_loc5_)
         {
            _loc3_ = param1.s.content;
            var _loc6_:String = param2;
            if("gem" !== _loc6_)
            {
               if(_loc3_.stages != null)
               {
                  _loc4_ = RoomObject_SocialTrigger;
               }
               else if(_loc3_.currentLabels.length)
               {
                  if(_loc3_.currentLabels[0].name == "idle")
                  {
                     _loc4_ = RoomObject_IdleActive;
                  }
                  else if(_loc3_.currentLabels[0].name == "random")
                  {
                     _loc4_ = RoomObject_RandomClick;
                  }
               }
               if(!_loc4_)
               {
                  _loc4_ = RoomObject_ForwardReverseHold;
               }
            }
            else
            {
               _loc4_ = RoomObject_GemPickup;
            }
            _loc5_ = new _loc4_(_loc3_);
            _roomObjs[param1.name] = _loc5_;
         }
         return _loc5_;
      }
      
      private function pointInVolume(param1:Point, param2:Array) : Boolean
      {
         var _loc6_:int = 0;
         var _loc4_:Number = NaN;
         var _loc3_:Number = 0;
         var _loc5_:Number = param2.length - 1;
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            if(param2[_loc6_].y <= param1.y && param2[_loc6_ + 1].y > param1.y || param2[_loc6_].y > param1.y && param2[_loc6_ + 1].y <= param1.y)
            {
               _loc4_ = (param1.y - param2[_loc6_].y) / (param2[_loc6_ + 1].y - param2[_loc6_].y);
               if(param1.x < param2[_loc6_].x + _loc4_ * (param2[_loc6_ + 1].x - param2[_loc6_].x))
               {
                  _loc3_++;
               }
            }
            _loc6_++;
         }
         return _loc3_ % 2 ? true : false;
      }
      
      private function convertToWorldSpace(param1:Point) : void
      {
         param1.x -= _offset.x;
         param1.y -= _offset.y;
      }
      
      public function findVolume(param1:String) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         if(_volumeActors != null)
         {
            while(_loc3_ < _volumeActors.length)
            {
               if(_volumeActors[_loc3_].name == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = [];
                  }
                  _loc2_.push(_volumeActors[_loc3_]);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function findVolumesByType(param1:int) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         if(_volumeActors != null)
         {
            while(_loc3_ < _volumeActors.length)
            {
               if(_volumeActors[_loc3_].type == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = [];
                  }
                  _loc2_.push(_volumeActors[_loc3_]);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
   }
}

