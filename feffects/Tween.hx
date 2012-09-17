﻿package feffects;

import haxe.FastList;

#if nme
	import nme.Lib;
	import nme.events.Event;
#elseif flash
	import flash.Lib;
	import flash.events.Event;
#elseif js
	import haxe.Timer;
#end

typedef Easing = Float -> Float -> Float -> Float -> Float

/**
* Class that allows tweening properties of an object.<br/>
* Version 1.3.3
* Compatible haxe 2.11 - flash/js/NME
* Usage :<br/>
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
* OR
* 
* mySprite.tween( {x : 100, y : 200 }, 1000, foo, true );
* 
* @author : M.Romecki
* 
*/

class TweenObject {
	
	public var tweens		(default, null)			: FastList<Tween>;
	public var target		(default, null)			: Dynamic;
	public var properties	(default, null)			: Dynamic;
	public var duration		(default, null)			: Int;
	public var easing		(default, null)			: Easing;
	public var isPlaing		(get_isPlaying, null)	: Bool;
	function get_isPlaying() {
		for ( tween in tweens ) 
			if ( tween.isPlaying )
				return true;
		return false;
	}
	
	public static function tween( target : Dynamic, properties : Dynamic, duration : Int, ?easing : Easing, ?onFinish : Void->Void, autoStart = false ) {
		return new TweenObject( target, properties, duration, easing, onFinish, autoStart );
	}
	
	public function new( target : Dynamic, properties : Dynamic, duration : Int, ?easing : Easing, ?onFinish : Void->Void, autoStart = false ) {
		this.target		= target;
		this.properties	= properties;
		this.duration	= duration;
		
		if ( easing != null )
			this.easing = easing;
		if( onFinish != null )
			endF = onFinish;
		
		tweens		= new FastList<Tween>();
		for ( key in Reflect.fields( properties ) ) {
			var prop = { };
			Reflect.setProperty( prop, key, Reflect.getProperty( properties, key ) );
			var tweenProp = new TweenProperty( target, prop, duration, easing, _endF );
			tweens.add( tweenProp );
		}
		
		if ( autoStart )
			start();
	}
	
	public function setEasing( easing : Easing ) {
		for ( tweenProp in tweens )
			tweenProp.setEasing( easing );
		return this;
	}
	
	public function start() {
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
		if ( tweens.isEmpty() )			
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
		
		var init = Reflect.getProperty( target, _property );
		var end = Reflect.getProperty( prop, _property );
		
		super( init, end, duration, easing );
		
		onUpdate( _updateF );
		onFinish( _endF );
	}
	
	inline function _updateF( n : Float ) {
		Reflect.setProperty( _target, _property, n );
	}
	
	inline function _endF() {
		__endF( this );
	}
}

/**
* Class that allows tweening numerical values of an object.<br/>
* Version 1.3.3
* Compatible haxe 2.11 - flash/js/NME
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
* OR fastest one : 
*
* new Tween( 0, 100, 2000, Elastic.easeIn, foo, foo2, true ).seek( 1000 );
* 
* @author : M.Romecki
* 
*/

class Tween{
	static var _aTweens	= new FastList<Tween>();
	static var _aPaused	= new FastList<Tween>();
	
	#if ( !nme && js )
		static var _timer	: haxe.Timer;
		public static var INTERVAL		= 10;
	#end
	
	public static var DEFAULT_EASING	= easingEquation;
			
	public var duration	(default, null): Int;
	public var position	(default, null): Int;
	public var reversed	(default, null): Bool;
	public var isPlaying(default, null): Bool;
	
	static var _isTweening	: Bool;
			
	var _initVal		: Float;
	var _endVal			: Float;
	var _startTime		: Float;
	var _pauseTime		: Float;
	var _offsetTime		: Float;
	var _reverseTime	: Float;
	
	var _easingF		: Easing;
	
	static function AddTween( tween : Tween ) : Void {
		
		if ( !_isTweening )
		{
			#if ( !nme && js )
				_timer 		= new haxe.Timer( INTERVAL ) ;
				_timer.run 	= cb_tick;
			#else
				Lib.current.stage.addEventListener( Event.ENTER_FRAME, cb_tick );
			#end
			_isTweening	= true;
			cb_tick();
		}
		
		_aTweens.add( tween );
	}

	static function RemoveTween( tween : Tween ) : Void {
		if ( !_isTweening )
			return;
		_aTweens.remove( tween );
		if ( _aTweens.isEmpty() && _aPaused.isEmpty() )	{
			#if ( !nme && js )
				_timer.stop() ;
				_timer	= null ;
			#else
				Lib.current.stage.removeEventListener( Event.ENTER_FRAME, cb_tick );
			#end
			_isTweening = false;
		}
	}
	
	public static function getActiveTweens() : FastList<Tween> {
		return _aTweens;
	}
	
	public static function getPausedTweens() : FastList<Tween> {
		return _aPaused;
	}
	
	static function setTweenPaused( tween : Tween ) : Void {
		if ( !_isTweening )
			return;
					
		_aPaused.add( tween );
		_aTweens.remove( tween );
	}
	
	static function setTweenActive( tween : Tween ) : Void {
		if ( !_isTweening )
			return;
					
		_aTweens.add( tween );
		_aPaused.remove( tween );
	}

	static function cb_tick( #if ( nme || flash ) ?_ #end ) : Void	{
		for ( i in _aTweens )
			i.doInterval();
	}
		
	/**
	* Create a tween from the [init] value, to the [end] value, while [dur] (in ms)<br />
	* There is a default easing equation.
	*/
	
	public function new( init : Float, end : Float, dur : Int, ?easing : Easing, ?updateF : Float->Void, ?endF : Void->Void, autoStart = false ) {
				
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
			
		if ( updateF != null )
			this.updateF = updateF;
			
		if ( endF != null )
			this.endF = endF;
			
		isPlaying = false;
		
		if ( autoStart )
			start();
	}
	
	public function start() : Void {
		
		_startTime = getStamp();
		_reverseTime = getStamp();
		
		if ( duration == 0 )
			finish();
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
		_startTime += getStamp() - _pauseTime;
		_reverseTime += getStamp() - _pauseTime;
				
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
	
	function finish() : Void {
		RemoveTween( this );
		var val = 0.0;
		isPlaying = false;
		if ( reversed )
			val = _initVal;
		else
			val = _endVal;
		
		updateF( val );
		endF();
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
		if ( curTime >= duration || curTime < 0 )
			finish();
		else{
			updateF( curVal );
		}
		position = curTime;						
	}
	
	inline function getCurVal( curTime : Int ) : Float {
		return _easingF( curTime, _initVal, _endVal - _initVal, duration );
	}
	
	inline function getStamp() {
		#if neko
			return neko.Sys.time() * 1000;
		#elseif cpp
			return cpp.Sys.time() * 1000;
		#elseif js
			return Date.now().getTime();
		#elseif flash
			return flash.Lib.getTimer();
		#end
	}

	static inline function easingEquation( t : Float, b : Float, c : Float, d : Float ) : Float {
		return c / 2 * ( Math.sin( Math.PI * ( t / d - 0.5 ) ) + 1 ) + b;
	}
}