import 'package:bicrypto/Controllers/home_controller.dart';
import 'package:bicrypto/Controllers/news/news_controller.dart';
import 'package:bicrypto/Style/styles.dart';
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
        return SafeArea(
          // This ensures that your content does not overlap with the status bar.
          child: DefaultTabController(
            length: newsController.categories.length,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: SizedBox(
                      // You might want to adjust this height to take into account the SafeArea padding.
                      height: MediaQuery.of(context).size.height * 0.5 -
                          MediaQuery.of(context).padding.top,
                      child: SimpleMarketScreen(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          HomeController homeController =
                              Get.find<HomeController>();
                          homeController.changeTabIndex(1);
                        },
                        child: Text(
                          "View More",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(
                      color: Color.fromARGB(150, 158, 158, 158),
                      thickness: 0.3,
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        labelColor: Theme.of(context)
                            .colorScheme
                            .onSurface, // Text color for selected tab
                        unselectedLabelColor: Colors.white
                            .withOpacity(0.6), // Text color for unselected tabs
                        indicatorColor: Theme.of(context)
                            .colorScheme
                            .primary, // Color for the indicator
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: newsController.categories
                            .map((category) => Tab(text: category))
                            .toList(),
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: newsController.categories.map((category) {
                  List<dynamic> categoryNews =
                      newsController.newsByCategory[category] ?? [];
                  return ListView.builder(
                    itemCount: categoryNews.length,
                    itemBuilder: (context, index) {
                      var newsItem = categoryNews[index];
                      return buildNewsItem(newsItem, context);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }
    });
  }

  Widget buildNewsItem(dynamic newsItem, BuildContext context) {
    var publishedDate =
        DateTime.fromMillisecondsSinceEpoch(newsItem['published_on'] * 1000);
    var relativeTime = timeago.format(publishedDate, locale: 'en_short');

    return Column(
      children: [
        const SizedBox(height: 16), // Spacing before the item
        Card(
          color: Colors.transparent,
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(newsItem['source_info']['img']),
                ),
                title: Text(
                  newsItem['source_info']['name'],
                  style:
                      const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                ),
                subtitle: Text(
                  "$relativeTime ago",
                  style:
                      TextStyle(color: Colors.grey[400], fontFamily: 'Inter'),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          color: Colors.grey[350], fontFamily: 'Inter'),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              newsItem['imageurl'] != null
                  ? GestureDetector(
                      onTap: () {
                        showNewsDetailsPopup(context, newsItem);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        ),
        const SizedBox(height: 16), // Spacing after the item
        Container(
          height: 5, // The height of the divider
          color: const Color.fromARGB(255, 0, 0, 0), // Color of the divider
        ),
      ],
    );
  }

  void showNewsDetailsPopup(BuildContext context, dynamic newsItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Transparent background
          insetPadding:
              const EdgeInsets.all(20), // Padding from the screen edges
          child: Container(
            decoration: BoxDecoration(
              color:
                  appTheme.colorScheme.surface, // Use surface color from theme
              borderRadius: BorderRadius.circular(15), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5), // Shadow color
                  blurRadius: 10, // Shadow blur radius
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  15), // Rounded corners for the clipping effect
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit content in the column
                children: <Widget>[
                  // Padding for the image
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0), // Padding at the top of the image
                    child: newsItem['imageurl'] != null
                        ? Image.network(newsItem['imageurl'])
                        : Container(),
                  ),
                  // Scrollable content area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16), // Padding inside the dialog
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsItem['title'],
                              style: appTheme.textTheme.displayLarge,
                            ),
                            const SizedBox(
                                height: 8), // Spacing between title and body
                            Text(
                              newsItem['body'],
                              style: appTheme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Close button at the bottom
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: appTheme.colorScheme
                            .primary, // Button text color from theme
                      ),
                      child: Text('Close',
                          style:
                              TextStyle(color: appTheme.colorScheme.onPrimary)),
                      onPressed: () =>
                          Navigator.of(context).pop(), // Close the dialog
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
