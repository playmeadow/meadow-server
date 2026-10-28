package loader
{
   import avatar.AvatarManager;
   import com.sbi.loader.FileServerEvent;
   import den.DenItem;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import pet.PetManager;
   
   public class DenItemHelper
   {
      
      private var _id:uint;
      
      private var _callback:Function;
      
      private var _loader:Loader;
      
      private var _sprite:Sprite;
      
      private var _portalSprite:Sprite;
      
      private var _sortOffset:int;
      
      private var _minigameDefId:int;
      
      private var _version:int;
      
      private var _version2:int;
      
      private var _version3:int;
      
      private var _bFlipLabel:Boolean;
      
      private var _onMouseDownCallback:Function;
      
      private var _onMouseOverCallback:Function;
      
      private var _onMouseOutCallback:Function;
      
      private var _passback:Object;
      
      public function DenItemHelper()
      {
         super();
      }
      
      public function get displayObject() : Sprite
      {
         return this._sprite;
      }
      
      public function get content() : DisplayObject
      {
         return this._loader.content;
      }
      
      public function get sortOffset() : int
      {
         return this._sortOffset;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get minigameDefId() : int
      {
         return this._minigameDefId;
      }
      
      public function get bFlipLabel() : Boolean
      {
         return this._bFlipLabel;
      }
      
      public function init(param1:uint, param2:Function, param3:int, param4:int = 0, param5:int = 0, param6:int = 0) : void
      {
         this._id = param1;
         this._callback = param2;
         this._minigameDefId = param4;
         this._bFlipLabel = false;
         this._version = param3;
         this._version2 = param5;
         this._version3 = param6;
         this._loader = new Loader();
         this._sprite = new Sprite();
         this._portalSprite = new Sprite();
         DenItemServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleData,false,0,true);
         DenItemServer.instance.requestFile(this._id);
      }
      
      public function destroy() : void
      {
         DenItemServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
         if(this._loader)
         {
            if(this._loader.parent)
            {
               this._loader.parent.removeChild(this._loader);
            }
            this._loader.unloadAndStop(true);
         }
         this._callback = null;
         this._sprite = null;
      }
      
      public function setupItemWithEmotes(param1:Object) : void
      {
         this._passback = param1;
      }
      
      public function addPortalListeners(param1:Object, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         this._passback = param1;
         this._onMouseDownCallback = param2;
         this._portalSprite.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         if(param3 != null)
         {
            this._onMouseOverCallback = param3;
            this._portalSprite.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         }
         if(param4 != null)
         {
            this._onMouseOutCallback = param4;
            this._portalSprite.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         }
      }
      
      public function addMouseListeners(param1:Object, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         this._passback = param1;
         this._onMouseDownCallback = param2;
         this._sprite.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         if(param3 != null)
         {
            this._onMouseOverCallback = param3;
            this._sprite.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         }
         if(param4 != null)
         {
            this._onMouseOutCallback = param4;
            this._sprite.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         }
      }
      
      public function removeMouseListeners() : void
      {
         this._passback = null;
         this._onMouseDownCallback = null;
         this._sprite.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         if(this._onMouseOverCallback != null)
         {
            this._onMouseOverCallback = null;
            this._sprite.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         }
         if(this._onMouseOutCallback != null)
         {
            this._onMouseOutCallback = null;
            this._sprite.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
      }
      
      public function removePortalListeners() : void
      {
         this._passback = null;
         this._onMouseDownCallback = null;
         this._portalSprite.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         if(this._onMouseOverCallback != null)
         {
            this._onMouseOverCallback = null;
            this._portalSprite.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         }
         if(this._onMouseOutCallback != null)
         {
            this._onMouseOutCallback = null;
            this._portalSprite.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
      }
      
      public function getVersions() : Array
      {
         if(Boolean(this._loader) && Boolean(this._loader.content) && this._loader.content.hasOwnProperty("getVersions"))
         {
            return this._loader.content["getVersions"]();
         }
         return null;
      }
      
      public function setVersion(param1:int, param2:int = 0, param3:int = 0) : void
      {
         this._version = param1;
         if(param2 > 0)
         {
            this._version2 = param2;
         }
         if(param3 > 0)
         {
            this._version3 = param3;
         }
         if(Boolean(this._loader) && Boolean(this._loader.content))
         {
            if(this._loader.content.hasOwnProperty("setVersion"))
            {
               if(this._version == -1)
               {
                  this._version = this.getVersions()[0];
               }
               this._loader.content["setVersion"](param1);
            }
            else if(this._loader.content.hasOwnProperty("pet"))
            {
               PetManager.setPetState(MovieClip(this._loader.content),this._version,this._version2,this._version3);
            }
         }
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         var _loc2_:Object = null;
         if(param1.id == this._id && param1.success)
         {
            DenItemServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onBytesLoaded);
            param1.data.position = 0;
            _loc2_ = param1.data.readObject();
            this._sortOffset = _loc2_.so;
            this._loader.loadBytes(_loc2_.ba);
         }
      }
      
      private function onBytesLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onBytesLoaded);
         var _loc2_:int = int(this._loader.content["totalFrames"]);
         var _loc3_:Array = this._loader.content["currentLabels"];
         if(_loc2_ < 2)
         {
            this._loader.cacheAsBitmap = true;
         }
         else if(_loc3_.length >= 0)
         {
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_.name == "flip")
               {
                  this._bFlipLabel = true;
                  break;
               }
            }
            if(_loc2_ == 2)
            {
               this._loader.cacheAsBitmap = true;
            }
         }
         if(this._version == -1)
         {
            if(this._loader.content.hasOwnProperty("getVersions"))
            {
               this._version = this.getVersions()[0];
            }
            else
            {
               this._version = 0;
            }
         }
         if(this._loader.content.hasOwnProperty("setVersion") && this._version >= 0)
         {
            MovieClip(this._loader.content).setVersion(this._version);
         }
         else if(this._loader.content.hasOwnProperty("pet"))
         {
            PetManager.setPetState(MovieClip(this._loader.content),this._version,this._version2,this._version3);
         }
         if(MovieClip(this._loader.content).isMoveToDisabled)
         {
            this._loader.name = "moveToDisabled";
         }
         if(this._passback != null)
         {
            if(this._passback.specialType == DenItem.SPECIAL_TYPE_PORTAL)
            {
               this._portalSprite.addChild(MovieClip(this._loader.content).clickObject);
            }
            else if(this._passback.specialType == DenItem.SPECIAL_TYPE_EMOTE && this._loader.content.hasOwnProperty("setEmoteCallback"))
            {
               MovieClip(this._loader.content).setEmoteCallback(this.onEmoteItemClicked);
            }
         }
         this._sprite.addChild(this._loader);
         this._sprite.addChild(this._portalSprite);
         if(this._callback != null)
         {
            this._callback(this);
            this._callback = null;
         }
      }
      
      private function onEmoteItemClicked(param1:int) : void
      {
         if(Boolean(AvatarManager.playerAvatarWorldView) && !AvatarManager.playerAvatarWorldView.isThisAttachmentOn(param1))
         {
            AvatarManager.setPlayerAttachmentEmot(param1);
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(this._onMouseDownCallback != null)
         {
            this._onMouseDownCallback(param1,this._minigameDefId);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this._onMouseOverCallback != null)
         {
            this._onMouseOverCallback(param1,this._passback,this._minigameDefId);
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this._onMouseOutCallback != null)
         {
            this._onMouseOutCallback(param1);
         }
      }
   }
}

