package item
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.UserInfo;
   import com.sbi.client.SFEvent;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.loader.FileServerEvent;
   import com.sbi.popup.SBOkPopup;
   import currency.CurrencyItem;
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
         _ignoreIlCache = new Object();
         itemDefsHaveLoaded = false;
         var _loc6_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc6_.init(DefPacksDefHelper.DEF_ITEM,itemDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_ITEM] = _loc6_;
         var _loc7_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc7_.init(DefPacksDefHelper.DEF_CURRENCY_EXCHANGE,currencyExchangeDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_CURRENCY_EXCHANGE] = _loc7_;
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
      
      public static function requestItemRecycle(param1:int, param2:Function, param3:Function) : void
      {
         _irCallback = param2;
         _recycleIlCallback = param3;
         gMainFrame.server.setXtObject_Str("ir",[param1]);
      }
      
      public static function requestItemUse(param1:Function, param2:Array, param3:Array) : void
      {
         var _loc5_:Object = null;
         var _loc4_:Array = [param2.length,param3.length];
         _loc4_ = _loc4_.concat(param2.concat(param3));
         if(!(_loc4_[0] == 0 && _loc4_[1] == 0))
         {
            gMainFrame.server.setXtObject_Str("iu",_loc4_,gMainFrame.server.isWorldZone);
            _loc5_ = {};
            _loc5_[0] = {
               "c":param1,
               "o":param2,
               "f":param3
            };
            _iuQueue.push(_loc5_);
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
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         if(_ilAvatarQueue)
         {
            _loc4_ = int(_ilAvatarQueue.length);
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               if(Boolean(_ilAvatarQueue[_loc5_]) && _ilAvatarQueue[_loc5_].hasOwnProperty(param2.userName))
               {
                  if(_ilAvatarQueue[_loc5_][param2.userName].hasOwnProperty(param1))
                  {
                     param3(param1,false);
                  }
               }
               _loc5_++;
            }
         }
         else
         {
            insertIntoILAvatarQueue(param1,null,param2);
            _loc6_ = {};
            _loc6_[param2.userName] = {
               "i":param1,
               "c":param3
            };
            _acIlAvatarQueue.push(_loc6_);
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
         var _loc6_:Avatar = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc11_:AvatarInfo = null;
         var _loc4_:Object = {
            "ilCallback":null,
            "ilAvatar":null
         };
         var _loc5_:int = int(_ilAvatarQueue.length);
         if(_loc5_ > 0)
         {
            param3 = param3;
            _loc10_ = 0;
            while(_loc10_ < _loc5_)
            {
               _loc7_ = _ilAvatarQueue[_loc10_].hasOwnProperty(param3) ? 1 : 0;
               if(_loc7_ == 1)
               {
                  _loc7_ = _ilAvatarQueue[_loc10_][param3].hasOwnProperty(param2) ? 1 : 0;
                  if(_loc7_ == 0)
                  {
                     _loc8_ = _ilAvatarQueue[_loc10_][param3][param2];
                     if((Boolean(_loc8_)) && Boolean(_loc8_["a"]))
                     {
                        _loc7_ = (_loc8_["a"].isChattyAvt ? _loc8_["a"].ilperUserAvId == param2 : _loc8_["a"].myChattyperUserAvId == param2) ? 2 : 0;
                     }
                  }
                  if(_loc7_ > 0)
                  {
                     _loc9_ = _ilAvatarQueue[_loc10_][param3][int(_loc7_ == 1 ? param2 : 0)];
                     _loc4_.ilCallback = _loc9_["c"];
                     _loc6_ = _loc9_["a"];
                     _ilAvatarQueue.splice(_loc10_,1);
                     break;
                  }
               }
               else if(_loc7_ == 0)
               {
                  _loc8_ = _ilAvatarQueue[_loc10_][0];
                  if((Boolean(_loc8_)) && Boolean(_loc8_["a"]))
                  {
                     _loc7_ = (_loc8_["a"].isChattyAvt ? _loc8_["a"].ilperUserAvId == param2 : _loc8_["a"].myChattyperUserAvId == param2) ? 2 : 0;
                  }
               }
               _loc10_++;
            }
         }
         if(!_loc6_ && _getAvatarFromAvatarManager != null)
         {
            _loc4_.ilCallback = null;
            _loc6_ = _getAvatarFromAvatarManager(param3,param2);
            if(!_loc6_)
            {
               if(param3.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && param2 == gMainFrame.userInfo.myPerUserAvId && MinigameManager.inFullRoomGame)
               {
                  _loc11_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,param2);
                  _loc6_ = new Avatar();
                  _loc6_.init(param2,_loc11_.avName,_loc11_.type,_loc11_.colors,_loc11_.customAvId,null,gMainFrame.userInfo.myUserName);
               }
               else if(_processAcIlComboFromAvatarManager != null)
               {
                  _processAcIlComboFromAvatarManager(param3,param2,false,param1);
               }
            }
         }
         _loc4_.ilAvatar = _loc6_;
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
         var _loc14_:Function = null;
         var _loc15_:Avatar = null;
         var _loc16_:int = 0;
         var _loc20_:Array = null;
         var _loc21_:int = 0;
         var _loc22_:Item = null;
         var _loc23_:Boolean = false;
         var _loc24_:Object = null;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc2_:Object = param1.concat();
         var _loc3_:Boolean = param1[2] == "3";
         var _loc4_:Boolean = param1[3] == "1";
         var _loc5_:int = int(param1[4]);
         var _loc6_:String = param1[5];
         var _loc7_:uint = uint(param1[6]);
         var _loc8_:int = int(param1[7]);
         var _loc9_:int = int(param1[8]);
         var _loc10_:* = 9;
         var _loc11_:Array = new Array();
         var _loc12_:Array = new Array();
         var _loc13_:Array = new Array();
         _loc16_ = 0;
         while(_loc16_ < _loc8_)
         {
            _loc12_.push(int(param1[_loc10_++]));
            _loc11_.push(int(param1[_loc10_++]));
            _loc16_++;
         }
         _loc16_ = 0;
         while(_loc16_ < _loc9_)
         {
            _loc13_.push(int(param1[_loc10_++]));
            _loc16_++;
         }
         var _loc17_:Object = getResponseItems(_loc2_,_loc5_,_loc6_);
         _loc15_ = _loc17_.ilAvatar;
         _loc14_ = _loc17_.ilCallback;
         if(!_loc15_)
         {
            return;
         }
         var _loc18_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc6_,_loc5_);
         if((Boolean(_loc18_)) && _loc15_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _loc20_ = _loc18_.getFullItems(true);
            _loc21_ = int(_loc20_.length);
            if(_loc20_)
            {
               _loc16_ = 0;
               while(_loc16_ < _loc12_.length)
               {
                  _loc25_ = 0;
                  while(_loc25_ < _loc21_)
                  {
                     if(_loc20_[_loc25_].invIdx == _loc12_[_loc16_])
                     {
                        _loc20_[_loc25_].setInUse(_loc18_.perUserAvId,true);
                        _loc23_ = true;
                        break;
                     }
                     _loc25_++;
                  }
                  if(!_loc3_ && !_loc23_)
                  {
                     _loc24_ = getItemDef(_loc11_[_loc16_]);
                     _loc22_ = new Item();
                     _loc22_.init(_loc24_.defId,_loc12_[_loc16_],_loc7_);
                     _loc22_.setInUse(_loc18_.perUserAvId,_loc4_);
                     _loc20_.unshift(_loc22_);
                  }
                  _loc23_ = false;
                  _loc16_++;
               }
               _loc21_ = int(_loc20_.length);
               _loc16_ = 0;
               while(_loc16_ < _loc13_.length)
               {
                  _loc25_ = 0;
                  while(_loc25_ < _loc21_)
                  {
                     if(_loc20_[_loc25_].invIdx == _loc13_[_loc16_])
                     {
                        _loc20_[_loc25_].setInUse(_loc18_.perUserAvId,false);
                        if(!_loc3_)
                        {
                           _loc20_.splice(_loc25_,1);
                        }
                        break;
                     }
                     _loc25_++;
                  }
                  _loc16_++;
               }
               _loc18_.fullItemList = _loc20_;
               gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc18_.perUserAvId,_loc18_);
            }
         }
         _loc15_.itemResponseIntegrate(_loc18_.getItems(true));
         if(_loc14_ != null)
         {
            _loc14_(true);
         }
         if(_loc15_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            checkIlCallbacks(_loc18_.userName);
         }
         var _loc19_:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && _loc19_ > 0)
         {
            _loc26_ = 0;
            while(_loc26_ < _loc19_)
            {
               if(_acIlAvatarQueue[_loc26_].hasOwnProperty(_loc15_.userName))
               {
                  if(_acIlAvatarQueue[_loc26_][_loc15_.userName].i == _loc15_.perUserAvId)
                  {
                     _acIlAvatarQueue[_loc26_][_loc15_.userName].c(_loc15_.userName,_loc15_.perUserAvId,false,_loc2_);
                  }
                  _acIlAvatarQueue.splice(_loc26_,1);
                  break;
               }
               _loc26_++;
            }
         }
      }
      
      private static function itemsInUseResponse(param1:Object) : void
      {
         var _loc10_:Function = null;
         var _loc11_:Avatar = null;
         var _loc12_:* = 0;
         var _loc14_:Array = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc18_:AvatarInfo = null;
         var _loc20_:Object = null;
         var _loc21_:int = 0;
         var _loc2_:Object = param1.concat();
         var _loc3_:int = int(param1[3]);
         var _loc4_:int = int(param1[4]);
         var _loc5_:String = param1[5];
         var _loc6_:int = int(param1[6]);
         var _loc7_:int = int(param1[7]);
         var _loc8_:int = int(param1[8]);
         var _loc9_:Array = param1.splice(9,param1.length);
         var _loc13_:Object = getResponseItems(_loc2_,_loc4_,_loc5_);
         _loc11_ = _loc13_.ilAvatar;
         _loc10_ = _loc13_.ilCallback;
         if(!_loc11_)
         {
            return;
         }
         var _loc17_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc11_.userName);
         if(_loc11_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _loc14_ = _loc17_.fullItemList;
            _loc16_ = int(_loc14_.length);
            _loc15_ = 0;
            while(_loc15_ < _loc16_)
            {
               _loc20_ = _loc14_[_loc15_];
               if(_loc20_.defId == 1 || _loc20_.defId == _loc6_ || _loc20_.defId == _loc7_)
               {
                  _loc20_.setInUse(_loc11_.perUserAvId,true);
               }
               else
               {
                  _loc12_ = 1;
                  while(_loc12_ < _loc8_)
                  {
                     if(_loc20_.invIdx == int(_loc9_[_loc12_]))
                     {
                        _loc20_.setInUse(_loc11_.perUserAvId,true);
                     }
                     _loc12_ += 2;
                     _loc12_ = _loc12_ + 1;
                  }
               }
               _loc15_++;
            }
            _loc17_.fullItemList = _loc14_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc11_.userName,_loc17_);
         }
         else
         {
            _loc14_ = generateClothingList(_loc8_,_loc9_,_loc11_.perUserAvId,_loc6_,_loc7_,false);
            _loc17_.fullItemList = _loc14_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc11_.userName,_loc17_);
         }
         _loc18_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc5_,_loc4_);
         if(_loc18_ == null)
         {
            _loc18_ = new AvatarInfo();
            if(_loc4_ == _loc11_.perUserAvId)
            {
               _loc18_.init(_loc4_,_loc11_.avName,_loc11_.userName,_loc11_.uuid,_loc11_.avTypeId,_loc11_.colors);
            }
            else
            {
               _loc18_.init(_loc4_);
            }
         }
         gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc4_,_loc18_);
         _loc11_.itemResponseIntegrate(_loc17_.getPartialItemList(_loc18_.type,true));
         if(_loc10_ != null)
         {
            _loc10_(true);
         }
         if(_loc11_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            checkIlCallbacks(_loc18_.userName);
         }
         var _loc19_:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && _loc19_ > 0)
         {
            _loc21_ = 0;
            while(_loc21_ < _loc19_)
            {
               if(_acIlAvatarQueue[_loc21_].hasOwnProperty(_loc11_.userName))
               {
                  if(_acIlAvatarQueue[_loc21_][_loc11_.userName].i == _loc11_.perUserAvId)
                  {
                     _acIlAvatarQueue[_loc21_][_loc11_.userName].c(_loc11_.userName,_loc11_.perUserAvId,false,_loc2_);
                  }
                  _acIlAvatarQueue.splice(_loc21_,1);
                  break;
               }
               _loc21_++;
            }
         }
      }
      
      public static function handleIlWhenBeforeACAfterReceivingAC(param1:Object) : void
      {
         itemListResponse(param1);
      }
      
      private static function itemListResponse(param1:Object) : void
      {
         var _loc11_:Function = null;
         var _loc12_:Avatar = null;
         var _loc19_:AvatarInfo = null;
         var _loc22_:int = 0;
         var _loc2_:Object = param1.concat();
         var _loc3_:Boolean = param1[2] == "0";
         if(!_loc3_)
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
         var _loc4_:int = int(param1[3]);
         var _loc5_:int = int(param1[4]);
         var _loc6_:String = param1[5];
         var _loc7_:int = int(param1[6]);
         var _loc8_:int = int(param1[7]);
         var _loc9_:int = int(param1[8]);
         var _loc10_:Array = param1.splice(9,param1.length);
         var _loc13_:int = int(_ilAvatarQueue.length);
         var _loc14_:Object = getResponseItems(_loc2_,_loc5_,_loc6_);
         _loc12_ = _loc14_.ilAvatar;
         _loc11_ = _loc14_.ilCallback;
         if(!_loc12_)
         {
            return;
         }
         var _loc15_:Array = generateClothingList(_loc9_,_loc10_,_loc12_.perUserAvId,_loc7_,_loc8_,_loc12_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase());
         var _loc16_:Array = [];
         var _loc17_:int = int(_loc15_.length);
         var _loc18_:int = 0;
         while(_loc18_ < _loc17_)
         {
            _loc16_[_loc18_] = _loc15_[_loc18_].clone();
            _loc18_++;
         }
         _loc15_ = null;
         if(_loc12_.userName != gMainFrame.userInfo.myUserName)
         {
            return;
         }
         var _loc20_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc12_.userName);
         _loc19_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc6_,_loc5_);
         _loc20_.fullItemList = _loc16_;
         gMainFrame.userInfo.setUserInfoByUserName(_loc12_.userName,_loc20_);
         _loc12_.itemResponseIntegrate(_loc20_.getPartialItemList(_loc19_.type,true));
         if(_loc11_ != null)
         {
            _loc11_(true);
         }
         checkIlCallbacks(_loc19_.userName);
         var _loc21_:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && _loc21_ > 0)
         {
            _loc22_ = 0;
            while(_loc22_ < _loc21_)
            {
               if(_acIlAvatarQueue[_loc22_].hasOwnProperty(_loc12_.userName))
               {
                  if(_acIlAvatarQueue[_loc22_][_loc12_.userName].i == _loc12_.perUserAvId)
                  {
                     _acIlAvatarQueue[_loc22_][_loc12_.userName].c(_loc12_.userName,_loc12_.perUserAvId,false,_loc2_);
                  }
                  _acIlAvatarQueue.splice(_loc22_,1);
                  break;
               }
               _loc22_++;
            }
         }
         _loc16_ = null;
      }
      
      private static function itemUseResponse(param1:Object) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Function = null;
         var _loc4_:Object = null;
         if(_iuQueue.length > 0)
         {
            _loc4_ = _iuQueue.shift()[0];
            _loc3_ = _loc4_["c"];
         }
         else
         {
            _loc3_ = null;
         }
         _loc2_ = false;
         if(param1[2] == "1")
         {
            _loc2_ = true;
         }
         if(_loc3_ != null)
         {
            _loc3_(_loc4_["o"],_loc4_["f"],_loc2_);
         }
      }
      
      private static function itemBuyResponse(param1:Object) : void
      {
         var _loc2_:Function = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc3_:int = int(param1[3]);
         var _loc4_:int = int(param1[2]);
         var _loc5_:int = int(param1[5]);
         if(param1[4] == "")
         {
            switch(_loc5_)
            {
               case Item.GEM_CURRENCY:
                  _loc6_ = int(gMainFrame.clientInfo.gemCount);
                  break;
               case Item.TICKET_CURRENCY:
                  _loc6_ = int(gMainFrame.clientInfo.ticketCount);
                  break;
               case Item.CRYSTAL_CURRENCY:
                  _loc6_ = int(gMainFrame.clientInfo.crystalCount);
                  break;
               case Item.DIAMOND_CURRENCY:
                  _loc6_ = int(gMainFrame.clientInfo.diamondCount);
                  break;
               default:
                  throw new Error("ItemManager: Received unknown currencyType: " + _loc5_);
            }
         }
         else
         {
            _loc6_ = int(param1[4]);
         }
         if(_loc4_ == 1 && _loc6_ >= 0)
         {
            switch(_loc5_)
            {
               case Item.GEM_CURRENCY:
                  gMainFrame.clientInfo.gemCount = _loc6_;
                  break;
               case Item.TICKET_CURRENCY:
                  gMainFrame.clientInfo.ticketCount = _loc6_;
                  break;
               case Item.CRYSTAL_CURRENCY:
                  gMainFrame.clientInfo.crystalCount = _loc6_;
                  break;
               case Item.DIAMOND_CURRENCY:
                  gMainFrame.clientInfo.diamondCount = _loc6_;
                  break;
               default:
                  throw new Error("ItemManager: Received unknown currencyType: " + _loc5_);
            }
         }
         if(_ibQueue.length > 0 && _ibQueue[0].hasOwnProperty(_loc3_))
         {
            _loc7_ = _ibQueue.shift()[_loc3_];
            _loc2_ = _loc7_["c"];
         }
         else
         {
            _loc2_ = null;
         }
         if(_loc2_ != null)
         {
            _loc2_(_loc4_,_loc6_);
         }
      }
      
      private static function itemRecycleResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1[2] == "1";
         var _loc3_:int = int(gMainFrame.clientInfo.gemCount);
         var _loc4_:int = param1[3] == "" ? _loc3_ : int(param1[3]);
         if(_loc2_ && _loc4_ >= 0)
         {
            gMainFrame.clientInfo.gemCount = _loc4_;
            if(_loc3_ < _loc4_)
            {
               guiManager.startGemsFlash();
            }
         }
         if(_irCallback != null)
         {
            _irCallback(_loc2_);
         }
      }
      
      private static function itemPrizeResponse(param1:Object) : void
      {
         guiManager.onItemPrize(param1);
      }
      
      private static function itemDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         _itemDefs = new Object();
         for each(_loc3_ in param1.def)
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
               "avatarUseFlag":uint(_loc3_.avatarUseFlags),
               "itemStatus":int(_loc3_.itemStatus),
               "recycleValue":int(_loc3_.recycleValue),
               "currencyType":int(_loc3_.currencyType),
               "defense":int(_loc3_.defense),
               "attack":int(_loc3_.attack),
               "attackMediaRefId":int(_loc3_.attackMediaRefId),
               "combatType":int(_loc3_.combatType),
               "modifierType":int(_loc3_.modifierType),
               "modifierValue":int(_loc3_.modifierValue),
               "criticalHit":int(_loc3_.criticalHit)
            };
            _loc4_ = _loc3_.colors.split(",");
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc4_[_loc5_] = uint(_loc4_[_loc5_]);
               _loc5_++;
            }
            _loc2_.colors = _loc4_;
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
         var _loc1_:Object = null;
         for each(_loc1_ in _itemDefs)
         {
            _loc1_.name = LocalizationManager.translateIdOnly(_loc1_.titleStrId);
         }
      }
      
      private static function currencyExchangeDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         _currencyExchangeDefs = new Object();
         for each(_loc3_ in param1.def)
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
         var _loc1_:Object = null;
         for each(_loc1_ in _currencyExchangeDefs)
         {
            _loc1_.name = LocalizationManager.translateIdOnly(_loc1_.titleStrId);
         }
      }
      
      private static function currencyUpdateResponse(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:SBOkPopup = null;
         var _loc2_:int = int(param1[2]);
         var _loc3_:int = int(param1[3]);
         var _loc4_:Boolean = param1[4] == 3 || param1[4] == 4;
         var _loc5_:int = -1;
         if(_loc2_ == Item.GEM_CURRENCY)
         {
            _loc5_ = int(gMainFrame.clientInfo.gemCount);
            gMainFrame.clientInfo.gemCount = _loc3_;
            _loc7_ = _loc3_ - _loc5_;
            if(_loc7_ != 1)
            {
               _loc6_ = 14900;
            }
            else
            {
               _loc6_ = 14901;
            }
         }
         else if(_loc2_ == Item.TICKET_CURRENCY)
         {
            _loc5_ = int(gMainFrame.clientInfo.ticketCount);
            gMainFrame.clientInfo.ticketCount = _loc3_;
            _loc7_ = _loc3_ - _loc5_;
            if(_loc7_ != 1)
            {
               _loc6_ = 14902;
            }
            else
            {
               _loc6_ = 14903;
            }
         }
         else if(_loc2_ == Item.CRYSTAL_CURRENCY)
         {
            _loc5_ = int(gMainFrame.clientInfo.crystalCount);
            gMainFrame.clientInfo.crystalCount = _loc3_;
            _loc7_ = _loc3_ - _loc5_;
            if(_loc7_ != 1)
            {
               _loc6_ = 14904;
            }
            else
            {
               _loc6_ = 14905;
            }
         }
         else
         {
            if(_loc2_ != Item.DIAMOND_CURRENCY)
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc2_);
            }
            _loc5_ = int(gMainFrame.clientInfo.diamondCount);
            gMainFrame.clientInfo.diamondCount = _loc3_;
            _loc7_ = _loc3_ - _loc5_;
            if(_loc7_ != 1)
            {
               _loc6_ = 14906;
            }
            else
            {
               _loc6_ = 14907;
            }
         }
         if(_loc5_ < _loc3_)
         {
            QuestManager.currencyUpdate(_loc3_ - _loc5_);
            if(guiManager != null)
            {
               if(guiManager.guiLayer != null)
               {
                  if(_loc4_)
                  {
                     _loc8_ = new SBOkPopup(guiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc6_,Utility.convertNumberToString(_loc7_)));
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
               if(!gMainFrame.isInMinigame())
               {
                  guiManager.startGemsFlash();
               }
            }
         }
      }
      
      private static function currencyDonationResponse(param1:Object) : void
      {
         if(_donateCallback != null)
         {
            _donateCallback(param1[2]) == "1";
            _donateCallback = null;
         }
      }
      
      private static function currencyExchangeResponse(param1:Object) : void
      {
         if(_currencyExchangeCallback != null)
         {
            _currencyExchangeCallback(param1[2] == "1",param1[3]);
            _currencyExchangeCallback = null;
         }
      }
      
      public static function shopListResponse(param1:Object, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:Function = null;
         var _loc10_:Object = null;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         var _loc4_:* = 6;
         var _loc5_:int = int(param1[2]);
         var _loc6_:String = param1[4];
         _loc3_ = 0;
         while(_loc3_ < _slQueue.length)
         {
            if(_slQueue[_loc3_].hasOwnProperty(_loc5_))
            {
               _loc10_ = _slQueue.shift()[_loc5_];
               _loc9_ = _loc10_["c"];
               break;
            }
            _loc3_++;
         }
         if(param2 == DefPacksDefHelper.DEF_ITEM)
         {
            _loc7_ = int(param1[_loc4_++]);
            _loc11_ = [];
            _loc8_ = generateClothingShopList(_loc7_,param1.splice(_loc4_++,param1.length),_loc11_);
            if(_loc9_ != null)
            {
               _loc9_(_loc8_,_loc6_,_loc11_);
            }
         }
         else if(param2 == DefPacksDefHelper.DEF_DEN_ITEM || param2 == DefPacksDefHelper.DEF_DEN_ROOM)
         {
            if(_denShopListHandler != null)
            {
               _denShopListHandler(param1,_loc5_,param2,_loc9_);
            }
         }
         else if(param2 == DefPacksDefHelper.DEF_CURRENCY_EXCHANGE)
         {
            _loc7_ = int(param1[_loc4_++]);
            _loc8_ = generateCurrencyExchangeShopList(_loc7_,param1.splice(_loc4_++,param1.length));
            if(_loc9_ != null)
            {
               _loc9_(_loc8_,_loc6_);
            }
         }
         else
         {
            if(param2 != DefPacksDefHelper.DEF_DIAMOND)
            {
               throw new Error("Unimplemented shopList response type: " + param2);
            }
            _loc7_ = int(param1[_loc4_++]);
            _loc12_ = [];
            _loc8_ = DiamondXtCommManager.generateDiamondShopList(_loc7_,param1.splice(_loc4_++,param1.length),_loc12_);
            if(_loc9_ != null)
            {
               _loc9_(_loc8_,_loc6_,_loc12_);
            }
         }
      }
      
      public static function setItemBuyIlCallback(param1:Function) : void
      {
         _buyItemsIlCallback = param1;
      }
      
      public static function setHudAvtItemListLayerAnim(param1:LayerAnim) : void
      {
         _hudAvtLayerAnim = param1;
      }
      
      public static function generateBodyModList(param1:int, param2:int = -1, param3:int = -1, param4:Boolean = true) : Array
      {
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Item = null;
         var _loc5_:Array = [];
         var _loc9_:int = 0;
         while(_loc9_ < _bodyItemDefIds.length)
         {
            _loc6_ = int(_bodyItemDefIds[_loc9_]);
            _loc7_ = _itemDefs[_loc6_];
            if(_loc7_ == null)
            {
               throw new Error("ItemManager: unknown body itemDef=" + _loc6_);
            }
            _loc8_ = getBodyModFromDefId(_loc6_,param1,_loc6_ == 1 || _loc6_ == param2 || _loc6_ == param3,param4);
            _loc5_.push(_loc8_);
            _loc9_++;
         }
         return _loc5_;
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
      
      public static function generateClothingList(param1:int, param2:Array, param3:int, param4:int, param5:int, param6:Boolean) : Array
      {
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:Item = null;
         var _loc7_:* = 0;
         var _loc9_:Array = [];
         var _loc13_:Array = generateBodyModList(param3,param4,param5,param6);
         _loc8_ = 0;
         while(_loc8_ < param1)
         {
            _loc10_ = int(param2[_loc7_++]);
            _loc11_ = _itemDefs[_loc10_];
            if(_loc11_ == null)
            {
               throw new Error("ItemXtCommManager: unknown clothing itemDef=" + _loc10_);
            }
            _loc12_ = new Item();
            if(param6)
            {
               _loc12_.init(_loc10_,int(param2[_loc7_++]),uint(param2[_loc7_++]),int(param2[_loc7_++]),int(param2[_loc7_++]));
            }
            else
            {
               _loc12_.init(_loc10_,int(param2[_loc7_++]),uint(param2[_loc7_++]),-1,-1);
               _loc12_.setInUse(param3,true);
            }
            _loc9_[_loc8_] = _loc12_;
            _loc8_++;
         }
         _loc9_ = _loc13_.concat(_loc9_);
         if(param6)
         {
            _loc9_.sortOn("invIdx",Array.NUMERIC | Array.DESCENDING);
         }
         return _loc9_;
      }
      
      private static function generateClothingShopList(param1:int, param2:Array, param3:Array) : Array
      {
         var _loc6_:Object = null;
         var _loc8_:Item = null;
         var _loc4_:int = _playerAvatar.avTypeId;
         var _loc5_:Array = [];
         var _loc7_:int = 0;
         while(_loc7_ < param1)
         {
            _loc8_ = new Item();
            _loc6_ = ItemXtCommManager.getItemDef(int(param2[_loc7_]));
            param3[_loc7_] = _loc6_.colors.concat();
            _loc8_.init(_loc6_.defId,_loc7_,_loc6_.colors[0],0,0,true);
            _loc5_.push(_loc8_);
            _loc7_++;
         }
         return _loc5_;
      }
      
      private static function generateCurrencyExchangeShopList(param1:int, param2:Array) : Array
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:CurrencyItem = null;
         var _loc3_:Array = [];
         var _loc4_:* = 0;
         var _loc8_:* = 0;
         while(_loc8_ < param1)
         {
            _loc5_ = int(param2[_loc4_++]);
            _loc6_ = getCurrencyExchangeDef(_loc5_);
            if(!_loc6_)
            {
               _loc8_--;
            }
            else
            {
               _loc7_ = new CurrencyItem();
               _loc7_.init(_loc5_,_loc6_.mediaId,_loc6_.result,_loc6_.resultType,_loc6_.value,_loc6_.currencyType,_loc6_.name);
               _loc3_[_loc8_] = _loc7_;
            }
            _loc8_++;
         }
         return _loc3_;
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
         if(Boolean(param3) && Boolean(gMainFrame.userInfo.getAvatarDefByAvatar(param2)) && param1 == gMainFrame.userInfo.getAvatarDefByAvatar(param2).patternRefId)
         {
            return true;
         }
         return (_itemDefs[param1].avatarUseFlag & 1 << param2.avTypeId - 1) != 0;
      }
      
      public static function avTypeThatCanUseItem(param1:int) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = int(_itemDefs[param1].avatarUseFlag);
         var _loc5_:Array = [];
         while(_loc2_ > 0)
         {
            if((_loc2_ & 1) == 1)
            {
               _loc3_ += 1;
               _loc5_.push(_loc3_ + _loc4_);
            }
            else
            {
               _loc4_++;
            }
            _loc2_ >>= 1;
         }
         return _loc5_;
      }
   }
}

