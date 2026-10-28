package Enums
{
   import localization.LocalizationManager;
   
   public class AdoptAPetDef
   {
      
      private var _defId:int;
      
      private var _titleStrId:int;
      
      private var _mediaRefId:int;
      
      private var _type:int;
      
      public function AdoptAPetDef(param1:int, param2:int, param3:int, param4:int)
      {
         super();
         _defId = param1;
         _titleStrId = param2;
         _mediaRefId = param3;
         _type = param4;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get titleStrId() : int
      {
         return _titleStrId;
      }
      
      public function get mediaRefId() : int
      {
         return _mediaRefId;
      }
      
      public function get name() : String
      {
         return LocalizationManager.translateIdOnly(_titleStrId);
      }
      
      public function get type() : int
      {
         return _type;
      }
   }
}

