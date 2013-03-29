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
#import "ServiceManager.h"
#import "ServiceController.h"


@implementation LaunchRocket

@synthesize serviceParent;

- (void)mainViewDidLoad
{
    ServiceManager *sm = [[ServiceManager alloc] init];
    
    NSMutableArray *services = [ServiceEnumerator enumerateWithBundle: [self bundle]];
    sm.services = services;
    
    for (Service *s in services) {
        ServiceController *sc = [[ServiceController alloc] initWithService:s];
        [sm.serviceControllers setObject:sc forKey:s.name];
    }
    
    ServicePane *sp = [[ServicePane alloc] initWithServiceManager:sm andView:self.serviceParent];
    [sp renderList];
}

@end
