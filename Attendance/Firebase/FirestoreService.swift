//
//  FirestoreService.swift
//  Attendance
//
//  Created by Dungeon_master on 26/07/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var attendanceList: [Attendance] = []
    
    // MARK: - 1. For AttendanceView (role + specific date)
    func fetchAttendanceForView(role: String, date: Date, completion: @escaping ([Attendance]) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        db.collection("attendance")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    let records = documents.compactMap { doc -> Attendance? in
                        var att = try? doc.data(as: Attendance.self)
                        att?.id = doc.documentID
                        return att
                    }

                    // ❗️Filter by role manually here to avoid composite index
                    let filtered = records.filter { $0.role == role }

                    DispatchQueue.main.async {
                        completion(filtered)
                    }
                } else {
                    print("Error: \(error?.localizedDescription ?? "Unknown")")
                    completion([])
                }
            }
    }


    
    // MARK: - 2. For DashboardView (today only)
    func fetchTodayAttendance(completion: @escaping ([Attendance]) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            print("Date calculation failed.")
            completion([])
            return
        }

        db.collection("attendance")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching today's attendance: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let records = snapshot?.documents.compactMap { doc -> Attendance? in
                    var att = try? doc.data(as: Attendance.self)
                    att?.id = doc.documentID
                    return att
                } ?? []

                DispatchQueue.main.async {
                    completion(records)
                }
            }
    }
   
    // MARK: - 3. For DashboardView (all time)
    func fetchAllAttendance(completion: @escaping ([Attendance]) -> Void) {
        db.collection("attendance")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching all attendance: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let records = snapshot?.documents.compactMap { doc -> Attendance? in
                    var att = try? doc.data(as: Attendance.self)
                    att?.id = doc.documentID
                    return att
                } ?? []

                DispatchQueue.main.async {
                    completion(records)
                }
            }
    }

      
    func addAttendance(_ attendance: Attendance) {
        do {
            _ = try db.collection("attendance").addDocument(from: attendance)
        } catch {
            print("Error adding attendance: \(error.localizedDescription)")
        }
    }

    func deleteAttendance(_ attendance: Attendance) {
        guard let id = attendance.id else { return }
        db.collection("attendance").document(id).delete { error in
            if let error = error {
                print("Delete error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.attendanceList.removeAll { $0.id == id }
                }
            }
        }
    }

    func updateAttendance(_ attendance: Attendance) {
        guard let id = attendance.id else { return }
        do {
            try db.collection("attendance").document(id).setData(from: attendance)
        } catch {
            print("Update error: \(error.localizedDescription)")
        }
    }


    // ✅ Optional: fetch by DocumentID directly
    func fetchAttendanceById(_ id: String) {
        db.collection("attendance").document(id).getDocument { docSnapshot, error in
            guard let document = docSnapshot, document.exists else { return }
            if let attendance = try? document.data(as: Attendance.self) {
                self.attendanceList = [attendance]
            }
        }
    }
}
