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
         _palette = PaletteHelper.getAnimalPalette();
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
         var _loc5_:* = 0;
         var _loc7_:* = 0;
         var _loc4_:* = 0;
         _w = param1.width;
         _h = param1.height;
         _ba = new Vector.<int>(_w * _h,true);
         var _loc3_:uint = 0;
         var _loc2_:int = -1;
         var _loc6_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < _h)
         {
            _loc7_ = 0;
            while(_loc7_ < _w)
            {
               _loc4_ = param1.getPixel32(_loc7_,_loc5_);
               if(_loc3_ != _loc4_ || _loc2_ < 0)
               {
                  _loc3_ = _loc4_;
                  _loc2_ = int(findPaletteColor(_loc4_));
               }
               _ba[_loc6_++] = _loc2_;
               _loc7_++;
            }
            _loc5_++;
         }
      }
      
      private function scaleShadow(param1:BitmapData, param2:int, param3:int, param4:int, param5:int) : Object
      {
         var _loc14_:* = 0;
         var _loc8_:* = 0;
         var _loc7_:* = 0;
         var _loc13_:* = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc10_:int = 0;
         _w = param1.width;
         _h = param1.height;
         var _loc9_:Vector.<uint> = param1.getVector(new Rectangle(0,0,_w,_h));
         var _loc12_:Vector.<int> = new Vector.<int>(_w * _h * 0.25,true);
         var _loc15_:int = 0;
         var _loc11_:int = 0;
         _loc16_ = 0;
         while(_loc16_ < _h)
         {
            _loc17_ = 0;
            while(_loc17_ < _w)
            {
               _loc15_ = _loc17_ + _loc16_ * _w;
               _loc13_ = _loc9_[_loc15_];
               _loc14_ = _loc9_[_loc15_ + 1];
               _loc15_ += _w;
               _loc8_ = _loc9_[_loc15_];
               _loc7_ = _loc9_[_loc15_ + 1];
               _loc12_[_loc11_++] = blendShadowColors(_loc13_,_loc14_,_loc8_,_loc7_);
               _loc17_ += 2;
            }
            _loc16_ += 2;
         }
         _ba = _loc12_;
         _h /= 2;
         _w /= 2;
         if(param4 != _w || param5 != _h)
         {
            _loc11_ = 0;
            _loc12_ = new Vector.<int>(param4 * param5,true);
            _loc16_ = param3;
            while(_loc16_ < param3 + param5)
            {
               _loc10_ = _loc16_ * _w + param2;
               _loc17_ = 0;
               while(_loc17_ < param4)
               {
                  _loc15_ = _ba[_loc10_++];
                  _loc12_[_loc11_++] = _loc15_;
                  _loc17_++;
               }
               _loc16_++;
            }
            _w = param4;
            _h = param5;
            _offX = param2;
            _offY = param3;
            _ba = _loc12_;
         }
         var _loc6_:Object = processPackImage();
         _loc6_.sm = 3;
         return _loc6_;
      }
      
      private function halfImage() : void
      {
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc1_:Vector.<int> = new Vector.<int>(_w * _h * 0.25,true);
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         _loc7_ = 0;
         while(_loc7_ < _h)
         {
            _loc8_ = 0;
            while(_loc8_ < _w)
            {
               _loc4_ = _loc8_ + _loc7_ * _w;
               _loc2_ = _ba[_loc4_];
               _loc3_ = _ba[_loc4_ + 1];
               _loc4_ += _w;
               _loc6_ = _ba[_loc4_];
               _loc5_ = _ba[_loc4_ + 1];
               _loc1_[_loc9_++] = blendColors(_loc2_,_loc3_,_loc6_,_loc5_);
               _loc8_ += 2;
            }
            _loc7_ += 2;
         }
         _ba = _loc1_;
         _h /= 2;
         _w /= 2;
      }
      
      private function crop() : void
      {
         var _loc5_:* = 0;
         var _loc9_:int = 0;
         var _loc12_:int = 0;
         var _loc2_:* = undefined;
         var _loc10_:int = 0;
         var _loc6_:int = _w;
         var _loc8_:int = 0;
         var _loc3_:int = _h;
         var _loc4_:int = 0;
         var _loc11_:int = 0;
         _loc9_ = 0;
         while(_loc9_ < _h)
         {
            _loc12_ = 0;
            while(_loc12_ < _w)
            {
               _loc5_ = uint(_ba[_loc11_++]);
               if(_loc5_ > 0)
               {
                  if(_loc12_ < _loc6_)
                  {
                     _loc6_ = _loc12_;
                  }
                  if(_loc12_ > _loc8_)
                  {
                     _loc8_ = _loc12_;
                  }
                  if(_loc9_ < _loc3_)
                  {
                     _loc3_ = _loc9_;
                  }
                  if(_loc9_ > _loc4_)
                  {
                     _loc4_ = _loc9_;
                  }
               }
               _loc12_++;
            }
            _loc9_++;
         }
         _offX = _loc6_;
         _offY = _loc3_;
         var _loc1_:uint = _loc8_ - _loc6_ + 1;
         var _loc7_:uint = _loc4_ - _loc3_ + 1;
         if(_loc6_ == _w && _loc3_ == _h)
         {
            _w = 0;
            _h = 0;
            _ba = null;
            return;
         }
         _loc11_ = 0;
         if(_loc1_ != _w || _loc7_ != _h)
         {
            _loc2_ = new Vector.<int>(_loc1_ * _loc7_,true);
            _loc9_ = _loc3_;
            while(_loc9_ < _loc3_ + _loc7_)
            {
               _loc10_ = _loc9_ * _w + _offX;
               _loc12_ = 0;
               while(_loc12_ < _loc1_)
               {
                  _loc5_ = uint(_ba[_loc10_++]);
                  _loc2_[_loc11_++] = _loc5_;
                  _loc12_++;
               }
               _loc9_++;
            }
            _w = _loc1_;
            _h = _loc7_;
            _ba = _loc2_;
         }
      }
      
      private function processPackImage() : Object
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc5_:* = null;
         var _loc3_:* = 0;
         if(_ba == null)
         {
            return null;
         }
         var _loc6_:Object = {
            "x":_offX,
            "y":_offY,
            "w":_w,
            "h":_h
         };
         var _loc8_:ByteArray = new ByteArray();
         _loc6_.b = _loc8_;
         var _loc7_:int = int(_ba.length);
         var _loc1_:uint = 256;
         var _loc2_:uint = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc7_)
         {
            _loc3_ = uint(_ba[_loc4_++]);
            if(_loc1_ == 256)
            {
               _loc1_ = _loc3_;
            }
            else if(_loc3_ != _loc1_)
            {
               if(_loc2_)
               {
                  _loc1_ |= 128;
                  while(_loc2_ > 255)
                  {
                     _loc8_.writeByte(_loc1_);
                     _loc8_.writeByte(255);
                     _loc2_ -= 256;
                  }
                  if(_loc2_ > 0)
                  {
                     _loc8_.writeByte(_loc1_);
                     _loc8_.writeByte(_loc2_);
                  }
                  else
                  {
                     _loc8_.writeByte(uint(_loc1_ & 0x7F));
                  }
               }
               else
               {
                  _loc8_.writeByte(_loc1_);
               }
               _loc1_ = _loc3_;
               _loc2_ = 0;
            }
            else
            {
               _loc2_++;
            }
         }
         if(_loc2_ || _loc7_ == 1)
         {
            _loc1_ |= 128;
            while(_loc2_ > 255)
            {
               _loc8_.writeByte(_loc1_);
               _loc8_.writeByte(255);
               _loc2_ -= 256;
            }
            if(_loc2_ > 0)
            {
               _loc8_.writeByte(_loc1_);
               _loc8_.writeByte(_loc2_);
            }
            else
            {
               _loc8_.writeByte(uint(_loc1_ & 0x7F));
            }
         }
         return _loc6_;
      }
      
      private function findPaletteColor(param1:uint) : uint
      {
         var _loc6_:* = 0;
         var _loc4_:uint = uint((param1 & 0xFF000000) >> 24);
         if(_loc4_ < 160)
         {
            return 0;
         }
         param1 |= 4278190080;
         _loc6_ = 0;
         while(_loc6_ < 25)
         {
            if(_palette[_loc6_] == param1)
            {
               return _loc6_;
            }
            _loc6_++;
         }
         var _loc2_:int = param1 >> 16 & 0xFF;
         var _loc5_:int = param1 >> 8 & 0xFF;
         var _loc3_:int = param1 & 0xFF;
         return findClosetPaletteIndex(_loc2_,_loc5_,_loc3_);
      }
      
      private function findClosetPaletteIndex(param1:int, param2:int, param3:int) : int
      {
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc12_:* = 0;
         var _loc8_:* = 0;
         var _loc10_:int = 10000000;
         var _loc11_:int = 0;
         _loc12_ = 0;
         while(_loc12_ < 25)
         {
            _loc8_ = uint(_palette[_loc12_]);
            _loc7_ = (_loc8_ >> 16 & 0xFF) - param1;
            _loc4_ = (_loc8_ >> 8 & 0xFF) - param2;
            _loc6_ = (_loc8_ & 0xFF) - param3;
            _loc5_ = _loc7_ * _loc7_ + _loc4_ * _loc4_ + _loc6_ * _loc6_;
            if(_loc5_ < _loc10_)
            {
               _loc10_ = _loc5_;
               _loc11_ = _loc12_;
            }
            _loc12_++;
         }
         return _loc11_;
      }
      
      private function blendColors(param1:uint, param2:uint, param3:uint, param4:uint) : uint
      {
         var _loc11_:* = 0;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:int = 0;
         var _loc12_:int = 0;
         if(param1 == 0)
         {
            _loc8_++;
         }
         if(param2 == 0)
         {
            _loc8_++;
         }
         if(param3 == 0)
         {
            _loc8_++;
         }
         if(param4 == 0)
         {
            _loc8_++;
         }
         if(_loc8_ == 4)
         {
            return 0;
         }
         if(param1 == param2 && param1 == param3 && param1 == param4)
         {
            _loc11_ = param1;
         }
         else
         {
            _loc9_ = [param1,param2,param3,param4];
            while(_loc12_ < 4)
            {
               if(_loc9_[_loc12_] != 0)
               {
                  param1 = uint(_palette[_loc9_[_loc12_]]);
                  _loc6_ += param1 >> 16 & 0xFF;
                  _loc10_ += param1 >> 8 & 0xFF;
                  _loc7_ += param1 & 0xFF;
                  _loc5_++;
               }
               _loc12_++;
            }
            _loc6_ /= _loc5_;
            _loc10_ /= _loc5_;
            _loc7_ /= _loc5_;
            _loc11_ = uint(findClosetPaletteIndex(_loc6_,_loc10_,_loc7_));
         }
         return uint(_loc11_ + _loc8_ * 25);
      }
      
      private function blendShadowColors(param1:uint, param2:uint, param3:uint, param4:uint) : int
      {
         var _loc6_:uint = ((param1 >> 24 & 0xFF) + (param2 >> 24 & 0xFF) + (param3 >> 24 & 0xFF) + (param4 >> 24 & 0xFF)) / 4;
         var _loc5_:uint = ((param1 & 0xFF & 0xFF) + (param2 & 0xFF & 0xFF) + (param3 & 0xFF & 0xFF) + (param4 & 0xFF & 0xFF)) / 4;
         if(_loc6_)
         {
            _loc5_ += (255 - _loc5_) * ((255 - _loc6_) / 255);
            _loc5_ = uint(_loc5_ >> 3);
            if(_loc5_ == 0)
            {
               _loc5_ = 1;
            }
         }
         else
         {
            _loc5_ = 0;
         }
         return _loc5_;
      }
   }
}

