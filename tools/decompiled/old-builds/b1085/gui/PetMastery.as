package gui
{
   import avatar.AvatarManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class PetMastery
   {
      
      private const MASTERY_MEDIA_ID:int = 1381;
      
      private var _masteryPopup:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _mediaHelper:MediaHelper;
      
      private var _currPet:GuiPet;
      
      public function PetMastery()
      {
         super();
      }
      
      public function init() : void
      {
         this._guiLayer = GuiManager.guiLayer;
      }
      
      public function displayMasteryPopup() : void
      {
         if(this._masteryPopup)
         {
            this.setupInitialConditions();
            this._guiLayer.addChild(this._masteryPopup);
            DarkenManager.darken(this._masteryPopup);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            this._mediaHelper = new MediaHelper();
            this._mediaHelper.init(this.MASTERY_MEDIA_ID,this.onMediaLoaded);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            this._masteryPopup = MovieClip(param1.getChildAt(0));
            this.setupInitialConditions();
            this._masteryPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._masteryPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._guiLayer.addChild(this._masteryPopup);
            DarkenManager.darken(this._masteryPopup);
            this.addEventListeners();
         }
      }
      
      private function setupInitialConditions() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc1_:Object = PetManager.myActivePet;
         if(_loc1_)
         {
            _loc2_ = 1;
            _loc3_ = int(_loc1_.uBits);
            _loc4_ = _loc3_ & 0x0F;
            _loc5_ = _loc3_ >> 4 & 0x0F;
            _loc6_ = _loc3_ >> 12 & 0x0F;
            _loc7_ = _loc3_ >> 16 & 0x0F;
            _loc8_ = _loc3_ >> 20 & 0x0F;
            _loc3_ = _loc8_ << 20 | _loc7_ << 16 | _loc6_ << 12 | _loc2_ << 8 | _loc5_ << 4 | _loc4_;
            _loc1_.uBits = _loc2_ << 8 | _loc3_;
            this._currPet = new GuiPet(_loc1_.idx,_loc1_.lBits,_loc1_.uBits,_loc1_.eBits,_loc1_.type,_loc1_.name,this.onPetLoaded);
            while(this._masteryPopup.itemBlock.numChildren > 0)
            {
               this._masteryPopup.itemBlock.removeChildAt(0);
            }
            this._masteryPopup.itemBlock.addChild(this._currPet);
            AvatarManager.playerAvatarWorldView.setActivePet(this._currPet.getLBits(),this._currPet.getUBits(),this._currPet.getEBits(),this._currPet.name);
         }
      }
      
      private function onPetLoaded(param1:MovieClip) : void
      {
         this._currPet.scaleX = this._currPet.scaleY = 2.5;
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMasteryClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(this._masteryPopup);
         this._guiLayer.removeChild(this._masteryPopup);
      }
      
      private function addEventListeners() : void
      {
         this._masteryPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._masteryPopup.xb.addEventListener(MouseEvent.MOUSE_DOWN,this.onMasteryClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._masteryPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._masteryPopup.xb.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMasteryClose);
      }
   }
}

