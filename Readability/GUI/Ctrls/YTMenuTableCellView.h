
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTMenuTableCellView;

@protocol YTMenuTableCellViewDelegate <NSObject>
@optional
- (void)menuTableCellView:(YTMenuTableCellView *)view iconTapped:(id)param;
@end

@interface YTMenuTableCellView : YTBaseView {
@private
	UIEdgeInsets _contentInsets;
	UIImageView *_imageIcon;
	VLLabel *_labelTitle;
	VLLabel *_labelTitleRight;
	UIView *_separatorBottom;
	BOOL _enableIconTouches;
	BOOL _iconTouchBegan;
	NSObject<YTMenuTableCellViewDelegate> *__weak _delegate;
}

@property(nonatomic, assign) UIEdgeInsets contentInsets;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIImage *icon;
@property(nonatomic, readonly) VLLabel *labelTitle;
@property(nonatomic, strong) NSString *titleRight;
@property(nonatomic, readonly) VLLabel *labelTitleRight;
@property(nonatomic, assign) BOOL enableIconTouches;
@property(nonatomic, assign) BOOL separatorBottomHidden;
@property(nonatomic, weak) NSObject<YTMenuTableCellViewDelegate> *delegate;

@end

