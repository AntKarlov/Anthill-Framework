package ru.antkarlov.anthill.ants.osm
{
	
	public class AntClassProvider extends Object implements IComponentProvider
	{
		private var _componentType:Class;
		
		public function AntClassProvider(aClass:Class)
		{
			super();
			_componentType = aClass;
		}
		
		//---------------------------------------
		// IComponentProvider Implementation
		//---------------------------------------
		
		//import ru.antkarlov.anthill.ants.osm.IComponentProvider;
		public function get component():*
		{
			return new _componentType();
		}
		
		public function get identifier():*
		{
			return _componentType;
		}
	
	}

}