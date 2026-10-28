package org.osmf.media.pluginClasses
{
   [ExcludeClass]
   public class VersionUtils
   {
      
      public function VersionUtils()
      {
         super();
      }
      
      public static function parseVersionString(version:String) : Object
      {
         var versionInfo:Array = version.split(".");
         var major:int = 0;
         var minor:int = 0;
         if(versionInfo.length >= 1)
         {
            major = parseInt(versionInfo[0]);
         }
         if(versionInfo.length >= 2)
         {
            minor = parseInt(versionInfo[1]);
            if(minor < 10)
            {
               minor *= 10;
            }
         }
         return {
            "major":major,
            "minor":minor
         };
      }
   }
}

