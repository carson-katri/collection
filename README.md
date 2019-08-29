# Collection

This makes it super easy to add a `UICollectionView` to your `SwiftUI` projects

```swift
Collection(["Hello", "World!", "This", "is", "a", "cool", "test"], itemSize: CGSize(width: 300, height: 100), spacing: 0, alignment: .leading) { text in
    Text(text)
        .padding(5)
        .background(Color.gray)
        .cornerRadius(5)
}
```
