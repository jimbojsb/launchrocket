//
//  ServicePane.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/26/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServicePane.h"
#import "Service.h"
#import "FlippedView.h"

@implementation ServicePane

@synthesize services;
@synthesize view;

-(id) initWithServices:(NSMutableArray *)servicesList andView:(NSScrollView *)scrollView {
    self = [super init];
    self.services = servicesList;
    self.view = scrollView;
    return self;
}

-(void) renderList {
    int serviceListHeight = (int) (70 * [self.services count]);
    FlippedView *serviceList = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, 400, serviceListHeight)];
    
    int listOffsetPixels = 0;
    for (Service *service in self.services) {
//        NSTextField *tf = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 150, 20)];
//        [tf setStringValue:service.name];
//        [tf setBezeled: NO];
//        [tf setDrawsBackground:NO];
//        [tf setEditable:NO];
//        [tf setSelectable:NO];
        
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, listOffsetPixels, 150, 50)];
        [imageView setImage:service.image];
        [serviceList addSubview:imageView];
        
        NSSegmentedControl *buttons = [[NSSegmentedControl alloc] initWithFrame:NSMakeRect(170, listOffsetPixels, 150, 50)];
        [buttons setSegmentCount:3];
        [buttons setLabel:@"Off" forSegment:0];
        [buttons setLabel:@"On" forSegment:1];
        [buttons setLabel:@"Auto" forSegment:2];
        [buttons setSegmentStyle:NSSegmentStyleCapsule];
        [serviceList addSubview:buttons];
        
//        [serviceList addSubview:tf];
        listOffsetPixels += 70;
    }
        
    [self.view setDocumentView:serviceList];

}

@end
