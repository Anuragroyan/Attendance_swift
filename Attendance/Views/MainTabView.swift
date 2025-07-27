//
//  MainTabView.swift
//  Attendance
//
//  Created by Dungeon_master on 26/07/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var firestore = FirestoreService()

    var body: some View {
        TabView {
            AttendanceView()
                .environmentObject(firestore)
                .tabItem {
                    Label("Attendance", systemImage: "checkmark.circle")
                }

            DashboardView(firestore: firestore)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
        }
    }
}
