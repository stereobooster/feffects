(function () { "use strict";
function $extend(from, fields) {
	function inherit() {}; inherit.prototype = from; var proto = new inherit();
	for (var name in fields) proto[name] = fields[name];
	return proto;
}
var Main = function() {
	var effects = [feffects.easing.Quint.easeIn,feffects.easing.Quint.easeOut,feffects.easing.Quint.easeInOut,feffects.easing.Sine.easeIn,feffects.easing.Sine.easeOut,feffects.easing.Sine.easeInOut,feffects.easing.Back.easeIn,feffects.easing.Back.easeOut,feffects.easing.Back.easeInOut,feffects.easing.Bounce.easeIn,feffects.easing.Bounce.easeOut,feffects.easing.Bounce.easeInOut,feffects.easing.Circ.easeIn,feffects.easing.Circ.easeOut,feffects.easing.Circ.easeInOut,feffects.easing.Cubic.easeIn,feffects.easing.Cubic.easeOut,feffects.easing.Cubic.easeInOut,feffects.easing.Elastic.easeIn,feffects.easing.Elastic.easeOut,feffects.easing.Elastic.easeInOut,feffects.easing.Expo.easeIn,feffects.easing.Expo.easeOut,feffects.easing.Expo.easeInOut,feffects.easing.Linear.easeIn,feffects.easing.Linear.easeOut,feffects.easing.Linear.easeInOut,feffects.easing.Linear.easeNone,feffects.easing.Quad.easeIn,feffects.easing.Quad.easeOut,feffects.easing.Quad.easeInOut,feffects.easing.Quart.easeIn,feffects.easing.Quart.easeOut,feffects.easing.Quad.easeInOut];
	var i = 0;
	var sprite = null;
	var gfx = null;
	var t = null;
	while(i < effects.length) {
		var sprite1 = [js.Browser.document.createElement("div")];
		js.Browser.document.body.appendChild(sprite1[0]);
		sprite1[0].style.position = "absolute";
		sprite1[0].style.backgroundColor = "#000000";
		sprite1[0].style.padding = "5px";
		sprite1[0].style.left = i * 10 + 30 + "px";
		t = new feffects.Tween(50,150,2000,effects[i]);
		t.onUpdate((function(sprite1) {
			return function(e) {
				sprite1[0].style.top = e + "px";
			};
		})(sprite1));
		t.start();
		t.seek(350);
		haxe.Timer.delay($bind(t,t.pause),250);
		haxe.Timer.delay($bind(t,t.resume),500);
		haxe.Timer.delay($bind(t,t.reverse),750);
		haxe.Timer.delay($bind(t,t.reverse),1000);
		haxe.Timer.delay($bind(t,t.reverse),1250);
		haxe.Timer.delay($bind(t,t.reverse),1500);
		haxe.Timer.delay($bind(t,t.pause),1750);
		haxe.Timer.delay($bind(t,t.resume),2000);
		i++;
	}
	console.log("start for 2000ms tweening");
	console.log("seek at 350ms");
	haxe.Timer.delay(function() {
		console.log("pause");
	},250);
	haxe.Timer.delay(function() {
		console.log("resume");
	},500);
	haxe.Timer.delay(function() {
		console.log("reverse");
	},750);
	haxe.Timer.delay(function() {
		console.log("reverse");
	},1000);
	haxe.Timer.delay(function() {
		console.log("reverse");
	},1250);
	haxe.Timer.delay(function() {
		console.log("reverse");
	},1500);
	haxe.Timer.delay(function() {
		console.log("pause");
	},1750);
	haxe.Timer.delay(function() {
		console.log("resume");
	},2000);
};
Main.main = function() {
	new Main();
}
var Reflect = function() { }
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	} catch( e ) {
	}
	return v;
}
Reflect.getProperty = function(o,field) {
	var tmp;
	return o == null?null:o.__properties__ && (tmp = o.__properties__["get_" + field])?o[tmp]():o[field];
}
Reflect.setProperty = function(o,field,value) {
	var tmp;
	if(o.__properties__ && (tmp = o.__properties__["set_" + field])) o[tmp](value); else o[field] = value;
}
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
}
var feffects = {}
feffects.TweenObject = function(target,properties,duration,easing,autoStart,onFinish) {
	if(autoStart == null) autoStart = false;
	this.target = target;
	this.properties = properties;
	this.duration = duration;
	this.easing = easing;
	this.onFinish(onFinish);
	this.tweens = new haxe.ds.GenericStack();
	this._nbTotal = 0;
	var _g = 0, _g1 = Reflect.fields(properties);
	while(_g < _g1.length) {
		var key = _g1[_g];
		++_g;
		var tp = new feffects.TweenProperty(target,key,Reflect.field(properties,key),duration,easing,false);
		tp.onFinish($bind(this,this._onFinish));
		this.tweens.add(tp);
		this._nbTotal++;
	}
	if(autoStart) this.start();
};
feffects.TweenObject.tween = function(target,properties,duration,easing,autoStart,onFinish) {
	if(autoStart == null) autoStart = false;
	return new feffects.TweenObject(target,properties,duration,easing,autoStart,onFinish);
}
feffects.TweenObject.prototype = {
	_onFinish: function() {
		this._nbFinished++;
		if(this._nbFinished == this._nbTotal) this.__onFinish();
	}
	,onFinish: function(f) {
		this.__onFinish = f != null?f:function() {
		};
		return this;
	}
	,stop: function(finish) {
		var $it0 = this.tweens.iterator();
		while( $it0.hasNext() ) {
			var tweenProp = $it0.next();
			tweenProp.stop(finish);
		}
	}
	,reverse: function() {
		var $it0 = this.tweens.iterator();
		while( $it0.hasNext() ) {
			var tweenProp = $it0.next();
			tweenProp.reverse();
		}
	}
	,seek: function(n) {
		var $it0 = this.tweens.iterator();
		while( $it0.hasNext() ) {
			var tweenProp = $it0.next();
			tweenProp.seek(n);
		}
		return this;
	}
	,resume: function() {
		var $it0 = this.tweens.iterator();
		while( $it0.hasNext() ) {
			var tweenProp = $it0.next();
			tweenProp.resume();
		}
	}
	,pause: function() {
		var $it0 = this.tweens.iterator();
		while( $it0.hasNext() ) {
			var tweenProp = $it0.next();
			tweenProp.pause();
		}
	}
	,start: function() {
		this._nbFinished = 0;
		var $it0 = this.tweens.iterator();
		while( $it0.hasNext() ) {
			var tweenProp = $it0.next();
			tweenProp.start();
		}
		return this.tweens;
	}
	,setEasing: function(easing) {
		var $it0 = this.tweens.iterator();
		while( $it0.hasNext() ) {
			var tweenProp = $it0.next();
			tweenProp.setEasing(easing);
		}
		return this;
	}
	,get_isPlaying: function() {
		var $it0 = this.tweens.iterator();
		while( $it0.hasNext() ) {
			var tween = $it0.next();
			if(tween.isPlaying) return true;
		}
		return false;
	}
	,__properties__: {get_isPlaying:"get_isPlaying"}
}
var haxe = {}
haxe.ds = {}
haxe.ds.GenericStack = function() {
};
haxe.ds.GenericStack.prototype = {
	iterator: function() {
		var l = this.head;
		return { hasNext : function() {
			return l != null;
		}, next : function() {
			var k = l;
			l = k.next;
			return k.elt;
		}};
	}
	,remove: function(v) {
		var prev = null;
		var l = this.head;
		while(l != null) {
			if(l.elt == v) {
				if(prev == null) this.head = l.next; else prev.next = l.next;
				break;
			}
			prev = l;
			l = l.next;
		}
		return l != null;
	}
	,add: function(item) {
		this.head = new haxe.ds.FastCell(item,this.head);
	}
}
feffects.Tween = function(init,end,dur,easing,autoStart,onUpdate,onFinish) {
	if(autoStart == null) autoStart = false;
	this._initVal = init;
	this._endVal = end;
	this.duration = dur;
	this._offsetTime = 0;
	this.position = 0;
	this.isPlaying = false;
	this.isPaused = false;
	this.isReversed = false;
	this.onUpdate(onUpdate);
	this.onFinish(onFinish);
	this.setEasing(easing);
	if(autoStart) this.start();
};
feffects.Tween.addTween = function(tween) {
	if(!feffects.Tween._isTweening) {
		feffects.Tween._timer = new haxe.Timer(feffects.Tween.INTERVAL);
		feffects.Tween._timer.run = feffects.Tween.cb_tick;
		feffects.Tween._isTweening = true;
		feffects.Tween.cb_tick();
	}
	feffects.Tween._aTweens.add(tween);
}
feffects.Tween.removeActiveTween = function(tween) {
	feffects.Tween._aTweens.remove(tween);
	feffects.Tween.checkActiveTweens();
}
feffects.Tween.removePausedTween = function(tween) {
	feffects.Tween._aPaused.remove(tween);
	feffects.Tween.checkActiveTweens();
}
feffects.Tween.checkActiveTweens = function() {
	if(feffects.Tween._aTweens.head == null) {
		if(feffects.Tween._timer != null) {
			feffects.Tween._timer.stop();
			feffects.Tween._timer = null;
		}
		feffects.Tween._isTweening = false;
	}
}
feffects.Tween.getActiveTweens = function() {
	return feffects.Tween._aTweens;
}
feffects.Tween.getPausedTweens = function() {
	return feffects.Tween._aPaused;
}
feffects.Tween.setTweenPaused = function(tween) {
	feffects.Tween._aPaused.add(tween);
	feffects.Tween._aTweens.remove(tween);
	feffects.Tween.checkActiveTweens();
}
feffects.Tween.setTweenActive = function(tween) {
	feffects.Tween._aTweens.add(tween);
	feffects.Tween._aPaused.remove(tween);
	if(!feffects.Tween._isTweening) {
		feffects.Tween._timer = new haxe.Timer(feffects.Tween.INTERVAL);
		feffects.Tween._timer.run = feffects.Tween.cb_tick;
		feffects.Tween._isTweening = true;
		feffects.Tween.cb_tick();
	}
}
feffects.Tween.cb_tick = function() {
	var $it0 = feffects.Tween._aTweens.iterator();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		i.doInterval();
	}
}
feffects.Tween.easingEquation = function(t,b,c,d) {
	return c / 2 * (Math.sin(Math.PI * (t / d - 0.5)) + 1) + b;
}
feffects.Tween.prototype = {
	getStamp: function() {
		return new Date().getTime();
	}
	,getCurVal: function(curTime) {
		return this._easingF(curTime,this._initVal,this._endVal - this._initVal,this.duration);
	}
	,doInterval: function() {
		var stamp = new Date().getTime();
		var curTime = 0;
		if(this.isReversed) curTime = this._reverseTime * 2 - stamp - this._startTime + this._offsetTime; else curTime = stamp - this._startTime + this._offsetTime;
		var curVal = this._easingF(curTime,this._initVal,this._endVal - this._initVal,this.duration);
		if(curTime >= this.duration || curTime < 0) this.stop(true); else this._onUpdate(curVal);
		this.position = curTime;
	}
	,setEasing: function(f) {
		this._easingF = f != null?f:feffects.Tween.easingEquation;
		return this;
	}
	,onFinish: function(f) {
		this._onFinish = f != null?f:function() {
		};
		return this;
	}
	,onUpdate: function(f) {
		this._onUpdate = f != null?f:function(_) {
		};
		return this;
	}
	,finish: function() {
		this._onUpdate(this.isReversed?this._initVal:this._endVal);
		this._onFinish();
	}
	,stop: function(doFinish) {
		if(doFinish == null) doFinish = false;
		if(this.isPaused) feffects.Tween.removePausedTween(this); else if(this.isPlaying) feffects.Tween.removeActiveTween(this);
		this.isPaused = false;
		this.isPlaying = false;
		if(doFinish) this.finish();
	}
	,reverse: function() {
		if(!this.isPlaying) return;
		this.isReversed = !this.isReversed;
		if(!this.isReversed) this._startTime += (new Date().getTime() - this._reverseTime) * 2;
		this._reverseTime = new Date().getTime();
	}
	,seek: function(ms) {
		this._offsetTime = ms < this.duration?ms:this.duration;
		return this;
	}
	,resume: function() {
		if(!this.isPaused || this.isPlaying) return;
		this._startTime += new Date().getTime() - this._pauseTime;
		this._reverseTime += new Date().getTime() - this._pauseTime;
		this.isPlaying = true;
		this.isPaused = false;
		feffects.Tween.setTweenActive(this);
	}
	,pause: function() {
		if(!this.isPlaying || this.isPaused) return;
		this._pauseTime = new Date().getTime();
		this.isPlaying = false;
		this.isPaused = true;
		feffects.Tween.setTweenPaused(this);
	}
	,start: function(position) {
		if(position == null) position = 0;
		this._startTime = new Date().getTime();
		this._reverseTime = new Date().getTime();
		this.seek(position);
		if(this.isPaused) feffects.Tween.removePausedTween(this);
		this.isPlaying = true;
		this.isPaused = false;
		feffects.Tween.addTween(this);
		if(this.duration == 0 || position >= this.duration) this.stop(true);
	}
}
feffects.TweenProperty = function(target,prop,value,duration,easing,autostart,onFinish) {
	if(autostart == null) autostart = false;
	this.target = target;
	this.property = prop;
	feffects.Tween.call(this,Reflect.getProperty(target,this.property),value,duration,easing,autostart,$bind(this,this.__onUpdate),onFinish);
};
feffects.TweenProperty.__super__ = feffects.Tween;
feffects.TweenProperty.prototype = $extend(feffects.Tween.prototype,{
	__onUpdate: function(n) {
		Reflect.setProperty(this.target,this.property,n);
	}
});
feffects.easing = {}
feffects.easing.Back = function() { }
feffects.easing.Back.easeIn = function(t,b,c,d) {
	return c * (t /= d) * t * (2.70158 * t - 1.70158) + b;
}
feffects.easing.Back.easeOut = function(t,b,c,d) {
	return c * ((t = t / d - 1) * t * (2.70158 * t + 1.70158) + 1) + b;
}
feffects.easing.Back.easeInOut = function(t,b,c,d) {
	var s = 1.70158;
	if((t /= d * 0.5) < 1) return c * 0.5 * (t * t * (((s *= 1.525) + 1) * t - s)) + b; else return c * 0.5 * ((t -= 2) * t * (((s *= 1.525) + 1) * t + s) + 2) + b;
}
feffects.easing.Bounce = function() { }
feffects.easing.Bounce.easeOut = function(t,b,c,d) {
	if((t /= d) < 1 / 2.75) return c * (7.5625 * t * t) + b; else if(t < 2 / 2.75) return c * (7.5625 * (t -= 1.5 / 2.75) * t + .75) + b; else if(t < 2.5 / 2.75) return c * (7.5625 * (t -= 2.25 / 2.75) * t + .9375) + b; else return c * (7.5625 * (t -= 2.625 / 2.75) * t + .984375) + b;
}
feffects.easing.Bounce.easeIn = function(t,b,c,d) {
	return c - feffects.easing.Bounce.easeOut(d - t,0,c,d) + b;
}
feffects.easing.Bounce.easeInOut = function(t,b,c,d) {
	if(t < d * 0.5) return (c - feffects.easing.Bounce.easeOut(d - t * 2,0,c,d)) * .5 + b; else return feffects.easing.Bounce.easeOut(t * 2 - d,0,c,d) * .5 + c * .5 + b;
}
feffects.easing.Circ = function() { }
feffects.easing.Circ.easeIn = function(t,b,c,d) {
	return -c * (Math.sqrt(1 - (t /= d) * t) - 1) + b;
}
feffects.easing.Circ.easeOut = function(t,b,c,d) {
	return c * Math.sqrt(1 - (t = t / d - 1) * t) + b;
}
feffects.easing.Circ.easeInOut = function(t,b,c,d) {
	if((t /= d * 0.5) < 1) return -c * 0.5 * (Math.sqrt(1 - t * t) - 1) + b; else return c * 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1) + b;
}
feffects.easing.Cubic = function() { }
feffects.easing.Cubic.easeIn = function(t,b,c,d) {
	return c * (t /= d) * t * t + b;
}
feffects.easing.Cubic.easeOut = function(t,b,c,d) {
	return c * ((t = t / d - 1) * t * t + 1) + b;
}
feffects.easing.Cubic.easeInOut = function(t,b,c,d) {
	if((t /= d * 0.5) < 1) return c * 0.5 * t * t * t + b; else return c * 0.5 * ((t -= 2) * t * t + 2) + b;
}
feffects.easing.Elastic = function() { }
feffects.easing.Elastic.easeIn = function(t,b,c,d) {
	if(t == 0) return b;
	if((t /= d) == 1) return b + c; else {
		var p = d * .3;
		var s = p * 0.25;
		return -(c * Math.pow(2,10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
	}
}
feffects.easing.Elastic.easeOut = function(t,b,c,d) {
	if(t == 0) return b; else if((t /= d) == 1) return b + c; else {
		var p = d * .3;
		var s = p * 0.25;
		return c * Math.pow(2,-10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
	}
}
feffects.easing.Elastic.easeInOut = function(t,b,c,d) {
	if(t == 0) return b; else if((t /= d / 2) == 2) return b + c; else {
		var p = d * (.3 * 1.5);
		var s = p * 0.25;
		if(t < 1) return -0.5 * (c * Math.pow(2,10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b; else return c * Math.pow(2,-10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p) * .5 + c + b;
	}
}
feffects.easing.Expo = function() { }
feffects.easing.Expo.easeIn = function(t,b,c,d) {
	return t == 0?b:c * Math.pow(2,10 * (t / d - 1)) + b;
}
feffects.easing.Expo.easeOut = function(t,b,c,d) {
	return t == d?b + c:c * (-Math.pow(2,-10 * t / d) + 1) + b;
}
feffects.easing.Expo.easeInOut = function(t,b,c,d) {
	if(t == 0) return b; else if(t == d) return b + c; else if((t /= d / 2) < 1) return c * 0.5 * Math.pow(2,10 * (t - 1)) + b; else return c * 0.5 * (-Math.pow(2,-10 * --t) + 2) + b;
}
feffects.easing.Linear = function() { }
feffects.easing.Linear.easeNone = function(t,b,c,d) {
	return c * t / d + b;
}
feffects.easing.Linear.easeIn = function(t,b,c,d) {
	return c * t / d + b;
}
feffects.easing.Linear.easeOut = function(t,b,c,d) {
	return c * t / d + b;
}
feffects.easing.Linear.easeInOut = function(t,b,c,d) {
	return c * t / d + b;
}
feffects.easing.Quad = function() { }
feffects.easing.Quad.easeIn = function(t,b,c,d) {
	return c * (t /= d) * t + b;
}
feffects.easing.Quad.easeOut = function(t,b,c,d) {
	return -c * (t /= d) * (t - 2) + b;
}
feffects.easing.Quad.easeInOut = function(t,b,c,d) {
	if((t /= d * 0.5) < 1) return c * 0.5 * t * t + b; else return -c * 0.5 * (--t * (t - 2) - 1) + b;
}
feffects.easing.Quart = function() { }
feffects.easing.Quart.easeIn = function(t,b,c,d) {
	return c * (t /= d) * t * t * t + b;
}
feffects.easing.Quart.easeOut = function(t,b,c,d) {
	return -c * ((t = t / d - 1) * t * t * t - 1) + b;
}
feffects.easing.Quart.easeInOut = function(t,b,c,d) {
	if((t /= d * 0.5) < 1) return c * 0.5 * t * t * t * t + b; else return -c * 0.5 * ((t -= 2) * t * t * t - 2) + b;
}
feffects.easing.Quint = function() { }
feffects.easing.Quint.easeIn = function(t,b,c,d) {
	return c * (t /= d) * t * t * t * t + b;
}
feffects.easing.Quint.easeOut = function(t,b,c,d) {
	return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
}
feffects.easing.Quint.easeInOut = function(t,b,c,d) {
	if((t /= d * 0.5) < 1) return c * 0.5 * t * t * t * t * t + b; else return c * 0.5 * ((t -= 2) * t * t * t * t + 2) + b;
}
feffects.easing.Sine = function() { }
feffects.easing.Sine.easeIn = function(t,b,c,d) {
	return -c * Math.cos(t / d * (Math.PI * 0.5)) + c + b;
}
feffects.easing.Sine.easeOut = function(t,b,c,d) {
	return c * Math.sin(t / d * (Math.PI * 0.5)) + b;
}
feffects.easing.Sine.easeInOut = function(t,b,c,d) {
	return -c * 0.5 * (Math.cos(Math.PI * t / d) - 1) + b;
}
haxe.Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe.Timer.delay = function(f,time_ms) {
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	};
	return t;
}
haxe.Timer.prototype = {
	run: function() {
		console.log("run");
	}
	,stop: function() {
		if(this.id == null) return;
		clearInterval(this.id);
		this.id = null;
	}
}
haxe.ds.FastCell = function(elt,next) {
	this.elt = elt;
	this.next = next;
};
var js = {}
js.Browser = function() { }
var $_;
function $bind(o,m) { var f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; return f; };
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
feffects.Tween._aTweens = new haxe.ds.GenericStack();
feffects.Tween._aPaused = new haxe.ds.GenericStack();
feffects.Tween.INTERVAL = 10;
feffects.Tween.DEFAULT_EASING = feffects.Tween.easingEquation;
js.Browser.document = typeof window != "undefined" ? window.document : null;
Main.main();
})();
