package ru.antkarlov.anthill.plugins.box2d.joints
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.plugins.box2d.*;
	
	import Box2D.Dynamics.b2Body;
	import Box2D.Common.Math.b2Vec2;
	
	/**
	 * Базовый класс реализующий общие функции для всех видов соеденений.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.09.2013
	 */
	public class AntBox2DBasicJoint extends AntActor
	{
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на физический менеджер.
		 * @default    null
		 */
		protected var _manager:AntBox2DManager;
		
		/**
		 * Помошник для работы в системе координат Box2D.
		 * @default    b2Vec2
		 */
		protected var _box2dVec:b2Vec2;
		
		/**
		 * Указатель на первое тело с которым связано соеденение.
		 * @default    null
		 */
		protected var _bodyA:b2Body;
		
		/**
		 * Указатель на второе тело с которым связано соеденение.
		 * @default    null
		 */
		protected var _bodyB:b2Body;
		
		/**
		 * Позиция соеденения для первого тела.
		 * @default    AntPoint
		 */
		protected var _positionA:AntPoint;
		
		/**
		 * Позиция соеденения для второго тела.
		 * @default    AntPoint
		 */
		protected var _positionB:AntPoint;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DBasicJoint(aManager:AntBox2DManager = null)
		{
			super();
			
			if (aManager == null)
			{
				var plg:Array = AntG.plugins.get(AntBox2DManager);
				if (plg.length >= 1)
				{
					aManager = plg[0] as AntBox2DManager;
				}
			}
			
			_manager = aManager;
			_box2dVec = new b2Vec2();
			_positionA = new AntPoint();
			_positionB = new AntPoint();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			_manager = null;
			_box2dVec = null;
			_bodyA = null;
			_bodyB = null;
			_positionA = null;
			_positionB = null;
			super.destroy();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Создает соеденение между телами в указанной точке.
		 * 
		 * @param	aX	 Позиция соеденения по горизонтали.
		 * @param	aY	 Позиция соеденения по вертикали.
		 * @param	aBodyA	 Первое тело которое будет соеденено.
		 * @param	aBodyB	 Второе тело которое будет соеденено.
		 */
		public function create(aBodyA:AntBox2DBody, aBodyB:AntBox2DBody):void
		{
			/*
				Данный метод реализуется потомками.
			*/
		}

		/**
		 * Создает соеденение между оригинальными телами Box2D в указанной точке.
		 * 
		 * @param	aX	 Позиция соеденения по горизонтали.
		 * @param	aY	 Позиция соеденения по вертикали.
		 * @param	aBodyA	 Первое тело которое будет соеденено.
		 * @param	aBodyB	 Второе тело которое будет соеденено.
		 */
		public function createOriginal(aBodyA:b2Body, aBodyB:b2Body):void
		{
			/*
				Данный метод реализуется потомками.
			*/
		}

	}

}