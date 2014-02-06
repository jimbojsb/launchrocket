//
//  LaunchRocket.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/24/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "LaunchRocket.h"
#import "ServiceManager.h"
#import "OpenSansFont.h"
#import <Security/Security.h>
#import <ServiceManagement/ServiceManagement.h>


@implementation LaunchRocket

@synthesize serviceParent;
@synthesize homebrewScan;
@synthesize launchRocketLabel;
@synthesize versionNumber;
@synthesize addPlist;

- (void)mainViewDidLoad
{
 
    
    NSString* myLabel = @"com.mydomain.myhelper";
    
    AuthorizationItem authItem = { kSMRightModifySystemDaemons, 0, NULL, 0 };
    AuthorizationRights authRights = { 1, &authItem };
    AuthorizationFlags flags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
    
    AuthorizationRef auth;
    if( AuthorizationCreate( &authRights, kAuthorizationEmptyEnvironment, flags, &auth ) == errAuthorizationSuccess ) {
        (void) SMJobRemove( kSMDomainSystemLaunchd, (CFStringRef)myLabel, auth, false, NULL );
        
        NSMutableDictionary *plist = [NSMutableDictionary dictionary];
        [plist setObject:myLabel forKey:@"Label"];
        [plist setObject:[NSNumber numberWithBool:YES] forKey:@"RunAtLoad"];
        [plist setObject:@[@"/usr/bin/touch", @"/etc/bar"] forKey:@"ProgramArguments"];
        CFErrorRef error;
        if ( SMJobSubmit( kSMDomainSystemLaunchd, (CFDictionaryRef)plist, auth, &error) ) {
            // Script is running
        } else {
            NSLog( @"Authenticated install submit failed with error %@", error );
        }
        if ( error ) {
            CFRelease( error );
        }
        
        (void) SMJobRemove( kSMDomainSystemLaunchd, (CFStringRef)myLabel, auth, false, NULL );
        
        AuthorizationFree( auth, 0 );
    }
    return;
    
    
    
    ServiceManager *sm = [[ServiceManager alloc] initWithView:self.serviceParent];
    [sm cleanServicesFile];
    [self.homebrewScan setTarget:sm];
    [self.homebrewScan setAction:@selector(handleHomebrewScanClick:)];
    [self.addPlist setTarget:sm];
    [self.addPlist setAction:@selector(handleAddPlistClick:)];
    
    self.launchRocketLabel.font = [OpenSansFont getFontWithSize:20];
    self.versionNumber.font = [OpenSansFont getFontWithSize:14];
    [sm renderList];
}

@end
