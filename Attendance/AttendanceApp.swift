//
//  AttendanceApp.swift
//  Attendance
//
//  Created by Dungeon_master on 26/07/25.
//

import SwiftUI
import Firebase

@main
struct AttendanceApp: App {
    init() {
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
