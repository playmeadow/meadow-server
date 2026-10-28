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
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         this.release();
         this._socialTriggersVolumes = [];
         this._splashVolumes = [];
         this._roomObjs = [];
         this._volumeActors = [];
         this._scene = param1;
         this._offset = param2;
         this._volumes = param1.getActorList("ActorVolume");
         this._layers = this._scene.getActorList("ActorLayer");
         if(this._volumes)
         {
            _loc3_ = 0;
            while(_loc3_ < this._volumes.length)
            {
               _loc4_ = this._volumes[_loc3_];
               this.newVolume(_loc4_);
               _loc3_++;
            }
         }
      }
      
      public function release() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:* = undefined;
         if(this._volumeActors)
         {
            _loc1_ = 0;
            while(_loc1_ < this._volumeActors.length)
            {
               for each(_loc3_ in this._volumeActors[_loc1_].interactiveObjs)
               {
                  _loc3_.release();
               }
               _loc1_++;
            }
         }
         if(this._roomObjs)
         {
            for each(_loc2_ in this._roomObjs)
            {
               _loc2_.release();
            }
         }
         this._socialTriggersVolumes = null;
         this._volumes = null;
         this._layers = null;
         this._splashVolumes = null;
      }
      
      public function get hasSplashVolume() : Boolean
      {
         return Boolean(this._splashVolumes) && Boolean(this._splashVolumes.length);
      }
      
      public function clearHold(param1:Boolean = true) : void
      {
         var _loc2_:RoomObject = null;
         for each(_loc2_ in this._roomObjs)
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
         return this.pointInVolume(param1,param2.v);
      }
      
      public function testMouseVolumes(param1:Point, param2:Boolean, param3:Function = null) : Object
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:RoomObject = null;
         if(this._volumeActors)
         {
            this.clearHold(param2);
            if(param2)
            {
               _loc5_ = 0;
               while(_loc5_ < this._volumeActors.length)
               {
                  _loc7_ = this._volumeActors[_loc5_];
                  if(this.isMouseVolume(_loc7_.type) && this.pointInVolume(param1,_loc7_.v))
                  {
                     if(_loc7_.interactiveObjs)
                     {
                        _loc6_ = 0;
                        while(_loc6_ < _loc7_.interactiveObjs.length)
                        {
                           if(param3 == null || Boolean(param3 != null) && Boolean(param3(_loc7_.name)))
                           {
                              _loc8_ = _loc7_.interactiveObjs[_loc6_];
                              _loc8_.setDir(1);
                              _loc8_.mouseDown(true);
                           }
                           _loc6_++;
                        }
                     }
                     _loc4_ = _loc7_;
                  }
                  _loc5_++;
               }
            }
            _loc5_ = 0;
            while(_loc5_ < this._volumeActors.length)
            {
               _loc7_ = this._volumeActors[_loc5_];
               if(Boolean(this.isMouseVolume(_loc7_.type)) && Boolean(_loc7_.interactiveObjs) && this.pointInVolume(param1,_loc7_.v))
               {
                  _loc6_ = 0;
                  while(_loc6_ < _loc7_.interactiveObjs.length)
                  {
                     if(param3 == null || Boolean(param3 != null) && Boolean(param3(_loc7_.name)))
                     {
                        _loc8_ = _loc7_.interactiveObjs[_loc6_];
                        if(!_loc8_.hold)
                        {
                           _loc8_.setDir(1);
                        }
                     }
                     _loc6_++;
                  }
               }
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      public function testPlantVolumes(param1:Point) : Object
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(this._volumeActors)
         {
            _loc2_ = 0;
            while(_loc2_ < this._volumeActors.length)
            {
               _loc3_ = this._volumeActors[_loc2_];
               if(this.isPlantVolume(_loc3_.type) && this.pointInVolume(param1,_loc3_.v))
               {
                  _loc4_ = _loc3_;
                  break;
               }
               _loc2_++;
            }
         }
         return _loc4_;
      }
      
      public function setVolumesEnabled(param1:String, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(this._volumeActors)
         {
            _loc3_ = 0;
            while(_loc3_ < this._volumeActors.length)
            {
               _loc4_ = this._volumeActors[_loc3_];
               if(_loc4_.name == param1)
               {
                  _loc4_.enabled = param2;
               }
               _loc3_++;
            }
         }
      }
      
      public function testStealthVolumes(param1:Point) : Object
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(this._volumeActors)
         {
            _loc2_ = 0;
            while(_loc2_ < this._volumeActors.length)
            {
               _loc3_ = this._volumeActors[_loc2_];
               if(Boolean(_loc3_.enabled) && Boolean(this.isStealthVolume(_loc3_.type)) && this.pointInVolume(param1,_loc3_.v))
               {
                  _loc4_ = _loc3_;
                  break;
               }
               _loc2_++;
            }
         }
         return _loc4_;
      }
      
      public function testAvatarVolumes(param1:Point) : Object
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(this._volumeActors)
         {
            _loc2_ = 0;
            while(_loc2_ < this._volumeActors.length)
            {
               _loc3_ = this._volumeActors[_loc2_];
               if(this.isAvatarVolume(_loc3_.type) && this.pointInVolume(param1,_loc3_.v))
               {
                  _loc4_ = _loc3_;
                  break;
               }
               _loc2_++;
            }
         }
         return _loc4_;
      }
      
      public function testSplashVolumes(param1:Point) : Object
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         _loc2_ = 0;
         while(_loc2_ < this._splashVolumes.length)
         {
            _loc3_ = this._splashVolumes[_loc2_];
            if(this.pointInVolume(param1,_loc3_.v))
            {
               _loc4_ = _loc3_;
               break;
            }
            _loc2_++;
         }
         return _loc4_;
      }
      
      public function updateSocialTriggers(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:* = undefined;
         if(Boolean(this._socialTriggersVolumes) && Boolean(this._socialTriggersVolumes.length))
         {
            this.clearSocialTriggers();
            for(_loc2_ in param1)
            {
               _loc3_ = param1[_loc2_];
               this.testSocialTriggers(new Point(_loc3_.x,_loc3_.y),_loc3_.animId);
            }
            this.updateSocialTriggersStage();
         }
      }
      
      private function clearSocialTriggers() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         for each(_loc1_ in this._socialTriggersVolumes)
         {
            for each(_loc2_ in _loc1_.interactiveObjs)
            {
               if(_loc2_ is RoomObject_SocialTrigger)
               {
                  _loc2_.clearCount();
               }
            }
         }
      }
      
      private function testSocialTriggers(param1:Point, param2:int) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         for each(_loc3_ in this._socialTriggersVolumes)
         {
            if(this.pointInVolume(param1,_loc3_.v) && (!_loc3_.animIds || _loc3_.animIds.indexOf(param2) >= 0))
            {
               for each(_loc4_ in _loc3_.interactiveObjs)
               {
                  if(_loc4_ is RoomObject_SocialTrigger)
                  {
                     _loc4_.incCount();
                  }
               }
            }
         }
      }
      
      private function updateSocialTriggersStage() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         for each(_loc1_ in this._socialTriggersVolumes)
         {
            for each(_loc2_ in _loc1_.interactiveObjs)
            {
               if(_loc2_ is RoomObject_SocialTrigger)
               {
                  _loc2_.update();
               }
            }
         }
      }
      
      private function isMouseVolume(param1:int) : Boolean
      {
         return param1 == 0 || param1 == 1 || param1 == 4 || param1 == 7 || param1 == 8 || param1 == 9 || param1 == 10 || param1 == 12 || param1 == 13;
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
         var _loc2_:int = 0;
         var _loc4_:Point = null;
         var _loc5_:Object = null;
         var _loc3_:Object = {
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
         _loc2_ = 0;
         while(_loc2_ < _loc3_.v.length)
         {
            _loc4_ = new Point(_loc3_.v[_loc2_].x,_loc3_.v[_loc2_].y);
            this.convertToWorldSpace(_loc4_);
            _loc3_.v[_loc2_] = _loc4_;
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this._layers.length)
         {
            _loc5_ = this._layers[_loc2_];
            if(_loc5_.name == param1.name)
            {
               if(!_loc3_.interactiveObjs)
               {
                  _loc3_.interactiveObjs = [];
               }
               _loc3_.interactiveObjs.push(this.getRoomObject(_loc5_,param1.message));
            }
            _loc2_++;
         }
         this._volumeActors.push(_loc3_);
         if(this.isSplashVolume(_loc3_.type))
         {
            this._splashVolumes.push(_loc3_);
         }
         if(this.isSocialTriggerVolume(_loc3_.type))
         {
            _loc3_.animIds = null;
            if(_loc3_.message.length)
            {
               _loc3_.animIds = _loc3_.message.split(",");
               _loc2_ = 0;
               while(_loc2_ < _loc3_.animIds.length)
               {
                  _loc3_.animIds[_loc2_] = int(_loc3_.animIds[_loc2_]);
                  _loc2_++;
               }
            }
            this._socialTriggersVolumes.push(_loc3_);
         }
      }
      
      private function getRoomObject(param1:Object, param2:String) : Object
      {
         var _loc4_:MovieClip = null;
         var _loc5_:Class = null;
         var _loc3_:RoomObject = this._roomObjs[param1.name];
         if(!_loc3_)
         {
            _loc4_ = param1.s.content;
            switch(param2)
            {
               case "gem":
                  _loc5_ = RoomObject_GemPickup;
                  break;
               default:
                  if(_loc4_.stages != null)
                  {
                     _loc5_ = RoomObject_SocialTrigger;
                  }
                  else if(_loc4_.currentLabels.length)
                  {
                     if(_loc4_.currentLabels[0].name == "idle")
                     {
                        _loc5_ = RoomObject_IdleActive;
                     }
                     else if(_loc4_.currentLabels[0].name == "random")
                     {
                        _loc5_ = RoomObject_RandomClick;
                     }
                  }
                  if(!_loc5_)
                  {
                     _loc5_ = RoomObject_ForwardReverseHold;
                  }
            }
            _loc3_ = new _loc5_(_loc4_);
            this._roomObjs[param1.name] = _loc3_;
         }
         return _loc3_;
      }
      
      private function pointInVolume(param1:Point, param2:Array) : Boolean
      {
         var _loc6_:Number = NaN;
         var _loc3_:Number = 0;
         var _loc4_:Number = param2.length - 1;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(param2[_loc5_].y <= param1.y && param2[_loc5_ + 1].y > param1.y || param2[_loc5_].y > param1.y && param2[_loc5_ + 1].y <= param1.y)
            {
               _loc6_ = (param1.y - param2[_loc5_].y) / (param2[_loc5_ + 1].y - param2[_loc5_].y);
               if(param1.x < param2[_loc5_].x + _loc6_ * (param2[_loc5_ + 1].x - param2[_loc5_].x))
               {
                  _loc3_++;
               }
            }
            _loc5_++;
         }
         return _loc3_ % 2 ? true : false;
      }
      
      private function convertToWorldSpace(param1:Point) : void
      {
         param1.x -= this._offset.x;
         param1.y -= this._offset.y;
      }
      
      public function findVolume(param1:String) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         if(this._volumeActors != null)
         {
            while(_loc3_ < this._volumeActors.length)
            {
               if(this._volumeActors[_loc3_].name == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = new Array();
                  }
                  _loc2_.push(this._volumeActors[_loc3_]);
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
         if(this._volumeActors != null)
         {
            while(_loc3_ < this._volumeActors.length)
            {
               if(this._volumeActors[_loc3_].type == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = new Array();
                  }
                  _loc2_.push(this._volumeActors[_loc3_]);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
   }
}

