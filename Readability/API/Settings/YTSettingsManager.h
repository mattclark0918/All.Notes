
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

typedef enum {
    kYTSyncBackendICloud = 1,
    kYTSyncBackendDropbox
} YTSyncBackendMode;

@interface YTSettingsManager : YTLogicObject <NSCoding> {
@private
	int64_t _savedDataVersion;
	BOOL _syncOnWiFiOnly;
	BOOL _autoAddNoteLocation;
	BOOL _saveTakenPhotosToCameraRoll;
}

@property(nonatomic, assign) BOOL syncOnWiFiOnly;
@property(nonatomic, assign) BOOL autoAddNoteLocation;
@property(nonatomic, assign) BOOL saveTakenPhotosToCameraRoll;
//1 ==> iCloud, 2 ==> Dropbox
@property(nonatomic, assign) YTSyncBackendMode syncBackendMode;

+ (YTSettingsManager *)shared;

@end
