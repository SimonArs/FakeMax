import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.geom.Matrix;
import lime.app.Application;

#if desktop
import openfl.events.KeyboardEvent;
#end

//просто для удобства
typedef Song = {
	var name:String;
	var bpm:Float;
	var lulz:String;
	var offset:Float;
}

//fuckamakaka
class Main extends Sprite
{
	static final songs:Array<Song> = [
		{name: 'brainpowder', bpm: 86, lulz: 'LET THE BASS KICK', offset: 93500},
		{name: 'dabointrak', bpm: 138, lulz: 'Boink boink', offset: 111000},
		{name: 'numa', bpm: 90, lulz: 'Maia hi maia hu', offset: 0},
		{name: 'badpig', bpm: 78, lulz: 'Ne...', offset: 0}
	];

	var text:TextField;
	var textFormat:TextFormat;
	var holder:Sprite;
	var leftGrad:Sprite;
	var rightGrad:Sprite;
	var timer:Float = 0;
	var pinpon:Float = 0;
	var bpm:Float;
	var beatInterval:Float;
	var beatTime:Float = 0;
	var lastTime:Float = 0;
	var screenWidth:Int = 0;
	var screenHeight:Int = 0;
	var bgColor:Int;
	var curBeat:Int = 0;

	public function new():Void {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(_):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		stage.frameRate = bound(stage.application.window.displayMode.refreshRate, 60, 360);

		#if desktop
		stage.displayState = FULL_SCREEN;
		stage.addEventListener(KeyboardEvent.KEY_UP, (e:KeyboardEvent) -> if (e.keyCode == openfl.ui.Keyboard.F11) stage.displayState = stage.displayState == FULL_SCREEN ? NORMAL : FULL_SCREEN);
		#end

		stage.scaleMode = NO_SCALE;
		stage.align = TOP_LEFT;

		addChild(leftGrad = new Sprite());
		addChild(rightGrad = new Sprite());

		addChild(holder = new Sprite());

		holder.addChild(text = new TextField());
		text.autoSize = LEFT;

		textFormat = new TextFormat("_sans", Std.int(Math.min(screenWidth, screenHeight) / 18), 0xFFFFFF, true, false, true);
		text.defaultTextFormat = textFormat;
		text.selectable = text.mouseEnabled = false;

		final song:Song = songs[Std.random(songs.length)];
		final channel:openfl.media.SoundChannel = openfl.utils.Assets.getSound('ass:ass/${song.name}.ogg').play(song.offset);
		channel?.addEventListener(Event.SOUND_COMPLETE, (_) -> #if desktop Sys.exit(0) #else Application.current.window.close() #end);

		bpm = song.bpm;
		beatInterval = 60 / bpm;

		text.text = song.lulz;

		stage.addEventListener(Event.RESIZE, (_) -> {
			screenWidth = Application.current.window.width;
			screenHeight = Application.current.window.height;

			holder.x = screenWidth * 0.5;
			holder.y = screenHeight * 0.5;

			textFormat.size = Std.int(Math.min(screenWidth, screenHeight) / 18);

			text.setTextFormat(textFormat);
			text.defaultTextFormat = textFormat;

			text.x = -text.width * 0.5;
			text.y = -text.height * 0.5;

			drawAll();
		});

		addEventListener(Event.ENTER_FRAME, (_) -> {
			final now:Float = Lib.getTimer();
			final elapsed:Float = (now - lastTime) * 0.001;
			lastTime = now;

			beatTime += elapsed;

			while (beatTime >= beatInterval) {
				beatTime -= beatInterval;
				curBeat++;

				bgColor = randomColor();
				text.textColor = 0xFFFFFF - bgColor;
				drawAll();
			}

			pinpon += elapsed * 5;

			holder.scaleX = Math.cos(pinpon);
			holder.y = screenHeight * 0.5 + Math.sin(pinpon * Math.PI) * 50;
		});
	}

	function drawAll():Void {
		graphics.clear();
		graphics.beginFill(bgColor);
		graphics.drawRect(0, 0, screenWidth, screenHeight);
		graphics.endFill();

		drawGradient(leftGrad, 0, true);
		drawGradient(rightGrad, screenWidth * 0.5, false);
	}

	function drawGradient(s:Sprite, xPos:Float, leftSide:Bool):Void {
		s.graphics.clear();

		final darker:Int = adjustColor(bgColor, -40);
		final lighter:Int = adjustColor(bgColor, 40);
		final odd:Bool = curBeat & 1 != 0;

		final m:Matrix = new Matrix();
		m.createGradientBox(screenWidth * 0.5, screenHeight, 0, xPos, 0);

		s.graphics.beginGradientFill(LINEAR, leftSide ? [odd ? lighter : darker, bgColor] : [bgColor, odd ? darker : lighter], [1, 1], [0, 255], m);
		s.graphics.drawRect(xPos, 0, screenWidth * 0.5, screenHeight);
		s.graphics.endFill();
	}

	function adjustColor(color:Int, amount:Int):Int {
		var r:Int = (color >> 16) & 0xFF;
		var g:Int = (color >> 8) & 0xFF;
		var b:Int = color & 0xFF;

		r = bound(r + amount, 0, 255);
		g = bound(g + amount, 0, 255);
		b = bound(b + amount, 0, 255);

		return (r << 16) | (g << 8) | b;
	}

	inline function bound(v:Int, ?min:Int, ?max:Int):Int {
		final lowBnd:Int = min != null && v < min ? min : v;
		return max != null && lowBnd > max ? max : lowBnd;
	}

	inline function randomColor():Int
		return (Std.random(256) << 16) | (Std.random(256) << 8) | Std.random(256);
}