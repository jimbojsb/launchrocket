//
//  ServiceManager.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServiceManager.h"
#import "Service.h"
#import "ServiceController.h"
#import "FlippedView.h"
#import "SegmentButton.h"

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
    [self loadServicesFromPlist];
    [self renderList];
}

-(IBAction) handleAddClick:(id)sender {
    NSOpenPanel *openDialog = [NSOpenPanel openPanel];
    [openDialog setCanChooseDirectories: NO];
    [openDialog setCanChooseFiles: YES];
    [openDialog setDirectoryURL: [NSURL URLWithString:NSHomeDirectory()]];
    [openDialog setAllowsMultipleSelection:NO];
    [openDialog setAllowedFileTypes: @[@"plist"]];
    [openDialog setDirectoryURL:[NSURL URLWithString: NSHomeDirectory()]];
    NSURL *chosenUrl;
    if ([openDialog runModal]) {
        chosenUrl = [openDialog URL];
        NSString *filePath = [[chosenUrl absoluteString] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
        [self addService:filePath];
    }
}

-(void) addService:(NSString *)plistFile {
    NSMutableDictionary *servicesList = [[NSMutableDictionary alloc] initWithContentsOfFile:self.servicesFilePath];
    Service *s = [[Service alloc] initWithPlist:plistFile];
    [servicesList setObject: s.plist forKey:s.identifier];
    [servicesList writeToFile:self.servicesFilePath atomically:YES];
}

-(void) loadServicesFromPlist {
    [self.services release];
    self.services = [[NSMutableArray alloc] init];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:self.servicesFilePath];
    for (NSString *key in plistData) {
        NSString *plistFile = [plistData objectForKey:key];
        Service *service = [[Service alloc] initWithPlist:plistFile];
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
        
        NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, listOffsetPixels, 170, 50)];
        [label setEditable:NO];
        [label setDrawsBackground:NO];
        [label setSelectable:NO];
        [label setStringValue:service.identifier];
        [label setBezeled:NO];
        [serviceList addSubview:label];
        
        NSTextField *status = [[NSTextField alloc] initWithFrame:NSMakeRect(270, listOffsetPixels, 20, 50)];
        [status setEditable:NO];
        [status setDrawsBackground:NO];
        [status setSelectable:NO];
        [status setBezeled:NO];
        if ([sc isStarted]) {
            [status setTextColor:[NSColor greenColor]];
            [status setStringValue:@"✔"];
        } else {
            [status setTextColor:[NSColor redColor]];
            [status setStringValue:@"✘"];
        }
        [serviceList addSubview:status];

        
        [serviceList addSubview:label];
        
        SegmentButton *onOff = [[SegmentButton alloc] initWithFrame:NSMakeRect(170, listOffsetPixels, 100, 50)];
       
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
        
        
        listOffsetPixels += 70;
    }
    
    [self.serviceParent setDocumentView:serviceList];
    
}



@end
