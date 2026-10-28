package gui
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class GuiHelpTextBubble extends MovieClip
   {
      
      public var soundBtn:MovieClip;
      
      public var txt:TextField;
      
      public var tl:MovieClip;
      
      public var tr:MovieClip;
      
      public var bl:MovieClip;
      
      public var bl2:MovieClip;
      
      public var br:MovieClip;
      
      public var bubble:MovieClip;
      
      public var helpBubbleBG:MovieClip = null;
      
      public var helpBubble:MovieClip = null;
      
      public function GuiHelpTextBubble()
      {
         super();
         this.soundBtn = this["soundBtn"];
         this.txt = this["txt"];
         this.tl = this["tl"];
         this.tr = this["tr"];
         this.bl = this["bl"];
         this.bl2 = this["bl2"];
         this.br = this["br"];
         this.bubble = this["bubble"];
         if(!this.soundBtn)
         {
            throw new Error("GuiHelpTextBubble MAIN BUTTONS is missing part or they are named incorrectly!");
         }
         if(!(Boolean(this.tl) && Boolean(this.tr) && Boolean(this.bl) && Boolean(this.bl2) && Boolean(this.br) && Boolean(this.bubble)))
         {
            throw new Error("GuiHelpTextBubble MAIN CONTENTS section is missing parts or they are named incorrectly!");
         }
         if(!this.txt)
         {
            throw new Error("GuiHelpTextBubble TEXT FIELDS section is missing parts or they are named incorrectly!");
         }
      }
      
      public function init(param1:Number = undefined, param2:Number = undefined) : void
      {
         visible = false;
         this.txt.autoSize = TextFieldAutoSize.CENTER;
      }
      
      public function setText(param1:String) : void
      {
         this.txt.text = param1;
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function bringToFront() : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function setTails(param1:Boolean = false, param2:Boolean = false, param3:Boolean = false) : void
      {
         if(param3)
         {
            this.tl.visible = false;
            this.tr.visible = false;
            this.bl.visible = false;
            this.br.visible = false;
            this.bl2.visible = true;
         }
         else if(param1)
         {
            if(param2)
            {
               this.tl.visible = true;
               this.tr.visible = false;
               this.bl.visible = false;
               this.br.visible = false;
               this.bl2.visible = false;
            }
            else
            {
               this.tl.visible = false;
               this.tr.visible = true;
               this.bl.visible = false;
               this.br.visible = false;
               this.bl2.visible = false;
            }
         }
         else if(param2)
         {
            this.tl.visible = false;
            this.tr.visible = false;
            this.bl.visible = true;
            this.br.visible = false;
            this.bl2.visible = false;
         }
         else
         {
            this.tl.visible = false;
            this.tr.visible = false;
            this.bl.visible = false;
            this.br.visible = true;
            this.bl2.visible = false;
         }
      }
   }
}

