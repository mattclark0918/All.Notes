
#import "VLDelayedScreenActivity.h"
#import "../../API/Classes.h"

@implementation VLDelayedScreenActivity

- (id)init {
	self = [super init];
	if(self) {
		[[DatabaseManager sharedManager] checkIsMainThread];
	}
	return self;
}

- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay maxDuration:(NSTimeInterval)maxDuration checkForCancelBlock:(VLBlockCheck)checkForCancelBlock {
	[[DatabaseManager sharedManager] checkIsMainThread];
	[self cancelActivity];
	_activityShowDelay = delay;
	_maxDuration = maxDuration;
	_title = nil;
	if(title)
		_title = [title copy];
	if(_timer) {
		[_timer stop];
		_timer = nil;
	}
	if(checkForCancelBlock)
		_checkForCancelBlock = [checkForCancelBlock copy];
	_timer = [[VLTimer alloc] init];
	_timer.interval = 0.05;
	_timer.enabledAlwaysFiring = YES;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	_uptimeStart = [VLTimer systemUptime];
	[_timer start];
	if(!_started) {
		_started = YES;
		//[self retain];
	}
}

- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay checkForCancelBlock:(VLBlockCheck)checkForCancelBlock {
	[self startActivityWithTitle:title delay:delay maxDuration:0 checkForCancelBlock:checkForCancelBlock];
}

- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay {
	[self startActivityWithTitle:title delay:delay checkForCancelBlock:nil];
}

- (void)onTimerEvent:(id)sender {
	[[DatabaseManager sharedManager] checkIsMainThread];
	if(_checkForCancelBlock) {
		BOOL result = _checkForCancelBlock();
		if(result) {
			[self cancelActivity];
			return;
		}
	}
	NSTimeInterval uptime = [VLTimer systemUptime];
	if(!_activityShown) {
		if(uptime >= _uptimeStart + _activityShowDelay) {
			_activityShown = YES;
			[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
			[[VLActivityScreen shared] startActivityWithTitle:_title];
		}
	}
}

- (void)cancelActivity {
	if(_timer) {
		[[DatabaseManager sharedManager] checkIsMainThread];
		[_timer stop];
		_timer = nil;
	}
	if(_activityShown) {
		[[DatabaseManager sharedManager] checkIsMainThread];
		_activityShown = NO;
		[[VLActivityScreen shared] stopActivity];
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
	if(_checkForCancelBlock) {
		_checkForCancelBlock = nil;
	}
	if(_started) {
		_started = NO;
		//[self autorelease];
	}
}

- (BOOL)isMaxDurationExceeded {
	[[DatabaseManager sharedManager] checkIsMainThread];
	if(!_started || !_maxDuration)
		return NO;
	NSTimeInterval uptime = [VLTimer systemUptime];
	if(uptime >= _uptimeStart + _maxDuration)
		return YES;
	return NO;
}

- (void)dealloc {
	[self cancelActivity];
	if(_checkForCancelBlock) {
		_checkForCancelBlock = nil;
	}
	if(_timer) {
		[_timer stop];
		_timer = nil;
	}
}

@end

