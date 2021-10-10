//
//  FilterView.swift
//  Nifty
//
//  Created by Stefano on 09.10.21.
//

import SwiftUI

final class SortViewModel: ObservableObject {
    
    @Published var sortItems = SortItem.items
    
    init() {
        let user: User? = UserCache().get()
        let sortType = user?.settings.sort ?? .tokenIdAsc
        select(sortType)
    }
    
    func select(_ type: SortItem.SortType) {
        self.sortItems = sortItems.map { item in
            SortItem(
                name: item.name,
                selected: item.type == type,
                type: item.type
            )
        }
    }
}

final class SortItem: Identifiable {
    
    enum SortType: String {
        case priceDesc
        case priceAsc
        case salesDesc
        case salesAsc
        case salesDateDesc
        case salesDateAsc
        case tokenIdDesc
        case tokenIdAsc
    }
    
    let id = UUID()
    let name: String
    var selected: Bool
    let type: SortType
    
    init(name: String, selected: Bool, type: SortItem.SortType) {
        self.name = name
        self.selected = selected
        self.type = type
    }
}

extension SortItem {
    static var items = [
        SortItem(name: "Latest price (highest first)", selected: true, type: .priceDesc),
        SortItem(name: "Latest price (lowest first)", selected: false, type: .priceAsc),
        SortItem(name: "No. of sales (highest first)", selected: false, type: .salesDesc),
        SortItem(name: "No. of sales (lowest first)", selected: false, type: .salesAsc),
        SortItem(name: "Sales date (latest first)", selected: false, type: .salesDateDesc),
        SortItem(name: "Sales date (earliest first)", selected: false, type: .salesDateAsc),
        SortItem(name: "Token ID (highest first)", selected: false, type: .tokenIdDesc),
        SortItem(name: "Token ID (lowest first)", selected: false, type: .tokenIdAsc)
    ]
}

struct SortView: View {
    
    @ObservedObject var viewModel: SortViewModel = SortViewModel()
    @Binding var show: Bool
    let onFilterSelection: (SortItem.SortType) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradient()
                Form {
                    ForEach(viewModel.sortItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            CheckBoxView(checked: item.selected)
                        }
                        .onTapGesture {
                            onFilterSelection(item.type)
                            viewModel.select(item.type)
                            show = false
                        }
                    }
                    .padding([.top, .bottom], 12)
                }
                .navigationTitle("Sort collection by")
            }
        }
    }
}

struct CheckBoxView: View {
    
    var checked: Bool

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        SortView(show: .constant(true)) { type in
            print("type")
        }
    }
}
