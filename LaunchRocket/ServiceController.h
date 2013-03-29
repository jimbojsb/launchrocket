//
//  ServiceController.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

@interface ServiceController : NSObject

@property (assign) Service *service;
@property (assign) NSString *plistPath;
@property (assign) NSString *launchAgentPath;
@property (assign) NSFileManager *fm;

-(id) initWithService:(Service *) theService;
-(BOOL) isStarted;
-(BOOL) shouldStartAtLogin;
-(void) start;
-(void) stop;
-(void) startAtLogin:(BOOL) shouldStartAtLogin;

@end
