/// Event names the API accepts (`App\Enums\AnalyticsEventName`).
enum AnalyticsEvent {
  screenView('screen_view'),
  appOpened('app_opened'),
  wentOffline('went_offline'),
  wentOnline('went_online'),
  login('login'),
  logout('logout'),
  songCreated('song_created'),
  songUpdated('song_updated'),
  songDeleted('song_deleted'),
  songSearched('song_searched'),
  lineUpCreated('line_up_created'),
  performanceStarted('performance_started'),
  practiceStarted('practice_started'),
  shareLinkCreated('share_link_created'),
  musicPlayerOpened('music_player_opened'),
  musicPlayerClosed('music_player_closed'),
  musicTrackPlayed('music_track_played'),
  musicTrackUnavailable('music_track_unavailable'),

  // App only.
  appBackgrounded('app_backgrounded'),
  presentStarted('present_started'),
  exported('exported'),
  liveSessionStarted('live_session_started'),
  liveSessionJoined('live_session_joined'),
  liveSessionLed('live_session_led'),
  networkSongImported('network_song_imported'),
  presentRemotePaired('present_remote_paired'),
  externalDisplayConnected('external_display_connected'),
  biometricLockEnabled('biometric_lock_enabled');

  const AnalyticsEvent(this.wire);

  final String wire;
}

/// Flat values only, as the API stores them.
typedef AnalyticsProperties = Map<String, Object?>;
