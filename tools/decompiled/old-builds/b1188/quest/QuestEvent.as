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
      
      public function QuestEvent(param1:String, param2:String = "")
      {
         super(param1,true,false);
         this._secondaryType = param2;
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

