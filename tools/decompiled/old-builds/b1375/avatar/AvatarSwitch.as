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
         var _loc5_:int = 0;
         var _loc1_:Array = avatars.slice();
         var _loc3_:int = int(avatars[_switchIdx].perUserAvId);
         var _loc2_:int = int(avatars[activeAvatarIdx].perUserAvId);
         var _loc4_:int = 0;
         avatars = [];
         _loc5_ = 0;
         while(_loc5_ < _loc1_.length)
         {
            if(_loc1_[_loc5_] != null)
            {
               avatars.push(_loc1_[_loc5_]);
               if(_loc3_ == _loc1_[_loc5_].perUserAvId)
               {
                  _switchIdx = _loc5_ - _loc4_;
                  AvatarXtCommManager.avSlotInfo[_loc3_].slotId = _switchIdx;
               }
               if(_loc2_ == _loc1_[_loc5_].perUserAvId)
               {
                  activeAvatarIdx = _loc5_ - _loc4_;
                  AvatarXtCommManager.avSlotInfo[_loc2_].slotId = activeAvatarIdx;
               }
            }
            else
            {
               _loc4_++;
            }
            _loc5_++;
         }
      }
      
      private static function updateAvatars() : void
      {
         var _loc4_:Avatar = null;
         var _loc5_:int = 0;
         var _loc2_:Avatar = null;
         for each(var _loc1_:AvatarInfo in playerUserInfo.avList)
         {
            if(_loc1_.perUserAvId == playerUserInfo.currPerUserAvId)
            {
               _loc4_ = AvatarManager.playerAvatar;
            }
            else
            {
               _loc4_ = avatars[AvatarXtCommManager.avSlotInfo[_loc1_.perUserAvId].slotId];
               if(!_loc4_)
               {
                  _loc4_ = new Avatar();
                  _loc4_ = AvatarUtility.generateNew(_loc1_.perUserAvId,_loc4_,_loc1_.userName,playerSfsUserId,AvatarManager.roomEnviroType);
               }
            }
            avatars[AvatarXtCommManager.avSlotInfo[_loc1_.perUserAvId].slotId] = _loc4_;
            _loc4_ = null;
         }
         var _loc3_:int = int(avatars.length);
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            if(avatars[_loc5_] != null)
            {
               _loc2_ = avatars[_loc5_];
               if(playerUserInfo.currPerUserAvId == _loc2_.perUserAvId)
               {
                  activeAvatarIdx = _switchIdx = _loc5_;
                  break;
               }
            }
            _loc5_++;
         }
      }
      
      public static function shouldChoose() : Boolean
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < avatars.length)
         {
            if(avatars[_loc3_])
            {
               if(isMemberOnlyAvatar(_loc3_))
               {
                  _loc1_++;
               }
               else
               {
                  if(avatars[_loc3_].enviroTypeFlag == 2)
                  {
                     _loc2_++;
                  }
                  _loc4_++;
               }
            }
            _loc3_++;
         }
         if(_loc4_ < 3 && _loc4_ > 0 && _loc2_ < 2 && _loc4_ != _loc2_)
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
         if(gMainFrame.userInfo.isMember && param1 < 48)
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
         var _loc8_:int = 0;
         var _loc6_:AvatarWorldView = null;
         var _loc2_:int = 0;
         var _loc4_:DisplayObject = null;
         var _loc5_:MediaHelper = null;
         var _loc7_:MediaHelper = null;
         DarkenManager.showLoadingSpiral(false);
         if(!_isChoosing)
         {
            if(_addAvatarCallback != null)
            {
               _addAvatarCallback(true);
               _addAvatarCallback = null;
            }
         }
         var _loc3_:int = 2;
         var _loc9_:Boolean = Boolean(int(param1[_loc3_++]));
         if(_loc9_)
         {
            _loc8_ = int(param1[_loc3_++]);
            _loc6_ = AvatarManager.avatarViewList[_loc8_];
            if(_loc6_ == null)
            {
               DebugUtility.debugTrace("ERROR: invalid avatar worldview savw:" + _loc6_ + " sfsUserId:" + _loc8_ + " data:" + param1);
               return;
            }
            _loc6_.setActivePet(0,0,0,0,"",0,0,0);
            if(_loc6_.getChildAt(0).hasOwnProperty("onbottom1"))
            {
               _loc2_ = _loc6_.numChildren - 1;
               while(_loc2_ > 0)
               {
                  _loc4_ = _loc6_.getChildAt(_loc2_);
                  if(_loc4_ is MovieClip && Boolean(MovieClip(_loc4_).hasOwnProperty("isTransformTop")))
                  {
                     endTransformAnim(MovieClip(_loc4_));
                     break;
                  }
                  _loc2_--;
               }
               endTransformAnim(_loc6_.getChildAt(0) as MovieClip);
            }
            if(_asTransformVec == null)
            {
               DebugUtility.debugTrace("ERROR: invalid AvatarSwitch state _asTransformTopMHVec: data:" + param1);
               return;
            }
            _loc5_ = new MediaHelper();
            _loc5_.init(_loc6_.roomType == 0 ? 33 : 1171,asTransformMediaHelper,[_loc6_,param1]);
            _asTransformVec.push(_loc5_);
            _loc7_ = new MediaHelper();
            _loc7_.init(_loc6_.roomType == 0 ? 34 : 1172,asTransformMediaHelper,[_loc6_]);
            _asTransformVec.push(_loc7_);
            if(_loc8_ == playerSfsUserId)
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
            _switchCallback(_loc9_,true);
            if(!_loc9_)
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
         var _loc23_:int = 0;
         var _loc15_:int = 0;
         var _loc9_:Boolean = false;
         var _loc27_:Avatar = null;
         var _loc22_:Avatar = null;
         var _loc7_:AvatarInfo = null;
         var _loc13_:AvatarWorldView = null;
         var _loc26_:Avatar = null;
         var _loc12_:int = 0;
         var _loc2_:Object = null;
         var _loc11_:AvatarInfo = null;
         var _loc3_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc8_:String = null;
         var _loc4_:Number = NaN;
         var _loc24_:int = 0;
         var _loc14_:int = 0;
         var _loc18_:int = 0;
         var _loc16_:int = 0;
         var _loc10_:Object = null;
         var _loc17_:BuddyEvent = null;
         var _loc25_:AvatarWorldView = null;
         var _loc19_:AvatarWorldView = null;
         var _loc6_:MovieClip = MovieClip(param1.target);
         if(_loc6_.parent == null || AvatarView(_loc6_.parent).avatarData == null)
         {
            endTransformAnim(_loc6_);
            return;
         }
         if(_loc6_.currentFrameLabel != null)
         {
            DebugUtility.debugTrace("entered frame:" + _loc6_.currentFrameLabel + " on transform effect for sfsUserId:" + AvatarView(_loc6_.parent).userId);
         }
         if(_loc6_.currentFrameLabel == "hideAvatar")
         {
            AvatarView(_loc6_.parent).hideAvatar();
            if(_loc6_.hasOwnProperty("data"))
            {
               _loc5_ = _loc6_.data;
               _loc23_ = 3;
               _loc15_ = int(_loc5_[_loc23_++]);
               _loc9_ = _loc15_ == playerSfsUserId;
               _loc27_ = AvatarManager.getAvatarBySfsUserId(_loc15_);
               if(_loc9_)
               {
                  _loc22_ = avatars[_switchIdx];
                  _loc22_.perUserAvId = _loc27_.perUserAvId;
                  _loc22_.avTypeId = _loc27_.avTypeId;
                  _loc22_.copyColors(_loc27_.colors);
                  _loc22_.avName = _loc27_.avName;
                  _loc22_.cloneShownAccFromAvatar(_loc27_);
                  _loc22_.customAvId = _loc27_.customAvId;
                  AvatarManager.clearPlayerSplashColor();
               }
               _loc27_.removeAllItems();
               _loc27_.perUserAvId = int(_loc5_[_loc23_++]);
               _loc27_.customAvId = int(_loc5_[_loc23_++]);
               _loc27_.avTypeId = int(_loc5_[_loc23_++]);
               _loc27_.setColors(uint(_loc5_[_loc23_++]),uint(_loc5_[_loc23_++]),uint(_loc5_[_loc23_++]));
               _loc27_.avName = _loc5_[_loc23_++];
               if(_loc27_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc27_.userName,_loc27_.perUserAvId) == null)
               {
                  AvatarXtCommManager.requestADForAvatar(_loc27_.perUserAvId,true,null,_loc27_);
               }
               else
               {
                  _loc7_ = new AvatarInfo();
                  _loc7_.perUserAvId = _loc27_.perUserAvId;
                  _loc7_.avName = _loc27_.avName;
                  _loc7_.userName = _loc27_.userName;
                  _loc7_.colors = _loc27_.colors.concat();
                  _loc7_.type = _loc27_.avTypeId;
                  _loc7_.customAvId = _loc27_.customAvId;
               }
               _loc13_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc15_);
               if(_loc13_)
               {
                  if(_loc13_.parent != null)
                  {
                     _loc13_.parent.removeChild(_loc13_);
                  }
                  if(_loc27_.enviroTypeFlag & 1 << 2)
                  {
                     _loc13_.x += AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                     _loc13_.y += AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                     AvatarManager.getFlyingLayer.addChild(_loc13_);
                  }
                  else
                  {
                     _loc13_.x -= AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                     _loc13_.y -= AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                     AvatarManager.getAvatarLayer.addChild(_loc13_);
                  }
               }
               if(_loc9_)
               {
                  if((_loc22_.enviroTypeFlag & 1 << 2) != (_loc27_.enviroTypeFlag & 1 << 2))
                  {
                     RoomManagerWorld.instance.rebuildGrid();
                     if(_loc13_ == null && !(_loc27_.enviroTypeFlag & 1 << 2) || RoomManagerWorld.instance.collisionTestGrid(_loc13_.x,_loc13_.y))
                     {
                        RoomManagerWorld.instance.teleportPlayerToDefault();
                     }
                  }
                  gMainFrame.userInfo.myPerUserAvId = _loc27_.perUserAvId;
                  GuiManager.positionHudAvatar();
                  _loc26_ = avatars[activeAvatarIdx];
                  avatars.splice(activeAvatarIdx,1);
                  avatars.unshift(avatars[_switchIdx - 1]);
                  avatars.splice(_switchIdx,1);
                  if(_secondChosenAvtIdx != -1)
                  {
                     avatars.unshift(avatars[_secondChosenAvtIdx - 1]);
                     avatars.splice(_secondChosenAvtIdx,1);
                  }
                  avatars.unshift(_loc26_);
                  activeAvatarIdx = 0;
                  _switchIdx = 0;
                  _secondChosenAvtIdx = -1;
                  _loc12_ = int(_loc5_[_loc23_++]);
                  _loc2_ = PetManager.getMyPetByInvId(_loc12_);
                  if(AvatarManager.playerAvatarWorldView)
                  {
                     _loc13_ = AvatarManager.playerAvatarWorldView;
                     if(_loc2_)
                     {
                        _loc13_.setActivePet(_loc2_.createdTs,_loc2_.lBits,_loc2_.uBits,_loc2_.eBits,_loc2_.name,_loc2_.personalityDefId,_loc2_.favoriteFoodDefId,_loc2_.favoriteToyDefId);
                     }
                     else
                     {
                        _loc13_.setActivePet(0,0,0,0,"",0,0,0);
                     }
                     _loc13_.clearSpecialPattern();
                     _loc13_.setupParticles();
                  }
                  PetManager.myActivePetInvId = _loc12_;
                  _loc11_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc27_.userName,_loc27_.perUserAvId);
                  if(_loc11_)
                  {
                     _loc7_.questLevel = int(_loc5_[_loc23_++]);
                     _loc7_.questHealthPercentage = _loc11_.questHealthPercentage;
                     _loc7_.healthBase = _loc11_.healthBase;
                     _loc7_.attackBase = _loc11_.attackBase;
                     _loc7_.attackMax = _loc11_.attackMax;
                     _loc7_.defenseBase = _loc11_.defenseBase;
                     _loc7_.defenseMax = _loc11_.defenseMax;
                     gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc27_.perUserAvId,_loc7_,true);
                     _loc27_.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(_loc27_.userName).getPartialItemList(_loc27_.avTypeId,true));
                     _loc13_.updateNameBarLevelShape(_loc7_.questLevel);
                  }
                  updateAvatarSlotIds();
               }
               else
               {
                  ItemXtCommManager.requestItemListForAvatar(null,_loc27_,false,false);
                  if(AvatarManager.buddyCardAvatarView && _loc27_.userName.toLowerCase() == AvatarManager.buddyCardAvatarView.userName.toLowerCase())
                  {
                     BuddyManager.updateCurrBuddyCardAvatar(_loc27_);
                  }
                  _loc3_ = int(_loc5_[_loc23_++]);
                  _loc20_ = int(_loc5_[_loc23_++]);
                  _loc21_ = int(_loc5_[_loc23_++]);
                  _loc8_ = _loc5_[_loc23_++];
                  _loc4_ = Number(_loc5_[_loc23_++]);
                  _loc24_ = int(_loc5_[_loc23_++]);
                  _loc14_ = int(_loc5_[_loc23_++]);
                  _loc18_ = int(_loc5_[_loc23_++]);
                  _loc16_ = int(_loc5_[_loc23_++]);
                  _loc13_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc15_);
                  if(_loc13_)
                  {
                     _loc13_.setActivePet(_loc4_,_loc3_,_loc20_,_loc21_,_loc8_,_loc24_,_loc14_,_loc18_);
                  }
                  _loc10_ = {
                     "name":_loc8_,
                     "lBits":_loc3_,
                     "uBits":_loc20_,
                     "eBits":_loc21_,
                     "createdTs":_loc4_,
                     "personalityDefId":_loc24_,
                     "favoriteFoodDefId":_loc14_,
                     "favoriteToyDefId":_loc18_
                  };
                  _loc10_.defId = PetManager.getDefIdFromLBits(_loc10_.lBits);
                  _loc10_.type = PetManager.petTypeForDefId(_loc10_.defId);
                  _loc10_.isGround = PetManager.isGround(_loc10_.type);
                  _loc7_.currPet = _loc10_;
                  _loc7_.questLevel = _loc16_;
                  gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc27_.perUserAvId,_loc7_,true);
                  _loc13_.updateNameBarLevelShape(_loc7_.questLevel);
                  _loc13_.clearSpecialPattern();
                  _loc13_.setupParticles();
                  _loc17_ = new BuddyEvent("OnBuddyChanged");
                  _loc17_.userName = _loc7_.userName;
                  BuddyManager.eventDispatcher.dispatchEvent(_loc17_);
               }
               AvatarWorldView(_loc6_.parent).setPos(_loc6_.parent.x,_loc6_.parent.y,false);
               delete _loc6_.data;
               if(_switchCallback != null)
               {
                  _switchCallback(true);
                  _switchCallback = null;
               }
            }
         }
         else if(_loc6_.currentFrameLabel == "changeAvatar")
         {
            AvatarView(_loc6_.parent).showAvatar();
         }
         else if(_loc6_.currentFrameLabel == "tintOn")
         {
            _loc25_ = AvatarWorldView(_loc6_.parent);
            if(_loc25_.roomType == 0)
            {
               _loc25_.setBlendColor(4290903190,7534606);
            }
            else
            {
               _loc25_.setBlendColor(4294967295,16777107);
            }
         }
         else if(_loc6_.currentFrameLabel == "tintOff")
         {
            _loc19_ = AvatarWorldView(_loc6_.parent);
            _loc19_.setBlendColor(0);
            _loc19_.setAlphaLevel(100);
            if(_loc19_.userId == playerSfsUserId)
            {
               AvatarManager.clearPlayerSplashColor();
            }
         }
         else if(_loc6_.currentFrame == _loc6_.totalFrames)
         {
            endTransformAnim(_loc6_);
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
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc1_:Object = AvatarXtCommManager.avSlotInfo;
         _loc3_ = 0;
         while(_loc3_ < avatars.length)
         {
            if(avatars[_loc3_])
            {
               _loc2_ = _loc1_[avatars[_loc3_].perUserAvId];
               if(_loc2_)
               {
                  _loc2_.slotId = _loc3_;
               }
            }
            _loc3_++;
         }
      }
   }
}

