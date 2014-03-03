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

#define PLACEHOLDER_TEXT_FROM @"From:"
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

    if (_currentPostCard.from)
        self.textViewFrom.text = _currentPostCard.from.toString;
    if (_currentPostCard.to)
        self.textViewTo.text = _currentPostCard.to.toString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickSave:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#if 0
#pragma mark TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.textViewFrom)
        textView.text = _currentPostCard.from;
    else if (textView == self.textViewTo)
        textView.text = _currentPostCard.to;
    textView.font = [UIFont systemFontOfSize:15];
    textView.textColor = [UIColor darkGrayColor];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    NSString *message;
    NSString *placeholder;
    if (textView == self.textViewFrom) {
        message = _currentPostCard.from;
        placeholder = PLACEHOLDER_TEXT_FROM;
    }
    else if (textView == self.textViewTo) {
        message = _currentPostCard.to;
        placeholder = PLACEHOLDER_TEXT_TO;
    }

    if (message.length == 0) {
        textView.text = placeholder;
        textView.font = [UIFont fontWithName:@"Noteworthy-light" size:15];
        textView.textColor = [UIColor blackColor];
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];

        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    NSString *oldComments;
    if (textView == self.textViewFrom) {
        oldComments = _currentPostCard.from;
        _currentPostCard.from = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if ([_currentPostCard.from length] > ADDRESS_LIMIT) {
            _currentPostCard.from = oldComments;
            textView.text = oldComments;
            return NO;
        }
    }
    else if (textView == self.textViewTo) {
        oldComments = _currentPostCard.to;
        _currentPostCard.to = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if ([_currentPostCard.to length] > ADDRESS_LIMIT) {
            _currentPostCard.to = oldComments;
            textView.text = oldComments;
            return NO;
        }
    }

    return YES;
}
#else
-(void)textViewDidBeginEditing:(UITextView *)textView {
    AddressEditorViewController *addressController = [[AddressEditorViewController alloc] init];
    addressController.delegate = self;
    if (textView == self.textViewFrom) {
        if (!_currentPostCard.from)
            _currentPostCard.from = (Address *)[Address createEntityInContext:_appDelegate.managedObjectContext];

        [addressController setAddress:_currentPostCard.from];
    }
    else if (textView == self.textViewTo) {
        if (!_currentPostCard.to)
            _currentPostCard.to = (Address *)[Address createEntityInContext:_appDelegate.managedObjectContext];

        [addressController setAddress:_currentPostCard.to];
    }
    [self.navigationController presentViewController:addressController animated:YES completion:nil];
}

-(void)didSaveAddress:(Address *)newAddress {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    [newAddress saveOrUpdateToParse];

    [self.textViewFrom resignFirstResponder];
    [self.textViewTo resignFirstResponder];

    [self.textViewFrom setText:[_currentPostCard.from toString]];
    [self.textViewTo setText:[_currentPostCard.to toString]];
}
#endif

@end
