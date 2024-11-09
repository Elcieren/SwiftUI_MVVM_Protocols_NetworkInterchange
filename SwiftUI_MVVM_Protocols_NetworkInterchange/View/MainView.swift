//
//  ContentView.swift
//  SwiftUI_MVVM_Protocols_NetworkInterchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var userListViewModel : UserListViewModel
    
    init(){
        self.userListViewModel = UserListViewModel(service: LocalService())
    }
    
    var body: some View {
        List(userListViewModel.userList, id: \.id) { user in
            VStack {
                Text(user.name).font(.title3).foregroundStyle(.blue).frame(maxWidth:.infinity , alignment: .leading)
                Text(user.username).font(.title3).foregroundStyle(.black).frame(maxWidth:.infinity , alignment: .leading)
                Text(user.email).font(.title3).foregroundStyle(.red).frame(maxWidth:.infinity , alignment: .leading)
            }
        }.task {
            await userListViewModel.downloasUsers()
        }
    }
}

#Preview {
    MainView()
}
