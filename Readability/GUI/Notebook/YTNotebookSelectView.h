
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@class YTNotebookSelectView_Cell;
@class YTNotebookSelectView;
@class YTNotebookSelectView_SearchOverlayView;
@class YTNotebookSelectView_CellSeparator;

@protocol YTNotebookSelectViewDelegate <NSObject>
@required
- (void)notebookSelectView:(YTNotebookSelectView *)notebookSelectView finishWithAction:(EYTUserActionType)action;

@end

@interface YTNotebookSelectView : YTBaseView <UITableViewDataSource, UITableViewDelegate,
	VLKeyboardTableViewDelegate, YTTableSearchBarDelegate> {
@private
	YTTableSearchBar *_tableSearchBar;
	YTNotebookSelectView_SearchOverlayView *_searchOverlayView;
	VLKeyboardTableView *_tableView;
	YTNotebookSelectView_Cell *_cellNewNotebook;
	YTNotebookSelectView_CellSeparator *_cellSeparator;
	NSMutableArray *_rowsNotebooks;
	NSString *_searchText;
	BOOL _cellsLoaded;
	NSObject<YTNotebookSelectViewDelegate> *__weak _delegate;
	BOOL _isSearching;
	BOOL _searchBarEditing;
	BOOL _closing;
    YTNotebook* _currNotebook;
}

//@property(nonatomic, assign) NSString *curNotebookGuid;
@property(nonatomic, weak) NSObject<YTNotebookSelectViewDelegate> *delegate;

- (void)beginSearching;

//sets the current notebook
- (void) setCurrNotebook:(YTNotebook *)newCurrNotebook;

//returns current notebook
- (YTNotebook*) getCurrNotebook;

@end
