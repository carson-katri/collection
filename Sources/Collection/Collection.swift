//
//  Collection.swift
//  Collection
//
//  Created by Carson Katri on 8/28/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import SwiftUI

private class CollectionDelegate<Cell>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate where Cell: View {
    var items: [Any]
    let cellContent: (Any, Int) -> Cell
    let itemSize: CGSize
    let spacing: CGFloat
    let inset: UIEdgeInsets?
    let alignment: Alignment
    let reorderable: Bool
    let onReorder: ([Any]) -> Void
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    /*func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        reorderable
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = items.remove(at: sourceIndexPath.item)
        items.insert(temp, at: destinationIndexPath.item)
    }*/
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.items[indexPath.item]
        let itemProvider = NSItemProvider(object: NSString(string: "\(item)"))
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destination: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destination = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destination = IndexPath(item: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            reorderItems(coordinator: coordinator, destination: destination, collectionView: collectionView)
        }
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destination: IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first, let source = item.sourceIndexPath {
            collectionView.performBatchUpdates({
                let deleted = self.items.remove(at: source.item)
                self.items.insert(deleted, at: destination.item)
                collectionView.deleteItems(at: [source])
                collectionView.insertItems(at: [destination])
            }) { _ in
                self.onReorder(self.items)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HostingCell", for: indexPath)
        let view = UIHostingController(rootView: cellContent(items[indexPath.item], indexPath.item)).view!
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
    
    init<Item>(items: [Item], cellContent: @escaping (Item, Int) -> Cell, itemSize: CGSize, spacing: CGFloat = 0, inset: UIEdgeInsets, reorderable: Bool, onReorder: @escaping ([Item]) -> Void) {
        self.items = items
        self.cellContent = { item, index in
            cellContent(item as! Item, index)
        }
        self.itemSize = itemSize
        self.spacing = spacing
        self.inset = inset
        self.alignment = .center
        self.reorderable = reorderable
        self.onReorder = { items in
            onReorder(items.map { $0 as! Item })
        }
    }
    
    init<Item>(items: [Item], cellContent: @escaping (Item, Int) -> Cell, itemSize: CGSize, spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool, onReorder: @escaping ([Item]) -> Void) {
        self.items = items
        self.cellContent = { item, index in
            cellContent(item as! Item, index)
        }
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        self.inset = .zero
        self.reorderable = reorderable
        self.onReorder = { items in
            onReorder(items.map { $0 as! Item })
        }
    }
}

public struct CollectionView: UIViewRepresentable {
    private let delegate: CollectionDelegate<AnyView>
    private let itemSize: CGSize
    private let spacing: CGFloat
    private let alignment: Alignment?
    
    public init<Cell, Item>(_ items: [Item], itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, inset: UIEdgeInsets, reorderable: Bool = false, onReorder: @escaping ([Item]) -> Void, @ViewBuilder _ cellContent: @escaping (Item, Int) -> Cell) where Cell: View {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = nil
        self.delegate = CollectionDelegate(items: items, cellContent: { item, index in
            AnyView(cellContent(item, index))
        }, itemSize: itemSize, spacing: spacing, inset: inset, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<Cell, Item>(_ items: [Item], itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Item]) -> Void, @ViewBuilder _ cellContent: @escaping (Item, Int) -> Cell) where Cell: View {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        self.delegate = CollectionDelegate(items: items, cellContent: { item, index in
            AnyView(cellContent(item, index))
        }, itemSize: itemSize, spacing: spacing, alignment: alignment, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<Cell>(_ items: ClosedRange<Int>, itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cellContent: @escaping (Int, Int) -> Cell) where Cell: View {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        self.delegate = CollectionDelegate(items: Array(items), cellContent: { item, index in
            AnyView(cellContent(item, index))
        }, itemSize: itemSize, spacing: spacing, alignment: alignment, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> A) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        self.delegate = CollectionDelegate(items: [AnyView(cells())], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View, C: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B, C)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1), AnyView(extracted.2)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View, C: View, D: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B, C, D)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1), AnyView(extracted.2), AnyView(extracted.3)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View, C: View, D: View, E: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B, C, D, E)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1), AnyView(extracted.2), AnyView(extracted.3), AnyView(extracted.4)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View, C: View, D: View, E: View, F: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B, C, D, E, F)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1), AnyView(extracted.2), AnyView(extracted.3), AnyView(extracted.4), AnyView(extracted.5)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View, C: View, D: View, E: View, F: View, G: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B, C, D, E, F, G)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1), AnyView(extracted.2), AnyView(extracted.3), AnyView(extracted.4), AnyView(extracted.5), AnyView(extracted.6)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View, C: View, D: View, E: View, F: View, G: View, H: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B, C, D, E, F, G, H)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1), AnyView(extracted.2), AnyView(extracted.3), AnyView(extracted.4), AnyView(extracted.5), AnyView(extracted.6), AnyView(extracted.7)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View, C: View, D: View, E: View, F: View, G: View, H: View, I: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B, C, D, E, F, G, H, I)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1), AnyView(extracted.2), AnyView(extracted.3), AnyView(extracted.4), AnyView(extracted.5), AnyView(extracted.6), AnyView(extracted.7), AnyView(extracted.8)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    public init<A: View, B: View, C: View, D: View, E: View, F: View, G: View, H: View, I: View, J: View>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Any]) -> Void, @ViewBuilder _ cells: () -> TupleView<(A, B, C, D, E, F, G, H, I, J)>) {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells().value
        self.delegate = CollectionDelegate(items: [AnyView(extracted.0), AnyView(extracted.1), AnyView(extracted.2), AnyView(extracted.3), AnyView(extracted.4), AnyView(extracted.5), AnyView(extracted.6), AnyView(extracted.7), AnyView(extracted.8), AnyView(extracted.9)], cellContent: { view, _ in
            view
        }, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }
    
    /*public init<Cell, Item, ID>(itemSize: CGSize = CGSize(width: 100, height: 100), spacing: CGFloat = 0, alignment: Alignment = .leading, reorderable: Bool = false, onReorder: @escaping ([Item]) -> Void, @ViewBuilder _ cells: () -> ForEach<Item, ID, Cell>) where Cell: View {
        self.itemSize = itemSize
        self.spacing = spacing
        self.alignment = alignment
        let extracted = cells()
        //self.delegate = CollectionDelegate(items: extracted.data.map { AnyView(extracted.content($0)) }, cellContent: { view, _ in
            //view
        //}, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
        self.delegate = CollectionDelegate<AnyView>(items: extracted.data.map { AnyView(extracted.content($0)) }, cellContent: { view, _ in view}, itemSize: itemSize, spacing: spacing, reorderable: reorderable, onReorder: onReorder)
    }*/
    
    public func makeUIView(context: UIViewRepresentableContext<CollectionView>) -> UICollectionView {
        var layout = UICollectionViewFlowLayout()
        if self.alignment == .leading {
            layout = CollectionViewLeftAlignFlowLayout()
        }
        layout.itemSize = itemSize
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dragInteractionEnabled = self.delegate.reorderable
        view.dragDelegate = self.delegate
        view.dropDelegate = self.delegate
        return view
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: UIViewRepresentableContext<CollectionView>) {
        uiView.sizeToFit()
        uiView.backgroundColor = .clear
        uiView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HostingCell")
        uiView.delegate = self.delegate
        uiView.dataSource = self.delegate
    }
}
