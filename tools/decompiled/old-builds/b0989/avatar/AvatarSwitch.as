package avatar
{
   import buddy.BuddyEvent;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import createAccountGui.GuiAvatarCreationAssets;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.media.SoundTransform;
   import gui.BuddyCard;
   import gui.BuddyManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.GuiNameTypeScreen;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class AvatarSwitch
   {
      
      public static var avatars:Array;
      
      public static var activeAvatarIdx:int;
      
      public static var playerUserInfo:UserInfo;
      
      public static var nameTypeScreen:GuiNameTypeScreen;
      
      public static var creationAssets:GuiAvatarCreationAssets;
      
      public static var playerUsername:String;
      
      public static var playerSfsUserId:int;
      
      public static var isSlotAvail:int;
      
      public static var isAddingSlot:Boolean;
      
      public static var availSlotFlags:int;
      
      public static var isChoosing:Boolean;
      
      private static var _addSlotCallback:Function;
      
      private static var _switchCallback:Function;
      
      private static var _addIdx:int;
      
      private static var _switchIdx:int;
      
      private static var _addAvatarCallback:Function;
      
      private static var _addAvatar:Avatar;
      
      private static var _addAvName:String;
      
      private static var _removeCallback:Function;
      
      private static var _removeIdx:int;
      
      private static var _isChoosing:Boolean;
      
      private static var _asTransformVec:Vector.<MediaHelper>;
      
      private static var _secondChosenAvtIdx:int;
      
      private static var _numOpenNonMemberSlots:int;
      
      private static var _caIdx:int;
      
      private static var _avatarName:String;
      
      private static var _avatarNameIndexes:Array;
      
      private static var _shopId:int;
      
      private static var _itemInShopDefId:int;
      
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
            playerUsername = playerUserInfo.userName;
            playerSfsUserId = gMainFrame.server.userId;
            avatars = [];
            updateAvatars();
         }
         else
         {
            _loc1_ = 0;
            while(_loc1_ < avatars.length)
            {
               if(Boolean(avatars[_loc1_]) && avatars[_loc1_].dbAvId == gMainFrame.userInfo.myDbAvId)
               {
                  if(_loc1_ != 0)
                  {
                     avatars.unshift(avatars[_loc1_]);
                     avatars.splice(_loc1_ + 1,1);
                     activeAvatarIdx = _switchIdx = 0;
                  }
                  break;
               }
               _loc1_++;
            }
            avatars[activeAvatarIdx] = AvatarManager.playerAvatar;
         }
      }
      
      public static function updateSlotPositions() : void
      {
         var _loc1_:Array = avatars.slice();
         var _loc2_:int = int(avatars[_switchIdx].dbAvId);
         var _loc3_:int = int(avatars[activeAvatarIdx].dbAvId);
         var _loc4_:int = 0;
         avatars = [];
         var _loc5_:int = 0;
         while(_loc5_ < _loc1_.length)
         {
            if(_loc1_[_loc5_] != null)
            {
               avatars.push(_loc1_[_loc5_]);
               if(_loc2_ == _loc1_[_loc5_].dbAvId)
               {
                  _switchIdx = _loc5_ - _loc4_;
                  AvatarXtCommManager.avSlotInfo[_loc2_].slotId = _switchIdx;
               }
               if(_loc3_ == _loc1_[_loc5_].dbAvId)
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
            if(_loc1_.dbAvId == playerUserInfo.currDbAvId)
            {
               _loc4_ = AvatarManager.playerAvatar;
            }
            else
            {
               _loc4_ = avatars[AvatarXtCommManager.avSlotInfo[_loc1_.dbAvId].slotId];
               if(!_loc4_)
               {
                  _loc4_ = new Avatar();
                  _loc4_ = AvatarUtility.generateNew(_loc1_.dbAvId,_loc4_,playerSfsUserId,AvatarManager.roomEnviroType);
               }
            }
            avatars[AvatarXtCommManager.avSlotInfo[_loc1_.dbAvId].slotId] = _loc4_;
            _loc4_ = null;
         }
         _loc2_ = int(avatars.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(avatars[_loc3_] != null)
            {
               _loc5_ = avatars[_loc3_];
               if(playerUserInfo.currDbAvId == _loc5_.dbAvId)
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
               else if((availSlotFlags & 1 << AvatarXtCommManager.avSlotInfo[avatars[_loc4_].dbAvId].avInvId) > 0)
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
            if(Boolean(avatars[_loc2_]) && Boolean(!gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[_loc2_].avTypeId)) && (availSlotFlags & 1 << AvatarXtCommManager.avSlotInfo[avatars[_loc2_].dbAvId].avInvId) > 0)
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
            if(Boolean(avatars[_loc2_]) && (availSlotFlags & 1 << AvatarXtCommManager.avSlotInfo[avatars[_loc2_].dbAvId].avInvId) > 0)
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
         return (availSlotFlags & 1 << AvatarXtCommManager.avSlotInfo[avatars[param1].dbAvId].avInvId) > 0;
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
            addNewWorldAvatar(_caIdx,_avatarName,_avatarNameIndexes);
         }
         DarkenManager.showLoadingSpiral(false);
         if(_addSlotCallback != null)
         {
            _addSlotCallback(param1,true);
         }
      }
      
      public static function addAvatar(param1:int, param2:Boolean = false, param3:Function = null, param4:Boolean = false, param5:Boolean = false, param6:int = -1, param7:Boolean = false, param8:int = 0, param9:int = -1, param10:int = -1, param11:int = -1) : void
      {
         _addIdx = param1;
         _addAvatarCallback = param3;
         _isChoosing = param4;
         _shopId = param10;
         _itemInShopDefId = param11;
         isAddingSlot = param2;
         creationAssets = AvatarUtility.creationAssets;
         if(creationAssets == null)
         {
            throw new Error("AvatarSwitch could not get a creationAssets reference!");
         }
         creationAssets.parent.setChildIndex(creationAssets,creationAssets.parent.numChildren - 1);
         var _loc12_:int = AvatarUtility.numNonMemberAvatars();
         AvatarUtility.reloadAvatarChooser(param5,_loc12_ >= 1 && _loc12_ - numNonMemberOceanAvatars > 0 ? false : param4,param6,param7,param8,param9);
         creationAssets.visible = true;
      }
      
      public static function set addAvatarCallback(param1:Function) : void
      {
         _addAvatarCallback = param1;
      }
      
      public static function addNewWorldAvatar(param1:int, param2:String, param3:Array, param4:Boolean = false) : void
      {
         if(isAddingSlot)
         {
            _caIdx = param1;
            _avatarName = param2;
            _avatarNameIndexes = param3;
            addSlot(_addAvatarCallback);
         }
         else
         {
            _addAvatar = AvatarUtility.creationAvatars[AvatarUtility.findAvatarIndexByType(param1)];
            _addAvName = param2;
            if(_addAvatar != null && param3[0] != null && param3[1] != null && param3[2] != null)
            {
               SBTracker.pop();
               if(_shopId != -1 && param4)
               {
                  AvatarXtCommManager.requestAvatarShopBuy([_shopId,_itemInShopDefId,GenericListXtCommManager.getAvailListUniqueId(),param3[0],param3[1],param3[2],_addAvatar.avTypeId],addAvatarResponse);
               }
               else
               {
                  AvatarXtCommManager.requestAvatarAdd([param3[0],param3[1],param3[2],_addAvatar.avTypeId],addAvatarResponse);
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
         if(param1 == 1)
         {
            _loc4_ = new Avatar();
            _loc4_.init(param2,_addAvName,_addAvatar.avTypeId,null,null,playerUsername,playerSfsUserId);
            _loc4_.copyColors(_addAvatar.colors);
            _loc4_.cloneShownAccFromAvatar(_addAvatar);
            _loc4_.accState.hideAllClothingArticles();
            if(!_isChoosing)
            {
               if((availSlotFlags & 1 << param3) == 0)
               {
                  availSlotFlags |= 1 << param3;
               }
               if(!Utility.isSameEnviroType(_loc4_.enviroTypeFlag,AvatarManager.roomEnviroType))
               {
                  avatars.splice(_addIdx,1);
                  avatars.unshift(_loc4_);
                  AvatarXtCommManager.avSlotInfo[_loc4_.dbAvId] = {
                     "slotId":0,
                     "avInvId":param3
                  };
                  _addIdx = 0;
               }
               else
               {
                  AvatarXtCommManager.avSlotInfo[_loc4_.dbAvId] = {
                     "slotId":_addIdx,
                     "avInvId":param3
                  };
                  avatars[_addIdx] = _loc4_;
               }
               switchAvatars(_addIdx);
            }
            else
            {
               AvatarXtCommManager.avSlotInfo[_loc4_.dbAvId] = {
                  "slotId":_addIdx,
                  "avInvId":param3
               };
               avatars[_addIdx] = _loc4_;
            }
         }
         if(param1 != 1 || _isChoosing)
         {
            DarkenManager.showLoadingSpiral(false);
            if(_addAvatarCallback != null)
            {
               _addAvatarCallback(param1);
               _addAvatarCallback = null;
            }
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
         AvatarXtCommManager.requestAvatarSwitch([avatars[param1].dbAvId]);
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
            _loc5_.setActivePet(0,0,0);
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
            _loc6_.init(_loc5_.roomType == Utility.ENVIRO_LAND ? uint(ASTRANSFORM_MEDIA_ID_TOP) : uint(ASTRANSFORM_OCEAN_MEDIA_ID_TOP),asTransformMediaHelper,[_loc5_,param1]);
            _asTransformVec.push(_loc6_);
            _loc7_ = new MediaHelper();
            _loc7_.init(_loc5_.roomType == Utility.ENVIRO_LAND ? uint(ASTRANSFORM_MEDIA_ID_BOTTOM) : uint(ASTRANSFORM_OCEAN_MEDIA_ID_BOTTOM),asTransformMediaHelper,[_loc5_]);
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
            GuiManager.setSwapBtnGray(false);
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
      
      public static function myAvatarListCallback(param1:int) : void
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
         AvatarXtCommManager.requestAvatarKill([avatars[param1].dbAvId],avatarKillResponse);
      }
      
      public static function avatarKillResponse(param1:Boolean, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:UserInfo = null;
         if(param1)
         {
            _loc4_ = isSlotAvailable(_removeIdx);
            _loc3_ = int(AvatarXtCommManager.avSlotInfo[avatars[_removeIdx].dbAvId].avInvId);
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(avatars[_removeIdx].userName);
            _loc5_.allItemsInUseOff(avatars[_removeIdx].dbAvId);
            AvatarXtCommManager.avSlotInfo[avatars[_removeIdx].dbAvId].avInvId = null;
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
         _loc3_[0] = AvatarXtCommManager.avSlotInfo[avatars[param1[0]].dbAvId].avInvId;
         if(param1[1] != null && Boolean(AvatarSwitch.avatars[param1[1]]))
         {
            _loc3_[1] = AvatarXtCommManager.avSlotInfo[avatars[param1[1]].dbAvId].avInvId;
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
         var _loc18_:int = 0;
         var _loc19_:BuddyEvent = null;
         var _loc20_:AvatarWorldView = null;
         var _loc21_:AvatarWorldView = null;
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
                  _loc8_.dbAvId = _loc7_.dbAvId;
                  _loc8_.avTypeId = _loc7_.avTypeId;
                  _loc8_.copyColors(_loc7_.colors);
                  _loc8_.avName = _loc7_.avName;
                  _loc8_.cloneShownAccFromAvatar(_loc7_);
                  AvatarManager.clearPlayerSplashColor();
               }
               _loc7_.removeAllItems();
               _loc7_.dbAvId = int(_loc3_[int(_loc4_++)]);
               _loc7_.avTypeId = int(_loc3_[int(_loc4_++)]);
               _loc7_.setColors(uint(_loc3_[int(_loc4_++)]),uint(_loc3_[int(_loc4_++)]),uint(_loc3_[int(_loc4_++)]));
               _loc7_.avName = _loc3_[int(_loc4_++)];
               if(_loc7_.userName == gMainFrame.userInfo.myUserName && gMainFrame.userInfo.getAvatarInfoByDbAvId(_loc7_.dbAvId) == null)
               {
                  AvatarXtCommManager.requestADForAvatar(_loc7_.dbAvId,true,null,_loc7_);
               }
               else
               {
                  _loc10_ = new AvatarInfo();
                  _loc10_.dbAvId = _loc7_.dbAvId;
                  _loc10_.avName = _loc7_.avName;
                  _loc10_.userName = _loc7_.userName;
                  _loc10_.colors = _loc7_.colors.concat();
                  _loc10_.type = _loc7_.avTypeId;
               }
               if(_loc6_)
               {
                  gMainFrame.userInfo.myDbAvId = _loc7_.dbAvId;
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
                  _loc12_ = int(_loc3_[int(_loc4_++)]);
                  _loc13_ = PetManager.getMyPetByInvId(_loc12_);
                  if(AvatarManager.playerAvatarWorldView)
                  {
                     _loc9_ = AvatarManager.playerAvatarWorldView;
                     _loc9_.setActivePet(_loc13_ ? uint(_loc13_.lBits) : 0,_loc13_ ? uint(_loc13_.uBits) : 0,_loc13_ ? uint(_loc13_.eBits) : 0);
                  }
                  PetManager.myActivePetInvId = _loc12_;
                  _loc14_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(_loc7_.dbAvId);
                  if(_loc14_)
                  {
                     _loc10_.questLevel = _loc14_.questLevel;
                     _loc10_.questHealthPercentage = _loc14_.questHealthPercentage;
                     _loc10_.healthBase = _loc14_.healthBase;
                     _loc10_.attackBase = _loc14_.attackBase;
                     _loc10_.attackMax = _loc14_.attackMax;
                     _loc10_.defenseBase = _loc14_.defenseBase;
                     _loc10_.defenseMax = _loc14_.defenseMax;
                     _loc7_.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(_loc7_.userName).getPartialItemList(_loc7_.avTypeId,true));
                     gMainFrame.userInfo.setAvatarInfoByDbAvId(_loc7_.dbAvId,_loc10_,true);
                     _loc9_.updateNameBarLevelShape(_loc10_.questLevel);
                  }
                  updateAvatarSlotIds();
               }
               else
               {
                  ItemXtCommManager.requestItemListForAvatar(null,_loc7_,false,false);
                  if(Boolean(AvatarManager.buddyCardAvatarView) && _loc7_.userName == AvatarManager.buddyCardAvatarView.userName)
                  {
                     BuddyCard.updateCurrBuddyCardAvatar(_loc7_);
                  }
                  _loc15_ = int(_loc3_[int(_loc4_++)]);
                  _loc16_ = int(_loc3_[int(_loc4_++)]);
                  _loc17_ = int(_loc3_[int(_loc4_++)]);
                  _loc18_ = int(_loc3_[_loc4_++]);
                  _loc9_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc5_);
                  if(_loc9_)
                  {
                     _loc9_.setActivePet(_loc15_,_loc16_,_loc17_);
                  }
                  _loc10_.questLevel = _loc18_;
                  gMainFrame.userInfo.setAvatarInfoByDbAvId(_loc7_.dbAvId,_loc10_,true);
                  _loc9_.updateNameBarLevelShape(_loc10_.questLevel);
                  _loc19_ = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
                  _loc19_.userName = _loc10_.userName;
                  BuddyManager.eventDispatcher.dispatchEvent(_loc19_);
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
            _loc20_ = AvatarWorldView(_loc2_.parent);
            if(_loc20_.roomType == Utility.ENVIRO_LAND)
            {
               _loc20_.setBlendColor(4290903190,7534606);
            }
            else
            {
               _loc20_.setBlendColor(4294967295,16777107);
            }
         }
         else if(_loc2_.currentFrameLabel == "tintOff")
         {
            _loc21_ = AvatarWorldView(_loc2_.parent);
            _loc21_.setBlendColor(0);
            _loc21_.setAlphaLevel(100);
            if(_loc21_.userId == playerSfsUserId)
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
         GuiManager.setSwapBtnGray(false);
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
               _loc2_ = _loc1_[avatars[_loc3_].dbAvId];
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

