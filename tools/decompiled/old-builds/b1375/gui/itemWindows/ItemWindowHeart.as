package gui.itemWindows
{
   import avatar.AvatarInfo;
   
   public class ItemWindowHeart extends ItemWindowBase
   {
      
      private var _frameName:String = "fullHeart";
      
      private var _hpPercentage:Number;
      
      private var _isEmptyHeart:Boolean;
      
      private var _numTotalHearts:Number = _loc10_.healthBase * 0.5;
      
      public function ItemWindowHeart(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _hpPercentage = param9.hpPercentage;
         var _loc10_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         var _loc13_:Number = 100 / _numTotalHearts;
         var _loc12_:Number = Math.min(_numTotalHearts,_hpPercentage / _loc13_);
         var _loc11_:int = Math.ceil(_loc12_);
         if(param4 + 1 == _loc11_)
         {
            if(_loc11_ - _loc12_ >= 0.5 && _numTotalHearts == _loc12_)
            {
               _frameName = "halfHeart";
            }
            else
            {
               _frameName = _loc11_ - _loc12_ >= 0.5 ? "halfEmpty" : "fullHeart";
            }
         }
         else if(param4 + 1 > _loc11_ && _loc11_ < _numTotalHearts)
         {
            _isEmptyHeart = true;
            if(param4 + 1 == Math.ceil(_numTotalHearts) && _loc11_ - _loc12_ >= 0.5)
            {
               _frameName = "halfCont";
            }
            else
            {
               _frameName = "emptyHeart";
            }
         }
         super("questHudHeart",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function updateFrame() : void
      {
         _window.gotoAndStop(_frameName);
      }
   }
}

