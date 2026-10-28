package com.sbi.loader
{
   import com.sbi.debug.DebugUtility;
   
   public class ResourceStack
   {
      
      private var _stack:Array;
      
      private var _callback:Function;
      
      private var _path:String;
      
      private var _openFile:Function;
      
      public function ResourceStack(param1:String, param2:Function)
      {
         super();
         _path = param1;
         _openFile = param2;
         _stack = [];
      }
      
      public function pushFile(param1:String, param2:Boolean = false) : void
      {
         _stack.push({
            "type":"file",
            "data":param1,
            "isBlocking":param2,
            "inProgress":false
         });
      }
      
      public function pushClass(param1:IResourceStackable, param2:Boolean = false) : void
      {
         _stack.push({
            "type":"class",
            "data":param1,
            "isBlocking":param2,
            "inProgress":false
         });
      }
      
      public function start(param1:Function) : void
      {
         _callback = param1;
         fifo();
      }
      
      private function fifo() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Object = null;
         var _loc2_:int = int(_stack.length);
         DebugUtility.debugTrace("ResourceStack fifo len:" + _loc2_);
         if(!_loc2_)
         {
            DebugUtility.debugTrace("ResourceStack _callback:" + _callback);
            if(_callback != null)
            {
               _callback();
               _callback = null;
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc1_ = _stack[_loc3_];
               DebugUtility.debugTrace("ResourceStack fifo next - o:" + _loc1_ + " o.inProgress:" + _loc1_.inProgress + " o.type:" + _loc1_.type + " o.data:" + _loc1_.data + " o.isBlocking:" + _loc1_.isBlocking);
               if(!_loc1_.inProgress)
               {
                  _loc1_.inProgress = true;
                  switch(_loc1_.type)
                  {
                     case "file":
                        loadFile(_loc1_.data);
                        break;
                     case "class":
                        _loc1_.data.init(onInitClassComplete);
                  }
                  _loc3_ = -1;
                  _loc2_ = int(_stack.length);
               }
               else if(_loc1_.isBlocking)
               {
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private function loadFile(param1:String) : void
      {
         var _loc2_:String = _path + param1;
         _openFile(_loc2_,onLoadComplete,onLoadProgress);
      }
      
      private function onLoadComplete(param1:LoaderEvent) : void
      {
         if(param1.status)
         {
            DebugUtility.debugTrace("ResourceStack onLoadComplete e:" + param1 + " name:" + param1.entry.name);
            removeResource("file",param1.entry.name);
            fifo();
            return;
         }
         throw new Error("could not load required resource!!! msg:" + param1.message);
      }
      
      private function onLoadProgress(param1:LoaderEvent) : void
      {
      }
      
      private function onInitClassComplete(param1:IResourceStackable) : void
      {
         removeResource("class",param1);
         fifo();
      }
      
      private function removeResource(param1:String, param2:*) : void
      {
         var _loc5_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:int = int(_stack.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = _stack[_loc5_];
            if(_loc3_.type == param1 && _loc3_.data == param2)
            {
               _stack.splice(_loc5_,1);
               break;
            }
            _loc5_++;
         }
      }
   }
}

