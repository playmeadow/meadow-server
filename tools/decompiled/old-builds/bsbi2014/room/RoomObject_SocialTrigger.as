package room
{
   import flash.display.MovieClip;
   
   public class RoomObject_SocialTrigger extends RoomObject
   {
      
      private var _currentStage:int;
      
      private var _stages:Array;
      
      private var _totalCount:int;
      
      public function RoomObject_SocialTrigger(mc:MovieClip)
      {
         super(mc);
         this._stages = mc.stages;
         this.clearCount();
         this.update();
      }
      
      public function clearCount() : void
      {
         this._totalCount = 0;
      }
      
      public function incCount() : void
      {
         ++this._totalCount;
      }
      
      public function update() : void
      {
         var i:int = 0;
         for(var newStage:int = 0; i < this._stages.length; )
         {
            if(this._totalCount < this._stages[i].total)
            {
               break;
            }
            newStage = i;
            i++;
         }
         if(this._currentStage != newStage)
         {
            this._currentStage = newStage;
            _mc.gotoAndPlay(this._stages[this._currentStage].label);
         }
      }
   }
}

