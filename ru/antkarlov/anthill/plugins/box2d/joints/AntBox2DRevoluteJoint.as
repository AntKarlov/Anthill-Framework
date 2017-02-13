package ru.antkarlov.anthill.plugins.box2d.joints
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.signals.AntSignal;
	import ru.antkarlov.anthill.debug.AntDrawer;
	import ru.antkarlov.anthill.plugins.box2d.*;
	
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Common.Math.b2Vec2;
	
	/**
	 * Класс реализующий возможность создания болтового соеденения между двумя физическими телами.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.09.2013
	 */
	public class AntBox2DRevoluteJoint extends AntBox2DBasicJoint
	{
		public var eventJointBreaks:AntSignal;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Оригинальные настройки соеденения для Box2D.
		 * @default    b2RevoluteJointDef
		 */
		protected var _jointDef:b2RevoluteJointDef;
		
		/**
		 * Указатель на оригинальное соеденение для Box2D.
		 * @default    null
		 */
		protected var _joint:b2RevoluteJoint;
		
		/**
		 * @private
		 */
		protected var _weakness:Number;
		
		/**
		 * @private
		 */
		protected var _reactionForce:AntPoint;
		
		// debug
		private var _limitDraw:Boolean = false;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DRevoluteJoint(aManager:AntBox2DManager = null)
		{
			super(aManager);
			
			eventJointBreaks = new AntSignal(AntBox2DRevoluteJoint);
			
			_jointDef = new b2RevoluteJointDef();
			_joint = null;
			_weakness = 0;
			_reactionForce = new AntPoint();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function copyFrom(aJoint:AntBox2DRevoluteJoint):AntBox2DRevoluteJoint
		{
			enableMotor = aJoint.enableMotor;
			enableLimit = aJoint.enableLimit;
			lowerAngle = aJoint.lowerAngle;
			upperAngle = aJoint.upperAngle;
			weakness = aJoint.weakness;
			x = aJoint.x;
			y = aJoint.y;
			
			return this;
		}
		
		/**
		 * @private
		 */
		public function copy(aResult:AntBox2DRevoluteJoint = null):AntBox2DRevoluteJoint
		{
			if (aResult == null)
			{
				aResult = new AntBox2DRevoluteJoint();
			}
			
			aResult.copyFrom(this);
			return aResult;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			if (_joint != null)
			{
				getAnchorA(_positionA);
				getAnchorB(_positionB);
				
				x = AntMath.lerp(_positionA.x, _positionB.x, 0.5);
				y = AntMath.lerp(_positionA.y, _positionB.y, 0.5);
				
				if (_weakness != 0)
				{
					getReactionForce(_reactionForce);
					if (_reactionForce.length() > _weakness)
					{
						breakJoint();
					}
				}
			}
			
			super.update();
		}
		
		/**
		 * @private
		 */
		/*override public function draw(aCamera:AntCamera):void
		{
			super.draw(aCamera);

			if (_limitDraw && _jointDef.enableLimit)
			{
				var p1:AntPoint = new AntPoint(globalX + 10, globalY);
				AntMath.rotateDeg(p1.x, p1.y, globalX, globalY, AntMath.toDegrees(_jointDef.lowerAngle) - 90, p1);
				
				var p2:AntPoint = new AntPoint(globalX + 10, globalY);
				AntMath.rotateDeg(p2.x, p2.y, globalX, globalY, AntMath.toDegrees(_jointDef.upperAngle) - 90, p2);
				
				p1.x += aCamera.scroll.x * scrollFactorX;
				p1.y += aCamera.scroll.y * scrollFactorY;
				p2.x += aCamera.scroll.x * scrollFactorX;
				p2.y += aCamera.scroll.y * scrollFactorY;
				
				_window(aCamera.buffer);
				AntDrawer.moveTo(globalX + aCamera.scroll.x * scrollFactorX, globalY + aCamera.scroll.y * scrollFactorY);
				AntDrawer.lineTo(p1.x, p1.y, 0x00FFFF);
				AntDrawer.moveTo(globalX + aCamera.scroll.x * scrollFactorX, globalY + aCamera.scroll.y * scrollFactorY);
				AntDrawer.lineTo(p2.x, p2.y, 0x00FFFF);
				
				AntDrawer.drawCircle(p1.x, p1.y, 2, 0x00FFFF);
				AntDrawer.drawCircle(p2.x, p2.y, 2, 0x00FFFF);
			}
		}*/
		
		/**
		 * @inheritDoc
		 */
		override public function create(aBodyA:AntBox2DBody, aBodyB:AntBox2DBody):void
		{
			if (_manager == null || (_manager != null && _manager.box2dWorld == null))
			{
				AntG.log("Warning: Can't to create AntBox2DRevoluteJoint. First need to initialize AntBox2DManager!", "error");
				return;
			}
			
			var haveBodyA:Boolean = (aBodyA != null);
			var haveBodyB:Boolean = (aBodyB != null);
			
			if (!haveBodyA && !haveBodyB)
			{
				AntG.log("Warning: Can't create AntBox2DRevoluteJoint. You must specify at least one existing body.", "error");
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
			
			_bodyA = (aBodyA == null) ? _manager.box2dWorld.GetGroundBody() : aBodyA;
			_bodyB = (aBodyB == null) ? _manager.box2dWorld.GetGroundBody() : aBodyB;
			var anchor:b2Vec2 = new b2Vec2(x / _manager.scale, y / _manager.scale);
			_jointDef.Initialize(_bodyA, _bodyB, anchor);
			_joint = _manager.box2dWorld.CreateJoint(_jointDef) as b2RevoluteJoint;
			
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
		 * Принудительный разрыв соеденения с уведомлением физических тел об этом событии.
		 */
		public function breakJoint():void
		{
			var ab:AntBox2DBody;
			
			ab = _bodyA.GetUserData() as AntBox2DBody;
			if (ab != null)
			{
				ab.jointBreaks(this);
			}
			
			ab = _bodyB.GetUserData() as AntBox2DBody;
			if (ab != null)
			{
				ab.jointBreaks(this);
			}
			
			eventJointBreaks.dispatch(this);
			kill();
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
		 * @return		Возвращает позицию соеденения для тела A.
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
		
		/**
		 * @private
		 */
		public function getReactionForce(aResult:AntPoint = null, aInvDt:Number = 1):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			
			if (_joint != null)
			{
				var reactionForce:b2Vec2 = _joint.GetReactionForce(aInvDt);
				aResult.set(reactionForce.x, reactionForce.y);
			}
			
			return aResult;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает текущую скорость вращаения соеденения радианы в секунду.
		 */
		public function get jointSpeed():Number
		{
			return (_joint != null) ? _joint.GetJointSpeed() : 0;
		}
		
		/**
		 * Возвращает текущую скорость вращения соеденения градусы в секунду.
		 */
		public function get jointSpeedDeg():Number
		{
			return jointSpeed / (Math.PI * 180);
		}
		
		/**
		 * Возвращает текущий угол соеденения в радианах.
		 */
		public function get jointAngle():Number 
		{
			return (_joint != null) ? _joint.GetJointAngle() : 0;
		}
		
		/**
		 * Возвращает текущий угол соеденения в градусах.
		 */
		public function get jointAngleDeg():Number
		{
			return jointAngle / (Math.PI * 180);
		}
		
		/**
		 * Вкл/Выкл мотор для соеденения.
		 */
		public function get enableMotor():Boolean { return _jointDef.enableMotor; }
		public function set enableMotor(value:Boolean):void
		{
			_jointDef.enableMotor = value;
			if (_joint != null)
			{
				_joint.EnableMotor(value);
			}
		}
		
		/**
		 * Определяет скорость вращения для соеденения.
		 */
		public function get motorSpeed():Number { return _jointDef.motorSpeed; }
		public function set motorSpeed(value:Number):void
		{
			_jointDef.motorSpeed = value;
			if (_joint != null)
			{
				_joint.SetMotorSpeed(value);
			}
		}
		
		/**
		 * Определяет силу вращения для соеденения.
		 */
		public function get maxMotorTorque():Number { return _jointDef.maxMotorTorque; }
		public function set maxMotorTorque(value:Number):void
		{
			_jointDef.maxMotorTorque = value;
			if (_joint != null)
			{
				_joint.SetMaxMotorTorque(value);
			}
		}
		
		/**
		 * Вкл/Выкл лимиты для соеденения.
		 */
		public function get enableLimit():Boolean { return _jointDef.enableLimit; }
		public function set enableLimit(value:Boolean):void
		{
			_jointDef.enableLimit = value;
			if (_joint != null)
			{
				_joint.EnableLimit(value);
			}
		}
		
		/**
		 * Определяет минимальный угол вращения в радианах.
		 */
		public function get lowerAngle():Number { return _jointDef.lowerAngle; }
		public function set lowerAngle(value:Number):void
		{
			_jointDef.lowerAngle = value;
			if (_joint != null)
			{
				_joint.SetLimits(_jointDef.lowerAngle, _jointDef.upperAngle);
			}
		}
		
		/**
		 * Определяет максимальный угол вращения в радианах.
		 */
		public function get upperAngle():Number { return _jointDef.upperAngle; }
		public function set upperAngle(value:Number):void
		{
			_jointDef.upperAngle = value;
			if (_joint != null)
			{
				_joint.SetLimits(_jointDef.lowerAngle, _jointDef.upperAngle);
			}
		}
		
		/**
		 * @private
		 */
		public function get weakness():Number { return _weakness; }
		public function set weakness(value:Number):void
		{
			_weakness = value;
		}
		
		/**
		 * @private
		 */
		public function get limitDraw():Boolean { return _limitDraw; }
		public function set limitDraw(value:Boolean):void
		{
			_limitDraw = value;
		}

	}

}