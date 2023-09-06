package net.blaxstar.starlib.components {
  import flash.events.Event;

  /**
   * Component interface.
   * provides the 3 methods required for all components.
   * @author Deron Decamp
   */
  public interface IComponent {

    function init():void;

    function add_children():void;

    function draw(e:Event = null):void;
  }

}