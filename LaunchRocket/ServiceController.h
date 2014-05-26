//
//  ServiceController.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"
#import "ServiceManager.h"

@interface ServiceController : NSObject

@property (strong) Service *service;
@property (strong) NSFileManager *fm;
@property (strong) NSImageView *statusIndicator;
@property (strong) NSButton *startStop;
@property (strong) NSButton *useSudo;
@property (strong) NSButton *runAtLogin;
@property (strong) ServiceManager *serviceManager;

@property int status;

-(id) initWithService:(Service *) theService;
-(BOOL) isStarted;
-(void) start;
-(void) stop;
-(void) updateStatusIndicator;
-(void) handleStartStopClick:(id)sender;
-(void) handleSudoClick:(id)sender;
-(void) updateStartStopStatus;
-(void) handleRunAtLoginClick:(id)sender;
-(void) handleRemoveClick:(id)sender;


@end
