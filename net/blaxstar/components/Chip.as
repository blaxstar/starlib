package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import net.blaxstar.style.Style;

  public class Chip extends Component {
    private const MIN_WIDTH:uint = 50;
    private const MIN_HEIGHT:Number = 30;
    private const MAX_WIDTH:Number = 40;

    private var _chipSurface:Sprite;
    private var _chipLabel:PlainText;
    private var _closeButton:Button;
    private var _layoutBox:HorizontalBox;
    private var _labelText:String;
    private var _data:Object;
    private var _cornerRadius:Number;

    public function Chip(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = 'CHIP', data:Object = null) {
      _labelText = label;
      _data = data;
      super(parent, xpos, ypos);
    }

    override public function init():void {
      _width_ = MIN_WIDTH;
      _height_ = MIN_HEIGHT;
      _cornerRadius = _height_ / 2;
      super.init();
    }

    override public function addChildren():void {
      drawSurface();
      _layoutBox = new HorizontalBox(this);
      _layoutBox.spacing = 10;
      addChild(_chipSurface);
      drawIcon();
      drawLabel();

      applyShadow();
      setChildIndex(_chipSurface, 0);
      super.addChildren();
    }

    private function drawIcon():void {
      _closeButton ||= new Button(_layoutBox, 0, 0);
      _closeButton.icon = Icon.CLOSE;
      _closeButton.getIcon().setColor('#' + Style.TEXT.value.toString(16));
      _closeButton.setSize(16, 16);
      _closeButton.on_click.add(removeChip);
    }

    private function removeChip(e:MouseEvent):void {
      parent.removeChild(this);
      destroy(e);
    }

    private function drawLabel():void {
      _chipLabel ||= new PlainText(_layoutBox, 0, 0, _labelText);
      _chipLabel.width = MAX_WIDTH;
      _chipLabel.color = Style.TEXT.value;
    }

    private function drawSurface():void {
      _chipSurface ||= new Sprite();
      var g:Graphics = _chipSurface.graphics;
      g.beginFill(Style.SECONDARY.value);
      g.drawRoundRectComplex(0, 0, _width_ + PADDING, _height_, _cornerRadius, _cornerRadius, _cornerRadius, _cornerRadius);
      g.endFill();
    }

    override public function draw(e:Event = null):void {

      _layoutBox.alignment = HorizontalBox.CENTER;
      _width_ = _layoutBox.width;
      drawSurface();
      drawLabel();
      _layoutBox.x = PADDING;
      _layoutBox.y = 5;
      super.draw();
    }
  }
}
