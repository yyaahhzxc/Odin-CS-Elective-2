import '../models/product.dart';

/// Static repository containing the initial CSSEC merchandise catalog.
const List<Product> mockProducts = [
  Product(
    id: 'prod-001',
    name: 'CS T-Shirt',
    price: 350.0,
    category: 'Apparel',
    description:
        'Official CS T-Shirt Merch for School Year 2026-2027.',
    soldCount: 142,
    stock: 50,
    variants: [
      ProductVariant(id: 'prod-001-v1', name: 'Violet'),
      ProductVariant(id: 'prod-001-v2', name: 'Black'),
      ProductVariant(id: 'prod-001-v3', name: 'White'),
    ],
  ),
  Product(
    id: 'prod-002',
    name: 'Palarong Atenista CS Jacket',
    price: 1200.0,
    category: 'Apparel',
    description:
        'Heavyweight wool-blend varsity bomber jacket with custom CS embroidered chest patch and ribbed contrast trims.',
    soldCount: 88,
    stock: 25,
    variants: [
      ProductVariant(id: 'prod-002-v1', name: 'Varsity Violet'),
      ProductVariant(
        id: 'prod-002-v2',
        name: 'Stealth Black',
        price: 1250.0,
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
    name: 'Enamel Pin',
    price: 220.0,
    category: 'Accessories',
    description:
        'pin idk.',
    soldCount: 310,
    stock: 120,
    variants: [
      ProductVariant(id: 'prod-004-v1', name: 'Chameleon Logo'),
      ProductVariant(id: 'prod-004-v2', name: 'Monitor Shield'),
      ProductVariant(id: 'prod-004-v3', name: 'Binary CS'),
    ],
  ),
  Product(
    id: 'prod-005',
    name: 'CS Stickers (Assorted)',
    price: 120.0,
    category: 'Accessories',
    description:
        'stickerz.',
    soldCount: 540,
    stock: 200,
    variants: [
      ProductVariant(id: 'prod-005-v1', name: 'Holo Chameleon'),
      ProductVariant(id: 'prod-005-v2', name: 'Python Code'),
      ProductVariant(id: 'prod-005-v3', name: 'Ateneo Crest'),
    ],
  ),
  Product(
    id: 'prod-006',
    name: 'Keychain',
    price: 150.0,
    category: 'Accessories',
    description:
        'keychain wieee',
    soldCount: 265,
    stock: 80,
    variants: [
      ProductVariant(id: 'prod-006-v1', name: 'Purple Acrylic'),
      ProductVariant(id: 'prod-006-v2', name: 'Clear Charm'),
    ],
  ),
];
