package
{
   import flash.utils.getDefinitionByName;
   import localization.LocalizationManager;
   
   public function GETDEFINITIONBYNAME(param1:String) : *
   {
      var _loc2_:* = new (getDefinitionByName(param1) as Class)();
      LocalizationManager.findAllTextfields(_loc2_);
      return _loc2_;
   }
}

