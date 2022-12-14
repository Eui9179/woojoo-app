import 'package:dio/dio.dart';
import 'package:dor_app/dio/dio_instance.dart';

Future<Map<String, dynamic>> dioApiInsertFriends(
    String accessToken, List<int> peopleToBeFriends) async {
  Dio dio = DioInstance(accessToken).dio;

  try {
    Response response = await dio.post('/user/friends', data: peopleToBeFriends);
    return {
      'statusCode': response.statusCode,
      'data': response.data['new_friends']
    };
  } on DioError catch (error) {
    return {
      'statusCode': error.response!.statusCode,
    };
  } finally {
    dio.close();
  }
}
