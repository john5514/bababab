import 'package:bicrypto/Controllers/news/news_controller.dart';
import 'package:bicrypto/widgets/market/SimplifiedMarketScreen%20.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsWidget extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  NewsWidget({super.key}) {
    _scrollController.addListener(() {
      if (_scrollController.offset >= 2000) {
        Get.find<NewsController>().showScrollToTopBtn.value = true;
      } else {
        Get.find<NewsController>().showScrollToTopBtn.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final NewsController newsController = Get.put(NewsController());

    return Obx(() {
      if (newsController.isLoading.value && newsController.newsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.extentAfter == 0 &&
                !newsController.isLoading.value) {
              newsController.loadMore();
            }
            return true;
          },
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: newsController.newsList.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.5, // Or another appropriate height
                      child: SimpleMarketScreen(),
                    );
                  }

                  if (index == 1) {
                    return const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    );
                  }

                  var newsIndex = index - 2;
                  var newsItem = newsController.newsList[newsIndex];
                  var publishedDate = DateTime.fromMillisecondsSinceEpoch(
                      newsItem['published_on'] * 1000);
                  var relativeTime =
                      timeago.format(publishedDate, locale: 'en_short');

                  return Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(newsItem['source_info']['img']),
                          ),
                          title: Text(
                            newsItem['source_info']['name'],
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Inter'),
                          ),
                          subtitle: Text(
                            "$relativeTime ago",
                            style: TextStyle(
                                color: Colors.grey[400], fontFamily: 'Inter'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                newsItem['title'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                newsItem['body'],
                                style: TextStyle(
                                    color: Colors.grey[350],
                                    fontFamily: 'Inter'),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        newsItem['imageurl'] != null
                            ? GestureDetector(
                                onTap: () {
                                  // Open URL or other action when the image is tapped
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  width: double.infinity,
                                  height: 180.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      newsItem['imageurl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  );
                },
              ),
              if (newsController.showScrollToTopBtn.value)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      _scrollController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_upward, size: 20),
                  ),
                ),
            ],
          ),
        );
      }
    });
  }
}
