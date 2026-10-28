package resourceArray
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   
   public class ResourceArrayXtCommManager
   {
      
      public static const RESOURCE_TYPE_MASTERPIECE:String = "masterpiece";
      
      private static var _resourceArrayGetCallback:Function;
      
      private static var _resourceArrayGetPassback:Object;
      
      private static var _resourceArrayPutCallback:Function;
      
      private static var _resourceArrayPutPassback:Object;
      
      public function ResourceArrayXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function sendResourceArrayGetRequest(param1:String, param2:String, param3:Boolean = false, param4:Function = null, param5:Object = null) : void
      {
         if(param2 != null)
         {
            _resourceArrayGetCallback = param4;
            _resourceArrayGetPassback = param5;
            gMainFrame.server.setXtObject_Str("crg",[param1,param2,gMainFrame.userInfo.myUUID,param3 ? "report" : ""]);
         }
      }
      
      public static function sendResourceArrayPutRequest(param1:String, param2:String, param3:String, param4:int, param5:int, param6:String = "", param7:Function = null, param8:Object = null) : void
      {
         if(param2 != null && param3 != null && param4 > 0)
         {
            _resourceArrayPutCallback = param7;
            _resourceArrayPutPassback = param8;
            gMainFrame.server.setXtObject_Str("crp",[param1,param2,gMainFrame.userInfo.myUUID,param6,[param5,param3,param4]]);
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc2_:int = 0;
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: ResouceArrayXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc5_:Array;
         switch((_loc5_ = param1.obj)[0])
         {
            case "crg":
               _loc3_ = _loc5_[2] == "1";
               _loc4_ = _loc5_[3] == "1";
               _loc2_ = int(_loc5_[4]);
               if(_resourceArrayGetCallback != null)
               {
                  _resourceArrayGetCallback(_loc3_,_loc4_,_loc2_,_resourceArrayGetPassback);
               }
               _resourceArrayGetCallback = null;
               _resourceArrayGetPassback = null;
               break;
            case "crp":
               _loc3_ = _loc5_[2] == "1";
               if(_resourceArrayPutCallback != null)
               {
                  _resourceArrayPutCallback(_loc3_,_resourceArrayPutPassback);
               }
               _resourceArrayPutCallback = null;
               _resourceArrayPutPassback = null;
         }
      }
   }
}

