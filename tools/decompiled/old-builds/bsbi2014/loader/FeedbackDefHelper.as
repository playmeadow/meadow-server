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
      
      public function init(id:uint, callback:Function = null) : void
      {
         this._id = id;
         this._callback = callback;
         FeedbackFileServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleData,false,0,true);
         FeedbackFileServer.instance.requestFile(this._id);
      }
      
      public function destroy() : void
      {
         FeedbackFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
         this._callback = null;
      }
      
      private function handleData(fse:FileServerEvent) : void
      {
         var fseDataCopy:* = undefined;
         var copyBuffer:ByteArray = null;
         if(fse.id == this._id && fse.success)
         {
            FeedbackFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
            copyBuffer = new ByteArray();
            copyBuffer.writeObject(fse.data);
            copyBuffer.position = 0;
            fseDataCopy = copyBuffer.readObject();
            fseDataCopy.uncompress("deflate");
            this._def = fseDataCopy.readObject();
            if(this._callback != null)
            {
               this._callback(this);
               this._callback = null;
            }
         }
      }
   }
}

