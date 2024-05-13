//
//  itemWindowView.swift
//  Calendar
//
//  Created by 朱明灿 on 2024/4/11.
// 弹窗，可以输入这一天要做的事项

import Foundation
import SwiftUI

let semaphore = DispatchSemaphore(value: 0)

struct itemWindowView: View {
    @State var inputTexts: [String] = []//输入文本
    @State var addReminder: [Date?] = []//是否添加提醒
    @State var selectedTime : Date = Date()//选择提醒的时间
    @State var showAlert = false//删除提醒
    @State var showSelectedTime: Int = -1//对哪一个事项选择提醒时间，-1则不展示选择时间
    @State var deleteIndex: Int = -1
    @Binding var showWindow: Bool//是否展示itemWindowView

    @ObservedObject var selectingdate : selectedDate//该提醒事项对应的日期
    
    @State var inputTextsNum: Int = 0
    
    //顶部小横线
    var topIndicator: some View{
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 40,height: 6)
            .opacity(0.2)
            .padding(.top).padding(.bottom)
    }
    //文本区
    var textField: some View{
        VStack {
            Text("提醒事项").bold().font(.title2)
            if selectingdate.date != nil{
                Text("\(dateToString(selectingdate.date!))")
                    .padding(.bottom)
            }
            ScrollView{
                ForEach(inputTexts.indices,id:\.self){ index in
                    HStack{
                        VStack{
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)){
                                    if !inputTexts[index].isEmpty{
                                        showSelectedTime = index
                                    }
                                }
                            }){
                                Image(systemName: "alarm")
                                    .font(.system(size: 25))
                                    .foregroundColor(.blue)
                            }//.padding(.bottom)
                            
                            if addReminder[index] != nil{
                                Text(dateToStringHourMinute(addReminder[index]!))
                                    .font(.system(size: 12))
                            }
                        }
                        TextEditor(text: $inputTexts[index])
                            .frame(height: 100)
                            .border(Color.black.opacity(0.2))
                            .cornerRadius(20)
                            .padding(.bottom)
                            .onTapGesture {
                                // 点击 TextEditor 时取消键盘的第一响应者
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }

                        //删除事项按钮
                        Button(action: {
                            showAlert = true
                            deleteIndex = index
                        }){
                            Image(systemName: "minus.circle")
                                .font(.system(size: 25))
                                .foregroundColor(.red)
                        }.padding(.bottom)
                        .alert(isPresented: $showAlert){//删除提醒
                            Alert(
                                title:Text("删除？"),
                                message: Text("删除后无法恢复"),
                                primaryButton: .default(Text("删除"),action: {
                                    withAnimation(.easeInOut(duration: 0.5)){
                                    deleteItem(index: deleteIndex)
                                }}),
                                secondaryButton: .default(Text("取消")))
                        }
                    }
                }
            }
            //添加事项按钮
            Button(action: {
                inputTexts.append("")
                self.inputTextsNum += 1
                addReminder.append(nil)
            }){
                Image(systemName: "plus.circle")
                    .font(.system(size: 25))
            }.padding(.bottom)
        }//VStack
        .padding(.leading).padding(.trailing)
        
    }
    //按钮
    var buttons: some View{
        HStack{
            Button(action: {//删除事项
                if selectingdate.date != nil{
                    for index in inputTexts.indices{
                        deleteItem(index: index)//删除存储的文本
                        selectedTimeView.removeRemind(time: selectingdate.date!, index: index)//删除存储的提醒
                    }
                    inputTexts.removeAll()
                    addReminder.removeAll()
                    UserDefaults.standard.set(inputTexts.count, forKey: dateToString(selectingdate.date!))
                }}){
                Capsule()
                    .fill(Color.red)
                    .overlay(){
                        Text("删除所有")
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(width: 100,height: 30)
            }
            
            Button(action: {//保存字符串
                if selectingdate.date != nil{
                    //过滤掉空事项
                    var newTextArray: [String] = []
                    var newRemindArray: [Date?] = []
                    for index in inputTexts.indices{
                        if !inputTexts[index].isEmpty{
                            newTextArray.append(inputTexts[index])
                            newRemindArray.append(addReminder[index])
                        }
                    }
                    inputTexts = newTextArray
                    addReminder = newRemindArray
                    
                    
                    for index in inputTexts.indices{
                        //储存文本
                        UserDefaults.standard.set(inputTexts[index], forKey: dateToString(selectingdate.date!) + String(index))
                    }
                    //储存事项个数
                    UserDefaults.standard.set(inputTexts.count, forKey: dateToString(selectingdate.date!))
                }
                //编辑完后移开弹窗
                //showWindow = false
                //selectingdate.date = nil
            }){
                Capsule()
                    .fill(Color.green)
                    .overlay(){
                        Text("完成编辑")
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(width: 100,height: 30)
            }
        }.padding(.bottom,100)
    }
    func deleteItem(index: Int)->Void{
        UserDefaults.standard.removeObject(forKey: dateToString(selectingdate.date!) + String(index))
        inputTexts.remove(at: index)
        addReminder.remove(at: index)
        if self.inputTextsNum > 0{
            self.inputTextsNum -= 1
        }
    }
    
    /*func searchRemind(id: String) -> Void{
        var judge = false
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getPendingNotificationRequests { requests in
            print("id:"+id)
            for request in requests {
                print("request.identifier:\(request.identifier)")
                if request.identifier == id {
                    judge = true
                }
            }
        }
        showRed = judge
    }*/
    func getRequest(id: String) -> UNNotificationRequest?{
        let notificationCenter = UNUserNotificationCenter.current()
        var result: UNNotificationRequest? = nil
        
        notificationCenter.getPendingNotificationRequests { requests in
            for request in requests {
                if request.identifier == id {
                    result = request
                }
            }
        }
        return result
    }
    
    var body: some View {
        ScrollView{
            ZStack{
                VStack{
                    topIndicator
                    textField
                    buttons
                }
                .padding(EdgeInsets(
                    top:5,
                    leading: 30,
                    bottom: 30,
                    trailing: 30))
                .fixedSize(horizontal: false, vertical: true)
                .cornerRadius(20)
                .onAppear {
                    // 读取之前保存的用户输入内容
                    inputTexts.removeAll()
                    addReminder.removeAll()
                    
                    var num = UserDefaults.standard.integer(forKey: dateToString(self.selectingdate.date!))
                    if num < 0{
                        num = 0
                    }
                    
                    for index in 0..<num{
                        //文本区
                        if let savedText = UserDefaults.standard.string(forKey: dateToString(self.selectingdate.date!) + String(index)) {
                            inputTexts.append(savedText)
                        }else{
                        }
                        
                        //添加的提醒
                        if let savedRemind = getRequest(id: dateToString(self.selectingdate.date!) + String(index)){
                            if let trigger = savedRemind.trigger as? UNCalendarNotificationTrigger{
                                addReminder.append(Calendar.current.date(from: trigger.dateComponents))
                            }
                        }else{
                            print("添加了nil,查找的id为"+dateToString(self.selectingdate.date!) + String(index))
                            addReminder.append(nil)
                        }
                        //调试区
                        print(addReminder)
                        
                    }
                }
                .onDisappear{
                    print(addReminder)
                    
                 }
            }//ZStack
        }//Scroll
        .overlay(
            VStack{
                if showSelectedTime != -1{
                    Spacer()
                    selectedTimeView(selectedTime: $selectedTime, addReminder: $addReminder, showSelectedTime: $showSelectedTime,inputText: inputTexts[showSelectedTime], selectingdate: selectingdate)
                        .padding()
                }
            }
        )
        
    }
    
}

func dateToStringHourMinute(_ date: Date, dateFormat: String = "hh:mm")->String{
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = dateFormat
    let dateString = formatter.string(from: date)
    return dateString
}

/*struct windowPreview: PreviewProvider{
    static var previews: some View{
        itemWindowView()
    }
}*/
