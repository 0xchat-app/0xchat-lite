import 'package:ox_localizable/ox_localizable.dart';

enum EMomentMoreOptionType {
  copyNotedID,
  copyNotedText,
  shareNoted,
  block,
}

extension EMomentMoreOptionTypeEx on EMomentMoreOptionType{
  String get text {
    switch(this){
      case EMomentMoreOptionType.copyNotedID:
        return 'Copy Note ID';
      case EMomentMoreOptionType.copyNotedText:
        return 'Copy Note Text';
      case EMomentMoreOptionType.shareNoted:
        return 'Share Note';
      case EMomentMoreOptionType.block:
        return 'Block User';
    }
  }
}

enum EMomentOptionType {
  reply,
  repost,
  like,
  zaps,
}

enum EMomentType {
  video,
  picture,
  quote,
  content,
}

enum ENotificationsMomentType {
  reply,
  repost,
  like,
  zaps,
  quote
}

enum EMomentQuoteType {
  repost,
  quote,
  share,
}

enum EOptionMomentsType {
  personal,
  group
}

enum EPaymentType {
  lighting,
  ecash
}

extension EPaymentTypeEx on EPaymentType{
  String get text {
    switch (this) {
      case EPaymentType.lighting:
        return 'ZAPS';
      case EPaymentType.ecash:
        return 'ECASH';
    }
  }

  String get getIcon {
    switch (this) {
      case EPaymentType.lighting:
        return 'lighting_icon.png';
      case EPaymentType.ecash:
        return 'ecash_icon.png';
    }
  }
}


extension EMomentQuoteTypeEx on EMomentQuoteType{
  String get text {
    switch (this) {
      case EMomentQuoteType.repost:
        return Localized.text('ox_discovery.repost');
      case EMomentQuoteType.quote:
        return Localized.text('ox_discovery.quote');
      case EMomentQuoteType.share:
        return Localized.text('ox_discovery.share');
    }
  }

  String get getIconName {
    switch (this) {
      case EMomentQuoteType.repost:
        return 'repost_moment_icon.png';
      case EMomentQuoteType.quote:
        return 'quote_moment_icon.png';
      case EMomentQuoteType.share:
        return 'share_moment_icon.png';
    }
  }
}


extension ENotificationsMomentTypeEx on ENotificationsMomentType{
  String get text {
    switch (this) {
      case ENotificationsMomentType.reply:
        return Localized.text('ox_discovery.reply');
      case ENotificationsMomentType.repost:
        return Localized.text('ox_discovery.repost');
      case ENotificationsMomentType.like:
        return Localized.text('ox_discovery.like');
      case ENotificationsMomentType.zaps:
        return Localized.text('ox_discovery.zaps');
      case ENotificationsMomentType.quote:
        return Localized.text('ox_discovery.quote');
    }
  }

  String get getIconName {
    switch (this) {
      case ENotificationsMomentType.reply:
        return 'comment_moment_icon.png';
      case ENotificationsMomentType.repost:
        return 'repost_moment_icon.png';
      case ENotificationsMomentType.like:
        return 'like_moment_icon.png';
      case ENotificationsMomentType.zaps:
        return 'lightning_moment_icon.png';
      case ENotificationsMomentType.quote:
        return 'quote_moment_icon.png';
    }
  }

  int get kind {
    switch (this) {
      case ENotificationsMomentType.reply:
        return 1;
      case ENotificationsMomentType.repost:
        return 6;
      case ENotificationsMomentType.like:
        return 7;
      case ENotificationsMomentType.zaps:
        return 9735;
      case ENotificationsMomentType.quote:
        return 2;
    }
  }

}


extension EMomentOptionTypeEx on EMomentOptionType{
  String get text {
    switch (this) {
      case EMomentOptionType.reply:
        return Localized.text('ox_discovery.reply');
      case EMomentOptionType.repost:
        return Localized.text('ox_discovery.repost');
      case EMomentOptionType.like:
        return Localized.text('ox_discovery.like');
      case EMomentOptionType.zaps:
        return Localized.text('ox_discovery.zaps');
    }
  }

  String get getIconName {
    switch (this) {
      case EMomentOptionType.reply:
        return 'comment_moment_icon.png';
      case EMomentOptionType.repost:
        return 'repost_moment_icon.png';
      case EMomentOptionType.like:
        return 'like_moment_icon.png';
      case EMomentOptionType.zaps:
        return 'lightning_moment_icon.png';
    }
  }
}

