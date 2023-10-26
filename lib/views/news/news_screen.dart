import 'package:bicrypto/Controllers/news/news_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsWidget extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  NewsWidget() {
    // Listener to change the state of FAB visibility
    _scrollController.addListener(() {
      if (_scrollController.offset >= 2000) {
        // Assuming each item is about 100 pixels height, adjust as needed
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
        return Center(child: CircularProgressIndicator());
      } else {
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Check if you're at the bottom of the list
            if (scrollInfo.metrics.extentAfter == 0 &&
                !newsController.isLoading.value) {
              newsController.loadMore(); // Load more when scrolled to bottom
            }
            return true;
          },
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: newsController.newsList.length,
                itemBuilder: (context, index) {
                  var newsItem = newsController.newsList[index];
                  var publishedDate = DateTime.fromMillisecondsSinceEpoch(
                      newsItem['published_on'] * 1000);
                  var relativeTime =
                      timeago.format(publishedDate, locale: 'en_short');

                  return Card(
                    color:
                        Colors.transparent, // Make card background transparent
                    elevation: 0, // Remove card shadow
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
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "$relativeTime ago",
                            style: TextStyle(color: Colors.grey[400]),
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
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                newsItem['body'],
                                style: TextStyle(color: Colors.grey[350]),
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
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Icon(Icons.arrow_upward, size: 20),
                  ),
                ),
            ],
          ),
        );
      }
    });
  }
}
