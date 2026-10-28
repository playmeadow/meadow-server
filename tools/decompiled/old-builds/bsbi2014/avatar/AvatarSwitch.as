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
         var i:int = 0;
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
            for(i = 0; i < avatars.length; i++)
            {
               if(Boolean(avatars[i]))
               {
                  if(avatars[i].perUserAvId == gMainFrame.userInfo.myPerUserAvId)
                  {
                     if(i != 0)
                     {
                        avatars.unshift(avatars[i]);
                        avatars.splice(i + 1,1);
                        activeAvatarIdx = _switchIdx = 0;
                     }
                  }
                  avatars[i].roomType = AvatarManager.roomEnviroType;
               }
            }
            avatars[activeAvatarIdx] = AvatarManager.playerAvatar;
         }
      }
      
      public static function updateSlotPositions() : void
      {
         var tempAvatars:Array = avatars.slice();
         var tempSwitchperUserAvId:int = int(avatars[_switchIdx].perUserAvId);
         var tempActiveAvatarperUserAvId:int = int(avatars[activeAvatarIdx].perUserAvId);
         var numSkipped:int = 0;
         avatars = [];
         for(var i:int = 0; i < tempAvatars.length; i++)
         {
            if(tempAvatars[i] != null)
            {
               avatars.push(tempAvatars[i]);
               if(tempSwitchperUserAvId == tempAvatars[i].perUserAvId)
               {
                  _switchIdx = i - numSkipped;
                  AvatarXtCommManager.avSlotInfo[tempSwitchperUserAvId].slotId = _switchIdx;
               }
               if(tempActiveAvatarperUserAvId == tempAvatars[i].perUserAvId)
               {
                  activeAvatarIdx = i - numSkipped;
                  AvatarXtCommManager.avSlotInfo[tempActiveAvatarperUserAvId].slotId = activeAvatarIdx;
               }
            }
            else
            {
               numSkipped++;
            }
         }
      }
      
      private static function updateAvatars() : void
      {
         var uai:AvatarInfo = null;
         var avatarsLength:int = 0;
         var i:int = 0;
         var av:Avatar = null;
         var sa:Avatar = null;
         for each(uai in playerUserInfo.avList)
         {
            if(uai.perUserAvId == playerUserInfo.currPerUserAvId)
            {
               av = AvatarManager.playerAvatar;
            }
            else
            {
               av = avatars[AvatarXtCommManager.avSlotInfo[uai.perUserAvId].slotId];
               if(!av)
               {
                  av = new Avatar();
                  av = AvatarUtility.generateNew(uai.perUserAvId,av,uai.userName,playerSfsUserId,AvatarManager.roomEnviroType);
               }
            }
            avatars[AvatarXtCommManager.avSlotInfo[uai.perUserAvId].slotId] = av;
            av = null;
         }
         avatarsLength = int(avatars.length);
         for(i = 0; i < avatarsLength; i++)
         {
            if(avatars[i] != null)
            {
               sa = avatars[i];
               if(playerUserInfo.currPerUserAvId == sa.perUserAvId)
               {
                  activeAvatarIdx = _switchIdx = i;
                  break;
               }
            }
         }
      }
      
      public static function shouldChoose() : Boolean
      {
         var nonMemberAvatars:int = 0;
         var numOceanOnlyAvatars:int = 0;
         var memberAvatars:int = 0;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]))
            {
               if(isMemberOnlyAvatar(i))
               {
                  memberAvatars++;
               }
               else
               {
                  if(avatars[i].enviroTypeFlag == 2)
                  {
                     numOceanOnlyAvatars++;
                  }
                  nonMemberAvatars++;
               }
            }
         }
         if(nonMemberAvatars < 3 && nonMemberAvatars > 0 && numOceanOnlyAvatars < 2 && nonMemberAvatars != numOceanOnlyAvatars)
         {
            return false;
         }
         return true;
      }
      
      public static function isMemberOnlyAvatar(index:int) : Boolean
      {
         return gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[index].avTypeId);
      }
      
      public static function get numTotalAvatars() : int
      {
         var numAvts:int = 0;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]))
            {
               numAvts++;
            }
         }
         return numAvts;
      }
      
      public static function getNumUsableLandAvatars(isChoosing:Boolean, isMember:Boolean) : int
      {
         var num:int = 0;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]) && Utility.isLand(avatars[i].enviroTypeFlag))
            {
               if(isChoosing || isMember)
               {
                  num++;
               }
               else if((availSlotFlags & 1 << AvatarXtCommManager.avSlotInfo[avatars[i].perUserAvId].avInvId) > 0)
               {
                  num++;
               }
            }
         }
         return num;
      }
      
      public static function get numMemberAvatars() : int
      {
         var num:int = 0;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]) && Boolean(gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[i].avTypeId)))
            {
               num++;
            }
         }
         return num;
      }
      
      public static function get numNonMemberAvatars() : int
      {
         var num:int = 0;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]) && !gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[i].avTypeId))
            {
               num++;
            }
         }
         return num;
      }
      
      public static function get numNonMemberOceanAvatars() : int
      {
         var num:int = 0;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]) && Boolean(!gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[i].avTypeId)) && avatars[i].enviroTypeFlag == 2)
            {
               num++;
            }
         }
         return num;
      }
      
      public static function getNumNonMemberAvailableAvatars() : int
      {
         var num:int = 0;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]) && Boolean(!gMainFrame.userInfo.getAvatarMemberInfoByAvType(avatars[i].avTypeId)) && (availSlotFlags & 1 << AvatarXtCommManager.avSlotInfo[avatars[i].perUserAvId].avInvId) > 0)
            {
               num++;
            }
         }
         return num;
      }
      
      public static function get numAvailAvatars() : int
      {
         var numAvailAvts:int = 0;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]) && (availSlotFlags & 1 << AvatarXtCommManager.avSlotInfo[avatars[i].perUserAvId].avInvId) > 0)
            {
               numAvailAvts++;
            }
         }
         return numAvailAvts;
      }
      
      public static function isSwitching() : Boolean
      {
         return Boolean(activeAvatarIdx != _switchIdx);
      }
      
      public static function isSlotAvailable(slotIdx:int) : Boolean
      {
         return (availSlotFlags & 1 << AvatarXtCommManager.avSlotInfo[avatars[slotIdx].perUserAvId].avInvId) > 0;
      }
      
      public static function get numOpenNonMemberSlots() : int
      {
         return _numOpenNonMemberSlots;
      }
      
      public static function set numOpenNonMemberSlots(value:int) : void
      {
         _numOpenNonMemberSlots = value;
      }
      
      public static function addSlot(addSlotCallback:Function) : void
      {
         _addSlotCallback = addSlotCallback;
         AvatarXtCommManager.requestAvatarBuy(showNewAvatarPopup);
      }
      
      public static function showNewAvatarPopup(success:Boolean) : void
      {
         if(success)
         {
            isAddingSlot = false;
            addNewWorldAvatar(_caIdx,_avatarName,_avatarNameIndexes);
         }
         DarkenManager.showLoadingSpiral(false);
         if(_addSlotCallback != null)
         {
            _addSlotCallback(success,true);
         }
      }
      
      public static function addAvatar(index:int, addingSlot:Boolean = false, addAvatarCallback:Function = null, isChoosing:Boolean = false, isChoosingOceanAnimal:Boolean = false, avatarTypeToShow:int = -1, skipToNameScreen:Boolean = false, currencyType:int = 0, specialValue:int = -1, shopId:int = -1, itemDefId:int = -1) : void
      {
         _addIdx = index;
         _addAvatarCallback = addAvatarCallback;
         _isChoosing = isChoosing;
         _shopId = shopId;
         _itemInShopDefId = itemDefId;
         isAddingSlot = addingSlot;
         var numNonMemberAvatars:int = AvatarUtility.numNonMemberAvatars();
         GuiManager.openAvatarCreator(isChoosingOceanAnimal,numNonMemberAvatars >= 1 && numNonMemberAvatars - numNonMemberOceanAvatars > 0 ? false : isChoosing,avatarTypeToShow,skipToNameScreen,currencyType,specialValue);
      }
      
      public static function set addAvatarCallback(value:Function) : void
      {
         _addAvatarCallback = value;
      }
      
      public static function addNewWorldAvatar(caIdx:int, avatarName:String, avatarNameIndexes:Array, isShopBuy:Boolean = false) : void
      {
         var nameIndex1:int = 0;
         var nameIndex2:int = 0;
         if(isAddingSlot)
         {
            _caIdx = caIdx;
            _avatarName = avatarName;
            _avatarNameIndexes = avatarNameIndexes;
            addSlot(_addAvatarCallback);
         }
         else
         {
            _addAvatar = AvatarUtility.creationAvatars[AvatarUtility.findAvatarIndexByType(caIdx)];
            _addAvName = avatarName;
            if(_addAvatar != null && avatarNameIndexes[0] != null && avatarNameIndexes[1] != null && avatarNameIndexes[2] != null)
            {
               nameIndex1 = LocalizationManager.isCurrLanguageReversed() ? int(avatarNameIndexes[2]) : int(avatarNameIndexes[1]);
               nameIndex2 = LocalizationManager.isCurrLanguageReversed() ? int(avatarNameIndexes[1]) : int(avatarNameIndexes[2]);
               SBTracker.pop();
               if(_shopId != -1 && isShopBuy)
               {
                  AvatarXtCommManager.requestAvatarShopBuy([_shopId,_itemInShopDefId,GenericListXtCommManager.getAvailListUniqueId(),avatarNameIndexes[0],nameIndex1,nameIndex2,_addAvatar.avTypeId],addAvatarResponse);
               }
               else
               {
                  AvatarXtCommManager.requestAvatarAdd([avatarNameIndexes[0],nameIndex1,nameIndex2,_addAvatar.avTypeId],addAvatarResponse);
               }
            }
            else
            {
               DebugUtility.debugTrace("Failed to request add avatar with addAvatar = " + _addAvatar + " AvatarNameIndexes[0] = " + avatarNameIndexes[0] + " AvatarNameIndexes[1] = " + avatarNameIndexes[1] + " AvatarNameIndexes[2] = " + avatarNameIndexes[2] + " addAvatar.avTypeId = " + (_addAvatar != null ? _addAvatar.avTypeId : null));
            }
         }
      }
      
      public static function addAvatarResponse(status:int, newPerUserAvId:int, newAvInvId:int) : void
      {
         var addAvCopy:Avatar = null;
         _status = status;
         if(_status == 1)
         {
            addAvCopy = new Avatar();
            addAvCopy.init(newPerUserAvId,_addAvName,_addAvatar.avTypeId,null,null,playerUsername,playerSfsUserId);
            addAvCopy.copyColors(_addAvatar.colors);
            addAvCopy.cloneShownAccFromAvatar(_addAvatar);
            addAvCopy.accState.hideAllClothingArticles();
            if(_isChoosing)
            {
               AvatarXtCommManager.avSlotInfo[addAvCopy.perUserAvId] = {
                  "slotId":_addIdx,
                  "avInvId":newAvInvId
               };
               avatars[_addIdx] = addAvCopy;
               AvatarXtCommManager.requestADForAvatar(addAvCopy.perUserAvId,true,onChoosingAdReceive,addAvCopy);
               return;
            }
            if((availSlotFlags & 1 << newAvInvId) == 0)
            {
               availSlotFlags |= 1 << newAvInvId;
            }
            if(!Utility.isSameEnviroType(addAvCopy.enviroTypeFlag,AvatarManager.roomEnviroType))
            {
               avatars.splice(_addIdx,1);
               avatars.unshift(addAvCopy);
               AvatarXtCommManager.avSlotInfo[addAvCopy.perUserAvId] = {
                  "slotId":0,
                  "avInvId":newAvInvId
               };
               _addIdx = 0;
            }
            else
            {
               AvatarXtCommManager.avSlotInfo[addAvCopy.perUserAvId] = {
                  "slotId":_addIdx,
                  "avInvId":newAvInvId
               };
               avatars[_addIdx] = addAvCopy;
            }
            switchAvatars(_addIdx);
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
      
      private static function onChoosingAdReceive() : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_addAvatarCallback != null)
         {
            _addAvatarCallback(_status);
            _addAvatarCallback = null;
         }
      }
      
      public static function switchAvatars(switchIdx:int, switchAvatarsCallback:Function = null) : void
      {
         if(switchIdx < 0 || switchIdx >= avatars.length)
         {
            throw new Error("Invalid switchIdx:" + switchIdx);
         }
         _switchCallback = switchAvatarsCallback;
         _switchIdx = switchIdx;
         RoomXtCommManager.isSwitching = true;
         _isChoosing = false;
         DarkenManager.showLoadingSpiral(true);
         RoomManagerWorld.instance.forceStopMovement();
         AvatarXtCommManager.requestAvatarSwitch([avatars[switchIdx].perUserAvId]);
      }
      
      public static function setAvatarSwitchCallback(switchAvatarsCallback:Function) : void
      {
         _switchCallback = switchAvatarsCallback;
      }
      
      public static function avatarSwitchResponse(data:Array) : void
      {
         var sfsUserId:int = 0;
         var savw:AvatarWorldView = null;
         var asTransformTop:MediaHelper = null;
         var asTransformBtm:MediaHelper = null;
         var ftci:int = 0;
         var ftcdo:DisplayObject = null;
         DarkenManager.showLoadingSpiral(false);
         if(!_isChoosing)
         {
            if(_addAvatarCallback != null)
            {
               _addAvatarCallback(true);
               _addAvatarCallback = null;
            }
         }
         var asi:int = 2;
         var success:Boolean = Boolean(int(data[int(asi++)]));
         if(success)
         {
            sfsUserId = int(data[int(asi++)]);
            savw = AvatarManager.avatarViewList[sfsUserId];
            if(savw == null)
            {
               DebugUtility.debugTrace("ERROR: invalid avatar worldview savw:" + savw + " sfsUserId:" + sfsUserId + " data:" + data);
               return;
            }
            savw.setActivePet(0,0,0,"");
            if(savw.getChildAt(0).hasOwnProperty("onbottom1"))
            {
               ftci = savw.numChildren - 1;
               while(ftci > 0)
               {
                  ftcdo = savw.getChildAt(ftci);
                  if(ftcdo is MovieClip && MovieClip(ftcdo).hasOwnProperty("isTransformTop"))
                  {
                     endTransformAnim(MovieClip(ftcdo));
                     break;
                  }
                  ftci--;
               }
               endTransformAnim(savw.getChildAt(0) as MovieClip);
            }
            if(_asTransformVec == null)
            {
               DebugUtility.debugTrace("ERROR: invalid AvatarSwitch state _asTransformTopMHVec:" + " data:" + data);
               return;
            }
            asTransformTop = new MediaHelper();
            asTransformTop.init(savw.roomType == Utility.ENVIRO_LAND ? uint(ASTRANSFORM_MEDIA_ID_TOP) : uint(ASTRANSFORM_OCEAN_MEDIA_ID_TOP),asTransformMediaHelper,[savw,data]);
            _asTransformVec.push(asTransformTop);
            asTransformBtm = new MediaHelper();
            asTransformBtm.init(savw.roomType == Utility.ENVIRO_LAND ? uint(ASTRANSFORM_MEDIA_ID_BOTTOM) : uint(ASTRANSFORM_OCEAN_MEDIA_ID_BOTTOM),asTransformMediaHelper,[savw]);
            _asTransformVec.push(asTransformBtm);
            if(sfsUserId == playerSfsUserId)
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
            _switchCallback(success,true);
            if(!success)
            {
               _switchCallback = null;
            }
         }
      }
      
      public static function myAvatarListCallback(slotFlags:int) : void
      {
         availSlotFlags = slotFlags;
      }
      
      public static function removeAvatar(removeIdx:int, removeAvatarCallback:Function) : void
      {
         if(removeIdx < 0 || removeIdx >= avatars.length)
         {
            throw new Error("Invalid removeIdx:" + removeIdx);
         }
         if(avatars.length <= 1)
         {
            throw new Error("Tried to remove avatar when less than 2 were left!");
         }
         _removeCallback = removeAvatarCallback;
         _removeIdx = removeIdx;
         AvatarXtCommManager.requestAvatarKill([avatars[removeIdx].perUserAvId],avatarKillResponse);
      }
      
      public static function avatarKillResponse(success:Boolean, newGemBalance:int) : void
      {
         var removedAvInvId:int = 0;
         var isCurrSlotAvailable:Boolean = false;
         var ui:UserInfo = null;
         if(success)
         {
            isCurrSlotAvailable = isSlotAvailable(_removeIdx);
            removedAvInvId = int(AvatarXtCommManager.avSlotInfo[avatars[_removeIdx].perUserAvId].avInvId);
            ui = gMainFrame.userInfo.getUserInfoByUserName(avatars[_removeIdx].userName);
            ui.allItemsInUseOff(avatars[_removeIdx].perUserAvId);
            AvatarXtCommManager.avSlotInfo[avatars[_removeIdx].perUserAvId].avInvId = null;
            avatars[_removeIdx] = null;
         }
         if(_removeCallback != null)
         {
            _removeCallback(success,_removeIdx,removedAvInvId,newGemBalance,isCurrSlotAvailable);
         }
         _removeIdx = -1;
      }
      
      public static function chooseTwo(switchIdxs:Array, aoCallback:Function) : void
      {
         _switchIdx = avatars[switchIdxs[0]].enviroTypeFlag == 2 ? int(switchIdxs[1]) : int(switchIdxs[0]);
         _secondChosenAvtIdx = -1;
         var switchInvIds:Array = [];
         switchInvIds[0] = AvatarXtCommManager.avSlotInfo[avatars[switchIdxs[0]].perUserAvId].avInvId;
         if(switchIdxs[1] != null && Boolean(AvatarSwitch.avatars[switchIdxs[1]]))
         {
            switchInvIds[1] = AvatarXtCommManager.avSlotInfo[avatars[switchIdxs[1]].perUserAvId].avInvId;
            _secondChosenAvtIdx = switchIdxs[1];
         }
         AvatarXtCommManager.requestAvatarOrdain(switchInvIds,aoCallback);
      }
      
      private static function asTransformMediaHelper(mc:MovieClip) : void
      {
         if(!mc.hasOwnProperty("mediaHelper"))
         {
            return;
         }
         var mh:MediaHelper = MediaHelper(mc.mediaHelper);
         var mhid:int = mh.id;
         if(mhid != ASTRANSFORM_MEDIA_ID_TOP && mhid != ASTRANSFORM_MEDIA_ID_BOTTOM && mhid != ASTRANSFORM_OCEAN_MEDIA_ID_TOP && mhid != ASTRANSFORM_OCEAN_MEDIA_ID_BOTTOM)
         {
            return;
         }
         mc.addEventListener(Event.ENTER_FRAME,transformEnterFrameHandler);
         var savw:AvatarView = AvatarView((mc.passback as Array)[0]);
         if(mhid == ASTRANSFORM_MEDIA_ID_TOP || mhid == ASTRANSFORM_OCEAN_MEDIA_ID_TOP)
         {
            mc.data = (mc.passback as Array)[1] as Array;
            DebugUtility.debugTrace("got top media for sfsUserId:" + int(mc.data[3]));
            mc.isTransformTop = true;
            savw.addChild(mc);
            _asTransformVec.splice(_asTransformVec.indexOf(mh),1);
         }
         else
         {
            mc.isTransformBottom = true;
            savw.addChildAt(mc,0);
            _asTransformVec.splice(_asTransformVec.indexOf(mh),1);
         }
         mc.gotoAndPlay(1);
         mc.mediaHelper.destroy();
         delete mc.mediaHelper;
         delete mc.passback;
      }
      
      private static function transformEnterFrameHandler(e:Event) : void
      {
         var data:Array = null;
         var asi:int = 0;
         var sfsUserId:int = 0;
         var selfSwitch:Boolean = false;
         var sav:Avatar = null;
         var otherAvatar:Avatar = null;
         var avatarWorldView:AvatarWorldView = null;
         var sai:AvatarInfo = null;
         var newAvatar:Avatar = null;
         var petInvId:int = 0;
         var myPet:Object = null;
         var newAvInfo:AvatarInfo = null;
         var lBits:int = 0;
         var uBits:int = 0;
         var eBits:int = 0;
         var petName:String = null;
         var questLevel:int = 0;
         var currPet:Object = null;
         var ble:BuddyEvent = null;
         var savw:AvatarWorldView = null;
         var etavw:AvatarWorldView = null;
         var tf:MovieClip = MovieClip(e.target);
         if(tf.parent == null || AvatarView(tf.parent).avatarData == null)
         {
            endTransformAnim(tf);
            return;
         }
         if(tf.currentFrameLabel != null)
         {
            DebugUtility.debugTrace("entered frame:" + tf.currentFrameLabel + " on transform effect for sfsUserId:" + AvatarView(tf.parent).userId);
         }
         if(tf.currentFrameLabel == "hideAvatar")
         {
            AvatarView(tf.parent).hideAvatar();
            if(tf.hasOwnProperty("data"))
            {
               data = tf.data;
               asi = 3;
               sfsUserId = int(data[int(asi++)]);
               selfSwitch = Boolean(sfsUserId == playerSfsUserId);
               sav = AvatarManager.getAvatarBySfsUserId(sfsUserId);
               if(selfSwitch)
               {
                  otherAvatar = avatars[_switchIdx];
                  otherAvatar.perUserAvId = sav.perUserAvId;
                  otherAvatar.avTypeId = sav.avTypeId;
                  otherAvatar.copyColors(sav.colors);
                  otherAvatar.avName = sav.avName;
                  otherAvatar.cloneShownAccFromAvatar(sav);
                  AvatarManager.clearPlayerSplashColor();
               }
               sav.removeAllItems();
               sav.perUserAvId = int(data[int(asi++)]);
               sav.avTypeId = int(data[int(asi++)]);
               sav.setColors(uint(data[int(asi++)]),uint(data[int(asi++)]),uint(data[int(asi++)]));
               sav.avName = data[int(asi++)];
               if(sav.userName == gMainFrame.userInfo.myUserName && gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(sav.userName,sav.perUserAvId) == null)
               {
                  AvatarXtCommManager.requestADForAvatar(sav.perUserAvId,true,null,sav);
               }
               else
               {
                  sai = new AvatarInfo();
                  sai.perUserAvId = sav.perUserAvId;
                  sai.avName = sav.avName;
                  sai.userName = sav.userName;
                  sai.colors = sav.colors.concat();
                  sai.type = sav.avTypeId;
               }
               avatarWorldView = AvatarManager.getAvatarWorldViewBySfsUserId(sfsUserId);
               if(Boolean(avatarWorldView))
               {
                  if(avatarWorldView.parent != null)
                  {
                     avatarWorldView.parent.removeChild(avatarWorldView);
                  }
                  if(Boolean(sav.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
                  {
                     avatarWorldView.x += AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                     avatarWorldView.y += AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                     AvatarManager.getFlyingLayer.addChild(avatarWorldView);
                  }
                  else
                  {
                     avatarWorldView.x -= AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                     avatarWorldView.y -= AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                     AvatarManager.getAvatarLayer.addChild(avatarWorldView);
                  }
               }
               if(selfSwitch)
               {
                  if((otherAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_AIR) != (sav.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
                  {
                     RoomManagerWorld.instance.rebuildGrid();
                     if(avatarWorldView == null && !(sav.enviroTypeFlag & 1 << Utility.ENVIRO_AIR) || Boolean(RoomManagerWorld.instance.collisionTestGrid(avatarWorldView.x,avatarWorldView.y)))
                     {
                        RoomManagerWorld.instance.teleportPlayerToDefault();
                     }
                  }
                  gMainFrame.userInfo.myPerUserAvId = sav.perUserAvId;
                  GuiManager.positionHudAvatar();
                  newAvatar = avatars[activeAvatarIdx];
                  avatars.splice(activeAvatarIdx,1);
                  avatars.unshift(avatars[_switchIdx - 1]);
                  avatars.splice(_switchIdx,1);
                  if(_secondChosenAvtIdx != -1)
                  {
                     avatars.unshift(avatars[_secondChosenAvtIdx - 1]);
                     avatars.splice(_secondChosenAvtIdx,1);
                  }
                  avatars.unshift(newAvatar);
                  activeAvatarIdx = 0;
                  _switchIdx = 0;
                  _secondChosenAvtIdx = -1;
                  petInvId = int(data[asi++]);
                  myPet = PetManager.getMyPetByInvId(petInvId);
                  if(Boolean(AvatarManager.playerAvatarWorldView))
                  {
                     avatarWorldView = AvatarManager.playerAvatarWorldView;
                     avatarWorldView.setActivePet(Boolean(myPet) ? uint(myPet.lBits) : 0,Boolean(myPet) ? uint(myPet.uBits) : 0,Boolean(myPet) ? uint(myPet.eBits) : 0,Boolean(myPet) ? myPet.name : "");
                  }
                  PetManager.myActivePetInvId = petInvId;
                  newAvInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(sav.userName,sav.perUserAvId);
                  if(Boolean(newAvInfo))
                  {
                     sai.questLevel = int(data[asi++]);
                     sai.questHealthPercentage = newAvInfo.questHealthPercentage;
                     sai.healthBase = newAvInfo.healthBase;
                     sai.attackBase = newAvInfo.attackBase;
                     sai.attackMax = newAvInfo.attackMax;
                     sai.defenseBase = newAvInfo.defenseBase;
                     sai.defenseMax = newAvInfo.defenseMax;
                     gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(sav.perUserAvId,sai,true);
                     sav.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(sav.userName).getPartialItemList(sav.avTypeId,true));
                     avatarWorldView.updateNameBarLevelShape(sai.questLevel);
                  }
                  updateAvatarSlotIds();
               }
               else
               {
                  ItemXtCommManager.requestItemListForAvatar(null,sav,false,false);
                  if(Boolean(AvatarManager.buddyCardAvatarView) && sav.userName == AvatarManager.buddyCardAvatarView.userName)
                  {
                     BuddyCard.updateCurrBuddyCardAvatar(sav);
                  }
                  lBits = int(data[int(asi++)]);
                  uBits = int(data[int(asi++)]);
                  eBits = int(data[int(asi++)]);
                  petName = data[int(asi++)];
                  questLevel = int(data[asi++]);
                  avatarWorldView = AvatarManager.getAvatarWorldViewBySfsUserId(sfsUserId);
                  if(Boolean(avatarWorldView))
                  {
                     avatarWorldView.setActivePet(lBits,uBits,eBits,petName);
                  }
                  currPet = {
                     "name":petName,
                     "lBits":lBits,
                     "uBits":uBits,
                     "eBits":eBits
                  };
                  currPet.defId = PetManager.getDefIdFromLBits(currPet.lBits);
                  currPet.type = PetManager.petTypeForDefId(currPet.defId);
                  currPet.isGround = PetManager.isGround(currPet.type);
                  sai.currPet = currPet;
                  sai.questLevel = questLevel;
                  gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(sav.perUserAvId,sai,true);
                  avatarWorldView.updateNameBarLevelShape(sai.questLevel);
                  ble = new BuddyEvent(BuddyEvent.BUDDY_CHANGED);
                  ble.userName = sai.userName;
                  BuddyManager.eventDispatcher.dispatchEvent(ble);
               }
               AvatarWorldView(tf.parent).setPos(tf.parent.x,tf.parent.y,false);
               delete tf.data;
               if(_switchCallback != null)
               {
                  _switchCallback(true);
                  _switchCallback = null;
               }
            }
         }
         else if(tf.currentFrameLabel == "changeAvatar")
         {
            AvatarView(tf.parent).showAvatar();
         }
         else if(tf.currentFrameLabel == "tintOn")
         {
            savw = AvatarWorldView(tf.parent);
            if(savw.roomType == Utility.ENVIRO_LAND)
            {
               savw.setBlendColor(4290903190,7534606);
            }
            else
            {
               savw.setBlendColor(4294967295,16777107);
            }
         }
         else if(tf.currentFrameLabel == "tintOff")
         {
            etavw = AvatarWorldView(tf.parent);
            etavw.setBlendColor(0);
            etavw.setAlphaLevel(100);
            if(etavw.userId == playerSfsUserId)
            {
               AvatarManager.clearPlayerSplashColor();
            }
         }
         else if(tf.currentFrame == tf.totalFrames)
         {
            endTransformAnim(tf);
         }
      }
      
      private static function endTransformAnim(tf:MovieClip) : void
      {
         var etavw:AvatarView = AvatarView(tf.parent);
         if(tf.parent != null && etavw.avatarData != null)
         {
            DebugUtility.debugTrace("ending one of two transitions for sfsUserId:" + etavw.userId);
         }
         tf.removeEventListener(Event.ENTER_FRAME,transformEnterFrameHandler);
         var s:SoundTransform = tf.soundTransform;
         s.volume = 0;
         tf.soundTransform = s;
         tf.gotoAndStop(1);
         RoomXtCommManager.isSwitching = false;
         if(etavw.userName == gMainFrame.userInfo.myUserName && !QuestManager.isInPrivateAdventureState)
         {
            GuiManager.setSwapBtnGray(false);
         }
         if(tf.parent != null)
         {
            tf.parent.removeChild(tf);
         }
      }
      
      private static function updateAvatarSlotIds() : void
      {
         var currAvtSlotInfo:Object = null;
         var ourAvatarSlotInfo:Object = AvatarXtCommManager.avSlotInfo;
         for(var i:int = 0; i < avatars.length; i++)
         {
            if(Boolean(avatars[i]))
            {
               currAvtSlotInfo = ourAvatarSlotInfo[avatars[i].perUserAvId];
               if(Boolean(currAvtSlotInfo))
               {
                  currAvtSlotInfo.slotId = i;
               }
            }
         }
      }
   }
}

