//
//  ServiceManager.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServiceManager.h"
#import "SegmentButton.h"
#import "Service.h"
#import "ServiceController.h"
#import "FlippedView.h"
#import "OpenSansFont.h"
#import "HorizontalDivider.h"

@implementation ServiceManager

@synthesize serviceControllers;
@synthesize services;
@synthesize bundle;
@synthesize serviceParent;

-(id) initWithBundle:(NSBundle *)b andView:(NSScrollView *)sv {
    self = [super init];
    self.serviceControllers = [[NSMutableDictionary alloc] init];
    self.bundle = b;
    self.serviceParent = sv;
    self.servicesFilePath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Library/Preferences/com.joshbutts.launchrocket.plist"];
    [self createServicesFile];
    [self loadServicesFromPlist];
    return self;
}

-(void) handleOnOffClick:(id)sender {
    SegmentButton *s = (SegmentButton *)sender;
    ServiceController *sc = [self.serviceControllers objectForKey:s.serviceName];
    if ([s isSelectedForSegment:0]) {
        [sc stop];
    } else {
        [sc start];
    }
}

-(void) createServicesFile {
    NSFileManager *fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:self.servicesFilePath]) {
        [[[NSMutableDictionary alloc] init] writeToFile:self.servicesFilePath atomically:YES];
    }
}

-(void) cleanServicesFile {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.servicesFilePath];
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSMutableArray *servicesToRemove = [[NSMutableArray alloc] init];
    for (NSString *key in dict) {
        NSDictionary *data = [dict objectForKey:key];
        if (![fm fileExistsAtPath:[data objectForKey:@"plist"]]) {
            [servicesToRemove addObject:key];
        }
    }
    for (NSString *key in servicesToRemove) {
        [dict removeObjectForKey:key];
    }
    [dict writeToFile:self.servicesFilePath atomically:YES];
}

-(IBAction) handleHomebrewScanClick:(id)sender {
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:@"/usr/local/opt"];
    for (NSString *item in de) {
        NSString *servicePlist = [NSString stringWithFormat:@"%@%@%@%@%@", @"/usr/local/opt/", item, @"/homebrew.mxcl.", item, @".plist"];
        if ([fm fileExistsAtPath:servicePlist]) {
            [self addService:servicePlist];
        }
    }
    [self cleanServicesFile];
    [self loadServicesFromPlist];
    [self renderList];
}

-(IBAction) handleAddPlistClick:(id)sender {
    NSOpenPanel *filePicker = [NSOpenPanel openPanel];
    [filePicker setCanChooseDirectories:NO];
    [filePicker setCanChooseFiles:YES];
    [filePicker setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [filePicker runModal];
    if (clicked == NSFileHandlingPanelOKButton) {
        NSString *plistFile = [[filePicker URL] path];
        [self addService:plistFile];
        [self cleanServicesFile];
        [self loadServicesFromPlist];
        [self renderList];
    }
    
}

-(void) addService:(NSString *)plistFile {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pathComponents = [plistFile componentsSeparatedByString:@"/"];
    NSArray *filenameComponents = [[pathComponents lastObject] componentsSeparatedByString:@"."];
    NSString *identifier = [[filenameComponents subarrayWithRange:NSMakeRange(0, [filenameComponents count] - 1)] componentsJoinedByString:@"."];
    NSString *serviceName = [[filenameComponents objectAtIndex:[filenameComponents count] - 2] capitalizedString];
    [dict setObject:plistFile forKey:@"plist"];
    [dict setObject:serviceName forKey:@"name"];
    NSMutableDictionary *servicesList = [[NSMutableDictionary alloc] initWithContentsOfFile:self.servicesFilePath];
    [servicesList setObject:dict forKey:identifier];
    [servicesList writeToFile:self.servicesFilePath atomically:YES];
}

-(void) loadServicesFromPlist {
    [self.services release];
    self.services = [[NSMutableArray alloc] init];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:self.servicesFilePath];
    for (NSString *key in plistData) {
        NSMutableDictionary *serviceData = [plistData objectForKey:key];
        Service *service = [[Service alloc] initWithOptions:serviceData];
        ServiceController *sc = [[ServiceController alloc] initWithService:service];
        [self.serviceControllers setObject:sc forKey:service.identifier];
        [self.services addObject:service];
    }
}


-(void) renderList {
    int serviceListHeight = (int) (50 * [self.services count]);
    FlippedView *serviceList = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, 400, serviceListHeight)];
    
    int listOffsetPixels = 0;
    for (Service *service in self.services) {
        
        ServiceController *sc = [self.serviceControllers objectForKey:service.identifier];
        
        NSImageView *statusIndicator = [[NSImageView alloc] initWithFrame:NSMakeRect(0, listOffsetPixels, 30, 30)];
        [statusIndicator setImageScaling:NSScaleToFit];
        [serviceList addSubview:statusIndicator];
        sc.statusIndicator = statusIndicator;
        [sc updateStatusIndicator];
        
        
        NSTextField *name = [[NSTextField alloc] initWithFrame:NSMakeRect(40, listOffsetPixels, 120, 30)];
        [name setStringValue:service.name];
        [name setBezeled:NO];
        [name setDrawsBackground:NO];
        [name setEditable:NO];
        [name setSelectable:NO];
        name.font = [OpenSansFont getFontWithSize:16];
        [serviceList addSubview:name];
        
        SegmentButton *onOff = [[SegmentButton alloc] initWithFrame:NSMakeRect(190, listOffsetPixels, 100, 30)];
        [onOff setSegmentCount:2];
        [onOff setLabel:@"Off" forSegment:0];
        [onOff setLabel:@"On" forSegment:1];
        [onOff setSegmentStyle:NSSegmentStyleCapsule];
        [onOff setTarget:self];
        [onOff setAction:@selector(handleOnOffClick:)];
        onOff.serviceName = service.identifier;
        if ([sc isStarted]) {
            [onOff setSelected:YES forSegment:1];
        } else {
            [onOff setSelected:YES forSegment:0];
        }
        [serviceList addSubview:onOff];
        
 

        
        NSButton *sudo = [[NSButton alloc] initWithFrame:NSMakeRect(300, listOffsetPixels, 80, 30)];
        [sudo setBezelStyle:NSTexturedRoundedBezelStyle];
        [sudo setButtonType:NSPushOnPushOffButton];
        [sudo setTitle:@"As Root"];
        [serviceList addSubview:sudo];
        
        
        listOffsetPixels += 37;

        HorizontalDivider *horizontalLine = [[HorizontalDivider alloc] initWithFrame:CGRectMake(0 , listOffsetPixels, 400, 1)];
        [serviceList addSubview:horizontalLine];

        listOffsetPixels += 10;

        
    }
    
    [self.serviceParent setDocumentView:serviceList];
    
}



@end
