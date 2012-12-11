//
//  TLImageUtilities.h
//  Bondsy
//
//  Created by Jared Verdi on 4/13/12.
//  Copyright (c) 2012 Thumb Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLImageUtilities : NSObject

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize;
+ (UIImage *)cropFromCenterImage:(UIImage *)image toSize:(CGRect)size;
+ (UIImage *)resizeAndCropFromCenterImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)cropImage:(UIImage *)image rect:(CGRect)rect;

+ (void)writeJPEG:(UIImage *)image toPath:(NSString *)path;
+ (void)writePNG:(UIImage *)image toPath:(NSString *)path;

+ (UIImage *)imageFromCompositeView:(UIView *)compositeView;

+ (UIImage *)image:(UIImage *)image maskedWithColor:(UIColor *)color;

+ (UIImage *)transparentBorderImage:(UIImage *)image borderSize:(NSUInteger)borderSize;

+ (UIImage *)convertToGreyscale:(UIImage *)i;

+ (UIImage *)fixOrientation:(UIImage *)image;
+ (UIImage *)fixOrientation:(UIImage *)image orientation:(UIImageOrientation)imageOrientation;

@end
