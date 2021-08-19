//
//  MultilineHStack.swift
//  Nifty
//
//  Created by Stefano on 19.08.21.
//

import SwiftUI

struct MultilineHStack<Model, Content>: View where Model: Hashable, Content: View {
    
    var models: [Model]
    var horizontalSpacing: CGFloat = 2
    var verticalSpacing: CGFloat = 0

    private let content: (Model) -> Content
    @State private var totalHeight
          = CGFloat.zero       // << variant for ScrollView/List
    //    = CGFloat.infinity   // << variant for VStack

    init(
        models: [Model],
        horizontalSpacing: CGFloat = 5,
        verticalSpacing: CGFloat = 5,
        @ViewBuilder content: @escaping (Model) -> Content
    ) {
        self.models = models
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.models, id: \.self) { model in
                content(model)
                    .padding(.horizontal, horizontalSpacing)
                    .padding(.vertical, verticalSpacing)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if (abs(width - dimension.width) > geometry.size.width)
                        {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if model == self.models.last {
                            width = 0 //last item
                        } else {
                            width -= dimension.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {dimension in
                        let result = height
                        if model == self.models.last {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
