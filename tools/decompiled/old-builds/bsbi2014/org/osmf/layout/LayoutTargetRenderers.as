package org.osmf.layout
{
   internal class LayoutTargetRenderers
   {
      
      public var containerRenderer:LayoutRendererBase;
      
      public var parentRenderer:LayoutRendererBase;
      
      public function LayoutTargetRenderers(target:ILayoutTarget)
      {
         super();
         target.addEventListener(LayoutTargetEvent.ADD_TO_LAYOUT_RENDERER,this.onAddedToLayoutRenderer);
         target.addEventListener(LayoutTargetEvent.REMOVE_FROM_LAYOUT_RENDERER,this.onRemovedFromLayoutRenderer);
         target.addEventListener(LayoutTargetEvent.SET_AS_LAYOUT_RENDERER_CONTAINER,this.onSetAsLayoutRendererContainer);
         target.addEventListener(LayoutTargetEvent.UNSET_AS_LAYOUT_RENDERER_CONTAINER,this.onUnsetAsLayoutRendererContainer);
      }
      
      private function onSetAsLayoutRendererContainer(event:LayoutTargetEvent) : void
      {
         if(this.containerRenderer != event.layoutRenderer)
         {
            this.containerRenderer = event.layoutRenderer;
            this.containerRenderer.setParent(this.parentRenderer);
         }
      }
      
      private function onUnsetAsLayoutRendererContainer(event:LayoutTargetEvent) : void
      {
         if(this.containerRenderer != null && this.containerRenderer == event.layoutRenderer)
         {
            this.containerRenderer.setParent(null);
            this.containerRenderer = null;
         }
      }
      
      private function onAddedToLayoutRenderer(event:LayoutTargetEvent) : void
      {
         if(this.parentRenderer != event.layoutRenderer)
         {
            this.parentRenderer = event.layoutRenderer;
            if(Boolean(this.containerRenderer))
            {
               this.containerRenderer.setParent(this.parentRenderer);
            }
         }
      }
      
      private function onRemovedFromLayoutRenderer(event:LayoutTargetEvent) : void
      {
         if(this.parentRenderer == event.layoutRenderer)
         {
            this.parentRenderer = null;
            if(Boolean(this.containerRenderer))
            {
               this.containerRenderer.setParent(null);
            }
         }
      }
   }
}

