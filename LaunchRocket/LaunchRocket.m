//
//  LaunchRocket.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/24/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "LaunchRocket.h"
#import "ServiceEnumerator.h"


@implementation LaunchRocket

@synthesize serviceParent;

- (void)mainViewDidLoad
{
    NSView *serviceList = [[NSView alloc] initWithFrame:NSMakeRect(10, 10, 200, 200)];
    
    NSMutableArray *services = [ServiceEnumerator enumerateWithBundle: [self bundle]];
    
    for (NSDictionary *service in services) {
        NSTextField *tf = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 150, 20)];
        [tf setStringValue:[service objectForKey:@"name"]];
        [tf setBezeled: NO];
        [tf setDrawsBackground:NO];
        [tf setEditable:NO];
        [tf setSelectable:NO];
        
        NSImageView *iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 150, 50)];
        [iconView setImage:[service objectForKey:@"icon"]];
        [serviceList addSubview:iconView];
        
        [serviceList addSubview:tf];
    }

    
    [self.serviceParent addSubview:serviceList];
}

@end
