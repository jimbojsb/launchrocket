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

-(id) init;
-(void) handleOnOffClick:(id) sender;
-(void) handleStartAtLoginClick:(id) sender;

@end
