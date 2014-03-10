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

//    [self.imageView.layer setBorderWidth:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    selectedImage = [UIImage imageNamed:@"DSC_0377.jpg"];
    if (button == self.buttonCamera) {

    }
    else if (button == self.buttonLibrary) {
        
    }

    if (!self.postCard) {
        self.postCard = (PostCard *)[PostCard createEntityInContext:_appDelegate.managedObjectContext];
        self.postCard.message = @"";
        self.postCard.to = nil;
        self.postCard.from = nil;
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

    [self performSegueWithIdentifier:@"PushFrontEditor" sender:nil];
}

-(void)startImageUpload {
    [AWSHelper uploadImage:selectedImage withName:[self keyForPhoto] toBucket:AWS_BUCKET withCallback:^(NSString *url) {
        NSLog(@"Final url: %@", url);
        self.postCard.image_url = [AWSHelper urlForPhotoWithKey:[self keyForPhoto]];
        [self.postCard saveOrUpdateToParseWithCompletion:nil];
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

@end
