//  Created by Bobby Ren on 11/28/13.

#import <Foundation/Foundation.h>
static const NSString *kPhotoTiffKey = @"{TIFF}";
static const NSString *kPhotoTiffTimestampKey = @"DateTime";
static const NSString *kPhotoTiffMakeModel = @"Make";
static const NSString *kPhotoExifKey = @"{Exif}";
static const NSString *kPhotoExifTimestampKey = @"DateTimeDigitized";

#define CAMERA_SIZE 320
#define CAMERA_TOP_OFFSET 60
@interface GPCamera : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *_picker;

    UIView *overlay;
    UIButton *buttonCamera;
    UIButton *buttonCancel;
    UIButton *buttonLibrary;
    UIButton *buttonRotate;
}
@property (nonatomic) id delegate;
+(void)setUserComment:(NSString*)comment meta:(NSDictionary *)meta;
+(void)setDescription:(NSString*)description meta:(NSDictionary *)meta;
+(BOOL)saveToAlbum:(UIImage *)image meta:(NSDictionary *)meta;
+(void)getMetaForInfo:(NSDictionary *)info withCompletion:(void(^)(NSDictionary *))completion;
+(void)requestAccessToPhotosWithCompletion:(void(^)(BOOL))completion;
+(BOOL)requestedSaveToAlbum;
+(BOOL)canSaveToAlbum;

// camera must be initialized in this order
-(void)startCameraFrom:(UIViewController *)presenter;
-(void)addOverlayWithFrame:(CGRect)frame;
-(void)takePicture;
-(void)rotateCamera;
@end
