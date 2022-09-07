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
	pragma(inline) LCDRect translate(int dx, int dy) {
		return LCDRect(this.left + dx, this.right + dx, this.top + dy, this.bottom + dy);
	}
}

/// Remarks: Assumes width and height are positive.
pragma(inline) LCDRect makeRect(int x, int y, int width, int height) {
	return LCDRect(x, x + width, y, y + height);
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
alias PDCallbackFunction = int function(void* userData);
///
alias PDMenuItemCallbackFunction = void function(void* userdata);

extern (C):

///
struct System {
	/// ptr = NULL -> malloc, size = 0 -> free
	void* function(void* ptr, size_t size) realloc;
  ///
	int function(char **ret, const char *fmt, ...) formatString;
  ///
	void function(const char* fmt, ...) logToConsole;
  ///
	void function(const char* fmt, ...) error;
  ///
	///
  PDLanguage function() getLanguage;
	///
  uint function() getCurrentTimeMilliseconds;
	///
  uint function(uint *milliseconds) getSecondsSinceEpoch;
	///
  void function(int x, int y) drawFPS;

	///
  void function(PDCallbackFunction update, void* userdata) setUpdateCallback;
	///
  void function(PDButtons* current, PDButtons* pushed, PDButtons* released) getButtonState;
	///
  void function(PDPeripherals mask) setPeripheralsEnabled;
	///
  void function(float* outx, float* outy, float* outz) getAccelerometer;

	///
  float function() getCrankChange;
	///
  float function() getCrankAngle;
	///
  int function() isCrankDocked;
	/// returns previous setting
	int function(int flag) setCrankSoundsDisabled;

	///
  int function() getFlipped;
	///
  void function(int disable) setAutoLockDisabled;

	///
  void function(LCDBitmap* bitmap, int xOffset) setMenuImage;
	///
  PDMenuItem* function(const char *title, PDMenuItemCallbackFunction callback, void* userdata) addMenuItem;
	///
  PDMenuItem* function(
		const char *title, int value, PDMenuItemCallbackFunction callback, void* userdata
	) addCheckmarkMenuItem;
	///
  PDMenuItem* function(
		const char *title, const char** optionTitles, int optionsCount, PDMenuItemCallbackFunction f, void* userdata
	) addOptionsMenuItem;
	///
  void function() removeAllMenuItems;
	///
  void function(PDMenuItem *menuItem) removeMenuItem;
	///
  int function(PDMenuItem *menuItem) getMenuItemValue;
	///
  void function(PDMenuItem *menuItem, int value) setMenuItemValue;
	///
  const(char*) function(PDMenuItem *menuItem) getMenuItemTitle;
	///
  void function(PDMenuItem *menuItem, const char *title) setMenuItemTitle;
	///
  void* function(PDMenuItem *menuItem) getMenuItemUserdata;
	///
  void function(PDMenuItem *menuItem, void *ud) setMenuItemUserdata;

	///
  int function() getReduceFlashing;

	// 1.1
	///
  float function() getElapsedTime;
	///
  void function() resetElapsedTime;

	// 1.4
	///
  float function() getBatteryPercentage;
	///
  float function() getBatteryVoltage;
}

///
void logToConsole(System* system, string message) {
  system.logToConsole(message.ptr);
}

///
struct File {
  // TODO: Implement Playdate File API
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
  void function(LCDColor color) clear;
	///
  void function(LCDSolidColor color) setBackgroundColor;
	///
  void function(LCDBitmap* stencil) setStencil; // deprecated in favor of setStencilImage, which adds a "tile" flag
	///
  void function(LCDBitmapDrawMode mode) setDrawMode;
	///
  void function(int dx, int dy) setDrawOffset;
	///
  void function(int x, int y, int width, int height) setClipRect;
	///
  void function() clearClipRect;
	///
  void function(LCDLineCapStyle endCapStyle) setLineCapStyle;
	///
  void function(LCDFont* font) setFont;
	///
  void function(int tracking) setTextTracking;
	///
  void function(LCDBitmap* target) pushContext;
	///
  void function() popContext;

	///
  void function(LCDBitmap* bitmap, int x, int y, LCDBitmapFlip flip) drawBitmap;
	///
  void function(LCDBitmap* bitmap, int x, int y, int width, int height, LCDBitmapFlip flip) tileBitmap;
	///
  void function(int x1, int y1, int x2, int y2, int width, LCDColor color) drawLine;
	///
  void function(int x1, int y1, int x2, int y2, int x3, int y3, LCDColor color) fillTriangle;
	///
  void function(int x, int y, int width, int height, LCDColor color) drawRect;
	///
  void function(int x, int y, int width, int height, LCDColor color) fillRect;
	/// stroked inside the rect
	void function(
		int x, int y, int width, int height, int lineWidth, float startAngle, float endAngle, LCDColor color
	) drawEllipse;
	///
  void function(int x, int y, int width, int height, float startAngle, float endAngle, LCDColor color) fillEllipse;
	///
  void function(LCDBitmap* bitmap, int x, int y, float xscale, float yscale) drawScaledBitmap;
	///
  int  function(const void* text, size_t len, PDStringEncoding encoding, int x, int y) drawText;

	// LCDBitmap
	///
  LCDBitmap* function(int width, int height, LCDColor bgcolor) newBitmap;
	///
  void function(LCDBitmap*) freeBitmap;
	///
  LCDBitmap* function(const char* path, const char** outerr) loadBitmap;
	///
  LCDBitmap* function(LCDBitmap* bitmap) copyBitmap;
	///
  void function(const char* path, LCDBitmap* bitmap, const char** outerr) loadIntoBitmap;
	///
  void function(LCDBitmap* bitmap, int* width, int* height, int* rowbytes, ubyte** mask, ubyte** data) getBitmapData;
	///
  void function(LCDBitmap* bitmap, LCDColor bgcolor) clearBitmap;
	///
  LCDBitmap* function(LCDBitmap* bitmap, float rotation, float xscale, float yscale, int* allocedSize) rotatedBitmap;

	// LCDBitmapTable
	///
  LCDBitmapTable* function(int count, int width, int height) newBitmapTable;
	///
  void function(LCDBitmapTable* table) freeBitmapTable;
	///
  LCDBitmapTable* function(const char* path, const char** outerr) loadBitmapTable;
	///
  void function(const char* path, LCDBitmapTable* table, const char** outerr) loadIntoBitmapTable;
	///
  LCDBitmap* function(LCDBitmapTable* table, int idx) getTableBitmap;

	// LCDFont
	///
  LCDFont* function(const char* path, const char** outErr) loadFont;
	///
  LCDFontPage* function(LCDFont* font, uint c) getFontPage;
	///
  LCDFontGlyph* function(LCDFontPage* page, uint c, LCDBitmap** bitmap, int* advance) getPageGlyph;
	///
  int function(LCDFontGlyph* glyph, uint glyphcode, uint nextcode) getGlyphKerning;
	///
  int function(LCDFont* font, const void* text, size_t len, PDStringEncoding encoding, int tracking) getTextWidth;

	// raw framebuffer access
	///
  ubyte* function() getFrame; // row stride = LCD_ROWSIZE
	///
  ubyte* function() getDisplayFrame; // row stride = LCD_ROWSIZE
	///
  LCDBitmap* function() getDebugBitmap; // valid in simulator only, function is NULL on device
	///
  LCDBitmap* function() copyFrameBufferBitmap;
	///
  void function(int start, int end) markUpdatedRows;
	///
  void function() display;

	/// misc util.
  void function(LCDColor* color, LCDBitmap* bitmap, int x, int y) setColorToPattern;
  ///
	int function(
		LCDBitmap* bitmap1, int x1, int y1, LCDBitmapFlip flip1,
		LCDBitmap* bitmap2, int x2, int y2, LCDBitmapFlip flip2,
		LCDRect rect
	) checkMaskCollision;

	// 1.1
  ///
	void function(int x, int y, int width, int height) setScreenClipRect;

	// 1.1.1
  ///
	void function(int nPoints, int* coords, LCDColor color, LCDPolygonFillRule fillrule) fillPolygon;
	///
  ubyte function(LCDFont* font) getFontHeight;

	// 1.7
  ///
	LCDBitmap* function() getDisplayBufferBitmap;
  ///
	void function(
		LCDBitmap* bitmap, int x, int y, float rotation, float centerx, float centery, float xscale, float yscale
	) drawRotatedBitmap;
  ///
	void function(int lineHeightAdustment) setTextLeading;

	// 1.8
  ///
	int function(LCDBitmap* bitmap, LCDBitmap* mask) setBitmapMask;
  ///
	LCDBitmap* function(LCDBitmap* bitmap) getBitmapMask;

	// 1.10
  ///
	void function(LCDBitmap* stencil, int tile) setStencilImage;

	// 1.12
  ///
	LCDFont* function(LCDFontData* data, int wide) makeFontFromData;
}

///
int drawText(Graphics* gfx, string text, int x, int y, PDStringEncoding encoding = PDStringEncoding.asciiEncoding) {
  return gfx.drawText(text.ptr, text.length, encoding, x, y);
}

///
struct Sprite {
  // TODO: Implement Playdate Sprite API
}

///
struct Display {
	///
  int function() getWidth;
	///
  int function() getHeight;

	///
  void function(float rate) setRefreshRate;

	///
  void function(int flag) setInverted;
	///
  void function(uint s) setScale;
	///
  void function(uint x, uint y) setMosaic;
	///
  void function(int x, int y) setFlipped;
	///
  void function(int x, int y) setOffset;
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
  extern (C) int eventHandlerShim(PlaydateAPI* playdate, PDSystemEvent event, uint arg) {
    return eventHandler(playdate, event, arg);
  }
}
