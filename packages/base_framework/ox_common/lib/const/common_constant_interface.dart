
abstract class ConstantInterface {

  const ConstantInterface();

  ///db version
  int get dbVersion => 10;

  /// 0xchat relay
  String get oxChatRelay => 'wss://relay.0xchat.com';

  /// nprofile: (0)User QRCode；
  int get qrCodeUser => 0;
  /// nevent: (1) Channel QRCode;
  int get qrCodeChannel => 1;
  /// nevent: (2) Group QRCode;
  int get qrCodeGroup => 2;
  /// nostr+walletconnect: (3) NWC
  int get qrCodeNWC => 3;

  String get baseUrl => 'https://www.0xchat.com';

  String get njumpURL =>  'https://njump.me/';

  String get APP_SCHEME => 'oxchat';

  String get NWC_SCHEME => 'nostr+walletconnect://';

  String get NOSTR_SCHEME => 'nostr://';

  /// share app link domain
  String get SHARE_APP_LINK_DOMAIN => 'https://www.0xchat.com/link';

  /// Push Notifications
  int get NOTIFICATION_PUSH_NOTIFICATIONS => 0;
  /// Private Messages
  int get NOTIFICATION_PRIVATE_MESSAGES => 1;
  /// Channels
  int get NOTIFICATION_CHANNELS => 2;
  /// Zaps
  int get NOTIFICATION_ZAPS => 3;
  /// Sound
  int get NOTIFICATION_SOUND => 4;
  /// Vibrate
  int get NOTIFICATION_VIBRATE => 5;
  ///like
  int get NOTIFICATION_REACTIONS => 6;
  ///reply&repos
  int get NOTIFICATION_REPLIES => 7;
  ///groups
  int get NOTIFICATION_GROUPS => 8;

  String get NOTICE_CHAT_ID => '1000000001';

  /// Aliyun OSS EndPoint
  String get ossEndPoint;

  /// Aliyun OSS BucketName
  String get ossBucketName;

  String get serverPubkey;
  String get serverSignKey;

  /// ios Bundle id
  String get bundleId;

  /// Giphy API Key
  String get giphyApiKey;
}