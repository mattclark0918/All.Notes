
#import <Foundation/Foundation.h>

@interface VLTableViewCell : UITableViewCell
{
@private
	UIView __weak *_subView;
	BOOL _canSubViewIndentRight;
}

@property(nonatomic, weak, readonly) UIView *subView;
@property(nonatomic, assign) BOOL canSubViewIndentRight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithSubView:(UIView*)subView reuseIdentifier:(NSString *)reuseIdentifier;

@end
