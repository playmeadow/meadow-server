package com.sbi.analytics
{
   import com.carlcalderon.arthropod.Debug;
   import flash.utils.getTimer;
   
   public class URIObj
   {
      
      private var _type:int;
      
      private var _trackingObject:Object;
      
      private var _containsAnUndefined:Boolean;
      
      private var _pageView:String;
      
      private var _userId:int;
      
      private var _isFromLogin:Boolean;
      
      private var _throttled:Boolean;
      
      private var _index:int;
      
      public function URIObj(uri:String, currTime:Number, isFromLogin:Boolean, type:int, index:int, throttled:Boolean, customFields:Object = null)
      {
         var sessionId:int = 0;
         var previousURIObj:URIObj = null;
         super();
         uri = uri.replace(/[',]/g,"");
         var pageStrings:Array = uri.split(/#/i);
         this._isFromLogin = isFromLogin;
         this._throttled = throttled;
         this._type = type;
         this._index = index;
         if(Boolean(customFields) && Boolean(customFields.userId))
         {
            this._userId = customFields.userId;
         }
         else
         {
            this._userId = isFromLogin ? 0 : (gMainFrame.clientInfo.dbUserId == undefined ? -1 : int(gMainFrame.clientInfo.dbUserId));
         }
         if(Boolean(customFields) && Boolean(customFields.sessionId))
         {
            sessionId = int(customFields.sessionId);
         }
         else
         {
            sessionId = int(gMainFrame.clientInfo.sessionId);
         }
         var duration:int = -1;
         if(Boolean(customFields) && Boolean(customFields.duration))
         {
            duration = int(customFields.duration);
         }
         else
         {
            previousURIObj = SBTracker.getPreviousURIObjByType(index,type);
            if(Boolean(previousURIObj))
            {
               previousURIObj.setTimeAndDurationAndOrder();
            }
         }
         this._trackingObject = {
            "userId":this._userId,
            "time":currTime,
            "order":(Boolean(customFields) && Boolean(customFields.order) ? customFields.order : 0),
            "duration":duration,
            "sessionId":sessionId,
            "uri":pageStrings[0],
            "uriParams":(pageStrings[1] != null ? pageStrings[1] : ""),
            "pop":(pageStrings[2] != null && pageStrings[2] == "pop" ? 1 : 0),
            "value":(pageStrings[3] != null ? pageStrings[3] : ""),
            "type":type
         };
         var debugTrackView:String = "userId: " + this._trackingObject.userId + "\n" + "time: " + this._trackingObject.time + "\n" + "order: " + this._trackingObject.order + "\n" + "duration: " + this._trackingObject.duration + "\n" + "sessionId: " + this._trackingObject.sessionId + "\n" + "URI: " + this._trackingObject.uri + "\n" + "uriParams: " + this._trackingObject.uriParams + "\n" + "pop: " + this._trackingObject.pop + "\n" + "value: " + this._trackingObject.value + "\ntype: " + this._trackingObject.type;
         Debug.log(debugTrackView,Debug.PINK);
      }
      
      public function destroy() : void
      {
         this._trackingObject = null;
      }
      
      public function get isFromLogin() : Boolean
      {
         return this._isFromLogin;
      }
      
      public function get trackingObject() : Object
      {
         return this._trackingObject;
      }
      
      public function get throttled() : Boolean
      {
         return this._throttled;
      }
      
      public function set index(value:int) : void
      {
         this._index = value;
      }
      
      public function setTimeAndDurationAndOrder() : void
      {
         var previousURIObj:URIObj = null;
         var lastTimeStamp:Number = SBTracker.getLastTimestamp(this._type);
         var isTimeTheSame:Boolean = this._trackingObject.time - lastTimeStamp == 0;
         SBTracker.setLastTimestamp(this._type,this._trackingObject.time);
         if(isTimeTheSame && this._trackingObject.order == 0)
         {
            previousURIObj = SBTracker.getPreviousURIObjByType(this._index,this._type);
            if(Boolean(previousURIObj))
            {
               this._trackingObject.order = previousURIObj.trackingObject.order + 1;
            }
         }
         var lastDuration:Number = SBTracker.getLastDuration(this._type);
         var currTime:Number = getTimer();
         SBTracker.setLastDuration(this._type,currTime);
         if(this._trackingObject.duration == -1)
         {
            this._trackingObject.duration = Math.round((currTime - lastDuration) / 100);
         }
      }
      
      public function get pageView() : String
      {
         if(this._trackingObject.duration != -1)
         {
            return (this._isFromLogin ? this._userId : gMainFrame.clientInfo.dbUserId) + "\n" + this._trackingObject.time + "\n" + this._trackingObject.order + "\n" + this._trackingObject.duration + "\n" + this._trackingObject.sessionId + "\n" + this._trackingObject.uri + "\n" + this._trackingObject.uriParams + "\n" + this._trackingObject.pop + "\n" + this._trackingObject.value + "\n" + this._trackingObject.type + "\n";
         }
         return "";
      }
      
      public function get ownPageView() : String
      {
         this.setTimeAndDurationAndOrder();
         return this.pageView;
      }
   }
}

