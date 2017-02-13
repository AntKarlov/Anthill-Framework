package ru.antkarlov.anthill.plugins.box2d.joints
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.plugins.box2d.*;
	
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Common.Math.b2Vec2;
	
	/**
	 * Класс реализующий возможность создания соеденения между физическим телом и произвольной точкой.
	 * Данный джоинт хорошо подходит для реализации перетаскивания физических тел курсором мыши.
	 * 
	 * <p>Пример использования:</p>
	 * 
	 * <listing>
	 *	var _mouseJoint:AntBox2DMouseJoint = new AntBox2DMouseJoint();
	 *	//..
	 *	// В методе update() для состояния..
	 * 	var p:AntPoint = AntG.mouse.getWorldPosition();
	 * 	// Если нажата кнопка мыши.
	 *	if (AntG.mouse.isPressed())
	 *	{
	 * 		// Если попали в тело.
	 *		var b:AntBox2DBody = _physics.getBodyByPosition(p.x, p.y);
	 *		if (b != null)
	 *		{
	 * 			// Инициализируем соеденение.
	 *			_mouseJoint.create(p.x, p.y, null, b);
	 *		}
	 *	}
	 * 	// Если кнопка мыши была отпущена и соеденение было создано ранее.
	 *	else if (AntG.mouse.isReleased() && _mouseJoint.exists)
	 *	{
	 *		_mouseJoint.kill();
	 *	}
	 *	
	 * 	// Если соеденение существует, обновляем его положение.
	 *	if (_mouseJoint.exists)
	 *	{
	 *		_mouseJoint.x = p.x;
	 *		_mouseJoint.y = p.y;
	 *		_mouseJoint.update();
	 *	}
	 * </listing>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  24.09.2013
	 */
	public class AntBox2DMouseJoint extends AntBox2DBasicJoint
	{
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Оригинальные настройки соеденения для Box2D.
		 * @default    b2MouseJointDef
		 */
		protected var _jointDef:b2MouseJointDef;
		
		/**
		 * Указатель на оригинальное соеденение для Box2D.
		 * @default    null
		 */
		protected var _joint:b2MouseJoint;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DMouseJoint(aManager:AntBox2DManager = null)
		{
			super(aManager);
			_jointDef = new b2MouseJointDef();
			_jointDef.maxForce = 1000;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			if (_joint != null && _manager != null)
			{
				_box2dVec.x = x / _manager.scale;
				_box2dVec.y = y / _manager.scale;
				_joint.SetTarget(_box2dVec);
			}
			
			super.update();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function create(aBodyA:AntBox2DBody, aBodyB:AntBox2DBody):void
		{
			if (_manager == null || (_manager != null && _manager.box2dWorld == null))
			{
				AntG.log("Warning: Can't to create AntBox2DMouseJoint. First need to initialize AntBox2DManager!", "error");
				return;
			}
			
			var haveBodyA:Boolean = (aBodyA != null);
			var haveBodyB:Boolean = (aBodyB != null);
			
			if (!haveBodyA && !haveBodyB)
			{
				AntG.log("Warning: Can't create AntBox2DMouseJoint. You must specify at least one existing body.", "error");
				return;
			}
			
			createOriginal((haveBodyA) ? aBodyA.box2dBody : null, (haveBodyB) ? aBodyB.box2dBody : null);
		}

		/**
		 * @inheritDoc
		 */
		override public function createOriginal(aBodyA:b2Body, aBodyB:b2Body):void
		{
			if (_manager == null || (_manager != null && _manager.box2dWorld == null))
			{
				AntG.log("Warning: Can't to create AntBox2DMouseJoint. First need to initialize AntBox2DManager!", "error");
				return;
			}
			
			_jointDef.bodyA = (aBodyA == null) ? _manager.box2dWorld.GetGroundBody() : aBodyA;
			_jointDef.bodyB = (aBodyB == null) ? _manager.box2dWorld.GetGroundBody() : aBodyB;
			_jointDef.target.Set(x / _manager.scale, y / _manager.scale);
			_joint = _manager.box2dWorld.CreateJoint(_jointDef) as b2MouseJoint;
			
			reset(x, y);
			revive();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			kill();
			_jointDef = null;
			_joint = null;
			super.destroy();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function kill():void
		{
			if (_manager != null && _manager.box2dWorld != null)
			{
				if (_joint != null)
				{
					_manager.box2dWorld.DestroyJoint(_joint);
					_joint = null;
				}
			}
			
			super.kill();
		}
		
		/**
		 * Извлекает позицию соеденения для тела A.
		 * 
		 * @param	aResult	 Точка куда может быть записан результат работы метода.
		 * @return		Возвращает позицию соеденения для тела A.
		 */
		public function getAnchorA(aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			if (_joint != null)
			{	
				_box2dVec = _joint.GetAnchorA();
				aResult.x = _box2dVec.x * _manager.scale;
				aResult.y = _box2dVec.y * _manager.scale;
			}
			
			return aResult;
		}
		
		/**
		 * Извлекает позицию соеденения для тела B.
		 * 
		 * @param	aResult	 Точка куда может быть записан результат работы метода.
		 * @return		Возвращает позицию соеденения для тела B.
		 */
		public function getAnchorB(aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}

			if (_joint != null)
			{	
				_box2dVec = _joint.GetAnchorB();
				aResult.x = _box2dVec.x * _manager.scale;
				aResult.y = _box2dVec.y * _manager.scale;
			}

			return aResult;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет максимальную силу в ньютонах.
		 */
		public function get maxForce():Number { return _jointDef.maxForce; }
		public function set maxForce(value:Number):void
		{
			_jointDef.maxForce = value;
			if (_joint != null)
			{
				_joint.SetMaxForce(value);
			}
		}
		
		/**
		 * Определяет частоту соеденения в Гц.
		 */
		public function get frequencyHz():Number { return _jointDef.frequencyHz; }
		public function set frequencyHz(value:Number):void
		{
			_jointDef.frequencyHz = value;
			if (_joint != null)
			{
				_joint.SetFrequency(value);
			}
		}
		
		/**
		 * Определяет коэффициент демпфирования.
		 */
		public function get dampingRatio():Number { return _jointDef.dampingRatio; }
		public function set dampingRatio(value:Number):void
		{
			_jointDef.dampingRatio = value;
			if (_joint != null)
			{
				_joint.SetDampingRatio(value);
			}
		}
		
	}

}