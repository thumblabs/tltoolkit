//
//  TLDateUtilities.m
//  Posto7
//
//  Created by Thumb Labs on 4/19/13.
//  Copyright (c) 2013 posto7. All rights reserved.
//

#import "TLDateUtilities.h"

#define TL_MINUTE 60
#define TL_HOUR   (60 * TL_MINUTE)
#define TL_DAY    (24 * TL_HOUR)
#define TL_WEEK   (7 * TL_DAY)
#define TL_MONTH  (30.5 * TL_DAY)
#define TL_YEAR   (365 * TL_DAY)

@implementation TLDateUtilities

+ (NSString*)relativeTimeStringForDate:(NSDate *)date
{
    NSTimeInterval elapsed = abs([date timeIntervalSinceNow]);
    
    if (elapsed < TL_MINUTE) {
        return NSLocalizedString(@"just now", @"just now");
    }
    else if (elapsed < TL_HOUR) {
        int mins = (int)(elapsed / TL_MINUTE);
        return [NSString stringWithFormat:NSLocalizedString(@"%dm ago", @"%dm ago"), mins];
        
    }
    else if (elapsed < TL_DAY) {
        int hours = (int)((elapsed + TL_HOUR / 2) / TL_HOUR);
        return [NSString stringWithFormat:NSLocalizedString(@"%dh ago", @"%dh ago"), hours];
        
    }
    else if (elapsed < TL_WEEK) {
        int day = (int)((elapsed + TL_DAY / 2) / TL_DAY);
        return [NSString stringWithFormat:NSLocalizedString(@"%dd ago", @"%dd ago"), day];
        
    }
    else if (elapsed < TL_MONTH) {
        int weeks = (int)((elapsed + TL_WEEK / 2) / TL_WEEK);
        return [NSString stringWithFormat:NSLocalizedString(@"%dw ago", @"%dw ago"), weeks];
        
    }
    else if (elapsed < TL_YEAR) {
        int months = (int)((elapsed + TL_MONTH / 2) / TL_MONTH);
        return [NSString stringWithFormat:NSLocalizedString(@"%dmo ago", @"%dmo ago"), months];
        
    }
    else {
        int years = (int)((elapsed + TL_YEAR / 2) / TL_YEAR);
        return [NSString stringWithFormat:NSLocalizedString(@"%dy ago", @"%dy ago"), years];
    }
}

+ (NSDate *)dateFromSqlString:(NSString *)dateString
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)timeTodayDayOfWeekOrFullDate:(NSDate *)date
{
    NSTimeInterval elapsed = abs([date timeIntervalSinceNow]);
    
    if (elapsed < TL_DAY) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"h:mm a"];
        return [formatter stringFromDate:date];
    }
    else if (elapsed < TL_WEEK) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"EEEE"];
        return [formatter stringFromDate:date];
    }
    else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMM/dd/yyyy"];
        return [formatter stringFromDate:date];
    }
}

@end
