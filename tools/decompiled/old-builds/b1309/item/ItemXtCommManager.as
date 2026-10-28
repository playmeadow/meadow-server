package item
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.UserInfo;
   import collection.AccItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import com.sbi.client.SFEvent;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import currency.CurrencyItem;
   import currency.UserCurrency;
   import diamond.DiamondXtCommManager;
   import game.MinigameManager;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import quest.QuestManager;
   
   public class ItemXtCommManager
   {
      
      public static var guiManager:Object;
      
      public static var hasRequestedFullItemList:Boolean;
      
      public static var itemDefsHaveLoaded:Boolean;
      
      public static var functionToCallWhenDefsLoaded:Function;
      
      private static var _ilAvatarQueue:Vector.<Object>;
      
      private static var _acIlAvatarQueue:Vector.<Object>;
      
      private static var _ibQueue:Vector.<Object>;
      
      private static var _iuQueue:Vector.<Object>;
      
      private static var _slQueue:Vector.<Object>;
      
      private static var _denShopListHandler:Function;
      
      private static var _buddyCardUpdateDropDownHandler:Function;
      
      private static var _donateCallback:Function;
      
      private static var _currencyExchangeCallback:Function;
      
      private static var _irCallback:Function;
      
      private static var _recycleIlCallback:Function;
      
      private static var _hudAvtLayerAnim:LayerAnim;
      
      private static var _buyItemsIlCallback:Function;
      
      private static var _getAvatarFromAvatarManager:Function;
      
      private static var _processAcIlComboFromAvatarManager:Function;
      
      private static var _playerAvatar:Avatar;
      
      private static var _itemDefs:Object;
      
      private static var _currencyExchangeDefs:Object;
      
      private static var _ignoreAndCacheIlResponses:Boolean;
      
      private static var _ignoreIlCache:Object;
      
      private static var _bodyItemDefIds:Array = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,314,315,316,317,318,319,320,407,457,480,926];
      
      public function ItemXtCommManager()
      {
         super();
      }
      
      public static function init(param1:Function = null, param2:Function = null, param3:Object = null, param4:Function = null, param5:Function = null) : void
      {
         _getAvatarFromAvatarManager = param1;
         _processAcIlComboFromAvatarManager = param2;
         guiManager = param3;
         _denShopListHandler = param4;
         _buddyCardUpdateDropDownHandler = param5;
         _ilAvatarQueue = new Vector.<Object>();
         _acIlAvatarQueue = new Vector.<Object>();
         _ibQueue = new Vector.<Object>();
         _iuQueue = new Vector.<Object>();
         _slQueue = new Vector.<Object>();
         _ignoreIlCache = {};
         itemDefsHaveLoaded = false;
         var _loc6_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc6_.init(1000,itemDefResponse,null,2);
         DefPacksDefHelper.mediaArray[1000] = _loc6_;
         var _loc7_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc7_.init(1051,currencyExchangeDefResponse,null,2);
         DefPacksDefHelper.mediaArray[1051] = _loc7_;
      }
      
      public static function destroy() : void
      {
         _ilAvatarQueue = null;
         _acIlAvatarQueue = null;
         _ibQueue = null;
         _iuQueue = null;
         _slQueue = null;
         _irCallback = null;
      }
      
      public static function set playerAvatar(param1:Avatar) : void
      {
         _playerAvatar = param1;
      }
      
      public static function set recycleIlCallback(param1:Function) : void
      {
         _recycleIlCallback = param1;
      }
      
      public static function requestItemBuy(param1:Function, param2:int, param3:int, param4:int, param5:int) : void
      {
         gMainFrame.server.setXtObject_Str("ib",[param2,1,param3,param4,GenericListXtCommManager.getAvailListUniqueId(),param5]);
         var _loc6_:Object = {};
         _loc6_[param2] = {
            "c":param1,
            "i":param3,
            "o":param4
         };
         _ibQueue.push(_loc6_);
      }
      
      public static function requestItemRecycle(param1:IntItemCollection, param2:Function, param3:Function) : void
      {
         _irCallback = param2;
         _recycleIlCallback = param3;
         gMainFrame.server.setXtObject_Str("ir",param1.getCoreArray());
      }
      
      public static function requestItemUse(param1:Function, param2:IntItemCollection, param3:IntItemCollection) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Array = [param2.length,param3.length];
         _loc5_ = _loc5_.concat(param2.concatCollection(param3));
         if(!(_loc5_[0] == 0 && _loc5_[1] == 0))
         {
            gMainFrame.server.setXtObject_Str("iu",_loc5_,gMainFrame.server.isWorldZone);
            _loc4_ = {};
            _loc4_[0] = {
               "c":param1,
               "o":param2,
               "f":param3
            };
            _iuQueue.push(_loc4_);
         }
      }
      
      public static function requestItemListForAvatar(param1:Function, param2:Avatar, param3:Boolean, param4:Boolean = true) : void
      {
         var _loc5_:int = param2.perUserAvId;
         insertIntoILAvatarQueue(_loc5_,param1,param2);
         gMainFrame.server.setXtObject_Str("il",[param2.userName,_loc5_,param3 ? "1" : "0"],gMainFrame.server.isWorldZone,false,param4);
      }
      
      public static function insertIntoILAvatarQueue(param1:int, param2:Function, param3:Avatar) : void
      {
         if(param3.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            hasRequestedFullItemList = true;
         }
         var _loc4_:Object = {};
         _loc4_[param3.userName] = {};
         _loc4_[param3.userName][param1] = {
            "c":param2,
            "a":param3
         };
         _ilAvatarQueue.push(_loc4_);
      }
      
      public static function removeFromILAvatarQueue(param1:String, param2:int) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _ilAvatarQueue.length)
         {
            if(_ilAvatarQueue[_loc3_].hasOwnProperty(param1))
            {
               if(_ilAvatarQueue[_loc3_][param1].hasOwnProperty(param2))
               {
                  _ilAvatarQueue.splice(_loc3_,1);
                  break;
               }
            }
            _loc3_++;
         }
      }
      
      public static function insertAvIntoAcIlQueue(param1:int, param2:Avatar, param3:Function) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         if(_ilAvatarQueue)
         {
            _loc5_ = int(_ilAvatarQueue.length);
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(_ilAvatarQueue[_loc6_] && _ilAvatarQueue[_loc6_].hasOwnProperty(param2.userName))
               {
                  if(_ilAvatarQueue[_loc6_][param2.userName].hasOwnProperty(param1))
                  {
                     trace("WARNING: avatar is in ilAvatarQueue but shouldn\'t be yet.");
                     param3(param1,false);
                  }
               }
               _loc6_++;
            }
         }
         else
         {
            insertIntoILAvatarQueue(param1,null,param2);
            _loc4_ = {};
            _loc4_[param2.userName] = {
               "i":param1,
               "c":param3
            };
            _acIlAvatarQueue.push(_loc4_);
         }
      }
      
      public static function requestShopList(param1:Function, param2:int) : void
      {
         var _loc3_:Object = {};
         _loc3_[param2] = {"c":param1};
         _slQueue.push(_loc3_);
         GenericListXtCommManager.requestGenericList(param2);
      }
      
      public static function requestDonateGems(param1:int, param2:Function) : void
      {
         _donateCallback = param2;
         gMainFrame.server.setXtObject_Str("cd",[param1]);
      }
      
      public static function requestCurrencyExchange(param1:int, param2:int, param3:Function) : void
      {
         gMainFrame.server.setXtObject_Str("ce",[param1,param2]);
         _currencyExchangeCallback = param3;
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "il":
               itemListResponse(_loc2_);
               break;
            case "iu":
               itemUseResponse(_loc2_);
               break;
            case "ib":
               itemBuyResponse(_loc2_);
               break;
            case "ir":
               itemRecycleResponse(_loc2_);
               break;
            case "cu":
               currencyUpdateResponse(_loc2_);
               break;
            case "cd":
               currencyDonationResponse(_loc2_);
               break;
            case "ce":
               currencyExchangeResponse(_loc2_);
               break;
            case "ip":
               itemPrizeResponse(_loc2_);
               break;
            default:
               throw new Error("ItemManager: Received illegal cmd: " + _loc2_[0]);
         }
      }
      
      private static function getResponseItems(param1:Object, param2:int, param3:String) : Object
      {
         var _loc7_:Avatar = null;
         var _loc8_:int = 0;
         var _loc5_:Object = null;
         var _loc11_:Object = null;
         var _loc10_:int = 0;
         var _loc6_:AvatarInfo = null;
         var _loc4_:Object = {
            "ilCallback":null,
            "ilAvatar":null
         };
         var _loc9_:int = int(_ilAvatarQueue.length);
         if(_loc9_ > 0)
         {
            param3 = param3;
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               _loc8_ = _ilAvatarQueue[_loc10_].hasOwnProperty(param3) ? 1 : 0;
               if(_loc8_ == 1)
               {
                  _loc8_ = _ilAvatarQueue[_loc10_][param3].hasOwnProperty(param2) ? 1 : 0;
                  if(_loc8_ == 0)
                  {
                     _loc5_ = _ilAvatarQueue[_loc10_][param3][param2];
                     if(_loc5_ && _loc5_["a"])
                     {
                        _loc8_ = (_loc5_["a"].isChattyAvt ? _loc5_["a"].ilperUserAvId == param2 : _loc5_["a"].myChattyperUserAvId == param2) ? 2 : 0;
                     }
                  }
                  if(_loc8_ > 0)
                  {
                     _loc11_ = _ilAvatarQueue[_loc10_][param3][int(_loc8_ == 1 ? param2 : 0)];
                     _loc4_.ilCallback = _loc11_["c"];
                     _loc7_ = _loc11_["a"];
                     _ilAvatarQueue.splice(_loc10_,1);
                     break;
                  }
               }
               else if(_loc8_ == 0)
               {
                  _loc5_ = _ilAvatarQueue[_loc10_][0];
                  if(_loc5_ && _loc5_["a"])
                  {
                     _loc8_ = (_loc5_["a"].isChattyAvt ? _loc5_["a"].ilperUserAvId == param2 : _loc5_["a"].myChattyperUserAvId == param2) ? 2 : 0;
                  }
               }
               _loc10_++;
            }
         }
         if(!_loc7_ && _getAvatarFromAvatarManager != null)
         {
            _loc4_.ilCallback = null;
            _loc7_ = _getAvatarFromAvatarManager(param3,param2);
            if(!_loc7_)
            {
               if(param3.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && param2 == gMainFrame.userInfo.myPerUserAvId && MinigameManager.inFullRoomGame)
               {
                  _loc6_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,param2);
                  _loc7_ = new Avatar();
                  _loc7_.init(param2,_loc6_.avName,_loc6_.type,_loc6_.colors,_loc6_.customAvId,null,gMainFrame.userInfo.myUserName);
               }
               else if(_processAcIlComboFromAvatarManager != null)
               {
                  _processAcIlComboFromAvatarManager(param3,param2,false,param1);
               }
            }
         }
         _loc4_.ilAvatar = _loc7_;
         return _loc4_;
      }
      
      private static function checkIlCallbacks(param1:String) : void
      {
         if(_buyItemsIlCallback != null)
         {
            _buyItemsIlCallback();
         }
         if(_recycleIlCallback != null)
         {
            _recycleIlCallback();
         }
         guiManager.openAvEditorRecycle();
         _buddyCardUpdateDropDownHandler(param1);
      }
      
      private static function itemsChangedListResponse(param1:Object) : void
      {
         var _loc15_:Function = null;
         var _loc5_:Avatar = null;
         var _loc21_:int = 0;
         var _loc24_:AccItemCollection = null;
         var _loc9_:int = 0;
         var _loc16_:Item = null;
         var _loc7_:Boolean = false;
         var _loc13_:Object = null;
         var _loc19_:int = 0;
         var _loc22_:int = 0;
         var _loc20_:Object = param1.concat();
         var _loc6_:Boolean = param1[2] == "3";
         var _loc4_:Boolean = param1[3] == "1";
         var _loc25_:int = int(param1[4]);
         var _loc14_:String = param1[5];
         var _loc2_:uint = uint(param1[6]);
         var _loc8_:int = int(param1[7]);
         var _loc3_:int = int(param1[8]);
         var _loc10_:int = 9;
         var _loc23_:Array = [];
         var _loc17_:Array = [];
         var _loc12_:Array = [];
         _loc21_ = 0;
         while(_loc21_ < _loc8_)
         {
            _loc17_.push(int(param1[_loc10_++]));
            _loc23_.push(int(param1[_loc10_++]));
            _loc21_++;
         }
         _loc21_ = 0;
         while(_loc21_ < _loc3_)
         {
            _loc12_.push(int(param1[_loc10_++]));
            _loc21_++;
         }
         var _loc11_:Object = getResponseItems(_loc20_,_loc25_,_loc14_);
         _loc5_ = _loc11_.ilAvatar;
         _loc15_ = _loc11_.ilCallback;
         if(!_loc5_)
         {
            return;
         }
         var _loc18_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc14_,_loc25_);
         if(_loc18_ && _loc5_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _loc24_ = _loc18_.getFullItems(true);
            _loc9_ = int(_loc24_.length);
            if(_loc24_)
            {
               _loc21_ = 0;
               while(_loc21_ < _loc17_.length)
               {
                  _loc19_ = 0;
                  while(_loc19_ < _loc9_)
                  {
                     if(_loc24_.getAccItem(_loc19_).invIdx == _loc17_[_loc21_])
                     {
                        _loc24_.getAccItem(_loc19_).setInUse(_loc18_.perUserAvId,true);
                        _loc7_ = true;
                        break;
                     }
                     _loc19_++;
                  }
                  if(!_loc6_ && !_loc7_)
                  {
                     _loc13_ = getItemDef(_loc23_[_loc21_]);
                     _loc16_ = new Item();
                     _loc16_.init(_loc13_.defId,_loc17_[_loc21_],_loc2_);
                     _loc16_.setInUse(_loc18_.perUserAvId,_loc4_);
                     _loc24_.getCoreArray().unshift(_loc16_);
                  }
                  _loc7_ = false;
                  _loc21_++;
               }
               _loc9_ = int(_loc24_.length);
               _loc21_ = 0;
               while(_loc21_ < _loc12_.length)
               {
                  _loc19_ = 0;
                  while(_loc19_ < _loc9_)
                  {
                     if(_loc24_.getAccItem(_loc19_).invIdx == _loc12_[_loc21_])
                     {
                        _loc24_.getAccItem(_loc19_).setInUse(_loc18_.perUserAvId,false);
                        if(!_loc6_)
                        {
                           _loc24_.getCoreArray().splice(_loc19_,1);
                        }
                        break;
                     }
                     _loc19_++;
                  }
                  _loc21_++;
               }
               _loc18_.fullItemList = _loc24_;
               gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc18_.perUserAvId,_loc18_);
            }
         }
         _loc5_.itemResponseIntegrate(_loc18_.getItems(true));
         if(_loc15_ != null)
         {
            _loc15_(true);
         }
         if(_loc5_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            checkIlCallbacks(_loc18_.userName);
         }
         var _loc26_:int = int(_acIlAvatarQueue.length);
         if(_acIlAvatarQueue && _loc26_ > 0)
         {
            _loc22_ = 0;
            while(_loc22_ < _loc26_)
            {
               if(_acIlAvatarQueue..hasOwnProperty(_loc5_.userName))
               {
                  if(_acIlAvatarQueue[_loc22_][_loc5_.userName].i == _loc5_.perUserAvId)
                  {
                     _acIlAvatarQueue[_loc22_][_loc5_.userName].c(_loc5_.userName,_loc5_.perUserAvId,false,_loc20_);
                  }
                  _acIlAvatarQueue.splice(_loc22_,1);
                  break;
               }
               _loc22_++;
            }
         }
      }
      
      private static function itemsInUseResponse(param1:Object) : void
      {
         var _loc19_:Function = null;
         var _loc4_:Avatar = null;
         var _loc9_:int = 0;
         var _loc13_:AccItemCollection = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc17_:Item = null;
         var _loc5_:AvatarInfo = null;
         var _loc10_:int = 0;
         var _loc8_:Object = param1.concat();
         var _loc3_:int = int(param1[3]);
         var _loc20_:int = int(param1[4]);
         var _loc18_:String = param1[5];
         var _loc11_:int = int(param1[6]);
         var _loc15_:int = int(param1[7]);
         var _loc12_:int = int(param1[8]);
         var _loc2_:Array = param1.splice(9,param1.length);
         var _loc14_:Object = getResponseItems(_loc8_,_loc20_,_loc18_);
         _loc4_ = _loc14_.ilAvatar;
         _loc19_ = _loc14_.ilCallback;
         if(!_loc4_)
         {
            return;
         }
         var _loc16_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc4_.userName);
         if(_loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _loc13_ = _loc16_.fullItemList;
            _loc7_ = int(_loc13_.length);
            _loc6_ = 0;
            while(_loc6_ < _loc7_)
            {
               _loc17_ = _loc13_.getAccItem(_loc6_);
               if(_loc17_.defId == 1 || _loc17_.defId == _loc11_ || _loc17_.defId == _loc15_)
               {
                  _loc17_.setInUse(_loc4_.perUserAvId,true);
               }
               else
               {
                  _loc9_ = 1;
                  while(_loc9_ < _loc12_)
                  {
                     if(_loc17_.invIdx == int(_loc2_[_loc9_]))
                     {
                        _loc17_.setInUse(_loc4_.perUserAvId,true);
                     }
                     _loc9_ += 2;
                     _loc9_++;
                  }
               }
               _loc6_++;
            }
            _loc16_.fullItemList = _loc13_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc4_.userName,_loc16_);
         }
         else
         {
            _loc16_.fullItemList = generateClothingList(_loc12_,_loc2_,_loc4_.perUserAvId,_loc11_,_loc15_,false);
            gMainFrame.userInfo.setUserInfoByUserName(_loc4_.userName,_loc16_);
         }
         _loc5_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc18_,_loc20_);
         if(_loc5_ == null)
         {
            _loc5_ = new AvatarInfo();
            if(_loc20_ == _loc4_.perUserAvId)
            {
               _loc5_.init(_loc20_,_loc4_.avName,_loc4_.userName,_loc4_.uuid,_loc4_.avTypeId,_loc4_.colors);
            }
            else
            {
               _loc5_.init(_loc20_);
            }
         }
         gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc20_,_loc5_);
         _loc4_.itemResponseIntegrate(_loc16_.getPartialItemList(_loc5_.type,true));
         if(_loc19_ != null)
         {
            _loc19_(true);
         }
         if(_loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            checkIlCallbacks(_loc5_.userName);
         }
         var _loc21_:int = int(_acIlAvatarQueue.length);
         if(_acIlAvatarQueue && _loc21_ > 0)
         {
            _loc10_ = 0;
            while(_loc10_ < _loc21_)
            {
               if(_acIlAvatarQueue[_loc10_].hasOwnProperty(_loc4_.userName))
               {
                  if(_acIlAvatarQueue[_loc10_][_loc4_.userName].i == _loc4_.perUserAvId)
                  {
                     _acIlAvatarQueue[_loc10_][_loc4_.userName].c(_loc4_.userName,_loc4_.perUserAvId,false,_loc8_);
                  }
                  _acIlAvatarQueue.splice(_loc10_,1);
                  break;
               }
               _loc10_++;
            }
         }
      }
      
      public static function handleIlWhenBeforeACAfterReceivingAC(param1:Object) : void
      {
         itemListResponse(param1);
      }
      
      private static function itemListResponse(param1:Object) : void
      {
         var _loc19_:Function = null;
         var _loc4_:Avatar = null;
         var _loc7_:int = 0;
         var _loc5_:AvatarInfo = null;
         var _loc9_:int = 0;
         var _loc8_:Object = param1.concat();
         var _loc20_:Boolean = param1[2] == "0";
         if(!_loc20_)
         {
            if(param1[2] == "1")
            {
               itemsInUseResponse(param1);
            }
            else
            {
               if(param1[2] == "-1")
               {
                  throw new Error("server returned IL failure: " + param1);
               }
               itemsChangedListResponse(param1);
            }
            return;
         }
         var _loc3_:int = int(param1[3]);
         var _loc21_:int = int(param1[4]);
         var _loc18_:String = param1[5];
         var _loc10_:int = int(param1[6]);
         var _loc14_:int = int(param1[7]);
         var _loc11_:int = int(param1[8]);
         var _loc2_:Array = param1.splice(9,param1.length);
         var _loc17_:int = int(_ilAvatarQueue.length);
         var _loc13_:Object = getResponseItems(_loc8_,_loc21_,_loc18_);
         _loc4_ = _loc13_.ilAvatar;
         _loc19_ = _loc13_.ilCallback;
         if(!_loc4_)
         {
            return;
         }
         var _loc12_:AccItemCollection = generateClothingList(_loc11_,_loc2_,_loc4_.perUserAvId,_loc10_,_loc14_,_loc4_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase());
         var _loc15_:AccItemCollection = new AccItemCollection();
         var _loc6_:int = int(_loc12_.length);
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            _loc15_.pushAccItem(_loc12_.getAccItem(_loc7_).clone() as Item);
            _loc7_++;
         }
         _loc12_ = null;
         if(_loc4_.userName != gMainFrame.userInfo.myUserName)
         {
            return;
         }
         var _loc16_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc4_.userName);
         _loc5_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc18_,_loc21_);
         _loc16_.fullItemList = _loc15_;
         gMainFrame.userInfo.setUserInfoByUserName(_loc4_.userName,_loc16_);
         _loc4_.itemResponseIntegrate(_loc16_.getPartialItemList(_loc5_.type,true));
         if(_loc19_ != null)
         {
            _loc19_(true);
         }
         checkIlCallbacks(_loc5_.userName);
         var _loc22_:int = int(_acIlAvatarQueue.length);
         if(_acIlAvatarQueue && _loc22_ > 0)
         {
            _loc9_ = 0;
            while(_loc9_ < _loc22_)
            {
               if(_acIlAvatarQueue[_loc9_].hasOwnProperty(_loc4_.userName))
               {
                  if(_acIlAvatarQueue[_loc9_][_loc4_.userName].i == _loc4_.perUserAvId)
                  {
                     _acIlAvatarQueue[_loc9_][_loc4_.userName].c(_loc4_.userName,_loc4_.perUserAvId,false,_loc8_);
                  }
                  _acIlAvatarQueue.splice(_loc9_,1);
                  break;
               }
               _loc9_++;
            }
         }
         _loc15_ = null;
      }
      
      private static function itemUseResponse(param1:Object) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Function = null;
         var _loc2_:Object = null;
         if(_iuQueue.length > 0)
         {
            _loc2_ = _iuQueue.shift()[0];
            _loc4_ = _loc2_["c"];
         }
         else
         {
            _loc4_ = null;
         }
         _loc3_ = false;
         if(param1[2] == "1")
         {
            _loc3_ = true;
         }
         if(_loc4_ != null)
         {
            _loc4_(_loc2_["o"],_loc2_["f"],_loc3_);
         }
      }
      
      private static function itemBuyResponse(param1:Object) : void
      {
         var _loc3_:Function = null;
         var _loc6_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:int = int(param1[3]);
         var _loc7_:int = int(param1[2]);
         var _loc2_:int = int(param1[5]);
         if(param1[4] == "")
         {
            _loc6_ = UserCurrency.getCurrency(_loc2_);
            if(_loc6_ == null)
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc2_);
            }
         }
         else
         {
            _loc6_ = param1[4];
         }
         if(_loc7_ == 1)
         {
            if(!UserCurrency.setCurrency(_loc6_,_loc2_))
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc2_);
            }
         }
         if(_ibQueue.length > 0 && _ibQueue[0].hasOwnProperty(_loc5_))
         {
            _loc4_ = _ibQueue.shift()[_loc5_];
            _loc3_ = _loc4_["c"];
         }
         else
         {
            _loc3_ = null;
         }
         if(_loc3_ != null)
         {
            _loc3_(_loc7_,_loc6_,0);
         }
      }
      
      private static function itemRecycleResponse(param1:Object) : void
      {
         var _loc4_:Boolean = int(param1[2]) > 0;
         var _loc3_:int = UserCurrency.getCurrency(0) as int;
         var _loc2_:* = param1[3] == "" ? _loc3_ : param1[3];
         if(_loc4_)
         {
            UserCurrency.setCurrency(_loc2_,0);
         }
         if(_irCallback != null)
         {
            _irCallback(int(param1[2]));
         }
      }
      
      private static function itemPrizeResponse(param1:Object) : void
      {
         guiManager.onItemPrize(param1);
      }
      
      private static function itemDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         var _loc5_:Array = null;
         var _loc4_:int = 0;
         _itemDefs = {};
         for each(var _loc3_:Object in param1.def)
         {
            _loc2_ = {
               "defId":int(_loc3_.id),
               "accId":int(_loc3_.layerDefId),
               "layerId":int(_loc3_.layerId),
               "type":int(_loc3_.type),
               "cost":int(_loc3_.value),
               "name":"",
               "titleStrId":int(_loc3_.titleStrId),
               "isGiftable":_loc3_.isGiftable == "1",
               "isMembersOnly":_loc3_.membersOnly == "1",
               "isNew":_loc3_.itemStatus == "1",
               "isOnSale":_loc3_.itemStatus == "2",
               "enviroType":int(_loc3_.enviroType),
               "avatarUseFlag":Number(_loc3_.avatarUseFlags),
               "itemStatus":int(_loc3_.itemStatus),
               "recycleValue":int(_loc3_.recycleValue),
               "currencyType":int(_loc3_.currencyType),
               "defense":int(_loc3_.defense),
               "attack":int(_loc3_.attack),
               "attackMediaRefId":int(_loc3_.attackMediaRefId),
               "combatType":int(_loc3_.combatType),
               "modifierType":int(_loc3_.modifierType),
               "modifierValue":int(_loc3_.modifierValue),
               "criticalHit":int(_loc3_.criticalHit),
               "combinedCurrencyString":_loc3_.combinedCost
            };
            _loc5_ = _loc3_.colors.split(",");
            _loc4_ = 0;
            while(_loc4_ < _loc5_.length)
            {
               _loc5_[_loc4_] = uint(_loc5_[_loc4_]);
               _loc4_++;
            }
            _loc2_.colors = _loc5_;
            _itemDefs[_loc2_.defId] = _loc2_;
            _itemDefs[int(_loc3_.id)].name = LocalizationManager.translateIdOnly(_loc3_.titleStrId);
         }
         itemDefsHaveLoaded = true;
         if(functionToCallWhenDefsLoaded != null)
         {
            functionToCallWhenDefsLoaded();
            functionToCallWhenDefsLoaded = null;
         }
      }
      
      public static function relocalizeItems() : void
      {
         for each(var _loc1_:Object in _itemDefs)
         {
            _loc1_.name = LocalizationManager.translateIdOnly(_loc1_.titleStrId);
         }
      }
      
      private static function currencyExchangeDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         _currencyExchangeDefs = {};
         for each(var _loc3_:Object in param1.def)
         {
            _loc2_ = {
               "defId":_loc3_.id,
               "mediaId":_loc3_.mediaRefId,
               "result":_loc3_.result,
               "resultType":_loc3_.resultType,
               "value":_loc3_.cost,
               "currencyType":_loc3_.costType,
               "name":"",
               "titleStrId":int(_loc3_.titleStrId)
            };
            _currencyExchangeDefs[_loc2_.defId] = _loc2_;
            _currencyExchangeDefs[int(_loc3_.id)].name = LocalizationManager.translateIdOnly(_loc3_.titleStrId);
         }
      }
      
      public static function relocalizeCurrencyExchanges() : void
      {
         for each(var _loc1_:Object in _currencyExchangeDefs)
         {
            _loc1_.name = LocalizationManager.translateIdOnly(_loc1_.titleStrId);
         }
      }
      
      private static function currencyUpdateResponse(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:SBOkPopup = null;
         var _loc2_:int = int(param1[2]);
         var _loc4_:Object = param1[3];
         var _loc5_:Boolean = param1[4] == 3 || param1[4] == 4;
         var _loc8_:int = -1;
         if(_loc2_ == 0)
         {
            _loc8_ = UserCurrency.getCurrency(0);
            UserCurrency.setCurrency(_loc4_,0);
            _loc7_ = int(_loc4_) - _loc8_;
            if(_loc7_ != 1)
            {
               _loc6_ = 14900;
            }
            else
            {
               _loc6_ = 14901;
            }
            QuestManager.currencyUpdate(int(_loc4_) - _loc8_);
         }
         else if(_loc2_ == 1)
         {
            _loc8_ = UserCurrency.getCurrency(1);
            UserCurrency.setCurrency(_loc4_,1);
            _loc7_ = int(_loc4_) - _loc8_;
            if(_loc7_ != 1)
            {
               _loc6_ = 14902;
            }
            else
            {
               _loc6_ = 14903;
            }
         }
         else if(_loc2_ == 2)
         {
            _loc8_ = UserCurrency.getCurrency(2);
            UserCurrency.setCurrency(_loc4_,2);
            _loc7_ = int(_loc4_) - _loc8_;
            if(_loc7_ != 1)
            {
               _loc6_ = 14904;
            }
            else
            {
               _loc6_ = 14905;
            }
         }
         else if(_loc2_ == 3)
         {
            _loc8_ = UserCurrency.getCurrency(3);
            UserCurrency.setCurrency(_loc4_,3);
            _loc7_ = int(_loc4_) - _loc8_;
            if(_loc7_ != 1)
            {
               _loc6_ = 14906;
            }
            else
            {
               _loc6_ = 14907;
            }
         }
         else if(_loc2_ == 4)
         {
            UserCurrency.setCurrency(_loc4_,4);
         }
         else if(_loc2_ == 5)
         {
            UserCurrency.setCurrency(_loc4_,5);
         }
         else if(_loc2_ == 6)
         {
            UserCurrency.setCurrency(_loc4_,6);
         }
         else if(_loc2_ == 7)
         {
            UserCurrency.setCurrency(_loc4_,7);
         }
         else if(_loc2_ == 8)
         {
            UserCurrency.setCurrency(_loc4_,7);
         }
         else if(_loc2_ == 9)
         {
            UserCurrency.setCurrency(_loc4_,9);
         }
         else if(_loc2_ == 10)
         {
            UserCurrency.setCurrency(_loc4_,10);
         }
         else
         {
            if(_loc2_ != 100)
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc2_);
            }
            UserCurrency.setCurrency(_loc4_,100);
         }
         if(_loc8_ < _loc4_)
         {
            if(guiManager != null)
            {
               if(guiManager.guiLayer != null)
               {
                  if(_loc5_)
                  {
                     _loc3_ = new SBOkPopup(guiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc6_,Utility.convertNumberToString(_loc7_)));
                  }
                  else if(param1[4] == 15)
                  {
                     GuiManager.openJumpPopup(false,null,null,_loc7_);
                  }
                  else if(param1[4] == 16)
                  {
                     guiManager.setupGemGiftPopup(_loc7_);
                  }
               }
            }
         }
         if(gMainFrame.clientInfo.roomType == 7)
         {
            QuestManager.updateCombinedCurrency();
         }
      }
      
      private static function currencyDonationResponse(param1:Object) : void
      {
         if(_donateCallback != null)
         {
            _donateCallback(param1[2] == "1");
            _donateCallback = null;
         }
      }
      
      private static function currencyExchangeResponse(param1:Object) : void
      {
         if(_currencyExchangeCallback != null)
         {
            _currencyExchangeCallback(param1[2] == "1",param1[3],0);
            _currencyExchangeCallback = null;
         }
      }
      
      public static function shopListResponse(param1:Object, param2:int) : void
      {
         var _loc6_:int = 0;
         var _loc12_:int = 0;
         var _loc5_:Function = null;
         var _loc8_:Object = null;
         var _loc9_:int = 6;
         var _loc3_:int = int(param1[2]);
         var _loc7_:String = param1[4];
         _loc6_ = 0;
         while(_loc6_ < _slQueue.length)
         {
            if(_slQueue[_loc6_].hasOwnProperty(_loc3_))
            {
               _loc8_ = _slQueue.shift()[_loc3_];
               _loc5_ = _loc8_["c"];
               break;
            }
            _loc6_++;
         }
         var _loc4_:Object = setupShopItemObject(param1,param2);
         var _loc10_:IitemCollection = _loc4_.shopItemArray;
         var _loc11_:Array = _loc4_.shopItemColorsArray;
         if(_loc10_ != null && _loc5_ != null)
         {
            if(_loc11_ != null)
            {
               _loc5_(_loc10_,_loc7_,_loc11_);
            }
            else
            {
               _loc5_(_loc10_,_loc7_);
            }
         }
      }
      
      private static function setupShopItemObject(param1:Object, param2:int) : Object
      {
         var _loc10_:int = 0;
         var _loc4_:Array = null;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         var _loc13_:Array = null;
         var _loc3_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:IitemCollection = null;
         var _loc7_:int = 6;
         if(param2 == 1000)
         {
            _loc10_ = int(param1[_loc7_++]);
            _loc8_ = [];
            _loc9_ = generateClothingShopList(_loc10_,param1.splice(_loc7_++,param1.length),_loc8_);
         }
         else if(param2 == 1030 || param2 == 1040)
         {
            if(_denShopListHandler != null)
            {
               _loc9_ = _denShopListHandler(param1,param2,null);
            }
         }
         else if(param2 == 1051)
         {
            _loc10_ = int(param1[_loc7_++]);
            _loc9_ = generateCurrencyExchangeShopList(_loc10_,param1.splice(_loc7_++,param1.length));
         }
         else if(param2 == 1054)
         {
            _loc10_ = int(param1[_loc7_++]);
            _loc8_ = [];
            _loc9_ = DiamondXtCommManager.generateDiamondShopList(_loc10_,param1.splice(_loc7_++,param1.length),_loc8_);
         }
         else
         {
            if(param2 != 1060)
            {
               throw new Error("Unimplemented shopList response type: " + param2);
            }
            _loc10_ = int(param1[_loc7_++]);
            if(_loc10_ > 0)
            {
               _loc4_ = (param1[_loc7_++] as String).split(",");
               _loc11_ = (param1[_loc7_++] as String).split(",");
               _loc12_ = (param1 as Array).slice(_loc7_);
               _loc5_ = 0;
               _loc6_ = 0;
               while(_loc6_ < _loc4_.length)
               {
                  _loc13_ = (param1 as Array).slice(0,_loc7_ - 2);
                  _loc13_[6] = _loc11_[_loc6_];
                  _loc13_ = _loc13_.concat(_loc12_.slice(_loc5_,_loc5_ + int(_loc11_[_loc6_])));
                  _loc5_ += int(_loc11_[_loc6_]);
                  _loc3_ = setupShopItemObject(_loc13_ as Object,_loc4_[_loc6_]);
                  if(_loc9_ == null)
                  {
                     _loc9_ = _loc3_.shopItemArray;
                  }
                  else
                  {
                     _loc9_.setCoreArray(_loc9_.concatCollection(_loc3_.shopItemArray));
                  }
                  if(_loc8_ == null)
                  {
                     _loc8_ = _loc3_.shopItemColorsArray;
                  }
                  else
                  {
                     _loc8_ = _loc8_.concat(_loc3_.shopItemColorsArray);
                  }
                  _loc6_++;
               }
            }
         }
         return {
            "shopItemArray":_loc9_,
            "shopItemColorsArray":_loc8_
         };
      }
      
      public static function setItemBuyIlCallback(param1:Function) : void
      {
         _buyItemsIlCallback = param1;
      }
      
      public static function setHudAvtItemListLayerAnim(param1:LayerAnim) : void
      {
         _hudAvtLayerAnim = param1;
      }
      
      public static function generateBodyModList(param1:int, param2:int = -1, param3:int = -1, param4:Boolean = true) : AccItemCollection
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc9_:Item = null;
         var _loc8_:int = 0;
         var _loc7_:AccItemCollection = new AccItemCollection();
         _loc8_ = 0;
         while(_loc8_ < _bodyItemDefIds.length)
         {
            _loc5_ = int(_bodyItemDefIds[_loc8_]);
            _loc6_ = _itemDefs[_loc5_];
            if(_loc6_ == null)
            {
               throw new Error("ItemManager: unknown body itemDef=" + _loc5_);
            }
            _loc9_ = getBodyModFromDefId(_loc5_,param1,_loc5_ == 1 || _loc5_ == param2 || _loc5_ == param3,param4);
            _loc7_.pushAccItem(_loc9_);
            _loc8_++;
         }
         return _loc7_;
      }
      
      public static function getBodyModFromDefId(param1:int, param2:int, param3:Boolean = false, param4:Boolean = true) : Item
      {
         var _loc5_:Item = new Item();
         if(param4)
         {
            _loc5_.init(param1,param1 * -1);
            _loc5_.setInUse(param2,param3);
         }
         else if(param3)
         {
            _loc5_.init(param1,param1 * -1,0,-1,-1);
         }
         else
         {
            _loc5_.init(param1,param1 * -1,0,0,0);
         }
         return _loc5_;
      }
      
      public static function generateClothingList(param1:int, param2:Array, param3:int, param4:int, param5:int, param6:Boolean) : AccItemCollection
      {
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc9_:Item = null;
         var _loc7_:int = 0;
         var _loc12_:AccItemCollection = new AccItemCollection();
         var _loc13_:AccItemCollection = generateBodyModList(param3,param4,param5,param6);
         _loc8_ = 0;
         while(_loc8_ < param1)
         {
            _loc10_ = int(param2[_loc7_++]);
            _loc11_ = _itemDefs[_loc10_];
            if(_loc11_ == null)
            {
               throw new Error("ItemXtCommManager: unknown clothing itemDef=" + _loc10_);
            }
            _loc9_ = new Item();
            if(param6)
            {
               _loc9_.init(_loc10_,int(param2[_loc7_++]),uint(param2[_loc7_++]),Number(param2[_loc7_++]),Number(param2[_loc7_++]));
            }
            else
            {
               _loc9_.init(_loc10_,int(param2[_loc7_++]),uint(param2[_loc7_++]),-1,-1);
               _loc9_.setInUse(param3,true);
            }
            _loc12_.setAccItem(_loc8_,_loc9_);
            _loc8_++;
         }
         _loc12_ = new AccItemCollection(_loc12_.concatCollection(_loc13_));
         if(param6)
         {
            _loc12_.getCoreArray().sortOn("invIdx",0x10 | 2);
         }
         return _loc12_;
      }
      
      private static function generateClothingShopList(param1:int, param2:Array, param3:Array) : IitemCollection
      {
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc5_:Item = null;
         var _loc4_:int = _playerAvatar.avTypeId;
         var _loc8_:IitemCollection = new IitemCollection();
         _loc7_ = 0;
         while(_loc7_ < param1)
         {
            _loc5_ = new Item();
            _loc6_ = ItemXtCommManager.getItemDef(int(param2[_loc7_]));
            param3[_loc6_.defId] = _loc6_.colors.concat();
            _loc5_.init(_loc6_.defId,_loc7_,_loc6_.colors[0],0,0,true);
            _loc8_.pushIitem(_loc5_);
            _loc7_++;
         }
         return _loc8_;
      }
      
      private static function generateCurrencyExchangeShopList(param1:int, param2:Array) : IitemCollection
      {
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         var _loc4_:CurrencyItem = null;
         var _loc6_:int = 0;
         var _loc8_:IitemCollection = new IitemCollection();
         var _loc7_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < param1)
         {
            _loc3_ = int(param2[_loc7_++]);
            _loc5_ = getCurrencyExchangeDef(_loc3_);
            if(!_loc5_)
            {
               _loc6_--;
            }
            else
            {
               _loc4_ = new CurrencyItem();
               _loc4_.init(_loc3_);
               _loc8_.setIitem(_loc6_,_loc4_);
            }
            _loc6_++;
         }
         return _loc8_;
      }
      
      public static function getItemDef(param1:int) : Object
      {
         return _itemDefs[param1];
      }
      
      public static function getCurrencyExchangeDef(param1:int) : Object
      {
         return _currencyExchangeDefs[param1];
      }
      
      public static function canUseItem(param1:int, param2:Avatar, param3:Boolean) : Boolean
      {
         if(param3 && gMainFrame.userInfo.getAvatarDefByAvatar(param2) && param1 == gMainFrame.userInfo.getAvatarDefByAvatar(param2).patternRefId)
         {
            return true;
         }
         return Utility.bitwiseAnd(_itemDefs[param1].avatarUseFlag,Utility.leftShiftNumbers(param2.avTypeId - 1)) != 0;
      }
      
      public static function avTypeThatCanUseItem(param1:int) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:Number = Number(_itemDefs[param1].avatarUseFlag);
         var _loc5_:Array = [];
         while(_loc2_ > 0)
         {
            if(Utility.bitwiseAnd(_loc2_,1) == 1)
            {
               _loc3_ += 1;
               _loc5_.push(_loc3_ + _loc4_);
            }
            else
            {
               _loc4_++;
            }
            _loc2_ = Utility.rightShiftNumber(_loc2_);
         }
         return _loc5_;
      }
   }
}

