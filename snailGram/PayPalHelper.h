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

@interface PayPalHelper : NSObject <PayPalPaymentDelegate, PayPalFuturePaymentDelegate>

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@property (nonatomic, weak) id delegate;
+(void)initializePayPal;
+(UIViewController *)showPayPalLoginWithDelegate:(id)_delegate;

@end
