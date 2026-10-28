package item
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.ImageArrayHelper;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.loader.ImageServerEvent;
   import com.sbi.loader.ImageServerURL;
   
   public class SimpleIcon
   {
      
      public static const GLOBAL_ANIM_FPS:int = 24;
      
      public static const THROTTLE_FRAME_UPDATES:int = 4;
      
      public static const ANIM_ICON:int = 18;
      
      public static const AN_ICON_L:int = 25;
      
      public static const AN_ICON_S:int = 26;
      
      private var _bitmap:LayerBitmap;
      
      private var _color:uint;
      
      private var _accId:int;
      
      private var _state:int;
      
      private var _avatarType:int;
      
      private var _currImageData:Object;
      
      private var _hflip:Boolean;
      
      private var _wasNull:Boolean;
      
      private var _holdDraw:Boolean;
      
      private var _callBack:Function;
      
      private var _expectingNewData:uint;
      
      private var _anIconId:int;
      
      public function SimpleIcon()
      {
         super();
      }
      
      public function init(param1:LayerBitmap, param2:uint, param3:int, param4:int, param5:Boolean = false, param6:Boolean = false, param7:Function = null) : void
      {
         this._bitmap = param1;
         this._color = param2;
         this._accId = param3;
         this._hflip = param6;
         this._callBack = param7;
         this._avatarType = param4;
         this._anIconId = param5 ? AN_ICON_L : AN_ICON_S;
         this._expectingNewData = 4294967295;
         this._currImageData = null;
         ImageServerURL.instance.addEventListener(ImageServerEvent.ON_NEW_DATA,this.handleIconData,false,0,true);
         this.paint();
      }
      
      public function destroy() : void
      {
         ImageServerURL.instance.removeEventListener(ImageServerEvent.ON_NEW_DATA,this.handleIconData);
      }
      
      public function paint() : void
      {
         this._expectingNewData = ImageArrayHelper.packId(this._avatarType,this._anIconId,this._accId);
         ImageServerURL.instance.requestImage(this._expectingNewData);
      }
      
      private function handleIconData(param1:ImageServerEvent) : void
      {
         if(param1.id != this._expectingNewData)
         {
            return;
         }
         if(param1.success)
         {
            this._currImageData = param1.imageData;
            this._bitmap.setLayer(param1.layer,this._currImageData,this._color);
            this._expectingNewData = 4294967295;
            this.drawFrame();
         }
      }
      
      private function drawFrame() : void
      {
         if(!this._currImageData || this._currImageData.length == 0)
         {
            DebugUtility.debugTrace("Icon skipping drawFrame due to invalid _currImageData:" + this._currImageData + " _currImageData.length:" + this._currImageData.length);
            return;
         }
         this._bitmap.paint(0,this._hflip);
         if(this._callBack != null)
         {
            this._callBack();
            this._callBack = null;
         }
      }
   }
}

