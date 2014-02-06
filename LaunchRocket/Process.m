//
//  Process.m
//  LaunchRocket
//
//  Created by Josh Butts on 1/24/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import "Process.h"

@implementation Process

@synthesize args;
@synthesize command;

-(id) initWithCommand:(NSString *)theCommand andArguments:(NSArray *)theArgs {
    self.command = theCommand;
    self.args = theArgs;
    return [super init];
}

-(NSString *) execute {
    NSTask *runCommand = [[NSTask alloc] init];
    
    NSPipe *stdOut = [NSPipe pipe];
    
    [runCommand setLaunchPath:self.command];
    [runCommand setArguments:self.args];
    [runCommand setStandardOutput:stdOut];
    [runCommand launch];
    [runCommand waitUntilExit];
    
    NSFileHandle *read = [stdOut fileHandleForReading];
    NSData *readData = [read readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    return output;
}

-(NSString *) executeSudo {
    
}

@end
