package org.osmf.elements
{
   import org.osmf.media.MediaResourceBase;
   import org.osmf.net.NetLoader;
   import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
   import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
   import org.osmf.traits.LoaderBase;
   
   public class VideoElement extends LightweightVideoElement
   {
      
      private var _alternateLoaders:Vector.<LoaderBase>;
      
      public function VideoElement(resource:MediaResourceBase = null, loader:NetLoader = null)
      {
         super(null,null);
         super.loader = loader;
         this.resource = resource;
      }
      
      override public function set resource(value:MediaResourceBase) : void
      {
         loader = getLoaderForResource(value,this.alternateLoaders);
         super.resource = value;
      }
      
      private function get alternateLoaders() : Vector.<LoaderBase>
      {
         if(this._alternateLoaders == null)
         {
            this._alternateLoaders = new Vector.<LoaderBase>();
            this._alternateLoaders.push(new HTTPStreamingNetLoader());
            this._alternateLoaders.push(new RTMPDynamicStreamingNetLoader());
            this._alternateLoaders.push(new NetLoader());
         }
         return this._alternateLoaders;
      }
   }
}

