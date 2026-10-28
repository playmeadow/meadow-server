package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ItemWindowParty extends ItemWindowBase
   {
      
      private var _defId:int;
      
      public function ItemWindowParty(param1:Function, param2:MovieClip, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super(param9.mediaRefId[param4],param1,param2,param3,param4,param5,param6,param7,param8);
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
         if(_window)
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
      
      public function setupTextAndAnims(param1:int, param2:String) : void
      {
         if(param1 > 0)
         {
            _window.goBtn.visible = false;
            _window.txt.timeTxt.text = param2;
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
      
      public function set titleText(param1:String) : void
      {
         if(_window.txt.hasOwnProperty("titleTxt"))
         {
            _window.txt.titleTxt.text = param1;
         }
      }
      
      public function set defId(param1:int) : void
      {
         this._defId = param1;
      }
      
      public function get defId() : int
      {
         return this._defId;
      }
   }
}

