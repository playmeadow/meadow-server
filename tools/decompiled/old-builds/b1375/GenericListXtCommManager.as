package
{
   import Enums.StreamDef;
   import WorldItems.WorldItemsManager;
   import avatar.Avatar;
   import avatar.AvatarItem;
   import avatar.AvatarUtility;
   import collection.BaseTypedCollection;
   import collection.IitemCollection;
   import collection.StreamDefCollection;
   import collection.WorldItemCollection;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import den.DenItem;
   import den.DenRoomItem;
   import gui.GenericListGuiManager;
   import inventory.Iitem;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import pet.PetItem;
   import pet.PetManager;
   
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
      
      public static const AVAIL_TYPE_AVATAR:int = 7;
      
      public static const AVAIL_TYPE_PET:int = 8;
      
      public static const AVAIL_TYPE_WORLD_ITEMS:int = 9;
      
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
      
      public static const AVAILABLE_PET_LIST:int = 312;
      
      public static const PERSONALITY_PET_LIST:int = 432;
      
      public static const MASTERPIECE_ICON_LIST_ID:int = 416;
      
      public static const MASTERPIECE_ICON_IN_DEN_ITEM_VERSION_ORDER:int = 424;
      
      public static const PLATFORMER_LIST:int = 566;
      
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
         var _loc5_:Boolean = true;
         if(param2 != null)
         {
            if(_requestCallbackQueue[param1])
            {
               _requestCallbackQueue[param1].push(param2);
               _loc5_ = false;
            }
            else
            {
               _requestCallbackQueue[param1] = [param2];
            }
         }
         if(param3 != null)
         {
            if(_requestPassbackQueue[param1])
            {
               _requestPassbackQueue[param1].push(param3);
            }
            else
            {
               _requestPassbackQueue[param1] = [param3];
            }
         }
         if(_cachedResponses[param1] && param1 != 1)
         {
            handleNewData(_cachedResponses[param1].concat());
         }
         else if(_loc5_)
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
      
      public static function getDefIdFromDef(param1:Iitem) : int
      {
         var _loc2_:int = 0;
         if(param1)
         {
            if(param1 is Item)
            {
               _loc2_ = param1.defId;
            }
            else if(param1 is DenItem)
            {
               _loc2_ = param1.defId;
            }
         }
         return _loc2_;
      }
      
      public static function filterIitemList(param1:int, param2:IitemCollection, param3:Boolean, ... rest) : void
      {
         var _loc30_:int = 0;
         var _loc14_:Object = null;
         var _loc6_:Array = null;
         var _loc15_:int = 0;
         var _loc19_:int = 0;
         var _loc26_:int = 0;
         var _loc16_:IitemCollection = null;
         var _loc18_:IitemCollection = null;
         var _loc29_:Boolean = false;
         var _loc13_:int = 0;
         var _loc20_:Iitem = null;
         var _loc27_:AvatarItem = null;
         var _loc12_:Avatar = null;
         var _loc31_:PetItem = null;
         var _loc21_:Array = null;
         var _loc23_:Boolean = false;
         var _loc10_:* = 0;
         var _loc24_:int = 0;
         var _loc28_:Object = null;
         var _loc11_:Array = null;
         var _loc25_:int = 0;
         var _loc17_:* = 0;
         var _loc8_:* = 0;
         var _loc9_:int = 0;
         switch(param1)
         {
            case 1000:
               _loc30_ = 0;
               break;
            case 1030:
               _loc30_ = 1;
               break;
            case 1040:
               _loc30_ = 3;
               break;
            case 1054:
               _loc30_ = 6;
               break;
            case 1060:
               _loc14_ = {};
               _loc6_ = [];
               _loc16_ = new IitemCollection();
               _loc26_ = 0;
               while(_loc26_ < param2.length)
               {
                  if(param2.getIitem(_loc26_) is DenItem)
                  {
                     _loc15_ = 1030;
                  }
                  else
                  {
                     if(!(param2.getIitem(_loc26_) is DenRoomItem))
                     {
                        throw new Error("Did not find type when loading combined list");
                     }
                     _loc15_ = 1040;
                  }
                  if(_loc14_[_loc15_] == null)
                  {
                     _loc14_[_loc15_] = _loc19_;
                     _loc18_ = new IitemCollection();
                     _loc18_.pushIitem(param2.getIitem(_loc26_));
                     _loc6_[_loc19_] = {
                        "defType":_loc15_,
                        "items":_loc18_
                     };
                     _loc19_++;
                  }
                  else
                  {
                     _loc6_[_loc14_[_loc15_]].items.pushIitem(param2.getIitem(_loc26_));
                  }
                  _loc26_++;
               }
               _loc14_ = null;
               _loc26_ = 0;
               while(_loc26_ < _loc6_.length)
               {
                  filterIitemList(int(_loc6_[_loc26_].defType),_loc6_[_loc26_].items,param3);
                  _loc16_.setCoreArray(_loc16_.concatCollection(_loc6_[_loc26_].items));
                  _loc26_++;
               }
               param2.setCoreArray(_loc16_.getCoreArray());
               return;
            case 1003:
               _loc30_ = 7;
               break;
            case 1046:
               _loc30_ = 8;
               break;
            default:
               DebugUtility.debugTrace("filtering of gl is not setup for listDefType=" + param1 + ". Returning list passed in");
               return;
         }
         var _loc5_:Array = _availDefs[_loc30_];
         if(!_loc5_ || _loc5_.length <= 0)
         {
            return;
         }
         var _loc7_:int = 0;
         while(_loc7_ < param2.length)
         {
            _loc29_ = false;
            switch(_loc30_)
            {
               case 0:
               case 1:
               case 3:
                  _loc20_ = param2.getIitem(_loc7_);
                  if(_loc20_.isDiamond)
                  {
                     _loc5_ = _availDefs[6];
                     if(!_loc5_ || _loc5_.length <= 0)
                     {
                        _loc13_ = 0;
                     }
                     else
                     {
                        _loc13_ = _loc20_.diamondItem.defId;
                     }
                  }
                  else
                  {
                     _loc5_ = _availDefs[_loc30_];
                     if(!_loc5_ || _loc5_.length <= 0)
                     {
                        _loc13_ = 0;
                     }
                     else
                     {
                        _loc13_ = _loc20_.defId;
                     }
                  }
                  break;
               case 6:
                  _loc13_ = param2.getIitem(_loc7_).diamondItem.defId;
                  break;
               case 7:
                  _loc27_ = param2.getIitem(_loc7_) as AvatarItem;
                  _loc12_ = _loc27_.avt;
                  if(_loc27_.isDiamond)
                  {
                     if(AvatarUtility.getAvatarDefIsViewable(_loc12_))
                     {
                        _loc13_ = 0;
                     }
                     else
                     {
                        _loc5_ = _availDefs[6];
                        if(!_loc5_ || _loc5_.length <= 0)
                        {
                           _loc13_ = 0;
                        }
                        else
                        {
                           _loc13_ = _loc27_.diamondItem.defId;
                        }
                     }
                  }
                  else
                  {
                     _loc5_ = _availDefs[7];
                     if(!_loc5_ || _loc5_.length <= 0)
                     {
                        _loc13_ = 0;
                     }
                     else
                     {
                        _loc13_ = _loc27_.defId;
                     }
                  }
                  break;
               case 8:
                  _loc31_ = param2.getIitem(_loc7_) as PetItem;
                  if(_loc31_.isDiamond)
                  {
                     if(PetManager.isPetAvailable(_loc31_.defId))
                     {
                        _loc13_ = 0;
                     }
                     else
                     {
                        _loc5_ = _availDefs[6];
                        if(!_loc5_ || _loc5_.length <= 0)
                        {
                           _loc13_ = 0;
                        }
                        else
                        {
                           _loc13_ = _loc31_.diamondItem.defId;
                        }
                     }
                  }
                  else
                  {
                     _loc5_ = _availDefs[8];
                     if(!_loc5_ || _loc5_.length <= 0)
                     {
                        _loc13_ = 0;
                     }
                     else
                     {
                        _loc13_ = _loc31_.defId;
                     }
                  }
                  break;
               default:
                  throw new Error("ERROR: Availability type=" + _loc30_ + " is not yet implemented!");
            }
            if(_loc13_ > 0)
            {
               _loc21_ = _loc5_[_loc13_];
               if(_loc21_ && _loc21_.length > 0)
               {
                  if(_loc21_.length > 2)
                  {
                     throw new Error("ERROR: We should never have more than 2 availability defs for a specific refId where refId=" + _loc13_);
                  }
                  _loc24_ = 0;
                  while(_loc24_ < 2)
                  {
                     _loc28_ = _loc21_[_loc24_];
                     if(_loc28_)
                     {
                        if(_loc30_ != 5)
                        {
                           if(_loc24_ == 0)
                           {
                              param2.getIitem(_loc7_).endTime = _loc28_.endTime;
                              _loc10_ = uint(_loc28_.endTime);
                           }
                           else
                           {
                              param2.getIitem(_loc7_).endTime = _loc10_;
                           }
                        }
                        if(!_loc28_.active && !_loc23_)
                        {
                           param2.getCoreArray().splice(_loc7_,1);
                           if(rest)
                           {
                              _loc25_ = 0;
                              while(_loc25_ < rest.length)
                              {
                                 _loc11_ = rest[_loc25_];
                                 if(!param3)
                                 {
                                    if(_loc11_)
                                    {
                                       if(_loc30_ == 5)
                                       {
                                          for each(var _loc22_:Array in _loc11_)
                                          {
                                             _loc22_.splice(_loc7_,1);
                                          }
                                       }
                                       else
                                       {
                                          _loc11_.splice(_loc7_,1);
                                       }
                                    }
                                 }
                                 _loc25_++;
                              }
                           }
                           _loc29_ = true;
                           break;
                        }
                        if(!_loc23_)
                        {
                           _loc23_ = true;
                           _loc17_ = uint(_loc21_[0].startTime);
                           _loc8_ = uint(_loc21_[0].endTime);
                           _loc9_ = 86400;
                           if(_loc17_ + 10 * _loc9_ >= Utility.getCurrEpochTime())
                           {
                              param2.getIitem(_loc7_).updateValueWithNewStatus(1);
                           }
                        }
                        else
                        {
                           param2.getIitem(_loc7_).updateValueWithNewStatus(_loc28_.status);
                        }
                     }
                     _loc24_++;
                  }
               }
            }
            _loc13_ = 0;
            _loc10_ = 0;
            _loc23_ = false;
            if(!_loc29_)
            {
               _loc7_++;
            }
         }
      }
      
      public static function filterTypedList(param1:int, param2:BaseTypedCollection, param3:Object = null) : void
      {
         var _loc17_:int = 0;
         var _loc16_:Boolean = false;
         var _loc14_:int = 0;
         var _loc6_:Array = null;
         var _loc11_:Boolean = false;
         var _loc12_:* = 0;
         var _loc13_:int = 0;
         var _loc15_:Object = null;
         var _loc5_:* = 0;
         var _loc8_:* = 0;
         var _loc10_:int = 0;
         switch(param1)
         {
            case 1037:
               _loc17_ = 5;
               break;
            case 1064:
               _loc17_ = 9;
         }
         var _loc4_:Array = _availDefs[_loc17_];
         if(!_loc4_ || _loc4_.length <= 0)
         {
            return;
         }
         var _loc7_:int = 0;
         while(_loc7_ < param2.length)
         {
            _loc16_ = false;
            switch(_loc17_ - 5)
            {
               case 0:
                  _loc14_ = (param2 as StreamDefCollection).getStreamDefItem(_loc7_).defId;
                  break;
               case 4:
                  _loc14_ = (param2 as WorldItemCollection).getWorldDefItem(_loc7_).defId;
                  break;
               default:
                  throw new Error("ERROR: Availability type=" + _loc17_ + " is not yet implemented!");
            }
            if(_loc14_ > 0)
            {
               _loc6_ = _loc4_[_loc14_];
               if(_loc6_ && _loc6_.length > 0)
               {
                  if(_loc6_.length > 2)
                  {
                     throw new Error("ERROR: We should never have more than 2 availability defs for a specific refId where refId=" + _loc14_);
                  }
                  _loc13_ = 0;
                  while(_loc13_ < 2)
                  {
                     _loc15_ = _loc6_[_loc13_];
                     if(_loc15_)
                     {
                        if(_loc13_ == 0)
                        {
                           param2.getCoreArray()[_loc7_].endTime = _loc15_.endTime;
                           _loc12_ = uint(_loc15_.endTime);
                        }
                        else
                        {
                           param2.getCoreArray()[_loc7_].endTime = _loc12_;
                        }
                        if(!_loc15_.active && !_loc11_)
                        {
                           param2.getCoreArray().splice(_loc7_,1);
                           if(param3)
                           {
                              if(_loc17_ == 5)
                              {
                                 for each(var _loc9_:Object in param3)
                                 {
                                    if(_loc9_ is Array)
                                    {
                                       _loc9_.splice(_loc7_,1);
                                    }
                                    else
                                    {
                                       _loc9_.getCoreArray().splice(_loc7_,1);
                                    }
                                 }
                              }
                              else
                              {
                                 param3.splice(_loc7_,1);
                              }
                           }
                           _loc16_ = true;
                           break;
                        }
                        if(!_loc11_)
                        {
                           _loc11_ = true;
                           _loc5_ = uint(_loc6_[0].startTime);
                           _loc8_ = uint(_loc6_[0].endTime);
                           _loc10_ = 86400;
                           if(_loc5_ + 10 * _loc10_ >= Utility.getCurrEpochTime())
                           {
                              param2.getCoreArray()[_loc7_].status = 1;
                           }
                        }
                     }
                     _loc13_++;
                  }
               }
            }
            _loc14_ = 0;
            _loc12_ = 0;
            _loc11_ = false;
            if(!_loc16_)
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
               case 1062:
               case 1063:
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
                  break;
               case 1064:
                  handleInWorldItemsResponse(param1);
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
         var _loc7_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Function = null;
         var _loc6_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc6_])
         {
            _loc7_ = 0;
            while(_loc7_ < _requestCallbackQueue[_loc6_].length)
            {
               _loc3_ = _requestPassbackQueue[_loc6_] ? _requestPassbackQueue[_loc6_][_loc7_] : null;
               _loc4_ = _requestCallbackQueue[_loc6_][_loc7_];
               if(_loc4_ != null)
               {
                  if(_loc3_)
                  {
                     _loc4_(_loc6_,param1,_loc3_);
                  }
                  else
                  {
                     _loc4_(_loc6_,param1);
                  }
                  if(_loc3_ != null)
                  {
                     for each(var _loc5_:Object in _requestPassbackQueue)
                     {
                        if(_loc5_ == _loc3_)
                        {
                           delete _requestPassbackQueue[_loc6_];
                           break;
                        }
                     }
                  }
               }
               else
               {
                  ItemXtCommManager.shopListResponse(param1,param2);
               }
               _loc7_++;
            }
            delete _requestCallbackQueue[_loc6_];
            delete _requestPassbackQueue[_loc6_];
         }
         else
         {
            ItemXtCommManager.shopListResponse(param1,param2);
         }
      }
      
      private static function handleLocalizationResponse(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Function = null;
         var _loc5_:int = 6;
         var _loc7_:int = int(param1[_loc5_++]);
         var _loc2_:Array = new Array(_loc7_);
         _loc8_ = 0;
         while(_loc8_ < _loc7_)
         {
            _loc2_[_loc8_] = param1[_loc5_++];
            _loc8_++;
         }
         var _loc6_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc6_])
         {
            _loc8_ = 0;
            while(_loc8_ < _requestCallbackQueue[_loc6_].length)
            {
               _loc3_ = _requestPassbackQueue[_loc6_] ? _requestPassbackQueue[_loc6_][_loc8_] : null;
               _loc4_ = _requestCallbackQueue[_loc6_][_loc8_];
               if(_loc4_ != null)
               {
                  if(_loc3_)
                  {
                     _loc4_(_loc6_,_loc2_,_loc3_);
                  }
                  else
                  {
                     _loc4_(_loc6_,_loc2_);
                  }
               }
               _loc8_++;
            }
            delete _requestCallbackQueue[_loc6_];
            delete _requestPassbackQueue[_loc6_];
         }
      }
      
      private static function handleMediaResponse(param1:Array) : void
      {
         var _loc9_:int = 0;
         var _loc4_:Object = null;
         var _loc6_:Function = null;
         var _loc7_:int = 6;
         var _loc5_:int = int(param1[_loc7_++]);
         var _loc2_:Array = new Array(_loc5_);
         var _loc3_:Array = new Array(_loc5_);
         _loc9_ = 0;
         while(_loc9_ < _loc5_)
         {
            _loc2_[_loc9_] = int(param1[_loc7_++]);
            _loc3_[_loc9_] = param1[_loc7_++];
            _loc9_++;
         }
         var _loc8_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc8_])
         {
            _loc9_ = 0;
            while(_loc9_ < _requestCallbackQueue[_loc8_].length)
            {
               _loc4_ = _requestPassbackQueue[_loc8_] ? _requestPassbackQueue[_loc8_][_loc9_] : null;
               _loc6_ = _requestCallbackQueue[_loc8_][_loc9_];
               if(_loc6_ != null)
               {
                  if(_loc6_.length == 3)
                  {
                     _loc6_(_loc8_,_loc2_,_loc3_);
                  }
                  else if(_loc6_.length == 4)
                  {
                     _loc6_(_loc8_,_loc2_,_loc3_,_loc4_);
                  }
               }
               _loc9_++;
            }
            delete _requestCallbackQueue[_loc8_];
            delete _requestPassbackQueue[_loc8_];
         }
      }
      
      private static function handleFactResponse(param1:Array) : void
      {
         var _loc9_:int = 0;
         var _loc3_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Function = null;
         var _loc7_:int = 6;
         var _loc2_:int = int(param1[_loc7_++]);
         var _loc4_:Array = [];
         _loc9_ = 0;
         while(_loc9_ < _loc2_)
         {
            _loc3_ = {
               "id":int(param1[_loc7_++]),
               "media":int(param1[_loc7_++]),
               "title":int(param1[_loc7_++]),
               "description":int(param1[_loc7_++]),
               "type":int(param1[_loc7_++]),
               "userVarId":int(param1[_loc7_++]),
               "bitIdx":int(param1[_loc7_++])
            };
            _loc4_.push(_loc3_);
            _loc9_++;
         }
         var _loc8_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc8_])
         {
            _loc9_ = 0;
            while(_loc9_ < _requestCallbackQueue[_loc8_].length)
            {
               _loc5_ = _requestPassbackQueue[_loc8_] ? _requestPassbackQueue[_loc8_][_loc9_] : null;
               _loc6_ = _requestCallbackQueue[_loc8_][_loc9_];
               if(_loc6_ != null)
               {
                  _loc6_(_loc4_);
               }
               _loc9_++;
            }
            delete _requestCallbackQueue[_loc8_];
            delete _requestPassbackQueue[_loc8_];
         }
      }
      
      private static function handleStreamResponse(param1:Array) : void
      {
         var _loc9_:int = 0;
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
         var _loc7_:int = 6;
         var _loc5_:String = param1[4];
         var _loc4_:int = int(param1[_loc7_++]);
         var _loc6_:StreamDefCollection = new StreamDefCollection();
         _loc9_ = 0;
         while(_loc9_ < _loc4_)
         {
            _loc6_.pushStreamDefItem(new StreamDef(int(param1[_loc7_++]),int(param1[_loc7_++]),param1[_loc7_++],int(param1[_loc7_++]),int(param1[_loc7_++]),-1));
            _loc9_++;
         }
         var _loc8_:int = int(param1[2]);
         var _loc3_:Object = _streamQueue[_loc8_];
         if(_loc3_)
         {
            if(_loc3_.h)
            {
               _loc3_.h.titleTxt = _loc5_;
               _loc3_.c(_loc8_,_loc6_,_loc3_.h);
            }
            else
            {
               _loc3_.c(_loc8_,_loc6_);
            }
            for each(var _loc2_:Object in _streamQueue)
            {
               if(_loc2_ == _streamQueue[_loc8_])
               {
                  delete _streamQueue[_loc8_];
                  break;
               }
            }
         }
      }
      
      private static function handleAvatarResponse(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Function = null;
         var _loc6_:int = 6;
         var _loc5_:int = int(param1[_loc6_++]);
         var _loc4_:Array = new Array(_loc5_);
         _loc8_ = 0;
         while(_loc8_ < _loc5_)
         {
            _loc4_[_loc8_] = int(param1[_loc6_++]);
            _loc8_++;
         }
         var _loc7_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc7_])
         {
            _loc8_ = 0;
            while(_loc8_ < _requestCallbackQueue[_loc7_].length)
            {
               _loc2_ = _requestPassbackQueue[_loc7_] ? _requestPassbackQueue[_loc7_][_loc8_] : null;
               _loc3_ = _requestCallbackQueue[_loc7_][_loc8_];
               if(_loc3_ != null)
               {
                  _loc3_(_loc4_);
               }
               _loc8_++;
            }
            delete _requestCallbackQueue[_loc7_];
            delete _requestPassbackQueue[_loc7_];
         }
      }
      
      private static function handleAvailabilityResponse(param1:Array) : void
      {
         var _loc7_:Date = null;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc9_:int = 0;
         var _loc4_:Object = null;
         var _loc12_:Function = null;
         var _loc13_:int = int(param1[2]);
         var _loc6_:int = 4;
         _availUniqueListId = int(param1[_loc6_++]);
         var _loc3_:int = int(param1[_loc6_++]);
         var _loc2_:int = int(param1[_loc6_++]);
         if(_loc3_ < 0)
         {
            _availDefExpireTime = -1;
         }
         else
         {
            _loc7_ = new Date();
            _availDefExpireTime = _loc7_.getTime() / 1000 + _loc3_;
         }
         _availDefs = {};
         _loc10_ = 0;
         while(_loc10_ < _loc2_)
         {
            _loc8_ = int(param1[_loc6_++]);
            _loc11_ = int(param1[_loc6_++]);
            _loc5_ = int(param1[_loc6_++]);
            _loc9_ = 0;
            while(_loc9_ < _loc11_)
            {
               if(!_availDefs[_loc8_])
               {
                  _availDefs[_loc8_] = [];
               }
               if(!_availDefs[_loc8_][_loc5_])
               {
                  _availDefs[_loc8_][_loc5_] = [];
               }
               _availDefs[_loc8_][_loc5_].push({
                  "status":int(param1[_loc6_++]),
                  "startTime":uint(param1[_loc6_++]),
                  "endTime":uint(param1[_loc6_++]),
                  "active":param1[_loc6_++] == "1"
               });
               _loc9_++;
            }
            _loc10_++;
         }
         if(_requestCallbackQueue[_loc13_])
         {
            _loc10_ = 0;
            while(_loc10_ < _requestCallbackQueue[_loc13_].length)
            {
               _loc4_ = _requestPassbackQueue[_loc13_] ? _requestPassbackQueue[_loc13_][_loc10_] : null;
               _loc12_ = _requestCallbackQueue[_loc13_][_loc10_];
               if(_loc12_ != null)
               {
                  if(_loc4_)
                  {
                     _loc12_(_loc4_);
                  }
                  else
                  {
                     _loc12_();
                  }
               }
               _loc10_++;
            }
            delete _requestCallbackQueue[_loc13_];
            delete _requestPassbackQueue[_loc13_];
         }
      }
      
      private static function handleNamebarBadgeResposne(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Function = null;
         var _loc6_:int = 6;
         var _loc2_:int = int(param1[_loc6_++]);
         var _loc3_:Array = new Array(_loc2_);
         _loc8_ = 0;
         while(_loc8_ < _loc2_)
         {
            _loc3_[_loc8_] = int(param1[_loc6_++]);
            _loc8_++;
         }
         var _loc7_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc7_])
         {
            _loc8_ = 0;
            while(_loc8_ < _requestCallbackQueue[_loc7_].length)
            {
               _loc4_ = _requestPassbackQueue[_loc7_] ? _requestPassbackQueue[_loc7_][_loc8_] : null;
               _loc5_ = _requestCallbackQueue[_loc7_][_loc8_];
               if(_loc5_ != null)
               {
                  _loc5_(_loc3_);
               }
               _loc8_++;
            }
            delete _requestCallbackQueue[_loc7_];
            delete _requestPassbackQueue[_loc7_];
         }
      }
      
      private static function handleScriptResponse(param1:Array) : void
      {
         var _loc7_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Function = null;
         var _loc5_:int = 6;
         var _loc8_:int = int(param1[_loc5_++]);
         var _loc4_:Array = new Array(_loc8_);
         _loc7_ = 0;
         while(_loc7_ < _loc8_)
         {
            _loc4_[_loc7_] = int(param1[_loc5_++]);
            _loc7_++;
         }
         var _loc6_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc6_])
         {
            _loc7_ = 0;
            while(_loc7_ < _requestCallbackQueue[_loc6_].length)
            {
               _loc2_ = _requestPassbackQueue[_loc6_] ? _requestPassbackQueue[_loc6_][_loc7_] : null;
               _loc3_ = _requestCallbackQueue[_loc6_][_loc7_];
               if(_loc3_ != null)
               {
                  _loc3_(_loc6_,_loc4_,_loc2_);
               }
               _loc7_++;
            }
            delete _requestCallbackQueue[_loc6_];
            delete _requestPassbackQueue[_loc6_];
         }
      }
      
      private static function handlePetResponse(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Function = null;
         var _loc6_:int = 6;
         var _loc9_:int = int(param1[_loc6_++]);
         var _loc2_:Array = [];
         _loc8_ = 0;
         while(_loc8_ < _loc9_)
         {
            _loc3_ = int(param1[_loc6_++]);
            if(param1[_loc6_++] == "1")
            {
               _loc2_.push(_loc3_);
            }
            _loc8_++;
         }
         var _loc7_:int = int(param1[2]);
         if(_requestCallbackQueue[_loc7_])
         {
            _loc8_ = 0;
            while(_loc8_ < _requestCallbackQueue[_loc7_].length)
            {
               _loc4_ = _requestPassbackQueue[_loc7_] ? _requestPassbackQueue[_loc7_][_loc8_] : null;
               _loc5_ = _requestCallbackQueue[_loc7_][_loc8_];
               if(_loc5_ != null)
               {
                  _loc5_(_loc7_,_loc2_,_loc4_);
               }
               _loc8_++;
            }
            delete _requestCallbackQueue[_loc7_];
            delete _requestPassbackQueue[_loc7_];
         }
      }
      
      private static function handleEBookResponse(param1:Array) : void
      {
         var _loc10_:int = 0;
         var _loc3_:Object = null;
         var _loc6_:Function = null;
         var _loc9_:int = int(param1[2]);
         var _loc8_:int = 6;
         var _loc5_:int = int(param1[_loc8_++]);
         var _loc2_:Array = new Array(_loc5_);
         var _loc4_:Array = new Array(_loc5_);
         var _loc7_:Array = new Array(_loc5_);
         _loc10_ = 0;
         while(_loc10_ < _loc5_)
         {
            _loc2_[_loc10_] = int(param1[_loc8_++]);
            _loc4_[_loc10_] = int(param1[_loc8_++]);
            _loc7_[_loc10_] = int(param1[_loc8_++]);
            _loc10_++;
         }
         if(_requestCallbackQueue[_loc9_])
         {
            _loc10_ = 0;
            while(_loc10_ < _requestCallbackQueue[_loc9_].length)
            {
               _loc3_ = _requestPassbackQueue[_loc9_] ? _requestPassbackQueue[_loc9_][_loc10_] : null;
               _loc6_ = _requestCallbackQueue[_loc9_][_loc10_];
               if(_loc6_ != null)
               {
                  _loc6_(_loc9_,_loc2_,_loc4_,_loc7_,_loc3_);
               }
               _loc10_++;
            }
            delete _requestCallbackQueue[_loc9_];
            delete _requestPassbackQueue[_loc9_];
         }
      }
      
      private static function handleSimpleResponse(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc2_:Object = null;
         var _loc4_:Function = null;
         var _loc7_:int = int(param1[2]);
         var _loc5_:int = 6;
         var _loc3_:int = int(param1[_loc5_++]);
         var _loc6_:Array = new Array(_loc3_);
         _loc8_ = 0;
         while(_loc8_ < _loc3_)
         {
            _loc6_[_loc8_] = int(param1[_loc5_++]);
            _loc8_++;
         }
         if(_requestCallbackQueue[_loc7_])
         {
            _loc8_ = 0;
            while(_loc8_ < _requestCallbackQueue[_loc7_].length)
            {
               _loc2_ = _requestPassbackQueue[_loc7_] ? _requestPassbackQueue[_loc7_][_loc8_] : null;
               _loc4_ = _requestCallbackQueue[_loc7_][_loc8_];
               if(_loc4_ != null)
               {
                  _loc4_(_loc7_,_loc6_,_loc2_);
               }
               _loc8_++;
            }
            delete _requestCallbackQueue[_loc7_];
            delete _requestPassbackQueue[_loc7_];
         }
      }
      
      private static function handleInWorldItemsResponse(param1:Array) : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = int(param1[2]);
         var _loc3_:int = 6;
         var _loc2_:int = int(param1[_loc3_++]);
         var _loc4_:WorldItemCollection = new WorldItemCollection();
         _loc6_ = 0;
         while(_loc6_ < _loc2_)
         {
            _loc4_.pushWorldDefItem(WorldItemsManager.getWorldItemDef(param1[_loc3_++]));
            _loc6_++;
         }
         filterTypedList(param1[3],_loc4_);
         WorldItemsManager.handleWorldItemsResponse(_loc4_);
      }
   }
}

