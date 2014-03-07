//
//  ServiceManager.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

@interface ServiceManager : NSObject

@property (strong) NSMutableArray *serviceControllers;
@property (strong) NSBundle *bundle;
@property (strong) NSScrollView* serviceParent;
@property (strong) NSString *preferencesFile;
@property (strong) NSMutableDictionary *preferences;

-(id) initWithView:(NSScrollView *)sv;
-(void) createPreferencesFile;
-(void) cleanServices;
-(void) renderList;
-(void) loadServices;
-(void) addService: (NSString *)plistFile;
-(void) removeService: (Service *)service;
-(void) saveService: (Service *)service;
-(void) writePreferences;
-(void) loadPreferences;


-(IBAction) handleHomebrewScanClick:(id) sender;
-(IBAction) handleAddPlistClick:(id)sender;


@end
