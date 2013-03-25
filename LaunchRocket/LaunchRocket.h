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


- (void)mainViewDidLoad;

@end
