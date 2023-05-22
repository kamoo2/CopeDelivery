import 'package:client/common/const/data.dart';
import 'package:client/common/dio/dio.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/product/product_card.dart';
import 'package:client/restaurant/component/restaurant_card.dart';
import 'package:client/restaurant/model/restaurant_detail_model.dart';
import 'package:client/restaurant/repository/restaurant_repository.dart';
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

  Future<RestaurantDetailModel> getRestaurantDetail() async {
    final dio = Dio();

    dio.interceptors.add(
      CustomInterceptor(storage: storage),
    );

    final repository =
        RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return repository.getRestaurantDetail(id: id);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: title,
        child: FutureBuilder<RestaurantDetailModel>(
          future: getRestaurantDetail(),
          builder: (_, AsyncSnapshot<RestaurantDetailModel> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                renderTop(model: snapshot.data!),
                renderLabel(),
                renderProducts(products: snapshot.data!.products),
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
