
#import <Foundation/Foundation.h>
#import "YTResourceImageView.h"
#import "YTResourceMediaView.h"
#import "YTResourceOtherView.h"
#import "YTResourceBaseView.h"
#import "YTResourceWebDocView.h"

@interface YTResourceView : YTResourceBaseView {
@private
	BOOL _waitingForReloadStarted;
	NSTimeInterval _waitingForReloadStartTime;
}

@property (nonatomic, strong) YTResourceImageView *imageView;
@property (nonatomic, strong) YTResourceMediaView *mediaView;
@property (nonatomic, strong) YTResourceWebDocView *webDocView;
@property (nonatomic, strong) YTResourceOtherView *otherView;
@property (nonatomic, strong) VLLabel *lbError;
@property (nonatomic, strong) UIButton *btnReload;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) VLTimer *timer;

- (BOOL)isImageShown;
- (UIView *)getImageHolderView;

@end

