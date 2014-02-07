//
//  ViewController.h
//  IPScanner
//
//  Created by pramesh on 2/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *arrBarcode;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
