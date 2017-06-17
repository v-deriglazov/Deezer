//
//  ViewController.m
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import "ViewController.h"

#import "DZUser.h"
#import "DZPlaylist.h"

#import "DZProfileTableViewCell.h"
#import "DZPlaylistTableViewCell.h"


static NSString *const kProfileCellID = @"profileCell";
static NSString *const kPlaylistCellID = @"playlistCell";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    UIRefreshControl *control = [UIRefreshControl new];
    [control addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = control;
}

- (void)refreshData
{
    [self.user refreshData];
}

- (void)setUser:(DZUser *)user
{
    if (_user != user)
    {
        if (_user != nil)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserWillRefreshNotification object:_user];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserDidRefreshNotification object:_user];
        }
        
        _user = user;
        
        if (_user != nil)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWillRefresh:) name:kUserWillRefreshNotification object:_user];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRefresh:) name:kUserDidRefreshNotification object:_user];
        }
        if (self.isViewLoaded)
            [self refreshData];
    }
}

- (void)userWillRefresh:(NSNotification *)notification
{
    NSParameterAssert(self.user == notification.object);
    [self.tableView.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -CGRectGetHeight(self.tableView.refreshControl.bounds)) animated:YES];
}

- (void)userDidRefresh:(NSNotification *)notification
{
    NSParameterAssert(self.user == notification.object);
    [self.tableView.refreshControl endRefreshing];
    [self.tableView reloadData];
    
    NSError *err = self.user.refreshError;
    if (err != nil)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:err.description preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:NULL];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? NSLocalizedString(@"Personal Info", nil) : NSLocalizedString(@"Playlists", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : self.user.playlists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *result = nil;
    NSString *text = nil;
    if (indexPath.section == 0)
    {
        DZProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileCellID];
        text = [self.user debugDescription];
        cell.text = text;
        result = cell;
    }
    else
    {
        DZPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlaylistCellID];
        text = [[[self.user.playlists allObjects] objectAtIndex:indexPath.row] debugDescription];
        cell.text = text;
        result = cell;
    }
    return result;
}

@end
