package
{
   import com.sbi.client.SFEvent;
   import den.DenItem;
   import gui.GenericListGuiManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   
   public class GenericListXtCommManager
   {
      
      private static var _requestCallbackQueue:Object;
      
      private static var _streamQueue:Object;
      
      private static var _requestPassback:Object;
      
      private static var _cachedResponses:Object;
      
      private static var _availDefs:Object;
      
      private static var _availUniqueListId:int;
      
      public static const AVAIL_LIST_ID:int = 1;
      
      public static const AVAIL_TYPE_CLOTHING:int = 0;
      
      public static const AVAIL_TYPE_DEN_ACC:int = 1;
      
      public static const AVAIL_TYPE_PARTY:int = 2;
      
      public static const AVAIL_TYPE_DEN_ROOM:int = 3;
      
      public static const AVAIL_TYPE_ROOM:int = 4;
      
      public static const AVAIL_TYPE_STREAM:int = 5;
      
      public static const AVAIL_TYPE_DIAMOND:int = 6;
      
      public static const ACC_JAMAA_SHOP_ID:int = 11;
      
      public static const ACC_BAHARIBAY_SHOP_ID:int = 50;
      
      public static const DEN_ITEM_MAIN_SHOP_ID:int = 12;
      
      public static const DEN_ITEM_CRYSTALREEF_SHOP_ID:int = 51;
      
      public static const DEN_ITEM_AUDIO_SHOP_ID:int = 56;
      
      public static const DEN_ITEM_PET_LAND:int = 85;
      
      public static const DEN_ITEM_PET_OCEAN:int = 89;
      
      public static const DEN_ITEM_FIRST_TIME_SHOP_ID:int = 234;
      
      public static const REDEMPTION_STORE_LIST_ID:int = 172;
      
      public static const DEN_ROOM_SHOP_ID:int = 13;
      
      public static const DEN_ROOM_FULL_SHOP_ID:int = 215;
      
      public static const MEDIA_EBOOK_1_ID:int = 23;
      
      public static const AVATAR_LIST_ID:int = 64;
      
      public static const MEDIA_JAG_CARD_LIST_ID:int = 10;
      
      public static const MEDIA_JAG_STAMP_LIST_ID:int = 44;
      
      private static var _availDefExpireTime:int = 0;
      
      public function GenericListXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _cachedResponses = new Object();
         _requestCallbackQueue = new Object();
         _streamQueue = new Object();
      }
      
      public static function destroy() : void
      {
      }
      
      public static function requestGenericList(glId:int, callback:Function = null, passback:Object = null, isFromWorld:Boolean = true) : void
      {
         if(callback != null)
         {
            _requestCallbackQueue[glId] = callback;
         }
         _requestPassback = passback;
         if(Boolean(_cachedResponses[glId]) && glId != AVAIL_LIST_ID)
         {
            handleNewData(_cachedResponses[glId].concat());
         }
         else
         {
            gMainFrame.server.setXtObject_Str("gl",[glId],isFromWorld);
         }
      }
      
      public static function requestStreamList(glId:int, callback:Function, helper:Object = null) : void
      {
         _streamQueue[glId] = {
            "c":callback,
            "h":helper
         };
         if(Boolean(_cachedResponses[glId]))
         {
            handleNewData(_cachedResponses[glId].concat());
         }
         else
         {
            gMainFrame.server.setXtObject_Str("gl",[glId]);
         }
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Array = evt.obj;
         if(data[0] == "gl")
         {
            _cachedResponses[int(data[2])] = data;
         }
         handleNewData(data.concat());
      }
      
      public static function isAvailListExpired() : Boolean
      {
         var date:Date = new Date();
         var timeSeconds:uint = date.getTime() / 1000;
         if(_availDefExpireTime == 0 || _availDefExpireTime > 0 && timeSeconds >= _availDefExpireTime)
         {
            return true;
         }
         return false;
      }
      
      public static function getAvailListUniqueId() : int
      {
         return _availUniqueListId;
      }
      
      public static function getDefIdFromDef(def:Object) : int
      {
         var defId:int = 0;
         if(Boolean(def))
         {
            if(def is Item)
            {
               defId = int(def.defId);
            }
            else if(def is DenItem)
            {
               defId = int(def.itemDefId);
            }
         }
         return defId;
      }
      
      public static function filterList(listDefType:int, items:Array, extraList:Object = null) : void
      {
         var availType:int = 0;
         var removed:Boolean = false;
         var defId:int = 0;
         var j:int = 0;
         var a:Array = null;
         switch(listDefType)
         {
            case DefPacksDefHelper.DEF_ITEM:
               availType = AVAIL_TYPE_CLOTHING;
               break;
            case DefPacksDefHelper.DEF_DEN_ITEM:
               availType = AVAIL_TYPE_DEN_ACC;
               break;
            case DefPacksDefHelper.DEF_DEN_ROOM:
               availType = AVAIL_TYPE_DEN_ROOM;
               break;
            case DefPacksDefHelper.DEF_STREAM:
               availType = AVAIL_TYPE_STREAM;
               break;
            case DefPacksDefHelper.DEF_DIAMOND:
               availType = AVAIL_TYPE_DIAMOND;
               break;
            default:
               trace("filtering of gl is not setup for listDefType=" + listDefType + ". Returning list passed in");
               return;
         }
         var availDefs:Array = _availDefs[availType];
         if(!availDefs || availDefs.length <= 0)
         {
            return;
         }
         var newItemsIdx:int = 0;
         while(newItemsIdx < items.length)
         {
            removed = false;
            switch(availType)
            {
               case AVAIL_TYPE_CLOTHING:
                  defId = int(items[newItemsIdx].defId);
                  break;
               case AVAIL_TYPE_DEN_ACC:
                  defId = int(items[newItemsIdx].itemDefId);
                  break;
               case AVAIL_TYPE_DEN_ROOM:
                  defId = int(items[newItemsIdx].itemDefId);
                  break;
               case AVAIL_TYPE_STREAM:
                  defId = int(items[newItemsIdx]);
                  break;
               case AVAIL_TYPE_DIAMOND:
                  defId = int(items[newItemsIdx].diamondDefId);
                  break;
               default:
                  throw new Error("ERROR: Availability type=" + availType + " is not yet implemented!");
            }
            if(defId > 0)
            {
               for(j = 0; j < availDefs.length; j++)
               {
                  if(defId == availDefs[j].defId)
                  {
                     if(availType != AVAIL_TYPE_STREAM)
                     {
                        items[newItemsIdx].endTime = availDefs[j].endTime;
                     }
                     if(!availDefs[j].active)
                     {
                        items.splice(newItemsIdx,1);
                        if(Boolean(extraList))
                        {
                           if(availType == AVAIL_TYPE_STREAM)
                           {
                              for each(a in extraList)
                              {
                                 a.splice(newItemsIdx,1);
                              }
                           }
                           else
                           {
                              extraList.splice(newItemsIdx,1);
                           }
                        }
                        removed = true;
                     }
                     break;
                  }
               }
            }
            if(!removed)
            {
               newItemsIdx++;
            }
         }
      }
      
      private static function handleNewData(data:Array) : void
      {
         var defType:int = 0;
         if(data[0] == "gl")
         {
            defType = int(data[3]);
            switch(defType)
            {
               case DefPacksDefHelper.DEF_ITEM:
               case DefPacksDefHelper.DEF_DEN_ITEM:
               case DefPacksDefHelper.DEF_DEN_ROOM:
               case DefPacksDefHelper.DEF_CURRENCY_EXCHANGE:
               case DefPacksDefHelper.DEF_DIAMOND:
                  handleItemResponse(data,defType);
                  break;
               case DefPacksDefHelper.DEF_LOCALIZATION:
                  handleLocalizationResponse(data);
                  break;
               case DefPacksDefHelper.DEF_MEDIA:
                  handleMediaResponse(data);
                  break;
               case DefPacksDefHelper.DEF_FACT:
                  handleFactResponse(data);
                  break;
               case DefPacksDefHelper.DEF_STREAM:
                  handleStreamResponse(data);
                  break;
               case DefPacksDefHelper.DEF_AVATAR:
                  handleAvatarResponse(data);
                  break;
               case DefPacksDefHelper.DEF_AVAILABILITY:
                  handleAvailabilityResponse(data);
                  break;
               case DefPacksDefHelper.DEF_NAMEBAR_BADGE:
                  handleNamebarBadgeResposne(data);
                  break;
               case DefPacksDefHelper.DEF_SCRIPT:
                  handleScriptResponse(data);
            }
            return;
         }
         throw new Error("GenericListXtCommManager illegal data cmd:" + data[0]);
      }
      
      public static function genericListTypeResponse(dfdh:DefPacksDefHelper) : void
      {
         var obj:Object = null;
         var o:Object = null;
         var data:Object = dfdh.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_GENERIC_LIST_TYPE] = null;
         var gld:Object = new Object();
         for each(obj in data)
         {
            o = {
               "defId":int(obj.id),
               "typeId":int(obj.typeId)
            };
            gld[obj.id] = o;
         }
         gMainFrame.userInfo.genericListDefs = gld;
      }
      
      private static function handleItemResponse(data:Array, glType:int) : void
      {
         ItemXtCommManager.shopListResponse(data,glType);
      }
      
      private static function handleLocalizationResponse(data:Array) : void
      {
         var callbackObject:Object = null;
         var j:int = 6;
         var numLocalizationStrings:int = int(data[j++]);
         var locStrs:Array = new Array(numLocalizationStrings);
         for(var i:int = 0; i < numLocalizationStrings; i++)
         {
            locStrs[i] = data[j++];
         }
         var glId:int = int(data[2]);
         var callback:Function = _requestCallbackQueue[glId];
         if(callback != null)
         {
            callback(glId,locStrs);
            for each(callbackObject in _requestCallbackQueue)
            {
               if(callbackObject == callback)
               {
                  delete _requestCallbackQueue[glId];
                  break;
               }
            }
         }
      }
      
      private static function handleMediaResponse(data:Array) : void
      {
         var callbackObject:Object = null;
         var j:int = 6;
         var numMediaIds:int = int(data[j++]);
         var mediaIds:Array = new Array(numMediaIds);
         var locStrs:Array = new Array(numMediaIds);
         for(var i:int = 0; i < numMediaIds; i++)
         {
            mediaIds[i] = int(data[j++]);
            locStrs[i] = data[j++];
         }
         var glId:int = int(data[2]);
         var callback:Function = _requestCallbackQueue[glId];
         if(callback != null)
         {
            callback(glId,mediaIds,locStrs);
            for each(callbackObject in _requestCallbackQueue)
            {
               if(callbackObject == callback)
               {
                  delete _requestCallbackQueue[glId];
                  break;
               }
            }
         }
      }
      
      private static function handleFactResponse(data:Array) : void
      {
         var fact:Object = null;
         var callbackObject:Object = null;
         var j:int = 6;
         var numFacts:int = int(data[j++]);
         var factDefs:Array = new Array();
         for(var i:int = 0; i < numFacts; i++)
         {
            fact = {
               "id":int(data[j++]),
               "media":int(data[j++]),
               "title":int(data[j++]),
               "description":int(data[j++]),
               "type":int(data[j++]),
               "userVarId":int(data[j++]),
               "bitIdx":int(data[j++])
            };
            factDefs.push(fact);
         }
         var glId:int = int(data[2]);
         var callback:Function = _requestCallbackQueue[glId];
         if(callback != null)
         {
            callback(factDefs);
            for each(callbackObject in _requestCallbackQueue)
            {
               if(callbackObject == callback)
               {
                  delete _requestCallbackQueue[glId];
                  break;
               }
            }
         }
      }
      
      private static function handleStreamResponse(data:Array) : void
      {
         var temp:Array = null;
         var streamQueue:Object = null;
         if(GenericListXtCommManager.isAvailListExpired())
         {
            if(Boolean(GenericListGuiManager) && Boolean(GenericListGuiManager.movieSelector))
            {
               GenericListGuiManager.movieSelector.destroy();
               GenericListGuiManager.movieSelector = null;
            }
            GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVAIL_LIST_ID,handleStreamResponse,data);
            return;
         }
         var j:int = 6;
         var titleTxt:String = data[4];
         var numStreams:int = int(data[j++]);
         var streamIds:Array = new Array(numStreams);
         var thumbIds:Array = new Array(numStreams);
         var baseTitles:Array = new Array(numStreams);
         var indivTitles:Array = new Array(numStreams);
         var status:Array = new Array(numStreams);
         var subtitleIds:Array = new Array(numStreams);
         for(var i:int = 0; i < numStreams; i++)
         {
            streamIds[i] = int(data[j++]);
            thumbIds[i] = int(data[j++]);
            temp = data[j++].split("|");
            baseTitles[i] = temp[0];
            if(Boolean(temp[1]))
            {
               indivTitles[i] = temp[1];
            }
            else
            {
               indivTitles[i] = temp[0];
            }
            status[i] = int(data[j++]);
            subtitleIds[i] = int(data[j++]);
         }
         var glId:int = int(data[2]);
         var o:Object = _streamQueue[glId];
         if(Boolean(o))
         {
            if(Boolean(o.h))
            {
               o.h.titleTxt = titleTxt;
               o.c(glId,streamIds,thumbIds,baseTitles,indivTitles,status,subtitleIds,o.h);
            }
            else
            {
               o.c(glId,streamIds,thumbIds,baseTitles,indivTitles,status,subtitleIds);
            }
            for each(streamQueue in _streamQueue)
            {
               if(streamQueue == _streamQueue[glId])
               {
                  delete _streamQueue[glId];
                  break;
               }
            }
         }
      }
      
      private static function handleAvatarResponse(data:Array) : void
      {
         var callbackObject:Object = null;
         var j:int = 6;
         var numAvtDefIds:int = int(data[j++]);
         var avDefIds:Array = new Array(numAvtDefIds);
         for(var i:int = 0; i < numAvtDefIds; i++)
         {
            avDefIds[i] = int(data[j++]);
         }
         var glId:int = int(data[2]);
         var callback:Function = _requestCallbackQueue[glId];
         if(callback != null)
         {
            callback(avDefIds);
            for each(callbackObject in _requestCallbackQueue)
            {
               if(callbackObject == callback)
               {
                  delete _requestCallbackQueue[glId];
                  break;
               }
            }
         }
      }
      
      private static function handleAvailabilityResponse(data:Array) : void
      {
         var type:int = 0;
         var date:Date = null;
         var callbackObject:Object = null;
         var glId:int = int(data[2]);
         var j:int = 4;
         _availUniqueListId = int(data[j++]);
         var secUntilExpir:int = int(data[j++]);
         var numDefs:int = int(data[j++]);
         if(secUntilExpir < 0)
         {
            _availDefExpireTime = -1;
         }
         else
         {
            date = new Date();
            _availDefExpireTime = date.getTime() / 1000 + secUntilExpir;
         }
         _availDefs = new Object();
         for(var i:int = 0; i < numDefs; i++)
         {
            type = int(data[j++]);
            if(!_availDefs[type])
            {
               _availDefs[type] = [];
            }
            _availDefs[type].push({
               "defId":int(data[j++]),
               "endTime":uint(data[j++]),
               "active":data[j++] == "1"
            });
         }
         var callback:Function = _requestCallbackQueue[glId];
         if(callback != null)
         {
            if(Boolean(_requestPassback))
            {
               callback(_requestPassback);
               _requestPassback = null;
            }
            else
            {
               callback();
            }
            for each(callbackObject in _requestCallbackQueue)
            {
               if(callbackObject == callback)
               {
                  delete _requestCallbackQueue[glId];
                  break;
               }
            }
         }
      }
      
      private static function handleNamebarBadgeResposne(data:Array) : void
      {
         var callbackObject:Object = null;
         var j:int = 6;
         var numBadges:int = int(data[j++]);
         var badges:Array = new Array(numBadges);
         for(var i:int = 0; i < numBadges; i++)
         {
            badges[i] = int(data[j++]);
         }
         var glId:int = int(data[2]);
         var callback:Function = _requestCallbackQueue[glId];
         if(callback != null)
         {
            callback(badges);
            for each(callbackObject in _requestCallbackQueue)
            {
               if(callbackObject == callback)
               {
                  delete _requestCallbackQueue[glId];
                  break;
               }
            }
         }
      }
      
      private static function handleScriptResponse(data:Array) : void
      {
         var j:int = 6;
         var numItems:int = int(data[j++]);
         var scriptIds:Array = new Array(numItems);
         for(var i:int = 0; i < numItems; i++)
         {
            scriptIds[i] = int(data[j++]);
         }
         var glId:int = int(data[2]);
         var callback:Function = _requestCallbackQueue[glId];
         if(callback != null)
         {
            callback(glId,scriptIds,_requestPassback);
         }
      }
   }
}

