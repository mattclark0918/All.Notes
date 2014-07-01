
#import "YTColoredView.h"

#define kDefaultColor [UIColor blackColor]

@implementation YTColoredView

@synthesize color = _color;

- (void)initialize
{
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	_color = kDefaultColor;
}

- (void)setColor:(UIColor *)color
{
	if(!color)
		color = kDefaultColor;
	_color = color;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGRect rcBnds = self.bounds;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[_color setFill];
	CGContextFillRect(ctx, rcBnds);
}


@end
