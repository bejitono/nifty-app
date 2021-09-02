//
//  NFTCollectionView.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import SDWebImageSwiftUI
import SwiftUI

struct NFTCollectionView: View {
    
    let collection: NFTCollectionViewModel
    
    var body: some View {
        VStack {
            VStack {
                WebImage(url: URL(string: collection.imageURL ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .padding([.top, .leading, .trailing], 20)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 200,
                maxHeight: 200,
                alignment: .center
            )
            VStack(alignment: .center, spacing: 10) {
                Title2(collection.name)
            }
            .padding()
        }
    }
}

struct NFTCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NFTCollectionView(collection: NFTCollectionViewModel(name: "sdfs", imageURL: "www.google.com", contractAddress: "sdf"))
    }
}
