/////////////////////////////////////////////////////////////////////////////
/// @file MqttConnectOptions.d
/// Declaration of MQTT async_client class
/// @date April 24, 2015
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
import std.stdio;
import std.conv;
import core.time;

/////////////////////////////////////////////////////////////////////////////

/**
 * Holds the set of options that control how the client connects to a 
 * server. 
 */
class MqttConnectOptions
{
	/** The option structure passed to the C library */
	private MQTTAsync_connectOptions opts;
	/* The user name, if any */
	private string userName;
	/* The user password, if any */
	private string psswd;
	/** The topic for the last will and testament (LWT) */
	private string willTopic;
	/** The message payload for the last will and testament (LWT)  */
	private string willPayload;

	this(Duration keepAliveInterval) {
		opts.keepAliveInterval = cast(int) keepAliveInterval.total!"seconds";
	}

	MQTTAsync_connectOptions getOptions() { return opts; }
}

