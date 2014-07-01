
#import "YTMapSearchView.h"
#import "../Main/Classes.h"
#import <AddressBookUI/AddressBookUI.h>

#define kBarBackColor [UIColor colorWithRed:201/255.0 green:201/255.0 blue:206/255.0 alpha:1.0]


@interface YTMapView_Annotation : NSObject <MKAnnotation> {
@private
	YTLocation *__strong _locationInfo;
	CLLocationCoordinate2D _lastCoord;
}

@property(nonatomic, strong) YTLocation *locationInfo;

@end

@implementation YTMapView_Annotation

- (void)setLocationInfo:(YTLocation *)locationInfo {
	if(_locationInfo != locationInfo) {
		if(_locationInfo) {
//			[_locationInfo.msgrVersionChanged removeObserver:self];
		}
		_locationInfo = locationInfo;
		if(_locationInfo) {
//			[_locationInfo.msgrVersionChanged addObserver:self selector:@selector(onLocationInfoDataChanged:)];
			[self onLocationInfoDataChanged];
		}
	}
}

- (void)onLocationInfoDataChanged:(id)sender {
	[self onLocationInfoDataChanged];
}

- (void)onLocationInfoDataChanged {
	if(_locationInfo) {
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_locationInfo.latitude floatValue], [_locationInfo.longitude floatValue]);
		if(coord.latitude != _lastCoord.latitude || coord.longitude != _lastCoord.longitude) {
			_lastCoord = coord;
			[self setCoordinate:_lastCoord];
		}
	}
}

- (NSString *)title {
	if(_locationInfo)
		return _locationInfo.name;
	return @"";
}

- (NSString *)subtitle {
	return nil;
}

- (CLLocationCoordinate2D)coordinate {
	return _lastCoord;
}
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	
}

- (void)dealloc {
	self.locationInfo = nil;
}

@end




@implementation YTMapView_OverlayView

- (void)initialize {
	[super initialize];
	self.opaque = NO;
	self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(self.alpha == 0)
		return nil;
	return [super hitTest:point withEvent:event];
}

@end





@implementation YTMapView


- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTViewBackColor;
    
    /*
    _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.opaque = NO;
    
    [self performInBackground:YES updateBlock:^{
        [self addSubview:_mapView];
    }];
     
     */
	
//	_timer = [[VLTimer alloc] init];
//	_timer.interval = 1.0;
//	[_timer setObserver:self selector:@selector(onTimerEvent:)];
//	[_timer start];
    
    [self checkForNeedUpdate];
	
	[self updateViewAsync];
}

- (void)performInBackground:(BOOL)inBackground updateBlock:(VLBlockVoid)updateBlock  {
	if(inBackground) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			@autoreleasepool {
				updateBlock();
			}
		});
	} else {
		updateBlock();
	}
}

- (void)performUpdateEndBlock:(VLBlockVoid)updateEndBlock {
	if([NSThread isMainThread]) {
		updateEndBlock();
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			updateEndBlock();
		});
	}
}


- (YTMapView_Annotation *)curAnnotation {
	NSArray *annotations = [NSArray arrayWithArray:[_mapView annotations]];
	YTMapView_Annotation *curAnnot = nil;
	for(NSObject *obj in annotations) {
		curAnnot = ObjectCast(obj, YTMapView_Annotation);
		if(curAnnot)
			break;
	}
	return curAnnot;
}

- (void)onUpdateView {
	[super onUpdateView];
    
	YTLocation *location = self.locationInfo;
	YTMapView_Annotation *curAnnot = [self curAnnotation];
	if(location && location.latitude && location.longitude) {
		if(!curAnnot) {
			curAnnot = [[YTMapView_Annotation alloc] init];
			curAnnot.locationInfo = location;
			[_mapView addAnnotation:curAnnot];
		}
		curAnnot.locationInfo = location;
	} else {
		if(curAnnot)
			[_mapView removeAnnotation:curAnnot];
	}
	if(!_updatedOnce) {
		_updatedOnce = YES;
		[[VLMessageCenter shared] performBlock:^{
			[self showFoundPin];
		} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
	}
	
	if(!_curLocationShownOnce) {
		if(!location || !location.latitude || !location.longitude) {
			if(_mapView.userLocation && _mapView.userLocation.coordinate.latitude && _mapView.userLocation.coordinate.longitude) {
				MKCoordinateRegion region;
				region.center = _mapView.userLocation.coordinate;
				MKCoordinateSpan span;
				span.latitudeDelta = span.longitudeDelta = 0.01;
				region.span = span;
				[_mapView setRegion:region animated:YES];
				_curLocationShownOnce = YES;
			}
		}
	}
        
	[self setNeedsLayout];
}

- (void)onTimerEvent:(id)sender {
//    [self performInBackground:YES updateBlock:^{
//        [self updateViewAsync];
//    }];
}

- (void)showFoundPin {
    [self performInBackground:YES updateBlock:^{
        YTMapView_Annotation *curAnnot = [self curAnnotation];
        if(curAnnot) {
            YTLocation *location = curAnnot.locationInfo;
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([location.latitude floatValue], [location.longitude floatValue]);
            MKCoordinateRegion region;
            region.center = coord;
            CLLocationDegrees delta = 0.01;
            region.span = MKCoordinateSpanMake(delta, delta);
            [_mapView setRegion:region animated:YES];
        }
    }];

}

- (void)onLocationInfoDataChanged {
	[super onLocationInfoDataChanged];
    [self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
    
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	[self checkForNeedUpdate];

}
+ (void)getAddressFromLocation:(CLLocation *)loc resultBlock:(void (^)(YTLocation *resultLocation, NSError *error))resultBlock {

	[[VLAppDelegateBase sharedAppDelegateBase] startAnimateNetworkActivityIndicator];
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error)
	{
		[[VLAppDelegateBase sharedAppDelegateBase] stopAnimateNetworkActivityIndicator];
		if(error) {
			VLLogError(error);
			NSInteger errorCode = error.code;
			BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
			CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
			if(!locationServicesEnabled)
				error = [NSError makeWithText:NSLocalizedString(@"Location services have not been enabled! Update your settings.", nil)];
			else if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted)
				error = [NSError makeWithText:NSLocalizedString(@"Location services have not been authorized for this app! Update your privacy settings.", nil)];
			else if(errorCode == kCLErrorNetwork)
				error = [NSError makeWithText:NSLocalizedString(@"GPS Location Services are Unavailable", nil)];
			// kCLErrorDenied,                       // Access to location or ranging has been denied by the user
			// kCLErrorNetwork,                      // general, network-related error
			resultBlock(nil, error);
			return;
		}
		CLPlacemark *placemark = placemarks.count ? ObjectCast([placemarks objectAtIndex:0], CLPlacemark) : nil;
		if(!placemark) {
			NSError *error = [NSError makeWithText:NSLocalizedString(@"Could not find address.", nil)];
			resultBlock(nil, error);
			return;
		}
		YTLocation *resultLocation = [[YTLocationManager sharedManager] createNewLocation];
		NSString *sAddr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
		if(!sAddr)
			sAddr = @"";
		sAddr = [sAddr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
		resultLocation.name = sAddr;
		CLLocation *loc = placemark.location;
		if(loc) {
			resultLocation.latitude = [NSNumber numberWithDouble: loc.coordinate.latitude];
			resultLocation.longitude = [NSNumber numberWithDouble: loc.coordinate.longitude];
		}
		resultBlock(resultLocation, nil);
	}];
}

+ (void)getAddressFromCurrentLocationWithResultBlock:(void (^)(YTLocation *resultLocation, NSError *error))resultBlock {
	CLLocation *locExisted = [[VLLocationManager shared] getLocation];
	if(locExisted) {
		[self getAddressFromLocation:locExisted resultBlock:^(YTLocation *resultLocation, NSError *error) {
			if(!error && resultLocation) {
				resultLocation.latitude = [NSNumber numberWithDouble: locExisted.coordinate.latitude];
				resultLocation.longitude = [NSNumber numberWithDouble: locExisted.coordinate.longitude];
			}
			resultBlock(resultLocation, error);
		}];
		return;
	}
}

- (void)startGettingSuggestedLocation {
	[[self class] getAddressFromCurrentLocationWithResultBlock:^(YTLocation *resultLocation, NSError *error) {
		if(resultLocation && !self.locationInfo) {
			self.locationInfo = resultLocation;
		}
	}];
}


- (void)checkForNeedUpdate {
	CGRect rcBnds = self.boundsNoBars;
	if(rcBnds.size.width < 1)
		return;
	BOOL inBackground = YES;
	BOOL needUpdate = NO;
	if(!_updatingInBackground) {
		needUpdate = YES;
		inBackground = NO;
	}
    
	if(!needUpdate) {
		if(!_updatingInBackground)
			needUpdate = YES;
	}
	if(!needUpdate)
		return;
    
    _updatingInBackground = YES;
	int updatingInBackgroundTicket = ++_updatingInBackgroundTicket;
	[self performInBackground:inBackground updateBlock:^{
        
		[self performUpdateEndBlock:^{
            
			if(updatingInBackgroundTicket != _updatingInBackgroundTicket)
				return;
			_updatingInBackground = NO;
			
            _mapView.frame = rcBnds;
		}];
        
	}];
}


- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
    
}

@end

