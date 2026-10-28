package org.osmf.layout
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import org.osmf.metadata.MetadataWatcher;
   
   public class LayoutRenderer extends LayoutRendererBase
   {
      
      private static const X:int = 1;
      
      private static const Y:int = 2;
      
      private static const WIDTH:int = 4;
      
      private static const HEIGHT:int = 8;
      
      private static const POSITION:int = 3;
      
      private static const DIMENSIONS:int = 12;
      
      private static const ALL:int = 15;
      
      private static const USED_METADATAS:Vector.<String> = new Vector.<String>(5,true);
      
      USED_METADATAS[0] = "http://www.osmf.org/layout/absolute/1.0";
      USED_METADATAS[1] = "http://www.osmf.org/layout/relative/1.0";
      USED_METADATAS[2] = "http://www.osmf.org/layout/anchor/1.0";
      USED_METADATAS[3] = "http://www.osmf.org/layout/padding/1.0";
      USED_METADATAS[4] = "http://www.osmf.org/layout/attributes/1.0";
      
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
      
      override protected function processContainerChange(param1:ILayoutTarget, param2:ILayoutTarget) : void
      {
         var oldContainer:ILayoutTarget = param1;
         var newContainer:ILayoutTarget = param2;
         if(oldContainer)
         {
            containerAbsoluteWatcher.unwatch();
            containerAttributesWatcher.unwatch();
         }
         if(newContainer)
         {
            containerAbsoluteWatcher = new MetadataWatcher(newContainer.layoutMetadata,"http://www.osmf.org/layout/absolute/1.0",null,function(... rest):void
            {
               invalidate();
            });
            containerAbsoluteWatcher.watch();
            containerAttributesWatcher = new MetadataWatcher(newContainer.layoutMetadata,"http://www.osmf.org/layout/attributes/1.0",null,function(param1:LayoutAttributesMetadata):void
            {
               layoutMode = param1 ? param1.layoutMode : "none";
               invalidate();
            });
            containerAttributesWatcher.watch();
         }
         invalidate();
      }
      
      override protected function processUpdateMediaDisplayBegin(param1:Vector.<ILayoutTarget>) : void
      {
         lastCalculatedBounds = null;
      }
      
      override protected function processUpdateMediaDisplayEnd() : void
      {
         lastCalculatedBounds = null;
      }
      
      override protected function processTargetAdded(param1:ILayoutTarget) : void
      {
         var watcher:MetadataWatcher;
         var target:ILayoutTarget = param1;
         var attributes:LayoutAttributesMetadata = target.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata;
         var relative:RelativeLayoutMetadata = target.layoutMetadata.getValue("http://www.osmf.org/layout/relative/1.0") as RelativeLayoutMetadata;
         if(layoutMode == "none" && relative == null && attributes == null && target.layoutMetadata.getValue("http://www.osmf.org/layout/absolute/1.0") == null && target.layoutMetadata.getValue("http://www.osmf.org/layout/anchor/1.0") == null)
         {
            relative = new RelativeLayoutMetadata();
            relative.width = 100;
            relative.height = 100;
            target.layoutMetadata.addValue("http://www.osmf.org/layout/relative/1.0",relative);
            attributes = new LayoutAttributesMetadata();
            attributes.scaleMode ||= "letterbox";
            attributes.verticalAlign ||= "middle";
            attributes.horizontalAlign ||= "center";
            target.layoutMetadata.addValue("http://www.osmf.org/layout/attributes/1.0",attributes);
         }
         watcher = new MetadataWatcher(target.layoutMetadata,"http://www.osmf.org/layout/attributes/1.0","index",function(... rest):void
         {
            updateTargetOrder(target);
         });
         watcher.watch();
         targetMetadataWatchers[target] = watcher;
      }
      
      override protected function processTargetRemoved(param1:ILayoutTarget) : void
      {
         var _loc2_:MetadataWatcher = targetMetadataWatchers[param1];
         delete targetMetadataWatchers[param1];
         _loc2_.unwatch();
         _loc2_ = null;
      }
      
      override protected function compareTargets(param1:ILayoutTarget, param2:ILayoutTarget) : Number
      {
         var _loc6_:LayoutAttributesMetadata = param1.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata;
         var _loc3_:LayoutAttributesMetadata = param2.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata;
         var _loc4_:* = _loc6_ ? _loc6_.index : NaN;
         var _loc5_:* = _loc3_ ? _loc3_.index : NaN;
         if(isNaN(_loc4_) && isNaN(_loc5_))
         {
            return 1;
         }
         if(!_loc4_)
         {
            _loc4_ = 0;
         }
         if(!_loc5_)
         {
            _loc5_ = 0;
         }
         return _loc4_ < _loc5_ ? -1 : (_loc4_ > _loc5_ ? 1 : 0);
      }
      
      override protected function calculateTargetBounds(param1:ILayoutTarget, param2:Number, param3:Number) : Rectangle
      {
         var _loc7_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc14_:BoxAttributesMetadata = null;
         var _loc8_:RelativeLayoutMetadata = null;
         var _loc12_:AnchorLayoutMetadata = null;
         var _loc10_:Point = null;
         var _loc15_:LayoutAttributesMetadata = param1.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata || new LayoutAttributesMetadata();
         if(_loc15_.includeInLayout == false)
         {
            return new Rectangle();
         }
         var _loc6_:Rectangle = new Rectangle(0,0,param1.measuredWidth,param1.measuredHeight);
         var _loc11_:AbsoluteLayoutMetadata = param1.layoutMetadata.getValue("http://www.osmf.org/layout/absolute/1.0") as AbsoluteLayoutMetadata;
         var _loc13_:Number = 0;
         var _loc4_:Number = 0;
         var _loc16_:int = 15;
         if(_loc11_)
         {
            if(!isNaN(_loc11_.x))
            {
               _loc6_.x = _loc11_.x;
               _loc16_ ^= 1;
            }
            if(!isNaN(_loc11_.y))
            {
               _loc6_.y = _loc11_.y;
               _loc16_ ^= 2;
            }
            if(!isNaN(_loc11_.width))
            {
               _loc6_.width = _loc11_.width;
               _loc16_ ^= 4;
            }
            if(!isNaN(_loc11_.height))
            {
               _loc6_.height = _loc11_.height;
               _loc16_ ^= 8;
            }
         }
         if(_loc16_ != 0)
         {
            _loc8_ = param1.layoutMetadata.getValue("http://www.osmf.org/layout/relative/1.0") as RelativeLayoutMetadata;
            if(_loc8_)
            {
               if(_loc16_ & 1 && !isNaN(_loc8_.x))
               {
                  _loc6_.x = param2 * _loc8_.x / 100 || 0;
                  _loc16_ ^= 1;
               }
               if(_loc16_ & 4 && !isNaN(_loc8_.width))
               {
                  if(layoutMode == "horizontal")
                  {
                     _loc14_ = container.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/box/1.0") as BoxAttributesMetadata || new BoxAttributesMetadata();
                     _loc6_.width = Math.max(0,param2 - _loc14_.absoluteSum) * _loc8_.width / _loc14_.relativeSum;
                  }
                  else
                  {
                     _loc6_.width = param2 * _loc8_.width / 100;
                  }
                  _loc16_ ^= 4;
               }
               if(_loc16_ & 2 && !isNaN(_loc8_.y))
               {
                  _loc6_.y = param3 * _loc8_.y / 100 || 0;
                  _loc16_ ^= 2;
               }
               if(_loc16_ & 8 && !isNaN(_loc8_.height))
               {
                  if(layoutMode == "vertical")
                  {
                     _loc14_ = container.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/box/1.0") as BoxAttributesMetadata || new BoxAttributesMetadata();
                     _loc6_.height = Math.max(0,param3 - _loc14_.absoluteSum) * _loc8_.height / _loc14_.relativeSum;
                  }
                  else
                  {
                     _loc6_.height = param3 * _loc8_.height / 100;
                  }
                  _loc16_ ^= 8;
               }
            }
         }
         if(_loc16_ != 0)
         {
            _loc12_ = param1.layoutMetadata.getValue("http://www.osmf.org/layout/anchor/1.0") as AnchorLayoutMetadata;
            if(_loc12_)
            {
               if(_loc16_ & 1 && !isNaN(_loc12_.left))
               {
                  _loc6_.x = _loc12_.left;
                  _loc16_ ^= 1;
               }
               if(_loc16_ & 2 && !isNaN(_loc12_.top))
               {
                  _loc6_.y = _loc12_.top;
                  _loc16_ ^= 2;
               }
               if(!isNaN(_loc12_.right) && param2)
               {
                  if(_loc16_ & 1 && !(_loc16_ & 4))
                  {
                     _loc6_.x = Math.max(0,param2 - _loc6_.width - _loc12_.right);
                     _loc16_ ^= 1;
                  }
                  else if(_loc16_ & 4 && !(_loc16_ & 1))
                  {
                     _loc6_.width = Math.max(0,param2 - _loc12_.right - _loc6_.x);
                     _loc16_ ^= 4;
                  }
                  else
                  {
                     _loc6_.x = Math.max(0,param2 - param1.measuredWidth - _loc12_.right);
                     _loc16_ ^= 1;
                  }
                  _loc13_ += _loc12_.right;
               }
               if(!isNaN(_loc12_.bottom) && param3)
               {
                  if(_loc16_ & 2 && !(_loc16_ & 8))
                  {
                     _loc6_.y = Math.max(0,param3 - _loc6_.height - _loc12_.bottom);
                     _loc16_ ^= 2;
                  }
                  else if(_loc16_ & 8 && !(_loc16_ & 2))
                  {
                     _loc6_.height = Math.max(0,param3 - _loc12_.bottom - _loc6_.y);
                     _loc16_ ^= 8;
                  }
                  else
                  {
                     _loc6_.y = Math.max(0,param3 - param1.measuredHeight - _loc12_.bottom);
                     _loc16_ ^= 2;
                  }
                  _loc4_ += _loc12_.bottom;
               }
            }
         }
         var _loc5_:PaddingLayoutMetadata = param1.layoutMetadata.getValue("http://www.osmf.org/layout/padding/1.0") as PaddingLayoutMetadata;
         if(_loc5_)
         {
            if(!isNaN(_loc5_.left))
            {
               _loc6_.x += _loc5_.left;
            }
            if(!isNaN(_loc5_.top))
            {
               _loc6_.y += _loc5_.top;
            }
            if(!isNaN(_loc5_.right) && !(_loc16_ & 4))
            {
               _loc6_.width -= _loc5_.right + (_loc5_.left || 0);
            }
            if(!isNaN(_loc5_.bottom) && !(_loc16_ & 8))
            {
               _loc6_.height -= _loc5_.bottom + (_loc5_.top || 0);
            }
         }
         if(_loc15_.scaleMode)
         {
            if(!(_loc16_ & 4 || _loc16_ & 8) && param1.measuredWidth && param1.measuredHeight)
            {
               _loc10_ = ScaleModeUtils.getScaledSize(_loc15_.scaleMode,_loc6_.width,_loc6_.height,param1.measuredWidth,param1.measuredHeight);
               _loc7_ = _loc6_.width - _loc10_.x;
               _loc9_ = _loc6_.height - _loc10_.y;
               _loc6_.width = _loc10_.x;
               _loc6_.height = _loc10_.y;
            }
         }
         if(layoutMode != "horizontal")
         {
            if(!_loc7_)
            {
               _loc7_ = param2 - (_loc6_.x || 0) - (_loc6_.width || 0) - _loc13_;
            }
         }
         if(layoutMode != "vertical")
         {
            if(!_loc9_)
            {
               _loc9_ = param3 - (_loc6_.y || 0) - (_loc6_.height || 0) - _loc4_;
            }
         }
         if(_loc9_)
         {
            switch(_loc15_.verticalAlign)
            {
               case null:
               case "top":
                  break;
               case "middle":
                  _loc6_.y += _loc9_ / 2;
                  break;
               case "bottom":
                  _loc6_.y += _loc9_;
            }
         }
         if(_loc7_)
         {
            switch(_loc15_.horizontalAlign)
            {
               case null:
               case "left":
                  break;
               case "center":
                  _loc6_.x += _loc7_ / 2;
                  break;
               case "right":
                  _loc6_.x += _loc7_;
            }
         }
         if(_loc15_.snapToPixel)
         {
            _loc6_.x = Math.round(_loc6_.x);
            _loc6_.y = Math.round(_loc6_.y);
            _loc6_.width = Math.round(_loc6_.width);
            _loc6_.height = Math.round(_loc6_.height);
         }
         if(layoutMode == "horizontal" || layoutMode == "vertical")
         {
            if(lastCalculatedBounds != null)
            {
               if(layoutMode == "horizontal")
               {
                  _loc6_.x = lastCalculatedBounds.x + lastCalculatedBounds.width;
               }
               else
               {
                  _loc6_.y = lastCalculatedBounds.y + lastCalculatedBounds.height;
               }
            }
            lastCalculatedBounds = _loc6_;
         }
         return _loc6_;
      }
      
      override protected function calculateContainerSize(param1:Vector.<ILayoutTarget>) : Point
      {
         var _loc5_:BoxAttributesMetadata = null;
         var _loc7_:Rectangle = null;
         var _loc6_:Rectangle = null;
         var _loc3_:Rectangle = null;
         var _loc8_:Point = new Point(NaN,NaN);
         var _loc2_:AbsoluteLayoutMetadata = container.layoutMetadata.getValue("http://www.osmf.org/layout/absolute/1.0") as AbsoluteLayoutMetadata;
         if(_loc2_)
         {
            _loc8_.x = _loc2_.width;
            _loc8_.y = _loc2_.height;
         }
         if(layoutMode != "none")
         {
            _loc5_ = new BoxAttributesMetadata();
            container.layoutMetadata.addValue("http://www.osmf.org/layout/attributes/box/1.0",_loc5_);
         }
         if(isNaN(_loc8_.x) || isNaN(_loc8_.y) || layoutMode != "none")
         {
            _loc7_ = new Rectangle();
            for each(var _loc4_:ILayoutTarget in param1)
            {
               if(_loc4_.layoutMetadata.includeInLayout)
               {
                  _loc6_ = calculateTargetBounds(_loc4_,_loc8_.x,_loc8_.y);
                  _loc6_.x ||= 0;
                  _loc6_.y ||= 0;
                  _loc6_.width ||= _loc4_.measuredWidth || 0;
                  _loc6_.height ||= _loc4_.measuredHeight || 0;
                  if(layoutMode == "horizontal")
                  {
                     if(!isNaN(_loc4_.layoutMetadata.percentWidth))
                     {
                        _loc5_.relativeSum += _loc4_.layoutMetadata.percentWidth;
                     }
                     else
                     {
                        _loc5_.absoluteSum += _loc6_.width;
                     }
                     if(_loc3_)
                     {
                        _loc6_.x = _loc3_.x + _loc3_.width;
                     }
                     _loc3_ = _loc6_;
                  }
                  else if(layoutMode == "vertical")
                  {
                     if(!isNaN(_loc4_.layoutMetadata.percentHeight))
                     {
                        _loc5_.relativeSum += _loc4_.layoutMetadata.percentHeight;
                     }
                     else
                     {
                        _loc5_.absoluteSum += _loc6_.height;
                     }
                     if(_loc3_)
                     {
                        _loc6_.y = _loc3_.y + _loc3_.height;
                     }
                     _loc3_ = _loc6_;
                  }
                  _loc7_ = _loc7_.union(_loc6_);
               }
            }
            _loc8_.x ||= _loc2_ == null || isNaN(_loc2_.width) ? _loc7_.width : _loc2_.width;
            _loc8_.y ||= _loc2_ == null || isNaN(_loc2_.height) ? _loc7_.height : _loc2_.height;
         }
         return _loc8_;
      }
   }
}

