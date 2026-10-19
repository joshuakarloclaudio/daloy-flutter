import SwiftUI
import WidgetKit

/// The home-screen widget: the next line-up and its songs, or "Plan a
/// line-up" when nothing is coming up. The app writes the next few line-ups
/// as JSON to the shared App Group
/// (`lib/features/home_screen_widget/home_screen_widget.dart`); each timeline
/// entry picks the first dated that day or later, so a passed one drops off
/// at midnight without the app running. Taps open `daloy://open<path>`,
/// which `SearchIndexPlugin` hands to Dart like a Spotlight hit.
struct NextLineUpWidget: Widget {
  static let kind = "NextLineUpWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: Self.kind, provider: NextLineUpProvider()) { entry in
      NextLineUpView(entry: entry)
        .containerBackground(for: .widget) { WidgetPalette.background }
    }
    .configurationDisplayName("Next line-up")
    .description("Your next line-up and its songs.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
  }
}

// MARK: - Data

private let appGroup = "group.pro.daloy.app"
private let dataKey = "next_line_ups"

struct WidgetSnapshot: Decodable {
  struct Song: Decodable {
    let title: String
    let key: String?
  }

  struct LineUp: Decodable {
    let id: Int
    let title: String
    /// `YYYY-MM-DD`, which sorts as it reads.
    let date: String
    let leader: String?
    let songsCount: Int
    let path: String
    let songs: [Song]?
  }

  /// Nil when signed out or without a workspace.
  let workspace: String?
  let lineUps: [LineUp]
  let newLineUpPath: String?

  static let empty = WidgetSnapshot(workspace: nil, lineUps: [], newLineUpPath: nil)

  static func load() -> WidgetSnapshot {
    guard let raw = UserDefaults(suiteName: appGroup)?.string(forKey: dataKey),
      let data = raw.data(using: .utf8),
      let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    else { return .empty }
    return snapshot
  }
}

struct NextLineUpEntry: TimelineEntry {
  let date: Date
  let workspace: String?
  let next: WidgetSnapshot.LineUp?
  let newLineUpPath: String

  var signedIn: Bool { workspace != nil }

  static let placeholder = NextLineUpEntry(
    date: .now,
    workspace: "Daloy",
    next: .init(
      id: 0, title: "Sunday Service", date: isoDate(.now), leader: "Leader", songsCount: 4, path: "/line-ups",
      songs: [
        .init(title: "Song one", key: "G"), .init(title: "Song two", key: "D"),
        .init(title: "Song three", key: "A"), .init(title: "Song four", key: "E"),
      ]),
    newLineUpPath: "/line-ups?new=1")
}

struct NextLineUpProvider: TimelineProvider {
  func placeholder(in context: Context) -> NextLineUpEntry { .placeholder }

  func getSnapshot(in context: Context, completion: @escaping (NextLineUpEntry) -> Void) {
    let snapshot = WidgetSnapshot.load()
    completion(context.isPreview && snapshot.lineUps.isEmpty ? .placeholder : entry(for: .now, snapshot))
  }

  /// Now, then each of the next three midnights; the app reloads the
  /// timeline whenever what it holds changes.
  func getTimeline(in context: Context, completion: @escaping (Timeline<NextLineUpEntry>) -> Void) {
    let snapshot = WidgetSnapshot.load()
    let calendar = Calendar.current
    var dates = [Date.now]
    var day = calendar.startOfDay(for: .now)
    for _ in 0..<3 {
      day = calendar.date(byAdding: .day, value: 1, to: day)!
      dates.append(day.addingTimeInterval(60))
    }
    completion(Timeline(entries: dates.map { entry(for: $0, snapshot) }, policy: .atEnd))
  }

  private func entry(for date: Date, _ snapshot: WidgetSnapshot) -> NextLineUpEntry {
    let today = isoDate(date)
    return NextLineUpEntry(
      date: date,
      workspace: snapshot.workspace,
      next: snapshot.lineUps.first { $0.date >= today },
      newLineUpPath: snapshot.newLineUpPath ?? "/line-ups?new=1")
  }
}

private func isoDate(_ date: Date) -> String {
  let format = DateFormatter()
  format.calendar = Calendar(identifier: .gregorian)
  format.locale = Locale(identifier: "en_US_POSIX")
  format.dateFormat = "yyyy-MM-dd"
  return format.string(from: date)
}

private func openURL(_ path: String?) -> URL? {
  path.flatMap { URL(string: "daloy://open\($0)") }
}

// MARK: - Views

/// `lib/core/theme/daloy_colors.dart`.
enum WidgetPalette {
  static let background = dynamic(light: 0xFFFFFF, dark: 0x18181B)
  static let foreground = dynamic(light: 0x09090B, dark: 0xFAFAFA)
  static let muted = dynamic(light: 0x71717B, dark: 0x9F9FA9)
  static let primary = dynamic(light: 0x007A55, dark: 0x006045)
  static let primaryInk = dynamic(light: 0x007A55, dark: 0x00BC7D)
  static let primaryForeground = Color(hex: 0xECFDF5)
  static let today = dynamic(light: 0x047857, dark: 0x34D399)

  private static func dynamic(light: UInt32, dark: UInt32) -> Color {
    Color(
      UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
  }
}

extension UIColor {
  fileprivate convenience init(hex: UInt32) {
    self.init(
      red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
  }
}

extension Color {
  fileprivate init(hex: UInt32) { self.init(UIColor(hex: hex)) }
}

struct NextLineUpView: View {
  let entry: NextLineUpEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    Group {
      if let next = entry.next {
        lineUp(next)
      } else {
        empty
      }
    }
    .widgetURL(openURL(tapPath))
  }

  /// Where a tap anywhere goes. The small widget opens one URL for all of
  /// it, so when empty that's "Plan a line-up"; bigger ones have a button.
  private var tapPath: String? {
    if let next = entry.next { return next.path }
    guard entry.signedIn else { return nil }
    return family == .systemSmall ? entry.newLineUpPath : "/line-ups"
  }

  private var songLimit: Int {
    switch family {
    case .systemMedium: 3
    case .systemLarge: 8
    default: 0
    }
  }

  @ViewBuilder
  private func lineUp(_ next: WidgetSnapshot.LineUp) -> some View {
    let isToday = next.date == isoDate(entry.date)
    let count = next.songsCount == 1 ? "1 song" : "\(next.songsCount) songs"
    let subtitle = [next.leader, count].compactMap { $0 }.joined(separator: " · ")

    if family == .accessoryRectangular {
      VStack(alignment: .leading, spacing: 1) {
        Text(eyebrow(next.date)).font(.caption2.weight(.semibold)).textCase(.uppercase)
        Text(next.title).font(.headline).lineLimit(1)
        Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    } else {
      VStack(alignment: .leading, spacing: 2) {
        Text(eyebrow(next.date))
          .font(.caption2.weight(.bold))
          .tracking(0.6)
          .textCase(.uppercase)
          .foregroundStyle(isToday ? WidgetPalette.today : WidgetPalette.primaryInk)
          .lineLimit(1)
        Text(next.title)
          .font(.system(family == .systemSmall ? .callout : .headline, design: .serif).weight(.bold))
          .foregroundStyle(WidgetPalette.foreground)
          .lineLimit(family == .systemSmall ? 3 : 1)
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(WidgetPalette.muted)
          .lineLimit(1)
        if songLimit > 0, let songs = next.songs, !songs.isEmpty {
          songList(Array(songs.prefix(songLimit)), more: next.songsCount - min(songs.count, songLimit))
            .padding(.top, 8)
        }
        Spacer(minLength: 0)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
  }

  private func songList(_ songs: [WidgetSnapshot.Song], more: Int) -> some View {
    VStack(alignment: .leading, spacing: family == .systemLarge ? 7 : 4) {
      ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
        HStack(spacing: 6) {
          Text("\(index + 1)")
            .font(.caption.monospacedDigit())
            .foregroundStyle(WidgetPalette.muted)
            .frame(width: 14, alignment: .leading)
          Text(song.title)
            .font(.subheadline)
            .foregroundStyle(WidgetPalette.foreground)
            .lineLimit(1)
          Spacer(minLength: 4)
          if let key = song.key {
            Text(key).font(.caption.weight(.bold)).foregroundStyle(WidgetPalette.primaryInk)
          }
        }
      }
      if more > 0 {
        Text("+\(more) more").font(.caption).foregroundStyle(WidgetPalette.muted).padding(.leading, 20)
      }
    }
  }

  @ViewBuilder
  private var empty: some View {
    if family == .accessoryRectangular {
      VStack(alignment: .leading, spacing: 1) {
        Text("Daloy").font(.caption2.weight(.semibold)).textCase(.uppercase)
        Text(entry.signedIn ? "No line-ups coming up" : "Open Daloy").font(.headline).lineLimit(2)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    } else {
      VStack(alignment: .leading, spacing: 2) {
        Text(entry.workspace ?? "Daloy")
          .font(.caption2.weight(.bold))
          .tracking(0.6)
          .textCase(.uppercase)
          .foregroundStyle(WidgetPalette.primaryInk)
          .lineLimit(1)
        Text(entry.signedIn ? "No line-ups coming up" : "Open Daloy to see your next line-up")
          .font(.system(.headline, design: .serif).weight(.bold))
          .foregroundStyle(WidgetPalette.foreground)
          .lineLimit(3)
        Spacer(minLength: 8)
        if entry.signedIn, let url = openURL(entry.newLineUpPath) {
          let label = Text("Plan a line-up")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(WidgetPalette.primaryForeground)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(WidgetPalette.primary))
          if family == .systemSmall {
            label
          } else {
            Link(destination: url) { label }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
  }

  private func eyebrow(_ date: String) -> String {
    let today = entry.date
    if date == isoDate(today) { return "Today" }
    if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today), date == isoDate(tomorrow) {
      return "Tomorrow"
    }
    let parse = DateFormatter()
    parse.locale = Locale(identifier: "en_US_POSIX")
    parse.dateFormat = "yyyy-MM-dd"
    guard let day = parse.date(from: date) else { return date }
    let sameYear = Calendar.current.isDate(day, equalTo: today, toGranularity: .year)
    return day.formatted(
      sameYear ? .dateTime.weekday(.abbreviated).month(.abbreviated).day() : .dateTime.month(.abbreviated).day().year())
  }
}

@main
struct DaloyWidgetBundle: WidgetBundle {
  var body: some Widget {
    NextLineUpWidget()
  }
}
