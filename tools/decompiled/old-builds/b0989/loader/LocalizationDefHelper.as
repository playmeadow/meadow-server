package loader
{
   import com.sbi.loader.FileServerEvent;
   
   public class LocalizationDefHelper
   {
      
      private var _id:uint;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      public function LocalizationDefHelper()
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
         LocalizationFileServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleData,false,0,true);
         LocalizationFileServer.instance.requestFile(this._id);
      }
      
      public function destroy() : void
      {
         LocalizationFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
         this._callback = null;
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         if(param1.id == this._id && param1.success)
         {
            LocalizationFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
            param1.data.position = 0;
            this._def = param1.data.readObject();
            if(this._callback != null)
            {
               this._callback(this);
               this._callback = null;
            }
         }
      }
   }
}

