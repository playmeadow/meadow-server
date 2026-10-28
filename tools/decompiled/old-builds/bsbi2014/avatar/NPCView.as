package avatar
{
   import com.sbi.graphics.LayerAnim;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Linear;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   
   public class NPCView extends Sprite
   {
      
      public static const NPC_STATE_LOADING:int = -2;
      
      public static const NPC_STATE_LOADED:int = -1;
      
      public static const NPC_STATE_IDLE:int = 0;
      
      public static const NPC_STATE_MOVE:int = 1;
      
      public static const NPC_STATE_ATTACK:int = 2;
      
      public static const NPC_STATE_RECOIL:int = 3;
      
      public static const NPC_STATE_DEATH:int = 4;
      
      public static const NPC_STATE_TREASURE_APPEAR:int = 5;
      
      public static const NPC_STATE_TREASURE_OPEN:int = 6;
      
      public static const NPC_STATE_TREASURE_DISAPPEAR:int = 7;
      
      public static const NPC_STATE_DANCE:int = 8;
      
      private var _npcDef:Object;
      
      private var _npcMC:MovieClip;
      
      private var _npcAvatarView:AvatarWorldView;
      
      private var _playerId:int;
      
      private var _namebar:NameBar;
      
      private var _mediaHelperObj:MediaHelper;
      
      private var _onLoadingCompleteCallback:Function;
      
      private var _npcState:int;
      
      private var _npcAngle:int;
      
      private var _healthBar:MovieClip;
      
      private var _hitText:TextField;
      
      private var _hitTextTween:GTween;
      
      private var _secondaryNpcMC:MovieClip;
      
      public var _eye:MovieClip;
      
      public var _beam:MovieClip;
      
      public var _npcFacingSW:Boolean;
      
      public function NPCView()
      {
         super();
      }
      
      public function get npcState() : int
      {
         return this._npcState;
      }
      
      public function get npcStateComplete() : Boolean
      {
         switch(this._npcState)
         {
            case NPC_STATE_LOADING:
               return false;
            case NPC_STATE_LOADED:
               return true;
            case NPC_STATE_TREASURE_APPEAR:
            case NPC_STATE_TREASURE_OPEN:
            case NPC_STATE_TREASURE_DISAPPEAR:
               return this._npcMC == null || Boolean(this._npcMC.finished);
            default:
               throw new Error("NPVView: npcStateComplete: Unsupported state");
         }
      }
      
      public function get readyToLaunchAttack() : Boolean
      {
         if(this._npcState == NPC_STATE_ATTACK)
         {
            if(this._npcMC != null)
            {
               if(this._npcMC.attacking == true)
               {
                  this._npcMC.attacking = false;
                  return true;
               }
               if(this._npcMC.hasOwnProperty("counterAttacking") && this._npcMC.counterAttacking == true)
               {
                  this._npcMC.counterAttacking = false;
                  return true;
               }
            }
            return false;
         }
         return true;
      }
      
      public function get readyToAttack() : Boolean
      {
         var customCollisionPoints:Array = null;
         var colPointIndex:int = 0;
         var colPoint:Object = null;
         if(this._npcMC != null && this._npcMC.hasOwnProperty("getCustomCollisionPoints"))
         {
            customCollisionPoints = this._npcMC.getCustomCollisionPoints();
            if(customCollisionPoints != null)
            {
               for(colPointIndex = 0; colPointIndex < customCollisionPoints.length; colPointIndex++)
               {
                  colPoint = customCollisionPoints[colPointIndex];
                  if(colPoint.Type == 2)
                  {
                     return !this._npcMC.animActive && Boolean(this._npcMC.readyForAttack);
                  }
               }
            }
         }
         if(this._npcState != NPC_STATE_ATTACK && this._npcState != NPC_STATE_DEATH)
         {
            return true;
         }
         return false;
      }
      
      public function get isDead() : Boolean
      {
         if(this._npcState == NPC_STATE_DEATH && (this._npcMC == null || this._npcMC.animActive == false))
         {
            return true;
         }
         return false;
      }
      
      public function get isDying() : Boolean
      {
         return this._npcState == NPC_STATE_DEATH;
      }
      
      public function moveFaceAnim(inAngle:Number) : void
      {
         var animDir:int = 0;
         var animFlip:Boolean = false;
         if(Boolean(this._npcAvatarView))
         {
            animDir = 0;
            for(animFlip = false; inAngle < 0; )
            {
               inAngle += 360;
            }
            while(inAngle >= 360)
            {
               inAngle -= 360;
            }
            if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
            {
               if(inAngle < 180)
               {
                  if(inAngle < 35)
                  {
                     animDir = LayerAnim.AN_MOVE_NNE;
                  }
                  else if(inAngle < 70)
                  {
                     animDir = LayerAnim.AN_MOVE_NE;
                  }
                  else if(inAngle < 110)
                  {
                     animDir = LayerAnim.AN_MOVE_E;
                  }
                  else if(inAngle < 145)
                  {
                     animDir = LayerAnim.AN_MOVE_SE;
                  }
                  else
                  {
                     animDir = LayerAnim.AN_MOVE_SSE;
                  }
               }
               else
               {
                  animFlip = true;
                  if(inAngle < 215)
                  {
                     animDir = LayerAnim.AN_MOVE_SSE;
                  }
                  else if(inAngle < 250)
                  {
                     animDir = LayerAnim.AN_MOVE_SE;
                  }
                  else if(inAngle < 290)
                  {
                     animDir = LayerAnim.AN_MOVE_E;
                  }
                  else if(inAngle < 325)
                  {
                     animDir = LayerAnim.AN_MOVE_NE;
                  }
                  else
                  {
                     animDir = LayerAnim.AN_MOVE_NNE;
                  }
               }
            }
            else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
            {
               if(inAngle < 180)
               {
                  animDir = LayerAnim.AN_SWIM_E;
               }
               else
               {
                  animFlip = true;
                  animDir = LayerAnim.AN_SWIM_E;
               }
            }
            this._npcAvatarView.playAnim(animDir,animFlip,LayerAnim.PLAY_LOOP__KEEP_CURRENT_FRAME);
         }
      }
      
      public function setNpcState(inState:int, inAngle:Number = 0) : void
      {
         if(this._npcState != NPC_STATE_DEATH)
         {
            switch(inState)
            {
               case NPC_STATE_TREASURE_APPEAR:
                  if(Boolean(this._npcMC))
                  {
                     this._npcMC.appear();
                     this._npcState = inState;
                  }
                  break;
               case NPC_STATE_TREASURE_OPEN:
                  if(Boolean(this._npcMC))
                  {
                     this._npcMC.openChest();
                     this._npcState = inState;
                  }
                  break;
               case NPC_STATE_TREASURE_DISAPPEAR:
                  if(Boolean(this._npcMC))
                  {
                     this._npcMC.disappear();
                     this._npcState = inState;
                  }
                  break;
               case NPC_STATE_DEATH:
                  if(Boolean(this._npcMC))
                  {
                     this._npcState = inState;
                     this._npcMC.noHealth();
                  }
                  break;
               case NPC_STATE_IDLE:
                  if(Boolean(this._npcMC))
                  {
                     if(this._npcMC.animActive == false)
                     {
                        this._npcState = inState;
                        this._npcMC.idle(270);
                     }
                     if(this._npcMC.hasOwnProperty("getSortHeight"))
                     {
                        if(Boolean(this._npcMC.parent.parent))
                        {
                           this._npcMC.parent.parent.name = this._npcMC.getSortHeight();
                        }
                     }
                  }
                  else if(Boolean(this._npcAvatarView))
                  {
                     if(this._npcState != inState)
                     {
                        if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
                        {
                           this.playAnimationState(LayerAnim.AN_IDLE_SE,false,LayerAnim.PLAY_LOOP,null);
                        }
                        else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
                        {
                           this.playAnimationState(LayerAnim.AN_FLOAT,false,LayerAnim.PLAY_LOOP,null);
                        }
                        this._npcState = inState;
                     }
                  }
                  break;
               case NPC_STATE_MOVE:
                  if(this._npcAvatarView != null)
                  {
                     this._npcState = inState;
                     if(this._npcAngle != inAngle)
                     {
                        this._npcAngle = inAngle;
                        this.moveFaceAnim(this._npcAngle);
                     }
                  }
                  else if(this._npcMC != null)
                  {
                     this._npcAngle = inAngle;
                     if(this._npcMC.animActive == false)
                     {
                        this._npcState = inState;
                        this._npcMC.moveCycle(this._npcAngle);
                     }
                  }
                  break;
               case NPC_STATE_ATTACK:
                  if(this._npcMC != null)
                  {
                     this._npcState = inState;
                     this._npcAngle = inAngle;
                     this._npcMC.attack(this._npcAngle);
                  }
                  break;
               case NPC_STATE_RECOIL:
                  if(this._npcMC != null)
                  {
                     if(this._npcState != NPC_STATE_RECOIL || this._npcMC.hasOwnProperty("animActive") == false || this._npcMC.animActive == false)
                     {
                        if(this._npcState == NPC_STATE_IDLE || this._npcState == NPC_STATE_MOVE)
                        {
                           this._npcState = inState;
                        }
                        this._npcMC.recoil(this._npcAngle);
                     }
                  }
                  break;
               case NPC_STATE_DANCE:
                  if(this._npcAvatarView != null)
                  {
                     this._npcState = inState;
                     if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
                     {
                        this.playAnimationState(LayerAnim.AN_DANCE,false,LayerAnim.PLAY_LOOP,null);
                     }
                     else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
                     {
                        this.playAnimationState(LayerAnim.AN_WATER_JIG,false,LayerAnim.PLAY_LOOP,null);
                     }
                  }
            }
         }
      }
      
      public function get collisionZapRadius() : Number
      {
         if(this._npcMC != null)
         {
            return this._npcMC.getCollisionRadius(0);
         }
         return 20;
      }
      
      public function get collisionRadiusMoving() : Number
      {
         if(this._npcMC != null)
         {
            if("getCollisionRadius" in this._npcMC)
            {
               return this._npcMC.getCollisionRadius(1);
            }
         }
         return 20;
      }
      
      public function get collisionRadiusAttack() : Number
      {
         if(this._npcMC != null)
         {
            if("getCollisionRadius" in this._npcMC)
            {
               return this._npcMC.getCollisionRadius(2);
            }
         }
         return 20;
      }
      
      public function get collisionMovingPoint() : Point
      {
         if(this._npcMC != null)
         {
            if("getCollisionPoint" in this._npcMC)
            {
               return this._npcMC.getCollisionPoint(1);
            }
         }
         return new Point(0,0);
      }
      
      public function get collisionZapPoint() : Point
      {
         if(this._npcMC != null)
         {
            if("getCollisionPoint" in this._npcMC)
            {
               return this._npcMC.getCollisionPoint(2);
            }
         }
         return new Point(0,0);
      }
      
      public function get collisionPointAttack() : Point
      {
         if(this._npcMC != null)
         {
            if("getCollisionPoint" in this._npcMC)
            {
               return this._npcMC.getCollisionPoint(0);
            }
         }
         return new Point(0,0);
      }
      
      public function get avatar() : Avatar
      {
         if(this._npcAvatarView != null)
         {
            return this._npcAvatarView.avatarData;
         }
         return null;
      }
      
      public function get talkingHeadMediaId() : int
      {
         if(this._npcDef != null)
         {
            return this._npcDef.headMediaRefId;
         }
         return 0;
      }
      
      public function reset() : void
      {
         this._npcState = NPC_STATE_LOADING;
      }
      
      public function init(npcDefId:int, playerId:int, namebarStrId:int = -1, hasHealthBar:Boolean = false, onLoadingCompleteCallback:Function = null) : void
      {
         var avt:Avatar = null;
         var itemsToUse:Array = null;
         var i:int = 0;
         var aiItem:Item = null;
         var index:int = 0;
         var colors:Array = null;
         var loadSelfAnims:Array = null;
         var text:String = null;
         this._npcFacingSW = false;
         this._npcState = NPC_STATE_LOADING;
         this._npcAngle = 0;
         this._npcDef = QuestManager.getNPCDef(npcDefId);
         this._playerId = playerId;
         this._onLoadingCompleteCallback = onLoadingCompleteCallback;
         this._hitText = new TextField();
         this._hitText.selectable = false;
         this._hitText.multiline = false;
         this._hitText.autoSize = TextFieldAutoSize.CENTER;
         this._hitText.visible = false;
         this._hitText.embedFonts = true;
         this._hitText.defaultTextFormat = new TextFormat("TikiIsland-Regular",36,4286945);
         this._hitText.filters = [new GlowFilter(0,1,3,3,10,2)];
         switch(this._npcDef.type)
         {
            case 0:
               this._mediaHelperObj = new MediaHelper();
               this._mediaHelperObj.init(this._npcDef.mediaRefId,this.onMediaLoaded);
               break;
            case 1:
               avt = new Avatar();
               avt.avName = "";
               avt.userName = "";
               this._npcAvatarView = new AvatarWorldView();
               this._npcAvatarView.initWorldView(avt,QuestManager._layerManager.room_chat,Utility.NON_MEMBER,true);
               avt.init(-1,avt.avName,this._npcDef.avatarRefId,[this._npcDef.baseColor,this._npcDef.patternColor,this._npcDef.eyesColor]);
               avt.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(this._npcDef.avatarRefId,this._npcDef.patternItemRefId,this._npcDef.eyesItemRefId,false));
               if(namebarStrId > 0)
               {
                  if(this._npcAvatarView != null && this._npcAvatarView.avatarData != null)
                  {
                     text = LocalizationManager.translateIdOnly(namebarStrId);
                     this._npcAvatarView.avatarData.avName = text;
                     this._npcAvatarView.avatarData.userName = text;
                     if(this._npcAvatarView.nameBar != null)
                     {
                        this._npcAvatarView.nameBar.setAvName(text);
                        this._npcAvatarView.nameBar.visible = true;
                     }
                  }
               }
               itemsToUse = new Array();
               index = 100;
               for(i = 0; i < this._npcAvatarView.avatarData.inventoryBodyMod.itemArray.length; i++)
               {
                  itemsToUse.push(this._npcAvatarView.avatarData.inventoryBodyMod.itemArray[i]);
               }
               if(this._npcDef.backItemRefId != 0)
               {
                  aiItem = new Item();
                  colors = ItemXtCommManager.getItemDef(this._npcDef.backItemRefId).colors;
                  aiItem.init(this._npcDef.backItemRefId,index++,colors[Math.min(this._npcDef.backColor,colors.length - 1)],-1,-1);
                  itemsToUse.push(aiItem);
               }
               if(this._npcDef.headItemRefId != 0)
               {
                  aiItem = new Item();
                  colors = ItemXtCommManager.getItemDef(this._npcDef.headItemRefId).colors;
                  aiItem.init(this._npcDef.headItemRefId,index++,colors[Math.min(this._npcDef.headColor,colors.length - 1)],-1,-1);
                  itemsToUse.push(aiItem);
               }
               if(this._npcDef.legItemRefId != 0)
               {
                  aiItem = new Item();
                  colors = ItemXtCommManager.getItemDef(this._npcDef.legItemRefId).colors;
                  aiItem.init(this._npcDef.legItemRefId,index++,colors[Math.min(this._npcDef.legColor,colors.length - 1)],-1,-1);
                  itemsToUse.push(aiItem);
               }
               if(this._npcDef.neckItemRefId != 0)
               {
                  aiItem = new Item();
                  colors = ItemXtCommManager.getItemDef(this._npcDef.neckItemRefId).colors;
                  aiItem.init(this._npcDef.neckItemRefId,index++,colors[Math.min(this._npcDef.neckColor,colors.length - 1)],-1,-1);
                  itemsToUse.push(aiItem);
               }
               if(this._npcDef.tailItemRefId != 0)
               {
                  aiItem = new Item();
                  colors = ItemXtCommManager.getItemDef(this._npcDef.tailItemRefId).colors;
                  aiItem.init(this._npcDef.tailItemRefId,index++,colors[Math.min(this._npcDef.tailColor,colors.length - 1)],-1,-1);
                  itemsToUse.push(aiItem);
               }
               this._npcAvatarView.avatarData.itemResponseIntegrate(itemsToUse);
               loadSelfAnims = new Array(15);
               if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
               {
                  loadSelfAnims[0] = LayerAnim.AN_IDLE_SE;
                  loadSelfAnims[1] = LayerAnim.AN_MOVE_NNE;
                  loadSelfAnims[2] = LayerAnim.AN_MOVE_NE;
                  loadSelfAnims[3] = LayerAnim.AN_MOVE_E;
                  loadSelfAnims[4] = LayerAnim.AN_MOVE_SE;
                  loadSelfAnims[5] = LayerAnim.AN_MOVE_SSE;
                  loadSelfAnims[6] = LayerAnim.AN_DANCE;
                  loadSelfAnims[7] = LayerAnim.AN_SLEEP;
                  loadSelfAnims[8] = LayerAnim.AN_HOP;
               }
               else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
               {
                  loadSelfAnims[0] = LayerAnim.AN_FLOAT;
                  loadSelfAnims[1] = LayerAnim.AN_SWIM_E;
                  loadSelfAnims[2] = LayerAnim.AN_WATER_DIVE;
                  loadSelfAnims[3] = LayerAnim.AN_WATER_PLAY;
                  loadSelfAnims[4] = LayerAnim.AN_WATER_SPIN;
                  loadSelfAnims[5] = LayerAnim.AN_WATER_JIG;
                  loadSelfAnims[6] = LayerAnim.AN_WATER_POSE;
               }
               this._npcAvatarView.preloadAnims(loadSelfAnims,this.redrawCallback);
         }
         if(hasHealthBar)
         {
            this._healthBar = GETDEFINITIONBYNAME("NPCHealth");
            this._healthBar.x = -this._healthBar.width * 0.5;
            this._healthBar.y = 18;
            this._healthBar.hpBar.width = this._healthBar.hpEnemyBarContainer.width;
            addChild(this._healthBar);
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._mediaHelperObj))
         {
            this._mediaHelperObj.destroy();
            this._mediaHelperObj = null;
         }
         if(Boolean(this._npcMC))
         {
            if(this._npcMC.hasOwnProperty("destroyPhantomNPC"))
            {
               this._npcMC.destroyPhantomNPC();
            }
            if(this._npcMC.parent != null)
            {
               this._npcMC.parent.removeChild(this._npcMC);
            }
         }
         if(Boolean(this._secondaryNpcMC) && Boolean(this._secondaryNpcMC.parent != null) && this._secondaryNpcMC.parent is MovieClip)
         {
            this._secondaryNpcMC.parent.removeChild(this._secondaryNpcMC);
         }
         if(Boolean(this._namebar))
         {
            this._namebar.destroy();
            this._namebar = null;
         }
         if(Boolean(this._healthBar))
         {
            this._healthBar = null;
         }
         if(Boolean(this._npcAvatarView))
         {
            if(this._npcAvatarView.parent != null)
            {
               this._npcAvatarView.parent.removeChild(this._npcAvatarView);
            }
            this._npcAvatarView.destroy(true);
         }
         this._hitTextTween = null;
      }
      
      public function updateHealthBar(healthPercent:int, damageAmount:int, criticalHit:Boolean, displayText:Boolean) : void
      {
         var text:String = null;
         if(Boolean(this._healthBar))
         {
            if(healthPercent == 0)
            {
               this._healthBar.visible = false;
            }
            else
            {
               this._healthBar.hpBar.width = this._healthBar.hpEnemyBarContainer.width * (healthPercent / 100);
            }
         }
         if(displayText)
         {
            if(damageAmount > 0 && Boolean(this._npcMC))
            {
               if(criticalHit)
               {
                  text = "Fierce!\n" + Math.abs(damageAmount) * -1;
               }
               else
               {
                  text = String(Math.abs(damageAmount) * -1);
               }
               this.playHitText(text);
            }
         }
      }
      
      public function playHitText(hitString:String) : void
      {
         var attachmentPoint:Point = null;
         this._hitText.visible = true;
         this._hitText.alpha = 2;
         this._hitText.text = hitString;
         try
         {
            attachmentPoint = this._npcMC.getAttachmentPoint();
            this._hitText.x = attachmentPoint.x + this.x - this._hitText.textWidth * 0.5;
            this._hitText.y = attachmentPoint.y + this.y;
         }
         catch(e:Error)
         {
            _hitText.x = this.x - _hitText.textWidth * 0.5;
            _hitText.y = this.y - _hitText.textHeight;
         }
         if(parent != null)
         {
            this._hitText.x += parent.x;
            this._hitText.y += parent.y;
         }
         if(Boolean(this._hitTextTween))
         {
            this._hitTextTween.resetValues({
               "y":this._hitText.y - 90,
               "alpha":0
            });
            this._hitTextTween.beginning();
            this._hitTextTween.paused = false;
         }
         else
         {
            this._hitTextTween = new GTween(this._hitText,1,{
               "y":this._hitText.y - 90,
               "alpha":0
            },{"ease":Linear.easeNone});
         }
      }
      
      public function playAnimationState(anim:int, bFlip:Boolean, loopMode:int, callback:Function) : void
      {
         if(Boolean(this._npcAvatarView))
         {
            this._npcAvatarView.playAnim(anim,bFlip,loopMode,callback);
         }
      }
      
      public function get npcMC() : MovieClip
      {
         return this._npcMC;
      }
      
      public function get defId() : int
      {
         return this._npcDef.defId;
      }
      
      public function get npcDef() : Object
      {
         return this._npcDef;
      }
      
      public function get secondaryNpcMC() : MovieClip
      {
         return this._secondaryNpcMC;
      }
      
      private function onMediaLoaded(img:MovieClip) : void
      {
         this._npcMC = img;
         addChild(this._npcMC);
         if(this._npcMC.hasOwnProperty("eye"))
         {
            this._eye = this._npcMC.eye;
         }
         if(this._npcDef.headMediaRefId != 0)
         {
            this._mediaHelperObj = new MediaHelper();
            this._mediaHelperObj.init(this._npcDef.headMediaRefId,this.secondaryNPCLoaded);
         }
         else
         {
            this.loadingComplete();
         }
      }
      
      private function secondaryNPCLoaded(img:MovieClip) : void
      {
         if(img.getChildAt(0) is MovieClip)
         {
            this._secondaryNpcMC = MovieClip(img.getChildAt(0));
         }
         else
         {
            this._secondaryNpcMC = img;
         }
         this._mediaHelperObj.destroy();
         this._mediaHelperObj = null;
         this.loadingComplete();
      }
      
      private function redrawCallback(layerAnim:LayerAnim) : void
      {
         if(Boolean(layerAnim) && Boolean(this._npcAvatarView))
         {
            if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
            {
               this.playAnimationState(LayerAnim.AN_IDLE_SE,false,LayerAnim.PLAY_LOOP,null);
            }
            else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
            {
               this.playAnimationState(LayerAnim.AN_FLOAT,false,LayerAnim.AN_FLOAT,null);
            }
            addChild(this._npcAvatarView);
            this.loadingComplete();
         }
      }
      
      private function loadingComplete() : void
      {
         this._npcState = NPC_STATE_LOADED;
         if(this._npcMC != null && this._npcMC.hasOwnProperty("setInit"))
         {
            this._npcMC.setInit(QuestManager._questDifficultyLevel);
            if(this._npcMC.hasOwnProperty("watcher"))
            {
               this._beam = this._npcMC.watcher;
            }
         }
         QuestManager._layerManager.room_chat.addChild(this._hitText);
         if(this._onLoadingCompleteCallback != null)
         {
            this._onLoadingCompleteCallback();
         }
      }
      
      public function setSwfState(swfStateName:String) : Number
      {
         if(this._npcMC != null)
         {
            return this._npcMC.setStateByScript(swfStateName);
         }
         if(this._npcAvatarView != null)
         {
            if(swfStateName == "dance")
            {
               if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
               {
                  this.playAnimationState(LayerAnim.AN_DANCE,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_WATER_JIG,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(swfStateName == "hop")
            {
               if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
               {
                  this.playAnimationState(LayerAnim.AN_HOP,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_WATER_DIVE,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(swfStateName == "spin")
            {
               if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_WATER_SPIN,this._npcFacingSW,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(swfStateName == "idle" || swfStateName == "facese")
            {
               this._npcFacingSW = false;
               if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
               {
                  this.playAnimationState(LayerAnim.AN_IDLE_SE,false,LayerAnim.PLAY_LOOP,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_FLOAT,false,LayerAnim.PLAY_LOOP,null);
               }
            }
            else if(swfStateName == "facesw")
            {
               this._npcFacingSW = true;
               if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_LAND)
               {
                  this.playAnimationState(LayerAnim.AN_IDLE_SE,true,LayerAnim.PLAY_LOOP,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == Utility.ENVIRO_OCEAN)
               {
                  this.playAnimationState(LayerAnim.AN_FLOAT,true,LayerAnim.PLAY_LOOP,null);
               }
            }
         }
         return 0;
      }
   }
}

