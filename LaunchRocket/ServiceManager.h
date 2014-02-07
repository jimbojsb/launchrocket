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

@property (retain) NSMutableArray *serviceControllers;
@property (retain) NSBundle *bundle;
@property (retain) NSScrollView* serviceParent;
@property (retain) NSString *servicesFilePath;

-(id) initWithView:(NSScrollView *)sv;
-(void) createServicesFile;
-(void) cleanServicesFile;
-(void) renderList;
-(void) loadServicesFromPlist;
-(void) addService: (NSString *)plistFile;
-(void) removeService: (Service *)service;
-(void) saveService: (Service *)service;
-(IBAction) handleHomebrewScanClick:(id) sender;
-(IBAction) handleAddPlistClick:(id)sender;

@end
