//
//  selectedTimeView.swift
//  Calendar
//
//  Created by 朱明灿 on 2024/4/18.
//

import Foundation
import SwiftUI

struct selectedTimeView: View {
    @Binding var selectedTime : Date
    @Binding var addReminder: [Date?]
    @Binding var showSelectedTime : Int//对应index
    var inputText: String
    
    @ObservedObject var selectingdate : selectedDate//该提醒事项对应的日期
    
    //选择提醒时间
    var timeView : some View{
        DatePicker("Select a time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
                .frame(height: 200)
    }
    //MARK: - 按钮
    var buttonView : some View{
        HStack(spacing: 40){
            Capsule()
                .fill(Color.red)
                .overlay(){
                    Text("取消")
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(width: 70,height: 30)
                .onTapGesture {
                    //取消后关闭该视图
                    withAnimation(.easeInOut(duration: 0.5)){
                        selectedTimeView.removeRemind(time: selectedTime,index: showSelectedTime)//删除该提醒
                        addReminder[showSelectedTime] = nil
                        showSelectedTime = -1
                    }
                }
            
            
            Capsule()
                .fill(Color.green)
                .overlay(){
                    Text("完成")
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(width: 70,height: 30)
                .onTapGesture {
                    //完成后关闭该视图
                    withAnimation(.easeInOut(duration: 0.5)){
                        UserDefaults.standard.set(selectedTime, forKey: dateToString(selectingdate.date!) + "Time" + String(showSelectedTime))
                        createRemind(time: selectedTime, text: inputText)//创建提醒
                        addReminder[showSelectedTime] = selectedTime
                        showSelectedTime = -1
                    }
                }
        }
    }
    
    
    var body: some View {
        VStack{
            timeView
            buttonView
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray, lineWidth: 2)
        )
        .background(Color.white.opacity(0.95))
        .onAppear{
            if let savedTime = UserDefaults.standard.object(forKey: dateToString(selectingdate.date!) + "Time" + String(showSelectedTime)) as? Date{
                selectedTime = savedTime
            }
            selectedTime = selectingdate.date!

        }
    }
}
