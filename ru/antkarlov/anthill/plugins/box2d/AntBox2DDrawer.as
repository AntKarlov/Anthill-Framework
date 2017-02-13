package ru.antkarlov.anthill.plugins.box2d
{
	import flash.display.Sprite;
	
	import ru.antkarlov.anthill.AntG;
	import ru.antkarlov.anthill.AntCamera;
	
	import Box2D.Dynamics.b2DebugDraw;
	
	
	public class AntBox2DDrawer extends Sprite
	{
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		protected var _camera:AntCamera;
		protected var _drawer:b2DebugDraw;
		protected var _drawShapes:Boolean;
		protected var _drawJoints:Boolean;
		protected var _drawAABB:Boolean;
		protected var _drawPairs:Boolean;
		protected var _drawCenterOfMass:Boolean;
		protected var _drawControllers:Boolean;
		
		protected var _manager:AntBox2DManager;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DDrawer(aManager:AntBox2DManager)
		{
			super();
			
			_camera = null;
			_drawer = new b2DebugDraw();
			_drawer.SetSprite(this);
			_drawer.SetFillAlpha(0.1);
			_drawer.SetLineThickness(1.0);
			_drawer.SetDrawScale(aManager.scale);
			
			_drawShapes = true;
			_drawJoints = true;
			_drawAABB = false;
			_drawPairs = false;
			_drawCenterOfMass = false;
			_drawControllers = false;
			
			_manager = aManager;
			if (_manager.box2dWorld != null)
			{
				_manager.box2dWorld.SetDebugDraw(_drawer);
			}
			else
			{
				AntG.log("Warning: Can't to initialize AntBox2DDrawer. The Box2D world is not initialized.", "error");
			}
			
			applyFlags();
		}
		
		/**
		 * @private
		 */
		public function destroy():void
		{
			if (_manager.box2dWorld != null)
			{
				_manager.box2dWorld.SetDebugDraw(null);
			}
			
			_camera = null;
			_manager = null;
			_drawer = null;
			
			if (this.parent != null)
			{
				this.parent.removeChild(this);
			}
		}
		
		/**
		 * @private
		 */
		public function update():void
		{
			if (_camera != null)
			{
				x = _camera.scroll.x - AntG.widthHalf;
				y = _camera.scroll.y - AntG.heightHalf;
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		protected function applyFlags():void
		{
			(_drawShapes == true) ? _drawer.AppendFlags(b2DebugDraw.e_shapeBit) : _drawer.ClearFlags(b2DebugDraw.e_shapeBit);
			(_drawJoints == true) ? _drawer.AppendFlags(b2DebugDraw.e_jointBit) : _drawer.ClearFlags(b2DebugDraw.e_jointBit);
			(_drawAABB == true) ? _drawer.AppendFlags(b2DebugDraw.e_aabbBit) : _drawer.ClearFlags(b2DebugDraw.e_aabbBit);
			(_drawPairs == true) ? _drawer.AppendFlags(b2DebugDraw.e_pairBit) : _drawer.ClearFlags(b2DebugDraw.e_pairBit);
			(_drawCenterOfMass == true) ? _drawer.AppendFlags(b2DebugDraw.e_centerOfMassBit) : _drawer.ClearFlags(b2DebugDraw.e_centerOfMassBit);
			(_drawControllers == true) ? _drawer.AppendFlags(b2DebugDraw.e_controllerBit) : _drawer.ClearFlags(b2DebugDraw.e_controllerBit);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function get camera():AntCamera { return _camera; }
		public function set camera(value:AntCamera):void
		{
			if (_camera != value)
			{
				if (this.parent != null && this.parent.contains(this))
				{
					this.parent.removeChild(this);
				}
				
				if (value != null)
				{
					value.screenSprite.addChild(this);
				}
				
				update();
				_camera = value;
			}
			
		}
		
		/**
		 * @private
		 */
		public function get drawShapes():Boolean { return _drawShapes; }
		public function set drawShapes(value:Boolean):void 
		{
			if (_drawShapes != value)
			{
				_drawShapes = value;
				applyFlags();
			}
		}
		
		/**
		 * @private
		 */
		public function get drawJoints():Boolean { return _drawJoints; }
		public function set drawJoints(value:Boolean):void 
		{ 
			if (_drawJoints != value)
			{
				_drawJoints = value;
				applyFlags();
			}
		}
		
		/**
		 * @private
		 */
		public function get drawAABB():Boolean { return _drawAABB; }
		public function set drawAABB(value:Boolean):void
		{
			if (_drawAABB != value)
			{
				_drawAABB = value;
				applyFlags();
			}
		}
		
		/**
		 * @private
		 */
		public function get drawPairs():Boolean { return _drawPairs; }
		public function set drawPairs(value:Boolean):void
		{
			if (_drawPairs != value)
			{
				_drawPairs = value;
				applyFlags();
			}
		}
		
		/**
		 * @private
		 */
		public function get drawCenterOfMass():Boolean { return _drawCenterOfMass; }
		public function set drawCenterOfMass(value:Boolean):void
		{
			if (_drawCenterOfMass != value)
			{
				_drawCenterOfMass = value;
				applyFlags();
			}
		}
		
		/**
		 * @private
		 */
		public function get drawControllers():Boolean { return _drawControllers; }
		public function set drawControllers(value:Boolean):void
		{
			if (_drawControllers != value)
			{
				_drawControllers = value;
				applyFlags();
			}
		}

	}

}