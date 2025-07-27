//
//  DashboardView.swift
//  Attendance
//
//  Created by Dungeon_master on 26/07/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var firestore: FirestoreService

    @State private var todayAttendance: [Attendance] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("📊 Attendance Dashboard")
                        .font(.title2)
                        .bold()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today: \(Date(), formatter: dateFormatter)")
                            .font(.headline)

                        HStack {
                            StatBox(label: "Total", value: "\(todayAttendance.count)", color: .blue)
                            StatBox(label: "Present", value: "\(presentCount)", color: .green)
                            StatBox(label: "Absent", value: "\(absentCount)", color: .red)
                        }

                        Divider()

                        HStack {
                            StatBox(label: "Students", value: "\(studentCount)", color: .purple)
                            StatBox(label: "Employees", value: "\(employeeCount)", color: .orange)
                        }

                        Text("Attendance Breakdown")
                            .font(.headline)
                            .padding(.top)
                        
                        Chart(pieData) { slice in
                            SectorMark(
                                angle: .value("Count", slice.count),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(slice.color)
                            .cornerRadius(4)
                            .annotation(position: .overlay) {
                                PieAnnotationView(slice: slice, total: todayAttendance.count)
                            }
                        }
                        .chartLegend(position: .bottom, alignment: .center)
                        .frame(height: 220)
                        .padding(.vertical)

                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                firestore.fetchTodayAttendance { records in
                    self.todayAttendance = records
                }
            }
        }
    }

    // MARK: - Computed stats

    var presentCount: Int {
        todayAttendance.filter { $0.isPresent }.count
    }

    var absentCount: Int {
        todayAttendance.filter { !$0.isPresent }.count
    }

    var studentCount: Int {
        todayAttendance.filter { $0.role == "Student" }.count
    }

    var employeeCount: Int {
        todayAttendance.filter { $0.role == "Employee" }.count
    }

    var pieData: [PieSlice] {
        [
            PieSlice(category: "Present", count: presentCount, color: .green),
            PieSlice(category: "Absent", count: absentCount, color: .red)
        ]
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}

struct StatBox: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PieSlice: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
    let color: Color
}


struct PieAnnotationView: View {
    let slice: PieSlice
    let total: Int

    var body: some View {
        if slice.count > 0 && (Double(slice.count) / Double(total)) > 0.05 {
            VStack(spacing: 2) {
                Text(slice.category)
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.white)
                Text("\(Int((Double(slice.count) / Double(total)) * 100))%")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.85))
            }
            .multilineTextAlignment(.center)
            .shadow(radius: 1)
        }
    }
}
