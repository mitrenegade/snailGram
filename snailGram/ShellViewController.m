//
//  ShellViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "ShellViewController.h"
#import "FrontEditorViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "PostCard+Parse.h"
#import "AWSHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "GPCamera.h"

@interface ShellViewController ()

@end

@implementation ShellViewController

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

    [self.canvas.layer setBorderWidth:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickButton:(id)sender {
    if (!camera) {
        camera = [[GPCamera alloc] init];
        [camera setDelegate:self];
    }

    UIButton *button = (UIButton *)sender;
    if (button == self.buttonCamera) {
        [camera startCameraFrom:self];
        [camera addOverlayWithFrame:_appDelegate.window.bounds];
    }
    else if (button == self.buttonLibrary) {
        UIImagePickerController *library = [[UIImagePickerController alloc] init];
        library.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        library.toolbarHidden = YES; // hide toolbar of app, if there is one.
        library.delegate = camera;

        [self presentViewController:library animated:YES completion:nil];
    }
}

-(void)imageSaved {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [self performSegueWithIdentifier:@"PushFrontEditor" sender:nil];
}

-(void)startImageUpload {
    [AWSHelper uploadImage:selectedImage withName:[self keyForPhoto] toBucket:AWS_BUCKET withCallback:^(NSString *url) {
        NSLog(@"Final url: %@", url);
        self.postCard.image_url = [AWSHelper urlForPhotoWithKey:[self keyForPhoto]];
        [self.postCard saveOrUpdateToParseWithCompletion:^(BOOL success) {
            [self imageSaved];
        }];
    }];
}

-(NSString *)keyForPhoto {
    return self.postCard.parseID;
}

#pragma mark Segue preparation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushFrontEditor"]) {
        FrontEditorViewController *controller = [segue destinationViewController];
        controller.image = selectedImage;
    }
}

#pragma mark Camera Delegate
-(void)dismissCamera {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didSelectPhoto:(UIImage *)photo meta:(NSDictionary *)meta {
    alertView = [UIAlertView alertViewWithTitle:@"Uploading photo..." message:nil cancelButtonTitle:nil otherButtonTitles:nil onDismiss:nil onCancel:nil];

    //selectedImage = [UIImage imageNamed:@"DSC_0377.jpg"];
    selectedImage = photo;

    if (!self.postCard) {
        self.postCard = (PostCard *)[PostCard createEntityInContext:_appDelegate.managedObjectContext];
        self.postCard.message = @"";
        self.postCard.to = nil;
        self.postCard.text = nil;
        self.postCard.image_url = @""; // todo: upload image to AWS then store url

        // if postCard doesn't exist on Parse yet, we don't have an image key
        [self.postCard saveOrUpdateToParseWithCompletion:^(BOOL success) {
            if (success) {
                [self startImageUpload];
            }
        }];
    }
    else {
        // if postCard already exists, start image upload
        [self startImageUpload];
    }
}
@end
