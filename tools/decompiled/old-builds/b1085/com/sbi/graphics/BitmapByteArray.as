package com.sbi.graphics
{
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class BitmapByteArray
   {
      
      private static const PALETTE_ALPHA_OFFSET:int = 25;
      
      private static const SHADOW_GRADIENT_SCALE:int = 3;
      
      private const TRANS:int = 0;
      
      private var _palette:Array;
      
      private var _h:int;
      
      private var _w:int;
      
      private var _offX:int;
      
      private var _offY:int;
      
      private var _ba:Vector.<int>;
      
      public function BitmapByteArray()
      {
         super();
         this._palette = PaletteHelper.getAnimalPalette();
      }
      
      public static function scaleAndPackImage(param1:BitmapData) : Object
      {
         var _loc2_:BitmapByteArray = new BitmapByteArray();
         _loc2_.loadBitmap(param1);
         _loc2_.halfImage();
         _loc2_.crop();
         return _loc2_.processPackImage();
      }
      
      public static function scaleAndPackShadow(param1:BitmapData, param2:int, param3:int, param4:int, param5:int) : Object
      {
         var _loc6_:BitmapByteArray = new BitmapByteArray();
         return _loc6_.scaleShadow(param1,param2,param3,param4,param5);
      }
      
      private function loadBitmap(param1:BitmapData) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc7_:uint = 0;
         this._w = param1.width;
         this._h = param1.height;
         this._ba = new Vector.<int>(this._w * this._h,true);
         var _loc4_:uint = 0;
         var _loc5_:int = -1;
         var _loc6_:* = 0;
         _loc3_ = 0;
         while(_loc3_ < this._h)
         {
            _loc2_ = 0;
            while(_loc2_ < this._w)
            {
               _loc7_ = param1.getPixel32(_loc2_,_loc3_);
               if(_loc4_ != _loc7_ || _loc5_ < 0)
               {
                  _loc4_ = _loc7_;
                  _loc5_ = int(this.findPaletteColor(_loc7_));
               }
               var _loc8_:Number;
               this._ba[_loc8_ = _loc6_++] = _loc5_;
               _loc2_++;
            }
            _loc3_++;
         }
      }
      
      private function scaleShadow(param1:BitmapData, param2:int, param3:int, param4:int, param5:int) : Object
      {
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         var _loc16_:int = 0;
         var _loc17_:* = 0;
         this._w = param1.width;
         this._h = param1.height;
         var _loc6_:Vector.<uint> = param1.getVector(new Rectangle(0,0,this._w,this._h));
         var _loc11_:Vector.<int> = new Vector.<int>(this._w * this._h * 0.25,true);
         var _loc12_:int = 0;
         var _loc13_:* = 0;
         var _loc14_:int = 0;
         while(_loc14_ < this._h)
         {
            _loc16_ = 0;
            while(_loc16_ < this._w)
            {
               _loc12_ = _loc16_ + _loc14_ * this._w;
               _loc7_ = _loc6_[_loc12_];
               _loc8_ = _loc6_[_loc12_ + 1];
               _loc12_ += this._w;
               _loc9_ = _loc6_[_loc12_];
               _loc10_ = _loc6_[_loc12_ + 1];
               var _loc18_:Number;
               _loc11_[_loc18_ = _loc13_++] = this.blendShadowColors(_loc7_,_loc8_,_loc9_,_loc10_);
               _loc16_ += 2;
            }
            _loc14_ += 2;
         }
         this._ba = _loc11_;
         this._h /= 2;
         this._w /= 2;
         if(param4 != this._w || param5 != this._h)
         {
            _loc13_ = 0;
            _loc11_ = new Vector.<int>(param4 * param5,true);
            _loc14_ = param3;
            while(_loc14_ < param3 + param5)
            {
               _loc17_ = int(_loc14_ * this._w + param2);
               _loc16_ = 0;
               while(_loc16_ < param4)
               {
                  _loc12_ = this._ba[_loc17_++];
                  _loc11_[_loc18_ = _loc13_++] = _loc12_;
                  _loc16_++;
               }
               _loc14_++;
            }
            this._w = param4;
            this._h = param5;
            this._offX = param2;
            this._offY = param3;
            this._ba = _loc11_;
         }
         var _loc15_:Object = this.processPackImage();
         _loc15_.sm = SHADOW_GRADIENT_SCALE;
         return _loc15_;
      }
      
      private function halfImage() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:Vector.<int> = new Vector.<int>(this._w * this._h * 0.25,true);
         var _loc6_:int = 0;
         var _loc7_:* = 0;
         var _loc8_:int = 0;
         while(_loc8_ < this._h)
         {
            _loc9_ = 0;
            while(_loc9_ < this._w)
            {
               _loc6_ = _loc9_ + _loc8_ * this._w;
               _loc1_ = this._ba[_loc6_];
               _loc2_ = this._ba[_loc6_ + 1];
               _loc6_ += this._w;
               _loc3_ = this._ba[_loc6_];
               _loc4_ = this._ba[_loc6_ + 1];
               var _loc10_:Number;
               _loc5_[_loc10_ = _loc7_++] = this.blendColors(_loc1_,_loc2_,_loc3_,_loc4_);
               _loc9_ += 2;
            }
            _loc8_ += 2;
         }
         this._ba = _loc5_;
         this._h /= 2;
         this._w /= 2;
      }
      
      private function crop() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc11_:Vector.<int> = null;
         var _loc12_:* = 0;
         var _loc4_:int = this._w;
         var _loc5_:int = 0;
         var _loc6_:int = this._h;
         var _loc7_:int = 0;
         var _loc8_:* = 0;
         _loc3_ = 0;
         while(_loc3_ < this._h)
         {
            _loc2_ = 0;
            while(_loc2_ < this._w)
            {
               _loc1_ = uint(this._ba[_loc8_++]);
               if(_loc1_ > 0)
               {
                  if(_loc2_ < _loc4_)
                  {
                     _loc4_ = _loc2_;
                  }
                  if(_loc2_ > _loc5_)
                  {
                     _loc5_ = _loc2_;
                  }
                  if(_loc3_ < _loc6_)
                  {
                     _loc6_ = _loc3_;
                  }
                  if(_loc3_ > _loc7_)
                  {
                     _loc7_ = _loc3_;
                  }
               }
               _loc2_++;
            }
            _loc3_++;
         }
         this._offX = _loc4_;
         this._offY = _loc6_;
         var _loc9_:uint = _loc5_ - _loc4_ + 1;
         var _loc10_:uint = _loc7_ - _loc6_ + 1;
         if(_loc4_ == this._w && _loc6_ == this._h)
         {
            this._w = 0;
            this._h = 0;
            this._ba = null;
            return;
         }
         _loc8_ = 0;
         if(_loc9_ != this._w || _loc10_ != this._h)
         {
            _loc11_ = new Vector.<int>(_loc9_ * _loc10_,true);
            _loc3_ = _loc6_;
            while(_loc3_ < _loc6_ + _loc10_)
            {
               _loc12_ = int(_loc3_ * this._w + this._offX);
               _loc2_ = 0;
               while(_loc2_ < _loc9_)
               {
                  _loc1_ = uint(this._ba[_loc12_++]);
                  var _loc13_:Number;
                  _loc11_[_loc13_ = _loc8_++] = _loc1_;
                  _loc2_++;
               }
               _loc3_++;
            }
            this._w = _loc9_;
            this._h = _loc10_;
            this._ba = _loc11_;
         }
      }
      
      private function processPackImage() : Object
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc10_:uint = 0;
         if(this._ba == null)
         {
            return null;
         }
         var _loc1_:Object = {
            "x":this._offX,
            "y":this._offY,
            "w":this._w,
            "h":this._h
         };
         var _loc5_:ByteArray = new ByteArray();
         _loc1_.b = _loc5_;
         var _loc6_:int = int(this._ba.length);
         var _loc7_:uint = 256;
         var _loc8_:uint = 0;
         var _loc9_:* = 0;
         while(_loc9_ < _loc6_)
         {
            _loc10_ = uint(this._ba[_loc9_++]);
            if(_loc7_ == 256)
            {
               _loc7_ = _loc10_;
            }
            else if(_loc10_ != _loc7_)
            {
               if(_loc8_)
               {
                  _loc7_ |= 128;
                  while(_loc8_ > 255)
                  {
                     _loc5_.writeByte(_loc7_);
                     _loc5_.writeByte(uint(255));
                     _loc8_ -= 256;
                  }
                  if(_loc8_ > 0)
                  {
                     _loc5_.writeByte(_loc7_);
                     _loc5_.writeByte(_loc8_);
                  }
                  else
                  {
                     _loc5_.writeByte(uint(_loc7_ & 0x7F));
                  }
               }
               else
               {
                  _loc5_.writeByte(_loc7_);
               }
               _loc7_ = _loc10_;
               _loc8_ = 0;
            }
            else
            {
               _loc8_++;
            }
         }
         if(Boolean(_loc8_) || _loc6_ == 1)
         {
            _loc7_ |= 128;
            while(_loc8_ > 255)
            {
               _loc5_.writeByte(_loc7_);
               _loc5_.writeByte(uint(255));
               _loc8_ -= 256;
            }
            if(_loc8_ > 0)
            {
               _loc5_.writeByte(_loc7_);
               _loc5_.writeByte(_loc8_);
            }
            else
            {
               _loc5_.writeByte(uint(_loc7_ & 0x7F));
            }
         }
         return _loc1_;
      }
      
      private function findPaletteColor(param1:uint) : uint
      {
         var _loc2_:uint = uint((param1 & 0xFF000000) >> 24);
         if(_loc2_ < 160)
         {
            return this.TRANS;
         }
         param1 |= 4278190080;
         var _loc3_:uint = 0;
         while(_loc3_ < PALETTE_ALPHA_OFFSET)
         {
            if(this._palette[_loc3_] == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         var _loc4_:int = param1 >> 16 & 0xFF;
         var _loc5_:int = param1 >> 8 & 0xFF;
         var _loc6_:int = param1 & 0xFF;
         return this.findClosetPaletteIndex(_loc4_,_loc5_,_loc6_);
      }
      
      private function findClosetPaletteIndex(param1:int, param2:int, param3:int) : int
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc12_:uint = 0;
         var _loc4_:int = 10000000;
         var _loc5_:int = 0;
         var _loc11_:uint = 0;
         while(_loc11_ < PALETTE_ALPHA_OFFSET)
         {
            _loc12_ = uint(this._palette[_loc11_]);
            _loc7_ = (_loc12_ >> 16 & 0xFF) - param1;
            _loc8_ = (_loc12_ >> 8 & 0xFF) - param2;
            _loc9_ = (_loc12_ & 0xFF) - param3;
            _loc10_ = _loc7_ * _loc7_ + _loc8_ * _loc8_ + _loc9_ * _loc9_;
            if(_loc10_ < _loc4_)
            {
               _loc4_ = _loc10_;
               _loc5_ = int(_loc11_);
            }
            _loc11_++;
         }
         return _loc5_;
      }
      
      private function blendColors(param1:uint, param2:uint, param3:uint, param4:uint) : uint
      {
         var _loc5_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         if(param1 == this.TRANS)
         {
            _loc6_++;
         }
         if(param2 == this.TRANS)
         {
            _loc6_++;
         }
         if(param3 == this.TRANS)
         {
            _loc6_++;
         }
         if(param4 == this.TRANS)
         {
            _loc6_++;
         }
         if(_loc6_ == 4)
         {
            return 0;
         }
         if(param1 == param2 && param1 == param3 && param1 == param4)
         {
            _loc5_ = param1;
         }
         else
         {
            _loc7_ = [param1,param2,param3,param4];
            while(_loc12_ < 4)
            {
               if(_loc7_[_loc12_] != this.TRANS)
               {
                  param1 = uint(this._palette[_loc7_[_loc12_]]);
                  _loc9_ += param1 >> 16 & 0xFF;
                  _loc10_ += param1 >> 8 & 0xFF;
                  _loc11_ += param1 & 0xFF;
                  _loc8_++;
               }
               _loc12_++;
            }
            _loc9_ /= _loc8_;
            _loc10_ /= _loc8_;
            _loc11_ /= _loc8_;
            _loc5_ = uint(this.findClosetPaletteIndex(_loc9_,_loc10_,_loc11_));
         }
         return uint(_loc5_ + _loc6_ * PALETTE_ALPHA_OFFSET);
      }
      
      private function blendShadowColors(param1:uint, param2:uint, param3:uint, param4:uint) : int
      {
         var _loc5_:uint = ((param1 >> 24 & 0xFF) + (param2 >> 24 & 0xFF) + (param3 >> 24 & 0xFF) + (param4 >> 24 & 0xFF)) / 4;
         var _loc6_:uint = ((param1 & 0xFF & 0xFF) + (param2 & 0xFF & 0xFF) + (param3 & 0xFF & 0xFF) + (param4 & 0xFF & 0xFF)) / 4;
         if(_loc5_)
         {
            _loc6_ += (255 - _loc6_) * ((255 - _loc5_) / 255);
            _loc6_ = uint(_loc6_ >> BitmapByteArray.SHADOW_GRADIENT_SCALE);
            if(_loc6_ == 0)
            {
               _loc6_ = 1;
            }
         }
         else
         {
            _loc6_ = 0;
         }
         return _loc6_;
      }
   }
}

