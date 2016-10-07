//
//  COLORUserProfile.h
//  COLORAdFramework
//
//  Created by Jordan Jasinski on 26/02/16.
//  Copyright © 2016 Replay inc. All rights reserved.
//

@import Foundation;
@import JavaScriptCore;

@protocol COLORUserProfileJavaScript <JSExport>

+(instancetype)sharedProfile;
-(void)reset;
-(void)setAge:(NSUInteger)age;
-(void)setGender:(NSString*)gender;
-(void)addKeyword:(NSString*)keyword;
-(void)removeKeyword:(NSString*)keyword;

@end

@interface COLORUserProfile : NSObject<COLORUserProfileJavaScript>

@property (nonatomic, strong, readonly) NSDictionary *profileDictionary;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, assign) NSString *gender;
@property (nonatomic, strong, readonly) NSArray *keywords;

@end
