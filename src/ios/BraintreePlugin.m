//
//  BraintreePlugin.m
//
//  Copyright (c) 2016 Akash. All rights reserved.
//

#import "BraintreePlugin.h"
#import <objc/runtime.h>
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/BTAPIClient.h>
#import <BraintreeCore/BTPaymentMethodNonce.h>
#import <BraintreePayPal/BraintreePayPal.h>

@interface BraintreePlugin() <BTAppSwitchDelegate, BTViewControllerPresentingDelegate>
    @property (nonatomic, strong) BTAPIClient *braintreeClient;
@end

@implementation BraintreePlugin

#pragma mark - Cordova commands

- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)finishLaunching:(NSNotification *)notification
{
    [BTAppSwitch setReturnURLScheme:@"com.ezerapp.payments"];
}

- (void)initialize:(CDVInvokedUrlCommand *)command {

    // Ensure we have the correct number of arguments.
    if ([command.arguments count] != 1) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A token is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Obtain the arguments.
    NSString* token = [command.arguments objectAtIndex:0];

    if (!token) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A token is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:token];

    if (!self.braintreeClient) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The Braintree client failed to initialize."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.braintreeClient];
    payPalDriver.viewControllerPresentingDelegate = self;
    payPalDriver.appSwitchDelegate = self; // Optional

    // Start the Vault flow
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        if (tokenizedPayPalAccount) {
            // NSLog(@"paypal nonce: %@", tokenizedPayPalAccount.billingAddress);
            NSDictionary *paypalDetails = @{
               @"nonce": tokenizedPayPalAccount.nonce,
               @"email": tokenizedPayPalAccount.email,
               @"firstName": tokenizedPayPalAccount.firstName,
               @"lastName": tokenizedPayPalAccount.lastName,
               @"phone": !tokenizedPayPalAccount.phone ? [NSNull null] : tokenizedPayPalAccount.phone,
               @"billingAddress": @{
                   @"recipientName": !tokenizedPayPalAccount.billingAddress.recipientName ? [NSNull null] : tokenizedPayPalAccount.billingAddress.recipientName,
                   @"streetAddress": !tokenizedPayPalAccount.billingAddress.streetAddress ? [NSNull null] : tokenizedPayPalAccount.billingAddress.streetAddress,
                   @"locality": !tokenizedPayPalAccount.billingAddress.locality ? [NSNull null] : tokenizedPayPalAccount.billingAddress.locality,
                   @"countryCodeAlpha2": !tokenizedPayPalAccount.billingAddress.countryCodeAlpha2 ? [NSNull null] : tokenizedPayPalAccount.billingAddress.countryCodeAlpha2,
                   @"postalCode": !tokenizedPayPalAccount.billingAddress.postalCode ? [NSNull null] : tokenizedPayPalAccount.billingAddress.postalCode,
                   @"region": !tokenizedPayPalAccount.billingAddress.region ? [NSNull null] : tokenizedPayPalAccount.billingAddress.region
               },
               @"clientMetadataId": !tokenizedPayPalAccount.clientMetadataId ? [NSNull null] : tokenizedPayPalAccount.clientMetadataId,
               @"payerId": !tokenizedPayPalAccount.payerId ? [NSNull null] : tokenizedPayPalAccount.payerId
            };
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: paypalDetails];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else if (error) {
             CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Something went wrong."];
            [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
            NSLog(@"paypal error: %@", error.localizedDescription);
        } else {
            NSLog(@"Cancelled...");
            CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User cancelled paypal."];
            [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        }
    }];
}

#pragma mark - BTViewControllerPresentingDelegate

- (void)paymentDriver:(__unused id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [self.viewController presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(__unused id)driver requestsDismissalOfViewController:(UIViewController *)viewController {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BTAppSwitchDelegate

// Optional - display and hide loading indicator UI
- (void)appSwitcherWillPerformAppSwitch:(id)appSwitcher {
    // You may also want to subscribe to UIApplicationDidBecomeActiveNotification
    // to dismiss the UI when a customer manually switches back to your app since
    // the payment button completion block will not be invoked in that case (e.g.
    // customer switches back via iOS Task Manager)
}

- (void)appSwitcher:(id)appSwitcher didPerformSwitchToTarget:(BTAppSwitchTarget)target {}

- (void)appSwitcherWillProcessPaymentInfo:(id)appSwitcher {
}
@end