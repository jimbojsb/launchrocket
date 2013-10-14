//
//  LaunchRocket.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/24/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "LaunchRocket.h"
#import "ServiceManager.h"


@implementation LaunchRocket

@synthesize serviceParent;
@synthesize homebrewScan;

- (void)mainViewDidLoad
{
    ServiceManager *sm = [[ServiceManager alloc] initWithBundle: [self bundle] andView:self.serviceParent];
    [self.homebrewScan setTarget:sm];
    [self.homebrewScan setAction:@selector(handleHomebrewScanClick:)];
    [self.add setTarget:sm];
    [self.add setAction:@selector(handleAddClick:)];
    [sm renderList];
}

@end
