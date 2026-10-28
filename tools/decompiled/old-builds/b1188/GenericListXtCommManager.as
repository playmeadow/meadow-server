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
      
      private static var _requestPassbackQueue:Object;
      
      private static var _streamQueue:Object;
      
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
      
      public static const CURR_SHOP_DIAMOND_AVATAR_LIST:int = 166;
      
      public static const DIAMOND_AVATAR_LIST_ID:int = 293;
      
      public static const MEDIA_JAG_CARD_LIST_ID:int = 10;
      
      public static const MEDIA_JAG_STAMP_LIST_ID:int = 44;
      
      public static const DIAMOND_PET_LIST:int = 214;
      
      private static var _availDefExpireTime:int = 0;
      
      public function GenericListXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _cachedResponses = new Object();
         _requestCallbackQueue = new Object();
         _requestPassbackQueue = new Object();
         _streamQueue = new Object();
      }
      
      public static function destroy() : void
      {
      }
      
      public static function requestGenericList(param1:int, param2:Function = null, param3:Object = null, param4:Boolean = true) : void
      {
         if(param2 != null)
         {
            _requestCallbackQueue[param1] = param2;
         }
         if(param3 != null)
         {
            _requestPassbackQueue[param1] = param3;
         }
         if(Boolean(_cachedResponses[param1]) && param1 != AVAIL_LIST_ID)
         {
            handleNewData(_cachedResponses[param1].concat());
         }
         else
         {
            gMainFrame.server.setXtObject_Str("gl",[param1],param4);
         }
      }
      
      public static function requestStreamList(param1:int, param2:Function, param3:Object = null) : void
      {
         _streamQueue[param1] = {
            "c":param2,
            "h":param3
         };
         if(_cachedResponses[param1])
         {
            handleNewData(_cachedResponses[param1].concat());
         }
         else
         {
            gMainFrame.server.setXtObject_Str("gl",[param1]);
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         if(_loc2_[0] == "gl")
         {
            _cachedResponses[int(_loc2_[2])] = _loc2_;
         }
         handleNewData(_loc2_.concat());
      }
      
      public static function isAvailListExpired() : Boolean
      {
         var _loc1_:Date = new Date();
         var _loc2_:uint = _loc1_.getTime() / 1000;
         if(_availDefExpireTime == 0 || _availDefExpireTime > 0 && _loc2_ >= _availDefExpireTime)
         {
            return true;
         }
         return false;
      }
      
      public static function getAvailListUniqueId() : int
      {
         return _availUniqueListId;
      }
      
      public static function getDefIdFromDef(param1:Object) : int
      {
         var _loc2_:int = 0;
         if(param1)
         {
            if(param1 is Item)
            {
               _loc2_ = int(param1.defId);
            }
            else if(param1 is DenItem)
            {
               _loc2_ = int(param1.itemDefId);
            }
         }
         return _loc2_;
      }
      
      public static function filterList(param1:int, param2:Array, param3:Object = null) : void
      {
         var _loc4_:int = 0;
         var _loc6_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         switch(param1)
         {
            case DefPacksDefHelper.DEF_ITEM:
               _loc4_ = AVAIL_TYPE_CLOTHING;
               break;
            case DefPacksDefHelper.DEF_DEN_ITEM:
               _loc4_ = AVAIL_TYPE_DEN_ACC;
               break;
            case DefPacksDefHelper.DEF_DEN_ROOM:
               _loc4_ = AVAIL_TYPE_DEN_ROOM;
               break;
            case DefPacksDefHelper.DEF_STREAM:
               _loc4_ = AVAIL_TYPE_STREAM;
               break;
            case DefPacksDefHelper.DEF_DIAMOND:
               _loc4_ = AVAIL_TYPE_DIAMOND;
               break;
            default:
               return;
         }
         var _loc5_:Array = _availDefs[_loc4_];
         if(!_loc5_ || _loc5_.length <= 0)
         {
            return;
         }
         var _loc7_:int = 0;
         while(_loc7_ < param2.length)
         {
            _loc6_ = false;
            switch(_loc4_)
            {
               case AVAIL_TYPE_CLOTHING:
                  _loc8_ = int(param2[_loc7_].defId);
                  break;
               case AVAIL_TYPE_DEN_ACC:
                  _loc8_ = int(param2[_loc7_].itemDefId);
                  break;
               case AVAIL_TYPE_DEN_ROOM:
                  _loc8_ = int(param2[_loc7_].itemDefId);
                  break;
               case AVAIL_TYPE_STREAM:
                  _loc8_ = int(param2[_loc7_]);
                  break;
               case AVAIL_TYPE_DIAMOND:
                  _loc8_ = int(param2[_loc7_].diamondDefId);
                  break;
               default:
                  throw new Error("ERROR: Availability type=" + _loc4_ + " is not yet implemented!");
            }
            if(_loc8_ > 0)
            {
               _loc9_ = 0;
               while(_loc9_ < _loc5_.length)
               {
                  if(_loc8_ == _loc5_[_loc9_].defId)
                  {
                     if(_loc4_ != AVAIL_TYPE_STREAM)
                     {
                        param2[_loc7_].endTime = _loc5_[_loc9_].endTime;
                     }
                     if(!_loc5_[_loc9_].active)
                     {
                        param2.splice(_loc7_,1);
                        if(param3)
                        {
                           if(_loc4_ == AVAIL_TYPE_STREAM)
                           {
                              for each(_loc10_ in param3)
                              {
                                 _loc10_.splice(_loc7_,1);
                              }
                           }
                           else
                           {
                              param3.splice(_loc7_,1);
                           }
                        }
                        _loc6_ = true;
                     }
                     break;
                  }
                  _loc9_++;
               }
            }
            if(!_loc6_)
            {
               _loc7_++;
            }
         }
      }
      
      private static function handleNewData(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1[0] == "gl")
         {
            _loc2_ = int(param1[3]);
            switch(_loc2_)
            {
               case DefPacksDefHelper.DEF_ITEM:
               case DefPacksDefHelper.DEF_DEN_ITEM:
               case DefPacksDefHelper.DEF_DEN_ROOM:
               case DefPacksDefHelper.DEF_CURRENCY_EXCHANGE:
               case DefPacksDefHelper.DEF_DIAMOND:
                  handleItemResponse(param1,_loc2_);
                  break;
               case DefPacksDefHelper.DEF_LOCALIZATION:
                  handleLocalizationResponse(param1);
                  break;
               case DefPacksDefHelper.DEF_MEDIA:
                  handleMediaResponse(param1);
                  break;
               case DefPacksDefHelper.DEF_FACT:
                  handleFactResponse(param1);
                  break;
               case DefPacksDefHelper.DEF_STREAM:
                  handleStreamResponse(param1);
                  break;
               case DefPacksDefHelper.DEF_AVATAR:
                  handleAvatarResponse(param1);
                  break;
               case DefPacksDefHelper.DEF_AVAILABILITY:
                  handleAvailabilityResponse(param1);
                  break;
               case DefPacksDefHelper.DEF_NAMEBAR_BADGE:
                  handleNamebarBadgeResposne(param1);
                  break;
               case DefPacksDefHelper.DEF_SCRIPT:
                  handleScriptResponse(param1);
                  break;
               case DefPacksDefHelper.DEF_PET:
                  handlePetResponse(param1);
            }
            return;
         }
         throw new Error("GenericListXtCommManager illegal data cmd:" + param1[0]);
      }
      
      public static function genericListTypeResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_GENERIC_LIST_TYPE] = null;
         var _loc3_:Object = new Object();
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = {
               "defId":int(_loc4_.id),
               "typeId":int(_loc4_.typeId)
            };
            _loc3_[_loc4_.id] = _loc5_;
         }
         gMainFrame.userInfo.genericListDefs = _loc3_;
      }
      
      private static function handleItemResponse(param1:Array, param2:int) : void
      {
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc3_:int = int(param1[2]);
         var _loc4_:Function = _requestCallbackQueue[_loc3_];
         var _loc5_:Object = _requestPassbackQueue[_loc3_];
         if(_loc4_ != null)
         {
            if(_loc5_)
            {
               _loc4_(_loc3_,param1,_loc5_);
            }
            else
            {
               _loc4_(_loc3_,param1);
            }
            for each(_loc6_ in _requestCallbackQueue)
            {
               if(_loc6_ == _loc4_)
               {
                  delete _requestCallbackQueue[_loc3_];
                  break;
               }
            }
            if(_loc5_ != null)
            {
               for each(_loc7_ in _requestPassbackQueue)
               {
                  if(_loc7_ == _loc5_)
                  {
                     delete _requestPassbackQueue[_loc3_];
                     break;
                  }
               }
            }
         }
         else
         {
            ItemXtCommManager.shopListResponse(param1,param2);
         }
      }
      
      private static function handleLocalizationResponse(param1:Array) : void
      {
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc2_:* = 6;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Array = new Array(_loc3_);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_[_loc5_] = param1[_loc2_++];
            _loc5_++;
         }
         var _loc6_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc6_];
         var _loc8_:Object = _requestPassbackQueue[_loc6_];
         if(_loc7_ != null)
         {
            _loc7_(_loc6_,_loc4_);
            for each(_loc9_ in _requestCallbackQueue)
            {
               if(_loc9_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc6_];
                  break;
               }
            }
            if(_loc8_ != null)
            {
               for each(_loc10_ in _requestPassbackQueue)
               {
                  if(_loc10_ == _loc8_)
                  {
                     delete _requestPassbackQueue[_loc6_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleMediaResponse(param1:Array) : void
      {
         var _loc10_:Object = null;
         var _loc11_:Object = null;
         var _loc2_:* = 6;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Array = new Array(_loc3_);
         var _loc5_:Array = new Array(_loc3_);
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_)
         {
            _loc4_[_loc6_] = int(param1[_loc2_++]);
            _loc5_[_loc6_] = param1[_loc2_++];
            _loc6_++;
         }
         var _loc7_:int = int(param1[2]);
         var _loc8_:Function = _requestCallbackQueue[_loc7_];
         var _loc9_:Object = _requestPassbackQueue[_loc7_];
         if(_loc8_ != null)
         {
            _loc8_(_loc7_,_loc4_,_loc5_);
            for each(_loc10_ in _requestCallbackQueue)
            {
               if(_loc10_ == _loc8_)
               {
                  delete _requestCallbackQueue[_loc7_];
                  break;
               }
            }
            if(_loc9_ != null)
            {
               for each(_loc11_ in _requestPassbackQueue)
               {
                  if(_loc11_ == _loc9_)
                  {
                     delete _requestPassbackQueue[_loc7_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleFactResponse(param1:Array) : void
      {
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc11_:Object = null;
         var _loc2_:* = 6;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Array = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc9_ = {
               "id":int(param1[_loc2_++]),
               "media":int(param1[_loc2_++]),
               "title":int(param1[_loc2_++]),
               "description":int(param1[_loc2_++]),
               "type":int(param1[_loc2_++]),
               "userVarId":int(param1[_loc2_++]),
               "bitIdx":int(param1[_loc2_++])
            };
            _loc4_.push(_loc9_);
            _loc5_++;
         }
         var _loc6_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc6_];
         var _loc8_:Object = _requestPassbackQueue[_loc6_];
         if(_loc7_ != null)
         {
            _loc7_(_loc4_);
            for each(_loc10_ in _requestCallbackQueue)
            {
               if(_loc10_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc6_];
                  break;
               }
            }
            if(_loc8_ != null)
            {
               for each(_loc11_ in _requestPassbackQueue)
               {
                  if(_loc11_ == _loc8_)
                  {
                     delete _requestPassbackQueue[_loc6_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleStreamResponse(param1:Array) : void
      {
         var _loc11_:Array = null;
         var _loc15_:Object = null;
         if(GenericListXtCommManager.isAvailListExpired())
         {
            if(Boolean(GenericListGuiManager) && Boolean(GenericListGuiManager.movieSelector))
            {
               GenericListGuiManager.movieSelector.destroy();
               GenericListGuiManager.movieSelector = null;
            }
            GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVAIL_LIST_ID,handleStreamResponse,param1);
            return;
         }
         var _loc2_:* = 6;
         var _loc3_:String = param1[4];
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:Array = new Array(_loc4_);
         var _loc6_:Array = new Array(_loc4_);
         var _loc7_:Array = new Array(_loc4_);
         var _loc8_:Array = new Array(_loc4_);
         var _loc9_:Array = new Array(_loc4_);
         var _loc10_:Array = new Array(_loc4_);
         var _loc12_:int = 0;
         while(_loc12_ < _loc4_)
         {
            _loc5_[_loc12_] = int(param1[_loc2_++]);
            _loc6_[_loc12_] = int(param1[_loc2_++]);
            _loc11_ = param1[_loc2_++].split("|");
            _loc7_[_loc12_] = _loc11_[0];
            if(_loc11_[1])
            {
               _loc8_[_loc12_] = _loc11_[1];
            }
            else
            {
               _loc8_[_loc12_] = _loc11_[0];
            }
            _loc9_[_loc12_] = int(param1[_loc2_++]);
            _loc10_[_loc12_] = int(param1[_loc2_++]);
            _loc12_++;
         }
         var _loc13_:int = int(param1[2]);
         var _loc14_:Object = _streamQueue[_loc13_];
         if(_loc14_)
         {
            if(_loc14_.h)
            {
               _loc14_.h.titleTxt = _loc3_;
               _loc14_.c(_loc13_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,_loc10_,_loc14_.h);
            }
            else
            {
               _loc14_.c(_loc13_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,_loc10_);
            }
            for each(_loc15_ in _streamQueue)
            {
               if(_loc15_ == _streamQueue[_loc13_])
               {
                  delete _streamQueue[_loc13_];
                  break;
               }
            }
         }
      }
      
      private static function handleAvatarResponse(param1:Array) : void
      {
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc2_:* = 6;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Array = new Array(_loc3_);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_[_loc5_] = int(param1[_loc2_++]);
            _loc5_++;
         }
         var _loc6_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc6_];
         var _loc8_:Object = _requestPassbackQueue[_loc6_];
         if(_loc7_ != null)
         {
            _loc7_(_loc4_);
            for each(_loc9_ in _requestCallbackQueue)
            {
               if(_loc9_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc6_];
                  break;
               }
            }
            if(_loc8_ != null)
            {
               for each(_loc10_ in _requestPassbackQueue)
               {
                  if(_loc10_ == _loc8_)
                  {
                     delete _requestPassbackQueue[_loc6_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleAvailabilityResponse(param1:Array) : void
      {
         var _loc6_:int = 0;
         var _loc10_:Date = null;
         var _loc11_:Object = null;
         var _loc12_:Object = null;
         var _loc2_:int = int(param1[2]);
         var _loc3_:* = 4;
         _availUniqueListId = int(param1[_loc3_++]);
         var _loc4_:int = int(param1[_loc3_++]);
         var _loc5_:int = int(param1[_loc3_++]);
         if(_loc4_ < 0)
         {
            _availDefExpireTime = -1;
         }
         else
         {
            _loc10_ = new Date();
            _availDefExpireTime = _loc10_.getTime() / 1000 + _loc4_;
         }
         _availDefs = new Object();
         var _loc7_:int = 0;
         while(_loc7_ < _loc5_)
         {
            _loc6_ = int(param1[_loc3_++]);
            if(!_availDefs[_loc6_])
            {
               _availDefs[_loc6_] = [];
            }
            _availDefs[_loc6_].push({
               "defId":int(param1[_loc3_++]),
               "endTime":uint(param1[_loc3_++]),
               "active":param1[_loc3_++] == "1"
            });
            _loc7_++;
         }
         var _loc8_:Function = _requestCallbackQueue[_loc2_];
         var _loc9_:Object = _requestPassbackQueue[_loc2_];
         if(_loc8_ != null)
         {
            if(_loc9_)
            {
               _loc8_(_loc9_);
            }
            else
            {
               _loc8_();
            }
            for each(_loc11_ in _requestCallbackQueue)
            {
               if(_loc11_ == _loc8_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc9_ != null)
            {
               for each(_loc12_ in _requestPassbackQueue)
               {
                  if(_loc12_ == _loc9_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleNamebarBadgeResposne(param1:Array) : void
      {
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc2_:* = 6;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Array = new Array(_loc3_);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_[_loc5_] = int(param1[_loc2_++]);
            _loc5_++;
         }
         var _loc6_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc6_];
         var _loc8_:Object = _requestPassbackQueue[_loc6_];
         if(_loc7_ != null)
         {
            _loc7_(_loc4_);
            for each(_loc9_ in _requestCallbackQueue)
            {
               if(_loc9_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc6_];
                  break;
               }
            }
            if(_loc8_ != null)
            {
               for each(_loc10_ in _requestPassbackQueue)
               {
                  if(_loc10_ == _loc8_)
                  {
                     delete _requestPassbackQueue[_loc6_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleScriptResponse(param1:Array) : void
      {
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc2_:* = 6;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:Array = new Array(_loc3_);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_[_loc5_] = int(param1[_loc2_++]);
            _loc5_++;
         }
         var _loc6_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc6_];
         var _loc8_:Object = _requestPassbackQueue[_loc6_];
         if(_loc7_ != null)
         {
            _loc7_(_loc6_,_loc4_,_loc8_);
            for each(_loc9_ in _requestCallbackQueue)
            {
               if(_loc9_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc6_];
                  break;
               }
            }
            if(_loc8_ != null)
            {
               for each(_loc10_ in _requestPassbackQueue)
               {
                  if(_loc10_ == _loc8_)
                  {
                     delete _requestPassbackQueue[_loc6_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handlePetResponse(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc10_:Object = null;
         var _loc11_:Object = null;
         var _loc2_:* = 6;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc5_:Array = new Array();
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_)
         {
            _loc4_ = int(param1[_loc2_++]);
            if(param1[_loc2_++] == "1")
            {
               _loc5_.push(_loc4_);
            }
            _loc6_++;
         }
         var _loc7_:int = int(param1[2]);
         var _loc8_:Function = _requestCallbackQueue[_loc7_];
         var _loc9_:Object = _requestPassbackQueue[_loc7_];
         if(_loc8_ != null)
         {
            _loc8_(_loc7_,_loc5_,_loc9_);
            for each(_loc10_ in _requestCallbackQueue)
            {
               if(_loc10_ == _loc8_)
               {
                  delete _requestCallbackQueue[_loc7_];
                  break;
               }
            }
            if(_loc9_ != null)
            {
               for each(_loc11_ in _requestPassbackQueue)
               {
                  if(_loc11_ == _loc9_)
                  {
                     delete _requestPassbackQueue[_loc7_];
                     break;
                  }
               }
            }
         }
      }
   }
}

