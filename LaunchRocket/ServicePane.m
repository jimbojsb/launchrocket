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
#import "ServiceController.h"
#import "ServiceManager.h"
#import "SegmentButton.h"
#import "ToggleButton.h"

@implementation ServicePane

@synthesize view;
@synthesize serviceManager;

-(id) initWithServiceManager:(ServiceManager *)sm andView:(NSScrollView *)scrollView {
    self = [super init];
    self.serviceManager = sm;
    self.view = scrollView;
    return self;
}

-(void) renderList {
    int serviceListHeight = (int) (70 * [self.serviceManager.services count]);
    FlippedView *serviceList = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, 400, serviceListHeight)];
    
    int listOffsetPixels = 0;
    for (Service *service in self.serviceManager.services) {
        
        ServiceController *sc = [self.serviceManager.serviceControllers objectForKey:service.name];
        
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, listOffsetPixels, 150, 50)];
        [imageView setImage:service.image];
        [serviceList addSubview:imageView];
        
        SegmentButton *onOff = [[SegmentButton alloc] initWithFrame:NSMakeRect(170, listOffsetPixels, 100, 50)];
        [onOff setSegmentCount:2];
        [onOff setLabel:@"Off" forSegment:0];
        [onOff setLabel:@"On" forSegment:1];
        [onOff setSegmentStyle:NSSegmentStyleCapsule];
        [onOff setTarget:self.serviceManager];
        [onOff setAction:@selector(handleOnOffClick:)];
        onOff.serviceName = service.name;
        if ([sc isStarted]) {
            [onOff setSelected:YES forSegment:1];
        } else {
            [onOff setSelected:YES forSegment:0];
        }
        [serviceList addSubview:onOff];
        
        ToggleButton *startAtLogin = [[ToggleButton alloc] initWithFrame:NSMakeRect(275, listOffsetPixels, 100, 50)];
        [startAtLogin setTitle:@"Start at Login"];
        [startAtLogin setButtonType:NSPushOnPushOffButton];
        [startAtLogin setBezelStyle:NSTexturedRoundedBezelStyle];
        [startAtLogin setTarget:self.serviceManager];
        [startAtLogin setAction:@selector(handleStartAtLoginClick:)];
        startAtLogin.serviceName = service.name;
        if ([sc shouldStartAtLogin]) {
            [startAtLogin setState:NSOnState];
        }
        [serviceList addSubview:startAtLogin];
        
        listOffsetPixels += 70;
    }
        
    [self.view setDocumentView:serviceList];

}

@end
