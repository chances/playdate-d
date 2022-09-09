/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module playdate;

import std.meta : Alias;

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
	buttonLeft	= (1<<0),
	buttonRight	= (1<<1),
	buttonUp	= (1<<2),
	buttonDown	= (1<<3),
	buttonB		= (1<<4),
	buttonA		= (1<<5)
}

///
enum PDLanguage {
	kPDLanguageEnglish,
	kPDLanguageJapanese,
	kPDLanguageUnknown,
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
	///
  void function(float* outx, float* outy, float* outz) @nogc getAccelerometer;

	///
  float function() @nogc getCrankChange;
	///
  float function() @nogc getCrankAngle;
	///
  int function() @nogc isCrankDocked;
	/// returns previous setting
	int function(int flag) @nogc setCrankSoundsDisabled;

	///
  int function() @nogc getFlipped;
	///
  void function(int disable) @nogc setAutoLockDisabled;

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

	// 1.1
	///
  float function() @nogc getElapsedTime;
	///
  void function() @nogc resetElapsedTime;

	// 1.4
	///
  float function() @nogc getBatteryPercentage;
	///
  float function() @nogc getBatteryVoltage;
}

///
void logToConsole(System* system, string message) @nogc {
  system.logToConsole(message.ptr);
}

version (unittest) {
  static message = "test";
  extern (C) void log(const(char*) msg, ...) {
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
  const(char*) function(void) @nogc getErr;

	///
  int function(
    const char* path, void function(const char* path, void* userdata) callback, void* userdata,
    bool showHidden
  ) @nogc listFiles;
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
	///
  void function(LCDBitmap* stencil) setStencil; // deprecated in favor of setStencilImage, which adds a "tile" @nogc flag
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
  void function(int x, int y, int width, int height, float startAngle, float endAngle, LCDColor color) @nogc fillEllipse;
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
  void function(LCDBitmap* bitmap, int* width, int* height, int* rowbytes, ubyte** mask, ubyte** data) @nogc getBitmapData;
	///
  void function(LCDBitmap* bitmap, LCDColor bgcolor) @nogc clearBitmap;
	///
  LCDBitmap* function(LCDBitmap* bitmap, float rotation, float xscale, float yscale, int* allocedSize) @nogc rotatedBitmap;

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

	// 1.1
  ///
	void function(int x, int y, int width, int height) @nogc setScreenClipRect;

	// 1.1.1
  ///
	void function(int nPoints, int* coords, LCDColor color, LCDPolygonFillRule fillrule) @nogc fillPolygon;
	///
  ubyte function(LCDFont* font) @nogc getFontHeight;

	// 1.7
  ///
	LCDBitmap* function() @nogc getDisplayBufferBitmap;
  ///
	void function(
		LCDBitmap* bitmap, int x, int y, float rotation, float centerx, float centery, float xscale, float yscale
	) @nogc drawRotatedBitmap;
  ///
	void function(int lineHeightAdustment) @nogc setTextLeading;

	// 1.8
  ///
	int function(LCDBitmap* bitmap, LCDBitmap* mask) @nogc setBitmapMask;
  ///
	LCDBitmap* function(LCDBitmap* bitmap) @nogc getBitmapMask;

	// 1.10
  ///
	void function(LCDBitmap* stencil, int tile) @nogc setStencilImage;

	// 1.12
  ///
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
  extern (C) int drawTextTest(const void* text, size_t len, PDStringEncoding encoding, int x, int y) {
    assert(text == txt.ptr);
    assert(len == txt.length);
    assert(encoding == PDStringEncoding.asciiEncoding);
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

///
struct Sound {
	// TODO: Implement Playdate Sound API
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
