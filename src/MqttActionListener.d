// MqttActionListener.d

import MqttToken;

/////////////////////////////////////////////////////////////////////////////

/**
 * Implementors of this interface will be notified when an 
 * asynchronous action completes. 
 *  
 * A listener is registered on an MqttToken and a token is
 * associated with an action like connect or publish. When used
 * with tokens on the MqttAsyncClient the listener will be
 * called back on the MQTT client's thread. The listener will be 
 * informed if the action succeeds or fails. It is importantthat 
 * the listener returns control quickly otherwise the operation 
 * of the MQTT client will be stalled. 
 */
interface IMqttActionListener
{
	/**
	 * This method is invoked when an action has completed 
	 * successfully. 
	 * @param tok The tokent associated with the action.
	 */
	void onSuccess(IMqttToken tok);
	/**
	 * This method is invoked when an action fails. 
	 * @param tok The token associated with the action
	 * @param exc 
	 */
	void onFailure(IMqttToken tok, Throwable exc);
}

