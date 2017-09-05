//
//  BraintreePlugin.h
//
//  Copyright (c) 2016 Akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface BraintreePlugin : CDVPlugin
- (void)initialize:(CDVInvokedUrlCommand *)command;
@end