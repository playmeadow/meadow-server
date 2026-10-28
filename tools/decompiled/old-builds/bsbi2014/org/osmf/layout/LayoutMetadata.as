package org.osmf.layout
{
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.MetadataNamespaces;
   import org.osmf.metadata.MetadataSynthesizer;
   import org.osmf.metadata.NullMetadataSynthesizer;
   
   public class LayoutMetadata extends Metadata
   {
      
      public static const LAYOUT_NAMESPACE:String = "http://www.osmf.org/layout/1.0";
      
      private const SYNTHESIZER:NullMetadataSynthesizer = new NullMetadataSynthesizer();
      
      public function LayoutMetadata()
      {
         super();
      }
      
      public function get index() : Number
      {
         return Boolean(this.lazyAttributes) ? this.lazyAttributes.index : NaN;
      }
      
      public function set index(value:Number) : void
      {
         this.eagerAttributes.index = value;
      }
      
      public function get scaleMode() : String
      {
         return Boolean(this.lazyAttributes) ? this.lazyAttributes.scaleMode : null;
      }
      
      public function set scaleMode(value:String) : void
      {
         this.eagerAttributes.scaleMode = value;
      }
      
      public function get horizontalAlign() : String
      {
         return Boolean(this.lazyAttributes) ? this.lazyAttributes.horizontalAlign : null;
      }
      
      public function set horizontalAlign(value:String) : void
      {
         this.eagerAttributes.horizontalAlign = value;
      }
      
      public function get verticalAlign() : String
      {
         return Boolean(this.lazyAttributes) ? this.lazyAttributes.verticalAlign : null;
      }
      
      public function set verticalAlign(value:String) : void
      {
         this.eagerAttributes.verticalAlign = value;
      }
      
      public function get snapToPixel() : Boolean
      {
         return Boolean(this.lazyAttributes) ? this.lazyAttributes.snapToPixel : true;
      }
      
      public function set snapToPixel(value:Boolean) : void
      {
         this.eagerAttributes.snapToPixel = value;
      }
      
      public function get layoutMode() : String
      {
         return Boolean(this.lazyAttributes) ? this.lazyAttributes.layoutMode : LayoutMode.NONE;
      }
      
      public function set layoutMode(value:String) : void
      {
         this.eagerAttributes.layoutMode = value;
      }
      
      public function get includeInLayout() : Boolean
      {
         return Boolean(this.lazyAttributes) ? this.lazyAttributes.includeInLayout : true;
      }
      
      public function set includeInLayout(value:Boolean) : void
      {
         this.eagerAttributes.includeInLayout = value;
      }
      
      public function get x() : Number
      {
         return Boolean(this.lazyAbsolute) ? this.lazyAbsolute.x : NaN;
      }
      
      public function set x(value:Number) : void
      {
         this.eagerAbsolute.x = value;
      }
      
      public function get y() : Number
      {
         return Boolean(this.lazyAbsolute) ? this.lazyAbsolute.y : NaN;
      }
      
      public function set y(value:Number) : void
      {
         this.eagerAbsolute.y = value;
      }
      
      public function get width() : Number
      {
         return Boolean(this.lazyAbsolute) ? this.lazyAbsolute.width : NaN;
      }
      
      public function set width(value:Number) : void
      {
         this.eagerAbsolute.width = value;
      }
      
      public function get height() : Number
      {
         return Boolean(this.lazyAbsolute) ? this.lazyAbsolute.height : NaN;
      }
      
      public function set height(value:Number) : void
      {
         this.eagerAbsolute.height = value;
      }
      
      public function get percentX() : Number
      {
         return Boolean(this.lazyRelative) ? this.lazyRelative.x : NaN;
      }
      
      public function set percentX(value:Number) : void
      {
         this.eagerRelative.x = value;
      }
      
      public function get percentY() : Number
      {
         return Boolean(this.lazyRelative) ? this.lazyRelative.y : NaN;
      }
      
      public function set percentY(value:Number) : void
      {
         this.eagerRelative.y = value;
      }
      
      public function get percentWidth() : Number
      {
         return Boolean(this.lazyRelative) ? this.lazyRelative.width : NaN;
      }
      
      public function set percentWidth(value:Number) : void
      {
         this.eagerRelative.width = value;
      }
      
      public function get percentHeight() : Number
      {
         return Boolean(this.lazyRelative) ? this.lazyRelative.height : NaN;
      }
      
      public function set percentHeight(value:Number) : void
      {
         this.eagerRelative.height = value;
      }
      
      public function get left() : Number
      {
         return Boolean(this.lazyAnchor) ? this.lazyAnchor.left : NaN;
      }
      
      public function set left(value:Number) : void
      {
         this.eagerAnchor.left = value;
      }
      
      public function get top() : Number
      {
         return Boolean(this.lazyAnchor) ? this.lazyAnchor.top : NaN;
      }
      
      public function set top(value:Number) : void
      {
         this.eagerAnchor.top = value;
      }
      
      public function get right() : Number
      {
         return Boolean(this.lazyAnchor) ? this.lazyAnchor.right : NaN;
      }
      
      public function set right(value:Number) : void
      {
         this.eagerAnchor.right = value;
      }
      
      public function get bottom() : Number
      {
         return Boolean(this.lazyAnchor) ? this.lazyAnchor.bottom : NaN;
      }
      
      public function set bottom(value:Number) : void
      {
         this.eagerAnchor.bottom = value;
      }
      
      public function get paddingLeft() : Number
      {
         return Boolean(this.lazyPadding) ? this.lazyPadding.left : NaN;
      }
      
      public function set paddingLeft(value:Number) : void
      {
         this.eagerPadding.left = value;
      }
      
      public function get paddingTop() : Number
      {
         return Boolean(this.lazyPadding) ? this.lazyPadding.top : NaN;
      }
      
      public function set paddingTop(value:Number) : void
      {
         this.eagerPadding.top = value;
      }
      
      public function get paddingRight() : Number
      {
         return Boolean(this.lazyPadding) ? this.lazyPadding.right : NaN;
      }
      
      public function set paddingRight(value:Number) : void
      {
         this.eagerPadding.right = value;
      }
      
      public function get paddingBottom() : Number
      {
         return Boolean(this.lazyPadding) ? this.lazyPadding.bottom : NaN;
      }
      
      public function set paddingBottom(value:Number) : void
      {
         this.eagerPadding.bottom = value;
      }
      
      override public function toString() : String
      {
         return "abs [" + this.x + ", " + this.y + ", " + this.width + ", " + this.height + "] " + "rel [" + this.percentX + ", " + this.percentY + ", " + this.percentWidth + ", " + this.percentHeight + "] " + "anch (" + this.left + ", " + this.top + ")(" + this.right + ", " + this.bottom + ") " + "pad [" + this.paddingLeft + ", " + this.paddingTop + ", " + this.paddingRight + ", " + this.paddingBottom + "] " + "layoutMode: " + this.layoutMode + " " + "index: " + this.index + " " + "scale: " + this.scaleMode + " " + "valign: " + this.verticalAlign + " " + "halign: " + this.horizontalAlign + " " + "snap: " + this.snapToPixel;
      }
      
      override public function get synthesizer() : MetadataSynthesizer
      {
         return this.SYNTHESIZER;
      }
      
      private function get lazyAttributes() : LayoutAttributesMetadata
      {
         return getValue(MetadataNamespaces.LAYOUT_ATTRIBUTES) as LayoutAttributesMetadata;
      }
      
      private function get eagerAttributes() : LayoutAttributesMetadata
      {
         var result:LayoutAttributesMetadata = this.lazyAttributes;
         if(result == null)
         {
            result = new LayoutAttributesMetadata();
            addValue(MetadataNamespaces.LAYOUT_ATTRIBUTES,result);
         }
         return result;
      }
      
      private function get lazyAbsolute() : AbsoluteLayoutMetadata
      {
         return getValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS) as AbsoluteLayoutMetadata;
      }
      
      private function get eagerAbsolute() : AbsoluteLayoutMetadata
      {
         var result:AbsoluteLayoutMetadata = this.lazyAbsolute;
         if(result == null)
         {
            result = new AbsoluteLayoutMetadata();
            addValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS,result);
         }
         return result;
      }
      
      private function get lazyRelative() : RelativeLayoutMetadata
      {
         return getValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS) as RelativeLayoutMetadata;
      }
      
      private function get eagerRelative() : RelativeLayoutMetadata
      {
         var result:RelativeLayoutMetadata = this.lazyRelative;
         if(result == null)
         {
            result = new RelativeLayoutMetadata();
            addValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS,result);
         }
         return result;
      }
      
      private function get lazyAnchor() : AnchorLayoutMetadata
      {
         return getValue(MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS) as AnchorLayoutMetadata;
      }
      
      private function get eagerAnchor() : AnchorLayoutMetadata
      {
         var result:AnchorLayoutMetadata = this.lazyAnchor;
         if(result == null)
         {
            result = new AnchorLayoutMetadata();
            addValue(MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS,result);
         }
         return result;
      }
      
      private function get lazyPadding() : PaddingLayoutMetadata
      {
         return getValue(MetadataNamespaces.PADDING_LAYOUT_PARAMETERS) as PaddingLayoutMetadata;
      }
      
      private function get eagerPadding() : PaddingLayoutMetadata
      {
         var result:PaddingLayoutMetadata = this.lazyPadding;
         if(result == null)
         {
            result = new PaddingLayoutMetadata();
            addValue(MetadataNamespaces.PADDING_LAYOUT_PARAMETERS,result);
         }
         return result;
      }
   }
}

