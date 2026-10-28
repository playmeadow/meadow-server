package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DarkenManager
   {
      
      private static var _darken:Vector.<DisplayObjectContainer>;
      
      private static var _stageDarkBG:Sprite;
      
      private static var _darkBG:Sprite;
      
      private static var _stageBlockBG:Sprite;
      
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
         _stageBlockBG = new Sprite();
         _stageDarkBG = new Sprite();
         addListeners();
         makeDarkShape();
         makeStageDarkBG();
         makeLightStageBlock();
         gMainFrame.stage.addEventListener(Event.RESIZE,onStageResize,false,0,true);
         _spiral = new LoadingSpiral(null);
         _spiral.isDarkenManagersSpiral = true;
         _layer = param1;
      }
      
      public static function destroy() : void
      {
         _darkBG.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         _stageDarkBG.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         _stageBlockBG.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
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
         removeInvisibleBlockBG();
         _stageBlockBG.x = undefined;
         _stageBlockBG.y = undefined;
         _stageBlockBG = null;
         _layer = null;
         _stageDarkBG = null;
      }
      
      public static function showLoadingSpiral(param1:Boolean, param2:Boolean = false) : void
      {
         if(_spiral)
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
         removeInvisibleBlockBG();
      }
      
      public static function addListeners() : void
      {
         _darkBG.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
         _stageDarkBG.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
         _stageBlockBG.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
      }
      
      public static function makeDarkShape() : void
      {
         _darkBG.graphics.beginFill(0,0.5);
         _darkBG.graphics.drawRect(0,0,MainFrame.VIEW_WIDTH,MainFrame.VIEW_HEIGHT);
         _darkBG.graphics.endFill();
         _darkBG.x = -MainFrame.VIEW_WIDTH * 0.5;
         _darkBG.y = -MainFrame.VIEW_HEIGHT * 0.5;
      }
      
      private static function makeLightStageBlock() : void
      {
         _stageBlockBG.graphics.beginFill(0,0);
         _stageBlockBG.graphics.drawRect(0,0,gMainFrame.stage.stageWidth,gMainFrame.stage.stageHeight);
         _stageBlockBG.graphics.endFill();
         _stageBlockBG.x = -gMainFrame.stage.stageWidth * 0.5 + MainFrame.VIEW_WIDTH * 0.5;
         _stageBlockBG.y = -gMainFrame.stage.stageHeight * 0.5 + MainFrame.VIEW_HEIGHT * 0.5;
      }
      
      private static function makeStageDarkBG(param1:Event = null) : void
      {
         _stageDarkBG.graphics.clear();
         _stageDarkBG.graphics.beginFill(0,0.5);
         _stageDarkBG.graphics.drawRect(0,0,gMainFrame.stage.stageWidth,gMainFrame.stage.stageHeight);
         _stageDarkBG.graphics.endFill();
         _stageDarkBG.x = -gMainFrame.stage.stageWidth * 0.5 + MainFrame.VIEW_WIDTH * 0.5;
         _stageDarkBG.y = -gMainFrame.stage.stageHeight * 0.5 + MainFrame.VIEW_HEIGHT * 0.5;
         if(_stageDarkBG.parent == null)
         {
            gMainFrame.stage.addChildAt(_stageDarkBG,0);
         }
      }
      
      private static function onStageResize(param1:Event) : void
      {
         makeStageDarkBG(param1);
      }
      
      private static function blockMouseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      public static function addInvisibleBlockBG() : void
      {
         if(_stageBlockBG)
         {
            if(_stageBlockBG.parent)
            {
               _stageBlockBG.parent.removeChild(_stageBlockBG);
            }
            gMainFrame.stage.addChild(_stageBlockBG);
         }
      }
      
      public static function removeInvisibleBlockBG() : void
      {
         if(_stageBlockBG)
         {
            if(_stageBlockBG.parent)
            {
               _stageBlockBG.parent.removeChild(_stageBlockBG);
            }
         }
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
         var _loc2_:int = 0;
         var _loc3_:DisplayObjectContainer = null;
         var _loc4_:DisplayObjectContainer = null;
         if(param1)
         {
            _loc2_ = _darken.indexOf(param1);
            if(_loc2_ >= 0)
            {
               if(param1.parent == _darkBG)
               {
                  param1.removeChild(_darkBG);
               }
               _darken.splice(_loc2_,1);
               if(_darken.length > 0)
               {
                  _loc3_ = _darken[_darken.length - 1];
                  _loc4_ = _loc3_;
                  _loc3_.addChildAt(_darkBG,0);
                  while(_loc4_ != null && _loc4_.parent != _layer)
                  {
                     if(_loc4_.parent == null)
                     {
                        break;
                     }
                     _loc4_ = _loc4_.parent;
                  }
                  _darkBG.x = -_loc4_.x;
                  _darkBG.y = -_loc4_.y;
               }
               gMainFrame.stage.invalidate();
            }
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

