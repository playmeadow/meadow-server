package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class FeedbackFileServer extends BaseFileServer
   {
      
      private static var _instance:FeedbackFileServer;
      
      private static const CONTENT_PATH:String = "feedbackDefs/";
      
      public function FeedbackFileServer(lock:Class)
      {
         super(CONTENT_PATH);
         if(lock != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use FeedbackFileServer.instance.");
         }
      }
      
      public static function get instance() : FeedbackFileServer
      {
         if(!_instance)
         {
            _instance = new FeedbackFileServer(SingletonLock);
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
