
#import "VLAlertView.h"
#import "../Common/Classes.h"

@implementation VLAlertView

+ (void)showWithOkAndTitle:(NSString*)title message:(NSString*)message
{
	[[[UIAlertView alloc] initWithTitle:title
								 message:message
								delegate:nil
					   cancelButtonTitle:[VLStringResources shared].buttonOK
					   otherButtonTitles:nil] show];
}

+ (void)showWithOkAndTitle:(NSString*)title message:(NSString*)message resultBlock:(void (^)())resultBlock
{
	VLAlertView *view = [[VLAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil
										  cancelButtonTitle:[VLStringResources shared].buttonOK
										  otherButtonTitles:nil];
	view.delegate = view;
	[view showWithResultBlock:^(int btnIndex, NSString *btnTitle)
	{
		resultBlock();
	}];
}

+ (void)showWithYesNoTitle:(NSString*)title message:(NSString*)message resultBlock:(void (^)(BOOL yesTapped))resultBlock
{
	VLAlertView *view = [[VLAlertView alloc] init];
	view.title = title;
	view.message = message;
	[view addButtonWithTitle:[VLStringResources shared].buttonYes];
	[view addButtonWithTitle:[VLStringResources shared].buttonNo];
	view.cancelButtonIndex = 1;
	view.delegate = view;
	[view showWithResultBlock:^(int btnIndex, NSString *btnTitle)
	{
		resultBlock(btnIndex == 0);
	}];
}

- (void)showWithResultBlock:(VLAlertView_ClickResultBlock)resultBlock
{
	self.delegate = self;
	_resultBlock = [resultBlock copy];
	[self show];
}

- (void)showOrSkip:(BOOL)skip withResultBlock:(VLAlertView_ClickResultBlock)resultBlock {
	if(skip) {
		resultBlock(-1, nil);
	} else {
		[self showWithResultBlock:resultBlock];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(_resultBlock)
	{
		VLAlertView_ClickResultBlock resultBlock = [_resultBlock copy];
		_resultBlock = nil;
		if(buttonIndex >= 0)
			resultBlock((int)buttonIndex, [self buttonTitleAtIndex:buttonIndex]);
		else
			resultBlock(-1, @"");
	}
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
	if(_resultBlock)
		[self alertView:self clickedButtonAtIndex:-1];
}



@end
