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
#import "PostCard+Image.h"

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

    [self.textViewMessage setFont:FONT_REGULAR(12)];
    [self.labelTo setFont:FONT_REGULAR(13)];

    [self.labelFrom setFont:FONT_REGULAR(6)];
    [self.labelFrom setHidden:YES];
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
#if !TESTING
    if (!_currentPostCard.to) {
        [UIAlertView alertViewWithTitle:@"Please enter a recipient" message:@"You must enter all necessary fields before sending the postcard!"];
        return;
    }
#endif

    [self.textViewMessage resignFirstResponder];

    if ([_currentPostCard.message length] == 0)
        [self.textViewMessage setHidden:YES];
    [self saveScreenshot];
    [self.textViewMessage setHidden:NO];

#if TESTING
    [self renderCompositeImage];
#endif
    [self goToPayment];
    
#if CAN_LOAD_POSTCARD
    // save coredata
    NSError *error;
    [_appDelegate.managedObjectContext save:&error];
#endif
}

-(IBAction)didClickFront:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];

    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];

    [[self navigationController] popViewControllerAnimated:NO];

    [UIView commitAnimations];
}

-(void)saveScreenshot {
    // Create the screenshot. draw everything in canvas
    float scaleX = POSTCARD_WIDTH_PIXELS / self.canvas.frame.size.width;
    float scaleY = POSTCARD_HEIGHT_PIXELS / self.canvas.frame.size.height;

    CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY);
    CGSize size = CGSizeMake(POSTCARD_WIDTH_PIXELS, POSTCARD_HEIGHT_PIXELS);
    UIGraphicsBeginImageContext(size);
    // Put everything in the current view into the screenshot
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextConcatCTM(ctx, t);
    [self.labelFrom setHidden:NO];
    [self.canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRestoreGState(ctx);
    [self.labelFrom setHidden:YES];
    // Save the current image context info into a UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self uploadImage:newImage];
}

#pragma mark AWS
-(void)uploadImage:(UIImage *)image {
    _currentPostCard.imageBack = image;
    NSData *data = UIImageJPEGRepresentation(image, .8);
    PFFile *imageFile = [PFFile fileWithData:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // update postcard with the url
        _currentPostCard.pfObject[@"back_image"] = imageFile;
        // update postcard with the url
        _currentPostCard.back_loaded = @YES;
        _currentPostCard.image_url_back = imageFile.url;
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

    // pretend there's more vertical space to get that extra line to check on
    CGSize tallerSize = CGSizeMake(textView.frame.size.width-15, textView.frame.size.height*2);

    CGSize newSize = [_currentPostCard.message sizeWithFont:textView.font constrainedToSize:tallerSize lineBreakMode:NSLineBreakByWordWrapping];

    if (newSize.height > textView.frame.size.height - 20)
    {
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
        alertView = [UIAlertView alertViewWithTitle:@"Finalizing postcard..." message:@"Please do not close until this is completed..."];
        [self renderCompositeImage];
    }];
}

-(void)didCancelPayPalLogin {
    NSLog(@"Paypal cancelled");
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [UIAlertView alertViewWithTitle:@"PayPal cancelled" message:@"PayPal login was cancelled; your postcard has not been created."];
    }];
}

#pragma mark final

-(void)renderCompositeImage {
    // render composite image
    UIImage *front = _currentPostCard.imageFront;
    UIImage *back = _currentPostCard.imageBack;
    int border = 0;
    UIView *canvas = [[UIView alloc] initWithFrame:CGRectMake(0, 0, front.size.width, front.size.height*2+border)];
    UIImageView *frontView = [[UIImageView alloc] initWithImage:front];
    UIImageView *backView = [[UIImageView alloc] initWithImage:back];
    [frontView setFrame:CGRectMake(0, 0, front.size.width, front.size.height)];
    [backView setFrame:CGRectMake(0, front.size.height+border, back.size.width, back.size.height)];
    canvas.backgroundColor = [UIColor lightGrayColor];
    [canvas addSubview:frontView];
    [canvas addSubview:backView];

    // save as UIImage
    UIGraphicsBeginImageContextWithOptions(canvas.frame.size, YES, 0.0);
    [canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * composite = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _currentPostCard.imageFull = composite;
    NSData *data = UIImageJPEGRepresentation(composite, .8);
    PFFile *imageFile = [PFFile fileWithData:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // update postcard with the url
        _currentPostCard.pfObject[@"full_image"] = imageFile;
        // update postcard with the url
        _currentPostCard.back_loaded = @YES;
        _currentPostCard.image_url_full = imageFile.url;
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        [_currentPostCard saveOrUpdateToParseWithCompletion:^(BOOL success) {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            if (success) {
                    [UIAlertView alertViewWithTitle:@"Thanks for using snailGram!" message:@"Your postcard order has been received and will be delivered in 5-7 days."];
                    [_appDelegate resetPostcard];
                    [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else {
                [UIAlertView alertViewWithTitle:@"Could not save postcard" message:@"We couldn't complete your Postcard. Please click to upload again." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Retry"] onDismiss:^(int buttonIndex) {

                    [self renderCompositeImage];

                } onCancel:nil];
            }
        }];
    } progressBlock:^(int percentDone) {
        alertView.message = [NSString stringWithFormat:@"Progress: %d%%", percentDone];
    }];
}

@end
