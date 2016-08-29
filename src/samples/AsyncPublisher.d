// AsyncPublisher.d
//

/*******************************************************************************
 * Copyright (c) 2015-2016 Frank Pagliughi <fpagliughi@mindspring.com>
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 *    http://www.eclipse.org/legal/epl-v10.html
 * and the Eclipse Distribution License is available at
 *   http://www.eclipse.org/org/documents/edl-v10.php.
 *
 * Contributors:
 *    Frank Pagliughi - initial implementation and documentation
 *******************************************************************************/

// Compile with:
//		gdc-4.9 -o AsyncPublisher AsyncPublisher.d  AsyncClient.d MQTTAsync.d \
// 			~/mqtt/org.eclipse.paho.mqtt.c/build/output/libpaho-mqtt3a.so
//

import MqttAsyncClient;
import MqttConnectOptions;
import MqttWillOptions;
import MqttMessage;
import MqttToken;
import MqttException;
import MqttActionListener;

import std.stdio;
import core.thread;
import core.time;

/////////////////////////////////////////////////////////////////////////////

class ConnListener : IMqttActionListener
{
	override void onSuccess(IMqttToken tok) {
		writeln("  Connection complete");
	}

	override void onFailure(IMqttToken tok, Throwable exc) {
		writeln("  Connection failed");
	}
}

// --------------------------------------------------------------------------

int main()
{
	const int		QOS = 1;
	const string	HOST = "tcp://localhost:1883";
	const string	CLIENT_ID = "AsyncClient.d";

	try {
		writeln("Initializing...");
		auto cli = new MqttAsyncClient(HOST, CLIENT_ID);

		if (!cli.isOK()) {
			writeln("Error creating client.");
			return 1;
		}

		auto willOpts = new MqttWillOptions("hello", "Connection Lost");
		auto connOpts = new MqttConnectOptions(60.seconds());
		connOpts.setWillOptions(willOpts);

		writeln("Connecting...");
		MqttToken tok = cli.connect(connOpts, null, new ConnListener);
		tok.waitForCompletion();
		writeln("...OK");

		writeln("Sending a message...");
		MqttDeliveryToken dtok = cli.publish("hello", "Hello World", QOS, false);
		dtok.waitForCompletion();

		writeln("...OK\nSending another message...");
		auto msg = new MqttMessage("Hi There", QOS);
		dtok = cli.publish("hello", msg);
		dtok.waitForCompletion();

		writeln("...OK\nDisconnecting...");
		stdout.flush();
		tok = cli.disconnect();
		tok.waitForCompletion();
		writeln("...OK\nDone");

		return 0;
	}
	catch (MqttException exc) {
		writeln("MQTT Error: ", exc.getReasonCode());
	}

	return 1;
}

