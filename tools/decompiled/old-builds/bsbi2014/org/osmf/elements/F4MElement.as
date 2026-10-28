package org.osmf.elements
{
   import org.osmf.media.URLResource;
   
   public class F4MElement extends LoadFromDocumentElement
   {
      
      public function F4MElement(resource:URLResource = null, loader:F4MLoader = null)
      {
         if(loader == null)
         {
            loader = new F4MLoader();
         }
         super(resource,loader);
      }
   }
}

