package gui
{
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   import movie.MovieNode;
   
   public class ItemWindowChapterSelect extends ItemWindowBase
   {
      
      private var _currMovieNodeDef:MovieNode;
      
      private var _isGray:Boolean;
      
      private var _baseDefId:int;
      
      public function ItemWindowChapterSelect(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super(2162,param1,param2,param3,param4,param5,param6,param7,param8);
         this._currMovieNodeDef = MovieNode(param2);
         this._baseDefId = param9.baseDefId;
      }
      
      public function getMovieNodeDef() : MovieNode
      {
         return this._currMovieNodeDef;
      }
      
      public function activateGrayState(param1:Boolean) : void
      {
         this._isGray = param1;
         _window.activateGrayState(param1);
      }
      
      public function get isGray() : Boolean
      {
         return this._isGray;
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:Boolean = false;
         if(this._currMovieNodeDef.defId != this._baseDefId && !gMainFrame.userInfo.userVarCache.isBitSet(this._currMovieNodeDef.userVarId,this._currMovieNodeDef.bitIndex))
         {
            if(this._currMovieNodeDef.bitIndex > 0 && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(this._currMovieNodeDef.userVarId,this._currMovieNodeDef.bitIndex - 1)))
            {
               this.activateGrayState(false);
               _loc1_ = true;
            }
            else
            {
               this.activateGrayState(true);
            }
         }
         if(this._currMovieNodeDef.thisChapterHasGift && (_loc1_ || this._isGray))
         {
            _window.btnCont.showGift(true);
         }
         else
         {
            _window.btnCont.showGift(false);
         }
         var _loc2_:String = LocalizationManager.translateIdOnly(this._currMovieNodeDef.streamTitleId);
         if(this._isGray)
         {
            _loc2_ = _loc2_.slice(0,_loc2_.indexOf(":"));
         }
         LocalizationManager.updateToFit(_window.btnCont.mouse.up.txt,_loc2_);
         LocalizationManager.updateToFit(_window.btnCont.gray.txt,_loc2_);
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
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
            if(_memberOnlyDown != null)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_memberOnlyDown,false,0,true);
            }
         }
      }
   }
}

