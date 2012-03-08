package feffects;

import haxe.FastList;

typedef Easing = Float -> Float -> Float -> Float -> Float

/**
* Class that allows tweening properties of an object.<br/>
* Version 1.3.0
* Compatible haxe 2.08 - flash/flash9+/js/neko/cpp
* Usage :<br/>
* import feffects.Tween;<br/>
* import feffects.easing.Elastic;<br/>
* 
* using feffects.Tween.TweenObject;
* ...<br/>
* var mySprite = new Sprite();
* mySprite.graphics.beginFill( 0 );
* mySprite.graphics.drawCircle( 0, 0, 20 );
* mySprite.graphics.endFill();
* 
* Lib.current.addChild( mySprite );
* 
* function foo() {
* 	trace( "end" );
* }
* 
* mySprite.tween( { x : 100, y : 200 }, 1000 ).onFinish( foo ).start();
* 
* @author : M.Romecki
* 
*/

class TweenObject {
	
	public var tweens		(default, null)		: Array<Tween>;
	public var settings							: { target : Dynamic, properties : Dynamic, duration : Int, easing : Easing };
	
	public static function tween( target : Dynamic, properties : Dynamic, duration : Int, ?easing : Easing ) {
		return new TweenObject( target, properties, duration, easing );
	}
	
	public function new( target : Dynamic, properties : Dynamic, duration : Int, ?easing : Easing ) {
		settings = {
			target		: target,
			properties	: properties,
			duration	: duration,
			easing		: easing
		}
		
		tweens = [];
	}
	
	public function start() {
		for ( key in Reflect.fields( settings.properties ) ) {
			var prop = { };
			Reflect.setField( prop, key, Reflect.field( settings.properties, key ) );
			var tweenProp = new TweenProperty( settings.target, prop, settings.duration, settings.easing, _endF );
			tweens.push( tweenProp );
		}
		for ( tweenProp in tweens )
			tweenProp.start();
		return tweens;
	}
	
	public function pause() {
		for ( tweenProp in tweens )
			tweenProp.pause();
	}
	
	public function resume() {
		for ( tweenProp in tweens )
			tweenProp.resume();
	}
	
	public function seek( n : Int ) {
		for ( tweenProp in tweens )
			tweenProp.seek( n );
	}
	
	public function reverse() {
		for ( tweenProp in tweens )
			tweenProp.reverse();
	}
	
	public function stop() {
		for ( tweenProp in tweens )
			tweenProp.stop();
	}
	
	public function onFinish( f : Void->Void ) {
		endF = f;
		return this;
	}
		
	dynamic function endF() {}
		
	function _endF( tp : TweenProperty ) {
		tweens.remove( tp );
		if ( tweens.length == 0 )			
			endF();
	}
}

private class TweenProperty extends Tween{
	
	var _target		: Dynamic;
	var _property	: String;
	var __endF		: TweenProperty->Void;
	
	public function new( target : Dynamic, prop : Dynamic, duration : Int, ?easing : Easing, endF : TweenProperty->Void ) {
		_target = target;
		_property = Reflect.fields( prop )[ 0 ];
		__endF = endF;
		
		var init = Reflect.field( target, _property );
		var end = Reflect.field( prop, _property );
		
		super( init, end, duration, easing );
		
		onUpdate( _updateF );
		onFinish( _endF );
	}
	
	function _updateF( n : Float ) {
		Reflect.setField( _target, _property, n ); 
	}
	
	function _endF() {
		__endF( this );
	}
}

/**
* Class that allows tweening numerical values of an object.<br/>
* Version 1.3.0
* Compatible haxe 2.08 - flash/flash9+/js/neko/cpp
* Usage :<br/>
* import feffects.Tween;<br/>
* import feffects.easing.Elastic;<br/>
* ...<br/>
* function foo ( n : Float ){
* 	mySprite.x = n;
* }
* var t = new Tween( 0, 100, 2000 );						// create a new tween<br/>
* t.onUpdate( foo );
* t.start();												// start the tween<br/>
* 
* You can add :
* * 
* t.setEasing( Elastic.easeIn );							// set the easing function used to compute values<br/>
* t.seek( 1000 );											// go to the specified position (in ms)</br>
* t.pause();<br/>
* t.resume();<br/>
* t.reverse();												// reverse the tween from the current position</br>
* t.stop();
* 
* OR combinated sythax :
* 
* new Tween( 0, 100, 2000 ).setEasing( Elastic.easeIn ).seek( 1000 ).onUpdate( foo ).onFinish( foo2 ).start();
* 
* @author : M.Romecki
* 
*/

class Tween{
	static var _aTweens	= new FastList<Tween>();
	static var _aPaused	= new FastList<Tween>();
	static var _timer	: haxe.Timer;
	
	public static var INTERVAL			= 10;
	public static var DEFAULT_EASING	= easingEquation;
			
	public var duration	(default, null): Int;
	public var position	(default, null): Int;
	public var reversed	(default, null): Bool;
	public var isPlaying(default, null): Bool;
			
	var _initVal		: Float;
	var _endVal			: Float;
	var _startTime		: Float;
	var _pauseTime		: Float;
	var _offsetTime		: Float;
	var _reverseTime	: Float;
	
	var _easingF		: Easing;
				
	static function AddTween( tween : Tween ) : Void {
		if( _timer == null )
			_timer = new haxe.Timer( INTERVAL ) ;
		_aTweens.add( tween ) ;
		_timer.run = DispatchTweens;
	}

	static function RemoveTween( tween : Tween ) : Void {
		if ( tween == null || _timer == null )
			return;
					
		_aTweens.remove( tween );
								
		if ( _aTweens.isEmpty() && _aPaused.isEmpty() )	{
			_timer.stop() ;
			_timer = null ;
		}
	}
	
	public static function getActiveTweens() : FastList<Tween> {
		return _aTweens;
	}
	
	public static function getPausedTweens() : FastList<Tween> {
		return _aPaused;
	}
	
	static function setTweenPaused( tween : Tween ) : Void {
		if ( tween == null || _timer == null )
			return;
					
		_aPaused.add( tween );
		_aTweens.remove( tween );
	}
	
	static function setTweenActive( tween : Tween ) : Void {
		if ( tween == null || _timer == null )
			return;
					
		_aTweens.add( tween );
		_aPaused.remove( tween );
	}

	static function DispatchTweens() : Void	{
		for ( i in _aTweens )
			i.doInterval();
	}
		
	/**
	* Create a tween from the [init] value, to the [end] value, while [dur] (in ms)<br />
	* There is a default easing equation.
	*/
	
	public function new( init : Float, end : Float, dur : Int, ?easing : Easing ) {
		_initVal = init;
		_endVal = end;
		duration = dur;
		
		_offsetTime = 0;
		position = 0;
		reversed = false;
		
		if ( easing != null )
			_easingF = easing;
		else
			_easingF = easingEquation;
			
		isPlaying = false;
	}
	
	public function start() : Void {
		_startTime = getStamp();
				
		if ( duration == 0 )
			endTween();
		else
			Tween.AddTween( this );
		isPlaying = true;
	}
	
	public function pause() : Void {
		_pauseTime = getStamp();
		
		Tween.setTweenPaused( this );
		isPlaying = false;
	}
	
	public function resume() : Void {
		_startTime = _reverseTime = _startTime + getStamp() - _pauseTime;
				
		Tween.setTweenActive( this );
		isPlaying = true;
	}
	
	/**
	* Go to the specified position [ms] (in ms) 
	*/
	public function seek( ms : Int ) : Tween {
		_offsetTime = ms;
		return this;
	}
		
	/**
	* Reverse the tweeen from the current position 
	*/
	public function reverse() : Void {
		reversed = !reversed;
		if ( !reversed )
			_startTime += ( getStamp() - _reverseTime ) * 2;

		_reverseTime = getStamp();
	}
	
	public function stop() : Void {
		Tween.RemoveTween( this );
		isPlaying = false;
	}
	
	public function onUpdate( f : Float -> Void ) {
		updateF = f;
		return this;
	}
	
	public function onFinish( f : Void -> Void ) {
		endF = f;
		return this;
	}
	
	/**
	* Set the [easingFunc] equation to use for tweening
	*/
	public function setEasing( f : Easing ) : Tween {
		_easingF = f;
		return this;
	}
	
	dynamic function updateF( e : Float ) { }
	dynamic function endF() { }
	
	inline function doInterval() : Void {
		var stamp = getStamp();
				
		var curTime = 0;
		untyped{
		if ( reversed )
			curTime = ( _reverseTime * 2 ) - stamp - _startTime + _offsetTime;
		else
			curTime = stamp - _startTime + _offsetTime;
		}
				
		var curVal = getCurVal( curTime );
		if ( curTime >= duration || curTime <= 0 )
			endTween();
		else{
			updateF( curVal );
		}
		position = curTime;						
	}
	
	inline function getCurVal( curTime : Int ) : Float {
		return _easingF( curTime, _initVal, _endVal - _initVal, duration );
	}
	
	inline function getStamp() {
		#if (neko || cpp)
			return neko.Sys.time() * 1000;
		#elseif js
			return Date.now().getTime();
		#elseif flash
			return flash.Lib.getTimer();
		#end
	}

	function endTween() : Void {
		RemoveTween( this );
		var val = 0.0;
		if ( reversed )
			val = _initVal;
		else
			val = _endVal;
		
		updateF( val );
		endF();
	}

	static inline function easingEquation( t : Float, b : Float, c : Float, d : Float ) : Float {
		return c / 2 * ( Math.sin( Math.PI * ( t / d - 0.5 ) ) + 1 ) + b;
	}
}