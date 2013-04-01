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

- (id) initWithOptions:(NSDictionary *)options {
    self = [super init];
    self.plist = [options objectForKey:@"plist"];
    self.image = [options objectForKey:@"image"];
    self.identifier = [self.plist stringByReplacingOccurrencesOfString:@".plist" withString:@""];

    return self;    
}

@end
