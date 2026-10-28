package gui
{
   import avatar.AvatarInfo;
   
   public class ItemWindowHeart extends ItemWindowBase
   {
      
      private var _frameName:String = "fullHeart";
      
      private var _hpPercentage:Number;
      
      private var _isEmptyHeart:Boolean;
      
      private var _numTotalHearts:Number;
      
      public function ItemWindowHeart(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._hpPercentage = customParams.hpPercentage;
         var ai:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         this._numTotalHearts = ai.healthBase * 0.5;
         var numHeartsPerPercentage:Number = 100 / this._numTotalHearts;
         var numHearts:Number = Math.min(this._numTotalHearts,this._hpPercentage / numHeartsPerPercentage);
         var numHeartsCeil:int = Math.ceil(numHearts);
         if(index + 1 == numHeartsCeil)
         {
            if(numHeartsCeil - numHearts >= 0.5 && this._numTotalHearts == numHearts)
            {
               this._frameName = "halfHeart";
            }
            else
            {
               this._frameName = numHeartsCeil - numHearts >= 0.5 ? "halfEmpty" : "fullHeart";
            }
         }
         else if(index + 1 > numHeartsCeil && numHeartsCeil < this._numTotalHearts)
         {
            this._isEmptyHeart = true;
            if(index + 1 == Math.ceil(this._numTotalHearts) && numHeartsCeil - numHearts >= 0.5)
            {
               this._frameName = "halfCont";
            }
            else
            {
               this._frameName = "emptyHeart";
            }
         }
         super("questHudHeart",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      public function updateFrame() : void
      {
         _window.gotoAndStop(this._frameName);
      }
   }
}

