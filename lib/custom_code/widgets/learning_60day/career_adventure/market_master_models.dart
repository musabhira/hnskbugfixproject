import 'package:flutter/material.dart';

/// Challenge types representing authentic supermarket interactions in Level 9.
enum MarketChallengeType {
  understandList,
  productSearch,
  quantityPickup,
  priceReading,
  askForHelp,
  listenToStaff,
  comparison,
  customerService,
  checkoutSum,
  cashierDialogue,
  shoppingRush,
}

/// An individual item in the shopping cart / basket.
class CartProductItem {
  final String id;
  final String name;
  final String quantityLabel;
  final int unitPrice;
  final int quantity;
  final IconData icon;

  const CartProductItem({
    required this.id,
    required this.name,
    required this.quantityLabel,
    required this.unitPrice,
    required this.quantity,
    required this.icon,
  });

  int get totalPrice => unitPrice * quantity;
}

/// A product option on a shelf for inspection.
class MarketProductChoice {
  final String id;
  final String name;
  final String brand;
  final String weightLabel;
  final int price;
  final bool isTarget;
  final String description;

  const MarketProductChoice({
    required this.id,
    required this.name,
    required this.brand,
    required this.weightLabel,
    required this.price,
    required this.isTarget,
    required this.description,
  });
}

/// A specific response option in a market challenge.
class MarketChallengeOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String feedback;
  final int xpReward;

  const MarketChallengeOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.feedback,
    this.xpReward = 20,
  });
}

/// A shopping challenge in the supermarket.
class MarketMasterChallenge {
  final int id;
  final MarketChallengeType type;
  final String aisleCode;
  final String sectionTitle;
  final String title;
  final String prompt;
  final String spokenText;
  final String hint;
  final List<MarketChallengeOption> options;
  final int correctOptionIndex;
  final List<MarketProductChoice>? shelfProducts;
  final CartProductItem? awardedCartItem;
  final int timeLimitSeconds;

  const MarketMasterChallenge({
    required this.id,
    required this.type,
    required this.aisleCode,
    required this.sectionTitle,
    required this.title,
    required this.prompt,
    required this.spokenText,
    required this.hint,
    required this.options,
    required this.correctOptionIndex,
    this.shelfProducts,
    this.awardedCartItem,
    this.timeLimitSeconds = 0,
  });

  MarketChallengeOption get correctOption => options[correctOptionIndex];
}

/// A connected supermarket zone in the 2D world.
class SupermarketZone {
  final String id;
  final String name;
  final double startX;
  final double endX;
  final Color primaryColor;
  final IconData icon;

  const SupermarketZone({
    required this.id,
    required this.name,
    required this.startX,
    required this.endX,
    required this.primaryColor,
    required this.icon,
  });
}

/// Complete curriculum data structure for Mission 09.
class MarketMasterLevelData {
  final String missionId;
  final String title;
  final String subtitle;
  final String tagline;
  final List<String> targetVocabulary;
  final List<SupermarketZone> zones;
  final List<MarketMasterChallenge> challenges;
  final List<CartProductItem> initialCart;
  final String shoppingListNote;

  const MarketMasterLevelData({
    required this.missionId,
    required this.title,
    required this.subtitle,
    required this.tagline,
    required this.targetVocabulary,
    required this.zones,
    required this.challenges,
    required this.initialCart,
    required this.shoppingListNote,
  });
}

/// Full Curriculum for Level 9 – Market Master
final kMission09MarketMasterData = MarketMasterLevelData(
  missionId: '09',
  title: 'Mission 09 – Market Master',
  subtitle: '2D Flame Supermarket Shopping & Communication Adventure',
  tagline: 'Read it. Find it. Ask for it. Buy it.',
  targetVocabulary: const [
    'aisle',
    'basket',
    'cart',
    'checkout',
    'cashier',
    'receipt',
    'price',
    'quantity',
    'packet',
    'bottle',
    'loaf',
    'dozen',
    'kilogram',
    'brand',
    'discount',
    'available',
    'customer',
    'section',
    'product',
    'total',
    'change',
    'purchase',
  ],
  zones: const [
    SupermarketZone(
      id: 'entrance',
      name: 'Entrance & Cart Bay',
      startX: 0,
      endX: 380,
      primaryColor: Color(0xFF0EA5E9),
      icon: Icons.shopping_cart_rounded,
    ),
    SupermarketZone(
      id: 'fresh_produce',
      name: 'Fresh Bakery & Dairy',
      startX: 380,
      endX: 740,
      primaryColor: Color(0xFFF59E0B),
      icon: Icons.bakery_dining_rounded,
    ),
    SupermarketZone(
      id: 'grocery_aisle3',
      name: 'Grocery & Grains (Aisle 3)',
      startX: 740,
      endX: 1120,
      primaryColor: Color(0xFF10B981),
      icon: Icons.rice_bowl_rounded,
    ),
    SupermarketZone(
      id: 'drinks',
      name: 'Drinks & Beverage Wall',
      startX: 1120,
      endX: 1460,
      primaryColor: Color(0xFF06B6D4),
      icon: Icons.local_drink_rounded,
    ),
    SupermarketZone(
      id: 'helpdesk',
      name: 'Customer Service Desk',
      startX: 1460,
      endX: 1680,
      primaryColor: Color(0xFF8B5CF6),
      icon: Icons.support_agent_rounded,
    ),
    SupermarketZone(
      id: 'checkout',
      name: 'Checkout & Cashier Lane',
      startX: 1680,
      endX: 1900,
      primaryColor: Color(0xFFEC4899),
      icon: Icons.point_of_sale_rounded,
    ),
  ],
  shoppingListNote:
      'Family Guest Dinner Shopping List:\n• 2 bottles of water\n• 1 loaf of bread\n• 6 eggs\n• 1 packet of instant coffee\n• 1 kg of rice\n\nDeadline: Complete checkout before 6:00 PM.',
  initialCart: const [],
  challenges: [
    // Challenge 1: Understand the List
    MarketMasterChallenge(
      id: 1,
      type: MarketChallengeType.understandList,
      aisleCode: 'ENTRANCE',
      sectionTitle: 'Shopping List Terminal',
      title: 'Understand the List: Quantities',
      prompt: 'Shopping List Item: “2 bottles of water”.\nHow many bottles do you need to pick up?',
      spokenText: 'How many bottles of water do you need to pick up?',
      hint: 'Look directly at the numeral before the unit container: 2 bottles.',
      options: [
        MarketChallengeOption(
          id: 'c1_opt_a',
          text: '2 bottles of water',
          isCorrect: true,
          feedback: 'Correct! You need exactly 2 bottles for the dinner guests.',
          xpReward: 20,
        ),
        MarketChallengeOption(
          id: 'c1_opt_b',
          text: '1 bottle of water',
          isCorrect: false,
          feedback: 'Incorrect: 1 bottle is not enough for the family gathering.',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c1_opt_c',
          text: '4 bottles of water',
          isCorrect: false,
          feedback: 'Incorrect: 4 bottles exceeds what is written on your list.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
      awardedCartItem: CartProductItem(
        id: 'water',
        name: 'Mineral Water',
        quantityLabel: '2 bottles',
        unitPrice: 25,
        quantity: 2,
        icon: Icons.water_drop_rounded,
      ),
    ),

    // Challenge 2: Find the Correct Product
    MarketMasterChallenge(
      id: 2,
      type: MarketChallengeType.productSearch,
      aisleCode: 'AISLE 1',
      sectionTitle: 'Coffee & Hot Beverages',
      title: 'Find the Correct Product: Instant Coffee',
      prompt: 'Your shopping list specifies: “1 packet of instant coffee”.\nSelect the correct item from the shelf display.',
      spokenText: 'Select the packet of instant coffee from the shelf display.',
      hint: 'Inspect the label adjectives carefully: choose Instant Coffee, not whole beans or ground roast.',
      shelfProducts: const [
        MarketProductChoice(
          id: 'coffee_beans',
          name: 'Roasted Coffee Beans',
          brand: 'Artisan Roast',
          weightLabel: '250g bag',
          price: 240,
          isTarget: false,
          description: 'Whole roasted coffee beans. Requires grinding machine.',
        ),
        MarketProductChoice(
          id: 'coffee_instant',
          name: 'Instant Coffee Granules',
          brand: 'Gold Roast',
          weightLabel: '1 packet (100g)',
          price: 180,
          isTarget: true,
          description: 'Quick dissolvable instant coffee granules packet.',
        ),
        MarketProductChoice(
          id: 'coffee_ground',
          name: 'Filter Ground Coffee',
          brand: 'Dark Roast',
          weightLabel: '200g pouch',
          price: 210,
          isTarget: false,
          description: 'Finely ground filter coffee powder for espresso machines.',
        ),
      ],
      options: [
        MarketChallengeOption(
          id: 'c2_opt_a',
          text: 'Instant Coffee Granules (₹180)',
          isCorrect: true,
          feedback: 'Spot on! You placed 1 packet of Instant Coffee into your cart.',
          xpReward: 20,
        ),
        MarketChallengeOption(
          id: 'c2_opt_b',
          text: 'Roasted Coffee Beans (₹240)',
          isCorrect: false,
          feedback: 'That is not the product on your list (requires a coffee grinder).',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c2_opt_c',
          text: 'Filter Ground Coffee (₹210)',
          isCorrect: false,
          feedback: 'Wrong item: your list asked specifically for instant coffee.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
      awardedCartItem: CartProductItem(
        id: 'coffee',
        name: 'Instant Coffee',
        quantityLabel: '1 packet',
        unitPrice: 180,
        quantity: 1,
        icon: Icons.coffee_rounded,
      ),
    ),

    // Challenge 3: Quantity Pickup
    MarketMasterChallenge(
      id: 3,
      type: MarketChallengeType.quantityPickup,
      aisleCode: 'AISLE 2',
      sectionTitle: 'Dairy & Farm Produce',
      title: 'Quantity Pickup: 6 Fresh Eggs',
      prompt: 'Your shopping list calls for: “6 eggs”.\nWhich carton size should you add to your basket?',
      spokenText: 'Which egg carton size should you add to your basket?',
      hint: 'Select the exact package containing six eggs (half-dozen).',
      options: [
        MarketChallengeOption(
          id: 'c3_opt_a',
          text: 'Carton of 6 Eggs (Half Dozen - ₹60)',
          isCorrect: true,
          feedback: 'Exact quantity! 6 eggs placed into your shopping cart.',
          xpReward: 20,
        ),
        MarketChallengeOption(
          id: 'c3_opt_b',
          text: 'Carton of 12 Eggs (One Dozen - ₹115)',
          isCorrect: false,
          feedback: 'Too many! The recipe only calls for 6 eggs.',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c3_opt_c',
          text: 'Small Pack of 4 Eggs (₹42)',
          isCorrect: false,
          feedback: 'Not enough! You need 6 eggs.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
      awardedCartItem: CartProductItem(
        id: 'eggs',
        name: 'Fresh Farm Eggs',
        quantityLabel: '6 eggs',
        unitPrice: 60,
        quantity: 1,
        icon: Icons.egg_rounded,
      ),
    ),

    // Challenge 4: Price Reading
    MarketMasterChallenge(
      id: 4,
      type: MarketChallengeType.priceReading,
      aisleCode: 'BEVERAGE WALL',
      sectionTitle: 'Digital Shelf Tag',
      title: 'Price Reading: Per-Unit Evaluation',
      prompt: 'Shelf Tag: “Natural Spring Mineral Water — ₹25 per bottle”.\nHow much does ONE bottle of water cost?',
      spokenText: 'How much does one bottle of water cost?',
      hint: 'The shelf tag displays ₹25 per unit bottle.',
      options: [
        MarketChallengeOption(
          id: 'c4_opt_a',
          text: '₹25',
          isCorrect: true,
          feedback: 'Correct! 1 bottle costs ₹25 (2 bottles cost ₹50).',
          xpReward: 20,
        ),
        MarketChallengeOption(
          id: 'c4_opt_b',
          text: '₹50',
          isCorrect: false,
          feedback: '₹50 is the price for two bottles, not one.',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c4_opt_c',
          text: '₹250',
          isCorrect: false,
          feedback: 'Check the decimal and digits: it is ₹25, not ₹250.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 5: Asking for Help
    MarketMasterChallenge(
      id: 5,
      type: MarketChallengeType.askForHelp,
      aisleCode: 'SUPERMARKET FLOOR',
      sectionTitle: 'Store Clerk Interaction',
      title: 'Polite Inquiries: Locating Rice',
      prompt: 'You cannot find the rice on the main display shelves.\nChoose the most polite and natural way to ask the store clerk.',
      spokenText: 'Excuse me, could you tell me where the rice is?',
      hint: "Polite inquiries in modern English open with 'Excuse me, could you tell me where...?'",
      options: [
        MarketChallengeOption(
          id: 'c5_opt_a',
          text: '“Excuse me, could you tell me where the rice is?”',
          isCorrect: true,
          feedback: 'Polite and fluent! Clerk smiles: “Sure! It’s in aisle three.”',
          xpReward: 25,
        ),
        MarketChallengeOption(
          id: 'c5_opt_b',
          text: '“Where rice?”',
          isCorrect: false,
          feedback: 'Blunt and fragmented. Needs polite opening and full sentence structure.',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c5_opt_c',
          text: '“Rice give me.”',
          isCorrect: false,
          feedback: 'Sounds like an impolite demand rather than an inquiry.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 6: Listen to the Staff
    MarketMasterChallenge(
      id: 6,
      type: MarketChallengeType.listenToStaff,
      aisleCode: 'AISLE 3',
      sectionTitle: 'Auditory Direction',
      title: 'Listen to the Staff: Directional Detail',
      prompt: 'Store Clerk Audio: “The rice is on the third aisle, next to the cooking oil.”\nWhat item is located next to the rice?',
      spokenText: 'The rice is on the third aisle, next to the cooking oil.',
      hint: 'Listen carefully for the prepositional phrase: next to the...',
      options: [
        MarketChallengeOption(
          id: 'c6_opt_a',
          text: 'Cooking oil',
          isCorrect: true,
          feedback: 'Excellent listening comprehension! You navigate right next to the cooking oil display.',
          xpReward: 25,
        ),
        MarketChallengeOption(
          id: 'c6_opt_b',
          text: 'Fresh bread',
          isCorrect: false,
          feedback: 'Incorrect: bread is in the bakery section near the entrance.',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c6_opt_c',
          text: 'Bottled water',
          isCorrect: false,
          feedback: 'Incorrect: bottled water is across in the beverage wall.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
      awardedCartItem: CartProductItem(
        id: 'rice',
        name: 'Basmati Rice',
        quantityLabel: '1 kg',
        unitPrice: 65,
        quantity: 1,
        icon: Icons.rice_bowl_rounded,
      ),
    ),

    // Challenge 7: Product Comparison
    MarketMasterChallenge(
      id: 7,
      type: MarketChallengeType.comparison,
      aisleCode: 'GRAIN SECTION',
      sectionTitle: 'Value & Quantity Analysis',
      title: 'Product Comparison: Quantity & Value',
      prompt: 'Two packages of Rice are on display:\n• Pack A: 500g — ₹90\n• Pack B: 1kg (1000g) — ₹150\n\nWhich product gives you MORE rice?',
      spokenText: 'Which product gives you more rice?',
      hint: '1 kg equals 1000 grams, which is double 500 grams.',
      options: [
        MarketChallengeOption(
          id: 'c7_opt_a',
          text: 'Pack B (1kg) gives more rice',
          isCorrect: true,
          feedback: 'Correct! 1kg (1000g) is twice as much rice as 500g.',
          xpReward: 25,
        ),
        MarketChallengeOption(
          id: 'c7_opt_b',
          text: 'Pack A (500g) gives more rice',
          isCorrect: false,
          feedback: 'Incorrect: 500 grams is only half a kilogram.',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c7_opt_c',
          text: 'Both packs have the same amount',
          isCorrect: false,
          feedback: 'Incorrect: 500g and 1kg are different quantities.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
      awardedCartItem: CartProductItem(
        id: 'bread',
        name: 'Whole Wheat Bread',
        quantityLabel: '1 loaf',
        unitPrice: 45,
        quantity: 1,
        icon: Icons.bakery_dining_rounded,
      ),
    ),

    // Challenge 8: Customer Service
    MarketMasterChallenge(
      id: 8,
      type: MarketChallengeType.customerService,
      aisleCode: 'SERVICE DESK',
      sectionTitle: 'Helpdesk Consultation',
      title: 'Customer Service: Explaining a Mistake',
      prompt: 'At customer service, the clerk asks: “Can I help you?”\nHow do you explain politely that you picked up the wrong item?',
      spokenText: 'Can I help you with anything today?',
      hint: "Use 'Sorry, I think I picked up the wrong item' to communicate constructively.",
      options: [
        MarketChallengeOption(
          id: 'c8_opt_a',
          text: '“Sorry, I think I picked up the wrong item.”',
          isCorrect: true,
          feedback: 'Polite and clear! Clerk: “No problem at all! Let me swap that for you.”',
          xpReward: 25,
        ),
        MarketChallengeOption(
          id: 'c8_opt_b',
          text: '“Wrong item me.”',
          isCorrect: false,
          feedback: 'Broken grammar. Lacks courteous sentence structure.',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c8_opt_c',
          text: '“Give right now.”',
          isCorrect: false,
          feedback: 'Rude and aggressive tone.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 9: Checkout Sum
    MarketMasterChallenge(
      id: 9,
      type: MarketChallengeType.checkoutSum,
      aisleCode: 'REGISTER 4',
      sectionTitle: 'Itemized Receipt Calculation',
      title: 'Checkout Calculation: Final Total Bill',
      prompt: 'Register Screen Itemized Bill:\n• Water (2 × ₹25) = ₹50\n• Bread (1 loaf) = ₹45\n• Eggs (6 pack) = ₹60\n• Instant Coffee (1 packet) = ₹180\n• Basmati Rice (1 kg) = ₹65\n\nHow much is the total amount due?',
      spokenText: 'How much is the total amount due at checkout?',
      hint: 'Add: 50 + 45 + 60 + 180 + 65 = ₹400.',
      options: [
        MarketChallengeOption(
          id: 'c9_opt_a',
          text: '₹400',
          isCorrect: true,
          feedback: 'Math and number comprehension verified! Total is exactly ₹400.',
          xpReward: 30,
        ),
        MarketChallengeOption(
          id: 'c9_opt_b',
          text: '₹375',
          isCorrect: false,
          feedback: 'Calculation error. Re-add the individual items.',
          xpReward: 5,
        ),
        MarketChallengeOption(
          id: 'c9_opt_c',
          text: '₹450',
          isCorrect: false,
          feedback: 'Too high. Sum of items is ₹400.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Challenge 10: Cashier Conversation (Multiple Natural Answers)
    MarketMasterChallenge(
      id: 10,
      type: MarketChallengeType.cashierDialogue,
      aisleCode: 'REGISTER 4',
      sectionTitle: 'Cashier Dialogue',
      title: 'Cashier Conversation: Natural Everyday Responses',
      prompt: 'The cashier finishes scanning your cart and asks:\n“Would you like a paper bag?”\nSelect an appropriate everyday response.',
      spokenText: 'Would you like a paper bag with your purchase?',
      hint: "Both 'Yes, please' and 'No, thank you' are valid courteous English responses.",
      options: [
        MarketChallengeOption(
          id: 'c10_opt_a',
          text: '“Yes, please.”',
          isCorrect: true,
          feedback: 'Courteous choice! Cashier bags your items carefully.',
          xpReward: 25,
        ),
        MarketChallengeOption(
          id: 'c10_opt_b',
          text: '“No, thank you. I brought my own bag.”',
          isCorrect: true,
          feedback: 'Great eco-friendly and polite response!',
          xpReward: 25,
        ),
        MarketChallengeOption(
          id: 'c10_opt_c',
          text: '“Bag bag!”',
          isCorrect: false,
          feedback: 'Unnatural repetition. Use polite formulaic expressions.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),

    // Final Timed Challenge: Shopping Rush
    MarketMasterChallenge(
      id: 11,
      type: MarketChallengeType.shoppingRush,
      aisleCode: 'EXPRESS LANE',
      sectionTitle: '90-Second Timed Shopping Rush',
      title: 'Final Challenge: 90-Second Shopping Rush',
      prompt: 'Emergency Guest Addition!\nCollect: 1 bottle of orange juice, 2 packs of sliced bread, and 1 box of cereal before the timer runs out!',
      spokenText: 'Emergency guest addition. Collect one bottle of juice, two packs of bread, and one box of cereal before the timer runs out.',
      timeLimitSeconds: 90,
      hint: 'Confirm exact quantities: 1 juice, 2 bread, 1 cereal.',
      options: [
        MarketChallengeOption(
          id: 'c11_opt_a',
          text: 'Cashier asks: “Did you find everything?” -> “Yes, I did.”',
          isCorrect: true,
          feedback: 'SUPERMARKET MASTER! All 5 primary items and 3 rush items successfully purchased!',
          xpReward: 50,
        ),
        MarketChallengeOption(
          id: 'c11_opt_b',
          text: '“I don’t know anything.”',
          isCorrect: false,
          feedback: 'Unhelpful response.',
          xpReward: 5,
        ),
      ],
      correctOptionIndex: 0,
    ),
  ],
);
