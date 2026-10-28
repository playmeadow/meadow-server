package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import loader.MediaHelper;
   
   public class EBookChooser
   {
      
      public static const LAND_TYPE:String = "land";
      
      public static const OCEAN_TYPE:String = "ocean";
      
      public static const AIR_TYPE:String = "air";
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _itemWindowsTop:WindowGenerator;
      
      private var _itemWindowsBottom:WindowGenerator;
      
      private var _currLoaderAppDomain:ApplicationDomain;
      
      private var _type:String;
      
      public function EBookChooser()
      {
         super();
      }
      
      public function init(param1:String, param2:Function) : void
      {
         this._type = param1;
         this._closeCallback = param2;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(3836,this.onPopupLoaded);
      }
      
      public function destroy() : void
      {
         this._closeCallback = null;
         if(this._mediaHelper)
         {
            this._mediaHelper.destroy();
            this._mediaHelper = null;
         }
         if(this._itemWindowsBottom)
         {
            this._itemWindowsBottom.destroy();
         }
         if(this._itemWindowsTop)
         {
            this._itemWindowsTop.destroy();
         }
         if(this._popup)
         {
            DarkenManager.unDarken(this._popup);
            if(Boolean(this._popup.parent) && GuiManager.guiLayer == this._popup.parent)
            {
               GuiManager.guiLayer.removeChild(this._popup);
            }
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._currLoaderAppDomain = param1.loaderInfo.applicationDomain;
            this._popup = MovieClip(param1.getChildAt(0));
            this._popup.logo.gotoAndStop(this._type);
            this._popup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._popup.y = MainFrame.VIEW_HEIGHT * 0.5;
            GuiManager.guiLayer.addChild(this._popup);
            DarkenManager.darken(this._popup);
            this.addEventListeners();
            this.loadBooks();
         }
      }
      
      private function addEventListeners() : void
      {
         this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._popup.xBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
      }
      
      private function loadBooks() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:Array = this.setupBooksObject();
         if(_loc1_ != null)
         {
            _loc2_ = 3;
            _loc3_ = 1;
            _loc4_ = Math.min(_loc2_,_loc1_.length);
            _loc5_ = Math.min(_loc2_,_loc1_.length - _loc4_);
            this._itemWindowsTop = new WindowGenerator();
            this._itemWindowsBottom = new WindowGenerator();
            this._itemWindowsTop.init(_loc2_,_loc3_,_loc4_,12,2,0,ItemWindowBook,_loc1_.slice(0,3),"",null,{"currLoaderAppDomain":this._currLoaderAppDomain},null,false,false);
            this._itemWindowsBottom.init(_loc2_,_loc3_,_loc5_,12,2,0,ItemWindowBook,_loc1_.slice(3,6),"",null,{"currLoaderAppDomain":this._currLoaderAppDomain},null,false,false);
            this._popup.itemWindowTop.addChild(this._itemWindowsTop);
            this._popup.itemWindowBtm.addChild(this._itemWindowsBottom);
         }
      }
      
      private function setupBooksObject() : Array
      {
         switch(this._type)
         {
            case LAND_TYPE:
               return [{
                  "mediaId":3839,
                  "listId":249
               },{
                  "mediaId":3853,
                  "listId":294
               },{
                  "mediaId":3977,
                  "listId":315
               }];
            case OCEAN_TYPE:
               return [{
                  "mediaId":3837,
                  "listId":240
               },{
                  "mediaId":3840,
                  "listId":254
               }];
            case AIR_TYPE:
               return [{
                  "mediaId":3838,
                  "listId":284
               }];
            default:
               return null;
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
      }
      
      private function onItemWindowOver(param1:MouseEvent) : void
      {
      }
      
      private function onItemWindowOut(param1:MouseEvent) : void
      {
      }
   }
}

