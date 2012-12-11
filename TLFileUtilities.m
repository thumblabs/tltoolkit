//
//  TLFileUtilities.m
//  Behance
//
//  Created by Thumb Labs on 10/4/12.
//  Copyright (c) 2012 Thumb Labs. All rights reserved.
//

#import "TLFileUtilities.h"

@implementation TLFileUtilities

+ (NSString *)documentsDirectory
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [paths objectAtIndex:0];
}

@end
