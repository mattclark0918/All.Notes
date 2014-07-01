
#import "YTPhotosThumbsView.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "../Notes/Classes.h"

#define kUseBigThumb YES//NO
#define kPreloadViews YES//NO
#define kThumbsDist (kUseBigThumb ? 2 : 8)
#define kThumbTouchBorders kUseBigThumb
#define kBigThumbWidthPortrait ( (320 - 1 * kThumbsDist) / 2 )
#define kBigThumbWidthLandscape ( (480 - 1 * kThumbsDist) / 2 )
#define kBigThumbWidthLandscapeIPhone5 ( (568 - 2 * kThumbsDist) / 3 )
#define kBigThumbWidth (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kBigThumbWidthPortrait : (IsUiIPhone5 ? kBigThumbWidthLandscapeIPhone5 : kBigThumbWidthLandscape))
#define kSmallThumbWidth ( (320 - 4 * kThumbsDist) / 3 )
#define kThumbWidth (kUseBigThumb ? kBigThumbWidth : kSmallThumbWidth)
#define kMaxThumbHeight (kUseBigThumb ? kThumbWidth : (kYTPhotoThumbnailSizeToShow.height / 2))
#define kThumbHeight (MIN(kThumbWidth, kMaxThumbHeight))
#define kDefaultMaxWaitingTimeToLoad 0.0//1.0
#define kShowDates YES//NO
#define kSeparatorColor [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0]//[UIColor colorWithRed:0x30/255.0 green:0x30/255.0 blue:0x30/255.0 alpha:1.0]
#define kSeparatorWidth 1.0

static NSDateFormatter* _dateFormatterTime = nil;
static NSDateFormatter* _dateFormatterDay = nil;
static NSDateFormatter* _dateFormatterDayMonthYear = nil;

@interface YTPhotosThumbsView()

- (BOOL)isThumbInVisibleArea:(CGRect)thumbFrame;

@end


@interface YTPhotosThumbsView_ThumbView()

- (CGSize)sizeOfLoadedImage;

@end


@interface YTPhotosThumbsView_ContentView()

- (void)checkForNextThumbs;

@end


@implementation YTPhotosThumbsView_ThumbView

@synthesize delegate = _delegate;
@synthesize resourceImageView = _resourceImageView;
@synthesize showImageView = _showImageView;

- (void)createResourceImageView {
	if(!_resourceImageView) {
		CGRect rcImage = [self rectForImageView];
		_resourceImageView = [[YTResourceImageView alloc] initWithFrame:rcImage];
		_resourceImageView.delegate = self;
		_resourceImageView.drawOnMainThread = NO;
		_resourceImageView.useMiniImage = NO;
		if(kUseBigThumb) {
			_resourceImageView.makeThumbnails = NO;
			_resourceImageView.makePreview = YES;
			_resourceImageView.aspectFill = YES;
		} else {
			_resourceImageView.makeThumbnails = YES;
			_resourceImageView.makePreview = NO;
		}
		if(kUseBigThumb)
			_resourceImageView.backgroundColor = [UIColor blackColor];
		[self insertSubview:_resourceImageView atIndex:0];
		[self layoutSubviews];
		if(self.resource)
			_resourceImageView.resource = self.resource;
	}
}

- (void)initialize {
	[super initialize];
    
	self.backgroundColor = kUseBigThumb ? [UIColor blackColor] : [UIColor clearColor];
	
	if(kShowDates) {
        
		_lbTime = [[VLLabel alloc] initWithFrame:CGRectZero];
		_lbDay = [[VLLabel alloc] initWithFrame:CGRectZero];
		_lbDate = [[VLLabel alloc] initWithFrame:CGRectZero];
		NSArray *labels = [NSArray arrayWithObjects:_lbTime, _lbDay, _lbDate, nil];
		for(VLLabel *label in labels) {
			label.backgroundColor = [UIColor clearColor];
			label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			label.textAlignment = NSTextAlignmentRight;
			label.textColor = [UIColor colorWithWhite:0xF8/255.0 alpha:1.0];
			label.adjustsFontSizeToFitWidth = YES;
			[self addSubview:label];
		}
	}
	
	_button = [UIButton buttonWithType:UIButtonTypeCustom];
	[_button setBackgroundImage:[UIImage imageNamed:@"black_rect_64.png"] forState:UIControlStateHighlighted];
	_button.alpha = 0.25;
	[_button addTarget:self action:@selector(onButtonTap:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_button];
	
	if(kUseBigThumb)
		self.clipsToBounds = YES;
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange addObserver:self selector:@selector(updateViewAsync)];
}

- (void)updateFonts:(id)sender {
	_lbTime.font = [[YTFontsManager shared] boldFontWithSize:9 fixed:YES];
	_lbDay.font = [[YTFontsManager shared] boldFontWithSize:27 fixed:YES];
	_lbDate.font = [[YTFontsManager shared] boldFontWithSize:10 fixed:YES];
	[self setNeedsLayout];
}

- (void)setShowImageView:(BOOL)showImageView {
	if(_showImageView != showImageView) {
		_showImageView = showImageView;
        YTAttachment* attachment = self.resource;
		if(_showImageView) {
			if(attachment && !_resourceImageView)
				[self createResourceImageView];
		} else {
			if(kPreloadViews && _resourceImageView) {
				[_resourceImageView removeFromSuperview];
				_resourceImageView = nil;
			}
		}
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	YTAttachment *res = self.resource;
	if(!res) {
        NSLog(@"resource is nil");
		return;
    }
    
    [self updateLabels];
}

//updates labels
- (void) updateLabels {
	if(kShowDates) {
        YTAttachment *res = self.resource;
        
		NSDate *date = res.createdDate;
        
        if (_dateFormatterTime == nil) {
            _dateFormatterTime = [[NSDateFormatter alloc] init];
            _dateFormatterTime.dateStyle = NSDateFormatterNoStyle;
            _dateFormatterTime.timeStyle = NSDateFormatterShortStyle;
            
            _dateFormatterDay = [[NSDateFormatter alloc] init];
            _dateFormatterDay.timeStyle = NSDateFormatterNoStyle;
            _dateFormatterDay.dateFormat = @"dd";

            _dateFormatterDayMonthYear = [[NSDateFormatter alloc] init];
            _dateFormatterDayMonthYear.timeStyle = NSDateFormatterNoStyle;
            _dateFormatterDayMonthYear.dateFormat = @"EEEE, MMM yyyy";
            
        }
        
		NSString *sTime = [_dateFormatterTime stringFromDate:date];
		_lbTime.text = sTime;
		NSString *sDay = [_dateFormatterDay stringFromDate:date];
		_lbDay.text = sDay;
		NSString *sDate = [[_dateFormatterDayMonthYear stringFromDate:date] uppercaseString];
		_lbDate.text = sDate;
	}
}

- (YTPhotosThumbsView *)parentThumbsView {
	return (YTPhotosThumbsView *)[VLCtrlsUtils getParentViewOfClass:[YTPhotosThumbsView class] ofView:self];
}

- (BOOL)resourceImageView:(YTResourceImageView *)resourceImageView isVisible:(id)param {
	if(!self.superview)
		return NO;
	BOOL result = NO;
	if(_delegate && [_delegate respondsToSelector:@selector(thumbView:isVisible:)])
		result = [_delegate thumbView:self isVisible:nil];
	return result;
}

/*
- (void)onResourceDataChanged {
	[super onResourceDataChanged];
	YTResourceInfo *resInfo = self.resource;
	if(resInfo && !_resourceImageView && !kPreloadViews)
		[self createResourceImageView];
	if(!_forcedShowImage && _resourceImageView)
		_resourceImageView.resource = resInfo;
	[self updateViewAsync];
}
*/

- (CGRect)rectForImageView {
	CGRect rcBnds = self.bounds;
	CGRect rcImage = rcBnds;
	if(kUseBigThumb)
		rcImage = CGRectInset(rcImage, -1, -1);
	return rcImage;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_button.frame = rcBnds;
	CGRect rcImage = [self rectForImageView];
	if(_resourceImageView.superview == self)
		_resourceImageView.frame = rcImage;
	if(kShowDates) {
		CGRect rcLabels = CGRectInset(rcBnds, 4, 4);
		rcLabels.size.width -= 3;
		float distY = -3;
		CGRect rcLbDate = rcLabels;
		rcLbDate.size.height = [@"W" vlSizeWithFont:_lbDate.font].height;
		rcLbDate.origin.y = CGRectGetMaxY(rcLabels) - rcLbDate.size.height;
		_lbDate.frame = rcLbDate;
		CGRect rcLbDay = rcLabels;
		rcLbDay.size.height = [@"W" vlSizeWithFont:_lbDay.font].height;
		rcLbDay.origin.y = rcLbDate.origin.y - distY - rcLbDay.size.height;
		_lbDay.frame = rcLbDay;
		CGRect rcLbTime = rcLabels;
		rcLbTime.size.height = [@"W" vlSizeWithFont:_lbTime.font].height;
		rcLbTime.origin.y = rcLbDay.origin.y - distY - rcLbTime.size.height;
		_lbTime.frame = rcLbTime;
	}
}

- (void)onButtonTap:(id)sender {
    
    NSLog(@"YTPhotosThumbsView::onButtonTap");
    
	[[VLMessageCenter shared] performBlock:^{
		YTAttachment *resInfo = self.resource;
		if(!resInfo)
			return;
        
        YTNote* note = resInfo.note;
        
		if(!note)
			return;
		YTNoteView *view = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class] parentView:[UIApplication sharedApplication].keyWindow];
		if(view && view.note == note)
			return;
		view = [[YTNoteView alloc] initWithFrame:CGRectZero];
		view.delegate = self;
		view.note = note;
		view.mainResource = self.resource;
		YTPhotosThumbsView *parentThumbsView = [self parentThumbsView];
		[[YTUiMediator shared] showNoteView:view optionalFromCellView:nil optionalOnThumbsView:parentThumbsView optionalFromThumbView:self];
	} afterDelay:0.01 ignoringTouches:YES];
}

- (void)noteView:(YTNoteView *)noteView finishWithAction:(EYTUserActionType)action {
	if(action == EYTUserActionTypeDelete) {
		[[YTUiMediator shared] deleteNoteWithNoteView:noteView resultBlock:^(BOOL result) {
			if(result) {
				[[YTSlidingContainerView shared] closeNoteView:noteView toThumbView:self];
			}
		}];
		return;
	}
	[[YTSlidingContainerView shared] closeNoteView:noteView toThumbView:self];
}

//TODO:::implement
- (CGSize)sizeOfLoadedImage {
    NSLog(@"TODO::YTPhotosThumbsView:::toimplement");
    return CGSizeZero;

    /*
	YTResourceInfo *res = self.resource;
	if(!res)
		return CGSizeZero;
	CGSize result = CGSizeZero;
	if(_resourceImageView)
		result = [_resourceImageView sizeOfLoadedImage];
	return result;
	//return [[YTResourcesStorage shared] sizeOfLoadedImage:res];
     */      
}

- (void)removeFromSuperview {
//    NSLog(@"YTPhotosThumbsView_ThumbView::removeFromSuperview");
    [[self subviews]
        makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange removeObserver:self];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
    
    self.resourceImageView = nil;
    self.delegate = nil;
    self.lbDate = nil;
    self.lbDay = nil;
    self.lbTime = nil;
    self.button = nil;
    
    [super removeFromSuperview];
}

- (void)dealloc {
//    NSLog(@"YTPhotosThumbsView_ThumbView::dealloc");
}

@end

@implementation YTPhotosThumbsView_ContentView

@synthesize parentThumbsViewRef = _parentThumbsViewRef;
@synthesize arrThumbs = _arrThumbs;
@synthesize arrResViewsFrames = _arrResViewsFrames;

- (id)initWithFrame:(CGRect)frame parentThumbsView:(YTPhotosThumbsView *)parentThumbsView maxWaitingTimeToLoad:(NSTimeInterval)maxWaitingTimeToLoad {
	_parentThumbsViewRef = parentThumbsView;
	_maxWaitingTimeToLoad = maxWaitingTimeToLoad;
	self = [super initWithFrame:frame];
	if(self) {
		
	}
	return self;
}

- (void)initialize {
	[super initialize];
	_arrResImages = [[NSMutableArray alloc] init];
	_arrResImagesSizes = [[NSMutableArray alloc] init];
	_arrResViewsFrames = [[NSMutableArray alloc] init];
	_arrThumbs = [[NSMutableArray alloc] init];
	_updatingInBackgroundArrResImages = [[NSMutableArray alloc] init];
	self.backgroundColor = [UIColor clearColor];
	
	_backViewSep = [[UIView alloc] initWithFrame:CGRectZero];
	_backViewSep.backgroundColor = kSeparatorColor;
	[self addSubview:_backViewSep];
	
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning addObserver:self selector:@selector(onReceiveMemoryWarning:)];
	[[VLAppDelegateBase sharedAppDelegateBase].msgrApplicationDidBecomeActive addObserver:self selector:@selector(onApplicationDidBecomeActive:)];
	
	[self checkForNeedUpdate];
	
	[self updateViewAsync];
}

- (void)checkForNeedUpdate {
    
    NSLog(@"YTPhotosThumbsView::checkForNeedUpdate");
    
    CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1)
		return;
	BOOL inBackground = YES;
	float allViewsWidth = rcBnds.size.width;
	BOOL needUpdate = NO;
	BOOL widthChanged = NO;
	if(allViewsWidth != _allViewsWidth) {
		if(!_updatingInBackground || _updatingInBackgroundAllViewsWidth != allViewsWidth) {
			needUpdate = YES;
			inBackground = NO;
			widthChanged = YES;
		}
	}
    
    YTAttachmentManager* attachmentsMgr = [YTAttachmentManager sharedManager];
	NSArray *arrAllRes = [NSArray arrayWithArray: [attachmentsMgr getAllAttachments]];
	NSMutableArray *arrNewRes = [NSMutableArray array];
	for(YTAttachment *resInfo in arrAllRes) {
		if([resInfo isImage]) {
			YTNote *note = resInfo.note;
			if(!note || resInfo.preview == nil)
				continue;
			[arrNewRes addObject:resInfo];
		}
	}
    
	[YTNoteResourcesListView sortResources:arrNewRes optionalMainResource:nil];
	if(!needUpdate) {
		if(![_arrResImages isEqualToArray:arrNewRes]) {
			if(!_updatingInBackground || ![_updatingInBackgroundArrResImages isEqualToArray:arrNewRes])
				needUpdate = YES;
		}
	}
    
	if(!needUpdate)
		return;
	
    NSLog(@"Ok, we'll need to update");
    
    NSMutableArray *arrNewResSizes = [NSMutableArray array];
	for(YTAttachment *resInfo in arrNewRes) {
        //TODO::::we may want to store orientation info
		CGSize imageSize = CGSizeMake([resInfo.width floatValue], [resInfo.height floatValue]);
		[arrNewResSizes addObject:[NSValue valueWithCGSize:imageSize]];
	}
	_updatingInBackground = YES;
	int updatingInBackgroundTicket = ++_updatingInBackgroundTicket;
	[self performInBackground:inBackground updateBlock:^{

		float allHeight = 0;
		NSArray *frames = [self getFramesForImageViewSizes:arrNewResSizes boundsWidth:allViewsWidth allHeight:&allHeight];
		
		[self performUpdateEndBlock:^{

			if(updatingInBackgroundTicket != _updatingInBackgroundTicket)
				return;
			_updatingInBackground = NO;
			
			_allViewsWidth = allViewsWidth;
			[_arrResImages removeAllObjects];
			[_arrResImages addObjectsFromArray:arrNewRes];
			[_arrResImagesSizes removeAllObjects];
			[_arrResImagesSizes addObjectsFromArray:arrNewResSizes];
			
			if(_allViewsHeight != allHeight) {
				_allViewsHeight = allHeight;
				if(_parentThumbsViewRef)
					[_parentThumbsViewRef setNeedsLayout];
			}
			[_arrResViewsFrames removeAllObjects];
			for(int i = 0; i < frames.count; i++) {
				NSValue *valFrame = [frames objectAtIndex:i];
				CGRect rcFrameRef = [valFrame CGRectValue];
				CGRect rcFrame = rcFrameRef;
				if(CGRectGetMaxX(rcFrame) < _allViewsWidth)
					rcFrame.size.width -= kSeparatorWidth;
				if(CGRectGetMaxY(rcFrame) < _allViewsHeight)
					rcFrame.size.height -= kSeparatorWidth;
				[_arrResViewsFrames addObject:[NSValue valueWithCGRect:rcFrame]];
			}
			NSMutableDictionary *mapViewByResHash = [NSMutableDictionary dictionaryWithCapacity:_arrThumbs.count];
			for(int i = 0; i < _arrThumbs.count; i++) {
				id idView = [_arrThumbs objectAtIndex:i];
				YTPhotosThumbsView_ThumbView *thumbView = ObjectCast(idView, YTPhotosThumbsView_ThumbView);
				if(thumbView && thumbView.resource)
					[mapViewByResHash setObject:thumbView forKey:thumbView.resource.uniqueIdentifier];
			}
			[_arrThumbs removeAllObjects];
			for(int i = 0; i < _arrResImages.count; i++) {
				YTAttachment *resInfo = [_arrResImages objectAtIndex:i];
				YTPhotosThumbsView_ThumbView *thumbView = [mapViewByResHash objectForKey:resInfo.uniqueIdentifier];
				if(thumbView) {
					[_arrThumbs addObject:thumbView];
					[mapViewByResHash removeObjectForKey:resInfo.uniqueIdentifier];
				} else {
					[_arrThumbs addObject:[NSNull null]];
				}
			}
			for(YTPhotosThumbsView_ThumbView *thumbView in mapViewByResHash.allValues)
				[thumbView removeFromSuperview];
			if(widthChanged)
				[self clearUnvisibleThumbs];
			for(int i = 0; i < _arrThumbs.count; i++) {
				id idView = [_arrThumbs objectAtIndex:i];
				YTPhotosThumbsView_ThumbView *thumbView = ObjectCast(idView, YTPhotosThumbsView_ThumbView);
				if(!thumbView)
					continue;
				CGRect thumbFrame = [(NSValue *)[_arrResViewsFrames objectAtIndex:i] CGRectValue];
				if(!CGRectEqualToRect(thumbView.frame, thumbFrame))
					thumbView.frame = thumbFrame;
			}
			[self checkForNextThumbs];
		}];

	}];
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

- (void)onUpdateView {
	[super onUpdateView];
    NSLog(@"YTPhotosThumbsView::onUpdateView");
    
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1)
		return;
	[self checkForNeedUpdate];
}

- (NSArray *)getFramesForImageViewSizes:(NSArray *)viewsSizes boundsWidth:(float)boundsWidth allHeight:(float *)allHeight {
	NSMutableArray *resultFrames = [NSMutableArray array];
	if(allHeight)
		*allHeight = 0;
	int viewsCount = (int)viewsSizes.count;
	if(viewsCount == 0)
		return resultFrames;
	NSMutableArray *arrSizes = [NSMutableArray array];
	NSMutableArray *arrSides = [NSMutableArray array];
	int totalSides = 0;
	int minSides = 0;
	int maxSides = 0;
	for(NSValue *viewSize in viewsSizes) {
		CGSize size = [viewSize CGSizeValue];
		[arrSizes addObject:[NSValue valueWithCGSize:size]];
		int sides = (int)(size.width + size.height);
		[arrSides addObject:[NSNumber numberWithInt:sides]];
		totalSides += sides;
		maxSides = MAX(maxSides, sides);
		if(!minSides)
			minSides = sides;
		else
			minSides = MIN(minSides, sides);
	}
	NSMutableArray *mosaicItems = [NSMutableArray array];
	for(int i = 0; i < viewsSizes.count; i++) {
		VLMosaicImagesLayouter_MosaicData *item = [[VLMosaicImagesLayouter_MosaicData alloc] init];
		int sides = [[arrSides objectAtIndex:i] intValue];
		int nMinSize = 1;
		int nMaxSize = 2;
		int nSize = nMinSize + round((((maxSides - minSides) - (sides - minSides)) / (double)(maxSides - minSides)) * (nMaxSize - nMinSize));
		nSize = MAX(MIN(nSize, nMaxSize), nMinSize);
		item.size = nSize;
		[mosaicItems addObject:item];
	}
	VLMosaicImagesLayouter *layouter = [[VLMosaicImagesLayouter alloc] init];
	CGSize frameSize = CGSizeMake(boundsWidth, 240);
	[layouter setupLayoutWithMosaicElements:mosaicItems frameSize:frameSize moduleSize:boundsWidth / 4.0];
	float maxY = 0;
	for(VLMosaicImagesLayouter_MosaicData *item in mosaicItems)
		maxY = MAX(maxY, CGRectGetMaxY(item.resultRect));
	if(allHeight)
		*allHeight = maxY;
	for(int i = 0; i < viewsSizes.count; i++) {
		VLMosaicImagesLayouter_MosaicData *item = [mosaicItems objectAtIndex:i];
		[resultFrames addObject:[NSValue valueWithCGRect:item.resultRect]];
	}
	return resultFrames;
}

- (void)layoutSubviews {
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	[self checkForNeedUpdate];
	CGRect rcBackSep = rcBnds;
	rcBackSep.size.height = _allViewsHeight;
	_backViewSep.frame = rcBackSep;
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = _allViewsHeight;
	return size;
}

- (void)onNotesManagerChanged {
	[super onNotesManagerChanged];
	[self updateViewAsync];
}

- (void)onResourcesManagerChanged {
	[super onResourcesManagerChanged];
	[self updateViewAsync];
}

- (void)checkForNextThumbs {
//    NSLog(@"YTPhotosThumbsView::checkForNextThumbs");
    
	if(!_parentThumbsViewRef)
		return;
    
//    NSLog(@"bla1");
    
	for(int i = 0; i < [_arrResViewsFrames count]; i++) {
		id idView = [_arrThumbs objectAtIndex:i];
		YTPhotosThumbsView_ThumbView *thumbView = ObjectCast(idView, YTPhotosThumbsView_ThumbView);
		if(thumbView) {
			if(kPreloadViews) {
				CGRect thumbFrame = [(NSValue *)[_arrResViewsFrames objectAtIndex:i] CGRectValue];
				if([_parentThumbsViewRef isThumbInVisibleArea:thumbFrame]) {
					thumbView.showImageView = YES;
				}
			}
			continue;
		}
		CGRect thumbFrame = [(NSValue *)[_arrResViewsFrames objectAtIndex:i] CGRectValue];
		if(kPreloadViews || [_parentThumbsViewRef isThumbInVisibleArea:thumbFrame]) {
			thumbView = [[YTPhotosThumbsView_ThumbView alloc] initWithFrame:thumbFrame];
			thumbView.delegate = self;
			[_arrThumbs replaceObjectAtIndex:i withObject:thumbView];
			[self addSubview:thumbView];
			YTAttachment *resInfo = [_arrResImages objectAtIndex:i];
			thumbView.resource = resInfo;
            [thumbView updateLabels];
            
            
			if(kPreloadViews && [_parentThumbsViewRef isThumbInVisibleArea:thumbFrame])
				thumbView.showImageView = YES;
		}
	}
}

- (BOOL)thumbView:(YTPhotosThumbsView_ThumbView *)thumbView isVisible:(id)param {
	CGRect thumbFrame = thumbView.frame;
	BOOL result = [_parentThumbsViewRef isThumbInVisibleArea:thumbFrame];
	return result;
}

- (void)clearUnvisibleThumbs {
	for(int i = 0; i < _arrResViewsFrames.count; i++) {
		id idView = [_arrThumbs objectAtIndex:i];
		YTPhotosThumbsView_ThumbView *thumbView = ObjectCast(idView, YTPhotosThumbsView_ThumbView);
		if(!thumbView)
			continue;
		CGRect thumbFrame = [(NSValue *)[_arrResViewsFrames objectAtIndex:i] CGRectValue];
		if(!_parentThumbsViewRef || ![_parentThumbsViewRef isThumbInVisibleArea:thumbFrame]) {
			if(kPreloadViews) {
				thumbView.showImageView = NO;
			} else {
				[thumbView removeFromSuperview];
				[_arrThumbs replaceObjectAtIndex:i withObject:[NSNull null]];
			}
		}
	}
}

- (void)onReceiveMemoryWarning:(id)sender {
	[self clearUnvisibleThumbs];
}

- (void)onApplicationDidBecomeActive:(id)sender {
	[self clearUnvisibleThumbs];
}

- (void)removeFromSuperview {
//    NSLog(@"YTPhotosThumbsView_ContentView::removeFromSuperview");
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.parentThumbsViewRef = nil;
    self.arrThumbs = nil;
    self.arrResViewsFrames = nil;
    self.backViewSep = nil;
    self.arrResImages = nil;
    self.arrResImagesSizes = nil;
    self.updatingInBackgroundArrResImages = nil;
        
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning removeObserver:self];
	[[VLAppDelegateBase sharedAppDelegateBase].msgrApplicationDidBecomeActive removeObserver:self];
    
    [super removeFromSuperview];
}

- (void)dealloc {
//    NSLog(@"YTPhotosThumbsView_ContentView::dealloc");
}

@end


@implementation YTPhotosThumbsView

+ (YTPhotosThumbsView *)currentInstance {
	NSMutableArray *arrViews = [NSMutableArray arrayWithArray:
								[VLCtrlsUtils getSubViewsOfClass:[YTPhotosThumbsView class] parentView:[UIApplication sharedApplication].keyWindow]];
	for(int i = (int) [arrViews count] - 1; i >= 0; i--) {
		YTPhotosThumbsView *view = [arrViews objectAtIndex:i];
		if(view.hidden) {
			[arrViews removeObjectAtIndex:i];
			continue;
		}
	}
	return [arrViews count] ? [arrViews objectAtIndex:0] : nil;
}

- (id)initWithFrame:(CGRect)frame maxWaitingTimeToLoad:(NSTimeInterval)maxWaitingTimeToLoad {
	_maxWaitingTimeToLoad = maxWaitingTimeToLoad;
	self = [super initWithFrame:frame];
	if(self) {
		
	}
	return self;
}

- (void)initialize {
	[super initialize];
    
    NSLog(@"YTPhotosThumbsView::initialize");
    
	if(!_maxWaitingTimeToLoad)
		_maxWaitingTimeToLoad = kDefaultMaxWaitingTimeToLoad;
	self.backgroundColor = kUseBigThumb ? [UIColor blackColor] : [UIColor whiteColor];
	
	self.customNavBar.btnBack.hidden = NO;
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Photos {Title}", nil);
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnBackTap:) forControlEvents:UIControlEventTouchUpInside];
	
	self.customNavBar.btnRight.hidden = NO;
	[self.customNavBar.btnRight setImage:[UIImage imageNamed:@"bbi_camera.png"] forState:UIControlStateNormal];
	[self.customNavBar.btnRight addTarget:self action:@selector(onBtnAddPhotoTap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	CGRect rcBnds = self.boundsNoBars;
	
	_scrollView = [[UIScrollView alloc] initWithFrame:rcBnds];
	_scrollView.delegate = self;
	[self addSubview:_scrollView];
	
	CGRect rcCont = _scrollView.frame;
	rcCont.origin = CGPointZero;
	_contentView = [[YTPhotosThumbsView_ContentView alloc] initWithFrame:rcCont parentThumbsView:self maxWaitingTimeToLoad:_maxWaitingTimeToLoad];
	[_scrollView addSubview:_contentView];
	
	_timer = [[VLTimer alloc] init];
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	_timer.enabledAlwaysFiring = YES;
	_timer.interval = 0.25;
	[_timer start];
	
	[self updateViewAsync];
	
    //observe changes on note
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object: [DatabaseManager sharedManager].managedObjectContext];
    
	if(self.bounds.size.width > 0) {
		[self layoutSubviews];
		[_contentView layoutSubviews];
	}
}

//we received a change object
- (void) handleDataModelChange: (NSNotification*) notification {

    NSSet* insertedObjects = [[notification userInfo] objectForKey: NSInsertedObjectsKey];
    NSSet* deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    
    BOOL needsUpdate = NO;
    if ([insertedObjects count] > 0) {
        for(NSManagedObject* obj in insertedObjects) {
            if ([obj isKindOfClass: [YTAttachment class]]) {
                needsUpdate = YES;
                break;
            }
        }
    }
    
    if (!needsUpdate && [deletedObjects count] > 0) {
        for(NSManagedObject* obj in deletedObjects) {
            if ([obj isKindOfClass: [YTAttachment class]]) {
                needsUpdate = YES;
                break;
            }
        }
    }
    
    if (needsUpdate) {
        NSLog(@"photo thumbs new neeeds update");
        [_contentView checkForNeedUpdate];
    }
}
    

- (void)layoutSubviews {
    
    NSLog(@"YTPhotosThumbsView::layoutSubviews");
    
	//VLLoggerTrace(@"");
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	if(!CGRectEqualToRect(_scrollView.frame, rcBnds))
		_scrollView.frame = rcBnds;
	CGRect rcCont = CGRectZero;
	rcCont.size.width = rcBnds.size.width;
	rcCont.size.height = [_contentView sizeThatFits:rcCont.size].height;
	if(rcCont.size.height < rcBnds.size.height)
		rcCont.size.height = rcBnds.size.height;
	_scrollView.contentSize = rcCont.size;
	CGRect rcContFrame = CGRectMake(_contentView.frame.origin.x, _contentView.frame.origin.y, rcCont.size.width, rcCont.size.height);
	_contentView.frame = rcContFrame;
	rcCont.size.height = [_contentView sizeThatFits:rcCont.size].height;
	if(rcCont.size.height != rcContFrame.size.height) {
		rcContFrame = CGRectMake(_contentView.frame.origin.x, _contentView.frame.origin.y, rcCont.size.width, rcCont.size.height);
		_contentView.frame = rcContFrame;
	}
	
}

- (BOOL)isAllImagesShown {
	BOOL visibleFound = NO;
	for(int i = 0; i < _contentView.arrThumbs.count; i++) {
		NSValue *valFrame = [_contentView.arrResViewsFrames objectAtIndex:i];
		CGRect thumbFrame = [valFrame CGRectValue];
		if([self isThumbInVisibleArea:thumbFrame]) {
			visibleFound = YES;
			id idView = [_contentView.arrThumbs objectAtIndex:i];
			YTPhotosThumbsView_ThumbView *view = ObjectCast(idView, YTPhotosThumbsView_ThumbView);
			if(!view)
				return NO;
			if(![view.resourceImageView isImageShown])
				return NO;
		} else {
			if(visibleFound)
				return YES;
			continue;
		}
	}
	return YES;
}

- (BOOL)isThumbInVisibleArea:(CGRect)thumbFrame {
	CGRect rcBnds = [self boundsNoBars];
	CGRect rcThumb = [self convertRect:thumbFrame fromView:_contentView];
	float approachHeight = 32;//100;
	CGRect rcArea = rcBnds;
	rcArea.origin.y -= approachHeight;
	rcArea.size.height += approachHeight * 2;
	if(CGRectIntersectsRect(rcArea, rcThumb))
		return YES;
	return NO;
}

- (void)onTimerEvent:(id)sender {
	[_contentView checkForNextThumbs];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_contentView checkForNextThumbs];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self beginIsScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if(!decelerate)
		[self endIsScrolling];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self endIsScrolling];
}

- (void)onBtnAddPhotoTap:(id)sender {
	[[YTUiMediator shared] startAddNewNoteAsPhoto:YES
                                         Notebook:nil
										isStarred:NO
							  previousScreenTitle:self.customNavBar.titleLabel.text];
}

- (void)onBtnBackTap:(id)sender {
	if(self.navigatingViewDelegate && [self.navigatingViewDelegate respondsToSelector:@selector(navigatingView:handleGoBack:)])
		[self.navigatingViewDelegate navigatingView:self handleGoBack:nil];
}

/*
- (void)didMoveToSuperview {
    NSLog(@"YTPhotosThumbsView::didMoveToSuperview");
    [_contentView checkForNeedUpdate];
    [super didMoveToSuperview];
}
*/

/*
- (void)removeFromSuperview {
    NSLog(@"YTPhotosThumbsView::removeFromSuperview");
    
    return;
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.scrollView = nil;
    self.contentView = nil;
    [self.timer stop];
    [self.timer setObserver:nil selector:nil];
    self.timer = nil;

    [super removeFromSuperview];
}
 */

- (void)dealloc {
//    NSLog(@"YTPhotosThumbsView::dealloc");
}

@end

