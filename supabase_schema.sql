-- ==============================================================================
-- PokéMart Supabase Schema & Seed Script
-- Activity: CS Elective 2 | Flutter E-Commerce Project
-- High-Resolution 3D Datamined Assets (PokeMiners/pogo_assets)
-- ==============================================================================

-- 1. Create Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    image_path TEXT DEFAULT '',
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    sold_count INTEGER DEFAULT 0,
    stock INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. Configure Row Level Security (RLS)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access on products" ON public.products;
CREATE POLICY "Allow public read access on products"
ON public.products
FOR SELECT
USING (true);

-- 3. Seed PokéMart Inventory (48 Authentic High-Res Items across 6 Bag Pockets)
INSERT INTO public.products (id, name, price, image_path, category, description, sold_count, stock)
VALUES
  ('poke-ball', 'Poké Ball', 200.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/pokeball_sprite.png', 'Poké Balls', 'A device for catching wild Pokémon. It is thrown like a ball comfortably at a target, expanding into a capsule to capture.', 950, 999),
  ('great-ball', 'Great Ball', 600.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/greatball_sprite.png', 'Poké Balls', 'A good, high-performance Ball that provides a higher Pokémon catch rate than a standard Poké Ball.', 540, 600),
  ('ultra-ball', 'Ultra Ball', 1200.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/ultraball_sprite.png', 'Poké Balls', 'An ultra-high-performance Ball providing a higher catch rate than a Great Ball. Ideal for challenging wild encounters.', 380, 450),
  ('master-ball', 'Master Ball', 5000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/masterball_sprite.png', 'Poké Balls', 'The best Ball with the ultimate level of performance. With it, you will catch any wild Pokémon without fail.', 12, 10),
  ('premier-ball', 'Premier Ball', 1000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/premierball_sprite.png', 'Poké Balls', 'A somewhat rare Poké Ball made as a commemorative item to celebrate an event or special milestone.', 160, 200),
  ('beast-ball', 'Beast Ball', 4000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/beastball_sprite.png', 'Poké Balls', 'A special Poké Ball designed to catch Ultra Beasts. It has a low success rate for catching standard Pokémon.', 45, 50),
  ('potion', 'Potion', 300.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0101.png', 'Medicine', 'A spray-type medicine for treating wounds. It restores the HP of one Pokémon by 60 points.', 780, 500),
  ('super-potion', 'Super Potion', 700.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0102.png', 'Medicine', 'A high-potency spray-type medicine for treating wounds. Restores the HP of one Pokémon by 120 points.', 520, 350),
  ('hyper-potion', 'Hyper Potion', 1200.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0103.png', 'Medicine', 'An advanced therapeutic spray. Restores the HP of a single Pokémon by up to 200 points.', 340, 250),
  ('max-potion', 'Max Potion', 2500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0104.png', 'Medicine', 'A fully restorative spray-type medicine that completely heals all HP for a single Pokémon.', 160, 120),
  ('revive', 'Revive', 1500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0201.png', 'Medicine', 'A medicine that can be used to revive a fainted Pokémon and restore half of its maximum HP.', 450, 200),
  ('max-revive', 'Max Revive', 4000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0202.png', 'Medicine', 'A rare and potent medicine that revives a fainted Pokémon and fully restores all of its maximum HP.', 90, 50),
  ('sun-stone', 'Sun Stone', 3000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Sun_Stone_Sprite.png', 'Evolution', 'A peculiar stone that can make certain species of Pokémon evolve. It burns as red as the evening sun.', 85, 60),
  ('kings-rock', 'King''s Rock', 3000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_King''s_Rock_Sprite.png', 'Evolution', 'An item to be held by a Pokémon. When the holder inflicts damage, there is a chance the target will flinch.', 70, 45),
  ('metal-coat', 'Metal Coat', 3000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Metal_Coat_Sprite.png', 'Evolution', 'A special metallic film that can make certain species of Pokémon evolve. It also boosts Steel-type moves.', 95, 50),
  ('dragon-scale', 'Dragon Scale', 3000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Dragon_Scale_Sprite.png', 'Evolution', 'A very tough and stiff scale that can make certain Dragon-type Pokémon evolve.', 65, 40),
  ('up-grade', 'Up-Grade', 3000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Up-Grade_Sprite.png', 'Evolution', 'A transparent device overflowing with all sorts of data. It was produced by Silph Co. to upgrade Porygon.', 50, 35),
  ('sinnoh-stone', 'Sinnoh Stone', 5000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Sinnoh_Stone_Sprite.png', 'Evolution', 'A special stone originally found in the Sinnoh region that can make certain species of Pokémon evolve.', 130, 80),
  ('unova-stone', 'Unova Stone', 5000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Bag_Unova_Stone_Sprite.png', 'Evolution', 'A rare stone originally discovered in the Unova region that makes certain species of Pokémon evolve.', 110, 70),
  ('meteorite', 'Meteorite', 4500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_Meteorite.png', 'Evolution', 'A glowing celestial stone charged with cosmic energy from outer space, enabling Rayquaza to learn Dragon Ascent.', 40, 25),
  ('razz-berry', 'Razz Berry', 100.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0701.png', 'Berries & Treats', 'Feed this to a wild Pokémon to make it calmer and easier to catch on your next throw.', 620, 800),
  ('bluk-berry', 'Bluk Berry', 100.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0702.png', 'Berries & Treats', 'A blue berry with a juicy texture. Widely used for cooking savory treats and curries in trainer camps.', 410, 600),
  ('nanab-berry', 'Nanab Berry', 100.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0703.png', 'Berries & Treats', 'Feed this to a Pokémon to calm its movements, preventing it from darting or dodging around.', 390, 500),
  ('poffin', 'Poffin', 350.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0704.png', 'Berries & Treats', 'A delicious pastry baked with care for Pokémon. Feeding this to your buddy fills its hunger meter and maximizes bond and mood.', 560, 158),
  ('pinap-berry', 'Pinap Berry', 150.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0705.png', 'Berries & Treats', 'Feed this to a wild Pokémon to increase the amount of Candy and item rewards you gain upon capture.', 540, 382),
  ('golden-razz-berry', 'Golden Razz Berry', 500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0706.png', 'Berries & Treats', 'A wondrous golden berry that drastically increases the catch rate of any wild Pokémon.', 310, 124),
  ('silver-pinap-berry', 'Silver Pinap Berry', 600.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_0707.png', 'Berries & Treats', 'A lustrous silver berry that both eases capture and doubles the reward upon catching.', 220, 89),
  ('deluxe-poffin', 'Deluxe Poffin', 800.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/poffin.3.png', 'Berries & Treats', 'A freshly baked gourmet treat crafted with choice berries to greatly elevate Pokémon affinity.', 340, 96),
  ('fast-tm', 'Fast TM', 4000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1201.png', 'Battle & Training', 'A Technical Machine that teaches a Pokémon a new fast move to adapt to any battle scenario.', 145, 90),
  ('charged-tm', 'Charged TM', 4000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1202.png', 'Battle & Training', 'A Technical Machine that teaches a Pokémon a new charged attack move.', 160, 90),
  ('elite-fast-tm', 'Elite Fast TM', 5000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1203.png', 'Battle & Training', 'An elite Technical Machine that allows you to choose any fast move for a Pokémon, including legacy moves.', 35, 20),
  ('elite-charged-tm', 'Elite Charged TM', 5000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1204.png', 'Battle & Training', 'An elite Technical Machine that lets you pick any charged move for a Pokémon, including event-exclusive moves.', 40, 20),
  ('rare-candy', 'Rare Candy', 2000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1301.png', 'Battle & Training', 'A candy packed with energy. When consumed by a Pokémon, it instantly raises its level by one.', 480, 350),
  ('rare-candy-xl', 'Rare Candy XL', 5000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/RareXLCandy_PSD.png', 'Battle & Training', 'A supreme candy that surges with tremendous power, raising a Pokémon''s stats beyond normal limits.', 95, 60),
  ('star-piece', 'Star Piece', 2500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/starpiece.png', 'Battle & Training', 'A small shard of a beautiful gem. Shines with starlight and boosts earnings by 50% for 30 minutes.', 210, 120),
  ('lucky-egg', 'Lucky Egg', 3000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/luckyegg.png', 'Battle & Training', 'An egg filled with happiness. Grants double experience points to the trainer for 30 minutes.', 270, 150),
  ('incense', 'Incense', 1000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Incense_0.png', 'Special Gear', 'An aromatic incense that attracts wild Pokémon to your location for 60 minutes.', 320, 200),
  ('daily-adventure-incense', 'Daily Adventure Incense', 2500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/dailyWalking_incense.png', 'Special Gear', 'A special incense that attracts rare and elusive Pokémon while walking for 15 minutes.', 180, 100),
  ('egg-incubator', 'Egg Incubator', 1500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/EggIncubatorUnlimited_Empty.png', 'Special Gear', 'A state-of-the-art incubation capsule that warms and hatches Pokémon eggs as you travel.', 230, 150),
  ('super-incubator', 'Super Incubator', 3000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/EggIncubatorSuper_Empty.png', 'Special Gear', 'A high-performance incubator with thermal enhancers that hatches eggs 33% faster.', 195, 110),
  ('premium-battle-pass', 'Premium Battle Pass', 1000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1402.png', 'Special Gear', 'A digital pass that grants entry to championship Raid Battles and competitive Battle Leagues.', 410, 300),
  ('remote-raid-pass', 'Remote Raid Pass', 2500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_1408.png', 'Special Gear', 'An electronic pass enabling trainers to participate in distant Raid Battles from anywhere.', 560, 400),
  ('lure-module', 'Lure Module', 1000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey.png', 'Special Gear', 'A module that attracts wild Pokémon to a PokéStop or beacon for 30 minutes.', 290, 220),
  ('glacial-lure-module', 'Glacial Lure Module', 1500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_glacial.png', 'Special Gear', 'A frosty module that attracts Water- and Ice-type Pokémon and enables special evolutions.', 140, 90),
  ('magnetic-lure-module', 'Magnetic Lure Module', 1500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_magnetic.png', 'Special Gear', 'An electric module that attracts Electric-, Steel-, and Rock-type Pokémon.', 135, 90),
  ('mossy-lure-module', 'Mossy Lure Module', 1500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_moss.png', 'Special Gear', 'A lush botanical module that attracts Grass-, Bug-, and Poison-type Pokémon.', 125, 90),
  ('rainy-lure-module', 'Rainy Lure Module', 1500.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/TroyKey_rainy.png', 'Special Gear', 'A moist, weather-mimicking module that attracts Water-, Bug-, and Electric-type Pokémon.', 115, 80),
  ('purified-gem', 'Purified Gem', 2000.00, 'https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Items/Item_ShadowGem.png', 'Special Gear', 'A crystal gem refined from shadow shards, used to subdue enraged Pokémon in battle.', 150, 100)
ON CONFLICT (id) DO UPDATE 
SET 
    name = EXCLUDED.name,
    price = EXCLUDED.price,
    image_path = EXCLUDED.image_path,
    category = EXCLUDED.category,
    description = EXCLUDED.description,
    sold_count = EXCLUDED.sold_count,
    stock = EXCLUDED.stock;
