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
#import "Process.h"


@implementation LaunchRocket

@synthesize serviceParent;
@synthesize homebrewScan;
@synthesize launchRocketLabel;
@synthesize versionNumber;
@synthesize addPlist;

- (void)mainViewDidLoad
{
    ServiceManager *sm = [[ServiceManager alloc] initWithView:self.serviceParent];
    [sm cleanServicesFile];
    [self.homebrewScan setTarget:sm];
    [self.homebrewScan setAction:@selector(handleHomebrewScanClick:)];
    [self.addPlist setTarget:sm];
    [self.addPlist setAction:@selector(handleAddPlistClick:)];
    
    self.launchRocketLabel.font = [OpenSansFont getFontWithSize:16];
    self.versionNumber.font = [OpenSansFont getFontWithSize:13];
    [sm renderList];
}

- (void)didUnselect {
    [Process killSudoHelper];
}

@end
