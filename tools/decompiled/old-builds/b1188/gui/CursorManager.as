package gui
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.ui.MouseCursorData;
   
   public class CursorManager extends Sprite
   {
      
      private static var _customCursor:Sprite;
      
      private static var _mcd:MouseCursorData;
      
      private static var _previousCursor:String;
      
      public static const CUSTOM_CURSOR:String = "custom_cursor";
      
      public static const DEFAULT_I_CURSOR:String = "ibeam";
      
      public static const DEFAULT_CURSOR:String = "Default_Cursor";
      
      public function CursorManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _customCursor = GETDEFINITIONBYNAME("Cursor");
         _mcd = new MouseCursorData();
      }
      
      public static function changeDefaultMouse() : void
      {
         var _loc1_:Vector.<BitmapData> = new Vector.<BitmapData>();
         _loc1_[0] = convertToBitmapData(_customCursor);
         _mcd.data = _loc1_;
         _mcd.hotSpot = new Point(5,0.5);
         Mouse.registerCursor("custom_cursor",_mcd);
         Mouse.cursor = "custom_cursor";
      }
      
      public static function switchToCursor(param1:String) : void
      {
         var _loc2_:Vector.<BitmapData> = new Vector.<BitmapData>();
         switch(param1)
         {
            case CUSTOM_CURSOR:
               _loc2_[0] = convertToBitmapData(_customCursor);
               _mcd.hotSpot = new Point(5,0.5);
               _mcd.data = _loc2_;
               Mouse.registerCursor("custom_cursor",_mcd);
               Mouse.cursor = "custom_cursor";
               break;
            case DEFAULT_I_CURSOR:
               Mouse.cursor = MouseCursor.IBEAM;
               break;
            case DEFAULT_CURSOR:
               Mouse.unregisterCursor("custom_cursor");
               _previousCursor = "";
         }
      }
      
      public static function showICursor(param1:Boolean) : void
      {
         if(Mouse.cursor != "auto")
         {
            if(param1)
            {
               _previousCursor = Mouse.cursor;
               switchToCursor(DEFAULT_I_CURSOR);
            }
            else
            {
               switchToCursor(_previousCursor);
            }
         }
      }
      
      private static function convertToBitmapData(param1:DisplayObject) : BitmapData
      {
         var _loc2_:Rectangle = new Rectangle(0,0,19,24);
         var _loc3_:BitmapData = new BitmapData(19,24,true,0);
         _loc3_.draw(param1);
         return _loc3_;
      }
   }
}

