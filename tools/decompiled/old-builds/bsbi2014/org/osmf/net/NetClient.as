package org.osmf.net
{
   import flash.utils.Dictionary;
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public dynamic class NetClient extends Proxy
   {
      
      private var handlers:Dictionary = new Dictionary();
      
      public function NetClient()
      {
         super();
      }
      
      public function addHandler(name:String, handler:Function, priority:int = 0) : void
      {
         var inserted:Boolean = false;
         var i:int = 0;
         var handlerWithPriority:Object = null;
         var handlersForName:Array = this.handlers.hasOwnProperty(name) ? this.handlers[name] : (this.handlers[name] = []);
         if(handlersForName.indexOf(handler) == -1)
         {
            inserted = false;
            priority = Math.max(0,priority);
            if(priority > 0)
            {
               for(i = 0; i < handlersForName.length; i++)
               {
                  handlerWithPriority = handlersForName[i];
                  if(handlerWithPriority.priority < priority)
                  {
                     handlersForName.splice(i,0,{
                        "handler":handler,
                        "priority":priority
                     });
                     inserted = true;
                     break;
                  }
               }
            }
            if(!inserted)
            {
               handlersForName.push({
                  "handler":handler,
                  "priority":priority
               });
            }
         }
      }
      
      public function removeHandler(name:String, handler:Function) : void
      {
         var handlersForName:Array = null;
         var i:int = 0;
         var handlerWithPriority:Object = null;
         if(this.handlers.hasOwnProperty(name))
         {
            handlersForName = this.handlers[name];
            for(i = 0; i < handlersForName.length; i++)
            {
               handlerWithPriority = handlersForName[i];
               if(handlerWithPriority.handler == handler)
               {
                  handlersForName.splice(i,1);
                  break;
               }
            }
         }
      }
      
      override flash_proxy function callProperty(methodName:*, ... args) : *
      {
         return this.invokeHandlers(methodName,args);
      }
      
      override flash_proxy function getProperty(name:*) : *
      {
         var result:* = undefined;
         if(this.handlers.hasOwnProperty(name))
         {
            result = function():*
            {
               return invokeHandlers(arguments.callee.name,arguments);
            };
            result.name = name;
         }
         return result;
      }
      
      override flash_proxy function hasProperty(name:*) : Boolean
      {
         return this.handlers.hasOwnProperty(name);
      }
      
      private function invokeHandlers(name:String, args:Array) : *
      {
         var result:Array = null;
         var handlersForName:Array = null;
         var handler:Object = null;
         if(this.handlers.hasOwnProperty(name))
         {
            result = [];
            handlersForName = this.handlers[name];
            for each(handler in handlersForName)
            {
               result.push(handler.handler.apply(null,args));
            }
         }
         return result;
      }
   }
}

