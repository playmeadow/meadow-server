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
      
      public function URIObj(param1:String, param2:Number, param3:Boolean, param4:int, param5:int, param6:Boolean, param7:Object = null)
      {
         var _loc9_:int = 0;
         var _loc12_:URIObj = null;
         super();
         param1 = param1.replace(/[',]/g,"");
         var _loc8_:Array = param1.split(/#/i);
         this._isFromLogin = param3;
         this._throttled = param6;
         this._type = param4;
         this._index = param5;
         if(Boolean(param7) && Boolean(param7.userId))
         {
            this._userId = param7.userId;
         }
         else
         {
            this._userId = param3 ? 0 : (gMainFrame.clientInfo.dbUserId == undefined ? -1 : int(gMainFrame.clientInfo.dbUserId));
         }
         if(Boolean(param7) && Boolean(param7.sessionId))
         {
            _loc9_ = int(param7.sessionId);
         }
         else
         {
            _loc9_ = int(gMainFrame.clientInfo.sessionId);
         }
         var _loc10_:int = -1;
         if(Boolean(param7) && Boolean(param7.duration))
         {
            _loc10_ = int(param7.duration);
         }
         else
         {
            _loc12_ = SBTracker.getPreviousURIObjByType(param5,param4);
            if(_loc12_)
            {
               _loc12_.setTimeAndDurationAndOrder();
            }
         }
         this._trackingObject = {
            "userId":this._userId,
            "time":param2,
            "order":(Boolean(param7) && Boolean(param7.order) ? param7.order : 0),
            "duration":_loc10_,
            "sessionId":_loc9_,
            "uri":_loc8_[0],
            "uriParams":(_loc8_[1] != null ? _loc8_[1] : ""),
            "pop":(_loc8_[2] != null && _loc8_[2] == "pop" ? 1 : 0),
            "value":(_loc8_[3] != null ? _loc8_[3] : ""),
            "type":param4
         };
         var _loc11_:String = "userId: " + this._trackingObject.userId + "\n" + "time: " + this._trackingObject.time + "\n" + "order: " + this._trackingObject.order + "\n" + "duration: " + this._trackingObject.duration + "\n" + "sessionId: " + this._trackingObject.sessionId + "\n" + "URI: " + this._trackingObject.uri + "\n" + "uriParams: " + this._trackingObject.uriParams + "\n" + "pop: " + this._trackingObject.pop + "\n" + "value: " + this._trackingObject.value + "\ntype: " + this._trackingObject.type;
         Debug.log(_loc11_,Debug.PINK);
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
      
      public function set index(param1:int) : void
      {
         this._index = param1;
      }
      
      public function setTimeAndDurationAndOrder() : void
      {
         var _loc5_:URIObj = null;
         var _loc1_:Number = SBTracker.getLastTimestamp(this._type);
         var _loc2_:Boolean = this._trackingObject.time - _loc1_ == 0;
         SBTracker.setLastTimestamp(this._type,this._trackingObject.time);
         if(_loc2_ && this._trackingObject.order == 0)
         {
            _loc5_ = SBTracker.getPreviousURIObjByType(this._index,this._type);
            if(_loc5_)
            {
               this._trackingObject.order = _loc5_.trackingObject.order + 1;
            }
         }
         var _loc3_:Number = SBTracker.getLastDuration(this._type);
         var _loc4_:Number = getTimer();
         SBTracker.setLastDuration(this._type,_loc4_);
         if(this._trackingObject.duration == -1)
         {
            this._trackingObject.duration = Math.round((_loc4_ - _loc3_) / 100);
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

