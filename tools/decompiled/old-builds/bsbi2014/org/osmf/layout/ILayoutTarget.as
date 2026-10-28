package org.osmf.layout
{
   import flash.display.DisplayObject;
   import flash.events.IEventDispatcher;
   
   [Event(name="removeChild",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="setChildIndex",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="addChildAt",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="removeFromLayoutRenderer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="addToLayoutRenderer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="unsetAsLayoutRendererContainer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="setAsLayoutRendererContainer",type="org.osmf.layout.LayoutTargetEvent")]
   [Event(name="mediaSizeChange",type="org.osmf.events.DisplayObjectEvent")]
   [Event(name="displayObjectChange",type="org.osmf.events.DisplayObjectEvent")]
   public interface ILayoutTarget extends IEventDispatcher
   {
      
      function get displayObject() : DisplayObject;
      
      function get layoutMetadata() : LayoutMetadata;
      
      function get measuredWidth() : Number;
      
      function get measuredHeight() : Number;
      
      function measure(param1:Boolean = true) : void;
      
      function layout(param1:Number, param2:Number, param3:Boolean = true) : void;
   }
}

