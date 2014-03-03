//
//  AddressEditorViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "AddressEditorViewController.h"

@interface AddressEditorViewController ()

@end

static NSArray *states;

@implementation AddressEditorViewController

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
    // Do any additional setup after loading the view from its nib.

    pickerViewState = [[UIPickerView alloc] init];
    pickerViewState.delegate = self;
    pickerViewState.dataSource = self;
    self.inputState.inputView = pickerViewState;

    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = [UIColor whiteColor];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(closePickerState:)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPickerState:)];
    [keyboardDoneButtonView setItems:@[done, cancel]];
    self.inputState.inputAccessoryView = keyboardDoneButtonView;

    pickerViewAddress = [[UIPickerView alloc] init];
    pickerViewAddress.delegate = self;
    pickerViewAddress.dataSource = self;
    self.inputExistingRecipient.inputView = pickerViewAddress;
    UIToolbar* keyboardDoneButtonView2 = [[UIToolbar alloc] init];
    keyboardDoneButtonView2.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView2.translucent = YES;
    keyboardDoneButtonView2.tintColor = [UIColor whiteColor];
    [keyboardDoneButtonView2 sizeToFit];
    UIBarButtonItem *done2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(closePickerAddress:)];
    UIBarButtonItem *cancel2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPickerAddress:)];
    [keyboardDoneButtonView2 setItems:@[done2, cancel2]];
    self.inputExistingRecipient.inputAccessoryView = keyboardDoneButtonView2;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        states = @[@"AL",@"AK",@"AZ",@"AR",@"CA",@"CO",@"CT",@"DE",@"FL",@"GA",@"HI",@"ID",@"IL",@"IN",@"IA",@"KS",@"KY",@"LA",@"ME",@"MD",@"MA",@"MI",@"MN",@"MS",@"MO",@"MT",@"NE",@"NV",@"NH",@"NJ",@"NM",@"NY",@"NC",@"ND",@"OH",@"OK",@"OR",@"PA",@"RI",@"SC",@"SD",@"TN",@"TX",@"UT",@"VT",@"VA",@"WA",@"WV",@"WI",@"WY"];
    });

    if (self.address) {
        self.inputStreet1.text = self.address.street;
        self.inputStreet2.text = self.address.street2;
        self.inputCity.text = self.address.city;
        self.inputState.text = self.address.state;
        self.inputZip.text = self.address.zip;
    }
    else
        self.address = (Address *)[Address createEntityInContext:_appDelegate.managedObjectContext];

    // load existing addresses
    existingAddresses = [[[Address where:@{}] descending:@"name"] all];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.inputExistingRecipient) {
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark PickerViewDatasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == pickerViewState)
        return [states count];
    else if (pickerView == pickerViewAddress)
        return [existingAddresses count];
    return 0;
}

#pragma mark PickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == pickerViewState)
        return states[row];
    else if (pickerView == pickerViewAddress)
        return [existingAddresses[row] name];
    return nil;
}
    
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == pickerViewState)
        [self.inputState setText:[self pickerView:pickerView titleForRow:row forComponent:component]];
    else if (pickerView == pickerViewAddress) {
        self.selectedAddress = existingAddresses[row];
        [self.inputExistingRecipient setText:[self.selectedAddress name]];
    }
}

-(void)closePickerState:(id)sender {
    [self.inputState resignFirstResponder];
}

-(void)cancelPickerState:(id)sender {
    if ([self.address state])
        [self.inputState setText:[self.address state]];
    [self.inputState resignFirstResponder];
}

-(void)closePickerAddress:(id)sender {
    [self.inputExistingRecipient resignFirstResponder];
}

-(void)cancelPickerAddress:(id)sender {
    self.inputExistingRecipient.text = nil;
    self.selectedAddress = nil;
    [self.inputExistingRecipient resignFirstResponder];
}

#pragma mark Save or Load address
-(void)didClickSave:(id)sender {
    // todo: need validation that data exists

    self.address.name = self.inputName.text;
    self.address.street = self.inputStreet1.text;
    self.address.street2 = self.inputStreet2.text;
    self.address.city = self.inputCity.text;
    self.address.state = self.inputState.text;
    self.address.zip = self.inputZip.text;

    [self.delegate didSaveAddress:self.address];
}

-(void)didClickLoad:(id)sender {
    // todo: need validation that an address was selected

    [self.delegate didSaveAddress:self.selectedAddress];
}
@end
