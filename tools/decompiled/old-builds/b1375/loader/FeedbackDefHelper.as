package loader
{
   import com.sbi.loader.FileServerEvent;
   import flash.utils.ByteArray;
   
   public class FeedbackDefHelper
   {
      
      private var _id:uint;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      public function FeedbackDefHelper()
      {
         super();
      }
      
      public function get id() : int
      {
         return _id;
      }
      
      public function get def() : Object
      {
         return _def;
      }
      
      public function init(param1:uint, param2:Function = null) : void
      {
         _id = param1;
         _callback = param2;
         FeedbackFileServer.instance.addEventListener("OnNewData",handleData,false,0,true);
         FeedbackFileServer.instance.requestFile(_id);
      }
      
      public function destroy() : void
      {
         FeedbackFileServer.instance.removeEventListener("OnNewData",handleData);
         _callback = null;
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:ByteArray = null;
         if(param1.id == _id && param1.success)
         {
            FeedbackFileServer.instance.removeEventListener("OnNewData",handleData);
            _loc2_ = new ByteArray();
            _loc2_.writeObject(param1.data);
            _loc2_.position = 0;
            _loc3_ = _loc2_.readObject();
            _loc3_.uncompress("deflate");
            _def = _loc3_.readObject();
            if(_callback != null)
            {
               _callback(this);
               _callback = null;
            }
         }
      }
   }
}

