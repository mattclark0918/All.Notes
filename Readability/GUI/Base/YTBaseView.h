
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"
#import "../../API/Classes.h"

@class YTCustomNavigationBar;
@class YTBaseView;
@class YTNotesContentView;


@protocol YTNavigatingViewDelegate <NSObject>
@optional
- (void)navigatingView:(YTBaseView *)navigatingView handleGoBack:(id)param;

@end


@interface YTBaseView_StatusBarBackView : VLBaseView {
@private
}

@end


@interface YTBaseView : VLBaseView {
@private
//	YTCustomNavigationBar *_customNavBar;
	BOOL _stickNavigationBar;
	YTNote *__strong _note;
	YTAttachment *__strong _resource;
	YTTag *__strong _noteTag;
	YTNoteEditInfo *__strong _noteEditInfo;
	YTLocation *__strong _locationInfo;
	NSObject *_objectTag;
	NSTimeInterval _updateViewMinDelay;
	NSTimeInterval _lastUpdateViewUptime;
	BOOL _callingOnUpdateViewYTWithDelay;
	NSObject<YTNavigatingViewDelegate> *__weak _navigatingViewDelegate;
	BOOL _navigationBarHidden;
	BOOL _slidingSuspended;
	UIStatusBarStyle _lastStatusBarStyle;
	BOOL _isScrolling;
}

@property(nonatomic, strong) YTCustomNavigationBar *customNavBar;
@property(nonatomic, readonly) BOOL customNavBarCreated;
@property(nonatomic, readonly) CGRect boundsNoBars;
@property(nonatomic, readonly) CGRect frameOfBar;
@property(nonatomic, assign) BOOL stickNavigationBar;
@property(nonatomic, strong) YTNote *note;
@property(nonatomic, strong) YTAttachment *resource;
@property(nonatomic, strong) YTTag *noteTag;
@property(nonatomic, strong) YTNoteEditInfo *noteEditInfo;
@property(nonatomic, strong) YTLocation *locationInfo;
@property(nonatomic, strong) NSObject *objectTag;
@property(nonatomic, weak) NSObject<YTNavigatingViewDelegate> *navigatingViewDelegate;
@property(nonatomic, strong) YTBaseView_StatusBarBackView *statusBarBackView;


- (YTNotesContentView *)parentContentView;

- (void)setUpdateViewMinDelay:(NSTimeInterval)updateViewMinDelay;
- (void)resetUpdateViewMinDelay;
- (void)onUpdateViewYT;

- (void)onNoteDataChanged;
- (void)onResourceDataChanged;
- (void)onNoteTagDataChanged;
- (void)onNoteEditInfoDataChanged;
- (void)onLocationInfoDataChanged;

- (void)onNotesManagerChanged;
- (void)onNotesContentManagerChanged;
- (void)onResourcesManagerChanged;
- (void)onLocationsManagerChanged;

- (void)assignEntitiesFrom:(YTBaseView *)other;

- (void)setNavigationBarHidden:(BOOL)hidden withStatusBarBackColor:(UIColor *)statusBarBackColor animated:(BOOL)animated;
- (void)suspendSliding:(BOOL)suspend;

- (void)beginIsScrolling;
- (void)endIsScrolling;

@end
