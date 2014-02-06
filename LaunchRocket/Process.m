//
//  Process.m
//  LaunchRocket
//
//  Created by Josh Butts on 1/24/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import "Process.h"

@implementation Process

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
    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@%@", [[NSBundle bundleForClass:[self class]] resourcePath], @"/sudo.app"];
    NSString *commandString = [NSString stringWithFormat:@"%@ %@", command, [args componentsJoinedByString:@" "]];
    NSString *scriptSource = @"set output to missing value\n";
    scriptSource = [scriptSource stringByAppendingString:"tell application \""];
    scriptSource = [scriptSource stringByAppendingString:"tell application \""];

    
    
    tell application \"%@\"\n execsudo(\"%@\")\n return output\n end tell\n", sudoHelperPath, commandString];
    NSAppleScript *script = [[NSAppleScript new] initWithSource:scriptSource];
    NSDictionary *error;
    NSString *output = [[script executeAndReturnError:&error] stringValue];
    NSLog(@"%@", output);
    return output;
}

-(void) killSudoHelper {
    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@%@", [[NSBundle bundleForClass:[self class]] resourcePath], @"/sudo.app"];
    NSString *scriptSource = [NSString stringWithFormat:@"tell application \"%@\"\n stopscript()\n end tell\n", sudoHelperPath];
    NSAppleScript *script = [[NSAppleScript new] initWithSource:scriptSource];
    [script executeAndReturnError:nil];
}


@end
