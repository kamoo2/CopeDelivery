import 'package:client/common/model/cursor_pagination_model.dart';
import 'package:client/restaurant/model/restaurant_detail_model.dart';
import 'package:client/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'restaurant_repository.g.dart';

@RestApi()
abstract class RestaurantRepository {
  // Repository 들이 같은 dio 인스턴스를 공유해야 한다.
  // http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  // http://$ip/restaurant
  @GET('/')
  @Headers({'accessToken': 'true'})
  Future<CursorPagination<RestaurantModel>> paginate();

  // http://$ip/restaurant/:id
  @GET('/{id}')
  @Headers({'accessToken': 'true'})
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}
