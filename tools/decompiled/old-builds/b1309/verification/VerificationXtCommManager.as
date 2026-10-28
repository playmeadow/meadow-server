package verification
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   
   public class VerificationXtCommManager
   {
      
      private static var _activationCallback:Function;
      
      public function VerificationXtCommManager()
      {
         super();
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function requestResendActivationEmail(param1:Function) : void
      {
         _activationCallback = param1;
         gMainFrame.server.setXtObject_Str("ves",[],gMainFrame.server.isWorldZone);
      }
      
      public static function requestRenameAndResendActivationEmail(param1:String, param2:Function) : void
      {
         _activationCallback = param2;
         gMainFrame.server.setXtObject_Str("ver",[param1],gMainFrame.server.isWorldZone);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: VerificationXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "ves":
               handleResendActivationEmail(_loc2_);
               break;
            case "ver":
               handleRenameAndResendActivationEmail(_loc2_);
               break;
            default:
               throw new Error("VerificationXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function handleResendActivationEmail(param1:Object) : void
      {
         if(_activationCallback != null)
         {
            _activationCallback(param1[2] == "1");
         }
      }
      
      private static function handleRenameAndResendActivationEmail(param1:Object) : void
      {
         if(_activationCallback != null)
         {
            _activationCallback(param1[2] == "1");
         }
      }
   }
}

