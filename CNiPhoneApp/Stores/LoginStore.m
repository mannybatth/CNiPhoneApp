//
//  LoginStore.m
//  CNiPhoneApp
//
//  Created by Manny on 2/18/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "LoginStore.h"

@implementation LoginStore

+ (void)login:(NSString *)username password:(NSString *)password block:(void (^)(NSString *, NSString *))block
{
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            username, @"username",
                            password, @"password", nil];
    
    [BaseStore api:@"/auth?action=login" header:header parameters:nil completionBlock:^(id response, NSString *error) {
        if (!error) {
            NSString *token = [[response objectForKey:@"data"] objectForKey:@"token"];
            block(token, nil);
        } else {
            block(response, error);
        }
    }];
}

@end
