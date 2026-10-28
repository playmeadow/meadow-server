package ecard
{
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class ECardImageBase
   {
      
      private var _mediaId:int;
      
      private var _img:MovieClip;
      
      private var _img2:MovieClip;
      
      private var _imgHelper:MediaHelper;
      
      private var _imgHelper2:MediaHelper;
      
      private var _onImageLoadedCallback:Function;
      
      public function ECardImageBase()
      {
         super();
      }
      
      public function init(param1:int, param2:Function = null) : void
      {
         this._mediaId = param1;
         this._onImageLoadedCallback = param2;
         this._imgHelper = new MediaHelper();
         this._imgHelper.init(this._mediaId,this.imgReceived);
         this._imgHelper2 = new MediaHelper();
         this._imgHelper2.init(this._mediaId,this.img2Received);
      }
      
      private function imgReceived(param1:MovieClip) : void
      {
         this._img = param1;
         this._imgHelper.destroy();
         this._imgHelper = null;
         if(Boolean(this._img2) && this._onImageLoadedCallback != null)
         {
            this._onImageLoadedCallback();
            this._onImageLoadedCallback = null;
         }
      }
      
      private function img2Received(param1:MovieClip) : void
      {
         this._img2 = param1;
         this._imgHelper2.destroy();
         this._imgHelper2 = null;
         if(Boolean(this._img) && this._onImageLoadedCallback != null)
         {
            this._onImageLoadedCallback();
            this._onImageLoadedCallback = null;
         }
      }
      
      public function get img() : MovieClip
      {
         return this._img;
      }
      
      public function get img2() : MovieClip
      {
         return this._img2;
      }
      
      public function get mediaId() : int
      {
         return this._mediaId;
      }
   }
}

