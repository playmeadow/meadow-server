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
      
      public function setScene(scene:SceneLoader, offset:Point) : void
      {
         var i:int = 0;
         var o:Object = null;
         this.release();
         this._socialTriggersVolumes = [];
         this._splashVolumes = [];
         this._roomObjs = [];
         this._volumeActors = [];
         this._scene = scene;
         this._offset = offset;
         this._volumes = scene.getActorList("ActorVolume");
         this._layers = this._scene.getActorList("ActorLayer");
         if(Boolean(this._volumes))
         {
            for(i = 0; i < this._volumes.length; i++)
            {
               o = this._volumes[i];
               this.newVolume(o);
            }
         }
      }
      
      public function release() : void
      {
         var i:int = 0;
         var o:Object = null;
         var ro:* = undefined;
         if(Boolean(this._volumeActors))
         {
            for(i = 0; i < this._volumeActors.length; i++)
            {
               for each(ro in this._volumeActors[i].interactiveObjs)
               {
                  ro.release();
               }
            }
         }
         if(Boolean(this._roomObjs))
         {
            for each(o in this._roomObjs)
            {
               o.release();
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
      
      public function clearHold(bMouseDown:Boolean = true) : void
      {
         var ro:RoomObject = null;
         for each(ro in this._roomObjs)
         {
            if(bMouseDown)
            {
               ro.mouseDown(false);
            }
            if(!ro.hold)
            {
               ro.setDir(-1);
            }
         }
      }
      
      public function testPointInVolume(p:Point, volume:Object) : Boolean
      {
         return this.pointInVolume(p,volume.v);
      }
      
      public function testMouseVolumes(p:Point, bMouseDown:Boolean, checkVolumeUse:Function = null) : Object
      {
         var ret:Object = null;
         var i:int = 0;
         var j:int = 0;
         var o:Object = null;
         var ro:RoomObject = null;
         if(Boolean(this._volumeActors))
         {
            this.clearHold(bMouseDown);
            if(bMouseDown)
            {
               for(i = 0; i < this._volumeActors.length; i++)
               {
                  o = this._volumeActors[i];
                  if(this.isMouseVolume(o.type) && this.pointInVolume(p,o.v))
                  {
                     if(Boolean(o.interactiveObjs))
                     {
                        for(j = 0; j < o.interactiveObjs.length; j++)
                        {
                           if(checkVolumeUse == null || Boolean(checkVolumeUse != null) && Boolean(checkVolumeUse(o.name)))
                           {
                              ro = o.interactiveObjs[j];
                              ro.setDir(1);
                              ro.mouseDown(true);
                           }
                        }
                     }
                     ret = o;
                  }
               }
            }
            for(i = 0; i < this._volumeActors.length; i++)
            {
               o = this._volumeActors[i];
               if(Boolean(this.isMouseVolume(o.type)) && Boolean(o.interactiveObjs) && this.pointInVolume(p,o.v))
               {
                  for(j = 0; j < o.interactiveObjs.length; j++)
                  {
                     if(checkVolumeUse == null || Boolean(checkVolumeUse != null) && Boolean(checkVolumeUse(o.name)))
                     {
                        ro = o.interactiveObjs[j];
                        if(!ro.hold)
                        {
                           ro.setDir(1);
                        }
                     }
                  }
               }
            }
         }
         return ret;
      }
      
      public function testPlantVolumes(p:Point) : Object
      {
         var i:int = 0;
         var o:Object = null;
         var ret:Object = null;
         if(Boolean(this._volumeActors))
         {
            for(i = 0; i < this._volumeActors.length; i++)
            {
               o = this._volumeActors[i];
               if(this.isPlantVolume(o.type) && this.pointInVolume(p,o.v))
               {
                  ret = o;
                  break;
               }
            }
         }
         return ret;
      }
      
      public function setVolumesEnabled(volumeName:String, bEnable:Boolean) : void
      {
         var i:int = 0;
         var o:Object = null;
         if(Boolean(this._volumeActors))
         {
            for(i = 0; i < this._volumeActors.length; i++)
            {
               o = this._volumeActors[i];
               if(o.name == volumeName)
               {
                  o.enabled = bEnable;
               }
            }
         }
      }
      
      public function testStealthVolumes(p:Point) : Object
      {
         var i:int = 0;
         var o:Object = null;
         var ret:Object = null;
         if(Boolean(this._volumeActors))
         {
            for(i = 0; i < this._volumeActors.length; i++)
            {
               o = this._volumeActors[i];
               if(Boolean(o.enabled) && Boolean(this.isStealthVolume(o.type)) && this.pointInVolume(p,o.v))
               {
                  ret = o;
                  break;
               }
            }
         }
         return ret;
      }
      
      public function testAvatarVolumes(p:Point) : Object
      {
         var i:int = 0;
         var o:Object = null;
         var ret:Object = null;
         if(Boolean(this._volumeActors))
         {
            for(i = 0; i < this._volumeActors.length; i++)
            {
               o = this._volumeActors[i];
               if(this.isAvatarVolume(o.type) && this.pointInVolume(p,o.v))
               {
                  ret = o;
                  break;
               }
            }
         }
         return ret;
      }
      
      public function testSplashVolumes(p:Point) : Object
      {
         var i:int = 0;
         var o:Object = null;
         var ret:Object = null;
         for(i = 0; i < this._splashVolumes.length; i++)
         {
            o = this._splashVolumes[i];
            if(this.pointInVolume(p,o.v))
            {
               ret = o;
               break;
            }
         }
         return ret;
      }
      
      public function updateSocialTriggers(avList:Object) : void
      {
         var key:Object = null;
         var a:* = undefined;
         if(Boolean(this._socialTriggersVolumes) && Boolean(this._socialTriggersVolumes.length))
         {
            this.clearSocialTriggers();
            for(key in avList)
            {
               a = avList[key];
               this.testSocialTriggers(new Point(a.x,a.y),a.animId);
            }
            this.updateSocialTriggersStage();
         }
      }
      
      private function clearSocialTriggers() : void
      {
         var o:Object = null;
         var o1:Object = null;
         for each(o in this._socialTriggersVolumes)
         {
            for each(o1 in o.interactiveObjs)
            {
               if(o1 is RoomObject_SocialTrigger)
               {
                  o1.clearCount();
               }
            }
         }
      }
      
      private function testSocialTriggers(p:Point, animId:int) : void
      {
         var o:Object = null;
         var o1:Object = null;
         for each(o in this._socialTriggersVolumes)
         {
            if(this.pointInVolume(p,o.v) && (!o.animIds || o.animIds.indexOf(animId) >= 0))
            {
               for each(o1 in o.interactiveObjs)
               {
                  if(o1 is RoomObject_SocialTrigger)
                  {
                     o1.incCount();
                  }
               }
            }
         }
      }
      
      private function updateSocialTriggersStage() : void
      {
         var o:Object = null;
         var o1:Object = null;
         for each(o in this._socialTriggersVolumes)
         {
            for each(o1 in o.interactiveObjs)
            {
               if(o1 is RoomObject_SocialTrigger)
               {
                  o1.update();
               }
            }
         }
      }
      
      private function isMouseVolume(type:int) : Boolean
      {
         return type == 0 || type == 1 || type == 4 || type == 7 || type == 8 || type == 9 || type == 10 || type == 12 || type == 13;
      }
      
      private function isSocialTriggerVolume(type:int) : Boolean
      {
         return type == 5;
      }
      
      private function isAvatarVolume(type:int) : Boolean
      {
         return type == 6 || type == 11;
      }
      
      private function isSplashVolume(type:int) : Boolean
      {
         return type == 3;
      }
      
      private function isPlantVolume(type:int) : Boolean
      {
         return type == 18;
      }
      
      private function isStealthVolume(type:int) : Boolean
      {
         return type == 19;
      }
      
      private function newVolume(v:Object) : void
      {
         var i:int = 0;
         var p:Point = null;
         var layer:Object = null;
         var o:Object = {
            "enabled":true,
            "name":v.name,
            "v":v.points.slice(),
            "status":0,
            "interactiveObjs":null,
            "message":v.message,
            "type":v.type,
            "typeDefId":v.typeDefId,
            "bWalkTo":v.walkTo
         };
         for(i = 0; i < o.v.length; i++)
         {
            p = new Point(o.v[i].x,o.v[i].y);
            this.convertToWorldSpace(p);
            o.v[i] = p;
         }
         for(i = 0; i < this._layers.length; i++)
         {
            layer = this._layers[i];
            if(layer.name == v.name)
            {
               if(!o.interactiveObjs)
               {
                  o.interactiveObjs = [];
               }
               o.interactiveObjs.push(this.getRoomObject(layer,v.message));
            }
         }
         this._volumeActors.push(o);
         if(this.isSplashVolume(o.type))
         {
            this._splashVolumes.push(o);
         }
         if(this.isSocialTriggerVolume(o.type))
         {
            o.animIds = null;
            if(Boolean(o.message.length))
            {
               o.animIds = o.message.split(",");
               for(i = 0; i < o.animIds.length; i++)
               {
                  o.animIds[i] = int(o.animIds[i]);
               }
            }
            this._socialTriggersVolumes.push(o);
         }
      }
      
      private function getRoomObject(layer:Object, message:String) : Object
      {
         var mc:MovieClip = null;
         var c:Class = null;
         var o:RoomObject = this._roomObjs[layer.name];
         if(!o)
         {
            mc = layer.s.content;
            switch(message)
            {
               case "gem":
                  c = RoomObject_GemPickup;
                  break;
               default:
                  if(mc.stages != null)
                  {
                     c = RoomObject_SocialTrigger;
                  }
                  else if(Boolean(mc.currentLabels.length))
                  {
                     if(mc.currentLabels[0].name == "idle")
                     {
                        c = RoomObject_IdleActive;
                     }
                     else if(mc.currentLabels[0].name == "random")
                     {
                        c = RoomObject_RandomClick;
                     }
                  }
                  if(!c)
                  {
                     c = RoomObject_ForwardReverseHold;
                  }
            }
            o = new c(mc);
            this._roomObjs[layer.name] = o;
         }
         return o;
      }
      
      private function pointInVolume(p:Point, v:Array) : Boolean
      {
         var vt:Number = NaN;
         var crossing:Number = 0;
         var n:Number = v.length - 1;
         for(var i:int = 0; i < n; i++)
         {
            if(v[i].y <= p.y && v[i + 1].y > p.y || v[i].y > p.y && v[i + 1].y <= p.y)
            {
               vt = (p.y - v[i].y) / (v[i + 1].y - v[i].y);
               if(p.x < v[i].x + vt * (v[i + 1].x - v[i].x))
               {
                  crossing++;
               }
            }
         }
         return Boolean(crossing % 2) ? true : false;
      }
      
      private function convertToWorldSpace(pos:Point) : void
      {
         pos.x -= this._offset.x;
         pos.y -= this._offset.y;
      }
      
      public function findVolume(name:String) : Array
      {
         var i:int = 0;
         var volumes:Array = null;
         if(this._volumeActors != null)
         {
            while(i < this._volumeActors.length)
            {
               if(this._volumeActors[i].name == name)
               {
                  if(volumes == null)
                  {
                     volumes = new Array();
                  }
                  volumes.push(this._volumeActors[i]);
               }
               i++;
            }
         }
         return volumes;
      }
      
      public function findVolumesByType(type:int) : Array
      {
         var i:int = 0;
         var volumes:Array = null;
         if(this._volumeActors != null)
         {
            while(i < this._volumeActors.length)
            {
               if(this._volumeActors[i].type == type)
               {
                  if(volumes == null)
                  {
                     volumes = new Array();
                  }
                  volumes.push(this._volumeActors[i]);
               }
               i++;
            }
         }
         return volumes;
      }
   }
}

