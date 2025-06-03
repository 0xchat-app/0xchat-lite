
import 'package:chatcore/chat-core.dart';
import 'package:ox_chat/page/ecash/ecash_signature_record_isar.dart';

@reflector
class EcashSignatureRecord extends DBObject {
  EcashSignatureRecord({
    required this.messageId,
  });

  final String messageId;

  @override
  String toString() {
    return '${super.toString()}, messageId: $messageId';
  }

  static List<String?> primaryKey() {
    return ['messageId'];
  }

  @override
  Map<String, Object?> toMap() => {
    'messageId': messageId,
  };

  static EcashSignatureRecord fromMap(Map<String, Object?> map) {
    return EcashSignatureRecord(
      messageId: map['messageId'] as String,
    );
  }

  static Future<void> migrateToISAR() async {
    List<EcashSignatureRecord> ecashSignatureRecords = await DB.sharedInstance.objects<EcashSignatureRecord>();
    List<EcashSignatureRecordISAR> ecashSignatureRecordsISAR = [];
    for(var ecashSignatureRecord in ecashSignatureRecords){
      ecashSignatureRecordsISAR.add(EcashSignatureRecordISAR.fromMap(ecashSignatureRecord.toMap()));
    }
    await DBISAR.sharedInstance.isar.writeTxn(() async {
      await DBISAR.sharedInstance.isar.ecashSignatureRecordISARs
          .putAll(ecashSignatureRecordsISAR);
    });
  }
}