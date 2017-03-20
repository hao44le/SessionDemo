//
//  ViewController.m
//  SessionDemo
//
//  Created by Gelei Chen on 19/3/2017.
//  Copyright © 2017 AISense Inc. All rights reserved.
//

#import "NEVViewController.h"
#import "AppDelegate.h"
@interface NEVViewController ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>{
    NSURLSessionTask *task;
    NSURLSession *session;
    
}
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation NEVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    session = [self backgroundSession];
    self.progress.progress = 0;
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    self.image.hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)start:(id)sender {
    if (task) return;
    
    NSURL * downloadURL = [NSURL URLWithString:@"https://nationalzoo.si.edu/sites/default/files/animals/africanlion-005_0.jpg"];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    task = [session downloadTaskWithRequest:request];
    [task resume];
    self.image.hidden = YES;
    self.progress.hidden = NO;
}

- (IBAction)crash:(id)sender {
    char *c = NULL;
    *c = 1;
}

- (NSURLSession*)backgroundSession{
    static NSURLSession*_session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.geleichen.com.demo"];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return _session;
}

- (void)callCompletionHandlerIfFinished {
    [session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
        if (count==0){
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            if(appDelegate.backgroundSessionCompletionHandler){
                void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
                appDelegate.backgroundSessionCompletionHandler = nil;
                completionHandler();
            }
        }
    }];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSLog(@"downloadTask: %@ progress: %f",downloadTask,progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progress.progress = progress;
    });
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*doctsPath = [paths objectAtIndex:0];
    NSString*filePath = [doctsPath stringByAppendingPathComponent:@"lion.png"];
    [[NSFileManager defaultManager]copyItemAtPath:[location path] toPath:filePath error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *_image2 = [UIImage imageWithContentsOfFile:filePath];
        self.image.image = _image2;
        self.progress.hidden = YES;
        self.image.hidden = NO;
    });
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error){
        NSLog(@"Task: %@ faile with error: %@",task,error);
    } else {
        NSLog(@"Task: %@ completed",task);
    }
    
    self->task = nil;
    
    [self callCompletionHandlerIfFinished];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
