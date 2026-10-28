package room
{
   import flash.events.Event;
   
   public class RoomEvent extends Event
   {
      
      public static const LOAD_SFX:String = "RoomEventLoadSfx";
      
      public static const PLAY_SFX:String = "RoomEventPlaySfx";
      
      public static const PLAY_SWFSFX:String = "RoomEventPlaySwfSfx";
      
      public static const PLAY_SWFSFXBYCLASS:String = "RoomEventPlaySwfSfxByClass";
      
      public static const ATTACH_EMOTE:String = "RoomEventAttachEmote";
      
      private var _secondaryType:String;
      
      private var _tertiaryType:String;
      
      private var _persistent:Boolean;
      
      public function RoomEvent(type:String, secondaryType:String = "", tertiaryType:String = "", persistent:Boolean = false)
      {
         super(type,true,false);
         this._secondaryType = secondaryType;
         this._tertiaryType = tertiaryType;
         this._persistent = persistent;
      }
      
      override public function clone() : Event
      {
         return new RoomEvent(type);
      }
      
      override public function toString() : String
      {
         return formatToString("RoomEvent",type,this._secondaryType,this._tertiaryType,this._persistent);
      }
      
      public function get secondaryType() : String
      {
         return this._secondaryType;
      }
      
      public function get tertiaryType() : String
      {
         return this._tertiaryType;
      }
      
      public function get persistent() : Boolean
      {
         return this._persistent;
      }
   }
}

