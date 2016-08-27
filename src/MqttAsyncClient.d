/////////////////////////////////////////////////////////////////////////////
/// @file MqttAsyncClient.d
/// The MQTT async_client class
/// @date Feb 21, 2015
/// @author Frank Pagliughi
/////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
 * Copyright (c) 2015 Frank Pagliughi <fpagliughi@mindspring.com>
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

import MQTTAsync;
import MqttMessage;
import MqttToken;
import MqttException;
import MqttCallback;
import MqttConnectOptions;
import MqttActionListener;

import std.stdio;
import std.string;
import std.conv;
import core.memory;

/////////////////////////////////////////////////////////////////////////////
// Callbacks from the C library.
//
// Note that the Garbage Collector lockdown technique for C callbacks is 
// described in the Phobos documentation, here:
// http://dlang.org/phobos/core_memory.html#.GC.addRoot
//

extern (C)
{
	/**
	 * Callback for when the connection to the broker is lost.
	 * @param context Pointer to the locked down client object.
	 * @param cause
	 */
	void onConnectionLostCallback(void *context, char *cause)
	{
		if (context == null) return;

		GC.removeRoot(context);
		GC.clrAttr(context, GC.BlkAttr.NO_MOVE);
		auto cli = cast(MqttAsyncClient) context;

		//tok.onComplete(MQTTASYNC_SUCCESS);
	}
	/**
	 * Callback from an unsuccessful connection. 
	 * @param context Pointer to the locked down token object.
	 * @param response 
	 */
	int onMessageArrivedCallback(void *context, char *topicName, int topicLen, MQTTAsync_message *msg)
	{
		if (context == null) return 0;

		//GC.removeRoot(context);
		//GC.clrAttr(context, GC.BlkAttr.NO_MOVE);
		auto cli = cast(MqttAsyncClient) context;

		string topic = to!string(topicName);
		auto m = new MqttMessage(*msg);

		cli.onMessageArrived(topic, cast(immutable) m);

		MQTTAsync_freeMessage(&msg);
		MQTTAsync_free(topicName);

		// TODO: Should the user code determine the return value?
		// The Java version does doesn't seem to...
		return (1);
	}

	void onDeliveryCompleteCallback(void *context, MQTTAsync_token token)
	{
		if (context == null) return;

		GC.removeRoot(context);
		GC.clrAttr(context, GC.BlkAttr.NO_MOVE);
		auto cli = cast(MqttAsyncClient) context;

		//tok.onComplete(retCode);
	}
}


/////////////////////////////////////////////////////////////////////////////

class MqttAsyncClient 
{
	private string serverURI;
	private string clientId;
	private MQTTAsync cli = null;
	private MqttCallback callback = null;
	private void chkRet(int ret) {
		if (ret != 0)
			throw new MqttException(ret);
	}

	this(string serverURI, string clientId) {
		this.serverURI = serverURI;
		this.clientId = clientId;
		chkRet(MQTTAsync_create(&cli, std.string.toStringz(serverURI),
					 std.string.toStringz(clientId), MQTTCLIENT_PERSISTENCE_NONE, null));
	}

	private void onMessageArrived(string topic, immutable MqttMessage msg) {
		write("Message Arrived on topic: ");
		write(topic);
		write("  ");
		writeln(cast(string) msg.getPayload());
	}

	MQTTAsync handle() { return cli; }
	bool isOK() { return cli != null; }

	void setCallback(MqttCallback cb) {
		this.callback = cb;
		void* context = cast(void*) this;
		MQTTAsync_setCallbacks(cli, context, &onConnectionLostCallback, 
							   &onMessageArrivedCallback, &onDeliveryCompleteCallback);
	}
	/**
	 * Determines if this client is currently connected to a message 
	 * broker/server. 
	 * @return @em true if if this client is currently connected to a 
	 *  	   server, @em false if not.
	 */
	bool isConnected() { return MQTTAsync_isConnected(cli) != 0; }

	/**
	 * Connects to an MQTT server using the default options.
	 * @return token used to track and wait for the connect to complete. The 
	 *  	   token will be passed to any callback that has been set.
	 * @throw MqttException for non security related problems
	 * @throw security_exception for security related problems
	 */
	MqttToken connect() {
		/*
		auto opt = new MQTTAsync_connectOptions;
		auto tok = new MqttToken(this);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_connect(cli, opt);
		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
		*/
		return connect(null, null, null);
	}

	MqttToken connect(MqttConnectOptions opts, Object userContext, 
					  IMqttActionListener listener) {
		auto opt = (opts is null) ? MQTTAsync_connectOptions() : opts.getOptions();
		auto tok = new MqttToken(this, userContext, listener);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_connect(cli, &opt);
		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
	}

	MqttToken disconnect() {
		auto opt = new MQTTAsync_disconnectOptions;
		auto tok = new MqttToken(this);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_disconnect(cli, opt);
		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
	}

	MqttDeliveryToken publish(string topic, string payload, int qos, bool retained) {
		auto opt = new MQTTAsync_responseOptions;
		MqttDeliveryToken tok = null;

		int ret = MQTTAsync_send(cli, std.string.toStringz(topic),
					cast(int) payload.length, payload.ptr, qos, retained?1:0, opt);

		if (ret != 0)
			throw new MqttException(ret);

		// TODO: Create a message object for this token
		tok = new MqttDeliveryToken(this, null, opt.token);
		return tok;
	}

	MqttDeliveryToken publish(string topic, MqttMessage msg) {
		MQTTAsync_message m = msg.getMessage();
		auto opt = new MQTTAsync_responseOptions;
		MqttDeliveryToken tok = null;

		int ret = MQTTAsync_sendMessage(cli, std.string.toStringz(topic), &m, opt);

		if (ret != 0)
			throw new MqttException(ret);

		tok = new MqttDeliveryToken(this, msg, opt.token);
		return tok;
	}

	MqttToken subscribe(string topic, int qos) {
		return subscribe(topic, qos, null, null);
	}

	MqttToken subscribe(string topic, int qos, Object userContext, 
						IMqttActionListener listener) {
		auto opt = new MQTTAsync_responseOptions;
		auto tok = new MqttToken(this, null, listener);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_subscribe(cli, std.string.toStringz(topic), qos, opt);

		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
	}

	MqttToken unsubscribe(string topic) {
		return unsubscribe(topic, null, null);
	}

	MqttToken unsubscribe(string topic, Object userContext, 
						  IMqttActionListener listener) {
		auto opt = new MQTTAsync_responseOptions;
		auto tok = new MqttToken(this, userContext, listener);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_unsubscribe(cli, std.string.toStringz(topic), opt);

		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
	}

}

