package
{
   import com.sbi.client.SFEvent;
   import loader.LocalizationDefHelper;
   
   public class LocalizationXtCommManager
   {
      
      private static var _tsDefCache:Array;
      
      private static var _tsDefQueue:Array;
      
      public static var LANG_ENG:int = 1;
      
      public static var LANG_SPA:int = 2;
      
      public static var LANG_POR:int = 3;
      
      public static var LANG_FRE:int = 4;
      
      public function LocalizationXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _tsDefCache = [];
         _tsDefQueue = [];
      }
      
      public static function destroy() : void
      {
         _tsDefQueue = null;
         _tsDefCache = null;
      }
      
      public static function sendTranslateStringRequest(param1:int, param2:int, param3:Function, param4:Object = null) : void
      {
         var _loc5_:Object = null;
         var _loc6_:LocalizationDefHelper = null;
         if(param1 > 0)
         {
            _loc5_ = _tsDefCache[param1];
            if(!_loc5_)
            {
               _loc6_ = new LocalizationDefHelper();
               _loc6_.init(param1,onLocalizationDefReceived);
               _tsDefQueue[param1] = {
                  "ldh":_loc6_,
                  "c":param3,
                  "lId":param2,
                  "p":param4
               };
            }
            else if(param4)
            {
               param3(param1,textForDefAndLangId(_loc5_,param2),param4);
            }
            else
            {
               param3(param1,textForDefAndLangId(_loc5_,param2));
            }
         }
      }
      
      private static function onLocalizationDefReceived(param1:LocalizationDefHelper) : void
      {
         var _loc5_:Function = null;
         var _loc2_:Object = param1.def;
         var _loc3_:Object = {
            "id":int(_loc2_.id),
            "name":_loc2_.name,
            "eng":_loc2_.eng,
            "spa":_loc2_.spa,
            "por":_loc2_.por,
            "fre":_loc2_.fre
         };
         _tsDefCache[_loc3_.id] = _loc3_;
         var _loc4_:Object = _tsDefQueue[_loc3_.id];
         if(_loc4_)
         {
            _loc5_ = _loc4_.c;
            if(_loc5_ != null)
            {
               if(_loc4_.p)
               {
                  _loc5_(_loc3_.id,textForDefAndLangId(_loc3_,_loc4_.lId),_loc4_.p);
               }
               else
               {
                  _loc5_(_loc3_.id,textForDefAndLangId(_loc3_,_loc4_.lId));
               }
            }
            _tsDefQueue[_loc3_.id] = null;
         }
      }
      
      private static function textForDefAndLangId(param1:Object, param2:int) : String
      {
         if(param1)
         {
            switch(param2)
            {
               case LANG_ENG:
                  return param1.eng;
               case LANG_SPA:
                  return param1.spa;
               case LANG_POR:
                  return param1.por;
               case LANG_FRE:
                  return param1.fre;
            }
         }
         return "";
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         var _loc3_:* = _loc2_[0];
         switch(0)
         {
         }
         throw new Error("LocalizationXtCommManager illegal data:" + _loc2_[0]);
      }
   }
}

