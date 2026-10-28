package gui
{
   import den.DenItem;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
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
      
      private var _showAddRemoveBtns:Boolean;
      
      private var _hasBeenHidden:Boolean;
      
      public function ItemWindowOriginal(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         var _loc10_:int = 0;
         var _loc11_:int = param4;
         _generatorIndex = param4;
         if(param9 != null)
         {
            _loadImmediately = param9.loadImmediately;
            _isRecycling = param9.isRecycling;
            _isViewingATradeList = param9.isViewingATradeList;
            _isECard = param9.isECard;
            _isAvatarEditor = param9.isAvatarEditor;
            _isTradeManager = param9.isTradeManager;
            _isAudio = param9.isAudio;
            _isPetItem = param9.isPetItem;
            _giftItemIdx = param9.giftItemIdx;
            _isTradeList = param9.isTradeList;
            _isChoosingForTradeList = param9.isChoosingForTradeList;
            _showAddRemoveBtns = param9.showAddRemoveBtns;
            if(param9.indexArray != null)
            {
               _loc10_ = int(param9.indexArray.length);
               _loc11_ = int(_loc10_ - 1 > param4 ? param9.indexArray[param4] : param9.indexArray[_loc10_ - 1] - param4 + param4);
            }
         }
         super("itemWindow",param1,param2,param3,_loc11_,param5,param6,param7,param8,true);
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
      
      public function get sizeCont() : MovieClip
      {
         return _window.sizeCont;
      }
      
      public function get gift() : MovieClip
      {
         return _window.gift;
      }
      
      public function get isDownGift() : Boolean
      {
         return _isDownGift;
      }
      
      public function get isActivePet() : Boolean
      {
         return _isActivePet;
      }
      
      public function get isLastPlacedAudio() : Boolean
      {
         return _isLastPlacedAudio;
      }
      
      public function get isAudio() : Boolean
      {
         return _isAudio;
      }
      
      public function get isUsable() : Boolean
      {
         return _currItem == null;
      }
      
      public function get currItem() : Object
      {
         return _currItem;
      }
      
      public function get itemName() : String
      {
         if(_currItem)
         {
            return _currItem.name;
         }
         return "";
      }
      
      override public function get numChildren() : int
      {
         return _window.numChildren;
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         return _window.getChildAt(param1);
      }
      
      public function resetDownGift() : void
      {
         _window.gift.visible = false;
         _isDownGift = false;
      }
      
      public function set currDownGift(param1:Object) : void
      {
         _isDownGift = true;
         _window.gift.visible = true;
      }
      
      public function resetAudioDown() : void
      {
         _isLastPlacedAudio = false;
         _window.cir.gotoAndStop("up");
      }
      
      public function setAudioDown() : void
      {
         _isLastPlacedAudio = true;
         _window.cir.gotoAndStop("down");
      }
      
      public function get defId() : int
      {
         if(_currItem)
         {
            if(_currItem is Item)
            {
               return _currItem.defId;
            }
            return _currItem.itemDefId;
         }
         return -1;
      }
      
      public function get avtSpecific() : MovieClip
      {
         return _window.avtSpecific;
      }
      
      public function get hasBeenHidden() : Boolean
      {
         return _hasBeenHidden;
      }
      
      public function removeLoadedItem() : void
      {
         _hasBeenHidden = true;
         if(_currItem)
         {
            if(_iconLayerName != "" && _currItem.hasOwnProperty(_iconLayerName))
            {
               if(_currItem[_iconLayerName].parent == _window.iconLayer)
               {
                  _window.iconLayer.removeChild(_currItem[_iconLayerName]);
               }
            }
            else if(_currItem.parent == _window.iconLayer)
            {
               _window.iconLayer.removeChild(_currItem);
            }
         }
         resetDownGift();
         resetAudioDown();
         resetVisibility();
         super.removeEventListeners();
      }
      
      public function updateWithInput(param1:*) : void
      {
         _hasBeenHidden = false;
         _currItem = param1;
         _isCurrItemLoaded = false;
         setChildrenAndInitialConditions();
         loadCurrItem();
         addEventListeners();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc3_:Object = null;
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !_isCurrItemLoaded && !_hasBeenHidden)
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
            if(_isTradeManager)
            {
               if(_currItem is Item)
               {
                  _loc3_ = _currItem;
                  _currItem = _loc3_.clone();
               }
               else
               {
                  _loc3_ = _currItem;
                  _currItem = _loc3_.clone();
               }
            }
            if(_currItem.isMemberOnly)
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  _window.lock.visible = true;
                  if(!isSpecialList())
                  {
                     _window.gray.visible = true;
                  }
               }
               else
               {
                  _window.lockOpen.visible = true;
               }
            }
            if(_currItem.isOcean)
            {
               _window.ocean.visible = true;
            }
            if(_currItem.isRareDiamond)
            {
               _window.rareDiamondTag.visible = true;
            }
            else
            {
               if(_currItem.isRare)
               {
                  _window.rare.visible = true;
               }
               _window.diamond.visible = _currItem.isDiamond;
            }
            if(_showAddRemoveBtns && (_isTradeList || _isTradeManager))
            {
               _window.removeBtn.visible = true;
               _window.addBtn.visible = false;
            }
            if(_isPetItem && _currItem.invIdx == PetManager.myActivePetInvId)
            {
               _window.cir.gotoAndStop("green");
               _isActivePet = true;
            }
            if(_currItem is Item)
            {
               if(_currItem.getInUse(gMainFrame.userInfo.myPerUserAvId))
               {
                  _window.cir.gotoAndStop("down");
               }
            }
            else if(_currItem is DenItem)
            {
               if(_currItem.categoryId != 0 && !_isActivePet)
               {
                  _isLastPlacedAudio = true;
                  _window.cir.gotoAndStop("down");
               }
            }
            if(_isECard)
            {
               if(_giftItemIdx == _currItem.invIdx)
               {
                  this.gift.visible = true;
                  _isDownGift = true;
               }
            }
         }
         else if(_currItem == null)
         {
            _isCurrItemLoaded = false;
            resetVisibility();
            resetDownGift();
            resetAudioDown();
            if(_showAddRemoveBtns && (_isTradeList || _isTradeManager))
            {
               _window.addBtn.visible = true;
            }
            while(_window.iconLayer.numChildren > 1)
            {
               _window.iconLayer.removeChildAt(_window.iconLayer.numChildren - 1);
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         resetVisibility();
         if(_currItem)
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
            if(_loadImmediately)
            {
               loadCurrItem();
            }
         }
         else if(_showAddRemoveBtns && (_isTradeList || _isTradeManager))
         {
            _window.addBtn.visible = true;
         }
      }
      
      override protected function onWindowLoadCallback() : void
      {
         if(_windowLoadedCallback != null)
         {
            _windowLoadedCallback(this,_generatorIndex);
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_window && _currItem)
         {
            if(_mouseDown != null && !(_currItem.isMemberOnly && _memberOnlyDown != null && !gMainFrame.userInfo.isMember && !isSpecialList()))
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener("rollOver",_mouseOver,false,0,true);
               if(_useToolTip)
               {
                  addEventListener("rollOver",onWindowRollOver,false,0,true);
               }
            }
            if(_mouseOut != null)
            {
               addEventListener("rollOut",_mouseOut,false,0,true);
               if(_useToolTip)
               {
                  addEventListener("rollOut",onWindowRollOut,false,0,true);
               }
            }
            if(_memberOnlyDown != null && _currItem.isMemberOnly && !gMainFrame.userInfo.isMember && !isSpecialList())
            {
               addEventListener("mouseDown",_memberOnlyDown,false,0,true);
            }
         }
         else if(_showAddRemoveBtns && (_isTradeList || _isTradeManager))
         {
            if(_mouseDown != null)
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener("rollOver",_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener("rollOut",_mouseOut,false,0,true);
            }
         }
      }
      
      private function isSpecialList() : Boolean
      {
         return _isTradeList || _isTradeManager || _isChoosingForTradeList || _isViewingATradeList || _isECard || _isRecycling;
      }
      
      private function resetVisibility() : void
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
         _window.rareDiamondTag.visible = false;
         _window.diamond.visible = false;
      }
   }
}

