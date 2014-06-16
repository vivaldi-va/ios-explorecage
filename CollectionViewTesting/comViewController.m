//
//  comViewController.m
//  CollectionViewTesting
//
//  Created by Zaccary Price on 11/06/14.
//  Copyright (c) 2014 Zaccary Price. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "comViewController.h"


typedef void (^ImageCompletionBlock)(UIImage *);
typedef void (^JSONCompletionBlock)(NSMutableArray *);
typedef void (^Callback)();

@interface comViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end

@implementation comViewController {
    NSMutableArray          *array;
    NSInteger               selectedLapseIndex;
    NSMutableDictionary     *lapseDict;
    UIActivityIndicatorView *refreshIndicator;
    NSMutableArray          *userData;
    UIRefreshControl        *refresh;
}





- (void) addActivityIndicatorToContext:(UIView *)context {
    UIActivityIndicatorView *indicator;
    indicator                   = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped  = YES;
    indicator.center            = context.center;
    
    [context addSubview:indicator];
}


-(void)fetchUserDataFromUrl:(NSURL *)url thenFinish:(JSONCompletionBlock)complete {
    NSLog(@"Fetching user data");
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            //[self.delegate fetchingGroupsFailedWithError:error];
        } else {
            //[self.delegate receivedGroupsJSON:data];
            
            NSError *error              = nil;
            userData                    = [[NSMutableArray alloc] init];
            NSDictionary *parsedObject  = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            
            NSArray *result = [parsedObject objectForKey:@"results"];
            
            for (int i = 0; i < [result count]; i++) {
                
                NSDictionary *user  = [result objectAtIndex:i];
                user                = [user objectForKey:@"user"];
                
                [userData addObject:user];
            }
			
			NSLog(@"got some user data");
            
            complete(userData);
            
        }
    }];
    
}


- (void) setupLapseArrayAndContinue:(JSONCompletionBlock)complete {
    array                               = [[NSMutableArray alloc] init];
    
    
    
    NSURL *userInfoUrl = [NSURL URLWithString:@"http://api.randomuser.me/?results=20"];
    
    
    [self fetchUserDataFromUrl:userInfoUrl thenFinish:^(NSMutableArray *data){
        
        // add 5 'lapses' into the array
        for (int i = 0; i < [data count]; i++) {
            lapseDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *user = [data objectAtIndex:i];
            
            [lapseDict setObject:@"99y ago" forKey:@"timeago"];
            [lapseDict setObject:@"http://cageme.herokuapp.com/620/1136" forKey:@"lapse_image"];
            [lapseDict setObject:[user objectForKey:@"picture"] forKey:@"user_avatar"];
            [lapseDict setObject:[user objectForKey:@"username"] forKey:@"user_name"];
            [lapseDict setObject:[user objectForKey:@"password"] forKey:@"lapse_title"];
			[lapseDict setValue:[NSNumber numberWithBool:NO] forKey:@"liked"];
            
            
            [array addObject:lapseDict];
        }
        
        complete(array);
        
    }];

}

- (void)reloadContent {
	NSLog(@"Reload Data");
	
    [self setupLapseArrayAndContinue:^(NSArray *data){
        NSLog(@"Reloading finished");
        [refreshIndicator stopAnimating];
        [refresh endRefreshing];
        [self.collectionView reloadData];
        
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
	refreshIndicator                    = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshIndicator.hidesWhenStopped   = YES;
    refreshIndicator.center             = self.view.center;
	
    [refreshIndicator startAnimating];
    
    [self.view addSubview:refreshIndicator];
	
    refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(reloadContent) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refresh];
    //[self.collectionView]
    [self reloadContent];
    
}





- (void) fetchImageWithURL:(NSURL *)url completionBlock:(ImageCompletionBlock)completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        
        NSData *imageData   = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *image      = [[UIImage alloc] initWithData:imageData];
        
        completionBlock(image);
        
    });
    
}



- (void)resizeImage:(UIImage *)image toWidth:(CGFloat)width completionBlock:(ImageCompletionBlock)completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *thumbImage = nil;
        // make images twice the size of their containers, for retina screen whatever
        CGSize newSize      = CGSizeMake(width, (width / image.size.width) * image.size.height);
        
        
        UIGraphicsBeginImageContext(newSize);
        
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        
        thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        completionBlock(thumbImage);
        
    });
}



-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [array count];
}


-(IBAction)likeLapse:(id)sender {
	UIButton *button = (UIButton *)sender;
	int tag						= [(UIButton *)sender tag];
	NSMutableDictionary *lapse	= [array objectAtIndex:tag];
	UIImage *iconFilledHeart	= [UIImage imageNamed:@"heart-filled.png"];
	UIImage *iconEmptyHeart		= [UIImage imageNamed:@"heart-outline.png"];
	
    NSLog(@"tapped button in cell at row %i", tag);
	NSLog(@"lapse name: %@", [lapse objectForKey:@"lapse_title"]);
	
	if(lapse[@"liked"] == [NSNumber numberWithBool:NO]) {
		[button setImage:iconFilledHeart forState:UIControlStateNormal];
		[lapse setValue:[NSNumber numberWithBool:YES] forKey:@"liked"];
		
	} else {
		[button setImage:iconEmptyHeart forState:UIControlStateNormal];
		[lapse setValue:[NSNumber numberWithBool:NO] forKey:@"liked"];
	}
	NSLog(@"lapse liked?: %@", lapse[@"liked"]);
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *row = [array objectAtIndex:indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExploreCell" forIndexPath:indexPath];
    
    UILabel *timeago        = (UILabel *)[cell viewWithTag:100];
    UILabel *username       = (UILabel *)[cell viewWithTag:200];
    UILabel *title          = (UILabel *)[cell viewWithTag:300];
    UIImageView *avatar     = (UIImageView *)[cell viewWithTag:400];
    UIImageView *lapse      = (UIImageView *)[cell viewWithTag:500];
	UIButton *likeButton	= (UIButton *)[cell viewWithTag:600];
	
    UIImage *iconFilledHeart	= [UIImage imageNamed:@"heart-filled.png"];
	
    // nillify the images to prevent flickering or some bullshit.
    lapse.image             = nil;
    avatar.image            = nil;
    
    
    
    UIActivityIndicatorView *indicator;
    
    indicator                   = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped  = YES;
    indicator.center            = lapse.center;
    
    [lapse addSubview:indicator];
    
    
    avatar.layer.cornerRadius   = 22.0f;
    avatar.clipsToBounds        = YES;
    
    
    
    
    // if the 'lapse_image' object is a string, this means it's a url string
    // so load the image using the nifty function
    if ([[row objectForKey:@"lapse_image"] isKindOfClass:[NSString class]]) {
        
        // like a record baby
        [indicator startAnimating];
        
        NSURL *lapseUrl = [NSURL URLWithString:[row objectForKey:@"lapse_image"]];
        
        
        [self fetchImageWithURL:lapseUrl completionBlock:^(UIImage *image){
            // once the image is fetched and delivered in a nice fancy block
            // resize it to the bounds of the image view to save memory
            // because we need all the memory for reasons.
            [self resizeImage:image toWidth:lapse.frame.size.width completionBlock:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // set the value of 'lapse_image' to the newfangled image object
                    // so we dont have to do all the resizing shit all over again.
                    [row setValue:image forKey:@"lapse_image"];
                    
                    // main queue time, set the image to the image object
                    lapse.image = image;
                    
                    // *record screech*
                    [indicator stopAnimating];
                    
                });
            }];
            
            
        }];
    } else {
        // if the object is in fact an image, just use that without doing anything
        // since all the work has been done already (probably)
        lapse.image = [row objectForKey:@"lapse_image"];
    }

    
    // it's the same as all that nonsense above really,
    // not a whole lot is different
    // check them object keys tho.
    if([[row objectForKey:@"user_avatar"] isKindOfClass:[NSString class]] ) {
        
        NSURL *avatarUrl = [NSURL URLWithString:[row objectForKey:@"user_avatar"]];
        [self fetchImageWithURL:avatarUrl completionBlock:^(UIImage *image){
            [self resizeImage:image toWidth:avatar.frame.size.width completionBlock:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [row setValue:image forKey:@"user_avatar"];
                    avatar.image = image;
                    
                });
            }];
        }];
    } else {
        avatar.image = [row objectForKey:@"user_avatar"];
    }
    
    
    
    
    if([row objectForKey:@"liked"] == [NSNumber numberWithBool:YES]) {
		[likeButton setImage:iconFilledHeart forState:UIControlStateNormal];
	}
    
    timeago.text    = [row objectForKey:@"timeago"];
    username.text   = [row objectForKey:@"user_name"];
    title.text      = [row objectForKey:@"lapse_title"];
	
	
	
	//UIImage *heartIcon = [UIImage imageNamed:@"heart-outline.png"];
	likeButton.tag = indexPath.row;
	
	[likeButton addTarget:self action:@selector(likeLapse:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
	
	
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedLapseIndex = indexPath.row;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    SingleLapseViewController *pvc = [segue destinationViewController];
    NSIndexPath *selected = [self.collectionView indexPathForCell:sender];
    
    
    pvc.currentLapse = [array objectAtIndex:selected.item];
}

@end
