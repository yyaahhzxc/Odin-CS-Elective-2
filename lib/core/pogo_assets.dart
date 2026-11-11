/// Official datamined asset endpoints directly sourced from the PokeMiners repository
/// (https://github.com/PokeMiners/pogo_assets).
class PogoAssets {
  PogoAssets._();

  static const String cdnBase =
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images';

  // --- Brand Logos ---
  static const String logo = '$cdnBase/Logos/PokemonGOLogo.png';
  static const String logoWhiteOutline =
      '$cdnBase/Logos/pokemongo_logo_white_outline.png';
  static const String pokemonLogo = '$cdnBase/Logos/pokemon_logo_en.png';

  // --- Official HUD & Menu Icons ---
  static const String btnShop = '$cdnBase/Menu%20Icons/btn_shop.png';
  static const String btnItems = '$cdnBase/Menu%20Icons/btn_items.png';
  static const String btnCoinsSmall =
      '$cdnBase/Menu%20Icons/btn_coins_small.png';
  static const String btnCloseNormal =
      '$cdnBase/Menu%20Icons/btn_close_normal.png';
  static const String btnPokeballShadow =
      '$cdnBase/Menu%20Icons/btn_pokeball_white_shadow.png';
  static const String btnActionMenu =
      '$cdnBase/Menu%20Icons/btn_action_menu.png';
  static const String iconCheck = '$cdnBase/Menu%20Icons/btn_check_mark.png';

  // --- In-Game Shop Banners & Sky Backgrounds ---
  static const String bannerSearchingForGold =
      '$cdnBase/Shop%20Images/PGO_Searching_for_Gold.jpg';
  static const String bannerShopSale =
      '$cdnBase/Shop%20Images/PGO_Avatar_Shop_Sale.jpg';
  static const String bgSkyGradient =
      '$cdnBase/Backgrounds/gradient_bg_blue_02.png';

  // --- Official Event & Bundle Boxes ---
  static const String boxGreat = '$cdnBase/Boxes/greatbox.png';
  static const String boxUltra = '$cdnBase/Boxes/ultrabox.png';
  static const String boxAdventure = '$cdnBase/Boxes/adventure_box.png';
  static const String boxSpecial = '$cdnBase/Boxes/specialbox.png';

  // --- Social / 3rd-Party OAuth Provider Badges (for Supabase Auth Activity) ---
  static const String oauthGoogle = '$cdnBase/Logos/GoogleLogo.png';
  static const String oauthFacebook = '$cdnBase/Logos/FacebookLogo.png';
  static const String oauthApple =
      '$cdnBase/Logos/ui_settings_social_apple_active.png';
}

