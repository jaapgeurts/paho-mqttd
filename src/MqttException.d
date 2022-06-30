// MqttException.d
import Async;
import std.conv : to;

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

class MqttException : Exception {
	private int reasonCode;

	this() {
		this(-1);
	}

	this (int reasonCode) {
        super(to!string(MQTTAsync_strerror(reasonCode)));
		this.reasonCode = reasonCode;
	}

	int getReasonCode() { return reasonCode; }
}
