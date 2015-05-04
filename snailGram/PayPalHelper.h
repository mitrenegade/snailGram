//
//  PayPalHelper.h
//  snailGram
//
//  Created by Bobby Ren on 3/19/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayPalMobile.h"

@protocol PayPalHelperDelegate <NSObject>

-(void)didCancelPayPalLogin;
-(void)didFinishPayPalLogin;

@end

#define PAYPAL_APP_ID_PRODUCTION @"Ad20fI6QNLsZM7HUN2odVyVO05ijbgcbQ7Ysjxkquv31HTRzKqa1PtfHMhpMre-xkQu8Ex8Jg8k7b-5R"
#define PAYPAL_APP_ID_SANDBOX @"AbtbRudqs0ulY5p95cPSRQNHnPlWYA1hRNN0uddzKVNiD3ytuCJtRy4ic4vFL1XQyNBQ3IuQra8VxyuF"

@interface PayPalHelper : NSObject <PayPalPaymentDelegate, PayPalFuturePaymentDelegate>

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@property (nonatomic, weak) id delegate;
+(void)initializePayPal;
+(UIViewController *)showPayPalLoginWithDelegate:(id)_delegate;

@end
