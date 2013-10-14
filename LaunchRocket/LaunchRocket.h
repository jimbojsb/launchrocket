//
//  LaunchRocket.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/24/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface LaunchRocket : NSPreferencePane

@property (assign) IBOutlet NSScrollView *serviceParent;
@property (assign) IBOutlet NSButton *homebrewScan;
@property (assign) IBOutlet NSButton *add;

- (void)mainViewDidLoad;

@end
