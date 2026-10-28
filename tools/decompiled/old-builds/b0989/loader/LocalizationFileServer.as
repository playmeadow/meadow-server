package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class LocalizationFileServer extends BaseFileServer
   {
      
      private static var _instance:LocalizationFileServer;
      
      public static const CONTENT_PATH:String = "local/";
      
      public function LocalizationFileServer(param1:Class)
      {
         super(CONTENT_PATH);
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use LocalizationFileServer.instance.");
         }
      }
      
      public static function get instance() : LocalizationFileServer
      {
         if(!_instance)
         {
            _instance = new LocalizationFileServer(SingletonLock);
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
