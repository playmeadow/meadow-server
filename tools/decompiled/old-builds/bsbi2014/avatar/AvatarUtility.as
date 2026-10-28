package avatar
{
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.GuiManager;
   import gui.SharedAvatarAnimalConstants;
   import item.Item;
   import item.ItemXtCommManager;
   
   public class AvatarUtility
   {
      
      public static var avatarTypes:Array;
      
      public static var creationAvatars:Array;
      
      public static var avatarDefInfo:Array;
      
      public static var skippedIndexes:Array;
      
      private static var _avtMgrGetAvtByPerUserAvId:Function;
      
      private static var _numViewsLoaded:int;
      
      private static var _numNonMemberAvatars:Function;
      
      public static const AVT_AVAIL_HIDDEN:int = 0;
      
      public static const AVT_AVAIL_ACTIVE:int = 1;
      
      public static const AVT_AVAIL_ENDANGERED:int = 2;
      
      public static const AVT_AVAIL_EXTINCT:int = 3;
      
      public function AvatarUtility()
      {
         super();
      }
      
      public static function init(avtMgrGetAvtByperUserAvId:Function, numNonMemberAvatars:Function = null, avatarListFetchDoneCallback:Function = null, isFromWorld:Boolean = true) : void
      {
         var avatarListCallback:Function = null;
         _avtMgrGetAvtByPerUserAvId = avtMgrGetAvtByperUserAvId;
         _numNonMemberAvatars = numNonMemberAvatars;
         avatarListCallback = isFromWorld ? buildCreationAvatarViews : avatarListFetchDoneCallback;
         GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVATAR_LIST_ID,avatarListCallback,null,isFromWorld);
      }
      
      public static function buildCreationAvatarViews(cad:Array, isFromAccountCreation:Boolean = false) : void
      {
         var n:int = 0;
         var caAvatar:Avatar = null;
         var iAvType:int = 0;
         var niCount:int = 0;
         var caItem:Item = null;
         var caType:int = 0;
         var na:int = 0;
         var k:int = 0;
         var currAvDef:Object = null;
         var eyesDef:Object = null;
         var patternDef:Object = null;
         avatarTypes = [];
         skippedIndexes = [];
         var naCount:int = int(cad.length);
         var numSkipped:int = 0;
         if(Boolean(creationAvatars))
         {
            if(creationAvatars.length > 0)
            {
               for(k = 0; k < creationAvatars.length; k++)
               {
                  creationAvatars[k].destroy();
               }
            }
         }
         avatarDefInfo = new Array(naCount);
         creationAvatars = [];
         na = 0;
         n = 0;
         while(na < naCount)
         {
            currAvDef = gMainFrame.userInfo.getAvatarDefByAvType(cad[na]);
            if(Boolean(currAvDef))
            {
               if(isAvatarActive(currAvDef.availability) && (!isFromAccountCreation || isFromAccountCreation && !currAvDef.isMemOnly && !isExtinct(currAvDef.availability) && Utility.isLand(currAvDef.enviroTypeFlag)))
               {
                  iAvType = int(cad[na]);
                  avatarTypes[na - numSkipped] = iAvType;
                  avatarDefInfo[na - numSkipped] = {
                     "isMemberOnly":currAvDef.isMemOnly,
                     "enviroFlag":currAvDef.enviroTypeFlag,
                     "recycleValue":currAvDef.cost * 0.5,
                     "cost":(currAvDef.status == 2 ? currAvDef.cost * 0.5 : currAvDef.cost),
                     "availability":currAvDef.availability,
                     "status":currAvDef.status
                  };
                  caAvatar = new Avatar();
                  caAvatar.init(0,"",iAvType,[currAvDef.colorLayer1,currAvDef.colorLayer2,currAvDef.colorLayer3]);
                  eyesDef = ItemXtCommManager.getItemDef(currAvDef.defEyes);
                  patternDef = ItemXtCommManager.getItemDef(currAvDef.defPattern);
                  caItem = new Item();
                  caItem.init(1,n++,0,-1,-1);
                  caAvatar.inventoryBodyMod.addItem(caItem);
                  caAvatar.accStateShowAccessory(caItem);
                  caItem = new Item();
                  caItem.init(eyesDef.defId,n++,eyesDef.colors,-1,-1);
                  caAvatar.inventoryBodyMod.addItem(caItem);
                  caAvatar.accStateShowAccessory(caItem);
                  if(Boolean(patternDef))
                  {
                     caItem = new Item();
                     caItem.init(patternDef.defId,n++,patternDef.colors,-1,-1);
                     caAvatar.inventoryBodyMod.addItem(caItem);
                     caAvatar.accStateShowAccessory(caItem);
                  }
                  creationAvatars.push(caAvatar);
                  skippedIndexes[na] = false;
               }
               else
               {
                  skippedIndexes[na] = true;
                  numSkipped++;
               }
            }
            na++;
         }
      }
      
      public static function generateNew(perUserAvId:int, paramAvt:Avatar = null, paramUserName:String = null, sfsUserId:int = -1, roomType:int = 0, callback:Function = null) : Avatar
      {
         var avInfo:AvatarInfo = null;
         var avt:Avatar = null;
         if(paramAvt == null && _avtMgrGetAvtByPerUserAvId != null)
         {
            avt = _avtMgrGetAvtByPerUserAvId(paramUserName,perUserAvId);
         }
         if(!avt)
         {
            if(Boolean(paramAvt))
            {
               avt = paramAvt;
            }
            else
            {
               avt = new Avatar();
            }
            if(avt.userName == null)
            {
               if(paramUserName == null)
               {
                  throw new Error("avt and paramUserName are both null!!!");
               }
               avt.userName = paramUserName;
            }
            avInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(paramUserName,perUserAvId);
            if(Boolean(avInfo) && avInfo.type != -1)
            {
               avt.init(perUserAvId,avInfo.avName,avInfo.type,avInfo.colors,null,avInfo.userName,sfsUserId,roomType);
               getAvatarItemData(avt,callback,avInfo);
            }
            else
            {
               avt.init(perUserAvId,"tempAvt",-1,[0,0,0],null,avt.userName,sfsUserId);
               AvatarXtCommManager.requestADForAvatar(perUserAvId,true,callback,avt);
            }
         }
         return avt;
      }
      
      public static function getAvatarItemData(avt:Avatar, avitemCallback:Function = null, avInfo:AvatarInfo = null) : void
      {
         if(avt == null || avt.perUserAvId < 0)
         {
            throw new Error("Invalid avatar!");
         }
         if(avInfo == null)
         {
            avInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(avt.userName,avt.perUserAvId);
            if(avInfo == null)
            {
               throw new Error("Invalid avatar or avInfo!");
            }
         }
         var items:Array = avInfo.getItems(true);
         if(Boolean(items) && items.length > 0)
         {
            avt.itemResponseIntegrate(items);
         }
         else if(avt.avTypeId > 0)
         {
            ItemXtCommManager.requestItemListForAvatar(null,avt,avt.userName == gMainFrame.userInfo.myUserName ? !ItemXtCommManager.hasRequestedFullItemList : false);
         }
         else
         {
            AvatarXtCommManager.requestADForAvatar(avt.perUserAvId,true,avitemCallback,avt);
         }
      }
      
      public static function layerArrayForItemsAndColors(itemsArray:Array, colorsArray:Array, perUserAvId:int) : Array
      {
         var obj:Object = null;
         var color:uint = 0;
         var tempItem:Item = null;
         var layerArray:Array = [];
         for each(tempItem in itemsArray)
         {
            if(tempItem.getInUse(perUserAvId))
            {
               if(tempItem.layerId == 1)
               {
                  color = uint(colorsArray[0]);
               }
               else if(tempItem.layerId == 2)
               {
                  color = uint(colorsArray[1]);
               }
               else if(tempItem.layerId == 3)
               {
                  color = uint(colorsArray[2]);
               }
               else
               {
                  color = tempItem.color;
               }
               obj = {
                  "l":tempItem.accId,
                  "c":color
               };
               layerArray.push(obj);
            }
         }
         return layerArray;
      }
      
      public static function findAvDefIndexByType(type:int) : int
      {
         for(var i:int = 0; i < avatarTypes.length; i++)
         {
            if(Boolean(avatarTypes[i]) && avatarTypes[i] == type)
            {
               return i;
            }
         }
         return -1;
      }
      
      public static function findAvatarIndexByType(type:int) : int
      {
         for(var i:int = 0; i < creationAvatars.length; i++)
         {
            if(Boolean(creationAvatars[i]) && creationAvatars[i].avTypeId == type)
            {
               return i;
            }
         }
         return -1;
      }
      
      public static function findAvDefByType(type:int) : Object
      {
         var foundIndex:int = findAvDefIndexByType(type);
         if(foundIndex != -1)
         {
            return avatarDefInfo[foundIndex];
         }
         return null;
      }
      
      public static function numNonMemberAvatars() : int
      {
         if(_numNonMemberAvatars != null)
         {
            return _numNonMemberAvatars();
         }
         return 0;
      }
      
      private static function nameTypeScreenMouseDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
      }
      
      public static function getAvatarHudPosition(avTypeId:int) : Point
      {
         var xOffset:Number = NaN;
         var yOffset:Number = NaN;
         switch(avTypeId)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               xOffset = 228;
               yOffset = 220;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               xOffset = 213;
               yOffset = 318;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               xOffset = 226;
               yOffset = 217;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               xOffset = 228;
               yOffset = 220;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               xOffset = 225;
               yOffset = 215;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               xOffset = 228;
               yOffset = 216;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               xOffset = 231;
               yOffset = 216;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               xOffset = 230;
               yOffset = 216;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               xOffset = 222;
               yOffset = 216;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               xOffset = 230;
               yOffset = 216;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               xOffset = 222;
               yOffset = 213;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               xOffset = 216;
               yOffset = 250;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               xOffset = 222;
               yOffset = 245;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               xOffset = 232;
               yOffset = 216;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               xOffset = 232;
               yOffset = 220;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               xOffset = 225;
               yOffset = 237;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               xOffset = 223;
               yOffset = 217;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               xOffset = 221;
               yOffset = 249;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               xOffset = 220;
               yOffset = 215;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               xOffset = 216;
               yOffset = 218;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               xOffset = 222;
               yOffset = 222;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               xOffset = 220;
               yOffset = 223;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               xOffset = 220;
               yOffset = 212;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               xOffset = 220;
               yOffset = 215;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               xOffset = 220;
               yOffset = 212;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               xOffset = 225;
               yOffset = 220;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               xOffset = 225;
               yOffset = 220;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               xOffset = 227;
               yOffset = 220;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               xOffset = 221;
               yOffset = 218;
               break;
            default:
               xOffset = 225;
               yOffset = 200;
         }
         return new Point(xOffset,yOffset);
      }
      
      public static function getAvatarViewPosition(avTypeId:int) : Point
      {
         var offset:Point = new Point();
         switch(avTypeId)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               offset.x = 137;
               offset.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               offset.x = 120;
               offset.y = 150;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               offset.x = 136;
               offset.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               offset.x = 133;
               offset.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               offset.x = 131;
               offset.y = 90;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               offset.x = 136;
               offset.y = 95;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               offset.x = 140;
               offset.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               offset.x = 125;
               offset.y = 95;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               offset.x = 127;
               offset.y = 130;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               offset.x = 134;
               offset.y = 80;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               offset.x = 131;
               offset.y = 75;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               offset.x = 125;
               offset.y = 90;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               offset.x = 127;
               offset.y = 120;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               offset.x = 140;
               offset.y = 100;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               offset.x = 130;
               offset.y = 100;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               offset.x = 125;
               offset.y = 117;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               offset.x = 129;
               offset.y = 95;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               offset.x = 128;
               offset.y = 95;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               offset.x = 124;
               offset.y = 110;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               offset.x = 123;
               offset.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               offset.x = 129;
               offset.y = 99;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               offset.x = 127;
               offset.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               offset.x = 127;
               offset.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               offset.x = 127;
               offset.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               offset.x = 127;
               offset.y = 110;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               offset.x = 130;
               offset.y = 100;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               offset.x = 140;
               offset.y = 100;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               offset.x = 134;
               offset.y = 97;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               offset.x = 130;
               offset.y = 97;
               break;
            default:
               offset.x = 112;
               offset.y = 140;
         }
         return offset;
      }
      
      public static function getAvatarChatOffset(avTypeId:int) : Point
      {
         var p:Point = new Point();
         if(GuiManager.isBeYourPetRoom())
         {
            if(Boolean(AvatarManager.playerAvatarWorldView))
            {
               p.x = 10;
               p.y = -80;
            }
            else
            {
               p.x = 10;
               p.y = -90;
            }
         }
         else
         {
            switch(avTypeId)
            {
               case SharedAvatarAnimalConstants.AV_TIGER:
                  p.x = 10;
                  p.y = -70;
                  break;
               case SharedAvatarAnimalConstants.AV_EAGLE:
                  p.x = 10;
                  p.y = -130;
                  break;
               case SharedAvatarAnimalConstants.AV_WOLF:
                  p.x = 5;
                  p.y = -80;
                  break;
               case SharedAvatarAnimalConstants.AV_KOALA:
                  p.x = -25;
                  p.y = -75;
                  break;
               case SharedAvatarAnimalConstants.AV_PANDA:
                  p.x = -15;
                  p.y = -85;
                  break;
               case SharedAvatarAnimalConstants.AV_MONKEY:
                  p.x = -25;
                  p.y = -75;
                  break;
               case SharedAvatarAnimalConstants.AV_BUNNY:
                  p.x = -25;
                  p.y = -75;
                  break;
               case SharedAvatarAnimalConstants.AV_RHINO:
                  p.x = -10;
                  p.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_CROC:
                  p.x = -10;
                  p.y = -90;
                  break;
               case SharedAvatarAnimalConstants.AV_ELEPHANT:
                  p.x = -10;
                  p.y = -105;
                  break;
               case SharedAvatarAnimalConstants.AV_SEAL:
                  p.x = -15;
                  p.y = -60;
                  break;
               case SharedAvatarAnimalConstants.AV_DOLPHIN:
                  p.x = -10;
                  p.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_SHARK:
                  p.x = -15;
                  p.y = -88;
                  break;
               case SharedAvatarAnimalConstants.AV_LION:
                  p.x = -15;
                  p.y = -90;
                  break;
               case SharedAvatarAnimalConstants.AV_HORSE:
                  p.x = -20;
                  p.y = -104;
                  break;
               case SharedAvatarAnimalConstants.AV_TURTLE:
                  p.x = -10;
                  p.y = -75;
                  break;
               case SharedAvatarAnimalConstants.AV_PENGUIN:
                  p.x = -16;
                  p.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_OCTOPUS:
                  p.x = -25;
                  p.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_GIRAFFE:
                  p.x = -17;
                  p.y = -130;
                  break;
               case SharedAvatarAnimalConstants.AV_FOX:
                  p.x = -17;
                  p.y = -88;
                  break;
               case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
                  p.x = -7;
                  p.y = -113;
                  break;
               case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
                  p.x = -7;
                  p.y = -99;
                  break;
               case SharedAvatarAnimalConstants.AV_RACCOON:
                  p.x = -2;
                  p.y = -58;
                  break;
               case SharedAvatarAnimalConstants.AV_CHEETAH:
                  p.x = 0;
                  p.y = -80;
                  break;
               case SharedAvatarAnimalConstants.AV_KANGAROO:
                  p.x = -2;
                  p.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_DEER:
                  p.x = -2;
                  p.y = -135;
                  break;
               case SharedAvatarAnimalConstants.AV_HYENA:
                  p.x = -5;
                  p.y = -85;
                  break;
               case SharedAvatarAnimalConstants.AV_OTTER:
                  p.x = -10;
                  p.y = -83;
                  break;
               case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
                  p.x = -5;
                  p.y = -100;
                  break;
               default:
                  p.x = -25;
                  p.y = -75;
            }
         }
         return p;
      }
      
      public static function getAvatarEmoteBgOffset(avTypeId:int) : Point
      {
         var p:Point = new Point();
         if(GuiManager.isBeYourPetRoom())
         {
            if(Boolean(AvatarManager.playerAvatarWorldView))
            {
               p.x = -5;
               p.y = -25;
            }
            else
            {
               p.x = -5;
               p.y = -35;
            }
         }
         else
         {
            switch(avTypeId)
            {
               case SharedAvatarAnimalConstants.AV_TIGER:
                  p.x = -5;
                  p.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_EAGLE:
                  p.x = -5;
                  p.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_WOLF:
                  p.x = -5;
                  p.y = -45;
                  break;
               case SharedAvatarAnimalConstants.AV_KOALA:
                  p.x = 8;
                  p.y = -40;
                  break;
               case SharedAvatarAnimalConstants.AV_PANDA:
                  p.x = 5;
                  p.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_MONKEY:
                  p.x = -5;
                  p.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_BUNNY:
                  p.x = -5;
                  p.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_RHINO:
                  p.x = -10;
                  p.y = -25;
                  break;
               case SharedAvatarAnimalConstants.AV_CROC:
                  p.x = 5;
                  p.y = -15;
                  break;
               case SharedAvatarAnimalConstants.AV_ELEPHANT:
                  p.x = 5;
                  p.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_SEAL:
                  p.x = 0;
                  p.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_DOLPHIN:
                  p.x = 0;
                  p.y = -20;
                  break;
               case SharedAvatarAnimalConstants.AV_SHARK:
                  p.x = 0;
                  p.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_LION:
                  p.x = 0;
                  p.y = -45;
                  break;
               case SharedAvatarAnimalConstants.AV_HORSE:
                  p.x = 5;
                  p.y = -37;
                  break;
               case SharedAvatarAnimalConstants.AV_TURTLE:
               case SharedAvatarAnimalConstants.AV_PENGUIN:
                  p.x = 0;
                  p.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_OCTOPUS:
                  p.x = -5;
                  p.y = -55;
                  break;
               case SharedAvatarAnimalConstants.AV_GIRAFFE:
                  p.x = 5;
                  p.y = -42;
                  break;
               case SharedAvatarAnimalConstants.AV_FOX:
                  p.x = 10;
                  p.y = -33;
                  break;
               case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
                  p.x = -1;
                  p.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
                  p.x = -1;
                  p.y = -15;
                  break;
               case SharedAvatarAnimalConstants.AV_RACCOON:
                  p.x = -8;
                  p.y = -24;
                  break;
               case SharedAvatarAnimalConstants.AV_CHEETAH:
                  p.x = -6;
                  p.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_KANGAROO:
                  p.x = -8;
                  p.y = -28;
                  break;
               case SharedAvatarAnimalConstants.AV_DEER:
                  p.x = -8;
                  p.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_HYENA:
                  p.x = -5;
                  p.y = -33;
                  break;
               case SharedAvatarAnimalConstants.AV_OTTER:
                  p.x = -10;
                  p.y = -33;
                  break;
               case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
                  p.x = -10;
                  p.y = -33;
                  break;
               default:
                  p.x = -5;
                  p.y = -45;
            }
         }
         return p;
      }
      
      public static function getAnimalItemWindowOffset(avTypeId:int) : Point
      {
         var p:Point = new Point();
         switch(avTypeId)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               p.x = 123;
               p.y = 34;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               p.x = 90;
               p.y = 135;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               p.x = 134;
               p.y = 45;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               p.x = 127;
               p.y = 58;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               p.x = 124;
               p.y = 50;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               p.x = 133;
               p.y = 54;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               p.x = 138;
               p.y = 65;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               p.x = 120;
               p.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               p.x = 133;
               p.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               p.x = 125;
               p.y = 52;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               p.x = 127;
               p.y = 38;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               p.x = 125;
               p.y = 75;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               p.x = 128;
               p.y = 80;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               p.x = 135;
               p.y = 60;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               p.x = 135;
               p.y = 75;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               p.x = 120;
               p.y = 67;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               p.x = 127;
               p.y = 62;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               p.x = 122;
               p.y = 62;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               p.x = 122;
               p.y = 78;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               p.x = 127;
               p.y = 72;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               p.x = 127;
               p.y = 90;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               p.x = 127;
               p.y = 90;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               p.x = 114;
               p.y = 98;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               p.x = 122;
               p.y = 70;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               p.x = 128;
               p.y = 65;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               p.x = 132;
               p.y = 70;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               p.x = 145;
               p.y = 70;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               p.x = 130;
               p.y = 68;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               p.x = 125;
               p.y = 68;
               break;
            default:
               p.x = 120;
               p.y = 50;
         }
         return p;
      }
      
      public static function getTalkingHeadOffset(avTypeId:int) : Point
      {
         var offset:Point = new Point();
         var _loc3_:int = avTypeId;
         switch(0)
         {
         }
         offset.x = 112;
         offset.y = 140;
         return offset;
      }
      
      public static function getAvatarPhotoOffset(avTypeId:int) : Point
      {
         var offset:Point = new Point();
         switch(avTypeId)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               offset.x = -150;
               offset.y = -160;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               offset.x = -195;
               offset.y = -60;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               offset.x = -155;
               offset.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               offset.x = -152;
               offset.y = -140;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               offset.x = -130;
               offset.y = -158;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               offset.x = -140;
               offset.y = -175;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               offset.x = -145;
               offset.y = -192;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               offset.x = -160;
               offset.y = -155;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               offset.x = -165;
               offset.y = -125;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               offset.x = -162;
               offset.y = -148;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               offset.x = -107;
               offset.y = -140;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               offset.x = -160;
               offset.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               offset.x = -160;
               offset.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               offset.x = -155;
               offset.y = -150;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               offset.x = -130;
               offset.y = -185;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               offset.x = -160;
               offset.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               offset.x = -162;
               offset.y = -180;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               offset.x = -160;
               offset.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               offset.x = -140;
               offset.y = -160;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               offset.x = -165;
               offset.y = -175;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               offset.x = -150;
               offset.y = -165;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               offset.x = -145;
               offset.y = -180;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               offset.x = -140;
               offset.y = -165;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               offset.x = -135;
               offset.y = -145;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               offset.x = -145;
               offset.y = -160;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               offset.x = -145;
               offset.y = -160;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               offset.x = -130;
               offset.y = -130;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               offset.x = -125;
               offset.y = -175;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               offset.x = -125;
               offset.y = -155;
               break;
            default:
               offset.x = -160;
               offset.y = -190;
         }
         return offset;
      }
      
      public static function getAvatarMinigameLobbyOffset(avTypeId:int) : Point
      {
         var offset:Point = new Point(0,0);
         switch(avTypeId)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
            case SharedAvatarAnimalConstants.AV_WOLF:
               offset.x = 160;
               offset.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               offset.x = 150;
               offset.y = 220;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
            case SharedAvatarAnimalConstants.AV_PANDA:
               offset.x = 158;
               offset.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               offset.x = 157;
               offset.y = 148;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               offset.x = 162;
               offset.y = 149;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
            case SharedAvatarAnimalConstants.AV_CROC:
               offset.x = 160;
               offset.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               offset.x = 155;
               offset.y = 165;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               offset.x = 153;
               offset.y = 150;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               offset.x = 148;
               offset.y = 173;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               offset.x = 153;
               offset.y = 170;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
            case SharedAvatarAnimalConstants.AV_HORSE:
               offset.x = 162;
               offset.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               offset.x = 155;
               offset.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               offset.x = 155;
               offset.y = 150;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               offset.x = 153;
               offset.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               offset.x = 155;
               offset.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               offset.x = 155;
               offset.y = 155;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               offset.x = 152;
               offset.y = 155;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               offset.x = 154;
               offset.y = 148;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               offset.x = 152;
               offset.y = 155;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
            case SharedAvatarAnimalConstants.AV_HYENA:
               offset.x = 158;
               offset.y = 155;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               offset.x = 153;
               offset.y = 172;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               offset.x = 159;
               offset.y = 150;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               offset.x = 152;
               offset.y = 152;
               break;
            default:
               offset.x = 160;
               offset.y = 152;
         }
         return offset;
      }
      
      public static function isAvatarActive(availability:int) : Boolean
      {
         if(availability > AVT_AVAIL_HIDDEN)
         {
            return true;
         }
         return false;
      }
      
      public static function isEndangered(availability:int) : Boolean
      {
         if(availability == AVT_AVAIL_ENDANGERED)
         {
            return true;
         }
         return false;
      }
      
      public static function isExtinct(availability:int) : Boolean
      {
         if(availability == AVT_AVAIL_EXTINCT)
         {
            return true;
         }
         return false;
      }
   }
}

