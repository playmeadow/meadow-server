package gui
{
   import avatar.AvatarManager;
   import den.DenItem;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import item.Item;
   import item.ItemXtCommManager;
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
      
      public function ItemWindowOriginal(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         var _loc11_:int = 0;
         var _loc10_:int = param4;
         this._generatorIndex = param4;
         if(param9 != null)
         {
            this._loadImmediately = param9.loadImmediately;
            this._isRecycling = param9.isRecycling;
            this._isViewingATradeList = param9.isViewingATradeList;
            this._isECard = param9.isECard;
            this._isAvatarEditor = param9.isAvatarEditor;
            this._isTradeManager = param9.isTradeManager;
            this._isAudio = param9.isAudio;
            this._isPetItem = param9.isPetItem;
            this._giftItemIdx = param9.giftItemIdx;
            this._isTradeList = param9.isTradeList;
            this._isChoosingForTradeList = param9.isChoosingForTradeList;
            if(param9.indexArray != null)
            {
               _loc11_ = int(param9.indexArray.length);
               _loc10_ = _loc11_ - 1 > param4 ? int(param9.indexArray[param4]) : int(param9.indexArray[_loc11_ - 1] - param4 + param4);
            }
         }
         super("itemWindow",param1,param2,param3,_loc10_,param5,param6,param7,param8,true);
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
      
      public function get avtSpecificIcon() : MovieClip
      {
         return _window.avtSpecificIcon;
      }
      
      public function get avtSpecificHighlight() : MovieClip
      {
         return _window.avtSpecificHighlight;
      }
      
      public function get isAvatarSpecific() : Boolean
      {
         return _window.avtSpecific.visible;
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
         this._isDownGift = false;
      }
      
      public function set currDownGift(param1:Object) : void
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
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         _itemYLocation = param1;
         _itemXLocation = param2;
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
                  _loc3_ = _currItem;
                  _currItem = new Item();
                  _currItem.init(_loc3_.defId,_loc3_.invIdx,_loc3_.color,_loc3_.getInUse(AvatarManager.playerAvatar.dbAvId));
               }
               else
               {
                  _loc3_ = _currItem;
                  _currItem = new DenItem();
                  _currItem.init(_loc3_.itemDefId,_loc3_.invIdx,_loc3_.categoryId,_loc3_.version,_loc3_.refId);
                  _currItem.name = _loc3_.name;
               }
            }
            if(_currItem.isMemberOnly)
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
            if(_currItem is Item)
            {
               if(Boolean(AvatarManager.playerAvatar) && Boolean(!ItemXtCommManager.canUseItem(_currItem.defId,AvatarManager.playerAvatar.avTypeId)) && ItemXtCommManager.isItemSpecificToSomeAvatar(_currItem.defId,_currItem.enviroType))
               {
                  _loc4_ = String(ItemXtCommManager.getFirstAvTypeThatCanUseItem(_currItem.defId));
                  if(_loc4_ != "-1")
                  {
                     if(_window.avtSpecific.currentFrameLabel != _loc4_)
                     {
                        _window.avtSpecific.gotoAndStop(_loc4_);
                     }
                     _window.avtSpecific.visible = true;
                  }
               }
            }
            if(_currItem.isOcean)
            {
               _window.ocean.visible = true;
            }
            if(_currItem.isRare)
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
               if(_currItem.getInUse(gMainFrame.userInfo.myDbAvId))
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

