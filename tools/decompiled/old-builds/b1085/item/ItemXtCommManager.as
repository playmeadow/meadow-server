package item
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
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
      
      private static var _bodyItemDefIds:Array = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,314,315,316,317,318,319,320,407,457,480];
      
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
         var _loc5_:int = param2.dbAvId;
         insertIntoILAvatarQueue(_loc5_,param1,param2);
         gMainFrame.server.setXtObject_Str("il",[param2.userName,_loc5_,param3 ? "1" : "0"],gMainFrame.server.isWorldZone,false,param4);
      }
      
      public static function insertIntoILAvatarQueue(param1:int, param2:Function, param3:Avatar) : void
      {
         if(param3.userName == gMainFrame.userInfo.myUserName)
         {
            hasRequestedFullItemList = true;
         }
         var _loc4_:Object = {};
         _loc4_[param1] = {
            "c":param2,
            "a":param3
         };
         _ilAvatarQueue.push(_loc4_);
      }
      
      public static function removeFromILAvatarQueue(param1:int) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < _ilAvatarQueue.length)
         {
            for(_loc3_ in _ilAvatarQueue[_loc2_])
            {
               if(int(_loc3_) == param1)
               {
                  _ilAvatarQueue.splice(_loc2_,1);
                  break;
               }
            }
            _loc2_++;
         }
      }
      
      public static function insertAvIntoAcIlQueue(param1:int, param2:Avatar, param3:Function) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = int(_ilAvatarQueue.length);
         if(Boolean(_ilAvatarQueue) && _loc4_ > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               if(Boolean(_ilAvatarQueue[_loc5_]) && _ilAvatarQueue[_loc5_].hasOwnProperty(param1))
               {
                  param3(param1,false);
               }
               _loc5_++;
            }
         }
         else
         {
            insertIntoILAvatarQueue(param1,null,param2);
            _acIlAvatarQueue.push({
               "i":param1,
               "c":param3
            });
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
      
      private static function getResponseItems(param1:Object, param2:int) : Object
      {
         var _loc5_:Avatar = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:int = 0;
         var _loc10_:AvatarInfo = null;
         var _loc3_:Object = {
            "ilCallback":null,
            "ilAvatar":null
         };
         var _loc4_:int = int(_ilAvatarQueue.length);
         if(_loc4_ > 0)
         {
            _loc9_ = 0;
            while(_loc9_ < _loc4_)
            {
               _loc6_ = _ilAvatarQueue[_loc9_].hasOwnProperty(param2) ? 1 : 0;
               if(_loc6_ == 0)
               {
                  _loc7_ = _ilAvatarQueue[_loc9_][0];
                  if((Boolean(_loc7_)) && Boolean(_loc7_["a"]))
                  {
                     _loc6_ = (_loc7_["a"].isChattyAvt ? _loc7_["a"].dbAvId == param2 : _loc7_["a"].myChattyDbAvId == param2) ? 2 : 0;
                  }
               }
               if(_loc6_ > 0)
               {
                  _loc8_ = _ilAvatarQueue.splice(_loc9_,1)[0][int(_loc6_ == 1 ? param2 : 0)];
                  _loc3_.ilCallback = _loc8_["c"];
                  _loc5_ = _loc8_["a"];
                  break;
               }
               _loc9_++;
            }
         }
         if(!_loc5_ && _getAvatarFromAvatarManager != null)
         {
            _loc3_.ilCallback = null;
            _loc5_ = _getAvatarFromAvatarManager(param2);
            if(!_loc5_)
            {
               if(param2 == gMainFrame.userInfo.myDbAvId && MinigameManager.inFullRoomGame)
               {
                  _loc10_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(param2);
                  _loc5_ = new Avatar();
                  _loc5_.init(param2,_loc10_.avName,_loc10_.type,_loc10_.colors,null,gMainFrame.userInfo.myUserName);
               }
               else if(_processAcIlComboFromAvatarManager != null)
               {
                  _processAcIlComboFromAvatarManager(param2,false,param1);
               }
            }
         }
         _loc3_.ilAvatar = _loc5_;
         return _loc3_;
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
         var _loc13_:Function = null;
         var _loc14_:Avatar = null;
         var _loc15_:int = 0;
         var _loc19_:Array = null;
         var _loc20_:int = 0;
         var _loc21_:Item = null;
         var _loc22_:Boolean = false;
         var _loc23_:Object = null;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc2_:Object = param1.concat();
         var _loc3_:Boolean = param1[2] == "3";
         var _loc4_:Boolean = param1[3] == "1";
         var _loc5_:int = int(param1[4]);
         var _loc6_:uint = uint(param1[5]);
         var _loc7_:int = int(param1[6]);
         var _loc8_:int = int(param1[7]);
         var _loc9_:* = 8;
         var _loc10_:Array = new Array();
         var _loc11_:Array = new Array();
         var _loc12_:Array = new Array();
         _loc15_ = 0;
         while(_loc15_ < _loc7_)
         {
            _loc11_.push(int(param1[_loc9_++]));
            _loc10_.push(int(param1[_loc9_++]));
            _loc15_++;
         }
         _loc15_ = 0;
         while(_loc15_ < _loc8_)
         {
            _loc12_.push(int(param1[_loc9_++]));
            _loc15_++;
         }
         var _loc16_:Object = getResponseItems(_loc2_,_loc5_);
         _loc14_ = _loc16_.ilAvatar;
         _loc13_ = _loc16_.ilCallback;
         if(!_loc14_)
         {
            return;
         }
         var _loc17_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByDbAvId(_loc5_);
         if((Boolean(_loc17_)) && _loc14_.userName == gMainFrame.userInfo.myUserName)
         {
            _loc19_ = _loc17_.getFullItems(true);
            _loc20_ = int(_loc19_.length);
            if(_loc19_)
            {
               _loc15_ = 0;
               while(_loc15_ < _loc11_.length)
               {
                  _loc24_ = 0;
                  while(_loc24_ < _loc20_)
                  {
                     if(_loc19_[_loc24_].invIdx == _loc11_[_loc15_])
                     {
                        _loc19_[_loc24_].setInUse(_loc17_.dbAvId,true);
                        _loc22_ = true;
                        break;
                     }
                     _loc24_++;
                  }
                  if(!_loc3_ && !_loc22_)
                  {
                     _loc23_ = getItemDef(_loc10_[_loc15_]);
                     _loc21_ = new Item();
                     _loc21_.init(_loc23_.defId,_loc11_[_loc15_],_loc6_);
                     _loc21_.setInUse(_loc17_.dbAvId,_loc4_);
                     _loc19_.unshift(_loc21_);
                  }
                  _loc22_ = false;
                  _loc15_++;
               }
               _loc20_ = int(_loc19_.length);
               _loc15_ = 0;
               while(_loc15_ < _loc12_.length)
               {
                  _loc24_ = 0;
                  while(_loc24_ < _loc20_)
                  {
                     if(_loc19_[_loc24_].invIdx == _loc12_[_loc15_])
                     {
                        _loc19_[_loc24_].setInUse(_loc17_.dbAvId,false);
                        if(!_loc3_)
                        {
                           _loc19_.splice(_loc24_,1);
                        }
                        break;
                     }
                     _loc24_++;
                  }
                  _loc15_++;
               }
               _loc17_.fullItemList = _loc19_;
               gMainFrame.userInfo.setAvatarInfoByDbAvId(_loc17_.dbAvId,_loc17_);
            }
         }
         _loc14_.itemResponseIntegrate(_loc17_.getItems(true));
         if(_loc13_ != null)
         {
            _loc13_();
         }
         if(_loc14_.userName == gMainFrame.userInfo.myUserName)
         {
            checkIlCallbacks(_loc17_.userName);
         }
         var _loc18_:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && _loc18_ > 0)
         {
            _loc25_ = 0;
            if(_loc25_ < _loc18_)
            {
               if(_acIlAvatarQueue[_loc25_].i == _loc14_.dbAvId)
               {
                  _acIlAvatarQueue[_loc25_].c(_loc14_.dbAvId,false,_loc2_);
               }
               _acIlAvatarQueue.splice(_loc25_,1);
            }
         }
      }
      
      private static function itemsInUseResponse(param1:Object) : void
      {
         var _loc8_:Function = null;
         var _loc9_:Avatar = null;
         var _loc10_:* = 0;
         var _loc12_:Array = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc16_:AvatarInfo = null;
         var _loc18_:Object = null;
         var _loc19_:int = 0;
         var _loc2_:Object = param1.concat();
         var _loc3_:int = int(param1[3]);
         var _loc4_:int = int(param1[4]);
         var _loc5_:int = int(param1[5]);
         var _loc6_:int = int(param1[6]);
         var _loc7_:Array = param1.splice(7,param1.length);
         var _loc11_:Object = getResponseItems(_loc2_,_loc3_);
         _loc9_ = _loc11_.ilAvatar;
         _loc8_ = _loc11_.ilCallback;
         if(!_loc9_)
         {
            return;
         }
         var _loc15_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc9_.userName);
         if(_loc9_.userName == gMainFrame.userInfo.myUserName)
         {
            _loc12_ = _loc15_.fullItemList;
            _loc14_ = int(_loc12_.length);
            _loc13_ = 0;
            while(_loc13_ < _loc14_)
            {
               _loc18_ = _loc12_[_loc13_];
               if(_loc18_.defId == 1 || _loc18_.defId == _loc4_ || _loc18_.defId == _loc5_)
               {
                  _loc18_.setInUse(_loc9_.dbAvId,true);
               }
               else
               {
                  _loc10_ = 1;
                  while(_loc10_ < _loc6_)
                  {
                     if(_loc18_.invIdx == int(_loc7_[_loc10_]))
                     {
                        _loc18_.setInUse(_loc9_.dbAvId,true);
                     }
                     _loc10_ += 2;
                     _loc10_ = _loc10_ + 1;
                  }
               }
               _loc13_++;
            }
            _loc15_.fullItemList = _loc12_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc9_.userName,_loc15_);
         }
         else
         {
            _loc12_ = generateClothingList(_loc6_,_loc7_,_loc9_.dbAvId,_loc4_,_loc5_,false);
            _loc15_.fullItemList = _loc12_;
            gMainFrame.userInfo.setUserInfoByUserName(_loc9_.userName,_loc15_);
         }
         _loc16_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(_loc3_);
         if(_loc16_ == null)
         {
            _loc16_ = new AvatarInfo();
            if(_loc3_ == _loc9_.dbAvId)
            {
               _loc16_.init(_loc3_,_loc9_.avName,_loc9_.userName,_loc9_.avTypeId,_loc9_.colors);
            }
            else
            {
               _loc16_.init(_loc3_);
            }
         }
         gMainFrame.userInfo.setAvatarInfoByDbAvId(_loc3_,_loc16_);
         _loc9_.itemResponseIntegrate(_loc15_.getPartialItemList(_loc16_.type,true));
         if(_loc8_ != null)
         {
            _loc8_();
         }
         if(_loc9_.userName == gMainFrame.userInfo.myUserName)
         {
            checkIlCallbacks(_loc16_.userName);
         }
         var _loc17_:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && _loc17_ > 0)
         {
            _loc19_ = 0;
            if(_loc19_ < _loc17_)
            {
               if(_acIlAvatarQueue[_loc19_].i == _loc9_.dbAvId)
               {
                  _acIlAvatarQueue[_loc19_].c(_loc9_.dbAvId,false,_loc2_);
               }
               _acIlAvatarQueue.splice(_loc19_,1);
            }
         }
      }
      
      public static function handleIlWhenBeforeACAfterReceivingAC(param1:Object) : void
      {
         itemListResponse(param1);
      }
      
      private static function itemListResponse(param1:Object) : void
      {
         var _loc9_:Function = null;
         var _loc10_:Avatar = null;
         var _loc17_:AvatarInfo = null;
         var _loc20_:int = 0;
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
               itemsChangedListResponse(param1);
            }
            return;
         }
         var _loc4_:int = int(param1[3]);
         var _loc5_:int = int(param1[4]);
         var _loc6_:int = int(param1[5]);
         var _loc7_:int = int(param1[6]);
         var _loc8_:Array = param1.splice(7,param1.length);
         var _loc11_:int = int(_ilAvatarQueue.length);
         var _loc12_:Object = getResponseItems(_loc2_,_loc4_);
         _loc10_ = _loc12_.ilAvatar;
         _loc9_ = _loc12_.ilCallback;
         if(!_loc10_)
         {
            return;
         }
         var _loc13_:Array = generateClothingList(_loc7_,_loc8_,_loc10_.dbAvId,_loc5_,_loc6_,_loc10_.userName == gMainFrame.userInfo.myUserName);
         var _loc14_:Array = [];
         var _loc15_:int = int(_loc13_.length);
         var _loc16_:int = 0;
         while(_loc16_ < _loc15_)
         {
            _loc14_[_loc16_] = _loc13_[_loc16_].clone();
            _loc16_++;
         }
         _loc13_ = null;
         if(_loc10_.userName != gMainFrame.userInfo.myUserName)
         {
            return;
         }
         var _loc18_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_loc10_.userName);
         _loc17_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(_loc4_);
         _loc18_.fullItemList = _loc14_;
         gMainFrame.userInfo.setUserInfoByUserName(_loc10_.userName,_loc18_);
         _loc10_.itemResponseIntegrate(_loc18_.getPartialItemList(_loc17_.type,true));
         if(_loc9_ != null)
         {
            _loc9_();
         }
         checkIlCallbacks(_loc17_.userName);
         var _loc19_:int = int(_acIlAvatarQueue.length);
         if(Boolean(_acIlAvatarQueue) && _loc19_ > 0)
         {
            _loc20_ = 0;
            if(_loc20_ < _loc19_)
            {
               if(_acIlAvatarQueue[_loc20_].i == _loc10_.dbAvId)
               {
                  _acIlAvatarQueue[_loc20_].c(_loc10_.dbAvId,false,_loc2_);
               }
               _acIlAvatarQueue.splice(_loc20_,1);
            }
         }
         _loc14_ = null;
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
               case Item.ORB_CURRENCY:
                  _loc6_ = int(gMainFrame.clientInfo.orbCount);
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
               case Item.ORB_CURRENCY:
                  gMainFrame.clientInfo.orbCount = _loc6_;
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
               "isGiftable":_loc3_.isGiftable == "1",
               "isMembersOnly":_loc3_.membersOnly == "1",
               "isNew":_loc3_.itemStatus == "1",
               "isOnSale":_loc3_.itemStatus == "2",
               "enviroType":int(_loc3_.enviroType),
               "avatarUseFlag":int(_loc3_.avatarUseFlags),
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
               "name":""
            };
            _currencyExchangeDefs[_loc2_.defId] = _loc2_;
            _currencyExchangeDefs[int(_loc3_.id)].name = LocalizationManager.translateIdOnly(_loc3_.titleStrId);
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
         else if(_loc2_ == Item.ORB_CURRENCY)
         {
            _loc5_ = int(gMainFrame.clientInfo.orbCount);
            gMainFrame.clientInfo.orbCount = _loc3_;
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
      
      public static function canUseItem(param1:int, param2:int) : Boolean
      {
         return (_itemDefs[param1].avatarUseFlag & 1 << param2 - 1) != 0;
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
      
      public static function getFirstAvTypeThatCanUseItem(param1:int) : int
      {
         var _loc2_:Array = avTypeThatCanUseItem(param1);
         if(Boolean(_loc2_) && _loc2_.length > 0)
         {
            return _loc2_[0];
         }
         return -1;
      }
      
      public static function isItemSpecificToSomeAvatar(param1:int, param2:int) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc3_:int = int(_itemDefs[param1].avatarUseFlag);
         while(_loc3_ > 0)
         {
            if((_loc3_ & 1) == 0)
            {
               _loc5_ = gMainFrame.userInfo.getAvatarDefByAvType(_loc4_ + 1);
               if(_loc5_)
               {
                  if(Utility.isSameEnviroType(_loc5_.enviroTypeFlag,AvatarManager.roomEnviroType))
                  {
                     if(Utility.isSameEnviroType(_loc5_.enviroTypeFlag,param2))
                     {
                        return true;
                     }
                  }
               }
            }
            _loc3_ >>= 1;
            _loc4_++;
         }
         return false;
      }
   }
}

