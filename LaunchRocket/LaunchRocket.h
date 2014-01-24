//
//  LaunchRocket.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/24/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface LaunchRocket : NSPreferencePane

@property (weak) IBOutlet NSScrollView *serviceParent;
@property (weak) IBOutlet NSButton *homebrewScan;
@property (weak) IBOutlet NSButton *addPlist;
@property (weak) IBOutlet NSTextField *launchRocketLabel;
@property (weak) IBOutlet NSTextField *versionNumber;


- (void)mainViewDidLoad;

@end
