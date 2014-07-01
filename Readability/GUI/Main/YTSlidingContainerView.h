
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTSlidingMenuView.h"
#import "YTSlidingContentView.h"
#import "YTSplashView.h"

@class YTSlidingContainerView_SliddenContentOverlayView;

@interface YTSlidingContainerView : YTBaseView <YTNavigatingViewDelegate, YTSlidingMenuViewDelegate> {
@private
	float _slideRatio;
	float _showSplashRatio;
	float _dragStartSlideRatio;
	BOOL _dragStarted;
	CGPoint _dragStartPoint;
	int _slideIgnoringCounter;
	
	BOOL _openingNoteView;
	BOOL _closingNoteView;
	
	int _disableAnimationCounter;
}

@property (nonatomic, strong) YTSlidingMenuView *menuView;
@property (nonatomic, strong) YTSlidingContentView *contentView;
@property (nonatomic, strong) YTSlidingContainerView_SliddenContentOverlayView *sliddenOverlay;
@property (nonatomic, strong) YTSplashView *splashView;
@property (nonatomic, strong) VLActivityView *activityViewLoading;
@property (nonatomic, strong) YTPhotosThumbsView *cachedPhotosThumbsView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) YTNotesContentView *contentView_noteView;
@property (nonatomic, strong) YTNoteView *noteView;

@property (nonatomic, strong) YTNotesContentView *contentView_noteEditView;
@property (nonatomic, strong) YTNoteEditView *noteEditView;

+ (YTSlidingContainerView *)shared;

- (void)suspendSliding;
- (void)resumeSliding;
- (void)suspendSliding:(BOOL)suspend;

- (void)showNoteView:(YTNoteView *)noteView fromCellView:(YTNoteTableCellView *)noteCellView;
- (BOOL)closeNoteView:(YTNoteView *)noteView toCellView:(YTNoteTableCellView *)noteCellView;

- (void)showNoteView:(YTNoteView *)noteView fromThumbView:(YTPhotosThumbsView_ThumbView *)thumbView;
- (BOOL)closeNoteView:(YTNoteView *)noteView toThumbView:(YTPhotosThumbsView_ThumbView *)thumbView;

- (void)showNoteEditView:(YTNoteEditView *)noteEditView;
- (BOOL)closeNoteEditView:(YTNoteEditView *)noteEditView;

@end




@interface YTSlidingContainerView_SliddenContentOverlayView : YTBaseView {
@private
}

@end




