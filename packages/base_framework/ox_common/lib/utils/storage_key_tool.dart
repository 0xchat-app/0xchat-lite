///Title: storage_key_tool
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author George
///CreateTime: 2021/4/21 2:02 PM
class StorageKeyTool {
  static const String KEY_PUBKEY = "pubKey";
  static const String KEY_PUBKEY_LIST = "KEY_PUBKEY_LIST";
  static const String KEY_IS_LOGIN_AMBER = "KEY_IS_LOGIN_AMBER";
  static const String APP_FONT_SIZE = "APP_FONT_SIZE";
  static const String APP_MOMENT_POSITION = "APP_MOMENT_POSITION";  //0: top; 1: tabbar; 2: delete.

  static const String APP_DOMAIN_NAME = "APP_DOMAIN_NAME"; //当前domain


}

enum StorageSettingKey {
  KEY_NOTIFICATION_LIST(1000, 'KEY_NOTIFICATION_LIST'), //save message notification value
  KEY_PUSH_TOKEN(1001, 'KEY_PUSH_TOKEN'),//save push token value
  KEY_PASSCODE(1002, 'KEY_PASSCODE'),//verify code
  KEY_FACEID(1003, 'KEY_FACEID'),
  KEY_FINGERPRINT(1004, 'KEY_FINGERPRINT'),
  KEY_CHAT_RUN_STATUS(1005, 'KEY_CHAT_RUN_STATUS'),
  KEY_CHAT_MSG_DELETE_TIME_TYPE(1006, 'KEY_CHAT_MSG_DELETE_TIME_TYPE'),
  KEY_CHAT_MSG_DELETE_TIME(1007, 'KEY_CHAT_MSG_DELETE_TIME'),
  KEY_CHAT_IMPORT_DB(1008, 'KEY_CHAT_IMPORT_DB'),
  KEY_IS_AGREE_USE_GIPHY(1009, 'KEY_IS_AGREE_USE_GIPHY'),
  KEY_DISTRIBUTOR_NAME(1010, 'KEY_DISTRIBUTOR_NAME'),// current Distributor
  KEY_SAVE_LOG_TIME(1011, 'KEY_SAVE_LOG_TIME'),
  KEY_DEFAULT_ZAP_AMOUNT(1012, 'KEY_DEFAULT_ZAP_AMOUNT'),
  KEY_DEFAULT_ZAP_DESCRIPTION(1013, 'KEY_DEFAULT_ZAP_DESCRIPTION'),
  KEY_ZAP_BADGE(1014, 'KEY_ZAP_BADGE'),
  KEY_OPEN_DEV_LOG(1015, 'KEY_OPEN_DEV_LOG'),
  KEY_THEME_INDEX(1016, 'KEY_THEME_INDEX'),
  KEY_OPEN_P2P_AND_RELAY(1017, 'KEY_OPEN_P2P_AND_RELAY'),
  KEY_IS_SHOW_WALLET_SELECTOR(1018, 'KEY_IS_SHOW_WALLET_SELECTOR'),
  KEY_DEFAULT_WALLET(1019, 'KEY_DEFAULT_WALLET'),
  KEY_ICE_SERVER(1020, 'KEY_ICE_SERVER'),
  KEY_FILE_STORAGE_SERVER(1021, 'KEY_FILE_STORAGE_SERVER'),
  KEY_FILE_STORAGE_SERVER_INDEX(1022, 'KEY_FILE_STORAGE_SERVER_INDEX'),
  KEY_DEFAULT_MINT_URL(1023, 'KEY_DEFAULT_MINT_URL'),
  KEY_WALLET_ACCESS(1024, 'KEY_WALLET_ACCESS'),
  KEY_ECASH_SAFE_TIPS_SEEN(1025, 'KEY_ECASH_SAFE_TIPS_SEEN'),
  KEY_SOUND_THEME(1026,'KEY_SOUND_THEME');

  final int keyIndex;
  final String name;
  const StorageSettingKey(this.keyIndex, this.name);

  static StorageSettingKey fromString(String name) {
    return StorageSettingKey.values.firstWhere((element) => element.name == name,
        orElse: () => throw ArgumentError('Invalid permission name: $name'));
  }

  static StorageSettingKey fromKeyIndex(int keyIndex) {
    return StorageSettingKey.values.firstWhere((element) => element.keyIndex == keyIndex,
        orElse: () => throw ArgumentError('Invalid permission name: $keyIndex'));
  }

}
