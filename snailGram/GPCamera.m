//  Created by Bobby Ren on 11/28/13.

#import "GPCamera.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <ImageIO/ImageIO.h>
#import "GPCameraDelegate.h"
#import "UIImage+Resize.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIAlertView+MKBlockAdditions.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation GPCamera

-(void)startCameraFrom:(UIViewController *)presenter {

    _picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.showsCameraControls = NO;
    }
    else
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    _picker.toolbarHidden = YES; // hide toolbar of app, if there is one.
    _picker.wantsFullScreenLayout = YES;
    _picker.delegate = self;

    if (_picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        if (![GPCamera requestedSaveToAlbum]) {
            [GPCamera requestAccessToPhotosWithCompletion:^(BOOL granted){
                if (granted) {
                    [presenter presentViewController:_picker animated:YES completion:nil];
                }
            }];
        }
        else if (![GPCamera canSaveToAlbum]) {
            // no access to album
            [UIAlertView alertViewWithTitle:@"Cannot take photo" message:@"Your device does not have a camera, and you did not allow camera roll access."];
        }
        else {
            [presenter presentViewController:_picker animated:YES completion:nil];
        }
    }
    else {
        [presenter presentViewController:_picker animated:YES completion:nil];
    }

}

-(void)addOverlayWithFrame:(CGRect)frame {
    // Initialization code

    if (_picker.sourceType != UIImagePickerControllerSourceTypeCamera)
        return;

    CALayer *top = [[CALayer alloc] init];
    top.frame = CGRectMake(0, 0, CAMERA_SIZE, CAMERA_TOP_OFFSET);
    top.backgroundColor = [[UIColor blackColor] CGColor];
    /*
    CALayer *bottom = [[CALayer alloc] init];
    bottom.frame = CGRectMake(0, CAMERA_TOP_OFFSET + CAMERA_SIZE, CAMERA_SIZE, frame.size.height - (CAMERA_TOP_OFFSET + CAMERA_SIZE));
    bottom.backgroundColor = [[UIColor blackColor] CGColor];
     */

    overlay = [[UIView alloc] initWithFrame:frame];
    [overlay.layer addSublayer:top];
    //[overlay.layer addSublayer:bottom];

    buttonCamera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    [buttonCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [buttonCamera setContentMode:UIViewContentModeCenter];
    [buttonCamera setBackgroundColor:[UIColor clearColor]];
    [buttonCamera setCenter:CGPointMake(160, frame.size.height - 100)];
    [buttonCamera addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];

    /*
    buttonLibrary = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonLibrary setFrame:CGRectMake(0, 0, 80, 40)];
    [buttonLibrary setTitle:@"Library" forState:UIControlStateNormal];
    [buttonLibrary setTintColor:[UIColor whiteColor]];
    [buttonLibrary setCenter:CGPointMake(260, frame.size.height - bottom.frame.size.height / 2)];
    [buttonLibrary addTarget:self action:@selector(showLibrary) forControlEvents:UIControlEventTouchUpInside];
     */

    buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCancel setFrame:CGRectMake(0, 0, 80, 40)];
    [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [buttonCancel setTintColor:[UIColor whiteColor]];
    [buttonCancel setCenter:CGPointMake(60, 30)];
    [buttonCancel addTarget:self.delegate action:@selector(dismissCamera) forControlEvents:UIControlEventTouchUpInside];

    buttonRotate = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRotate setFrame:CGRectMake(0, 0, 80, 40)];
    [buttonRotate setBackgroundColor:[UIColor clearColor]];
    [buttonRotate setCenter:CGPointMake(280, 30)];
    [buttonRotate setImage:[UIImage imageNamed:@"rotateCamera"] forState:UIControlStateNormal];
    [buttonRotate addTarget:self action:@selector(rotateCamera) forControlEvents:UIControlEventTouchUpInside];

    [overlay addSubview:buttonCamera];
    [overlay addSubview:buttonCancel];
//    [overlay addSubview:buttonLibrary];
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [overlay addSubview:buttonRotate];
    }

    [_picker setCameraOverlayView:overlay];
}

-(void)takePicture {
    [_picker takePicture];
}

-(void)showLibrary {
    UIImagePickerController *library = [[UIImagePickerController alloc] init];
    library.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    library.toolbarHidden = YES; // hide toolbar of app, if there is one.
    library.wantsFullScreenLayout = YES;
    library.delegate = self;

    [_picker presentViewController:library animated:YES completion:nil];
}

-(void)rotateCamera {
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        return;
    }

    if(_picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else {
        _picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

#pragma mark ImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // select from photo library or capture
    DebugLog(@"Completed");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // resize/crop
    float width = image.size.width;
    float y0 = CAMERA_TOP_OFFSET * width / 320; // this value adjusts the top offset
    // this function doesn't do what we think. the second value seems to scale.
    image = [image croppedImage:CGRectMake(y0, 0, width-y0/2, width-y0/2) orientation:image.imageOrientation];

    float factor = .5;
    CGSize size = CGSizeMake(image.size.width*factor, image.size.height*factor);
    UIImage *resizedImage = [image resizedImage:size interpolationQuality:kCGInterpolationDefault];

    [GPCamera getMetaForInfo:info withCompletion:^(NSDictionary *result) {
        [self.delegate didSelectPhoto:resizedImage meta:result];

        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && result) {
            // save a larger res to the album. also, [image resizedImage:] doesn't store orientation correctly, but shows up correctly on AWS and viewer
            if (![GPCamera requestedSaveToAlbum]) {
                [GPCamera requestAccessToPhotosWithCompletion:^(BOOL granted) {
                    [GPCamera saveToAlbum:image meta:result];
                }];
            }
            else {
                [GPCamera saveToAlbum:image meta:result];
            }
        }
    }];

    [self.delegate dismissCamera];
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    DebugLog(@"Cancelled");
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self.delegate dismissCamera];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark ALASsetsLibrary
+ (void)setUserComment:(NSString*)comment meta:(NSDictionary *)meta {
    [meta[kPhotoExifKey] setObject:comment forKey:(NSString*)kCGImagePropertyExifUserComment];
}
+ (void)setDescription:(NSString*)description meta:(NSDictionary *)meta  {
    [meta[kPhotoTiffKey] setObject:description forKey:(NSString*)kCGImagePropertyTIFFImageDescription];
}

#pragma mark general camera functions

+(void)requestAccessToPhotosWithCompletion:(void(^)(BOOL))completion {
    // request access
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        DebugLog(@"Need authorization for camera roll");
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"camera:albumAccess:requested"];
        // request by loading a default asset
        [UIAlertView alertViewWithTitle:@"Access to album" message:@"Allow Pact to save and load photos from your camera roll?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] onDismiss:^(int buttonIndex) {
            //ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            //[lib assetForURL:[NSURL URLWithString:@"assets-library://asset/asset.JPG?id=test&ext=JPG"] resultBlock:nil failureBlock:nil];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"camera:saveToAlbum"];
            if (completion)
                completion(YES);
        } onCancel:^{
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"camera:saveToAlbum"];
            if (completion)
                completion(NO);
        }];
    }
}

+(BOOL)requestedSaveToAlbum {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"camera:albumAccess:requested"] boolValue])
        return YES;
    return NO;
}

+(BOOL)canSaveToAlbum {
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || ([self requestedSaveToAlbum] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"camera:saveToAlbum"] boolValue] == NO))
        return NO;
    return YES;
}

+(void)getMetaForInfo:(NSDictionary *)info withCompletion:(void(^)(NSDictionary *))completion {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        if (url) {
            ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
            [assetsLib assetForURL:url resultBlock:^(ALAsset *asset) {
                completion([[asset defaultRepresentation] metadata]);
            } failureBlock:^(NSError *error) {
                completion(nil);
            }];
        }
        else {
            completion([info objectForKey:UIImagePickerControllerMediaMetadata]);
        }
    }
}

+(BOOL)saveToAlbum:(UIImage *)image meta:(NSDictionary *)meta {
    // save to album
    if (![self canSaveToAlbum])
        return NO;
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        [UIAlertView alertViewWithTitle:@"Cannot save to album" message:@"Pact could not access your camera roll. Please go to your phone Settings->Privacy to change this." cancelButtonTitle:@"Skip" otherButtonTitles:@[@"Never save"] onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"camera:albumAccess:requested"];
                [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"camera:saveToAlbum"];
            }
        } onCancel:nil];
        return NO;
    }

    NSMutableDictionary *cachedMeta = [meta mutableCopy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:image meta:cachedMeta toAlbum:@"Pact" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                DebugLog(@"Image could not be saved!");
            }
            else {
                DebugLog(@"Saved to album with meta: %@", cachedMeta);
            }
        }];
    });

    return YES;
}
@end
