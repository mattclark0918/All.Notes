
#import "YTELCImagePickerController.h"
#import "../../Libs/Classes.h"

static int _showsCounter;

@implementation YTELCImagePickerController

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)showWithAssetsLibrary: (ALAssetsLibrary*) assetsLib ResultBlock:(YTELCImagePickerController_ResultBlock)resultBlock {
    NSLog(@"showWithAssetsLibrary");
    
	if(_resultBlock) {
		_resultBlock = nil;
	}
	_showsCounter++;
    
    self.resultBlock = resultBlock;
    
//	if(resultBlock)
//		_resultBlock = [resultBlock copy];
	ELCImagePickerController *picker = [[ELCImagePickerController alloc] initWithSelectDefultGroupOnShow:YES AssetsLibrary: assetsLib];

	picker.maximumImagesCount = INT_MAX;
	picker.imagePickerDelegate = self;
	[picker view]; // Force to load view
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
		return picker.albumPicker.defaultGroupShown;
	} ignoringTouches:YES completeBlock:^{
		if(kIosVersionFloat >= 7.0)
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
		[[VLAppDelegateBase sharedAppDelegateBase].topModalViewController presentViewController:picker animated:YES completion:^{
		}];
	}];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    
	if(kIosVersionFloat >= 7.0)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:[info count]];
	for(NSDictionary *dict in info) {
		ALAsset *asset = [dict objectForKey:@"asset"];
		[assets addObject:asset];
	}
    NSLog(@"assets is %@", assets);
    
	[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:picker animated:YES];
    
    NSLog(@"assets[2] is %@", assets);
    
    
	if(_resultBlock) {
        NSLog(@"calling result block");
		_resultBlock(assets);
		_resultBlock = nil;
	}
	_showsCounter--;
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
	if(kIosVersionFloat >= 7.0)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:picker animated:YES];
	if(_resultBlock) {
		_resultBlock([NSArray array]);
		_resultBlock = nil;
	}
	_showsCounter--;
}

+ (BOOL)isShown {
	return (_showsCounter > 0);
}

- (void)dealloc {
	if(_resultBlock) {
		_resultBlock = nil;
	}
}

@end

