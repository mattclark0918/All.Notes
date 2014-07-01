
#import "YTLocationSuggestView.h"
#import <AddressBookUI/AddressBookUI.h>

@implementation YTLocationSuggestView

@synthesize delegate = _delegate;

- (void)initialize {
	[super initialize];
    
    NSLog(@"YTLocationSuggestView::initialize");
    
	_searchText = @"";
	
	_placemarks = [[NSMutableArray alloc] init];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self addSubview:_tableView];
	
	[self updateViewAsync];
}

- (void)setSearchText:(NSString *)searchText {
	if(!searchText)
		searchText = @"";
	if(![_searchText isEqual:searchText]) {
		_searchText = [searchText copy];
		if(_searchText.length >= 2) {
			[self startSearchWitText:_searchText];
		} else {
			_curSearchTicket++;
			[self setPlacemarks:[NSArray array]];
		}
	}
}

- (void)onUpdateView {
	[super onUpdateView];
}

- (void)setPlacemarks:(NSArray *)placemarks {
	if(![_placemarks isEqualToArray:placemarks]) {
		[_placemarks removeAllObjects];
		[_placemarks addObjectsFromArray:placemarks];
		[_tableView reloadData];
	}
}

- (void)startSearchWitText:(NSString *)searchText {
	int searchTicket = ++_curSearchTicket;
	[[VLAppDelegateBase sharedAppDelegateBase] startAnimateNetworkActivityIndicator];
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder geocodeAddressString:searchText completionHandler:^(NSArray *placemarks, NSError *error)
	{
		[[VLAppDelegateBase sharedAppDelegateBase] stopAnimateNetworkActivityIndicator];
		if(searchTicket != _curSearchTicket)
			return;
		if(error) {
			VLLogError(error);
			return;
		}
		if(!placemarks)
			placemarks = [NSArray array];
		[self setPlacemarks:placemarks];
	}];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_tableView.frame = rcBnds;
}

- (NSString *)addressStringFromPlacemark:(CLPlacemark *)placemark {
	NSString *sAddr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
	sAddr = [sAddr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
	return sAddr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _placemarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *_reuseId = @"Placemark Cell";
	VLTableViewCell *cell = (VLTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:_reuseId];
	if(!cell) {
		cell = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_reuseId];
		cell.textLabel.font = [[YTFontsManager shared] fontTableCellLabel];
	}
	CLPlacemark *placemark = [_placemarks objectAtIndex:indexPath.row];
	cell.textLabel.text = [self addressStringFromPlacemark:placemark];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	CLPlacemark *placemark = [_placemarks objectAtIndex:indexPath.row];
	if(_delegate && [_delegate respondsToSelector:@selector(locationSuggestView:placemarkSelected:)])
		[_delegate locationSuggestView:self placemarkSelected:placemark];
}

- (void)removeFromSuperview {
//    NSLog(@"YTLocationSuggestView::removeFromSuperview");
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.tableView = nil;
    self.placemarks = nil;
    
    [super removeFromSuperview];
}

- (void) dealloc {
//    NSLog(@"YTLocationSuggestView::dealloc");
}


@end

