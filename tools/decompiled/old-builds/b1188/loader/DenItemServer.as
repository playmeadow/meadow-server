package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class DenItemServer extends BaseFileServer
   {
      
      private static var _instance:DenItemServer;
      
      private static const CONTENT_PATH:String = "items/";
      
      public function DenItemServer(param1:Class)
      {
         super(CONTENT_PATH);
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use DenItemServer.instance.");
         }
      }
      
      public static function get instance() : DenItemServer
      {
         if(!_instance)
         {
            _instance = new DenItemServer(SingletonLock);
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
