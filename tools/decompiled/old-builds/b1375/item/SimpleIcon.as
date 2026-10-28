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
         _bitmap = param1;
         _color = param2;
         _accId = param3;
         _hflip = param6;
         _callBack = param7;
         _avatarType = param4;
         _anIconId = param5 ? 25 : 26;
         _expectingNewData = 4294967295;
         _currImageData = null;
         ImageServerURL.instance.addEventListener("OnNewData",handleIconData,false,0,true);
         paint();
      }
      
      public function destroy() : void
      {
         ImageServerURL.instance.removeEventListener("OnNewData",handleIconData);
      }
      
      public function paint() : void
      {
         _expectingNewData = ImageArrayHelper.packId(_avatarType,_anIconId,_accId);
         ImageServerURL.instance.requestImage(_expectingNewData);
      }
      
      private function handleIconData(param1:ImageServerEvent) : void
      {
         if(param1.id != _expectingNewData)
         {
            return;
         }
         if(param1.success)
         {
            _currImageData = param1.imageData;
            _bitmap.setLayer(param1.layer,_currImageData,_color);
            _expectingNewData = 4294967295;
            drawFrame();
         }
         else if(_callBack != null)
         {
            _callBack();
            _callBack = null;
         }
      }
      
      private function drawFrame() : void
      {
         if(!_currImageData || _currImageData.length == 0)
         {
            DebugUtility.debugTrace("Icon skipping drawFrame due to invalid _currImageData:" + _currImageData + " _currImageData.length:" + _currImageData.length);
            return;
         }
         _bitmap.paint(0,_hflip);
         if(_callBack != null)
         {
            _callBack();
            _callBack = null;
         }
      }
   }
}

