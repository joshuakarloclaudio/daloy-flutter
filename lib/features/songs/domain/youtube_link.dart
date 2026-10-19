/// YouTube links on songs — the twin of the YouTube half of the web's
/// `lib/streaming-links.ts`.
library;

final _videoId = RegExp(r'^[a-zA-Z0-9_-]{11}$');

String? _checked(String? id) => id != null && _videoId.hasMatch(id) ? id : null;

/// The video in a watch/share/embed/shorts/live URL, or null.
String? extractYouTubeVideoId(String url) {
  final trimmed = url.trim();
  final normalized = RegExp(r'^https?://', caseSensitive: false).hasMatch(trimmed)
      ? trimmed
      : trimmed.startsWith('//')
      ? 'https:$trimmed'
      : 'https://$trimmed';
  final uri = Uri.tryParse(normalized);
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (host == 'youtu.be') return _checked(segments.firstOrNull);
  if (host == 'youtube.com' || host.endsWith('.youtube.com')) {
    if (segments.length >= 2 && const {'shorts', 'embed', 'live', 'v'}.contains(segments.first)) {
      return _checked(segments[1]);
    }
    return _checked(uri.queryParameters['v']);
  }
  return null;
}

/// Accepts a bare 11-character id or any common YouTube URL.
String? resolveYouTubeVideoId(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  if (_videoId.hasMatch(trimmed)) return trimmed;
  return extractYouTubeVideoId(trimmed);
}

/// The one URL form a song's YouTube link is stored in.
String canonicalYouTubeUrl(String videoId) => 'https://www.youtube.com/watch?v=${Uri.encodeQueryComponent(videoId)}';

/// A song's playable video, or null without a (usable) link.
String? songYouTubeVideoId(String? youtubeUrl) {
  final raw = youtubeUrl?.trim();
  if (raw == null || raw.isEmpty) return null;
  return resolveYouTubeVideoId(raw);
}
