import 'package:client/common/const/data.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/product/product_card.dart';
import 'package:client/restaurant/component/restaurant_card.dart';
import 'package:client/restaurant/model/restaurant_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String id;
  final String title;

  const RestaurantDetailScreen({
    Key? key,
    required this.id,
    required this.title,
  }) : super(key: key);

  Future<Map<String, dynamic>> getRestaurantDetail() async {
    final dio = Dio();

    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    final resp = await dio.get('http://$ip/restaurant/$id',
        options: Options(headers: {'authorization': 'Bearer $accessToken'}));
    return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: title,
        child: FutureBuilder<Map<String, dynamic>>(
          future: getRestaurantDetail(),
          builder: (_, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            final item = RestaurantDetailModel.fromJson(snapshot.data!);
            return CustomScrollView(
              slivers: [
                renderTop(model: item),
                renderLabel(),
                renderProducts(products: item.products),
              ],
            );
          },
        )
        // Column(
        //   children: [
        //     RestaurantCard(
        //       image: Image.asset('asset/images/food/ddeok_bok_gi.jpg'),
        //       name: '불타는 떡볶이',
        //       tags: ['떡', '튀', '순'],
        //       ratingsCount: 100,
        //       deliveryTime: 30,
        //       deliveryFee: 3000,
        //       ratings: 4.75,
        //       isDetail: true,
        //       detail: 'ㅋㅋ',
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //       child: ProductCard(),
        //     ),
        //   ],
        // ),
        );
  }

  SliverPadding renderLabel() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  renderProducts({required List<RestaurantProductModel> products}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index];
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ProductCard.fromModel(model: model),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({required RestaurantDetailModel model}) {
    return SliverToBoxAdapter(
      // 일반 위젯을 넣기 위해서는 SliverToBoxAdapter로 감싸줘야함
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
    );
  }
}
