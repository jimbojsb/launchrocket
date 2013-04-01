//
//  ServiceManager.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceManager : NSObject

@property (retain) NSMutableDictionary *serviceControllers;
@property (retain) NSMutableArray *services;
@property (retain) NSBundle *bundle;
@property (retain) NSScrollView* serviceParent;
@property (retain) NSString *servicesFilePath;

-(id) initWithBundle: (NSBundle *)b andView:(NSScrollView *)sv;
-(void) handleOnOffClick:(id) sender;
-(void) handleStartAtLoginClick:(id) sender;
-(void) createServicesFile;
-(void) renderList;
-(void) loadServicesFromPlist;
-(void) addService: (NSString *)plistFile imageFile:(NSString *)imageFile;
-(IBAction) handleHomebrewScanClick:(id) sender;

@end
