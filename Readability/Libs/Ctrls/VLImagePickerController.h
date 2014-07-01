
#import <Foundation/Foundation.h>

@class VLImagePickerController;

typedef void (^VLImagePickerController_ResultBlock)(UIImage *image);

@interface VLImagePickerController : NSObject
	<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
@private
	UIView *_parentView;
	CGRect _parentViewRect;
	UIPopoverController *_popover;
	UIImagePickerControllerSourceType _sourceType;
	NSString *_pathToChosenVideo;
	BOOL _canPickVideo;
	BOOL _doNotPickImage;
	BOOL _isImageSelected;
	BOOL _isCanceled;
}

@property(nonatomic, strong) UIImagePickerController *ctr;

@property(nonatomic, readonly) UIImagePickerControllerSourceType sourceType;
@property(nonatomic, readonly) NSString *pathToChosenVideo;
@property(nonatomic, assign) BOOL canPickVideo;
@property(nonatomic, assign) BOOL doNotPickImage;
@property (nonatomic, strong) VLImagePickerController_ResultBlock resultBlock;


+ (VLImagePickerController *)shared;

- (void)showWithSource:(UIImagePickerControllerSourceType)sourceType 
		fromParentView:(UIView *)parentView
				  rect:(CGRect)rect
		   orBarButton:(UIBarButtonItem*)barButton
		   resultBlock:(VLImagePickerController_ResultBlock)resultBlock;

@end
