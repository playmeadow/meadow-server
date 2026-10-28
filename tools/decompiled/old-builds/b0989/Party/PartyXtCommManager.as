package Party
{
   import com.sbi.client.SFEvent;
   import gui.PartyManager;
   
   public class PartyXtCommManager
   {
      
      public function PartyXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
      }
      
      public static function destroy() : void
      {
      }
      
      public static function sendJoinPartyRequest(param1:int) : void
      {
         gMainFrame.server.setXtObject_Str("sj",[param1]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "sl":
               PartyManager.partyListResponse(_loc2_);
               break;
            case "sj":
               PartyManager.roomSoireeResponse(_loc2_);
         }
      }
   }
}

