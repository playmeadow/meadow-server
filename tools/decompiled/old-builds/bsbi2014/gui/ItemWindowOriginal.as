package gui
{
   import avatar.AvatarManager;
   import den.DenItem;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import item.Item;
   import pet.PetManager;
   
   public class ItemWindowOriginal extends ItemWindowBase
   {
      
      private var _isAvatarEditor:Boolean;
      
      private var _isTradeList:Boolean;
      
      private var _isChoosingForTradeList:Boolean;
      
      private var _generatorIndex:int;
      
      private var _giftItemIdx:int;
      
      private var _isDownGift:Boolean;
      
      private var _isPetItem:Boolean;
      
      private var _isActivePet:Boolean;
      
      private var _isAudio:Boolean;
      
      private var _isLastPlacedAudio:Boolean;
      
      private var _isTradeManager:Boolean;
      
      private var _isECard:Boolean;
      
      private var _isViewingATradeList:Boolean;
      
      private var _isRecycling:Boolean;
      
      private var _loadImmediately:Boolean;
      
      public function ItemWindowOriginal(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         var indexArrayLength:int = 0;
         var indexCount:int = index;
         this._generatorIndex = index;
         if(customParams != null)
         {
            this._loadImmediately = customParams.loadImmediately;
            this._isRecycling = customParams.isRecycling;
            this._isViewingATradeList = customParams.isViewingATradeList;
            this._isECard = customParams.isECard;
            this._isAvatarEditor = customParams.isAvatarEditor;
            this._isTradeManager = customParams.isTradeManager;
            this._isAudio = customParams.isAudio;
            this._isPetItem = customParams.isPetItem;
            this._giftItemIdx = customParams.giftItemIdx;
            this._isTradeList = customParams.isTradeList;
            this._isChoosingForTradeList = customParams.isChoosingForTradeList;
            if(customParams.indexArray != null)
            {
               indexArrayLength = int(customParams.indexArray.length);
               indexCount = indexArrayLength - 1 > index ? int(customParams.indexArray[index]) : int(customParams.indexArray[indexArrayLength - 1] - index + index);
            }
         }
         super("itemWindow",windowLoaded,currItem,iconLayerName,indexCount,mouseDown,mouseOver,mouseOut,memberOnlyDown,true);
      }
      
      public function get removeBtn() : MovieClip
      {
         return _window.removeBtn;
      }
      
      public function get addBtn() : MovieClip
      {
         return _window.addBtn;
      }
      
      public function get cir() : MovieClip
      {
         return _window.cir;
      }
      
      public function get gift() : MovieClip
      {
         return _window.gift;
      }
      
      public function get isDownGift() : Boolean
      {
         return this._isDownGift;
      }
      
      public function get isActivePet() : Boolean
      {
         return this._isActivePet;
      }
      
      public function get isLastPlacedAudio() : Boolean
      {
         return this._isLastPlacedAudio;
      }
      
      public function get isAudio() : Boolean
      {
         return this._isAudio;
      }
      
      override public function get numChildren() : int
      {
         return _window.numChildren;
      }
      
      override public function getChildAt(index:int) : DisplayObject
      {
         return _window.getChildAt(index);
      }
      
      public function resetDownGift() : void
      {
         _window.gift.visible = false;
         this._isDownGift = false;
      }
      
      public function set currDownGift(o:Object) : void
      {
         this._isDownGift = true;
         _window.gift.visible = true;
      }
      
      public function resetAudioDown() : void
      {
         this._isLastPlacedAudio = false;
         _window.cir.gotoAndStop("up");
      }
      
      public function setAudioDown() : void
      {
         this._isLastPlacedAudio = true;
         _window.cir.gotoAndStop("down");
      }
      
      public function get defId() : int
      {
         if(Boolean(_currItem))
         {
            if(_currItem is Item)
            {
               return _currItem.defId;
            }
            return _currItem.itemDefId;
         }
         return -1;
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         var tempItem:Object = null;
         _itemYLocation = currYLocation;
         _itemXLocation = currXLocation;
         if(Boolean(_currItem) && !_isCurrItemLoaded)
         {
            _isCurrItemLoaded = true;
            if(_iconLayerName != "" && _currItem.hasOwnProperty(_iconLayerName))
            {
               _window.iconLayer.addChild(_currItem[_iconLayerName]);
            }
            else
            {
               _window.iconLayer.addChild(DisplayObject(_currItem));
            }
            if(this._isTradeManager)
            {
               if(_currItem is Item)
               {
                  tempItem = _currItem;
                  _currItem = new Item();
                  _currItem.init(tempItem.defId,tempItem.invIdx,tempItem.color,tempItem.getInUse(AvatarManager.playerAvatar.perUserAvId));
               }
               else
               {
                  tempItem = _currItem;
                  _currItem = new DenItem();
                  _currItem.init(tempItem.itemDefId,tempItem.invIdx,tempItem.categoryId,tempItem.version,tempItem.refId);
                  _currItem.name = tempItem.name;
               }
            }
            if(Boolean(_currItem.isMemberOnly))
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  _window.lock.visible = true;
                  if(!this.isSpecialList())
                  {
                     _window.gray.visible = true;
                  }
               }
               else
               {
                  _window.lockOpen.visible = true;
               }
            }
            if(Boolean(_currItem.isOcean))
            {
               _window.ocean.visible = true;
            }
            if(Boolean(_currItem.isRare))
            {
               _window.rare.visible = true;
            }
            if(this._isTradeList || this._isTradeManager)
            {
               _window.removeBtn.visible = true;
            }
            if(this._isPetItem && _currItem.invIdx == PetManager.myActivePetInvId)
            {
               _window.cir.gotoAndStop("green");
               this._isActivePet = true;
            }
            if(_currItem is Item)
            {
               if(Boolean(_currItem.getInUse(gMainFrame.userInfo.myPerUserAvId)))
               {
                  _window.cir.gotoAndStop("down");
               }
            }
            else if(_currItem is DenItem)
            {
               if(_currItem.categoryId != 0 && !this._isActivePet)
               {
                  this._isLastPlacedAudio = true;
                  _window.cir.gotoAndStop("down");
               }
            }
            if(this._isECard)
            {
               if(this._giftItemIdx == _currItem.invIdx)
               {
                  this.gift.visible = true;
                  this._isDownGift = true;
               }
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.lock.visible = false;
         _window.lockOpen.visible = false;
         _window.gray.visible = false;
         _window.gift.visible = false;
         _window.addBtn.visible = false;
         _window.removeBtn.visible = false;
         _window.ocean.visible = false;
         _window.rare.visible = false;
         _window.avtSpecific.visible = false;
         _window.avtSpecificIcon.visible = false;
         _window.avtSpecificHighlight.visible = false;
         if(Boolean(_currItem))
         {
            if(!_spiral)
            {
               _spiral = new LoadingSpiral(_window.iconLayer);
            }
            else
            {
               _spiral.setNewParent(_window.iconLayer);
            }
            if(!_currItem.isIconLoaded)
            {
               _currItem.imageLoadedCallback = _spiral.destroy();
            }
            else
            {
               _spiral.destroy();
            }
            if(this._loadImmediately)
            {
               this.loadCurrItem();
            }
         }
         else if(this._isTradeList || this._isTradeManager)
         {
            _window.addBtn.visible = true;
         }
      }
      
      override protected function onWindowLoadCallback() : void
      {
         if(_windowLoadedCallback != null)
         {
            _windowLoadedCallback(this,this._generatorIndex);
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(Boolean(_window) && Boolean(_currItem))
         {
            if(_mouseDown != null && !(_currItem.isMemberOnly && _memberOnlyDown != null && !gMainFrame.userInfo.isMember && !this.isSpecialList()))
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener(MouseEvent.ROLL_OVER,_mouseOver,false,0,true);
               if(_useToolTip)
               {
                  addEventListener(MouseEvent.ROLL_OVER,onWindowRollOver,false,0,true);
               }
            }
            if(_mouseOut != null)
            {
               addEventListener(MouseEvent.ROLL_OUT,_mouseOut,false,0,true);
               if(_useToolTip)
               {
                  addEventListener(MouseEvent.ROLL_OUT,onWindowRollOut,false,0,true);
               }
            }
            if(Boolean(_memberOnlyDown != null && _currItem.isMemberOnly) && Boolean(!gMainFrame.userInfo.isMember) && !this.isSpecialList())
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_memberOnlyDown,false,0,true);
            }
         }
         else if(this._isTradeList || this._isTradeManager)
         {
            if(_mouseDown != null)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener(MouseEvent.ROLL_OVER,_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener(MouseEvent.ROLL_OUT,_mouseOut,false,0,true);
            }
         }
      }
      
      private function isSpecialList() : Boolean
      {
         return this._isTradeList || this._isTradeManager || this._isChoosingForTradeList || this._isViewingATradeList || this._isECard || this._isRecycling;
      }
   }
}

