
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

@interface VLTableSectionHeader : VLBaseView {
@private
	VLLabel *_label;
	UIEdgeInsets _insets;
}

@property(nonatomic, readonly) VLLabel *label;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) UIEdgeInsets insets;

- (CGSize)sizeThatFits:(CGSize)size;

@end

