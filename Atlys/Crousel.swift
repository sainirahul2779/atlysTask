//
//  CrouserThree.swift
//  Atlys
//
//  Created by Rahul on 03/11/25.
//
import SwiftUI


struct ZStackCarousel: View {
    let items = [
        DemoCard(title: "India", image: "item1"),
        DemoCard(title: "Dubai", image: "item2"),
        DemoCard(title: "Chaina", image: "item3"),
        DemoCard(title: "Australia", image: "item4"),
        DemoCard(title: "Nepal", image: "item5")
    ]
    
    
    @State private var offset: CGFloat = 0
    @State private var centeredId: Int? = nil
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width*0.6
            let cardHeight = cardWidth
            let containerHeight = cardHeight * 2
            let sidePadding = (geo.size.width - cardWidth) / 2
            
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    // MARK: Scrollable transparent lane
                    LazyHStack(spacing: 0) {
                        Rectangle().fill(.clear)
                            .frame(width: sidePadding, height: containerHeight)
                        
                        ForEach(items.indices, id: \.self) { i in
                            let isCentered = (centeredId == i)
                            
                            let scale = isCentered ? 1.3 : 1.0
                            
                            Rectangle()
                                .fill(.clear)
                                .frame(width: cardWidth, height: containerHeight)
                                .contentShape(Rectangle())
                                .id(i)
                                .scaleEffect(scale)
                                .compositingGroup()
                        }
                        
                        Rectangle().fill(.clear)
                            .frame(width: sidePadding, height: containerHeight)
                    }
                    .scrollTargetLayout()
                    
                    // MARK: Visible cards overlay
                    GeometryReader { _ in
                        let center = offset + geo.size.width / 2
                        
                        ZStack {
                            ForEach(items.indices, id: \.self) { i in
                                let x = sidePadding + cardWidth/2 + CGFloat(i) * cardWidth
                                let isCentered = (centeredId == i)
                                let scale = isCentered ? 1.3 : 1.0
                                let z: Double = isCentered ? 1000 : (i < (centeredId ?? 0) ? 1.0 : -1.0)
                                ZStack {
                                    Image(items[i].image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: cardWidth, height: cardHeight)
                                        .clipped()                                     // cuts overflow
                                        .clipShape(RoundedRectangle(cornerRadius: 24)) // ✅ rounded mask

                                    Text(items[i].title)
                                        .font(.title.bold())
                                        .foregroundStyle(.white)
                                        .shadow(radius: 3)
                                }
                                    .frame(width: cardWidth, height: cardHeight)
                                    .scaleEffect(scale)
                                    .offset(x: x - center + sidePadding)
                                    .zIndex(z)
                                    .animation(.spring(response: 0.28, dampingFraction: 0.9), value: offset)

                            }
                        }
                        .frame(height: containerHeight)
                        
                    }
                }
            }
            .contentMargins(.horizontal, sidePadding, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $centeredId)
            .frame(height: containerHeight)
            .onPreferenceChange(OffsetKey.self) { newOffset in
                offset = newOffset
            }
            .onAppear {
                centeredId = 2
            }
        }
    }
    
}

// MARK: Offset Key
private struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}


struct DemoCard: Identifiable {
    let id = UUID()
    let title: String
    let image: String
}


#Preview {
    ZStackCarousel()
        .padding(.vertical, 40)
        .background(Color(.systemGroupedBackground))
}
