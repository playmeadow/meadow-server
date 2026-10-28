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
      
      public function ItemWindowChapterSelect(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         super(2162,windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
         this._currMovieNodeDef = MovieNode(currItem);
         this._baseDefId = customParams.baseDefId;
      }
      
      public function getMovieNodeDef() : MovieNode
      {
         return this._currMovieNodeDef;
      }
      
      public function activateGrayState(b:Boolean) : void
      {
         this._isGray = b;
         _window.activateGrayState(b);
      }
      
      public function get isGray() : Boolean
      {
         return this._isGray;
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var shouldStillShowGift:Boolean = false;
         if(this._currMovieNodeDef.defId != this._baseDefId && !gMainFrame.userInfo.userVarCache.isBitSet(this._currMovieNodeDef.userVarId,this._currMovieNodeDef.bitIndex))
         {
            if(this._currMovieNodeDef.bitIndex > 0 && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(this._currMovieNodeDef.userVarId,this._currMovieNodeDef.bitIndex - 1)))
            {
               this.activateGrayState(false);
               shouldStillShowGift = true;
            }
            else
            {
               this.activateGrayState(true);
            }
         }
         if(this._currMovieNodeDef.thisChapterHasGift && (shouldStillShowGift || this._isGray))
         {
            _window.btnCont.showGift(true);
         }
         else
         {
            _window.btnCont.showGift(false);
         }
         var text:String = LocalizationManager.translateIdOnly(this._currMovieNodeDef.streamTitleId);
         if(this._isGray)
         {
            text = text.slice(0,text.indexOf(":"));
         }
         LocalizationManager.updateToFit(_window.btnCont.mouse.up.txt,text);
         LocalizationManager.updateToFit(_window.btnCont.gray.txt,text);
      }
      
      override protected function addEventListeners() : void
      {
         if(Boolean(_window))
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

