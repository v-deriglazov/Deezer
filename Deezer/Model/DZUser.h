//
//  DZUser.h
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DZPlaylist;

extern NSString *const kUserWillRefreshNotification;
extern NSString *const kUserDidRefreshNotification;

@interface DZUser : NSObject

@property (nonatomic) uint64_t userID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong, readonly) NSSet<DZPlaylist *> *playlists;

+ (instancetype)user;

@property (nonatomic, strong) NSError *refreshError;
- (BOOL)isRefreshing;
- (void)refreshData;

@end
