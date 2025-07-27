//
//  EditAttendanceView.swift
//  Attendance
//
//  Created by Dungeon_master on 26/07/25.
//

import SwiftUI

struct EditAttendanceView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var attendance: Attendance
    let originalAttendance: Attendance
    @ObservedObject var firestore: FirestoreService

    @State private var showAlert = false
    @State private var alertMessage = ""

    var roles = ["Student", "Employee"]

    init(attendance: Attendance, firestore: FirestoreService) {
        self._attendance = State(initialValue: attendance)
        self.originalAttendance = attendance
        self.firestore = firestore
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $attendance.name)

                    Picker("Role", selection: $attendance.role) {
                        ForEach(roles, id: \.self) { role in
                            Text(role)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Toggle("Present", isOn: $attendance.isPresent)

                    DatePicker("Date", selection: $attendance.date, displayedComponents: .date)
                }

                Section {
                    Button("Save Changes") {
                        if attendance.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            alertMessage = "Name cannot be empty."
                            showAlert = true
                            return
                        }

                        logChanges()
                        firestore.updateAttendance(attendance)
                        presentationMode.wrappedValue.dismiss()
                    }

                    Button("Reset Changes", role: .cancel) {
                        attendance = originalAttendance
                    }

                    Button("Delete Entry", role: .destructive) {
                        firestore.deleteAttendance(attendance)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Edit Attendance")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Validation Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func logChanges() {
        if attendance.name != originalAttendance.name {
            print("✏️ Name changed: '\(originalAttendance.name)' → '\(attendance.name)'")
        }
        if attendance.role != originalAttendance.role {
            print("✏️ Role changed: '\(originalAttendance.role)' → '\(attendance.role)'")
        }
        if attendance.isPresent != originalAttendance.isPresent {
            print("✏️ Presence changed: \(originalAttendance.isPresent) → \(attendance.isPresent)")
        }
        if !Calendar.current.isDate(attendance.date, inSameDayAs: originalAttendance.date) {
            print("✏️ Date changed: \(originalAttendance.date.formatted()) → \(attendance.date.formatted())")
        }
    }
}

