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
         _isPet = param9 != null ? param9.isPet : false;
         _isMember = param9 != null ? param9.isMember : false;
         _nameBarData = param9 != null ? param9.nameBarData : 0;
         if(!_isPet)
         {
            _ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(param2.userName,param2.perUserAvId);
         }
         super("charBtnSmlCont",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get sel() : MovieClip
      {
         return _window.sel;
      }
      
      public function get isPet() : Boolean
      {
         return _isPet;
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
         if(_currFrameName)
         {
            if(param1 == "over")
            {
               xpShape[_currFrameName].mouse.gotoAndPlay(1);
            }
            else
            {
               xpShape[_currFrameName].mouse.gotoAndStop(1);
            }
         }
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !_isCurrItemLoaded)
         {
            _isCurrItemLoaded = true;
            _window.charLayer.addChild(DisplayObject(_currItem));
            if(_ai && _ai.questLevel > 0)
            {
               _currFrameName = xpShape.currentLabels[Utility.getColorId(_nameBarData) - 1].name;
               if(xpShape.currentFrameLabel != _currFrameName)
               {
                  xpShape.gotoAndStop(_currFrameName);
               }
               Utility.createXpShape(_ai.questLevel,_isMember,xpShape[_currFrameName].mouse.up.icon,xpShape[_currFrameName].mouse.mouse.icon,2147483647);
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:Object = null;
         _window.sel.visible = false;
         if(_isPet)
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

