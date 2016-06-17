//
//  ViewController.m
//  ZYYDispatchDemo
//
//  Created by zhangyangyang on 16/6/17.
//  Copyright © 2016年 8win. All rights reserved.
//


/*
 
     需求： dispatch实现一个题  10个任务 两个一组（这两个任务是并发的），这五个组是按先后顺序执行的
     分析思路：
      1、 两个一组（这两个任务是并发的）  GCD中 给 队列中的block 添加 方法的时候 始终坚持 FIFO原则。 保证2个任务是并放的 最好通过一个线程组来搞定它。  如果有 3个任务，要求并发，那 线程组的威力 就可以得到更好的表现。   （注意一点：并发和并行不是一个概念）
 
      2、 剩下4个组是按先后顺序执行 这个最简单，就用 GCD 的同步函数 串行队列就行了。
 
      3、 为了 第一组 和 剩下的4组 整体按照 先后顺序执行， 用一个线程组 来管理 最完美。
 
 
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_group_t group  = dispatch_group_create(); // 创建一个线程组
    dispatch_queue_t dispatchQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL); // 创建一个并行队列
    
    dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
        // 并行执行第一组中线程中的一个任务
        [self task1];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
        // 并行执行第一组中线程中的二个任务
        [self task2];
    });
   
    // 按照先后顺序开始执行 剩下的 4组任务
    dispatch_group_notify(group, dispatch_get_global_queue(0,0), ^{
        
            // 同步 执行第二组中的 二个任务
            dispatch_sync(dispatchQueue, ^{
                [self task3];
                [self task4];
            });
        
            // 同步 执行第三组中的 二个任务
            dispatch_sync(dispatchQueue, ^{
                [self task5];
                [self task6];
            });
            dispatch_sync(dispatchQueue, ^{
                [self task7];
                [self task8];
            });
            dispatch_sync(dispatchQueue, ^{
                [self task9];
                [self task10];
            });

    });
}

//  如果你把下载图片的耗时操作，添加到task1中，那么gcd在运行时候 由于 task1 和 task2 是并行执行，所有gcd 会优先执行完 task2 ，然后再执行完taks1，但是它们两个是同时发起的。 只是执行时间不同。   如果 taks1 中的 下载图片任务 给注销掉，这样 task1 和 task2的耗时操作基本上一样，这样多运行几次程序，就会发现 每次lldb 都会输出不同的结果，又时候task1 先完成，有时候 task2先完成。不过以上2种情况 都恰恰证明了 gcd的精髓所在，就是可以并行执行任务。

- (void)task1
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    // [self loadImage]; 把这一块的代码 可以放开 进行调试比较。
}

#pragma mark 请求图片数据
- (void)loadImage{
    //请求数据
    NSURL *url   = [NSURL URLWithString:@"http://images.apple.com/iphone-6/overview/images/biggest_right_large.png"];
}

- (void)task2
{
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)task3
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)task4
{
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)task5
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)task6
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)task7
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)task8
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)task9
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


- (void)task10
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

/*
 
     LLDB的 2种 输出结果
     
     2016-06-17 20:22:15.746 ZYYDispatchDemo[1981:282236] task1
     2016-06-17 20:22:15.746 ZYYDispatchDemo[1981:282222] task2
     2016-06-17 20:22:15.746 ZYYDispatchDemo[1981:282236] task3
     2016-06-17 20:22:15.746 ZYYDispatchDemo[1981:282236] task4
     2016-06-17 20:22:15.746 ZYYDispatchDemo[1981:282236] task5
     2016-06-17 20:22:15.746 ZYYDispatchDemo[1981:282236] task6
     2016-06-17 20:22:15.747 ZYYDispatchDemo[1981:282236] task7
     2016-06-17 20:22:15.747 ZYYDispatchDemo[1981:282236] task8
     2016-06-17 20:22:15.747 ZYYDispatchDemo[1981:282236] task9
     2016-06-17 20:22:15.747 ZYYDispatchDemo[1981:282236] task10
     
     
     2016-06-17 20:22:43.575 ZYYDispatchDemo[1990:282902] task2
     2016-06-17 20:22:43.575 ZYYDispatchDemo[1990:282895] task1
     2016-06-17 20:22:43.576 ZYYDispatchDemo[1990:282902] task3
     2016-06-17 20:22:43.576 ZYYDispatchDemo[1990:282902] task4
     2016-06-17 20:22:43.576 ZYYDispatchDemo[1990:282902] task5
     2016-06-17 20:22:43.576 ZYYDispatchDemo[1990:282902] task6
     2016-06-17 20:22:43.577 ZYYDispatchDemo[1990:282902] task7
     2016-06-17 20:22:43.577 ZYYDispatchDemo[1990:282902] task8
     2016-06-17 20:22:43.577 ZYYDispatchDemo[1990:282902] task9
     2016-06-17 20:22:43.577 ZYYDispatchDemo[1990:282902] task10
 
 
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
