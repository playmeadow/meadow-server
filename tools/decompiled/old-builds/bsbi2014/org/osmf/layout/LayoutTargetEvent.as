package org.osmf.layout
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LayoutTargetEvent extends Event
   {
      
      public static const SET_AS_LAYOUT_RENDERER_CONTAINER:String = "setAsLayoutRendererContainer";
      
      public static const UNSET_AS_LAYOUT_RENDERER_CONTAINER:String = "unsetAsLayoutRendererContainer";
      
      public static const ADD_TO_LAYOUT_RENDERER:String = "addToLayoutRenderer";
      
      public static const REMOVE_FROM_LAYOUT_RENDERER:String = "removeFromLayoutRenderer";
      
      public static const ADD_CHILD_AT:String = "addChildAt";
      
      public static const REMOVE_CHILD:String = "removeChild";
      
      public static const SET_CHILD_INDEX:String = "setChildIndex";
      
      private var _layoutRenderer:LayoutRendererBase;
      
      private var _layoutTarget:ILayoutTarget;
      
      private var _displayObject:DisplayObject;
      
      private var _index:int;
      
      public function LayoutTargetEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, layoutRenderer:LayoutRendererBase = null, layoutTarget:ILayoutTarget = null, displayObject:DisplayObject = null, index:int = -1)
      {
         this._layoutRenderer = layoutRenderer;
         this._layoutTarget = layoutTarget;
         this._displayObject = displayObject;
         this._index = index;
         super(type,bubbles,cancelable);
      }
      
      public function get layoutRenderer() : LayoutRendererBase
      {
         return this._layoutRenderer;
      }
      
      public function get layoutTarget() : ILayoutTarget
      {
         return this._layoutTarget;
      }
      
      public function get displayObject() : DisplayObject
      {
         return this._displayObject;
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      override public function clone() : Event
      {
         return new LayoutTargetEvent(type,bubbles,cancelable,this._layoutRenderer,this._layoutTarget,this._displayObject,this._index);
      }
   }
}

