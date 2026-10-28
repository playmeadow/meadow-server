package
{
   import adobe.utils.*;
   import avatar.NameBar;
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.globalization.*;
   import flash.media.*;
   import flash.net.*;
   import flash.net.drm.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.sensors.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.engine.*;
   import flash.text.ime.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol2357")]
   public dynamic class memberNameBar extends NameBar
   {
      
      public var currCT:ColorTransform;
      
      public var currColorId:int;
      
      public function memberNameBar()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function updateColor(param1:*) : *
      {
         if(!this.currCT)
         {
            this.currCT = new ColorTransform();
         }
         switch(param1)
         {
            case 1:
               this.currCT.color = 7566205;
               this.currColorId = 1;
               break;
            case 2:
               this.currCT.color = 6593023;
               this.currColorId = 2;
               break;
            case 3:
               this.currCT.color = 13073480;
               this.currColorId = 3;
               break;
            case 5:
               this.currCT.color = 10406971;
               this.currColorId = 5;
               break;
            case 6:
               this.currCT.color = 16028056;
               this.currColorId = 6;
               break;
            case 7:
               this.currCT.color = 12153599;
               this.currColorId = 7;
               break;
            case 8:
               this.currCT.color = 16727859;
               this.currColorId = 8;
               break;
            case 9:
               this.currCT.color = 5751740;
               this.currColorId = 9;
               break;
            case 10:
               this.currCT.color = 15394278;
               this.currColorId = 10;
               break;
            case 4:
            default:
               this.currCT.color = 16631860;
               this.currColorId = 4;
         }
         this.showDrawnColor(this.e,this.currColorId);
         this.showDrawnColor(this.m,this.currColorId);
         this.findChildrenAndSet(this.e,this.currCT);
         this.findChildrenAndSet(this.c,this.currCT);
         this.findChildrenAndSet(this.selnub,this.currCT);
         this.findChildrenAndSet(this.m,this.currCT);
         this.findChildrenAndSet(this.shape,this.currCT);
         this.findChildrenAndSet(this.hostTag,this.currCT);
      }
      
      public function showDrawnColor(param1:*, param2:int) : *
      {
         var _loc3_:* = param1 ? param1.getChildByName("old") : null;
         if(_loc3_ is MovieClip && _loc3_.totalFrames >= param2)
         {
            _loc3_.gotoAndStop(param2);
            this.stopChildren(_loc3_);
            if(param1.mouse)
            {
               param1.mouse.visible = false;
            }
            if(param1.gradient)
            {
               param1.gradient.visible = false;
            }
         }
      }
      
      public function stopChildren(param1:*) : *
      {
         var _loc2_:* = undefined;
         var _loc3_:* = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc2_ = param1.getChildAt(_loc3_);
            if(_loc2_ is MovieClip)
            {
               _loc2_.gotoAndStop(1);
               this.stopChildren(_loc2_);
            }
            _loc3_++;
         }
      }
      
      public function getCurrCT() : *
      {
         return this.currCT;
      }
      
      public function getCurrColorId() : *
      {
         if(this.currCT)
         {
            return this.currColorId;
         }
         return 4;
      }
      
      public function findChildrenAndSet(param1:*, param2:*) : *
      {
         var _loc3_:* = undefined;
         this.setColor(param1,param2);
         if("numChildren" in param1)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.numChildren)
            {
               this.findChildrenAndSet(param1.getChildAt(_loc3_),param2);
               _loc3_++;
            }
         }
      }
      
      public function setColor(param1:*, param2:*) : *
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(param1 != null)
         {
            if(param1.name == "norm")
            {
               param1.transform.colorTransform = param2;
            }
            else if(param1.name == "light" || param1.name == "dark")
            {
               _loc3_ = null;
               _loc4_ = null;
               _loc3_ = this.RGBtoHSB(param2.redOffset,param2.greenOffset,param2.blueOffset);
               if(param1.name == "light")
               {
                  _loc3_.s *= 0.2;
                  if(_loc3_.b < 60)
                  {
                     _loc3_.b = 60;
                  }
               }
               else if(param1.name == "dark")
               {
                  _loc3_.b *= 0.5;
               }
               _loc4_ = this.HSBtoRGB(_loc3_.h,_loc3_.s,_loc3_.b);
               param1.transform.colorTransform = new ColorTransform(param2.redMultiplier,param2.greenMultiplier,param2.blueMultiplier,param2.alphaMultiplier,_loc4_.r,_loc4_.g,_loc4_.b,param2.alphaOffset);
            }
         }
      }
      
      public function HSBtoRGB(param1:int, param2:int, param3:int) : Object
      {
         var _loc7_:Number = NaN;
         var _loc4_:Object = new Object();
         var _loc5_:Number = param3 * 0.01 * 255;
         var _loc6_:Number = _loc5_ * (1 - param2 * 0.01);
         if(param1 == 360)
         {
            param1 = 0;
         }
         if(param2 == 0)
         {
            _loc4_.r = _loc4_.g = _loc4_.b = param3 * (255 * 0.01);
         }
         else
         {
            _loc7_ = Math.floor(param1 / 60);
            switch(_loc7_)
            {
               case 0:
                  _loc4_.r = _loc5_;
                  _loc4_.g = _loc6_ + param1 * (_loc5_ - _loc6_) / 60;
                  _loc4_.b = _loc6_;
                  break;
               case 1:
                  _loc4_.r = _loc5_ - (param1 - 60) * (_loc5_ - _loc6_) / 60;
                  _loc4_.g = _loc5_;
                  _loc4_.b = _loc6_;
                  break;
               case 2:
                  _loc4_.r = _loc6_;
                  _loc4_.g = _loc5_;
                  _loc4_.b = _loc6_ + (param1 - 120) * (_loc5_ - _loc6_) / 60;
                  break;
               case 3:
                  _loc4_.r = _loc6_;
                  _loc4_.g = _loc5_ - (param1 - 180) * (_loc5_ - _loc6_) / 60;
                  _loc4_.b = _loc5_;
                  break;
               case 4:
                  _loc4_.r = _loc6_ + (param1 - 240) * (_loc5_ - _loc6_) / 60;
                  _loc4_.g = _loc6_;
                  _loc4_.b = _loc5_;
                  break;
               case 5:
                  _loc4_.r = _loc5_;
                  _loc4_.g = _loc6_;
                  _loc4_.b = _loc5_ - (param1 - 300) * (_loc5_ - _loc6_) / 60;
                  break;
               case 6:
                  _loc4_.r = _loc5_;
                  _loc4_.g = _loc6_ + param1 * (_loc5_ - _loc6_) / 60;
                  _loc4_.b = _loc6_;
            }
            _loc4_.r = Math.min(255,Math.max(0,Math.round(_loc4_.r)));
            _loc4_.g = Math.min(255,Math.max(0,Math.round(_loc4_.g)));
            _loc4_.b = Math.min(255,Math.max(0,Math.round(_loc4_.b)));
         }
         return _loc4_;
      }
      
      public function RGBtoHSB(param1:int, param2:int, param3:int) : Object
      {
         var _loc4_:Object = new Object();
         var _loc5_:Number = Math.max(param1,param2,param3);
         var _loc6_:Number = Math.min(param1,param2,param3);
         _loc4_.s = _loc5_ != 0 ? (_loc5_ - _loc6_) / _loc5_ * 100 : 0;
         _loc4_.b = _loc5_ / 255 * 100;
         if(_loc4_.s == 0)
         {
            _loc4_.h = 0;
         }
         else
         {
            switch(_loc5_)
            {
               case param1:
                  _loc4_.h = (param2 - param3) / (_loc5_ - _loc6_) * 60 + 0;
                  break;
               case param2:
                  _loc4_.h = (param3 - param1) / (_loc5_ - _loc6_) * 60 + 120;
                  break;
               case param3:
                  _loc4_.h = (param1 - param2) / (_loc5_ - _loc6_) * 60 + 240;
            }
         }
         _loc4_.h = Math.min(360,Math.max(0,Math.round(_loc4_.h)));
         _loc4_.s = Math.min(100,Math.max(0,Math.round(_loc4_.s)));
         _loc4_.b = Math.min(100,Math.max(0,Math.round(_loc4_.b)));
         return _loc4_;
      }
      
      internal function frame1() : *
      {
      }
   }
}

