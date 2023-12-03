/////////////////////////////////////////////////////////////////////////////
/// @file MqttWillOptions.d
/// Definition of MqttWillOptions class
/// @date August 28, 2016
/// @author Frank Pagliughi
/////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
 * Copyright (c) 2016 Frank Pagliughi <fpagliughi@mindspring.com>
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

import Async;
import std.stdio;
import std.string;
import std.conv;
import core.time;

extern (C) int onSllErrorCallback(const char* str, size_t len, void* u) {
	MqttSSLOptions opts = cast(MqttSSLOptions)u;
	opts.ssl_error_cb(str[0..len].idup);
	return true;
}

/////////////////////////////////////////////////////////////////////////////

/**
 * Options for a connection using SSL/TSL.
 */
class MqttSSLOptions
{
	/** The underlying C struct for SSL options  */
	private MQTTAsync_SSLOptions opts;
	/** The file containing trusted public certificates */
	private string trustStore;
	/** The file containing the public certificate chain for the client */
	private string keyStore;
	/** The file containing the client's private key */
	private string privateKey;
	/** The password to load the client's privateKey (if encrypted) */
	private string privateKeyPassword;
	/** The list of cipher suites for the SSL handshake */
	private string enabledCipherSuites;
	/** True/False option to enable verification of the server certificate */
	private bool enableServerCertAuth;
	/** The SSL/TLS version to use. Specify one of MQTT_SSL_VERSION_DEFAULT (0), MQTT_SSL_VERSION_TLS_1_0 (1), MQTT_SSL_VERSION_TLS_1_1 (2) or MQTT_SSL_VERSION_TLS_1_2 (3). Only used if struct_version is >= 1.  */
 	private int sslVersion;
	/** Whether to carry out post-connect checks, including that a certificate matches the given host name. Exists only if struct_version >= 2 */
	private bool verify;
	/** From the OpenSSL documentation: If CApath is not NULL, it points to a directory containing CA certificates in PEM format. Exists only if struct_version >= 2 */
	private string caPath;
	/** Callback function for OpenSSL error handler ERR_print_errors_cb Exists only if struct_version >= 3 */
	private int function(string str) ssl_error_cb;

	/**
	 * Constructs the SSL/TSL options.
	 * @param trustStore The file containing trusted public certificates
	 * @param keyStore The file containing the public certificate chain for
	 *  			   the client
	 * @param privateKey The file containing the client's private key.
	 */
	this(string trustStore, string keyStore, string privateKey) {
		setTrustStore(trustStore);
		setKeyStore(keyStore);
		setPrivateKey(privateKey);
	}
	/**
	 * Constructs the SSL/TSL options.
	 * @param trustStore The file containing trusted public certificates
	 * @param keyStore The file containing the public certificate chain for
	 *  			   the client
	 * @param privateKey The file containing the client's private key.
	 * @param privateKeyPassword The password to load the client's
	 *  						 privateKey (if encrypted)
	 */
	this(string trustStore, string keyStore, string privateKey,
			string privateKeyPassword) {
		setTrustStore(trustStore);
		setKeyStore(keyStore);
		setPrivateKey(privateKey);
		setPrivateKeyPassword(privateKeyPassword);
	}
	/**
	 * Constructs the SSL/TSL options.
	 * @param trustStore The file containing trusted public certificates
	 * @param keyStore The file containing the public certificate chain for
	 *  			   the client
	 * @param privateKey The file containing the client's private key.
	 * @param privateKeyPassword The password to load the client's
	 *  						 privateKey (if encrypted)
	 * @param enabledCipherSuites The list of cipher suites for the SSL
	 *  						  handshake
	 * @param enableServerCertAuth The option to verify the server
	 *  						   certificate.
	 */
	this(string trustStore, string keyStore, string privateKey,
			string privateKeyPassword, string enabledCipherSuites,
			bool enableServerCertAuth) {
		this(trustStore,keyStore,privateKey,privateKeyPassword);
		setEnabledCipherSuites(enabledCipherSuites);
		setEnableServerCertAuth(enableServerCertAuth);
	}
	/**
	 * Gets the underlying C struct for the will options.
	 * @return The underlying C struct for the will options.
	 */
	MQTTAsync_SSLOptions getOptions() { return opts; }
	/**
	 * Gets a pointer to the underlying C struct for the will options. This
	 * is needed by the @ref MqttConnectOptions structure when making a
	 * connection to the broker.
	 * @return A pointer to the underlying C struct for the will options.
	 */
	MQTTAsync_SSLOptions* getOptionsPtr() { return &opts; }
	/**
	 * Gets the name of the file containing the public digital certificates
	 * trusted by the client.
	 * @return The file containing trusted public certificates
	 */
	string getTrustStore() { return trustStore; }
	/**
	 * Returns the file containing the public certificate chain of the client.
	 * @return string
	 */
	string getKeyStore() { return keyStore; }
	/**
	 * Returns the file containing the client's private key.
	 * @return string
	 */
	string getPrivateKey() { return privateKey; }
	/**
	 * Gets the password to load the client's privateKey if encrypted.
	 * @return The password to load the client's privateKey if encrypted.
	 */
	string getPrivateKeyPassword() { return privateKeyPassword; }
	/**
	 * Returns the list of cipher suites that the client will present to the
	 * server during the SSL handshake.
	 * @return The list of cipher suites that the client will present to the
	 *  	   server during the SSL handshake.
	 */
	string getEnabledCipherSuites() { return enabledCipherSuites; }
	/**
	 * Gets whether we verify the server certificate.
	 * @return Whether we verify the server certificate.
	 */
	bool getEnableServerCertAuth() const {
		return enableServerCertAuth;
	}
	/** The SSL/TLS version to use. Specify one of
	 * MQTT_SSL_VERSION_DEFAULT (0),
	 * MQTT_SSL_VERSION_TLS_1_0 (1),
	 * MQTT_SSL_VERSION_TLS_1_1 (2)
	 * or MQTT_SSL_VERSION_TLS_1_2 (3).
	 * Only used if struct_version is >= 1.  */
 	int getSslVersion() const {
		return sslVersion;
	}

	/** Whether to carry out post-connect checks,
	 * including that a certificate matches the given host name.
	 * Exists only if struct_version >= 2 */
	bool getVerify() const {
		return verify;
	}

	/** From the OpenSSL documentation:
	 * If CApath is not NULL, it points to a directory
	 * containing CA certificates in PEM format.
	 * Exists only if struct_version >= 2 */
	string getCAPath() const {
		return caPath;
	}

	/**
	 * Sets the name of the file containing the public digital certificates
	 * trusted by the client.
	 * @param trustStore The file containing the public digital certificates
	 *  				 trusted by the client.
	 */
	void setTrustStore(string trustStore) {
		this.trustStore = trustStore;
		if (!trustStore.empty)
		    opts.trustStore = std.string.toStringz(this.trustStore);
	}
	/**
	 * Sets the name of the file containing the public certificate chain of
	 * the client.
	 * @param keyStore The file containing the public certificate chain of
	 *  			   the client.
	 */
	void setKeyStore(string keyStore) {
		this.keyStore = keyStore;
		if (!keyStore.empty)
			opts.keyStore = std.string.toStringz(this.keyStore);
	}
	/**
	 * Sets the file containing the client's private key.
	 * @param privateKey The file containing the client's private key. =
	 */
	void setPrivateKey(string privateKey) {
		this.privateKey = privateKey;
		if (!privateKey.empty)
			opts.privateKey = std.string.toStringz(this.privateKey);
	}
	/**
	 * Sets the password to load the client's privateKey (if encrypted).
	 * @param privateKeyPassword The password to load the client's
	 *  						 privateKey.
	 */
	void setPrivateKeyPassword(string privateKeyPassword) {
		this.privateKeyPassword = privateKeyPassword;
		if (!privateKeyPassword.empty)
			opts.privateKeyPassword = std.string.toStringz(this.privateKeyPassword);
	}
	/**
	 * Sets the list of cipher suites that the client will present to the server
	 * during the SSL handshake.
	 *
	 * For a  full explanation of the cipher list format, please see the
	 * OpenSSL on-line documentation:
	 * http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT
	 *
	 * If this setting is ommitted, its default value will be "ALL", that
	 * is, all the cipher suites -excluding those offering no encryption-
	 * will be considered.
	 *
	 * This setting can be used to set an SSL anonymous connection ("aNULL"
	 * string value, for instance).
	 *
	 * @param enabledCipherSuites The list of cipher suites that the client
	 *  						  will present to the server during the SSL
	 *  						  handshake.
	 */
	void setEnabledCipherSuites(string enabledCipherSuites) {
		this.enabledCipherSuites = enabledCipherSuites;
		if (!enabledCipherSuites.empty)
			opts.enabledCipherSuites = std.string.toStringz(this.enabledCipherSuites);
	}
	/**
	 * Sets the option to verify the server certificate.
	 * @param enablServerCertAuth Whether to verify the server certificate.
	 */
	void setEnableServerCertAuth(bool enablServerCertAuth) {
		this.enableServerCertAuth = enableServerCertAuth;
		opts.enableServerCertAuth = enablServerCertAuth ? 1 : 0;
	}
	/** The SSL/TLS version to use. Specify one of
	 * MQTT_SSL_VERSION_DEFAULT (0),
	 * MQTT_SSL_VERSION_TLS_1_0 (1),
	 * MQTT_SSL_VERSION_TLS_1_1 (2)
	 * or MQTT_SSL_VERSION_TLS_1_2 (3).
	 * Only used if struct_version is >= 1.  */
 	void setSslVersion(int sslVersion) {
		this.sslVersion = sslVersion;
		opts.sslVersion = sslVersion;
		if (opts.struct_version < 1)
			opts.struct_version = 1;
	}
	/** Whether to carry out post-connect checks, 
	 * including that a certificate matches the given host name.
	 * Exists only if struct_version >= 2 */
	void setVerify(bool verify) {
		this.verify = verify;
		opts.verify = verify ? 1 : 0;
		if (opts.struct_version < 2)
			opts.struct_version = 2;
	}

	/** From the OpenSSL documentation:
	 * If CApath is not NULL, it points to a directory
	 * containing CA certificates in PEM format.
	 * Exists only if struct_version >= 2 */
	void setCAPath(string caPath) {
		this.caPath = caPath;
		if (!caPath.empty)
			opts.caPath = std.string.toStringz(this.caPath);
	}

	/** Callback function for OpenSSL error handler
	 * ERR_print_errors_cb Exists only if struct_version >= 3 */
	void setSslErrorCallback(int function(string) cb) {
		this.ssl_error_cb = cb;
		opts.ssl_error_cb = &onSllErrorCallback;
		opts.ssl_error_context = cast(void*)this;
		if (opts.struct_version < 3)
			opts.struct_version = 3;
	}

}

