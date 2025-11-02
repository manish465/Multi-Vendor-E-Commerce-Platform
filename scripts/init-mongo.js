// Switch to ecommerce database
db = db.getSiblingDB("ecommerce");

// Create collections
db.createCollection("products");
db.createCollection("categories");
db.createCollection("vendors");
db.createCollection("user_interactions");
db.createCollection("product_features");

// Create indexes for products collection
db.products.createIndex({ vendorId: 1 });
db.products.createIndex({ category: 1 });
db.products.createIndex({ subCategory: 1 });
db.products.createIndex({ brand: 1 });
db.products.createIndex({ status: 1 });
db.products.createIndex({ tags: 1 });
db.products.createIndex({ price: 1 });
db.products.createIndex({ createdAt: -1 });
db.products.createIndex({ name: "text", description: "text" });

// Create indexes for categories
db.categories.createIndex({ name: 1 }, { unique: true });
db.categories.createIndex({ parentCategory: 1 });
db.categories.createIndex({ level: 1 });

// Create indexes for vendors
db.vendors.createIndex({ userId: 1 }, { unique: true });
db.vendors.createIndex({ businessName: 1 });
db.vendors.createIndex({ rating: -1 });

// Create indexes for user interactions
db.user_interactions.createIndex({ userId: 1 });
db.user_interactions.createIndex({ productId: 1 });
db.user_interactions.createIndex({ interactionType: 1 });
db.user_interactions.createIndex({ timestamp: -1 });
db.user_interactions.createIndex({ userId: 1, productId: 1 });

// Create indexes for product features
db.product_features.createIndex({ productId: 1 }, { unique: true });
db.product_features.createIndex({ category: 1 });
db.product_features.createIndex({ brand: 1 });

// Insert sample categories
db.categories.insertMany([
  {
    _id: ObjectId(),
    name: "Electronics",
    parentCategory: null,
    level: 1,
    description: "Electronic devices and accessories",
    attributes: ["brand", "color", "warranty"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
  {
    _id: ObjectId(),
    name: "Audio",
    parentCategory: "Electronics",
    level: 2,
    description: "Audio devices and accessories",
    attributes: ["brand", "color", "connectivity", "batteryLife"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
  {
    _id: ObjectId(),
    name: "Computers",
    parentCategory: "Electronics",
    level: 2,
    description: "Computers and accessories",
    attributes: ["brand", "processor", "ram", "storage", "screenSize"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
  {
    _id: ObjectId(),
    name: "Clothing",
    parentCategory: null,
    level: 1,
    description: "Clothing and apparel",
    attributes: ["brand", "size", "color", "material"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
  {
    _id: ObjectId(),
    name: "Men's Clothing",
    parentCategory: "Clothing",
    level: 2,
    description: "Men's apparel",
    attributes: ["brand", "size", "color", "material", "fitType"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
  {
    _id: ObjectId(),
    name: "Women's Clothing",
    parentCategory: "Clothing",
    level: 2,
    description: "Women's apparel",
    attributes: ["brand", "size", "color", "material", "fitType"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
  {
    _id: ObjectId(),
    name: "Books",
    parentCategory: null,
    level: 1,
    description: "Books and publications",
    attributes: ["author", "publisher", "language", "format"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
  {
    _id: ObjectId(),
    name: "Home & Kitchen",
    parentCategory: null,
    level: 1,
    description: "Home and kitchen items",
    attributes: ["brand", "color", "material", "dimensions"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
  {
    _id: ObjectId(),
    name: "Sports & Outdoors",
    parentCategory: null,
    level: 1,
    description: "Sports and outdoor equipment",
    attributes: ["brand", "size", "color", "material"],
    imageUrl: null,
    isActive: true,
    createdAt: new Date(),
  },
]);

// Insert sample vendor (will be associated with actual user after Keycloak setup)
db.vendors.insertOne({
  _id: ObjectId(),
  userId: "temp-user-id", // Will be replaced with actual Keycloak user ID
  businessName: "TechStore Electronics",
  description: "Premium electronics and gadgets",
  logo: null,
  rating: 4.5,
  totalProducts: 0,
  totalSales: 0,
  commission: 15,
  status: "ACTIVE",
  contactEmail: "vendor@techstore.com",
  contactPhone: "+1-555-0300",
  address: {
    street: "123 Business Ave",
    city: "San Francisco",
    state: "CA",
    zipCode: "94101",
    country: "USA",
  },
  bankDetails: {
    accountName: "TechStore Electronics LLC",
    accountNumber: "****1234",
    routingNumber: "****5678",
    bankName: "Commerce Bank",
  },
  createdAt: new Date(),
  updatedAt: new Date(),
});

print("MongoDB initialization completed successfully!");
print(
  "Created collections: products, categories, vendors, user_interactions, product_features"
);
print("Created indexes for all collections");
print("Inserted sample categories and vendor");
