package feffects;

import haxe.FastList;

#if nme
	import nme.Lib;
	import nme.events.Event;
#elseif flash9
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
	
	public var tweens		(default, null)			: List<Tween>;
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
	
	var __onFinish			: Dynamic;
	var __onFinishParams	: Array<Dynamic>;
	
	public static function tween( target : Dynamic, properties : Dynamic, duration : Int, ?easing : Easing, autoStart = false, ?onFinish : Dynamic, ?onFinishParams : Array<Dynamic> ) {
		return new TweenObject( target, properties, duration, easing, autoStart, onFinish, onFinishParams );
	}
	
	public function new( target : Dynamic, properties : Dynamic, duration : Int, ?easing : Easing, autoStart = false, ?onFinish : Dynamic, ?onFinishParams : Array<Dynamic> ) {
		this.target			= target;
		this.properties		= properties;
		this.duration		= duration;
		this.easing 		= easing;
		
		this.onFinish( onFinish, onFinishParams );
		
		if ( autoStart )
			start();
	}
	
	public function setEasing( easing : Easing ) : TweenObject {
		for ( tweenProp in tweens )
			tweenProp.setEasing( easing );
		return this;
	}
	
	public function start() : List<Tween>{
		tweens	= new List<Tween>();
		for ( key in Reflect.fields( properties ) ) {
			var tp = new TweenProperty( target, key, Reflect.field( properties, key ), duration, easing, false );
			tp.onFinish( _onFinish, [ tp ] ).start();
			tweens.add( tp );
		}
				
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
	
	public function seek( n : Int ) : TweenObject {
		for ( tweenProp in tweens )
			tweenProp.seek( n );
		return this;
	}
	
	public function reverse(){
		for ( tweenProp in tweens )
			tweenProp.reverse();
	}
	
	public function stop( ?finish : Bool ) {
		for ( tweenProp in tweens )
			tweenProp.stop( finish );
	}
	
	public function onFinish( f : Dynamic, ?params : Array<Dynamic> ) : TweenObject {
		__onFinish 			= f;
		__onFinishParams	= params == null ? [] : params;
		return this;
	}
		
	function _onFinish( tp : TweenProperty ) {
		tweens.remove( tp );
		if ( tweens.isEmpty() )
			if ( __onFinish != null )
				Reflect.callMethod( null, __onFinish, __onFinishParams );
	}
}

class TweenProperty extends Tween{
	
	var _target				: Dynamic;
	var _property			: String;
	var ___onUpdate			: Dynamic;
	var ___onUpdateParams	: Array<Dynamic>;
	
	public function new( target : Dynamic, prop : String, value : Float, duration : Int, ?easing : Easing, autostart = false, ?onUpdate : Dynamic, ?onUpdateParams : Array<Dynamic>, ?onFinish : Dynamic, ?onFinishParams : Array<Dynamic> ) {
		_target					= target;
		_property				= prop;
		___onUpdateParams		= [ 0 ];
		if( onUpdateParams != null )
			___onUpdateParams	= ___onUpdateParams.concat( onUpdateParams );
		
		super( Reflect.getProperty( target, _property ), value, duration, easing, autostart, __onUpdate, onFinish, onFinishParams );
	}
	
	function __onUpdate( n : Float ) {
		Reflect.setProperty( _target, _property, n );
		if ( ___onUpdate != null )
		{
			___onUpdateParams[ 0 ]	= n;
			Reflect.callMethod( null, ___onUpdate, ___onUpdateParams );
		}
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

class Tween {
	static var _aTweens	= new FastList<Tween>();
	static var _aPaused	= new FastList<Tween>();
	
	#if ( !nme && js || flash8 )
		static var _timer	: haxe.Timer;
		public static var INTERVAL		= 10;
	#end
	
	public static var DEFAULT_EASING	= easingEquation;
			
	public var duration		(default, null) : Int;
	public var position		(default, null) : Int;
	public var isReversed	(default, null) : Bool;
	public var isPlaying	(default, null) : Bool;
	public var isPaused		(default, null) : Bool;
	
	static var _isTweening	: Bool;
			
	var _initVal		: Float;
	var _endVal			: Float;
	var _startTime		: Float;
	var _pauseTime		: Float;
	var _offsetTime		: Float;
	var _reverseTime	: Float;
	
	var _easingF		: Easing;
	var _onUpdate		: Dynamic;
	var _onFinish		: Dynamic;
	var _onUpdateParams	: Array<Dynamic>;
	var _onFinishParams	: Array<Dynamic>;
	
	static function AddTween( tween : Tween ) : Void {
		if ( !_isTweening )
		{
			#if ( !nme && js || flash8 )
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

	static function RemoveActiveTween( tween : Tween ) : Void {
		_aTweens.remove( tween );
		checkActiveTweens();
	}
	
	static function RemovePausedTween( tween : Tween ) : Void {
		_aPaused.remove( tween );
		checkActiveTweens();
	}
	
	static function checkActiveTweens() {
		if ( _aTweens.isEmpty() )
		{
			#if ( !nme && js || flash8 )
				if ( _timer != null )
				{
					_timer.stop() ;
					_timer	= null ;
				}
			#else
				Lib.current.stage.removeEventListener( Event.ENTER_FRAME, cb_tick );
			#end
			_isTweening = false;
		}
	}
	
	public static function getActiveTweens() {
		return _aTweens;
	}
	
	public static function getPausedTweens() {
		return _aPaused;
	}
	
	static function setTweenPaused( tween : Tween ) : Void {
		if ( !tween.isPlaying )
			return;
					
		_aPaused.add( tween );
		_aTweens.remove( tween );
		
		checkActiveTweens();
	}
	
	static function setTweenActive( tween : Tween ) : Void {
		if ( tween.isPlaying )
			return;
					
		_aTweens.add( tween );
		_aPaused.remove( tween );
		
		if ( !_isTweening )
		{
			#if ( !nme && js || flash8 )
				_timer 		= new haxe.Timer( INTERVAL ) ;
				_timer.run 	= cb_tick;
			#else
				Lib.current.stage.addEventListener( Event.ENTER_FRAME, cb_tick );
			#end
			_isTweening	= true;
			cb_tick();
		}
	}

	static function cb_tick( #if ( nme || flash9 ) ?_ #end ) : Void	{
		for ( i in _aTweens )
			i.doInterval();
	}
		
	/**
	* Create a tween from the [init] value, to the [end] value, while [dur] (in ms)<br />
	* There is a default easing equation.
	*/
	
	public function new( init : Float, end : Float, dur : Int, ?easing : Easing, autoStart = false, ?onUpdate : Dynamic, ?onUpdateParams : Array<Dynamic>, ?onFinish : Dynamic, ?onFinishParams : Array<Dynamic> ) {
				
		_initVal		= init;
		_endVal			= end;
		duration		= dur;
		
		this.onUpdate( onUpdate, onUpdateParams ); 
		this.onFinish( onFinish, onFinishParams );
		
		_offsetTime 	= 0;
		position		= 0;
		isPlaying		= false;
		isPaused		= false;
		isReversed		= false;
		
		if ( easing != null )
			_easingF = easing;
		else
			_easingF = easingEquation;
			
		if ( autoStart )
			start();
	}
	
	public function start( position = 0 ) : Void {
		
		_startTime		= getStamp();
		_reverseTime	= getStamp();
		
		seek( position );
		
		if ( isPaused )
			RemovePausedTween( this );
		
		Tween.AddTween( this );
		isPlaying = true;
		
		if ( duration == 0 || position >= duration )
			finish();
	}
	
	public function pause() : Void {
		if ( !isPlaying )
			return;
			
		_pauseTime	= getStamp();
		
		Tween.setTweenPaused( this );
		isPlaying	= false;
		isPaused	= true;
	}
	
	public function resume() : Void {
		if ( !isPaused || isPlaying )
			return;
		
		_startTime		+= getStamp() - _pauseTime;
		_reverseTime 	+= getStamp() - _pauseTime;
				
		Tween.setTweenActive( this );
		isPlaying	= true;
		isPaused	= true;
	}
	
	/**
	* Go to the specified position [ms] (in ms) 
	*/
	public function seek( ms : Int ) : Tween {
		_offsetTime = ms < duration ? ms : duration;
		return this;
	}
		
	/**
	* Reverse the tweeen from the current position 
	*/
	public function reverse() {
		if ( !isPlaying )
			return;
		
		isReversed = !isReversed;
		if ( !isReversed )
			_startTime += ( getStamp() - _reverseTime ) * 2;

		_reverseTime = getStamp();
	}
	
	public function stop( ?doFinish : Bool ) : Void {
		if( isPaused )
			RemovePausedTween( this );
		else
			if( isPlaying )
				RemoveActiveTween( this );
				
		if ( doFinish )
			finish();		
		
		isPaused	= false;
		isPlaying	= false;
	}
	
	function finish() : Void {
		RemoveActiveTween( this );
		isPlaying				= false;
		_onUpdateParams[ 0 ]	= isReversed ? _initVal : _endVal;
		
		if( _onUpdate != null )
			Reflect.callMethod( null, _onUpdate, _onUpdateParams );
		if( _onFinish != null )
			Reflect.callMethod( null, _onFinish, _onFinishParams );
	}

	
	public function onUpdate( f : Dynamic, ?params : Array<Dynamic> ) {
		_onUpdate		= f;
		_onUpdateParams	= [ 0 ];
		if ( params != null )
			_onUpdateParams = _onUpdateParams.concat( params );
					
		return this;
	}
	
	public function onFinish( f : Dynamic, ?params : Array<Dynamic> ) {
		_onFinish 		= f;
		_onFinishParams	= params == null ? [] : params;
		return this;
	}
	
	/**
	* Set the [easingFunc] equation to use for tweening
	*/
	public function setEasing( f : Easing ) : Tween {
		_easingF = f;
		return this;
	}
	
	function doInterval() : Void {
		var stamp = getStamp();
				
		var curTime = 0;
		untyped{
		if ( isReversed )
			curTime = ( _reverseTime * 2 ) - stamp - _startTime + _offsetTime;
		else
			curTime = stamp - _startTime + _offsetTime;
		}
		
		var curVal = getCurVal( curTime );
		if ( curTime >= duration || curTime < 0 )
			finish();
		else {
			if ( _onUpdate != null )
			{
				_onUpdateParams[ 0 ] = curVal;
				Reflect.callMethod( null, _onUpdate, _onUpdateParams );
			}
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