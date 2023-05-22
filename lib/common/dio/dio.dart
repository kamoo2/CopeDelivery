import 'package:client/common/const/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  CustomInterceptor({required this.storage});

  // 1) 요청을 보낼때
  // 요청이 보내질 때마다
  // 만약에 요청의 Header에 accessToken : true라는 값이 있다면
  // 실제 토큰을 가져와서 authorization : Bearer $token으로 변경해준다.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ] [${options.method}] ${options.uri}');

    if (options.headers['accessToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을때
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 401 에러가 났을 때 (status code)
    // 토큰을 재발급 받는 시도를 하고 토큰이 재발급 되면
    // 다시 새로운 토큰으로 요청을 한다.
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken 아예 없으면
    // 당연히 에러 던진다
    if (refreshToken == null) {
      // 에러를 던질 때는 handler.reject를 사용한다.
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        final resp = await dio.post(
          'http://$ip/auth/token',
          options: Options(
            headers: {
              'authorization': 'Bearer $refreshToken',
            },
          ),
        );
        final accessToken = resp.data['accessToken'];

        final options = err.requestOptions;

        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });

        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        // accessToken을 갈아 끼운 options를 이용해 다시 데이터 요청
        final response = await dio.fetch(options);

        // 요청 받은 데이터를 반환 -> view에서는 에러가 던져지지 않기 때문에 에러가 난걸 알아 차릴 수 없다.
        return handler.resolve(response);
      } on DioError catch (e) {
        // refreshToken의 상태가 이상하다.
        return handler.reject(e);
      }
    }
  }
}
