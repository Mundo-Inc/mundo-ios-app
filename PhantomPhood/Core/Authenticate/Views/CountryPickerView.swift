//
//  CountryPickerView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/8/24.
//

import SwiftUI

struct CountryPickerView: View {
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selection: Country
    
    var body: some View {
        NavigationStack {
            VStack {
                CountryPickerViewContent(searchText: searchText, selection: $selection)
            }
            .font(.body)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText)
        }
        .presentationDetents([.medium])
    }
}

fileprivate struct CountryPickerViewContent: View {
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismiss) private var dismiss
    
    let searchText: String
    @Binding var selection: Country
    
    var body: some View {
        if isSearching {
            List(searchText.isEmpty ? Country.list : Country.list.filter({ $0.name.lowercased().contains(searchText.lowercased())})) { country in
                Button {
                    selection = country
                    dismiss()
                } label: {
                    CountryRow(country: country)
                }
                .foregroundStyle(Color.primary)
                .tag(country)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Picker("Country Code", selection: $selection) {
                ForEach(Country.list) { country in
                    CountryRow(country: country)
                        .tag(country)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

fileprivate struct CountryRow: View {
    let country: Country
    
    var body: some View {
        HStack {
            Text(country.emoji)
            Text(country.name)
            
            Spacer()
            
            Text(country.dialCode)
        }
        .foregroundStyle(Color.primary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(country.name), \(country.dialCode)")
    }
}

#Preview {
    CountryPickerView(selection: .constant(Country.US))
}
