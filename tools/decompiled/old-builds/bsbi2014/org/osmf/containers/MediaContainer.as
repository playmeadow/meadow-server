package org.osmf.containers
{
   import flash.display.DisplayObject;
   import flash.errors.IllegalOperationError;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import org.osmf.events.ContainerChangeEvent;
   import org.osmf.layout.LayoutMetadata;
   import org.osmf.layout.LayoutRenderer;
   import org.osmf.layout.LayoutRendererBase;
   import org.osmf.layout.LayoutTargetEvent;
   import org.osmf.layout.LayoutTargetSprite;
   import org.osmf.layout.MediaElementLayoutTarget;
   import org.osmf.media.MediaElement;
   import org.osmf.utils.OSMFStrings;
   
   public class MediaContainer extends LayoutTargetSprite implements IMediaContainer
   {
      
      private var layoutTargets:Dictionary = new Dictionary();
      
      private var _layoutRenderer:LayoutRendererBase;
      
      private var _backgroundColor:Number;
      
      private var _backgroundAlpha:Number;
      
      private var lastAvailableWidth:Number;
      
      private var lastAvailableHeight:Number;
      
      public function MediaContainer(layoutRenderer:LayoutRendererBase = null, layoutMetadata:LayoutMetadata = null)
      {
         super(layoutMetadata);
         this._layoutRenderer = layoutRenderer || new LayoutRenderer();
         this._layoutRenderer.container = this;
      }
      
      public function addMediaElement(element:MediaElement) : MediaElement
      {
         var contentTarget:MediaElementLayoutTarget = null;
         if(element == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(this.layoutTargets[element] == undefined)
         {
            element.dispatchEvent(new ContainerChangeEvent(ContainerChangeEvent.CONTAINER_CHANGE,false,false,element.container,this));
            contentTarget = MediaElementLayoutTarget.getInstance(element);
            this.layoutTargets[element] = contentTarget;
            this._layoutRenderer.addTarget(contentTarget);
            element.addEventListener(ContainerChangeEvent.CONTAINER_CHANGE,this.onElementContainerChange);
            return element;
         }
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
      }
      
      public function removeMediaElement(element:MediaElement) : MediaElement
      {
         var result:MediaElement = null;
         if(element == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         var contentTarget:MediaElementLayoutTarget = this.layoutTargets[element];
         if(Boolean(contentTarget))
         {
            element.removeEventListener(ContainerChangeEvent.CONTAINER_CHANGE,this.onElementContainerChange);
            this._layoutRenderer.removeTarget(contentTarget);
            delete this.layoutTargets[element];
            result = element;
            if(element.container == this)
            {
               element.dispatchEvent(new ContainerChangeEvent(ContainerChangeEvent.CONTAINER_CHANGE,false,false,element.container,null));
            }
            return result;
         }
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
      }
      
      public function containsMediaElement(element:MediaElement) : Boolean
      {
         return this.layoutTargets[element] != undefined;
      }
      
      public function get layoutRenderer() : LayoutRendererBase
      {
         return this._layoutRenderer;
      }
      
      public function get clipChildren() : Boolean
      {
         return scrollRect != null;
      }
      
      public function set clipChildren(value:Boolean) : void
      {
         if(value && scrollRect == null)
         {
            scrollRect = new Rectangle(0,0,this._layoutRenderer.measuredWidth,this._layoutRenderer.measuredHeight);
         }
         else if(value == false && Boolean(scrollRect))
         {
            scrollRect = null;
         }
      }
      
      public function get backgroundColor() : Number
      {
         return this._backgroundColor;
      }
      
      public function set backgroundColor(value:Number) : void
      {
         if(value != this._backgroundColor)
         {
            this._backgroundColor = value;
            this.drawBackground();
         }
      }
      
      public function get backgroundAlpha() : Number
      {
         return this._backgroundAlpha;
      }
      
      public function set backgroundAlpha(value:Number) : void
      {
         if(value != this._backgroundAlpha)
         {
            this._backgroundAlpha = value;
            this.drawBackground();
         }
      }
      
      override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true) : void
      {
         super.layout(availableWidth,availableHeight,deep);
         this.lastAvailableWidth = availableWidth;
         this.lastAvailableHeight = availableHeight;
         if(!isNaN(this.backgroundColor))
         {
            this.drawBackground();
         }
         if(Boolean(scrollRect))
         {
            scrollRect = new Rectangle(0,0,availableWidth,availableHeight);
         }
      }
      
      override public function validateNow() : void
      {
         this._layoutRenderer.validateNow();
      }
      
      override public function addChild(child:DisplayObject) : DisplayObject
      {
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DIRECT_DISPLAY_LIST_MOD_ERROR));
      }
      
      override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
      {
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DIRECT_DISPLAY_LIST_MOD_ERROR));
      }
      
      override public function removeChild(child:DisplayObject) : DisplayObject
      {
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DIRECT_DISPLAY_LIST_MOD_ERROR));
      }
      
      override public function setChildIndex(child:DisplayObject, index:int) : void
      {
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.DIRECT_DISPLAY_LIST_MOD_ERROR));
      }
      
      override protected function onAddChildAt(event:LayoutTargetEvent) : void
      {
         super.addChildAt(event.displayObject,event.index);
      }
      
      override protected function onRemoveChild(event:LayoutTargetEvent) : void
      {
         super.removeChild(event.displayObject);
      }
      
      override protected function onSetChildIndex(event:LayoutTargetEvent) : void
      {
         super.setChildIndex(event.displayObject,event.index);
      }
      
      private function drawBackground() : void
      {
         graphics.clear();
         if(Boolean(!isNaN(this._backgroundColor) && this._backgroundAlpha != 0) && Boolean(this.lastAvailableWidth) && Boolean(this.lastAvailableHeight))
         {
            graphics.beginFill(this._backgroundColor,this._backgroundAlpha);
            graphics.drawRect(0,0,this.lastAvailableWidth,this.lastAvailableHeight);
            graphics.endFill();
         }
      }
      
      private function onElementContainerChange(event:ContainerChangeEvent) : void
      {
         if(event.oldContainer == this)
         {
            this.removeMediaElement(event.target as MediaElement);
         }
      }
   }
}

