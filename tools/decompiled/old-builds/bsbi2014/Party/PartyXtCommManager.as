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
      
      public static function sendJoinPartyRequest(partyDefId:int) : void
      {
         gMainFrame.server.setXtObject_Str("sj",[partyDefId]);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         switch(data[0])
         {
            case "sl":
               PartyManager.partyListResponse(data);
               break;
            case "sj":
               PartyManager.roomSoireeResponse(data);
         }
      }
   }
}

