package org.osmf.net
{
   import org.osmf.utils.URL;
   
   [ExcludeClass]
   public class FMSURL extends URL
   {
      
      private static const APPNAME_START_INDEX:uint = 0;
      
      private static const INSTANCENAME_START_INDEX:uint = 2;
      
      private static const STREAMNAME_START_INDEX:uint = 4;
      
      private static const DEFAULT_INSTANCE_NAME:String = "_definst_";
      
      public static const MP4_STREAM:String = "mp4";
      
      public static const MP3_STREAM:String = "mp3";
      
      public static const ID3_STREAM:String = "id3";
      
      public static const QUERY_STRING_STREAM:String = "streamName";
      
      public static const QUERY_STRING_STREAMTYPE:String = "streamType";
      
      private var _useInstance:Boolean;
      
      private var _appName:String;
      
      private var _instanceName:String;
      
      private var _streamName:String;
      
      private var _fileFormat:String;
      
      private var _origins:Vector.<FMSHost>;
      
      private var _edges:Vector.<FMSHost>;
      
      public function FMSURL(url:String, useInstance:Boolean = false)
      {
         super(url);
         this._useInstance = useInstance;
         this._appName = "";
         this._instanceName = "";
         this._streamName = "";
         this._fileFormat = "";
         this.parsePath();
         this.parseQuery();
      }
      
      public function get useInstance() : Boolean
      {
         return this._useInstance;
      }
      
      public function get appName() : String
      {
         return this._appName;
      }
      
      public function get instanceName() : String
      {
         return this._instanceName;
      }
      
      public function get streamName() : String
      {
         return this._streamName;
      }
      
      public function get fileFormat() : String
      {
         return this._fileFormat;
      }
      
      public function get edges() : Vector.<FMSHost>
      {
         return this._edges;
      }
      
      public function get origins() : Vector.<FMSHost>
      {
         return this._origins;
      }
      
      private function parsePath() : void
      {
         var definstPattern:RegExp = null;
         var streamStartNdx:uint = 0;
         var i:int = 0;
         if(path == null || path.length == 0)
         {
            this._streamName = getParamValue(QUERY_STRING_STREAM);
            this._fileFormat = getParamValue(QUERY_STRING_STREAMTYPE);
            return;
         }
         var pattern:RegExp = /(\/)/;
         var result:Array = path.split(pattern);
         if(result != null)
         {
            this._appName = result[APPNAME_START_INDEX];
            this._instanceName = "";
            this._streamName = "";
            definstPattern = new RegExp("^.*/" + DEFAULT_INSTANCE_NAME,"i");
            if(path.search(definstPattern) > -1)
            {
               this._useInstance = true;
            }
            streamStartNdx = STREAMNAME_START_INDEX;
            if(this._useInstance)
            {
               this._instanceName = result[INSTANCENAME_START_INDEX];
            }
            else
            {
               streamStartNdx = INSTANCENAME_START_INDEX;
            }
            for(i = int(streamStartNdx); i < result.length; i++)
            {
               this._streamName += result[i];
            }
            if(this._streamName == null || this._streamName == "")
            {
               this._streamName = getParamValue(QUERY_STRING_STREAM);
            }
            if(this._streamName.search(/^mp4:/i) > -1)
            {
               this._fileFormat = MP4_STREAM;
            }
            else if(this._streamName.search(/^mp3:/i) > -1)
            {
               this._fileFormat = MP3_STREAM;
            }
            else if(this._streamName.search(/^id3:/i) > -1)
            {
               this._fileFormat = ID3_STREAM;
            }
            if(this._fileFormat == null || this._fileFormat == "")
            {
               this._fileFormat = getParamValue(QUERY_STRING_STREAMTYPE);
            }
         }
         var mp4PrefixStart:int = this._streamName.indexOf("/mp4:");
         var mp3PrefixStart:int = this._streamName.indexOf("/mp3:");
         var id3PrefixStart:int = this._streamName.indexOf("/id3:");
         var prefixStart:int = -1;
         if(mp4PrefixStart > 0)
         {
            prefixStart = mp4PrefixStart;
         }
         else if(mp3PrefixStart > 0)
         {
            prefixStart = mp3PrefixStart;
         }
         else if(id3PrefixStart > 0)
         {
            prefixStart = id3PrefixStart;
         }
         if(this.useInstance && prefixStart > 0)
         {
            this._instanceName += "/";
            this._instanceName += this._streamName.substr(0,prefixStart);
            this._streamName = this.streamName.substr(prefixStart + 1);
         }
      }
      
      private function parseQuery() : void
      {
         var tempIndex:int = 0;
         var tempNdex:int = 0;
         var tempFMSURL:FMSURL = null;
         if(query == null || query.length == 0 || query.search(/:\//) == -1)
         {
            return;
         }
         var edgeOriginURIs:Array = query.split("?");
         for(var ndx:int = 0; ndx < edgeOriginURIs.length; ndx++)
         {
            tempIndex = int(edgeOriginURIs[ndx].toString().search(/:\//));
            if(tempIndex == -1)
            {
               edgeOriginURIs.splice(ndx,1);
            }
         }
         var hasEdge:Boolean = false;
         var originIndex:int = 0;
         if(edgeOriginURIs.length >= 2)
         {
            hasEdge = true;
            originIndex = edgeOriginURIs.length - 1;
         }
         var tempSN:String = "";
         var tempPN:String = "";
         var colonIndex:int = 0;
         var slashIndex:int = 0;
         var startIndex:int = 0;
         var endIndex:int = 0;
         for(var i:int = 0; i < edgeOriginURIs.length; i++)
         {
            tempNdex = int(edgeOriginURIs[i].toString().search(/:\//));
            startIndex = tempNdex + 2;
            if(edgeOriginURIs[i].charAt(startIndex) == "/")
            {
               startIndex++;
            }
            colonIndex = int(edgeOriginURIs[i].indexOf(":",startIndex));
            slashIndex = int(edgeOriginURIs[i].indexOf("/",startIndex));
            if(slashIndex < 0 && colonIndex < 0)
            {
               tempSN = edgeOriginURIs[i].slice(startIndex);
            }
            else if(colonIndex >= 0 && colonIndex < slashIndex)
            {
               endIndex = colonIndex;
               tempSN = edgeOriginURIs[i].slice(startIndex,endIndex);
               startIndex = endIndex + 1;
               endIndex = slashIndex;
               tempPN = edgeOriginURIs[i].slice(startIndex,endIndex);
            }
            else if(edgeOriginURIs[i].indexOf("://") != -1)
            {
               endIndex = slashIndex;
               tempSN = edgeOriginURIs[i].slice(startIndex,endIndex);
            }
            else
            {
               endIndex = int(edgeOriginURIs[i].indexOf("/"));
               tempSN = "localhost";
            }
            if(i == originIndex)
            {
               if(this._origins == null)
               {
                  this._origins = new Vector.<FMSHost>();
               }
               this._origins.push(new FMSHost(tempSN,tempPN));
               tempFMSURL = new FMSURL(edgeOriginURIs[i],this._useInstance);
               if(this._appName == "")
               {
                  this._appName = tempFMSURL.appName;
               }
               if(this._useInstance && this._instanceName == "")
               {
                  this._instanceName = tempFMSURL.instanceName;
               }
               if(this._streamName == "")
               {
                  this._streamName = tempFMSURL.streamName;
               }
            }
            else if(edgeOriginURIs[i] != query && hasEdge)
            {
               if(this._edges == null)
               {
                  this._edges = new Vector.<FMSHost>();
               }
               this._edges.push(new FMSHost(tempSN,tempPN));
            }
         }
      }
   }
}

