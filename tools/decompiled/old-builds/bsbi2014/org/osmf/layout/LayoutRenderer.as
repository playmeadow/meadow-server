package org.osmf.layout
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import org.osmf.metadata.MetadataNamespaces;
   import org.osmf.metadata.MetadataWatcher;
   
   public class LayoutRenderer extends LayoutRendererBase
   {
      
      private static const USED_METADATAS:Vector.<String> = new Vector.<String>(5,true);
      
      private static const X:int = 1;
      
      private static const Y:int = 2;
      
      private static const WIDTH:int = 4;
      
      private static const HEIGHT:int = 8;
      
      private static const POSITION:int = X + Y;
      
      private static const DIMENSIONS:int = WIDTH + HEIGHT;
      
      private static const ALL:int = POSITION + DIMENSIONS;
      
      USED_METADATAS[0] = MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS;
      USED_METADATAS[1] = MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS;
      USED_METADATAS[2] = MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS;
      USED_METADATAS[3] = MetadataNamespaces.PADDING_LAYOUT_PARAMETERS;
      USED_METADATAS[4] = MetadataNamespaces.LAYOUT_ATTRIBUTES;
      
      private var layoutMode:String = "none";
      
      private var lastCalculatedBounds:Rectangle;
      
      private var targetMetadataWatchers:Dictionary = new Dictionary();
      
      private var containerAbsoluteWatcher:MetadataWatcher;
      
      private var containerAttributesWatcher:MetadataWatcher;
      
      public function LayoutRenderer()
      {
         super();
      }
      
      override protected function get usedMetadatas() : Vector.<String>
      {
         return USED_METADATAS;
      }
      
      override protected function processContainerChange(oldContainer:ILayoutTarget, newContainer:ILayoutTarget) : void
      {
         if(Boolean(oldContainer))
         {
            this.containerAbsoluteWatcher.unwatch();
            this.containerAttributesWatcher.unwatch();
         }
         if(Boolean(newContainer))
         {
            this.containerAbsoluteWatcher = new MetadataWatcher(newContainer.layoutMetadata,MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS,null,function(... _):void
            {
               invalidate();
            });
            this.containerAbsoluteWatcher.watch();
            this.containerAttributesWatcher = new MetadataWatcher(newContainer.layoutMetadata,MetadataNamespaces.LAYOUT_ATTRIBUTES,null,function(facet:LayoutAttributesMetadata):void
            {
               layoutMode = Boolean(facet) ? facet.layoutMode : LayoutMode.NONE;
               invalidate();
            });
            this.containerAttributesWatcher.watch();
         }
         invalidate();
      }
      
      override protected function processUpdateMediaDisplayBegin(targets:Vector.<ILayoutTarget>) : void
      {
         this.lastCalculatedBounds = null;
      }
      
      override protected function processUpdateMediaDisplayEnd() : void
      {
         this.lastCalculatedBounds = null;
      }
      
      override protected function processTargetAdded(target:ILayoutTarget) : void
      {
         var watcher:MetadataWatcher;
         var attributes:LayoutAttributesMetadata = target.layoutMetadata.getValue(MetadataNamespaces.LAYOUT_ATTRIBUTES) as LayoutAttributesMetadata;
         var relative:RelativeLayoutMetadata = target.layoutMetadata.getValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS) as RelativeLayoutMetadata;
         if(this.layoutMode == LayoutMode.NONE && relative == null && attributes == null && target.layoutMetadata.getValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS) == null && target.layoutMetadata.getValue(MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS) == null)
         {
            relative = new RelativeLayoutMetadata();
            relative.width = 100;
            relative.height = 100;
            target.layoutMetadata.addValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS,relative);
            attributes = new LayoutAttributesMetadata();
            attributes.scaleMode = attributes.scaleMode || ScaleMode.LETTERBOX;
            attributes.verticalAlign = attributes.verticalAlign || VerticalAlign.MIDDLE;
            attributes.horizontalAlign = attributes.horizontalAlign || HorizontalAlign.CENTER;
            target.layoutMetadata.addValue(MetadataNamespaces.LAYOUT_ATTRIBUTES,attributes);
         }
         watcher = new MetadataWatcher(target.layoutMetadata,MetadataNamespaces.LAYOUT_ATTRIBUTES,LayoutAttributesMetadata.INDEX,function(... _):void
         {
            updateTargetOrder(target);
         });
         watcher.watch();
         this.targetMetadataWatchers[target] = watcher;
      }
      
      override protected function processTargetRemoved(target:ILayoutTarget) : void
      {
         var watcher:MetadataWatcher = this.targetMetadataWatchers[target];
         delete this.targetMetadataWatchers[target];
         watcher.unwatch();
         watcher = null;
      }
      
      override protected function compareTargets(x:ILayoutTarget, y:ILayoutTarget) : Number
      {
         var attributesX:LayoutAttributesMetadata = x.layoutMetadata.getValue(MetadataNamespaces.LAYOUT_ATTRIBUTES) as LayoutAttributesMetadata;
         var attributesY:LayoutAttributesMetadata = y.layoutMetadata.getValue(MetadataNamespaces.LAYOUT_ATTRIBUTES) as LayoutAttributesMetadata;
         var indexX:Number = Boolean(attributesX) ? attributesX.index : NaN;
         var indexY:Number = Boolean(attributesY) ? attributesY.index : NaN;
         if(isNaN(indexX) && isNaN(indexY))
         {
            return 1;
         }
         indexX ||= 0;
         indexY ||= 0;
         return indexX < indexY ? -1 : (indexX > indexY ? 1 : 0);
      }
      
      override protected function calculateTargetBounds(target:ILayoutTarget, availableWidth:Number, availableHeight:Number) : Rectangle
      {
         var deltaX:Number = NaN;
         var deltaY:Number = NaN;
         var box:BoxAttributesMetadata = null;
         var relative:RelativeLayoutMetadata = null;
         var anchors:AnchorLayoutMetadata = null;
         var size:Point = null;
         var attributes:LayoutAttributesMetadata = target.layoutMetadata.getValue(MetadataNamespaces.LAYOUT_ATTRIBUTES) as LayoutAttributesMetadata || new LayoutAttributesMetadata();
         if(attributes.includeInLayout == false)
         {
            return new Rectangle();
         }
         var rect:Rectangle = new Rectangle(0,0,target.measuredWidth,target.measuredHeight);
         var absolute:AbsoluteLayoutMetadata = target.layoutMetadata.getValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS) as AbsoluteLayoutMetadata;
         var deltaXExclude:Number = 0;
         var deltaYExclude:Number = 0;
         var toDo:int = ALL;
         if(Boolean(absolute))
         {
            if(!isNaN(absolute.x))
            {
               rect.x = absolute.x;
               toDo ^= X;
            }
            if(!isNaN(absolute.y))
            {
               rect.y = absolute.y;
               toDo ^= Y;
            }
            if(!isNaN(absolute.width))
            {
               rect.width = absolute.width;
               toDo ^= WIDTH;
            }
            if(!isNaN(absolute.height))
            {
               rect.height = absolute.height;
               toDo ^= HEIGHT;
            }
         }
         if(toDo != 0)
         {
            relative = target.layoutMetadata.getValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS) as RelativeLayoutMetadata;
            if(Boolean(relative))
            {
               if(Boolean(toDo & X) && !isNaN(relative.x))
               {
                  rect.x = availableWidth * relative.x / 100 || 0;
                  toDo ^= X;
               }
               if(Boolean(toDo & WIDTH) && !isNaN(relative.width))
               {
                  if(this.layoutMode == LayoutMode.HORIZONTAL)
                  {
                     box = container.layoutMetadata.getValue(MetadataNamespaces.BOX_LAYOUT_ATTRIBUTES) as BoxAttributesMetadata || new BoxAttributesMetadata();
                     rect.width = Math.max(0,availableWidth - box.absoluteSum) * relative.width / box.relativeSum;
                  }
                  else
                  {
                     rect.width = availableWidth * relative.width / 100;
                  }
                  toDo ^= WIDTH;
               }
               if(Boolean(toDo & Y) && !isNaN(relative.y))
               {
                  rect.y = availableHeight * relative.y / 100 || 0;
                  toDo ^= Y;
               }
               if(Boolean(toDo & HEIGHT) && !isNaN(relative.height))
               {
                  if(this.layoutMode == LayoutMode.VERTICAL)
                  {
                     box = container.layoutMetadata.getValue(MetadataNamespaces.BOX_LAYOUT_ATTRIBUTES) as BoxAttributesMetadata || new BoxAttributesMetadata();
                     rect.height = Math.max(0,availableHeight - box.absoluteSum) * relative.height / box.relativeSum;
                  }
                  else
                  {
                     rect.height = availableHeight * relative.height / 100;
                  }
                  toDo ^= HEIGHT;
               }
            }
         }
         if(toDo != 0)
         {
            anchors = target.layoutMetadata.getValue(MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS) as AnchorLayoutMetadata;
            if(Boolean(anchors))
            {
               if(Boolean(toDo & X) && !isNaN(anchors.left))
               {
                  rect.x = anchors.left;
                  toDo ^= X;
               }
               if(Boolean(toDo & Y) && !isNaN(anchors.top))
               {
                  rect.y = anchors.top;
                  toDo ^= Y;
               }
               if(!isNaN(anchors.right) && Boolean(availableWidth))
               {
                  if(Boolean(toDo & X) && !(toDo & WIDTH))
                  {
                     rect.x = Math.max(0,availableWidth - rect.width - anchors.right);
                     toDo ^= X;
                  }
                  else if(Boolean(toDo & WIDTH) && !(toDo & X))
                  {
                     rect.width = Math.max(0,availableWidth - anchors.right - rect.x);
                     toDo ^= WIDTH;
                  }
                  else
                  {
                     rect.x = Math.max(0,availableWidth - target.measuredWidth - anchors.right);
                     toDo ^= X;
                  }
                  deltaXExclude += anchors.right;
               }
               if(!isNaN(anchors.bottom) && Boolean(availableHeight))
               {
                  if(Boolean(toDo & Y) && !(toDo & HEIGHT))
                  {
                     rect.y = Math.max(0,availableHeight - rect.height - anchors.bottom);
                     toDo ^= Y;
                  }
                  else if(Boolean(toDo & HEIGHT) && !(toDo & Y))
                  {
                     rect.height = Math.max(0,availableHeight - anchors.bottom - rect.y);
                     toDo ^= HEIGHT;
                  }
                  else
                  {
                     rect.y = Math.max(0,availableHeight - target.measuredHeight - anchors.bottom);
                     toDo ^= Y;
                  }
                  deltaYExclude += anchors.bottom;
               }
            }
         }
         var padding:PaddingLayoutMetadata = target.layoutMetadata.getValue(MetadataNamespaces.PADDING_LAYOUT_PARAMETERS) as PaddingLayoutMetadata;
         if(Boolean(padding))
         {
            if(!isNaN(padding.left))
            {
               rect.x += padding.left;
            }
            if(!isNaN(padding.top))
            {
               rect.y += padding.top;
            }
            if(!isNaN(padding.right) && !(toDo & WIDTH))
            {
               rect.width -= padding.right + (padding.left || 0);
            }
            if(!isNaN(padding.bottom) && !(toDo & HEIGHT))
            {
               rect.height -= padding.bottom + (padding.top || 0);
            }
         }
         if(Boolean(attributes.scaleMode))
         {
            if(Boolean(!(toDo & WIDTH || toDo & HEIGHT)) && Boolean(target.measuredWidth) && Boolean(target.measuredHeight))
            {
               size = ScaleModeUtils.getScaledSize(attributes.scaleMode,rect.width,rect.height,target.measuredWidth,target.measuredHeight);
               deltaX = rect.width - size.x;
               deltaY = rect.height - size.y;
               rect.width = size.x;
               rect.height = size.y;
            }
         }
         if(this.layoutMode != LayoutMode.HORIZONTAL)
         {
            deltaX ||= availableWidth - (rect.x || 0) - (rect.width || 0) - deltaXExclude;
         }
         if(this.layoutMode != LayoutMode.VERTICAL)
         {
            deltaY ||= availableHeight - (rect.y || 0) - (rect.height || 0) - deltaYExclude;
         }
         if(Boolean(deltaY))
         {
            switch(attributes.verticalAlign)
            {
               case null:
               case VerticalAlign.TOP:
                  break;
               case VerticalAlign.MIDDLE:
                  rect.y += deltaY / 2;
                  break;
               case VerticalAlign.BOTTOM:
                  rect.y += deltaY;
            }
         }
         if(Boolean(deltaX))
         {
            switch(attributes.horizontalAlign)
            {
               case null:
               case HorizontalAlign.LEFT:
                  break;
               case HorizontalAlign.CENTER:
                  rect.x += deltaX / 2;
                  break;
               case HorizontalAlign.RIGHT:
                  rect.x += deltaX;
            }
         }
         if(attributes.snapToPixel)
         {
            rect.x = Math.round(rect.x);
            rect.y = Math.round(rect.y);
            rect.width = Math.round(rect.width);
            rect.height = Math.round(rect.height);
         }
         if(this.layoutMode == LayoutMode.HORIZONTAL || this.layoutMode == LayoutMode.VERTICAL)
         {
            if(this.lastCalculatedBounds != null)
            {
               if(this.layoutMode == LayoutMode.HORIZONTAL)
               {
                  rect.x = this.lastCalculatedBounds.x + this.lastCalculatedBounds.width;
               }
               else
               {
                  rect.y = this.lastCalculatedBounds.y + this.lastCalculatedBounds.height;
               }
            }
            this.lastCalculatedBounds = rect;
         }
         return rect;
      }
      
      override protected function calculateContainerSize(targets:Vector.<ILayoutTarget>) : Point
      {
         var boxAttributes:BoxAttributesMetadata = null;
         var containerBounds:Rectangle = null;
         var targetBounds:Rectangle = null;
         var lastBounds:Rectangle = null;
         var target:ILayoutTarget = null;
         var size:Point = new Point(NaN,NaN);
         var absolute:AbsoluteLayoutMetadata = container.layoutMetadata.getValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS) as AbsoluteLayoutMetadata;
         if(Boolean(absolute))
         {
            size.x = absolute.width;
            size.y = absolute.height;
         }
         if(this.layoutMode != LayoutMode.NONE)
         {
            boxAttributes = new BoxAttributesMetadata();
            container.layoutMetadata.addValue(MetadataNamespaces.BOX_LAYOUT_ATTRIBUTES,boxAttributes);
         }
         if(isNaN(size.x) || isNaN(size.y) || this.layoutMode != LayoutMode.NONE)
         {
            containerBounds = new Rectangle();
            for each(target in targets)
            {
               if(target.layoutMetadata.includeInLayout)
               {
                  targetBounds = this.calculateTargetBounds(target,size.x,size.y);
                  targetBounds.x = targetBounds.x || 0;
                  targetBounds.y = targetBounds.y || 0;
                  targetBounds.width = targetBounds.width || (target.measuredWidth || 0);
                  targetBounds.height = targetBounds.height || (target.measuredHeight || 0);
                  if(this.layoutMode == LayoutMode.HORIZONTAL)
                  {
                     if(!isNaN(target.layoutMetadata.percentWidth))
                     {
                        boxAttributes.relativeSum += target.layoutMetadata.percentWidth;
                     }
                     else
                     {
                        boxAttributes.absoluteSum += targetBounds.width;
                     }
                     if(Boolean(lastBounds))
                     {
                        targetBounds.x = lastBounds.x + lastBounds.width;
                     }
                     lastBounds = targetBounds;
                  }
                  else if(this.layoutMode == LayoutMode.VERTICAL)
                  {
                     if(!isNaN(target.layoutMetadata.percentHeight))
                     {
                        boxAttributes.relativeSum += target.layoutMetadata.percentHeight;
                     }
                     else
                     {
                        boxAttributes.absoluteSum += targetBounds.height;
                     }
                     if(Boolean(lastBounds))
                     {
                        targetBounds.y = lastBounds.y + lastBounds.height;
                     }
                     lastBounds = targetBounds;
                  }
                  containerBounds = containerBounds.union(targetBounds);
               }
            }
            size.x = size.x || (absolute == null || isNaN(absolute.width) ? containerBounds.width : absolute.width);
            size.y = size.y || (absolute == null || isNaN(absolute.height) ? containerBounds.height : absolute.height);
         }
         return size;
      }
   }
}

