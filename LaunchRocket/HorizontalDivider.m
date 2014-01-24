//
//  HorizontalDivider.m
//  LaunchRocket
//
//  Created by Josh Butts on 1/23/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import "HorizontalDivider.h"

@implementation HorizontalDivider

- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:
    [[NSColor grayColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}


@end
