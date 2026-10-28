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
         if(Boolean(this._masteryPopup))
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
      
      private function onMediaLoaded(mc:MovieClip) : void
      {
         if(Boolean(mc))
         {
            DarkenManager.showLoadingSpiral(false);
            this._masteryPopup = MovieClip(mc.getChildAt(0));
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
         var cat8:int = 0;
         var uBits:int = 0;
         var cat6:int = 0;
         var cat7:int = 0;
         var cat9:int = 0;
         var cat10:int = 0;
         var cat11:int = 0;
         var myPet:Object = PetManager.myActivePet;
         if(Boolean(myPet))
         {
            cat8 = 1;
            uBits = int(myPet.uBits);
            cat6 = uBits & 0x0F;
            cat7 = uBits >> 4 & 0x0F;
            cat9 = uBits >> 12 & 0x0F;
            cat10 = uBits >> 16 & 0x0F;
            cat11 = uBits >> 20 & 0x0F;
            uBits = cat11 << 20 | cat10 << 16 | cat9 << 12 | cat8 << 8 | cat7 << 4 | cat6;
            myPet.uBits = cat8 << 8 | uBits;
            this._currPet = new GuiPet(myPet.idx,myPet.lBits,myPet.uBits,myPet.eBits,myPet.type,myPet.name,this.onPetLoaded);
            while(this._masteryPopup.itemBlock.numChildren > 0)
            {
               this._masteryPopup.itemBlock.removeChildAt(0);
            }
            this._masteryPopup.itemBlock.addChild(this._currPet);
            AvatarManager.playerAvatarWorldView.setActivePet(this._currPet.getLBits(),this._currPet.getUBits(),this._currPet.getEBits(),this._currPet.name);
         }
      }
      
      private function onPetLoaded(content:MovieClip, guiPet:GuiPet) : void
      {
         this._currPet.scaleX = this._currPet.scaleY = 2.5;
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onMasteryClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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

