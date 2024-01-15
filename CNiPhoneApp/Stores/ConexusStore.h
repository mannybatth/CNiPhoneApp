//
//  ConexusStore.h
//  CNApp
//
//  Created by Manpreet Singh on 7/2/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "BaseStore.h"
#import "Conexus.h"

@interface ConexusStore : BaseStore

+ (void)getAllUserConexus:(void (^)(NSArray *conexus, NSString *error))block;
+ (void)getAllUserConexus:(void (^)(NSArray *conexus, NSString *error))block allowCache:(BOOL)allowCache;

+ (void)getConexusDetails:(NSString*)conexusId block:(void (^)(Conexus *conexus, NSString *error))block;
+ (void)getConexusPosts:(NSString *)conexusId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block;
+ (void)getConexusMembers:(NSString*)conexusId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block;

@end
