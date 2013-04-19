//
//  TLImageUtilities.m
//  Bondsy
//
//  Created by Jared Verdi on 4/13/12.
//  Copyright (c) 2012 Thumb Labs. All rights reserved.
//

#import "TLImageUtilities.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>

@implementation TLImageUtilities

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)cropFromCenterImage:(UIImage *)image toSize:(CGRect)size
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, size);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

+ (UIImage *)resizeAndCropFromCenterImage:(UIImage *)image toSize:(CGSize)size
{
    UIImage *resizedImage = [self resizeImage:image 
                              withContentMode:UIViewContentModeScaleAspectFill
                                         size:size];
    
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - size.width) / 2),
                                 round((resizedImage.size.height - size.height) / 2),
                                 size.width,
                                 size.height);
    
    return [self cropFromCenterImage:resizedImage toSize:cropRect];
}

+ (UIImage *)cropImage:(UIImage *)image rect:(CGRect)rect {
    
    image = [TLImageUtilities fixOrientation:image];
    
    if (image.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * image.scale,
                          rect.origin.y * image.scale,
                          rect.size.width * image.scale,
                          rect.size.height * image.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

+ (void)writeJPEG:(UIImage *)image toPath:(NSString *)path
{
    NSURL *outURL = [[NSURL alloc] initFileURLWithPath:path];
    
    CGImageDestinationRef dr = CGImageDestinationCreateWithURL((__bridge CFURLRef)outURL,
                                                               (CFStringRef)@"public.jpeg", 
                                                               1, 
                                                               NULL);
    
    CGImageDestinationAddImage(dr, image.CGImage, NULL);
    
    CGImageDestinationFinalize(dr);
    CFRelease(dr);
}

+ (void)writePNG:(UIImage *)image toPath:(NSString *)path
{
    NSURL *outURL = [[NSURL alloc] initFileURLWithPath:path];
    
    CGImageDestinationRef dr = CGImageDestinationCreateWithURL((__bridge CFURLRef)outURL,
                                                               (CFStringRef)@"public.png", 
                                                               1, 
                                                               NULL);
    
    CGImageDestinationAddImage(dr, image.CGImage, NULL);
    
    CGImageDestinationFinalize(dr);
    CFRelease(dr);
}


// Private Helper Methods

+ (UIImage *)resizeImage:(UIImage *)image 
         withContentMode:(UIViewContentMode)contentMode
                    size:(CGSize)size
{
    CGFloat horizontalRatio = size.width / image.size.width;
    CGFloat verticalRatio = size.height / image.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
    }
    
    CGSize newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
    
    return [self resizeImage:image toSize:newSize];
}

+ (UIImage *)imageFromCompositeView:(UIView *)compositeView
{
    UIGraphicsBeginImageContext(compositeView.bounds.size);
    
	[compositeView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return compositeImage;
}

+ (UIImage *)image:(UIImage *)image maskedWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContext(image.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

+ (BOOL)imageHasAlpha:(UIImage *)image {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

+ (UIImage *)imageWithAlpha:(UIImage *)image {
    if ([self imageHasAlpha:image]) {
        return image;
    }

    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);

    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];

    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);

    return imageWithAlpha;
}

+ (UIImage *)transparentBorderImage:(UIImage *)startingImage borderSize:(NSUInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha:startingImage];
    
    CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(image.CGImage),
                                                0,
                                                CGImageGetColorSpace(image.CGImage),
                                                CGImageGetBitmapInfo(image.CGImage));
    
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
    CGContextDrawImage(bitmap, imageLocation, image.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self newBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}

+ (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}

// http://mobiledevelopertips.com/graphics/convert-an-image-uiimage-to-grayscale.html
+ (UIImage *)convertToGreyscale:(UIImage *)i
{    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, i.size.width, i.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, i.size.width, i.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [i CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object  
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

+ (UIImage *)fixOrientation:(UIImage *)image 
{
    return [self fixOrientation:image orientation:-1];
}

+ (UIImage *)fixOrientation:(UIImage *)image orientation:(UIImageOrientation)imageOrientation
{
    if (-1 == imageOrientation) {
        imageOrientation = image.imageOrientation;
    }
    
    // No-op if the orientation is already correct
    if (imageOrientation == UIImageOrientationUp) return image;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
