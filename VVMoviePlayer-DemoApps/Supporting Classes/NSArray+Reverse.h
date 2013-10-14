//
//  NSArray+Reverse.h
//  mobileapidev
//
//  Created by Benjamin Askren on 6/1/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Reverse)

- (NSArray *)reversedArray ;

@end

@interface NSMutableArray (Reverse)

- (void)reverse;

@end
