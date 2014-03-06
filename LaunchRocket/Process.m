//
//  Process.m
//  LaunchRocket
//
//  Created by Josh Butts on 1/24/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import "Process.h"

@implementation Process

@synthesize pathEnvVar;

-(id) init {
    self = [super init];
    self.pathEnvVar = [self findPathEnvVar];
    return self;
}

-(NSString *) execute:(NSString *)command {
    NSLog(@"%@%@", @"Executing command: ", command);
    
    NSString *resolvedCommand;
    if (self.pathEnvVar != nil) {
        resolvedCommand = [NSString stringWithFormat:@"PATH=%@ %@", self.pathEnvVar, command];
    } else {
        resolvedCommand = command;
    }
    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@%@", [[NSBundle bundleForClass:[self class]] resourcePath], @"/sudo.app"];
    NSMutableString *scriptSource = [NSMutableString stringWithFormat:@"tell application \"%@\"\n exec(\"%@\")\n end tell\n", sudoHelperPath, resolvedCommand];
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

-(NSString *) findPathEnvVar {
    static NSString *path;
    
    NSLog(@"%@", @"Discovering bash profile files");
    // try the most common way to get your path variable
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *filesToMaybeSource = @[@".bash_profile", @".bashrc", @".profile"];
    NSMutableArray *filesToSource = [[NSMutableArray alloc] init];
    for (NSString *file in filesToMaybeSource) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), file];
        if ([fm fileExistsAtPath:filePath]) {
            [filesToSource addObject:[NSString stringWithFormat:@"source %@", filePath]];
        }
    }
    NSString *echoCommand = [NSString stringWithFormat:@"%@ && echo $PATH", [filesToSource componentsJoinedByString:@" && "]];
    NSString *result = [self execute:echoCommand];
    return result;
}

+(void) killSudoHelper {
    NSLog(@"%@", @"Killing helper");
    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@%@", [[NSBundle bundleForClass:[self class]] resourcePath], @"/sudo.app"];
    NSString *scriptSource = [NSString stringWithFormat:@"tell application \"%@\"\n stopscript()\n end tell\n", sudoHelperPath];
    NSAppleScript *script = [[NSAppleScript new] initWithSource:scriptSource];
    [script executeAndReturnError:nil];
}


@end
