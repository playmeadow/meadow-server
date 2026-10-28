package gui
{
   import flash.display.MovieClip;
   
   public class ItemWindowAvtPetSml extends ItemWindowBase
   {
      
      private var _isPet:Boolean;
      
      public function ItemWindowAvtPetSml(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._isPet = param9 != null ? Boolean(param9.isPet) : false;
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
      
      override public function gotoAndStop(param1:Object, param2:String = null) : void
      {
         _window.gotoAndStop(param1,param2);
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

