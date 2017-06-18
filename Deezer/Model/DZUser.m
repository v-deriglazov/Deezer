//
//  DZUser.m
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import "DZUser.h"
#import "DZPlaylist.h"
#import "DZRequestManager.h"

static NSString *const kUserIDKey = @"id";
static NSString *const kNameKey = @"name";
static NSString *const kPictureKey = @"picture";
static NSString *const kCountryKey = @"country";

NSString *const kUserWillRefreshNotification = @"UserWillRefreshNotification";
NSString *const kUserDidRefreshNotification = @"UserDidRefreshNotification";


typedef enum : NSUInteger {
    DZUserRefreshStageNone          = 0,
    DZUserRefreshStageBegin         = 1,
    DZUserRefreshStageProfile       = 1<<1,
    DZUserRefreshStagePlaylists     = 1<<2,
} DZUserRefreshStage;


@interface DZUser ()
@property (nonatomic, strong) NSSet<DZPlaylist *> *playlists;
@property (nonatomic, strong) NSSet<DZPlaylist *> *fetchedPlaylists;
@property (nonatomic) DZUserRefreshStage refreshStage;
@end


@implementation DZUser

+ (instancetype)user
{
    static DZUser *sUser = nil;
    if (sUser == nil)
    {
        sUser = [DZUser new];
        sUser.userID = 2529;
    }
    return sUser;
}

- (NSSet<DZPlaylist *> *)playlists
{
    if (_playlists == nil)
        _playlists = [NSSet new];
    return _playlists;
}

- (void)setRefreshStage:(DZUserRefreshStage)refreshStage
{
    if (refreshStage == (DZUserRefreshStageBegin|DZUserRefreshStageProfile|DZUserRefreshStagePlaylists))
        refreshStage = DZUserRefreshStageNone;
    
    if (_refreshStage != refreshStage)
    {
        if (_refreshStage == DZUserRefreshStageNone)
        {
            self.refreshError = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserWillRefreshNotification object:self];
        }
        _refreshStage = refreshStage;
        if (_refreshStage == DZUserRefreshStageNone)
        {
            self.playlists = self.fetchedPlaylists;
            self.fetchedPlaylists = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidRefreshNotification object:self];
        }
    }
}

#pragma mark -

- (BOOL)isRefreshing
{
    return (self.refreshStage != DZUserRefreshStageNone);
}

- (void)refreshData
{
    if (self.isRefreshing)
    {
        return;
    }
    
    self.refreshStage = DZUserRefreshStageBegin;
    __weak typeof(self) weakSelf = self;
    [DZRequestManager refreshUserWithID:self.userID completion:^(BOOL result, NSDictionary *data)
    {
        if (result)
        {
            result = [weakSelf parseProfileData:data];
        }
        else
        {
            weakSelf.refreshError = [NSError errorWithDomain:NSURLErrorDomain code:500 userInfo:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.refreshStage |= DZUserRefreshStageProfile;
        });
    }];
    
    [DZRequestManager refreshPlaylistsForUserWithID:self.userID completion:^(BOOL result, NSArray<NSDictionary *> *data)
    {
        if (result)
        {
            [weakSelf parsePlaylistData:data];
        }
        else
        {
            weakSelf.refreshError = [NSError errorWithDomain:NSURLErrorDomain code:501 userInfo:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.refreshStage |= DZUserRefreshStagePlaylists;
        });
    }];
}

#pragma mark - Parse

- (BOOL)parseProfileData:(NSDictionary *)data
{
    if ([data[kUserIDKey] longLongValue] != self.userID)
    {
        self.refreshError = [NSError errorWithDomain:NSURLErrorDomain code:502 userInfo:nil];
        return NO;
    }
    
    self.name = data[kNameKey];
    self.photo = data[kPictureKey];
    self.country = data[kCountryKey];
    return YES;
}

- (void)parsePlaylistData:(NSArray<NSDictionary *> *)data
{
    NSSet<DZPlaylist *> *list = [DZPlaylist parseData:data];
    self.fetchedPlaylists = list;
}

#pragma mark -

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"id %llu, name %@ country %@. playlists count %lu", self.userID, self.name, self.country, self.playlists.count];
}

@end
