package com.sbi.graphics
{
   import flash.utils.ByteArray;
   
   public class PaletteHelper
   {
      
      public static var gamePalette:Array;
      
      public static var avatarPalette1:Array;
      
      public static var avatarPalette2:Array;
      
      private static const PALETTE_ALPHA_OFFSET:int = 25;
      
      public function PaletteHelper()
      {
         super();
      }
      
      public static function setGamePalette(param1:ByteArray, param2:ByteArray = null, param3:ByteArray = null) : void
      {
         var _loc4_:int = param1.length / 4;
         gamePalette = new Array(_loc4_);
         var _loc5_:* = 0;
         while(_loc5_ < _loc4_)
         {
            var _loc6_:Number;
            gamePalette[_loc6_ = _loc5_++] = param1.readUnsignedInt();
         }
         if(param2)
         {
            _loc4_ = int(param2.length);
            avatarPalette1 = new Array(_loc4_);
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               avatarPalette1[_loc6_ = _loc5_++] = param2.readUnsignedByte();
            }
         }
         if(param3)
         {
            param3.position = 0;
            _loc4_ = int(param3.length);
            avatarPalette2 = new Array(_loc4_);
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               avatarPalette2[_loc6_ = _loc5_++] = param3.readUnsignedByte();
            }
         }
      }
      
      public static function mixColors(param1:uint, param2:uint) : uint
      {
         var _loc3_:uint = uint(param1 >> 16 & 0xFF);
         var _loc4_:uint = uint(param1 >> 8 & 0xFF);
         var _loc5_:uint = uint(param1 & 0xFF);
         var _loc6_:uint = uint(param2 >> 16 & 0xFF);
         var _loc7_:uint = uint(param2 >> 8 & 0xFF);
         var _loc8_:uint = uint(param2 & 0xFF);
         _loc3_ = (_loc3_ + _loc6_) / 2;
         _loc4_ = (_loc4_ + _loc7_) / 2;
         _loc5_ = (_loc5_ + _loc8_) / 2;
         return _loc3_ << 16 | _loc4_ << 8 | _loc5_;
      }
      
      public static function setColorGradient(param1:Array, param2:uint, param3:uint, param4:uint) : void
      {
         var _loc13_:uint = 0;
         var _loc5_:uint = uint(param2 >> 16 & 0xFF);
         var _loc6_:uint = uint(param2 >> 8 & 0xFF);
         var _loc7_:uint = uint(param2 & 0xFF);
         var _loc8_:uint = _loc5_ / (param4 + 2);
         var _loc9_:uint = _loc6_ / (param4 + 2);
         var _loc10_:uint = _loc7_ / (param4 + 2);
         var _loc11_:* = int(param3 + param4 - 1);
         var _loc12_:uint = 0;
         while(_loc12_ < param4)
         {
            _loc13_ = uint(_loc5_ << 16 | _loc6_ << 8 | _loc7_);
            param1[_loc11_] = _loc13_ | 255 << 24;
            param1[_loc11_ + PALETTE_ALPHA_OFFSET] = _loc13_ | 192 << 24;
            param1[_loc11_ + PALETTE_ALPHA_OFFSET * 2] = _loc13_ | 128 << 24;
            param1[_loc11_ + PALETTE_ALPHA_OFFSET * 3] = _loc13_ | 64 << 24;
            _loc5_ -= _loc8_;
            _loc6_ -= _loc9_;
            _loc7_ -= _loc10_;
            _loc11_--;
            _loc12_++;
         }
      }
      
      public static function AddRGB(param1:uint, param2:int, param3:int, param4:int) : uint
      {
         var _loc5_:int = param1 >> 24 & 0xFF;
         var _loc6_:int = param1 >> 16 & 0xFF;
         var _loc7_:int = param1 >> 8 & 0xFF;
         var _loc8_:int = param1 & 0xFF;
         _loc6_ += param2;
         if(_loc6_ < 0)
         {
            _loc6_ = 0;
         }
         else if(_loc6_ > 255)
         {
            _loc6_ = 255;
         }
         _loc7_ += param3;
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         else if(_loc7_ > 255)
         {
            _loc7_ = 255;
         }
         _loc8_ += param4;
         if(_loc8_ < 0)
         {
            _loc8_ = 0;
         }
         else if(_loc8_ > 255)
         {
            _loc8_ = 255;
         }
         return uint(_loc5_ << 24 | _loc6_ << 16 | _loc7_ << 8 | _loc8_);
      }
      
      public static function getAnimalPalette() : Array
      {
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc1_:Array = new Array(uint(4278255615),uint(4286513152),uint(4290707456),uint(4294901760),uint(4278222592),uint(4278238976),uint(4278255360),uint(4278190207),uint(4278190271),uint(4278190335),uint(4286545791),uint(4290756543),uint(4294967295),uint(4282400768),uint(4286611456),uint(4278206528),uint(4278222976),uint(4282384448),uint(4286578816),uint(4286595136),uint(4294934656),uint(4282417216),uint(4286644096),uint(4282400896),uint(4286611711),uint(4278190080));
         var _loc2_:uint = uint(192 << 24);
         var _loc3_:int = 0;
         while(_loc3_ < 3)
         {
            _loc4_ = 1;
            while(_loc4_ <= PALETTE_ALPHA_OFFSET)
            {
               _loc5_ = uint(_loc1_[_loc4_] & 0xFFFFFF);
               _loc6_ = uint(_loc5_ | _loc2_);
               _loc1_.push(_loc6_);
               _loc4_++;
            }
            _loc2_ -= 64 << 24;
            _loc3_++;
         }
         return _loc1_;
      }
      
      public static function BuildAnimalPalette(param1:Array, param2:uint, param3:uint, param4:uint, param5:uint) : void
      {
         setColorGradient(param1,param2,1,3);
         setColorGradient(param1,param3,4,3);
         setColorGradient(param1,param4,7,3);
         setColorGradient(param1,param5,10,3);
         setColorGradient(param1,PaletteHelper.mixColors(param2,param3),13,2);
         setColorGradient(param1,PaletteHelper.mixColors(param3,param4),15,2);
         setColorGradient(param1,PaletteHelper.mixColors(param2,param4),17,2);
         setColorGradient(param1,PaletteHelper.mixColors(param2,param5),19,2);
         setColorGradient(param1,PaletteHelper.mixColors(param3,param5),21,2);
         setColorGradient(param1,PaletteHelper.mixColors(param4,param5),23,2);
      }
      
      public static function adjustPaletteColor(param1:Array, param2:uint) : void
      {
         var _loc7_:int = 0;
         var _loc8_:uint = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc3_:Number = (param2 >> 24 & 0xFF) / 255;
         var _loc4_:int = param2 >> 16 & 0xFF;
         var _loc5_:int = param2 >> 8 & 0xFF;
         var _loc6_:int = param2 & 0xFF;
         while(_loc7_ < param1.length)
         {
            _loc8_ = uint(param1[_loc7_]);
            _loc9_ = _loc8_ >> 24 & 0xFF;
            _loc10_ = _loc8_ >> 16 & 0xFF;
            _loc11_ = _loc8_ >> 8 & 0xFF;
            _loc12_ = _loc8_ & 0xFF;
            _loc13_ = _loc4_ - _loc10_;
            _loc13_ = _loc13_ * _loc3_;
            _loc10_ += _loc13_;
            if(_loc10_ < 0)
            {
               _loc10_ = 0;
            }
            else if(_loc10_ > 255)
            {
               _loc10_ = 255;
            }
            _loc13_ = _loc5_ - _loc11_;
            _loc13_ = _loc13_ * _loc3_;
            _loc11_ += _loc13_;
            if(_loc11_ < 0)
            {
               _loc11_ = 0;
            }
            else if(_loc11_ > 255)
            {
               _loc11_ = 255;
            }
            _loc13_ = _loc6_ - _loc12_;
            _loc13_ = _loc13_ * _loc3_;
            _loc12_ += _loc13_;
            if(_loc12_ < 0)
            {
               _loc12_ = 0;
            }
            else if(_loc12_ > 255)
            {
               _loc12_ = 255;
            }
            param1[_loc7_] = uint(_loc9_ << 24 | _loc10_ << 16 | _loc11_ << 8 | _loc12_);
            _loc7_++;
         }
      }
      
      public static function getHexColorsFromPalette(param1:uint) : Array
      {
         var _loc2_:Array = [];
         _loc2_[0] = gamePalette[param1 >> 24 & 0xFF];
         _loc2_[1] = gamePalette[param1 >> 16 & 0xFF];
         _loc2_[2] = gamePalette[param1 >> 8 & 0xFF];
         _loc2_[3] = gamePalette[param1 & 0xFF];
         return _loc2_;
      }
      
      public static function getRGBColors(param1:uint) : Array
      {
         var _loc2_:Array = [];
         _loc2_[0] = decToRGBObj(gamePalette[param1 >> 24 & 0xFF]);
         _loc2_[1] = decToRGBObj(gamePalette[param1 >> 16 & 0xFF]);
         _loc2_[2] = decToRGBObj(gamePalette[param1 >> 8 & 0xFF]);
         _loc2_[3] = decToRGBObj(gamePalette[param1 & 0xFF]);
         return _loc2_;
      }
      
      private static function decToRGBObj(param1:uint) : Object
      {
         return {
            "r":param1 >> 16 & 0xFF,
            "g":param1 >> 8 & 0xFF,
            "b":param1 & 0xFF
         };
      }
   }
}

