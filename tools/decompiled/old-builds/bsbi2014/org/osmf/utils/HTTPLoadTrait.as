package org.osmf.utils
{
   import flash.net.URLLoader;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   [ExcludeClass]
   public class HTTPLoadTrait extends LoadTrait
   {
      
      private var _urlLoader:URLLoader;
      
      public function HTTPLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
      {
         super(loader,resource);
      }
      
      public function get urlLoader() : URLLoader
      {
         return this._urlLoader;
      }
      
      public function set urlLoader(value:URLLoader) : void
      {
         this._urlLoader = value;
      }
   }
}

