
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "VLBaseView.h"

@interface VLBadgeView : VLBaseView
{
	NSString *_badgeText;
	UIColor *badgeTextColor;
	UIColor *badgeInsetColor;
	UIColor *badgeFrameColor;
	BOOL badgeFrame;
	BOOL badgeShining;
	CGFloat badgeCornerRoundness;
	CGFloat badgeScaleFactor;
}

@property(nonatomic, strong, setter = setBadgeText:) NSString *badgeText;
@property(nonatomic, strong) UIColor *badgeTextColor;
@property(nonatomic, strong) UIColor *badgeInsetColor;
@property(nonatomic, strong) UIColor *badgeFrameColor;

@property(nonatomic, readwrite) BOOL badgeFrame;
@property(nonatomic, readwrite) BOOL badgeShining;

@property(nonatomic, readwrite) CGFloat badgeCornerRoundness;
@property(nonatomic, readwrite) CGFloat badgeScaleFactor;

+ (VLBadgeView*)customBadgeWithString:(NSString *)badgeString;
+ (VLBadgeView*)customBadgeWithString:(NSString *)badgeString withStringColor:(UIColor*)stringColor withInsetColor:(UIColor*)insetColor withBadgeFrame:(BOOL)badgeFrameYesNo withBadgeFrameColor:(UIColor*)frameColor withScale:(CGFloat)scale withShining:(BOOL)shining;
- (void)autoBadgeSizeWithString:(NSString *)badgeString;

@end
