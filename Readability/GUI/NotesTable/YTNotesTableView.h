
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNoteTableCellView.h"
#import "YTNoteTableCellInfo.h"

@class YTNotesDisplayParams;


@interface YTHomeFeedView_TableHeaderViewBase : YTBaseView {
@private
	UIImageView *_ivBack;
	VLLabel *_lbTitle;
	YTNoteTableCellView_Separator *_separator;
}

@property(nonatomic,readonly) UIImageView *ivBack;
@property(nonatomic,readonly) VLLabel *lbTitle;

@end


@interface YTHomeFeedView_RemindersHeaderView : YTHomeFeedView_TableHeaderViewBase {
@private
}

@end


@interface YTHomeFeedView_RecentlyCompletedHeaderView : YTHomeFeedView_TableHeaderViewBase {
@private
}

@end


@interface YTHomeFeedView_AllNotesHeaderView : YTHomeFeedView_TableHeaderViewBase {
@private
	VLTimer *_timer;
}

@end


@interface YTHomeFeedView_MonthHeaderView : YTHomeFeedView_TableHeaderViewBase {
@private
	NSDate *_dateMonth;
}

@property(nonatomic) NSDate *dateMonth;

@end


@interface YTHomeFeedView_MonthSectionInfo : YTLogicObject {
@private
	NSDate *_dateMonth;
	int _absoluteMonth;
	NSMutableArray *_notes;
}

@property(nonatomic, strong) NSDate *dateMonth;
@property(nonatomic, assign) int absoluteMonth;
@property(nonatomic, readonly) NSMutableArray *notes;

+ (NSString *)stringFromDateMonth:(NSDate *)dateMonth timezone:(NSTimeZone *)timezone;
+ (int)absoluteMonthFromDateMonth:(NSDate *)dateMonth timezone:(NSTimeZone *)timezone;

@end


@interface YTNotesTableView : YTBaseView <UITableViewDataSource, UITableViewDelegate, YTNoteViewDelegate, YTTableSearchBarDelegate> {
@private
	YTNotesDisplayParams *_notesDisplayParams;
	VLKeyboardTableView *_tableView;
	YTTableSearchBar *_tableSearchBar;
	BOOL _searchBarPulled;
	NSMutableArray *_arrMonthsSectionsNew;
	NSMutableArray *_notesSections;
	NSMutableArray *_notesSectionsNew;
	NSMutableDictionary *_dictCellInfoByNoteGuid;
	NSMutableArray *_sectionsHeaders;
	NSMutableArray *_sectionsHeadersNew;
	BOOL _updatingInBackground;
	int _updatingInBackgroundTicket;
	int64_t _lastResourcesManagerVersion;
	BOOL _hasNotesLoadedOnce;
	VLTimer *_timer;
	int64_t _lastManagersVersion;
	NSTimeInterval _lastUpdateUptime;
	YTHomeFeedView_RemindersHeaderView *_headerToDo;
	YTHomeFeedView_RecentlyCompletedHeaderView *_headerToDoDone;
	YTHomeFeedView_AllNotesHeaderView *_headerAllNotes;
	YTEmptyNotesView *_emptyNotesView;
	UIView *_lastTableBackView;
	BOOL _isSearching;
	NSString *_searchText;
	NSString *_lastSearchText;
	int _curSearchingTicket;
	int _isSearchingInBackgroundCounter;
	UIView *_searchOverlayView;
    
    NSMutableArray *_notesArray;
    
}

@property(nonatomic, readonly) BOOL hasNotesLoadedOnce;

@property (nonatomic, strong) NSArray* filteredNotes;

+ (YTNotesTableView *)currentInstance;
- (id)initWithNotesDisplayParams:(YTNotesDisplayParams *)notesDisplayParams;
- (void)startUpdateNotesInBackgroundWithResultBlock:(VLBlockVoid)resultBlock;
- (void)showNote:(YTNote *)note animated:(BOOL)animated;

@end

