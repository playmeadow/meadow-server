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
         if(_delayTimer)
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
      
      public static function addModule(param1:Function, param2:String) : void
      {
         _xtReplyCallbacks.push(param1);
         _xtReplyCommands.push(param2);
      }
      
      public static function removeModule(param1:Function) : void
      {
         var _loc2_:int = _xtReplyCallbacks.indexOf(param1);
         if(_loc2_ >= 0)
         {
            _xtReplyCallbacks.splice(_loc2_,1);
            _xtReplyCommands.splice(_loc2_,1);
            return;
         }
         throw new Error("module not found! callback:" + param1);
      }
      
      public static function xtReplyHandler(param1:SFEvent) : void
      {
         if(_xtReplyCallbacks[_xtReplyCommands.indexOf(param1.obj[0].charAt(0))] == undefined)
         {
            throw new Error("ERROR: undefined module command:" + param1.obj[0]);
         }
         var _loc2_:Function = _xtReplyCallbacks[_xtReplyCommands.indexOf(param1.obj[0].charAt(0))];
         if(MSG_DELAY_MS == 0)
         {
            _loc2_(param1);
         }
         else
         {
            _delayList.push({
               "f":_loc2_,
               "e":param1,
               "ts":getTimer() + MSG_DELAY_MS
            });
         }
      }
      
      private static function delayTimerHandler(param1:TimerEvent) : void
      {
         var _loc3_:Object = null;
         var _loc2_:uint = uint(getTimer());
         var _loc4_:* = 0;
         while(_loc4_ < _delayList.length)
         {
            _loc3_ = _delayList[_loc4_];
            if(_loc3_.ts >= _loc2_)
            {
               break;
            }
            _loc3_.f(_loc3_.e);
            _delayList.splice(0,1);
            _loc4_--;
            _loc4_++;
         }
      }
   }
}

