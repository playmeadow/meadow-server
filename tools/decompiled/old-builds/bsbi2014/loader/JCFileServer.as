package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class JCFileServer extends BaseFileServer
   {
      
      private static var _instance:JCFileServer;
      
      private static const CONTENT_PATH:String = "ABSU/";
      
      public function JCFileServer(lock:Class)
      {
         super(CONTENT_PATH);
         if(lock != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use JCFileServer.instance.");
         }
      }
      
      public static function get instance() : JCFileServer
      {
         if(!_instance)
         {
            _instance = new JCFileServer(SingletonLock);
         }
         return _instance;
      }
      
      public function requestFileWithExtension(id:uint, noCache:Boolean = false, contentType:int = 0, pathExtension:String = "") : void
      {
         super.updatePath(CONTENT_PATH + pathExtension);
         super.requestFile(id,noCache,contentType,false);
      }
      
      override public function clearFromCache(path:String, id:int) : void
      {
         super.clearFromCache(CONTENT_PATH + path,id);
      }
   }
}

class SingletonLock
{
   
   public function SingletonLock()
   {
      super();
   }
}
