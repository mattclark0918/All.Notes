
#import <Foundation/Foundation.h>
#import "../Ctrls/Classes.h"

@class YTSyncButton;

@interface YTSyncTableViewCell : VLTableViewCell {
@private
	YTSyncButton *_syncButton;
	BOOL _wasSyncing;
}

- (void)updateSyncButton;

@end

