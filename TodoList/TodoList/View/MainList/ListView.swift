//
//  ListView.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/04.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var listViewModel: ListViewModel
    //MARK: - Lifecycle
    var body: some View {
        ZStack {
            if listViewModel.items.isEmpty {
                NoListItemView()
                    .transition(AnyTransition.opacity
                        .animation(.easeIn))
            }  else  {
                List {
                    ForEach(listViewModel.items) { items in
                        ListRowView(item: items)
                            .onTapGesture {
                                withAnimation(.linear) {
                                    listViewModel.updateItem(item: items)
                                }
                            }
                    }
                    .onDelete(perform: listViewModel.deleteItem )
                    .onMove(perform: listViewModel.moveItem )
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Todo List 📝")
        .navigationBarItems(
            leading:  EditButton()
                .foregroundColor(ColorAsset.fontColor.opacity(1.0)),
            trailing:
                NavigationLink("추가하기", destination: AddView())
                .foregroundColor(ColorAsset.fontColor.opacity(1.0))
        )
    }
}
//MARK: - Previews
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListView()
        }
        .environmentObject(ListViewModel())
    }
}
