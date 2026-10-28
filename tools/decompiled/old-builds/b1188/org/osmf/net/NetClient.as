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
      
      public function addHandler(param1:String, param2:Function, param3:int = 0) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc4_:Array = this.handlers.hasOwnProperty(param1) ? this.handlers[param1] : (this.handlers[param1] = []);
         if(_loc4_.indexOf(param2) == -1)
         {
            _loc5_ = false;
            param3 = Math.max(0,param3);
            if(param3 > 0)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc4_.length)
               {
                  _loc7_ = _loc4_[_loc6_];
                  if(_loc7_.priority < param3)
                  {
                     _loc4_.splice(_loc6_,0,{
                        "handler":param2,
                        "priority":param3
                     });
                     _loc5_ = true;
                     break;
                  }
                  _loc6_++;
               }
            }
            if(!_loc5_)
            {
               _loc4_.push({
                  "handler":param2,
                  "priority":param3
               });
            }
         }
      }
      
      public function removeHandler(param1:String, param2:Function) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         if(this.handlers.hasOwnProperty(param1))
         {
            _loc3_ = this.handlers[param1];
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = _loc3_[_loc4_];
               if(_loc5_.handler == param2)
               {
                  _loc3_.splice(_loc4_,1);
                  break;
               }
               _loc4_++;
            }
         }
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         return this.invokeHandlers(param1,rest);
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         var result:* = undefined;
         var name:* = param1;
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
      
      override flash_proxy function hasProperty(param1:*) : Boolean
      {
         return this.handlers.hasOwnProperty(param1);
      }
      
      private function invokeHandlers(param1:String, param2:Array) : *
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         if(this.handlers.hasOwnProperty(param1))
         {
            _loc3_ = [];
            _loc4_ = this.handlers[param1];
            for each(_loc5_ in _loc4_)
            {
               _loc3_.push(_loc5_.handler.apply(null,param2));
            }
         }
         return _loc3_;
      }
   }
}

