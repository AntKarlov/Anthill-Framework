package ru.antkarlov.anthill.plugins.box2d
{
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Common.Math.b2Math;
	import Box2D.Collision.b2Manifold;
	
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  22.09.2013
	 */
	public class AntBox2DContactListener extends b2ContactListener
	{
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _bodyA:AntBox2DBody;
		private var _bodyB:AntBox2DBody;
		private var _contact:AntBox2DContact;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DContactListener()
		{
			super();
			_bodyA = null;
			_bodyB = null;
			_contact = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void 
		{
			_bodyA = contact.GetFixtureA().GetUserData() as AntBox2DBody;
			_bodyB = contact.GetFixtureB().GetUserData() as AntBox2DBody;
			
			_contact = AntBox2DContact.get();
			_contact.setData(contact);
			
			if (_bodyA.allowPreSolveContacts)
			{
				_bodyA.preSolveContact(_contact);
			}
			
			if (_bodyB.allowPreSolveContacts)
			{
				_bodyB.preSolveContact(_contact);
			}
			
			_contact.resetData();
			AntBox2DContact.set(_contact);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function BeginContact(contact:b2Contact):void
		{
			_bodyA = contact.GetFixtureA().GetUserData() as AntBox2DBody;
			_bodyB = contact.GetFixtureB().GetUserData() as AntBox2DBody;
			
			_contact = AntBox2DContact.get();
			_contact.setData(contact)
			
			if (_bodyA.allowBeginContacts)
			{
				_bodyA.beginContact(_contact);
			}
			
			if (_bodyB.allowBeginContacts)
			{
				_bodyB.beginContact(_contact);
			}
			
			_contact.resetData();
			AntBox2DContact.set(_contact);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function EndContact(contact:b2Contact):void
		{
			_bodyA = contact.GetFixtureA().GetUserData() as AntBox2DBody;
			_bodyB = contact.GetFixtureB().GetUserData() as AntBox2DBody;
			
			_contact = AntBox2DContact.get();
			_contact.setData(contact);
			
			if (_bodyA.allowEndContacts)
			{
				_bodyA.endContact(_contact);
			}
			
			if (_bodyB.allowEndContacts)
			{
				_bodyB.endContact(_contact);
			}
			
			_contact.resetData();
			AntBox2DContact.set(_contact);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			_bodyA = contact.GetFixtureA().GetUserData() as AntBox2DBody;
			_bodyB = contact.GetFixtureB().GetUserData() as AntBox2DBody;
			
			var maxImpulse:Number = 0;
			const n:int = impulse.normalImpulses.length;
			var i:int = 0;
			while (i < n)
			{
				maxImpulse = b2Math.Max(maxImpulse, impulse.normalImpulses[i++]);
			}
			
			_contact = AntBox2DContact.get();
			_contact.setData(contact);
			_contact.impulse = maxImpulse;
			
			if (_bodyA.allowPostSolveContacts)
			{
				_bodyA.postSolveContact(_contact);
			}
			
			if (_bodyB.allowPostSolveContacts)
			{
				_bodyB.postSolveContact(_contact);
			}
			
			_contact.resetData();
			AntBox2DContact.set(_contact);
		}

	}

}