package org.osmf.layout
{
   import flash.geom.Point;
   
   internal class ScaleModeUtils
   {
      
      public function ScaleModeUtils()
      {
         super();
      }
      
      public static function getScaledSize(scaleMode:String, availableWidth:Number, availableHeight:Number, intrinsicWidth:Number, intrinsicHeight:Number) : Point
      {
         var result:Point = null;
         var availableRatio:Number = NaN;
         var componentRatio:Number = NaN;
         switch(scaleMode)
         {
            case ScaleMode.ZOOM:
            case ScaleMode.LETTERBOX:
               availableRatio = availableWidth / availableHeight;
               componentRatio = (intrinsicWidth || availableWidth) / (intrinsicHeight || availableHeight);
               if(scaleMode == ScaleMode.ZOOM && componentRatio < availableRatio || scaleMode == ScaleMode.LETTERBOX && componentRatio > availableRatio)
               {
                  result = new Point(availableWidth,availableWidth / componentRatio);
               }
               else
               {
                  result = new Point(availableHeight * componentRatio,availableHeight);
               }
               break;
            case ScaleMode.STRETCH:
               result = new Point(availableWidth,availableHeight);
               break;
            case ScaleMode.NONE:
               result = new Point(intrinsicWidth || availableWidth,intrinsicHeight || availableHeight);
         }
         return result;
      }
   }
}

