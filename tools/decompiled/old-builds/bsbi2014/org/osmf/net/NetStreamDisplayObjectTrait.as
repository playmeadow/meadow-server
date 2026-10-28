package org.osmf.net
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.media.Video;
   import flash.net.NetStream;
   import org.osmf.traits.DisplayObjectTrait;
   
   [ExcludeClass]
   public class NetStreamDisplayObjectTrait extends DisplayObjectTrait
   {
      
      private var netStream:NetStream;
      
      public function NetStreamDisplayObjectTrait(netStream:NetStream, view:DisplayObject, mediaWidth:Number = 0, mediaHeight:Number = 0)
      {
         super(view,mediaWidth,mediaHeight);
         this.netStream = netStream;
         NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA,this.onMetaData);
         if(view is Video)
         {
            view.addEventListener(Event.ADDED_TO_STAGE,this.onStage);
         }
      }
      
      private function onStage(event:Event) : void
      {
         displayObject.removeEventListener(Event.ADDED_TO_STAGE,this.onStage);
         displayObject.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      private function onFrame(event:Event) : void
      {
         if(Video(displayObject).videoWidth != 0 && Video(displayObject).videoHeight != 0)
         {
            if(Video(displayObject).videoWidth != mediaWidth && Video(displayObject).videoHeight != mediaHeight)
            {
               this.newMediaSize(Video(displayObject).videoWidth,Video(displayObject).videoHeight);
            }
            displayObject.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         }
      }
      
      private function onMetaData(info:Object) : void
      {
         if(!isNaN(info.width) && !isNaN(info.height) && (info.width != mediaWidth || info.height != mediaHeight))
         {
            this.newMediaSize(info.width,info.height);
         }
      }
      
      private function newMediaSize(width:Number, height:Number) : void
      {
         if(displayObject.width == 0 && displayObject.height == 0)
         {
            displayObject.width = width;
            displayObject.height = height;
         }
         setMediaSize(width,height);
      }
   }
}

