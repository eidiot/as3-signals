package org.osflash.signals
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	/**
	 * Signal dispatches events to multiple listeners.
	 * It is inspired by C# events and delegates, and by
	 * <a target="_top" href="http://en.wikipedia.org/wiki/Signals_and_slots">signals and slots</a>
	 * in Qt.
	 * A Signal adds event dispatching functionality through composition and interfaces,
	 * rather than inheriting from a dispatcher.
	 * <br/><br/>
	 * Project home: <a target="_top" href="http://github.com/robertpenner/as3-signals/">http://github.com/robertpenner/as3-signals/</a>
	 */
	public class FreeSignalBase implements ISignal
	{
		protected var _valueClasses:Array;		// of Class
		protected var listeners:Array;			// of Function
		protected var onceListeners:Dictionary;	// of Function
		protected var listenersNeedCloning:Boolean = false;

		/**
		 * Super constructor for FreeSignals.
		 * FreeSignal implemnets ISignal interface as Signal.
		 * But not implements IDispatcher interface.
		 * Instead, every FreeSignal has own dispatch() method with different parameters.
		 * So that you know what value object you need to pass when dispatch one FreeSignal,
		 * and in the handler function you know what you can get.
		 */
		public function FreeSignalBase()
		{
			_valueClasses = [];
			listeners = [];
			onceListeners = new Dictionary();
		}

		/** @inheritDoc */
		public function get valueClasses() : Array { return _valueClasses; }

		/** @inheritDoc */
		public function get numListeners() : uint { return listeners.length; }

		/** @inheritDoc */
		public function add(listener:Function) : Function
		{
			registerListener(listener);
			return listener;
		}

		/** @inheritDoc */
		public function addOnce(listener:Function) : Function
		{
			registerListener(listener, true);
			return listener;;
		}

		/** @inheritDoc */
		public function remove(listener:Function) : Function
		{
			var index:int = listeners.indexOf(listener);
			if (index == -1) return listener;
			if (listenersNeedCloning)
			{
				listeners = listeners.slice();
				listenersNeedCloning = false;
			}
			listeners.splice(index, 1);
			delete onceListeners[listener];
			return listener;
		}

		public function removeAll():void
		{
			// Looping backwards is more efficient when removing array items.
			for (var i:uint = listeners.length; i--; )
			{
				remove(listeners[i] as Function);
			}
		}

		protected function registerListener(listener:Function, once:Boolean = false):void
		{
			// If there are no previous listeners, add the first one as quickly as possible.
			if (!listeners.length)
			{
				listeners[0] = listener;
				if (once) onceListeners[listener] = true;
				return;
			}

			if (listeners.indexOf(listener) >= 0)
			{
				// If the listener was previously added, definitely don't add it again.
				// But throw an exception in some cases, as the error messages explain.
				if (onceListeners[listener] && !once)
				{
					throw new IllegalOperationError('You cannot addOnce() then add() the same listener without removing the relationship first.');
				}
				else if (!onceListeners[listener] && once)
				{
					throw new IllegalOperationError('You cannot add() then addOnce() the same listener without removing the relationship first.');
				}
				// Listener was already added, so do nothing.
				return;
			}

			if (listenersNeedCloning)
			{
				listeners = listeners.slice();
				listenersNeedCloning = false;
			}

			// Faster than push().
			listeners[listeners.length] = listener;
			if (once) onceListeners[listener] = true;
		}

		/**
		 * Call this function in the subclasses' dispatch() method.
		 */
		protected function doDispatch():void
		{
			if (!listeners.length) return;

			// During a dispatch, add() and remove() should clone listeners array instead of modifying it.
			listenersNeedCloning = true;

			for each (var listener:Function in listeners)
			{
				if (onceListeners[listener]) remove(listener);
				if (listener.length == 0)
				{
					listener();
				}
				else
				{
					listener(this);
				}
			}
			listenersNeedCloning = false;
		}
	}
}