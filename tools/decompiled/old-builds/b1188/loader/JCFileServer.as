package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class JCFileServer extends BaseFileServer
   {
      
      private static var _instance:JCFileServer;
      
      private static const CONTENT_PATH:String = "ABSU/";
      
      public function JCFileServer(param1:Class)
      {
         super(CONTENT_PATH);
         if(param1 != SingletonLock)
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
      
      public function requestFileWithExtension(param1:uint, param2:Boolean = false, param3:int = 0, param4:String = "") : void
      {
         super.updatePath(CONTENT_PATH + param4);
         super.requestFile(param1,param2,param3,false);
      }
      
      override public function clearFromCache(param1:String, param2:int) : void
      {
         super.clearFromCache(CONTENT_PATH + param1,param2);
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
