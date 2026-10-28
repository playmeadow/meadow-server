package avatar
{
   import buddy.BuddyEvent;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.media.SoundTransform;
   import gui.BuddyCard;
   import gui.BuddyManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.GuiNameTypeScreen;
   import gui.SwitchManager;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class AvatarSwitch
   {
      
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
      
      public static const ASTRANSFORM_MEDIA_ID_TOP:int = 33;
      
      public static const ASTRANSFORM_MEDIA_ID_BOTTOM:int = 34;
      
      public static const ASTRANSFORM_OCEAN_MEDIA_ID_TOP:int = 1171;
      
      public static const ASTRANSFORM_OCEAN_MEDIA_ID_BOTTOM:int = 1172;
      
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
         var _loc1_:int = 0;
         if(playerUserInfo == null)
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
         else
         {
            _loc1_ = 0;
            while(_loc1_ < avatars.length)
            {
               if(avatars[_loc1_])
               {
                  if(avatars[_loc1_].perUserAvId == gMainFrame.userInfo.myPerUserAvId)
                  {
                     if(_loc1_ != 0)
                     {
                        avatars.unshift(avatars[_loc1_]);
                        avatars.splice(_loc1_ + 1,1);
                        activeAvatarIdx = _switchIdx = 0;
                     }
                  }
                  avatars[_loc1_].roomType = AvatarManager.roomEnviroType;
               }
               _loc1_++;
            }
            avatars[activeAvatarIdx] = AvatarManager.playerAvatar;
         }
      }
      
      public static function updateSlotPositions() : void
      {
         var _loc1_:Array = avatars.slice();
         var _loc2_:int = int(avatars[_switchIdx].perUserAvId);
         var _loc3_:int = int(avatars[activeAvatarIdx].perUserAvId);
         var _loc4_:int = 0;
         avatars = [];
         var _loc5_:int = 0;
         while(_loc5_ < _loc1_.length)
         {
            if(_loc1_[_loc5_] != null)
            {
               avatars.push(_loc1_[_loc5_]);
               if(_loc2_ == _loc1_[_loc5_].perUserAvId)
               {
                  _switchIdx = _loc5_ - _loc4_;
                  AvatarXtCommManager.avSlotInfo[_loc2_].slotId = _switchIdx;
               }
               if(_loc3_ == _loc1_[_loc5_].perUserAvId)
               {
                  activeAvatarIdx = _loc5_ - _loc4_;
                  AvatarXtCommManager.avSlotInfo[_loc3_].slotId = activeAvatarIdx;
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
         var _loc1_:AvatarInfo = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Avatar = null;
         var _loc5_:Avatar = null;
         for each(_loc1_ in playerUserInfo.avList)
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
         _loc2_ = int(avatars.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(avatars[_loc3_] != null)
            {
               _loc5_ = avatars[_loc3_];
               if(playerUserInfo.currPerUserAvId == _loc5_.perUserAvId)
               {
                  activeAvatarIdx = _switchIdx = _loc3_;
                  break;
               }
            }
            _loc3_++;
         }
      }
      
      public static function shouldChoose() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < avatars.length)
         {
            if(avatars[_loc4_])
            {
               if(isMemberOnlyAvatar(_loc4_))
               {
                  _loc3_++;
               }
               else
               {
                  if(avatars[_loc4_].enviroTypeFlag == 2)
                  {
                     _loc2_++;
                  }
                  _loc1_++;
               }
            }
            _loc4_++;
         }
         if(_loc1_ < 3 && _loc1_ > 0 && _loc2_ < 2 && _loc1_ != _loc2_)
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
         if(Boolean(gMainFrame.userInfo.isMember) && param1 < SwitchManager.NUM_AVATAR_SLOTS)
         {
            return true;
         }
         param1 += 1;
         if(availSlotFlags == uint.MAX_VALUE || (availSlotFlags & 0xFFFF) == param1 || (availSlotFlags & 0xFFFF0000) >> 16 == param1)
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
         while(_loc4_ < avatars.length)
         {
            if(Boolean(avatars[_loc4_]) && Utility.isLand(avatars[_loc4_].enviroTypeFlag))
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
         while(_loc2_ < avatars.length)
         {
            if(Boolean(avatars[_loc2_]) && Boolean(gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId)))
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
         while(_loc2_ < avatars.length)
         {
            if(Boolean(avatars[_loc2_]) && !gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId))
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
         while(_loc2_ < avatars.length)
         {
            if(Boolean(avatars[_loc2_]) && Boolean(!gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId)) && avatars[_loc2_].enviroTypeFlag == 2)
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
         while(_loc2_ < avatars.length)
         {
            if(Boolean(avatars[_loc2_]) && Boolean(!gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId)) && isAvInvIdUsable(AvatarXtCommManager.avSlotInfo[avatars[_loc2_].perUserAvId].avInvId))
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
         while(_loc2_ < avatars.length)
         {
            if(Boolean(avatars[_loc2_]) && isAvInvIdUsable(AvatarXtCommManager.avSlotInfo[avatars[_loc2_].perUserAvId].avInvId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function isSwitching() : Boolean
      {
         return Boolean(activeAvatarIdx != _switchIdx);
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
      
      public static function addAvatar(param1:int, param2:Boolean = false, param3:Function = null, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false, param7:int = -1, param8:Boolean = false, param9:int = -1, param10:int = -1) : void
      {
         _addIdx = param1;
         _addAvatarCallback = param3;
         _isChoosing = param4;
         _shopId = param9;
         _itemInShopDefId = param10;
         _isSwitchingDen = param6;
         isAddingSlot = param2;
         var _loc11_:int = AvatarUtility.numNonMemberAvatars();
         GuiManager.openAvatarCreator(param5,_loc11_ >= 1 && _loc11_ - numNonMemberOceanAvatars > 0 ? false : param4,param7,param8);
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
         var _loc7_:int = 0;
         var _loc8_:int = 0;
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
               _loc7_ = LocalizationManager.isCurrLanguageReversed() ? int(param3[2]) : int(param3[1]);
               _loc8_ = LocalizationManager.isCurrLanguageReversed() ? int(param3[1]) : int(param3[2]);
               SBTracker.pop();
               if(QuestManager.isInPrivateAdventureState)
               {
                  QuestManager.privateAdventureJoinClose(true);
               }
               if(param6)
               {
                  AvatarXtCommManager.requestAvatarFastPassAdd([_addAvatar.avTypeId,param3[0],_loc7_,_loc8_],addFastPassAvatarResponse);
               }
               else
               {
                  AvatarXtCommManager.requestAvatarAdd([param3[0],_loc7_,_loc8_,_addAvatar.avTypeId,_addAvatar.customAvId,param4,GenericListXtCommManager.getAvailListUniqueId(),_shopId],addAvatarResponse);
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
         var _loc5_:AvatarWorldView = null;
         var _loc6_:MediaHelper = null;
         var _loc7_:MediaHelper = null;
         var _loc8_:* = 0;
         var _loc9_:DisplayObject = null;
         DarkenManager.showLoadingSpiral(false);
         if(!_isChoosing)
         {
            if(_addAvatarCallback != null)
            {
               _addAvatarCallback(true);
               _addAvatarCallback = null;
            }
         }
         var _loc2_:* = 2;
         var _loc3_:Boolean = Boolean(int(param1[int(_loc2_++)]));
         if(_loc3_)
         {
            _loc4_ = int(param1[int(_loc2_++)]);
            _loc5_ = AvatarManager.avatarViewList[_loc4_];
            if(_loc5_ == null)
            {
               DebugUtility.debugTrace("ERROR: invalid avatar worldview savw:" + _loc5_ + " sfsUserId:" + _loc4_ + " data:" + param1);
               return;
            }
            _loc5_.setActivePet(0,0,0,"");
            if(_loc5_.getChildAt(0).hasOwnProperty("onbottom1"))
            {
               _loc8_ = int(_loc5_.numChildren - 1);
               while(_loc8_ > 0)
               {
                  _loc9_ = _loc5_.getChildAt(_loc8_);
                  if(_loc9_ is MovieClip && MovieClip(_loc9_).hasOwnProperty("isTransformTop"))
                  {
                     endTransformAnim(MovieClip(_loc9_));
                     break;
                  }
                  _loc8_--;
               }
               endTransformAnim(_loc5_.getChildAt(0) as MovieClip);
            }
            if(_asTransformVec == null)
            {
               DebugUtility.debugTrace("ERROR: invalid AvatarSwitch state _asTransformTopMHVec:" + " data:" + param1);
               return;
            }
            _loc6_ = new MediaHelper();
            _loc6_.init(_loc5_.roomType == SbiConstants.ENVIRO_LAND ? uint(ASTRANSFORM_MEDIA_ID_TOP) : uint(ASTRANSFORM_OCEAN_MEDIA_ID_TOP),asTransformMediaHelper,[_loc5_,param1]);
            _asTransformVec.push(_loc6_);
            _loc7_ = new MediaHelper();
            _loc7_.init(_loc5_.roomType == SbiConstants.ENVIRO_LAND ? uint(ASTRANSFORM_MEDIA_ID_BOTTOM) : uint(ASTRANSFORM_OCEAN_MEDIA_ID_BOTTOM),asTransformMediaHelper,[_loc5_]);
            _asTransformVec.push(_loc7_);
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
            _switchCallback(_loc3_,true);
            if(!_loc3_)
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
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:UserInfo = null;
         if(param1)
         {
            _loc4_ = isSlotAvailable(_removeIdx);
            _loc3_ = int(AvatarXtCommManager.avSlotInfo[avatars[_removeIdx].perUserAvId].avInvId);
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(avatars[_removeIdx].userName);
            _loc5_.allItemsInUseOff(avatars[_removeIdx].perUserAvId);
            AvatarXtCommManager.avSlotInfo[avatars[_removeIdx].perUserAvId].avInvId = null;
            avatars[_removeIdx] = null;
         }
         if(_removeCallback != null)
         {
            _removeCallback(param1,_removeIdx,_loc3_,param2,_loc4_);
         }
         _removeIdx = -1;
      }
      
      public static function chooseTwo(param1:Array, param2:Function) : void
      {
         _switchIdx = avatars[param1[0]].enviroTypeFlag == 2 ? int(param1[1]) : int(param1[0]);
         _secondChosenAvtIdx = -1;
         var _loc3_:Array = [];
         _loc3_[0] = AvatarXtCommManager.avSlotInfo[avatars[param1[0]].perUserAvId].avInvId;
         if(param1[1] != null && Boolean(AvatarSwitch.avatars[param1[1]]))
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
         var _loc2_:MediaHelper = MediaHelper(param1.mediaHelper);
         var _loc3_:int = _loc2_.id;
         if(_loc3_ != ASTRANSFORM_MEDIA_ID_TOP && _loc3_ != ASTRANSFORM_MEDIA_ID_BOTTOM && _loc3_ != ASTRANSFORM_OCEAN_MEDIA_ID_TOP && _loc3_ != ASTRANSFORM_OCEAN_MEDIA_ID_BOTTOM)
         {
            return;
         }
         param1.addEventListener(Event.ENTER_FRAME,transformEnterFrameHandler);
         var _loc4_:AvatarView = AvatarView((param1.passback as Array)[0]);
         if(_loc3_ == ASTRANSFORM_MEDIA_ID_TOP || _loc3_ == ASTRANSFORM_OCEAN_MEDIA_ID_TOP)
         {
            param1.data = (param1.passback as Array)[1] as Array;
            DebugUtility.debugTrace("got top media for sfsUserId:" + int(param1.data[3]));
            param1.isTransformTop = true;
            _loc4_.addChild(param1);
            _asTransformVec.splice(_asTransformVec.indexOf(_loc2_),1);
         }
         else
         {
            param1.isTransformBottom = true;
            _loc4_.addChildAt(param1,0);
            _asTransformVec.splice(_asTransformVec.indexOf(_loc2_),1);
         }
         param1.gotoAndPlay(1);
         param1.mediaHelper.destroy();
         delete param1.mediaHelper;
         delete param1.passback;
      }
      
      private static function transformEnterFrameHandler(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc4_:* = 0;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:Avatar = null;
         var _loc8_:Avatar = null;
         var _loc9_:AvatarWorldView = null;
         var _loc10_:AvatarInfo = null;
         var _loc11_:Avatar = null;
         var _loc12_:int = 0;
         var _loc13_:Object = null;
         var _loc14_:AvatarInfo = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:String = null;
         var _loc19_:int = 0;
         var _loc20_:Object = null;
         var _loc21_:BuddyEvent = null;
         var _loc22_:AvatarWorldView = null;
         var _loc23_:AvatarWorldView = null;
         var _loc2_:MovieClip = MovieClip(param1.target);
         if(_loc2_.parent == null || AvatarView(_loc2_.parent).avatarData == null)
         {
            endTransformAnim(_loc2_);
            return;
         }
         if(_loc2_.currentFrameLabel != null)
         {
            DebugUtility.debugTrace("entered frame:" + _loc2_.currentFrameLabel + " on transform effect for sfsUserId:" + AvatarView(_loc2_.parent).userId);
         }
         if(_loc2_.currentFrameLabel == "hideAvatar")
         {
            AvatarView(_loc2_.parent).hideAvatar();
            if(_loc2_.hasOwnProperty("data"))
            {
               _loc3_ = _loc2_.data;
               _loc4_ = 3;
               _loc5_ = int(_loc3_[int(_loc4_++)]);
               _loc6_ = Boolean(_loc5_ == playerSfsUserId);
               _loc7_ = AvatarManager.getAvatarBySfsUserId(_loc5_);
               if(_loc6_)
               {
                  _loc8_ = avatars[_switchIdx];
                  _loc8_.perUserAvId = _loc7_.perUserAvId;
                  _loc8_.avTypeId = _loc7_.avTypeId;
                  _loc8_.copyColors(_loc7_.colors);
                  _loc8_.avName = _loc7_.avName;
                  _loc8_.cloneShownAccFromAvatar(_loc7_);
                  _loc8_.customAvId = _loc7_.customAvId;
                  AvatarManager.clearPlayerSplashColor();
               }
               _loc7_.removeAllItems();
               _loc7_.perUserAvId = int(_loc3_[int(_loc4_++)]);
               _loc7_.customAvId = int(_loc3_[int(_loc4_++)]);
               _loc7_.avTypeId = int(_loc3_[int(_loc4_++)]);
               _loc7_.setColors(uint(_loc3_[int(_loc4_++)]),uint(_loc3_[int(_loc4_++)]),uint(_loc3_[int(_loc4_++)]));
               _loc7_.avName = _loc3_[int(_loc4_++)];
               if(_loc7_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc7_.userName,_loc7_.perUserAvId) == null)
               {
                  AvatarXtCommManager.requestADForAvatar(_loc7_.perUserAvId,true,null,_loc7_);
               }
               else
               {
                  _loc10_ = new AvatarInfo();
                  _loc10_.perUserAvId = _loc7_.perUserAvId;
                  _loc10_.avName = _loc7_.avName;
                  _loc10_.userName = _loc7_.userName;
                  _loc10_.colors = _loc7_.colors.concat();
                  _loc10_.type = _loc7_.avTypeId;
                  _loc10_.customAvId = _loc7_.customAvId;
               }
               _loc9_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc5_);
               if(_loc9_)
               {
                  if(_loc9_.parent != null)
                  {
                     _loc9_.parent.removeChild(_loc9_);
                  }
                  if(_loc7_.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR)
                  {
                     _loc9_.x += AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                     _loc9_.y += AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                     AvatarManager.getFlyingLayer.addChild(_loc9_);
                  }
                  else
                  {
                     _loc9_.x -= AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                     _loc9_.y -= AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                     AvatarManager.getAvatarLayer.addChild(_loc9_);
                  }
               }
               if(_loc6_)
               {
                  if((_loc8_.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR) != (_loc7_.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR))
                  {
                     RoomManagerWorld.instance.rebuildGrid();
                     if(_loc9_ == null && !(_loc7_.enviroTypeFlag & 1 << SbiConstants.ENVIRO_AIR) || Boolean(RoomManagerWorld.instance.collisionTestGrid(_loc9_.x,_loc9_.y)))
                     {
                        RoomManagerWorld.instance.teleportPlayerToDefault();
                     }
                  }
                  gMainFrame.userInfo.myPerUserAvId = _loc7_.perUserAvId;
                  GuiManager.positionHudAvatar();
                  _loc11_ = avatars[activeAvatarIdx];
                  avatars.splice(activeAvatarIdx,1);
                  avatars.unshift(avatars[_switchIdx - 1]);
                  avatars.splice(_switchIdx,1);
                  if(_secondChosenAvtIdx != -1)
                  {
                     avatars.unshift(avatars[_secondChosenAvtIdx - 1]);
                     avatars.splice(_secondChosenAvtIdx,1);
                  }
                  avatars.unshift(_loc11_);
                  activeAvatarIdx = 0;
                  _switchIdx = 0;
                  _secondChosenAvtIdx = -1;
                  _loc12_ = int(_loc3_[_loc4_++]);
                  _loc13_ = PetManager.getMyPetByInvId(_loc12_);
                  if(AvatarManager.playerAvatarWorldView)
                  {
                     _loc9_ = AvatarManager.playerAvatarWorldView;
                     _loc9_.setActivePet(_loc13_ ? uint(_loc13_.lBits) : 0,_loc13_ ? uint(_loc13_.uBits) : 0,_loc13_ ? uint(_loc13_.eBits) : 0,_loc13_ ? _loc13_.name : "");
                     _loc9_.clearSpecialPattern();
                     _loc9_.setupParticles();
                  }
                  PetManager.myActivePetInvId = _loc12_;
                  _loc14_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc7_.userName,_loc7_.perUserAvId);
                  if(_loc14_)
                  {
                     _loc10_.questLevel = int(_loc3_[_loc4_++]);
                     _loc10_.questHealthPercentage = _loc14_.questHealthPercentage;
                     _loc10_.healthBase = _loc14_.healthBase;
                     _loc10_.attackBase = _loc14_.attackBase;
                     _loc10_.attackMax = _loc14_.attackMax;
                     _loc10_.defenseBase = _loc14_.defenseBase;
                     _loc10_.defenseMax = _loc14_.defenseMax;
                     gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc7_.perUserAvId,_loc10_,true);
                     _loc7_.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(_loc7_.userName).getPartialItemList(_loc7_.avTypeId,true));
                     _loc9_.updateNameBarLevelShape(_loc10_.questLevel);
                  }
                  updateAvatarSlotIds();
               }
               else
               {
                  ItemXtCommManager.requestItemListForAvatar(null,_loc7_,false,false);
                  if(Boolean(AvatarManager.buddyCardAvatarView) && _loc7_.userName.toLowerCase() == AvatarManager.buddyCardAvatarView.userName.toLowerCase())
                  {
                     BuddyCard.updateCurrBuddyCardAvatar(_loc7_);
                  }
                  _loc15_ = int(_loc3_[int(_loc4_++)]);
                  _loc16_ = int(_loc3_[int(_loc4_++)]);
                  _loc17_ = int(_loc3_[int(_loc4_++)]);
                  _loc18_ = _loc3_[int(_loc4_++)];
                  _loc19_ = int(_loc3_[_loc4_++]);
                  _loc9_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc5_);
                  if(_loc9_)
                  {
                     _loc9_.setActivePet(_loc15_,_loc16_,_loc17_,_loc18_);
                  }
                  _loc20_ = {
                     "name":_loc18_,
                     "lBits":_loc15_,
                     "uBits":_loc16_,
                     "eBits":_loc17_
                  };
                  _loc20_.defId = PetManager.getDefIdFromLBits(_loc20_.lBits);
                  _loc20_.type = PetManager.petTypeForDefId(_loc20_.defId);
                  _loc20_.isGround = PetManager.isGround(_loc20_.type);
                  _loc10_.currPet = _loc20_;
                  _loc10_.questLevel = _loc19_;
                  gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc7_.perUserAvId,_loc10_,true);
                  _loc9_.updateNameBarLevelShape(_loc10_.questLevel);
                  _loc9_.clearSpecialPattern();
                  _loc9_.setupParticles();
                  _loc21_ = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
                  _loc21_.userName = _loc10_.userName;
                  BuddyManager.eventDispatcher.dispatchEvent(_loc21_);
               }
               AvatarWorldView(_loc2_.parent).setPos(_loc2_.parent.x,_loc2_.parent.y,false);
               delete _loc2_.data;
               if(_switchCallback != null)
               {
                  _switchCallback(true);
                  _switchCallback = null;
               }
            }
         }
         else if(_loc2_.currentFrameLabel == "changeAvatar")
         {
            AvatarView(_loc2_.parent).showAvatar();
         }
         else if(_loc2_.currentFrameLabel == "tintOn")
         {
            _loc22_ = AvatarWorldView(_loc2_.parent);
            if(_loc22_.roomType == SbiConstants.ENVIRO_LAND)
            {
               _loc22_.setBlendColor(4290903190,7534606);
            }
            else
            {
               _loc22_.setBlendColor(4294967295,16777107);
            }
         }
         else if(_loc2_.currentFrameLabel == "tintOff")
         {
            _loc23_ = AvatarWorldView(_loc2_.parent);
            _loc23_.setBlendColor(0);
            _loc23_.setAlphaLevel(100);
            if(_loc23_.userId == playerSfsUserId)
            {
               AvatarManager.clearPlayerSplashColor();
            }
         }
         else if(_loc2_.currentFrame == _loc2_.totalFrames)
         {
            endTransformAnim(_loc2_);
         }
      }
      
      private static function endTransformAnim(param1:MovieClip) : void
      {
         var _loc2_:AvatarView = AvatarView(param1.parent);
         if(param1.parent != null && _loc2_.avatarData != null)
         {
            DebugUtility.debugTrace("ending one of two transitions for sfsUserId:" + _loc2_.userId);
         }
         param1.removeEventListener(Event.ENTER_FRAME,transformEnterFrameHandler);
         var _loc3_:SoundTransform = param1.soundTransform;
         _loc3_.volume = 0;
         param1.soundTransform = _loc3_;
         param1.gotoAndStop(1);
         RoomXtCommManager.isSwitching = false;
         if(_loc2_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && !QuestManager.isInPrivateAdventureState)
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
         var _loc1_:Object = AvatarXtCommManager.avSlotInfo;
         var _loc3_:int = 0;
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

