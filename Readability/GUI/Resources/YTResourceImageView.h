
#import <Foundation/Foundation.h>
#import "YTResourceBaseView.h"
#import "YTImagePreviewView.h"

@class YTResourceImageView;

@protocol YTResourceImageViewDelegate <NSObject>
@optional
- (void)resourceImageView:(YTResourceImageView *)resourceImageView imageChanged:(UIImage *)image;
- (BOOL)resourceImageView:(YTResourceImageView *)resourceImageView isVisible:(id)param;

@end


@interface YTResourceImageView : YTResourceBaseView <YTImagePreviewViewDeleate> {
@private
	BOOL _drawOnMainThread;
	BOOL _useMiniImage;
	NSString *_lastImageKey;
	NSString *_loadingAttachmentHash;
}

@property (nonatomic, strong) YTImagePreviewView *imageShowView;
@property(nonatomic, assign) BOOL drawOnMainThread;
@property(nonatomic, assign) BOOL useMiniImage;
@property(nonatomic, weak) NSObject<YTResourceImageViewDelegate> *delegate;
@property(strong, nonatomic, readonly) UIView *imageHolderView;

- (BOOL)isImageShown;
- (CGSize)sizeOfLoadedImage;

@end
