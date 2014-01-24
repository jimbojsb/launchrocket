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

@property (retain) Service *service;
@property (retain) NSFileManager *fm;
@property (strong) NSImageView *statusIndicator;
@property (strong) NSSegmentedControl *onOff;
@property (strong) NSButton *sudo;
@property int status;

-(id) initWithService:(Service *) theService;
-(BOOL) isStarted;
-(void) start;
-(void) stop;
-(void) updateStatusIndicator;
-(void) handleOnOffClick:(id)sender;
-(void) handleSudoClick:(id)sender;
-(void) updateOnOffStatus;

@end
