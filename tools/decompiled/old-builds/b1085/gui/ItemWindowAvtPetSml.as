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
      
      public function ItemWindowAvtPetSml(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._isPet = param9 != null ? Boolean(param9.isPet) : false;
         this._isMember = param9 != null ? Boolean(param9.isMember) : false;
         this._nameBarData = param9 != null ? int(param9.nameBarData) : 0;
         if(!this._isPet)
         {
            this._ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenDbAvId(param2.userName,param2.dbAvId);
         }
         super("charBtnSmlCont",param1,param2,param3,param4,param5,param6,param7,param8);
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
      
      override public function gotoAndStop(param1:Object, param2:String = null) : void
      {
         _window.gotoAndStop(param1,param2);
         if(this._currFrameName)
         {
            if(param1 == "over")
            {
               this.xpShape[this._currFrameName].mouse.gotoAndPlay(1);
            }
            else
            {
               this.xpShape[this._currFrameName].mouse.gotoAndStop(1);
            }
         }
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
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
         var _loc1_:Object = null;
         _window.sel.visible = false;
         if(this._isPet)
         {
            _loc1_ = _currItem;
            _loc1_.x = this.width * 0.5;
            _loc1_.y = this.height * 0.8;
            _loc1_.scaleX = _loc1_.scaleY = 1.1;
            _currItem = _loc1_;
         }
      }
   }
}

