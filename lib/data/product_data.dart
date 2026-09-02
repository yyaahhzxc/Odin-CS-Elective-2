import '../models/product.dart';

/// Static repository containing the initial CSSEC merchandise catalog.
const List<Product> mockProducts = [
  Product(
    id: 'prod-001',
    name: 'CS T-Shirt',
    price: 350.0,
    imagePath: 'assets/images/shirt.jpg',
    category: 'Apparel',
    description:
        'Official CS T-Shirt Merch for School Year 2026-2027.',
    soldCount: 142,
    stock: 50,
  ),
  Product(
    id: 'prod-002',
    name: 'Palarong Atenista CS Jacket',
    price: 1200.0,
    imagePath: 'assets/images/jacket.jpg',
    category: 'Apparel',
    description:
        'Heavyweight wool-blend varsity bomber jacket with custom CS embroidered chest patch and ribbed contrast trims.',
    soldCount: 88,
    stock: 25,
  ),
  Product(
    id: 'prod-003',
    name: 'CS Jersey',
    price: 650.0,
    imagePath: 'assets/images/jersey.jpg',
    category: 'Apparel',
    description:
        'Breathable dry-fit jersey, designed to be worn for Palarong Atenista 2026. Includes custom naming and jersey number on the back.',
    soldCount: 95,
    stock: 30,
  ),
  Product(
    id: 'prod-004',
    name: 'Enamel Pin',
    price: 220.0,
    imagePath: 'assets/images/pins.jpg',
    category: 'Accessories',
    description:
        'pin idk.',
    soldCount: 310,
    stock: 120,
  ),
  Product(
    id: 'prod-005',
    name: 'CS Stickers (Assorted)',
    price: 120.0,
    imagePath: 'assets/images/stickers.jpg',
    category: 'Accessories',
    description:
        'stickerz.',
    soldCount: 540,
    stock: 200,
  ),
  Product(
    id: 'prod-006',
    name: 'Keychain',
    price: 150.0,
    imagePath: 'assets/images/keychain.jpg',
    category: 'Accessories',
    description:
        'keychain wieee',
    soldCount: 265,
    stock: 80,
  ),
];
