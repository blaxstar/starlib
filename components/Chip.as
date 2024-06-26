package net.blaxstar.starlib.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import net.blaxstar.starlib.style.Style;

  public class Chip extends Component {
    private const MIN_WIDTH:uint = 100;
    private const MIN_HEIGHT:Number = 30;

    private var _chip_surface:Shape;
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
      _chip_surface = new Shape();
      
      super.init();
    }

    override public function add_children():void {
      _layout_box.spacing = 10;
      _layout_box.alignment = HorizontalBox.CENTER;
      _layout_box.y = PADDING/2;

      addChild(_chip_surface);
      addChild(_layout_box);
      _layout_box.addChild(_chip_label);
      _layout_box.addChild(_close_button);

      _chip_label.color = Style.TEXT.value;
      draw_label();
      draw_icon();
      draw_surface();
      apply_shadow();
      setChildIndex(_chip_surface, 0);
      _layout_box.addEventListener(Event.RESIZE, draw);
      super.add_children();
    }

    private function draw_icon():void {
      _close_button.icon = Icon.DELETE;
      _close_button.get_icon().set_color(Style.TEXT.to_hex_string());
      _close_button.on_click.add(remove_chip);
      _close_button.set_size(26,28);
    }

    private function remove_chip(e:MouseEvent):void {
      parent.removeChild(this);
      destroy();
    }

    private function draw_label():void {
      _chip_label.text = _label_text;
    }

    private function draw_surface():void {
      _width_ = _layout_box.width + PADDING * 2;
      _height_ = _layout_box.height + PADDING;
      _corner_radius = _height_ / 2;

      var g:Graphics = _chip_surface.graphics;
      g.clear();
      g.beginFill(Style.SECONDARY.value);
      g.drawRoundRectComplex(0, 0, _width_, _height_, _corner_radius, _corner_radius, _corner_radius, _corner_radius);
      g.endFill();
    }

    override public function draw(e:Event = null):void {
      draw_label();
      draw_surface();
      _layout_box.move(PADDING, PADDING / 2);
      super.draw();
    }

    override protected function on_theme_update():void {
      draw_surface();
      _close_button.get_icon().set_color(Style.TEXT.to_hex_string());
    }

    public function get label_string():String {
      return _chip_label.text;
    }

    public function set data(val:Object):void {
      _data = val;
    }

    public function get data():Object {
      return _data;
    }
  }
}
