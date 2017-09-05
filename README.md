# Braintree cordova plugin only for paypal

This is a [Cordova](http://cordova.apache.org/) plugin for the [Braintree](https://www.braintreepayments.com/) mobile payment processing SDK.

This version of the plugin uses versions `4.1.3` (iOS) and `2.2.3` (Android) of the Braintree mobile SDK. Documentation for the Braintree SDK can be found [here](https://developers.braintreepayments.com/start/overview).

# Install

To add the plugin to your Cordova project, simply add the plugin from the npm registry:

    cordova plugin add https://bitbucket.org/cappitalsurat/braintree-paypal-plugin

iOS Manual changes for ezer app:

* Add in all lib/ios/* frameworks in `Embedded Binaries` section manually  (set app target iOS 8+)
* Add following in `AppDelegate.m` (obj-c)

```
#import "BraintreeCore/BraintreeCore.h"

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([url.scheme localizedCaseInsensitiveCompare:@"com.ezerapp.payments"] == NSOrderedSame) {
        return [BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication];
    }
    return NO;
}
```
# Usage

The plugin is available via a global variable named `BraintreePlugin`. It exposes the following properties and functions.

All functions accept optional success and failure callbacks as their last two arguments, where the failure callback will receive an error string as an argument unless otherwise noted.

## Initialize Braintree Client ##

Used to initialize the Braintree client. This will directly start paypal flow.

Method Signature:

`initialize(token, successCallback, failureCallback)`

Parameters:

* `token` (string): The unique client token or static tokenization key to use.

Example Usage:

```
var token = "YOUR_TOKEN";

BraintreePlugin.initialize(token,
    function () { console.log("init OK!"); },
    function (error) { console.error(error); });
```