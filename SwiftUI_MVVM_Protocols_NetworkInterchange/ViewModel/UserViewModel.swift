//
//  UserViewModel.swift
//  SwiftUI_MVVM_Protocols_NetworkInterchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import Foundation


class UserListViewModel: ObservableObject {
    @Published var userList = [UserViewModel]()
    
    // let webservice = WebService()
    private var service : NetworkService
    init(service: NetworkService) {
        self.service = service
    }
    
    func downloasUsers() async {
        var resource = ""
        
        if service.typ == "Webservice" {
            resource = Constants.Urls.userExtension
        } else {
            resource = Constants.Paths.baseUrl
        }
        
        do {
            let users = try await service.download(resource)
            DispatchQueue.main.async {
                self.userList = users.map(UserViewModel.init)
            }
        } catch {
            
        }
        
    }
}


struct UserViewModel {
   
    let user: User
    
    var id: Int {
        user.id
    }
    
    var name: String {
        user.name
    }
    
    var username: String {
        user.username
    }
    
    var email: String {
        user.email
    }
    
    

}
