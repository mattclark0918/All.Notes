
#import "YTSyncTableViewCell.h"
#import "../Ctrls/YTSyncButton.h"
#import "../../API/Sync/YTSyncManager.h"

@implementation YTSyncTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if(self) {
		[self.textLabel centerText];
		self.textLabel.text = NSLocalizedString(@"Synchronize now", nil);
		self.textLabel.textColor = kYTLabelsBlueTextColor;
		
		_syncButton = [[YTSyncButton alloc] initWithFrame:CGRectZero];
		_syncButton.userInteractionEnabled = NO;
		_syncButton.alpha = 0.0;
		[self.textLabel.superview addSubview:_syncButton];
		
		[self updateSyncButton];
	}
	return self;
}

- (void)updateSyncButton {
	BOOL isSyncing = [[YTSyncManager sharedSyncManager] isSyncing];
	if(_wasSyncing != isSyncing) {
		_wasSyncing = isSyncing;
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			_syncButton.alpha = isSyncing ? 1.0 : 0.0;
		}];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.textLabel.superview.bounds;
	CGRect rcBut = rcBnds;
	rcBut.size.width = rcBut.size.height;
	rcBut.origin.x = CGRectGetMidX(rcBnds) + [self.textLabel sizeOfText].width/2 + 0;
	if(CGRectGetMaxX(rcBut) > CGRectGetMaxX(rcBnds))
		rcBut.origin.x = CGRectGetMaxX(rcBnds) - rcBut.size.width;
	_syncButton.frame = [UIScreen roundRect:rcBut];
}

@end

