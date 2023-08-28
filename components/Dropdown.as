package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import net.blaxstar.style.Style;
  import flash.display.Stage;
  import flash.display.Shape;
  import flash.display.Sprite;

  /**
   * ...
   * @author Deron Decamp
   */
  // TODO (dyxribo, STARLIB-6): implement dropdown component
  public class Dropdown extends Component {
    private const MIN_HEIGHT:uint = 30;
    private const MIN_WIDTH:uint = 150;
    private var _displayLabel:PlainText;
    private var _labelFill:Sprite;
    private var _labelText:String;
    private var _dropdownButton:Button;
    private var _dropdownList:List;
    private var _selectedItem:ListItem;

    public function Dropdown(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, initLabel:String = "Select an Item") {
      _labelText = initLabel;
      super(parent, xpos, ypos);
    }

    /** INTERFACE net.blaxstar.components.IComponent ===================== */

    /**
     * initializes the component by adding all the children and committing the visual changes to be written on the next frame. created to be overridden.
     */
    override public function init():void {
      _width_ = MIN_WIDTH;
      _height_ = MIN_HEIGHT;
      buttonMode = useHandCursor = true;
      super.init();
    }

    /**
     * base method for initializing and adding children of the component. created to be overridden.
     */
    override public function addChildren():void {
      _displayLabel = new PlainText(this, 0, 0, _labelText);
      _displayLabel.width = _width_;

      _dropdownButton = new Button(this, _displayLabel.width, 0);
      _dropdownButton.icon = Icon.EXPAND_DOWN;
      _dropdownButton.setSize(MIN_HEIGHT, MIN_HEIGHT);

      var buttonIcon:Icon = _dropdownButton.getIcon();
      buttonIcon.setColor(Style.TEXT.value.toString(16));
      _dropdownButton.on_click.add(onClick);

      _dropdownList ||= new List(null, 0, _displayLabel.height - 2);
      _dropdownList.visible = false;
      _dropdownList.width = _displayLabel.width;
      _dropdownList.addClickDelegate(onListItemClick);

      super.addChildren();
    }

    private function onListItemClick(e:MouseEvent):void {
      _selectedItem = e.currentTarget as ListItem;
      _labelText = _selectedItem.label;
      draw();
    }

    private function onClick(e:MouseEvent):void {
      if (!_dropdownList.parent) {
        addChild(_dropdownList);
      }
      _dropdownList.visible = !_dropdownList.visible;

      draw();
    }

    /**
     * base method for (re)drawing the component itself. created to be overridden.
     */
    override public function draw(e:Event = null):void {
      if (_dropdownList.visible) {
        _height_ = MIN_HEIGHT + _dropdownList.height;
      }
      else {
        _height_ = MIN_HEIGHT;
      }

      drawBorder();

      if (_dropdownList.numItems == 1) {
        _selectedItem = _dropdownList.getItemAt(0);
      }

      _displayLabel.text = _labelText;

      super.draw(e);
    }

    private function drawBorder():void {
      _labelFill = new Sprite();
      var g:Graphics = _labelFill.graphics;
      g.clear();
      g.lineStyle(2, Style.SECONDARY.value);
      g.beginFill(Style.SURFACE.value, 1);
      g.drawRoundRect(0, 0, _width_, MIN_HEIGHT, 7, 7);
      g.endFill();
      if (!_labelFill.parent) {
        addChild(_labelFill);
        _labelFill.addEventListener(MouseEvent.CLICK, onClick);
      }
      setChildIndex(_labelFill, 0);
    }

    /** END INTERFACE ===================== */
    // public

    public function addListItem(item:ListItem):void {
      _dropdownList.addItem(item);
    }
    public function multiAddListItemByString(...rest):void {

      _dropdownList.multiAddByStringArray(rest);
    }

    // private
    // getters/setters

    public function get value():String {
      return _labelText;
    }
    // delegate functions
  }

}
