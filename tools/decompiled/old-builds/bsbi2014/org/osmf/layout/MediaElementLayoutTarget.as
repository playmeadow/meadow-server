package org.osmf.layout
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.events.DisplayObjectEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.traits.DisplayObjectTrait;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="removeChild",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="setChildIndex",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="addChildAt",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="removeFromLayoutRenderer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="addToLayoutRenderer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="unsetAsLayoutRendererContainer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="setAsLayoutRendererContainer",type="org.osmf.layout.LayoutTargetEvent")]
   public class MediaElementLayoutTarget extends EventDispatcher implements ILayoutTarget
   {
      
      private static const layoutTargets:Dictionary = new Dictionary(true);
      
      private var _mediaElement:MediaElement;
      
      private var _layoutMetadata:LayoutMetadata;
      
      private var displayObjectTrait:DisplayObjectTrait;
      
      private var _displayObject:DisplayObject;
      
      private var renderers:LayoutTargetRenderers;
      
      public function MediaElementLayoutTarget(mediaElement:MediaElement, constructorLock:Class)
      {
         super();
         if(constructorLock != ConstructorLock)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ILLEGAL_CONSTRUCTOR_INVOCATION));
         }
         this._mediaElement = mediaElement;
         this._mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD,this.onMediaElementTraitsChange);
         this._mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE,this.onMediaElementTraitsChange);
         this._mediaElement.addEventListener(MediaElementEvent.METADATA_ADD,this.onMetadataAdd);
         this._mediaElement.addEventListener(MediaElementEvent.METADATA_REMOVE,this.onMetadataRemove);
         this.renderers = new LayoutTargetRenderers(this);
         this._layoutMetadata = this._mediaElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
         addEventListener(LayoutTargetEvent.ADD_CHILD_AT,this.onAddChildAt);
         addEventListener(LayoutTargetEvent.SET_CHILD_INDEX,this.onSetChildIndex);
         addEventListener(LayoutTargetEvent.REMOVE_CHILD,this.onRemoveChild);
         this.onMediaElementTraitsChange();
      }
      
      public static function getInstance(mediaElement:MediaElement) : MediaElementLayoutTarget
      {
         var instance:* = undefined;
         for(instance in layoutTargets)
         {
            if(instance.mediaElement == mediaElement)
            {
               break;
            }
            instance = null;
         }
         if(instance == null)
         {
            instance = new MediaElementLayoutTarget(mediaElement,ConstructorLock);
            layoutTargets[instance] = true;
         }
         return instance;
      }
      
      public function get mediaElement() : MediaElement
      {
         return this._mediaElement;
      }
      
      public function get layoutMetadata() : LayoutMetadata
      {
         if(this._layoutMetadata == null)
         {
            this._layoutMetadata = new LayoutMetadata();
            this._mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE,this._layoutMetadata);
         }
         return this._layoutMetadata;
      }
      
      public function get displayObject() : DisplayObject
      {
         return this._displayObject;
      }
      
      public function get measuredWidth() : Number
      {
         return Boolean(this.displayObjectTrait) ? this.displayObjectTrait.mediaWidth : NaN;
      }
      
      public function get measuredHeight() : Number
      {
         return Boolean(this.displayObjectTrait) ? this.displayObjectTrait.mediaHeight : NaN;
      }
      
      public function measure(deep:Boolean = true) : void
      {
         if(this._displayObject is ILayoutTarget)
         {
            ILayoutTarget(this._displayObject).measure(deep);
         }
      }
      
      public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true) : void
      {
         if(this._displayObject is ILayoutTarget)
         {
            ILayoutTarget(this._displayObject).layout(availableWidth,availableHeight,deep);
         }
         else if(this._displayObject != null && this.renderers.containerRenderer == null)
         {
            this._displayObject.width = availableWidth;
            this._displayObject.height = availableHeight;
         }
      }
      
      private function onMediaElementTraitsChange(event:MediaElementEvent = null) : void
      {
         var newDisplayObjectTrait:DisplayObjectTrait = null;
         if(event == null || Boolean(event) && Boolean(event.traitType == MediaTraitType.DISPLAY_OBJECT))
         {
            newDisplayObjectTrait = Boolean(event) && event.type == MediaElementEvent.TRAIT_REMOVE ? null : this._mediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
            if(newDisplayObjectTrait != this.displayObjectTrait)
            {
               if(Boolean(this.displayObjectTrait))
               {
                  this.displayObjectTrait.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE,this.onDisplayObjectTraitDisplayObjecChange);
                  this.displayObjectTrait.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.onDisplayObjectTraitMediaSizeChange);
               }
               this.displayObjectTrait = newDisplayObjectTrait;
               if(Boolean(this.displayObjectTrait))
               {
                  this.displayObjectTrait.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE,this.onDisplayObjectTraitDisplayObjecChange);
                  this.displayObjectTrait.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.onDisplayObjectTraitMediaSizeChange);
               }
               this.updateDisplayObject(Boolean(this.displayObjectTrait) ? this.displayObjectTrait.displayObject : null);
            }
         }
      }
      
      private function onMetadataAdd(event:MediaElementEvent) : void
      {
         if(event.namespaceURL == LayoutMetadata.LAYOUT_NAMESPACE)
         {
            this._layoutMetadata = event.metadata as LayoutMetadata;
         }
      }
      
      private function onMetadataRemove(event:MediaElementEvent) : void
      {
         if(event.namespaceURL == LayoutMetadata.LAYOUT_NAMESPACE)
         {
            this._layoutMetadata = null;
         }
      }
      
      private function updateDisplayObject(newDisplayObject:DisplayObject) : void
      {
         var oldDisplayObject:DisplayObject = this._displayObject;
         if(newDisplayObject != this.displayObject)
         {
            this._displayObject = newDisplayObject;
            dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE,false,false,oldDisplayObject,newDisplayObject));
         }
         if(newDisplayObject is ILayoutTarget && Boolean(this.renderers.parentRenderer))
         {
            ILayoutTarget(newDisplayObject).dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER,false,false,this.renderers.parentRenderer));
         }
      }
      
      private function onDisplayObjectTraitDisplayObjecChange(event:DisplayObjectEvent) : void
      {
         this.updateDisplayObject(event.newDisplayObject);
      }
      
      private function onDisplayObjectTraitMediaSizeChange(event:DisplayObjectEvent) : void
      {
         dispatchEvent(event.clone());
      }
      
      private function onAddChildAt(event:LayoutTargetEvent) : void
      {
         if(this._displayObject is ILayoutTarget)
         {
            ILayoutTarget(this._displayObject).dispatchEvent(event.clone());
         }
         else if(this._displayObject is DisplayObjectContainer)
         {
            DisplayObjectContainer(this._displayObject).addChildAt(event.displayObject,event.index);
         }
      }
      
      private function onRemoveChild(event:LayoutTargetEvent) : void
      {
         if(this._displayObject is ILayoutTarget)
         {
            ILayoutTarget(this._displayObject).dispatchEvent(event.clone());
         }
         else if(this._displayObject is DisplayObjectContainer)
         {
            DisplayObjectContainer(this._displayObject).removeChild(event.displayObject);
         }
      }
      
      private function onSetChildIndex(event:LayoutTargetEvent) : void
      {
         if(this._displayObject is ILayoutTarget)
         {
            ILayoutTarget(this._displayObject).dispatchEvent(event.clone());
         }
         else if(this._displayObject is DisplayObjectContainer)
         {
            DisplayObjectContainer(this._displayObject).setChildIndex(event.displayObject,event.index);
         }
      }
   }
}

class ConstructorLock
{
   
   public function ConstructorLock()
   {
      super();
   }
}
