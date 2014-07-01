
#import "VLActionSheet.h"
#import "../Common/Classes.h"
#import "VLAppDelegateBase.h"

@implementation VLActionSheet

@synthesize result = _result;
@synthesize autoTapButtonIndex = _autoTapButtonIndex;

- (id)init
{
    self = [super init];
	if(self)
	{
		_autoTapButtonIndex = -1;
		self.delegate = self;
    }
    return self;
}

- (void)showAsyncFromView:(UIView*)view resultBlock:(VLActionSheet_ClickResultBlock)resultBlock
{
	if(_autoTapButtonIndex >= 0 && _autoTapButtonIndex < self.numberOfButtons - 1) {
		resultBlock(_autoTapButtonIndex, [self buttonTitleAtIndex:_autoTapButtonIndex]);
		return;
	}
	if(!view)
		view = [UIApplication sharedApplication].keyWindow;
	
	// Fix for iOS7 problem 'Sheet can not be presented because the view is not in a window':
	if(kIosVersionFloat >= 7 && view && view == [VLAppDelegateBase sharedAppDelegateBase].rootViewController.view) {
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		if(![window.subviews containsObject:view])
			view = [window.subviews lastObject];
	}
	
	if(_resultBlock)
	{
		_resultBlock = nil;
	}
	if(resultBlock)
		_resultBlock = [resultBlock copy];
	[super showInView:view];
}

- (void)showAsyncFromRect:(CGRect)rect
				   inView:(UIView *)view
			  orBarButton:(UIBarButtonItem*)barButton
			  resultBlock:(VLActionSheet_ClickResultBlock)resultBlock
{
	if(_autoTapButtonIndex >= 0 && _autoTapButtonIndex < self.numberOfButtons - 1) {
		resultBlock(_autoTapButtonIndex, [self buttonTitleAtIndex:_autoTapButtonIndex]);
		return;
	}
	if(!view)
		view = [UIApplication sharedApplication].keyWindow;
	_result = -1;
	if(_resultBlock)
	{
		_resultBlock = nil;
	}
	if(resultBlock)
		_resultBlock = [resultBlock copy];
	if(barButton)
		[super showFromBarButtonItem:barButton animated:YES];
	else
		[super showFromRect:rect inView:view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	_result = (int)buttonIndex;
	if(_resultBlock)
	{
		VLActionSheet_ClickResultBlock resultBlock = [_resultBlock copy];
		_resultBlock = nil;
		resultBlock((int)buttonIndex, (buttonIndex >= 0 && buttonIndex < [self numberOfButtons]) ? [self buttonTitleAtIndex:buttonIndex] : @"");
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	[self actionSheet:actionSheet clickedButtonAtIndex:-1];
}

- (void)dealloc
{
	self.delegate = nil;
}

@end
