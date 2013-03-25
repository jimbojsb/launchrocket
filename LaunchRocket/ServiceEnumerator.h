//
//  ServiceEnumerator.h
//  BrewPub
//
//  Created by Josh Butts on 3/17/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceEnumerator : NSObject

+ (NSMutableArray *) enumerateWithBundle: (NSBundle *) bundle;
+ (void) createServicesDirectory;

@end
