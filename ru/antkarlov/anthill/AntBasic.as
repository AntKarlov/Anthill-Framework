package ru.antkarlov.anthill
{
	
	/**
	 * Базовый класс для всех визуальных и не визуальных объектов Anthill.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  26.08.2012
	 */
	public class AntBasic extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Любое пользовательское значение которое может идентифицировать объект.
		 * @default    -1
		 */
		public var tag:int;
		
		/**
		 * Указатель на любые пользовательские данные.
		 * @default    null
		 */
		public var userData:Object;
		
		/**
		 * Определеяет существование объекта. 
		 * Если объект существует то для него вызываются методы <code>update()</code> и <code>draw()</code>.
		 * @default    true
		 */
		public var exists:Boolean;
		
		/**
		 * Определяет активность объекта. 
		 * Если объект не активен <code>active = false</code>, то для такого объекта не будет вызываться метод <code>update()</code>.
		 * @default    true
		 */
		public var active:Boolean;
		
		/**
		 * Определяет видимость объекта.
		 * Если объект невидим <code>visible = false</code>, то для такого объекта не будет вызываться метод <code>draw()</code>.
		 * @default    true
		 */
		public var visible:Boolean;
		
		/**
		 * Определяет жизненый цикл объекта. 
		 * Если объект "мертвый" <code>alive = false</code>, то это значит, что для объекта был вызван метод <code>kill()</code>.
		 * Для воскрешения "мертвого" объекта следует использовать метод <code>revive()</code>.
		 * @default    true
		 */
		public var alive:Boolean;
		
		/**
		 * Указатель на массив камер из <code>AntG.cameras</code>.
		 */
		public var cameras:Array;
		
		/**
		 * Определяет может ли данный объект рисовать свой отладочный образ.
		 * @default    true
		 */
		public var allowDebugDraw:Boolean;
		
		/**
		 * Используется для автоматического подсчета активных объектов. 
		 * Доступ к значению осуществляется через <code>AntG.numOfActive</code>.
		 */
		static internal var _numOfActive:int = 0;
		
		/**
		 * Используется для автоматического подсчета видимых объектов. 
		 * Доступ к значению осуществляется через <code>AntG.numOfVisible</code>.
		 */
		static internal var _numOfVisible:int = 0;
		
		/**
		 * Используется для автоматического подсчета количества объектов видимых камерами.
		 * Доступ к значению осуществляется через <code>AntG.numOnScreen</code>.
		 */
		static internal var _numOnScreen:int = 0;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBasic()
		{
			super();
			
			tag = -1;
			userData = null;
			
			exists = true;
			active = true;
			visible = true;
			alive = true;
			allowDebugDraw = true;
		}
		
		/**
		 * Перекрывайте этот метод чтобы в нем корректно занулять переменные 
		 * и вызывайте этот метод вручную если необходимо уничтожить объект.
		 */
		public function dispose():void
		{
			// ...
		}
		
		/**
		 * Вызывается каждый кадр перед методом <code>update()</code>.
		 */
		public function preUpdate():void
		{
			_numOfActive++;
		}
		
		/**
		 * Вызывается каждый кадр.
		 */
		public function update():void
		{
			// ...
		}
		
		/**
		 * Вызывается каждый кадр сразу после метода <code>update()</code>;
		 */
		public function postUpdate():void
		{
			// ...
		}
		
		/**
		 * Вызывается каждый кадр после метода <code>postUpdate()</code> для отрисовки объекта.
		 */
		public function draw():void
		{
			// ...
		}
		
		/**
		 * Вызывается для рисования отладочной отрисовки.
		 * 
		 * @param	aCamera	 Указатель на камеру в которую необходимо произвести отрисовку.
		 */
		public function debugDraw(aCamera:AntCamera):void
		{
			// ...
		}
		
		/**
		 * Вызывается когда объект необходимо временно "убить".
		 */
		public function kill():void
		{
			exists = false;
			alive = false;
		}
		
		/**
		 * Воскрешает объект после временного "убийства".
		 */
		public function revive():void
		{
			exists = true;
			alive = true;
		}
		
	}

}