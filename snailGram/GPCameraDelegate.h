//  Created by Bobby Ren on 11/28/13.

#import <Foundation/Foundation.h>

@protocol GPCameraDelegate <NSObject>
-(void)dismissCamera;
-(void)didSelectPhoto:(UIImage *)photo meta:(NSDictionary *)meta;
@end
