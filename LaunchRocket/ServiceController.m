//
//  ServiceController.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServiceController.h"

@implementation ServiceController

@synthesize service;
@synthesize statusIndicator;
@synthesize sudo;
@synthesize onOff;
@synthesize status;

-(id) initWithService:(Service *)theService {
    self = [super init];
    
    self.service = theService;
    if ([self isStarted]) {
        self.status = 2;
    }
    return self;
}

-(BOOL) isStarted {
    NSTask *command = [[NSTask alloc] init];
    NSString *bashCommand = [NSString stringWithFormat:@"%@%@", @"/bin/launchctl list | grep ", self.service.identifier];
    NSArray *args = [NSArray arrayWithObjects:@"-c", bashCommand, nil];
    NSPipe *stdOut = [NSPipe pipe];
    
    [command setLaunchPath:@"/bin/bash"];
    [command setArguments:args];
    [command setStandardOutput:stdOut];
    [command launch];
    [command waitUntilExit];
    
    NSFileHandle *read = [stdOut fileHandleForReading];
    NSData *readData = [read readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    
    if ([output length] > 0) {
        self.status = 2;
        return YES;
    }
    self.status = 0;
    return NO;
    
}

-(void) stop {
    self.status = 1;
    [self updateStatusIndicator];
    NSTask *command = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"unload", self.service.plist, nil];
    
    [command setLaunchPath:@"/bin/launchctl"];
    [command setArguments:args];
    [command launch];
    [command waitUntilExit];
    [self isStarted];
    [self updateStatusIndicator];

}

-(void) start {
    self.status = 1;
    [self updateStatusIndicator];
    NSTask *command = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"load", self.service.plist, nil];
    
    [command setLaunchPath:@"/bin/launchctl"];
    [command setArguments:args];
    [command launch];
    [command waitUntilExit];
    [self isStarted];
    [self updateStatusIndicator];
}

-(void) updateStatusIndicator {
    NSString *statusImageName;
    switch (self.status) {
        case 0:
            statusImageName = @"red";
            break;
        case 1:
            statusImageName = @"yellow";
            break;
        case 2:
            statusImageName = @"green";
            break;
    }
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:statusImageName ofType:@"png"]];
    [self.statusIndicator setImage:image];
    [self.statusIndicator setNeedsDisplay:YES];
}

-(void) updateOnOffStatus {
    if (self.status == 0) {
        [self.onOff setSelected:YES forSegment:0];
    } else {
        [self.onOff setSelected:YES forSegment:1];
    }
    [self.onOff setNeedsDisplay:YES];
}

-(void) handleOnOffClick:(id)sender {
    NSSegmentedControl *s = (NSSegmentedControl *)sender;
    if ([s isSelectedForSegment:0]) {
        [self stop];
    } else {
        [self start];
    }
}

@end
