//
//  AddressEditorViewController.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Address.h"

@protocol AddressEditorDelegate <NSObject>

-(void)didSaveAddress:(Address *)newAddress;

@end

@interface AddressEditorViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIPickerView *pickerViewState;
    UIPickerView *pickerViewAddress;
    NSArray *existingAddresses;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) Address *address;
@property (nonatomic, weak) Address *selectedAddress;

#pragma mark new recipient inputs
@property (nonatomic, weak) IBOutlet UITextField *inputName;
@property (nonatomic, weak) IBOutlet UITextField *inputStreet1;
@property (nonatomic, weak) IBOutlet UITextField *inputStreet2;
@property (nonatomic, weak) IBOutlet UITextField *inputCity;
@property (nonatomic, weak) IBOutlet UITextField *inputState;
@property (nonatomic, weak) IBOutlet UITextField *inputZip;

#pragma mark existing recipients
@property (nonatomic, weak) IBOutlet UITextField *inputExistingRecipient;

-(IBAction)didClickSave:(id)sender;
-(IBAction)didClickLoad:(id)sender;
@end
