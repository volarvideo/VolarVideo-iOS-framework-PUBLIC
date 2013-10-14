//
//  B3Utils.h

//
//  Created by Benjamin Askren on 9/14/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface B3Utils : NSObject

+(NSString *) pathToPrivateDocs;
+(NSString *) pathToBundle;
+(id) loadEncodableObjectNamed:(NSString *) fileName;
+(id) loadPackagedObjectNamed:(NSString *)fileName;
+(void) saveEncodableObject:(id)obj named:(NSString *) fileName;
+(BOOL) toBoolean:(id) obj;

+ (UIImage *) snazzUpImage:(UIImage *)img ;
+ (UIColor *) stringToColor:(NSString *)str ;
+ (NSString *)appDocsDirectory;
+ (NSString *)appHiddenDirectory;
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format;

+ (BOOL)checkIsDeviceVersionHigherThanRequiredVersion:(NSString *)requiredVersion;
+ (NSDateFormatter *) getDateFormatterWithTimeZone ;
@end
