package
{
   import com.sbi.client.SFEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class XtReplyDemuxer
   {
      
      private static var _delayList:Array;
      
      private static var _delayTimer:Timer;
      
      private static var _xtReplyCallbacks:Array;
      
      private static var _xtReplyCommands:Array;
      
      private static var MSG_DELAY_MS:int = 0;
      
      public function XtReplyDemuxer()
      {
         super();
      }
      
      public static function init() : void
      {
         if(MSG_DELAY_MS > 0)
         {
            _delayList = [];
            _delayTimer = new Timer(10);
            _delayTimer.addEventListener(TimerEvent.TIMER,delayTimerHandler,false,0,true);
            _delayTimer.start();
         }
         _xtReplyCallbacks = [];
         _xtReplyCommands = [];
         gMainFrame.server.addEventListener(SFEvent.ON_XT_REPLY,xtReplyHandler,false,0,true);
      }
      
      public static function destroy() : void
      {
         _delayList = null;
         if(Boolean(_delayTimer))
         {
            if(_delayTimer.running)
            {
               _delayTimer.stop();
            }
            _delayTimer = null;
         }
         _xtReplyCallbacks = null;
         _xtReplyCommands = null;
         gMainFrame.server.removeEventListener(SFEvent.ON_XT_REPLY,xtReplyHandler);
      }
      
      public static function addModule(callback:Function, command:String) : void
      {
         _xtReplyCallbacks.push(callback);
         _xtReplyCommands.push(command);
      }
      
      public static function removeModule(callback:Function) : void
      {
         var modIdx:int = _xtReplyCallbacks.indexOf(callback);
         if(modIdx >= 0)
         {
            _xtReplyCallbacks.splice(modIdx,1);
            _xtReplyCommands.splice(modIdx,1);
            return;
         }
         throw new Error("module not found! callback:" + callback);
      }
      
      public static function xtReplyHandler(evt:SFEvent) : void
      {
         if(_xtReplyCallbacks[_xtReplyCommands.indexOf(evt.obj[0].charAt(0))] == undefined)
         {
            throw new Error("ERROR: undefined module command:" + evt.obj[0]);
         }
         var xtReplyFunction:Function = _xtReplyCallbacks[_xtReplyCommands.indexOf(evt.obj[0].charAt(0))];
         if(MSG_DELAY_MS == 0)
         {
            xtReplyFunction(evt);
         }
         else
         {
            _delayList.push({
               "f":xtReplyFunction,
               "e":evt,
               "ts":getTimer() + MSG_DELAY_MS
            });
         }
      }
      
      private static function delayTimerHandler(te:TimerEvent) : void
      {
         var o:Object = null;
         var currTime:uint = uint(getTimer());
         for(var i:int = 0; i < _delayList.length; i++)
         {
            o = _delayList[i];
            if(o.ts >= currTime)
            {
               break;
            }
            o.f(o.e);
            _delayList.splice(0,1);
            i--;
         }
      }
   }
}

