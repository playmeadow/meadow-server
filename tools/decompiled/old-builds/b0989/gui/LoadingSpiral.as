package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   
   public class LoadingSpiral extends MovieClip
   {
      
      public static var hasBeenLoaded:Boolean;
      
      public static const LOADING_SPIRAL_MEDIA_ID:int = 44;
      
      private var _isDarkenManagersSpiral:Boolean;
      
      private var _loadingSpiral:MovieClip;
      
      private var _loadingSpiralHelper:MediaHelper;
      
      private var _parent:DisplayObjectContainer;
      
      private var _addToParent:Boolean;
      
      private var _displayPercentage:Boolean;
      
      public function LoadingSpiral(param1:DisplayObjectContainer = null, param2:Number = 0, param3:Number = 0, param4:Boolean = false)
      {
         super();
         if(param1)
         {
            this._parent = param1;
         }
         this._addToParent = true;
         this.x = param2;
         this.y = param3;
         this._loadingSpiralHelper = new MediaHelper();
         this._loadingSpiralHelper.init(LOADING_SPIRAL_MEDIA_ID,this.loadingSpiralHandler);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         hasBeenLoaded = false;
         this._displayPercentage = param4;
      }
      
      public function destroy() : void
      {
         if(Boolean(this._parent) && Boolean(this._loadingSpiral) && this.parent == this._parent)
         {
            this._parent.removeChild(this);
            this._parent = null;
            this._addToParent = false;
         }
         if(!this._isDarkenManagersSpiral)
         {
            this._parent = null;
         }
         this._displayPercentage = false;
      }
      
      public function set isDarkenManagersSpiral(param1:Boolean) : void
      {
         this._isDarkenManagersSpiral = param1;
      }
      
      public function setNewParent(param1:DisplayObjectContainer, param2:Number = 0, param3:Number = 0, param4:Boolean = false) : void
      {
         this._parent = param1;
         this._addToParent = true;
         if(Boolean(this._parent) && Boolean(this._loadingSpiral))
         {
            this._parent.addChild(this);
         }
         if(this._loadingSpiral)
         {
            if(param4)
            {
               this._loadingSpiral.txt.text = "0%";
               this._loadingSpiral.txt.visible = true;
            }
            else
            {
               this._loadingSpiral.txt.visible = false;
            }
         }
         this.x = param2;
         this.y = param3;
      }
      
      public function updatePercentText(param1:String) : void
      {
         if(this._loadingSpiral)
         {
            this._loadingSpiral.txt.text = param1;
         }
      }
      
      private function loadingSpiralHandler(param1:MovieClip) : void
      {
         if(this._addToParent)
         {
            this._loadingSpiral = param1;
            this._loadingSpiral.txt.text = "0%";
            if(this._loadingSpiral)
            {
               this.addChild(this._loadingSpiral);
            }
            if(this._parent)
            {
               this._parent.addChild(this);
            }
            if(!this._displayPercentage)
            {
               this._loadingSpiral.txt.visible = false;
            }
            else
            {
               this._loadingSpiral.txt.visible = true;
            }
            hasBeenLoaded = true;
            this._loadingSpiralHelper.destroy();
            this._loadingSpiralHelper = null;
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

