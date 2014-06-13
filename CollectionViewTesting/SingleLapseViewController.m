//
//  SingleLapseViewController.m
//  CollectionViewTesting
//
//  Created by Zaccary Price on 13/06/14.
//  Copyright (c) 2014 Zaccary Price. All rights reserved.
//

#import "SingleLapseViewController.h"

@interface SingleLapseViewController ()

@end

@implementation SingleLapseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UILabel *timeago        = (UILabel *)[self.view viewWithTag:100];
    UILabel *username       = (UILabel *)[self.view viewWithTag:200];
    UILabel *title          = (UILabel *)[self.view viewWithTag:300];
    UIImageView *avatar     = (UIImageView *)[self.view viewWithTag:400];
    UIImageView *lapse      = (UIImageView *)[self.view viewWithTag:500];
    
    // give some hipsteresque looking rounded-avatar shit
    avatar.layer.cornerRadius = 22.0f;
    avatar.clipsToBounds = YES;
    
    timeago.text = [self.currentLapse objectForKey:@"timeago"];
    username.text = [self.currentLapse objectForKey:@"user_name"];
    title.text = [self.currentLapse objectForKey:@"lapse_title"];
    avatar.image = [self.currentLapse objectForKey:@"user_avatar"];
    lapse.image = [self.currentLapse objectForKey:@"lapse_image"];
    
    
                    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
