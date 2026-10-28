package loader
{
   import com.adobe.serialization.json.JSON;
   import com.sbi.loader.FileServerEvent;
   import flash.utils.ByteArray;
   
   public class PollDefHelper
   {
      
      private var _id:uint;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      public function PollDefHelper()
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
         PollFileServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleData,false,0,true);
         PollFileServer.instance.requestFile(this._id,false,FileServerEvent.AMF3_TYPE);
      }
      
      public function destroy() : void
      {
         PollFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
         this._callback = null;
      }
      
      private function handleData(fse:FileServerEvent) : void
      {
         var fseDataCopy:* = undefined;
         var copyBuffer:ByteArray = null;
         if(fse.id == this._id && fse.success)
         {
            PollFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
            if(fse.contentType == FileServerEvent.JSON_TYPE)
            {
               this._def = com.adobe.serialization.json.JSON.decode(fse.data);
            }
            else if(fse.contentType == FileServerEvent.AMF3_TYPE)
            {
               copyBuffer = new ByteArray();
               copyBuffer.writeObject(fse.data);
               copyBuffer.position = 0;
               fseDataCopy = copyBuffer.readObject();
               fseDataCopy.uncompress("deflate");
               this._def = fseDataCopy.readObject();
            }
            else
            {
               this._def = fse.data;
            }
            if(this._callback != null)
            {
               this._callback(this);
               this._callback = null;
            }
         }
      }
   }
}

