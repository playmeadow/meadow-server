package room
{
   import com.sbi.graphics.SortLayer;
   import den.DenItem;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import game.MinigameManager;
   import gui.GuiManager;
   import loader.DenItemHelper;
   
   public class DenItemHolder extends EventDispatcher
   {
      
      private const MOUSE_DOWN_TYPE:int = 0;
      
      private const MOUSE_OVER_TYPE:int = 1;
      
      private const MOUSE_OUT_TYPE:int = 2;
      
      private var _currItems:Array;
      
      private var _itemsInit:Array;
      
      private var _layerManager:LayerManager;
      
      private var _dragItem:Object;
      
      private var _itemFilter:Object;
      
      private var _dragPoint:Point;
      
      private var _closeBtn:MovieClip;
      
      private var _flipBtn:MovieClip;
      
      private var _themePos:Point;
      
      private var _isWaitingToSetItemsForFirstTime:Boolean;
      
      private var _roomMode:int;
      
      public function DenItemHolder(param1:LayerManager)
      {
         super();
         this._themePos = new Point();
         this._dragPoint = new Point();
         this._layerManager = param1;
         this._closeBtn = new (getDefinitionByName("closeBtn") as Class)();
         this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
         this._flipBtn = new (getDefinitionByName("itemRotateBtnCont") as Class)();
         this._flipBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onFlipBtn,false,0,true);
         this.release();
      }
      
      public function release() : void
      {
         var _loc1_:Object = null;
         this._isWaitingToSetItemsForFirstTime = true;
         if(this._currItems)
         {
            for each(_loc1_ in this._currItems)
            {
               if(_loc1_.di)
               {
                  _loc1_.di.destroy();
               }
            }
         }
         this._currItems = [];
         this._itemsInit = [];
         this._dragItem = null;
         this.updateCloseBtn();
      }
      
      public function get numberOfInUseItems() : int
      {
         return this._currItems.length;
      }
      
      public function get isDragging() : Boolean
      {
         return this._dragItem != null;
      }
      
      public function setItems(param1:Array, param2:Boolean = false) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(this._isWaitingToSetItemsForFirstTime && param2)
         {
            this._isWaitingToSetItemsForFirstTime = false;
         }
         var _loc6_:int = 0;
         while(_loc6_ < param1.length)
         {
            _loc3_ = param1[_loc6_];
            if(_loc3_)
            {
               if(_loc3_.c > 0)
               {
                  _loc5_ = false;
                  for each(_loc4_ in this._currItems)
                  {
                     if(_loc3_.r == _loc4_.r && _loc3_.i == _loc4_.i)
                     {
                        _loc4_.f = _loc3_.f;
                        _loc8_ = Number(_loc3_.x) + Number(_loc4_.offX);
                        _loc9_ = Number(_loc3_.y) + Number(_loc4_.offY);
                        this.setItemMatrix(_loc4_,_loc8_,_loc9_,_loc4_.f);
                        if(_loc4_.s == DenItem.SORT_PET && Boolean(_loc4_.di))
                        {
                           _loc4_.di.setVersion(_loc3_.v,_loc3_.v2,_loc3_.v3);
                        }
                        _loc5_ = true;
                        break;
                     }
                  }
                  if(!_loc5_)
                  {
                     this.setItem(_loc3_.i,_loc3_.p,_loc3_.x,_loc3_.y,_loc3_.l,_loc3_.c,_loc3_.s,_loc3_.f,_loc3_.mg,_loc3_.v,_loc3_.v2,_loc3_.v3,_loc3_.strmName,_loc3_.r,param2);
                  }
               }
               else
               {
                  for each(_loc4_ in this._currItems)
                  {
                     if(_loc3_.r == _loc4_.r && _loc3_.i == _loc4_.i)
                     {
                        this.releaseItem(_loc4_,param2);
                        break;
                     }
                  }
               }
            }
            _loc6_++;
         }
         for each(_loc3_ in this._currItems)
         {
            if(_loc3_.s == DenItem.SORT_AUDIO)
            {
               _loc7_ = true;
               break;
            }
         }
         if(!_loc7_)
         {
            this.setItem(DenItem.DEF_AUDIO_INVIDX,DenItem.DEF_AUDIO_PACKED_ID,0,0,0,DenItem.PLACE_CAT_ICONL,DenItem.SORT_AUDIO,0,0,0,DenItem.DEF_AUDIO_VOL,0,DenItem.DEF_AUDIO_STRMNAME,DenItem.REF_ID_DEN_ITEM,param2);
         }
         if(this._isWaitingToSetItemsForFirstTime)
         {
            this._isWaitingToSetItemsForFirstTime = false;
         }
      }
      
      public function removeItem(param1:int, param2:int) : void
      {
         var _loc3_:Object = null;
         for each(_loc3_ in this._currItems)
         {
            if(_loc3_.r == param2 && _loc3_.i == param1)
            {
               this.releaseItem(_loc3_);
               break;
            }
         }
      }
      
      public function saveState() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Boolean = false;
         var _loc5_:DenItemHolderEvent = null;
         var _loc6_:Array = null;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc1_:Array = [];
         for each(_loc2_ in this._itemsInit)
         {
            _loc4_ = false;
            for each(_loc3_ in this._currItems)
            {
               if(_loc3_.r == _loc2_.r && _loc3_.i == _loc2_.i)
               {
                  _loc4_ = true;
                  if(_loc3_.s != DenItem.SORT_AUDIO && (_loc3_.x != _loc2_.x || _loc3_.y != _loc2_.y || _loc3_.f != _loc2_.f))
                  {
                     _loc1_.push({
                        "di":_loc3_.di,
                        "f":_loc3_.f,
                        "i":_loc3_.i,
                        "x":_loc3_.x,
                        "s":_loc3_.s,
                        "y":_loc3_.y,
                        "offX":_loc3_.offX,
                        "offY":_loc3_.offY,
                        "r":_loc3_.r
                     });
                  }
                  break;
               }
            }
            if(!_loc4_)
            {
               _loc1_.push({
                  "f":0,
                  "i":_loc2_.i,
                  "s":_loc2_.s,
                  "x":0,
                  "y":0,
                  "d":0,
                  "r":_loc2_.r
               });
            }
         }
         for each(_loc3_ in this._currItems)
         {
            _loc4_ = false;
            for each(_loc2_ in this._itemsInit)
            {
               if(_loc2_.r == _loc3_.r && _loc2_.i == _loc3_.i)
               {
                  _loc4_ = true;
                  break;
               }
            }
            if(!_loc4_)
            {
               _loc1_.push({
                  "f":_loc3_.f,
                  "di":_loc3_.di,
                  "i":_loc3_.i,
                  "s":_loc3_.s,
                  "x":_loc3_.x,
                  "y":_loc3_.y,
                  "offX":_loc3_.offX,
                  "offY":_loc3_.offY,
                  "r":_loc3_.r
               });
            }
         }
         if(_loc1_.length > 0)
         {
            this.updateInitialState();
            _loc5_ = new DenItemHolderEvent(DenItemHolderEvent.SAVE_STATE);
            _loc6_ = new Array();
            for each(_loc7_ in _loc1_)
            {
               if(_loc7_.i != -1)
               {
                  if(_loc7_.di)
                  {
                     _loc9_ = int(_loc7_.x - _loc7_.offX);
                     _loc10_ = int(_loc7_.y - _loc7_.offY);
                     _loc8_ = {
                        "i":_loc7_.i,
                        "s":_loc7_.s,
                        "d":1,
                        "x":_loc9_,
                        "y":_loc10_,
                        "f":_loc7_.f,
                        "r":_loc7_.r
                     };
                  }
                  else
                  {
                     _loc8_ = {
                        "i":_loc7_.i,
                        "s":_loc7_.s,
                        "d":0,
                        "x":0,
                        "y":0,
                        "f":0,
                        "r":_loc7_.r
                     };
                  }
                  _loc6_.push(_loc8_);
               }
            }
            _loc5_.array = _loc6_;
            dispatchEvent(_loc5_);
         }
      }
      
      public function removeHighlightState() : void
      {
         if(this._closeBtn.parent)
         {
            this._closeBtn.parent.removeChild(this._closeBtn);
         }
         if(this._flipBtn.parent)
         {
            this._flipBtn.parent.removeChild(this._flipBtn);
         }
         if(this._itemFilter)
         {
            if(this._itemFilter.di.displayObject)
            {
               this._itemFilter.di.displayObject.filters = [];
            }
            this._itemFilter = null;
         }
      }
      
      private function updateInitialState() : void
      {
         var _loc1_:Object = null;
         this._itemsInit = [];
         for each(_loc1_ in this._currItems)
         {
            this._itemsInit.push({
               "c":_loc1_.c,
               "di":_loc1_.di,
               "l":_loc1_.l,
               "i":_loc1_.i,
               "f":_loc1_.f,
               "s":_loc1_.x,
               "x":_loc1_.x,
               "y":_loc1_.y,
               "offX":_loc1_.offX,
               "offY":_loc1_.offY,
               "r":_loc1_.r
            });
         }
      }
      
      public function handleMouse(param1:Number, param2:Number, param3:Boolean) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param3)
         {
            if(this._dragItem)
            {
               _loc4_ = this._dragItem.x + param1 - this._dragPoint.x;
               _loc5_ = this._dragItem.y + param2 - this._dragPoint.y;
               this.setItemMatrix(this._dragItem,_loc4_,_loc5_,this._dragItem.f);
               this.setBtnPos(_loc4_ + this._dragItem.di.displayObject.width - 30,_loc5_);
               this._dragPoint.x = param1;
               this._dragPoint.y = param2;
            }
         }
         else
         {
            this._dragItem = this.hitTest(param1,param2);
            if(this._dragItem)
            {
               this._dragPoint.x = param1;
               this._dragPoint.y = param2;
            }
            this.updateCloseBtn();
         }
      }
      
      public function setThemePosition(param1:int, param2:int) : void
      {
         this._themePos = new Point(param1,param2);
      }
      
      public function setRoomMode(param1:int) : void
      {
         this._roomMode = param1;
         this.stopListenersOnPets(this._roomMode == RoomManagerWorld.ROOM_MODE_DEN);
         this.stopMouseOnNonMouseItems(this._roomMode == RoomManagerWorld.ROOM_MODE_DEN);
      }
      
      public function stopListenersOnPets(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this._currItems)
         {
            if(Boolean(_loc2_.di) && Boolean(_loc2_.di.content) && Boolean(_loc2_.di.content.hasOwnProperty("listenToMouse")))
            {
               _loc2_.di.content.listenToMouse = !param1;
            }
         }
      }
      
      public function stopMouseOnNonMouseItems(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this._currItems)
         {
            if(Boolean(_loc2_.di) && Boolean(_loc2_.di.content) && Boolean(_loc2_.di.content.hasOwnProperty("ignoreMouseCompletely")) && Boolean(_loc2_.di.displayObject))
            {
               Sprite(_loc2_.di.displayObject).mouseEnabled = !param1;
               Sprite(_loc2_.di.displayObject).mouseChildren = !param1;
            }
         }
      }
      
      public function shouldStopMovement(param1:Point) : Boolean
      {
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc2_:int = int(this._currItems.length);
         if(_loc2_ > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc3_ = this._currItems[_loc5_];
               if(!this.isTheme(_loc3_.s) && _loc3_.s != DenItem.SORT_AUDIO)
               {
                  if(_loc3_.di.displayObject.numChildren > 0)
                  {
                     _loc4_ = _loc3_.di.displayObject.getChildAt(0).content;
                     if(_loc4_.parent.name == "moveToDisabled")
                     {
                        if(_loc4_.hitTestPoint(param1.x,param1.y,true))
                        {
                           return true;
                        }
                     }
                  }
               }
               _loc5_++;
            }
         }
         return false;
      }
      
      private function isTheme(param1:int) : Boolean
      {
         return param1 > 1 && param1 < 4;
      }
      
      private function setItem(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int, param10:int, param11:int, param12:int, param13:String, param14:int, param15:Boolean) : void
      {
         var _loc20_:Object = null;
         var _loc21_:DenItemHolderEvent = null;
         var _loc22_:Object = null;
         var _loc23_:DenItemHolderEvent = null;
         var _loc16_:int = param7 == DenItem.SORT_PET ? param11 : 0;
         var _loc17_:int = param7 == DenItem.SORT_PET ? param12 : 0;
         var _loc18_:DenItemHelper = new DenItemHelper();
         _loc18_.init(param2,this.itemLoaded,param10,param9,_loc16_,_loc17_);
         if(this.isTheme(param7))
         {
            for each(_loc20_ in this._currItems)
            {
               if(_loc20_.s == param7)
               {
                  this.releaseItem(_loc20_);
                  _loc21_ = new DenItemHolderEvent(DenItemHolderEvent.ITEM_REMOVED);
                  _loc21_.id = _loc20_.i;
                  _loc21_.refId = _loc20_.r;
                  _loc21_.array = [_loc20_];
                  dispatchEvent(_loc21_);
                  break;
               }
            }
         }
         else if(param7 == DenItem.SORT_AUDIO)
         {
            for each(_loc22_ in this._currItems)
            {
               if(_loc22_.s == param7)
               {
                  this.releaseItem(_loc22_);
                  _loc23_ = new DenItemHolderEvent(DenItemHolderEvent.ITEM_REMOVED);
                  _loc23_.id = _loc22_.i;
                  _loc23_.refId = _loc22_.r;
                  _loc23_.array = [_loc22_];
                  dispatchEvent(_loc23_);
                  break;
               }
            }
            RoomManagerWorld.instance.playMusic(param13 + ".mp3",param11 / 100);
         }
         var _loc19_:Object = {
            "c":param6,
            "s":param7,
            "di":_loc18_,
            "f":param8,
            "i":param1,
            "l":param5,
            "x":param3,
            "y":param4,
            "r":param14,
            "bNewPlaced":param15
         };
         this._currItems.push(_loc19_);
         if(this._roomMode == RoomManagerWorld.ROOM_MODE_DEN)
         {
            if(Boolean(_loc19_.di) && Boolean(_loc19_.di.content) && Boolean(_loc19_.di.content.hasOwnProperty("listenToMouse")))
            {
               _loc19_.di.content.listenToMouse = false;
            }
         }
         else if(Boolean(_loc19_.di) && Boolean(_loc19_.di.displayObject) && Boolean(_loc19_.di.content) && Boolean(_loc19_.di.content.hasOwnProperty("ignoreMouseCompletely")))
         {
            Sprite(_loc19_.di.displayObject).mouseEnabled = false;
            Sprite(_loc19_.di.displayObject).mouseChildren = false;
         }
         if(param9 > 0)
         {
            this.addListenersToItem(_loc18_,_loc19_);
         }
         if(this._isWaitingToSetItemsForFirstTime || !param15)
         {
            this._itemsInit.push({
               "c":_loc19_.c,
               "s":_loc19_.s,
               "di":_loc19_.di,
               "f":_loc19_.f,
               "i":_loc19_.i,
               "l":_loc19_.l,
               "x":_loc19_.x,
               "y":_loc19_.y,
               "r":param14,
               "bNewPlaced":_loc19_.bNewPlaced
            });
         }
      }
      
      private function updateCloseBtn() : void
      {
         var _loc1_:Sprite = null;
         if(this._dragItem)
         {
            _loc1_ = this._dragItem.di.displayObject;
            if(this._closeBtn.parent != _loc1_)
            {
               this.setBtnPos(this._dragItem.x + _loc1_.width - 30,this._dragItem.y);
               this._layerManager.room_chat.addChild(this._closeBtn);
               this._layerManager.room_chat.addChild(this._flipBtn);
            }
            if(this._itemFilter != this._dragItem)
            {
               if(this._itemFilter)
               {
                  this._itemFilter.di.displayObject.filters = [];
               }
               this._itemFilter = this._dragItem;
               this._itemFilter.di.displayObject.filters = [new GlowFilter(16777215,1,8,8,8)];
            }
         }
         else
         {
            if(this._closeBtn.parent)
            {
               this._closeBtn.parent.removeChild(this._closeBtn);
            }
            if(this._flipBtn.parent)
            {
               this._flipBtn.parent.removeChild(this._flipBtn);
            }
            if(this._itemFilter)
            {
               if(this._itemFilter.di.displayObject)
               {
                  this._itemFilter.di.displayObject.filters = [];
               }
               this._itemFilter = null;
            }
         }
      }
      
      private function setBtnPos(param1:Number, param2:Number) : void
      {
         this._closeBtn.x = param1;
         this._closeBtn.y = param2;
         this._flipBtn.x = param1 + 15;
         this._flipBtn.y = param2 + 55;
      }
      
      private function onCloseBtn(param1:Event) : void
      {
         var _loc2_:DenItemHolderEvent = null;
         param1.stopPropagation();
         if(this._dragItem)
         {
            _loc2_ = new DenItemHolderEvent(DenItemHolderEvent.ITEM_REMOVED);
            _loc2_.id = this._dragItem.i;
            _loc2_.refId = this._dragItem.r;
            _loc2_.array = [this._dragItem];
            this.releaseItem(this._dragItem);
            this._dragItem = null;
            this.updateCloseBtn();
            dispatchEvent(_loc2_);
         }
      }
      
      private function onFlipBtn(param1:Event) : void
      {
         param1.stopPropagation();
         if(this._dragItem)
         {
            this._dragItem.f = this._dragItem.f == 0 ? 1 : 0;
            this.setItemMatrix(this._dragItem,this._dragItem.x,this._dragItem.y,this._dragItem.f);
         }
      }
      
      private function isInInitList(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         while(_loc3_ < this._itemsInit.length)
         {
            if(this._itemsInit[_loc3_].refId == param2 && this._itemsInit[_loc3_].i == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function releaseItem(param1:Object, param2:Boolean = true) : void
      {
         var _loc3_:int = this._currItems.indexOf(param1);
         if(_loc3_ >= 0)
         {
            this._currItems.splice(_loc3_,1);
            if(param1.di)
            {
               if(param1.di.displayObject.parent)
               {
                  param1.di.displayObject.parent.removeChild(param1.di.displayObject);
               }
               if(param1.di.minigameDefId > 0)
               {
                  this.removeListenersFromItem(param1.di);
               }
            }
         }
         if(!param2)
         {
            _loc3_ = 0;
            while(_loc3_ < this._itemsInit.length)
            {
               if(this._itemsInit[_loc3_].i == param1.i)
               {
                  this._itemsInit.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private function setItemMatrix(param1:Object, param2:Number, param3:Number, param4:int = 0) : void
      {
         var _loc9_:Sprite = null;
         var _loc10_:Loader = null;
         var _loc11_:MovieClip = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc5_:DisplayObject = param1.di.displayObject;
         param1.x = param2;
         param1.y = param3;
         var _loc6_:Matrix = _loc5_.transform.matrix;
         _loc6_.identity();
         var _loc7_:Number = param2;
         var _loc8_:Number = param3;
         if(param1.di.bFlipLabel)
         {
            _loc9_ = _loc5_ as Sprite;
            _loc10_ = _loc9_.getChildAt(0) as Loader;
            _loc11_ = _loc10_.content as MovieClip;
            _loc11_.gotoAndStop(param4 ? "flip" : 1);
         }
         else if(param4)
         {
            _loc12_ = 1;
            _loc13_ = 1;
            _loc12_ *= -1;
            _loc7_ += _loc5_.width;
            _loc6_.scale(_loc12_,_loc13_);
         }
         _loc6_.translate(_loc7_,_loc8_);
         _loc5_.transform.matrix = _loc6_;
      }
      
      private function hitTest(param1:int, param2:int) : Object
      {
         var _loc5_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:DisplayObject = null;
         var _loc10_:Rectangle = null;
         var _loc11_:Number = NaN;
         var _loc3_:Number = -999999999;
         var _loc4_:int = 99999999;
         var _loc6_:int = int(this._currItems.length);
         while(_loc7_ < _loc6_)
         {
            _loc8_ = this._currItems[_loc7_];
            if(!this.isTheme(_loc8_.s))
            {
               _loc9_ = _loc8_.di.displayObject;
               _loc10_ = _loc9_.getBounds(this._layerManager.room_avatars);
               _loc11_ = _loc10_.bottom - Number(_loc9_.name);
               if(param1 > _loc10_.left && param1 < _loc10_.right && param2 > _loc10_.top && param2 < _loc10_.bottom)
               {
                  if(_loc8_.l <= _loc4_)
                  {
                     if(_loc8_.l == 1 || _loc11_ > _loc3_)
                     {
                        _loc4_ = int(_loc8_.l);
                        _loc3_ = _loc11_;
                        _loc5_ = _loc8_;
                        if(_loc4_ == 1)
                        {
                           _loc3_ = -999999999;
                        }
                     }
                  }
               }
            }
            _loc7_++;
         }
         return _loc5_;
      }
      
      private function itemLoaded(param1:DenItemHelper) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:DisplayObject = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:SortLayer = null;
         for each(_loc3_ in this._currItems)
         {
            if(_loc3_.di == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(_loc2_)
         {
            _loc4_ = param1.displayObject;
            _loc2_.offX = -(_loc4_.width * 0.5);
            _loc2_.offY = -_loc4_.height;
            _loc5_ = _loc2_.x + _loc2_.offX;
            _loc6_ = _loc2_.y + _loc2_.offY;
            if(_loc2_.bNewPlaced)
            {
               _loc6_ += _loc4_.height * 0.5;
               _loc2_.bNewPlaced = false;
            }
            if(this._roomMode == RoomManagerWorld.ROOM_MODE_DEN)
            {
               if(Boolean(_loc2_.di) && Boolean(_loc2_.di.content) && Boolean(_loc2_.di.content.hasOwnProperty("listenToMouse")))
               {
                  _loc2_.di.content.listenToMouse = false;
               }
            }
            else if(Boolean(_loc4_) && Boolean(_loc2_.di) && Boolean(_loc2_.di.content) && Boolean(_loc2_.di.content.hasOwnProperty("ignoreMouseCompletely")))
            {
               Sprite(_loc4_).mouseEnabled = false;
               Sprite(_loc4_).mouseChildren = false;
            }
            _loc8_ = int(_loc2_.l);
            this.setItemMatrix(_loc2_,_loc5_,_loc6_,_loc2_.f);
            if(this.isTheme(_loc2_.s))
            {
               _loc8_ = 100;
               _loc4_.x = 0;
               _loc4_.y = 0;
               this.setItemMatrix(_loc2_,0,0);
            }
            for each(_loc9_ in this._itemsInit)
            {
               if(_loc2_.r == _loc9_.r && _loc2_.i == _loc9_.i)
               {
                  if(_loc2_.x != _loc9_.x || _loc2_.y != _loc9_.y)
                  {
                     _loc9_.x = _loc2_.x;
                     _loc9_.y = _loc2_.y;
                     _loc9_.offX = _loc2_.offX;
                     _loc9_.offY = _loc2_.offY;
                     break;
                  }
               }
            }
            switch(_loc8_)
            {
               default:
                  _loc7_ = param1.sortOffset;
                  _loc10_ = this._layerManager.room_avatars;
                  if(_loc7_)
                  {
                     _loc4_.name = String(_loc7_);
                  }
                  _loc10_.addChild(_loc4_);
                  break;
               case 1:
                  this._layerManager.room_bkg_main.addChild(_loc4_);
                  break;
               case 100:
                  this._layerManager.room_bkg_main.addChildAt(_loc4_,0);
            }
         }
      }
      
      private function addListenersToItem(param1:DenItemHelper, param2:Object) : void
      {
         param1.addMouseListeners(param2,this.onItemDown,this.onItemOver,this.onItemOut);
      }
      
      private function removeListenersFromItem(param1:DenItemHelper) : void
      {
         param1.removeMouseListeners();
      }
      
      private function onItemDown(param1:MouseEvent, param2:int) : void
      {
         if(this._roomMode != RoomManagerWorld.ROOM_MODE_AVATAR)
         {
            return;
         }
         param1.stopPropagation();
         this.sendMouseEvent(param1);
         var _loc3_:Object = {"typeDefId":param2};
         MinigameManager.handleGameClick(_loc3_,null);
      }
      
      private function onItemOver(param1:MouseEvent, param2:Object, param3:int) : void
      {
         if(this._roomMode != RoomManagerWorld.ROOM_MODE_AVATAR)
         {
            return;
         }
         param1.stopPropagation();
         this.sendMouseEvent(param1);
         var _loc4_:Sprite = Sprite(param1.currentTarget);
         GuiManager.toolTip.init(this._layerManager.room_orbs,MinigameManager.getGameName(param3),param2.x + _loc4_.width * 0.5,param2.y + _loc4_.height - 75);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onItemOut(param1:MouseEvent) : void
      {
         if(this._roomMode != RoomManagerWorld.ROOM_MODE_AVATAR)
         {
            return;
         }
         param1.stopPropagation();
         this.sendMouseEvent(param1);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function sendMouseEvent(param1:MouseEvent) : void
      {
         var _loc3_:Sprite = null;
         var _loc4_:Loader = null;
         var _loc5_:MovieClip = null;
         var _loc2_:int = -1;
         switch(param1.type)
         {
            case MouseEvent.MOUSE_DOWN:
               _loc2_ = this.MOUSE_DOWN_TYPE;
               break;
            case MouseEvent.MOUSE_OVER:
               _loc2_ = this.MOUSE_OVER_TYPE;
               break;
            case MouseEvent.MOUSE_OUT:
               _loc2_ = this.MOUSE_OUT_TYPE;
         }
         if(_loc2_ >= 0)
         {
            _loc3_ = Sprite(param1.currentTarget);
            _loc4_ = Loader(_loc3_.getChildAt(0));
            if(_loc4_)
            {
               _loc5_ = MovieClip(_loc4_.content);
               if(_loc5_)
               {
                  if(_loc5_.hasOwnProperty("handleMouse"))
                  {
                     _loc5_.handleMouse(_loc2_);
                  }
               }
            }
         }
      }
   }
}

