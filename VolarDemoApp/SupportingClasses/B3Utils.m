//
//  B3Utils.m

//
//  Created by Benjamin Askren on 9/14/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import "B3Utils.h"

@implementation B3Utils

+(NSString *) pathToPrivateDocs {
    /*
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;*/
    return [B3Utils appDocsDirectory];
}

+(NSString *) pathToBundle {
    return [[NSBundle mainBundle] bundlePath];
}

+(id) loadEncodableObjectNamed:(NSString *) fileName {
    id obj;
    NSString *path = [[B3Utils pathToPrivateDocs] stringByAppendingPathComponent:fileName];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:path];
    if (codedData) {
        // we have already save an encoded version of this file, so let's load it
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
        obj = [unarchiver decodeObjectForKey:@"Data"];
        [unarchiver finishDecoding];
    }
    if (!obj)
        // hasn't been generated yet, so have to get it out of the bundle
        //path = [[NSBundle mainBundle] bundlePath];
        obj = [B3Utils loadPackagedObjectNamed:fileName];
    
    return obj;
}

+(id) loadPackagedObjectNamed:(NSString *)fileName {
    id obj;
    NSString *path = [[B3Utils pathToBundle] stringByAppendingPathComponent:fileName];
    obj = [NSMutableArray arrayWithContentsOfFile:path];
    if (!obj) {
        NSLog(@"WARNING! loadEncodableObjectNamed: Cannot find the file [%@] in package.",fileName);
    }
    return obj;
}

+(void) saveEncodableObject:(id)obj named:(NSString *) fileName {
    // temporarily commented out for the purpose of driving a clean boot at each launch
    /*
     if (!obj)
     return;
     NSString *path = [[BcUtils pathToPrivateDocs] stringByAppendingPathComponent:[NSString stringWithFormat:fileName]];
     NSMutableData *data = [[NSMutableData alloc]init];
     NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
     [archiver encodeObject:obj forKey:@"Data"];
     [archiver finishEncoding];
     [data writeToFile:path atomically:YES];
     */
}

+(BOOL) toBoolean:(id) obj {
	if (!obj)
		return NO;
    if ([obj isKindOfClass:[NSString class]]) {
		NSString *objString = (NSString *) obj;
		objString = [objString lowercaseString];
		if ([objString isEqualToString:@"true"])
			return YES;
		if ([objString isEqualToString:@"yes"])
			return YES;
		if ([objString isEqualToString:@"1"])
			return YES;
		if ([objString isEqualToString:@"on"])
			return YES;
	} else if ([obj isKindOfClass:[NSNumber class]]) {
		return [obj boolValue];
	} else {
		NSLog(@"toBoolean obj=%@ class=%@",obj,[obj class]);
	}
    
	return NO;
}


#pragma mark Core Data Objects


#pragma mark NSDate

+ (NSDate*)dateFromString:(NSString *)string {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"MM-dd-yy"];
    [inputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *date = [inputFormatter dateFromString:string];
    if (!date) {
        [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [inputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        date = [inputFormatter dateFromString:string];
    }
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	[outputFormatter setTimeZone:[NSTimeZone localTimeZone]];			//display time in local time zone
	NSString *timestamp_str = [outputFormatter stringFromDate:date];
	return timestamp_str;
}

#pragma mark UIImage custom
+ (UIImage *) snazzUpImage:(UIImage *)img  {
    NSString *maskName = (img.size.width==256?@"256x108-roundedCornerMask":@"300x200-roundedCornerMask");
    //    return [UIImage imageNamed:maskName];
    CGImageRef maskRef = [[UIImage imageNamed:maskName] CGImage];
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    //    return [UIImage imageWithCGImage:mask];
    CGImageRef masked = CGImageCreateWithMask([img CGImage], mask);
    UIImage *rcImage = [UIImage imageWithCGImage:masked];
    //    return rcImage;
    UIGraphicsBeginImageContextWithOptions(rcImage.size, FALSE, 0.0);
    [rcImage drawInRect:CGRectMake( 0, 0, rcImage.size.width, rcImage.size.height)];
    NSString *glossName = (img.size.width==256?@"256x108-glossyOverlay":@"300x200-glossyOverlay");
    [[UIImage imageNamed:glossName] drawInRect:CGRectMake( 0, 0, img.size.width, img.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CFRelease(masked);
    CFRelease(mask);
    return newImage;
}

+ (UIColor *) stringToColor:(NSString *)str {
    const char *rstr = [[str substringToIndex:2] UTF8String];
    const char *gstr = [[[str substringFromIndex:2] substringToIndex:2] UTF8String];
    const char *bstr = [[str substringFromIndex:4] UTF8String];
    char *eptr=NULL;
    int red   = strtol(rstr,&eptr,16);
    int green = strtol(gstr,&eptr,16);
    int blue  = strtol(bstr,&eptr,16);
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return color;
}
#pragma mark File operations

+ (NSString *)appDocsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)appHiddenDirectory {
    // NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@".data"];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"Private Documents"];
    //NSLog(@"appHiddenDirectory path:%@",path);
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory)
            return path;
        else {
            // Handle error. ".data" is a file which should not be there...
            [NSException raise:@".data exists, and is a file" format:@"Path: %@", path];
            // NSError *error = nil;
            // if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            //     [NSException raise:@"could not remove file" format:@"Path: %@", path];
            // }
        }
    }
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        // Handle error.
        [NSException raise:@"Failed creating directory" format:@"[%@], %@", path, error];
    }
    return path;
}
/*
 // Returns the URL to the application's Documents directory.
 - (NSURL *)applicationDocumentsDirectory
 {
 return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
 }
 */

//**********************************************************************************

//   Below is a block for checking is current ios version higher than required version.

//**********************************************************************************

+ (BOOL)checkIsDeviceVersionHigherThanRequiredVersion:(NSString *)requiredVersion
{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:requiredVersion options:NSNumericSearch] != NSOrderedAscending)
    {
        return YES;
    }
    
    return NO;
}

+ (NSDateFormatter *) getDateFormatterWithTimeZone {
    //Returns the following information in the format of the locale:
    //YYYY-MM-dd HH:mm:ss z (Z is time zone)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    return dateFormatter;
}

@end
