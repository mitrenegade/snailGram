//
//  AddressEditorViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "AddressEditorViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import <AddressBook/AddressBook.h>
#import "Address+Info.h"

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
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;

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

    // load existing addresses
    if ([existingAddresses count] == 0) {
        ABAuthorizationStatus authStatus =  ABAddressBookGetAuthorizationStatus ();
        if (authStatus == kABAuthorizationStatusAuthorized){
            [self loadContacts:NO];
        }
    }

    [self.buttonExistingRecipient setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.inputExistingRecipient) {
        if (requestedContacts) {
            existingAddresses = [[[[Address where:@{}] not:@{@"name":@""}] ascending:@"name"] all];
        }
        else {
            [self requestContactsPermission];
            [textField resignFirstResponder];
            return;
        }

        if ([existingAddresses count] == 0) {
            [UIAlertView alertViewWithTitle:@"No saved addresses" message:@"There are no saved recipients. Please create a new address."];
            [textField resignFirstResponder];
        }
        else {
            [self pickerView:pickerViewAddress didSelectRow:0 inComponent:0];
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.inputName)
        [self.inputStreet1 becomeFirstResponder];
    if (textField == self.inputStreet1)
        [self.inputStreet2 becomeFirstResponder];
    if (textField == self.inputStreet2)
        [self.inputCity becomeFirstResponder];
    if (textField == self.inputCity)
        [self.inputState becomeFirstResponder];
    if (textField == self.inputState)
        [self.inputZip becomeFirstResponder];
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

    if ([[self.inputExistingRecipient text] length] > 0) {
        [self.buttonExistingRecipient setEnabled:YES];
    }
    else
        [self.buttonExistingRecipient setEnabled:NO];
}

-(void)cancelPickerAddress:(id)sender {
    self.inputExistingRecipient.text = nil;
    self.selectedAddress = nil;
    [self.inputExistingRecipient resignFirstResponder];
}

#pragma mark Save or Load address
-(void)didClickSave:(id)sender {
    if (![self.inputName.text length]) {
        [UIAlertView alertViewWithTitle:@"Please enter a name" message:nil];
        return;
    }
    if (![self.inputStreet1.text length] && ![self.inputStreet2.text length]) {
        [UIAlertView alertViewWithTitle:@"Please enter a street" message:nil];
        return;
    }
    if (![self.inputCity.text length]) {
        [UIAlertView alertViewWithTitle:@"Please enter a city" message:nil];
        return;
    }
    if (![self.inputState.text length]) {
        [UIAlertView alertViewWithTitle:@"Please enter a state" message:nil];
        return;
    }
    if (![self.inputZip.text length]) {
        [UIAlertView alertViewWithTitle:@"Please enter a zip code" message:nil];
        return;
    }
    if ([self.inputZip.text length] != 5) {
        [UIAlertView alertViewWithTitle:@"Please enter a 5 digit zip code" message:nil];
        return;
    }

    if (!self.address) {
        Address *newAddress = [Address createInContext:_appDelegate.managedObjectContext withName:self.inputName.text street:self.inputStreet1.text street2:self.inputStreet2.text city:self.inputCity.text state:self.inputState.text zip:self.inputZip.text];
        self.address = newAddress;
    }
    else {
        self.address.name = self.inputName.text;
        self.address.street = self.inputStreet1.text;
        self.address.street2 = self.inputStreet2.text;
        self.address.city = self.inputCity.text;
        self.address.state = self.inputState.text;
        self.address.zip = self.inputZip.text;

        NSError *error;
        [_appDelegate.managedObjectContext save:&error];
    }

    [self.delegate didSaveAddress:self.address];
}

-(void)didClickLoad:(id)sender {
    if (!self.selectedAddress) {
        [UIAlertView alertViewWithTitle:@"Please select an existing recipient" message:nil];
        return;
    }
    [self.delegate didSaveAddress:self.selectedAddress];
}

-(void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Contact list
-(void)requestContactsPermission {
    ABAuthorizationStatus authStatus =  ABAddressBookGetAuthorizationStatus ();
    if (authStatus == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBook = ABAddressBookCreate( );
        ABAddressBookRequestAccessWithCompletion(addressBook , ^(bool granted, CFErrorRef error){
            if (granted){
                alert = [UIAlertView alertViewWithTitle:@"Loading contacts" message:@"Please be patient"];
                [self loadContacts:YES];
            }
            else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [UIAlertView alertViewWithTitle:@"Contact access denied" message:@"snailGram will not be able to access your contacts list. You can still manually add addresses. To change this, please go to Settings->Privacy->Contacts to enable access." cancelButtonTitle:@"Close" otherButtonTitles:nil onDismiss:nil onCancel:^{
                    }];
                });
            }
        });
    }
    else if (authStatus == kABAuthorizationStatusAuthorized){
        [self loadContacts:YES];
    }
    else {
        // already denied, cannot request it
        // don't do anything
    }
}

-(void)loadContacts:(BOOL)shouldDisplayContacts {
    isLoadingContacts = YES;

    // address book functionality is done on an async queue to prevent UI locking
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );

        NSArray * peopleArray = [(__bridge NSArray*) allPeople mutableCopy];

        CFRelease(allPeople);

        NSMutableArray *allContacts = [NSMutableArray array
                                       ];

        for (id person in peopleArray){
            // Get the address properties.
            NSString *street, *city, *state, *zip;
            BOOL hasAddress = NO;
            ABMultiValueRef addresses = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonAddressProperty);
            for (CFIndex j = 0; j<ABMultiValueGetCount(addresses);j++){
                CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(addresses, j);
                street = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressStreetKey) copy];
                city = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressCityKey) copy];
                state = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressStateKey) copy];
                zip = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressZIPKey) copy];

                if (street && city && state) {
                    NSLog(@"Found address: %@", dict);
                    hasAddress = YES;
                    CFRelease(dict);
                    break;
                }
                CFRelease(dict);
            }
            CFRelease(addresses);

            if (!hasAddress)
                continue;

            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(NSString*)CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)person, kABPersonFirstNameProperty)), @"firstName", (NSString*)CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)person, kABPersonLastNameProperty)), @"lastName", nil];

            dict[@"name"] = [NSString stringWithFormat:@"%@ %@", (dict[@"firstName"]?dict[@"firstName"]:@""), (dict[@"lastName"]?dict[@"lastName"]:@"")];

            if (street)
                dict[@"street"] = street;
            if (city)
                dict[@"city"] = city;
            if (state)
                dict[@"state"] = state;
            if (zip)
                dict[@"zip"] = zip;

            [allContacts addObject:dict];
        }
        CFRelease(addressBook);

        dispatch_sync(dispatch_get_main_queue(), ^{
            // create addresses
            for (NSDictionary *dict in allContacts) {
                NSArray *oldAddresses = [[Address where:@{@"name": dict[@"name"]}] all];
                if ([oldAddresses count] == 0) {
                    Address *newAddress = [Address createWithInfo:dict inContext:_appDelegate.managedObjectContext];
                }
            }

            // create models
            [alert dismissWithClickedButtonIndex:0 animated:NO];
            isLoadingContacts = NO;
            requestedContacts = YES;

            if (shouldDisplayContacts)
                [self.inputExistingRecipient becomeFirstResponder];
        });
    });
}

@end
