
#import <Foundation/Foundation.h>

@interface YTImageSizeCacheInfo : NSObject {
@private
	CGSize _size;
	UIImageOrientation _orient;
}

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) UIImageOrientation orient;

@end


@interface YTImageUtilities : NSObject
{
	
}

+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath imageOrientation:(UIImageOrientation*)imageOrientation fileExt:(NSString *)fileExt;
+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath imageOrientation:(UIImageOrientation*)imageOrientation;
+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath;

@end
