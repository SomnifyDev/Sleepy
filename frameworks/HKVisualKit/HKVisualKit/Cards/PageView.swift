// Copyright (c) 2022 Sleepy.

import SwiftUI

public struct PagingView<Content>: View where Content: View {
    @Binding private var index: Int
    private let maxIndex: Int
    private let content: () -> Content

    @State private var offset = CGFloat.zero
    @State private var dragging = false

    public init(index: Binding<Int>, maxIndex: Int, @ViewBuilder content: @escaping () -> Content) {
        _index = index
        self.maxIndex = maxIndex
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        self.content()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }
                .content.offset(x: self.offset(in: geometry), y: 0)
                .frame(width: geometry.size.width, alignment: .leading)
                .gesture(
                    DragGesture().onChanged { value in
                        self.dragging = true
                        self.offset = -CGFloat(self.index) * geometry.size.width + value.translation.width
                    }
                    .onEnded { value in
                        let predictedEndOffset = -CGFloat(self.index) * geometry.size.width + value.predictedEndTranslation.width
                        let predictedIndex = Int(round(predictedEndOffset / -geometry.size.width))
                        self.index = self.clampedIndex(from: predictedIndex)
                        withAnimation(.easeOut) {
                            self.dragging = false
                        }
                    }
                )
            }
            .clipped()

            PageControl(index: $index, maxIndex: maxIndex)
        }
    }

    func offset(in geometry: GeometryProxy) -> CGFloat {
        if self.dragging {
            return max(min(self.offset, 0), -CGFloat(self.maxIndex) * geometry.size.width)
        } else {
            return -CGFloat(self.index) * geometry.size.width
        }
    }

    func clampedIndex(from predictedIndex: Int) -> Int {
        let newIndex = min(max(predictedIndex, index - 1), index + 1)
        guard newIndex >= 0
        else {
            return 0
        }
        guard newIndex <= self.maxIndex
        else {
            return self.maxIndex
        }
        return newIndex
    }
}

struct PageControl: View {
    @Binding var index: Int
    let maxIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ... maxIndex, id: \.self) { index in
                Circle()
                    .fill(index == self.index ? Color(.lightGray) : Color.white)
                    .frame(width: 8, height: 8)
            }
        }

        .padding(.vertical, 3)
        .padding(.horizontal, 4)
        .background(Color.black.opacity(0.1))
        .cornerRadius(4)
        .padding(.trailing, 24)
        .padding(.bottom, 8)
    }
}
