//
//  ServiceEnumerator.m
//  BrewPub
//
//  Created by Josh Butts on 3/17/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServiceEnumerator.h"

@implementation ServiceEnumerator

+ (NSMutableArray *) enumerateWithBundle:(NSBundle *)bundle {
    [self createServicesDirectory];
    NSMutableArray *services = [[NSMutableArray alloc] init];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:@"/usr/local/etc/launchrocket" error:nil];
    for (NSString *file in files) {
        NSString *extension = [file substringFromIndex:[file length] - 5];
        if ([@"plist" isEqualToString:extension]) {
            NSString *fullFilePath = [NSString stringWithFormat:@"%@%@", @"/usr/local/etc/launchrocket/", file];
            NSDictionary *plistData = [[NSDictionary alloc] initWithContentsOfFile: fullFilePath];
            NSMutableDictionary *launchRocketData = [plistData objectForKey:@"launchrocket"];
            if (launchRocketData == nil) {
                continue;
            }
            [launchRocketData setObject: fullFilePath forKey:@"plist"];
            BOOL iconIsLoadable = [fileManager fileExistsAtPath:[launchRocketData objectForKey:@"icon"]];
            NSImage *icon;
            if (iconIsLoadable) {
                icon = [[NSImage alloc] initWithContentsOfFile:[launchRocketData objectForKey:@"icon"]];
            } else {
                NSString *resourcePath = [bundle resourcePath];
                NSString *iconPath = [NSString stringWithFormat:@"%@%@%@", resourcePath, @"/", [launchRocketData objectForKey:@"icon"]];
                icon = [[NSImage alloc] initWithContentsOfFile: iconPath];
            }
            if (icon == nil) {
                continue;
            } else {
                [launchRocketData setObject:icon forKey:@"icon"];
            }
            [services addObject:launchRocketData];
        }
    }
   return services;
}

+ (void) createServicesDirectory {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createDirectoryAtPath:@"/usr/local/etc/launchrocket" withIntermediateDirectories:NO attributes:nil error:nil];
}

@end
