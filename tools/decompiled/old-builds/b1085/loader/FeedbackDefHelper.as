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
         return this._id;
      }
      
      public function get def() : Object
      {
         return this._def;
      }
      
      public function init(param1:uint, param2:Function = null) : void
      {
         this._id = param1;
         this._callback = param2;
         FeedbackFileServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleData,false,0,true);
         FeedbackFileServer.instance.requestFile(this._id);
      }
      
      public function destroy() : void
      {
         FeedbackFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
         this._callback = null;
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:ByteArray = null;
         if(param1.id == this._id && param1.success)
         {
            FeedbackFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
            _loc3_ = new ByteArray();
            _loc3_.writeObject(param1.data);
            _loc3_.position = 0;
            _loc2_ = _loc3_.readObject();
            _loc2_.uncompress("deflate");
            this._def = _loc2_.readObject();
            if(this._callback != null)
            {
               this._callback(this);
               this._callback = null;
            }
         }
      }
   }
}

