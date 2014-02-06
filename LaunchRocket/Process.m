//
//  Process.m
//  LaunchRocket
//
//  Created by Josh Butts on 1/24/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import "Process.h"

@implementation Process

@synthesize authref;


-(NSString *) execute:(NSString *)command withArugments:(NSArray *)args {
    NSTask *runCommand = [[NSTask alloc] init];
    
    NSPipe *stdOut = [NSPipe pipe];
    
    [runCommand setLaunchPath:command];
    [runCommand setArguments:args];
    [runCommand setStandardOutput:stdOut];
    [runCommand launch];
    [runCommand waitUntilExit];
    
    NSFileHandle *read = [stdOut fileHandleForReading];
    NSData *readData = [read readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    return output;
}

-(NSString *) executeSudo:(NSString *)command withArugments:(NSArray *)args {
    
}

-(void) getAuthRef {
    OSStatus status;
    AuthorizationRef authorizationRef;
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
                                 kAuthorizationFlagDefaults, &authorizationRef);
    if (status == errAuthorizationSuccess) {
        NSLog(@"%@", @"Succesfully got auth ref");
        self.authref = authorizationRef;
    } else {
        NSLog(@"%@", @"Failed to get auth ref");
    }
}

@end
