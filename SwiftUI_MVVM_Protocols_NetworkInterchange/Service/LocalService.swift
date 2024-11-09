//
//  LocalService.swift
//  SwiftUI_MVVM_Protocols_NetworkInterchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import Foundation


class LocalService : NetworkService {
    var typ : String = "Localservice"
    
    
    func download(_ resource: String) async throws -> [User] {
        
        guard let path = Bundle.main.path(forResource: resource, ofType: "json") else { fatalError("Resource not found") }
        let data = try Data(contentsOf: URL(filePath: path))
        
        return try JSONDecoder().decode([User].self, from: data)
    }
}
