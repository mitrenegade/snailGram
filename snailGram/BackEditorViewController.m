//
//  BackEditorViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "BackEditorViewController.h"
#import "Address+Info.h"
#import "Address+Parse.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "PostCard+Parse.h"
#import "PayPalHelper.h"
#import "Payment+Parse.h"

#define PLACEHOLDER_TEXT_TO @"To:"
#define ADDRESS_LIMIT 300
@interface BackEditorViewController ()

@end

@implementation BackEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.canvas.layer setBorderWidth:2];

    if ([_currentPostCard.message length])
        self.textViewMessage.text = _currentPostCard.message;
    if (_currentPostCard.to)
        self.labelTo.text = _currentPostCard.to.toString;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editAddress)];
    [self.labelTo addGestureRecognizer:tap];

    // done button
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = [UIColor whiteColor];
    [keyboardDoneButtonView sizeToFit];
    [keyboardDoneButtonView setItems:@[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")                                                                       style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardInput:)]]];
    self.textViewMessage.inputAccessoryView = keyboardDoneButtonView;

    [self.textViewMessage setFont:FONT_REGULAR(14)];
    [self.labelTo setFont:FONT_REGULAR(14)];
}

-(void)closeKeyboardInput:(id)sender {
    [self.textViewMessage resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark navigation
-(IBAction)didClickSave:(id)sender {
    [self.textViewMessage resignFirstResponder];

    if ([_currentPostCard.message length] == 0)
        [self.textViewMessage setHidden:YES];
    [self saveScreenshot];
    [self.textViewMessage setHidden:NO];

    [self goToPayment];
}

-(IBAction)didClickFront:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];

    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];

    [[self navigationController] popViewControllerAnimated:NO];

    [UIView commitAnimations];
}

-(void)saveScreenshot {
    //alertView = [UIAlertView alertViewWithTitle:@"Finalizing postcard..." message:nil];

    // Create the screenshot
    float scale = 5;

    CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    CGSize size = CGSizeMake(self.canvas.frame.size.width * scale, self.canvas.frame.size.height * scale);
    UIGraphicsBeginImageContext(size);
    // Put everything in the current view into the screenshot
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextConcatCTM(ctx, t);
    [self.canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRestoreGState(ctx);
    // Save the current image context info into a UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self uploadImage:newImage];
}

#pragma mark AWS
-(void)uploadImage:(UIImage *)image {
    NSString *name = [NSString stringWithFormat:@"%@-b", _currentPostCard.parseID];
    [AWSHelper uploadImage:image withName:name toBucket:AWS_BUCKET withCallback:^(NSString *url) {
        // update postcard with the url
        _currentPostCard.image_url_back = [AWSHelper urlForPhotoWithKey:name];
        _currentPostCard.back_loaded = @YES;
        [_currentPostCard saveOrUpdateToParseWithCompletion:^(BOOL success) {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            if (success) {
                NSLog(@"upload finished");
            }
            else {
                [UIAlertView alertViewWithTitle:@"Could not save image" message:@"We couldn't save your image. Please try again." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Retry"] onDismiss:^(int buttonIndex) {
                    [self uploadImage:image];
                } onCancel:nil];
            }
        }];
    }];
}

#pragma mark TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.textViewMessage) {
        textView.text = _currentPostCard.message;
    }

    textView.font = [UIFont systemFontOfSize:15];
    textView.textColor = [UIColor darkGrayColor];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    NSString *message;
    NSString *placeholder;
    if (textView == self.textViewMessage) {
        message = _currentPostCard.message;

        if (message.length == 0) {
            textView.text = placeholder;
            textView.font = [UIFont fontWithName:@"Noteworthy-light" size:15];
            textView.textColor = [UIColor blackColor];
        }
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    if (textView != self.textViewMessage)
        return YES;

    NSString *oldComments;
    oldComments = _currentPostCard.message;
    _currentPostCard.message = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([_currentPostCard.message length] > MESSAGE_LENGTH_LIMIT) {
        _currentPostCard.message = oldComments;
        textView.text = oldComments;
        return NO;
    }

    return YES;
}

-(void)didSaveAddress:(Address *)newAddress {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    [newAddress saveOrUpdateToParseWithCompletion:nil];
    NSError *error;
    [_appDelegate.managedObjectContext save:&error];
    
    _currentPostCard.to = newAddress;
    NSString *str = [_currentPostCard.to toString];
    self.labelTo.text = [NSString stringWithFormat:@"To: %@", str];
}

-(void)editAddress {
    AddressEditorViewController *addressController = [[AddressEditorViewController alloc] init];
    addressController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addressController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark Payment
-(void)goToPayment {
    UIViewController *controller = [PayPalHelper showPayPalLoginWithDelegate:self];
    // Present the PayPalFuturePaymentViewController
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

#pragma mark PayPalHelperDelegate
-(void)didFinishPayPalLogin {
    NSLog(@"Paypal finished");
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [UIAlertView alertViewWithTitle:@"PayPal completed" message:@"Thank you for paying with PayPal. Your postcard is on its way."];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

-(void)didCancelPayPalLogin {
    NSLog(@"Paypal cancelled");
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [UIAlertView alertViewWithTitle:@"PayPal cancelled" message:@"PayPal login was cancelled; your postcard has not been created."];
    }];
}

@end
