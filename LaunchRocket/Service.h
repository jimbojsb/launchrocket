//
//  Service.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/26/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject

@property (assign) NSString* plist;
@property (assign) NSString* name;
@property (assign) NSImage* image;

- (id) initWithOptions:(NSDictionary*) options;


@end
