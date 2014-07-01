
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTResourceBaseView : YTBaseView {
@private
//	YTResourceLoadingReference *_loadingReference;
	BOOL _makeThumbnails;
	BOOL _makePreview;
	BOOL _aspectFill;
	UIColor *_activityBackColor;
	BOOL _showActivityIndicator;
}

@property(nonatomic, strong) UIActivityIndicatorView *activityView;
@property(nonatomic, assign) BOOL makeThumbnails;
@property(nonatomic, assign) BOOL makePreview;
@property(nonatomic, assign) BOOL aspectFill;
@property(nonatomic) UIColor *activityBackColor;
@property(nonatomic, assign) BOOL showActivityIndicator;

@end

