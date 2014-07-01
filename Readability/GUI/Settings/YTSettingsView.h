
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@class YTSettingsView_HeaderCopyright, YTSyncTableViewCell;;

@interface YTSettingsView : YTBaseView <UITableViewDataSource, UITableViewDelegate> {
@private
    BOOL _show_cellLastSyncDate;

}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *allCells;
@property (nonatomic, strong) NSMutableArray *cellsSections;
@property (nonatomic, strong) UIView *overlaySepLSD1;
@property (nonatomic, strong) UIView *overlaySepLSD2;
@property (nonatomic, strong) VLTableViewCell *cellNotebooks;
@property (nonatomic, strong) VLSettingsTableCell *cellAutoAddNoteLocation;
@property (nonatomic, strong) VLSettingsTableCell *cellSaveToCameraRoll;
@property (nonatomic, strong) VLSettingsTableCell *cellSyncOnWiFiOnly;
@property (nonatomic, strong) VLTableViewCell *cellChooseWallpaper;
@property (nonatomic, strong) VLSettingsTableCell *cellRateApp;
@property (nonatomic, strong) VLSettingsTableCell *cellReportProblem;
@property (nonatomic, strong) YTSettingsView_HeaderCopyright *headerCopyright;

@property (nonatomic, strong) VLSettingsTableCell* cellICloud;
@property (nonatomic, strong) VLSettingsTableCell* cellDropbox;
@property (nonatomic, strong) VLSettingsTableCell* cellSynNow;
@property (nonatomic, strong) YTSyncTableViewCell* cellSync;
@end


@interface YTSettingsView_HeaderCopyright : VLTableSectionHeader {
@private
	NSString *_textCopyright1;
	NSString *_textCopyright2;
	UIView *_overlaySepCopyright;
}

- (CGSize)sizeThatFits:(CGSize)size;

@end


