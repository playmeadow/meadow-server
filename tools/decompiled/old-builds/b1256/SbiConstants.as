package
{
   public class SbiConstants
   {
      
      public static const ACCOUNT_TYPE_ARCHIVED:int = -2;
      
      public static const ACCOUNT_TYPE_NEW:int = -1;
      
      public static const ACCOUNT_TYPE_NONE:int = 0;
      
      public static const NON_MEMBER:int = 1;
      
      public static const PREMIUM_MEMBER:int = 2;
      
      public static const BETA_MEMBER:int = 3;
      
      public static const INTERNAL:int = 4;
      
      public static const COMMUNITY:int = 5;
      
      public static const INTERACTION_TYPE_BUDDY:int = 0;
      
      public static const INTERACTION_TYPE_TRADE:int = 1;
      
      public static const INTERACTION_TYPE_GIFT:int = 2;
      
      public static const INTERACTION_TYPE_CHAT:int = 3;
      
      public static const INTERACTION_TYPE_JAG:int = 4;
      
      public static const INTERACTION_TYPE_MULTIPLAYER:int = 5;
      
      public static const INTERACTION_TYPE_PVP:int = 6;
      
      public static const INTERACTION_TYPE_QUEST:int = 7;
      
      public static const ENVIRO_LAND:int = 0;
      
      public static const ENVIRO_OCEAN:int = 1;
      
      public static const ENVIRO_AIR:int = 2;
      
      public static const ROOMTYPE_WORLD:int = 0;
      
      public static const ROOMTYPE_GAME:int = 1;
      
      public static const ROOMTYPE_DEN:int = 2;
      
      public static const ROOMTYPE_LOBBY:int = 3;
      
      public static const ROOMTYPE_FFM:int = 4;
      
      public static const ROOMTYPE_PARTY:int = 5;
      
      public static const ROOMTYPE_WORLDGAME:int = 6;
      
      public static const ROOMTYPE_QUEST:int = 7;
      
      public static const ROOMTYPE_QUEST_STAGING:int = 8;
      
      public static const CHAT_TYPE_TYPED:int = 0;
      
      public static const CHAT_TYPE_SAFE:int = 1;
      
      public static const CHAT_TYPE_EMOTE:int = 2;
      
      public static const CHAT_TYPE_ACTION:int = 3;
      
      public static const CHAT_TYPE_ATTACHMENT:int = 4;
      
      public static const CHAT_TYPE_PERM_EMOTE:int = 5;
      
      public static const CHAT_TYPE_SLIDE:int = 6;
      
      public static const CHAT_TYPE_PET_ACTION:int = 7;
      
      public static const CHAT_TYPE_BLEND_COLOR:int = 8;
      
      public static const CHAT_TYPE_LIMITED:int = 9;
      
      public static const CHAT_TYPE_ALPHA_LEVEL:int = 10;
      
      public static const CHAT_TYPE_CUST_ADVENTURE:int = 11;
      
      public static const CHAT_TYPE_CUST_PVP:int = 12;
      
      public static const PLAYER_WALL_LOCKED:int = 0;
      
      public static const PLAYER_WALL_BUDDIES:int = 1;
      
      public static const PLAYER_WALL_EVERYONE:int = 2;
      
      public static const PLAYER_WALL_WEB_DISABLED:int = 0;
      
      public static const PLAYER_WALL_WEB_ENABLED:int = 1;
      
      public static const PLAYER_WALL_TOKEN_LOCKED_FAILURE:int = -1;
      
      public static const PLAYER_WALL_TOKEN_BUDDIES_FAILURE:int = -2;
      
      public static const PLAYER_WALL_FAILURE_TOKEN:String = "token";
      
      public static const PLAYER_WALL_FAILURE_UNAVAILABLE:String = "unavailable";
      
      public static const MAX_CONCURRENT_PLAYER_WALL_POSTS:int = 5;
      
      public static const LAYER_BASE_ID:int = 1;
      
      public static const LAYER_PATTERN_ID:int = 2;
      
      public static const LAYER_EYE_ID:int = 3;
      
      public static const GEM_CURRENCY:int = 0;
      
      public static const TICKET_CURRENCY:int = 1;
      
      public static const CRYSTAL_CURRENCY:int = 2;
      
      public static const DIAMOND_CURRENCY:int = 3;
      
      public static const STRAW_CURRENCY:int = 4;
      
      public static const BAMBOO_CURRENCY:int = 5;
      
      public static const WOOD_CURRENCY:int = 6;
      
      public static const STONE_CURRENCY:int = 7;
      
      public static const SILVER_CURRENCY:int = 8;
      
      public static const GOLD_CURRENCY:int = 9;
      
      public static const GEM_STONE_CURRENCY:int = 10;
      
      public static const NUM_CURRENCY_TYPES:int = 11;
      
      public static const COMBINED_CURRENCY:int = 100;
      
      public static const TRADE_OFFER_MAX:int = 20;
      
      public static const CURRENCY_NAMES:Vector.<String> = Vector.<String>(["gems","tickets","orbs","diamonds","straw","bamboo","wood","stone","silver","gold","gemstone"]);
      
      public static const ACHIEVEMENT_TYPE_NAMES:Array = [23527,22833,22834,22835,22836,22825,22837,22826,22838,22854,22856,22839,22840,22859,22850,22841,22857,22842,22827,22851,22843,22852,22844,22853,22828,22855,22829,22845,22858,23528,22830,22846,22847,22831,22832,22848,22849];
      
      public static const USERNAME_REGEX:RegExp = /^[a-zA-z0-9À-ÖØ-öø-ÿ][a-z0-9ß-öø-ÿ]+$/i;
      
      public static const EMAIL_REGEX:RegExp = new RegExp(/^[\w%+\.-]+@(?:[a-zA-Z0-9-]+[\.{1}])+[a-zA-Z]{2,}$/i);
      
      public function SbiConstants()
      {
         super();
      }
   }
}

