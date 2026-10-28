package loader
{
   import avatar.AvatarManager;
   import com.sbi.loader.FileServerEvent;
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
      
      private var _nameStrId:int;
      
      private var _listLauncherId:int;
      
      private var _version:int;
      
      private var _version2:int;
      
      private var _version3:int;
      
      private var _bFlipLabel:Boolean;
      
      private var _isUniqueImageItem:Boolean;
      
      private var _uniqueImageId:String;
      
      private var _uniqueImageCreator:String;
      
      private var _masterpieceDefHelper:MasterpieceDefHelper;
      
      private var _onMouseDownCallback:Function;
      
      private var _onMouseOverCallback:Function;
      
      private var _onMouseOutCallback:Function;
      
      private var _passback:Object;
      
      private var _uniqueImage:Sprite;
      
      public function DenItemHelper()
      {
         super();
      }
      
      public function get displayObject() : Sprite
      {
         return _sprite;
      }
      
      public function get content() : DisplayObject
      {
         return _loader.content;
      }
      
      public function get sortOffset() : int
      {
         return _sortOffset;
      }
      
      public function get id() : int
      {
         return _id;
      }
      
      public function get minigameDefId() : int
      {
         return _minigameDefId;
      }
      
      public function get bFlipLabel() : Boolean
      {
         return _bFlipLabel;
      }
      
      public function get isUniqueImageItem() : Boolean
      {
         return _isUniqueImageItem;
      }
      
      public function get listLauncherId() : int
      {
         return _listLauncherId;
      }
      
      public function get nameStrId() : int
      {
         return _nameStrId;
      }
      
      public function get uniqueImage() : Sprite
      {
         return _uniqueImage;
      }
      
      public function get uniqueImageId() : String
      {
         return _uniqueImageId;
      }
      
      public function set uniqueImageId(param1:String) : void
      {
         _uniqueImageId = param1;
      }
      
      public function get uniqueImageCreator() : String
      {
         return _uniqueImageCreator;
      }
      
      public function set uniqueImageCreator(param1:String) : void
      {
         _uniqueImageCreator = param1;
      }
      
      public function init(param1:uint, param2:Function, param3:int, param4:int = 0, param5:int = 0, param6:int = 0, param7:int = 0, param8:int = 0, param9:String = "", param10:String = "") : void
      {
         _id = param1;
         _callback = param2;
         _minigameDefId = param4;
         _nameStrId = param8;
         _listLauncherId = param7;
         _bFlipLabel = false;
         _isUniqueImageItem = false;
         _version = param3;
         _version2 = param5;
         _version3 = param6;
         _loader = new Loader();
         _sprite = new Sprite();
         _portalSprite = new Sprite();
         _uniqueImage = new Sprite();
         _uniqueImageId = param9;
         _uniqueImageCreator = param10;
         DenItemServer.instance.addEventListener("OnNewData",handleData,false,0,true);
         DenItemServer.instance.requestFile(_id);
      }
      
      public function destroy() : void
      {
         DenItemServer.instance.removeEventListener("OnNewData",handleData);
         if(_loader)
         {
            if(_loader.parent)
            {
               _loader.parent.removeChild(_loader);
            }
            _loader.unloadAndStop(true);
         }
         _callback = null;
         _sprite = null;
      }
      
      public function loadUniqueImage() : void
      {
         if(_loader && _loader.content.hasOwnProperty("setUniqueImage"))
         {
            _isUniqueImageItem = true;
            if(_uniqueImageId != "")
            {
               _masterpieceDefHelper = new MasterpieceDefHelper();
               _masterpieceDefHelper.init(_uniqueImageId,onUniqueImageIdLoaded);
            }
         }
      }
      
      public function setupItemWithEmotes(param1:Object) : void
      {
         _passback = param1;
      }
      
      public function addPortalListeners(param1:Object, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         _passback = param1;
         _onMouseDownCallback = param2;
         _portalSprite.addEventListener("mouseDown",onMouseDown,false,0,true);
         if(param3 != null)
         {
            _onMouseOverCallback = param3;
            _portalSprite.addEventListener("mouseOver",onMouseOver,false,0,true);
         }
         if(param4 != null)
         {
            _onMouseOutCallback = param4;
            _portalSprite.addEventListener("mouseOut",onMouseOut,false,0,true);
         }
      }
      
      public function addMouseListeners(param1:Object, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         _passback = param1;
         _onMouseDownCallback = param2;
         _sprite.addEventListener("mouseDown",onMouseDown,false,0,true);
         if(param3 != null)
         {
            _onMouseOverCallback = param3;
            _sprite.addEventListener("mouseOver",onMouseOver,false,0,true);
         }
         if(param4 != null)
         {
            _onMouseOutCallback = param4;
            _sprite.addEventListener("mouseOut",onMouseOut,false,0,true);
         }
      }
      
      public function removeMouseListeners() : void
      {
         _passback = null;
         _onMouseDownCallback = null;
         _sprite.removeEventListener("mouseDown",onMouseDown);
         if(_onMouseOverCallback != null)
         {
            _onMouseOverCallback = null;
            _sprite.removeEventListener("mouseOver",onMouseOver);
         }
         if(_onMouseOutCallback != null)
         {
            _onMouseOutCallback = null;
            _sprite.removeEventListener("mouseOut",onMouseOut);
         }
      }
      
      public function removePortalListeners() : void
      {
         _passback = null;
         _onMouseDownCallback = null;
         _portalSprite.removeEventListener("mouseDown",onMouseDown);
         if(_onMouseOverCallback != null)
         {
            _onMouseOverCallback = null;
            _portalSprite.removeEventListener("mouseOver",onMouseOver);
         }
         if(_onMouseOutCallback != null)
         {
            _onMouseOutCallback = null;
            _portalSprite.removeEventListener("mouseOut",onMouseOut);
         }
      }
      
      public function getVersions() : Array
      {
         if(_loader && _loader.content && _loader.content.hasOwnProperty("getVersions"))
         {
            return _loader.content["getVersions"]();
         }
         return null;
      }
      
      public function setVersion(param1:int, param2:int = 0, param3:int = 0) : void
      {
         _version = param1;
         if(param2 > 0)
         {
            _version2 = param2;
         }
         if(param3 > 0)
         {
            _version3 = param3;
         }
         if(_loader && _loader.content)
         {
            if(_loader.content.hasOwnProperty("setVersion"))
            {
               if(_version == -1)
               {
                  _version = getVersions()[0];
               }
               _loader.content["setVersion"](param1);
            }
            else if(_loader.content.hasOwnProperty("pet"))
            {
               PetManager.setPetState(MovieClip(_loader.content),_version,_version2,_version3);
            }
         }
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         var _loc2_:Object = null;
         if(param1.id == _id && param1.success)
         {
            DenItemServer.instance.removeEventListener("OnNewData",handleData);
            _loader.contentLoaderInfo.addEventListener("complete",onBytesLoaded);
            param1.data.position = 0;
            _loc2_ = param1.data.readObject();
            _sortOffset = _loc2_.so;
            _loader.loadBytes(_loc2_.ba);
         }
      }
      
      private function onBytesLoaded(param1:Event) : void
      {
         _loader.contentLoaderInfo.removeEventListener("complete",onBytesLoaded);
         var _loc2_:int = int(_loader.content["totalFrames"]);
         var _loc3_:Array = _loader.content["currentLabels"];
         if(_loc2_ < 2)
         {
            _loader.cacheAsBitmap = true;
         }
         else if(_loc3_.length >= 0)
         {
            for each(var _loc4_:Object in _loc3_)
            {
               if(_loc4_.name == "flip")
               {
                  _bFlipLabel = true;
                  break;
               }
            }
            if(_loc2_ == 2)
            {
               _loader.cacheAsBitmap = true;
            }
         }
         if(_version == -1)
         {
            if(_loader.content.hasOwnProperty("getVersions"))
            {
               _version = getVersions()[0];
            }
            else
            {
               _version = 0;
            }
         }
         if(_loader.content.hasOwnProperty("setVersion") && _version >= 0)
         {
            MovieClip(_loader.content).setVersion(_version);
         }
         else if(_loader.content.hasOwnProperty("pet"))
         {
            PetManager.setPetState(MovieClip(_loader.content),_version,_version2,_version3);
         }
         if(MovieClip(_loader.content).isMoveToDisabled)
         {
            _loader.name = "moveToDisabled";
         }
         if(_passback != null)
         {
            if(_passback.specialType == 1)
            {
               _portalSprite.addChild(MovieClip(_loader.content).clickObject);
            }
            else if(_passback.specialType == 2 && _loader.content.hasOwnProperty("setEmoteCallback"))
            {
               MovieClip(_loader.content).setEmoteCallback(onEmoteItemClicked);
            }
         }
         if(_loader.content.hasOwnProperty("setUniqueImage"))
         {
            _isUniqueImageItem = true;
            if(_uniqueImageId != "")
            {
               _masterpieceDefHelper = new MasterpieceDefHelper();
               _masterpieceDefHelper.init(_uniqueImageId,onUniqueImageIdLoaded);
            }
         }
         _sprite.addChild(_loader);
         _sprite.addChild(_portalSprite);
         if(_callback != null)
         {
            _callback(this);
            _callback = null;
         }
      }
      
      private function onUniqueImageIdLoaded(param1:Sprite) : void
      {
         _masterpieceDefHelper.destroy();
         _masterpieceDefHelper = null;
         _uniqueImage.addChild(param1);
         MovieClip(_loader.content).setUniqueImage(_uniqueImage);
      }
      
      private function onEmoteItemClicked(param1:int) : void
      {
         if(AvatarManager.playerAvatarWorldView && !AvatarManager.playerAvatarWorldView.isThisAttachmentOn(param1))
         {
            AvatarManager.setPlayerAttachmentEmot(param1);
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(_onMouseDownCallback != null)
         {
            _onMouseDownCallback(param1,_minigameDefId,_listLauncherId,_uniqueImageId,_version,_uniqueImageCreator,_isUniqueImageItem);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(_onMouseOverCallback != null)
         {
            _onMouseOverCallback(param1,_passback,_minigameDefId,_listLauncherId,_uniqueImageId,_version,_uniqueImageCreator,_isUniqueImageItem);
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(_onMouseOutCallback != null)
         {
            _onMouseOutCallback(param1);
         }
      }
   }
}

