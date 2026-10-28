package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class DefPacksFileServer extends BaseFileServer
   {
      
      private static var _instance:DefPacksFileServer;
      
      private static const CONTENT_PATH:String = "defPacks/";
      
      public function DefPacksFileServer(lock:Class)
      {
         super(CONTENT_PATH);
         if(lock != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use DefPacksFileServer.instance.");
         }
      }
      
      public static function get instance() : DefPacksFileServer
      {
         if(!_instance)
         {
            _instance = new DefPacksFileServer(SingletonLock);
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
