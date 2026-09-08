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
];
