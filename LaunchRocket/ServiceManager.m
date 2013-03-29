//
//  ServiceManager.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServiceManager.h"
#import "ToggleButton.h"
#import "SegmentButton.h"
#import "Service.h"
#import "ServiceController.h"

@implementation ServiceManager

@synthesize serviceControllers;
@synthesize services;

-(id) init {
    self = [super init];
    self.serviceControllers = [[NSMutableDictionary alloc] init];
    return self;
}

-(void) handleOnOffClick:(id)sender {
    SegmentButton *s = (SegmentButton *)sender;
    ServiceController *sc = [self.serviceControllers objectForKey:s.serviceName];
    if ([s isSelectedForSegment:0]) {
        [sc stop];
    } else {
        [sc start];
    }
}

-(void) handleStartAtLoginClick:(id)sender {
    ToggleButton *t = (ToggleButton *)sender;
    ServiceController *sc = [self.serviceControllers objectForKey:t.serviceName];
    if (t.state == NSOnState) {
        [sc startAtLogin: YES];
    } else {
        [sc startAtLogin: NO];
    }

}


@end
