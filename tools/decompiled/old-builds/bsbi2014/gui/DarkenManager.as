package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getTimer;
   
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
      
      public static function init(layer:DisplayLayer) : void
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
         _layer = layer;
      }
      
      public static function destroy() : void
      {
         _darkBG.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         _stageDarkBG.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         _stageBlockBG.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         for(var i:int = 0; i < _darken.length; i++)
         {
            while(Boolean(_darken[i].numChildren))
            {
               _darken[i].removeChildAt(0);
            }
         }
         if(Boolean(_spiral))
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
      
      public static function showLoadingSpiral(show:Boolean, displayPercentText:Boolean = false) : void
      {
         if(Boolean(_spiral))
         {
            if(show)
            {
               _spiral.setNewParent(_layer,450,275,displayPercentText);
               darken(_spiral);
            }
            else
            {
               unDarken(_spiral);
               _spiral.destroy();
            }
         }
      }
      
      public static function updateLoadingSpiralPercentage(percent:String) : void
      {
         _spiral.updatePercentText(percent);
      }
      
      public static function clearDarkenList() : void
      {
         if(Boolean(_darken))
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
      
      private static function makeStageDarkBG(evt:Event = null) : void
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
      
      private static function onStageResize(evt:Event) : void
      {
         makeStageDarkBG(evt);
      }
      
      private static function blockMouseHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      public static function addInvisibleBlockBG() : void
      {
         if(Boolean(_stageBlockBG))
         {
            if(Boolean(_stageBlockBG.parent))
            {
               _stageBlockBG.parent.removeChild(_stageBlockBG);
            }
            gMainFrame.stage.addChild(_stageBlockBG);
         }
      }
      
      public static function removeInvisibleBlockBG() : void
      {
         if(Boolean(_stageBlockBG))
         {
            if(Boolean(_stageBlockBG.parent))
            {
               _stageBlockBG.parent.removeChild(_stageBlockBG);
            }
         }
      }
      
      public static function darken(popUp:DisplayObjectContainer) : void
      {
         popUp.addChildAt(_darkBG,0);
         var parentPopup:DisplayObjectContainer = popUp;
         while(parentPopup != null && parentPopup.parent != _layer)
         {
            if(parentPopup.parent == null)
            {
               break;
            }
            parentPopup = parentPopup.parent;
         }
         _darkBG.x = -parentPopup.x;
         _darkBG.y = -parentPopup.y;
         if(setFocus != null)
         {
            setFocus(false);
         }
         if(_darken.indexOf(popUp) < 0)
         {
            _darken.push(popUp);
         }
      }
      
      public static function unDarken(popup:DisplayObjectContainer) : void
      {
         var index:int = 0;
         var nextPopup:DisplayObjectContainer = null;
         var parentPopup:DisplayObjectContainer = null;
         var time:int = getTimer();
         if(Boolean(popup) && _darkBG.parent == popup)
         {
            popup.removeChild(_darkBG);
            index = _darken.indexOf(popup);
            if(index >= 0)
            {
               _darken.splice(index,1);
            }
            if(_darken.length > 0)
            {
               nextPopup = _darken[_darken.length - 1];
               parentPopup = nextPopup;
               nextPopup.addChildAt(_darkBG,0);
               while(parentPopup != null && parentPopup.parent != _layer)
               {
                  if(parentPopup.parent == null)
                  {
                     break;
                  }
                  parentPopup = parentPopup.parent;
               }
               _darkBG.x = -parentPopup.x;
               _darkBG.y = -parentPopup.y;
            }
            gMainFrame.stage.invalidate();
         }
      }
      
      public static function get isDarkened() : Boolean
      {
         var isDarkened:Boolean = false;
         for(var i:int = 0; i < _darken.length; i++)
         {
            if(_darken[i].visible)
            {
               isDarkened = true;
               break;
            }
         }
         return isDarkened;
      }
   }
}

