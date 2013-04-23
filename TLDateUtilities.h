//
//  TLDateUtilities.h
//  Posto7
//
//  Created by Thumb Labs on 4/19/13.
//  Copyright (c) 2013 posto7. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLDateUtilities : NSObject

+ (NSString *)relativeTimeStringForDate:(NSDate *)date;
+ (NSDate *)dateFromSqlString:(NSString *)dateString;

@end
