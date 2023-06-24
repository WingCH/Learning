//
//  ContactsFeature.swift
//  study_tca
//
//  Created by Wing on 24/6/2023.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}

struct ContactsFeature: ReducerProtocol {
    struct State: Equatable {
        @PresentationState var addContact: AddContactFeature.State?
        var contacts: IdentifiedArrayOf<Contact> = []
    }

    enum Action: Equatable {
        case addButtonTapped
        case addContact(PresentationAction<AddContactFeature.Action>)
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addContact = AddContactFeature.State(
                    contact: Contact(id: UUID(), name: "")
                )
                return .none
//            case .addContact(.presented(.delegate(.cancel))):
//                state.addContact = nil
//                return .none
            case let .addContact(.presented(.delegate(.saveContact(contact)))):
                state.contacts.append(contact)
//                state.addContact = nil
                return .none
            case .addContact:
                return .none
            }
        }
        /*
         這個語法稱為"Key Path Expressions as Functions"（鍵路徑表達式為函數），在 Swift 5.2 以後被引入。

         `\.$addContact`是一個key path，目標是 `ContactsFeature.State` 的 `addContact` 屬性。斜線 `/` 是一個前綴運算符，用於將列舉類型的 case 轉換為函數。

         在這裡的用法中，`/Action.addContact`會接收一個 `ContactsFeature.Action` instance並嘗試將之解封到 `Action.addContact` case。如果這個 action 不是 `.addContact` ，該函數將返回 nil，否則它將返回包含在 `.addContact` case 中的 associated value。

         https://github.com/pointfreeco/swift-case-paths
         */
        .ifLet(\.$addContact, action: /ContactsFeature.Action.addContact) {
            AddContactFeature()
        }
    }
}

struct ContentView: View {
    let store: StoreOf<ContactsFeature>

    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: \.contacts) { viewStore in
                List {
                    ForEach(viewStore.state) { contact in
                        Text(contact.name)
                    }
                }
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem {
                        Button {
                            viewStore.send(.addButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .sheet(
            store: self.store.scope(
                state: \.$addContact,
                action: { .addContact($0) }
            )
        ) { addContactStore in
            NavigationStack {
                AddContactView(store: addContactStore)
            }
        }
    }
}
