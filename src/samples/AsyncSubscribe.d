// AsyncPublisher.d
//
// Compile with:
//		gdc-4.9 -o AsyncSubscribe AsyncPublisher.d  AsyncClient.d MQTTAsync.d \
// 			~/mqtt/org.eclipse.paho.mqtt.c/build/output/libpaho-mqtt3a.so
//

import MqttAsyncClient;
import MqttMessage;
import MqttToken;
import MqttException;
import MqttCallback;
import MqttActionListener;

import std.stdio;
import core.thread;

/////////////////////////////////////////////////////////////////////////////

class Callback : MqttCallback
{
	override void connectionLost(const string cause) {}

	override void messageArrived(const string topic, MqttMessage msg) {
		writeln("Callback: Message arrived");
	}

	override void deliveryComplete(MqttDeliveryToken tok) {}
};

/////////////////////////////////////////////////////////////////////////////

int main()
{
	const int QOS = 1;

	try {
		auto cli = new MqttAsyncClient("tcp://localhost:1883", "AsyncSubscribe.d");

		if (!cli.isOK()) {
			writeln("Error creating client.");
			return 1;
		}

		Callback cb;
		cli.setCallback(cb);

		write("Connecting...");
		stdout.flush();
		MqttToken tok = cli.connect();
		tok.waitForCompletion();
		writeln("OK");

		write("Subscribing...");
		stdout.flush();
		tok = cli.subscribe("hello", QOS);
		tok.waitForCompletion();
		writeln("OK");

		int n = 12;
		while (--n > 0) {
			Thread.sleep(dur!("seconds")(5));
		}

		write("\nDisconnecting...");
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

