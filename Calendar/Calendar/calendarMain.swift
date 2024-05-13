//
//  calendarMain.swift
//  Calendar
//
//  Created by 朱明灿 on 2024/4/10.
//

import SwiftUI
import Foundation


struct calendarMain: View {
    let months: [Int] = [1,2,3,4,5,6,7,8,9,10,11,12]
    var calendar = Calendar.current
    var startDate: Date
    var endDate: Date
    let weekdays: [String] = {
            let dateFormatter = DateFormatter()
            return dateFormatter.shortWeekdaySymbols
        }()//加括号代表立即执行闭包，不加括号一般就是拿来传参
    @State var monthCurrent = calendarMain.getCurrentMonth()
    @State var showWindow = false
    @ObservedObject var selectingDate = selectedDate()
    
    var body: some View {
        ///可以滚动
        VStack{
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 18))
                        .bold()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                }
            }.padding(.leading).padding(.trailing)
            
            
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 2, alignment: .center), count: 7), spacing: 16) {
                    Section(header: Text("\(self.monthCurrent)月")) {
                        ForEach(getBlank(year: 2024, month: self.monthCurrent),id: \.self){_ in
                                Text("")
                        }
                        ForEach(getDatesForMonth(month: self.monthCurrent), id: \.self) { date in
                            CalendarCellView(showWindow: $showWindow,selectingDate: self.selectingDate, date: date)
                        }
                    }
                }
            .padding()
            Spacer()
            HStack(){
                Button(action: {
                    if self.monthCurrent > 1{
                        withTransaction(.init(animation: .easeInOut(duration: 0.3))) {
                            self.monthCurrent -= 1
                        }
                    }
                }){
                    Image(systemName: "chevron.left.square")
                        .font(.system(size: 40))
                }.padding(.trailing)
                Button(action: {
                    if self.monthCurrent < 12{
                        withTransaction(.init(animation: .easeInOut(duration: 0.3))) {
                                                self.monthCurrent += 1
                                            }}
                }){
                    Image(systemName: "chevron.right.square")
                        .font(.system(size: 40))
                }.padding(.leading)
            }.padding(.bottom,50)
            //Spacer()
            
        }//VStack
        .sheet(isPresented: $showWindow,onDismiss: {
            selectingDate.date = nil
        }){
            VStack{
                if self.selectingDate.date != nil{
                    itemWindowView(showWindow: $showWindow,selectingdate: self.selectingDate)
                    Spacer()
                }
            }.edgesIgnoringSafeArea(.bottom)
        }
    }
    private func getDatesForMonth(month: Int) -> [Date] {
        let startDateComponents = calendar.dateComponents([.year], from: startDate)
        let monthStartDateComponents = DateComponents(year: startDateComponents.year, month: month)
        guard let monthStartDate = calendar.date(from: monthStartDateComponents) else {
            return []
        }
        
        let range = calendar.range(of: .day, in: .month, for: monthStartDate)!
        let days = range.map { day -> Date in
            return calendar.date(bySetting: .day, value: day, of: monthStartDate)!
        }
        
        return days
    }
    func getFirstWeekdayOfMonth(year: Int, month: Int) -> Int? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let date = calendar.date(from: components) else {
            return nil
        }
        
        let weekday = calendar.component(.weekday, from: date)
        return weekday
    }
    func getBlank(year: Int, month: Int) -> [Int]{
        guard let num = getFirstWeekdayOfMonth(year: year, month: month) else{
            return []
        }
        var array : [Int] = []
        
        if num == 1{
            return array
        }
        for i in 1...num-1{
            array.append(i)
        }
        return array
    }
    static func getCurrentMonth() -> Int {
            let calendar = Calendar.current
            let currentDate = Date()
            let currentMonth = calendar.component(.month, from: currentDate)
        
            return currentMonth
    }
}
//一个单元格的View
struct CalendarCellView: View {
    @Binding var showWindow: Bool
    @ObservedObject var selectingDate : selectedDate
    let date: Date
    let calendar = Calendar.current
   
    var body: some View {
        Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 24))
                    .foregroundColor(calendar.isDate(date, inSameDayAs: Date()) ? .red : .black)
                    .frame(width: 45, height: 45)
                    .background(Color.gray.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(
                            {
                                if UserDefaults.standard.integer(forKey: dateToString(date)) == 0{
                                    return false
                                }
                                else{
                                    return true
                                }
                            }() ? Color.red : Color.clear,lineWidth: 5))
                    .cornerRadius(8)
                    .onTapGesture {//点击后action
                        withAnimation(.spring(
                            response: 0.45,
                            dampingFraction: 0.45,
                            blendDuration: 0)){//显式调用动画，默认使用.default动画
                                if self.selectingDate.date != nil{
                                    self.selectingDate.date = nil
                                    //showWindow = false
                                }else{
                                    self.selectingDate.date = self.date
                                    showWindow = true
                                }
                        }
                        
                        
                    }
    }
}

struct contentPreview: PreviewProvider{
    static var previews: some View{
        calendarMain(startDate: stringToDate("2024-01-01"), endDate: stringToDate("2024-12-30"))
    }
}
//字符串转日期
func stringToDate(_ string:String, dateFormat:String = "yyyy-MM-dd") -> Date {
    let formatter = DateFormatter()
    formatter.locale = Locale.init(identifier: "zh_CN")
    formatter.dateFormat = dateFormat
    let date = formatter.date(from: string)
    return date!
}
//日期转字符串
func dateToString(_ date: Date, dateFormat: String = "yyyy-MM-dd") -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = dateFormat
    let dateString = formatter.string(from: date)
    return dateString
}


