package room
{
   import com.sbi.graphics.SortLayer;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   
   public class LayerManager
   {
      
      private var _layer_bkg:DisplayLayer;
      
      private var _layer_room_bkg:DisplayLayer;
      
      private var _layer_room_bkg_group:DisplayLayer;
      
      private var _layer_room_bkg_main:DisplayLayer;
      
      private var _layer_room_avatars:SortLayer;
      
      private var _layer_room_fg:DisplayLayer;
      
      private var _layer_flying_avatars:SortLayer;
      
      private var _layer_room_super_fg:DisplayLayer;
      
      private var _layer_room_chat:DisplayLayer;
      
      private var _layer_room_orbs:DisplayLayer;
      
      private var _layer_worldGame:DisplayLayer;
      
      private var _layer_gui:DisplayLayer;
      
      private var _layer_fps:DisplayLayer;
      
      private var _layer_debug:DisplayLayer;
      
      private var _debugShape:Shape;
      
      public function LayerManager(param1:DisplayObjectContainer, param2:DisplayLayer)
      {
         super();
         this._layer_bkg = new DisplayLayer();
         this._layer_room_bkg = new DisplayLayer();
         this._layer_room_bkg_group = new DisplayLayer();
         this._layer_room_bkg_main = new DisplayLayer();
         this._layer_room_avatars = new SortLayer();
         this._layer_room_fg = new DisplayLayer();
         this._layer_room_super_fg = new DisplayLayer();
         this._layer_flying_avatars = new SortLayer();
         this._layer_room_chat = new DisplayLayer();
         this._layer_room_orbs = new DisplayLayer();
         this._layer_room_orbs.mouseEnabled = false;
         this._layer_worldGame = new DisplayLayer();
         this._layer_gui = new DisplayLayer();
         this._layer_fps = new DisplayLayer();
         param1.addChildAt(this._layer_bkg,param1.getChildIndex(param2));
         this._layer_bkg.addChild(this._layer_room_bkg);
         this._layer_bkg.addChild(this._layer_room_bkg_group);
         this._layer_room_bkg_group.addChild(this._layer_room_bkg_main);
         this._layer_room_bkg_group.addChild(this._layer_room_avatars);
         this._layer_bkg.addChild(this._layer_room_fg);
         this._layer_bkg.addChild(this._layer_flying_avatars);
         this._layer_bkg.addChild(this._layer_room_super_fg);
         this._layer_bkg.addChild(this._layer_room_chat);
         this._layer_bkg.addChild(this._layer_room_orbs);
         this._layer_room_fg.mouseChildren = false;
         this._layer_room_fg.mouseEnabled = false;
         this._layer_room_super_fg.mouseChildren = false;
         this._layer_room_super_fg.mouseEnabled = false;
         param1.addChildAt(this._layer_worldGame,param1.getChildIndex(param2));
         param1.addChildAt(this._layer_gui,param1.getChildIndex(param2));
         this._layer_debug = new DisplayLayer();
         this._layer_fps.addChild(this._layer_debug);
         param1.stage.addChild(this._layer_fps);
         this._debugShape = new Shape();
      }
      
      public function get gui() : DisplayLayer
      {
         return this._layer_gui;
      }
      
      public function get bkg() : DisplayLayer
      {
         return this._layer_bkg;
      }
      
      public function get fps() : DisplayLayer
      {
         return this._layer_fps;
      }
      
      public function get room_bkg_group() : DisplayLayer
      {
         return this._layer_room_bkg_group;
      }
      
      public function get room_bkg_main() : DisplayLayer
      {
         return this._layer_room_bkg_main;
      }
      
      public function get room_bkg() : DisplayLayer
      {
         return this._layer_room_bkg;
      }
      
      public function get room_fg() : DisplayLayer
      {
         return this._layer_room_fg;
      }
      
      public function get room_super_fg() : DisplayLayer
      {
         return this._layer_room_super_fg;
      }
      
      public function get room_avatars() : SortLayer
      {
         return this._layer_room_avatars;
      }
      
      public function get room_chat() : DisplayLayer
      {
         return this._layer_room_chat;
      }
      
      public function get flying_avatars() : SortLayer
      {
         return this._layer_flying_avatars;
      }
      
      public function get room_orbs() : DisplayLayer
      {
         return this._layer_room_orbs;
      }
      
      public function get layer_debug() : DisplayLayer
      {
         return this._layer_debug;
      }
      
      public function get layer_worldGame() : DisplayLayer
      {
         return this._layer_worldGame;
      }
      
      public function get debugShape() : Shape
      {
         return this._debugShape;
      }
   }
}

