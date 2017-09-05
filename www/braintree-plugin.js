"use strict";

var exec = require("cordova/exec");

/**
 * The Cordova plugin ID for this plugin.
 */
var PLUGIN_ID = "BraintreePlugin";

/**
 * The plugin which will be exported and exposed in the global scope.
 */
var BraintreePlugin = {};

/**
 * Used to initialize the Braintree client.
 *
 * The client must be initialized before other methods can be used.
 *
 * @param {string} token - The client token or tokenization key to use with the Braintree client.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
BraintreePlugin.initialize = function initialize(token, successCallback, failureCallback) {

    if (!token || typeof(token) !== "string") {
        failureCallback("A non-null, non-empty string must be provided for the token parameter.");
        return;
    }

    exec(successCallback, failureCallback, PLUGIN_ID, "initialize", [token]);
};

module.exports = BraintreePlugin;
