package org.osmf.layout
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import org.osmf.events.DisplayObjectEvent;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.MetadataWatcher;
   import org.osmf.utils.OSMFStrings;
   
   public class LayoutRendererBase extends EventDispatcher
   {
      
      private static var cleaningRenderers:Boolean;
      
      private static var dispatcher:DisplayObject = new Sprite();
      
      private static var dirtyRenderers:Vector.<LayoutRendererBase> = new Vector.<LayoutRendererBase>();
      
      private var _parent:LayoutRendererBase;
      
      private var _container:ILayoutTarget;
      
      private var layoutMetadata:LayoutMetadata;
      
      private var layoutTargets:Vector.<ILayoutTarget> = new Vector.<ILayoutTarget>();
      
      private var stagedDisplayObjects:Dictionary = new Dictionary(true);
      
      private var _measuredWidth:Number;
      
      private var _measuredHeight:Number;
      
      private var dirty:Boolean;
      
      private var cleaning:Boolean;
      
      private var metaDataWatchers:Dictionary = new Dictionary();
      
      public function LayoutRendererBase()
      {
         super();
      }
      
      private static function flagDirty(renderer:LayoutRendererBase) : void
      {
         if(renderer == null || dirtyRenderers.indexOf(renderer) != -1)
         {
            return;
         }
         dirtyRenderers.push(renderer);
         if(cleaningRenderers == false)
         {
            dispatcher.addEventListener(Event.EXIT_FRAME,onExitFrame);
         }
      }
      
      private static function flagClean(renderer:LayoutRendererBase) : void
      {
         var index:Number = dirtyRenderers.indexOf(renderer);
         if(index != -1)
         {
            dirtyRenderers.splice(index,1);
         }
      }
      
      private static function onExitFrame(event:Event) : void
      {
         var renderer:LayoutRendererBase = null;
         dispatcher.removeEventListener(Event.EXIT_FRAME,onExitFrame);
         cleaningRenderers = true;
         while(dirtyRenderers.length != 0)
         {
            renderer = dirtyRenderers.shift();
            if(renderer.parent == null)
            {
               renderer.validateNow();
            }
            else
            {
               renderer.dirty = false;
            }
         }
         cleaningRenderers = false;
      }
      
      final public function get parent() : LayoutRendererBase
      {
         return this._parent;
      }
      
      final internal function setParent(value:LayoutRendererBase) : void
      {
         this._parent = value;
         this.processParentChange(this._parent);
      }
      
      final public function get container() : ILayoutTarget
      {
         return this._container;
      }
      
      final public function set container(value:ILayoutTarget) : void
      {
         var oldContainer:ILayoutTarget = null;
         if(value != this._container)
         {
            oldContainer = this._container;
            if(oldContainer != null)
            {
               this.reset();
               oldContainer.dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER,false,false,this));
               oldContainer.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.invalidatingEventHandler);
            }
            this._container = value;
            if(Boolean(this._container))
            {
               this.layoutMetadata = this._container.layoutMetadata;
               this._container.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.invalidatingEventHandler,false,0,true);
               this._container.dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER,false,false,this));
               this.invalidate();
            }
            this.processContainerChange(oldContainer,value);
         }
      }
      
      final public function addTarget(target:ILayoutTarget) : ILayoutTarget
      {
         var namespaceURL:String = null;
         var watcher:MetadataWatcher = null;
         if(target == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(this.layoutTargets.indexOf(target) != -1)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         target.dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER,false,false,this));
         var index:int = Math.abs(BinarySearch.search(this.layoutTargets,this.compareTargets,target));
         this.layoutTargets.splice(index,0,target);
         var watchers:Array = this.metaDataWatchers[target] = new Array();
         for each(namespaceURL in this.usedMetadatas)
         {
            watcher = new MetadataWatcher(target.layoutMetadata,namespaceURL,null,this.targetMetadataChangeCallback);
            watcher.watch();
            watchers.push(watcher);
         }
         target.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE,this.invalidatingEventHandler);
         target.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.invalidatingEventHandler);
         target.addEventListener(LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER,this.onTargetAddedToRenderer);
         target.addEventListener(LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER,this.onTargetSetAsContainer);
         this.invalidate();
         this.processTargetAdded(target);
         return target;
      }
      
      final public function removeTarget(target:ILayoutTarget) : ILayoutTarget
      {
         var removedTarget:ILayoutTarget = null;
         var watcher:MetadataWatcher = null;
         if(target == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         var index:Number = this.layoutTargets.indexOf(target);
         if(index != -1)
         {
            this.removeFromStage(target);
            removedTarget = this.layoutTargets.splice(index,1)[0];
            target.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE,this.invalidatingEventHandler);
            target.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.invalidatingEventHandler);
            target.removeEventListener(LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER,this.onTargetAddedToRenderer);
            target.removeEventListener(LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER,this.onTargetSetAsContainer);
            for each(watcher in this.metaDataWatchers[target])
            {
               watcher.unwatch();
            }
            delete this.metaDataWatchers[target];
            this.processTargetRemoved(target);
            target.dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.REMOVE_FROM_LAYOUT_RENDERER,false,false,this));
            this.invalidate();
            return removedTarget;
         }
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
      }
      
      final public function hasTarget(target:ILayoutTarget) : Boolean
      {
         return this.layoutTargets.indexOf(target) != -1;
      }
      
      final public function get measuredWidth() : Number
      {
         return this._measuredWidth;
      }
      
      final public function get measuredHeight() : Number
      {
         return this._measuredHeight;
      }
      
      final public function invalidate() : void
      {
         if(this.cleaning == false && this.dirty == false)
         {
            this.dirty = true;
            if(this._parent != null)
            {
               this._parent.invalidate();
            }
            else
            {
               flagDirty(this);
            }
         }
      }
      
      final public function validateNow() : void
      {
         if(this._container == null || this.cleaning == true)
         {
            return;
         }
         if(Boolean(this._parent))
         {
            this._parent.validateNow();
            return;
         }
         this.cleaning = true;
         this.measure();
         this.layout(this._measuredWidth,this._measuredHeight);
         this.cleaning = false;
      }
      
      internal function measure() : void
      {
         var target:ILayoutTarget = null;
         var size:Point = null;
         this.prepareTargets();
         for each(target in this.layoutTargets)
         {
            target.measure(true);
         }
         size = this.calculateContainerSize(this.layoutTargets);
         this._measuredWidth = size.x;
         this._measuredHeight = size.y;
         this._container.measure(false);
      }
      
      internal function layout(availableWidth:Number, availableHeight:Number) : void
      {
         var target:ILayoutTarget = null;
         var bounds:Rectangle = null;
         var displayObject:DisplayObject = null;
         this.processUpdateMediaDisplayBegin(this.layoutTargets);
         this._container.layout(availableWidth,availableHeight,false);
         for each(target in this.layoutTargets)
         {
            bounds = this.calculateTargetBounds(target,availableWidth,availableHeight);
            target.layout(bounds.width,bounds.height,true);
            displayObject = target.displayObject;
            if(Boolean(displayObject))
            {
               displayObject.x = bounds.x;
               displayObject.y = bounds.y;
            }
         }
         this.dirty = false;
         this.processUpdateMediaDisplayEnd();
      }
      
      protected function get usedMetadatas() : Vector.<String>
      {
         return new Vector.<String>();
      }
      
      protected function compareTargets(x:ILayoutTarget, y:ILayoutTarget) : Number
      {
         return 0;
      }
      
      protected function processContainerChange(oldContainer:ILayoutTarget, newContainer:ILayoutTarget) : void
      {
      }
      
      protected function processTargetAdded(target:ILayoutTarget) : void
      {
      }
      
      protected function processTargetRemoved(target:ILayoutTarget) : void
      {
      }
      
      protected function processStagedTarget(target:ILayoutTarget) : void
      {
      }
      
      protected function processUnstagedTarget(target:ILayoutTarget) : void
      {
      }
      
      protected function processUpdateMediaDisplayBegin(targets:Vector.<ILayoutTarget>) : void
      {
      }
      
      protected function processUpdateMediaDisplayEnd() : void
      {
      }
      
      protected function updateTargetOrder(target:ILayoutTarget) : void
      {
         var index:int = this.layoutTargets.indexOf(target);
         if(index != -1)
         {
            this.layoutTargets.splice(index,1);
            index = Math.abs(BinarySearch.search(this.layoutTargets,this.compareTargets,target));
            this.layoutTargets.splice(index,0,target);
         }
      }
      
      protected function calculateTargetBounds(target:ILayoutTarget, availableWidth:Number, availableHeight:Number) : Rectangle
      {
         return new Rectangle();
      }
      
      protected function calculateContainerSize(targets:Vector.<ILayoutTarget>) : Point
      {
         return new Point();
      }
      
      protected function processParentChange(value:LayoutRendererBase) : void
      {
      }
      
      private function reset() : void
      {
         var target:ILayoutTarget = null;
         for each(target in this.layoutTargets)
         {
            this.removeTarget(target);
         }
         if(Boolean(this._container))
         {
            this._container.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.invalidatingEventHandler);
            this.validateNow();
         }
         this._container = null;
         this.layoutMetadata = null;
      }
      
      private function targetMetadataChangeCallback(metadata:Metadata) : void
      {
         this.invalidate();
      }
      
      private function invalidatingEventHandler(event:Event) : void
      {
         this.invalidate();
      }
      
      private function onTargetAddedToRenderer(event:LayoutTargetEvent) : void
      {
         var target:ILayoutTarget = null;
         if(event.layoutRenderer != this)
         {
            target = event.target as ILayoutTarget;
            if(this.hasTarget(target))
            {
               this.removeTarget(target);
            }
         }
      }
      
      private function onTargetSetAsContainer(event:LayoutTargetEvent) : void
      {
         var target:ILayoutTarget = null;
         if(event.layoutRenderer != this)
         {
            target = event.target as ILayoutTarget;
            if(this.container == target)
            {
               this.container = null;
            }
         }
      }
      
      private function prepareTargets() : void
      {
         var target:ILayoutTarget = null;
         var displayObject:DisplayObject = null;
         var displayListCounter:int = 0;
         for each(target in this.layoutTargets)
         {
            displayObject = target.displayObject;
            if(Boolean(displayObject))
            {
               this.addToStage(target,target.displayObject,displayListCounter);
               displayListCounter++;
            }
            else
            {
               this.removeFromStage(target);
            }
         }
      }
      
      private function addToStage(target:ILayoutTarget, object:DisplayObject, index:Number) : void
      {
         var currentObject:DisplayObject = this.stagedDisplayObjects[target];
         if(currentObject == object)
         {
            this._container.dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.SET_CHILD_INDEX,false,false,this,target,currentObject,index));
         }
         else
         {
            if(currentObject != null)
            {
               this._container.dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.REMOVE_CHILD,false,false,this,target,currentObject));
            }
            this.stagedDisplayObjects[target] = object;
            this._container.dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.ADD_CHILD_AT,false,false,this,target,object,index));
            if(currentObject == null)
            {
               this.processStagedTarget(target);
            }
         }
      }
      
      private function removeFromStage(target:ILayoutTarget) : void
      {
         var currentObject:DisplayObject = this.stagedDisplayObjects[target];
         if(currentObject != null)
         {
            delete this.stagedDisplayObjects[target];
            this._container.dispatchEvent(new LayoutTargetEvent(LayoutTargetEvent.REMOVE_CHILD,false,false,this,target,currentObject));
         }
      }
   }
}

