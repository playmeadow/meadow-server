package avatar
{
   import flash.utils.ByteArray;
   import mx.core.MovieClipLoaderAsset;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1")]
   public class AvatarManager_FlowerIdle extends MovieClipLoaderAsset
   {
      
      private static var bytes:ByteArray = null;
      
      public var dataClass:Class = AvatarManager_FlowerIdle_dataClass;
      
      public function AvatarManager_FlowerIdle()
      {
         super();
         initialWidth = 11000 / 20;
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

