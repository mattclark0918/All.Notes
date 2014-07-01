
#import "YTResourceView.h"

@implementation YTResourceView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
	
	_lbError = [VLLabel new];
	_lbError.visible = NO;
	_lbError.backgroundColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0];
	_lbError.textColor = [UIColor redColor];
	_lbError.numberOfLines = 0;
	[_lbError centerText];
	_lbError.lineBreakMode = NSLineBreakByWordWrapping;
	[_lbError roundCorners:4];
	_lbError.adjustsFontSizeToFitWidthMultiLine = YES;
	_lbError.font = [[YTFontsManager shared] lightFontWithSize:16 fixed:YES];
	[self addSubview:_lbError];
	
	_btnReload = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	_btnReload.visible = NO;
	[_btnReload setTitleForAllStates:NSLocalizedString(@"Reload {Button}", nil)];
	[_btnReload addTarget:self action:@selector(onBtnReloadTap:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_btnReload];
	
	_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
	//[self addGestureRecognizer:tap];
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 0.2;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	
	[self updateViewAsync];
}

- (YTResourceBaseView *)subResourceView {
	if(_imageView)
		return _imageView;
	else if(_mediaView)
		return _mediaView;
	else if(_webDocView)
		return _webDocView;
	else if(_otherView)
		return _otherView;
	return nil;
}

- (void)resetState {
	_waitingForReloadStarted = NO;
}

- (void)setResource:(YTAttachment *)resource {
	if(self.resource != resource) {
		[super setResource:resource];
		[self resetState];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	YTResourceBaseView *lastSubView = [self subResourceView];
	YTAttachment *resource = self.resource;
	if(resource) {
        
		BOOL isOtherType = [resource isOtherType];
		if([resource isImage]) {
			if(_mediaView) {
				[_mediaView removeFromSuperview];
				_mediaView = nil;
			}
			if(_webDocView) {
				[_webDocView removeFromSuperview];
				_webDocView = nil;
			}
			if(_otherView) {
				[_otherView removeFromSuperview];
				_otherView = nil;
			}
			if(!_imageView) {
				_imageView = [[YTResourceImageView alloc] init];
				_imageView.drawOnMainThread = NO;
				_imageView.useMiniImage = YES;
				_imageView.backgroundColor = [UIColor clearColor];
				_imageView.activityBackColor = self.activityBackColor;
				[self addSubview:_imageView];
				[self setNeedsLayout];
			}
		} else if([resource isVideo] || [resource isAudio]) {
			if(_imageView) {
				[_imageView removeFromSuperview];
				_imageView = nil;
			}
			if(_webDocView) {
				[_webDocView removeFromSuperview];
				_webDocView = nil;
			}
			if(_otherView) {
				[_otherView removeFromSuperview];
				_otherView = nil;
			}
			if(!_mediaView) {
				_mediaView = [[YTResourceMediaView alloc] init];
				_mediaView.backgroundColor = [UIColor clearColor];
				_mediaView.activityBackColor = self.activityBackColor;
				[self addSubview:_mediaView];
				[self setNeedsLayout];
			}
		} else if([resource isWebDocViewable] && !isOtherType) {
			if(_imageView) {
				[_imageView removeFromSuperview];
				_imageView = nil;
			}
			if(_mediaView) {
				[_mediaView removeFromSuperview];
				_webDocView = nil;
			}
			if(_otherView) {
				[_otherView removeFromSuperview];
				_otherView = nil;
			}
			if(!_webDocView) {
				_webDocView = [[YTResourceWebDocView alloc] init];
				_webDocView.activityBackColor = self.activityBackColor;
				[self addSubview:_webDocView];
				[self setNeedsLayout];
			}
		} else {
			if(_imageView) {
				[_imageView removeFromSuperview];
				_imageView = nil;
			}
			if(_mediaView) {
				[_mediaView removeFromSuperview];
				_mediaView = nil;
			}
			if(_webDocView) {
				[_webDocView removeFromSuperview];
				_webDocView = nil;
			}
            
			if(!_otherView) {
				_otherView = [[YTResourceOtherView alloc] init];
				_otherView.backgroundColor = [UIColor clearColor];
				_otherView.activityBackColor = self.activityBackColor;
				[self addSubview:_otherView];
				[self setNeedsLayout];
			}
		}
	}
	if(_imageView)
		_imageView.resource = resource;
	if(_mediaView)
		_mediaView.resource = resource;
	if(_webDocView)
		_webDocView.resource = resource;
	if(_otherView)
		_otherView.resource = resource;
	YTResourceBaseView *curSubView = [self subResourceView];
	if(curSubView) {
		curSubView.makeThumbnails = self.makeThumbnails;
		curSubView.makePreview = self.makePreview;
		curSubView.aspectFill = self.aspectFill;
	}
    
    /*
	if(curSubView != lastSubView) {
		if(lastSubView)
			[lastSubView.loadingReference.msgrVersionChanged removeObserver:self];
		if(curSubView)
			[curSubView.loadingReference.msgrVersionChanged addObserver:self selector:@selector(onLoadingReferenceChanged_YTResourceView:)];
	}
	[self onLoadingReferenceChanged_YTResourceView:self];
    */
}

/*
//TODO:::this method will be removed or changed
- (void)onLoadingReferenceChanged_YTResourceView:(id)sender {
	[self updateMessageControls];
}

//TODO:::this method will be removed or changed
- (void)updateMessageControls {
	YTResourceBaseView *curSubView = [self subResourceView];
	if(curSubView && curSubView.loadingReference && curSubView.loadingReference.parentInfoRef) {
		YTResourceLoadingReference *loadingReference = curSubView.loadingReference;
		YTResourceLoadingInfo *parentInfoRef = loadingReference.parentInfoRef;
		BOOL processing = parentInfoRef.processing;
		NSError *error = parentInfoRef.error;
		if(error && !processing) {
			//NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Synchronization failure. This may be due to a network problem or service maintenance.", nil), @""];
			NSString *text = NSLocalizedString(@"Synchronization failure. This may be due to a network problem or service maintenance.", nil);
			NSTimeInterval uptime = [VLTimer systemUptime];
			if(!_waitingForReloadStarted && kYTResourceDownloadWaitingForReloadEnabled) {
				_waitingForReloadStarted = YES;
				_waitingForReloadStartTime = uptime;
			}
			if(_waitingForReloadStarted) {
				NSTimeInterval timeCounted = uptime - _waitingForReloadStartTime;
				int seconds = round(timeCounted);
				if(seconds < kYTResourceDownloadWaitingForReloadMaxTime) {
					//text = [NSString stringWithFormat:NSLocalizedString(@"FAILED\n(tap to reload)\nreload in %d sec", nil), (int)kYTResourceDownloadWaitingForReloadMaxTime - seconds];
					text = NSLocalizedString(@"Synchronization failure. This may be due to a network problem or service maintenance.", nil);
				} else {
					_waitingForReloadStarted = NO;
					if(_lbError.visible) {
						_lbError.visible = NO;
						[self removeGestureRecognizer:_tapRecognizer];
					}
					[_timer stop];
					[self startReload];
					return;
				}
				if(!_timer.started)
					[_timer start];
			}
			if(!_lbError.visible) {
				_lbError.visible = YES;
				[self setNeedsLayout];
				[self addGestureRecognizer:_tapRecognizer];
			}
			if(_waitingForReloadStarted && kYTResourceDownloadWaitingForReloadObscureWaiting) {
				_lbError.alpha = 0.01;
				text = @"";
			} else {
				_lbError.alpha = 1.0;
				[self bringSubviewToFront:_lbError];
			}
			_lbError.text = text;
		} else {
			if(_lbError.visible) {
				_lbError.visible = NO;
				[self removeGestureRecognizer:_tapRecognizer];
			}
		}
		if(_waitingForReloadStarted && kYTResourceDownloadWaitingForReloadObscureWaiting) {
			[self setIsProcessing:YES];
			[self bringSubviewToFront:self.activityView];
			[self bringSubviewToFront:_lbError];
		} else {
			[self setIsProcessing:NO];
		}
	} else {
		if(_lbError.visible) {
			_lbError.visible = NO;
			[self removeGestureRecognizer:_tapRecognizer];
		}
		_lbError.text = @"";
	}
}
 

- (void)setIsProcessing:(BOOL)processing {
	if(processing != self.activityView.visible) {
		if(processing) {
			self.activityView.visible = YES;
			[self.activityView startAnimating];
		} else {
			[self.activityView stopAnimating];
			self.activityView.visible = NO;
		}
	}
}

- (void)onTimerEvent:(id)sender {
	[self updateMessageControls];
}
*/
 
- (void)onResourceDataChanged {
	[super onResourceDataChanged];
	[self updateViewAsync];
}

//TODO:::this method will be changed or removed
- (void)startReload {
	_waitingForReloadStarted = NO;
	YTResourceBaseView *curSubView = [self subResourceView];
    /* TODO:::commented
	if(curSubView && curSubView.loadingReference && curSubView.loadingReference.parentInfoRef) {
		YTResourceLoadingReference *loadingReference = curSubView.loadingReference;
		YTResourceLoadingInfo *parentInfoRef = loadingReference.parentInfoRef;
		BOOL processing = parentInfoRef.processing;
		NSError *error = parentInfoRef.error;
		if(error && !processing) {
///			[[YTResourcesStorage shared] startLoadResource:parentInfoRef];
		}
	}
    */
}

- (void)onBtnReloadTap:(id)sender {
	[self startReload];
}

- (void)onTap:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized) {
		[self startReload];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	if(_imageView)
		_imageView.frame = rcBnds;
	if(_mediaView)
		_mediaView.frame = rcBnds;
	if(_webDocView)
		_webDocView.frame = rcBnds;
	if(_otherView)
		_otherView.frame = rcBnds;
	if(_lbError.visible) {
		CGRect rcLabel = rcBnds;
		rcLabel = CGRectInset(rcLabel, 1, 1);
		rcLabel.origin.x = CGRectGetMidX(rcBnds) - rcLabel.size.width/2;
		rcLabel.origin.y = CGRectGetMidY(rcBnds) - rcLabel.size.height/2;
		_lbError.frame = [UIScreen roundRect:rcLabel];
	}
}

- (BOOL)isImageShown {
	return _imageView && [_imageView isImageShown];
}

- (UIView *)getImageHolderView {
	if(_imageView)
		return _imageView.imageHolderView;
	else
		return nil;
}

- (void) removeFromSuperview {
//    NSLog(@"YTResourceView::removeFromSuperview");

    [_timer stop];
    [_timer setObserver: nil selector:nil];
    _timer = nil;
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.imageView = nil;
    self.mediaView = nil;
    self.webDocView = nil;
    self.otherView = nil;
    self.lbError = nil;
    self.btnReload = nil;
    self.tapRecognizer = nil;
    
    
    [super removeFromSuperview];
}

- (void) dealloc {
//    NSLog(@"YTResourceView::dealloc");
}


@end

