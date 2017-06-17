//
//  DZRequestManager.h
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DZRequestManager : NSObject

+ (void)refreshUserWithID:(uint64_t)userID completion:(void(^)(BOOL result, NSDictionary *data))completion;
+ (void)refreshPlaylistsForUserWithID:(uint64_t)userID completion:(void(^)(BOOL result, NSArray<NSDictionary *> *data))completion;

@end
