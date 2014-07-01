
#import <Foundation/Foundation.h>
#import "VLTimer.h"
#import "VLRefreshTableHeaderView.h"

@protocol VLTablePullToDefreshDelegate;
@class VLKeyboardTableView;

@protocol VLKeyboardTableViewDelegate <NSObject>
@optional
- (UIView *)keyboardTableView:(VLKeyboardTableView *)keyboardTableView getFirstResponder:(id)param;
@end

@interface VLKeyboardTableView : UITableView <UITableViewDataSource, UITableViewDelegate, VLRefreshTableHeaderDelegate>
{
@private
	BOOL _initialized;
	id<UITableViewDataSource> __weak _dataSourceInt;
	id<UITableViewDelegate> __weak _delegateInt;
	BOOL _keyboardShown;
	CGRect _frameOfKeyboard;
	UITableViewCell *_additionTableCell;
	BOOL _hasFirstResponder;
	VLTimer *_timer;
	UIView *_lastFirstResponder;
	
	VLRefreshTableHeaderView *_refreshHeaderView;
	BOOL _refreshHeaderReloading;
	BOOL _emulateDragging;
	id<VLTablePullToDefreshDelegate> __weak _pullToRefreshDelegate;
	BOOL _pullToRefreshViewDoneLoadingCalled;
	NSObject<VLKeyboardTableViewDelegate> *__weak _keyboardTableViewDelegate;
}

@property(nonatomic, weak) id<VLTablePullToDefreshDelegate> pullToRefreshDelegate;
@property(nonatomic, readonly) VLRefreshTableHeaderView *pullToRefresHeaderView;
@property(nonatomic, weak) NSObject<VLKeyboardTableViewDelegate> *keyboardTableViewDelegate;

- (id)initWithFrame:(CGRect)frame
			  style:(UITableViewStyle)style
		 dataSource:(id<UITableViewDataSource>)dataSource
		   delegate:(id<UITableViewDelegate>)delegate;
- (void)resetDataSourceAndDelegate;
- (void)addPullToRefreshViewWithStyle:(VLPullRefreshStyle)style height:(float)height;
- (void)pullToRefreshPullDown;
- (void)pullToRefreshViewDoneLoading;

@end

@protocol VLTablePullToDefreshDelegate<NSObject>

@optional
- (NSDate*)pullToRefreshLastUpdatedDate:(VLKeyboardTableView*)tableView;
- (BOOL)pullToRefreshHeaderPulledAndShouldStartUpdating:(VLKeyboardTableView*)tableView;

@end
