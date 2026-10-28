package avatar
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.utils.ByteArray;
   
   public class AvatarViewExt_Splash
   {
      
      private static const SHADOW_X_OFFSET:int = -100;
      
      private static const SHADOW_Y_OFFSET:int = -20;
      
      private static const Shadow:Class = AvatarViewExt_Splash_Shadow;
      
      private static const WaterSplashSWF:Class = AvatarViewExt_Splash_WaterSplashSWF;
      
      private const _constSplash:ByteArray = new WaterSplashSWF();
      
      private var _mask:Shape;
      
      private var _shadow:Bitmap;
      
      private var _splash:Loader;
      
      private var _parent:Sprite;
      
      private var _maskLayer:DisplayObject;
      
      private var _bLastSplashVolume:Boolean;
      
      private var _bSplashInProgress:Boolean;
      
      private var _lastSplashLiquid:String;
      
      public function AvatarViewExt_Splash(param1:Sprite, param2:DisplayObject)
      {
         super();
         this._parent = param1;
         this._bSplashInProgress = false;
         this._bLastSplashVolume = false;
         this.createShadow();
         this.createMask(param2);
         this._parent.addChild(param2);
         this.createSplash();
      }
      
      public function destroy() : void
      {
         if(this._shadow)
         {
            this._parent.removeChild(this._shadow);
            this._shadow = null;
         }
         if(this._splash)
         {
            this._parent.removeChild(this._splash);
            this._splash.unloadAndStop();
            this._splash = null;
         }
         if(this._mask)
         {
            this._parent.removeChild(this._mask);
            this._mask = null;
         }
      }
      
      public function showShadow(param1:Boolean = true) : void
      {
         this._shadow.visible = param1;
      }
      
      private function createShadow() : void
      {
         this._shadow = new Shadow();
         this._shadow.x = SHADOW_X_OFFSET;
         this._shadow.y = SHADOW_Y_OFFSET;
         this._parent.addChild(this._shadow);
      }
      
      private function createMask(param1:DisplayObject) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         this._maskLayer = param1;
         this._mask = new Shape();
         this._parent.addChild(this._mask);
         this._mask.graphics.lineStyle();
         this._mask.graphics.beginFill(16777215,1);
         _loc2_ = -150;
         _loc3_ = -275;
         this._mask.graphics.moveTo(_loc2_,_loc3_);
         this._mask.graphics.lineTo(_loc2_ + 245,_loc3_);
         this._mask.graphics.lineTo(_loc2_ + 245,_loc3_ + 235);
         this._mask.graphics.curveTo(_loc2_ + 122.5,_loc3_ + 260,_loc2_,_loc3_ + 235);
         this._mask.graphics.lineTo(_loc2_,_loc3_);
         this._mask.graphics.endFill();
         this._maskLayer.mask = null;
         this._mask.visible = false;
      }
      
      private function createSplash() : void
      {
         this._splash = new Loader();
         this._splash.loadBytes(this._constSplash);
         this._splash.x = -18;
         this._splash.y = -28;
         this._parent.addChild(this._splash);
         this._splash.visible = false;
      }
      
      public function heartbeat(param1:Boolean, param2:Boolean, param3:String) : void
      {
         var _loc4_:MovieClip = MovieClip(this._splash.content);
         if(_loc4_)
         {
            if(param3 == "ice" || param3 == "fire" || param3 == "ghost")
            {
               param1 = false;
            }
            if(param1)
            {
               _loc4_.setState(param2 ? 1 : 2);
            }
            else if(_loc4_.currentFrame == 1 && this._splash.visible == true)
            {
               this._splash.visible = false;
            }
            if(param1 != this._bLastSplashVolume || param3 != this._lastSplashLiquid)
            {
               _loc4_.setLiquid(param3);
               this._bLastSplashVolume = param1;
               this._lastSplashLiquid = param3;
               this.showMask(param1);
               if(param1)
               {
                  if(this._splash.visible == false)
                  {
                     this._splash.visible = true;
                  }
                  _loc4_.setState(param2 ? 1 : 2);
               }
               else
               {
                  _loc4_.setState(0);
               }
            }
         }
      }
      
      private function showMask(param1:Boolean = true) : void
      {
         if(param1)
         {
            this._maskLayer.mask = this._mask;
            this.showShadow(false);
         }
         else
         {
            this._maskLayer.mask = null;
            this.showShadow(true);
         }
      }
   }
}

