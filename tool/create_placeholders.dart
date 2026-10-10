// Run with:  dart run tool/create_placeholders.dart
// Creates minimal valid placeholder assets so the app runs without downloads.

import 'dart:convert';
import 'dart:io';

void main() async {
  await _makeDir('assets/sounds');
  await _makeDir('assets/sprites');
  await _makeDir('assets/rive');
  await _makeDir('assets/animations');
  await _makeDir('assets/images/characters');
  await _makeDir('assets/images/worlds');
  await _makeDir('assets/images/ui');

  // ── Sounds (minimal silent WAV, 16-bit PCM, 8000 Hz, mono) ──────────
  final silentWav = _buildSilentWav(durationMs: 800);
  for (final name in [
    'success',
    'wrong_soft',
    'bonus',
    'tap_soft',
    'underwater_ambience',
  ]) {
    final f = File('assets/sounds/$name.mp3');
    if (!f.existsSync()) {
      f.writeAsBytesSync(silentWav);
      print('✅ Created  assets/sounds/$name.mp3  (silent WAV placeholder)');
    } else {
      print('⏭️  Skipped  assets/sounds/$name.mp3  (already exists)');
    }
  }

  // ── Sprites (colored 64×64 PNG per trash type) ──────────────────────
  final spriteMap = {
    'trash_plastic': _buildColorPng(64, const [0xFA, 0xCC, 0x15]),  // yellow
    'trash_glass':   _buildColorPng(64, const [0x1D, 0xB9, 0x54]),  // green
    'trash_organic': _buildColorPng(64, const [0x92, 0x40, 0x0E]),  // brown
    'trash_paper':   _buildColorPng(64, const [0x0E, 0xA5, 0xE9]),  // blue
    'recycle_bin':   _buildColorPng(64, const [0x8B, 0x5C, 0xF6]),  // purple
    'tree_oak':      _buildColorPng(64, const [0x14, 0xA0, 0x4A]),  // green
    'solar_panel':   _buildColorPng(64, const [0x0E, 0xA5, 0xE9]),  // sky blue
  };
  for (final entry in spriteMap.entries) {
    final f = File('assets/sprites/${entry.key}.png');
    if (!f.existsSync()) {
      f.writeAsBytesSync(entry.value);
      print('✅ Created  assets/sprites/${entry.key}.png  (${64}x${64} color PNG)');
    } else {
      print('⏭️  Skipped  assets/sprites/${entry.key}.png  (already exists)');
    }
  }

  // ── Lottie JSON placeholder ──────────────────────────────────────────
  const lottiePlaceholder = '{"v":"5.9.0","fr":30,"ip":0,"op":30,"w":200,"h":200,"nm":"placeholder","ddd":0,"assets":[],"layers":[]}';
  for (final name in ['splash_leaf', 'reward_open', 'confetti', 'loading']) {
    final f = File('assets/animations/$name.json');
    if (!f.existsSync()) {
      f.writeAsStringSync(lottiePlaceholder);
      print('✅ Created  assets/animations/$name.json  (empty Lottie placeholder)');
    } else {
      print('⏭️  Skipped  assets/animations/$name.json  (already exists)');
    }
  }

  // ── Character image placeholder (64x64 circle PNG) ──────────────────
  final charNames = ['child_hero', 'child_playing', 'guardian_forest', 'guardian_ocean'];
  for (final name in charNames) {
    final f = File('assets/images/characters/$name.png');
    if (!f.existsSync()) {
      f.writeAsBytesSync(_buildColorPng(64, const [0x7C, 0x3A, 0xED]));
      print('✅ Created  assets/images/characters/$name.png');
    }
  }

  // ── Note about .riv ──────────────────────────────────────────────────
  print('');
  print('ℹ️  assets/rive/eco_mascot.riv  → emoji fallback active (no .riv needed to run)');
  print('   Download a free one from https://rive.app/community (search "kids mascot")');
  print('');
  print('🎉 Done! Run:  flutter pub get && flutter run');
}

// ── WAV builder ──────────────────────────────────────────────────────────

List<int> _buildSilentWav({required int durationMs}) {
  const sampleRate = 8000;
  const numChannels = 1;
  const bitsPerSample = 16;
  final numSamples = (sampleRate * durationMs / 1000).round();
  final dataSize = numSamples * numChannels * (bitsPerSample ~/ 8);
  final chunkSize = 36 + dataSize;

  final buf = BytesBuilder();

  // RIFF header
  buf.add(_ascii('RIFF'));
  buf.add(_int32(chunkSize));
  buf.add(_ascii('WAVE'));

  // fmt sub-chunk
  buf.add(_ascii('fmt '));
  buf.add(_int32(16));           // sub-chunk size
  buf.add(_int16(1));            // PCM
  buf.add(_int16(numChannels));
  buf.add(_int32(sampleRate));
  buf.add(_int32(sampleRate * numChannels * bitsPerSample ~/ 8));  // byte rate
  buf.add(_int16(numChannels * bitsPerSample ~/ 8));               // block align
  buf.add(_int16(bitsPerSample));

  // data sub-chunk
  buf.add(_ascii('data'));
  buf.add(_int32(dataSize));
  buf.add(List.filled(dataSize, 0));  // silence

  return buf.toBytes();
}

List<int> _ascii(String s) => s.codeUnits;
List<int> _int16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _int32(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];

// ── Minimal PNG builder (solid color, no compression) ────────────────────

List<int> _buildColorPng(int size, List<int> rgb) {
  // Use a well-formed 1×1 transparent PNG then scale via code? No — embed real PNG bytes.
  // We use a known-valid minimal 8x8 RGB PNG built from scratch (pure Dart, no external lib).

  // IHDR
  final ihdr = <int>[
    ...size.to4Bytes(), ...size.to4Bytes(),
    8,    // bit depth
    2,    // color type: RGB
    0, 0, 0,
  ];

  // Raw image data: each row = filter byte (0) + RGB * width
  final rawRows = <int>[];
  for (int y = 0; y < size; y++) {
    rawRows.add(0); // filter type None
    for (int x = 0; x < size; x++) {
      rawRows.addAll(rgb);
    }
  }

  // IDAT: zlib compress the raw rows
  final compressed = zlib.encode(rawRows);

  final chunks = <int>[];

  // PNG signature
  chunks.addAll([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  // IHDR chunk
  chunks.addAll(_pngChunk('IHDR', ihdr));

  // IDAT chunk
  chunks.addAll(_pngChunk('IDAT', compressed));

  // IEND chunk
  chunks.addAll(_pngChunk('IEND', []));

  return chunks;
}

List<int> _pngChunk(String name, List<int> data) {
  final nameBytes = name.codeUnits;
  final length = data.length.to4Bytes();
  final crcData = [...nameBytes, ...data];
  final crcVal = _crc32(crcData);
  return [...length, ...nameBytes, ...data, ...crcVal.to4Bytes()];
}

int _crc32(List<int> data) {
  var crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc ^= byte;
    for (var j = 0; j < 8; j++) {
      if (crc & 1 != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc >>= 1;
      }
    }
  }
  return (~crc) & 0xFFFFFFFF;
}

extension on int {
  List<int> to4Bytes() => [
        (this >> 24) & 0xFF,
        (this >> 16) & 0xFF,
        (this >> 8) & 0xFF,
        this & 0xFF,
      ];
}

Future<void> _makeDir(String path) async {
  final d = Directory(path);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
    print('📁 Created  $path/');
  }
}
