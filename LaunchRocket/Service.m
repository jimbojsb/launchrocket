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
@synthesize name;
@synthesize image;

- (id) initWithOptions:(NSDictionary *)options {
    self = [super init];
    self.plist = [options objectForKey:@"plist"];
    self.name = [options objectForKey:@"name"];
    self.image = [options objectForKey:@"image"];

    return self;    
}

@end
