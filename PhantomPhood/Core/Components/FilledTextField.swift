//
//  FilledTextField.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI



struct FilledTextField_Previews: PreviewProvider {
    @State static var text = ""
    
    static var previews: some View {
        TextField("Test", text: $text)
            .withFilledStyle()
    }
}
