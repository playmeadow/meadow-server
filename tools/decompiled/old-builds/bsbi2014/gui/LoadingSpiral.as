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
      
      public function LoadingSpiral(parent:DisplayObjectContainer = null, xPos:Number = 0, yPos:Number = 0, displayPercentage:Boolean = false)
      {
         super();
         if(Boolean(parent))
         {
            this._parent = parent;
         }
         this._addToParent = true;
         this.x = xPos;
         this.y = yPos;
         this._loadingSpiralHelper = new MediaHelper();
         this._loadingSpiralHelper.init(LOADING_SPIRAL_MEDIA_ID,this.loadingSpiralHandler);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         hasBeenLoaded = false;
         this._displayPercentage = displayPercentage;
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
      
      public function set isDarkenManagersSpiral(value:Boolean) : void
      {
         this._isDarkenManagersSpiral = value;
      }
      
      public function setNewParent(parent:DisplayObjectContainer, xPos:Number = 0, yPos:Number = 0, displayPercentage:Boolean = false) : void
      {
         this._parent = parent;
         this._addToParent = true;
         if(Boolean(this._parent) && Boolean(this._loadingSpiral))
         {
            this._parent.addChild(this);
         }
         if(Boolean(this._loadingSpiral))
         {
            if(displayPercentage)
            {
               this._loadingSpiral.txt.text = "0%";
               this._loadingSpiral.txt.visible = true;
            }
            else
            {
               this._loadingSpiral.txt.visible = false;
            }
         }
         this.x = xPos;
         this.y = yPos;
      }
      
      public function updatePercentText(percentage:String) : void
      {
         if(Boolean(this._loadingSpiral))
         {
            this._loadingSpiral.txt.text = percentage;
         }
      }
      
      private function loadingSpiralHandler(media:MovieClip) : void
      {
         if(this._addToParent)
         {
            this._loadingSpiral = media;
            this._loadingSpiral.txt.text = "0%";
            if(Boolean(this._loadingSpiral))
            {
               this.addChild(this._loadingSpiral);
            }
            if(Boolean(this._parent))
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
      
      private function onMouseDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onMouseOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
   }
}

