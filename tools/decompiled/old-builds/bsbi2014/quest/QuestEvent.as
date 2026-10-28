package quest
{
   import flash.events.Event;
   
   public class QuestEvent extends Event
   {
      
      public static const LOAD_SFX:String = "QuestEventLoadSfx";
      
      public static const PLAY_SFX:String = "QuestEventPlaySfx";
      
      public static const TORCH:String = "QuestEventTorch";
      
      public static const TRIGGER_CAMERASHAKE:String = "QuestEventTriggerCameraShake";
      
      private var _secondaryType:String;
      
      public function QuestEvent(type:String, secondaryType:String = "")
      {
         super(type,true,false);
         this._secondaryType = secondaryType;
      }
      
      override public function clone() : Event
      {
         return new QuestEvent(type);
      }
      
      override public function toString() : String
      {
         return formatToString("QuestEvent",type,this._secondaryType);
      }
      
      public function get secondaryType() : String
      {
         return this._secondaryType;
      }
   }
}

