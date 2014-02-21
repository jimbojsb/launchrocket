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
#import "OpenSansFont.h"
#import "HorizontalDivider.h"
#import "Process.h"

@implementation ServiceManager

@synthesize serviceControllers;
@synthesize bundle;
@synthesize serviceParent;

-(id) initWithView:(NSScrollView *)sv {

    NSLog(@"%@", @"Initializing service mananger");
    self = [super init];
    self.serviceControllers = [[NSMutableArray alloc] init];
    self.bundle = [NSBundle bundleForClass:[self class]];
    self.serviceParent = sv;
    self.servicesFilePath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Library/Preferences/com.joshbutts.launchrocket.plist"];
    [self createServicesFile];
    [self loadServicesFromPlist];
    return self;
}

-(void) createServicesFile {

    NSFileManager *fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:self.servicesFilePath]) {
        NSLog(@"%@", @"Creating preferences file");
        [[[NSMutableDictionary alloc] init] writeToFile:self.servicesFilePath atomically:YES];
    }
}

-(void) cleanServicesFile {

    NSLog(@"%@", @"Removing non-existent services from preferences");
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
    
    Process *p = [[Process alloc] init];
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSLog(@"%@", @"Discovering bash profile files");
    // try the most common way to get your homebrew prefix
    NSArray *filesToMaybeSource = @[@".bash_profile", @".bashrc", @".profile"];
    NSMutableArray *filesToSource = [[NSMutableArray alloc] init];
    for (NSString *file in filesToMaybeSource) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), file];
        if ([fm fileExistsAtPath:filePath]) {
            [filesToSource addObject:[NSString stringWithFormat:@"source %@", filePath]];
        }
    }
    
    NSString *homebrewBashCommand = [NSString stringWithFormat:@"%@ && brew --prefix", [filesToSource componentsJoinedByString:@" && "]];
    NSLog(@"%@%@", @"Resolved homebrew path command: ", homebrewBashCommand);

    
    NSString *homebrewPath = [p execute:homebrewBashCommand];
    NSLog(@"%@%@", @"Homebrew prefix: ", homebrewPath);

    
    //if that doesn't work, we need the path to your brew executable
    if ([homebrewPath isEqualToString:@""]) {
        
        NSLog(@"%@", @"Homebrew path not found on initial attempt");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"We couldn't automatically find your Homebrew path. Please select your 'brew' executable"];
        NSInteger response = [alert runModal];
        if (response == 1001) {
            return;
        }
        
        NSLog(@"%@", @"Waiting for file selection");
        NSOpenPanel *brewPicker = [NSOpenPanel openPanel];
        [brewPicker setCanChooseDirectories:NO];
        [brewPicker setCanChooseFiles:YES];
        [brewPicker setAllowsMultipleSelection:NO];
        [brewPicker setDirectoryURL:[NSURL URLWithString:@"/usr"]];
        
        NSInteger clicked = [brewPicker runModal];
        if (clicked == NSFileHandlingPanelOKButton) {
            NSString *brew = [[brewPicker URL] path];
            NSLog(@"%@%@", @"Path to brew: ", homebrewPath);

            homebrewPath = [p execute:[NSString stringWithFormat:@"%@%@", brew, @" --prefix"]];
            NSLog(@"%@%@", @"Homebrew prefix: ", homebrewPath);
        }
    }
    
    // give up
    if ([homebrewPath isEqualToString:@""]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"We couldn't find your homebrew prefix using your Bash profile or the file you selected."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[self.serviceParent window] completionHandler:nil];
        NSLog(@"%@", @"Unable to find Homebrew path");
        return;
    }
    
    
    NSLog(@"%@", @"Scanning homebrew opt/");
    NSString *optPath = [NSString stringWithFormat:@"%@/opt/", homebrewPath];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:optPath];
    for (NSString *item in de) {
        NSString *servicePlist = [NSString stringWithFormat:@"%@%@%@%@%@", optPath, item, @"/homebrew.mxcl.", item, @".plist"];
        if ([fm fileExistsAtPath:servicePlist]) {
            [self addService:servicePlist];
        }
    }
    
    NSLog(@"%@", @"Scanning for josegonzales/php");
    //handle special plists, most specifically, josegonzales/php stuff
    NSString *specialPlistPath = [[self bundle] pathForResource:@"special-plists" ofType:@"plist"];
    NSArray *additionalPlists = [NSArray arrayWithContentsOfFile:specialPlistPath];
    for (NSString *plist in additionalPlists) {
        NSString *servicePlist = [NSString stringWithFormat:@"%@%@", optPath, plist];
        if ([fm fileExistsAtPath:servicePlist]) {
            [self addService:servicePlist];
        }
    }
    
    NSLog(@"%@", @"Scanning for homebrew etc/launchrocket");
    // scan etc/launchrocket
    NSString *launchrocketPlistsPath = [NSString stringWithFormat:@"%@/etc/launchrocket", homebrewPath];
    if ([fm fileExistsAtPath:launchrocketPlistsPath]) {
        de = [fm enumeratorAtPath:launchrocketPlistsPath];
        for (NSString *plist in de) {
            NSString *servicePlist = [NSString stringWithFormat:@"%@/%@", launchrocketPlistsPath, plist];
            if ([fm fileExistsAtPath:servicePlist]) {
                [self addService:servicePlist];
            }
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
    NSLog(@"%@%@", @"Adding services", plistFile);
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
    NSLog(@"%@", @"Wrote services file");
}

-(void) saveService:(Service *)service {
    NSMutableDictionary *servicesList = [[NSMutableDictionary alloc] initWithContentsOfFile:self.servicesFilePath];
    [servicesList setObject:[service getPlistData] forKey:service.identifier];
    [servicesList writeToFile:self.servicesFilePath atomically:YES];
    NSLog(@"%@", @"Wrote services file");
}

-(void) removeService:(Service *)service {
    NSMutableDictionary *servicesList = [[NSMutableDictionary alloc] initWithContentsOfFile:self.servicesFilePath];
    [servicesList removeObjectForKey:service.identifier];
    [servicesList writeToFile:self.servicesFilePath atomically:YES];
    NSLog(@"%@", @"Wrote services file");
    [self loadServicesFromPlist];
    [self renderList];
}


-(void) loadServicesFromPlist {
    NSLog(@"%@", @"Attempting to load services from plist");
    [self.serviceControllers release];
    self.serviceControllers = [[NSMutableArray alloc] init];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:self.servicesFilePath];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    for (NSString *key in plistData) {
        NSMutableDictionary *serviceData = [plistData objectForKey:key];
        Service *service = [[Service alloc] initWithOptions:serviceData];
        
        if (![fm fileExistsAtPath:service.plist]) {
            NSLog(@"%@%@", service.plist, @" was not found. Removing from list.");
            service.identifier = key;
            [self removeService:service];
            continue;
        }
        
        ServiceController *sc = [[ServiceController alloc] initWithService:service];
        sc.serviceManager = self;
        sc.service = service;
        [self.serviceControllers addObject:sc];
    }
    NSLog(@"%@", @"Successfully loaded services from plist");

}


-(void) renderList {
    int serviceListHeight = (int) (50 * [self.serviceControllers count]);
    FlippedView *serviceList = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, 500, serviceListHeight)];
    
    int listOffsetPixels = 0;
    for (ServiceController *sc in self.serviceControllers) {
        
        NSImageView *statusIndicator = [[NSImageView alloc] initWithFrame:NSMakeRect(0, listOffsetPixels, 30, 30)];
        [statusIndicator setImageScaling:NSScaleToFit];
        [serviceList addSubview:statusIndicator];
        sc.statusIndicator = statusIndicator;
        [sc updateStatusIndicator];
        
        
        NSTextField *name = [[NSTextField alloc] initWithFrame:NSMakeRect(40, listOffsetPixels, 120, 30)];
        [name setStringValue:sc.service.name];
        [name setBezeled:NO];
        [name setDrawsBackground:NO];
        [name setEditable:NO];
        [name setSelectable:NO];
        name.font = [OpenSansFont getFontWithSize:16];
        [serviceList addSubview:name];
        
        NSButton *startStop = [[NSButton alloc] initWithFrame:NSMakeRect(190, listOffsetPixels, 50, 30)];
        [startStop setBezelStyle:NSTexturedRoundedBezelStyle];
        [startStop setTarget:sc];
        [startStop setAction:@selector(handleStartStopClick:)];
        sc.startStop = startStop;
        [sc updateStartStopStatus];
        [serviceList addSubview:startStop];
    
        NSButton *sudo = [[NSButton alloc] initWithFrame:NSMakeRect(260, listOffsetPixels - 1, 80, 30)];
        [sudo setButtonType:NSSwitchButton];
        [sudo setTitle:@"As Root"];
        [sudo setTarget:sc];
        [sudo setAction:@selector(handleSudoClick:)];
        if (sc.service.useSudo) {
            [sudo setState:NSOnState];
        }
        [serviceList addSubview:sudo];
        
//        NSButton *runAtLogin = [[NSButton alloc] initWithFrame:NSMakeRect(330, listOffsetPixels - 1, 80, 30)];
//        [runAtLogin setButtonType:NSSwitchButton];
//        [runAtLogin setTitle:@"At Login"];
//        [runAtLogin setTarget:sc];
//        [runAtLogin setAction:@selector(handleRunAtLoginClick:)];
//        [serviceList addSubview:runAtLogin];
        
        NSButton *remove = [[NSButton alloc] initWithFrame:NSMakeRect(410, listOffsetPixels, 70, 30)];
        [remove setBezelStyle:NSTexturedRoundedBezelStyle];
        [remove setTitle:@"Remove"];
        [remove setTarget:sc];
        [remove setAction:@selector(handleRemoveClick:)];
        [serviceList addSubview:remove];

        
        
        listOffsetPixels += 37;

        HorizontalDivider *horizontalLine = [[HorizontalDivider alloc] initWithFrame:CGRectMake(0 , listOffsetPixels, 480, 1)];
        [serviceList addSubview:horizontalLine];

        listOffsetPixels += 10;

        
    }
    
    [self.serviceParent setDocumentView:serviceList];
    
}



@end
