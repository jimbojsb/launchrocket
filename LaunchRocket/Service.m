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
@synthesize name;

- (id) initWithOptions:(NSDictionary *)options {
    self = [super init];
    self.plist = [options objectForKey:@"plist"];
    NSDictionary *plistData = [[NSDictionary alloc] initWithContentsOfFile:self.plist];
    self.identifier = [plistData objectForKey:@"Label"];
    self.name = [options objectForKey:@"name"];
    return self;    
}

@end
