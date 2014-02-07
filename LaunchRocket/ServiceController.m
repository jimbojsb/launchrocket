//
//  ServiceController.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServiceController.h"
#import "Process.h"
#import "Service.h"

@implementation ServiceController

@synthesize service;
@synthesize statusIndicator;
@synthesize useSudo;
@synthesize startStop;
@synthesize status;
@synthesize runAtLogin;
@synthesize serviceManager;

-(id) initWithService:(Service *)theService {
    self = [super init];
    
    self.service = theService;
    if ([self isStarted]) {
        self.status = 2;
    }
    return self;
}

-(BOOL) isStarted {
    
    Process *p = [[Process alloc] init];
    
    NSString *output;
    NSMutableString *launchCtlCommand = [[NSMutableString alloc] initWithString:@"/bin/launchctl list | grep "];
    [launchCtlCommand appendString:self.service.identifier];
    
    if (self.service.useSudo) {
        output = [p executeSudo:@"/bin/bash" withArguments:@[@"-c", launchCtlCommand]];
    } else {
        output = [p execute:@"/bin/bash" withArguments:@[@"-c", launchCtlCommand]];
    }
    
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
    
    Process *p = [[Process alloc] init];
    if (self.service.useSudo) {
        [p executeSudo:@"/bin/launchctl" withArguments: @[@"unload", self.service.plist]];
    } else {
        [p execute:@"/bin/launchctl" withArguments:@[@"unload", self.service.plist]];
    }
    
    [self isStarted];
    [self updateStatusIndicator];
    [self updateStartStopStatus];

}

-(void) start {
    self.status = 1;
    [self updateStatusIndicator];
    
    Process *p = [[Process alloc] init];
    if (self.service.useSudo) {
        [p executeSudo:@"/bin/launchctl" withArguments: @[@"load", self.service.plist]];
    } else {
        [p execute:@"/bin/launchctl" withArguments:@[@"load", self.service.plist]];
    }
    
    [self isStarted];
    [self updateStatusIndicator];
    [self updateStartStopStatus];
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

-(void) updateStartStopStatus {
    if (self.status == 0) {
        [self.startStop setTitle:@"Start"];
    } else {
        [self.startStop setTitle:@"Stop"];
    }
    [self.startStop setNeedsDisplay:YES];
}

-(void) handleStartStopClick:(id)sender {
    if (self.status == 0) {
        [self start];
    } else {
        [self stop];
    }
}

-(void) handleSudoClick:(id)sender {
    NSButton *b = (NSButton *)sender;
    if (b.state == NSOnState) {
        self.service.useSudo = YES;
    } else {
        self.service.useSudo = NO;
    }
    [self.serviceManager saveService:self.service];
}

-(void) handleRunAtLoginClick:(id)sender {
    NSButton *b = (NSButton *)sender;
    if (b.state == NSOnState) {
        self.service.runAtLogin = YES;
    } else {
        self.service.runAtLogin = NO;
    }
    [self.serviceManager saveService:self.service];
}

-(void) handleRemoveClick:(id)sender {
    [self stop];
    [self.serviceManager removeService:self.service];
}

@end
