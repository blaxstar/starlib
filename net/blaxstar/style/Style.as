package net.blaxstar.style
{
import flash.display.DisplayObjectContainer;
import flash.display.StageAlign;
import flash.display.StageScaleMode;

/**
	 * ...
	 * @author Deron D. (SnaiLegacy)
	 * decamp.deron@gmail.com
	 */
	public class Style 
	{
		// static
		
		static public const LIGHT:uint = 0;
		static public const DARK:uint = 1;
		
		static public var CURRENT_THEME:uint = LIGHT;
		/*
		 * Color that appears most frequently across app screens and components.
		 */
		static public var PRIMARY:RGBA;
		/**
		 * Used for contrast between UI elements (primary color).
		 */
		static public var PRIMARY_LIGHT:RGBA;
		/**
		 * Used for contrast between UI elements (primary color).
		 */
		static public var PRIMARY_DARK:RGBA;
		/**
		 * Optional color that appears sparingly across app screens and components. 
		 * Best used for components like floating action buttons, sliders, switches, 
		 * highlighting selected text, progress bars, links, and headlines.
		 */
		static public var SECONDARY:RGBA;
		
		/**
		 * Used for contrast between UI elements (secondary).
		 */
		static public var SECONDARY_LIGHT:RGBA;
		/**
		 * Used for contrast between UI elements (secondary).
		 */
		static public var SECONDARY_DARK:RGBA;
		
		/**
		 * Color that shows behind scrollable content.
		 */
		static public var BACKGROUND:RGBA;
		/**
		 * Affects surfaces of components, such as cards, sheets, and menus.
		 */
		static public var SURFACE:RGBA;
		/**
		 * Affects the surfaces of components in the "hover" state (usually buttons).
		 */
		static public var GLOW:RGBA;
		/**
		 * Affects components with errors to display.
		 */
		static public var ERROR:RGBA;
		/**
		 * Affects plain text.
		 */
		static public var TEXT:RGBA;
		
		static public function init(theme:uint, main:DisplayObjectContainer):void
		{
			setTheme(theme);
			main.stage.color = BACKGROUND.value;
			main.stage.align = StageAlign.TOP_LEFT;
			main.stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		static public function setTheme(style:uint):void
		{
			switch (style)
			{
				case DARK:
					PRIMARY = new RGBA(50, 50, 50);
					PRIMARY_LIGHT = PRIMARY.tint();
					PRIMARY_DARK = PRIMARY.shade();
					SECONDARY = new RGBA(236, 64, 122);
					SECONDARY_LIGHT = SECONDARY.tint();
					SECONDARY_DARK = SECONDARY.shade();
					BACKGROUND = new RGBA(50, 50, 50);
					SURFACE = new RGBA(50, 50, 50);
					GLOW = BACKGROUND.tint();
					ERROR = new RGBA(176, 0, 32);
					TEXT = new RGBA(250, 250, 250);
					CURRENT_THEME = DARK;
					break;
				case LIGHT:
				default:
					PRIMARY = new RGBA(250, 250, 250);
					PRIMARY_LIGHT = PRIMARY.tint();
					PRIMARY_DARK = PRIMARY.shade();
					SECONDARY = new RGBA(100, 149, 247);
					SECONDARY_LIGHT = SECONDARY.tint();
					SECONDARY_DARK = SECONDARY.shade();
					BACKGROUND = new RGBA(250, 250, 250);
					SURFACE = new RGBA(255, 255, 255);
					GLOW = BACKGROUND.shade();
					ERROR = new RGBA(176, 0, 32);
					TEXT = new RGBA(50, 50, 50);
					CURRENT_THEME = LIGHT;
					break;
			}
		}
	}
}