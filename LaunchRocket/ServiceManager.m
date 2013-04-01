//
//  ServiceManager.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServiceManager.h"
#import "ToggleButton.h"
#import "SegmentButton.h"
#import "Service.h"
#import "ServiceController.h"
#import "FlippedView.h"

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

-(void) handleStartAtLoginClick:(id)sender {
    ToggleButton *t = (ToggleButton *)sender;
    ServiceController *sc = [self.serviceControllers objectForKey:t.serviceName];
    if (t.state == NSOnState) {
        [sc startAtLogin: YES];
    } else {
        [sc startAtLogin: NO];
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
    NSString *homebrewMappingFile = [[NSString alloc] initWithFormat:@"%@%@", [self.bundle resourcePath], @"/homebrew-mapping.plist"];
    NSDictionary *homebrewMappings = [[NSDictionary alloc] initWithContentsOfFile:homebrewMappingFile];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:@"/usr/local/opt"];
    for (NSString *item in de) {
        NSString *servicePlist = [NSString stringWithFormat:@"%@%@%@%@%@", @"/usr/local/opt/", item, @"/homebrew.mxcl.", item, @".plist"];
        if ([fm fileExistsAtPath:servicePlist]) {
            NSString *serviceIdentifier = [[NSString alloc] initWithFormat:@"%@%@", @"homebrew.mxcl.", item];
            NSString *imageFile = [homebrewMappings objectForKey:serviceIdentifier];
            if (imageFile != nil) {
                [self addService:servicePlist imageFile:imageFile];
            }
        }
    }
    [self cleanServicesFile];
    [self loadServicesFromPlist];
    [self renderList];
}

-(void) addService:(NSString *)plistFile imageFile:(NSString *)imageFile {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *identifier = [plistFile substringToIndex:[plistFile length] - 5];
    [dict setObject:plistFile forKey:@"plist"];
    [dict setObject:imageFile forKey:@"image"];
    NSMutableDictionary *servicesList = [[NSMutableDictionary alloc] initWithContentsOfFile:self.servicesFilePath];
    [servicesList setObject:dict forKey:identifier];
    [servicesList writeToFile:self.servicesFilePath atomically:YES];
}

-(void) loadServicesFromPlist {
    [self.services release];
    self.services = [[NSMutableArray alloc] init];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:self.servicesFilePath];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    for (NSString *key in plistData) {
        NSMutableDictionary *serviceData = [plistData objectForKey:key];
        BOOL imageIsLoadable = [fileManager fileExistsAtPath:[serviceData objectForKey:@"image"]];
        NSImage *image;
        if (imageIsLoadable) {
            image = [[NSImage alloc] initWithContentsOfFile:[serviceData objectForKey:@"image"]];
        } else {
            NSString *resourcePath = [self.bundle resourcePath];
            NSString *imagePath = [NSString stringWithFormat:@"%@%@%@", resourcePath, @"/", [serviceData objectForKey:@"image"]];
            image = [[NSImage alloc] initWithContentsOfFile: imagePath];
        }
        if (image == nil) {
            continue;
        } else {
            [serviceData setObject:image forKey:@"image"];
        }
        Service *service = [[Service alloc] initWithOptions:serviceData];
        ServiceController *sc = [[ServiceController alloc] initWithService:service];
        [self.serviceControllers setObject:sc forKey:service.identifier];
        [self.services addObject:service];
    }
}


-(void) renderList {
    int serviceListHeight = (int) (70 * [self.services count]);
    FlippedView *serviceList = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, 400, serviceListHeight)];
    
    int listOffsetPixels = 0;
    for (Service *service in self.services) {
        
        ServiceController *sc = [self.serviceControllers objectForKey:service.identifier];
        
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, listOffsetPixels, 150, 50)];
        [imageView setImage:service.image];
        [serviceList addSubview:imageView];
        
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
        
        ToggleButton *startAtLogin = [[ToggleButton alloc] initWithFrame:NSMakeRect(275, listOffsetPixels, 100, 50)];
        [startAtLogin setTitle:@"Start at Login"];
        [startAtLogin setButtonType:NSPushOnPushOffButton];
        [startAtLogin setBezelStyle:NSTexturedRoundedBezelStyle];
        [startAtLogin setTarget:self];
        [startAtLogin setAction:@selector(handleStartAtLoginClick:)];
        startAtLogin.serviceName = service.identifier;
        if ([sc shouldStartAtLogin]) {
            [startAtLogin setState:NSOnState];
        }
        [serviceList addSubview:startAtLogin];
        
        listOffsetPixels += 70;
    }
    
    [self.serviceParent setDocumentView:serviceList];
    
}



@end
