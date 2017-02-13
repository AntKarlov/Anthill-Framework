package ru.antkarlov.anthill.plugins.box2d
{
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2ContactFilter;
	
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  23.09.2013
	 */
	public class AntBox2DContactFilter extends b2ContactFilter
	{
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DContactFilter()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function ShouldCollide(fixtureA:b2Fixture, fixtureB:b2Fixture):Boolean
		{
			return super.ShouldCollide(fixtureA, fixtureB);
		}

	}

}