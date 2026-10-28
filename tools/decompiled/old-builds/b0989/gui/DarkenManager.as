package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.getTimer;
   
   public class DarkenManager
   {
      
      private static var _darken:Vector.<DisplayObjectContainer>;
      
      private static var _darkBG:Sprite;
      
      private static var _layer:DisplayLayer;
      
      private static var _spiral:LoadingSpiral;
      
      public static var setFocus:Function;
      
      public function DarkenManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer) : void
      {
         _darken = new Vector.<DisplayObjectContainer>();
         _darkBG = new Sprite();
         addListeners();
         makeDarkShape();
         _spiral = new LoadingSpiral(null);
         _spiral.isDarkenManagersSpiral = true;
         _layer = param1;
      }
      
      public static function destroy() : void
      {
         _darkBG.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         var _loc1_:int = 0;
         while(_loc1_ < _darken.length)
         {
            while(_darken[_loc1_].numChildren)
            {
               _darken[_loc1_].removeChildAt(0);
            }
            _loc1_++;
         }
         if(_spiral)
         {
            _spiral.destroy();
            _spiral = null;
         }
         _darken = null;
         _darkBG.x = undefined;
         _darkBG.y = undefined;
         _darkBG = null;
         _layer = null;
         _darkBG = null;
      }
      
      public static function showLoadingSpiral(param1:Boolean, param2:Boolean = false) : void
      {
         if(param1)
         {
            _spiral.setNewParent(_layer,450,275,param2);
            darken(_spiral);
         }
         else
         {
            unDarken(_spiral);
            _spiral.destroy();
         }
      }
      
      public static function updateLoadingSpiralPercentage(param1:String) : void
      {
         _spiral.updatePercentText(param1);
      }
      
      public static function clearDarkenList() : void
      {
         if(_darken)
         {
            _darken.length = 0;
         }
      }
      
      public static function addListeners() : void
      {
         _darkBG.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
      }
      
      public static function makeDarkShape() : void
      {
         with(_darkBG.graphics)
         {
            beginFill(0,0.5);
            drawRect(0,0,MainFrame.VIEW_WIDTH,MainFrame.VIEW_HEIGHT);
            endFill();
         }
         _darkBG.x = -MainFrame.VIEW_WIDTH * 0.5;
         _darkBG.y = -MainFrame.VIEW_HEIGHT * 0.5;
      }
      
      private static function blockMouseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      public static function darken(param1:DisplayObjectContainer) : void
      {
         param1.addChildAt(_darkBG,0);
         var _loc2_:DisplayObjectContainer = param1;
         while(_loc2_ != null && _loc2_.parent != _layer)
         {
            if(_loc2_.parent == null)
            {
               break;
            }
            _loc2_ = _loc2_.parent;
         }
         _darkBG.x = -_loc2_.x;
         _darkBG.y = -_loc2_.y;
         if(setFocus != null)
         {
            setFocus(false);
         }
         if(_darken.indexOf(param1) < 0)
         {
            _darken.push(param1);
         }
      }
      
      public static function unDarken(param1:DisplayObjectContainer) : void
      {
         var _loc3_:int = 0;
         var _loc4_:DisplayObjectContainer = null;
         var _loc5_:DisplayObjectContainer = null;
         var _loc2_:int = getTimer();
         if(Boolean(param1) && _darkBG.parent == param1)
         {
            param1.removeChild(_darkBG);
            _loc3_ = _darken.indexOf(param1);
            if(_loc3_ >= 0)
            {
               _darken.splice(_loc3_,1);
            }
            if(_darken.length > 0)
            {
               _loc5_ = _darken[_darken.length - 1];
               _loc5_.addChildAt(_darkBG,0);
               while(_loc5_ != null && _loc5_.parent != _layer)
               {
                  if(_loc5_.parent == null)
                  {
                     break;
                  }
                  _loc5_ = _loc5_.parent;
               }
               _darkBG.x = -_loc5_.x;
               _darkBG.y = -_loc5_.y;
            }
            gMainFrame.stage.invalidate();
         }
      }
      
      public static function get isDarkened() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc2_:int = 0;
         while(_loc2_ < _darken.length)
         {
            if(_darken[_loc2_].visible)
            {
               _loc1_ = true;
               break;
            }
            _loc2_++;
         }
         return _loc1_;
      }
   }
}

