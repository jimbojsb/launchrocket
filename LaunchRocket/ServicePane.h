//
//  ServicePane.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/26/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServicePane : NSObject

@property (assign) NSMutableArray* services;
@property (assign) NSScrollView* view;

-(id) initWithServices:(NSMutableArray *) servicesList andView:(NSScrollView *) scrollView;
-(void) renderList;

@end
