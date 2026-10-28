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
   import flash.utils.getDefinitionByName;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Linear;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import quest.QuestManager;
   
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
      
      private var _npcEyeAngle:int;
      
      private var _npcEyeAngleUpdateDelay:int;
      
      private var _healthBar:MovieClip;
      
      private var _hitText:TextField;
      
      private var _hitTextTween:GTween;
      
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
            if(this._npcMC != null && this._npcMC.attacking == true)
            {
               this._npcMC.attacking = false;
               return true;
            }
            return false;
         }
         return true;
      }
      
      public function get readyToAttack() : Boolean
      {
         if(this._npcState != NPC_STATE_ATTACK && this._npcState != NPC_STATE_DEATH)
         {
            return true;
         }
         return false;
      }
      
      public function get isDead() : Boolean
      {
         return this._npcState == NPC_STATE_DEATH && (this._npcMC == null || this._npcMC.animActive == false);
      }
      
      public function get isDying() : Boolean
      {
         return this._npcState == NPC_STATE_DEATH;
      }
      
      public function setNpcState(param1:int, param2:Number = 0) : void
      {
         if(this._npcMC)
         {
            if(this._npcState != NPC_STATE_DEATH)
            {
               switch(param1)
               {
                  case NPC_STATE_TREASURE_APPEAR:
                     if(this._npcMC)
                     {
                        this._npcMC.appear();
                        this._npcState = param1;
                     }
                     break;
                  case NPC_STATE_TREASURE_OPEN:
                     if(this._npcMC)
                     {
                        this._npcMC.openChest();
                        this._npcState = param1;
                     }
                     break;
                  case NPC_STATE_TREASURE_DISAPPEAR:
                     if(this._npcMC)
                     {
                        this._npcMC.disappear();
                        this._npcState = param1;
                     }
                     break;
                  case NPC_STATE_DEATH:
                     this._npcState = param1;
                     this._npcMC.noHealth();
                     break;
                  case NPC_STATE_IDLE:
                     if(this._npcMC.animActive == false)
                     {
                        this._npcState = param1;
                        this._npcMC.idle(270);
                        if(this._npcEyeAngle != 270)
                        {
                           --this._npcEyeAngleUpdateDelay;
                           if(this._npcEyeAngleUpdateDelay <= 0)
                           {
                              this._npcEyeAngleUpdateDelay = Math.random() * 8 + 2;
                              this._npcEyeAngle = 270;
                              if(this._npcMC["setEye"] != null)
                              {
                                 this._npcMC.setEye(270);
                              }
                           }
                        }
                     }
                     if(this._npcMC.hasOwnProperty("getSortHeight"))
                     {
                        this._npcMC.parent.parent.name = this._npcMC.getSortHeight();
                     }
                     break;
                  case NPC_STATE_MOVE:
                     this._npcAngle = param2;
                     if(this._npcMC.animActive == false)
                     {
                        this._npcState = param1;
                        this._npcMC.moveCycle(this._npcAngle);
                        if(this._npcEyeAngle != this._npcAngle)
                        {
                           --this._npcEyeAngleUpdateDelay;
                           if(this._npcEyeAngleUpdateDelay <= 0)
                           {
                              this._npcEyeAngleUpdateDelay = Math.random() * 8 + 2;
                              this._npcEyeAngle = this._npcAngle;
                              if(this._npcMC["setEye"] != null)
                              {
                                 this._npcMC.setEye(this._npcAngle);
                              }
                           }
                        }
                     }
                     break;
                  case NPC_STATE_ATTACK:
                     this._npcState = param1;
                     this._npcAngle = param2;
                     this._npcMC.attack(this._npcAngle);
                     if(this._npcEyeAngle != this._npcAngle)
                     {
                        --this._npcEyeAngleUpdateDelay;
                        if(this._npcEyeAngleUpdateDelay <= 0)
                        {
                           this._npcEyeAngleUpdateDelay = Math.random() * 8 + 2;
                           this._npcEyeAngle = this._npcAngle;
                           if(this._npcMC["setEye"] != null)
                           {
                              this._npcMC.setEye(this._npcAngle);
                           }
                        }
                     }
                     break;
                  case NPC_STATE_RECOIL:
                     if(this._npcState != NPC_STATE_RECOIL)
                     {
                        if(this._npcState == NPC_STATE_IDLE || this._npcState == NPC_STATE_MOVE)
                        {
                           this._npcState = param1;
                        }
                        this._npcMC.recoil(this._npcAngle);
                     }
                     break;
                  case NPC_STATE_DANCE:
                     this._npcState = param1;
                     this.playAnimationState(LayerAnim.AN_DANCE,false,LayerAnim.PLAY_LOOP,null);
               }
            }
         }
      }
      
      public function get collisionRadius() : Number
      {
         if(this._npcMC != null)
         {
            return this._npcMC.getCollisionRadius();
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
      
      public function get collisionPoint() : Point
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
      
      public function get collisionRadiusAttack() : Number
      {
         if(this._npcMC != null)
         {
            if("getCollisionRadius" in this._npcMC)
            {
               return this._npcMC.getCollisionRadius(0);
            }
         }
         return 20;
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
      
      public function init(param1:int, param2:int, param3:int = -1, param4:Boolean = false, param5:Function = null) : void
      {
         var _loc6_:Avatar = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:Item = null;
         var _loc10_:* = 0;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         this._npcState = NPC_STATE_LOADING;
         this._npcAngle = 0;
         this._npcDef = QuestManager.getNPCDef(param1);
         this._playerId = param2;
         this._onLoadingCompleteCallback = param5;
         this._hitText = new TextField();
         this._hitText.selectable = false;
         this._hitText.multiline = false;
         this._hitText.autoSize = TextFieldAutoSize.CENTER;
         this._hitText.visible = false;
         this._hitText.embedFonts = true;
         this._hitText.defaultTextFormat = new TextFormat("Tiki-Island",36,4286945);
         this._hitText.filters = [new GlowFilter(0,1,3,3,10,2)];
         switch(this._npcDef.type)
         {
            case 0:
               this._mediaHelperObj = new MediaHelper();
               this._mediaHelperObj.init(this._npcDef.mediaRefId,this.onMediaLoaded);
               break;
            case 1:
               _loc6_ = new Avatar();
               _loc6_.avName = "";
               _loc6_.userName = "";
               this._npcAvatarView = new AvatarWorldView();
               this._npcAvatarView.initWorldView(_loc6_,QuestManager._layerManager.room_chat,Utility.NON_MEMBER,true);
               _loc6_.init(-1,_loc6_.avName,this._npcDef.avatarRefId,[this._npcDef.baseColor,this._npcDef.patternColor,this._npcDef.eyesColor]);
               _loc6_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(this._npcDef.avatarRefId,this._npcDef.patternItemRefId,this._npcDef.eyesItemRefId,false));
               if(param3 > 0)
               {
                  LocalizationXtCommManager.sendTranslateStringRequest(param3,LocalizationXtCommManager.LANG_ENG,this.onNameBarLocReceived,param3);
               }
               _loc7_ = new Array();
               _loc10_ = 100;
               _loc8_ = 0;
               while(_loc8_ < this._npcAvatarView.avatarData.inventoryBodyMod.itemArray.length)
               {
                  _loc7_.push(this._npcAvatarView.avatarData.inventoryBodyMod.itemArray[_loc8_]);
                  _loc8_++;
               }
               if(this._npcDef.backItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc11_ = ItemXtCommManager.getItemDef(this._npcDef.backItemRefId).colors;
                  _loc9_.init(this._npcDef.backItemRefId,_loc10_++,_loc11_[Math.min(this._npcDef.backColor,_loc11_.length - 1)],-1,-1);
                  _loc7_.push(_loc9_);
               }
               if(this._npcDef.headItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc11_ = ItemXtCommManager.getItemDef(this._npcDef.headItemRefId).colors;
                  _loc9_.init(this._npcDef.headItemRefId,_loc10_++,_loc11_[Math.min(this._npcDef.headColor,_loc11_.length - 1)],-1,-1);
                  _loc7_.push(_loc9_);
               }
               if(this._npcDef.legItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc11_ = ItemXtCommManager.getItemDef(this._npcDef.legItemRefId).colors;
                  _loc9_.init(this._npcDef.legItemRefId,_loc10_++,_loc11_[Math.min(this._npcDef.legColor,_loc11_.length - 1)],-1,-1);
                  _loc7_.push(_loc9_);
               }
               if(this._npcDef.neckItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc11_ = ItemXtCommManager.getItemDef(this._npcDef.neckItemRefId).colors;
                  _loc9_.init(this._npcDef.neckItemRefId,_loc10_++,_loc11_[Math.min(this._npcDef.neckColor,_loc11_.length - 1)],-1,-1);
                  _loc7_.push(_loc9_);
               }
               if(this._npcDef.tailItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc11_ = ItemXtCommManager.getItemDef(this._npcDef.tailItemRefId).colors;
                  _loc9_.init(this._npcDef.tailItemRefId,_loc10_++,_loc11_[Math.min(this._npcDef.tailColor,_loc11_.length - 1)],-1,-1);
                  _loc7_.push(_loc9_);
               }
               this._npcAvatarView.avatarData.itemResponseIntegrate(_loc7_);
               _loc12_ = new Array(3);
               _loc12_[0] = LayerAnim.AN_IDLE_SE;
               _loc12_[1] = LayerAnim.AN_DANCE;
               _loc12_[2] = LayerAnim.AN_SLEEP;
               this._npcAvatarView.preloadAnims(_loc12_,this.redrawCallback);
         }
         if(param4)
         {
            this._healthBar = new (getDefinitionByName("NPCHealth") as Class)();
            this._healthBar.x = -this._healthBar.width * 0.5;
            this._healthBar.y = 18;
            this._healthBar.hpBar.width = this._healthBar.hpEnemyBarContainer.width;
            addChild(this._healthBar);
         }
      }
      
      private function onNameBarLocReceived(param1:int, param2:String, param3:Object) : void
      {
         if(this._npcAvatarView != null && this._npcAvatarView.avatarData != null)
         {
            this._npcAvatarView.avatarData.avName = param2;
            this._npcAvatarView.avatarData.userName = param2;
            if(this._npcAvatarView.nameBar != null)
            {
               this._npcAvatarView.nameBar.setAvName(param2);
               this._npcAvatarView.nameBar.visible = true;
            }
         }
      }
      
      public function destroy() : void
      {
         if(this._mediaHelperObj)
         {
            this._mediaHelperObj.destroy();
            this._mediaHelperObj = null;
         }
         if(Boolean(this._npcMC) && this._npcMC.parent != null)
         {
            this._npcMC.parent.removeChild(this._npcMC);
         }
         if(this._namebar)
         {
            this._namebar.destroy();
            this._namebar = null;
         }
         if(this._healthBar)
         {
            this._healthBar = null;
         }
         if(this._npcAvatarView)
         {
            if(this._npcAvatarView.parent != null)
            {
               this._npcAvatarView.parent.removeChild(this._npcAvatarView);
            }
            this._npcAvatarView.destroy(true);
         }
         this._hitTextTween = null;
      }
      
      public function updateHealthBar(param1:int, param2:int, param3:Boolean) : void
      {
         if(this._healthBar)
         {
            if(param1 == 0)
            {
               this._healthBar.visible = false;
            }
            else
            {
               this._healthBar.hpBar.width = this._healthBar.hpEnemyBarContainer.width * (param1 / 100);
            }
         }
      }
      
      public function playHitText(param1:String) : void
      {
         var attachmentPoint:Point = null;
         var hitString:String = param1;
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
         if(this._hitTextTween)
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
      
      public function playAnimationState(param1:int, param2:Boolean, param3:int, param4:Function) : void
      {
         if(this._npcAvatarView)
         {
            this._npcAvatarView.playAnim(param1,param2,param3,param4);
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
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         this._npcMC = param1;
         this._mediaHelperObj.destroy();
         this._mediaHelperObj = null;
         addChild(this._npcMC);
         this.loadingComplete();
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(Boolean(param1) && Boolean(this._npcAvatarView))
         {
            this.playAnimationState(LayerAnim.AN_IDLE_SE,false,LayerAnim.PLAY_LOOP,null);
            addChild(this._npcAvatarView);
            this.loadingComplete();
         }
      }
      
      private function loadingComplete() : void
      {
         this._npcState = NPC_STATE_LOADED;
         QuestManager._layerManager.room_chat.addChild(this._hitText);
         if(this._onLoadingCompleteCallback != null)
         {
            this._onLoadingCompleteCallback();
         }
      }
      
      public function setSwfState(param1:String) : Number
      {
         if(this._npcMC != null)
         {
            return this._npcMC.setStateByScript(param1);
         }
         if(this._npcAvatarView != null)
         {
            if(param1 == "dance")
            {
               this.playAnimationState(LayerAnim.AN_DANCE,false,LayerAnim.PLAY_LOOP,null);
            }
         }
         return 0;
      }
   }
}

