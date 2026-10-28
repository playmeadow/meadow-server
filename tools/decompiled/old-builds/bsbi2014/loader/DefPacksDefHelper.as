package loader
{
   import com.adobe.serialization.json.JSON;
   import com.sbi.loader.FileServerEvent;
   import flash.utils.ByteArray;
   
   public class DefPacksDefHelper
   {
      
      public static const DEF_ITEM:int = 1000;
      
      public static const DEF_AVATAR:int = 1003;
      
      public static const DEF_LOCALIZATION:int = 1023;
      
      public static const DEF_NPC:int = 1025;
      
      public static const DEF_LAYER:int = 1027;
      
      public static const DEF_DEN_ITEM:int = 1030;
      
      public static const DEF_MEDIA:int = 1033;
      
      public static const DEF_FACT:int = 1035;
      
      public static const DEF_EMOTICON:int = 1036;
      
      public static const DEF_STREAM:int = 1037;
      
      public static const DEF_GENERIC_LIST_TYPE:int = 1038;
      
      public static const DEF_DEN_ROOM:int = 1040;
      
      public static const DEF_PET:int = 1046;
      
      public static const DEF_PARTY:int = 1047;
      
      public static const DEF_AVAILABILITY:int = 1048;
      
      public static const DEF_NAMEBAR_BADGE:int = 1049;
      
      public static const DEF_BATTLE_CARD:int = 1050;
      
      public static const DEF_CURRENCY_EXCHANGE:int = 1051;
      
      public static const DEF_SCRIPT:int = 1052;
      
      public static const DEF_MOVIE_NODE:int = 1053;
      
      public static const DEF_DIAMOND:int = 1054;
      
      public static const DEF_PREFERRED_LOCALIZATION:int = 1055;
      
      public static const PREDICTIVE_TEXT_FILE_TO_APPEND_TO:int = 10;
      
      public static const AUTO_CORRECT_TEXT_FILE_TO_APPEND_TO:int = 1;
      
      public static var mediaArray:Array = [];
      
      private var _id:uint;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      private var _passback:Object;
      
      public function DefPacksDefHelper()
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
      
      public function get passback() : Object
      {
         return this._passback;
      }
      
      public function init(id:uint, callback:Function = null, passback:Object = null, contentType:int = 0) : void
      {
         this._id = id;
         this._callback = callback;
         this._passback = passback;
         DefPacksFileServer.instance.addEventListener(FileServerEvent.ON_NEW_DATA,this.handleData,false,0,true);
         DefPacksFileServer.instance.requestFile(this._id,false,contentType);
      }
      
      public function destroy() : void
      {
         DefPacksFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
         this._callback = null;
      }
      
      private function handleData(fse:FileServerEvent) : void
      {
         var fseDataCopy:* = undefined;
         var copyBuffer:ByteArray = null;
         if(fse.id == this._id && fse.success)
         {
            DefPacksFileServer.instance.removeEventListener(FileServerEvent.ON_NEW_DATA,this.handleData);
            if(fse.contentType == FileServerEvent.JSON_TYPE)
            {
               fse.data.position = 0;
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

