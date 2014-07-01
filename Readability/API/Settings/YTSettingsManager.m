
#import "YTSettingsManager.h"
#import "YTWallpapersManager.h"

#define kSavedDataKey @"YTSettingsManager"
#define kSavedDataVersion (kYTManagersBaseVersion + 3)

static YTSettingsManager *_shared = nil;

@implementation YTSettingsManager

@synthesize syncOnWiFiOnly = _syncOnWiFiOnly;
@synthesize autoAddNoteLocation = _autoAddNoteLocation;
@dynamic saveTakenPhotosToCameraRoll;

+ (YTSettingsManager *)shared {
	if(!_shared) {
		_shared = [VLObjectFileStorage loadRootObjectWithKey:kSavedDataKey version:kSavedDataVersion];
		if(!_shared)
			_shared = [[YTSettingsManager alloc] init];
	}
	return _shared;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
        
        NSLog(@"YTSettingsManager::initWithCoder");
        
		_shared = self;
		
		_syncOnWiFiOnly = NO;
		_autoAddNoteLocation = YES;//NO;
		_saveTakenPhotosToCameraRoll = YES;//NO;
		_syncBackendMode = kYTSyncBackendICloud;
        
		if(aDecoder) {
			_syncOnWiFiOnly = [aDecoder decodeBoolForKey:@"_syncOnWiFiOnly"];
			if([aDecoder containsValueForKey:@"_autoAddNoteLocation"])
				_autoAddNoteLocation = [aDecoder decodeBoolForKey:@"_autoAddNoteLocation"];
			_saveTakenPhotosToCameraRoll = [aDecoder decodeBoolForKey:@"_saveTakenPhotosToCameraRoll"];
            
            if ([aDecoder containsValueForKey:@"_syncBackendMode"]) {
                _syncBackendMode = [aDecoder decodeIntForKey:@"_syncBackendMode"];
            }
            
		}
		
		[self.msgrVersionChanged addObserver:self selector:@selector(onVersionChanged:)];
		_savedDataVersion = self.version;
	}
	return self;
}

- (id)init {
	return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:_syncOnWiFiOnly forKey:@"_syncOnWiFiOnly"];
	[aCoder encodeBool:_autoAddNoteLocation forKey:@"_autoAddNoteLocation"];
	[aCoder encodeBool:_saveTakenPhotosToCameraRoll forKey:@"_saveTakenPhotosToCameraRoll"];
    [aCoder encodeInt:_syncBackendMode forKey:@"_syncBackendMode"];
}

- (void)onVersionChanged:(id)sender {
	if(_savedDataVersion != self.version) {
		VLLogEvent(@"Saving");
		[VLObjectFileStorage saveDataWithRootObject:self key:kSavedDataKey version:kSavedDataVersion];
		_savedDataVersion = self.version;
	}
}

- (void)setSyncOnWiFiOnly:(BOOL)syncOnWiFiOnly {
	if(_syncOnWiFiOnly != syncOnWiFiOnly) {
		_syncOnWiFiOnly = syncOnWiFiOnly;
		[self modifyVersion];
	}
}

- (void)setAutoAddNoteLocation:(BOOL)autoAddNoteLocation {
	if(_autoAddNoteLocation != autoAddNoteLocation) {
		_autoAddNoteLocation = autoAddNoteLocation;
		[self modifyVersion];
	}
}

- (void) setSyncBackendMode:(YTSyncBackendMode )syncBackendMode {
    if (_syncBackendMode != syncBackendMode) {
        _syncBackendMode = syncBackendMode;
        [self modifyVersion];
    }
}

- (BOOL)saveTakenPhotosToCameraRoll {
	// TODO: always YES, because text not lcalized yet
	return YES;
	return _saveTakenPhotosToCameraRoll;
}

- (void)setSaveTakenPhotosToCameraRoll:(BOOL)saveTakenPhotosToCameraRoll {
	if(_saveTakenPhotosToCameraRoll != saveTakenPhotosToCameraRoll) {
		_saveTakenPhotosToCameraRoll = saveTakenPhotosToCameraRoll;
		[self modifyVersion];
	}
}


@end

