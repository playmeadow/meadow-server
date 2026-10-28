package com.sbi.loader
{
   import com.sbi.debug.DebugUtility;
   
   public class ResourceStack
   {
      
      private var _stack:Array;
      
      private var _callback:Function;
      
      private var _path:String;
      
      private var _openFile:Function;
      
      public function ResourceStack(initPath:String, initOpenFile:Function)
      {
         super();
         this._path = initPath;
         this._openFile = initOpenFile;
         this._stack = new Array();
      }
      
      public function pushFile(file:String, isBlocking:Boolean = false) : void
      {
         this._stack.push({
            "type":"file",
            "data":file,
            "isBlocking":isBlocking,
            "inProgress":false
         });
      }
      
      public function pushClass(classRef:IResourceStackable, isBlocking:Boolean = false) : void
      {
         this._stack.push({
            "type":"class",
            "data":classRef,
            "isBlocking":isBlocking,
            "inProgress":false
         });
      }
      
      public function start(callback:Function) : void
      {
         this._callback = callback;
         this.fifo();
      }
      
      private function fifo() : void
      {
         var i:int = 0;
         var o:Object = null;
         var len:int = int(this._stack.length);
         DebugUtility.debugTrace("ResourceStack fifo len:" + len);
         if(!len)
         {
            DebugUtility.debugTrace("ResourceStack _callback:" + this._callback);
            if(this._callback != null)
            {
               this._callback();
               this._callback = null;
            }
         }
         else
         {
            for(i = 0; i < len; i++)
            {
               o = this._stack[i];
               DebugUtility.debugTrace("ResourceStack fifo next - o:" + o + " o.inProgress:" + o.inProgress + " o.type:" + o.type + " o.data:" + o.data + " o.isBlocking:" + o.isBlocking);
               if(!o.inProgress)
               {
                  o.inProgress = true;
                  switch(o.type)
                  {
                     case "file":
                        this.loadFile(o.data);
                        break;
                     case "class":
                        o.data.init(this.onInitClassComplete);
                  }
                  i = -1;
                  len = int(this._stack.length);
               }
               else if(Boolean(o.isBlocking))
               {
                  break;
               }
            }
         }
      }
      
      private function loadFile(loadTarget:String) : void
      {
         var target:String = this._path + loadTarget;
         this._openFile(target,this.onLoadComplete,this.onLoadProgress);
      }
      
      private function onLoadComplete(e:LoaderEvent) : void
      {
         if(e.status)
         {
            DebugUtility.debugTrace("ResourceStack onLoadComplete e:" + e + " name:" + e.entry.name);
            this.removeResource("file",e.entry.name);
            this.fifo();
            return;
         }
         throw new Error("could not load required resource!!! msg:" + e.message);
      }
      
      private function onLoadProgress(e:LoaderEvent) : void
      {
      }
      
      private function onInitClassComplete(classRef:IResourceStackable) : void
      {
         this.removeResource("class",classRef);
         this.fifo();
      }
      
      private function removeResource(type:String, data:*) : void
      {
         var s:Object = null;
         var len:int = int(this._stack.length);
         for(var i:int = 0; i < len; i++)
         {
            s = this._stack[i];
            if(s.type == type && s.data == data)
            {
               this._stack.splice(i,1);
               break;
            }
         }
      }
   }
}

