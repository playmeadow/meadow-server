package
{
   import avatar.Avatar;
   import avatar.AvatarItem;
   import avatar.AvatarUtility;
   import collection.BaseTypedCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
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
      
      public static const MASTERPIECE_ICON_LIST_ID:int = 416;
      
      public static const MASTERPIECE_ICON_IN_DEN_ITEM_VERSION_ORDER:int = 424;
      
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
         var _loc26_:int = 0;
         var _loc7_:Object = null;
         var _loc30_:Array = null;
         var _loc10_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc12_:IitemCollection = null;
         var _loc27_:IitemCollection = null;
         var _loc28_:Boolean = false;
         var _loc23_:int = 0;
         var _loc8_:Iitem = null;
         var _loc13_:AvatarItem = null;
         var _loc15_:Avatar = null;
         var _loc11_:PetItem = null;
         var _loc9_:Array = null;
         var _loc20_:Boolean = false;
         var _loc6_:* = 0;
         var _loc21_:int = 0;
         var _loc14_:Object = null;
         var _loc5_:Array = null;
         var _loc22_:int = 0;
         var _loc25_:* = 0;
         var _loc31_:* = 0;
         var _loc24_:int = 0;
         switch(param1)
         {
            case 1000:
               _loc26_ = 0;
               break;
            case 1030:
               _loc26_ = 1;
               break;
            case 1040:
               _loc26_ = 3;
               break;
            case 1054:
               _loc26_ = 6;
               break;
            case 1060:
               _loc7_ = {};
               _loc30_ = [];
               _loc12_ = new IitemCollection();
               _loc18_ = 0;
               while(_loc18_ < param2.length)
               {
                  if(param2.getIitem(_loc18_) is DenItem)
                  {
                     _loc10_ = 1030;
                  }
                  else
                  {
                     if(!(param2.getIitem(_loc18_) is DenRoomItem))
                     {
                        throw new Error("Did not find type when loading combined list");
                     }
                     _loc10_ = 1040;
                  }
                  if(_loc7_[_loc10_] == null)
                  {
                     _loc7_[_loc10_] = _loc17_;
                     _loc27_ = new IitemCollection();
                     _loc27_.pushIitem(param2.getIitem(_loc18_));
                     _loc30_[_loc17_] = {
                        "defType":_loc10_,
                        "items":_loc27_
                     };
                     _loc17_++;
                  }
                  else
                  {
                     _loc30_[_loc7_[_loc10_]].items.pushIitem(param2.getIitem(_loc18_));
                  }
                  _loc18_++;
               }
               _loc7_ = null;
               _loc18_ = 0;
               while(_loc18_ < _loc30_.length)
               {
                  filterIitemList(int(_loc30_[_loc18_].defType),_loc30_[_loc18_].items,param3);
                  _loc12_.setCoreArray(_loc12_.concatCollection(_loc30_[_loc18_].items));
                  _loc18_++;
               }
               param2.setCoreArray(_loc12_.getCoreArray());
               return;
            case 1003:
               _loc26_ = 7;
               break;
            case 1046:
               _loc26_ = 8;
               break;
            default:
               DebugUtility.debugTrace("filtering of gl is not setup for listDefType=" + param1 + ". Returning list passed in");
               return;
         }
         var _loc19_:Array = _availDefs[_loc26_];
         if(!_loc19_ || _loc19_.length <= 0)
         {
            return;
         }
         var _loc29_:int = 0;
         while(_loc29_ < param2.length)
         {
            _loc28_ = false;
            switch(_loc26_)
            {
               case 0:
               case 1:
               case 3:
                  _loc8_ = param2.getIitem(_loc29_);
                  if(_loc8_.isDiamond)
                  {
                     _loc19_ = _availDefs[6];
                     if(!_loc19_ || _loc19_.length <= 0)
                     {
                        _loc23_ = 0;
                     }
                     else
                     {
                        _loc23_ = _loc8_.diamondItem.defId;
                     }
                  }
                  else
                  {
                     _loc19_ = _availDefs[_loc26_];
                     if(!_loc19_ || _loc19_.length <= 0)
                     {
                        _loc23_ = 0;
                     }
                     else
                     {
                        _loc23_ = _loc8_.defId;
                     }
                  }
                  break;
               case 6:
                  _loc23_ = param2.getIitem(_loc29_).diamondItem.defId;
                  break;
               case 7:
                  _loc13_ = param2.getIitem(_loc29_) as AvatarItem;
                  _loc15_ = _loc13_.avt;
                  if(_loc13_.isDiamond)
                  {
                     if(AvatarUtility.getAvatarDefIsViewable(_loc15_))
                     {
                        _loc23_ = 0;
                     }
                     else
                     {
                        _loc19_ = _availDefs[6];
                        if(!_loc19_ || _loc19_.length <= 0)
                        {
                           _loc23_ = 0;
                        }
                        else
                        {
                           _loc23_ = _loc13_.diamondItem.defId;
                        }
                     }
                  }
                  else
                  {
                     _loc19_ = _availDefs[7];
                     if(!_loc19_ || _loc19_.length <= 0)
                     {
                        _loc23_ = 0;
                     }
                     else
                     {
                        _loc23_ = _loc13_.defId;
                     }
                  }
                  break;
               case 8:
                  _loc11_ = param2.getIitem(_loc29_) as PetItem;
                  if(_loc11_.isDiamond)
                  {
                     if(PetManager.isPetAvailable(_loc23_))
                     {
                        _loc23_ = 0;
                     }
                     else
                     {
                        _loc19_ = _availDefs[6];
                        if(!_loc19_ || _loc19_.length <= 0)
                        {
                           _loc23_ = 0;
                        }
                        else
                        {
                           _loc23_ = _loc11_.diamondItem.defId;
                        }
                     }
                  }
                  else
                  {
                     _loc19_ = _availDefs[8];
                     if(!_loc19_ || _loc19_.length <= 0)
                     {
                        _loc23_ = 0;
                     }
                     else
                     {
                        _loc23_ = _loc11_.defId;
                     }
                  }
                  break;
               default:
                  throw new Error("ERROR: Availability type=" + _loc26_ + " is not yet implemented!");
            }
            if(_loc23_ > 0)
            {
               _loc9_ = _loc19_[_loc23_];
               if(_loc9_ && _loc9_.length > 0)
               {
                  if(_loc9_.length > 2)
                  {
                     throw new Error("ERROR: We should never have more than 2 availability defs for a specific refId where refId=" + _loc23_);
                  }
                  _loc21_ = 0;
                  while(_loc21_ < 2)
                  {
                     _loc14_ = _loc9_[_loc21_];
                     if(_loc14_)
                     {
                        if(_loc26_ != 5)
                        {
                           if(_loc21_ == 0)
                           {
                              param2.getIitem(_loc29_).endTime = _loc14_.endTime;
                              _loc6_ = uint(_loc14_.endTime);
                           }
                           else
                           {
                              param2.getIitem(_loc29_).endTime = _loc6_;
                           }
                        }
                        if(!_loc14_.active && !_loc20_)
                        {
                           param2.getCoreArray().splice(_loc29_,1);
                           if(rest)
                           {
                              _loc22_ = 0;
                              while(_loc22_ < rest.length)
                              {
                                 _loc5_ = rest[_loc22_];
                                 if(!param3)
                                 {
                                    if(_loc5_)
                                    {
                                       if(_loc26_ == 5)
                                       {
                                          for each(var _loc16_:Array in _loc5_)
                                          {
                                             _loc16_.splice(_loc29_,1);
                                          }
                                       }
                                       else
                                       {
                                          _loc5_.splice(_loc29_,1);
                                       }
                                    }
                                 }
                                 _loc22_++;
                              }
                           }
                           _loc28_ = true;
                           break;
                        }
                        if(!_loc20_)
                        {
                           _loc20_ = true;
                           _loc25_ = uint(_loc9_[0].startTime);
                           _loc31_ = uint(_loc9_[0].endTime);
                           _loc24_ = 86400;
                           if(_loc25_ + 10 * _loc24_ >= Utility.getCurrEpochTime())
                           {
                              param2.getIitem(_loc29_).updateValueWithNewStatus(1);
                           }
                        }
                        else
                        {
                           param2.getIitem(_loc29_).updateValueWithNewStatus(_loc14_.status);
                        }
                     }
                     _loc21_++;
                  }
               }
            }
            _loc23_ = 0;
            _loc6_ = 0;
            _loc20_ = false;
            if(!_loc28_)
            {
               _loc29_++;
            }
         }
      }
      
      public static function filterTypedList(param1:int, param2:BaseTypedCollection, param3:Object = null) : void
      {
         var _loc10_:int = 0;
         var _loc11_:Boolean = false;
         var _loc9_:int = 0;
         var _loc5_:Array = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc13_:Object = null;
         switch(param1 - 1037)
         {
            case 0:
               _loc10_ = 5;
         }
         var _loc6_:Array = _availDefs[_loc10_];
         if(!_loc6_ || _loc6_.length <= 0)
         {
            return;
         }
         var _loc12_:int = 0;
         while(_loc12_ < param2.length)
         {
            _loc11_ = false;
            switch(_loc10_ - 5)
            {
               case 0:
                  _loc9_ = (param2 as IntItemCollection).getIntItem(_loc12_);
                  if(_loc9_ > 0)
                  {
                     _loc5_ = _loc6_[_loc9_];
                     if(_loc5_ && _loc5_.length > 0)
                     {
                        if(_loc5_.length > 2)
                        {
                           throw new Error("ERROR: We should never have more than 2 availability defs for a specific refId where refId=" + _loc9_);
                        }
                        _loc8_ = 0;
                        while(_loc8_ < 2)
                        {
                           _loc13_ = _loc5_[_loc8_];
                           if(_loc13_)
                           {
                              if(!_loc13_.active && !_loc7_)
                              {
                                 param2.getCoreArray().splice(_loc12_,1);
                                 if(param3)
                                 {
                                    if(_loc10_ == 5)
                                    {
                                       for each(var _loc4_:Object in param3)
                                       {
                                          if(_loc4_ is Array)
                                          {
                                             _loc4_.splice(_loc12_,1);
                                          }
                                          else
                                          {
                                             _loc4_.getCoreArray().splice(_loc12_,1);
                                          }
                                       }
                                    }
                                    else
                                    {
                                       param3.splice(_loc12_,1);
                                    }
                                 }
                                 _loc11_ = true;
                                 break;
                              }
                              if(!_loc7_)
                              {
                                 _loc7_ = true;
                              }
                           }
                           _loc8_++;
                        }
                     }
                  }
                  if(!_loc11_)
                  {
                     _loc12_++;
                  }
                  break;
               default:
                  throw new Error("ERROR: Availability type=" + _loc10_ + " is not yet implemented!");
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
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1038] = null;
         var _loc4_:Object = {};
         for each(var _loc3_:Object in _loc2_)
         {
            _loc5_ = {
               "defId":int(_loc3_.id),
               "typeId":int(_loc3_.typeId)
            };
            _loc4_[_loc3_.id] = _loc5_;
         }
         gMainFrame.userInfo.genericListDefs = _loc4_;
      }
      
      private static function handleItemResponse(param1:Array, param2:int) : void
      {
         var _loc3_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc3_];
         var _loc6_:Object = _requestPassbackQueue[_loc3_];
         if(_loc7_ != null)
         {
            if(_loc6_)
            {
               _loc7_(_loc3_,param1,_loc6_);
            }
            else
            {
               _loc7_(_loc3_,param1);
            }
            for each(var _loc5_:Object in _requestCallbackQueue)
            {
               if(_loc5_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc3_];
                  break;
               }
            }
            if(_loc6_ != null)
            {
               for each(var _loc4_:Object in _requestPassbackQueue)
               {
                  if(_loc4_ == _loc6_)
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
         var _loc7_:int = 0;
         var _loc9_:int = 6;
         var _loc10_:int = int(param1[_loc9_++]);
         var _loc5_:Array = new Array(_loc10_);
         _loc7_ = 0;
         while(_loc7_ < _loc10_)
         {
            _loc5_[_loc7_] = param1[_loc9_++];
            _loc7_++;
         }
         var _loc2_:int = int(param1[2]);
         var _loc8_:Function = _requestCallbackQueue[_loc2_];
         var _loc6_:Object = _requestPassbackQueue[_loc2_];
         if(_loc8_ != null)
         {
            if(_loc6_)
            {
               _loc8_(_loc2_,_loc5_,_loc6_);
            }
            else
            {
               _loc8_(_loc2_,_loc5_);
            }
            for each(var _loc4_:Object in _requestCallbackQueue)
            {
               if(_loc4_ == _loc8_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc6_ != null)
            {
               for each(var _loc3_:Object in _requestPassbackQueue)
               {
                  if(_loc3_ == _loc6_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleMediaResponse(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc10_:int = 6;
         var _loc7_:int = int(param1[_loc10_++]);
         var _loc11_:Array = new Array(_loc7_);
         var _loc5_:Array = new Array(_loc7_);
         _loc8_ = 0;
         while(_loc8_ < _loc7_)
         {
            _loc11_[_loc8_] = int(param1[_loc10_++]);
            _loc5_[_loc8_] = param1[_loc10_++];
            _loc8_++;
         }
         var _loc2_:int = int(param1[2]);
         var _loc9_:Function = _requestCallbackQueue[_loc2_];
         var _loc6_:Object = _requestPassbackQueue[_loc2_];
         if(_loc9_ != null)
         {
            _loc9_(_loc2_,_loc11_,_loc5_);
            for each(var _loc4_:Object in _requestCallbackQueue)
            {
               if(_loc4_ == _loc9_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc6_ != null)
            {
               for each(var _loc3_:Object in _requestPassbackQueue)
               {
                  if(_loc3_ == _loc6_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleFactResponse(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc5_:Object = null;
         var _loc10_:int = 6;
         var _loc4_:int = int(param1[_loc10_++]);
         var _loc11_:Array = [];
         _loc8_ = 0;
         while(_loc8_ < _loc4_)
         {
            _loc5_ = {
               "id":int(param1[_loc10_++]),
               "media":int(param1[_loc10_++]),
               "title":int(param1[_loc10_++]),
               "description":int(param1[_loc10_++]),
               "type":int(param1[_loc10_++]),
               "userVarId":int(param1[_loc10_++]),
               "bitIdx":int(param1[_loc10_++])
            };
            _loc11_.push(_loc5_);
            _loc8_++;
         }
         var _loc2_:int = int(param1[2]);
         var _loc9_:Function = _requestCallbackQueue[_loc2_];
         var _loc7_:Object = _requestPassbackQueue[_loc2_];
         if(_loc9_ != null)
         {
            _loc9_(_loc11_);
            for each(var _loc6_:Object in _requestCallbackQueue)
            {
               if(_loc6_ == _loc9_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc7_ != null)
            {
               for each(var _loc3_:Object in _requestPassbackQueue)
               {
                  if(_loc3_ == _loc7_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleStreamResponse(param1:Array) : void
      {
         var _loc3_:Array = null;
         var _loc6_:int = 0;
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
         var _loc13_:String = param1[4];
         var _loc9_:int = int(param1[_loc7_++]);
         var _loc14_:IntItemCollection = new IntItemCollection();
         var _loc4_:IntItemCollection = new IntItemCollection();
         var _loc11_:Array = new Array(_loc9_);
         var _loc2_:Array = new Array(_loc9_);
         var _loc15_:IntItemCollection = new IntItemCollection();
         var _loc5_:IntItemCollection = new IntItemCollection();
         _loc6_ = 0;
         while(_loc6_ < _loc9_)
         {
            _loc14_.setIntItem(_loc6_,int(param1[_loc7_++]));
            _loc4_.setIntItem(_loc6_,int(param1[_loc7_++]));
            _loc3_ = param1[_loc7_++].split("|");
            _loc11_[_loc6_] = _loc3_[0];
            if(_loc3_[1])
            {
               _loc2_[_loc6_] = _loc3_[1];
            }
            else
            {
               _loc2_[_loc6_] = _loc3_[0];
            }
            _loc15_.setIntItem(_loc6_,int(param1[_loc7_++]));
            _loc5_.setIntItem(_loc6_,int(param1[_loc7_++]));
            _loc6_++;
         }
         var _loc12_:int = int(param1[2]);
         var _loc10_:Object = _streamQueue[_loc12_];
         if(_loc10_)
         {
            if(_loc10_.h)
            {
               _loc10_.h.titleTxt = _loc13_;
               _loc10_.c(_loc12_,_loc14_,_loc4_,_loc11_,_loc2_,_loc15_,_loc5_,_loc10_.h);
            }
            else
            {
               _loc10_.c(_loc12_,_loc14_,_loc4_,_loc11_,_loc2_,_loc15_,_loc5_);
            }
            for each(var _loc8_:Object in _streamQueue)
            {
               if(_loc8_ == _streamQueue[_loc12_])
               {
                  delete _streamQueue[_loc12_];
                  break;
               }
            }
         }
      }
      
      private static function handleAvatarResponse(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc10_:int = 6;
         var _loc7_:int = int(param1[_loc10_++]);
         var _loc4_:Array = new Array(_loc7_);
         _loc8_ = 0;
         while(_loc8_ < _loc7_)
         {
            _loc4_[_loc8_] = int(param1[_loc10_++]);
            _loc8_++;
         }
         var _loc2_:int = int(param1[2]);
         var _loc9_:Function = _requestCallbackQueue[_loc2_];
         var _loc6_:Object = _requestPassbackQueue[_loc2_];
         if(_loc9_ != null)
         {
            _loc9_(_loc4_);
            for each(var _loc5_:Object in _requestCallbackQueue)
            {
               if(_loc5_ == _loc9_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc6_ != null)
            {
               for each(var _loc3_:Object in _requestPassbackQueue)
               {
                  if(_loc3_ == _loc6_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleAvailabilityResponse(param1:Array) : void
      {
         var _loc3_:Date = null;
         var _loc9_:int = 0;
         var _loc15_:int = 0;
         var _loc11_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc12_:int = int(param1[2]);
         var _loc7_:int = 4;
         _availUniqueListId = int(param1[_loc7_++]);
         var _loc10_:int = int(param1[_loc7_++]);
         var _loc2_:int = int(param1[_loc7_++]);
         if(_loc10_ < 0)
         {
            _availDefExpireTime = -1;
         }
         else
         {
            _loc3_ = new Date();
            _availDefExpireTime = _loc3_.getTime() / 1000 + _loc10_;
         }
         _availDefs = {};
         _loc6_ = 0;
         while(_loc6_ < _loc2_)
         {
            _loc9_ = int(param1[_loc7_++]);
            _loc11_ = int(param1[_loc7_++]);
            _loc15_ = int(param1[_loc7_++]);
            _loc8_ = 0;
            while(_loc8_ < _loc11_)
            {
               if(!_availDefs[_loc9_])
               {
                  _availDefs[_loc9_] = [];
               }
               if(!_availDefs[_loc9_][_loc15_])
               {
                  _availDefs[_loc9_][_loc15_] = [];
               }
               _availDefs[_loc9_][_loc15_].push({
                  "status":int(param1[_loc7_++]),
                  "startTime":uint(param1[_loc7_++]),
                  "endTime":uint(param1[_loc7_++]),
                  "active":param1[_loc7_++] == "1"
               });
               _loc8_++;
            }
            _loc6_++;
         }
         var _loc14_:Function = _requestCallbackQueue[_loc12_];
         var _loc5_:Object = _requestPassbackQueue[_loc12_];
         if(_loc14_ != null)
         {
            if(_loc5_)
            {
               _loc14_(_loc5_);
            }
            else
            {
               _loc14_();
            }
            for each(var _loc13_:Object in _requestCallbackQueue)
            {
               if(_loc13_ == _loc14_)
               {
                  delete _requestCallbackQueue[_loc12_];
                  break;
               }
            }
            if(_loc5_ != null)
            {
               for each(var _loc4_:Object in _requestPassbackQueue)
               {
                  if(_loc4_ == _loc5_)
                  {
                     delete _requestPassbackQueue[_loc12_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleNamebarBadgeResposne(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc10_:int = 6;
         var _loc7_:int = int(param1[_loc10_++]);
         var _loc2_:Array = new Array(_loc7_);
         _loc8_ = 0;
         while(_loc8_ < _loc7_)
         {
            _loc2_[_loc8_] = int(param1[_loc10_++]);
            _loc8_++;
         }
         var _loc3_:int = int(param1[2]);
         var _loc9_:Function = _requestCallbackQueue[_loc3_];
         var _loc6_:Object = _requestPassbackQueue[_loc3_];
         if(_loc9_ != null)
         {
            _loc9_(_loc2_);
            for each(var _loc5_:Object in _requestCallbackQueue)
            {
               if(_loc5_ == _loc9_)
               {
                  delete _requestCallbackQueue[_loc3_];
                  break;
               }
            }
            if(_loc6_ != null)
            {
               for each(var _loc4_:Object in _requestPassbackQueue)
               {
                  if(_loc4_ == _loc6_)
                  {
                     delete _requestPassbackQueue[_loc3_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleScriptResponse(param1:Array) : void
      {
         var _loc7_:int = 0;
         var _loc9_:int = 6;
         var _loc10_:int = int(param1[_loc9_++]);
         var _loc6_:Array = new Array(_loc10_);
         _loc7_ = 0;
         while(_loc7_ < _loc10_)
         {
            _loc6_[_loc7_] = int(param1[_loc9_++]);
            _loc7_++;
         }
         var _loc2_:int = int(param1[2]);
         var _loc8_:Function = _requestCallbackQueue[_loc2_];
         var _loc5_:Object = _requestPassbackQueue[_loc2_];
         if(_loc8_ != null)
         {
            _loc8_(_loc2_,_loc6_,_loc5_);
            for each(var _loc4_:Object in _requestCallbackQueue)
            {
               if(_loc4_ == _loc8_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc5_ != null)
            {
               for each(var _loc3_:Object in _requestPassbackQueue)
               {
                  if(_loc3_ == _loc5_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handlePetResponse(param1:Array) : void
      {
         var _loc10_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 6;
         var _loc11_:int = int(param1[_loc8_++]);
         var _loc9_:Array = [];
         _loc6_ = 0;
         while(_loc6_ < _loc11_)
         {
            _loc10_ = int(param1[_loc8_++]);
            if(param1[_loc8_++] == "1")
            {
               _loc9_.push(_loc10_);
            }
            _loc6_++;
         }
         var _loc2_:int = int(param1[2]);
         var _loc7_:Function = _requestCallbackQueue[_loc2_];
         var _loc5_:Object = _requestPassbackQueue[_loc2_];
         if(_loc7_ != null)
         {
            _loc7_(_loc2_,_loc9_,_loc5_);
            for each(var _loc4_:Object in _requestCallbackQueue)
            {
               if(_loc4_ == _loc7_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc5_ != null)
            {
               for each(var _loc3_:Object in _requestPassbackQueue)
               {
                  if(_loc3_ == _loc5_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleEBookResponse(param1:Array) : void
      {
         var _loc10_:int = 0;
         var _loc2_:int = int(param1[2]);
         var _loc9_:Function = _requestCallbackQueue[_loc2_];
         var _loc7_:Object = _requestPassbackQueue[_loc2_];
         var _loc11_:int = 6;
         var _loc8_:int = int(param1[_loc11_++]);
         var _loc12_:Array = new Array(_loc8_);
         var _loc4_:Array = new Array(_loc8_);
         var _loc5_:Array = new Array(_loc8_);
         _loc10_ = 0;
         while(_loc10_ < _loc8_)
         {
            _loc12_[_loc10_] = int(param1[_loc11_++]);
            _loc4_[_loc10_] = int(param1[_loc11_++]);
            _loc5_[_loc10_] = int(param1[_loc11_++]);
            _loc10_++;
         }
         if(_loc9_ != null)
         {
            _loc9_(_loc2_,_loc12_,_loc4_,_loc5_,_loc7_);
            for each(var _loc6_:Object in _requestCallbackQueue)
            {
               if(_loc6_ == _loc9_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc7_ != null)
            {
               for each(var _loc3_:Object in _requestPassbackQueue)
               {
                  if(_loc3_ == _loc7_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
      
      private static function handleSimpleResponse(param1:Array) : void
      {
         var _loc9_:int = 0;
         var _loc2_:int = int(param1[2]);
         var _loc8_:Function = _requestCallbackQueue[_loc2_];
         var _loc6_:Object = _requestPassbackQueue[_loc2_];
         var _loc10_:int = 6;
         var _loc7_:int = int(param1[_loc10_++]);
         var _loc3_:Array = new Array(_loc7_);
         _loc9_ = 0;
         while(_loc9_ < _loc7_)
         {
            _loc3_[_loc9_] = int(param1[_loc10_++]);
            _loc9_++;
         }
         if(_loc8_ != null)
         {
            _loc8_(_loc2_,_loc3_,_loc6_);
            for each(var _loc5_:Object in _requestCallbackQueue)
            {
               if(_loc5_ == _loc8_)
               {
                  delete _requestCallbackQueue[_loc2_];
                  break;
               }
            }
            if(_loc6_ != null)
            {
               for each(var _loc4_:Object in _requestPassbackQueue)
               {
                  if(_loc4_ == _loc6_)
                  {
                     delete _requestPassbackQueue[_loc2_];
                     break;
                  }
               }
            }
         }
      }
   }
}

