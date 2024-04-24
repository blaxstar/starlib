package net.blaxstar.starlib.components.interfaces
{
  import flash.events.Event;

  public interface IFunctionQueueable {

        function queue_function(func:Function, ... rest):void;
        function check_queue(e:Event):void;

  }
}