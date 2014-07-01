
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import <MapKit/MapKit.h>
#import "../Ctrls/Classes.h"
#import "YTLocationSuggestView.h"

@class YTMapSearchView;

@protocol YTMapSearchViewDelegate <NSObject>
@required
- (void)mapSearchView:(YTMapSearchView *)mapSearchView finishWithAction:(EYTUserActionType)action;

@end

@interface YTMapSearchView_OverlayView : YTBaseView {
@private
}

@end

@interface YTMapSearchView : YTBaseView <MKMapViewDelegate, UISearchBarDelegate, YTLocationSuggestViewDelegate> {
@private
    int _curSearchTicket;
    BOOL _updatedOnce;
    BOOL _curLocationShownOnce;
    BOOL _isSearching;
}

@property(nonatomic, weak) NSObject<YTMapSearchViewDelegate> *delegate;

@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UIToolbar *toolbar;
@property(nonatomic, strong) UIBarButtonItem *bbiUseThisLoc;
@property(nonatomic, strong) VLTimer *timer;
@property(nonatomic, strong) VLLabel *lbAddressText;
@property(nonatomic, strong) YTMapSearchView_OverlayView *overlayView;
@property(nonatomic, strong) YTLocationSuggestView *locationSuggestView;


+ (void)getAddressFromCurrentLocationWithResultBlock:(void (^)(YTLocation *resultLocation, NSError *error))resultBlock;
- (void)startGettingSuggestedLocation;

@end
