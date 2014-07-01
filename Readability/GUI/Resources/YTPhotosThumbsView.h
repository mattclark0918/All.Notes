
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"
#import "YTResourceImageView.h"
#import "YTNoteViewDelegate.h"

@class YTEmptyNotesView;
@class YTPhotosThumbsView;
@class YTPhotosThumbsView_ThumbView;

@protocol YTPhotosThumbsView_ThumbViewDelegate <NSObject>
@optional
- (BOOL)thumbView:(YTPhotosThumbsView_ThumbView *)thumbView isVisible:(id)param;

@end

@interface YTPhotosThumbsView_ThumbView : YTBaseView <YTNoteViewDelegate, YTResourceImageViewDelegate> {
@private
	BOOL _forcedShowImage;
	NSObject<YTPhotosThumbsView_ThumbViewDelegate> *__weak _delegate;
	BOOL _showImageView;
}


@property (nonatomic, strong) VLLabel *lbTime;
@property (nonatomic, strong) VLLabel *lbDay;
@property (nonatomic, strong) VLLabel *lbDate;
@property(nonatomic, weak) NSObject<YTPhotosThumbsView_ThumbViewDelegate> *delegate;
@property(nonatomic, strong) YTResourceImageView *resourceImageView;
@property(nonatomic, assign) BOOL showImageView;
@property (nonatomic, strong) UIButton *button;

@end


@interface YTPhotosThumbsView_ContentView : YTBaseView <YTPhotosThumbsView_ThumbViewDelegate> {
@private
	float _allViewsHeight;
	float _allViewsWidth;
	NSTimeInterval _maxWaitingTimeToLoad;
	BOOL _updatingInBackground;
	int _updatingInBackgroundTicket;
	int _updatingInBackgroundAllViewsWidth;
}

@property(nonatomic, weak) YTPhotosThumbsView *parentThumbsViewRef;
@property(nonatomic, strong) NSMutableArray *arrThumbs;
@property(nonatomic, strong) NSMutableArray *arrResViewsFrames;
@property (nonatomic, strong) UIView *backViewSep;
@property (nonatomic, strong) NSMutableArray *arrResImages;
@property (nonatomic, strong) NSMutableArray *arrResImagesSizes;
@property (nonatomic, strong) NSMutableArray *updatingInBackgroundArrResImages;

- (id)initWithFrame:(CGRect)frame parentThumbsView:(YTPhotosThumbsView *)parentThumbsView maxWaitingTimeToLoad:(NSTimeInterval)maxWaitingTimeToLoad;

@end


@interface YTPhotosThumbsView : YTBaseView <UIScrollViewDelegate> {
@private
	NSTimeInterval _maxWaitingTimeToLoad;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YTPhotosThumbsView_ContentView *contentView;
@property (nonatomic, strong) VLTimer *timer;


+ (YTPhotosThumbsView *)currentInstance;
- (id)initWithFrame:(CGRect)frame maxWaitingTimeToLoad:(NSTimeInterval)maxWaitingTimeToLoad;
- (BOOL)isAllImagesShown;

@end

