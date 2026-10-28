package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public dynamic class SBMessage extends SBPopup
   {
      
      public var messageTxt:TextField = new TextField();
      
      public function SBMessage(init_parent:DisplayObjectContainer, init_skin:MovieClip, init_message:String, autoOpen:Boolean = true, init_enabled:Boolean = true, init_modal:Boolean = false, init_draggable:Boolean = true, init_darken:Boolean = false, init_title:String = null, init_x:Number = undefined, init_y:Number = undefined, init_width:Number = undefined, init_height:Number = undefined, init_children:Array = null)
      {
         this.messageTxt.text = init_message;
         super(init_parent,init_skin,this.messageTxt,autoOpen,init_enabled,init_modal,init_draggable,init_darken,init_title,init_x,init_y,init_width,init_height,init_children);
      }
   }
}

