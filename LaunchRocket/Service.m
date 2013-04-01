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
@synthesize image;
@synthesize identifier;
@synthesize plistFilename;

- (id) initWithOptions:(NSDictionary *)options {
    self = [super init];
    self.plist = [options objectForKey:@"plist"];
    self.image = [options objectForKey:@"image"];
    NSDictionary *plistData = [[NSDictionary alloc] initWithContentsOfFile:self.plist];
    self.identifier = [plistData objectForKey:@"Label"];
    self.plistFilename = [NSString stringWithFormat:@"%@%@", self.identifier, @".plist"];
    return self;    
}

@end
