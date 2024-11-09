//
//  NetworkService.swift
//  SwiftUI_MVVM_Protocols_NetworkInterchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import Foundation


protocol NetworkService {
    func download(_ resource: String) async throws -> [User]
    var typ : String { get }
}
