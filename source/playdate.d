/// See_Also: <a href="https://sdk.play.date/1.12.3/Inside Playdate with C.html">Inside Playdate with C</a> - Official Playdate SDK Documentation
///
/// Authors: Chance Snow
/// Copyright:
/// Copyright © 2014-2017 Panic, Inc. All rights reserved.
/// Copyright © 2022 Chance Snow.
/// License: MIT License
module playdate;

import std.meta : Alias;

/// Attribute specifying which version a symbol was added to the Playdate C SDK.
struct AddedIn {
  ///
  this(ubyte major, ubyte minor, ubyte patch = 0) {}
}

alias LCDPattern = ubyte;
alias LCDColor = ubyte;

alias LCDBitmap = Alias!(void);
alias LCDBitmapTable = Alias!(void*);
alias LCDFont = Alias!(void*);
alias LCDFontData = Alias!(void*);
alias LCDFontPage = Alias!(void*);
alias LCDFontGlyph = Alias!(void*);
alias LCDVideoPlayer = Alias!(void*);
alias PDMenuItem = Alias!(void*);
alias SDFile = Alias!(void*);

///
enum PDButtons : int {
  ///
  buttonLeft  = (1<<0),
  ///
  buttonRight = (1<<1),
  ///
  buttonUp    = (1<<2),
  ///
  buttonDown  = (1<<3),
  ///
  buttonB     = (1<<4),
  ///
  buttonA     = (1<<5)
}

///
enum PDLanguage {
	///
  english,
	///
  japanese,
	///
  unknown,
}

///
@AddedIn(1, 13)
struct PDDateTime {
  ///
  ushort year;
  /// 1-12
  ubyte month;
  /// 1-31
  ubyte day;
  /// 1 = Monday, 7 = Sunday
  ubyte weekday;
  /// 0-23
  ubyte hour;
  ///
  ubyte minute;
  ///
  ubyte second;
}

///
enum PDPeripherals : int {
	none            = 0,
	accelerometer   = (1<<0),
	allPeripherals  = 0xffff
}

///
struct LCDRect {
  /// Left edge along x-axis.
	int left;
	/// Right edge along x-axis, not inclusive.
  int right;
  /// Top edge along y-axis.
	int top;
	/// Bottom edge along y-axis, not inclusive.
  int bottom;

  ///
	pragma(inline) LCDRect translate(int dx, int dy) const {
		return LCDRect(this.left + dx, this.right + dx, this.top + dy, this.bottom + dy);
	}
}

/// Remarks: Assumes width and height are positive.
pragma(inline) LCDRect makeRect(int x, int y, int width, int height) {
	return LCDRect(x, x + width, y, y + height);
}

unittest {
  const rect = makeRect(5, 10, 20, 40);
  assert(rect.left == 5);
  assert(rect.right == 25);
  assert(rect.top == 10);
  assert(rect.bottom == 50);

  const translatedRect = rect.translate(20, 20);
  assert(translatedRect.left == 25);
  assert(translatedRect.right == 45);
  assert(translatedRect.top == 30);
  assert(translatedRect.bottom == 70);
}

///
enum LCD_COLUMNS =	400;
///
enum LCD_ROWS =		240;
///
enum LCD_ROWSIZE =	52;
///
enum LCD_SCREEN_RECT = makeRect(0, 0, LCD_COLUMNS, LCD_ROWS);

///
enum LCDBitmapDrawMode {
	copy,
	whiteTransparent,
	blackTransparent,
	fillWhite,
	fillBlack,
	xor,
	nxor,
	inverted
}

///
enum LCDBitmapFlip {
	unflipped,
	flippedX,
	flippedY,
	flippedXy
}

///
enum LCDSolidColor {
	black,
	white,
	clear,
	xor
}

///
enum LCDLineCapStyle {
	butt,
	square,
	round
}

///
enum PDStringEncoding {
	asciiEncoding,
	utf8Encoding,
	_16BitLeEncoding
}

///
enum LCDPolygonFillRule {
	nonZero,
	evenOdd
}

///
enum PDSystemEvent {
	init,
	initLua,
	lock,
	unlock,
	pause,
	resume,
	terminate,
	keyPressed,
	keyReleased,
	lowPower
}

///
alias PDCallbackFunction = int function(void* userData) @nogc;
///
alias PDMenuItemCallbackFunction = void function(void* userdata) @nogc;

/// Fill the passed-in `left` buffer (and `right` if it’s a stereo source) with `len` samples each and return `true`, or `false` if the source is silent through the cycle.
alias AudioSourceFunction = bool function(void* context, short* left, short* right, int len) @nogc;

/// Called with the recorded audio data, a monophonic stream of samples.
///
/// Return `true` to continue recording, `false` to stop recording.
/// See_Also: `Sound.setMicCallback`
alias RecordCallback = bool function (void* context, short* buffer, int length) @nogc;

/// `bufactive` is `true` if samples have been set in the left or right buffers.
/// Return `true` if it changed the buffer samples, otherwise `false`.
/// `left` and `right` (if the effect is on a stereo channel) are sample buffers in signed Q8.24 format.
alias effectProc = bool function(SoundEffect e, int* left, int* right, int nsamples, bool bufactive) @nogc;

extern (C):

///
struct System {
	/// ptr = NULL -> malloc, size = 0 -> free
	void* function(void* ptr, size_t size) @nogc realloc;
  ///
	int function(char **ret, const char *fmt, ...) @nogc formatString;
  ///
	void function(const char* fmt, ...) @nogc logToConsole;
  ///
	void function(const char* fmt, ...) @nogc error;
	///
  PDLanguage function() @nogc getLanguage;
	///
  uint function() @nogc getCurrentTimeMilliseconds;
	///
  uint function(uint *milliseconds) @nogc getSecondsSinceEpoch;
	///
  void function(int x, int y) @nogc drawFPS;

	///
  void function(PDCallbackFunction update, void* userdata) @nogc setUpdateCallback;
	///
  void function(PDButtons* current, PDButtons* pushed, PDButtons* released) @nogc getButtonState;
	///
  void function(PDPeripherals mask) @nogc setPeripheralsEnabled;
	/// Returns the last-read accelerometer data.
  void function(float* outx, float* outy, float* outz) @nogc getAccelerometer;

	/// Returns the angle change of the crank since the last time this function was called. Negative values are anti-clockwise.
  float function() @nogc getCrankChange;
	/// Returns the current position of the crank, in the range 0-360.
  /// Zero is pointing up, and the value increases as the crank moves clockwise, as viewed from the right side of the device.
  float function() @nogc getCrankAngle;
	/// Returns `true` or `false` indicating whether or not the crank is folded into the unit.
  bool function() @nogc isCrankDocked;
	/// Returns the previous value for this setting.
  /// Remarks:
  /// 0.12 adds sound effects for various system events, such as the menu opening or closing, USB cable plugged or
  /// unplugged, and the crank docked or undocked. Since games can receive notification of the crank docking and
  /// undocking, and may incorporate this into the game, we’ve provided a function for muting the default sounds for
  /// these events.
	int function(int flag) @nogc setCrankSoundsDisabled;

	///
  int function() @nogc getFlipped;
	/// Disables or enables the 60 second auto lock feature. When called, the timer is reset to 60 seconds.
  /// Remarks:
  /// As of 0.10.3, the device will automatically lock if the user doesn’t press any buttons or use the crank for more
  /// than 60 seconds. In order for games that expect longer periods without interaction to continue to function, it is
  /// possible to manually disable the auto lock feature. Note that when disabling the timeout, developers should take
  /// care to re-enable the timeout when appropiate.
  void function(bool disable) @nogc setAutoLockDisabled;

	///
  void function(LCDBitmap* bitmap, int xOffset) @nogc setMenuImage;
	///
  PDMenuItem* function(const char *title, PDMenuItemCallbackFunction callback, void* userdata) @nogc addMenuItem;
	///
  PDMenuItem* function(
		const char *title, int value, PDMenuItemCallbackFunction callback, void* userdata
	) @nogc addCheckmarkMenuItem;
	///
  PDMenuItem* function(
		const char *title, const char** optionTitles, int optionsCount, PDMenuItemCallbackFunction f, void* userdata
	) @nogc addOptionsMenuItem;
	///
  void function() @nogc removeAllMenuItems;
	///
  void function(PDMenuItem *menuItem) @nogc removeMenuItem;
	///
  int function(PDMenuItem *menuItem) @nogc getMenuItemValue;
	///
  void function(PDMenuItem *menuItem, int value) @nogc setMenuItemValue;
	///
  const(char*) function(PDMenuItem *menuItem) @nogc getMenuItemTitle;
	///
  void function(PDMenuItem *menuItem, const char *title) @nogc setMenuItemTitle;
	///
  void* function(PDMenuItem *menuItem) @nogc getMenuItemUserdata;
	///
  void function(PDMenuItem *menuItem, void *ud) @nogc setMenuItemUserdata;

	///
  int function() @nogc getReduceFlashing;

	///
  @AddedIn(1, 1)
  float function() @nogc getElapsedTime;
	///
  @AddedIn(1, 1)
  void function() @nogc resetElapsedTime;

	///
  @AddedIn(1, 4)
  float function() @nogc getBatteryPercentage;
	///
  @AddedIn(1, 4)
  float function() @nogc getBatteryVoltage;

  ///
  @AddedIn(1, 13)
  int function() @nogc getTimezoneOffset;
  ///
  @AddedIn(1, 13)
  bool function() @nogc shouldDisplay24HourTime;
  ///
  @AddedIn(1, 13)
  void function(int epoch, PDDateTime* datetime) @nogc convertEpochToDateTime;
  ///
  @AddedIn(1, 13)
  int function(PDDateTime* datetime) @nogc convertDateTimeToEpoch;
}

///
void logToConsole(System* system, string message) @nogc {
  system.logToConsole(message.ptr);
}

version (unittest) {
  static message = "test";
  extern (C) void log(const(char*) msg, ...) @nogc {
    assert(msg == message.ptr);
  }
}

unittest {
  auto system = System();
  system.logToConsole = &log;
  logToConsole(&system, message);
}

///
enum FileOptions {
	///
  read      = (1<<0),
	///
  readData  = (1<<1),
	///
  write     = (1<<2),
	///
  append    = (2<<2)
}

///
struct FileStat {
	/// Whether the file is a directory.
  int isDir;
	/// Size of the file, in bytes.
  uint size;
	/// Year component of the file's last modified date.
  int m_year;
	/// Month component of the file's last modified date.
  int m_month;
	/// Day component of the file's last modified date.
  int m_day;
	/// Hour component of the file's last modified date.
  int m_hour;
	/// Minute component of the file's last modified date.
  int m_minute;
	/// Second component of the file's last modified date.
  int m_second;
}

///
struct File {
  ///
  const(char*) function() @nogc geterr;

	///
  int function(
    const char* path, void function(const char* path, void* userdata) callback, void* userdata,
    bool showHidden
  ) @nogc listfiles;
	///
  int function(const char* path, FileStat* stat) @nogc stat;
	///
  int function(const char* path) @nogc mkdir;
	///
  int function(const char* name, int recursive) @nogc unlink;
  ///
	int function(const char* from, const char* to) @nogc rename;

	///
  SDFile function(const char* name, FileOptions mode) @nogc open;
	///
  int function(SDFile file) @nogc close;
	///
  int function(SDFile file, void* buf, uint len) @nogc read;
	///
  int function(SDFile file, const void* buf, uint len) @nogc write;
	///
  int function(SDFile file) @nogc flush;
	///
  int function(SDFile file) @nogc tell;
	///
  int function(SDFile file, int pos, int whence) @nogc seek;
}

///
struct Video {
	///
  LCDVideoPlayer*function (const char* path) loadVideo;
	///
  void function(LCDVideoPlayer* p) freePlayer;
	///
  int function(LCDVideoPlayer* p, LCDBitmap* context) setContext;
	///
  void function(LCDVideoPlayer* p) useScreenContext;
	///
  int function(LCDVideoPlayer* p, int n) renderFrame;
	///
  const(char*) function(LCDVideoPlayer* p) getError;
  ///
	void function(
		LCDVideoPlayer* p, int* outWidth, int* outHeight, float* outFrameRate, int* outFrameCount, int* outCurrentFrame
	) getInfo;
  ///
	LCDBitmap*function (LCDVideoPlayer *p) getContext;
}

///
struct Graphics {
  ///
	Video* video;

	// Drawing Functions
	///
  void function(LCDColor color) @nogc clear;
	///
  void function(LCDSolidColor color) @nogc setBackgroundColor;
  /// Deprecated: In favor of `setStencilImage`, which adds a "tile" flag
  void function(LCDBitmap* stencil) @nogc setStencil;
	///
  void function(LCDBitmapDrawMode mode) @nogc setDrawMode;
	///
  void function(int dx, int dy) @nogc setDrawOffset;
	///
  void function(int x, int y, int width, int height) @nogc setClipRect;
	///
  void function() @nogc clearClipRect;
	///
  void function(LCDLineCapStyle endCapStyle) @nogc setLineCapStyle;
	///
  void function(LCDFont* font) @nogc setFont;
	///
  void function(int tracking) @nogc setTextTracking;
	///
  void function(LCDBitmap* target) @nogc pushContext;
	///
  void function() @nogc popContext;

	///
  void function(LCDBitmap* bitmap, int x, int y, LCDBitmapFlip flip) @nogc drawBitmap;
	///
  void function(LCDBitmap* bitmap, int x, int y, int width, int height, LCDBitmapFlip flip) @nogc tileBitmap;
	///
  void function(int x1, int y1, int x2, int y2, int width, LCDColor color) @nogc drawLine;
	///
  void function(int x1, int y1, int x2, int y2, int x3, int y3, LCDColor color) @nogc fillTriangle;
	///
  void function(int x, int y, int width, int height, LCDColor color) @nogc drawRect;
	///
  void function(int x, int y, int width, int height, LCDColor color) @nogc fillRect;
	/// stroked inside the rect
	void function(
		int x, int y, int width, int height, int lineWidth, float startAngle, float endAngle, LCDColor color
	) @nogc drawEllipse;
	///
  void function(
    int x, int y, int width, int height, float startAngle, float endAngle, LCDColor color
  ) @nogc fillEllipse;
	///
  void function(LCDBitmap* bitmap, int x, int y, float xscale, float yscale) @nogc drawScaledBitmap;
	///
  int  function(const void* text, size_t len, PDStringEncoding encoding, int x, int y) @nogc drawText;

	// LCDBitmap
	///
  LCDBitmap* function(int width, int height, LCDColor bgcolor) @nogc newBitmap;
	///
  void function(LCDBitmap*) @nogc freeBitmap;
	///
  LCDBitmap* function(const char* path, const char** outerr) @nogc loadBitmap;
	///
  LCDBitmap* function(LCDBitmap* bitmap) @nogc copyBitmap;
	///
  void function(const char* path, LCDBitmap* bitmap, const char** outerr) @nogc loadIntoBitmap;
	///
  void function(
    LCDBitmap* bitmap, int* width, int* height, int* rowbytes, ubyte** mask, ubyte** data
  ) @nogc getBitmapData;
	///
  void function(LCDBitmap* bitmap, LCDColor bgcolor) @nogc clearBitmap;
	///
  LCDBitmap* function(
    LCDBitmap* bitmap, float rotation, float xscale, float yscale, int* allocedSize
  ) @nogc rotatedBitmap;

	// LCDBitmapTable
	///
  LCDBitmapTable* function(int count, int width, int height) @nogc newBitmapTable;
	///
  void function(LCDBitmapTable* table) @nogc freeBitmapTable;
	///
  LCDBitmapTable* function(const char* path, const char** outerr) @nogc loadBitmapTable;
	///
  void function(const char* path, LCDBitmapTable* table, const char** outerr) @nogc loadIntoBitmapTable;
	///
  LCDBitmap* function(LCDBitmapTable* table, int idx) @nogc getTableBitmap;

	// LCDFont
	///
  LCDFont* function(const char* path, const char** outErr) @nogc loadFont;
	///
  LCDFontPage* function(LCDFont* font, uint c) @nogc getFontPage;
	///
  LCDFontGlyph* function(LCDFontPage* page, uint c, LCDBitmap** bitmap, int* advance) @nogc getPageGlyph;
	///
  int function(LCDFontGlyph* glyph, uint glyphcode, uint nextcode) @nogc getGlyphKerning;
	///
  int function(LCDFont* font, const void* text, size_t len, PDStringEncoding encoding, int tracking) @nogc getTextWidth;

	// raw framebuffer access
	///
  ubyte* function() getFrame; // row stride = @nogc LCD_ROWSIZE
	///
  ubyte* function() getDisplayFrame; // row stride = @nogc LCD_ROWSIZE
	///
  LCDBitmap* function() getDebugBitmap; // valid in simulator only, function is NULL on @nogc device
	///
  LCDBitmap* function() @nogc copyFrameBufferBitmap;
	///
  void function(int start, int end) @nogc markUpdatedRows;
	///
  void function() @nogc display;

	/// misc util.
  void function(LCDColor* color, LCDBitmap* bitmap, int x, int y) @nogc setColorToPattern;
  ///
	int function(
		LCDBitmap* bitmap1, int x1, int y1, LCDBitmapFlip flip1,
		LCDBitmap* bitmap2, int x2, int y2, LCDBitmapFlip flip2,
		LCDRect rect
	) @nogc checkMaskCollision;

	///
  @AddedIn(1, 1)
	void function(int x, int y, int width, int height) @nogc setScreenClipRect;

	///
  @AddedIn(1, 1, 1)
	void function(int nPoints, int* coords, LCDColor color, LCDPolygonFillRule fillrule) @nogc fillPolygon;
	///
  @AddedIn(1, 1, 1)
  ubyte function(LCDFont* font) @nogc getFontHeight;

	///
  @AddedIn(1, 7)
	LCDBitmap* function() @nogc getDisplayBufferBitmap;
  ///
  @AddedIn(1, 7)
	void function(
		LCDBitmap* bitmap, int x, int y, float rotation, float centerx, float centery, float xscale, float yscale
	) @nogc drawRotatedBitmap;
  ///
  @AddedIn(1, 7)
	void function(int lineHeightAdustment) @nogc setTextLeading;

	///
  @AddedIn(1, 8)
	int function(LCDBitmap* bitmap, LCDBitmap* mask) @nogc setBitmapMask;
  ///
	LCDBitmap* function(LCDBitmap* bitmap) @nogc getBitmapMask;

	///
  @AddedIn(1, 10)
	void function(LCDBitmap* stencil, int tile) @nogc setStencilImage;

	///
  @AddedIn(1, 12)
	LCDFont* function(LCDFontData* data, int wide) @nogc makeFontFromData;
}

///
int drawText(
  Graphics* gfx, string text, int x, int y, PDStringEncoding encoding = PDStringEncoding.asciiEncoding
) @nogc {
  return gfx.drawText(text.ptr, text.length, encoding, x, y);
}

version (unittest) {
  static txt = "test";
  extern (C) int drawTextTest(const void* text, size_t len, PDStringEncoding encoding, int x, int y) @nogc {
    assert(text == txt.ptr);
    assert(len == txt.length);
    assert(encoding == PDStringEncoding.asciiEncoding);
    assert(x >= 0);
    assert(y >= 0);
    return 0;
  }
}

unittest {
  auto gfx = Graphics();
  gfx.drawText = &drawTextTest;
  assert(drawText(&gfx, message, 5, 5) == 0);
}

///
struct Sprite {
  // TODO: Implement Playdate Sprite API
}

///
struct Display {
	///
  int function() @nogc getWidth;
	///
  int function() @nogc getHeight;

	///
  void function(float rate) @nogc setRefreshRate;

	///
  void function(int flag) @nogc setInverted;
	///
  void function(uint s) @nogc setScale;
	///
  void function(uint x, uint y) @nogc setMosaic;
	///
  void function(int x, int y) @nogc setFlipped;
	///
  void function(int x, int y) @nogc setOffset;
}

/// A SoundChannel contains `SoundSource`s and `SoundEffect`s.
alias SoundChannel = Alias!(void*);

///
struct SoundChannelApi {
  ///
  SoundChannel function() @nogc newChannel;
	///
  void function(SoundChannel channel) @nogc freeChannel;
	///
  int function(SoundChannel channel, SoundSource* source) @nogc addSource;
	///
  int function(SoundChannel channel, SoundSource* source) @nogc removeSource;
  /// Creates a new `SoundSource` using the given data provider `callback` and adds it to the default channel.
  /// Remarks: The caller takes ownership of the allocated `SoundSource`, and should free it with `playdate.system.realloc(source, NULL);` when it is no longer in use.
  SoundSource* function(
    SoundChannel channel, AudioSourceFunction* callback, void* context, int stereo
  ) @nogc addCallbackSource;
	///
  void function(SoundChannel channel, SoundEffect* effect) @nogc addEffect;
	///
  void function(SoundChannel channel, SoundEffect* effect) @nogc removeEffect;
	///
  void function(SoundChannel channel, float volume) @nogc setVolume;
	///
  float function(SoundChannel channel) @nogc getVolume;
	///
  void function(SoundChannel channel, PDSynthSignalValue mod) @nogc setVolumeModulator;
	///
  PDSynthSignalValue function(SoundChannel channel) @nogc getVolumeModulator;
	///
  void function(SoundChannel channel, float pan) @nogc setPan;
	///
  void function(SoundChannel channel, PDSynthSignalValue mod) @nogc setPanModulator;
	///
  PDSynthSignalValue function(SoundChannel channel) @nogc getPanModulator;
	///
  PDSynthSignalValue function(SoundChannel channel) @nogc getDryLevelSignal;
	///
  PDSynthSignalValue function(SoundChannel channel) @nogc getWetLevelSignal;
}

///
struct SoundFileplayer {
  // TODO: Implement Playdate Sound Fileplayer API
}

///
struct SoundSample {
  // TODO: Implement Playdate Sound Sample API
}

///
struct SoundSampleplayer {
  // TODO: Implement Playdate Sound Sampleplayer API
}

///
struct SoundSynth {
  // TODO: Implement Playdate Sound Synth API
}

///
struct SoundSequence {
  // TODO: Implement Playdate Sound Sequence API
}

///
alias SoundEffect = Alias!(void*);

///
struct SoundEffectApi {
  // TODO: Implement Playdate Sound Effect API
}

///
struct SoundLfo {
  // TODO: Implement Playdate Sound Lfo API
}

///
struct SoundEnvelope {
  // TODO: Implement Playdate Sound Envelope API
}

///
struct SoundSource {
  // TODO: Implement Playdate Sound Source API
}

///
struct ControlSignal {
  // TODO: Implement Playdate Contr olSignal API
}

///
struct SoundTrack {
  // TODO: Implement Playdate Sound Track API
}

///
struct SoundInstrument {
  // TODO: Implement Playdate Sound Instrument API
}

/// A PDSynthSignalValue represents a signal that can be used as an input to a modulator.
/// Its `PDSynthSignal` subclass is used for "active" signals that change their values automatically.
/// `PDSynthLFO` and `PDSynthEnvelope` are subclasses of `PDSynthSignal`.
alias PDSynthSignalValue = Alias!(void*);
alias PDSynthSignal = Alias!(void*);

///
struct SoundSignal {
  // TODO: Implement Playdate Sound Signal API
}

///
struct Sound {
	///
  SoundChannelApi* channel;
	///
  SoundFileplayer* fileplayer;
	///
  SoundSample* sample;
	///
  SoundSampleplayer* sampleplayer;
	///
  SoundSynth* synth;
	///
  SoundSequence* sequence;
	///
  SoundEffectApi* effect;
	///
  SoundLfo* lfo;
	///
  SoundEnvelope* envelope;
	///
  SoundSource* source;
	///
  ControlSignal* controlsignal;
	///
  SoundTrack* track;
	///
  SoundInstrument* instrument;

	///
  uint function() @nogc getCurrentTime;
	/// The `callback` function you pass in will be called every audio render cycle.
  SoundSource* function(AudioSourceFunction callback, void* context, bool stereo) @nogc addSource;

	///
  SoundChannel function() @nogc getDefaultChannel;

	///
  void function(SoundChannel channel) @nogc addChannel;
	///
  void function(SoundChannel channel) @nogc removeChannel;

	/// The `callback` you pass in will be called every audio cycle.
  ///
  /// If `forceInternal` is set, the device microphone is used regardless of whether the headset has a microphone.
  void function(RecordCallback callback, void* context, bool forceInternal) @nogc setMicCallback;
	/// If `headphone` contains a non-null pointer, the value is set to `true` if headphones are currently plugged in.
  /// Likewise, mic is set if the headphones include a microphone.
  /// If `changeCallback` is provided, it will be called when the headset or mic status changes, and audio output
  /// will not automatically switch from speaker to headphones when headphones are plugged in (and vice versa).
  /// In this case, the callback should use `playdate.sound.setOutputsActive()` to change the output if needed.
  void function(
    bool* headphone, bool* headsetmic, void function(bool headphone, bool mic) @nogc changeCallback
  ) @nogc getHeadphoneState;
	/// Force audio output to the given outputs, regardless of headphone status.
  void function(bool headphone, bool speaker) setOutputsActive;

	///
  @AddedIn(1, 5)
  void function(SoundSource* source) removeSource;

	///
  @AddedIn(1, 12)
	SoundSignal* signal;
}

///
struct Lua {
	// TODO: Implement Playdate Lua API
}

///
struct Json {
	// TODO: Implement Playdate Json API
}

///
struct Scoreboards {
	// TODO: Implement Playdate Scoreboards API
}

///
struct PlaydateAPI {
  ///
  System* system;
	///
  File* file;
	///
  Graphics* graphics;
	///
  Sprite* sprite;
	///
  Display* display;
	///
  Sound* sound;
	///
  Lua* lua;
	///
  Json* json;
	///
  Scoreboards* scoreboards;
}

/// Generates a shim around your `eventHandler` used by the Playdate OS as the entry-point to your application.
mixin template EventHandlerShim() {
  extern (C) int eventHandlerShim(PlaydateAPI* playdate, PDSystemEvent event, uint arg) @nogc {
    return eventHandler(playdate, event, arg);
  }
}
