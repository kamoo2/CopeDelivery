import 'package:client/common/const/data.dart';
import 'package:client/common/dio/dio.dart';
import 'package:client/restaurant/component/restaurant_card.dart';
import 'package:client/restaurant/model/restaurant_model.dart';
import 'package:client/restaurant/repository/restaurant_repository.dart';
import 'package:client/restaurant/view/restaurant_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  Future<List<RestaurantModel>> paginateRestaurant() async {
    final dio = Dio();

    dio.interceptors.add(
      CustomInterceptor(storage: storage),
    );

    final resp =
        await RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant')
            .paginate();

    return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FutureBuilder<List<RestaurantModel>>(
            future: paginateRestaurant(),
            builder: (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.separated(
                  itemBuilder: (_, index) {
                    final pItem = snapshot.data![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RestaurantDetailScreen(
                                id: pItem.id, title: pItem.name)));
                      },
                      child: RestaurantCard.fromModel(model: pItem),
                    );
                  },
                  separatorBuilder: (_, index) {
                    return SizedBox(height: 16.0);
                  },
                  itemCount: snapshot.data!.length);
            },
          )),
    ));
  }
}
