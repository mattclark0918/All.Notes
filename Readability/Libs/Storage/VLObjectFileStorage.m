
#import "VLObjectFileStorage.h"

@implementation VLObjectFileStorage

- (id)initWithKey:(NSString*)key version:(int)version
{
	self = [super initWithKey:key version:version];
	if(self)
	{
		
	}
	return self;
}

- (NSString*)filePath
{
	NSString *dirHome = NSHomeDirectory();
	NSString *dirDocs = @"Documents";
	NSString *pathDirDocs = [dirHome stringByAppendingPathComponent:dirDocs];
	NSString *result = [[pathDirDocs stringByAppendingPathComponent:self.key] stringByAppendingPathExtension:@"dat"];
	return result;
}

- (void)saveData:(NSData*)data
{
	[data writeToFile:[self filePath] atomically:YES];
}

- (NSData*)loadData
{
	NSData *result = [NSData dataWithContentsOfFile:[self filePath]];
	return result;
}

- (void)removeData
{
	NSString *filePath = [self filePath];
	if(!filePath || !filePath.length)
		return;
	NSFileManager *manr = [NSFileManager defaultManager];
	NSError* err = nil;
	[manr removeItemAtPath:filePath error:&err];
}

+ (void)saveDataWithRootObject:(NSObject*)rootObject key:(NSString*)key version:(int)version
{
	VLObjectFileStorage *instance = [[VLObjectFileStorage alloc] initWithKey:key version:version];
	[instance saveDataWithRootObject:rootObject];
}

+ (id)loadRootObjectWithKey:(NSString*)key version:(int)version
{
	VLObjectFileStorage *instance = [[VLObjectFileStorage alloc] initWithKey:key version:version];
	NSObject *result = [instance loadRootObject];
	return result;
}


@end
