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
@synthesize preferencesFile;
@synthesize preferences;


-(id) initWithView:(NSScrollView *)sv {

    NSLog(@"Initializing service mananger");
    self = [super init];
    self.serviceControllers = [[NSMutableArray alloc] init];
    self.bundle = [NSBundle bundleForClass:[self class]];
    self.serviceParent = sv;
    self.preferencesFile = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Library/Preferences/com.joshbutts.launchrocket.plist"];
    [self loadPreferences];
    [self loadServices];
    return self;
}

-(void) createPreferencesFile {
    NSFileManager *fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:self.preferencesFile]) {
        NSLog(@"Creating preferences file");
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
        NSString *version =[[[self bundle] infoDictionary] valueForKey:@"PreferenceFileVersion"];
        [prefs setObject:version forKey:@"version"];
        [prefs setObject:[[NSDictionary alloc] init] forKey:@"services"];
        [prefs writeToFile:self.preferencesFile atomically:YES];
    }
}

-(void) writePreferences {
    [self.preferences writeToFile:self.preferencesFile atomically:YES];
    NSLog(@"Wrote preferences file");
}

-(void) loadPreferences {
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    if ([fm fileExistsAtPath:self.preferencesFile]) {
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.preferencesFile];
        NSString *version = [[[self bundle] infoDictionary] valueForKey:@"PreferenceFileVersion"];
        if (![version isEqualToString:[prefs objectForKey:@"version"]]) {
            [fm removeItemAtPath:self.preferencesFile error:nil];
            NSLog(@"Killing preferences file, versions did not match");
            [self createPreferencesFile];
            [self loadPreferences];
        } else {
            self.preferences = prefs;
        }
    } else {
        [self createPreferencesFile];
        [self loadPreferences];
    }
}

-(void) cleanServices {

    NSLog(@"Removing non-existent services from preferences");
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSMutableArray *servicesToRemove = [[NSMutableArray alloc] init];
    for (NSString *key in [self.preferences objectForKey:@"services"]) {
        NSDictionary *data = [[self.preferences objectForKey:@"services"] objectForKey:key];
        if (![fm fileExistsAtPath:[data objectForKey:@"plist"]]) {
            [servicesToRemove addObject:key];
        }
    }
    for (NSString *key in servicesToRemove) {
        [[self.preferences objectForKey:@"services"] removeObjectForKey:key];
    }
    [self writePreferences];
}

-(IBAction) handleHomebrewScanClick:(id)sender {
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSString *homebrewPrefix = nil;
    if ([fm fileExistsAtPath:@"/usr/local/bin/brew"]) {
        NSLog(@"Found 'brew' at /usr/local/bin/brew, assuming that's the homebrew prefix");
        homebrewPrefix = @"/usr/local";
    }
    
    if (homebrewPrefix == nil) {
        homebrewPrefix = [self.preferences objectForKey:@"homebrewPrefix"];        
    }

    
    if (homebrewPrefix == nil) {
        NSLog(@"Prompting user to select homebrew prefix");
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"You appear to have a non-standard Hombrew installation. Please browse to your homebrew prefix. (brew --prefix)"];
        NSInteger response = [alert runModal];
        
        if (response == 1001) { //@TODO: find a better way to do this
            return;
        }
        
        NSLog(@"Waiting for path selection");
        NSOpenPanel *brewPicker = [NSOpenPanel openPanel];
        [brewPicker setCanChooseDirectories:YES];
        [brewPicker setCanChooseFiles:NO];
        [brewPicker setAllowsMultipleSelection:NO];
        [brewPicker setDirectoryURL:[NSURL URLWithString:@"/usr"]];
        
        NSInteger clicked = [brewPicker runModal];
        if (clicked == NSFileHandlingPanelOKButton) {
            NSString *selectedHomebrewPrefix = [[brewPicker URL] path];
            NSLog(@"User selected %@", selectedHomebrewPrefix);
            if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/bin/brew", selectedHomebrewPrefix]]) {
                homebrewPrefix = selectedHomebrewPrefix;
                [self.preferences setObject:homebrewPrefix forKey:@"homebrewPrefix"];
                [self writePreferences];
                NSLog(@"Wrote homebrew prefix to preferences");
            }
        }
    }
    
    if (homebrewPrefix == nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"We couldn't find your homebrew prefix at the path you selected"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[self.serviceParent window] completionHandler:nil];
        NSLog(@"Unable to get Hombrew prefix");
        return;

    }
    
    NSLog(@"Scanning homebrew opt/");
    NSString *optPath = [NSString stringWithFormat:@"%@/opt/", homebrewPrefix];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:optPath];
    for (NSString *item in de) {
        NSString *servicePlist = [NSString stringWithFormat:@"%@%@%@%@%@", optPath, item, @"/homebrew.mxcl.", item, @".plist"];
        if ([fm fileExistsAtPath:servicePlist]) {
            [self addService:servicePlist];
        }
    }
    
    NSLog(@"Scanning for special plists");
    NSString *specialPlistPath = [[self bundle] pathForResource:@"special-plists" ofType:@"plist"];
    NSArray *additionalPlists = [NSArray arrayWithContentsOfFile:specialPlistPath];
    for (NSString *plist in additionalPlists) {
        NSString *servicePlist = [NSString stringWithFormat:@"%@%@", optPath, plist];
        if ([fm fileExistsAtPath:servicePlist]) {
            [self addService:servicePlist];
        }
    }
    
    NSLog(@"Scanning for homebrew etc/launchrocket");
    // scan etc/launchrocket
    NSString *launchrocketPlistsPath = [NSString stringWithFormat:@"%@/etc/launchrocket", homebrewPrefix];
    if ([fm fileExistsAtPath:launchrocketPlistsPath]) {
        de = [fm enumeratorAtPath:launchrocketPlistsPath];
        for (NSString *plist in de) {
            NSString *servicePlist = [NSString stringWithFormat:@"%@/%@", launchrocketPlistsPath, plist];
            if ([fm fileExistsAtPath:servicePlist]) {
                [self addService:servicePlist];
            }
        }
    }
    
    [self cleanServices];
    [self loadServices];
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
        [self cleanServices];
        [self loadServices];
        [self renderList];
    }
    
}

-(void) addService:(NSString *)plistFile {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pathComponents = [plistFile componentsSeparatedByString:@"/"];
    NSArray *filenameComponents = [[pathComponents lastObject] componentsSeparatedByString:@"."];
    NSString *identifier = [[filenameComponents subarrayWithRange:NSMakeRange(0, [filenameComponents count] - 1)] componentsJoinedByString:@"."];
    NSString *serviceName = [[[filenameComponents subarrayWithRange:NSMakeRange(2, [filenameComponents count] - 3)] componentsJoinedByString:@"."] capitalizedString];
    [dict setObject:plistFile forKey:@"plist"];
    [dict setObject:serviceName forKey:@"name"];
    
    NSMutableDictionary *current = [[[self.preferences objectForKey:@"services"] objectForKey:identifier] mutableCopy];
    if (current == nil) {
        NSLog(@"Adding %@", plistFile);
        [[self.preferences objectForKey:@"services"] setObject:dict forKey:identifier];
    } else {
        [current addEntriesFromDictionary: dict];
        [[self.preferences objectForKey:@"services"] setObject:current.copy forKey:identifier];
        NSLog(@"%@ already exists -- updating", plistFile);
    }
    [self writePreferences];
}

-(void) saveService:(Service *)service {
    [[self.preferences objectForKey:@"services"] setObject:[service getPlistData] forKey:service.identifier];
    [self writePreferences];
}

-(void) removeService:(Service *)service {
    [[self.preferences objectForKey:@"services"] removeObjectForKey:service.identifier];
    [self writePreferences];
    [self loadServices];
    [self renderList];
}


-(void) loadServices {
    NSLog(@"Attempting to load services from plist");
    [self.serviceControllers release];
    self.serviceControllers = [[NSMutableArray alloc] init];
    NSDictionary *plistData = [self.preferences objectForKey:@"services"];
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSMutableArray *staleServices = [[NSMutableArray alloc] init];
    for (NSString *key in plistData) {
        NSMutableDictionary *serviceData = [plistData objectForKey:key];
        Service *service = [[Service alloc] initWithOptions:serviceData];
        
        if (![fm fileExistsAtPath:service.plist]) {
            NSLog(@"%@%@", service.plist, @" was not found. Will be removed from list.");
            service.identifier = key;
            [staleServices addObject:service];
            continue;
        }
        
        ServiceController *sc = [[ServiceController alloc] initWithService:service];
        sc.serviceManager = self;
        sc.service = service;
        [self.serviceControllers addObject:sc];
    }
    NSLog(@"Successfully loaded services from plist");
    
    for (Service *s in staleServices) {
        [self removeService:s];
    }

}


-(void) renderList {
    int serviceListHeight = (int) (50 * [self.serviceControllers count]);
    FlippedView *serviceList = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, 500, serviceListHeight)];
    
    int listOffsetPixels = 0;
    for (ServiceController *sc in self.serviceControllers) {
        
        NSImageView *statusIndicator = [[NSImageView alloc] initWithFrame:NSMakeRect(0, listOffsetPixels, 30, 30)];
        [statusIndicator setImageScaling:NSImageScaleAxesIndependently];
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
        
        NSButton *runAtLogin = [[NSButton alloc] initWithFrame:NSMakeRect(330, listOffsetPixels - 1, 80, 30)];
        [runAtLogin setButtonType:NSSwitchButton];
        [runAtLogin setTitle:@"At Login"];
        [runAtLogin setTarget:sc];
        [runAtLogin setAction:@selector(handleRunAtLoginClick:)];
        if (sc.service.runAtLogin) {
            [runAtLogin setState:NSOnState];
        }
        [serviceList addSubview:runAtLogin];
        
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
