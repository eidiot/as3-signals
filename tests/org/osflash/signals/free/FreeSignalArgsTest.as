package org.osflash.signals.free
{
	import asunit.asserts.assertEquals;
	import asunit.framework.IAsync;
	public class FreeSignalArgsTest
	{
		[Inject]
		public var async:IAsync;
		public var completed:FreeSignal;

		[Test]
		public function pass_arguments():void
		{
			completed = new FreeSignal(this);
			completed.addOnce(async.add(checkArgs, 10));
			completed.dispatch("a001", "Jim", 1000);
		}

		private function checkArgs(signal:FreeSignal) : void
		{
			assertEquals('target shoud be this', this, signal.target);
			assertEquals('id argument', "a001", signal.id);
			assertEquals('name argument', "Jim", signal.name);
			assertEquals('time argument', 1000, signal.time);
		}
	}
}
import org.osflash.signals.FreeSignalBase;
import org.osflash.signals.free.FreeSignalArgsTest;

internal class FreeSignal extends FreeSignalBase
{
	public var target:FreeSignalArgsTest;
	public var id:String;
	public var name:String;
	public var time:int;

	public function FreeSignal(target:FreeSignalArgsTest)
	{
		this.target = target;
	}

	public function dispatch(id:String, name:String, time:int):void
	{
		this.id = id;
		this.name = name;
		this.time = time;
		doDispatch();
	}
}