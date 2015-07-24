//
//  Service.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/26/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "Service.h"

@implementation Service

@synthesize plist;
@synthesize identifier;
@synthesize name;
@synthesize useSudo;
@synthesize runAtLogin;

- (id) initWithOptions:(NSDictionary *)options {
    self = [super init];
    self.plist = [options objectForKey:@"plist"];
      
    NSDictionary *plistData = [[NSDictionary alloc] initWithContentsOfURL:self.plist];
    self.identifier = [plistData objectForKey:@"Label"];
    self.name = [options objectForKey:@"name"];
    
    NSNumber *shouldUseSudo = [options objectForKey:@"useSudo"];
    if (shouldUseSudo == nil) {
        self.useSudo = NO;
    } else {
        self.useSudo = [shouldUseSudo boolValue];
    }
    
    NSNumber *shouldRunAtLogin = [options objectForKey:@"runAtLogin"];
    if (shouldRunAtLogin == nil) {
        self.runAtLogin = NO;
    } else {
        self.runAtLogin = [shouldRunAtLogin boolValue];
    }

    NSLog(@"%@", self.plist);
    
    return self;    
}

-(NSMutableDictionary *) getPlistData {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:self.name forKey:@"name"];
    [data setObject:self.plist forKey:@"plist"];
    [data setObject:[NSNumber numberWithBool:self.useSudo] forKey:@"useSudo"];
    [data setObject:[NSNumber numberWithBool:self.runAtLogin] forKey:@"runAtLogin"];
    return data;
}


- (NSString *)pathForService {
    
    NSString *plistFile = [NSString stringWithFormat:@"/tmp/%@.plist", self.identifier];
    if (self.runAtLogin) {
        if (self.useSudo) {
            plistFile = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@.plist", self.identifier];
        } else {
            plistFile = [NSString stringWithFormat:@"%@/Library/LaunchAgents/%@.plist", NSHomeDirectory(), self.identifier];
        }
        plistFile =[NSString stringWithFormat:@"/Library/LaunchDaemons/%@.plist", self.identifier];
    }
    
    NSLog(@"Path for service: %@", plistFile);
    return plistFile;
}

@end
