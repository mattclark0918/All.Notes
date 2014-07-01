
#import <Foundation/Foundation.h>
#import "../ELCImagePicker/Classes.h"

@class YTELCImagePickerController;

typedef void (^YTELCImagePickerController_ResultBlock)(NSArray *assets);

@interface YTELCImagePickerController : NSObject <ELCImagePickerControllerDelegate> {
@private
}

@property (nonatomic, strong) YTELCImagePickerController_ResultBlock resultBlock;

- (void)showWithAssetsLibrary: (ALAssetsLibrary*) assetsLib ResultBlock:(YTELCImagePickerController_ResultBlock)resultBlock;
+ (BOOL)isShown;

@end