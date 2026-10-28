package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class MediaFileServer extends BaseFileServer
   {
      
      private static var _instance:MediaFileServer;
      
      private static const CONTENT_PATH:String = "media/";
      
      public function MediaFileServer(lock:Class)
      {
         super(CONTENT_PATH);
         if(lock != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use MediaFileServer.instance.");
         }
      }
      
      public static function get instance() : MediaFileServer
      {
         if(!_instance)
         {
            _instance = new MediaFileServer(SingletonLock);
         }
         return _instance;
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
