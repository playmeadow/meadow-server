package room
{
   import avatar.AvatarManager;
   import com.sbi.graphics.SortLayer;
   import flash.display.BitmapData;
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
   import game.MinigameManager;
   import gui.BuddyList;
   import gui.GuiManager;
   import loader.DenItemHelper;
   import localization.LocalizationManager;
   
   public class DenItemHolder extends EventDispatcher
   {
      
      private const MOUSE_DOWN_TYPE:int = 0;
      
      private const MOUSE_OVER_TYPE:int = 1;
      
      private const MOUSE_OUT_TYPE:int = 2;
      
      private var _currItems:Array;
      
      private var _itemsInit:Array;
      
      private var _savedDenItemHelpers:Array;
      
      private var _layerManager:LayerManager;
      
      private var _dragItem:Object;
      
      private var _itemFilter:Object;
      
      private var _dragPoint:Point;
      
      private var _closeBtn:MovieClip;
      
      private var _flipBtn:MovieClip;
      
      private var _linkBtn:MovieClip;
      
      private var _themePos:Point;
      
      private var _isWaitingToSetItemsForFirstTime:Boolean;
      
      private var _roomMode:int;
      
      private var _lastPortalInvId:int;
      
      private var _portalToEnterInvId:int;
      
      private var _portalRadiusBmpData:BitmapData;
      
      public function DenItemHolder(param1:LayerManager)
      {
         super();
         _themePos = new Point();
         _dragPoint = new Point();
         _layerManager = param1;
         _closeBtn = GETDEFINITIONBYNAME("closeBtn");
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _flipBtn = GETDEFINITIONBYNAME("itemRotateBtnCont");
         _flipBtn.addEventListener("mouseDown",onFlipBtn,false,0,true);
         _linkBtn = GETDEFINITIONBYNAME("portalLinkBtnCont");
         _linkBtn.addEventListener("mouseDown",onLinkBtn,false,0,true);
         release();
         _lastPortalInvId = -1;
      }
      
      public function release() : void
      {
         _isWaitingToSetItemsForFirstTime = true;
         if(_currItems)
         {
            for each(var _loc1_:Object in _currItems)
            {
               if(_loc1_.di)
               {
                  _loc1_.di.destroy();
               }
            }
         }
         _currItems = [];
         _itemsInit = [];
         _savedDenItemHelpers = [];
         _dragItem = null;
         updateCloseBtn();
      }
      
      public function clearDen() : void
      {
         release();
         setItem(-1,40435715,0,0,0,3,4,0,0,0,50,0,"MusDenDef",0,false,0,"",0,0);
      }
      
      public function get numberOfInitItems() : int
      {
         return _itemsInit.length;
      }
      
      public function get numberOfInUseItems() : int
      {
         return _currItems.length;
      }
      
      public function get isDragging() : Boolean
      {
         return _dragItem != null;
      }
      
      public function reloadItems() : void
      {
         var _loc1_:int = 0;
         if(_savedDenItemHelpers)
         {
            _loc1_ = 0;
            while(_loc1_ < _savedDenItemHelpers.length)
            {
               itemLoaded(_savedDenItemHelpers[_loc1_],true);
               _loc1_++;
            }
         }
      }
      
      public function setItems(param1:Array, param2:Boolean = false) : void
      {
         var _loc4_:* = null;
         var _loc5_:Object = null;
         var _loc3_:Boolean = false;
         var _loc6_:int = 0;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc7_:Boolean = false;
         if(_isWaitingToSetItemsForFirstTime && param2)
         {
            _isWaitingToSetItemsForFirstTime = false;
         }
         _loc6_ = 0;
         while(_loc6_ < param1.length)
         {
            _loc5_ = param1[_loc6_];
            if(_loc5_)
            {
               if(_loc5_.c > 0)
               {
                  _loc3_ = false;
                  for each(_loc4_ in _currItems)
                  {
                     if(_loc5_.r == _loc4_.r && _loc5_.i == _loc4_.i)
                     {
                        _loc4_.f = _loc5_.f;
                        _loc9_ = Number(_loc5_.x) + Number(_loc4_.offX);
                        _loc8_ = Number(_loc5_.y) + Number(_loc4_.offY);
                        setItemMatrix(_loc4_,_loc9_,_loc8_,_loc4_.f);
                        if(_loc4_.s == 5 && _loc4_.di)
                        {
                           _loc4_.di.setVersion(_loc5_.v,_loc5_.v2,_loc5_.v3);
                        }
                        if(_loc4_.specialType == 1)
                        {
                           _loc4_.userNameLink = _loc5_.userNameLink;
                           if(_loc4_.di && _loc4_.di.content && _loc4_.di.content.hasOwnProperty("active"))
                           {
                              if(_loc4_.userNameLink != "")
                              {
                                 _loc4_.di.content.active(true);
                              }
                              else
                              {
                                 _loc4_.di.content.active(false);
                              }
                           }
                           BuddyList.destroyInWorldBuddyList();
                        }
                        _loc3_ = true;
                        break;
                     }
                  }
                  if(!_loc3_)
                  {
                     setItem(_loc5_.i,_loc5_.p,_loc5_.x,_loc5_.y,_loc5_.l,_loc5_.c,_loc5_.s,_loc5_.f,_loc5_.mg,_loc5_.v,_loc5_.v2,_loc5_.v3,_loc5_.strmName,_loc5_.r,param2,_loc5_.specialType,_loc5_.userNameLink,_loc5_.listLauncherId,_loc5_.nameStrId);
                  }
               }
               else
               {
                  for each(_loc4_ in _currItems)
                  {
                     if(_loc5_.r == _loc4_.r && _loc5_.i == _loc4_.i)
                     {
                        releaseItem(_loc4_,param2);
                        break;
                     }
                  }
               }
            }
            _loc6_++;
         }
         for each(_loc5_ in _currItems)
         {
            if(_loc5_.s == 4)
            {
               _loc7_ = true;
               break;
            }
         }
         if(!_loc7_)
         {
            setItem(-1,40435715,0,0,0,3,4,0,0,0,50,0,"MusDenDef",0,param2,0,"",0,0);
         }
         if(!param2)
         {
            updateInitialState();
         }
         if(_isWaitingToSetItemsForFirstTime)
         {
            _isWaitingToSetItemsForFirstTime = false;
         }
      }
      
      public function removeItem(param1:int, param2:int) : void
      {
         for each(var _loc3_:Object in _currItems)
         {
            if(_loc3_.r == param2 && _loc3_.i == param1)
            {
               releaseItem(_loc3_);
               break;
            }
         }
      }
      
      public function saveState() : void
      {
         var _loc4_:* = null;
         var _loc6_:* = null;
         var _loc10_:Boolean = false;
         var _loc2_:DenItemHolderEvent = null;
         var _loc3_:Array = null;
         var _loc1_:Object = null;
         var _loc5_:* = null;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:Array = [];
         for each(_loc6_ in _itemsInit)
         {
            _loc10_ = false;
            for each(_loc4_ in _currItems)
            {
               if(_loc4_.r == _loc6_.r && _loc4_.i == _loc6_.i)
               {
                  _loc10_ = true;
                  if(_loc4_.s != 4 && (_loc4_.x != _loc6_.x || _loc4_.y != _loc6_.y || _loc4_.f != _loc6_.f || _loc4_.userNameLink != _loc6_.userNameLink))
                  {
                     _loc7_.push({
                        "di":_loc4_.di,
                        "f":_loc4_.f,
                        "i":_loc4_.i,
                        "x":_loc4_.x,
                        "s":_loc4_.s,
                        "y":_loc4_.y,
                        "offX":_loc4_.offX,
                        "offY":_loc4_.offY,
                        "r":_loc4_.r,
                        "userNameLink":_loc4_.userNameLink
                     });
                  }
                  break;
               }
            }
            if(!_loc10_)
            {
               _loc7_.push({
                  "f":0,
                  "i":_loc6_.i,
                  "s":_loc6_.s,
                  "x":0,
                  "y":0,
                  "d":0,
                  "r":_loc6_.r,
                  "userNameLink":""
               });
            }
         }
         for each(_loc4_ in _currItems)
         {
            _loc10_ = false;
            for each(_loc6_ in _itemsInit)
            {
               if(_loc6_.r == _loc4_.r && _loc6_.i == _loc4_.i)
               {
                  _loc10_ = true;
                  break;
               }
            }
            if(!_loc10_)
            {
               _loc7_.push({
                  "f":_loc4_.f,
                  "di":_loc4_.di,
                  "i":_loc4_.i,
                  "s":_loc4_.s,
                  "x":_loc4_.x,
                  "y":_loc4_.y,
                  "offX":_loc4_.offX,
                  "offY":_loc4_.offY,
                  "r":_loc4_.r,
                  "userNameLink":_loc4_.userNameLink
               });
            }
         }
         if(_loc7_.length > 0)
         {
            updateInitialState();
            _loc2_ = new DenItemHolderEvent("OnSaveState");
            _loc3_ = [];
            for each(_loc5_ in _loc7_)
            {
               if(_loc5_.i != -1)
               {
                  if(_loc5_.di)
                  {
                     _loc9_ = _loc5_.x - _loc5_.offX;
                     _loc8_ = _loc5_.y - _loc5_.offY;
                     _loc1_ = {
                        "i":_loc5_.i,
                        "s":_loc5_.s,
                        "d":1,
                        "x":_loc9_,
                        "y":_loc8_,
                        "f":_loc5_.f,
                        "r":_loc5_.r,
                        "userNameLink":_loc5_.userNameLink
                     };
                  }
                  else
                  {
                     _loc1_ = {
                        "i":_loc5_.i,
                        "s":_loc5_.s,
                        "d":0,
                        "x":0,
                        "y":0,
                        "f":0,
                        "r":_loc5_.r,
                        "userNameLink":_loc5_.userNameLink
                     };
                  }
                  _loc3_.push(_loc1_);
               }
            }
            _loc2_.array = _loc3_;
            dispatchEvent(_loc2_);
         }
      }
      
      public function removeHighlightState() : void
      {
         if(_closeBtn.parent)
         {
            _closeBtn.parent.removeChild(_closeBtn);
         }
         if(_flipBtn.parent)
         {
            _flipBtn.parent.removeChild(_flipBtn);
         }
         if(_linkBtn.parent)
         {
            _linkBtn.parent.removeChild(_linkBtn);
         }
         if(_itemFilter)
         {
            if(_itemFilter.di.displayObject)
            {
               _itemFilter.di.displayObject.filters = [];
            }
            _itemFilter = null;
         }
      }
      
      private function updateInitialState() : void
      {
         _itemsInit = [];
         for each(var _loc1_:Object in _currItems)
         {
            _itemsInit.push({
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
               "r":_loc1_.r,
               "userNameLink":_loc1_.userNameLink
            });
         }
      }
      
      public function handleMouse(param1:Number, param2:Number, param3:Boolean) : void
      {
         var _loc6_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:Object = null;
         if(param3)
         {
            if(_dragItem)
            {
               _loc6_ = _dragItem.x + param1 - _dragPoint.x;
               _loc5_ = _dragItem.y + param2 - _dragPoint.y;
               setItemMatrix(_dragItem,_loc6_,_loc5_,_dragItem.f);
               setBtnPos(_loc6_ + _dragItem.di.displayObject.width - 30,_loc5_);
               _dragPoint.x = param1;
               _dragPoint.y = param2;
            }
         }
         else
         {
            if(_dragItem && _dragItem.specialType == 1)
            {
               _loc4_ = hitTest(param1,param2);
               if(!BuddyList.isOverWorldBuddyList(param1,param2) && _loc4_ != _dragItem)
               {
                  BuddyList.closeWorldBuddyList();
                  _dragItem = _loc4_;
               }
            }
            else
            {
               _dragItem = hitTest(param1,param2);
            }
            if(_dragItem)
            {
               _dragPoint.x = param1;
               _dragPoint.y = param2;
            }
            updateCloseBtn();
         }
      }
      
      public function setThemePosition(param1:int, param2:int) : void
      {
         _themePos = new Point(param1,param2);
      }
      
      public function setRoomMode(param1:int) : void
      {
         _roomMode = param1;
         stopListenersOnPets(_roomMode == 1);
         stopMouseOnNonMouseItems(_roomMode == 1);
      }
      
      public function stopListenersOnPets(param1:Boolean) : void
      {
         for each(var _loc2_:Object in _currItems)
         {
            if(_loc2_.di && _loc2_.di.content && _loc2_.di.content.hasOwnProperty("listenToMouse"))
            {
               _loc2_.di.content.listenToMouse = !param1;
            }
         }
      }
      
      public function stopMouseOnNonMouseItems(param1:Boolean) : void
      {
         for each(var _loc2_:Object in _currItems)
         {
            if(_loc2_.di && _loc2_.di.content && _loc2_.di.content.hasOwnProperty("ignoreMouseCompletely") && _loc2_.di.displayObject)
            {
               Sprite(_loc2_.di.displayObject).mouseEnabled = !param1;
               Sprite(_loc2_.di.displayObject).mouseChildren = !param1;
            }
         }
      }
      
      public function shouldStopMovement(param1:Point) : Boolean
      {
         var _loc4_:Object = null;
         var _loc3_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc2_:int = int(_currItems.length);
         if(_loc2_ > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc4_ = _currItems[_loc5_];
               if(!isTheme(_loc4_.s) && _loc4_.s != 4)
               {
                  if(_loc4_.di.displayObject.numChildren > 0)
                  {
                     _loc3_ = _loc4_.di.displayObject.getChildAt(0).content;
                     if(_loc3_.parent.name == "moveToDisabled")
                     {
                        if(_loc3_.hitTestPoint(param1.x,param1.y,true))
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
      
      public function portalItemTest(param1:Boolean, param2:Point) : void
      {
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:Sprite = null;
         var _loc5_:Object = null;
         var _loc3_:int = int(_currItems.length);
         if(_loc3_ > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc3_)
            {
               _loc4_ = _currItems[_loc6_];
               if(_loc4_.specialType == 1 && _loc4_.userNameLink != "")
               {
                  if(_loc4_.di.content)
                  {
                     if(param1)
                     {
                        if(_loc4_.di.displayObject.getChildAt(0).content.clickObject.hitTestPoint(param2.x,param2.y,true))
                        {
                           _loc7_ = Sprite(_loc4_.di.displayObject.getChildAt(0).content.radiusObject);
                           _portalToEnterInvId = _loc4_.i;
                           _portalRadiusBmpData = new BitmapData(_loc7_.width,_loc7_.height);
                           _portalRadiusBmpData.draw(_loc7_);
                        }
                        else
                        {
                           _portalToEnterInvId = -1;
                           if(_portalRadiusBmpData)
                           {
                              _portalRadiusBmpData.dispose();
                              _portalRadiusBmpData = null;
                           }
                        }
                        _lastPortalInvId = -1;
                     }
                     if(_portalToEnterInvId == _loc4_.i)
                     {
                        _loc5_ = _loc4_.di.content.getRadiusObject();
                        if(!AvatarManager.playerAvatarWorldView.bmpDataHitTest(_portalRadiusBmpData,new Point(_loc4_.x + _loc5_.x,_loc4_.y + _loc5_.y)))
                        {
                           return;
                        }
                        if(_lastPortalInvId == _loc4_.i)
                        {
                           return;
                        }
                        if(_lastPortalInvId == -1)
                        {
                           RoomXtCommManager.sendRoomJoinRequest("den" + _loc4_.userNameLink,_loc4_.i);
                           _lastPortalInvId = _loc4_.i;
                           return;
                        }
                     }
                  }
               }
               _loc6_++;
            }
         }
         _lastPortalInvId = -1;
      }
      
      private function isTheme(param1:int) : Boolean
      {
         return param1 > 1 && param1 < 4;
      }
      
      private function setItem(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int, param10:int, param11:int, param12:int, param13:String, param14:int, param15:Boolean, param16:int, param17:String, param18:int, param19:int) : void
      {
         var _loc24_:DenItemHolderEvent = null;
         var _loc20_:DenItemHolderEvent = null;
         var _loc27_:int = int(param7 == 5 ? param11 : 0);
         var _loc26_:int = int(param7 == 5 ? param12 : 0);
         var _loc21_:DenItemHelper = new DenItemHelper();
         if(isTheme(param7))
         {
            for each(var _loc22_:Object in _currItems)
            {
               if(_loc22_.s == param7)
               {
                  releaseItem(_loc22_);
                  _loc24_ = new DenItemHolderEvent("OnItemRemoved");
                  _loc24_.id = _loc22_.i;
                  _loc24_.refId = _loc22_.r;
                  _loc24_.array = [_loc22_];
                  dispatchEvent(_loc24_);
                  break;
               }
            }
         }
         else if(param7 == 4)
         {
            for each(var _loc23_:Object in _currItems)
            {
               if(_loc23_.s == param7)
               {
                  releaseItem(_loc23_);
                  _loc20_ = new DenItemHolderEvent("OnItemRemoved");
                  _loc20_.id = _loc23_.i;
                  _loc20_.refId = _loc23_.r;
                  _loc20_.array = [_loc23_];
                  dispatchEvent(_loc20_);
                  break;
               }
            }
            RoomManagerWorld.instance.playMusic(param13 + ".mp3",param11 / 100);
         }
         var _loc25_:Object = {
            "c":param6,
            "s":param7,
            "di":_loc21_,
            "f":param8,
            "i":param1,
            "l":param5,
            "x":param3,
            "y":param4,
            "r":param14,
            "bNewPlaced":param15,
            "specialType":param16,
            "userNameLink":param17
         };
         _currItems.push(_loc25_);
         _loc21_.init(param2,itemLoaded,param10,param9,_loc27_,_loc26_,param18,param19);
         if(_roomMode == 1)
         {
            if(_loc25_.di && _loc25_.di.content && _loc25_.di.content.hasOwnProperty("listenToMouse"))
            {
               _loc25_.di.content.listenToMouse = false;
            }
         }
         else if(_loc25_.di && _loc25_.di.displayObject && _loc25_.di.content && _loc25_.di.content.hasOwnProperty("ignoreMouseCompletely"))
         {
            Sprite(_loc25_.di.displayObject).mouseEnabled = false;
            Sprite(_loc25_.di.displayObject).mouseChildren = false;
         }
         if(_loc25_.di && _loc25_.di.content && _loc25_.di.content.hasOwnProperty("active"))
         {
            if(_loc25_.userNameLink != "")
            {
               _loc25_.di.content.active(true);
            }
            else
            {
               _loc25_.di.content.active(false);
            }
         }
         if(param9 > 0 || param18 > 0)
         {
            addListenersToItem(_loc21_,_loc25_);
         }
         else if(param16 == 1)
         {
            addPortalListenersToItem(_loc21_,_loc25_);
         }
         else if(param16 == 2)
         {
            _loc21_.setupItemWithEmotes(_loc25_);
         }
         if(_isWaitingToSetItemsForFirstTime || !param15)
         {
            _itemsInit.push({
               "c":_loc25_.c,
               "s":_loc25_.s,
               "di":_loc25_.di,
               "f":_loc25_.f,
               "i":_loc25_.i,
               "l":_loc25_.l,
               "x":_loc25_.x,
               "y":_loc25_.y,
               "r":param14,
               "bNewPlaced":_loc25_.bNewPlaced,
               "specialType":param16,
               "userNameLink":param17
            });
         }
      }
      
      private function updateCloseBtn() : void
      {
         var _loc1_:Sprite = null;
         if(_dragItem)
         {
            _loc1_ = _dragItem.di.displayObject;
            if(_closeBtn.parent != _loc1_)
            {
               setBtnPos(_dragItem.x + _loc1_.width - 30,_dragItem.y);
               _layerManager.room_chat.addChild(_closeBtn);
               _layerManager.room_chat.addChild(_flipBtn);
               if(_dragItem.specialType == 1)
               {
                  _layerManager.room_chat.addChild(_linkBtn);
               }
               else if(_linkBtn.parent)
               {
                  _linkBtn.parent.removeChild(_linkBtn);
                  BuddyList.closeWorldBuddyList();
               }
            }
            if(_itemFilter != _dragItem)
            {
               if(_itemFilter)
               {
                  _itemFilter.di.displayObject.filters = [];
               }
               _itemFilter = _dragItem;
               _itemFilter.di.displayObject.filters = [new GlowFilter(16777215,1,8,8,8)];
            }
         }
         else
         {
            if(_closeBtn.parent)
            {
               _closeBtn.parent.removeChild(_closeBtn);
            }
            if(_flipBtn.parent)
            {
               _flipBtn.parent.removeChild(_flipBtn);
            }
            if(_linkBtn.parent)
            {
               _linkBtn.parent.removeChild(_linkBtn);
               BuddyList.closeWorldBuddyList();
            }
            if(_itemFilter)
            {
               if(_itemFilter.di.displayObject)
               {
                  _itemFilter.di.displayObject.filters = [];
               }
               _itemFilter = null;
            }
         }
      }
      
      private function setBtnPos(param1:Number, param2:Number) : void
      {
         _closeBtn.x = param1;
         _closeBtn.y = param2;
         _flipBtn.x = param1 + 15;
         _flipBtn.y = param2 + 55;
         _linkBtn.x = param1 + 15;
         _linkBtn.y = param2 + 90;
         BuddyList.updateWorldBuddyListPosition(_linkBtn);
      }
      
      private function onCloseBtn(param1:Event) : void
      {
         var _loc2_:DenItemHolderEvent = null;
         param1.stopPropagation();
         if(_dragItem)
         {
            _loc2_ = new DenItemHolderEvent("OnItemRemoved");
            _loc2_.id = _dragItem.i;
            _loc2_.refId = _dragItem.r;
            _loc2_.array = [_dragItem];
            releaseItem(_dragItem);
            _dragItem = null;
            updateCloseBtn();
            dispatchEvent(_loc2_);
         }
      }
      
      private function onFlipBtn(param1:Event) : void
      {
         param1.stopPropagation();
         if(_dragItem)
         {
            _dragItem.f = _dragItem.f == 0 ? 1 : 0;
            setItemMatrix(_dragItem,_dragItem.x,_dragItem.y,_dragItem.f);
         }
      }
      
      private function onLinkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_dragItem)
         {
            BuddyList.buildInWorldBuddyList(_linkBtn,_dragItem,onSelectUserToLink,_dragItem.userNameLink);
         }
      }
      
      private function onSelectUserToLink(param1:String) : void
      {
         if(_dragItem)
         {
            _dragItem.userNameLink = param1;
            if(_dragItem.di && _dragItem.di.content && _dragItem.di.content.hasOwnProperty("active"))
            {
               if(param1 != "")
               {
                  _dragItem.di.content.active(true);
               }
               else
               {
                  _dragItem.di.content.active(false);
               }
            }
         }
      }
      
      private function isInInitList(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _itemsInit.length)
         {
            if(_itemsInit[_loc3_].refId == param2 && _itemsInit[_loc3_].i == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function releaseItem(param1:Object, param2:Boolean = true) : void
      {
         var _loc3_:int = _currItems.indexOf(param1);
         if(_loc3_ >= 0)
         {
            _currItems.splice(_loc3_,1);
            if(param1.di)
            {
               if(param1.di.displayObject.parent)
               {
                  param1.di.displayObject.parent.removeChild(param1.di.displayObject);
               }
               if(param1.di.minigameDefId > 0 || param1.di.listLauncherId > 0)
               {
                  removeListenersFromItem(param1.di);
               }
               if(param1.specialType == 1)
               {
                  removePortalListenersFromItem(param1.di);
                  _lastPortalInvId = -1;
                  _portalToEnterInvId = -1;
                  if(_portalRadiusBmpData)
                  {
                     _portalRadiusBmpData.dispose();
                     _portalRadiusBmpData = null;
                  }
               }
            }
         }
         if(!param2)
         {
            _loc3_ = 0;
            while(_loc3_ < _itemsInit.length)
            {
               if(_itemsInit[_loc3_].i == param1.i)
               {
                  _itemsInit.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private function setItemMatrix(param1:Object, param2:Number, param3:Number, param4:int = 0) : void
      {
         var _loc9_:Sprite = null;
         var _loc11_:Loader = null;
         var _loc8_:MovieClip = null;
         var _loc13_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc7_:DisplayObject = param1.di.displayObject;
         param1.x = param2;
         param1.y = param3;
         var _loc10_:Matrix = _loc7_.transform.matrix;
         _loc10_.identity();
         var _loc6_:Number = param2;
         var _loc5_:Number = param3;
         if(param1.di.bFlipLabel)
         {
            _loc9_ = _loc7_ as Sprite;
            _loc11_ = _loc9_.getChildAt(0) as Loader;
            _loc8_ = _loc11_.content as MovieClip;
            _loc8_.gotoAndStop(param4 ? "flip" : 1);
         }
         else if(param4)
         {
            _loc13_ = 1;
            _loc12_ = 1;
            _loc13_ *= -1;
            _loc6_ += _loc7_.width;
            _loc10_.scale(_loc13_,_loc12_);
         }
         _loc10_.translate(_loc6_,_loc5_);
         _loc7_.transform.matrix = _loc10_;
      }
      
      private function hitTest(param1:int, param2:int) : Object
      {
         var _loc4_:Object = null;
         var _loc11_:int = 0;
         var _loc7_:Object = null;
         var _loc5_:DisplayObject = null;
         var _loc6_:Rectangle = null;
         var _loc3_:Number = NaN;
         var _loc10_:Number = -999999999;
         var _loc8_:int = 99999999;
         var _loc9_:int = int(_currItems.length);
         while(_loc11_ < _loc9_)
         {
            _loc7_ = _currItems[_loc11_];
            if(!isTheme(_loc7_.s))
            {
               _loc5_ = _loc7_.di.displayObject;
               _loc6_ = _loc5_.getBounds(_layerManager.room_avatars);
               _loc3_ = _loc6_.bottom - Number(_loc5_.name);
               if(param1 > _loc6_.left && param1 < _loc6_.right && param2 > _loc6_.top && param2 < _loc6_.bottom)
               {
                  if(_loc7_.l <= _loc8_)
                  {
                     if(_loc7_.l == 1 || _loc3_ > _loc10_)
                     {
                        _loc8_ = int(_loc7_.l);
                        _loc10_ = _loc3_;
                        _loc4_ = _loc7_;
                        if(_loc8_ == 1)
                        {
                           _loc10_ = -999999999;
                        }
                     }
                  }
               }
            }
            _loc11_++;
         }
         return _loc4_;
      }
      
      private function itemLoaded(param1:DenItemHelper, param2:Boolean = false) : void
      {
         var _loc7_:Object = null;
         var _loc3_:DisplayObject = null;
         var _loc12_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc9_:Boolean = false;
         var _loc11_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:SortLayer = null;
         if(!param2)
         {
            _savedDenItemHelpers.push(param1);
         }
         for each(var _loc5_:Object in _currItems)
         {
            if(_loc5_.di == param1)
            {
               _loc7_ = _loc5_;
               break;
            }
         }
         if(_loc7_ && _loc7_.s != 4)
         {
            _loc3_ = param1.displayObject;
            _loc7_.offX = -(_loc3_.width * 0.5);
            _loc7_.offY = -_loc3_.height;
            if(param2)
            {
               _loc7_.x -= _loc7_.offX;
               _loc7_.y -= _loc7_.offY;
            }
            _loc12_ = _loc7_.x + _loc7_.offX;
            _loc10_ = _loc7_.y + _loc7_.offY;
            _loc9_ = Boolean(_loc7_.bNewPlaced);
            if(_loc7_.bNewPlaced)
            {
               _loc10_ += _loc3_.height * 0.5;
               _loc7_.bNewPlaced = false;
            }
            if(_roomMode == 1)
            {
               if(_loc7_.di && _loc7_.di.content && _loc7_.di.content.hasOwnProperty("listenToMouse"))
               {
                  _loc7_.di.content.listenToMouse = false;
               }
            }
            else if(_loc3_ && _loc7_.di && _loc7_.di.content && _loc7_.di.content.hasOwnProperty("ignoreMouseCompletely"))
            {
               Sprite(_loc3_).mouseEnabled = false;
               Sprite(_loc3_).mouseChildren = false;
            }
            if(_loc7_.di && _loc7_.di.content && _loc7_.di.content.hasOwnProperty("active"))
            {
               if(_loc7_.userNameLink != "")
               {
                  _loc7_.di.content.active(true);
               }
               else
               {
                  _loc7_.di.content.active(false);
               }
            }
            _loc8_ = int(_loc7_.l);
            setItemMatrix(_loc7_,_loc12_,_loc10_,_loc7_.f);
            if(isTheme(_loc7_.s))
            {
               _loc8_ = 100;
               _loc3_.x = 0;
               _loc3_.y = 0;
               setItemMatrix(_loc7_,0,0);
            }
            if(!_loc9_)
            {
               for each(var _loc4_:Object in _itemsInit)
               {
                  if(_loc7_.r == _loc4_.r && _loc7_.i == _loc4_.i)
                  {
                     if(_loc7_.x != _loc4_.x || _loc7_.y != _loc4_.y)
                     {
                        _loc4_.x = _loc7_.x;
                        _loc4_.y = _loc7_.y;
                        _loc4_.offX = _loc7_.offX;
                        _loc4_.offY = _loc7_.offY;
                        break;
                     }
                  }
               }
            }
            switch(_loc8_)
            {
               case 1:
                  _layerManager.room_bkg_main.addChild(_loc3_);
                  break;
               case 100:
                  _layerManager.room_bkg_main.addChildAt(_loc3_,0);
                  break;
               default:
                  _loc11_ = param1.sortOffset;
                  _loc6_ = _layerManager.room_avatars;
                  if(_loc11_)
                  {
                     _loc3_.name = String(_loc11_);
                  }
                  _loc6_.addChild(_loc3_);
            }
         }
      }
      
      private function addListenersToItem(param1:DenItemHelper, param2:Object) : void
      {
         param1.addMouseListeners(param2,onItemDown,onItemOver,onItemOut);
      }
      
      private function addPortalListenersToItem(param1:DenItemHelper, param2:Object) : void
      {
         param1.addPortalListeners(param2,onPortalItemDown,onPortalItemOver,onPortalItemOut);
      }
      
      private function removeListenersFromItem(param1:DenItemHelper) : void
      {
         param1.removeMouseListeners();
      }
      
      private function removePortalListenersFromItem(param1:DenItemHelper) : void
      {
         param1.removePortalListeners();
      }
      
      private function onItemDown(param1:MouseEvent, param2:int, param3:int) : void
      {
         var _loc4_:Object = null;
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1);
         if(param2 > 0)
         {
            _loc4_ = {"typeDefId":param2};
            MinigameManager.handleGameClick(_loc4_,null);
         }
         else if(param3 > 0)
         {
            GuiManager.openEBook(param3,true,true);
         }
      }
      
      private function onPortalItemDown(param1:MouseEvent, param2:int, param3:int) : void
      {
      }
      
      private function onItemOver(param1:MouseEvent, param2:Object, param3:int, param4:int) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1);
         var _loc5_:Sprite = Sprite(param1.currentTarget);
         GuiManager.toolTip.init(_layerManager.room_orbs,param3 > 0 ? MinigameManager.getGameName(param3) : LocalizationManager.translateIdOnly(param2.di.nameStrId),param2.x + _loc5_.width * 0.5,param2.y + _loc5_.height - 75);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onPortalItemOver(param1:MouseEvent, param2:Object, param3:int, param4:int) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         if(param2.userNameLink != "")
         {
            sendMouseEvent(param1,true);
         }
      }
      
      private function onItemOut(param1:MouseEvent) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onPortalItemOut(param1:MouseEvent) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1,true);
      }
      
      private function sendMouseEvent(param1:MouseEvent, param2:Boolean = false) : void
      {
         var _loc4_:Sprite = null;
         var _loc5_:Loader = null;
         var _loc3_:MovieClip = null;
         var _loc6_:int = -1;
         switch(param1.type)
         {
            case "mouseDown":
               _loc6_ = 0;
               break;
            case "mouseOver":
               _loc6_ = 1;
               break;
            case "mouseOut":
               _loc6_ = 2;
         }
         if(_loc6_ >= 0)
         {
            if(param2)
            {
               _loc4_ = Sprite(param1.currentTarget.parent);
            }
            else
            {
               _loc4_ = Sprite(param1.currentTarget);
            }
            if(_loc4_.parent)
            {
               _loc5_ = Loader(_loc4_.getChildAt(0));
               if(_loc5_)
               {
                  _loc3_ = MovieClip(_loc5_.content);
                  if(_loc3_)
                  {
                     if(_loc3_.hasOwnProperty("handleMouse"))
                     {
                        _loc3_.handleMouse(_loc6_);
                     }
                  }
               }
            }
         }
      }
   }
}

