package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import game.MinigameInfo;
   import game.MinigameManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ItemWindowGameIcon extends ItemWindowBase
   {
      
      private var _mediaHelper:MediaHelper;
      
      private var _currGameDefId:int;
      
      private var _mgf:MinigameInfo;
      
      private var _toolTipName:String = "";
      
      public function ItemWindowGameIcon(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _currGameDefId = int(param2);
         super(4314,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get itemYLocation() : Number
      {
         return _itemYLocation;
      }
      
      public function get itemXLocation() : Number
      {
         return _itemXLocation;
      }
      
      public function get toolTipName() : String
      {
         return _toolTipName;
      }
      
      public function get currGamDefId() : int
      {
         return _currGameDefId;
      }
      
      public function get currWindow() : MovieClip
      {
         return _window;
      }
      
      public function get currItem() : MovieClip
      {
         if(!(_currItem is int))
         {
            return _currItem as MovieClip;
         }
         return _window;
      }
      
      public function get doubleGems() : MovieClip
      {
         return _window.mouse.mouse.doubleGems;
      }
      
      public function get gameLaunchObject() : Object
      {
         return {"typeDefId":_mgf.gameDefId};
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem is int)
         {
            _mgf = MinigameManager.minigameInfoCache.getMinigameInfo(_currGameDefId);
            if(_mgf.gemMultiplier > 1)
            {
               _window.mouse.mouse.doubleGems.visible = true;
            }
            _toolTipName = LocalizationManager.translateIdOnly(_mgf.titleStrId);
            if(_mgf)
            {
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(_mgf.gameLibraryIconMediaId,onCurrItemLoaded);
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.mouse.mouse.doubleGems.visible = false;
      }
      
      private function onCurrItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _currItem = param1.getChildAt(0);
            _isCurrItemLoaded = true;
            _currItem.x += _currItem.width * 0.5;
            _currItem.y += _currItem.height * 0.5;
            _window.mouse.mouse.itemWindow.addChild(DisplayObject(_currItem));
         }
      }
   }
}

