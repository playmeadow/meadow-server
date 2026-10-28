package it.gotoandplay.smartfoxserver.handlers
{
   import it.gotoandplay.smartfoxserver.SFSEvent;
   import it.gotoandplay.smartfoxserver.SmartFoxClient;
   import it.gotoandplay.smartfoxserver.util.ObjectSerializer;
   
   public class ExtHandler implements IMessageHandler
   {
      
      private var sfs:SmartFoxClient;
      
      public function ExtHandler(param1:SmartFoxClient)
      {
         super();
         this.sfs = param1;
      }
      
      public function handleMessage(param1:Object, param2:String) : void
      {
         var _loc9_:Object = null;
         var _loc6_:SFSEvent = null;
         var _loc5_:XML = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc4_:String = null;
         var _loc3_:Object = null;
         if(param2 == "xml")
         {
            _loc5_ = param1 as XML;
            _loc7_ = _loc5_.body.@action;
            _loc8_ = int(_loc5_.body.@id);
            if(_loc7_ == "xtRes")
            {
               _loc4_ = _loc5_.body.toString();
               _loc3_ = ObjectSerializer.getInstance().deserialize(_loc4_);
               _loc9_ = {};
               _loc9_.dataObj = _loc3_;
               _loc9_.type = param2;
               _loc6_ = new SFSEvent("onExtensionResponse",_loc9_);
               sfs.dispatchEvent(_loc6_);
            }
         }
         else if(param2 == "json")
         {
            _loc9_ = {};
            _loc9_.dataObj = param1.o;
            _loc9_.type = param2;
            _loc6_ = new SFSEvent("onExtensionResponse",_loc9_);
            sfs.dispatchEvent(_loc6_);
         }
         else if(param2 == "str")
         {
            _loc9_ = {};
            _loc9_.dataObj = param1;
            _loc9_.type = param2;
            _loc6_ = new SFSEvent("onExtensionResponse",_loc9_);
            sfs.dispatchEvent(_loc6_);
         }
      }
   }
}

