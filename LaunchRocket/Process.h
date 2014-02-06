//
//  Process.h
//  LaunchRocket
//
//  Created by Josh Butts on 1/24/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Process : NSObject

@property (strong) NSString *command;
@property (strong) NSArray *args;


-(id) initWithCommand:(NSString *)command andArguments:(NSArray *)args;
-(NSString *) execute;
-(NSString *) executeSudo;

@end
