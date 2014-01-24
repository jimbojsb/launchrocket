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

-(id) initWithService:(Service *)theService {
    self = [super init];
    
    self.service = theService;
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
        return YES;
    }
    return NO;
    
}

-(void) stop {
    [self setStatus:@"yellow"];
    NSTask *command = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"unload", self.service.plist, nil];
    
    [command setLaunchPath:@"/bin/launchctl"];
    [command setArguments:args];
    [command launch];
    [command waitUntilExit];
    [self setStatus:@"red"];

}

-(void) start {
    [self setStatus:@"yellow"];
    NSTask *command = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"load", self.service.plist, nil];
    
    [command setLaunchPath:@"/bin/launchctl"];
    [command setArguments:args];
    [command launch];
    [command waitUntilExit];
    [self setStatus:@"green"];
}

-(void) setStatus:(NSString *)status {
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:status];
    [self.statusIndicator setImage:image];
}

@end
