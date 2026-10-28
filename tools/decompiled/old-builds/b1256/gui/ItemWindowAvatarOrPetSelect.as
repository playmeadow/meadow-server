package gui
{
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class ItemWindowAvatarOrPetSelect extends ItemWindowBase
   {
      
      private var _mediaHelper:MediaHelper;
      
      private var _currIconId:int;
      
      private var _forCreation:Boolean;
      
      private var _avType:int;
      
      private var _currDef:Object;
      
      private var _shouldShowDiamond:Boolean;
      
      private var _customAvId:int;
      
      private var _creationAvatar:Avatar;
      
      private var _isPet:Boolean;
      
      private var _currGuiPet:GuiPet;
      
      private var _selectedIndex:int;
      
      public function ItemWindowAvatarOrPetSelect(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _currIconId = int(param2);
         _isPet = param9.isPet == null ? false : true;
         _selectedIndex = param9.selectedIndex == null ? 0 : param9.selectedIndex;
         if(!_isPet)
         {
            _forCreation = param9.forCreation == null ? false : param9.forCreation;
            _avType = param9.avTypes[param4];
            _creationAvatar = param9.creationAvatars[param4];
            _customAvId = _creationAvatar.customAvId;
            _currDef = AvatarUtility.findAvDefByType(_avType,_customAvId);
            _shouldShowDiamond = _currDef.isDiamond && !AvatarUtility.getAvatarDefIsViewableWithAvId(_avType,_customAvId != -1);
         }
         else
         {
            _currDef = PetManager.getPetDef(_currIconId);
            _shouldShowDiamond = _currDef.isDiamond;
         }
         super(1810,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get currIconId() : int
      {
         return _currIconId;
      }
      
      public function get currWindow() : MovieClip
      {
         return _window;
      }
      
      public function get customAvId() : int
      {
         return _customAvId;
      }
      
      public function selectItem() : void
      {
         if(_window.currentFrameLabel != (!_isPet && isDiamond) ? "diamond_down" : "down")
         {
            _window.gotoAndStop(!_isPet && isDiamond ? "diamond_down" : "down");
         }
      }
      
      public function deselect() : void
      {
         if(_window.currentFrameLabel != (!_isPet && isDiamond) ? "diamond_up" : "up")
         {
            _window.gotoAndStop(!_isPet && isDiamond ? "diamond_up" : "up");
         }
      }
      
      public function setupLayers() : void
      {
         _window.diamond.visible = _shouldShowDiamond;
      }
      
      public function get isDiamond() : Boolean
      {
         return _currDef.isDiamond;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(_currGuiPet)
         {
            _currGuiPet.destroy();
            _currGuiPet = null;
         }
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         if(_window)
         {
            if(_isPet)
            {
               if(!_isCurrItemLoaded)
               {
                  _loc3_ = PetManager.packPetBits(PetManager.createRandomPet(_currIconId));
                  _currGuiPet = PetManager.getGuiPet(0,_loc3_[0],_loc3_[1],_loc3_[2],_currDef.type,_currDef.title,null);
                  _window.diamond.visible = _shouldShowDiamond;
                  if(!gMainFrame.userInfo.isMember)
                  {
                     if(_currDef.isMember)
                     {
                        _window.memberLock.visible = true;
                     }
                  }
                  if(_currGuiPet.canGoInOcean())
                  {
                     _window.ocean.visible = true;
                  }
                  _currGuiPet.scaleX = _currGuiPet.scaleY = 2;
                  _currGuiPet.x = 53;
                  _currGuiPet.y = 85;
                  _window.itemWindow.addChild(_currGuiPet);
                  _isCurrItemLoaded = true;
               }
            }
            else if(_currItem is int && _currItem != 0)
            {
               _itemYLocation = param1;
               _itemXLocation = param2;
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(int(_currItem),onCurrItemLoaded);
            }
            else if(_currItem && !_isCurrItemLoaded)
            {
               _isCurrItemLoaded = true;
               if(!gMainFrame.userInfo.isMember)
               {
                  if(_currDef.isMemberOnly)
                  {
                     _window.memberLock.visible = true;
                  }
               }
               if(!_forCreation && Utility.isOcean(_currDef.enviroFlag))
               {
                  _window.ocean.visible = true;
               }
               if(AvatarUtility.isEndangered(_currDef.availability))
               {
                  if(_avType == 13 || _avType == 16 || _avType == 26)
                  {
                     LocalizationManager.translateId(_window.endangered.txt,11177);
                  }
                  else if(_avType == 6)
                  {
                     LocalizationManager.translateId(_window.endangered.txt,14226);
                  }
                  else
                  {
                     LocalizationManager.translateId(_window.endangered.txt,11178);
                  }
                  _window.endangered.visible = true;
               }
               if(AvatarUtility.isExtinct(_currDef.availability))
               {
                  _loc4_ = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];
                  _currItem.filters = [new ColorMatrixFilter(_loc4_)];
               }
               _window.diamond.visible = _shouldShowDiamond;
               if(_currDef.isDiamond && _window.currentFrameLabel != "diamond_down")
               {
                  _window.gotoAndStop("diamond_up");
               }
               if(_iconLayerName != "" && _currItem.hasOwnProperty(_iconLayerName))
               {
                  _window.itemWindow.addChild(_currItem[_iconLayerName]);
               }
               else
               {
                  _window.itemWindow.addChild(DisplayObject(_currItem));
               }
            }
            if(index == _selectedIndex)
            {
               selectItem();
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.memberLock.visible = false;
         _window.endangered.visible = false;
         _window.ocean.visible = false;
         _window.diamond.visible = false;
         if(_forCreation)
         {
            loadCurrItem();
         }
      }
      
      private function onCurrItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _currItem = param1.getChildAt(0);
            loadCurrItem();
         }
      }
   }
}

