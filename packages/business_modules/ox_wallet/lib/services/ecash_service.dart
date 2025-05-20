import 'package:cashu_dart/cashu_dart.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/log_util.dart';

class EcashService {

  static Future<Receipt?> createLightningInvoice({required IMintIsar mint, required int amount}) async {
    Receipt? receipt;
    try {
      receipt = await Cashu.createLightningInvoice(mint: mint, amount: amount);
    } catch (e, s) {
      LogUtil.e('Create Lightning Invoice Failed: $e\r\n$s');
    }
    return receipt;
  }

  static Future<CashuResponse<String>> sendEcash({
    required IMintIsar mint,
    required int amount,
    String? memo,
    List<ProofIsar>? proofs,
  }) async {
    try {
      return await Cashu.sendEcash(
        mint: mint,
        amount: amount,
        memo: memo ?? '',
        proofs: proofs,
      );
    } catch (e, s) {
      final msg = 'Send Ecash Failed: $e\r\n$s';
      return CashuResponse.fromErrorMsg(msg);
    }
  }

  static Future<CashuResponse<String>> sendEcashForP2PK({
    required IMintIsar mint,
    required int amount,
    String? memo,
    required List<UserDBISAR> singer,
    List<UserDBISAR>? refund,
    DateTime? locktime,
    int? signNumRequired,
    P2PKSecretSigFlag? sigFlag,
    List<ProofIsar>? proofs,
  }) async {
    try {
      return await Cashu.sendEcashToPublicKeys(
        mint: mint,
        amount: amount,
        memo: memo ?? '',
        publicKeys: singer.map((e) => '02${e.pubKey}').toList(),
        refundPubKeys: refund?.map((e) => '02${e.pubKey}').toList(),
        locktime: locktime,
        signNumRequired: signNumRequired,
        sigFlag: sigFlag,
        proofs: proofs,
      );
    } catch (e, s) {
      final msg = 'Send Ecash Failed: $e\r\n$s';
      return CashuResponse.fromErrorMsg(msg);
    }
  }

  static Future<CashuResponse<(String memo, int amount)>> redeemEcash(String ecashString) async {
    try {
      return await Cashu.redeemEcash(
        ecashString: ecashString,
      );
    } catch(e, s) {
      final msg = 'Redeem ecash Failed: $e\r\n$s';
      return CashuResponse.fromErrorMsg(msg);
    }
  }

  static int? decodeLightningInvoice({required String invoice}) {
    int? amount;
    try{
      amount = Cashu.amountOfLightningInvoice(invoice);
    }catch(e,s){
      LogUtil.e('Decode Lightning Invoice Failed: $e\r\n$s');
    }
    return amount;
  }

  static Future<CashuResponse?> payingLightningInvoice({required IMintIsar mint, required String pr}) async {
    try{
      return await Cashu.payingLightningInvoice(mint: mint, pr: pr);
    }catch(e,s){
      LogUtil.e('Paying Lightning Invoice Failed: $e\r\n$s');
    }
    return null;
  }

  static Future<List<ProofIsar>> getAllUseProofs({required IMintIsar mint}) async {
    List<ProofIsar> proofs = [];
    try{
      proofs = await Cashu.getAllUseProofs(mint);
    }catch(e,s){
      LogUtil.e('Get Proofs Failed: $e\r\n$s');
    }
    return proofs;
  }

  static bool isLnInvoice(String invoice){
    return Cashu.isLnInvoice(invoice);
  }

  static bool isCashuToken(String token){
    return Cashu.isCashuToken(token);
  }

  static Future<List<IHistoryEntryIsar>> getHistoryList() async {
    List<IHistoryEntryIsar> historyEntry = [];
    try {
      historyEntry = await Cashu.getHistoryList(size: 50);
    } catch (e, s) {
      LogUtil.e('Get History List Failed: $e\r\n$s');
    }
    return historyEntry;
  }

  static Future<IMintIsar?> addMint(String mintURL) async {
    return await Cashu.addMint(mintURL);
  }

  static Future<bool> deleteMint(IMintIsar mint) async {
    try {
      return await Cashu.deleteMint(mint);
    } catch (e, s) {
      LogUtil.e('Delete Mint Failed: $e\r\n$s');
      return false;
    }
  }

  static Future<int?> checkProofsAvailable(IMintIsar mint) async {
    int? result;
    try {
      result = await Cashu.checkProofsAvailable(mint);
    } catch (e, s) {
      LogUtil.e('Check Proofs Available Failed: $e\r\n$s');
    }
    return result;
  }

  static Future<bool?> checkEcashTokenSpendable({required IHistoryEntryIsar entry}) async {
    bool? result;
    try {
      result = await Cashu.isEcashTokenSpendableFromHistory(entry);
    } catch (e, s) {
      LogUtil.e('Check Ecash Token Spendable: $e\r\n$s');
    }
    return result;
  }

  static Future<String?> tryCreateSpendableEcashToken(String token) {
    return Cashu.tryCreateSpendableEcashToken(token);
  }

  static Future<void> editMintName(IMintIsar mint, String name) async {
    return await Cashu.editMintName(mint, name);
  }

  static Future<bool> fetchMintInfo(IMintIsar mint) {
    return Cashu.fetchMintInfo(mint);
  }

  static int totalBalance() {
    return Cashu.totalBalance();
  }
}
