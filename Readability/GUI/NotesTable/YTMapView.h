
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import <MapKit/MapKit.h>
#import "../Ctrls/Classes.h"



@interface YTMapView_OverlayView : YTBaseView {
@private
}

@end

@interface YTMapView : YTBaseView <MKMapViewDelegate, YTLocationSuggestViewDelegate> {
@private
	MKMapView *_mapView;
    
	BOOL _updatedOnce;
	BOOL _curLocationShownOnce;
	BOOL _updatingInBackground;
    int _updatingInBackgroundTicket;
	VLTimer *_timer;
}


+ (void)getAddressFromCurrentLocationWithResultBlock:(void (^)(YTLocation *resultLocation, NSError *error))resultBlock;
- (void)startGettingSuggestedLocation;

@end
