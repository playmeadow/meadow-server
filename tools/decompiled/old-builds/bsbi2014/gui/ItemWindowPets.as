package gui
{
   import avatar.AvatarManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class ItemWindowPets extends ItemWindowBase
   {
      
      private var _isRecycling:Boolean;
      
      private var _currGuiPet:GuiPet;
      
      public function ItemWindowPets(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._isRecycling = customParams.isRecycling;
         super("itemWindowPets",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown,true);
      }
      
      public function get cir() : MovieClip
      {
         return _window.cir;
      }
      
      public function get gray() : MovieClip
      {
         return _window.gray;
      }
      
      public function get cageIcon() : MovieClip
      {
         return _window.cageIcon;
      }
      
      public function get newPetIcon() : MovieClip
      {
         return _window.newPet;
      }
      
      public function get hasPet() : Boolean
      {
         return _currItem;
      }
      
      override public function destroy() : void
      {
         if(Boolean(this._currGuiPet))
         {
            this._currGuiPet.destroy();
            this._currGuiPet = null;
         }
         super.destroy();
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         var currPet:Object = null;
         _itemYLocation = currYLocation;
         _itemXLocation = currXLocation;
         if(Boolean(_currItem) && !_isCurrItemLoaded)
         {
            currPet = PetManager.getPetDef(_currItem.defId);
            this._currGuiPet = new GuiPet(_currItem.idx,_currItem.lBits,_currItem.uBits,_currItem.eBits,_currItem.type,_currItem.name,null);
            _window.cageIcon.visible = this._isRecycling;
            _window.ocean.visible = this._currGuiPet.canGoInOcean();
            if(!gMainFrame.userInfo.isMember)
            {
               _window.lockOpen.visible = false;
               if(Boolean(currPet.isMember))
               {
                  _window.gray.visible = true;
                  _window.lock.visible = true;
               }
               else
               {
                  _window.lock.visible = false;
                  _window.gray.visible = false;
               }
            }
            else
            {
               _window.lock.visible = false;
               _window.gray.visible = false;
               if(Boolean(currPet.isMember))
               {
                  _window.lockOpen.visible = true;
               }
               else
               {
                  _window.lockOpen.visible = false;
               }
            }
            _window.newPet.visible = false;
            if(!PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,currPet.type))
            {
               _window.gray.visible = true;
            }
            else if(PetManager.myActivePetInvId == this._currGuiPet.idx)
            {
               _window.cir.gotoAndStop("down");
            }
            this._currGuiPet.scaleX = this._currGuiPet.scaleY = 2;
            _isCurrItemLoaded = true;
            _window.iconLayer.addChild(this._currGuiPet);
         }
         if(Boolean(_spiral))
         {
            _spiral.destroy();
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _spiral = new LoadingSpiral(_window.iconLayer);
         _window.lockOpen.visible = false;
         _window.lock.visible = false;
         _window.gray.visible = false;
         _window.ocean.visible = false;
         _window.cageIcon.visible = false;
         _window.newPet.gray.visible = false;
      }
      
      override protected function addEventListeners() : void
      {
         if(Boolean(_window))
         {
            if(_mouseDown != null && !(_memberOnlyDown != null && !gMainFrame.userInfo.isMember))
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
            }
            if(_mouseOver != null && Boolean(_currItem))
            {
               addEventListener(MouseEvent.ROLL_OVER,_mouseOver,false,0,true);
               if(_useToolTip)
               {
                  addEventListener(MouseEvent.ROLL_OVER,this.onWindowRollOver,false,0,true);
               }
            }
            if(_mouseOut != null && Boolean(_currItem))
            {
               addEventListener(MouseEvent.ROLL_OUT,_mouseOut,false,0,true);
               if(_useToolTip)
               {
                  addEventListener(MouseEvent.ROLL_OUT,onWindowRollOut,false,0,true);
               }
            }
            if(_memberOnlyDown != null && !gMainFrame.userInfo.isMember)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_memberOnlyDown,false,0,true);
            }
         }
      }
      
      override protected function onWindowRollOver(evt:MouseEvent) : void
      {
         if(_useToolTip && this.parent != null)
         {
            if(_windowGenerator == null)
            {
               _windowGenerator = WindowGenerator(this.parent.parent);
            }
            _windowGenerator.toolTip.init(_windowGenerator.parent.parent,this._currGuiPet.petName,this.x + _windowGenerator.boxWidth * 0.5 + _windowGenerator.parent.x + _itemXLocation,this.y + _windowGenerator.boxHeight - _itemYLocation + _windowGenerator.parent.y - 5);
            _windowGenerator.toolTip.startTimer(evt);
         }
      }
   }
}

