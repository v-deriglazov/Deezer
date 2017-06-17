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


static NSString *const kCellID = @"cellID";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
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
    [self.tableView.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -CGRectGetHeight(self.tableView.refreshControl.bounds)) animated:YES];
}

- (void)userDidRefresh:(NSNotification *)notification
{
    NSParameterAssert(self.user == notification.object);
    [self.tableView reloadData];
    [self.tableView.refreshControl endRefreshing];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    NSString *text = nil;
    if (indexPath.section == 0)
    {
        text = [self.user debugDescription];
    }
    else
    {
        text = [[[self.user.playlists allObjects] objectAtIndex:indexPath.row] debugDescription];
    }
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self refreshData];
}

@end
