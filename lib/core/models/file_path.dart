// ignore_for_file: public_member_api_docs, sort_constructors_first

/// Simple holder for a possible `url` and `local` path alternative.
///
/// Use [resolve] to pick a preferred path (local first by default) and get a
/// normalized, trimmed string along with whether it's a local resource.
class KFilePath {
  final String? url;
  final String? local;

  const KFilePath({this.url, this.local});

  factory KFilePath.empty() => KFilePath(url: '', local: '');

  KFilePath copyWith({String? url, String? local}) {
    return KFilePath(url: url ?? this.url, local: local ?? this.local);
  }

  @override
  bool operator ==(covariant KFilePath other) {
    if (identical(this, other)) return true;

    return other.url == url && other.local == local;
  }

  @override
  int get hashCode => url.hashCode ^ local.hashCode;
}

extension FilePathExtension on KFilePath {
  bool get containsLocalPath => (local != null && local!.trim().isNotEmpty);
  bool get containsUrlPath => (url != null && url!.trim().isNotEmpty);
  bool get containsAnyPath => containsLocalPath || containsUrlPath;

  ({String? data, bool isLocal}) resolve({bool preferLocal = true}) {
    final first = preferLocal ? (local ?? url) : (url ?? local);
    final trimmed = first?.trim();

    if (trimmed?.isNotEmpty ?? false) {
      return (data: trimmed, isLocal: first == local);
    }
    return (data: null, isLocal: preferLocal);
  }
}
