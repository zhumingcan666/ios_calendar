//
//  CalendarApp.swift
//  Calendar
//
//  Created by 朱明灿 on 2024/4/10.
//

import SwiftUI
import UserNotifications

@main
struct CalendarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    //系统会在启动过程中调用一次这个方法，并将应用程序实例和启动选项字典作为参数传递给它
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //application参数：代表当前的应用程序对象，可以访问和操作应用程序级别的属性和方法，例如注册远程通知、管理通知中心等。
        //didFinishLaunchingWithOptions参数：是一个包含启动选项的字典，用于告诉应用程序在启动时发生了什么事件，键是 UIApplication.LaunchOptionsKey 枚举值，表示不同的启动选项，例如应用程序被推送通知唤醒、通过URL启动
        UNUserNotificationCenter.current().delegate = self//将 AppDelegate 类指定为 UNUserNotificationCenter 的代理，可以将通知的回调委托给 AppDelegate 来处理，当应用程序接收到通知、用户与通知进行交互或者通知出现其他事件时，UNUserNotificationCenter 将调用 AppDelegate 中相应的代理方法，以便你可以在这些方法中编写自定义的逻辑
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if granted {
                print("用户已授权通知")
            } else {
                print("用户未授权通知")
            }
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 解析远程通知内容
        // ...
        
        // 创建本地通知内容
        /*let content = UNMutableNotificationContent()
        content.title = "这是通知标题"
        content.body = "这是通知内容"
        content.sound = UNNotificationSound.default
        
        // 创建通知触发器
        var dateComponents = DateComponents()
        dateComponents.year = 2024
        dateComponents.month = 4
        dateComponents.day = 18
        dateComponents.hour = 22
        dateComponents.minute = 18

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // 创建通知请求
        let request = UNNotificationRequest(identifier: "NotificationIdentifier", content: content, trigger: trigger)
        
        // 发送本地通知请求
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("发送通知失败: \(error.localizedDescription)")
            } else {
                print("通知已发送")
            }
            
            completionHandler(.newData) // 标记后台获取数据的结果
        }*/
        
    }
    
}
