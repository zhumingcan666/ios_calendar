//
//  ContentView.swift
//  Calendar
//
//  Created by 朱明灿 on 2024/4/10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        calendarMain(startDate: stringToDate("2024-01-01"), endDate: stringToDate("2024-12-30"))
    }
}

#Preview {
    ContentView()
}
