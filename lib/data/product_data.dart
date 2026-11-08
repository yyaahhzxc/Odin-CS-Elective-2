import '../models/product.dart';

/// Static repository containing the initial CSSEC merchandise catalog.
const List<Product> mockProducts = [
  Product(
    id: 'prod-001',
    name: 'CS T-Shirt',
    price: 350.0,
    imagePath: 'assets/images/001-shirt/shirt_black_front.png',
    images: [
      'assets/images/001-shirt/shirt_black_front.png',
      'assets/images/001-shirt/shirt_black_back.png',
    ],
    category: 'Apparel',
    description:
        'Official CS T-Shirt Merch for IT Week 2026: Iridescence. Premium cotton blend featuring front chest print and full back graphic art.',
    soldCount: 142,
    stock: 50,
    variants: [
      ProductVariant(
        id: 'prod-001-v1',
        name: 'Black',
        imagePath: 'assets/images/001-shirt/shirt_black_front.png',
        images: [
          'assets/images/001-shirt/shirt_black_front.png',
          'assets/images/001-shirt/shirt_black_back.png',
        ],
      ),
      ProductVariant(
        id: 'prod-001-v2',
        name: 'White',
        imagePath: 'assets/images/001-shirt/shirt_white_front.png',
        images: [
          'assets/images/001-shirt/shirt_white_front.png',
          'assets/images/001-shirt/shirt_white_back.png',
        ],
      ),
      ProductVariant(
        id: 'prod-001-v3',
        name: 'Violet',
        imagePath: 'assets/images/001-shirt/shirt_violet_front.png',
        images: [
          'assets/images/001-shirt/shirt_violet_front.png',
          'assets/images/001-shirt/shirt_violet_back.png',
        ],
      ),
    ],
  ),
  Product(
    id: 'prod-002',
    name: 'Palarong Atenista CS Jacket',
    price: 1200.0,
    imagePath: 'assets/images/002-jacket/jacket_variant_1.png',
    images: [
      'assets/images/002-jacket/jacket_variant_1.png',
    ],
    category: 'Apparel',
    description:
        'Heavyweight wool-blend varsity bomber jacket with custom CS embroidered chest patch and ribbed contrast trims.',
    soldCount: 88,
    stock: 25,
    variants: [
      ProductVariant(
        id: 'prod-002-v1',
        name: 'Varsity Violet (White Panel)',
        imagePath: 'assets/images/002-jacket/jacket_variant_1.png',
        images: [
          'assets/images/002-jacket/jacket_variant_1.png',
        ],
      ),
      ProductVariant(
        id: 'prod-002-v2',
        name: 'Stealth Violet (Purple Panel)',
        price: 1250.0,
        imagePath: 'assets/images/002-jacket/jacket_variant_2.png',
        images: [
          'assets/images/002-jacket/jacket_variant_2.png',
        ],
      ),
    ],
  ),
  Product(
    id: 'prod-003',
    name: 'Palarong Atenista CS Jersey',
    price: 350,
    imagePath: 'assets/images/003-jersey/sleeved_purple_front.png',
    images: [
      'assets/images/003-jersey/sleeved_purple_front.png',
      'assets/images/003-jersey/sleeved_purple_back.png',
    ],
    category: 'Apparel',
    description:
        'Breathable dry-fit jersey, designed to be worn for Palarong Atenista 2026. Includes custom naming and jersey number on the back.',
    soldCount: 95,
    stock: 30,
    variants: [
      ProductVariant(
        id: 'prod-003-v1',
        name: 'Sleeved Jersey (Purple)',
        images: [
          'assets/images/003-jersey/sleeved_purple_front.png',
          'assets/images/003-jersey/sleeved_purple_back.png',
        ],
      ),
      ProductVariant(
        id: 'prod-003-v2',
        name: 'Sleeved White',
        price: 999999,
        images: [
          'assets/images/003-jersey/sleeved_white_front.png',
          'assets/images/003-jersey/sleeved_white_back.png',
        ],
      ),
    ],
  ),
  Product(
    id: 'prod-004',
    name: 'CS Button Pin',
    price: 50.0,
    imagePath: 'assets/images/004-pin/pin_robot.png',
    images: [
      'assets/images/004-pin/pin_robot.png',
    ],
    category: 'Accessories',
    description:
        'Official IT Week 2026 button pin with glossy finish and sturdy safety pin backing.',
    soldCount: 310,
    stock: 120,
    variants: [
      ProductVariant(
        id: 'prod-004-v1',
        name: 'Robot Companion',
        imagePath: 'assets/images/004-pin/pin_robot.png',
        images: [
          'assets/images/004-pin/pin_robot.png',
        ],
      ),
      ProductVariant(
        id: 'prod-004-v2',
        name: 'CS Student',
        imagePath: 'assets/images/004-pin/pin_student.png',
        images: [
          'assets/images/004-pin/pin_student.png',
        ],
      ),
    ],
  ),
  Product(
    id: 'prod-005',
    name: 'CS Stickers',
    price: 15.0,
    imagePath: 'assets/images/005-sticker/sticker_frog_hood.png',
    images: [
      'assets/images/005-sticker/sticker_frog_hood.png',
    ],
    category: 'Accessories',
    description:
        'Waterproof die-cut vinyl sticker with laminate finish, ideal for laptops, water bottles, and gear.',
    soldCount: 540,
    stock: 200,
    variants: [
      ProductVariant(
        id: 'prod-005-v1',
        name: 'Frog Hood Chibi',
        imagePath: 'assets/images/005-sticker/sticker_frog_hood.png',
        images: [
          'assets/images/005-sticker/sticker_frog_hood.png',
        ],
      ),
      ProductVariant(
        id: 'prod-005-v2',
        name: 'Exhausted Student',
        imagePath: 'assets/images/005-sticker/sticker_exhausted_student.png',
        images: [
          'assets/images/005-sticker/sticker_exhausted_student.png',
        ],
      ),
    ],
  ),
  Product(
    id: 'prod-006',
    name: 'CS Keychain',
    price: 75.0,
    imagePath: 'assets/images/006-keychain/keychain_chibi.png',
    images: [
      'assets/images/006-keychain/keychain_chibi.png',
    ],
    category: 'Accessories',
    description:
        'Durable clear acrylic keychain featuring the official CS mascot with vibrant double-sided print and silver swivel clasp.',
    soldCount: 265,
    stock: 80,
    variants: [
      ProductVariant(
        id: 'prod-006-v1',
        name: 'CS Mascot Chibi',
        imagePath: 'assets/images/006-keychain/keychain_chibi.png',
        images: [
          'assets/images/006-keychain/keychain_chibi.png',
        ],
      ),
    ],
  ),
  Product(
    id: 'prod-007',
    name: 'CSSEC Lanyard (Iridescence)',
    price: 120.0,
    imagePath: '',
    category: 'Accessories',
    description:
        'Satin ribbon lanyard with CSSEC 2026 Iridescence graphics, metal clip, and safety breakaway buckle.',
    soldCount: 45,
    stock: 80,
  ),
  Product(
    id: 'prod-008',
    name: 'CSSEC Embroidered Cap',
    price: 280.0,
    imagePath: '',
    category: 'Apparel',
    description:
        'Classic baseball cap featuring embroidered CSSEC crest with adjustable brass metal strap.',
    soldCount: 30,
    stock: 40,
  ),
  Product(
    id: 'prod-009',
    name: 'CSSEC Canvas Tote Bag',
    price: 220.0,
    imagePath: '',
    category: 'Accessories',
    description:
        'Heavy duty 12oz canvas tote bag with reinforced straps, built for laptops and textbooks.',
    soldCount: 65,
    stock: 50,
  ),
  Product(
    id: 'prod-010',
    name: 'CSSEC Insulated Water Bottle',
    price: 650.0,
    imagePath: '',
    category: 'Accessories',
    description:
        'Double-wall vacuum insulated 750ml stainless steel water bottle with laser-engraved CS monogram.',
    soldCount: 28,
    stock: 35,
  ),
  Product(
    id: 'prod-011',
    name: 'CSSEC Windbreaker Jacket',
    price: 950.0,
    imagePath: '',
    category: 'Apparel',
    description:
        'Lightweight water-resistant windbreaker jacket with reflective accents and zippered hood.',
    soldCount: 18,
    stock: 20,
  ),
  Product(
    id: 'prod-012',
    name: 'CSSEC Oversized Hoodie',
    price: 890.0,
    imagePath: '',
    category: 'Apparel',
    description:
        'Heavyweight fleece hoodie in violet with dropped shoulders and spacious kangaroo pocket.',
    soldCount: 52,
    stock: 25,
  ),
  Product(
    id: 'prod-013',
    name: 'CSSEC Enamel Lapel Pin',
    price: 75.0,
    imagePath: '',
    category: 'Accessories',
    description:
        'Gold-plated hard enamel pin with dual clutch backing, ideal for bags and ID straps.',
    soldCount: 80,
    stock: 70,
  ),
  Product(
    id: 'prod-014',
    name: 'CSSEC Desk Mat / Mousepad',
    price: 450.0,
    imagePath: '',
    category: 'Accessories',
    description:
        'Extended 900x400mm gaming mousepad with anti-fray stitched edges and micro-woven surface.',
    soldCount: 40,
    stock: 30,
  ),
  Product(
    id: 'prod-015',
    name: 'CSSEC Tech Cable Organizer',
    price: 320.0,
    imagePath: '',
    category: 'Accessories',
    description:
        'Water-resistant compact pouch with elastic loops and mesh dividers for chargers and dongles.',
    soldCount: 22,
    stock: 45,
  ),
  Product(
    id: 'prod-016',
    name: 'CSSEC Crewneck Sweatshirt',
    price: 750.0,
    imagePath: '',
    category: 'Apparel',
    description:
        'Soft-touch pre-shrunk fleece sweater with minimalist typographic CSSEC chest emblem.',
    soldCount: 34,
    stock: 25,
  ),
  Product(
    id: 'prod-017',
    name: 'CSSEC Reversible Bucket Hat',
    price: 260.0,
    imagePath: '',
    category: 'Apparel',
    description:
        'Two-tone reversible cotton twill bucket hat in deep purple and stealth black.',
    soldCount: 15,
    stock: 30,
  ),
  Product(
    id: 'prod-018',
    name: 'CSSEC Etched Metal Bookmark',
    price: 50.0,
    imagePath: '',
    category: 'Accessories',
    description:
        'Laser-cut stainless steel bookmark with decorative violet tassel.',
    soldCount: 90,
    stock: 100,
  ),
];
