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
      
      public function ItemWindowAvatarSelect(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._currIconId = int(param2);
         this._forCreation = param9.forCreation == null ? false : Boolean(param9.forCreation);
         this._avType = param9.avTypes[param4];
         this._avDef = AvatarUtility.avatarDefInfo[AvatarUtility.findAvatarIndexByType(this._avType)];
         super(1810,param1,param2,param3,param4,param5,param6,param7,param8);
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
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc3_:Array = null;
         if(_window)
         {
            if(_currItem is int)
            {
               _itemYLocation = param1;
               _itemXLocation = param2;
               this._mediaHelper = new MediaHelper();
               this._mediaHelper.init(int(_currItem),this.onCurrItemLoaded);
            }
            else if(Boolean(_currItem) && !_isCurrItemLoaded)
            {
               _isCurrItemLoaded = true;
               if(!gMainFrame.userInfo.isMember)
               {
                  if(this._avDef.isMemberOnly)
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
                  _loc3_ = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];
                  _currItem.filters = [new ColorMatrixFilter(_loc3_)];
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
      
      private function onCurrItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _currItem = param1.getChildAt(0);
            this.loadCurrItem();
         }
      }
   }
}

