import '../models/product.dart';

/// Static repository containing the initial CSSEC merchandise catalog.
const List<Product> mockProducts = [
  Product(
    id: 'prod-001',
    name: 'CSSEC Chameleon Classic T-Shirt',
    price: 350.0,
    imagePath: 'assets/images/shirt.jpg',
    category: 'Apparel',
    description:
        'Official Ateneo CS Student Executive Council premium cotton t-shirt featuring the signature geometric chameleon logo and clean typographic accents.',
    soldCount: 142,
    stock: 50,
  ),
  Product(
    id: 'prod-002',
    name: 'CSSEC Chameleon Varsity Jacket',
    price: 1200.0,
    imagePath: 'assets/images/jacket.jpg',
    category: 'Apparel',
    description:
        'Heavyweight wool-blend varsity bomber jacket with custom CSSEC embroidered chest patch, vegan leather sleeves, and ribbed contrast trims.',
    soldCount: 88,
    stock: 25,
  ),
  Product(
    id: 'prod-003',
    name: 'CSSEC Cyber Esports Jersey',
    price: 650.0,
    imagePath: 'assets/images/jersey.jpg',
    category: 'Apparel',
    description:
        'Breathable dry-fit gaming jersey engineered for tournaments, featuring circuit board gradients, sublimated council crest, and roster numbering.',
    soldCount: 95,
    stock: 30,
  ),
  Product(
    id: 'prod-004',
    name: 'CSSEC Enamel Pin Set (3-Pack)',
    price: 220.0,
    imagePath: 'assets/images/pins.jpg',
    category: 'Accessories',
    description:
        'Set of 3 metallic zinc alloy enamel lapel pins: Binary Chameleon emblem, Computer Studies monitor shield, and CS Binary Matrix badge.',
    soldCount: 310,
    stock: 120,
  ),
  Product(
    id: 'prod-005',
    name: 'CSSEC Holographic Stickers Pack',
    price: 120.0,
    imagePath: 'assets/images/stickers.jpg',
    category: 'Accessories',
    description:
        'Waterproof die-cut vinyl stickers for laptops and hydroflasks, including rainbow holographic Chameleon, Python code snippet, and Ateneo CS emblem.',
    soldCount: 540,
    stock: 200,
  ),
  Product(
    id: 'prod-006',
    name: 'CSSEC Chameleon Acrylic Keychain',
    price: 150.0,
    imagePath: 'assets/images/keychain.jpg',
    category: 'Accessories',
    description:
        'Double-sided clear purple acrylic charm with stainless steel swivel snap hook, featuring the playful CSSEC chameleon mascot.',
    soldCount: 265,
    stock: 80,
  ),
];
