package gui
{
   import avatar.AvatarInfo;
   
   public class ItemWindowHeart extends ItemWindowBase
   {
      
      private var _frameName:String = "fullHeart";
      
      private var _hpPercentage:Number;
      
      private var _isEmptyHeart:Boolean;
      
      private var _numTotalHearts:Number;
      
      public function ItemWindowHeart(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._hpPercentage = param9.hpPercentage;
         var _loc10_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
         this._numTotalHearts = _loc10_.healthBase * 0.5;
         var _loc11_:Number = 100 / this._numTotalHearts;
         var _loc12_:Number = Math.min(this._numTotalHearts,this._hpPercentage / _loc11_);
         var _loc13_:int = Math.ceil(_loc12_);
         if(param4 + 1 == _loc13_)
         {
            if(_loc13_ - _loc12_ >= 0.5 && this._numTotalHearts == _loc12_)
            {
               this._frameName = "halfHeart";
            }
            else
            {
               this._frameName = _loc13_ - _loc12_ >= 0.5 ? "halfEmpty" : "fullHeart";
            }
         }
         else if(param4 + 1 > _loc13_ && _loc13_ < this._numTotalHearts)
         {
            this._isEmptyHeart = true;
            if(param4 + 1 == Math.ceil(this._numTotalHearts) && _loc13_ - _loc12_ >= 0.5)
            {
               this._frameName = "halfCont";
            }
            else
            {
               this._frameName = "emptyHeart";
            }
         }
         super("questHudHeart",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function updateFrame() : void
      {
         _window.gotoAndStop(this._frameName);
      }
   }
}

