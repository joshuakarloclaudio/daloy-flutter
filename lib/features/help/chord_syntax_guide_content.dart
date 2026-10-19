/// The chord syntax guide's words, in English and Tagalog: the web's
/// `components/help/chord-syntax-guide-content.tsx`, as data. Keep the two in
/// step when either changes.
library;

enum GuideLanguage { en, tl }

/// One string in both languages.
typedef Tr = ({String en, String tl});

extension TrIn on Tr {
  String inLang(GuideLanguage language) => language == GuideLanguage.en ? en : tl;
}

Tr _same(String s) => (en: s, tl: s);

sealed class GuideBlock {
  const GuideBlock();
}

/// A paragraph; [small] for the quieter asides.
class GuideText extends GuideBlock {
  const GuideText(this.text, {this.small = false});

  final Tr text;
  final bool small;
}

/// A titled example: the text you type, then what it means.
class GuideEntry extends GuideBlock {
  const GuideEntry({required this.title, required this.code, required this.body});

  final Tr title;
  final String code;
  final Tr body;
}

/// A table whose leading [codeColumns] columns are typed text.
class GuideTable extends GuideBlock {
  const GuideTable({required this.headers, required this.rows, required this.codeColumns});

  final List<Tr> headers;

  /// Code cells are plain strings; the last cell of a row is the meaning.
  final List<(List<String> code, Tr meaning)> rows;
  final int codeColumns;
}

/// A chart snippet drawn the way the chart draws it.
class GuideExample extends GuideBlock {
  const GuideExample(this.content);

  final String content;
}

class GuideSection {
  const GuideSection({required this.id, required this.title, required this.blocks});

  final String id;
  final Tr title;
  final List<GuideBlock> blocks;
}

const Tr guideTitle = (en: 'Chord syntax guide', tl: 'Gabay sa pagsulat ng chord');

const Tr guideIntro = (
  en: 'Everything you can type into the chord editor, and exactly what it turns into.',
  tl: 'Lahat ng puwede mong itype sa chord editor, at kung ano talaga ang lalabas nito.',
);

final List<GuideSection> guideSections = [
  const GuideSection(
    id: 'basics',
    title: (en: 'The basics', tl: 'Mga pangunahin'),
    blocks: [
      GuideText((
        en: 'A chord chart is just text. Chords live inside square brackets — everything else on the line (lyrics, spacing, symbols) is read as-is.',
        tl: 'Text lang talaga ang chord chart. Nasa loob ng square brackets ang mga chord — ang lahat ng iba pa sa linya (lyrics, spacing, mga simbolo) ay binabasa nang eksakto kung ano ang nakasulat.',
      )),
      GuideEntry(
        title: (en: 'Typing a chord', tl: 'Pag-type ng chord'),
        code: '[C]  [Am]  [F#m]  [Bsus4]',
        body: (
          en: 'Type the chord name directly and press space, dash, or a new line — it auto-wraps in brackets for you. You almost never have to type the brackets yourself.',
          tl: 'I-type lang ang pangalan ng chord tapos pindutin ang space, dash, o bagong linya — awtomatikong may lalagyang bracket. Bihira mo pang kailanganing i-type mismo ang bracket.',
        ),
      ),
      GuideEntry(
        title: (en: "Case doesn't matter while typing", tl: 'Hindi importante ang malaki/maliit na letra'),
        code: 'c → [C]   am → [Am]',
        body: (
          en: "Type lowercase if that's faster — the root letter is capitalized for you automatically.",
          tl: 'Puwedeng maliit na letra kung mas mabilis — awtomatikong ginagawang malaki ang root letter.',
        ),
      ),
    ],
  ),
  GuideSection(
    id: 'qualities',
    title: (en: 'Chord qualities', tl: 'Klase ng chord'),
    blocks: [
      const GuideText((
        en: 'Add letters/numbers right after the root to change what kind of chord it is.',
        tl: 'Maglagay ng letra/numero pagkatapos ng root para baguhin ang klase ng chord.',
      )),
      const GuideText((
        en: 'In letters mode, a chord always shows exactly as typed (just with the root capitalized). The middle column only shows up in numbers mode, once a key is set — see that section further down. It assumes a key where 1 is C, just to line the columns up.',
        tl: 'Sa letters mode, laging lalabas ang chord nang eksakto kung paano ito na-type (root lang ang ginagawang malaki). Ang gitnang kolum ay lalabas lang sa numbers mode, kapag may naka-set nang key — makikita ang bahaging iyon sa ibaba. Ipinapalagay dito na ang 1 ay C, para lang lumapat ang mga kolum.',
      ), small: true),
      GuideTable(
        codeColumns: 2,
        headers: const [
          (en: 'You type', tl: 'Ita-type mo'),
          (en: 'In numbers mode', tl: 'Sa numbers mode'),
          (en: 'Meaning', tl: 'Kahulugan'),
        ],
        rows: [
          (['Cm', '1m'], _same('minor')),
          (['C7', '17'], _same('dominant 7th')),
          (['Cmaj7', '1Δ7'], _same('major 7th')),
          (['Cm7', '1m7'], _same('minor 7th')),
          (['Csus2', '1sus2'], _same('suspended 2nd')),
          (['Csus4', '1sus4'], _same('suspended 4th')),
          (['Cdim', '1°'], _same('diminished')),
          (['Cdim7', '1°7'], _same('diminished 7th')),
          (['Cm7b5', '1ø7'], _same('half-diminished')),
          (['Caug', '1+'], _same('augmented')),
          (['C6 / C9 / C11 / C13', '16 / 19 / 111 / 113'], (en: 'added extension', tl: 'dagdag na extension')),
          (['Cadd9', '1add9'], (en: 'added 9th, no 7th', tl: 'may dagdag na 9th, walang 7th')),
          (['Cm9', '1m9'], _same('minor 9th')),
        ],
      ),
      const GuideText((
        en: 'On the chord keyboard: hold down a root key and a grid of qualities pops up above it — slide to the one you want and lift your finger.',
        tl: 'Sa chord keyboard: pindutin nang matagal ang isang root key at may lalabas na grid ng mga klase sa itaas nito — i-slide papunta sa gusto mo at bitawan.',
      )),
    ],
  ),
  const GuideSection(
    id: 'bass',
    title: (en: 'Bass chords', tl: 'Bass chords'),
    blocks: [
      GuideEntry(
        title: (en: 'Slash chord', tl: 'Slash chord'),
        code: 'G/B  →  [G]/[B]',
        body: (
          en: "Type the chord, a slash, then the bass note, and press space — both get wrapped, one bracket each. The bass note is what's actually played on the bottom (here, a G chord with a B in the bass).",
          tl: 'I-type ang chord, tapos slash, tapos ang bass note, saka pindutin ang space — magkakaroon ng sariling bracket ang bawat isa. Ang bass note ang aktwal na tunog sa ibaba (dito, G chord pero B ang nasa baba).',
        ),
      ),
      GuideEntry(
        title: (en: 'Quick bass notes on the keyboard', tl: 'Mabilisang bass note sa keyboard'),
        code: 'hold “/” key',
        body: (
          en: "With the cursor on a chord, hold the / key on the chord keyboard for a grid of that chord's diatonic bass notes.",
          tl: 'Kapag nasa chord ang cursor, pindutin nang matagal ang / key sa chord keyboard para makita ang mga diatonic bass note ng chord na iyon.',
        ),
      ),
    ],
  ),
  const GuideSection(
    id: 'sections',
    title: (en: 'Section labels', tl: 'Mga label ng bahagi'),
    blocks: [
      GuideText((
        en: 'A word by itself on a line, ending in a colon, becomes a section label — Verse, Chorus, Bridge, anything you name.',
        tl: 'Ang isang salitang mag-isa sa isang linya, na may kasunod na colon, ay nagiging label ng bahagi — Verse, Chorus, Bridge, kahit anong itawag mo.',
      )),
      GuideEntry(
        title: (en: 'Plain form', tl: 'Plain na anyo'),
        code: 'Verse:\nChorus:\nPre-Chorus 2:',
        body: (
          en: 'The simplest way to mark a section, and what the Sections tab inserts for you. Nothing else should be on that line.',
          tl: 'Ang pinakasimpleng paraan ng paglagay ng bahagi, at ito ang ilalagay ng Sections tab kapag pinindot mo ito. Walang ibang dapat nasa linyang iyon.',
        ),
      ),
      GuideEntry(
        title: (en: 'Bracketed form', tl: 'May bracket na anyo'),
        code: '[Chorus]',
        body: (en: 'Also works, and reads exactly the same.', tl: 'Gumagana rin ito, at pareho lang ang pagbasa.'),
      ),
    ],
  ),
  const GuideSection(
    id: 'repeats',
    title: (en: 'Repeat markers', tl: 'Tanda ng ulit'),
    blocks: [
      GuideText((
        en: "Add x2, x3, x4… (or 2x, 3x…) right after a section, a bar line, or a bare chord line to mark how many times it's played.",
        tl: 'Maglagay ng x2, x3, x4… (o 2x, 3x…) pagkatapos ng bahagi, bar line, o chord line para markahan kung ilang beses itong tinutugtog.',
      )),
      GuideEntry(
        title: (en: 'On a section', tl: 'Sa isang bahagi'),
        code: 'Chorus: x2\n[Chorus] x2',
        body: (
          en: 'The whole section repeats that many times before moving on.',
          tl: 'Uulitin ang buong bahagi ng ganoong dami bago tumuloy sa susunod.',
        ),
      ),
      GuideEntry(
        title: (en: 'On a bar line', tl: 'Sa bar line'),
        code: '| [C] | [G] | x4',
        body: (
          en: 'Just that line of bars repeats — handy for a riff or a vamp.',
          tl: 'Ang linyang iyon lang ng mga bar ang uulitin — magandang gamitin para sa riff o vamp.',
        ),
      ),
    ],
  ),
  const GuideSection(
    id: 'bars',
    title: (en: 'Bar lines', tl: 'Bar lines'),
    blocks: [
      GuideText((
        en: 'A | groups chords into measures. This is what lets the metronome and practice mode count along with the chart. The opening and closing | are optional.',
        tl: 'Ang | ay naghihiwalay ng mga chord sa bawat measure. Ito ang dahilan kung bakit kayang bilangin ng metronome at practice mode ang chart. Optional ang unang at huling |.',
      )),
      GuideEntry(
        title: (en: 'Grouping chords', tl: 'Paghihiwalay ng mga chord'),
        code: '| [C] [G] | [Am] [F] |',
        body: (
          en: "Two chords in the first bar, two in the second. Without dots or dashes to say exactly when each one lands, practice mode doesn't guess — it highlights both chords together for the whole bar. Add beat placeholders (next section) to place them on specific beats instead.",
          tl: 'Dalawang chord sa unang bar, dalawa sa pangalawa. Kung walang tuldok o dash na magsasabi kung kailan eksaktong tutunog ang bawat isa, hindi nagha-hulaan ang practice mode — pareho itong ino-highlight sa buong bar. Magdagdag ng beat placeholder (susunod na bahagi) para tumama sila sa tiyak na beat.',
        ),
      ),
      GuideExample('Verse:\n| [C] [G] | [Am] [F] |'),
    ],
  ),
  const GuideSection(
    id: 'beats',
    title: (en: 'Beats inside a bar', tl: 'Beats sa loob ng bar'),
    blocks: [
      GuideText((
        en: 'Inside a bar, use ., -, _ or a bare / (with spaces around it) as a beat placeholder. Each one extends whichever chord came right before it, one beat at a time.',
        tl: 'Sa loob ng bar, gamitin ang ., -, _ o mag-isang / (may space sa magkabila) bilang beat placeholder. Ang bawat isa ay nagpapatuloy sa chord na nauna dito, isang beat kada isa.',
      )),
      GuideEntry(
        title: (en: 'One placeholder per chord', tl: 'Isang placeholder kada chord'),
        code: '| [C] . [G] . |    | [C] - [G] - |',
        body: (
          en: "In 4/4, both of these read as: C for two beats, then G for two beats. A placeholder right after a chord adds one more beat to that same chord — it doesn't split the bar evenly on its own.",
          tl: 'Sa 4/4, pareho itong binabasa bilang: C sa loob ng dalawang beat, tapos G naman sa dalawa. Ang placeholder na kasunod ng isang chord ay nagdaragdag ng isa pang beat sa parehong chord — hindi ito basta-basta naghahati ng bar nang pantay.',
        ),
      ),
      GuideEntry(
        title: (
          en: 'Placeholders stack onto the chord before them',
          tl: 'Nagdadagdag ang placeholder sa chord bago rito',
        ),
        code: '| [C] . . [G] |',
        body: (
          en: "This is not two beats each — every placeholder extends whatever came right before it. Here that's C held for three beats, then G for the last one.",
          tl: 'Hindi ito dalawang beat kada isa — ang bawat placeholder ay nagpapatuloy lang sa nauna dito. Dito, tatlong beat ang C, tapos isang beat na lang ang G.',
        ),
      ),
      GuideEntry(
        title: (en: 'A run of dots', tl: 'Sunod-sunod na tuldok'),
        code: '| [C] .. [G] |',
        body: (
          en: 'Written together with no spaces, .. still adds two more beats onto C — the exact same three-beats-C, one-beat-G result as ". ." written apart.',
          tl: 'Kahit magkadikit na sinulat, ang .. ay nagdaragdag pa rin ng dalawang beat sa C — parehong-pareho ng resulta ng ". ." na hiwalay isinulat: tatlong beat na C, isang beat na G.',
        ),
      ),
      GuideEntry(
        title: (en: "Don't confuse with a slash chord", tl: 'Huwag ipagkamali sa slash chord'),
        code: '[G]/[B]  (bass chord)\n[G] / [B]  (G, then B — separator)',
        body: (
          en: 'A / stuck directly to two chords is a bass chord. The same / with spaces around it is just a beat placeholder — it splits the bar instead.',
          tl: 'Ang / na nakadikit sa dalawang chord ay bass chord. Ang parehong / na may space sa magkabila ay beat placeholder lang — naghahati ito ng bar.',
        ),
      ),
      GuideExample('Verse:\n| [C] . [G] . |\n| [C] . . [G] |'),
    ],
  ),
  const GuideSection(
    id: 'short-bars',
    title: (en: 'Short bars', tl: 'Maiksing bar'),
    blocks: [
      GuideText((
        en: 'Sometimes a chord only needs to ring for part of a bar before the next section starts — a 2-count hold in a 4/4 song, for example. Write fewer beat placeholders than the time signature calls for, and that one bar becomes exactly that short.',
        tl: 'Minsan, kailangan lang tumunog ang isang chord ng kalahati ng bar bago magsimula ang susunod na bahagi — halimbawa, 2 counts na lang sa isang 4/4 na kanta. Maglagay ng mas kaunting beat placeholder kaysa sa hinihingi ng time signature, at magiging kasingiksi lang niyan ang bar na iyon.',
      )),
      GuideEntry(
        title: (en: 'A 2-beat bar in 4/4', tl: '2-beat na bar sa 4/4'),
        code: '| [G] . [A] . |\n| [A] . |\nChorus:\n| [C] | [G] |',
        body: (
          en: "A held for its usual 2 beats, then just 2 more before the chorus — not a full extra bar. The click and the chord highlight both shorten to match; the very next click lands right on the chorus's first chord.",
          tl: '2 beats muna ang A gaya ng dati, tapos 2 pa bago ang chorus — hindi na kumpletong bar pa. Magiging kasingiksi rin ang click at ang naka-highlight na chord; ang susunod na click ay tatama mismo sa unang chord ng chorus.',
        ),
      ),
      GuideText((
        en: 'This only kicks in when you deliberately write a rhythm with placeholders. A plain | [A] | with no dots always plays a full bar, exactly as before.',
        tl: 'Gagana lang ito kapag sinadya mong maglagay ng rhythm gamit ang placeholder. Ang plain na | [A] | na walang tuldok ay laging kumpletong bar, gaya noon.',
      ), small: true),
    ],
  ),
  const GuideSection(
    id: 'simile',
    title: (en: 'The % mark', tl: 'Ang % na tanda'),
    blocks: [
      GuideEntry(
        title: (en: 'Repeat the bar before it', tl: 'Ulitin ang naunang bar'),
        code: '| [C] | % | [G] | % |',
        body: (
          en: 'A % bar sounds exactly like the bar right before it. Handy for a long stretch of the same chord without retyping it every bar. It even carries across lines and into the next section if nothing new is written.',
          tl: 'Ang bar na may % ay tunog eksaktong kapareho ng bar na bago rito. Magandang gamitin kung matagal ang parehong chord nang hindi na kailangang ulit-ulitin i-type. Nagpapatuloy pa nga ito kahit sa susunod na linya o bahagi kung walang bago pang nakasulat.',
        ),
      ),
    ],
  ),
  const GuideSection(
    id: 'numbers',
    title: (en: 'Number system', tl: 'Number system'),
    blocks: [
      GuideText((
        en: "The Nashville Number System writes chords as scale degrees instead of letters, so the same chart transposes just by changing the key. It only works once the song has a key set — Daloy always saves letters underneath; numbers are just how they're shown and typed.",
        tl: 'Sinusulat ng Nashville Number System ang mga chord bilang scale degree sa halip na letra, kaya ang parehong chart ay puwedeng lang baguhin ang key para mag-transpose. Gagana lang ito kapag may naka-set nang key ang kanta — laging naka-save sa letra sa likod ang Daloy; ang numero ay paraan lang ng pagpapakita at pag-type.',
      )),
      GuideEntry(
        title: (en: 'Typing a degree', tl: 'Pag-type ng degree'),
        code: '1  →  the I chord\n6m  →  the vi chord',
        body: (
          en: 'With the cursor not on a chord, 1 through 7 insert a chord by scale degree. b or # before the number flattens or sharpens it.',
          tl: 'Kapag hindi nasa isang chord ang cursor, ang 1 hanggang 7 ay naglalagay ng chord ayon sa scale degree. Ang b o # bago ang numero ay nagpapababa o nagpapataas dito.',
        ),
      ),
      GuideEntry(
        title: (en: 'Qualities work the same way', tl: 'Pareho rin ang paraan ng klase'),
        code: '6m7  →  vi chord, minor 7th',
        body: (
          en: 'Add letters or digits right after the degree, same as a letter chord — 6m7 is the vi chord as a minor 7th (Am7 in the key of C). With the cursor already sitting on an existing chord instead, pressing 6, 7 or 9 adds that extension to it directly, without retyping the whole thing.',
          tl: 'Maglagay ng letra o numero kaagad pagkatapos ng degree, gaya ng sa letter chord — ang 6m7 ay ang vi chord bilang minor 7th (Am7 sa key na C). Kung nasa isang existing chord na ang cursor, ang pagpindot ng 6, 7, o 9 ay direktang magdaragdag ng extension dito, nang hindi na kailangang i-type ulit ang buong chord.',
        ),
      ),
      GuideText((
        en: 'Qualities print with standard symbols: ° for diminished, ø7 for half-diminished, + for augmented, Δ7 for major 7th. Typing dim, m7b5, aug, or maj7 works exactly the same as typing the symbol.',
        tl: 'Ang mga klase ay lumalabas gamit ang standard na simbolo: ° para sa diminished, ø7 para sa half-diminished, + para sa augmented, Δ7 para sa major 7th. Ang pag-type ng dim, m7b5, aug, o maj7 ay kaparehong-kapareho ng pag-type ng simbolo.',
      )),
    ],
  ),
  GuideSection(
    id: 'cheatsheet',
    title: (en: 'Cheat sheet', tl: 'Buod'),
    blocks: [
      GuideTable(
        codeColumns: 1,
        headers: const [(en: 'Symbol', tl: 'Simbolo'), (en: 'Means', tl: 'Ibig sabihin')],
        rows: [
          (['[C]'], (en: 'A chord', tl: 'Isang chord')),
          (['[G]/[B]'], (en: 'Bass note (no spaces around /)', tl: 'Bass note (walang space sa /)')),
          (['Verse:  /  [Chorus]'], (en: 'Section label', tl: 'Label ng bahagi')),
          (['x2, 2x'], (en: 'Repeat count', tl: 'Bilang ng ulit')),
          (['|'], _same('Bar line')),
          (['. - _ /'], (en: 'Beat placeholder (with spaces)', tl: 'Beat placeholder (may space)')),
          (['%'], (en: 'Same as the bar before it', tl: 'Kapareho ng bar na bago rito')),
          (
            ['1–7, b/#'],
            (en: 'Scale-degree chord (numbers notation)', tl: 'Chord ayon sa scale degree (numbers notation)'),
          ),
        ],
      ),
    ],
  ),
];
