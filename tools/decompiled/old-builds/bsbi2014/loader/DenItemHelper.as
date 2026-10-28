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
      
      public function init(id:uint, callback:Function, version:int, mgDefId:int = 0, version2:int = 0, version3:int = 0) : void
      {
         this._id = id;
         this._callback = callback;
         this._minigameDefId = mgDefId;
         this._bFlipLabel = false;
         this._version = version;
         this._version2 = version2;
         this._version3 = version3;
         this._loader = new Loader();
         this._sprite = new Sprite();
         this._portalSprite = new Sprite();
         DenItemServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleData,false,0,true);
         DenItemServer.instance.requestFile(this._id);
      }
      
      public function destroy() : void
      {
         DenItemServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
         if(Boolean(this._loader))
         {
            if(Boolean(this._loader.parent))
            {
               this._loader.parent.removeChild(this._loader);
            }
            this._loader.unloadAndStop(true);
         }
         this._callback = null;
         this._sprite = null;
      }
      
      public function setupItemWithEmotes(passback:Object) : void
      {
         this._passback = passback;
      }
      
      public function addPortalListeners(passback:Object, downCallback:Function, overCallback:Function = null, outCallback:Function = null) : void
      {
         this._passback = passback;
         this._onMouseDownCallback = downCallback;
         this._portalSprite.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         if(overCallback != null)
         {
            this._onMouseOverCallback = overCallback;
            this._portalSprite.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         }
         if(outCallback != null)
         {
            this._onMouseOutCallback = outCallback;
            this._portalSprite.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         }
      }
      
      public function addMouseListeners(passback:Object, downCallback:Function, overCallback:Function = null, outCallback:Function = null) : void
      {
         this._passback = passback;
         this._onMouseDownCallback = downCallback;
         this._sprite.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         if(overCallback != null)
         {
            this._onMouseOverCallback = overCallback;
            this._sprite.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         }
         if(outCallback != null)
         {
            this._onMouseOutCallback = outCallback;
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
      
      public function setVersion(version:int, version2:int = 0, version3:int = 0) : void
      {
         this._version = version;
         if(version2 > 0)
         {
            this._version2 = version2;
         }
         if(version3 > 0)
         {
            this._version3 = version3;
         }
         if(Boolean(this._loader) && Boolean(this._loader.content))
         {
            if(this._loader.content.hasOwnProperty("setVersion"))
            {
               if(this._version == -1)
               {
                  this._version = this.getVersions()[0];
               }
               this._loader.content["setVersion"](version);
            }
            else if(this._loader.content.hasOwnProperty("pet"))
            {
               PetManager.setPetState(MovieClip(this._loader.content),this._version,this._version2,this._version3);
            }
         }
      }
      
      private function handleData(fse:FileServerEvent) : void
      {
         var o:Object = null;
         if(fse.id == this._id && fse.success)
         {
            DenItemServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onBytesLoaded);
            fse.data.position = 0;
            o = fse.data.readObject();
            this._sortOffset = o.so;
            this._loader.loadBytes(o.ba);
         }
      }
      
      private function onBytesLoaded(evt:Event) : void
      {
         var o:Object = null;
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onBytesLoaded);
         var totalFrames:int = int(this._loader.content["totalFrames"]);
         var labels:Array = this._loader.content["currentLabels"];
         if(totalFrames < 2)
         {
            this._loader.cacheAsBitmap = true;
         }
         else if(labels.length >= 0)
         {
            for each(o in labels)
            {
               if(o.name == "flip")
               {
                  this._bFlipLabel = true;
                  break;
               }
            }
            if(totalFrames == 2)
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
         if(Boolean(MovieClip(this._loader.content).isMoveToDisabled))
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
      
      private function onEmoteItemClicked(idToShow:int) : void
      {
         if(Boolean(AvatarManager.playerAvatarWorldView) && !AvatarManager.playerAvatarWorldView.isThisAttachmentOn(idToShow))
         {
            AvatarManager.setPlayerAttachmentEmot(idToShow);
         }
      }
      
      private function onMouseDown(evt:MouseEvent) : void
      {
         if(this._onMouseDownCallback != null)
         {
            this._onMouseDownCallback(evt,this._minigameDefId);
         }
      }
      
      private function onMouseOver(evt:MouseEvent) : void
      {
         if(this._onMouseOverCallback != null)
         {
            this._onMouseOverCallback(evt,this._passback,this._minigameDefId);
         }
      }
      
      private function onMouseOut(evt:MouseEvent) : void
      {
         if(this._onMouseOutCallback != null)
         {
            this._onMouseOutCallback(evt);
         }
      }
   }
}

