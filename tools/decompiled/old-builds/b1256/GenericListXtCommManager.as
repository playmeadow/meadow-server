package
{
   import com.sbi.client.SFEvent;
   import den.DenItem;
   import den.DenRoomItem;
   import gui.GenericListGuiManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   
   public class GenericListXtCommManager
   {
      
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
      
      public static const DEN_ROOM_FULL_SHOP_ID:int = 384;
      
      public static const MEDIA_EBOOK_1_ID:int = 23;
      
      public static const AVATAR_LIST_ID:int = 64;
      
      public static const CURR_SHOP_DIAMOND_AVATAR_LIST:int = 166;
      
      public static const DIAMOND_AVATAR_LIST_ID:int = 293;
      
      public static const MEDIA_JAG_CARD_LIST_ID:int = 10;
      
      public static const MEDIA_JAG_STAMP_LIST_ID:int = 44;
      
      public static const DIAMOND_PET_LIST:int = 214;
      
      private static var _requestCallbackQueue:Object;
      
      private static var _requestPassbackQueue:Object;
      
      private static var _streamQueue:Object;
      
      private static var _cachedResponses:Object;
      
      private static var _availDefs:Object;
      
      private static var _availDefExpireTime:int = 0;
      
      private static var _availUniqueListId:int;
      
      public function GenericListXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _cachedResponses = {};
         _requestCallbackQueue = {};
         _requestPassbackQueue = {};
         _streamQueue = {};
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
         if(_cachedResponses[param1] && param1 != 1)
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
         var _loc2_:Date = new Date();
         var _loc1_:uint = _loc2_.getTime() / 1000;
         if(_availDefExpireTime == 0 || _availDefExpireTime > 0 && _loc1_ >= _availDefExpireTime)
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
         var _loc14_:int = 0;
         var _loc12_:Object = null;
         var _loc5_:Array = null;
         var _loc15_:int = 0;
         var _loc6_:int = 0;
         var _loc10_:int = 0;
         var _loc13_:Boolean = false;
         var _loc11_:int = 0;
         var _loc9_:int = 0;
         switch(param1)
         {
            case 1000:
               _loc14_ = 0;
               break;
            case 1030:
               _loc14_ = 1;
               break;
            case 1040:
               _loc14_ = 3;
               break;
            case 1037:
               _loc14_ = 5;
               break;
            case 1054:
               _loc14_ = 6;
               break;
            case 1060:
               _loc12_ = {};
               _loc5_ = [];
               _loc10_ = 0;
               while(_loc10_ < param2.length)
               {
                  if(param2[_loc10_] is DenItem)
                  {
                     _loc15_ = 1030;
                  }
                  else
                  {
                     if(!(param2[_loc10_] is DenRoomItem))
                     {
                        throw new Error("Did not find type when loading combined list");
                     }
                     _loc15_ = 1040;
                  }
                  if(_loc12_[_loc15_] == null)
                  {
                     _loc12_[_loc15_] = _loc6_;
                     _loc5_[_loc6_] = {
                        "defType":_loc15_,
                        "items":[param2[_loc10_]]
                     };
                     _loc6_++;
                  }
                  else
                  {
                     _loc5_[_loc12_[_loc15_]].items.push(param2[_loc10_]);
                  }
                  _loc10_++;
               }
               _loc12_ = null;
               param2 = [];
               _loc10_ = 0;
               while(_loc10_ < _loc5_.length)
               {
                  filterList(int(_loc5_[_loc10_].defType),_loc5_[_loc10_].items);
                  param2 = param2.concat(_loc5_[_loc10_].items);
                  _loc10_++;
               }
               return;
            default:
               trace("filtering of gl is not setup for listDefType=" + param1 + ". Returning list passed in");
               return;
         }
         var _loc4_:Array = _availDefs[_loc14_];
         if(!_loc4_ || _loc4_.length <= 0)
         {
            return;
         }
         var _loc7_:int = 0;
         while(_loc7_ < param2.length)
         {
            _loc13_ = false;
            switch(_loc14_)
            {
               case 0:
                  _loc11_ = int(param2[_loc7_].defId);
                  break;
               case 1:
                  _loc11_ = int(param2[_loc7_].itemDefId);
                  break;
               case 3:
                  _loc11_ = int(param2[_loc7_].itemDefId);
                  break;
               case 5:
                  _loc11_ = int(param2[_loc7_]);
                  break;
               case 6:
                  _loc11_ = int(param2[_loc7_].diamondDefId);
                  break;
               default:
                  throw new Error("ERROR: Availability type=" + _loc14_ + " is not yet implemented!");
            }
            if(_loc11_ > 0)
            {
               _loc9_ = 0;
               while(_loc9_ < _loc4_.length)
               {
                  if(_loc11_ == _loc4_[_loc9_].defId)
                  {
                     if(_loc14_ != 5)
                     {
                        param2[_loc7_].endTime = _loc4_[_loc9_].endTime;
                     }
                     if(!_loc4_[_loc9_].active)
                     {
                        param2.splice(_loc7_,1);
                        if(param3)
                        {
                           if(_loc14_ == 5)
                           {
                              for each(var _loc8_:Array in param3)
                              {
                                 _loc8_.splice(_loc7_,1);
                              }
                           }
                           else
                           {
                              param3.splice(_loc7_,1);
                           }
                        }
                        _loc13_ = true;
                     }
                     break;
                  }
                  _loc9_++;
               }
            }
            if(!_loc13_)
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
               case 1000:
               case 1030:
               case 1040:
               case 1051:
               case 1054:
               case 1060:
                  handleItemResponse(param1,_loc2_);
                  break;
               case 1023:
                  handleLocalizationResponse(param1);
                  break;
               case 1033:
                  handleMediaResponse(param1);
                  break;
               case 1035:
                  handleFactResponse(param1);
                  break;
               case 1037:
                  handleStreamResponse(param1);
                  break;
               case 1003:
                  handleAvatarResponse(param1);
                  break;
               case 1048:
                  handleAvailabilityResponse(param1);
                  break;
               case 1049:
                  handleNamebarBadgeResposne(param1);
                  break;
               case 1052:
                  handleScriptResponse(param1);
                  break;
               case 1046:
                  handlePetResponse(param1);
                  break;
               case 1058:
                  handleEBookResponse(param1);
                  break;
               case 1024:
               case 1047:
                  handleSimpleResponse(param1);
            }
            return;
         }
         throw new Error("GenericListXtCommManager illegal data cmd:" + param1[0]);
      }
      
      public static function genericListTypeResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         var _loc3_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1038] = null;
         var _loc2_:Object = {};
         for each(var _loc5_:Object in _loc3_)
         {
            _loc4_ = {
               "defId":int(_loc5_.id),
               "typeId":int(_loc5_.typeId)
            };
            _loc2_[_loc5_.id] = _loc4_;
         }
         gMainFrame.userInfo.genericListDefs = _loc2_;
      }
      
      private static function handleItemResponse(param1:Array, param2:int) : void
      {
         var _loc7_:int = int(param1[2]);
         var _loc5_:Function = _requestCallbackQueue[_loc7_];
         var _loc4_:Object = _requestPassbackQueue[_loc7_];
         if(_loc5_ != null)
         {
            if(_loc4_)
            {
               _loc5_(_loc7_,param1,_loc4_);
            }
            else
            {
               _loc5_(_loc7_,param1);
            }
            for each(var _loc3_:Object in _requestCallbackQueue)
            {
               if(_loc3_ == _loc5_)
               {
                  delete _requestCallbackQueue[_loc7_];
                  break;
               }
            }
            if(_loc4_ != null)
            {
               for each(var _loc6_:Object in _requestPassbackQueue)
               {
                  if(_loc6_ == _loc4_)
                  {
                     delete _requestPassbackQueue[_loc7_];
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
         var _loc10_:int = 0;
         var _loc7_:int = 6;
         var _loc9_:int = int(param1[_loc7_++]);
         var _loc2_:Array = new Array(_loc9_);
         _loc10_ = 0;
         while(_loc10_ < _loc9_)
         {
            _loc2_[_loc10_] = param1[_loc7_++];
            _loc10_++;
         }
         var _loc8_:int = int(param1[2]);
         var _loc5_:Function = _requestCallbackQueue[_loc8_];
         var _loc4_:Object = _requestPassbackQueue[_loc8_];
         if(_loc5_ != null)
         {
            if(_loc4_)
            {
               _loc5_(_loc8_,_loc2_,_loc4_);
            }
            else
            {
               _loc5_(_loc8_,_loc2_);
            }
            for each(var _loc3_:Object in _requestCallbackQueue)
            {
               if(_loc3_ == _loc5_)
               {
                  delete _requestCallbackQueue[_loc8_];
                  break;
               }
            }
            if(_loc4_ != null)
            {
               for each(var _loc6_:Object in _requestPassbackQueue)
               {
                  if(_loc6_ == _loc4_)
                  {
                     delete _requestPassbackQueue[_loc8_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleMediaResponse(param1:Array) : void
      {
         var _loc11_:int = 0;
         var _loc9_:int = 6;
         var _loc6_:int = int(param1[_loc9_++]);
         var _loc2_:Array = new Array(_loc6_);
         var _loc3_:Array = new Array(_loc6_);
         _loc11_ = 0;
         while(_loc11_ < _loc6_)
         {
            _loc2_[_loc11_] = int(param1[_loc9_++]);
            _loc3_[_loc11_] = param1[_loc9_++];
            _loc11_++;
         }
         var _loc10_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc10_];
         var _loc5_:Object = _requestPassbackQueue[_loc10_];
         if(_loc7_ != null)
         {
            _loc7_(_loc10_,_loc2_,_loc3_);
            for each(var _loc4_:Object in _requestCallbackQueue)
            {
               if(_loc4_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc10_];
                  break;
               }
            }
            if(_loc5_ != null)
            {
               for each(var _loc8_:Object in _requestPassbackQueue)
               {
                  if(_loc8_ == _loc5_)
                  {
                     delete _requestPassbackQueue[_loc10_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleFactResponse(param1:Array) : void
      {
         var _loc11_:int = 0;
         var _loc3_:Object = null;
         var _loc9_:int = 6;
         var _loc2_:int = int(param1[_loc9_++]);
         var _loc4_:Array = [];
         _loc11_ = 0;
         while(_loc11_ < _loc2_)
         {
            _loc3_ = {
               "id":int(param1[_loc9_++]),
               "media":int(param1[_loc9_++]),
               "title":int(param1[_loc9_++]),
               "description":int(param1[_loc9_++]),
               "type":int(param1[_loc9_++]),
               "userVarId":int(param1[_loc9_++]),
               "bitIdx":int(param1[_loc9_++])
            };
            _loc4_.push(_loc3_);
            _loc11_++;
         }
         var _loc10_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc10_];
         var _loc6_:Object = _requestPassbackQueue[_loc10_];
         if(_loc7_ != null)
         {
            _loc7_(_loc4_);
            for each(var _loc5_:Object in _requestCallbackQueue)
            {
               if(_loc5_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc10_];
                  break;
               }
            }
            if(_loc6_ != null)
            {
               for each(var _loc8_:Object in _requestPassbackQueue)
               {
                  if(_loc8_ == _loc6_)
                  {
                     delete _requestPassbackQueue[_loc10_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleStreamResponse(param1:Array) : void
      {
         var _loc14_:Array = null;
         var _loc11_:int = 0;
         if(GenericListXtCommManager.isAvailListExpired())
         {
            if(GenericListGuiManager && GenericListGuiManager.movieSelector)
            {
               GenericListGuiManager.movieSelector.destroy();
               GenericListGuiManager.movieSelector = null;
            }
            GenericListXtCommManager.requestGenericList(1,handleStreamResponse,param1);
            return;
         }
         var _loc10_:int = 6;
         var _loc9_:String = param1[4];
         var _loc12_:int = int(param1[_loc10_++]);
         var _loc5_:Array = new Array(_loc12_);
         var _loc2_:Array = new Array(_loc12_);
         var _loc13_:Array = new Array(_loc12_);
         var _loc6_:Array = new Array(_loc12_);
         var _loc4_:Array = new Array(_loc12_);
         var _loc3_:Array = new Array(_loc12_);
         _loc11_ = 0;
         while(_loc11_ < _loc12_)
         {
            _loc5_[_loc11_] = int(param1[_loc10_++]);
            _loc2_[_loc11_] = int(param1[_loc10_++]);
            _loc14_ = param1[_loc10_++].split("|");
            _loc13_[_loc11_] = _loc14_[0];
            if(_loc14_[1])
            {
               _loc6_[_loc11_] = _loc14_[1];
            }
            else
            {
               _loc6_[_loc11_] = _loc14_[0];
            }
            _loc4_[_loc11_] = int(param1[_loc10_++]);
            _loc3_[_loc11_] = int(param1[_loc10_++]);
            _loc11_++;
         }
         var _loc15_:int = int(param1[2]);
         var _loc8_:Object = _streamQueue[_loc15_];
         if(_loc8_)
         {
            if(_loc8_.h)
            {
               _loc8_.h.titleTxt = _loc9_;
               _loc8_.c(_loc15_,_loc5_,_loc2_,_loc13_,_loc6_,_loc4_,_loc3_,_loc8_.h);
            }
            else
            {
               _loc8_.c(_loc15_,_loc5_,_loc2_,_loc13_,_loc6_,_loc4_,_loc3_);
            }
            for each(var _loc7_:Object in _streamQueue)
            {
               if(_loc7_ == _streamQueue[_loc15_])
               {
                  delete _streamQueue[_loc15_];
                  break;
               }
            }
         }
      }
      
      private static function handleAvatarResponse(param1:Array) : void
      {
         var _loc10_:int = 0;
         var _loc8_:int = 6;
         var _loc6_:int = int(param1[_loc8_++]);
         var _loc5_:Array = new Array(_loc6_);
         _loc10_ = 0;
         while(_loc10_ < _loc6_)
         {
            _loc5_[_loc10_] = int(param1[_loc8_++]);
            _loc10_++;
         }
         var _loc9_:int = int(param1[2]);
         var _loc4_:Function = _requestCallbackQueue[_loc9_];
         var _loc3_:Object = _requestPassbackQueue[_loc9_];
         if(_loc4_ != null)
         {
            _loc4_(_loc5_);
            for each(var _loc2_:Object in _requestCallbackQueue)
            {
               if(_loc2_ == _loc4_)
               {
                  delete _requestCallbackQueue[_loc9_];
                  break;
               }
            }
            if(_loc3_ != null)
            {
               for each(var _loc7_:Object in _requestPassbackQueue)
               {
                  if(_loc7_ == _loc3_)
                  {
                     delete _requestPassbackQueue[_loc9_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleAvailabilityResponse(param1:Array) : void
      {
         var _loc9_:Date = null;
         var _loc8_:int = 0;
         var _loc12_:int = 0;
         var _loc11_:int = int(param1[2]);
         var _loc10_:int = 4;
         _availUniqueListId = int(param1[_loc10_++]);
         var _loc3_:int = int(param1[_loc10_++]);
         var _loc2_:int = int(param1[_loc10_++]);
         if(_loc3_ < 0)
         {
            _availDefExpireTime = -1;
         }
         else
         {
            _loc9_ = new Date();
            _availDefExpireTime = _loc9_.getTime() / 1000 + _loc3_;
         }
         _availDefs = {};
         _loc12_ = 0;
         while(_loc12_ < _loc2_)
         {
            _loc8_ = int(param1[_loc10_++]);
            if(!_availDefs[_loc8_])
            {
               _availDefs[_loc8_] = [];
            }
            _availDefs[_loc8_].push({
               "defId":int(param1[_loc10_++]),
               "endTime":uint(param1[_loc10_++]),
               "active":param1[_loc10_++] == "1"
            });
            _loc12_++;
         }
         var _loc6_:Function = _requestCallbackQueue[_loc11_];
         var _loc5_:Object = _requestPassbackQueue[_loc11_];
         if(_loc6_ != null)
         {
            if(_loc5_)
            {
               _loc6_(_loc5_);
            }
            else
            {
               _loc6_();
            }
            for each(var _loc4_:Object in _requestCallbackQueue)
            {
               if(_loc4_ == _loc6_)
               {
                  delete _requestCallbackQueue[_loc11_];
                  break;
               }
            }
            if(_loc5_ != null)
            {
               for each(var _loc7_:Object in _requestPassbackQueue)
               {
                  if(_loc7_ == _loc5_)
                  {
                     delete _requestPassbackQueue[_loc11_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleNamebarBadgeResposne(param1:Array) : void
      {
         var _loc10_:int = 0;
         var _loc8_:int = 6;
         var _loc2_:int = int(param1[_loc8_++]);
         var _loc3_:Array = new Array(_loc2_);
         _loc10_ = 0;
         while(_loc10_ < _loc2_)
         {
            _loc3_[_loc10_] = int(param1[_loc8_++]);
            _loc10_++;
         }
         var _loc9_:int = int(param1[2]);
         var _loc6_:Function = _requestCallbackQueue[_loc9_];
         var _loc5_:Object = _requestPassbackQueue[_loc9_];
         if(_loc6_ != null)
         {
            _loc6_(_loc3_);
            for each(var _loc4_:Object in _requestCallbackQueue)
            {
               if(_loc4_ == _loc6_)
               {
                  delete _requestCallbackQueue[_loc9_];
                  break;
               }
            }
            if(_loc5_ != null)
            {
               for each(var _loc7_:Object in _requestPassbackQueue)
               {
                  if(_loc7_ == _loc5_)
                  {
                     delete _requestPassbackQueue[_loc9_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleScriptResponse(param1:Array) : void
      {
         var _loc9_:int = 0;
         var _loc7_:int = 6;
         var _loc10_:int = int(param1[_loc7_++]);
         var _loc5_:Array = new Array(_loc10_);
         _loc9_ = 0;
         while(_loc9_ < _loc10_)
         {
            _loc5_[_loc9_] = int(param1[_loc7_++]);
            _loc9_++;
         }
         var _loc8_:int = int(param1[2]);
         var _loc4_:Function = _requestCallbackQueue[_loc8_];
         var _loc3_:Object = _requestPassbackQueue[_loc8_];
         if(_loc4_ != null)
         {
            _loc4_(_loc8_,_loc5_,_loc3_);
            for each(var _loc2_:Object in _requestCallbackQueue)
            {
               if(_loc2_ == _loc4_)
               {
                  delete _requestCallbackQueue[_loc8_];
                  break;
               }
            }
            if(_loc3_ != null)
            {
               for each(var _loc6_:Object in _requestPassbackQueue)
               {
                  if(_loc6_ == _loc3_)
                  {
                     delete _requestPassbackQueue[_loc8_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handlePetResponse(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc10_:int = 0;
         var _loc8_:int = 6;
         var _loc11_:int = int(param1[_loc8_++]);
         var _loc2_:Array = [];
         _loc10_ = 0;
         while(_loc10_ < _loc11_)
         {
            _loc3_ = int(param1[_loc8_++]);
            if(param1[_loc8_++] == "1")
            {
               _loc2_.push(_loc3_);
            }
            _loc10_++;
         }
         var _loc9_:int = int(param1[2]);
         var _loc6_:Function = _requestCallbackQueue[_loc9_];
         var _loc5_:Object = _requestPassbackQueue[_loc9_];
         if(_loc6_ != null)
         {
            _loc6_(_loc9_,_loc2_,_loc5_);
            for each(var _loc4_:Object in _requestCallbackQueue)
            {
               if(_loc4_ == _loc6_)
               {
                  delete _requestCallbackQueue[_loc9_];
                  break;
               }
            }
            if(_loc5_ != null)
            {
               for each(var _loc7_:Object in _requestPassbackQueue)
               {
                  if(_loc7_ == _loc5_)
                  {
                     delete _requestPassbackQueue[_loc9_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleEBookResponse(param1:Array) : void
      {
         var _loc12_:int = 0;
         var _loc11_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc11_];
         var _loc4_:Object = _requestPassbackQueue[_loc11_];
         var _loc10_:int = 6;
         var _loc6_:int = int(param1[_loc10_++]);
         var _loc3_:Array = new Array(_loc6_);
         var _loc5_:Array = new Array(_loc6_);
         var _loc8_:Array = new Array(_loc6_);
         _loc12_ = 0;
         while(_loc12_ < _loc6_)
         {
            _loc3_[_loc12_] = int(param1[_loc10_++]);
            _loc5_[_loc12_] = int(param1[_loc10_++]);
            _loc8_[_loc12_] = int(param1[_loc10_++]);
            _loc12_++;
         }
         if(_loc7_ != null)
         {
            _loc7_(_loc11_,_loc3_,_loc5_,_loc8_,_loc4_);
            for each(var _loc2_:Object in _requestCallbackQueue)
            {
               if(_loc2_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc11_];
                  break;
               }
            }
            if(_loc4_ != null)
            {
               for each(var _loc9_:Object in _requestPassbackQueue)
               {
                  if(_loc9_ == _loc4_)
                  {
                     delete _requestPassbackQueue[_loc11_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleSimpleResponse(param1:Array) : void
      {
         var _loc10_:int = 0;
         var _loc9_:int = int(param1[2]);
         var _loc5_:Function = _requestCallbackQueue[_loc9_];
         var _loc3_:Object = _requestPassbackQueue[_loc9_];
         var _loc7_:int = 6;
         var _loc4_:int = int(param1[_loc7_++]);
         var _loc8_:Array = new Array(_loc4_);
         _loc10_ = 0;
         while(_loc10_ < _loc4_)
         {
            _loc8_[_loc10_] = int(param1[_loc7_++]);
            _loc10_++;
         }
         if(_loc5_ != null)
         {
            _loc5_(_loc9_,_loc8_,_loc3_);
            for each(var _loc2_:Object in _requestCallbackQueue)
            {
               if(_loc2_ == _loc5_)
               {
                  delete _requestCallbackQueue[_loc9_];
                  break;
               }
            }
            if(_loc3_ != null)
            {
               for each(var _loc6_:Object in _requestPassbackQueue)
               {
                  if(_loc6_ == _loc3_)
                  {
                     delete _requestPassbackQueue[_loc9_];
                     break;
                  }
               }
            }
         }
      }
   }
}

