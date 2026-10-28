package gui
{
   import avatar.AvatarUtility;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ItemWindowAvatarSelect extends ItemWindowBase
   {
      
      private var _mediaHelper:MediaHelper;
      
      private var _currIconId:int;
      
      private var _forCreation:Boolean;
      
      private var _avType:int;
      
      private var _avDef:Object;
      
      public function ItemWindowAvatarSelect(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._currIconId = int(currItem);
         this._forCreation = customParams.forCreation == null ? false : Boolean(customParams.forCreation);
         this._avType = customParams.avTypes[index];
         this._avDef = AvatarUtility.avatarDefInfo[AvatarUtility.findAvatarIndexByType(this._avType)];
         super(1810,windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      public function get currIconId() : int
      {
         return this._currIconId;
      }
      
      public function get currWindow() : MovieClip
      {
         return _window;
      }
      
      public function deselect() : void
      {
         if(_window.currentFrameLabel != "up")
         {
            _window.gotoAndStop("up");
         }
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         var matrix:Array = null;
         if(Boolean(_window))
         {
            if(_currItem is int)
            {
               _itemYLocation = currYLocation;
               _itemXLocation = currXLocation;
               this._mediaHelper = new MediaHelper();
               this._mediaHelper.init(int(_currItem),this.onCurrItemLoaded);
            }
            else if(Boolean(_currItem) && !_isCurrItemLoaded)
            {
               _isCurrItemLoaded = true;
               if(!gMainFrame.userInfo.isMember)
               {
                  if(Boolean(this._avDef.isMemberOnly))
                  {
                     _window.memberLock.visible = true;
                  }
               }
               if(!this._forCreation && Utility.isOcean(this._avDef.enviroFlag))
               {
                  _window.ocean.visible = true;
               }
               if(AvatarUtility.isEndangered(this._avDef.availability))
               {
                  if(this._avType == 13 || this._avType == 16 || this._avType == 26)
                  {
                     LocalizationManager.translateId(_window.endangered.txt,11177);
                  }
                  else if(this._avType == 6)
                  {
                     LocalizationManager.translateId(_window.endangered.txt,14226);
                  }
                  _window.endangered.visible = true;
               }
               if(AvatarUtility.isExtinct(this._avDef.availability))
               {
                  matrix = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];
                  _currItem.filters = [new ColorMatrixFilter(matrix)];
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
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.memberLock.visible = false;
         _window.endangered.visible = false;
         _window.ocean.visible = false;
         if(this._forCreation)
         {
            this.loadCurrItem();
         }
      }
      
      private function onCurrItemLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _currItem = img.getChildAt(0);
            this.loadCurrItem();
         }
      }
   }
}

