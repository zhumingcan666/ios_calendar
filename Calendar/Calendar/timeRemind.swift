//
//  timeRemind.swift
//  Calendar
//
//  Created by 朱明灿 on 2024/4/20.
//

import Foundation
import SwiftUI

extension selectedTimeView{
    func createRemind(time: Date,text: String)->Void{
        let content = UNMutableNotificationContent()
        content.title = "您有待完成的事项"
        //content.subtitle = "子标题"
        content.body = text
        content.badge = 1
        
        let dateComponents =  Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: dateToString(time)+String(showSelectedTime), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { err in
            err != nil ? print("添加本地通知错误", err!.localizedDescription) : print("添加本地通知成功")
        }
        print("添加的id为"+dateToString(time)+String(showSelectedTime))
    }
    
    static func removeRemind(time: Date,index: Int)->Void{
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dateToString(time) + String(index)])
    }
}
