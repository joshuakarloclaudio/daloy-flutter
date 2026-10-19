/// Every path in the app, in one place.
abstract final class Routes {
  static const signIn = '/sign-in';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  /// Reachable while signed out; everything else redirects to [signIn].
  static const signedOut = {signIn, register, forgotPassword};

  /// Where the link in a reset email lands; open to anyone.
  static const resetPassword = '/reset-password';

  /// A workspace's people, join link and invitations (admins).
  static const team = '/team';

  static String join(String token) => '/join/$token';
  static String invite(String token) => '/invite/$token';

  /// Joining from a link is open to the signed out (they sign in first) and
  /// to the signed in who have no workspace yet.
  static bool isJoin(String location) => location.startsWith('/join/') || location.startsWith('/invite/');
  static const home = '/';
  static const songs = '/songs';
  static const lineUps = '/line-ups';

  /// Line-ups, opening the new-line-up sheet — the home-screen widget's
  /// "Plan a line-up".
  static const newLineUp = '/line-ups?new=1';
  static const profile = '/profile';
  static const chordSyntaxGuide = '/help/chord-syntax';

  /// What's saved on this device, and clearing it.
  static const storage = '/storage';

  /// Signed in, but no workspace yet.
  static const workspaceSetup = '/setup';

  static String song(int id) => '/songs/$id';

  /// The song opened at [line] of its chords or lyrics ([view]: `chords` /
  /// `lyrics`), lit briefly — where a search hit on its words lands.
  static String songAt(int id, {required int line, required String view}) => '/songs/$id?line=$line&view=$view';
  static const search = '/search';
  static String songEdit(int id) => '/songs/$id/edit';
  static String songPractice(int id) => '/songs/$id/practice';
  static String songListen(int id) => '/songs/$id/listen';
  static String songPresent(int id) => '/songs/$id/present';
  static String lineUp(int id) => '/line-ups/$id';
  static String lineUpEdit(int id) => '/line-ups/$id/edit';

  /// Notes and section order; [song] scrolls to that song, [notes] opens on
  /// the notes.
  static String lineUpPrepare(int id, {int? song, bool notes = false}) => Uri(
    path: '/line-ups/$id/prepare',
    queryParameters: {'song': ?song?.toString(), if (notes) 'tab': 'notes'},
  ).toString().replaceFirst(RegExp(r'\?$'), '');
  static String perform(int id) => '/line-ups/$id/perform';

  /// Perform, going live as it opens.
  static String performLive(int id) => '/line-ups/$id/perform?live=1';
  static String practice(int id) => '/line-ups/$id/practice';
  static String present(int id) => '/line-ups/$id/present';
  static String listen(int id) => '/line-ups/$id/listen';
}
