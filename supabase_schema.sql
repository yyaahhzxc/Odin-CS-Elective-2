-- ==============================================================================
-- CSShop Supabase Schema & Seed Script
-- Activity: CS Elective 2 | Supabase-Flutter Activity (Price Filter + Pagination)
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
-- As covered in lecture slides 30 & 41, RLS is enabled by default.
-- We must explicitly grant read access to anonymous public users.
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access on products" ON public.products;
CREATE POLICY "Allow public read access on products"
ON public.products
FOR SELECT
USING (true);

-- 3. Seed Initial & Placeholder Products (18 Total Products for Pagination Testing)
INSERT INTO public.products (id, name, price, image_path, category, description, sold_count, stock)
VALUES
    -- Base catalog items with assets
    ('prod-001', 'CS T-Shirt', 350.00, 'assets/images/001-shirt/shirt_black_front.png', 'Apparel', 'Official CS T-Shirt Merch for IT Week 2026: Iridescence. Premium cotton blend featuring front chest print and full back graphic art.', 142, 50),
    ('prod-002', 'Palarong Atenista CS Jacket', 1200.00, 'assets/images/002-jacket/jacket_variant_1.png', 'Apparel', 'Heavyweight wool-blend varsity bomber jacket with custom CS embroidered chest patch and ribbed contrast trims.', 88, 25),
    ('prod-003', 'Palarong Atenista CS Jersey', 350.00, 'assets/images/003-jersey/sleeved_purple_front.png', 'Apparel', 'Breathable dry-fit jersey, designed to be worn for Palarong Atenista 2026. Includes custom naming and jersey number on the back.', 95, 30),
    ('prod-004', 'CSSEC Button Pin', 40.00, 'assets/images/004-pin/pin_variant_1.png', 'Accessories', 'High-gloss acrylic button pin with safety pin clasp, featuring exclusive CSSEC IT Week 2026 badge graphics.', 210, 100),
    ('prod-005', 'CSSEC Vinyl Sticker Pack', 45.00, 'assets/images/005-sticker/sticker_variant_1.png', 'Accessories', 'Waterproof die-cut vinyl sticker pack with matte UV laminate finish. Scratch-resistant for laptops, tumblers, and notebooks.', 320, 150),
    ('prod-006', 'CS Mascot Acrylic Keychain', 80.00, 'assets/images/006-keychain/mascot_keychain.png', 'Accessories', 'Double-sided transparent acrylic charm keychain featuring the official CS mascot with silver keyring attachment.', 175, 60),

    -- Additional placeholder items (no image assets, testing pagination & price filtering)
    ('prod-007', 'CSSEC Lanyard (Iridescence)', 120.00, '', 'Accessories', 'Satin ribbon lanyard with CSSEC 2026 Iridescence graphics, metal clip, and safety breakaway buckle.', 45, 80),
    ('prod-008', 'CSSEC Embroidered Cap', 280.00, '', 'Apparel', 'Classic baseball cap featuring embroidered CSSEC crest with adjustable brass metal strap.', 30, 40),
    ('prod-009', 'CSSEC Canvas Tote Bag', 220.00, '', 'Accessories', 'Heavy duty 12oz canvas tote bag with reinforced straps, built for laptops and textbooks.', 65, 50),
    ('prod-010', 'CSSEC Insulated Water Bottle', 650.00, '', 'Accessories', 'Double-wall vacuum insulated 750ml stainless steel water bottle with laser-engraved CS monogram.', 28, 35),
    ('prod-011', 'CSSEC Windbreaker Jacket', 950.00, '', 'Apparel', 'Lightweight water-resistant windbreaker jacket with reflective accents and zippered hood.', 18, 20),
    ('prod-012', 'CSSEC Oversized Hoodie', 890.00, '', 'Apparel', 'Heavyweight fleece hoodie in violet with dropped shoulders and spacious kangaroo pocket.', 52, 25),
    ('prod-013', 'CSSEC Enamel Lapel Pin', 75.00, '', 'Accessories', 'Gold-plated hard enamel pin with dual clutch backing, ideal for bags and ID straps.', 80, 70),
    ('prod-014', 'CSSEC Desk Mat / Mousepad', 450.00, '', 'Accessories', 'Extended 900x400mm gaming mousepad with anti-fray stitched edges and micro-woven surface.', 40, 30),
    ('prod-015', 'CSSEC Tech Cable Organizer', 320.00, '', 'Accessories', 'Water-resistant compact pouch with elastic loops and mesh dividers for chargers and dongles.', 22, 45),
    ('prod-016', 'CSSEC Crewneck Sweatshirt', 750.00, '', 'Apparel', 'Soft-touch pre-shrunk fleece sweater with minimalist typographic CSSEC chest emblem.', 34, 25),
    ('prod-017', 'CSSEC Reversible Bucket Hat', 260.00, '', 'Apparel', 'Two-tone reversible cotton twill bucket hat in deep purple and stealth black.', 15, 30),
    ('prod-018', 'CSSEC Etched Metal Bookmark', 50.00, '', 'Accessories', 'Laser-cut stainless steel bookmark with decorative violet tassel.', 90, 100)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    price = EXCLUDED.price,
    image_path = EXCLUDED.image_path,
    category = EXCLUDED.category,
    description = EXCLUDED.description,
    sold_count = EXCLUDED.sold_count,
    stock = EXCLUDED.stock;

