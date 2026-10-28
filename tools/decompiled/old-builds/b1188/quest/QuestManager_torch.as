package quest
{
   import flash.utils.ByteArray;
   import mx.core.MovieClipLoaderAsset;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1")]
   public class QuestManager_torch extends MovieClipLoaderAsset
   {
      
      private static var bytes:ByteArray = null;
      
      public var dataClass:Class = QuestManager_torch_dataClass;
      
      public function QuestManager_torch()
      {
         super();
         initialWidth = 13880 / 20;
         initialHeight = 8000 / 20;
      }
      
      override public function get movieClipData() : ByteArray
      {
         if(bytes == null)
         {
            bytes = ByteArray(new this.dataClass());
         }
         return bytes;
      }
   }
}

