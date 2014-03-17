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
        self.textViewTo.text = _currentPostCard.to.toString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark navigation
-(IBAction)didClickSave:(id)sender {
    [self.textViewMessage resignFirstResponder];
    [self.textViewTo resignFirstResponder];

    if ([_currentPostCard.message length] == 0)
        [self.textViewMessage setHidden:YES];
    [self saveScreenshot];
    [self.textViewMessage setHidden:NO];
}

-(IBAction)didClickFront:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.25];

    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];

    [[self navigationController] popViewControllerAnimated:NO];

    [UIView commitAnimations];
}

-(void)saveScreenshot {
    alertView = [UIAlertView alertViewWithTitle:@"Finalizing postcard..." message:nil];

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
        [_currentPostCard saveOrUpdateToParseWithCompletion:^(BOOL success) {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            if (success) {
                [UIAlertView alertViewWithTitle:@"Postcard saved" message:@"Thank you for creating a postcard. It has been saved and you will be able to view it through Parse soon." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
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
    AddressEditorViewController *addressController = [[AddressEditorViewController alloc] init];
    addressController.delegate = self;
    if (textView == self.textViewMessage) {
        textViewEditing = self.textViewMessage;
        textView.text = _currentPostCard.message;
    }
    else if (textView == self.textViewTo) {
        textViewEditing = self.textViewTo;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addressController];
        [self.navigationController presentViewController:nav animated:YES completion:^{
        }];
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

    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];

        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
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
    
    if (textViewEditing == self.textViewTo) {
        [self.textViewTo resignFirstResponder];

        _currentPostCard.to = newAddress;
        [self.textViewTo setText:[_currentPostCard.to toString]];
    }
}

@end
