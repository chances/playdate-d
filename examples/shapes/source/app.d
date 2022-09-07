module shapes;

import playdate;

static PlaydateAPI* pd;

// Compilation
// Simulator:
// ldc2 -shared playdate.d -of=dist/pdex.dylib
// $PLAYDATE_SDK_PATH/bin/pdc dist app.pdx
// Device:
// ldc2 -disable-simplify-libcalls -c -Os -nodefaultlib -mtriple=thumb-none-eabi -float-abi=hard -mcpu=cortex-m7 playdate.d -of=app.pdex

mixin EventHandlerShim;

int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint arg) {
	final switch (event) {
		case PDSystemEvent.init:
			pd = playdate;
			pd.display.setRefreshRate(30);
			pd.system.setUpdateCallback(&update, null);
			pd.system.logToConsole("Foo");
			break;
		case PDSystemEvent.initLua:
			break;
		case PDSystemEvent.lock:
			break;
		case PDSystemEvent.unlock:
			break;
		case PDSystemEvent.pause:
			auto img = pd.graphics.newBitmap(400, 240, LCDSolidColor.white);
			pd.graphics.pushContext(img);
			drawText(pd.graphics, "The game is paused", 10, 10);
			pd.graphics.popContext();
			pd.system.setMenuImage(img, 0);
			pd.graphics.freeBitmap(img);
			break;
		case PDSystemEvent.resume:
			break;
		case PDSystemEvent.terminate:
			break;
		case PDSystemEvent.keyPressed:
			break;
		case PDSystemEvent.keyReleased:
			break;
		case PDSystemEvent.lowPower:
			break;
	}
    return 0;
}

static int update(void* userData) {
  pd.graphics.clear(LCDSolidColor.white);
	pd.graphics.drawRect(5, 5, LCD_COLUMNS - 10, LCD_ROWS - 10, LCDSolidColor.black);
  pd.graphics.drawLine(LCD_COLUMNS / 2, 5, 5, LCD_ROWS - 5, 1, LCDSolidColor.black);
  pd.graphics.drawLine(LCD_COLUMNS / 2, 5, LCD_COLUMNS - 5, LCD_ROWS - 5, 1, LCDSolidColor.black);
  pd.graphics.fillTriangle(
    LCD_COLUMNS / 2, LCD_ROWS - 5 - 1,
    LCD_COLUMNS / 4, LCD_ROWS / 4,
    LCD_COLUMNS / 4 * 3, LCD_ROWS / 4,
    LCDSolidColor.xor
  );
	pd.system.drawFPS(10, 10);

	return 1;
}
