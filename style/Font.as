package net.blaxstar.starlib.style {
import flash.text.TextFormat;

/**
	 * a class of enumerated font formatting options.
	 * @author Deron D. (decamp.deron@gmail.com)
	 */
	public class Font {
    // embed the default fonts, just simpler this way
		[Embed(source = "fonts/PRODUCT_SANS_REGULAR.TTF", embedAsCFF = "false", fontName = "gsans", mimeType = "application/x-font")]
		protected const GSANS_REGULAR:Class;
		[Embed(source = "fonts/PRODUCT_SANS_BOLD.TTF", embedAsCFF = "false", fontName = "gsans_bold", mimeType = "application/x-font")]
		protected const GSANS_BOLD:Class;

    // formatting options similar to the official mat components
		static public const H1:TextFormat         = new TextFormat(Font.gsans, 96);
		static public const H2:TextFormat         = new TextFormat(Font.gsans, 60);
		static public const H3:TextFormat         = new TextFormat(Font.gsans, 48);
		static public const H4:TextFormat         = new TextFormat(Font.gsans, 34);
		static public const H5:TextFormat         = new TextFormat(Font.gsans, 24);
		static public const H6:TextFormat         = new TextFormat(Font.gsans_bold, 20);
		static public const SUBTITLE_1:TextFormat = new TextFormat(Font.gsans, 16);
		static public const SUBTITLE_2:TextFormat = new TextFormat(Font.gsans_bold, 14);
		static public const BODY_1:TextFormat     = new TextFormat(Font.gsans, 16);
		static public const BODY_2:TextFormat     = new TextFormat(Font.gsans, 14);
		static public const BUTTON:TextFormat     = new TextFormat(Font.gsans, 14);
		static public const CAPTION:TextFormat    = new TextFormat(Font.gsans, 12);
		static public const OVERLINE:TextFormat   = new TextFormat(Font.gsans, 10);
		public static var embed_fonts:Boolean;

    /**
     * setup the defaults for the spacing of each formatting option, and ensure that embedded fonts are being used.
     * @return void
     */
		static public function init():void {
			H1.letterSpacing = -1.5;
			H2.letterSpacing = -0.5;
			H4.letterSpacing = 0.25;
			H6.letterSpacing = 0.15;
			SUBTITLE_1.letterSpacing = 0.15;
			SUBTITLE_2.letterSpacing = 0.1;
			BODY_1.letterSpacing = 0.5;
			BODY_2.letterSpacing = 0.25;
			BUTTON.letterSpacing = 1.25;
			CAPTION.letterSpacing = 0.4;
			OVERLINE.letterSpacing = 1.5;
			embed_fonts = true;
		}
    /**
     * the identifying font name for gsans, as a string.
     * @return font name for gsans.
     */
		static public function get gsans():String {
			return "gsans";
		}
    /**
     * the identifying font name for gsans bold, as a string.
     * @return font name for gsans bold.
     */
		static public function get gsans_bold():String {
			return "gsans_bold";
		}

	}

}
