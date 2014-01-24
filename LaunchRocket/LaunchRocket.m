//
//  LaunchRocket.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/24/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "LaunchRocket.h"
#import "ServiceManager.h"
#import "OpenSansFont.h"

@implementation LaunchRocket

@synthesize serviceParent;
@synthesize homebrewScan;
@synthesize launchRocketLabel;
@synthesize versionNumber;

- (void)mainViewDidLoad
{

    
    
    
    ServiceManager *sm = [[ServiceManager alloc] initWithBundle: [self bundle] andView:self.serviceParent];
    [sm cleanServicesFile];
    [self.homebrewScan setTarget:sm];
    [self.homebrewScan setAction:@selector(handleHomebrewScanClick:)];
    self.launchRocketLabel.font = [OpenSansFont getFontWithSize:20];
    self.versionNumber.font = [OpenSansFont getFontWithSize:14];
    [sm renderList];
}

@end
