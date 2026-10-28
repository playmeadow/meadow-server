package game
{
   import flash.utils.ByteArray;
   import mx.core.MovieClipLoaderAsset;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1")]
   public class MinigameManager_GameTotem extends MovieClipLoaderAsset
   {
      
      private static var bytes:ByteArray = null;
      
      public var dataClass:Class = MinigameManager_GameTotem_dataClass;
      
      public function MinigameManager_GameTotem()
      {
         super();
         initialWidth = 2000 / 20;
         initialHeight = 3000 / 20;
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

