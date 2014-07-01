
#import "YTResourceBaseView.h"

@implementation YTResourceBaseView

//@synthesize loadingReference = _loadingReference;
@synthesize activityView = _activityView;
@synthesize makeThumbnails = _makeThumbnails;
@synthesize makePreview = _makePreview;
@synthesize aspectFill = _aspectFill;
@synthesize activityBackColor = _activityBackColor;
@synthesize showActivityIndicator = _showActivityIndicator;

- (void)initialize {
	[super initialize];
	_showActivityIndicator = YES;
	self.backgroundColor = [UIColor blackColor];
	_makePreview = YES;
	_activityBackColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
	
	_activityView = [[UIActivityIndicatorView alloc] init];
	_activityView.hidden = YES;
	_activityView.contentMode = UIViewContentModeCenter;
	_activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	_activityView.backgroundColor = _activityBackColor;
	_activityView.alpha = 0.7;
	[self addSubview:_activityView];
		
	[self updateViewAsync];
}

- (void)setActivityBackColor:(UIColor *)activityBackColor {
	_activityBackColor = activityBackColor;
	_activityView.backgroundColor = _activityBackColor;
}

- (void)onUpdateView {
	[super onUpdateView];
}

- (void)onResourceDataChanged {
	[super onResourceDataChanged];
	[self updateViewAsync];
}

    //TODO:::we're removing loading reference
//- (void)onLoadingReferenceChanged:(id)sender {
//	[self updateViewAsync];
//}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(_activityView)
		_activityView.frame = rcBnds;
}

- (void)removeFromSuperview {
//    NSLog(@"YTResourceBaseView::removeFromSuperView");
    self.activityView = nil;
    
    [super removeFromSuperview];
}


@end

