package org.osmf.net.httpstreaming.f4f
{
   [ExcludeClass]
   internal class FullBox extends Box
   {
      
      private var _version:uint;
      
      private var _flags:uint;
      
      public function FullBox()
      {
         super();
      }
      
      public function get version() : uint
      {
         return this._version;
      }
      
      public function set version(value:uint) : void
      {
         this._version = value;
      }
      
      public function get flags() : uint
      {
         return this._flags;
      }
      
      public function set flags(value:uint) : void
      {
         this._flags = value;
      }
   }
}

