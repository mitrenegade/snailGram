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
        self.textViewTo.text = _currentPostCard.to.toString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickSave:(id)sender {
    [UIAlertView alertViewWithTitle:@"Postcard saved" message:@"Thank you for creating a postcard. It has been saved and you will be able to view it through Parse soon." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
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
