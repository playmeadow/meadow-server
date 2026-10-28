package avatar
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Matrix;
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
      
      private var _shadowChildIndex:int;
      
      public function AvatarViewExt_Splash(parent:Sprite, layerBitmap:DisplayObject)
      {
         super();
         this._parent = parent;
         this._bSplashInProgress = false;
         this._bLastSplashVolume = false;
         this.createShadow();
         this.createMask(layerBitmap);
         this._parent.addChild(layerBitmap);
         this.createSplash();
      }
      
      public function destroy() : void
      {
         if(Boolean(this._shadow) && this._shadow.parent != null)
         {
            this._shadow.parent.removeChild(this._shadow);
            this._shadow = null;
         }
         if(Boolean(this._splash))
         {
            this._parent.removeChild(this._splash);
            this._splash.unloadAndStop();
            this._splash = null;
         }
         if(Boolean(this._mask))
         {
            this._parent.removeChild(this._mask);
            this._mask = null;
         }
      }
      
      public function showShadow(flag:Boolean = true) : void
      {
         this._shadow.visible = flag;
      }
      
      private function createShadow() : void
      {
         this._shadow = new Shadow();
         this._shadow.x = SHADOW_X_OFFSET;
         this._shadow.y = SHADOW_Y_OFFSET;
         this._parent.addChild(this._shadow);
      }
      
      private function createMask(maskLayer:DisplayObject) : void
      {
         var x:Number = NaN;
         var y:Number = NaN;
         this._maskLayer = maskLayer;
         this._mask = new Shape();
         this._parent.addChild(this._mask);
         this._mask.graphics.lineStyle();
         this._mask.graphics.beginFill(16777215,1);
         x = -150;
         y = -275;
         this._mask.graphics.moveTo(x,y);
         this._mask.graphics.lineTo(x + 245,y);
         this._mask.graphics.lineTo(x + 245,y + 235);
         this._mask.graphics.curveTo(x + 122.5,y + 260,x,y + 235);
         this._mask.graphics.lineTo(x,y);
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
      
      public function flipSplash(b:Boolean) : void
      {
         var matrix:Matrix = this._shadow.transform.matrix;
         if(b)
         {
            if(matrix.a != -1)
            {
               matrix.scale(-1,1);
               this._shadow.transform.matrix = matrix;
               matrix = this._splash.content.transform.matrix;
               matrix.scale(-1,1);
               this._splash.content.transform.matrix = matrix;
            }
         }
         else if(matrix.a == -1)
         {
            matrix.scale(-1,1);
            this._shadow.transform.matrix = matrix;
            matrix = this._splash.content.transform.matrix;
            matrix.scale(-1,1);
            this._splash.content.transform.matrix = matrix;
         }
      }
      
      public function heartbeat(bInSplashVolume:Boolean, bIsSplashAnim:Boolean, splashLiquid:String, inAir:Boolean) : void
      {
         if(Boolean(this._shadow))
         {
            if(inAir)
            {
               if(this._shadow.parent != null)
               {
                  this._shadowChildIndex = this._shadow.parent.getChildIndex(this._shadow);
                  this._shadow.parent.removeChild(this._shadow);
               }
            }
            else if(this._shadow.parent == null)
            {
               this._parent.addChildAt(this._shadow,this._shadowChildIndex);
            }
         }
         var splashMC:MovieClip = MovieClip(this._splash.content);
         if(Boolean(splashMC))
         {
            if(splashLiquid == "ice" || splashLiquid == "fire" || splashLiquid == "ghost")
            {
               bInSplashVolume = false;
            }
            if(bInSplashVolume)
            {
               splashMC.setState(bIsSplashAnim ? 1 : 2);
            }
            else if(splashMC.currentFrame == 1 && this._splash.visible == true)
            {
               this._splash.visible = false;
            }
            if(bInSplashVolume != this._bLastSplashVolume || splashLiquid != this._lastSplashLiquid)
            {
               splashMC.setLiquid(splashLiquid);
               this._bLastSplashVolume = bInSplashVolume;
               this._lastSplashLiquid = splashLiquid;
               this.showMask(bInSplashVolume);
               if(bInSplashVolume)
               {
                  if(this._splash.visible == false)
                  {
                     this._splash.visible = true;
                  }
                  splashMC.setState(bIsSplashAnim ? 1 : 2);
               }
               else
               {
                  splashMC.setState(0);
               }
            }
         }
      }
      
      private function showMask(show:Boolean = true) : void
      {
         if(show)
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

