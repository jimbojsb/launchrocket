//
//  OpenSansFont.m
//  LaunchRocket
//
//  Created by Josh Butts on 1/23/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import "OpenSansFont.h"

@implementation OpenSansFont

+(NSFont *) getFontWithSize:(int)size {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *openSansFontPath = [NSString stringWithFormat:@"%@%@", [bundle resourcePath], @"/OpenSans-Light.ttf", Nil];
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef) openSansFontPath, kCFURLPOSIXPathStyle, false);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithURL(url);
    CGFontRef theCGFont = CGFontCreateWithDataProvider(dataProvider);
    CTFontRef theCTFont = CTFontCreateWithGraphicsFont(theCGFont, size, nil, nil);
    NSFont *openSans = (NSFont *) theCTFont;
    CFRelease(theCGFont);
    CFRelease(dataProvider);
    CFRelease(url);
    return openSans;
}

@end
