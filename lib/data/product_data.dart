import '../models/product.dart';

/// Static repository containing the authentic PokéMart (Galar Region) merchandise catalog.
///
/// Curated with official high-resolution 3D rendered assets from PokeMiners/pogo_assets
/// across 6 authentic Pokémon Sword & Shield Bag pockets.
const List<Product> mockProducts = [
  // ---------------------------------------------------------------------------
  // POKÉ BALLS (6 Items)
  // ---------------------------------------------------------------------------
  Product(
    id: 'poke-ball',
    name: 'Poké Ball',
    price: 200.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/pokeball_sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/pokeball_sprite.png',
    ],
    category: 'Poké Balls',
    description:
        'A device for catching wild Pokémon. It is thrown like a ball comfortably at a target, expanding into a capsule to capture.',
    soldCount: 950,
    stock: 999,
  ),
  Product(
    id: 'great-ball',
    name: 'Great Ball',
    price: 600.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/greatball_sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/greatball_sprite.png',
    ],
    category: 'Poké Balls',
    description:
        'A good, high-performance Ball that provides a higher Pokémon catch rate than a standard Poké Ball.',
    soldCount: 540,
    stock: 600,
  ),
  Product(
    id: 'ultra-ball',
    name: 'Ultra Ball',
    price: 1200.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/ultraball_sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/ultraball_sprite.png',
    ],
    category: 'Poké Balls',
    description:
        'An ultra-high-performance Ball providing a higher catch rate than a Great Ball. Ideal for challenging wild encounters in Galar.',
    soldCount: 380,
    stock: 450,
  ),
  Product(
    id: 'master-ball',
    name: 'Master Ball',
    price: 5000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/masterball_sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/masterball_sprite.png',
    ],
    category: 'Poké Balls',
    description:
        'The best Ball with the ultimate level of performance. With it, you will catch any wild Pokémon without fail.',
    soldCount: 12,
    stock: 10,
  ),
  Product(
    id: 'premier-ball',
    name: 'Premier Ball',
    price: 1000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/premierball_sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/premierball_sprite.png',
    ],
    category: 'Poké Balls',
    description:
        'A somewhat rare Poké Ball made as a commemorative item to celebrate an event or special milestone.',
    soldCount: 160,
    stock: 200,
  ),
  Product(
    id: 'beast-ball',
    name: 'Beast Ball',
    price: 4000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/beastball_sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/beastball_sprite.png',
    ],
    category: 'Poké Balls',
    description:
        'A special Poké Ball designed to catch Ultra Beasts. It has a low success rate for catching standard Pokémon.',
    soldCount: 45,
    stock: 50,
  ),

  // ---------------------------------------------------------------------------
  // MEDICINE (6 Items)
  // ---------------------------------------------------------------------------
  Product(
    id: 'potion',
    name: 'Potion',
    price: 300.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0101.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0101.png',
    ],
    category: 'Medicine',
    description:
        'A spray-type medicine for treating wounds. It restores the HP of one Pokémon by 60 points.',
    soldCount: 780,
    stock: 500,
  ),
  Product(
    id: 'super-potion',
    name: 'Super Potion',
    price: 700.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0102.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0102.png',
    ],
    category: 'Medicine',
    description:
        'A high-potency spray-type medicine for treating wounds. Restores the HP of one Pokémon by 120 points.',
    soldCount: 520,
    stock: 350,
  ),
  Product(
    id: 'hyper-potion',
    name: 'Hyper Potion',
    price: 1200.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0103.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0103.png',
    ],
    category: 'Medicine',
    description:
        'An advanced therapeutic spray. Restores the HP of a single Pokémon by up to 200 points.',
    soldCount: 340,
    stock: 250,
  ),
  Product(
    id: 'max-potion',
    name: 'Max Potion',
    price: 2500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0104.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0104.png',
    ],
    category: 'Medicine',
    description:
        'A fully restorative spray-type medicine that completely heals all HP for a single Pokémon.',
    soldCount: 160,
    stock: 120,
  ),
  Product(
    id: 'revive',
    name: 'Revive',
    price: 1500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0201.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0201.png',
    ],
    category: 'Medicine',
    description:
        'A medicine that can be used to revive a fainted Pokémon and restore half of its maximum HP.',
    soldCount: 450,
    stock: 200,
  ),
  Product(
    id: 'max-revive',
    name: 'Max Revive',
    price: 4000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0202.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0202.png',
    ],
    category: 'Medicine',
    description:
        'A rare and potent medicine that revives a fainted Pokémon and fully restores all of its maximum HP.',
    soldCount: 90,
    stock: 50,
  ),

  // ---------------------------------------------------------------------------
  // EVOLUTION (8 Items)
  // ---------------------------------------------------------------------------
  Product(
    id: 'sun-stone',
    name: 'Sun Stone',
    price: 3000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Sun_Stone_Sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Sun_Stone_Sprite.png',
    ],
    category: 'Evolution',
    description:
        'A peculiar stone that can make certain species of Pokémon evolve. It burns as red as the evening sun.',
    soldCount: 85,
    stock: 60,
  ),
  Product(
    id: 'kings-rock',
    name: "King's Rock",
    price: 3000.0,
    imagePath:
        "https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_King's_Rock_Sprite.png",
    images: [
      "https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_King's_Rock_Sprite.png",
    ],
    category: 'Evolution',
    description:
        'An item to be held by a Pokémon. When the holder inflicts damage, there is a chance the target will flinch.',
    soldCount: 70,
    stock: 45,
  ),
  Product(
    id: 'metal-coat',
    name: 'Metal Coat',
    price: 3000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Metal_Coat_Sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Metal_Coat_Sprite.png',
    ],
    category: 'Evolution',
    description:
        'A special metallic film that can make certain species of Pokémon evolve. It also boosts Steel-type moves.',
    soldCount: 95,
    stock: 50,
  ),
  Product(
    id: 'dragon-scale',
    name: 'Dragon Scale',
    price: 3000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Dragon_Scale_Sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Dragon_Scale_Sprite.png',
    ],
    category: 'Evolution',
    description:
        'A very tough and stiff scale that can make certain Dragon-type Pokémon evolve.',
    soldCount: 65,
    stock: 40,
  ),
  Product(
    id: 'up-grade',
    name: 'Up-Grade',
    price: 3000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Up-Grade_Sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Up-Grade_Sprite.png',
    ],
    category: 'Evolution',
    description:
        'A transparent device overflowing with all sorts of data. It was produced by Silph Co. to upgrade Porygon.',
    soldCount: 50,
    stock: 35,
  ),
  Product(
    id: 'sinnoh-stone',
    name: 'Sinnoh Stone',
    price: 5000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Sinnoh_Stone_Sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Sinnoh_Stone_Sprite.png',
    ],
    category: 'Evolution',
    description:
        'A special stone originally found in the Sinnoh region that can make certain species of Pokémon evolve.',
    soldCount: 130,
    stock: 80,
  ),
  Product(
    id: 'unova-stone',
    name: 'Unova Stone',
    price: 5000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Unova_Stone_Sprite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Unova_Stone_Sprite.png',
    ],
    category: 'Evolution',
    description:
        'A rare stone originally discovered in the Unova region that makes certain species of Pokémon evolve.',
    soldCount: 110,
    stock: 70,
  ),
  Product(
    id: 'meteorite',
    name: 'Meteorite',
    price: 4500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_Meteorite.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_Meteorite.png',
    ],
    category: 'Evolution',
    description:
        'A glowing celestial stone charged with cosmic energy from outer space, enabling Rayquaza to learn Dragon Ascent.',
    soldCount: 40,
    stock: 25,
  ),

  // ---------------------------------------------------------------------------
  // BERRIES & TREATS (8 Items)
  // ---------------------------------------------------------------------------
  Product(
    id: 'razz-berry',
    name: 'Razz Berry',
    price: 100.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0701.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0701.png',
    ],
    category: 'Berries & Treats',
    description:
        'Feed this to a wild Pokémon to make it calmer and easier to catch on your next throw.',
    soldCount: 620,
    stock: 800,
  ),
  Product(
    id: 'bluk-berry',
    name: 'Bluk Berry',
    price: 100.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0702.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0702.png',
    ],
    category: 'Berries & Treats',
    description:
        'A blue berry with a juicy texture. Widely used for cooking savory curries in Galar camps.',
    soldCount: 410,
    stock: 600,
  ),
  Product(
    id: 'nanab-berry',
    name: 'Nanab Berry',
    price: 100.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0703.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0703.png',
    ],
    category: 'Berries & Treats',
    description:
        'Feed this to a Pokémon to calm its movements, preventing it from darting or dodging around.',
    soldCount: 390,
    stock: 500,
  ),
  Product(
    id: 'wepear-berry',
    name: 'Wepear Berry',
    price: 100.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0704.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0704.png',
    ],
    category: 'Berries & Treats',
    description:
        'A crisp, crunchy berry with an astringent flavor that makes curry tangy and flavorful.',
    soldCount: 280,
    stock: 400,
  ),
  Product(
    id: 'pinap-berry',
    name: 'Pinap Berry',
    price: 150.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0705.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0705.png',
    ],
    category: 'Berries & Treats',
    description:
        'Feed this to a wild Pokémon to increase the amount of Candy and item rewards you gain upon capture.',
    soldCount: 540,
    stock: 650,
  ),
  Product(
    id: 'golden-razz-berry',
    name: 'Golden Razz Berry',
    price: 500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0706.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0706.png',
    ],
    category: 'Berries & Treats',
    description:
        'A wondrous golden berry that drastically increases the catch rate of any wild Pokémon.',
    soldCount: 310,
    stock: 300,
  ),
  Product(
    id: 'silver-pinap-berry',
    name: 'Silver Pinap Berry',
    price: 600.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0707.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0707.png',
    ],
    category: 'Berries & Treats',
    description:
        'A lustrous silver berry that both eases capture and doubles the reward upon catching.',
    soldCount: 220,
    stock: 250,
  ),
  Product(
    id: 'poffin',
    name: 'Poffin',
    price: 800.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/poffin.3.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/poffin.3.png',
    ],
    category: 'Berries & Treats',
    description:
        'A delicious snack pastry baked for Pokémon to maximize their friendship, bond, and mood.',
    soldCount: 340,
    stock: 200,
  ),

  // ---------------------------------------------------------------------------
  // BATTLE & TRAINING (8 Items)
  // ---------------------------------------------------------------------------
  Product(
    id: 'fast-tm',
    name: 'Fast TM',
    price: 4000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1201.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1201.png',
    ],
    category: 'Battle & Training',
    description:
        'A Technical Machine that teaches a Pokémon a new fast move to adapt to any battle scenario.',
    soldCount: 145,
    stock: 90,
  ),
  Product(
    id: 'charged-tm',
    name: 'Charged TM',
    price: 4000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1202.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1202.png',
    ],
    category: 'Battle & Training',
    description:
        'A Technical Machine that teaches a Pokémon a new charged attack move.',
    soldCount: 160,
    stock: 90,
  ),
  Product(
    id: 'elite-fast-tm',
    name: 'Elite Fast TM',
    price: 5000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1203.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1203.png',
    ],
    category: 'Battle & Training',
    description:
        'An elite Technical Machine that allows you to choose any fast move for a Pokémon, including legacy moves.',
    soldCount: 35,
    stock: 20,
  ),
  Product(
    id: 'elite-charged-tm',
    name: 'Elite Charged TM',
    price: 5000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1204.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1204.png',
    ],
    category: 'Battle & Training',
    description:
        'An elite Technical Machine that lets you pick any charged move for a Pokémon, including event-exclusive moves.',
    soldCount: 40,
    stock: 20,
  ),
  Product(
    id: 'rare-candy',
    name: 'Rare Candy',
    price: 2000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1301.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1301.png',
    ],
    category: 'Battle & Training',
    description:
        'A candy packed with energy. When consumed by a Pokémon, it instantly raises its level by one.',
    soldCount: 480,
    stock: 350,
  ),
  Product(
    id: 'rare-candy-xl',
    name: 'Rare Candy XL',
    price: 5000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/RareXLCandy_PSD.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/RareXLCandy_PSD.png',
    ],
    category: 'Battle & Training',
    description:
        'A supreme candy that surges with tremendous power, raising a Pokémon\'s stats beyond normal limits.',
    soldCount: 95,
    stock: 60,
  ),
  Product(
    id: 'star-piece',
    name: 'Star Piece',
    price: 2500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/starpiece.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/starpiece.png',
    ],
    category: 'Battle & Training',
    description:
        'A small shard of a beautiful gem. Shines with starlight and boosts earnings by 50% for 30 minutes.',
    soldCount: 210,
    stock: 120,
  ),
  Product(
    id: 'lucky-egg',
    name: 'Lucky Egg',
    price: 3000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/luckyegg.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/luckyegg.png',
    ],
    category: 'Battle & Training',
    description:
        'An egg filled with happiness. Grants double experience points to the trainer for 30 minutes.',
    soldCount: 270,
    stock: 150,
  ),

  // ---------------------------------------------------------------------------
  // SPECIAL GEAR (12 Items)
  // ---------------------------------------------------------------------------
  Product(
    id: 'incense',
    name: 'Incense',
    price: 1000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Incense_0.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Incense_0.png',
    ],
    category: 'Special Gear',
    description:
        'An aromatic incense that attracts wild Pokémon to your location for 60 minutes.',
    soldCount: 320,
    stock: 200,
  ),
  Product(
    id: 'daily-adventure-incense',
    name: 'Daily Adventure Incense',
    price: 2500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/dailyWalking_incense.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/dailyWalking_incense.png',
    ],
    category: 'Special Gear',
    description:
        'A special incense that attracts rare and elusive Pokémon while walking for 15 minutes.',
    soldCount: 180,
    stock: 100,
  ),
  Product(
    id: 'egg-incubator',
    name: 'Egg Incubator',
    price: 1500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/EggIncubatorUnlimited_Empty.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/EggIncubatorUnlimited_Empty.png',
    ],
    category: 'Special Gear',
    description:
        'A state-of-the-art incubation capsule that warms and hatches Pokémon eggs as you travel.',
    soldCount: 230,
    stock: 150,
  ),
  Product(
    id: 'super-incubator',
    name: 'Super Incubator',
    price: 3000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/EggIncubatorSuper_Empty.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/EggIncubatorSuper_Empty.png',
    ],
    category: 'Special Gear',
    description:
        'A high-performance incubator with thermal enhancers that hatches eggs 33% faster.',
    soldCount: 195,
    stock: 110,
  ),
  Product(
    id: 'premium-battle-pass',
    name: 'Premium Battle Pass',
    price: 1000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1402.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1402.png',
    ],
    category: 'Special Gear',
    description:
        'A digital pass that grants entry to championship Raid Battles and competitive Battle Leagues.',
    soldCount: 410,
    stock: 300,
  ),
  Product(
    id: 'remote-raid-pass',
    name: 'Remote Raid Pass',
    price: 2500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1408.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1408.png',
    ],
    category: 'Special Gear',
    description:
        'An electronic pass enabling trainers to participate in distant Raid Battles from anywhere in Galar.',
    soldCount: 560,
    stock: 400,
  ),
  Product(
    id: 'lure-module',
    name: 'Lure Module',
    price: 1000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey.png',
    ],
    category: 'Special Gear',
    description:
        'A module that attracts wild Pokémon to a PokéStop or beacon for 30 minutes.',
    soldCount: 290,
    stock: 220,
  ),
  Product(
    id: 'glacial-lure-module',
    name: 'Glacial Lure Module',
    price: 1500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_glacial.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_glacial.png',
    ],
    category: 'Special Gear',
    description:
        'A frosty module that attracts Water- and Ice-type Pokémon and enables special evolutions.',
    soldCount: 140,
    stock: 90,
  ),
  Product(
    id: 'magnetic-lure-module',
    name: 'Magnetic Lure Module',
    price: 1500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_magnetic.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_magnetic.png',
    ],
    category: 'Special Gear',
    description:
        'An electric module that attracts Electric-, Steel-, and Rock-type Pokémon.',
    soldCount: 135,
    stock: 90,
  ),
  Product(
    id: 'mossy-lure-module',
    name: 'Mossy Lure Module',
    price: 1500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_moss.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_moss.png',
    ],
    category: 'Special Gear',
    description:
        'A lush botanical module that attracts Grass-, Bug-, and Poison-type Pokémon.',
    soldCount: 125,
    stock: 90,
  ),
  Product(
    id: 'rainy-lure-module',
    name: 'Rainy Lure Module',
    price: 1500.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_rainy.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_rainy.png',
    ],
    category: 'Special Gear',
    description:
        'A moist, weather-mimicking module that attracts Water-, Bug-, and Electric-type Pokémon.',
    soldCount: 115,
    stock: 80,
  ),
  Product(
    id: 'purified-gem',
    name: 'Purified Gem',
    price: 2000.0,
    imagePath:
        'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_ShadowGem.png',
    images: [
      'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_ShadowGem.png',
    ],
    category: 'Special Gear',
    description:
        'A crystal gem refined from shadow shards, used to subdue enraged Pokémon in battle.',
    soldCount: 150,
    stock: 100,
  ),
];
