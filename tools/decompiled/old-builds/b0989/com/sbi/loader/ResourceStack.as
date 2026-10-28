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
         this._path = param1;
         this._openFile = param2;
         this._stack = new Array();
      }
      
      public function pushFile(param1:String, param2:Boolean = false) : void
      {
         this._stack.push({
            "type":"file",
            "data":param1,
            "isBlocking":param2,
            "inProgress":false
         });
      }
      
      public function pushClass(param1:IResourceStackable, param2:Boolean = false) : void
      {
         this._stack.push({
            "type":"class",
            "data":param1,
            "isBlocking":param2,
            "inProgress":false
         });
      }
      
      public function start(param1:Function) : void
      {
         this._callback = param1;
         this.fifo();
      }
      
      private function fifo() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc1_:int = int(this._stack.length);
         DebugUtility.debugTrace("ResourceStack fifo len:" + _loc1_);
         if(!_loc1_)
         {
            if(this._callback != null)
            {
               this._callback();
               this._callback = null;
            }
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               _loc3_ = this._stack[_loc2_];
               if(!_loc3_.inProgress)
               {
                  _loc3_.inProgress = true;
                  switch(_loc3_.type)
                  {
                     case "file":
                        this.loadFile(_loc3_.data);
                        break;
                     case "class":
                        _loc3_.data.init(this.onInitClassComplete);
                  }
                  _loc2_ = -1;
                  _loc1_ = int(this._stack.length);
               }
               else if(_loc3_.isBlocking)
               {
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      private function loadFile(param1:String) : void
      {
         var _loc2_:String = this._path + param1;
         this._openFile(_loc2_,this.onLoadComplete,this.onLoadProgress);
      }
      
      private function onLoadComplete(param1:LoaderEvent) : void
      {
         if(param1.status)
         {
            this.removeResource("file",param1.entry.name);
            this.fifo();
            return;
         }
         throw new Error("could not load required resource!!! msg:" + param1.message);
      }
      
      private function onLoadProgress(param1:LoaderEvent) : void
      {
      }
      
      private function onInitClassComplete(param1:IResourceStackable) : void
      {
         this.removeResource("class",param1);
         this.fifo();
      }
      
      private function removeResource(param1:String, param2:*) : void
      {
         var _loc5_:Object = null;
         var _loc3_:int = int(this._stack.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = this._stack[_loc4_];
            if(_loc5_.type == param1 && _loc5_.data == param2)
            {
               this._stack.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
      }
   }
}

