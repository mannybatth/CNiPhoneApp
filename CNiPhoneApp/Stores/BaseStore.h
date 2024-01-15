//
//  BaseStore.h
//  CNApp
//
//  Created by Manpreet Singh on 6/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#define DEFAULT_CACHE_INTERVAL 60*60*24

#import "BaseStore.h"
#import "AFNetworking.h"
#import "CNHTTPClient.h"
#import "EGOCache.h"
#import "EGOCache+NSArray.h"
#import "Session.h"

@interface BaseStore : NSObject

+ (NSOperation*)api:(NSString *)query completionBlock:(void (^)(id response, NSString *err))block;
+ (NSOperation*)api:(NSString *)query parameters:(NSDictionary*)params completionBlock:(void (^)(id response, NSString *err))block;
+ (NSOperation*)api:(NSString *)query header:(NSDictionary*)header parameters:(NSDictionary*)params completionBlock:(void (^)(id response, NSString *err))block;
+ (NSOperation*)api:(NSString *)query header:(NSDictionary*)header parameters:(NSDictionary*)params method:(NSString*)method completionBlock:(void (^)(id response, NSString *err))block;
+ (NSOperation*)uploadPhoto:(NSData *)imgData block:(void (^)(NSDictionary *response, NSString *error))block;
+ (void)showErrorAlertWithTitle:(NSString*)title message:(NSString*)message;

@end
