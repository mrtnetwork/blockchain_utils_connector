import 'package:blockchain_utils_connector/src/api/transcript_api.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultTranscriptApi implements BuTranscriptApi {
  DefaultTranscriptApi(this._b);

  final BuPlatformBindings _b;

  @override
  BuResult<BuMerlin> merlin({required List<int> label}) =>
      BuMerlin.open(_b, label: label);

  @override
  BuResult<BuStrobe> strobe({required List<int> protocol}) =>
      BuStrobe.open(_b, protocol: protocol);
}
