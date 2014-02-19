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
    
    NSLog(@"%@%@", @"Initializing service ", theService.identifier);
    
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
        output = [p executeSudo:launchCtlCommand];
    } else {
        output = [p execute:launchCtlCommand];
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
        NSString *tmpPlist = [NSString stringWithFormat:@"/tmp/%@.plist", self.service.identifier];
        NSString *copyCommand = [NSString stringWithFormat:@"cp %@ %@", self.service.plist, tmpPlist];
        NSString *runCommand = [NSString stringWithFormat:@"/bin/launchctl unload %@", tmpPlist];
        NSString *cleanupCommand = [NSString stringWithFormat:@"rm %@", tmpPlist];
        [p executeSudo:copyCommand];
        [p executeSudo:runCommand];
        [p executeSudo:cleanupCommand];
    } else {
        NSString *command = [NSString stringWithFormat:@"/bin/launchctl unload %@", self.service.plist];
        [p execute:command];
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
        NSString *tmpPlist = [NSString stringWithFormat:@"/tmp/%@.plist", self.service.identifier];
        NSString *copyCommand = [NSString stringWithFormat:@"cp %@ %@", self.service.plist, tmpPlist];
        NSString *runCommand = [NSString stringWithFormat:@"/bin/launchctl load %@", tmpPlist];
        NSString *cleanupCommand = [NSString stringWithFormat:@"rm %@", tmpPlist];
        [p executeSudo:copyCommand];
        [p executeSudo:runCommand];
        [p executeSudo:cleanupCommand];
    } else {
        NSString *command = [NSString stringWithFormat:@"/bin/launchctl load %@", self.service.plist];
        [p execute:command];
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
