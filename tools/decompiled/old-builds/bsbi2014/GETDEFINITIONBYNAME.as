package
{
   import flash.utils.getDefinitionByName;
   import localization.LocalizationManager;
   
   public function GETDEFINITIONBYNAME(a:String, localize:Boolean = true) : *
   {
      var item:* = new (getDefinitionByName(a) as Class)();
      if(localize)
      {
         LocalizationManager.findAllTextfields(item);
      }
      return item;
   }
}

