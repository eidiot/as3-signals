package org.osflash.signals.free
{
	import asunit.asserts.assertEquals;
	import asunit.framework.IAsync;

	public class FreeSignalTargetTest
	{
		[Inject]
		public var async:IAsync;

		public var completed:FreeSignal;

		[Test]
		public function target_is_set_in_constructor():void
		{
			completed = new FreeSignal(this);
			completed.addOnce(async.add(checkTarget, 10));
			completed.dispatch();
		}

		private function checkTarget(signal:FreeSignal) : void
		{
			assertEquals('target should be this', this, signal.target);
		}
	}
}
import org.osflash.signals.FreeSignalBase;

internal class FreeSignal extends FreeSignalBase
{
	public var target:Object;
	public function FreeSignal(target:Object)
	{
		this.target = target;
	}
	public function dispatch():void
	{
		doDispatch();
	}
}