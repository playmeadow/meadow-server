package it.gotoandplay.smartfoxserver.http
{
   import flash.net.URLLoader;
   
   public class LoaderFactory
   {
      
      private static const DEFAULT_POOL_SIZE:int = 2;
      
      private var currentLoaderIndex:int;
      
      private var responseHandler:Function;
      
      private var errorHandler:Function;
      
      public function LoaderFactory(param1:Function, param2:Function, param3:int = 2)
      {
         super();
         this.responseHandler = param1;
         this.errorHandler = param2;
      }
      
      public function getLoader() : URLLoader
      {
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.dataFormat = "text";
         _loc1_.addEventListener("complete",this.responseHandler);
         _loc1_.addEventListener("ioError",this.errorHandler);
         _loc1_.addEventListener("networkError",this.errorHandler);
         return _loc1_;
      }
   }
}

