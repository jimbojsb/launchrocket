//
//  ServicePane.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/26/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceManager.h"

@interface ServicePane : NSObject

@property (retain) ServiceManager* serviceManager;
@property (retain) NSScrollView* view;

-(id) initWithServiceManager:(ServiceManager *) sm andView:(NSScrollView *) scrollView;
-(void) renderList;

@end
