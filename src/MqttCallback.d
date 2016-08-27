// MqttCallback.d

import MqttMessage;
import MqttToken;

/////////////////////////////////////////////////////////////////////////////  

/**
 * Provides a mechanism for tracking the completion of an asynchronous 
 * action. 
 */
interface MqttCallback
{
	/**
	 * This method is called when the connection to the server is lost.
	 * @param cause 
	 */
	void connectionLost(const string cause);
	/**
	 * This method is called when a message arrives from the server. 
	 * @param topic
	 * @param msg 
	 */
	void messageArrived(const string topic, MqttMessage msg);
	/**
	 * Called when delivery for a message has been completed, and all 
	 * acknowledgments have been received.
	 * @param token 
	 */
	void deliveryComplete(MqttDeliveryToken tok);
};

