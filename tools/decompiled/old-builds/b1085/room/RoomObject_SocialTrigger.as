package room
{
   import flash.display.MovieClip;
   
   public class RoomObject_SocialTrigger extends RoomObject
   {
      
      private var _currentStage:int;
      
      private var _stages:Array;
      
      private var _totalCount:int;
      
      public function RoomObject_SocialTrigger(param1:MovieClip)
      {
         super(param1);
         this._stages = param1.stages;
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
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         while(_loc2_ < this._stages.length)
         {
            if(this._totalCount < this._stages[_loc2_].total)
            {
               break;
            }
            _loc1_ = _loc2_;
            _loc2_++;
         }
         if(this._currentStage != _loc1_)
         {
            this._currentStage = _loc1_;
            _mc.gotoAndPlay(this._stages[this._currentStage].label);
         }
      }
   }
}

