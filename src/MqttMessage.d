// Message.d

import MQTTAsync;
import std.conv;

/////////////////////////////////////////////////////////////////////////////

class MqttMessage
{
	const int DFLT_QOS = 1;

	private MQTTAsync_message msg;
	private blob payload;

//	this(immutable(MQTTAsync_message) msg) immutable {
//		//this.msg = cast(immutable MQTTAsync_message)(msg);
//		payload = cast(blob) msg.payload[0..msg.payloadlen];
//		assert(payload.length == msg.payloadlen);
//
//		this.msg = msg.dup;	//MQTTAsync_message(msg, payload);
//		this.msg.payload = cast(immutable(void)*) payload.ptr;
//		this.msg.payloadlen = cast(int) payload.length;
//	}

	/**
	 * Creates an immutable message with the given payload.
	 */
	this(blob payload) immutable {
		this.msg = immutable MQTTAsync_message(payload);
		this.payload = payload;
	}
	/**
	 * Creates a message from a C library message structure. 
	 * @param msg An MQTT C library message structure. 
	 */
	this(MQTTAsync_message msg) {
		this.msg = msg;
		payload = cast(blob) msg.payload[0..msg.payloadlen];
		assert(payload.length == msg.payloadlen);

		this.msg.payload = cast(immutable(void)*) payload.ptr;
		this.msg.payloadlen = cast(int) payload.length;
	}
	/**
	 * Creates a message object. 
	 * @param payload The payload of the messages.
	 * @param qos The quality of service for the message.
	 * @param retained Whether the message should be retained by the broker.
	 */
	this(blob payload, int qos, bool retained) {
		msg.struct_id = "MQTM";
		msg.struct_version = 0;
		setPayload(payload);
		msg.qos = DFLT_QOS;
		msg.retained = false;
		msg.dup = 0;
		msg.msgid = 0;
	}
	/**
	 * Creates a message object. 
	 * @param payload The payload of the messages.
	 * @param qos The quality of service for the message.
	 */
	this(blob payload, int qos) {
		this(payload, qos, false);
	}
	/**
	 * Creates a message object. 
	 * @param payload The payload of the messages.
	 */
	this(blob payload) {
		this(payload, DFLT_QOS, false);
	}
	/**
	 * Creates a message object. 
	 * @param payload A string to use as the payload of the messages.
	 * @param qos The quality of service for the message.
	 * @param retained Whether the message should be retained by the broker.
	 */
	this(string payload, int qos, bool retained) {
		this(cast(blob) payload, qos, retained);
	}
	/**
	 * Creates a message object. 
	 * @param payload A string to use as the payload of the messages.
	 * @param qos The quality of service for the message.
	 */
	this(string payload, int qos) {
		this(cast(blob) payload, qos, false);
	}
	/**
	 * Creates a message object. 
	 * @param payload A string to use as the payload of the messages.
	 */
	this(string payload) {
		this(cast(blob) payload, DFLT_QOS, false);
	}

	MQTTAsync_message getMessage() { return msg; }
	/**
	 * Clears the payload, resetting it to be empty.
	 */
	void clear_payload() {
		msg.payloadlen = 0;
		msg.payload = null;
		payload = null;
	}
	/**
	 * Gets the payload
	 */
	blob getPayload() immutable { return payload; }
	blob getPayload() { return payload; }
	/**
	 * Returns the quality of service for this message.
	 * @return The quality of service for this message.
	 */
	int getQos() { return msg.qos; }
	/**
	 * Returns whether or not this message might be a duplicate of one which 
	 * has already been received. 
	 * @return true this message might be a duplicate of one which 
	 * has already been received, false otherwise
	 */
	bool isDuplicate() { return msg.dup != 0; }
	/**
	 * Returns whether or not this message should be/was retained by the 
	 * server.
	 * @return true if this message should be/was retained by the 
	 * server, false otherwise.
	 */
	bool isRetained() { return msg.retained != 0; }
	/**
	 * Sets the payload of this message to be the specified string. 
	 * @param payload A string to use as the message payload.
	 */
	void setPayload(blob payload) {
		this.payload = payload;
		msg.payload = cast(immutable(void)*) payload.ptr;
		// TODO: Check length for valid MQTT len?
		msg.payloadlen = cast(int) payload.length;
	}
	/**
	 * Sets the payload of this message to be the specified string. 
	 * @param payload A string to use as the message payload.
	 */
	void setPayload(string payload) {
		setPayload(to!blob(payload));
	}
	/**
	 * Sets the quality of service for this message.
	 * @param qos The quality of service for this message.
	 */
	void setQos(int qos) { //throw(std::invalid_argument) {
		//validate_qos(qos); 
		msg.qos = qos;
	}
	/**
	 * Whether or not the publish message should be retained by the 
	 * messaging engine. 
	 * @param retained 
	 */
	void setRetained(bool retained) { msg.retained = (retained) ? 1 : 0; }
	/**
	 * Returns a string representation of the message payload. 
	 * @return A string representation of the message payload. 
	 */
	string toStr() const { return to!string(payload); }
	/**
	 * Determines if the QOS value is a valid one.
	 * @param qos The QOS value.
	 * @throw std::invalid_argument If the qos value is invalid.
	 */
//	static void validate_qos(int qos) throw(std::invalid_argument) {
//		if (qos < 0 || qos > 2)
//			throw exception(QOS invalid);	//std::invalid_argument("QOS invalid");
//	}
}

