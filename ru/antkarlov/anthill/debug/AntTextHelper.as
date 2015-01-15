package ru.antkarlov.anthill.debug
{
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	
	/**
	 * Статический класс помошник для создания текстовых полей и стилей.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  15.01.2015
	 */
	public class AntTextHelper extends Object
	{
		/*
			TODO Добавить метод выделения текста цветом.
		*/
		
		/**
		 * @constructor
		 */
		public function AntTextHelper()
		{
			super();
		}
		
		/**
		 * @private
		 */
		public static function makeLabel(aParent:DisplayObjectContainer = null, aX:int = 0, aY:int = 0, 
			aText:String = "", aAlign:String = "left", aFontName:String = "system", aFontColor:uint = 0xFFFFFF, 
			aFontSize:int = 8):TextField
		{
			var label:TextField = new TextField();
			label.x = aX;
			label.y = aY;
			label.height = 16;
			label.multiline = false;
			label.wordWrap = false;
			label.embedFonts = true;
			label.selectable = false;
			label.antiAliasType = AntiAliasType.NORMAL;
			label.gridFitType = GridFitType.PIXEL;
			label.defaultTextFormat = makeTextFormat(aAlign, aFontName, aFontColor, aFontSize);
			label.text = aText;
			
			if (aParent != null)
			{
				aParent.addChild(label);
			}
			
			return label;
		}
		
		/**
		 * @private
		 */
		public static function makeTextFormat(aAlign:String = "left", aFontName:String = "system", 
			aFontColor:uint = 0xFFFFFF, aFontSize:int = 8):TextFormat
		{
			var textFormat:TextFormat = new TextFormat(aFontName, aFontSize, aFontColor);
			textFormat.align = aAlign;
			return textFormat;
		}
	
	}

}