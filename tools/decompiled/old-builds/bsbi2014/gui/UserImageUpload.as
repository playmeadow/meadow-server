package gui
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.JPEGAsyncCompleteEvent;
   import com.sbi.graphics.JpegAsynchEncoder;
   import com.sbi.popup.SBOkPopup;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import localization.LocalizationManager;
   
   public class UserImageUpload
   {
      
      private static const MAX_FILE_SIZE:Number = 2000 * 1024;
      
      private var _myFileReference:FileReference;
      
      private var _byteArrayLoader:Loader;
      
      private var _uploadBtn:MovieClip;
      
      private var _jpgEncoder:JpegAsynchEncoder;
      
      private var _fileName:String;
      
      public function UserImageUpload()
      {
         super();
      }
      
      public function init() : void
      {
         this.addEventListeners();
      }
      
      public function setUploadBtn(uploadBtn:MovieClip) : void
      {
         if(Boolean(uploadBtn))
         {
            this._uploadBtn = uploadBtn;
            this._uploadBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onUploadDown,false,0,true);
            return;
         }
         throw new Error("Upload button was not provided");
      }
      
      public function get uploadedImage() : ByteArray
      {
         if(Boolean(this._jpgEncoder))
         {
            return this._jpgEncoder.ImageData;
         }
         return null;
      }
      
      public function get fileName() : String
      {
         if(Boolean(this._fileName))
         {
            return this._fileName;
         }
         return "";
      }
      
      public function resetUploader() : void
      {
         this._jpgEncoder = null;
         this._fileName = null;
      }
      
      private function onUploadDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._myFileReference = new FileReference();
         this._myFileReference.addEventListener(Event.SELECT,this.onFileSelected,false,0,true);
         this._myFileReference.browse([new FileFilter("Images","*.jpeg;*.jpg;*.png")]);
      }
      
      private function onFileSelected(event:Event) : void
      {
         if(this._myFileReference.size > MAX_FILE_SIZE)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14806));
            return;
         }
         DarkenManager.showLoadingSpiral(true,true);
         this._myFileReference.addEventListener(Event.COMPLETE,this.onFileLoaded,false,0,true);
         this._myFileReference.addEventListener(IOErrorEvent.IO_ERROR,this.onFileLoadError,false,0,true);
         this._myFileReference.addEventListener(ProgressEvent.PROGRESS,this.onProgress,false,0,true);
         this._myFileReference.load();
      }
      
      private function onProgress(evt:ProgressEvent) : void
      {
         DebugUtility.debugTrace("UPLOADED: " + (evt.bytesLoaded / evt.bytesTotal * 100).toFixed() + " %");
      }
      
      private function onFileLoaded(evt:Event) : void
      {
         var myFileReference:FileReference = evt.target as FileReference;
         if(myFileReference["data"].bytesAvailable > 0)
         {
            this._byteArrayLoader = new Loader();
            this._byteArrayLoader.loadBytes(myFileReference["data"]);
            this._fileName = this._myFileReference.name;
            this._byteArrayLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onByteArrayLoaded,false,0,true);
            this._myFileReference.removeEventListener(Event.COMPLETE,this.onFileLoaded);
            this._myFileReference.removeEventListener(IOErrorEvent.IO_ERROR,this.onFileLoadError);
            this._myFileReference.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            this.onFileLoadError(null);
         }
      }
      
      private function onFileLoadError(evt:Event) : void
      {
         this._myFileReference.removeEventListener(Event.COMPLETE,this.onFileLoaded);
         this._myFileReference.removeEventListener(IOErrorEvent.IO_ERROR,this.onFileLoadError);
         this._myFileReference.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14807));
      }
      
      private function onByteArrayLoaded(evt:Event) : void
      {
         var content:Bitmap = evt.target.content;
         this._jpgEncoder = new JpegAsynchEncoder();
         this._jpgEncoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE,this.asyncEncodingComplete,false,0,true);
         this._jpgEncoder.addEventListener(ProgressEvent.PROGRESS,this.onEncodingProgress,false,0,true);
         this._jpgEncoder.PixelsPerIteration = 128;
         this._jpgEncoder.JPEGAsyncEncoder(50);
         this._jpgEncoder.encode(content.bitmapData);
      }
      
      private function asyncEncodingComplete(event:JPEGAsyncCompleteEvent) : void
      {
         this._jpgEncoder.removeEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE,this.asyncEncodingComplete);
         this._jpgEncoder.removeEventListener(ProgressEvent.PROGRESS,this.onEncodingProgress);
         this._uploadBtn.visible = false;
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function onEncodingProgress(event:ProgressEvent) : void
      {
         DarkenManager.updateLoadingSpiralPercentage(Math.round(event.bytesLoaded / event.bytesTotal * 100) + "%");
      }
      
      private function addEventListeners() : void
      {
      }
      
      private function removeEventListeners() : void
      {
         this._uploadBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onUploadDown);
      }
   }
}

