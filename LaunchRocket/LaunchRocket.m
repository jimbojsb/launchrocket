//
//  LaunchRocket.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/24/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "LaunchRocket.h"
#import "ServiceEnumerator.h"
#import "Service.h"
#import "ServicePane.h"


@implementation LaunchRocket

@synthesize serviceParent;

- (void)mainViewDidLoad
{        
    NSMutableArray *services = [ServiceEnumerator enumerateWithBundle: [self bundle]];
    ServicePane *sp = [[ServicePane alloc] initWithServices:services andView:self.serviceParent];
    [sp renderList];
}

@end
