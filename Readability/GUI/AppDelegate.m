
#import "AppDelegate.h"
#import "YTUiMediator.h"
#import "TestFlight.h"
#import "YTCommon.h"
#import "../API/Managers/Classes.h"
#import "../API/Sync/YTSyncManager.h"
#import <CoreData/CoreData.h>

@implementation AppDelegate

@synthesize rootNavigationVC = _rootNavigationVC;
@synthesize window = _window;

+ (AppDelegate*)sharedAppDelegate
{
	return ObjectCast([VLAppDelegateBase sharedAppDelegateBase], AppDelegate);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    NSLog(@"appDelegate did finish launching with options");
    
	[VLTimer setTimerIntervalMultiplier:kYTTimerIntervalMultiplier];
	   
	[VLLogger shared].loggingDisabled = !kYTLoggingEnabled;
	if(kYTLogToFile) {
		[[VLLogger shared] setMaxLogFileSizes:kYTMaxLogFileSizes];
		[[VLLogger shared] enableLoggingToFile];
	}
	
#ifdef kYTIsBeta
	// !!!: Use the next line only during beta:
	//[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
	//[TestFlight setDeviceIdentifier:[VLAppDelegateBase applicationInstanceIdentifier]];
	[TestFlight takeOff:kYTTestFlightAppToken];
#else
#endif
	
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	if(kIosVersionFloat >= 7.0)
		[application setStatusBarStyle:UIStatusBarStyleLightContent];
    [application setStatusBarHidden:NO];
	application.applicationSupportsShakeToEdit = NO;
	_backgroundTaskId = UIBackgroundTaskInvalid;
	application.applicationIconBadgeNumber = 0;
	
    
    
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    directoryURL = [directoryURL URLByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier isDirectory:YES];
    
    NSLog(@"directory url is %@", directoryURL);
    
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:NULL];
    
    
    //setups database manager
    [[DatabaseManager sharedManager] setupContext];
    
    //setus sync manager and ensables syncing
    // Setup Sync Manager
    YTSyncManager *syncManager = [YTSyncManager sharedSyncManager];
    syncManager.managedObjectContext = [DatabaseManager sharedManager].managedObjectContext;
    
    NSLog(@"store path is %@", [[[DatabaseManager sharedManager] urlForPersistentStore] path]);
    
    syncManager.storePath = [[[DatabaseManager sharedManager] urlForPersistentStore] path];
    [syncManager setup];
    
    [YTNotebookManager sharedManager];
    [YTNoteManager sharedManager];
    [YTLocationManager sharedManager];
    [YTTagManager sharedManager];
    
	[VLActivityView setDefaultBackgroundcolor:kYTProgressIndicatorBackColor];
	[VLActivityView setDefaultCenterBackcolor:kYTProgressIndicatorCenterBackColorTransparent];
	[VLActivityView setDefaultDimBackground:NO];
	
	[[VLMessageCenter shared] setTimerInterval:kYTMessageCenterTimerInterval];
//	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
//	[VLIapCommon initializeWithIsSandbox:kYTDebugMode];
	//[[YTStorageManager shared] initialize];
	//[[YTResourcesStorage shared] initialize];
	[VLImageCache shared].maxAllPixelsAmount = kYTImageCachMaxAllPixelsAmount;
	//[YTCachedImageStore shared];

	//[[YTDatabaseManager shared] initializeMT];
	//[[YTEntitiesManagersLister shared] initializeMT];
	   
    /*
     NSTimeInterval tm1 = [[NSProcessInfo processInfo] systemUptime];     
	[[VLMessageCenter shared] performBlock:^{
		[[YTDatabaseManager shared] initializeWithResultBlockMT:^{
			[[YTEntitiesManagersLister shared] initializeWithResultBlockMT:^{
				NSTimeInterval tm2 = [[NSProcessInfo processInfo] systemUptime];
				VLLoggerTrace(@"DB initialization %0.4f s", tm2 - tm1);
			}];
		}];
	} afterDelay:0.01 ignoringTouches:YES];
     */
     
	//[YTPhotoPreviewMaker shared];
	[[YTFontsManager shared] initialize];
	[[YTNoteTableCellViewManager shared] initialize];
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *curAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *lastAppVersion = [defs objectForKey:kYTCurrentAppVersionKey];
	if(!lastAppVersion)
		lastAppVersion = @"0.0";
	if(![lastAppVersion isEqual:curAppVersion]) {
		[defs setObject:curAppVersion forKey:kYTCurrentAppVersionKey];
		[defs synchronize];
	}
	NSString *curAppBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *lastAppBuild = [defs objectForKey:kYTCurrentAppBuildKey];
	if(!lastAppBuild)
		lastAppBuild = @"0";
	if(![lastAppBuild isEqual:curAppBuild]) {
		[defs setObject:curAppBuild forKey:kYTCurrentAppBuildKey];
		[defs synchronize];
	}
	
	//[[YTDatabaseManager shared] waitingUntilDone:YES performBlockOnDT:^{
	//	[[YTDatabaseManager shared] cleanDatabase];
	//}];
	
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	_rootNavigationVC = [[YTRootNavigationController alloc] init];
	_rootNavigationVC.navigationBarHidden = YES;

	_slidingVC = [[YTBaseViewController alloc] initWithViewClass:[YTSlidingContainerView class]];
	[_rootNavigationVC pushViewController:_slidingVC animated:NO];
	
	_window.rootViewController = _rootNavigationVC;
	super.rootViewController = _rootNavigationVC;
	
	[_window makeKeyAndVisible];
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 1.0;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	[_timer start];
	

    /*
    //lets perform sync
    NSLog(@"will synchronize");
    [[YTSyncManager sharedSyncManager] synchronizeWithCompletion:^(NSError *error) {
        NSLog(@"synching complete");
        if (error != nil) {
            NSLog(@"error is %@", error);
        }
    }];
    */ 
    
	return YES;
}

- (void)onTimerEvent:(id)sender
{
	if(_backgroundTaskId != UIBackgroundTaskInvalid) {
		UIApplication *app = [UIApplication sharedApplication];
		NSTimeInterval timeRemaining = [app backgroundTimeRemaining];
		if(timeRemaining < 30.0) { // Stop app before it is terminated
			VLLogEvent(@"Ending background task (timeRemaining < 30.0)");
			[app endBackgroundTask:_backgroundTaskId];
			_backgroundTaskId = UIBackgroundTaskInvalid;
			return;
		}
	}
	YTNoteEditView *noteEditView = (YTNoteEditView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteEditView class] parentView:self.rootViewController.view];
	[YTApiMediator shared].isShowingMainView = (noteEditView == nil);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    
    UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [context performBlock:^{
            if ([context hasChanges]) {
                [context save:NULL];
            }
            
            [[YTSyncManager sharedSyncManager] synchronizeWithCompletion:^(NSError *error) {
                NSLog(@"sync completed");
                if (error != nil) {
                    NSLog(@"with error: %@", error);
                }
                [[UIApplication sharedApplication] endBackgroundTask:identifier];
            }];
        }];
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[YTSyncManager sharedSyncManager] synchronizeWithCompletion: ^(NSError *error) {
        NSLog(@"sync completed");
        if (error != nil) {
            NSLog(@"with error: %@", error);
        }
    }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[super applicationWillResignActive:application];
	BOOL isBackgroundSupported = NO;
	UIDevice* device = [UIDevice currentDevice];
	if([device respondsToSelector:@selector(isMultitaskingSupported)])
		isBackgroundSupported = [device isMultitaskingSupported];
	if(   isBackgroundSupported
	   && kYTAllowSyncInBackground
//	   && [YTSyncManager shared].processing
	   && [VLDeviceManager isInternetAvailable]
	   ) {
		VLLogEvent(@"Try begin background task");
		UIApplication *app = [UIApplication sharedApplication];
		_backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^(void) {
			if(_backgroundTaskId != UIBackgroundTaskInvalid) {
				VLLogEvent(@"BackgroundTaskWithExpirationHandler called. Ending background task.");
				[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
				_backgroundTaskId = UIBackgroundTaskInvalid;
			}
		}];
		if(_backgroundTaskId != UIBackgroundTaskInvalid) {
			VLLogEvent(@"Succeed begin background task");
			NSTimeInterval time = [app backgroundTimeRemaining];
			VLLogEvent(([NSString stringWithFormat:@"Background task: %f seconds remaining", time]));
		} else {
			VLLogEvent(@"Failed begin background task");
		}
	}
	if([application respondsToSelector:@selector(setMinimumBackgroundFetchInterval:)]) {

        /**TODO:: user management is off
         //and it looks like this is used for syncing
		YTUsersEnManager *manrUser = [YTUsersEnManager shared];
		if(manrUser.isLoggedIn && !manrUser.isDemo) {
			NSTimeInterval minimumBackgroundFetchInterval = UIApplicationBackgroundFetchIntervalMinimum;
			//NSTimeInterval minimumBackgroundFetchInterval = kYTMinimumBackgroundFetchInterval;
			[application setMinimumBackgroundFetchInterval:minimumBackgroundFetchInterval];
			VLLoggerTrace(@"setMinimumBackgroundFetchInterval: %f", minimumBackgroundFetchInterval);
		} else {
			[application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
		}
        */
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	NSDictionary *userInfo = notification.userInfo ? notification.userInfo : [NSDictionary dictionary];
	NSString *noteGuid = [userInfo stringValueForKey:kYTJsonKeyNoteGUID defaultVal:@""];
	if(![NSString isEmpty:noteGuid]) {
		YTNote *note = [[YTNoteManager sharedManager] getNoteByGuid:noteGuid];
		if(note) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kDefaultAnimationDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				if([YTNotesTableView currentInstance])
					[[YTNotesTableView currentInstance] showNote:note animated:YES];
			});
		}
	}
}

/*
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	YTUsersEnManager *manrUser = [YTUsersEnManager shared];
	if(!manrUser.isLoggedIn || manrUser.isDemo) {
		[application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
		completionHandler(UIBackgroundFetchResultNoData);
		return;
	}
	YTSyncManager *manrSync = [YTSyncManager shared];
	[manrSync startSyncMTWithResultBlockMT:^(NSError *error) {
		if(error) {
			VLLoggerError(@"%@", error);
		}
		completionHandler(UIBackgroundFetchResultNewData);
	}];
}
*/ 



@end

