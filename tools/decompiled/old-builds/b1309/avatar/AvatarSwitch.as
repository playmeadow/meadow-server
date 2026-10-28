package avatar
{
   import buddy.BuddyEvent;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.media.SoundTransform;
   import gui.BuddyManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.GuiNameTypeScreen;
   import inventory.Iitem;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class AvatarSwitch
   {
      
      public static const ASTRANSFORM_MEDIA_ID_TOP:int = 33;
      
      public static const ASTRANSFORM_MEDIA_ID_BOTTOM:int = 34;
      
      public static const ASTRANSFORM_OCEAN_MEDIA_ID_TOP:int = 1171;
      
      public static const ASTRANSFORM_OCEAN_MEDIA_ID_BOTTOM:int = 1172;
      
      public static var avatars:Array;
      
      public static var activeAvatarIdx:int;
      
      public static var playerUserInfo:UserInfo;
      
      public static var nameTypeScreen:GuiNameTypeScreen;
      
      public static var playerUsername:String;
      
      public static var playerSfsUserId:int;
      
      public static var isSlotAvail:int;
      
      public static var isAddingSlot:Boolean;
      
      public static var availSlotFlags:uint;
      
      public static var isChoosing:Boolean;
      
      private static var _addSlotCallback:Function;
      
      private static var _switchCallback:Function;
      
      private static var _addIdx:int;
      
      private static var _switchIdx:int;
      
      private static var _addAvatarCallback:Function;
      
      private static var _addFastPassAvatarCallback:Function;
      
      private static var _addAvatar:Avatar;
      
      private static var _addAvName:String;
      
      private static var _removeCallback:Function;
      
      private static var _removeIdx:int;
      
      private static var _isChoosing:Boolean;
      
      private static var _isSwitchingDen:Boolean;
      
      private static var _asTransformVec:Vector.<MediaHelper>;
      
      private static var _secondChosenAvtIdx:int;
      
      private static var _numOpenNonMemberSlots:int;
      
      private static var _caIdx:int;
      
      private static var _avatarName:String;
      
      private static var _avatarNameIndexes:Array;
      
      private static var _avatarDiamondDefId:int;
      
      private static var _shopId:int;
      
      private static var _itemInShopDefId:int;
      
      private static var _status:int;
      
      public function AvatarSwitch()
      {
         super();
      }
      
      public static function init() : void
      {
         _asTransformVec = new Vector.<MediaHelper>();
         _secondChosenAvtIdx = -1;
      }
      
      public static function destroy() : void
      {
         _asTransformVec = null;
      }
      
      public static function playerInfoSet() : void
      {
         playerUserInfo = gMainFrame.userInfo.playerUserInfo;
         playerUsername = playerUserInfo ? playerUserInfo.userName : gMainFrame.userInfo.myUserName;
         playerSfsUserId = gMainFrame.server.userId;
         avatars = [];
         if(playerUserInfo)
         {
            updateAvatars();
         }
      }
      
      public static function updateCurrentAvatarAfterRedemption(param1:Avatar) : void
      {
         var _loc2_:int = 0;
         if(avatars)
         {
            _loc2_ = 0;
            while(_loc2_ < avatars.length)
            {
               if(avatars[_loc2_])
               {
                  if(avatars[_loc2_].perUserAvId == gMainFrame.userInfo.myPerUserAvId)
                  {
                     avatars[_loc2_] = param1;
                     break;
                  }
               }
               _loc2_++;
            }
         }
      }
      
      public static function updateAfterRedeemingAvatar(param1:uint) : void
      {
         myAvatarListCallback(param1);
         playerUserInfo = null;
         playerInfoSet();
         GuiManager.showHudAvt();
      }
      
      public static function updateSlotPositions() : void
      {
         var _loc4_:int = 0;
         var _loc3_:Array = avatars.slice();
         var _loc5_:int = int(avatars[_switchIdx].perUserAvId);
         var _loc1_:int = int(avatars[activeAvatarIdx].perUserAvId);
         var _loc2_:int = 0;
         avatars = [];
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_] != null)
            {
               avatars.push(_loc3_[_loc4_]);
               if(_loc5_ == _loc3_[_loc4_].perUserAvId)
               {
                  _switchIdx = _loc4_ - _loc2_;
                  AvatarXtCommManager.avSlotInfo[_loc5_].slotId = _switchIdx;
               }
               if(_loc1_ == _loc3_[_loc4_].perUserAvId)
               {
                  activeAvatarIdx = _loc4_ - _loc2_;
                  AvatarXtCommManager.avSlotInfo[_loc1_].slotId = activeAvatarIdx;
               }
            }
            else
            {
               _loc2_++;
            }
            _loc4_++;
         }
      }
      
      private static function updateAvatars() : void
      {
         var _loc1_:Avatar = null;
         var _loc2_:int = 0;
         var _loc5_:Avatar = null;
         for each(var _loc4_:AvatarInfo in playerUserInfo.avList)
         {
            if(_loc4_.perUserAvId == playerUserInfo.currPerUserAvId)
            {
               _loc1_ = AvatarManager.playerAvatar;
            }
            else
            {
               _loc1_ = avatars[AvatarXtCommManager.avSlotInfo[_loc4_.perUserAvId].slotId];
               if(!_loc1_)
               {
                  _loc1_ = new Avatar();
                  _loc1_ = AvatarUtility.generateNew(_loc4_.perUserAvId,_loc1_,_loc4_.userName,playerSfsUserId,AvatarManager.roomEnviroType);
               }
            }
            avatars[AvatarXtCommManager.avSlotInfo[_loc4_.perUserAvId].slotId] = _loc1_;
            _loc1_ = null;
         }
         var _loc3_:int = int(avatars.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(avatars[_loc2_] != null)
            {
               _loc5_ = avatars[_loc2_];
               if(playerUserInfo.currPerUserAvId == _loc5_.perUserAvId)
               {
                  activeAvatarIdx = _switchIdx = _loc2_;
                  break;
               }
            }
            _loc2_++;
         }
      }
      
      public static function shouldChoose() : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < avatars.length)
         {
            if(avatars[_loc2_])
            {
               if(isMemberOnlyAvatar(_loc2_))
               {
                  _loc1_++;
               }
               else
               {
                  if(avatars[_loc2_].enviroTypeFlag == 2)
                  {
                     _loc3_++;
                  }
                  _loc4_++;
               }
            }
            _loc2_++;
         }
         if(_loc4_ < 3 && _loc4_ > 0 && _loc3_ < 2 && _loc4_ != _loc3_)
         {
            return false;
         }
         return true;
      }
      
      public static function isMemberOnlyAvatar(param1:int) : Boolean
      {
         return gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[param1].avTypeId);
      }
      
      public static function get numTotalAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < avatars.length)
         {
            if(avatars[_loc2_])
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function isAvInvIdUsable(param1:int) : Boolean
      {
         if(gMainFrame.userInfo.isMember && param1 < 36)
         {
            return true;
         }
         param1 += 1;
         if(availSlotFlags == 4294967295 || (availSlotFlags & 0xFFFF) == param1 || (availSlotFlags & 0xFFFF0000) >> 16 == param1)
         {
            return true;
         }
         return false;
      }
      
      public static function adjustAvailSlotFlags(param1:int, param2:Boolean) : void
      {
         param1 += 1;
         if(!gMainFrame.userInfo.isMember)
         {
            if((availSlotFlags & 0xFFFF) == 0)
            {
               if(param2)
               {
                  availSlotFlags |= param1;
               }
               else
               {
                  availSlotFlags |= 4294901760;
               }
            }
            else if((availSlotFlags & 0xFFFF0000) >> 16 == 0)
            {
               if(param2)
               {
                  availSlotFlags |= param1 << 16;
               }
               else
               {
                  availSlotFlags &= 65535;
               }
            }
         }
      }
      
      public static function getNumUsableLandAvatars(param1:Boolean, param2:Boolean) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < avatars.length)
         {
            if(avatars[_loc4_] && Utility.isLand(avatars[_loc4_].enviroTypeFlag))
            {
               if(param1 || param2)
               {
                  _loc3_++;
               }
               else if(isAvInvIdUsable(AvatarXtCommManager.avSlotInfo[avatars[_loc4_].perUserAvId].avInvId))
               {
                  _loc3_++;
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function get numMemberAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < avatars.length)
         {
            if(avatars[_loc2_] && gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function get numNonMemberAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < avatars.length)
         {
            if(avatars[_loc2_] && !gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function get numNonMemberOceanAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < avatars.length)
         {
            if(avatars[_loc2_] && !gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId) && avatars[_loc2_].enviroTypeFlag == 2)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function getNumNonMemberAvailableAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < avatars.length)
         {
            if(avatars[_loc2_] && !gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId) && isAvInvIdUsable(AvatarXtCommManager.avSlotInfo[avatars[_loc2_].perUserAvId].avInvId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function get numAvailAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < avatars.length)
         {
            if(avatars[_loc2_] && isAvInvIdUsable(AvatarXtCommManager.avSlotInfo[avatars[_loc2_].perUserAvId].avInvId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function isSwitching() : Boolean
      {
         return activeAvatarIdx != _switchIdx;
      }
      
      public static function isSlotAvailable(param1:int) : Boolean
      {
         return isAvInvIdUsable(AvatarXtCommManager.avSlotInfo[avatars[param1].perUserAvId].avInvId);
      }
      
      public static function get numOpenNonMemberSlots() : int
      {
         return _numOpenNonMemberSlots;
      }
      
      public static function set numOpenNonMemberSlots(param1:int) : void
      {
         _numOpenNonMemberSlots = param1;
      }
      
      public static function addSlot(param1:Function) : void
      {
         _addSlotCallback = param1;
         AvatarXtCommManager.requestAvatarBuy(showNewAvatarPopup);
      }
      
      public static function showNewAvatarPopup(param1:Boolean) : void
      {
         if(param1)
         {
            isAddingSlot = false;
            addNewWorldAvatar(_caIdx,_avatarName,_avatarNameIndexes,_avatarDiamondDefId);
         }
         DarkenManager.showLoadingSpiral(false);
         if(_addSlotCallback != null)
         {
            _addSlotCallback(param1,true);
         }
      }
      
      public static function addAvatar(param1:int, param2:Boolean = false, param3:Function = null, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false, param7:int = -1, param8:Boolean = false, param9:int = -1, param10:int = -1, param11:Iitem = null) : void
      {
         _addIdx = param1;
         _addAvatarCallback = param3;
         _isChoosing = param4;
         _shopId = param9;
         _itemInShopDefId = param10;
         _isSwitchingDen = param6;
         isAddingSlot = param2;
         var _loc12_:int = AvatarUtility.numNonMemberAvatars();
         GuiManager.openAvatarCreator(param5,_loc12_ >= 1 && _loc12_ - numNonMemberOceanAvatars > 0 ? false : param4,param7,param8,param11);
      }
      
      public static function addFastPassAvatar(param1:Function) : void
      {
         _addFastPassAvatarCallback = param1;
         GuiManager.openFastPassAvatarCreator();
      }
      
      public static function set addFastPassAvatarCallback(param1:Function) : void
      {
         _addFastPassAvatarCallback = param1;
      }
      
      public static function set addAvatarCallback(param1:Function) : void
      {
         _addAvatarCallback = param1;
      }
      
      public static function addNewWorldAvatar(param1:int, param2:String, param3:Array, param4:int = -1, param5:int = -1, param6:Boolean = false) : void
      {
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         if(isAddingSlot)
         {
            _caIdx = param1;
            _avatarName = param2;
            _avatarNameIndexes = param3;
            _avatarDiamondDefId = param4;
            addSlot(_addAvatarCallback);
         }
         else
         {
            _addAvatar = AvatarUtility.findCreationAvatarByType(param1,param5);
            _addAvName = param2;
            if(_addAvatar != null && param3[0] != null && param3[1] != null && param3[2] != null)
            {
               _loc8_ = int(LocalizationManager.isCurrLanguageReversed() ? param3[2] : param3[1]);
               _loc7_ = int(LocalizationManager.isCurrLanguageReversed() ? param3[1] : param3[2]);
               SBTracker.pop();
               if(QuestManager.isInPrivateAdventureState)
               {
                  QuestManager.privateAdventureJoinClose(true);
               }
               if(param6)
               {
                  AvatarXtCommManager.requestAvatarFastPassAdd([_addAvatar.avTypeId,param3[0],_loc8_,_loc7_],addFastPassAvatarResponse);
               }
               else
               {
                  AvatarXtCommManager.requestAvatarAdd([param3[0],_loc8_,_loc7_,_addAvatar.avTypeId,_addAvatar.customAvId,param4,GenericListXtCommManager.getAvailListUniqueId(),_shopId],addAvatarResponse);
               }
            }
            else
            {
               DebugUtility.debugTrace("Failed to request add avatar with addAvatar = " + _addAvatar + " AvatarNameIndexes[0] = " + param3[0] + " AvatarNameIndexes[1] = " + param3[1] + " AvatarNameIndexes[2] = " + param3[2] + " addAvatar.avTypeId = " + (_addAvatar != null ? _addAvatar.avTypeId : null));
            }
         }
      }
      
      public static function addAvatarResponse(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:Avatar = null;
         _status = param1;
         if(_status == 1)
         {
            _loc4_ = new Avatar();
            _loc4_.init(param2,_addAvName,_addAvatar.avTypeId,null,_addAvatar.customAvId,null,playerUsername,playerSfsUserId);
            _loc4_.copyColors(_addAvatar.colors);
            _loc4_.cloneShownAccFromAvatar(_addAvatar);
            _loc4_.accState.hideAllClothingArticles();
            if(_isChoosing)
            {
               AvatarXtCommManager.avSlotInfo[_loc4_.perUserAvId] = {
                  "slotId":_addIdx,
                  "avInvId":param3
               };
               avatars[_addIdx] = _loc4_;
               AvatarXtCommManager.requestADForAvatar(_loc4_.perUserAvId,true,onChoosingAdReceive,_loc4_);
               return;
            }
            adjustAvailSlotFlags(param3,true);
            if(!Utility.isSameEnviroType(_loc4_.enviroTypeFlag,AvatarManager.roomEnviroType))
            {
               avatars.splice(_addIdx,1);
               avatars.unshift(_loc4_);
               for each(var _loc5_:Object in AvatarXtCommManager.avSlotInfo)
               {
                  _loc5_.slotId++;
               }
               AvatarXtCommManager.avSlotInfo[_loc4_.perUserAvId] = {
                  "slotId":0,
                  "avInvId":param3
               };
               _addIdx = 0;
            }
            else
            {
               AvatarXtCommManager.avSlotInfo[_loc4_.perUserAvId] = {
                  "slotId":_addIdx,
                  "avInvId":param3
               };
               avatars[_addIdx] = _loc4_;
            }
            if(_isSwitchingDen && _addAvatarCallback != null)
            {
               _addAvatarCallback(_status);
            }
            else
            {
               switchAvatars(_addIdx);
            }
         }
         if(_status != 1)
         {
            DarkenManager.showLoadingSpiral(false);
            if(_addAvatarCallback != null)
            {
               _addAvatarCallback(_status);
               _addAvatarCallback = null;
            }
         }
      }
      
      public static function addFastPassAvatarResponse(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_addFastPassAvatarCallback != null)
         {
            _addFastPassAvatarCallback(param1);
            _addFastPassAvatarCallback = null;
         }
         if(param1)
         {
            AvatarXtCommManager.requestAvatarList([1,gMainFrame.userInfo.myUserName],AvatarSwitch.myAvatarListCallback);
            gMainFrame.userInfo.needFastPass = false;
            RoomManagerWorld.instance.setUpWorldJoin();
         }
      }
      
      private static function onChoosingAdReceive(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_addAvatarCallback != null)
         {
            _addAvatarCallback(_status);
            _addAvatarCallback = null;
         }
      }
      
      public static function switchAvatars(param1:int, param2:Function = null) : void
      {
         if(param1 < 0 || param1 >= avatars.length)
         {
            throw new Error("Invalid switchIdx:" + param1);
         }
         _switchCallback = param2;
         _switchIdx = param1;
         RoomXtCommManager.isSwitching = true;
         _isChoosing = false;
         DarkenManager.showLoadingSpiral(true);
         RoomManagerWorld.instance.forceStopMovement();
         AvatarXtCommManager.requestAvatarSwitch([avatars[param1].perUserAvId]);
      }
      
      public static function setAvatarSwitchCallback(param1:Function) : void
      {
         _switchCallback = param1;
      }
      
      public static function avatarSwitchResponse(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc9_:AvatarWorldView = null;
         var _loc5_:int = 0;
         var _loc2_:DisplayObject = null;
         var _loc3_:MediaHelper = null;
         var _loc8_:MediaHelper = null;
         DarkenManager.showLoadingSpiral(false);
         if(!_isChoosing)
         {
            if(_addAvatarCallback != null)
            {
               _addAvatarCallback(true);
               _addAvatarCallback = null;
            }
         }
         var _loc6_:int = 2;
         var _loc7_:Boolean = Boolean(int(param1[_loc6_++]));
         if(_loc7_)
         {
            _loc4_ = int(param1[_loc6_++]);
            _loc9_ = AvatarManager.avatarViewList[_loc4_];
            if(_loc9_ == null)
            {
               DebugUtility.debugTrace("ERROR: invalid avatar worldview savw:" + _loc9_ + " sfsUserId:" + _loc4_ + " data:" + param1);
               return;
            }
            _loc9_.setActivePet(0,0,0,"");
            if(_loc9_.getChildAt(0).hasOwnProperty("onbottom1"))
            {
               _loc5_ = _loc9_.numChildren - 1;
               while(_loc5_ > 0)
               {
                  _loc2_ = _loc9_.getChildAt(_loc5_);
                  if(_loc2_ is MovieClip && Boolean(MovieClip(_loc2_).hasOwnProperty("isTransformTop")))
                  {
                     endTransformAnim(MovieClip(_loc2_));
                     break;
                  }
                  _loc5_--;
               }
               endTransformAnim(_loc9_.getChildAt(0) as MovieClip);
            }
            if(_asTransformVec == null)
            {
               DebugUtility.debugTrace("ERROR: invalid AvatarSwitch state _asTransformTopMHVec: data:" + param1);
               return;
            }
            _loc3_ = new MediaHelper();
            _loc3_.init(_loc9_.roomType == 0 ? 33 : 1171,asTransformMediaHelper,[_loc9_,param1]);
            _asTransformVec.push(_loc3_);
            _loc8_ = new MediaHelper();
            _loc8_.init(_loc9_.roomType == 0 ? 34 : 1172,asTransformMediaHelper,[_loc9_]);
            _asTransformVec.push(_loc8_);
            if(_loc4_ == playerSfsUserId)
            {
               GuiManager.setSwapBtnGray(true);
            }
         }
         else
         {
            DebugUtility.debugTrace("switch error!!!");
            RoomXtCommManager.isSwitching = false;
            if(!QuestManager.isInPrivateAdventureState)
            {
               GuiManager.setSwapBtnGray(false);
            }
            if(_switchIdx != activeAvatarIdx)
            {
               _switchIdx = activeAvatarIdx;
            }
         }
         if(_switchCallback != null)
         {
            _switchCallback(_loc7_,true);
            if(!_loc7_)
            {
               _switchCallback = null;
            }
         }
      }
      
      public static function myAvatarListCallback(param1:uint) : void
      {
         availSlotFlags = param1;
      }
      
      public static function removeAvatar(param1:int, param2:Function) : void
      {
         if(param1 < 0 || param1 >= avatars.length)
         {
            throw new Error("Invalid removeIdx:" + param1);
         }
         if(avatars.length <= 1)
         {
            throw new Error("Tried to remove avatar when less than 2 were left!");
         }
         _removeCallback = param2;
         _removeIdx = param1;
         AvatarXtCommManager.requestAvatarKill([avatars[param1].perUserAvId],avatarKillResponse);
      }
      
      public static function avatarKillResponse(param1:Boolean, param2:int) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Boolean = false;
         var _loc3_:UserInfo = null;
         if(param1)
         {
            _loc4_ = isSlotAvailable(_removeIdx);
            _loc5_ = int(AvatarXtCommManager.avSlotInfo[avatars[_removeIdx].perUserAvId].avInvId);
            _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(avatars[_removeIdx].userName);
            _loc3_.allItemsInUseOff(avatars[_removeIdx].perUserAvId);
            _loc3_.removeAvatarFromList(avatars[_removeIdx].perUserAvId);
            delete AvatarXtCommManager.avSlotInfo[avatars[_removeIdx].perUserAvId];
            delete avatars[_removeIdx];
         }
         if(_removeCallback != null)
         {
            _removeCallback(param1,_removeIdx,_loc5_,param2,_loc4_);
         }
         _removeIdx = -1;
      }
      
      public static function chooseTwo(param1:Array, param2:Function) : void
      {
         _switchIdx = avatars[param1[0]].enviroTypeFlag == 2 ? param1[1] : param1[0];
         _secondChosenAvtIdx = -1;
         var _loc3_:Array = [];
         _loc3_[0] = AvatarXtCommManager.avSlotInfo[avatars[param1[0]].perUserAvId].avInvId;
         if(param1[1] != null && AvatarSwitch.avatars[param1[1]])
         {
            _loc3_[1] = AvatarXtCommManager.avSlotInfo[avatars[param1[1]].perUserAvId].avInvId;
            _secondChosenAvtIdx = param1[1];
         }
         AvatarXtCommManager.requestAvatarOrdain(_loc3_,param2);
      }
      
      private static function asTransformMediaHelper(param1:MovieClip) : void
      {
         if(!param1.hasOwnProperty("mediaHelper"))
         {
            return;
         }
         var _loc4_:MediaHelper = MediaHelper(param1.mediaHelper);
         var _loc2_:int = _loc4_.id;
         if(_loc2_ != 33 && _loc2_ != 34 && _loc2_ != 1171 && _loc2_ != 1172)
         {
            return;
         }
         param1.addEventListener("enterFrame",transformEnterFrameHandler);
         var _loc3_:AvatarView = AvatarView((param1.passback as Array)[0]);
         if(_loc2_ == 33 || _loc2_ == 1171)
         {
            param1.data = (param1.passback as Array)[1] as Array;
            DebugUtility.debugTrace("got top media for sfsUserId:" + int(param1.data[3]));
            param1.isTransformTop = true;
            _loc3_.addChild(param1);
            _asTransformVec.splice(_asTransformVec.indexOf(_loc4_),1);
         }
         else
         {
            param1.isTransformBottom = true;
            _loc3_.addChildAt(param1,0);
            _asTransformVec.splice(_asTransformVec.indexOf(_loc4_),1);
         }
         param1.gotoAndPlay(1);
         param1.mediaHelper.destroy();
         delete param1.mediaHelper;
         delete param1.passback;
      }
      
      private static function transformEnterFrameHandler(param1:Event) : void
      {
         var _loc5_:Array = null;
         var _loc17_:int = 0;
         var _loc16_:int = 0;
         var _loc19_:Boolean = false;
         var _loc9_:Avatar = null;
         var _loc23_:Avatar = null;
         var _loc20_:AvatarInfo = null;
         var _loc2_:AvatarWorldView = null;
         var _loc3_:Avatar = null;
         var _loc12_:int = 0;
         var _loc10_:Object = null;
         var _loc15_:AvatarInfo = null;
         var _loc4_:int = 0;
         var _loc11_:int = 0;
         var _loc6_:int = 0;
         var _loc13_:String = null;
         var _loc8_:int = 0;
         var _loc7_:Object = null;
         var _loc21_:BuddyEvent = null;
         var _loc22_:AvatarWorldView = null;
         var _loc18_:AvatarWorldView = null;
         var _loc14_:MovieClip = MovieClip(param1.target);
         if(_loc14_.parent == null || AvatarView(_loc14_.parent).avatarData == null)
         {
            endTransformAnim(_loc14_);
            return;
         }
         if(_loc14_.currentFrameLabel != null)
         {
            DebugUtility.debugTrace("entered frame:" + _loc14_.currentFrameLabel + " on transform effect for sfsUserId:" + AvatarView(_loc14_.parent).userId);
         }
         if(_loc14_.currentFrameLabel == "hideAvatar")
         {
            AvatarView(_loc14_.parent).hideAvatar();
            if(_loc14_.hasOwnProperty("data"))
            {
               _loc5_ = _loc14_.data;
               _loc17_ = 3;
               _loc16_ = int(_loc5_[_loc17_++]);
               _loc19_ = _loc16_ == playerSfsUserId;
               _loc9_ = AvatarManager.getAvatarBySfsUserId(_loc16_);
               if(_loc19_)
               {
                  _loc23_ = avatars[_switchIdx];
                  _loc23_.perUserAvId = _loc9_.perUserAvId;
                  _loc23_.avTypeId = _loc9_.avTypeId;
                  _loc23_.copyColors(_loc9_.colors);
                  _loc23_.avName = _loc9_.avName;
                  _loc23_.cloneShownAccFromAvatar(_loc9_);
                  _loc23_.customAvId = _loc9_.customAvId;
                  AvatarManager.clearPlayerSplashColor();
               }
               _loc9_.removeAllItems();
               _loc9_.perUserAvId = int(_loc5_[_loc17_++]);
               _loc9_.customAvId = int(_loc5_[_loc17_++]);
               _loc9_.avTypeId = int(_loc5_[_loc17_++]);
               _loc9_.setColors(uint(_loc5_[_loc17_++]),uint(_loc5_[_loc17_++]),uint(_loc5_[_loc17_++]));
               _loc9_.avName = _loc5_[_loc17_++];
               if(_loc9_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc9_.userName,_loc9_.perUserAvId) == null)
               {
                  AvatarXtCommManager.requestADForAvatar(_loc9_.perUserAvId,true,null,_loc9_);
               }
               else
               {
                  _loc20_ = new AvatarInfo();
                  _loc20_.perUserAvId = _loc9_.perUserAvId;
                  _loc20_.avName = _loc9_.avName;
                  _loc20_.userName = _loc9_.userName;
                  _loc20_.colors = _loc9_.colors.concat();
                  _loc20_.type = _loc9_.avTypeId;
                  _loc20_.customAvId = _loc9_.customAvId;
               }
               _loc2_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc16_);
               if(_loc2_)
               {
                  if(_loc2_.parent != null)
                  {
                     _loc2_.parent.removeChild(_loc2_);
                  }
                  if(_loc9_.enviroTypeFlag & 1 << 2)
                  {
                     _loc2_.x += AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                     _loc2_.y += AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                     AvatarManager.getFlyingLayer.addChild(_loc2_);
                  }
                  else
                  {
                     _loc2_.x -= AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                     _loc2_.y -= AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                     AvatarManager.getAvatarLayer.addChild(_loc2_);
                  }
               }
               if(_loc19_)
               {
                  if((_loc23_.enviroTypeFlag & 1 << 2) != (_loc9_.enviroTypeFlag & 1 << 2))
                  {
                     RoomManagerWorld.instance.rebuildGrid();
                     if(_loc2_ == null && !(_loc9_.enviroTypeFlag & 1 << 2) || RoomManagerWorld.instance.collisionTestGrid(_loc2_.x,_loc2_.y))
                     {
                        RoomManagerWorld.instance.teleportPlayerToDefault();
                     }
                  }
                  gMainFrame.userInfo.myPerUserAvId = _loc9_.perUserAvId;
                  GuiManager.positionHudAvatar();
                  _loc3_ = avatars[activeAvatarIdx];
                  avatars.splice(activeAvatarIdx,1);
                  avatars.unshift(avatars[_switchIdx - 1]);
                  avatars.splice(_switchIdx,1);
                  if(_secondChosenAvtIdx != -1)
                  {
                     avatars.unshift(avatars[_secondChosenAvtIdx - 1]);
                     avatars.splice(_secondChosenAvtIdx,1);
                  }
                  avatars.unshift(_loc3_);
                  activeAvatarIdx = 0;
                  _switchIdx = 0;
                  _secondChosenAvtIdx = -1;
                  _loc12_ = int(_loc5_[_loc17_++]);
                  _loc10_ = PetManager.getMyPetByInvId(_loc12_);
                  if(AvatarManager.playerAvatarWorldView)
                  {
                     _loc2_ = AvatarManager.playerAvatarWorldView;
                     _loc2_.setActivePet(_loc10_ ? _loc10_.lBits : 0,_loc10_ ? _loc10_.uBits : 0,_loc10_ ? _loc10_.eBits : 0,_loc10_ ? _loc10_.name : "");
                     _loc2_.clearSpecialPattern();
                     _loc2_.setupParticles();
                  }
                  PetManager.myActivePetInvId = _loc12_;
                  _loc15_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc9_.userName,_loc9_.perUserAvId);
                  if(_loc15_)
                  {
                     _loc20_.questLevel = int(_loc5_[_loc17_++]);
                     _loc20_.questHealthPercentage = _loc15_.questHealthPercentage;
                     _loc20_.healthBase = _loc15_.healthBase;
                     _loc20_.attackBase = _loc15_.attackBase;
                     _loc20_.attackMax = _loc15_.attackMax;
                     _loc20_.defenseBase = _loc15_.defenseBase;
                     _loc20_.defenseMax = _loc15_.defenseMax;
                     gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc9_.perUserAvId,_loc20_,true);
                     _loc9_.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(_loc9_.userName).getPartialItemList(_loc9_.avTypeId,true));
                     _loc2_.updateNameBarLevelShape(_loc20_.questLevel);
                  }
                  updateAvatarSlotIds();
               }
               else
               {
                  ItemXtCommManager.requestItemListForAvatar(null,_loc9_,false,false);
                  if(AvatarManager.buddyCardAvatarView && _loc9_.userName.toLowerCase() == AvatarManager.buddyCardAvatarView.userName.toLowerCase())
                  {
                     BuddyManager.updateCurrBuddyCardAvatar(_loc9_);
                  }
                  _loc4_ = int(_loc5_[_loc17_++]);
                  _loc11_ = int(_loc5_[_loc17_++]);
                  _loc6_ = int(_loc5_[_loc17_++]);
                  _loc13_ = _loc5_[_loc17_++];
                  _loc8_ = int(_loc5_[_loc17_++]);
                  _loc2_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc16_);
                  if(_loc2_)
                  {
                     _loc2_.setActivePet(_loc4_,_loc11_,_loc6_,_loc13_);
                  }
                  _loc7_ = {
                     "name":_loc13_,
                     "lBits":_loc4_,
                     "uBits":_loc11_,
                     "eBits":_loc6_
                  };
                  _loc7_.defId = PetManager.getDefIdFromLBits(_loc7_.lBits);
                  _loc7_.type = PetManager.petTypeForDefId(_loc7_.defId);
                  _loc7_.isGround = PetManager.isGround(_loc7_.type);
                  _loc20_.currPet = _loc7_;
                  _loc20_.questLevel = _loc8_;
                  gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc9_.perUserAvId,_loc20_,true);
                  _loc2_.updateNameBarLevelShape(_loc20_.questLevel);
                  _loc2_.clearSpecialPattern();
                  _loc2_.setupParticles();
                  _loc21_ = new BuddyEvent("OnBuddyChanged");
                  _loc21_.userName = _loc20_.userName;
                  BuddyManager.eventDispatcher.dispatchEvent(_loc21_);
               }
               AvatarWorldView(_loc14_.parent).setPos(_loc14_.parent.x,_loc14_.parent.y,false);
               delete _loc14_.data;
               if(_switchCallback != null)
               {
                  _switchCallback(true);
                  _switchCallback = null;
               }
            }
         }
         else if(_loc14_.currentFrameLabel == "changeAvatar")
         {
            AvatarView(_loc14_.parent).showAvatar();
         }
         else if(_loc14_.currentFrameLabel == "tintOn")
         {
            _loc22_ = AvatarWorldView(_loc14_.parent);
            if(_loc22_.roomType == 0)
            {
               _loc22_.setBlendColor(4290903190,7534606);
            }
            else
            {
               _loc22_.setBlendColor(4294967295,16777107);
            }
         }
         else if(_loc14_.currentFrameLabel == "tintOff")
         {
            _loc18_ = AvatarWorldView(_loc14_.parent);
            _loc18_.setBlendColor(0);
            _loc18_.setAlphaLevel(100);
            if(_loc18_.userId == playerSfsUserId)
            {
               AvatarManager.clearPlayerSplashColor();
            }
         }
         else if(_loc14_.currentFrame == _loc14_.totalFrames)
         {
            endTransformAnim(_loc14_);
         }
      }
      
      private static function endTransformAnim(param1:MovieClip) : void
      {
         var _loc3_:AvatarView = AvatarView(param1.parent);
         if(param1.parent != null && _loc3_.avatarData != null)
         {
            DebugUtility.debugTrace("ending one of two transitions for sfsUserId:" + _loc3_.userId);
         }
         param1.removeEventListener("enterFrame",transformEnterFrameHandler);
         var _loc2_:SoundTransform = param1.soundTransform;
         _loc2_.volume = 0;
         param1.soundTransform = _loc2_;
         param1.gotoAndStop(1);
         RoomXtCommManager.isSwitching = false;
         if(_loc3_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && !QuestManager.isInPrivateAdventureState)
         {
            GuiManager.setSwapBtnGray(false);
         }
         if(param1.parent != null)
         {
            param1.parent.removeChild(param1);
         }
      }
      
      private static function updateAvatarSlotIds() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:Object = AvatarXtCommManager.avSlotInfo;
         _loc2_ = 0;
         while(_loc2_ < avatars.length)
         {
            if(avatars[_loc2_])
            {
               _loc1_ = _loc3_[avatars[_loc2_].perUserAvId];
               if(_loc1_)
               {
                  _loc1_.slotId = _loc2_;
               }
            }
            _loc2_++;
         }
      }
   }
}

