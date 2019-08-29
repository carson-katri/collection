//
//  Collection.swift
//  SwiftUITest
//
//  Created by Carson Katri on 8/28/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import SwiftUI

private class CollectionDelegate<Item, Cell>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout where Cell: View {
    let items: [Item]
    let cellContent: (Item) -> Cell
    let itemSize: CGSize
    let spacing: CGFloat
    let inset: UIEdgeInsets?
    let alignment: Alignment
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HostingCell", for: indexPath)
        let view = UIHostingController(rootView: cellContent(items[indexPath.item])).view!
        view.frame = cell.bounds
        cell.contentView.addSubview(view)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Calculate insets to fit with spacing
        let itemSpace = itemSize.width + (spacing * 2)
        let itemCount = Int(collectionView.frame.size.width / itemSpace)
        //let inset = collectionView.frame.size.width - ((itemSize.width + (spacing * 2)) * CGFloat(itemCount))
        //return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        print(itemCount)
        if let inset = self.inset {
            return inset
        } else {
//            switch alignment {
//            case .leading:
//                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.bounds.size.width - (CGFloat(itemCount) * itemSpace))
//            default:
//                break
//            }
        }
        return .zero
    }
    
    init(items: [Item], cellContent: @escaping (Item) -> Cell, itemSize: CGSize, spacing: CGFloat, inset: UIEdgeInsets) {
        self.items = items
        self.cellContent = cellContent
        self.itemSize = itemSize
        self.spacing = spacing
        self.inset = inset
        self.alignment = .center
    }
    
    init(items: [Item], cellContent: @escaping (Item) -> Cell, itemSize: CGSize, spacing: CGFloat, alignment: Alignment = .leading) {
        self.items = items
        self.cellContent = cellContent
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        self.inset = .zero
    }
}

struct Collection<Item, Cell>: UIViewRepresentable where Cell: View {
    private let delegate: CollectionDelegate<Item, Cell>
    private let itemSize: CGSize
    private let spacing: CGFloat
    private let alignment: Alignment?
    
    init(_ items: [Item], itemSize: CGSize, spacing: CGFloat, inset: UIEdgeInsets = .zero, @ViewBuilder _ cellContent: @escaping (Item) -> Cell) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = nil
        self.delegate = CollectionDelegate(items: items, cellContent: cellContent, itemSize: itemSize, spacing: spacing, inset: inset)
    }
    
    init(_ items: [Item], itemSize: CGSize, spacing: CGFloat, alignment: Alignment = .leading, @ViewBuilder _ cellContent: @escaping (Item) -> Cell) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        self.delegate = CollectionDelegate(items: items, cellContent: cellContent, itemSize: itemSize, spacing: spacing, alignment: alignment)
    }
        
    func makeUIView(context: UIViewRepresentableContext<Collection<Item, Cell>>) -> UICollectionView {
        var layout = UICollectionViewFlowLayout()
        if self.alignment == .leading {
            layout = CollectionViewLeftAlignFlowLayout()
        }
        layout.itemSize = itemSize
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    func updateUIView(_ uiView: UICollectionView, context: UIViewRepresentableContext<Collection<Item, Cell>>) {
        uiView.sizeToFit()
        uiView.backgroundColor = .clear
        uiView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HostingCell")
        uiView.delegate = self.delegate
        uiView.dataSource = self.delegate
    }
}

/*struct Collection<Row>: View where Row: View {
    let rowContent: () -> Row
    
    init(@ViewBuilder _ rowContent: @escaping () -> Row) {
        self.rowContent = rowContent
    }
    
    var body: some View {
        HStack {
            rowContent()
        }
    }
}*/

struct Collection_Previews: PreviewProvider {
    static var previews: some View {
//        Collection(["Hello", "World!", "This", "is", "a", "cool", "test"], itemSize: CGSize(width: 300, height: 100)) { text in
//            Text(text)
//                .padding()
//                .background(Color.primary.opacity(0.1))
//                .cornerRadius(5)
//        }
        Collection(["Hello", "World!", "This", "is", "a", "cool", "test"], itemSize: CGSize(width: 300, height: 100), spacing: 0, alignment: .leading) { text in
            Text(text)
                .padding(5)
                .background(Color.gray)
                .cornerRadius(5)
        }
    }
}
