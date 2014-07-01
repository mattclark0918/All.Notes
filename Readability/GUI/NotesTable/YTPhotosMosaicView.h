
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"
#import "YTResourceImageView.h"
#import "YTNoteViewDelegate.h"

@class YTEmptyNotesView;
@class YTPhotosMosaicView;
@class YTPhotosMosaicView_ThumbView;

@protocol YTPhotosMosaicView_ThumbViewDelegate <NSObject>
@optional
- (BOOL)thumbView:(YTPhotosMosaicView_ThumbView *)thumbView isVisible:(id)param;

@end

@interface YTPhotosMosaicView_ThumbView : YTBaseView <YTNoteViewDelegate, YTResourceImageViewDelegate> {
@private
	YTResourceImageView *_resourceImageView;
	UIButton *_button;
	BOOL _forcedShowImage;
	VLLabel *_lbTime;
	VLLabel *_lbDay;
	VLLabel *_lbDate;
	NSObject<YTPhotosMosaicView_ThumbViewDelegate> *__weak _delegate;
	BOOL _showImageView;
}

@property(nonatomic, weak) NSObject<YTPhotosMosaicView_ThumbViewDelegate> *delegate;
@property(nonatomic, readonly) YTResourceImageView *resourceImageView;
@property(nonatomic, assign) BOOL showImageView;

@end


@interface YTPhotosMosaicView_ContentView : YTBaseView <YTPhotosMosaicView_ThumbViewDelegate> {
@private
	UIView *_backViewSep;
	NSMutableArray *_arrResImages;
	NSMutableArray *_arrResImagesSizes;
	NSMutableArray *_arrResViewsFrames;
	float _allViewsHeight;
	float _allViewsWidth;
	NSMutableArray *_arrThumbs;
	NSTimeInterval _maxWaitingTimeToLoad;
	BOOL _updatingInBackground;
	int _updatingInBackgroundTicket;
	int _updatingInBackgroundAllViewsWidth;
	NSMutableArray *_updatingInBackgroundArrResImages;
	YTPhotosMosaicView *__strong _parentThumbsViewRef;
}

@property(nonatomic, strong) YTPhotosMosaicView *parentThumbsViewRef;
@property(nonatomic, readonly) NSArray *arrThumbs;
@property(nonatomic, readonly) NSArray *arrResViewsFrames;

- (id)initWithFrame:(CGRect)frame parentThumbsView:(YTPhotosMosaicView *)parentThumbsView maxWaitingTimeToLoad:(NSTimeInterval)maxWaitingTimeToLoad  Note: (YTNote*) note;

@end


@interface YTPhotosMosaicView : YTBaseView <UIScrollViewDelegate> {
@private
	UIScrollView *_scrollView;
	YTPhotosMosaicView_ContentView *_contentView;
	NSTimeInterval _maxWaitingTimeToLoad;
	VLTimer *_timer;
}

+ (YTPhotosMosaicView *)currentInstance;
- (id)initWithFrame:(CGRect)frame maxWaitingTimeToLoad:(NSTimeInterval)maxWaitingTimeToLoad  Note: (YTNote*) note;
- (BOOL)isAllImagesShown;

- (void) changeNote: (YTNote*) newNote;

@end

