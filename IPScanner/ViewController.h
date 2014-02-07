//
//  ViewController.h
//  IPScanner
//
//  Created by pramesh on 2/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,ZBarReaderDelegate>{
    NSMutableArray *arrBarcode;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnScan;
- (IBAction)btnScan:(id)sender;

@end
