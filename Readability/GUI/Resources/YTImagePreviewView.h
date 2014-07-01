
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTImagePreviewView_TiledView;
@class YTImagePreviewView;

@protocol YTImagePreviewView_TiledViewDeleate <NSObject>
@optional
- (void)tiledView:(YTImagePreviewView_TiledView *)tiledView imageDrawn:(UIImage *)image;
@end


@protocol YTImagePreviewViewDeleate <NSObject>
@optional
- (BOOL)imagePreviewView:(YTImagePreviewView *)imagePreviewView isVisible:(id)param;
@end


@interface YTImagePreviewView : YTBaseView <YTImagePreviewView_TiledViewDeleate> {
@private
	CGSize _imageSize;
	UIViewContentMode _imageContentMode;
	BOOL _useMiniImage;
	BOOL _drawAsync;
	BOOL _imageDrawn;
}

@property (nonatomic, strong) YTImagePreviewView_TiledView *tiledView;
@property (nonatomic, weak) NSObject<YTImagePreviewViewDeleate> *delegate;
@property (nonatomic, strong) UIImageView *imageViewMini;
@property (nonatomic, strong) UIImageView *imageView;

- (id)        initImage:(UIImage *)image
			  imageSize:(CGSize)imageSize
	   imageContentMode:(UIViewContentMode)imageContentMode
			  drawAsync:(BOOL)drawAsync
              miniImage:(UIImage *)miniImage;
- (CGSize)imageSize;
- (BOOL)isImageShown;

@end




@interface YTImagePreviewView_TiledView : YTBaseView {
@private
	CGSize _imageSize;
}

@property(nonatomic, weak) NSObject<YTImagePreviewView_TiledViewDeleate> *delegate;
@property(atomic, strong) UIImage* image;

- (id)initImage:(UIImage *)image
			  imageSize:(CGSize)imageSize;

@end

