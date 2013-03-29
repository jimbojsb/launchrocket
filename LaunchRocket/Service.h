//
//  Service.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/26/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject

@property (retain) NSString* plist;
@property (retain) NSString* name;
@property (retain) NSImage* image;
@property (retain) NSString* identifier;

- (id) initWithOptions:(NSDictionary*) options;


@end
