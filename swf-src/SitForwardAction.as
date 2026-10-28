// not in the game: the action sprite of sitting facing forward (":sitS:",
// gui.ActionManager). the game's other actions are sprites of the HUD's art,
// found by their class name; this one has no art of its own, and only its
// class name is ever read.
package gui
{
   import flash.display.Sprite;

   public class SitForwardAction extends Sprite
   {
      public function SitForwardAction()
      {
         super();
      }
   }
}
