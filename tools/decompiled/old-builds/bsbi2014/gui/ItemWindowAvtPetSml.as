package gui
{
   import avatar.AvatarInfo;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ItemWindowAvtPetSml extends ItemWindowBase
   {
      
      private var _isPet:Boolean;
      
      private var _ai:AvatarInfo;
      
      private var _isMember:Boolean;
      
      private var _nameBarData:int;
      
      private var _currFrameName:String;
      
      public function ItemWindowAvtPetSml(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._isPet = customParams != null ? Boolean(customParams.isPet) : false;
         this._isMember = customParams != null ? Boolean(customParams.isMember) : false;
         this._nameBarData = customParams != null ? int(customParams.nameBarData) : 0;
         if(!this._isPet)
         {
            this._ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(currItem.userName,currItem.perUserAvId);
         }
         super("charBtnSmlCont",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      public function get sel() : MovieClip
      {
         return _window.sel;
      }
      
      public function get isPet() : Boolean
      {
         return this._isPet;
      }
      
      public function get charLayer() : MovieClip
      {
         return _window.charLayer;
      }
      
      public function get xpShape() : MovieClip
      {
         return _window.xpShape;
      }
      
      override public function gotoAndStop(frame:Object, scene:String = null) : void
      {
         _window.gotoAndStop(frame,scene);
         if(Boolean(this._currFrameName))
         {
            if(frame == "over")
            {
               this.xpShape[this._currFrameName].mouse.gotoAndPlay(1);
            }
            else
            {
               this.xpShape[this._currFrameName].mouse.gotoAndStop(1);
            }
         }
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         _itemYLocation = currYLocation;
         _itemXLocation = currXLocation;
         if(Boolean(_currItem) && !_isCurrItemLoaded)
         {
            _isCurrItemLoaded = true;
            _window.charLayer.addChild(DisplayObject(_currItem));
            if(Boolean(this._ai) && this._ai.questLevel > 0)
            {
               this._currFrameName = this.xpShape.currentLabels[Utility.getColorId(this._nameBarData) - 1].name;
               if(this.xpShape.currentFrameLabel != this._currFrameName)
               {
                  this.xpShape.gotoAndStop(this._currFrameName);
               }
               Utility.createXpShape(this._ai.questLevel,this._isMember,this.xpShape[this._currFrameName].mouse.up.icon,this.xpShape[this._currFrameName].mouse.mouse.icon,int.MAX_VALUE);
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var tempItem:Object = null;
         _window.sel.visible = false;
         if(this._isPet)
         {
            tempItem = _currItem;
            tempItem.x = this.width * 0.5;
            tempItem.y = this.height * 0.8;
            tempItem.scaleX = tempItem.scaleY = 1.1;
            _currItem = tempItem;
         }
      }
   }
}

