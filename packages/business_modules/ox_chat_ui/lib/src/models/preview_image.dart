import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A class that represents an image showed in a preview widget.
@immutable
class PreviewImage extends Equatable {
  /// Creates a preview image.
  const PreviewImage({
    required this.id,
    required this.uri,
    this.decryptSecret,
    this.decryptNonce,
  });

  /// Unique ID of the image.
  final String id;

  /// Image's URI.
  final String uri;

  final String? decryptSecret;
  final String? decryptNonce;

  /// Equatable props.
  @override
  List<Object> get props => [id, uri];
}
