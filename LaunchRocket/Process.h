//
//  Process.h
//  LaunchRocket
//
//  Created by Josh Butts on 1/24/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Process : NSObject

@property AuthorizationRef authref;


-(NSString *) execute:(NSString *)command withArugments:(NSArray *)args;
-(NSString *) executeSudo:(NSString *)command withArugments:(NSArray *)args;;
-(void) getAuthRef;

@end
