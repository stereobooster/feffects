package feffects;

import feffects.Tween;

class TweenRgb extends Tween {

	var _initVals		: Dynamic;
	var _endVals		: Dynamic;

	public function intToRgb(c: Int): Dynamic {
		return {
			r: ( (c >> 16) & 0xFF ),
			g: ( (c >> 8) & 0xFF ),
			b: ( c & 0xFF )
		};
	}

	public function RgbToInt(c: Dynamic): Int {
		return ( ( c.r << 16 ) | ( c.g << 8 ) | c.b );
	}

	public function new( init : Float, end : Float, dur : Int, ?easing : Easing, autoStart = false, ?onUpdate : Float->Void, ?onFinish : Void->Void ) {
		super(init, end, dur, easing, autoStart, onUpdate, onFinish);

		_initVals		= intToRgb( Std.int(init) );
		_endVals		= intToRgb( Std.int(end) );
	}

	override function getCurVal( curTime : Int ) : Float {
		var c = {
			r: Math.floor(_easingF( curTime, _initVals.r, _endVals.r - _initVals.r, duration )),
			g: Math.floor(_easingF( curTime, _initVals.g, _endVals.g - _initVals.g, duration )),
			b: Math.floor(_easingF( curTime, _initVals.b, _endVals.b - _initVals.b, duration ))
		};
		return RgbToInt(c);
	}
}

