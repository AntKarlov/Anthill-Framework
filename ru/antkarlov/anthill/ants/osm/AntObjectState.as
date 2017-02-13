package ru.antkarlov.anthill.ants.osm
{
	import flash.utils.Dictionary;
	
	public class AntObjectState extends Object
	{
		internal var _providers:Dictionary;
		
		public function AntObjectState()
		{
			super();
			_providers = new Dictionary();
		}
		
		public function add(aClass:Class):AntComponentMapping
		{
			return new AntComponentMapping(this, aClass);
		}
		
		public function get(aClass:Class):IComponentProvider
		{
			return _providers[aClass];
		}
		
		public function has(aClass:Class):Boolean
		{
			return _providers[aClass] != null;
		}
	
	}

}