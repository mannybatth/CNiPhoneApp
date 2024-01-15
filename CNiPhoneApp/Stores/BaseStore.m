//
//  BaseStore.m
//  CNApp
//
//  Created by Manpreet Singh on 6/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "BaseStore.h"

@implementation BaseStore

+ (NSOperation *)api:(NSString *)query completionBlock:(void (^)(id, NSString *))block
{
    return [self api:query parameters:nil completionBlock:block];
}

+ (NSOperation*)api:(NSString *)query parameters:(NSDictionary*)params completionBlock:(void (^)(id response, NSString *err))block
{
    return [self api:query header:nil parameters:params completionBlock:block];
}

+ (NSOperation*)api:(NSString *)query header:(NSDictionary*)header parameters:(NSDictionary*)params completionBlock:(void (^)(id response, NSString *err))block
{
    NSString *method;
    if (params) method = @"POST";
    else method = @"GET";
    return [self api:query header:header parameters:params method:method completionBlock:block];
}

+ (NSOperation*)api:(NSString *)query header:(NSDictionary*)header parameters:(NSDictionary*)params method:(NSString*)method completionBlock:(void (^)(id response, NSString *err))block
{
    NSString *path = [NSString stringWithFormat:@"/api%@", query];
    
    NSLog(@"api call: %@ %@ \n\n", method, path);
    
    CNHTTPClient *httpClient = [CNHTTPClient sharedClient];
    
    NSMutableURLRequest *request = [httpClient.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:path relativeToURL:httpClient.baseURL] absoluteString] parameters:params error:nil];
    
    [request setValue:[Session shared].currentToken forHTTPHeaderField:@"token"];
    for(id headerKey in header) {
        [request setValue:[header objectForKey:headerKey] forHTTPHeaderField:headerKey];
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[[AFJSONResponseSerializer alloc] init]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSString *errorString;
        if ([[JSON objectForKey:@"errors"] count] > 0) {
            NSData *errorData = [NSJSONSerialization dataWithJSONObject:[JSON objectForKey:@"errors"]
                                                                options:0
                                                                  error:nil];
            
            errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        }
        
        if (!errorString) {
            block(JSON, nil);
        } else {
            block(JSON, errorString);
            [BaseStore showErrorAlertWithTitle:@"Sorry, there was a problem" message:errorString];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@ %li %li \n\n %@", request.URL.absoluteString, (long)[operation.response statusCode], (long)[error code], error.description);
        [httpClient.operationQueue cancelAllOperations];
        block(operation.responseString, error.localizedDescription);
        if (!([operation.response statusCode] == 401 || [operation.response statusCode] == 403 || [error code] == NSURLErrorTimedOut || [error code] == NSURLErrorCancelled || [error code] == NSURLErrorCannotFindHost)) {
            [BaseStore showErrorAlertWithTitle:@"Failed to make request" message:error.localizedDescription];
        }
        
    }];
    
    [httpClient.operationQueue addOperation:operation];
    return operation;
    
}

+ (NSOperation*)uploadPhoto:(NSData *)imgData block:(void (^)(NSDictionary *response, NSString *error))block
{
    CNHTTPClient *httpClient = [CNHTTPClient sharedClient];
    
    [httpClient.requestSerializer setAuthorizationHeaderFieldWithToken:[Session shared].currentToken];
    
    NSString *path = [NSString stringWithFormat:@"/api/attachment_picture/?TOKEN=%@", [Session shared].currentToken];
    NSMutableURLRequest *request = [httpClient.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:httpClient.baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imgData name:@"upload_file" fileName:@"temp.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[[AFJSONResponseSerializer alloc] init]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSString *errorString;
        if ([[JSON objectForKey:@"errors"] count] > 0) {
            NSData *errorData = [NSJSONSerialization dataWithJSONObject:[JSON objectForKey:@"errors"]
                                                                options:0
                                                                  error:nil];
            
            errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        }
        
        if (!errorString) {
            block(JSON, nil);
        } else {
            block(JSON, errorString);
            [BaseStore showErrorAlertWithTitle:@"Sorry, there was a problem" message:errorString];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [httpClient.operationQueue cancelAllOperations];
        block(nil, error.localizedDescription);
        if (!([operation.response statusCode] == 401 || [operation.response statusCode] == 403)) {
            [BaseStore showErrorAlertWithTitle:@"Upload Failed" message:error.localizedDescription];
        }
        
    }];
    
    [httpClient.operationQueue addOperation:operation];
    return operation;
}

+ (void)showErrorAlertWithTitle:(NSString*)title message:(NSString*)message
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//    [alert show];
}

@end
