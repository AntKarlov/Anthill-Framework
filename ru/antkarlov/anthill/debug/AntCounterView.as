package ru.antkarlov.anthill.debug
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.GridFitType;
	import flash.text.AntiAliasType;
	
	/**
	 * Реализация простого отображения счетчика для какого-либо вида данных.
	 * Используется только для отладочных инструментов Anthill.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  14.01.2015
	 */
	public class AntCounterView extends Sprite
	{
		private var _tfTitle:TextField;
		private var _tfValue:TextField;
		private var _tfSign:TextField;
		
		/**
		 * @private
		 */
		public function AntCounterView(aParent:DisplayObjectContainer = null, aX:int = 0, aY:int = 0, 
			aTitle:String = "title", aSign:String = "")
		{
			super();
			
			_tfTitle = AntTextHelper.makeLabel(this, 0, 0, aTitle, "left", "systemSmall", 0xe5dbc6);		
			_tfSign =  AntTextHelper.makeLabel(this, 0, 9, aSign, "left", "systemSmall", 0x8a816f);
			_tfValue =  AntTextHelper.makeLabel(this, 0, 5, "0", "left", "system", 0xe5dbc6);
			
			x = aX;
			y = aY;
			
			if (aParent != null)
			{
				aParent.addChild(this);
			}
		}
		
		/**
		 * @private
		 */
		public function destroy():void
		{
			removeChild(_tfTitle);
			_tfTitle = null;
			
			removeChild(_tfValue);
			_tfValue = null;
			
			removeChild(_tfSign);
			_tfSign = null;
		}
				
		/**
		 * @private
		 */
		public function get text():String { return _tfValue.text; }
		public function set text(aValue:String):void
		{
			_tfValue.text = aValue;
			_tfSign.x = _tfValue.textWidth + 2;
		}

	}

}