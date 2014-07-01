
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTCustomNavigationBar_TapBlockView;


@interface YTCustomNavigationBar : YTBaseView {
@private
	UIView *_contentViewCNB;
	UIImageView *_ivBotShadow;
	VLLabel *_titleLabel;
	UIImageView *_imageViewTitle;
	UIButton *_btnBack;
	UIButton *_btnLeft;
	UIButton *_btnRight;
	YTCustomNavigationBar_TapBlockView *_tapBlockView;
	float _bottomTapBlockAreaRatio;
}

@property(nonatomic, strong, readonly) UIView *contentView;
@property(nonatomic, strong, readonly) VLLabel *titleLabel;
@property(nonatomic, strong, readonly) UIButton *btnBack;
@property(nonatomic, strong, readonly) UIButton *btnLeft;
@property(nonatomic, strong, readonly) UIButton *btnRight;
@property(nonatomic, assign) float bottomTapBlockAreaRatio;

- (void)setTitleImage:(UIImage *)image;

@end

