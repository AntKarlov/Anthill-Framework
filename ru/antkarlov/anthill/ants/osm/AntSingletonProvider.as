package ru.antkarlov.anthill.ants.osm
{
	
	public class AntSingletonProvider extends Object
	{
		private var _componentClass:Class;
		private var _instance:*;
		
		public function AntSingletonProvider(aClass:Class)
		{
			super();
			_componentClass = aClass;
		}
		
		//---------------------------------------
		// IComponentProvider Implementation
		//---------------------------------------
		
		//import ru.antkarlov.anthill.ants.osm.IComponentProvider;
		public function get component():*
		{
			if (_instance == null)
			{
				_instance = new _componentClass();
			}
			
			return _instance;
		}
		
		public function get identifier():*
		{
			return component;
		}
	
	}

}