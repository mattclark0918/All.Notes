
#import <Foundation/Foundation.h>
#import "../Logic/Classes.h"

@interface VLImageCache_ImageInfo : NSObject {
@private
	UIImage *_image;
	NSString *_sHash;
	NSDate *_lastAccessTime;
}

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) NSString *sHash;
@property(nonatomic, strong) NSDate *lastAccessTime;

@end


@interface VLImageCache : VLLogicObject {
@private
	NSMutableDictionary *_mapInfoByHash;
	int64_t _maxAllPixelsAmount;
}

@property(nonatomic, assign) int64_t maxAllPixelsAmount;

+ (VLImageCache *)shared;

- (UIImage *)imageByHash:(NSString *)sHash;
- (void)setImage:(UIImage *)image withHash:(NSString *)sHash;
- (void)clear;

@end

