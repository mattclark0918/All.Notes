
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Resources/Classes.h"

@interface YTNoteResourceRowView : YTBaseView {
@private
}

@property(nonatomic, strong) YTResourceView *resourceView;
@property(nonatomic, strong) VLLabel *lbTitle;


- (CGSize)sizeThatFits:(CGSize)size;
- (BOOL)isImageLoaded;
- (CGSize)sizeOfLoadedImage;
- (BOOL)isImageShown;

@end

