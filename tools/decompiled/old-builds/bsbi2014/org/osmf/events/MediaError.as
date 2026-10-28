package org.osmf.events
{
   public class MediaError extends Error
   {
      
      private var _detail:String;
      
      public function MediaError(errorID:int, detail:String = null)
      {
         super(this.getMessageForErrorID(errorID),errorID);
         this._detail = detail;
      }
      
      public function get detail() : String
      {
         return this._detail;
      }
      
      protected function getMessageForErrorID(errorID:int) : String
      {
         return MediaErrorCodes.getMessageForErrorID(errorID);
      }
   }
}

