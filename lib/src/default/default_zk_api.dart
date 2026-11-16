import 'package:blockchain_utils_connector/src/api/zk_api.dart';
import 'package:blockchain_utils_connector/src/connector/bu_features.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultZkApi implements BuZkApi {
  DefaultZkApi(this._b);

  final BuPlatformBindings _b;

  @override
  int version() => _b.zkVersion();

  @override
  bool enableLogging({int enable = 1, int mode = 0}) =>
      _b.zkEnableLogging(enable, mode) == 0;

  @override
  int backendVersion() => _b.backendVersion();

  @override
  int backendFeatures() => _b.backendFeatures();

  @override
  bool hasFeature(BuBuildFeature feature) => feature.isIn(_b.backendFeatures());
}
