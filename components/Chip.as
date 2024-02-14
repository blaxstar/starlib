package net.blaxstar.starlib.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import net.blaxstar.starlib.style.Style;

  public class Chip extends Component {
    private const MIN_WIDTH:uint = 50;
    private const MIN_HEIGHT:Number = 30;
    private const MAX_WIDTH:Number = 40;

    private var _chip_surface:Sprite;
    private var _chip_label:PlainText;
    private var _close_button:Button;
    private var _layout_box:HorizontalBox;
    private var _label_text:String;
    private var _data:Object;
    private var _corner_radius:Number;

    public function Chip(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = 'CHIP', data:Object = null) {
      _label_text = label;
      _data = data;
      super(parent, xpos, ypos);
    }

    override public function init():void {
      _layout_box = new HorizontalBox();
      _close_button = new Button();
      _chip_label = new PlainText();
      _chip_surface = new Sprite();

      _width_ = MIN_WIDTH;
      _height_ = MIN_HEIGHT;
      _corner_radius = _height_ / 2;
      super.init();
    }

    override public function add_children():void {
      _layout_box.spacing = 10;

      addChild(_chip_surface);
      addChild(_layout_box);
      draw_surface();
      draw_icon();
      draw_label();

      apply_shadow();
      setChildIndex(_chip_surface, 0);
      super.add_children();
    }

    private function draw_icon():void {
      _close_button.icon = Icon.CLOSE;
      _close_button.get_icon().set_color('#' + Style.TEXT.value.toString(16));
      _close_button.set_size(16, 16);
      _close_button.on_click.add(remove_chip);
      addChild(_close_button);
    }

    private function remove_chip(e:MouseEvent):void {
      parent.removeChild(this);
      destroy();
    }

    private function draw_label():void {
      _chip_label.text = _label_text;
      _chip_label.width = MAX_WIDTH;
      _chip_label.color = Style.TEXT.value;

      _layout_box.addChild(_chip_label);
    }

    private function draw_surface():void {
      var g:Graphics = _chip_surface.graphics;
      g.beginFill(Style.SECONDARY.value);
      g.drawRoundRectComplex(0, 0, _width_ + PADDING, _height_, _corner_radius, _corner_radius, _corner_radius, _corner_radius);
      g.endFill();
    }

    override public function draw(e:Event = null):void {

      _layout_box.alignment = HorizontalBox.CENTER;
      _width_ = _layout_box.width;
      _layout_box.x = PADDING;
      _layout_box.y = 5;

      draw_surface();
      draw_label();
      super.draw();
    }
  }
}
