package feffects.easing;

class Sine implements haxe.Public {
	inline static function easeIn ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return -c * Math.cos ( t / d * ( Math.PI * 0.5 ) ) + c + b;
	}
	
	inline static function easeOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return c * Math.sin( t / d * ( Math.PI * 0.5 ) ) + b;
	}
	
	inline static function easeInOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return -c * 0.5 * ( Math.cos( Math.PI * t / d ) - 1 ) + b;
	}
}
