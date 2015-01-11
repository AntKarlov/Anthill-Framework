package ru.antkarlov.anthill.ants.osm
{
	
	public class AntMethodProvider extends Object
	{
		private var _method:Function;
		
		public function AntMethodProvider(aMethod:Function)
		{
			super();
			_method = aMethod;
		}
		
		//---------------------------------------
		// IComponentProvider Implementation
		//---------------------------------------
		
		//import ru.antkarlov.anthill.ants.osm.IComponentProvider;
		public function get component():*
		{
			return _method();
		}
		
		public function get identifier():*
		{
			return _method;
		}
		
	}

}