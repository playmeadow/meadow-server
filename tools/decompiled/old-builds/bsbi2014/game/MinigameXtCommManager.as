package game
{
   import com.sbi.client.SFEvent;
   
   public class MinigameXtCommManager
   {
      
      private static var _miCallback:Function;
      
      public static const PVP_REQUEST_OR_ACCEPT:int = 0;
      
      public static const PVP_DENY_DENIED_OR_CANCEL:int = 1;
      
      public function MinigameXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         XtReplyDemuxer.addModule(handleXtReply,"m");
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function sendMinigameInfoRequest(gameDefIds:Array, subRoom:Boolean = false, callback:Function = null) : void
      {
         _miCallback = callback;
         gMainFrame.server.setXtObject_Str("mi",gameDefIds,true,subRoom);
      }
      
      public static function sendMinigameJoinRequest(gameId:int, subRoom:Boolean = false, playMultiPlayer:Boolean = false, proModeId:int = 0) : void
      {
         var mjra:Array = [gameId,playMultiPlayer ? "1" : "0",proModeId];
         gMainFrame.server.setXtObject_Str("mj",mjra,true,subRoom);
      }
      
      public static function sendMinigameStartRequest(gameId:int, subRoom:Boolean = false) : void
      {
         var mjra:Array = [gameId];
         gMainFrame.server.setXtObject_Str("ms",mjra,true,subRoom);
      }
      
      public static function sendMinigameLeaveRequest() : void
      {
         gMainFrame.server.setXtObject_Str("ml",null,true,true);
      }
      
      public static function sendMinigameMessageRequest(messages:Array, inRoom:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("mm",messages,true,inRoom);
      }
      
      public static function sendMinigamePvpMsg(gameDefId:int, flag:int, userName:String = "") : void
      {
         if(userName != "")
         {
            gMainFrame.server.setXtObject_Str("mp",[gameDefId,flag,userName]);
         }
         else
         {
            gMainFrame.server.setXtObject_Str("mp",[gameDefId,flag]);
         }
      }
      
      public static function sendMinigameCustomPvpJoinMsg(gameDefId:int, isCancel:int, userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("mcp",[gameDefId,isCancel,userName]);
      }
      
      public static function sendMinigameLeaderboardRequest(gameId:int) : void
      {
         var mlbra:Array = [gameId];
         gMainFrame.server.setXtObject_Str("mlb",mlbra);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:* = evt.obj;
         switch(data[0])
         {
            case "mi":
               handleMinigameInfo(data);
               break;
            case "ms":
               MinigameManager.startGame(data);
               break;
            case "mj":
               MinigameManager.joinGameResponse(data);
               break;
            case "ml":
            case "mm":
               MinigameManager.messageGame(data);
               break;
            case "me":
               MinigameManager.minigameEndResponse(data);
               break;
            case "mr":
               MinigameManager.minigameRoomRemovedResponse(data);
               break;
            case "mp":
               MinigameManager.pvpResponse(data);
               break;
            case "mg":
               MinigameManager.minigameGems(data);
               break;
            case "ma":
               MinigameManager.minigamePetMastery(data);
               break;
            case "mlb":
               MinigameManager.leaderBoardResponse(data);
               break;
            default:
               throw new Error("MinigameManager illegal data:" + data[0]);
         }
      }
      
      private static function handleMinigameInfo(data:Object) : void
      {
         var cmi:MinigameInfo = null;
         var di:int = 2;
         var minigameInfosLength:int = parseInt(data[di++]);
         for(var hmi:int = 0; hmi < minigameInfosLength; hmi++)
         {
            cmi = new MinigameInfo();
            cmi.init(parseInt(data[di++]),parseInt(data[di++]),data[di++],data[di++],parseInt(data[di++]),parseInt(data[di++]),parseInt(data[di++]),parseInt(data[di++]),parseInt(data[di++]),parseInt(data[di++]),parseInt(data[di++]),parseInt(data[di++]),parseInt(data[di++]),parseFloat(data[di++]),null,parseInt(data[di++]),parseInt(data[di++]),parseInt(data[di++]));
            MinigameManager.minigameInfoCache.setMinigameInfo(cmi.gameDefId,cmi);
         }
         if(_miCallback != null)
         {
            _miCallback();
            _miCallback = null;
         }
      }
   }
}

