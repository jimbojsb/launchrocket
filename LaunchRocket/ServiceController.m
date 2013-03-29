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
@synthesize plistPath;
@synthesize launchAgentPath;
@synthesize fm;

-(id) initWithService:(Service *)theService {
    self = [super init];
    
    self.service = theService;
    self.fm = [[NSFileManager alloc] init];
    self.plistPath = [NSString stringWithFormat:@"%@%@", @"/usr/local/etc/launchrocket/", self.service.plist];
    self.launchAgentPath = [NSString stringWithFormat:@"%@%@%@", NSHomeDirectory(), @"/Library/LaunchAgents/", self.service.plist];
    
    return self;
}

-(BOOL) isStarted {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*?\"PID\" = \"[0-9]\".*?" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSTask *command = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"list", self.service.plist, nil];
    NSPipe *stdOut = [NSPipe pipe];
    
    [command setLaunchPath:@"/bin/launchctl"];
    [command setArguments:args];
    [command setStandardOutput:stdOut];
    [command launch];
    [command waitUntilExit];
    
    NSFileHandle *read = [stdOut fileHandleForReading];
    NSData *readData = [read readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    
    if ([regex numberOfMatchesInString:output options:0 range:NSMakeRange(0, [output length])] > 0) {
        return YES;
    }
    return NO;
    
}

-(BOOL) shouldStartAtLogin {
    return [self.fm fileExistsAtPath:self.launchAgentPath];
}

-(void) startAtLogin:(BOOL) shouldStartAtLogin {
    [self.fm removeItemAtPath:self.launchAgentPath error:nil];
    if (shouldStartAtLogin) {
        [self.fm createSymbolicLinkAtPath:self.launchAgentPath withDestinationPath:self.plistPath error:nil];
    }
}

-(void) stop {
    NSTask *command = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"unload", self.plistPath, nil];
    
    [command setLaunchPath:@"/bin/launchctl"];
    [command setArguments:args];
    [command launch];
    [command waitUntilExit];

}

-(void) start {
    NSTask *command = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"load", self.plistPath, nil];
    
    [command setLaunchPath:@"/bin/launchctl"];
    [command setArguments:args];
    [command launch];
    [command waitUntilExit];

}

@end
