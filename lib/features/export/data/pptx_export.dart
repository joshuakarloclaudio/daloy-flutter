/// Lyrics as PowerPoint slides, written on the device. There is no mature
/// Dart PPTX library, so this writes the Open XML parts itself: one master,
/// one blank layout, a theme, and the slides. Same deck as the web's
/// pptxgenjs export: a dark title slide per song, then a slide per section
/// with its label above and the song's title below. Pure Dart.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../domain/export_sheet.dart';

// 16:9 in EMU (13.333in × 7.5in).
const _slideW = 12192000;
const _slideH = 6858000;

const _background = '1E293B';
const _foreground = 'F8FAFC';
const _subtle = '94A3B8';
const _label = '64748B';
const _watermark = '334155';
const _face = 'Arial';

/// The lyrics of every song in [set] as a .pptx file.
Uint8List buildLyricsPptx(ExportSet set) {
  final slides = <String>[];
  for (final s in set.songs) {
    final key = s.soundingKey;
    slides.add(
      _slide([
        _textBox(1, s.song.title, y: .35, h: .20, size: 40, color: _foreground, bold: true),
        if ([?_blank(s.song.artist), if (key != null) 'Key of $key'] case final parts when parts.isNotEmpty)
          _textBox(2, parts.join('  ·  '), y: .57, h: .10, size: 18, color: _subtle),
      ]),
    );

    for (final section in lyricSlides(s)) {
      final count = section.lines.length;
      final size = count <= 2 ? 36 : (count <= 4 ? 28 : 22);
      final hasLabel = section.label.isNotEmpty;
      slides.add(
        _slide([
          if (hasLabel) _textBox(1, section.label.toUpperCase(), y: .05, h: .08, size: 10, color: _label, spacing: 300),
          _textBox(
            2,
            section.lines,
            y: hasLabel ? .15 : .10,
            h: .75,
            size: size,
            color: _foreground,
            middle: true,
            lineSpacing: 140,
          ),
          _textBox(3, s.song.title, y: .90, h: .08, size: 10, color: _watermark),
        ]),
      );
    }
  }
  if (slides.isEmpty) slides.add(_slide([_textBox(1, set.title, y: .35, h: .2, size: 40, color: _foreground)]));
  return _package(set.title, slides);
}

String? _blank(String? v) => v == null || v.trim().isEmpty ? null : v.trim();

/// [text] made safe for XML, dropping control characters it can't hold.
String _esc(String text) =>
    const HtmlEscape(HtmlEscapeMode.element)
        .convert(text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), ''))
        .replaceAll('"', '&quot;');

/// A centred text box spanning 90% of the width, [y] and [h] as fractions
/// of the slide. [text] is a line or a list of lines (one paragraph each).
String _textBox(
  int id,
  Object text, {
  required double y,
  required double h,
  required int size,
  required String color,
  bool bold = false,
  bool middle = false,
  int? spacing,
  int? lineSpacing,
}) {
  final lines = text is List<String> ? text : [text as String];
  final paragraphs = lines.map((line) {
    final spc = lineSpacing == null ? '' : '<a:lnSpc><a:spcPct val="${lineSpacing * 1000}"/></a:lnSpc>';
    final run =
        '<a:r><a:rPr lang="en-US" sz="${size * 100}"${bold ? ' b="1"' : ''}${spacing == null ? '' : ' spc="$spacing"'} dirty="0">'
        '<a:solidFill><a:srgbClr val="$color"/></a:solidFill>'
        '<a:latin typeface="$_face"/><a:cs typeface="$_face"/></a:rPr><a:t>${_esc(line)}</a:t></a:r>';
    return '<a:p><a:pPr algn="ctr">$spc</a:pPr>$run</a:p>';
  }).join();

  return '<p:sp><p:nvSpPr><p:cNvPr id="${id + 1}" name="Text $id"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>'
      '<p:spPr><a:xfrm><a:off x="${(_slideW * .05).round()}" y="${(_slideH * y).round()}"/>'
      '<a:ext cx="${(_slideW * .9).round()}" cy="${(_slideH * h).round()}"/></a:xfrm>'
      '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/></p:spPr>'
      '<p:txBody><a:bodyPr wrap="square" rtlCol="0" anchor="${middle ? 'ctr' : 't'}"><a:normAutofit/></a:bodyPr>'
      '<a:lstStyle/>$paragraphs</p:txBody></p:sp>';
}

const _ns =
    'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
    'xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"';

const _xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n';

const _emptyTree =
    '<p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>'
    '<p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>';

String _slide(List<String> shapes) =>
    '$_xml<p:sld $_ns><p:cSld><p:bg><p:bgPr><a:solidFill><a:srgbClr val="$_background"/></a:solidFill><a:effectLst/></p:bgPr></p:bg>'
    '<p:spTree>$_emptyTree${shapes.join()}</p:spTree></p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sld>';

const _rel = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
const _pkgRel = 'http://schemas.openxmlformats.org/package/2006/relationships';

String _rels(List<(String id, String type, String target)> rels) =>
    '$_xml<Relationships xmlns="$_pkgRel">'
    '${rels.map((r) => '<Relationship Id="${r.$1}" Type="${r.$2}" Target="${r.$3}"/>').join()}'
    '</Relationships>';

Uint8List _package(String title, List<String> slides) {
  final n = slides.length;
  final archive = Archive();
  void add(String name, String content) => archive.addFile(ArchiveFile.string(name, content));

  add(
    '[Content_Types].xml',
    '$_xml<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>'
        '<Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>'
        '<Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>'
        '<Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>'
        '<Override PartName="/ppt/presProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presProps+xml"/>'
        '<Override PartName="/ppt/viewProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml"/>'
        '<Override PartName="/ppt/tableStyles.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.tableStyles+xml"/>'
        '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
        '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>'
        '${[for (var i = 1; i <= n; i++) '<Override PartName="/ppt/slides/slide$i.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>'].join()}'
        '</Types>',
  );

  add(
    '_rels/.rels',
    _rels([
      ('rId1', '$_rel/officeDocument', 'ppt/presentation.xml'),
      (
        'rId2',
        'http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties',
        'docProps/core.xml',
      ),
      ('rId3', '$_rel/extended-properties', 'docProps/app.xml'),
    ]),
  );

  add(
    'docProps/core.xml',
    '$_xml<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
        'xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        '<dc:title>${_esc(title)}</dc:title><dc:creator>Daloy</dc:creator></cp:coreProperties>',
  );
  add(
    'docProps/app.xml',
    '$_xml<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">'
        '<Application>Daloy</Application><Slides>$n</Slides></Properties>',
  );

  // presentation.xml: rId1 master, rId2–4 props, slides from rId10.
  add(
    'ppt/presentation.xml',
    '$_xml<p:presentation $_ns saveSubsetFonts="1">'
        '<p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/></p:sldMasterIdLst>'
        '<p:sldIdLst>${[for (var i = 0; i < n; i++) '<p:sldId id="${256 + i}" r:id="rId${10 + i}"/>'].join()}</p:sldIdLst>'
        '<p:sldSz cx="$_slideW" cy="$_slideH"/><p:notesSz cx="6858000" cy="9144000"/>'
        '<p:defaultTextStyle><a:defPPr><a:defRPr lang="en-US"/></a:defPPr></p:defaultTextStyle>'
        '</p:presentation>',
  );
  add(
    'ppt/_rels/presentation.xml.rels',
    _rels([
      ('rId1', '$_rel/slideMaster', 'slideMasters/slideMaster1.xml'),
      ('rId2', '$_rel/presProps', 'presProps.xml'),
      ('rId3', '$_rel/viewProps', 'viewProps.xml'),
      ('rId4', '$_rel/theme', 'theme/theme1.xml'),
      ('rId5', '$_rel/tableStyles', 'tableStyles.xml'),
      for (var i = 0; i < n; i++) ('rId${10 + i}', '$_rel/slide', 'slides/slide${i + 1}.xml'),
    ]),
  );

  add('ppt/presProps.xml', '$_xml<p:presentationPr $_ns/>');
  add(
    'ppt/viewProps.xml',
    '$_xml<p:viewPr $_ns><p:normalViewPr><p:restoredLeft sz="15620"/><p:restoredTop sz="94660"/></p:normalViewPr>'
        '<p:gridSpacing cx="76200" cy="76200"/></p:viewPr>',
  );
  add(
    'ppt/tableStyles.xml',
    '$_xml<a:tblStyleLst xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
        'def="{5C22544A-7EE6-4342-B048-85BDC9FD1C3A}"/>',
  );

  add(
    'ppt/slideMasters/slideMaster1.xml',
    '$_xml<p:sldMaster $_ns><p:cSld><p:bg><p:bgRef idx="1001"><a:schemeClr val="bg1"/></p:bgRef></p:bg>'
        '<p:spTree>$_emptyTree</p:spTree></p:cSld>'
        '<p:clrMap bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" accent1="accent1" accent2="accent2" accent3="accent3" '
        'accent4="accent4" accent5="accent5" accent6="accent6" hlink="hlink" folHlink="folHlink"/>'
        '<p:sldLayoutIdLst><p:sldLayoutId id="2147483649" r:id="rId1"/></p:sldLayoutIdLst>'
        '<p:txStyles><p:titleStyle><a:lvl1pPr><a:defRPr sz="4400"/></a:lvl1pPr></p:titleStyle>'
        '<p:bodyStyle><a:lvl1pPr><a:defRPr sz="2800"/></a:lvl1pPr></p:bodyStyle>'
        '<p:otherStyle><a:lvl1pPr><a:defRPr sz="1800"/></a:lvl1pPr></p:otherStyle></p:txStyles></p:sldMaster>',
  );
  add(
    'ppt/slideMasters/_rels/slideMaster1.xml.rels',
    _rels([
      ('rId1', '$_rel/slideLayout', '../slideLayouts/slideLayout1.xml'),
      ('rId2', '$_rel/theme', '../theme/theme1.xml'),
    ]),
  );

  add(
    'ppt/slideLayouts/slideLayout1.xml',
    '$_xml<p:sldLayout $_ns type="blank" preserve="1"><p:cSld name="Blank"><p:spTree>$_emptyTree</p:spTree></p:cSld>'
        '<p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sldLayout>',
  );
  add(
    'ppt/slideLayouts/_rels/slideLayout1.xml.rels',
    _rels([('rId1', '$_rel/slideMaster', '../slideMasters/slideMaster1.xml')]),
  );

  add('ppt/theme/theme1.xml', _theme);

  for (final (i, slide) in slides.indexed) {
    add('ppt/slides/slide${i + 1}.xml', slide);
    add(
      'ppt/slides/_rels/slide${i + 1}.xml.rels',
      _rels([('rId1', '$_rel/slideLayout', '../slideLayouts/slideLayout1.xml')]),
    );
  }

  return Uint8List.fromList(ZipEncoder().encode(archive));
}

String _solid(String hex) => '<a:solidFill><a:srgbClr val="$hex"/></a:solidFill>';

final _theme =
    '$_xml<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Daloy">'
    '<a:themeElements>'
    '<a:clrScheme name="Daloy">'
    '<a:dk1><a:srgbClr val="000000"/></a:dk1><a:lt1><a:srgbClr val="FFFFFF"/></a:lt1>'
    '<a:dk2><a:srgbClr val="$_background"/></a:dk2><a:lt2><a:srgbClr val="$_foreground"/></a:lt2>'
    '<a:accent1><a:srgbClr val="008236"/></a:accent1><a:accent2><a:srgbClr val="2563EB"/></a:accent2>'
    '<a:accent3><a:srgbClr val="$_subtle"/></a:accent3><a:accent4><a:srgbClr val="$_label"/></a:accent4>'
    '<a:accent5><a:srgbClr val="$_watermark"/></a:accent5><a:accent6><a:srgbClr val="F59E0B"/></a:accent6>'
    '<a:hlink><a:srgbClr val="2563EB"/></a:hlink><a:folHlink><a:srgbClr val="7C3AED"/></a:folHlink>'
    '</a:clrScheme>'
    '<a:fontScheme name="Daloy">'
    '<a:majorFont><a:latin typeface="$_face"/><a:ea typeface=""/><a:cs typeface=""/></a:majorFont>'
    '<a:minorFont><a:latin typeface="$_face"/><a:ea typeface=""/><a:cs typeface=""/></a:minorFont>'
    '</a:fontScheme>'
    '<a:fmtScheme name="Daloy">'
    '<a:fillStyleLst>${_solid('FFFFFF') * 3}</a:fillStyleLst>'
    '<a:lnStyleLst>${'<a:ln w="9525">${_solid('000000')}</a:ln>' * 3}</a:lnStyleLst>'
    '<a:effectStyleLst>${'<a:effectStyle><a:effectLst/></a:effectStyle>' * 3}</a:effectStyleLst>'
    '<a:bgFillStyleLst>${_solid('FFFFFF') * 3}</a:bgFillStyleLst>'
    '</a:fmtScheme>'
    '</a:themeElements><a:objectDefaults/><a:extraClrSchemeLst/></a:theme>';
