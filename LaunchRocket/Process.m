//
//  Process.m
//  LaunchRocket
//
//  Created by Josh Butts on 1/24/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import "Process.h"

@implementation Process

-(NSString *) execute:(NSString *)command {
    NSLog(@"%@%@", @"Executing command: ", command);
    
    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@%@", [[NSBundle bundleForClass:[self class]] resourcePath], @"/sudo.app"];
    NSMutableString *scriptSource = [NSMutableString stringWithFormat:@"tell application \"%@\"\n exec(\"%@\")\n end tell\n", sudoHelperPath, command];
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
    NSDictionary *error;
    NSString *output = [[script executeAndReturnError:&error] stringValue];
    NSLog(@"Result of `%@` was %@", command, output);
    return output;
}

-(NSString *) executeSudo:(NSString *)command {
    NSLog(@"%@%@", @"Executing command with sudo: ", command);

    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@%@", [[NSBundle bundleForClass:[self class]] resourcePath], @"/sudo.app"];
    NSMutableString *scriptSource = [NSMutableString stringWithFormat:@"tell application \"%@\"\n execsudo(\"%@\")\n end tell\n", sudoHelperPath, command];
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
    NSDictionary *error;
    NSString *output = [[script executeAndReturnError:&error] stringValue];
    NSLog(@"Result of `sudo %@` was %@", command, output);
    return output;
}

+(void) killSudoHelper {
    NSLog(@"%@", @"Killing helper");
    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@%@", [[NSBundle bundleForClass:[self class]] resourcePath], @"/sudo.app"];
    NSString *scriptSource = [NSString stringWithFormat:@"tell application \"%@\"\n stopscript()\n end tell\n", sudoHelperPath];
    NSAppleScript *script = [[NSAppleScript new] initWithSource:scriptSource];
    [script executeAndReturnError:nil];
}


@end
