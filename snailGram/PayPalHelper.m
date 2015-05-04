//
//  PayPalHelper.m
//  snailGram
//
//  Created by Bobby Ren on 3/19/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "PayPalHelper.h"
#import "Payment+Parse.h"

@implementation PayPalHelper

@synthesize payPalConfiguration = _payPalConfiguration;

static PayPalHelper *sharedPayPalHelper;

+(PayPalHelper *)sharedPayPalHelper {
    if (!sharedPayPalHelper) {
        sharedPayPalHelper = [[PayPalHelper alloc] init];

        [PayPalHelper initializePayPal];
    }
    return sharedPayPalHelper;
}

#pragma mark Paypal SDK 2.0.0 used for user auth when withdrawing
+(void)initializePayPal {
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : PAYPAL_APP_ID_PRODUCTION, PayPalEnvironmentSandbox : PAYPAL_APP_ID_SANDBOX}];

    PayPalHelper *helper = [PayPalHelper sharedPayPalHelper];
    helper.payPalConfiguration = [[PayPalConfiguration alloc] init];

    // See PayPalConfiguration.h for details and default values.

    // Minimally, you will need to set three merchant information properties.
    // These should be the same values that you provided to PayPal when you registered your app.
    helper.payPalConfiguration.merchantName = @"snailGram";
    helper.payPalConfiguration.merchantPrivacyPolicyURL = [NSURL URLWithString:@"http://snailgrams.com"];
    helper.payPalConfiguration.merchantUserAgreementURL = [NSURL URLWithString:@"https://snailgrams.com"];
}

+(UIViewController *)showPayPalLoginWithDelegate:(id)_delegate {
    PayPalHelper *helper = [PayPalHelper sharedPayPalHelper];
#if TESTING
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
#else
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
#endif
    helper.delegate = _delegate;

    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];

    // Amount, currency, and description
    NSNumber *price = [[NSUserDefaults standardUserDefaults] objectForKey:@"price"];
    if (!price) {
        price = @(5); // default price
    }
    payment.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@", price]];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Postage for one postcard";

    // Use the intent property to indicate that this is a "sale" payment,
    // meaning combined Authorization + Capture. To perform Authorization only,
    // and defer Capture to your server, use PayPalPaymentIntentAuthorize.
    payment.intent = PayPalPaymentIntentSale;

    // Check whether payment is processable.
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    // Create a PayPalPaymentViewController.
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                   configuration:helper.payPalConfiguration
                                                                        delegate:helper];
    return paymentViewController;
}

#pragma mark - PayPalPaymentDelegate methods
- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];

    // Dismiss the PayPalPaymentViewController.
    // do it after verifyCompletedPayment returns
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self.delegate didCancelPayPalLogin];
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
                                                           options:0
                                                             error:nil];

    // completedPayment.confirmation looks like this:
    /*
    response =     {
        "create_time" = "2014-03-20T07:12:33Z";
        id = "PAY-6RV70583SB702805EKEYSZ6Y";
        intent = sale;
        state = approved;
    };
     */
    Payment *payment = (Payment *)[Payment createEntityInContext:_appDelegate.managedObjectContext];
    NSDictionary *response = completedPayment.confirmation[@"response"];
    payment.state = response[@"state"];
#if TESTING
    payment.state = @"sandbox";
#endif
    payment.intent = response[@"intent"];
    payment.paypal_id = response[@"id"];
    payment.create_time = response[@"create_time"];
    payment.postcard = _currentPostCard;
    payment.post_card_id = _currentPostCard.parseID;
    payment.data = confirmation;

    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
    NSLog(@"Saving payment to Parse: %@", completedPayment.confirmation[@"response"]);
    [payment saveOrUpdateToParseWithCompletion:^(BOOL success) {
        if (success) {
            NSLog(@"Payment updated!");

            // todo: update credit card to reflect payment id, status
            [self.delegate didFinishPayPalLogin];
        }
        else {
            NSLog(@"Payment could not be updated");

            // todo: update credit card to reflect payment id, status
        }
    }];
}

@end
