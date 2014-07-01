
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTImagePickerController;

@interface YTWallpapersManager : YTLogicObject <NSCoding> {
@private
	int64_t _savedDataVersion;
	int _customWallpaperVersion;
	NSString *_wallpaperFilePath;
}

@property(nonatomic, readonly) int customWallpaperVersion;

@property (nonatomic, strong) YTImagePickerController* picker;

+ (YTWallpapersManager *)shared;

- (BOOL)customWallpaperExists;
- (void)removeCustomWallpaper;
- (UIImage *)getCustomWallpaper;
- (UIImage *)getDefaultWallpaper;
- (void)startChooseWalpaper;

@end

