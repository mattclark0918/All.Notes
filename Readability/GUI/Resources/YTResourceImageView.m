
#import "YTResourceImageView.h"

#define kUseTiledView NO//YES
#define kUseTiledImagePreviewView YES//NO

@implementation YTResourceImageView

@synthesize drawOnMainThread = _drawOnMainThread;
@synthesize useMiniImage = _useMiniImage;
@synthesize delegate = _delegate;
@synthesize imageHolderView = _imageScrollView;

- (void)initialize {
	[super initialize];
    
	self.backgroundColor = [UIColor blackColor];
	_lastImageKey = @"";
	_loadingAttachmentHash = @"";
	self.clipsToBounds = YES;

	[self updateViewAsync];
}

- (void) setImage:(UIImage *)image
        imageSize:(CGSize)imageSize
        miniImage:(UIImage *)miniImage {
	   
	UIViewContentMode contentMode = UIViewContentModeScaleAspectFit;
	if(self.makeThumbnails || self.aspectFill)
		contentMode = UIViewContentModeScaleAspectFill;
	if(image == nil) {
		/*if(_imageScrollView) {
			[_imageScrollView removeFromSuperview];
			[_imageScrollView release];
			_imageScrollView = nil;
		}*/
		if(_imageShowView) {
			[_imageShowView removeFromSuperview];
			_imageShowView = nil;
		}
	} else {
		if(kUseTiledImagePreviewView) {
			if(!_imageShowView) {
				_imageShowView = [[YTImagePreviewView alloc] initImage:image
																	   imageSize:imageSize
																imageContentMode:contentMode
																	   drawAsync:!_drawOnMainThread
																   miniImage:miniImage];
				_imageShowView.delegate = self;
				[self addSubview:_imageShowView];
				[self layoutSubviews];
			}
		}/* else if(kUseTiledView) {
			if(!_imageScrollView) {
				_imageScrollView = [[YTTilingImageScrollView alloc] initImageFilePath:imageFilePath
																		imageSize:imageSize
																 imageContentMode:contentMode
																	miniImagePath:miniImagePath
																 drawOnMainThread:_drawOnMainThread];
				_imageScrollView.userInteractionEnabled = NO;
				[self addSubview:_imageScrollView];
				[self layoutSubviews];
			}
		} else {
			_imageShowView = [[YTImageShowView alloc] initImageFilePath:imageFilePath
															  imageSize:imageSize
													   imageContentMode:contentMode
														   useMiniImage:_useMiniImage
														  miniImagePath:miniImagePath];
			[self addSubview:_imageShowView];
			[self layoutSubviews];
		}*/
	}
}

- (void)setResource:(YTAttachment *)resource {
//    NSLog(@"YTResourceImageView::setResource");
    
	if(resource != self.resource) {
//        NSLog(@"its a different resource");
		[self setImage:nil imageSize:CGSizeZero miniImage:nil];
		[self setIsProcessing:NO];
		[super setResource:resource];
	}
}

- (BOOL)imagePreviewView:(YTImagePreviewView *)imagePreviewView isVisible:(id)param {
	if(!self.superview)
		return NO;
	BOOL result = NO;
	if(_delegate && [_delegate respondsToSelector:@selector(resourceImageView:isVisible:)])
		result = [_delegate resourceImageView:self isVisible:nil];
	return result;
}

- (BOOL)isImageShown {
	//return (_imageScrollView && [_imageScrollView isImageShown]) || (_imageShowView && [_imageShowView isImageShown]);
	return (_imageShowView && [_imageShowView isImageShown]);
}

- (CGSize)sizeOfLoadedImage {
	//if(_imageScrollView)
	//	return _imageScrollView.imageSize;
	if(_imageShowView)
		return _imageShowView.imageSize;
	return CGSizeZero;
}

//TODO:::comment will handle attachments later
- (NSString *)imageKey {
    YTAttachment *resource = self.resource;
    
	if (!resource) {
        return nil;
    }
    
    return resource.uniqueIdentifier;
    
    /*
	if(!resource)
		return @"";
	NSString *imageKey = [NSString stringWithFormat:@"%@_%d_%d", resource.attachmenthash,
						  (int)self.makeThumbnails, (int)self.makePreview];
	return imageKey;
    */
}

- (void)setIsProcessing:(BOOL)processing {
	if(!self.showActivityIndicator || !self.activityView)
		return;
	if(processing != self.activityView.visible) {
		if(processing) {
			self.activityView.visible = YES;
			[self.activityView startAnimating];
			[self bringSubviewToFront:self.activityView];
		} else {
			[self.activityView stopAnimating];
			self.activityView.visible = NO;
		}
	}
}

- (void)onUpdateView {
//    NSLog(@"YTResourceImageView::onUpdateView");
    
	[super onUpdateView];
	YTAttachment *resource = self.resource;
	if(resource) {
		NSString *imageKey = [self imageKey];
		if(![_lastImageKey isEqual:imageKey]) {
            _lastImageKey = @"";
			[self setImage:nil imageSize:CGSizeZero miniImage:nil];
		}
		
		if(_imageShowView && [_imageShowView isImageShown]) {
			[self setIsProcessing:NO];
			return;
		}
		
//		[self.loadingReference setResourceHash:resource.attachmenthash andType:resource.attachmentTypeName categoryId:(int)resource.attachmentCategoryId];
//		YTResourceLoadingInfo *loadingInfo = self.loadingReference.parentInfoRef;
//		BOOL processing = loadingInfo.processing;
//		if(loadingInfo.processing && !resource.isThumbnail) {
//			[_loadingAttachmentHash release];
//			_loadingAttachmentHash = [resource.attachmenthash copy];
//		}
        
		BOOL skip = NO;
		if((_imageShowView && [_imageShowView isImageShown])
		   && [_lastImageKey isEqual:imageKey])
			skip = YES;
		if(!skip) {
//			[_lastImageKey release];
//			_lastImageKey = [imageKey copy];
            
            _lastImageKey = @"";
            
			[self setImage:nil imageSize:CGSizeZero miniImage:nil];
			//if(processing) {
				
			//} else {
                
            //here we really load the image
            //PROFILE
            //NSLog(@"here we're really loading the image");

            
            /*
            YTAttachmentPreview* preview = resource.preview;
            NSLog(@"before loading image");
            UIImage* image = [UIImage imageWithData: preview.data];
            NSLog(@"after loading image");
            //sets image
            [self setImage:image imageSize:image.size miniImage:nil];
            NSLog(@"after setImage");
            //make preview a fault
            [[DatabaseManager sharedManager].managedObjectContext refreshObject:preview mergeChanges:NO];
            NSLog(@"after refresh object");
            */
            
            YTAttachmentPreview* preview = resource.preview;
            NSManagedObjectID* previewID = preview.objectID;
            preview = nil;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                @autoreleasepool {
                    
                    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContextForBackgroundThread;
                    
                    YTAttachmentPreview* previewOnBackgroundThread = (YTAttachmentPreview*) [context objectWithID: previewID];
                    NSData* data = previewOnBackgroundThread.data;
                    UIImage* image = [UIImage imageWithData: data];
                    
                    data = nil;
                    
                    //sets image (must be on the main thread)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImage:image imageSize:image.size miniImage:nil];
                    });
                    
                    //make preview a fault
                    [[DatabaseManager sharedManager].managedObjectContextForBackgroundThread refreshObject:preview mergeChanges:NO];
                    
                }
            });
		}

		//if(_imageShowView && [_imageShowView isImageShown])
		//	processing = NO;
		//[self setIsProcessing:processing];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
        
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	/*if(_imageScrollView && _imageScrollView.superview == self) {
		if(!CGRectEqualToRect(_imageScrollView.frame, rcBnds))
			_imageScrollView.frame = rcBnds;
	}*/
	if(_imageShowView && _imageShowView.superview == self) {
		if(!CGRectEqualToRect(_imageShowView.frame, rcBnds))
			_imageShowView.frame = rcBnds;
	}
}

- (void)removeFromSuperview {
//    NSLog(@"YTResourceImageView::removeFromSuperview");
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.imageShowView.delegate = nil;
    self.imageShowView = nil;
    
    [super removeFromSuperview];
}

- (void)dealloc {
//    NSLog(@"YTResourceImageView::dealloc");
}

@end

