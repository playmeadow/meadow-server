package gui
{
   import flash.display.MovieClip;
   
   public class GuiStatusIcon
   {
      
      public function GuiStatusIcon()
      {
         super();
      }
      
      public static function initClip(statusIcon:MovieClip, trackingObject:Object = null) : void
      {
         statusIcon.visible = false;
         statusIcon["_x"].visible = false;
         statusIcon["_wait"].visible = true;
         statusIcon["_check"].visible = false;
         if(Boolean(trackingObject))
         {
            trackingObject.xTracking = false;
            trackingObject.waitTracking = true;
            trackingObject.checkTracking = false;
         }
      }
      
      public static function initClipOff(statusIcon:MovieClip, trackingObject:Object = null) : void
      {
         statusIcon.visible = false;
         statusIcon["_x"].visible = false;
         statusIcon["_wait"].visible = false;
         statusIcon["_check"].visible = false;
         if(Boolean(trackingObject))
         {
            trackingObject.xTracking = false;
            trackingObject.waitTracking = false;
            trackingObject.checkTracking = false;
         }
      }
      
      public static function setVisBasedOnTrackers(statusIcon:MovieClip, trackingObject:Object = null) : void
      {
         statusIcon["_x"].visible = trackingObject.xTracking;
         statusIcon["_wait"].visible = trackingObject.waitTracking;
         statusIcon["_check"].visible = trackingObject.checkTracking;
      }
      
      public static function showX(statusIcon:MovieClip, trackingObject:Object = null) : void
      {
         statusIcon["_x"].visible = true;
         statusIcon["_wait"].visible = false;
         statusIcon["_check"].visible = false;
         if(Boolean(trackingObject))
         {
            trackingObject.xTracking = true;
            trackingObject.waitTracking = false;
            trackingObject.checkTracking = false;
         }
      }
      
      public static function showWait(statusIcon:MovieClip, trackingObject:Object = null) : void
      {
         statusIcon["_x"].visible = false;
         statusIcon["_wait"].visible = true;
         statusIcon["_check"].visible = false;
         if(Boolean(trackingObject))
         {
            trackingObject.xTracking = false;
            trackingObject.waitTracking = true;
            trackingObject.checkTracking = false;
         }
      }
      
      public static function showCheck(statusIcon:MovieClip, trackingObject:Object = null) : void
      {
         statusIcon["_x"].visible = false;
         statusIcon["_wait"].visible = false;
         statusIcon["_check"].visible = true;
         if(Boolean(trackingObject))
         {
            trackingObject.xTracking = false;
            trackingObject.waitTracking = false;
            trackingObject.checkTracking = true;
         }
      }
   }
}

