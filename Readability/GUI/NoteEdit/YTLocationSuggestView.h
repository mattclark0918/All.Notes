
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import <MapKit/MapKit.h>

@class YTLocationSuggestView;

@protocol YTLocationSuggestViewDelegate <NSObject>
@optional
- (void)locationSuggestView:(YTLocationSuggestView *)locationSuggestView placemarkSelected:(CLPlacemark *)placemark;
@end

@interface YTLocationSuggestView : YTBaseView <UITableViewDataSource, UITableViewDelegate> {
@private
	int _curSearchTicket;
	NSString *_searchText;
	NSObject<YTLocationSuggestViewDelegate> *__weak _delegate;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *placemarks;

@property(nonatomic, weak) NSObject<YTLocationSuggestViewDelegate> *delegate;

- (void)setSearchText:(NSString *)searchText;

@end

