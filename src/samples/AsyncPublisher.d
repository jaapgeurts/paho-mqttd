// AsyncPublisher.d
//
// Compile with:
//		gdc-4.9 -o AsyncPublisher AsyncPublisher.d  AsyncClient.d MQTTAsync.d \
// 			~/mqtt/org.eclipse.paho.mqtt.c/build/output/libpaho-mqtt3a.so
//

import MqttAsyncClient;
import MqttMessage;
import MqttToken;
import MqttException;
import MqttActionListener;

import std.stdio;
import core.thread;

/////////////////////////////////////////////////////////////////////////////

class ConnListener : IMqttActionListener
{
	override void onSuccess(IMqttToken tok) {
		writeln("Connection complete");
	}

	override void onFailure(IMqttToken tok, Throwable exc) {
		writeln("Connection failed");
	}
}

// --------------------------------------------------------------------------

int main()
{
	const int QOS = 1;

	try {
		auto cli = new MqttAsyncClient("tcp://localhost:1883", "AsyncClient.d");

		if (!cli.isOK()) {
			writeln("Error creating client.");
			return 1;
		}

		write("Connecting...");
		stdout.flush();
		auto connListener = new ConnListener;
		MqttToken tok = cli.connect(null, null, connListener);
		tok.waitForCompletion();
		writeln("OK");

		//Thread.sleep(dur!("seconds")(5));

		write("Sending a message...");
		stdout.flush();
		MqttDeliveryToken dtok = cli.publish("hello", "Hello World", QOS, false);
		dtok.waitForCompletion();

		write("OK\nSending another message...");
		stdout.flush();
		auto msg = new MqttMessage("Hi There", QOS);
		dtok = cli.publish("hello", msg);
		dtok.waitForCompletion();

		write("OK\nDisconnecting...");
		stdout.flush();
		tok = cli.disconnect();
		tok.waitForCompletion();
		writeln("OK\nDone");

		return 0;
	}
	catch (MqttException exc) {
		writeln("MQTT Error: ", exc.getReasonCode());
	}

	return 1;
}

