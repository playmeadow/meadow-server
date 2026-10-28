package room
{
   import avatar.AvatarManager;
   import collection.DenStateItemCollection;
   import com.sbi.graphics.SortLayer;
   import den.DenStateItem;
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
      
      private var _currItems:DenStateItemCollection;
      
      private var _itemsInit:DenStateItemCollection;
      
      private var _savedDenItemHelpers:Array;
      
      private var _layerManager:LayerManager;
      
      private var _dragItem:DenStateItem;
      
      private var _itemFilter:DenStateItem;
      
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
            for each(var _loc1_:DenStateItem in _currItems.getCoreArray())
            {
               if(_loc1_.denItemHelper)
               {
                  _loc1_.denItemHelper.destroy();
               }
            }
         }
         _currItems = new DenStateItemCollection();
         _itemsInit = new DenStateItemCollection();
         _savedDenItemHelpers = [];
         _dragItem = null;
         updateCloseBtn();
      }
      
      public function clearDen() : void
      {
         release();
         var _loc1_:DenStateItem = new DenStateItem(617,-1,40435715,0,0,0,50,0,0,3,0,3,0,0,0,"MusDenDef",0,"",0,0,"","",-1,"",false,null,0,0,null);
         setItem(_loc1_);
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
      
      public function setItems(param1:DenStateItemCollection, param2:Boolean = false) : void
      {
         var _loc4_:DenStateItem = null;
         var _loc5_:* = null;
         var _loc3_:Boolean = false;
         var _loc6_:int = 0;
         var _loc10_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:DenStateItem = null;
         var _loc7_:Boolean = false;
         if(_isWaitingToSetItemsForFirstTime && param2)
         {
            _isWaitingToSetItemsForFirstTime = false;
         }
         _loc6_ = 0;
         while(_loc6_ < param1.length)
         {
            _loc4_ = param1.getDenStateItem(_loc6_);
            if(_loc4_)
            {
               if(_loc4_.catId > 0)
               {
                  _loc3_ = false;
                  for each(_loc5_ in _currItems.getCoreArray())
                  {
                     if(_loc4_.refId == _loc5_.refId && _loc4_.invIdx == _loc5_.invIdx)
                     {
                        _loc5_.flipped = _loc4_.flipped;
                        _loc10_ = _loc4_.x + _loc5_.offsetX;
                        _loc9_ = _loc4_.y + _loc5_.offsetY;
                        setItemMatrix(_loc5_,_loc10_,_loc9_,_loc5_.flipped);
                        if(_loc5_.sortCatId == 99 && _loc5_.denItemHelper)
                        {
                           _loc5_.denItemHelper.setVersion(_loc4_.version,_loc4_.version2,_loc4_.version3);
                        }
                        if(_loc5_.specialType == 1)
                        {
                           _loc5_.userNameLink = _loc4_.userNameLink;
                           if(_loc5_.denItemHelper && _loc5_.denItemHelper.content && _loc5_.denItemHelper.content.hasOwnProperty("active"))
                           {
                              if(_loc5_.userNameLink != "")
                              {
                                 Object(_loc5_.denItemHelper.content).active(true);
                              }
                              else
                              {
                                 Object(_loc5_.denItemHelper.content).active(false);
                              }
                           }
                           BuddyList.destroyInWorldBuddyList();
                        }
                        if(_loc5_.uniqueImageId != _loc4_.uniqueImageId)
                        {
                           _loc5_.uniqueImageId = _loc4_.uniqueImageId;
                           _loc5_.uniqueImageCreator = _loc4_.uniqueImageCreator;
                           if(_loc5_.denItemHelper)
                           {
                              (_loc5_.denItemHelper as DenItemHelper).uniqueImageId = _loc5_.uniqueImageId;
                              (_loc5_.denItemHelper as DenItemHelper).uniqueImageCreator = _loc5_.uniqueImageCreator;
                              (_loc5_.denItemHelper as DenItemHelper).loadUniqueImage();
                           }
                        }
                        _loc3_ = true;
                        break;
                     }
                  }
                  if(!_loc3_)
                  {
                     _loc8_ = _loc4_.clone();
                     _loc8_.userAction = param2;
                     setItem(_loc8_);
                  }
               }
               else
               {
                  for each(_loc5_ in _currItems.getCoreArray())
                  {
                     if(_loc4_.refId == _loc5_.refId && _loc4_.invIdx == _loc5_.invIdx)
                     {
                        releaseItem(_loc5_,param2);
                        break;
                     }
                  }
               }
            }
            _loc6_++;
         }
         for each(_loc5_ in _currItems.getCoreArray())
         {
            if(_loc5_.sortCatId == 4)
            {
               _loc7_ = true;
               break;
            }
         }
         if(!_loc7_)
         {
            _loc4_ = new DenStateItem(0,-1,40435715,0,0,0,50,0,0,3,0,4,0,0,0,"MusDenDef",0,"",0,0,"","",-1,"",param2,null,0,0,null);
            setItem(_loc4_);
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
         for each(var _loc3_:DenStateItem in _currItems.getCoreArray())
         {
            if(_loc3_.refId == param2 && _loc3_.invIdx == param1)
            {
               releaseItem(_loc3_);
               break;
            }
         }
      }
      
      public function saveState() : void
      {
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc10_:Boolean = false;
         var _loc2_:DenItemHolderEvent = null;
         var _loc3_:Array = null;
         var _loc1_:Object = null;
         var _loc5_:* = null;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:Array = [];
         for each(_loc6_ in _itemsInit.getCoreArray())
         {
            _loc10_ = false;
            for each(_loc4_ in _currItems.getCoreArray())
            {
               if(_loc4_.refId == _loc6_.refId && _loc4_.invIdx == _loc6_.invIdx)
               {
                  _loc10_ = true;
                  if(_loc4_.sortCatId != 4 && (_loc4_.x != _loc6_.x || _loc4_.y != _loc6_.y || _loc4_.flipped != _loc6_.flipped || _loc4_.userNameLink != _loc6_.userNameLink || _loc4_.uniqueImageId != _loc6_.uniqueImageId || _loc4_.uniqueImageCreator != _loc6_.uniqueImageCreator))
                  {
                     _loc7_.push({
                        "di":_loc4_.denItemHelper,
                        "f":_loc4_.flipped,
                        "i":_loc4_.invIdx,
                        "x":_loc4_.x,
                        "s":_loc4_.sortCatId,
                        "y":_loc4_.y,
                        "offX":_loc4_.offsetX,
                        "offY":_loc4_.offsetY,
                        "r":_loc4_.refId,
                        "userNameLink":_loc4_.userNameLink,
                        "uniqueImageId":_loc4_.uniqueImageId,
                        "uniqueImageCreator":_loc4_.uniqueImageCreator
                     });
                  }
                  break;
               }
            }
            if(!_loc10_)
            {
               _loc7_.push({
                  "f":0,
                  "i":_loc6_.invIdx,
                  "s":_loc6_.sortCatId,
                  "x":0,
                  "y":0,
                  "d":0,
                  "r":_loc6_.refId,
                  "userNameLink":"",
                  "uniqueImageId":"",
                  "uniqueImageCreator":""
               });
            }
         }
         for each(_loc4_ in _currItems.getCoreArray())
         {
            _loc10_ = false;
            for each(_loc6_ in _itemsInit.getCoreArray())
            {
               if(_loc6_.refId == _loc4_.refId && _loc6_.invIdx == _loc4_.invIdx)
               {
                  _loc10_ = true;
                  break;
               }
            }
            if(!_loc10_)
            {
               _loc7_.push({
                  "f":_loc4_.flipped,
                  "di":_loc4_.defId,
                  "i":_loc4_.invIdx,
                  "s":_loc4_.sortCatId,
                  "x":_loc4_.x,
                  "y":_loc4_.y,
                  "offX":_loc4_.offsetX,
                  "offY":_loc4_.offsetY,
                  "r":_loc4_.refId,
                  "userNameLink":_loc4_.userNameLink,
                  "uniqueImageId":_loc4_.uniqueImageId,
                  "uniqueImageCreator":_loc4_.uniqueImageCreator
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
                        "userNameLink":_loc5_.userNameLink,
                        "uniqueImageId":_loc5_.uniqueImageId,
                        "uniqueImageCreator":_loc5_.uniqueImageCreator
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
                        "userNameLink":_loc5_.userNameLink,
                        "uniqueImageId":_loc5_.uniqueImageId,
                        "uniqueImageCreator":_loc5_.uniqueImageCreator
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
            if(_itemFilter.denItemHelper.displayObject)
            {
               _itemFilter.denItemHelper.displayObject.filters = [];
            }
            _itemFilter = null;
         }
      }
      
      private function updateInitialState() : void
      {
         _itemsInit = new DenStateItemCollection();
         for each(var _loc1_:DenStateItem in _currItems.getCoreArray())
         {
            _itemsInit.pushDenStateItem(_loc1_.clone());
         }
      }
      
      public function handleMouse(param1:Number, param2:Number, param3:Boolean) : void
      {
         var _loc6_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:DenStateItem = null;
         if(param3)
         {
            if(_dragItem)
            {
               _loc6_ = _dragItem.x + param1 - _dragPoint.x;
               _loc5_ = _dragItem.y + param2 - _dragPoint.y;
               setItemMatrix(_dragItem,_loc6_,_loc5_,_dragItem.flipped);
               setBtnPos(_loc6_ + _dragItem.denItemHelper.displayObject.width - 30,_loc5_);
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
         for each(var _loc2_:DenStateItem in _currItems.getCoreArray())
         {
            if(_loc2_.denItemHelper && _loc2_.denItemHelper.content && _loc2_.denItemHelper.content.hasOwnProperty("listenToMouse"))
            {
               Object(_loc2_.denItemHelper.content).listenToMouse = !param1;
            }
         }
      }
      
      public function stopMouseOnNonMouseItems(param1:Boolean) : void
      {
         for each(var _loc2_:DenStateItem in _currItems.getCoreArray())
         {
            if(_loc2_.denItemHelper && _loc2_.denItemHelper.content && _loc2_.denItemHelper.content.hasOwnProperty("ignoreMouseCompletely") && _loc2_.denItemHelper.displayObject)
            {
               Sprite(_loc2_.denItemHelper.displayObject).mouseEnabled = !param1;
               Sprite(_loc2_.denItemHelper.displayObject).mouseChildren = !param1;
            }
         }
      }
      
      public function shouldStopMovement(param1:Point) : Boolean
      {
         var _loc3_:DenStateItem = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc2_:int = int(_currItems.length);
         if(_loc2_ > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc3_ = _currItems.getDenStateItem(_loc5_);
               if(!isTheme(_loc3_.sortCatId) && _loc3_.sortCatId != 4)
               {
                  if(_loc3_.denItemHelper.displayObject.numChildren > 0)
                  {
                     _loc4_ = Loader(_loc3_.denItemHelper.displayObject.getChildAt(0)).content as MovieClip;
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
      
      public function portalItemTest(param1:Boolean, param2:Point) : void
      {
         var _loc4_:DenStateItem = null;
         var _loc6_:int = 0;
         var _loc7_:Sprite = null;
         var _loc5_:Object = null;
         var _loc3_:int = int(_currItems.length);
         if(_loc3_ > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc3_)
            {
               _loc4_ = _currItems.getDenStateItem(_loc6_);
               if(_loc4_.specialType == 1 && _loc4_.userNameLink != "")
               {
                  if(_loc4_.denItemHelper.content)
                  {
                     if(param1)
                     {
                        if(Object(_loc4_.denItemHelper.displayObject.getChildAt(0)).content.clickObject.hitTestPoint(param2.x,param2.y,true))
                        {
                           _loc7_ = Sprite(Object(_loc4_.denItemHelper.displayObject.getChildAt(0)).content.radiusObject);
                           _portalToEnterInvId = _loc4_.invIdx;
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
                     if(_portalToEnterInvId == _loc4_.invIdx)
                     {
                        _loc5_ = Object(_loc4_.denItemHelper.content).getRadiusObject();
                        if(!AvatarManager.playerAvatarWorldView.bmpDataHitTest(_portalRadiusBmpData,new Point(_loc4_.x + _loc5_.x,_loc4_.y + _loc5_.y)))
                        {
                           return;
                        }
                        if(_lastPortalInvId == _loc4_.invIdx)
                        {
                           return;
                        }
                        if(_lastPortalInvId == -1)
                        {
                           RoomXtCommManager.sendRoomJoinRequest("den" + _loc4_.userNameLink,_loc4_.invIdx);
                           _lastPortalInvId = _loc4_.invIdx;
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
      
      private function setItem(param1:DenStateItem) : void
      {
         var _loc5_:DenItemHolderEvent = null;
         var _loc6_:DenItemHolderEvent = null;
         var _loc8_:int = int(param1.sortCatId == 99 ? param1.version2 : 0);
         var _loc7_:int = int(param1.sortCatId == 99 ? param1.version3 : 0);
         var _loc3_:DenItemHelper = new DenItemHelper();
         if(isTheme(param1.sortCatId))
         {
            for each(var _loc4_:DenStateItem in _currItems.getCoreArray())
            {
               if(_loc4_.sortCatId == param1.sortCatId)
               {
                  releaseItem(_loc4_);
                  _loc5_ = new DenItemHolderEvent("OnItemRemoved");
                  _loc5_.id = _loc4_.invIdx;
                  _loc5_.refId = _loc4_.refId;
                  _loc5_.array = [_loc4_];
                  dispatchEvent(_loc5_);
                  break;
               }
            }
         }
         else if(param1.sortCatId == 4)
         {
            for each(var _loc2_:DenStateItem in _currItems.getCoreArray())
            {
               if(_loc2_.sortCatId == param1.sortCatId)
               {
                  releaseItem(_loc2_);
                  _loc6_ = new DenItemHolderEvent("OnItemRemoved");
                  _loc6_.id = _loc2_.invIdx;
                  _loc6_.refId = _loc2_.refId;
                  _loc6_.array = [_loc2_];
                  dispatchEvent(_loc6_);
                  break;
               }
            }
            RoomManagerWorld.instance.playMusic(param1.strmName + ".mp3",param1.version2 / 100);
         }
         param1.denItemHelper = _loc3_;
         _currItems.pushDenStateItem(param1);
         _loc3_.init(param1.packedId,itemLoaded,param1.version,param1.minigameDefId,_loc8_,_loc7_,param1.listLauncherId,param1.nameStrId,param1.uniqueImageId,param1.uniqueImageCreator,param1.uniqueImageCreatorDbId,param1.uniqueImageCreatorUUID);
         if(_roomMode == 1)
         {
            if(param1.denItemHelper && param1.denItemHelper.content && param1.denItemHelper.content.hasOwnProperty("listenToMouse"))
            {
               Object(param1.denItemHelper.content).listenToMouse = false;
            }
         }
         else if(param1.denItemHelper && param1.denItemHelper.displayObject && param1.denItemHelper.content && param1.denItemHelper.content.hasOwnProperty("ignoreMouseCompletely"))
         {
            Sprite(param1.denItemHelper.displayObject).mouseEnabled = false;
            Sprite(param1.denItemHelper.displayObject).mouseChildren = false;
         }
         if(param1.denItemHelper && param1.denItemHelper.content && param1.denItemHelper.content.hasOwnProperty("active"))
         {
            if(param1.userNameLink != "")
            {
               Object(param1.denItemHelper.content).active(true);
            }
            else
            {
               Object(param1.denItemHelper.content).active(false);
            }
         }
         if(param1.minigameDefId > 0 || param1.listLauncherId > 0 || _loc3_.isUniqueImageItem)
         {
            addListenersToItem(_loc3_,param1);
         }
         else if(param1.specialType == 1)
         {
            addPortalListenersToItem(_loc3_,param1);
         }
         else if(param1.specialType == 2)
         {
            _loc3_.setupItemWithEmotes(param1);
         }
         if(_isWaitingToSetItemsForFirstTime || !param1.userAction)
         {
            _itemsInit.pushDenStateItem(param1.clone());
         }
      }
      
      private function updateCloseBtn() : void
      {
         var _loc1_:Sprite = null;
         if(_dragItem)
         {
            _loc1_ = _dragItem.denItemHelper.displayObject;
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
                  _itemFilter.denItemHelper.displayObject.filters = [];
               }
               _itemFilter = _dragItem;
               _itemFilter.denItemHelper.displayObject.filters = [new GlowFilter(16777215,1,8,8,8)];
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
               if(_itemFilter.denItemHelper.displayObject)
               {
                  _itemFilter.denItemHelper.displayObject.filters = [];
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
            _loc2_.id = _dragItem.invIdx;
            _loc2_.refId = _dragItem.refId;
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
            _dragItem.flipped = _dragItem.flipped == 0 ? 1 : 0;
            setItemMatrix(_dragItem,_dragItem.x,_dragItem.y,_dragItem.flipped);
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
            if(_dragItem.denItemHelper && _dragItem.denItemHelper.content && _dragItem.denItemHelper.content.hasOwnProperty("active"))
            {
               if(param1 != "")
               {
                  Object(_dragItem.denItemHelper.content).active(true);
               }
               else
               {
                  Object(_dragItem.denItemHelper.content).active(false);
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
            if(_itemsInit.getDenStateItem(_loc3_).refId == param2 && _itemsInit.getDenStateItem(_loc3_).invIdx == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function releaseItem(param1:DenStateItem, param2:Boolean = true) : void
      {
         var _loc3_:int = _currItems.getCoreArray().indexOf(param1);
         if(_loc3_ >= 0)
         {
            _currItems.getCoreArray().splice(_loc3_,1);
            if(param1.defId)
            {
               if(param1.denItemHelper.displayObject.parent)
               {
                  param1.denItemHelper.displayObject.parent.removeChild(param1.denItemHelper.displayObject);
               }
               if(param1.denItemHelper.minigameDefId > 0 || param1.denItemHelper.listLauncherId > 0 || param1.denItemHelper.uniqueImageId != "")
               {
                  removeListenersFromItem(param1.denItemHelper);
               }
               if(param1.specialType == 1)
               {
                  removePortalListenersFromItem(param1.denItemHelper);
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
               if(_itemsInit.getDenStateItem(_loc3_).invIdx == param1.invIdx)
               {
                  _itemsInit.getCoreArray().splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private function setItemMatrix(param1:DenStateItem, param2:Number, param3:Number, param4:int = 0) : void
      {
         var _loc7_:Sprite = null;
         var _loc9_:Loader = null;
         var _loc12_:MovieClip = null;
         var _loc16_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc13_:Matrix = null;
         var _loc15_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:DisplayObject = param1.denItemHelper.displayObject;
         param1.x = param2;
         param1.y = param3;
         var _loc8_:Matrix = _loc6_.transform.matrix;
         _loc8_.identity();
         var _loc11_:Number = param2;
         var _loc10_:Number = param3;
         if(param1.denItemHelper.bFlipLabel)
         {
            _loc7_ = _loc6_ as Sprite;
            _loc9_ = _loc7_.getChildAt(0) as Loader;
            _loc12_ = _loc9_.content as MovieClip;
            _loc12_.gotoAndStop(param4 ? "flip" : 1);
         }
         else if(param4)
         {
            _loc16_ = -1;
            _loc14_ = 1;
            _loc11_ += _loc6_.width;
            _loc8_.scale(_loc16_,_loc14_);
         }
         if(param1.denItemHelper.isUniqueImageItem)
         {
            _loc13_ = Object(param1.denItemHelper.content).item1.imageCont.transform.matrix;
            _loc15_ = Math.abs(_loc13_.b);
            _loc5_ = Math.abs(_loc13_.a);
            _loc13_.a = 1;
            _loc13_.b = 1;
            _loc13_.a = param4 ? -1 : 1;
            _loc13_.b = param4 ? -1 : 1;
            _loc13_.a *= _loc5_;
            _loc13_.b *= _loc15_;
            Object(param1.denItemHelper.content).item1.imageCont.transform.matrix = _loc13_;
         }
         _loc8_.translate(_loc11_,_loc10_);
         _loc6_.transform.matrix = _loc8_;
      }
      
      private function hitTest(param1:int, param2:int) : DenStateItem
      {
         var _loc4_:DenStateItem = null;
         var _loc11_:int = 0;
         var _loc7_:DenStateItem = null;
         var _loc5_:DisplayObject = null;
         var _loc6_:Rectangle = null;
         var _loc3_:Number = NaN;
         var _loc10_:Number = -999999999;
         var _loc8_:int = 99999999;
         var _loc9_:int = int(_currItems.length);
         while(_loc11_ < _loc9_)
         {
            _loc7_ = _currItems.getDenStateItem(_loc11_);
            if(!isTheme(_loc7_.sortCatId))
            {
               _loc5_ = _loc7_.denItemHelper.displayObject;
               _loc6_ = _loc5_.getBounds(_layerManager.room_avatars);
               _loc3_ = _loc6_.bottom - Number(_loc5_.name);
               if(param1 > _loc6_.left && param1 < _loc6_.right && param2 > _loc6_.top && param2 < _loc6_.bottom)
               {
                  if(_loc7_.layerId <= _loc8_)
                  {
                     if(_loc7_.layerId == 1 || _loc3_ > _loc10_)
                     {
                        _loc8_ = _loc7_.layerId;
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
         var _loc4_:DenStateItem = null;
         var _loc3_:DisplayObject = null;
         var _loc12_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc9_:Boolean = false;
         var _loc11_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:SortLayer = null;
         if(!param2)
         {
            _savedDenItemHelpers.push(param1);
         }
         for each(var _loc6_:DenStateItem in _currItems.getCoreArray())
         {
            if(_loc6_.denItemHelper == param1)
            {
               _loc4_ = _loc6_;
               break;
            }
         }
         if(_loc4_ && _loc4_.sortCatId != 4)
         {
            _loc3_ = param1.displayObject;
            _loc4_.offsetX = -(_loc3_.width * 0.5);
            _loc4_.offsetY = -_loc3_.height;
            if(param2)
            {
               _loc4_.x -= _loc4_.offsetX;
               _loc4_.y -= _loc4_.offsetY;
            }
            _loc12_ = _loc4_.x + _loc4_.offsetX;
            _loc10_ = _loc4_.y + _loc4_.offsetY;
            _loc9_ = _loc4_.newPlaced;
            if(_loc4_.newPlaced)
            {
               _loc10_ += _loc3_.height * 0.5;
               _loc4_.newPlaced = false;
            }
            if(_roomMode == 1)
            {
               if(_loc4_.denItemHelper && _loc4_.denItemHelper.content && _loc4_.denItemHelper.content.hasOwnProperty("listenToMouse"))
               {
                  Object(_loc4_.denItemHelper.content).listenToMouse = false;
               }
            }
            else if(_loc3_ && _loc4_.denItemHelper && _loc4_.denItemHelper.content && _loc4_.denItemHelper.content.hasOwnProperty("ignoreMouseCompletely"))
            {
               Sprite(_loc3_).mouseEnabled = false;
               Sprite(_loc3_).mouseChildren = false;
            }
            if(_loc4_.denItemHelper && _loc4_.denItemHelper.content && _loc4_.denItemHelper.content.hasOwnProperty("active"))
            {
               if(_loc4_.userNameLink != "")
               {
                  Object(_loc4_.denItemHelper.content).active(true);
               }
               else
               {
                  Object(_loc4_.denItemHelper.content).active(false);
               }
            }
            if(_loc4_.denItemHelper && _loc4_.denItemHelper.isUniqueImageItem)
            {
               addListenersToItem(_loc4_.denItemHelper,_loc4_);
            }
            _loc8_ = _loc4_.layerId;
            setItemMatrix(_loc4_,_loc12_,_loc10_,_loc4_.flipped);
            if(isTheme(_loc4_.sortCatId))
            {
               _loc8_ = 100;
               _loc3_.x = 0;
               _loc3_.y = 0;
               setItemMatrix(_loc4_,0,0);
            }
            if(!_loc9_)
            {
               for each(var _loc5_:DenStateItem in _itemsInit.getCoreArray())
               {
                  if(_loc4_.refId == _loc5_.refId && _loc4_.invIdx == _loc5_.invIdx)
                  {
                     if(_loc4_.x != _loc5_.x || _loc4_.y != _loc5_.y)
                     {
                        _loc5_.x = _loc4_.x;
                        _loc5_.y = _loc4_.y;
                        _loc5_.offsetX = _loc4_.offsetX;
                        _loc5_.offsetY = _loc4_.offsetY;
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
                  _loc7_ = RoomManagerWorld.instance.inPreviewMode ? _layerManager.preview_room_avatar : _layerManager.room_avatars;
                  if(_loc11_)
                  {
                     _loc3_.name = String(_loc11_);
                  }
                  _loc7_.addChild(_loc3_);
            }
         }
      }
      
      private function addListenersToItem(param1:DenItemHelper, param2:DenStateItem) : void
      {
         param1.addMouseListeners(param2,onItemDown,onItemOver,onItemOut);
      }
      
      private function addPortalListenersToItem(param1:DenItemHelper, param2:DenStateItem) : void
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
      
      private function onItemDown(param1:MouseEvent, param2:int, param3:int, param4:String, param5:int, param6:String, param7:int, param8:String, param9:Boolean) : void
      {
         var _loc10_:Object = null;
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1);
         if(param2 > 0)
         {
            _loc10_ = {"typeDefId":param2};
            MinigameManager.handleGameClick(_loc10_,null);
         }
         else if(param3 > 0)
         {
            GuiManager.openPageFlipBook(param3,true,true,false);
         }
         else if(param9)
         {
            GuiManager.openMasterpiecePreview(param4,param6,param7,param8,param5);
         }
      }
      
      private function onPortalItemDown(param1:MouseEvent, param2:int, param3:int, param4:String, param5:int, param6:String, param7:int, param8:String, param9:Boolean) : void
      {
      }
      
      private function onItemOver(param1:MouseEvent, param2:DenStateItem, param3:int, param4:int, param5:String, param6:int, param7:String, param8:int, param9:String, param10:Boolean) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1);
         var _loc11_:Sprite = Sprite(param1.currentTarget);
         GuiManager.toolTip.init(_layerManager.room_orbs,param3 > 0 ? MinigameManager.getGameName(param3) : LocalizationManager.translateIdOnly(param2.denItemHelper.nameStrId),param2.x + _loc11_.width * 0.5,param2.y + _loc11_.height - 75);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onPortalItemOver(param1:MouseEvent, param2:DenStateItem, param3:int, param4:int, param5:String, param6:int, param7:String, param8:int, param9:String, param10:Boolean) : void
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

