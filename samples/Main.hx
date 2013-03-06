import feffects.Tween;
import feffects.easing.Quint;
import feffects.easing.Sine;
import feffects.easing.Back;
import feffects.easing.Bounce;
import feffects.easing.Circ;
import feffects.easing.Cubic;
import feffects.easing.Elastic;
import feffects.easing.Expo;
import feffects.easing.Linear;
import feffects.easing.Quad;
import feffects.easing.Quart;

#if flash9
	import flash.display.MovieClip;
	import flash.Lib;
#elseif flash8
	import flash.MovieClip;
	import flash.Lib;
#elseif (js && !nme)
	#if haxe3
		import js.Browser;
	#else
		import js.Dom;
	#end
	import js.Lib;
#elseif nme
	import nme.display.MovieClip;
	import nme.Lib;
#end

using feffects.Tween.TweenObject;

class Main {
	public function new() {
		var effects = 
		[ 
			Quint.easeIn, Quint.easeOut, Quint.easeInOut,
			Sine.easeIn, Sine.easeOut, Sine.easeInOut,
			Back.easeIn, Back.easeOut, Back.easeInOut,
			Bounce.easeIn, Bounce.easeOut, Bounce.easeInOut,
			Circ.easeIn, Circ.easeOut, Circ.easeInOut,
			Cubic.easeIn, Cubic.easeOut, Cubic.easeInOut,
			Elastic.easeIn, Elastic.easeOut, Elastic.easeInOut,
			Expo.easeIn, Expo.easeOut, Expo.easeInOut,
			Linear.easeIn, Linear.easeOut, Linear.easeInOut, Linear.easeNone,
			Quad.easeIn, Quad.easeOut, Quad.easeInOut,
			Quart.easeIn, Quart.easeOut, Quad.easeInOut
		];
		
		var i = 0;
		var sprite	= null;
		var gfx		= null;
		var t		= null;
		while ( i < effects.length ) {
			#if (flash9||nme)
				sprite = new MovieClip();
				sprite.x = i * 10 + 30;
				gfx = sprite.graphics;
				gfx.beginFill( 0x000000, 1 );
				Lib.current.addChild( sprite );
			#elseif js
				// new local var sprite needed...js bug ???
				#if haxe3
					var sprite = Browser.document.createElement( "div" );
					Browser.document.body.appendChild( sprite );
				#else
					var sprite = Lib.document.createElement( "div" );
					Lib.document.body.appendChild( sprite );
				#end
				sprite.style.position = "absolute";
				sprite.style.backgroundColor = "#000000";
				sprite.style.padding = "5px";
				sprite.style.left = i * 10 + 30 + "px";
			#elseif flash8
				sprite = Lib.current.createEmptyMovieClip( "sprite" + i, i );
				sprite._x = i * 10 + 30;
				gfx = sprite;
				gfx.beginFill( 0x000000, 100 );
			#end
			
			#if (flash||nme)
				gfx.lineTo( 10, 0 );
				gfx.lineTo( 10, 10 );
				gfx.lineTo( 0, 10 );
				gfx.lineTo( 0, 0 );
				gfx.endFill();
				#if flash8
					t = sprite.tween( { _y : 150 }, 2000, effects[ i ] );
				#else
					t = sprite.tween( { y : 150 }, 2000, effects[ i ] );
				#end
			#elseif js
				t = new Tween( 50, 150, 2000, effects[ i ] );
				t.onUpdate( function ( e ) sprite.style.top = e + "px" );
			#end
				
			t.start();
			t.seek( 350 );
									
			haxe.Timer.delay( t.pause, 250 );
			haxe.Timer.delay( t.resume, 500 );
			haxe.Timer.delay( t.reverse, 750 );
			haxe.Timer.delay( t.reverse, 1000 );
			haxe.Timer.delay( t.reverse, 1250 );
			haxe.Timer.delay( t.reverse, 1500 );
			haxe.Timer.delay( t.pause, 1750 );
			haxe.Timer.delay( t.resume, 2000 );
			i++;
		}
		
		trace( "start for 2000ms tweening" );
		trace( "seek at 350ms" );
		haxe.Timer.delay( function() trace( "pause" ), 250 );
		haxe.Timer.delay( function() trace( "resume" ), 500 );
		haxe.Timer.delay( function() trace( "reverse" ), 750 );
		haxe.Timer.delay( function() trace( "reverse" ), 1000 );
		haxe.Timer.delay( function() trace( "reverse" ), 1250 );
		haxe.Timer.delay( function() trace( "reverse" ), 1500 );
		haxe.Timer.delay( function() trace( "pause" ), 1750 );
		haxe.Timer.delay( function() trace( "resume" ), 2000 );
	}
	
	public static function main() {
		new Main();
	}
}