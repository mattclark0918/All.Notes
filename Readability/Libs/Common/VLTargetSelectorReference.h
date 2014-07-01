
#import <Foundation/Foundation.h>

@interface VLTargetSelectorReference : NSObject
{
	id __weak _target;
	SEL _selector;
}

@property(nonatomic, weak) id target;
@property(nonatomic, assign) SEL selector;

- (id)initWithTarget:(id)target selector:(SEL)selector;

@end
