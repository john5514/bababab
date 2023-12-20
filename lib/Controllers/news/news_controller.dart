import 'package:bicrypto/services/news_service.dart';
import 'package:get/get.dart';

class NewsController extends GetxController {
  var isLoading = true.obs;
  var newsList = <dynamic>[].obs;
  var page = 1.obs; // Track current page
  var showScrollToTopBtn = false.obs;
  var categories = <String>[].obs; // Store unique categories
  var newsByCategory =
      <String, List<dynamic>>{}.obs; // News organized by category

  @override
  void onInit() {
    fetchNews();
    super.onInit();
  }

  void fetchNews() async {
    if (!isLoading.value) {
      isLoading(true);
    }

    try {
      var news = await CryptoNewsService().fetchCryptoNews(page.value);
      if (news.isNotEmpty) {
        newsList.addAll(news); // Append to existing list
      }
    } finally {
      isLoading(false);
    }
    _extractCategories();
    _organizeNewsByCategory();
  }

  void _extractCategories() {
    Set<String> uniqueCategories = {};
    for (var newsItem in newsList) {
      uniqueCategories.addAll(newsItem['categories'].split('|'));
    }
    categories.assignAll(uniqueCategories);
  }

  void _organizeNewsByCategory() {
    Map<String, List<dynamic>> organizedNews = {};
    for (var category in categories) {
      organizedNews[category] = newsList
          .where((newsItem) => newsItem['categories'].contains(category))
          .toList();
    }
    newsByCategory.assignAll(organizedNews);
  }

  void loadMore() {
    if (!isLoading.value) {
      page.value++;
      fetchNews();
    }
  }
}
