// MqttException.d

class MqttException : Exception {
	private int reasonCode;

	this() {
		this(-1);
	}

	this (int reasonCode) {
		super("MQTT Exception");
		this.reasonCode = reasonCode;
	}

	int getReasonCode() { return reasonCode; }
}
