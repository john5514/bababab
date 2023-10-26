import 'package:bicrypto/services/news_service.dart';
import 'package:get/get.dart';

class NewsController extends GetxController {
  var isLoading = true.obs;
  var newsList = <dynamic>[].obs;
  var page = 1.obs; // Track current page
  var showScrollToTopBtn = false.obs;

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
  }

  void loadMore() {
    if (!isLoading.value) {
      page.value++;
      fetchNews();
    }
  }
}
