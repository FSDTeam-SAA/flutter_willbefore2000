import '../../feature/product/domain/entrity/product.dart';

class FuzzySearch {
  final List<Product> products;
  
  FuzzySearch(this.products);

  List<Product> search(String query) {
    if (query.trim().isEmpty) return [];
    
    final searchTerms = query.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();
    final scoredProducts = <ScoredProduct>[];
    
    for (final product in products) {
      final score = _calculateRelevanceScore(product, searchTerms);
      if (score > 0) {
        scoredProducts.add(ScoredProduct(product, score));
      }
    }
    
    scoredProducts.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredProducts.map((sp) => sp.product).toList();
  }

  double _calculateRelevanceScore(Product product, List<String> searchTerms) {
    double score = 0.0;
    
    final title = product.title.toLowerCase();
    final description = product.description.toLowerCase();
    final category = product.categoryId.toLowerCase();
    // final brand = product.brand?.toLowerCase() ?? '';
    
    for (final term in searchTerms) {
      if (title.contains(term)) {
        score += title.startsWith(term) ? 10.0 : 8.0;
      }
      
      // if (brand.contains(term)) {
      //   score += brand.startsWith(term) ? 9.0 : 7.0;
      // }
      
      if (category.contains(term)) {
        score += 6.0;
      }
      
      if (description.contains(term)) {
        score += 3.0;
      }
      
      score += _fuzzyMatch(title, term) * 5.0;
      // score += _fuzzyMatch(brand, term) * 4.0;
      score += _fuzzyMatch(description, term) * 2.0;
    }
    
    // score += product.rating * 0.5;
    // score += (product.reviewCount / 100) * 0.3;
    
    return score;
  }

  double _fuzzyMatch(String text, String term) {
    if (text.isEmpty || term.isEmpty) return 0.0;
    
    final distance = _levenshteinDistance(text, term);
    final maxLength = text.length > term.length ? text.length : term.length;
    
    if (distance == 0) return 1.0;
    if (distance > maxLength * 0.6) return 0.0;
    
    return 1.0 - (distance / maxLength);
  }

  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    
    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));
    
    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[len1][len2];
  }
}

class ScoredProduct {
  final Product product;
  final double score;
  
  ScoredProduct(this.product, this.score);
}
