package
{
   import flash.utils.getDefinitionByName;
   import localization.LocalizationManager;
   
   public function GETDEFINITIONBYNAME(param1:String, param2:Boolean = true) : *
   {
      var _loc3_:* = new (getDefinitionByName(param1) as Class)();
      if(param2)
      {
         LocalizationManager.findAllTextfields(_loc3_);
      }
      return _loc3_;
   }
}

