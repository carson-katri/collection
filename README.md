# Collection

This makes it super easy to add a `UICollectionView` to your `SwiftUI` projects

```swift
Collection(["Hello", "World", "this", "is", "a", "test"], itemSize: CGSize(width: 120, height: 50), spacing: 5) { text in
    Text(text)
        .lineLimit(1)
        .padding(.leading, 5)
        .frame(width: 120, height: 50, alignment: .leading)
        .background(Color.primary.opacity(0.1))
        .cornerRadius(5)
}
.padding(5)
```
