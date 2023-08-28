package net.blaxstar.networking
{
import flash.system.Security;
import debug.DebugDaemon;

/**
	 * ...
	 * @author Deron D. (SnaiLegacy)
	 * decamp.deron@gmail.com
	 */
	public class NetUtil
	{
		static public function load_policy_file(host:String, port:uint):void
		{
			if (port > 65535)
			{
				return;
			}

			if (host.search("://") > -1)
			{
        try {
          Security.loadPolicyFile(host + ":" + port);
				  Security.loadPolicyFile(host + ":" + port + "/crossdomain.xml");
        } catch (e:Error) {
          DebugDaemon.write_log(e.message, DebugDaemon.ERROR_IO);
        }

			}
			else
			{
        try {
          Security.loadPolicyFile("xmlsocket://" + host + ":" + port);
          Security.loadPolicyFile("https://" + host + ":" + port);

          Security.loadPolicyFile("xmlsocket://" + host + ":" + port + "/crossdomain.xml");
          Security.loadPolicyFile("https://" + host + ":" + port + "/crossdomain.xml");
        } catch (e:Error) {
          DebugDaemon.write_log(e.message, DebugDaemon.ERROR_IO);
        }

			}
		}

	}

}
