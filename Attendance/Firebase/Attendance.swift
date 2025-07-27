//
//  AttendanceModel.swift
//  Attendance
//
//  Created by Dungeon_master on 26/07/25.
//

import Foundation
import FirebaseFirestoreSwift

struct Attendance: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var role: String
    var date: Date
    var isPresent: Bool
}
