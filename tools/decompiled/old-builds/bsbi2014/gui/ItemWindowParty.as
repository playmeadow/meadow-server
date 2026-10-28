package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   
   public class ItemWindowParty extends ItemWindowBase
   {
      
      private var _defId:int;
      
      public function ItemWindowParty(windowLoaded:Function, currItem:MovieClip, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         super(customParams.mediaRefId[index],windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.anims.mouseEnabled = false;
         _window.anims.mouseChildren = false;
         _window.txt.mouseEnabled = false;
         _window.txt.mouseChildren = false;
      }
      
      override protected function addEventListeners() : void
      {
         if(Boolean(_window))
         {
            if(_mouseDown != null && !(_memberOnlyDown != null && !gMainFrame.userInfo.isMember))
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
            if(_memberOnlyDown != null && !gMainFrame.userInfo.isMember)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_memberOnlyDown,false,0,true);
            }
         }
      }
      
      public function setupTextAndAnims(secToStart:int, printTime:String) : void
      {
         if(secToStart > 0)
         {
            _window.goBtn.visible = false;
            _window.txt.timeTxt.text = printTime;
         }
         else
         {
            _window.goBtn.visible = true;
            _window.txt.timeTxt.visible = false;
            _window.anims.animate();
         }
      }
      
      public function get txt() : MovieClip
      {
         return _window.txt;
      }
      
      public function set titleText(id:int) : void
      {
         if(Boolean(_window.txt.hasOwnProperty("titleTxt")))
         {
            LocalizationManager.translateId(_window.txt.titleTxt,id);
         }
      }
      
      public function set defId(value:int) : void
      {
         this._defId = value;
      }
      
      public function get defId() : int
      {
         return this._defId;
      }
   }
}

