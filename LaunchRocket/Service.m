//
//  Service.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/26/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "Service.h"

@implementation Service

@synthesize plist;
@synthesize identifier;

- (id) initWithPlist:(NSString *)plistFile {
    self = [super init];
    self.plist = plistFile;
    NSArray *fileParts = [plistFile componentsSeparatedByString:@"/"];
    self.identifier = [fileParts lastObject];
    return self;
}

@end
