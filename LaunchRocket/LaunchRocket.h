//
//  LaunchRocket.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/24/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface LaunchRocket : NSPreferencePane

@property IBOutlet NSScrollView *serviceParent;
@property IBOutlet NSButton *homebrewScan;
@property IBOutlet NSButton *addPlist;
@property IBOutlet NSTextField *launchRocketLabel;
@property IBOutlet NSTextField *versionNumber;


- (void)mainViewDidLoad;

@end
