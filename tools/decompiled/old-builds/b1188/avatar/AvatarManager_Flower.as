package avatar
{
   import flash.utils.ByteArray;
   import mx.core.MovieClipLoaderAsset;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1")]
   public class AvatarManager_Flower extends MovieClipLoaderAsset
   {
      
      private static var bytes:ByteArray = null;
      
      public var dataClass:Class = AvatarManager_Flower_dataClass;
      
      public function AvatarManager_Flower()
      {
         super();
         initialWidth = 2840 / 20;
         initialHeight = 2600 / 20;
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

