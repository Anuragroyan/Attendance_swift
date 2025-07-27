//
//  AttendanceView.swift
//  Attendance
//
//  Created by Dungeon_master on 26/07/25.
//

import SwiftUI

struct AttendanceView: View {
    @StateObject private var firestore = FirestoreService()
    @State private var selectedRole: String = "Student"
    @State private var name = ""
    @State private var isPresent = true
    @State private var selectedDate = Date()
    @State private var reportText = ""
    @State private var selectedAttendance: Attendance?

    var filteredAttendance: [Attendance] {
        firestore.attendanceList
    }

    var total: Int {
        filteredAttendance.count
    }

    var presentCount: Int {
        filteredAttendance.filter { $0.isPresent }.count
    }

    var absentCount: Int {
        total - presentCount
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                rolePicker
                datePicker
                attendanceForm

                if total > 0 {
                    summaryView
                }

                attendanceList

                if total > 0 {
                    reportSection
                }
            }
            .navigationTitle("\(selectedRole) Attendance")
            .onAppear {
                fetchData()
            }
            .onChange(of: selectedRole) {
                fetchData()
            }
            .onChange(of: selectedDate) {
                fetchData()
            }
            .sheet(item: $selectedAttendance) { attendance in
                EditAttendanceView(attendance: attendance, firestore: firestore)
            }
        }
    }

    private var rolePicker: some View {
        Picker("Role", selection: $selectedRole) {
            Text("Student").tag("Student")
            Text("Employee").tag("Employee")
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }

    private var datePicker: some View {
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
            .padding(.horizontal)
    }

    private var attendanceForm: some View {
        Form {
            TextField("Name", text: $name)
            Toggle("Present", isOn: $isPresent)

            Button("Mark Attendance") {
                let attendance = Attendance(
                    name: name.trimmingCharacters(in: .whitespaces),
                    role: selectedRole,
                    date: selectedDate,
                    isPresent: isPresent
                )

                guard !attendance.name.isEmpty else { return }

                firestore.addAttendance(attendance)
                name = ""
                isPresent = true
                fetchData()
            }
        }
    }

    private var summaryView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Summary for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.headline)
            HStack {
                Text("Total: \(total)")
                Spacer()
                Text("Present: \(presentCount)")
                Spacer()
                Text("Absent: \(absentCount)")
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var attendanceList: some View {
        List {
            ForEach(filteredAttendance) { record in
                Button {
                    selectedAttendance = record
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(record.name).font(.headline)
                            Text(record.date.formatted()).font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: record.isPresent ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(record.isPresent ? .green : .red)
                    }
                    .padding(6)
                    .background(Calendar.current.isDateInToday(record.date) ? Color.yellow.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let record = filteredAttendance[index]
                    firestore.deleteAttendance(record)
                }
                fetchData()
            }
        }
    }

    private var reportSection: some View {
        VStack {
            Button("Generate Report") {
                reportText = filteredAttendance.map {
                    "\($0.name): \($0.isPresent ? "Present" : "Absent")"
                }.joined(separator: "\n")
            }
            .padding(.top, 6)

            if !reportText.isEmpty {
                ShareLink(item: reportText) {
                    Label("Export Report", systemImage: "square.and.arrow.up")
                }
                .padding(.bottom)
            }
        }
    }

    private func fetchData() {
        firestore.fetchAttendanceForView(role: selectedRole, date: selectedDate) { records in
            firestore.attendanceList = records
        }
    }

}
