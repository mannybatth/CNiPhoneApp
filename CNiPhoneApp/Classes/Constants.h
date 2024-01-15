//
//  Constants.h
//  CNApp
//
//  Created by Manpreet Singh on 7/8/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#ifndef CNApp_Constants_h
#define CNApp_Constants_h

//#define TESTING_CNAPP

#ifdef TESTING_CNAPP
#define BASE_URL @"http://cndev.coursenetworking.com"
#else
#define BASE_URL @"https://www.thecn.com"
#endif

#define CN_APP_STORE_ID 531484941
#define ADOBE_CONNECT_APP_STORE_ID 430437503

#define UPLOAD_PICTURE_MAX_WIDTH 1024
#define UPLOAD_PICTURE_MAX_HEIGHT 768

#define DEFAULT_AVATAR_IMG @"default_profile"

#define NOTF_REFRESH_HOME_FEED @"RefreshHomeFeed"
#define NOTF_REFRESH_LEFT_BAR @"RefreshLeftSideBar"
#define NOTF_POST_VIEW_CHANGED @"PostViewChanged"

#define ACTION_INSERT_VIEW @"InsertViewAction"
#define ACTION_UPDATE_VIEW @"UpdateViewAction"
#define ACTION_DELETE_VIEW @"DeleteViewAction"

#define STATUS_BAR_HEIGHT   [UIApplication sharedApplication].statusBarFrame.size.height
#define USER_DEFAULT        [NSUserDefaults standardUserDefaults]
#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#endif
