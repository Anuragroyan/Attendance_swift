//
//  AttendanceListView.swift
//  Attendance
//
//  Created by Dungeon_master on 27/07/25.
//
import SwiftUI

struct AttendanceListView: View {
    @ObservedObject var firestore: FirestoreService
    @State private var attendanceList: [Attendance] = []
    @State private var selectedAttendance: Attendance?
    @State private var showEditView = false
    let role: String
    let date: Date

    var body: some View {
        NavigationView {
            List {
                ForEach(attendanceList) { att in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(att.name).font(.headline)
                            Text(att.role).font(.subheadline).foregroundColor(.gray)
                            Text(att.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                        }
                        Spacer()
                        Button("Edit") {
                            selectedAttendance = att
                            showEditView = true
                        }
                        .padding(.trailing)

                        Button(role: .destructive) {
                            firestore.deleteAttendance(att)
                            fetchData() // Refresh list
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Attendance")
            .onAppear {
                fetchData()
            }
            .sheet(isPresented: $showEditView) {
                if let selected = selectedAttendance {
                    EditAttendanceView(attendance: selected, firestore: firestore)
                }
            }
        }
    }

    func fetchData() {
        firestore.fetchAttendanceForView(role: role, date: date) { records in
            self.attendanceList = records
        }
    }
}
