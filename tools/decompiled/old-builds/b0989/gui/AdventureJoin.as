package gui
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import loader.MediaHelper;
   import quest.QuestXtCommManager;
   
   public class AdventureJoin
   {
      
      private const MEDIA_ID:int = 2249;
      
      private var _scriptDef:Object;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _inParamsWaiting:Object;
      
      private var _artLoadingSpiral:LoadingSpiral;
      
      private var _closeCallback:Function;
      
      private var _savedParams:Array;
      
      public function AdventureJoin()
      {
         super();
      }
      
      public function init(param1:int, param2:Function) : void
      {
         this._savedParams = [];
         this._scriptDef = QuestXtCommManager.getScriptDef(param1);
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = param2;
         DarkenManager.showLoadingSpiral(true);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this.MEDIA_ID,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         this._mediaHelper.destroy();
         this._mediaHelper = null;
         if(this._popup)
         {
            DarkenManager.unDarken(this._popup);
            this._guiLayer.removeChild(this._popup);
            this._popup = null;
         }
      }
      
      public function handleWaitResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Avatar = null;
         if(this._popup)
         {
            _loc2_ = 4;
            _loc3_ = 1;
            _loc4_ = 1;
            while(_loc4_ < _loc2_ + 1)
            {
               while(this._popup["p" + _loc4_].char.charLayer.numChildren > 0)
               {
                  this._popup["p" + _loc4_].char.charLayer.removeChildAt(0);
               }
               this._popup["p" + _loc4_].char.gotoAndPlay("waiting");
               this._popup["p" + _loc4_].nameBar.lastName_txt.text = "";
               _loc4_++;
            }
            _loc5_ = 2;
            while(_loc5_ < _loc2_ + 2)
            {
               if(_loc5_ < param1.length)
               {
                  _loc6_ = int(param1[_loc5_]);
                  this._popup["p" + (_loc5_ - 1)].char.gotoAndPlay("up");
                  _loc7_ = AvatarManager.getAvatarBySfsUserId(_loc6_);
                  if(_loc7_ == null)
                  {
                     this._savedParams[_loc6_] = this._popup["p" + (_loc5_ - 1)];
                     AvatarXtCommManager.requestAvatarGetBySfsId(_loc6_,this.onAvatarGetReceived);
                  }
                  else
                  {
                     this.setupAvatar(this._popup["p" + (_loc5_ - 1)],_loc7_);
                  }
               }
               else
               {
                  this._popup["p" + (_loc5_ - 1)].char.gotoAndPlay("waiting");
                  this._popup["p" + (_loc5_ - 1)].nameBar.firstName_txt.text = "Waiting...";
                  this._popup["p" + (_loc5_ - 1)].nameBar.lastName_txt.text = "";
               }
               _loc5_++;
            }
         }
         else
         {
            this._inParamsWaiting = param1;
         }
      }
      
      private function setupAvatar(param1:MovieClip, param2:Avatar) : void
      {
         var _loc4_:Point = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc3_:AvatarView = new AvatarView();
         _loc3_.init(param2);
         _loc3_.playAnim(LayerAnim.AN_HUD_AVT);
         _loc3_.scaleX = 0.7;
         _loc3_.scaleY = 0.7;
         _loc4_ = AvatarUtility.getAvatarMinigameLobbyOffset(_loc3_.avTypeId);
         _loc3_.x = _loc4_.x;
         _loc3_.y = _loc4_.y;
         param1.char.charLayer.addChild(_loc3_);
         var _loc5_:String = param2.avName;
         var _loc6_:int = _loc5_.indexOf(" ");
         if(_loc6_ != -1)
         {
            _loc7_ = _loc5_.substr(0,_loc6_);
            _loc8_ = _loc5_.substr(_loc6_ + 1,_loc5_.length);
         }
         else
         {
            _loc7_ = _loc5_;
         }
         param1.nameBar.firstName_txt.text = _loc7_;
         if(_loc8_)
         {
            param1.nameBar.lastName_txt.text = _loc8_;
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:int) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:int = 0;
         var _loc7_:Avatar = null;
         if(this._popup)
         {
            _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
            if(!_loc5_)
            {
               throw new Error("onAvatarSFSGetReceived and avInfo is null");
            }
            _loc6_ = _loc5_.dbAvId;
            _loc7_ = AvatarManager.getAvatarByUserName(param1);
            if(_loc7_ == null)
            {
               _loc7_ = AvatarUtility.generateNew(_loc6_,null,-1,0);
            }
            this.setupAvatar(this._savedParams[param4],_loc7_);
            delete this._savedParams[param4];
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         DarkenManager.showLoadingSpiral(false);
         this._popup = MovieClip(param1.getChildAt(0));
         LocalizationXtCommManager.sendTranslateStringRequest(this._scriptDef.titleStrId,LocalizationXtCommManager.LANG_ENG,this.onlocalizationReceived);
         LocalizationXtCommManager.sendTranslateStringRequest(this._scriptDef.descStrId,LocalizationXtCommManager.LANG_ENG,this.onlocalizationReceived);
         this._artLoadingSpiral = new LoadingSpiral(this._popup.artWindow,this._popup.artWindow.width * 0.5,this._popup.artWindow.height * 0.5);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this._scriptDef.mediaRefId,this.onArtLoaded);
         var _loc2_:AvatarView = new AvatarView();
         _loc2_.init(AvatarManager.playerAvatar);
         _loc2_.playAnim(LayerAnim.AN_HUD_AVT);
         this._popup.p1.char.charLayer.addChild(_loc2_);
         var _loc3_:String = AvatarManager.playerAvatar.avName;
         var _loc4_:int = _loc3_.indexOf(" ");
         if(_loc4_ != -1)
         {
            _loc5_ = _loc3_.substr(0,_loc4_);
            _loc6_ = _loc3_.substr(_loc4_ + 1,_loc3_.length);
         }
         else
         {
            _loc5_ = _loc3_;
         }
         this._popup.p1.nameBar.firstName_txt.text = _loc5_;
         if(_loc6_)
         {
            this._popup.p1.nameBar.lastName_txt.text = _loc6_;
         }
         this.addEventListeners();
         this._popup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         this._guiLayer.addChild(this._popup);
         DarkenManager.darken(this._popup);
         if(this._inParamsWaiting != null)
         {
            this.handleWaitResponse(this._inParamsWaiting);
            this._inParamsWaiting = null;
         }
      }
      
      private function onlocalizationReceived(param1:int, param2:String) : void
      {
         if(param1 == this._scriptDef.titleStrId)
         {
            this._popup.titleTxt.text = param2;
         }
         else if(param1 == this._scriptDef.descStrId)
         {
            this._popup.contTxt.text = param2;
         }
      }
      
      private function onArtLoaded(param1:MovieClip) : void
      {
         while(this._popup.artWindow.numChildren > 0)
         {
            this._popup.artWindow.removeChildAt(0);
         }
         this._popup.artWindow.addChild(param1);
         if(this._artLoadingSpiral != null)
         {
            this._artLoadingSpiral.destroy();
            this._artLoadingSpiral = null;
         }
      }
      
      private function addEventListeners() : void
      {
         this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._popup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
         this._popup.playBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         if(this._popup)
         {
            this._popup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._popup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn);
            this._popup.playBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlayBtn);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestJoinCancel();
         if(this._closeCallback != null)
         {
            this._closeCallback();
            this._closeCallback = null;
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onPlayBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         var _loc2_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
         if(Boolean(_loc2_) && _loc2_.questLevel < this._scriptDef.levelMin)
         {
            new SBOkPopup(this._guiLayer,"Your animal must be level " + this._scriptDef.levelMin + " to go on this Adventure.");
            return;
         }
         QuestXtCommManager.sendQuestStartRequest();
      }
   }
}

