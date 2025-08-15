class HeroTagManager {
  // Generate unique hero tags for different contexts
  static String generateProductHeroTag({
    required String productId,
    required String context,
    int? index,
  }) {
    final baseTag = 'product-$productId-$context';
    return index != null ? '$baseTag-$index' : baseTag;
  }

  // Context constants for consistency
  static const String homePopular = 'home-popular';
  static const String homeNewArrivals = 'home-new-arrivals';
  static const String homeForYou = 'home-for-you';
  static const String searchResults = 'search-results';
  static const String categoryProducts = 'category-products';
  static const String productList = 'product-list';
  static const String favorites = 'favorites';
  static const String cart = 'cart';
  
  // Generate context-specific tags
  static String forHomePopular(String productId, int index) =>
      generateProductHeroTag(productId: productId, context: homePopular, index: index);
      
  static String forHomeNewArrivals(String productId, int index) =>
      generateProductHeroTag(productId: productId, context: homeNewArrivals, index: index);
      
  static String forHomeForYou(String productId, int index) =>
      generateProductHeroTag(productId: productId, context: homeForYou, index: index);
      
  static String forSearchResults(String productId, int index) =>
      generateProductHeroTag(productId: productId, context: searchResults, index: index);
      
  static String forCategoryProducts(String productId, int index) =>
      generateProductHeroTag(productId: productId, context: categoryProducts, index: index);
      
  static String forProductList(String productId, int index) =>
      generateProductHeroTag(productId: productId, context: productList, index: index);
      
  static String forFavorites(String productId, int index) =>
      generateProductHeroTag(productId: productId, context: favorites, index: index);
      
  static String forCart(String productId, int index) =>
      generateProductHeroTag(productId: productId, context: cart, index: index);
}
