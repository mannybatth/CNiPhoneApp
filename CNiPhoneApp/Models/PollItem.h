//
//  PollItem.h
//  CNApp
//
//  Created by Manpreet Singh on 9/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "PollChoice.h"
#import "Picture.h"
#import "Link.h"
#import "Video.h"
#import "Attachment.h"

static NSString* const POLL_TYPE_SHORT_ANSWER = @"short_answer";
static NSString* const POLL_TYPE_MULTIPLE_CHOICE = @"multiple_choice";
static NSString* const POLL_TYPE_ONE_CHOICE = @"one_choice";
static NSString* const POLL_TYPE_TRUE_FALSE = @"true_false";
static NSString* const POLL_TYPE_YES_NO = @"yes_no";
static NSString* const POLL_TYPE_AGREE_DISAGREE = @"agree_disagree";
static NSString* const POLL_TYPE_AGREE_NOOPINION_DISAGREE = @"agree_noopinion_disagree";
static NSString* const POLL_TYPE_STRONGLYAGREE_AGREE_NOOPINION_DISAGREE_STRONGLYDISAGREE = @"stronglyagree_agree_noopinion_disagree_stronglydisagree";
static NSString* const POLL_TYPE_SCALE_5 = @"scale_5";
static NSString* const POLL_TYPE_SCALE_10 = @"scale_10";

@interface PollItem : NSObject

@property (nonatomic, strong) NSString *rawText;
@property (nonatomic, strong) NSString *shortRawText;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *pollType;
@property (nonatomic, strong) NSString *correctResponseText;
@property (nonatomic) int questionCount;
@property (nonatomic) int questionOrder;
@property (nonatomic) int submissionCount;
@property (nonatomic) BOOL hasSubmissionsCount;
@property (nonatomic) BOOL isDisplayResult;
@property (nonatomic) BOOL isDisplayUser;
@property (nonatomic) BOOL isEnable;
@property (nonatomic) BOOL isEnd;
@property (nonatomic) BOOL isOwner;
@property (nonatomic) BOOL isPictures;
@property (nonatomic) BOOL isShortAnswerType;
@property (nonatomic) BOOL isUserSubmit;
@property (nonatomic, strong) NSString *resultMessage;

@property (nonatomic, strong) NSArray *choices;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *chartOptions;
@property (nonatomic, strong) NSArray *submissions;

@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSArray *pictures;
@property (nonatomic, strong) NSArray *videos;

+ (PollItem *)itemFromJSON:(NSDictionary *)dict;
+ (NSArray *)itemsFromJSONArray:(NSArray *)arr;

@end
