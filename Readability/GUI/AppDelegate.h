
#import <UIKit/UIKit.h>
#import "../Libs/Classes.h"
#import "../API/Classes.h"
#import "Main/Classes.h"
//#import "User/Classes.h"

@interface AppDelegate : VLAppDelegateBase
{
@private
	UIWindow *_window;
	YTRootNavigationController *_rootNavigationVC;
	YTBaseViewController *_slidingVC;
	UIBackgroundTaskIdentifier _backgroundTaskId;
	VLTimer *_timer;
}

@property(nonatomic, readonly) YTRootNavigationController *rootNavigationVC;
@property(nonatomic, readonly) UIWindow *window;


+ (AppDelegate *)sharedAppDelegate;

@end
