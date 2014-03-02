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
    self.inputState.inputView = pickerViewState;

    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = [UIColor whiteColor];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(closePicker:)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPicker:)];
    [keyboardDoneButtonView setItems:@[done, cancel]];
    self.inputState.inputAccessoryView = keyboardDoneButtonView;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark PickerViewDatasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [states count];
}

#pragma mark PickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return states[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.inputState setText:[self pickerView:pickerView titleForRow:row forComponent:component]];
}

-(void)closePicker:(id)sender {
    [self.address setState:self.inputState.text];
    [self.inputState resignFirstResponder];
}

-(void)cancelPicker:(id)sender {
    if ([self.address state])
        [self.inputState setText:[self.address state]];
    [self.inputState resignFirstResponder];
}

-(void)didClickSave:(id)sender {
    self.address.street = self.inputStreet1.text;
    self.address.street2 = self.inputStreet2.text;
    self.address.city = self.inputCity.text;
    self.address.state = self.inputState.text;
    self.address.zip = self.inputZip.text;

    [self.delegate didSaveAddress:self.address];
}
@end
