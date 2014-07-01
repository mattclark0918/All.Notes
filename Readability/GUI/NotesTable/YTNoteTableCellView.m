
#import "YTNoteTableCellView.h"
#import "YTNotesTableView.h"

#define kDrawThumbOnMainThread NO//YES//NO

#define kInsetLeft 10.0
#define kInsetTop 7.0
#define kInsetRight 12.0
#define kInsetBottom 7.0

#define kInsetMosaicLeft 0.0 // Left Inset for Map + Mosaic (previously kInsetLeft)
#define kInsetMosaicRight 0.0 // Right Inset for Map +  Mosaic (previously kInsetRight)

#define kPaddingGapBottomTop 10.
#define kPaddingGapBottomInner 5.

#define kThumbnailHeight 95.
#define kMapWidth 90
#define kDateDayLabelSize CGSizeMake(60., 50.)//CGSizeMake(54, 54)
#define kHeightForLabels 45.
#define kMaxLocationLabelHeight 20.
//#define kContentHeight (kInsetTop + kThumbnailSize.height + kInsetBottom)
#define kMaxTextLinesCount 2
#define kBottomSeparatorHeight 10.0
#define kDateColorNoImage [UIColor colorWithRed:0x30/255.0 green:0x30/255.0 blue:0x30/255.0 alpha:1.0]
//#define kDateColorNoImage [UIColor colorWithRed:0xEE/255.0 green:0x80/255.0 blue:0x30/255.0 alpha:1.0]
#define kDateColorWithImage [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0]
#define kSeparatorColorTop [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]
#define kSeparatorColorBottom [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]

static UIFont *_fontForTextCapital;
static UIFont *_fontForTextContent;
static UIFont *_fontForLabelDateDay;
static UIFont *_fontForLabelDateWeekday;
static float _heightForTextCapitalLine = -1;
static float _heightForTextContentLine = -1;
static float _heightForLabelDateDay = -1;
static float _heightForLabelDateWeekday = -1;
static UIColor *_dateDayTextColorStarred = nil;



static YTNoteTableCellViewManager *_shared;

@implementation YTNoteTableCellViewManager

+ (YTNoteTableCellViewManager *)shared {
	if(!_shared)
		_shared = [[YTNoteTableCellViewManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(onFontsChanged:)];
	}
	return self;
}

- (void)initialize {
	
}

- (void)onFontsChanged:(id)sender {
	_fontForTextCapital = nil;
	_fontForTextContent = nil;
	_fontForLabelDateDay = nil;
	_fontForLabelDateWeekday = nil;
	_heightForTextCapitalLine = -1;
	_heightForTextContentLine = -1;
	_heightForLabelDateDay = -1;
	_heightForLabelDateWeekday = -1;
}

- (UIFont *)fontForTextCapital {
	if(!_fontForTextCapital)
		_fontForTextCapital = [[YTFontsManager shared] fontNoteTextCapital];
	return _fontForTextCapital;
}

- (UIFont *)fontForTextContent {
	if(!_fontForTextContent)
		_fontForTextContent = [[YTFontsManager shared] fontNoteTextContent];
	return _fontForTextContent;
}

- (UIFont *)fontForLabelDateDay {
	if(!_fontForLabelDateDay)
		_fontForLabelDateDay = [[YTFontsManager shared] boldFontWithSize:26 fixed:YES];
	return _fontForLabelDateDay;
}

- (UIFont *)fontForLabelDateWeekday {
	if(!_fontForLabelDateWeekday)
		_fontForLabelDateWeekday = [[YTFontsManager shared] fontWithSize:8 fixed:YES];
	return _fontForLabelDateWeekday;
}

- (float)heightForTextCapitalLine {
	if(_heightForTextCapitalLine < 0)
		_heightForTextCapitalLine = [@"W" vlSizeWithFont:[self fontForTextCapital]].height;
	return _heightForTextCapitalLine;
}

- (float)heightForTextContentLine {
	if(_heightForTextContentLine < 0)
		_heightForTextContentLine = [@"W" vlSizeWithFont:[self fontForTextContent]].height;
	return _heightForTextContentLine;
}

- (float)heightForLabelDateDay {
	if(_heightForLabelDateDay < 0)
		_heightForLabelDateDay = [@"W" vlSizeWithFont:[self fontForLabelDateDay]].height;
	return _heightForLabelDateDay;
}

- (float)heightForLabelDateWeekday {
	if(_heightForLabelDateWeekday < 0)
		_heightForLabelDateWeekday = [@"W" vlSizeWithFont:[self fontForLabelDateWeekday]].height;
	return _heightForLabelDateWeekday;
}

- (UIColor *)dateDayTextColorStarred {
	if(!_dateDayTextColorStarred)
		_dateDayTextColorStarred = kYTNoteDateDayTextColorStarred;
	return _dateDayTextColorStarred;
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
}

@end




@interface YTNoteTableCellView_ThumbFrame : YTBaseView {
@private
}
@end

@implementation YTNoteTableCellView_ThumbFrame

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	float lineW = 1.0;
	float corner = 1.33;
	static UIColor *_lineColor;
	if(!_lineColor)
		_lineColor = [UIColor colorWithRed:95/255.0 green:93/255.0 blue:77/255.0 alpha:0.98];
	[_lineColor setStroke];
	CGContextSetLineWidth(ctx, lineW);
	CGRect rc = rcBnds;//CGRectInset(rcBnds, lineW/2, lineW/2);
	CGContextMoveToPoint(ctx, rc.origin.x + corner, rc.origin.y);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc) - corner, rc.origin.y);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc), rc.origin.y + corner);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc), CGRectGetMaxY(rc) - corner);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc) - corner, CGRectGetMaxY(rc));
	CGContextAddLineToPoint(ctx, rc.origin.x + corner, CGRectGetMaxY(rc));
	CGContextAddLineToPoint(ctx, rc.origin.x, CGRectGetMaxY(rc) - corner);
	CGContextAddLineToPoint(ctx, rc.origin.x, rc.origin.y + corner);
	CGContextAddLineToPoint(ctx, rc.origin.x + corner, rc.origin.y);
	CGContextStrokePath(ctx);
}

- (float)padding {
	return 0;
}

/*- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	float lineW = 2;
	float corner = 1.5;
	static UIColor *_lineColor;
	if(!_lineColor)
		_lineColor = [[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:0.9] retain];
	[_lineColor setStroke];
	CGContextSetLineWidth(ctx, lineW);
	CGRect rc = CGRectInset(rcBnds, lineW/2, lineW/2);
	CGContextMoveToPoint(ctx, rc.origin.x + corner, rc.origin.y);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc) - corner, rc.origin.y);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc), rc.origin.y + corner);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc), CGRectGetMaxY(rc) - corner);
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rc) - corner, CGRectGetMaxY(rc));
	CGContextAddLineToPoint(ctx, rc.origin.x + corner, CGRectGetMaxY(rc));
	CGContextAddLineToPoint(ctx, rc.origin.x, CGRectGetMaxY(rc) - corner);
	CGContextAddLineToPoint(ctx, rc.origin.x, rc.origin.y + corner);
	CGContextAddLineToPoint(ctx, rc.origin.x + corner, rc.origin.y);
	CGContextStrokePath(ctx);
	static UIColor *_lineColor2;
	if(!_lineColor2)
		_lineColor2 = [[UIColor colorWithRed:95/255.0 green:93/255.0 blue:77/255.0 alpha:0.8] retain];
	float lineW2 = 1;
	[_lineColor2 setStroke];
	CGContextSetLineWidth(ctx, lineW2);
	CGRect rc2 = CGRectInset(rcBnds, lineW - lineW2/2, lineW - lineW2/2);
	CGContextStrokeRect(ctx, rc2);
}

- (float)padding {
	return 1;
}*/

@end




@implementation YTNoteTableCellView_Separator

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[kSeparatorColorTop setFill];
	CGContextFillRect(ctx, CGRectMake(rcBnds.origin.x, rcBnds.origin.y, rcBnds.size.width, 1));
	[kSeparatorColorBottom setFill];
	CGContextFillRect(ctx, CGRectMake(rcBnds.origin.x, rcBnds.origin.y + 1, rcBnds.size.width, 1));
}

- (float)optimalHeight {
	return kBottomSeparatorHeight;
}

@end



@implementation YTNoteTableCellView

@synthesize cellInfo = _cellInfo;
@synthesize textView = _textView;
@synthesize thumbnailView = _thumbnailView;
@synthesize resourceImage = _resourceImage;
@synthesize mapView = _mapView;
@synthesize photoThumbsView = _photoThumbsView;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = YES;
}

- (id)initWithFrame:(CGRect)frame
           showDate:(BOOL)showDate
      showThumbnail:(BOOL)showThumbnail
 showAttachmentIcon:(BOOL)showAttachmentIcon
             hasMap:(BOOL)hasMap
               Note:(YTNote*) note
{
	
	self = [super initWithFrame:frame];
	if(self) {
		_showDate = showDate;
		_showThumbnail = showThumbnail;
		_showAttachmentIcon = showAttachmentIcon;
        _hasMap = hasMap;
		//_resourceImage = [resourceImage retain];
		
        self.note = note;
		_textView = [[YTNoteCellTextView alloc] initWithFrame:CGRectZero];
		[self addSubview:_textView];
		
		if(_showThumbnail) {
            _photoThumbsView = [[YTPhotosMosaicView alloc] initWithFrame:CGRectZero maxWaitingTimeToLoad:0.5 Note: self.note];
            _photoThumbsView.note = self.cellInfo.note;
            [self addSubview:_photoThumbsView];
            
            if (_hasMap) {
                _mapView = [[AsyncImageView alloc] initWithFrame:CGRectZero];
                [self addSubview:_mapView];
            }
		}
        
        if (!_showThumbnail && _hasMap){
            _locationLabelView = [[YTNoteLocationLabelView alloc] initWithFrame:CGRectZero];
            _locationLabelView.userInteractionEnabled = NO;
            [self addSubview:_locationLabelView];
        }
		
		if(_showDate) {
			_lbDateDay = [[VLLabel alloc] initWithFrame:CGRectZero];
			_lbDateWeekday = [[VLLabel alloc] initWithFrame:CGRectZero];
			NSArray *labels = [NSArray arrayWithObjects:_lbDateDay, _lbDateWeekday, nil];
            UIColor *textColor = kDateColorNoImage;
			for(VLLabel *label in labels) {
				label.adjustsFontSizeToFitWidth = YES;
				label.backgroundColor = [UIColor clearColor];
				label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
				label.textAlignment = NSTextAlignmentRight;
				label.textColor = textColor;
				[self addSubview:label];
			}
		}
		
//      //TODO:::comment to try to spot non clearing memory bug
//		[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
//		[self updateFonts:self];
//		[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange addObserver:self selector:@selector(updateViewAsync)];
	}
	return self;
}

- (void)updateFonts:(id)sender {
	if(_textView)
		[_textView setFontCapital:[[YTNoteTableCellViewManager shared] fontForTextCapital] fontContext:[[YTNoteTableCellViewManager shared] fontForTextContent]];
	if(_lbDateDay)
		_lbDateDay.font = [[YTNoteTableCellViewManager shared] fontForLabelDateDay];
	if(_lbDateWeekday)
		_lbDateWeekday.font = [[YTNoteTableCellViewManager shared] fontForLabelDateWeekday];
	[self setNeedsLayout];
}

- (YTNotesTableView *)getParentNotesTableView {
	return (YTNotesTableView *)[VLCtrlsUtils getParentViewOfClass:[YTNotesTableView class] ofView:self];
}

+ (float)contentHeight:(BOOL)showThumb hasLocation:(BOOL)hasLocation{
	float lineCapitalHeight = [[YTNoteTableCellViewManager shared] heightForTextCapitalLine];
	float lineContentHeight = [[YTNoteTableCellViewManager shared] heightForTextContentLine];
	float linesHeight = lineCapitalHeight + lineContentHeight * (kMaxTextLinesCount - 1);
    float result;
    if (showThumb){
        result = kInsetTop + linesHeight + kThumbnailHeight + kPaddingGapBottomTop + kInsetBottom;
    }
    else{
        float locationLabelHeight = 0;
        if (hasLocation) {
            locationLabelHeight = kMaxLocationLabelHeight;
        }
        result = kInsetTop + linesHeight + locationLabelHeight + kInsetBottom;
    }

	return result;
}

+ (float)optimalHeight:(BOOL)showThumb hasLocation:(BOOL)hasLocation{
	return [self contentHeight:showThumb hasLocation:hasLocation] + kBottomSeparatorHeight;
}

- (void)prepareForAddToTable {
	if(_thumbnailView) {
		_thumbnailView.resource = nil;
	}
	if(_cellInfo) {
		[_cellInfo.msgrVersionChanged removeObserver:self];
		_cellInfo = nil;
	}

}

- (void)applyCellInfo:(YTNoteTableCellInfo *)cellInfo {
    
    //PROFILE
    //NSLog(@"YTNoteTableCellView::applyCellInfo");
    
	if(_cellInfo != cellInfo) {
		if(_cellInfo) {
			[_cellInfo.msgrVersionChanged removeObserver:self];
		}
		_cellInfo = cellInfo;
		[_cellInfo.msgrVersionChanged addObserver:self selector:@selector(onCellInfoDataChanged:)];
	}
	if(_resourceImage) {
		_resourceImage = nil;
	}
	if(cellInfo.resourceImage)
		_resourceImage = cellInfo.resourceImage;
	[_textView setText:cellInfo.title];
	if(_showThumbnail != cellInfo.showThumbnail) {
		_showThumbnail = cellInfo.showThumbnail;
	}
    
	if(cellInfo.showThumbnail) {
        
        //PROFILE
        //NSLog(@"setting resource on applyCellInfo");
        
        //Show Thumbnail
		[_thumbnailView setResource:cellInfo.resourceImage];
        
        //Show Mosaic Image View
        //[_photoThumbsView setNote: cellInfo.note];
        [_photoThumbsView changeNote: cellInfo.note];
        
        //Map View
        if (cellInfo.note.location != nil) {
            YTLocation *location = cellInfo.note.location;
            NSString *strURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=11&size=%dx%d&markers=color:blue%%7Clabel:S%%7C%f,%f&sensor=false", [location.latitude doubleValue], [location.longitude doubleValue], kMapWidth * 2, 85 * 2, [location.latitude doubleValue], [location.longitude doubleValue]];
            
            _mapView.imageURL = [NSURL URLWithString:strURL];
        }
	}
    else if (cellInfo.note.location != nil) {
        _locationLabelView.note = cellInfo.note;
        [_locationLabelView updateViewNow]; //TODO::maybe think on a better way
    }
    
	if(_showDate != cellInfo.showDateLabels) {
		_showDate = cellInfo.showDateLabels;
	}
	if(cellInfo.showDateLabels) {
		if(![_lbDateDay.text isEqual:cellInfo.strDay]) {
			_lbDateDay.text = cellInfo.strDay;
		}
		_lbDateWeekday.text = cellInfo.strWeekday;
		
        if ([cellInfo.note.isFavorite boolValue]) {
			_lbDateDay.textColor = [[YTNoteTableCellViewManager shared] dateDayTextColorStarred];
        }
        else {
			_lbDateDay.textColor = kDateColorNoImage;
        }
        
	}
	if(_showAttachmentIcon != cellInfo.showAttachmentIcon) {
		_showAttachmentIcon = cellInfo.showAttachmentIcon;
	}
    
    [self setNeedsLayout];
}

- (void)onCellInfoDataChanged:(id)sender {
    
	if(_cellInfo) {
		[self applyCellInfo:_cellInfo];
	}
}

- (void)layoutSubviews {
    //PROFILE
//    NSLog(@"YTNoteTableCellView::layoutSubviews");
    
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcContFixed = rcBnds;
	rcContFixed.size.height -= kBottomSeparatorHeight;
	CGRect rcCont = rcContFixed;
	//float offsetX = 0;
	float spaceX = 4.0;
	//rcCont.origin.x += offsetX;
	CGRect rcContFree = rcCont;

	rcContFree.origin.y += kInsetTop;
	rcContFree.size.height -= kInsetTop + kInsetBottom;
    
    float lineCapitalHeight = [[YTNoteTableCellViewManager shared] heightForTextCapitalLine];
    float lineContentHeight = [[YTNoteTableCellViewManager shared] heightForTextContentLine];
    float linesHeight = lineCapitalHeight + lineContentHeight * (kMaxTextLinesCount - 1);
    
    if(!_showThumbnail && _hasMap){
                
        CGRect rcLocation = rcContFree;
        
        rcLocation.origin.y = CGRectGetMinY(rcContFree) + linesHeight;
        rcLocation.size.height = 0;
        rcLocation.size.height = [_locationLabelView sizeThatFits:rcLocation.size].height;
        
        rcLocation.origin.x += kInsetLeft;
        rcLocation.size.width -= kInsetLeft + kInsetRight;
        
        _locationLabelView.frame = rcLocation;
    }
	
	CGRect rcDay = CGRectZero;
	if(_showThumbnail || _showDate) {
		float datesDX = 0;
		CGRect rcRightBox = rcContFree;
		rcRightBox.size = kDateDayLabelSize;

        rcRightBox.origin.x = CGRectGetMaxX(rcContFree) - rcRightBox.size.width - kInsetRight;

        CGRect rcBottomFreeRect = rcContFree;
        rcBottomFreeRect.origin.y = CGRectGetMinY(rcContFree) + linesHeight + kPaddingGapBottomTop;
        rcBottomFreeRect.size.height -= linesHeight + kPaddingGapBottomTop;
        if (_hasMap && _showThumbnail) {
            CGRect rcMap = rcBottomFreeRect;
            
            rcMap.size.width = kMapWidth;
            _mapView.frame = rcMap;
            
            rcBottomFreeRect.origin.x += rcMap.size.width + kPaddingGapBottomInner;
            rcBottomFreeRect.size.width -= rcMap.size.width + kPaddingGapBottomInner;
        }
        
		if(_showThumbnail) {
            CGRect rcThumb = rcBottomFreeRect;
            rcThumb.size.width = rcBottomFreeRect.size.width;

            _photoThumbsView.frame = rcThumb;// [UIScreen roundRect:rcThumb];
            
		}
		if(_showDate) {
			float heightForLabelDateDay = [[YTNoteTableCellViewManager shared] heightForLabelDateDay];
			float heightForLabelDateWeekday = [[YTNoteTableCellViewManager shared] heightForLabelDateWeekday];
			CGRect rcDateAll = rcRightBox;
			rcDateAll.origin.x += 1;
			rcDateAll.size.width -= 2;
			CGRect rcWeekday = rcDateAll;
			rcWeekday.size.height = heightForLabelDateWeekday;
			rcWeekday.origin.y = CGRectGetMaxY(rcDateAll) - rcWeekday.size.height - rcDateAll.size.height * 0.04;
			rcDay = rcDateAll;
			rcDay.size.height = heightForLabelDateDay;
			rcDay.origin.y = rcWeekday.origin.y - rcDay.size.height;
			rcDay.origin.y += heightForLabelDateDay * 0.11;
			
			float freeH = (rcDateAll.size.height - rcDay.size.height - rcWeekday.size.height) / 3;
			float dy = freeH - (rcDay.origin.y - rcDateAll.origin.y);
			rcDay.origin.y += dy;
			rcWeekday.origin.y += dy;
			
			_lbDateWeekday.frame = [UIScreen roundRect:rcWeekday];
			_lbDateDay.frame = [UIScreen roundRect:rcDay];
			
			datesDX = rcDateAll.size.width;
		}
		float maxDX = datesDX;
		if(maxDX)
			maxDX += spaceX;
		rcContFree.size.width -= maxDX;
	}

	if(_showAttachmentIcon && !_showThumbnail && _showDate) {
		if(!_iconAttachment) {
			_iconAttachment = [[UIImageView alloc] initWithFrame:CGRectZero];
			_iconAttachment.backgroundColor = [UIColor clearColor];
			_iconAttachment.contentMode = UIViewContentModeCenter;
			_iconAttachment.image = [UIImage imageNamed:@"res_attachment.png"];
			[self addSubview:_iconAttachment];
		}
		CGRect rcIcon = rcDay;
		rcIcon.size.width = _iconAttachment.image.size.width;
		rcIcon.origin.x = CGRectGetMaxX(rcDay) - [_lbDateDay.text vlSizeWithFont:_lbDateDay.font].width - 2 - rcIcon.size.width;
		_iconAttachment.frame = [UIScreen roundRect:rcIcon];
	} else {
		if(_iconAttachment)
			_iconAttachment.hidden = YES;
	}
	
	rcContFree.origin.x += spaceX;
	rcContFree.size.width -= spaceX;
    rcContFree.size.height = kHeightForLabels;
	
	CGRect rcText = rcContFree;
    
    rcText.origin.x += kInsetLeft;
    rcText.size.width -= kInsetLeft + kInsetRight;
    
	if(_textView.superview == self)
		_textView.frame = rcText;
	
	CGRect rcSep = rcBnds;
	rcSep.size.height = kBottomSeparatorHeight;
	rcSep.origin.y = CGRectGetMaxY(rcContFixed);// - rcSep.size.height;
	if(_separator)
		_separator.frame = rcSep;
}

- (void)onSelectedChanged:(BOOL)selected {
	if(selected)
		self.backgroundColor = kYTNoteCellBackColorSel;
	else
		self.backgroundColor = [UIColor clearColor];
}

- (BOOL)canBeSelected {
	return YES;
}

- (void)showThumbnailFrame:(BOOL)show animated:(BOOL)animated {
//	if(_thumbFrame) {
//		if(animated) {
//			double delay = 0;
//			double duration = kDefaultAnimationDuration/8;
//			if(show) {
//				delay = kDefaultAnimationDuration - duration;
//			}
//			_thumbFrame.alpha = show ? 0.0 : 1.0;
//			[UIView animateWithDuration:duration
//								  delay:delay
//								options:0
//			animations:^{
//				_thumbFrame.alpha = show ? 1.0 : 0.0;
//			}
//			completion:^(BOOL finished) {
//				if(finished) {
//				}
//			}];
//		} else {
//			_thumbFrame.hidden = !show;
//			_thumbFrame.alpha = 1.0;
//		}
//	}
}

- (void)removeFromSuperview {
    //NSLog(@"YTNoteTableCellView::removeFromSuperview");
    
    [_textView removeFromSuperview];
    _textView = nil;
    _resourceImage = nil;
    [_lbDateDay removeFromSuperview];
    _lbDateDay = nil;
    [_lbDateWeekday removeFromSuperview];
    _lbDateWeekday = nil;
    [_locationLabelView removeFromSuperview];
    _locationLabelView = nil;
    [_separator removeFromSuperview];
    _separator = nil;
    _cellInfo = nil;
    [_photoThumbsView removeFromSuperview];
    _photoThumbsView = nil;
    [_mapView removeFromSuperview];
    _mapView = nil;
    [_thumbnailView removeFromSuperview];
    _thumbnailView = nil;
    
    
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];


    [super removeFromSuperview];

}

- (void)dealloc {
    //NSLog(@"YTNoteTableCellView::dealloc");
    
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange removeObserver:self];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	if(_cellInfo) {
		[_cellInfo.msgrVersionChanged removeObserver:self];
	}
}

@end




@implementation YTNotesTableViewCell

-(void) setFrame:(CGRect)frame
{
    float inset = 5.0f;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    frame.size.height -= kBottomSeparatorHeight;
    [super setFrame:frame];
}

- (void)internalSetSelected:(BOOL)selected {
	if(_lastSelected != selected) {
		_lastSelected = selected;
		YTNoteTableCellView *view = ObjectCast(self.subView, YTNoteTableCellView);
		if(view)
			[view onSelectedChanged:selected];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	YTNoteTableCellView *noteView = ObjectCast(self.subView, YTNoteTableCellView);
	if(noteView && ![noteView canBeSelected])
		return;
	[self internalSetSelected:selected];
	[super setSelected:selected animated:animated];
}

- (void)setSelected:(BOOL)selected {
	[self internalSetSelected:selected];
	[super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[self internalSetSelected:highlighted];
	[super setHighlighted:highlighted animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted {
	[self internalSetSelected:highlighted];
	[super setHighlighted:highlighted];
}

- (void)removeFromSuperview {
    //NSLog(@"YTNotesTableViewCell::removeFromSuperview");
    
    [[self.contentView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    [super removeFromSuperview];
}

- (void)dealloc {
    //NSLog(@"YTNotesTableViewCell::dealloc");
}

@end






