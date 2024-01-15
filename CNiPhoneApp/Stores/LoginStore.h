//
//  LoginStore.h
//  CNiPhoneApp
//
//  Created by Manny on 2/18/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "BaseStore.h"

@interface LoginStore : BaseStore

+ (void)login:(NSString*)username password:(NSString*)password block:(void (^)(NSString *token, NSString *error))block;

@end
