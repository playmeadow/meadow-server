package Party
{
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBStandardPopup;
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class PartyManager
   {
      
      public static const RESTRICTIONS_NONE:int = 0;
      
      public static const RESTRICTIONS_AVATAR:int = 1;
      
      public static const RESTRICTIONS_MEMBERONLY:int = 2;
      
      public static const RESTRICTIONS_PET:int = 4;
      
      public static const RESTRICTIONS_BEYOURPET:int = 8;
      
      private static const PARTY_POPUP_MEDIA_ID:int = 1215;
      
      private static const PARTY_BARRIER_MEDIA_ID:int = 1299;
      
      private static var _partyDefs:Object;
      
      private static var _partyPopup:PartyPopup;
      
      private static var _partyBarrier:MovieClip;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _timeOffset:int;
      
      public function PartyManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _timeOffset = Math.abs(RoomManagerWorld.instance.shardId) * 10 % 60;
         requestPartyDefs(null);
      }
      
      public static function openPartyPopup() : void
      {
         if(_partyPopup)
         {
            _partyPopup.destroy();
         }
         _partyPopup = new PartyPopup(onPartyPopupClose,_timeOffset);
      }
      
      public static function showPartyPopup(param1:Boolean) : void
      {
         if(_partyPopup)
         {
            _partyPopup.showPopup(param1);
         }
         else
         {
            openPartyPopup();
         }
      }
      
      public static function closePartyPopup(param1:Boolean = false) : void
      {
         if(param1 && _partyPopup)
         {
            _partyPopup.showPopup(false);
         }
         else
         {
            onPartyPopupClose();
         }
      }
      
      public static function updateTime(param1:int) : void
      {
         if(_partyPopup)
         {
            _partyPopup.updateTime(param1);
         }
      }
      
      public static function get partyDefs() : Object
      {
         return _partyDefs;
      }
      
      public static function getPartyDef(param1:int) : Object
      {
         return _partyDefs[param1];
      }
      
      public static function roomSoireeResponse(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 2;
         if(param1[_loc3_++] == "0")
         {
            _loc2_ = param1[_loc3_++];
            RoomXtCommManager.loadingNewRoom = false;
            if(_loc2_ == "NM")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14779));
            }
            else if(_loc2_ == "NA")
            {
               showPartyBarrier(false,false,param1[_loc3_++]);
            }
            else if(_loc2_ == "NP")
            {
               DarkenManager.showLoadingSpiral(false);
               showPartyBarrier(false,false,param1[_loc3_++]);
            }
         }
      }
      
      public static function partyListResponse(param1:Object) : void
      {
         if(_partyPopup)
         {
            _partyPopup.partyListResponse(param1);
         }
      }
      
      public static function customPartyListResponse(param1:Object) : void
      {
         if(_partyPopup)
         {
            _partyPopup.customPartyListResponse(param1);
         }
      }
      
      public static function customPartyCreateResponse(param1:Object) : void
      {
         var _loc2_:UserInfo = null;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 2;
         var _loc6_:Boolean = param1[_loc5_++] == "1";
         if(_loc6_)
         {
            _loc3_ = param1[_loc5_++] == "1";
            if(_loc3_)
            {
               _loc2_ = gMainFrame.userInfo.playerUserInfo;
               if(_loc2_)
               {
                  _loc2_.timeLeftHostingCustomParty = int(param1[_loc5_++]);
                  gMainFrame.userInfo.playerUserInfo = _loc2_;
                  AvatarManager.updateCustomPartyHostingDataForMyself();
               }
            }
         }
         else
         {
            _loc2_ = gMainFrame.userInfo.playerUserInfo;
            if(_loc2_)
            {
               _loc2_.timeLeftHostingCustomParty = -1;
               gMainFrame.userInfo.playerUserInfo = _loc2_;
               AvatarManager.updateCustomPartyHostingDataForMyself();
            }
            switch(param1[_loc5_++])
            {
               case "ND":
                  _loc4_ = 24247;
                  break;
               case "EXISTS":
                  _loc4_ = 24249;
                  break;
               case "NM":
                  _loc4_ = 24236;
                  break;
               case "INV":
               case "NR":
               case "DIS":
               default:
                  _loc4_ = 24248;
            }
            onPartyPopupClose(true);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(_loc4_));
         }
      }
      
      public static function customPartyJoinResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 2;
         var _loc4_:Boolean = param1[_loc3_++] == "1";
         if(!_loc4_)
         {
            switch(param1[_loc3_++])
            {
               case "NPP":
               case "BLK":
               case "DIS":
                  _loc2_ = 24251;
                  break;
               default:
                  _loc2_ = 24251;
            }
            onPartyPopupClose(true);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(_loc2_));
         }
      }
      
      public static function customPartyIsHostingResponse(param1:Object, param2:String, param3:Function) : void
      {
         var _loc4_:UserInfo = null;
         var _loc5_:int = int(param1[2]);
         if(param2 != null && param2 != "")
         {
            _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(param2);
            if(_loc4_)
            {
               _loc4_.timeLeftHostingCustomParty = _loc5_;
            }
         }
         if(param3 != null)
         {
            param3(_loc5_,_loc4_);
         }
      }
      
      public static function customPartyKillResponse(param1:Object) : void
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.playerUserInfo;
         if(_loc2_)
         {
            _loc2_.timeLeftHostingCustomParty = -1;
            gMainFrame.userInfo.playerUserInfo = _loc2_;
            AvatarManager.updateCustomPartyHostingDataForMyself();
         }
         onPartyPopupClose(true);
         var _loc3_:int = int(param1[2]);
         Utility.setupDiamondRefundPopup(GuiManager.guiLayer,_loc3_,null);
         UserCurrency.setCurrency(UserCurrency.getCurrency(3) + _loc3_,3);
      }
      
      public static function requestPartyDefs(param1:Function) : void
      {
         var _loc2_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc2_.init(1047,onPartyDataResponse,param1,2);
         DefPacksDefHelper.mediaArray[1047] = _loc2_;
      }
      
      public static function sendCustomPartyJoin(param1:String, param2:String, param3:String) : void
      {
         DarkenManager.showLoadingSpiral(true);
         if(param3 == null)
         {
            PartyXtCommManager.sendCustomPartyNodeId(param1,param2,onGetPartyNodeId);
         }
         else if(param3 == gMainFrame.server.serverIp)
         {
            PartyXtCommManager.sendCustomPartyJoinRequest(param2);
         }
         else
         {
            gMainFrame.clientInfo.autoStartRoom = param2;
            gMainFrame.clientInfo.autoStartRoomShardId = -4;
            DebugUtility.debugTrace("using autoStartRoom to prep resend custom party join request after switching server nodes - customPartyCreatorUUID:" + gMainFrame.clientInfo.autoStartRoom + " autoStartRoomShardId:" + gMainFrame.clientInfo.autoStartRoomShardId);
            if(!gMainFrame.switchServersIfNeeded(param3))
            {
               new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14835),false);
               return;
            }
         }
      }
      
      public static function isBeYourPetParty() : Boolean
      {
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc1_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc1_ != null && _loc1_.restrictions == 8)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function canSwitchToAvatar(param1:Avatar, param2:Boolean = false) : Boolean
      {
         var _loc3_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc3_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc3_ != null)
            {
               if(_loc3_.restrictions == 1)
               {
                  if((_loc3_.avatarDefFlags & 1 << param1.avTypeId - 1) == 0)
                  {
                     if(param2)
                     {
                        showPartyBarrier(true);
                     }
                     return false;
                  }
               }
               else if(_loc3_.restrictions == 4)
               {
                  if(!PetManager.checkIfHasPet(param1.enviroTypeFlag))
                  {
                     if(param2)
                     {
                        showPartyBarrier(true,true);
                     }
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      public static function canSwitchPet(param1:Boolean = false) : Boolean
      {
         var _loc2_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc2_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc2_ != null && (_loc2_.restrictions == 4 || _loc2_.restrictions == 8))
            {
               if(param1)
               {
                  showPartyBarrier(true);
               }
               return false;
            }
         }
         return true;
      }
      
      public static function showPartyBarrier(param1:Boolean = false, param2:Boolean = false, param3:int = -1) : void
      {
         var _loc4_:Object = null;
         if(param3 == -1)
         {
            param3 = int(gMainFrame.clientInfo.secondaryDefId);
         }
         if(_partyBarrier)
         {
            _loc4_ = _partyDefs[param3];
            if(_loc4_ != null)
            {
               if(int(_loc4_.restrictions) == 4 || int(_loc4_.restrictions) == 8)
               {
                  setupBarrierTextForPets({
                     "isTryingToSwitch":param1,
                     "doesNotHaveRequiredPet":param2
                  });
               }
               else
               {
                  onAvatarNameLocalization(_loc4_.avatarDefFlags,param1);
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(1299,onMediaItemLoaded,{
               "isTryingToSwitch":param1,
               "doesNotHaveRequiredPet":param2,
               "secondaryDefId":param3
            });
         }
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onBarrierClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_partyBarrier);
         _partyBarrier.visible = false;
      }
      
      private static function onPartyDataResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[1047] = null;
         _partyDefs = param1.def;
         if(param1.passback != null)
         {
            param1.passback();
         }
      }
      
      private static function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = null;
         if(param1)
         {
            _partyBarrier = MovieClip(param1.getChildAt(0));
            _partyBarrier.addEventListener("mouseDown",onPopup,false,0,true);
            _partyBarrier.bx.addEventListener("mouseDown",onBarrierClose,false,0,true);
            _partyBarrier.x = 900 * 0.5;
            _partyBarrier.y = 550 * 0.5;
            _partyBarrier.visible = false;
            GuiManager.guiLayer.addChild(_partyBarrier);
            _loc2_ = _partyDefs[param1.passback.secondaryDefId];
            if(_loc2_ != null)
            {
               if(int(_loc2_.restrictions) == 4 || int(_loc2_.restrictions) == 8)
               {
                  setupBarrierTextForPets(param1.passback);
               }
               else
               {
                  onAvatarNameLocalization(_loc2_.avatarDefFlags,param1.passback.isTryingToSwitch);
               }
            }
         }
      }
      
      private static function onPartyPopupClose(param1:Boolean = false) : void
      {
         if(_partyPopup)
         {
            _partyPopup.destroy(param1);
            _partyPopup = null;
         }
      }
      
      private static function onAvatarNameLocalization(param1:Number, param2:Object = null) : void
      {
         var _loc5_:String = param1.toString(2);
         var _loc3_:int = _loc5_.length - 1;
         _loc3_;
         while(_loc3_ >= 0)
         {
            if(_loc5_.charAt(_loc3_) == "1")
            {
               _loc3_ = _loc5_.length - 1 - _loc3_ + 1;
               break;
            }
            _loc3_--;
         }
         var _loc4_:String = "Avatar" + _loc3_;
         if(_partyBarrier.currentFrameLabel != _loc4_)
         {
            _partyBarrier.gotoAndStop(_loc4_);
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(param2)
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/member/switch");
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/member");
            }
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/barrier/#" + _loc4_ + "/nonMember");
         }
         DarkenManager.showLoadingSpiral(false);
         _partyBarrier.parent.setChildIndex(_partyBarrier,_partyBarrier.parent.numChildren - 1);
         DarkenManager.darken(_partyBarrier);
         _partyBarrier.visible = true;
      }
      
      private static function setupBarrierTextForPets(param1:Object = null) : void
      {
         if(_partyBarrier.currentFrameLabel != "Pets")
         {
            _partyBarrier.gotoAndStop("Pets");
         }
         if(param1)
         {
            if(param1.doesNotHaveRequiredPet)
            {
               LocalizationManager.translateId(_partyBarrier.Message_txt,18790);
            }
            else
            {
               LocalizationManager.translateId(_partyBarrier.Message_txt,11407);
            }
         }
         else if(AvatarManager.roomEnviroType == 1)
         {
            LocalizationManager.translateId(_partyBarrier.Message_txt,11366);
         }
         else
         {
            LocalizationManager.translateId(_partyBarrier.Message_txt,11367);
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(param1)
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#petParty/member/switch");
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/barrier/#petParty/member");
            }
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/barrier/#petParty/nonMember");
         }
         DarkenManager.showLoadingSpiral(false);
         _partyBarrier.parent.setChildIndex(_partyBarrier,_partyBarrier.parent.numChildren - 1);
         DarkenManager.darken(_partyBarrier);
         _partyBarrier.visible = true;
      }
      
      private static function onGetPartyNodeId(param1:String, param2:Object) : void
      {
         if(param2[2] == "1")
         {
            sendCustomPartyJoin(param1,param2[3],param2[4]);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
   }
}

