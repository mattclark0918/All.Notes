
#import "VLImagePickerController.h"
#import "../Logic/Classes.h"
#import "../Ctrls/Classes.h"
#import "../System/Classes.h"
#import "../Drawing/Classes.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation VLImagePickerController

@synthesize sourceType = _sourceType;
@synthesize pathToChosenVideo = _pathToChosenVideo;
@synthesize canPickVideo = _canPickVideo;
@synthesize doNotPickImage = _doNotPickImage;

+ (VLImagePickerController *)shared
{
	static VLImagePickerController *_shared = nil;
	if(!_shared)
		_shared = [[VLImagePickerController alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		
	}
	return self;
}

- (void)showWithSource:(UIImagePickerControllerSourceType)sourceType 
		fromParentView:(UIView *)parentView
				  rect:(CGRect)rect
		   orBarButton:(UIBarButtonItem*)barButton
		   resultBlock:(VLImagePickerController_ResultBlock)resultBlock
{
    
    NSLog(@"VLImagePickerController::showWithSource");
    
	_pathToChosenVideo = nil;
	_resultBlock = resultBlock;// [resultBlock copy];
	_parentView = parentView;
	_parentViewRect = rect;
	if(_parentViewRect.size.width < 1)
		_parentViewRect.size.width = 1;
	if(_parentViewRect.size.height < 1)
		_parentViewRect.size.height = 1;
	UIViewController *holderVC = [[VLAppDelegateBase sharedAppDelegateBase] topModalViewController];
	if(!_ctr)
	{
		_ctr = [[UIImagePickerController alloc] init];
		NSMutableArray *mediaTypes = [NSMutableArray arrayWithArray:_ctr.mediaTypes];
		NSString *movieType = (NSString *)kUTTypeMovie;
		if(_canPickVideo) {
			if(![mediaTypes containsObject:movieType])
				[mediaTypes addObject:movieType];
		} else {
			if([mediaTypes containsObject:movieType])
				[mediaTypes removeObject:movieType];
		}
		NSString *imageType = (NSString *)kUTTypeImage;
		if(_doNotPickImage) {
			if([mediaTypes containsObject:imageType])
				[mediaTypes removeObject:imageType];
		}
		_ctr.mediaTypes = mediaTypes;
	}
    
    _ctr.delegate = self;
    
	_sourceType = sourceType;
	_ctr.sourceType = _sourceType;
	_isImageSelected = NO;
	_isCanceled = NO;
	if(IsUiIPad)
	{
		if(!_popover)
		{
			_popover = [[UIPopoverController alloc] initWithContentViewController:_ctr];         
			_popover.delegate = self;
		}
		if(barButton)
			[_popover presentPopoverFromBarButtonItem:barButton
							 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		else
			[_popover presentPopoverFromRect:_parentViewRect inView:_parentView
				permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
		[holderVC presentViewController:_ctr animated:YES completion:^{
		}];
}

- (void)finishWithImage:(UIImage *)image {
    
    NSLog(@"finishWithImage");
    
	if(image)
		_isImageSelected = YES;
	else
		_isCanceled = YES;
	if(_resultBlock) {
		VLImagePickerController_ResultBlock resultBlock = [_resultBlock copy];
		_resultBlock = nil;
		resultBlock(image);
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"imagePickerController:didFinishPickingImage");
    
	_isImageSelected = YES;
	if(_popover)
		[_popover dismissPopoverAnimated:YES];
	else
		[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:_ctr animated:YES];
    
	[self finishWithImage:image];

//	NSLog(@"making ctr nil");
//    _ctr = nil;
    
}
- (void)imagePickerController:(UIImagePickerController *)picker
	didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSLog(@"imagePickerController:didFinishPickingMediaWithInfo");
    
    
	/*Printing description of info:
	 {
	 UIImagePickerControllerMediaType = "public.movie";
	 UIImagePickerControllerMediaURL = "file://localhost/private/var/mobile/Applications/DC86D944-E39E-49BA-96AA-3A0703A92CDD/tmp//trim.3UDzaz.MOV";
	 UIImagePickerControllerReferenceURL = "assets-library://asset/asset.MOV?id=7D0895E2-9D6D-4724-9811-F62DBD7200A3&ext=MOV";
	 }*/
	_isImageSelected = YES;
	NSString *sMediaType = [info objectForKey:UIImagePickerControllerMediaType];
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSString *movieType = (NSString *)kUTTypeMovie;
	if([sMediaType isEqual:movieType]) {
		_pathToChosenVideo = nil;
		NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
		if(url)
			_pathToChosenVideo = [url path];
	}
	if(_popover)
		[_popover dismissPopoverAnimated:YES];
	else
		[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:_ctr animated:YES];
	[self finishWithImage:image];
    
//	NSLog(@"making ctr nil 2");
//    _ctr = nil;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    NSLog(@"imagePickerControllerDidCancel");
    
    
	_isCanceled = YES;
	if(_popover)
		[_popover dismissPopoverAnimated:YES];
	else
		[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:_ctr animated:YES];
	[self finishWithImage:nil];
    
//	NSLog(@"making ctr nil 3");
//    _ctr = nil;
    
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
	return YES;
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	if(!_isImageSelected && !_isCanceled) {
		[self finishWithImage:nil];
	}
    
//	NSLog(@"making ctr nil 4");
//    _ctr = nil;
}


@end

